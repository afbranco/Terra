"""Ligação com a estação base: direto na porta serial (MIB520) ou por um SerialForwarder (o do TinyOS,
o do TOSSIM ou um remoto). As duas entregam e recebem pacotes Active Message:
(am, origem, destino, carga)."""

import socket
import struct
import sys
import threading
import time

from . import framing

AM_GROUP = 0x22          # TOS_AM_GROUP padrão do TinyOS
BS_ADDR = 1              # a estação base é o nó 1 (o TerraControl também manda para o 1)


def am_packet(am, payload, dest=BS_ADDR, src=0, group=AM_GROUP):
    """Despacho AM + cabeçalho (destino, origem, tamanho, grupo, tipo) + carga."""
    return bytes([framing.DISPATCH_AM]) + struct.pack(">HHBBB", dest, src, len(payload), group, am) + payload


def parse_am(pkt):
    """(am, origem, destino, carga) de um pacote AM, ou None se não for AM."""
    if len(pkt) < 8 or pkt[0] != framing.DISPATCH_AM:
        return None
    dest, src, n, _group, am = struct.unpack(">HHBBB", pkt[1:8])
    return am, src, dest, bytes(pkt[8:8 + n])


class Link:
    """Base: `on_message(am, src, dest, payload)` é chamado na thread de leitura."""

    def __init__(self):
        self.on_message = None
        self._closed = False

    def _deliver(self, pkt):
        m = parse_am(pkt)
        if m and self.on_message:
            self.on_message(*m)

    def send(self, am, payload, dest=BS_ADDR):
        raise NotImplementedError

    def close(self):
        self._closed = True


class SFLink(Link):
    """SerialForwarder: TCP, os dois lados mandam "U " e depois cada pacote vai com 1 byte de
    tamanho na frente. O "U " vai logo depois da conexão e a resposta é conferida na thread de
    leitura: o SerialForwarder do TOSSIM lê o "U " bloqueado dentro do sf.process(), sem soltar o
    GIL, e uma espera aqui travaria os dois quando a simulação roda numa thread do mesmo processo."""

    def __init__(self, host="localhost", port=9002, timeout=30):
        super().__init__()
        fim = time.time() + timeout
        while True:
            try:
                self.s = socket.create_connection((host, port), timeout=5)
                break
            except OSError:
                if time.time() > fim:
                    raise
                time.sleep(0.2)
        self.s.sendall(b"U ")
        self.s.settimeout(None)
        self.where = "%s:%d" % (host, port)
        self._lock = threading.Lock()
        threading.Thread(target=self._reader, daemon=True).start()

    def _recv_exact(self, n):
        d = b""
        while len(d) < n:
            x = self.s.recv(n - len(d))
            if not x:
                return d
            d += x
        return d

    def _reader(self):
        try:
            if self._recv_exact(2) != b"U ":
                print("terractl: the SerialForwarder at %s did not answer the protocol" % self.where,
                      file=sys.stderr)
                return
        except OSError:
            return
        while not self._closed:
            try:
                n = self._recv_exact(1)
                if not n:
                    return
                self._deliver(self._recv_exact(n[0]))
            except OSError:
                return

    def send(self, am, payload, dest=BS_ADDR):
        p = am_packet(am, payload, dest)
        with self._lock:
            self.s.sendall(bytes([len(p)]) + p)
        return True

    def close(self):
        super().close()
        try:
            self.s.close()
        except OSError:
            pass


class SerialLink(Link):
    """Porta serial da estação base (na MIB520, a segunda porta; 57600 bauds no micaz). Cada pacote
    vai com PACKET_ACK e é repetido até o mote confirmar, como o SerialForwarder faz."""

    def __init__(self, port, baud=57600, ack_timeout=0.25, retries=5):
        super().__init__()
        try:
            import serial  # pyserial
        except ImportError:
            raise SystemExit("terractl: --serial needs pyserial (it comes inside terractl-<v>.pyz; "
                             "from the source tree: pip install pyserial)")
        self.ser = serial.Serial(port, baud, timeout=0.05)
        self.ack_timeout, self.retries = ack_timeout, retries
        self.dec = framing.Decoder()
        self._seq = 0
        self._acks = set()
        self._cv = threading.Condition()
        self._wlock = threading.Lock()
        threading.Thread(target=self._reader, daemon=True).start()

    def _reader(self):
        while not self._closed:
            try:
                data = self.ser.read(256)
            except Exception:
                return
            for f in self.dec.feed(data):
                if f[0] == framing.PROTO_ACK and len(f) >= 2:
                    with self._cv:
                        self._acks.add(f[1])
                        self._cv.notify_all()
                elif f[0] == framing.PROTO_PACKET_NOACK:
                    self._deliver(f[1:])
                elif f[0] == framing.PROTO_PACKET_ACK and len(f) >= 2:
                    self._deliver(f[2:])

    def send(self, am, payload, dest=BS_ADDR):
        with self._wlock:
            self._seq = (self._seq + 1) % 256
            seq = self._seq
            frame = framing.encode(bytes([framing.PROTO_PACKET_ACK, seq]) + am_packet(am, payload, dest))
            for _ in range(self.retries):
                with self._cv:
                    self._acks.discard(seq)
                self.ser.write(frame)
                with self._cv:
                    if self._cv.wait_for(lambda: seq in self._acks, self.ack_timeout):
                        return True
            return False

    def close(self):
        super().close()
        try:
            self.ser.close()
        except Exception:
            pass


def open_link(serial=None, sf=None, baud=57600):
    if serial:
        return SerialLink(serial, baud)
    host, _, port = (sf or "localhost:9002").rpartition(":")
    return SFLink(host or "localhost", int(port))
