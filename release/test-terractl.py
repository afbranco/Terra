#!/usr/bin/env python3
"""Testes do terractl (#92) que não precisam do TOSSIM (a carga e a decodificação estão em
tests/terractl e tests/terractlgrp):

- quadro serial: CRC-16 (CCITT, início 0), escape de 0x7E/0x7D, CRC errado descartado;
- SerialLink numa porta serial simulada (pty): o pacote vai com PACKET_ACK e é repetido até a
  confirmação; o que o "mote" manda chega como mensagem;
- gravação: o firmware com o ID do nó sai igual ao do tos-set-symbols + avr-objcopy (o que o make
  do TinyOS faz), e com o ID 1 igual ao .ihex da release.

Uso, na imagem do tinyos-toolchain: test-terractl.py <pasta com os terra-<v>-*-micaz-*.exe>
"""
import glob
import os
import subprocess
import sys
import tempfile
import threading
import time

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from terractl import flash, framing, link  # noqa: E402

falhas = []


def confere(cond, msg):
    print(("ok: " if cond else "FALHOU: ") + msg)
    if not cond:
        falhas.append(msg)


# Quadro serial
confere(framing.crc16(b"123456789") == 0x31C3, "CRC-16 de '123456789' = 0x31C3")
corpo = bytes([framing.PROTO_PACKET_NOACK, 0, 0x7E, 0x7D, 0x20, 0xFF])
q = framing.encode(corpo)
confere(q.count(0x7E) == 2 and 0x7D in q, "0x7E e 0x7D da carga vão com escape")
d = framing.Decoder()
confere(d.feed(b"\x00\x01" + q + q[:4]) == [corpo] and d.feed(q[4:]) == [corpo], "quadro de volta, também em pedaços")
ruim = bytearray(q)
ruim[3] ^= 1
d = framing.Decoder()
confere(d.feed(bytes(ruim)) == [] and d.bad == 1, "quadro com CRC errado descartado")

# SerialLink numa pty: o "mote" ignora o primeiro envio e confirma o segundo; depois manda uma
# mensagem sem confirmação.
try:
    import serial  # noqa: F401
    tem_serial = True
except ImportError:
    tem_serial = False
if not tem_serial:
    confere(False, "pyserial ausente (python3-serial)")
else:
    mestre, escravo = os.openpty()
    import termios
    import tty
    tty.setraw(escravo)
    vistos = []

    def mote():
        dec = framing.Decoder()
        fim = time.time() + 5
        while time.time() < fim:
            for f in dec.feed(os.read(mestre, 256)):
                vistos.append(f)
                if f[0] == framing.PROTO_PACKET_ACK and len(vistos) >= 2:
                    os.write(mestre, framing.encode(bytes([framing.PROTO_ACK, f[1]])))
                    msg = link.am_packet(145, bytes([7, 0, 11, 0, 1, 42]), dest=0xFFFF, src=11)
                    os.write(mestre, framing.encode(bytes([framing.PROTO_PACKET_NOACK]) + msg))
                    return
    threading.Thread(target=mote, daemon=True).start()
    lk = link.SerialLink(os.ttyname(escravo), 57600, ack_timeout=0.2)
    chegou = []
    lk.on_message = lambda *m: chegou.append(m)
    ok = lk.send(0xA0, b"\x00\x01")
    time.sleep(0.5)
    lk.close()
    confere(ok and len(vistos) == 2 and vistos[0] == vistos[1], "PACKET_ACK repetido até a confirmação")
    confere(vistos and vistos[0][0] == framing.PROTO_PACKET_ACK and vistos[0][2:3] == b"\x00"
            and vistos[0][-3] == 0xA0, "envio com despacho AM e o tipo 0xA0")
    confere(chegou == [(145, 11, 0xFFFF, bytes([7, 0, 11, 0, 1, 42]))], "mensagem do mote entregue")
    termios.tcflush(escravo, termios.TCIOFLUSH)

# Grade do simulador (terractl sim): 8 vizinhos dentro da grade, como o TerraSim.py da .ova.
from terractl import sim  # noqa: E402
confere(len(sim.grid_links(3, 3)) == 20 and (11, 22) in sim.grid_links(3, 3)
        and (13, 21) not in sim.grid_links(3, 3), "grade 3x3: 20 enlaces, diagonais dentro da grade")
confere(sim.grid_links(1, 1) == [] and len(sim.grid_links(9, 9)) == 2 * 9 * 8 + 2 * 8 * 8, "grades 1x1 e 9x9")
confere(len(sim.noise_trace()) == 10000, "ruído do TerraSim.py com 10 mil leituras")

# Gravação com ID
exes = sorted(glob.glob(os.path.join(sys.argv[1], "terra-*-micaz-*.exe"))) if len(sys.argv) > 1 else []
confere(len(exes) == 4, "4 firmwares micaz em %s" % (sys.argv[1:] or ["?"]))


def le_ihex(p):
    mem, seg = {}, 0
    for linha in open(p):
        linha = linha.strip()
        if not linha.startswith(":"):
            continue
        b = bytes.fromhex(linha[1:])
        n, a, tipo = b[0], b[1] << 8 | b[2], b[3]
        if tipo == 2:
            seg = (b[4] << 8 | b[5]) << 4
        elif tipo == 4:
            seg = (b[4] << 8 | b[5]) << 16
        elif tipo == 0:
            for i in range(n):
                mem[seg + a + i] = b[4 + i]
    return mem


with tempfile.TemporaryDirectory() as t:
    for exe in exes:
        nome = os.path.basename(exe)
        ref = os.path.join(t, "ref.ihex")
        subprocess.run(["tos-set-symbols", "--objcopy", "avr-objcopy", "--objdump", "avr-objdump",
                        "--target", "ihex", exe, ref, "TOS_NODE_ID=11", "ActiveMessageAddressC__addr=11"],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        img = flash.with_node_id(exe, 11).image()
        confere(img == le_ihex(ref), "%s: nó 11 igual ao do tos-set-symbols" % nome)
        meu = os.path.join(t, "meu.ihex")
        open(meu, "w").write(flash.ihex(img))
        confere(le_ihex(meu) == img, "%s: .ihex do terractl de volta" % nome)
        rel = exe[:-4] + ".ihex"
        confere(flash.with_node_id(exe, 1).image() == le_ihex(rel), "%s: nó 1 igual ao .ihex da release" % nome)

print("test-terractl: " + ("; ".join(falhas) if falhas else "OK"))
sys.exit(1 if falhas else 0)
