"""Carga de um programa na rede, como o TerraControl: anuncia a versão nova pela estação base, manda os
blocos e responde aos pedidos de bloco dos motes."""

import os
import threading
import time

from . import messages as M


class Program:
    """Um .vmx: a primeira linha é o cabeçalho (startProg, endProg, nTracks, wClocks, asyncs,
    wClock0, gate0, inEvts, async0); cada linha seguinte tem o byte em hex nas colunas 0-1 e o
    endereço nas colunas 5-9."""

    def __init__(self, path):
        with open(path) as f:
            self.header = [int(x) for x in f.readline().split()]
            mem = {}
            for linha in f:
                try:
                    mem[int(linha[5:10])] = int(linha[0:2], 16)
                except ValueError:
                    pass
        if len(self.header) < 9 or not mem:
            raise SystemExit("terractl: %s não parece um .vmx" % path)
        self.start = self.header[0] // M.BLOCK_SIZE
        self.nblocks = max(mem) // M.BLOCK_SIZE + 1 - self.start
        self.blocks = {b: bytes(mem.get(b * M.BLOCK_SIZE + j, 0) for j in range(M.BLOCK_SIZE))
                       for b in range(self.start, self.start + self.nblocks)}


def state_file():
    base = os.environ.get("XDG_STATE_HOME") or os.path.join(os.path.expanduser("~"), ".local", "state")
    return os.path.join(base, "terractl", "version")


def last_version():
    try:
        return int(open(state_file()).read().strip())
    except (OSError, ValueError):
        return 0


def save_version(v):
    p = state_file()
    try:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, "w") as f:
            f.write("%d\n" % v)
    except OSError:
        pass


class Loader:
    """`log(texto)` recebe o andamento. A versão tem de ser maior que a da rede (o mote descarta a
    igual ou menor); se um mote pede uma versão maior, a carga passa para a seguinte."""

    def __init__(self, link, prog, version=None, log=print, gap=0.15, persist=True):
        """`persist`: guarda a versão usada (False no simulador, que começa da versão 0)."""
        self.link, self.prog, self.log, self.gap, self.persist = link, prog, log, gap, persist
        self.version = version or ((last_version() if persist else 0) + 1)
        if not 1 <= self.version <= 0xFFFF:
            raise SystemExit("terractl: versão %d fora de 1..65535" % self.version)
        self.pedidos = 0           # pedidos de bloco atendidos (chegam todos com a origem da BS, que
        self.blocos_pedidos = set()  # os repassa: não dá para saber qual mote pediu)
        self._lock = threading.RLock()
        self._ultimo_anuncio = 0

    def announce(self):
        self._ultimo_anuncio = time.time()
        self.link.send(M.AM_NEWPROGVERSION,
                       M.new_prog_version(self.version, self.prog.header, self.prog.nblocks, self.prog.start))

    def send_block(self, b):
        self.link.send(M.AM_NEWPROGBLOCK, M.new_prog_block(self.version, b, self.prog.blocks[b]))

    def push(self):
        """Anuncia e manda todos os blocos (o que se perder, os motes pedem)."""
        with self._lock:
            self.announce()
            for b in sorted(self.prog.blocks):
                if self.gap:
                    time.sleep(self.gap)
                self.send_block(b)

    def start(self):
        if self.persist:
            save_version(self.version)
        self.log("versão %d, %d blocos (%d a %d)" % (self.version, self.prog.nblocks, self.prog.start,
                                                      self.prog.start + self.prog.nblocks - 1))
        self.push()

    def handle(self, am, src, payload):
        """Trata um reqProgBlock; devolve True se a mensagem era da carga."""
        if am != M.AM_REQPROGBLOCK or len(payload) < 5:
            return False
        _oper, v, b = M.parse_req_prog_block(payload)
        with self._lock:
            if v == self.version and b in self.prog.blocks:
                self.pedidos += 1
                self.blocos_pedidos.add(b)
                self.send_block(b)
            elif v > self.version:
                self.version = v + 1
                if self.persist:
                    save_version(self.version)
                self.log("a rede já está na versão %d: a carga passa para a %d" % (v, self.version))
                if self.gap:
                    threading.Thread(target=self.push, daemon=True).start()
                else:
                    self.push()         # sem espera entre os blocos (o simulador espaça)
            elif time.time() - self._ultimo_anuncio > 1:
                self.announce()      # pediu a versão (0) ou tem uma antiga
        return True

    def resumo(self):
        if not self.pedidos:
            return "versão %d: nenhum pedido de bloco (os blocos enviados bastaram, ou ninguém recebeu)" % self.version
        return "versão %d: %d pedido(s) de bloco atendido(s), blocos %s" % (
            self.version, self.pedidos, sorted(self.blocos_pedidos))
