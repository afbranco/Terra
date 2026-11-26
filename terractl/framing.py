"""Quadro serial do TinyOS 2 (TEP 113), como o SerialP do mote e o tos.py do TinyOS.

Um quadro é [0x7E] dados-com-escape [0x7E]. Os dados são o byte de protocolo, o número de sequência
(só no PACKET_ACK), o despacho (0 = Active Message), o cabeçalho AM, a carga e o CRC-16 (CCITT,
polinômio 0x1021, início 0, em little-endian) de tudo o que vem antes dele. 0x7E e 0x7D dentro dos
dados viram 0x7D seguido do byte xor 0x20.
"""

FLAG = 0x7E
ESC = 0x7D

PROTO_ACK = 67           # resposta do mote a um PACKET_ACK: [67][seq]
PROTO_PACKET_ACK = 68    # pacote que pede confirmação: [68][seq][despacho]...
PROTO_PACKET_NOACK = 69  # pacote sem confirmação: [69][despacho]...

DISPATCH_AM = 0


def crc16(data, crc=0):
    for b in data:
        crc ^= b << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) if crc & 0x8000 else (crc << 1)
            crc &= 0xFFFF
    return crc


def escape(data):
    out = bytearray()
    for b in data:
        if b in (FLAG, ESC):
            out += bytes([ESC, b ^ 0x20])
        else:
            out.append(b)
    return bytes(out)


def encode(body):
    """O quadro completo de `body` (protocolo em diante, sem o CRC)."""
    c = crc16(body)
    return bytes([FLAG]) + escape(bytes(body) + bytes([c & 0xFF, c >> 8])) + bytes([FLAG])


class Decoder:
    """Junta os bytes que chegam da serial em quadros. `feed` devolve os quadros completos e com CRC
    certo (protocolo em diante, sem o CRC); os com CRC errado contam em `bad`."""

    def __init__(self):
        self.buf = None      # None: fora de um quadro
        self.esc = False
        self.bad = 0

    def feed(self, data):
        frames = []
        for b in data:
            if b == FLAG:
                if self.buf is not None and len(self.buf) >= 3:
                    body, got = bytes(self.buf[:-2]), self.buf[-2] | (self.buf[-1] << 8)
                    if crc16(body) == got:
                        frames.append(body)
                    else:
                        self.bad += 1
                self.buf = bytearray()   # o 0x7E que fecha um quadro também abre o seguinte
                self.esc = False
            elif self.buf is None:
                continue
            elif b == ESC:
                self.esc = True
            else:
                self.buf.append(b ^ 0x20 if self.esc else b)
                self.esc = False
        return frames
