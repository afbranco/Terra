#!/usr/bin/env python3
"""Teste: versão nova no meio da disseminação, numa linha de 3 saltos (issue #74).

BS (nó 1) e os nós 11, 12 e 13 em linha (1-11-12-13). O teste faz o papel do TerraControl: manda
a versão 1 (versao2_v1.vmx, LED 1) aos 2 s, a versão 2 (versao2_v2.vmx, LED 2) aos 3 s, no meio da
disseminação da 1, e responde aos pedidos de bloco de cada versão. Todos têm de terminar na versão
2. Com a BS perdendo mensagens (#74), o anúncio da versão 2 se perdia e os três ficavam na 1 (v1.2.0,
em 4 de 12 casos com a versão 2 entre 2,6 e 4 s; por pelo menos 700 s).

Só no TOSSIM (AVRORA = False): o Avrora não monta a topologia em linha.

Uso, na imagem do tinyos-toolchain: test_versao2.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import socket
import struct
import sys

SEGUNDOS = 60
PORTA_SF = 9002
AQUI = os.path.dirname(os.path.abspath(__file__))
AVRORA = False
NOS_M = [11, 12, 13]
LINKS = [(1, 11), (11, 12), (12, 13)]
T2 = 3.0
# Último LED de cada mote: o 2 da versão 2.
ESPERADO_FIM = {11: 2, 12: 2, 13: 2}
sys.path.insert(0, sys.argv[1])
sys.path.insert(0, os.path.dirname(AQUI))
from vmtest import deploy, messages  # noqa: E402
from TOSSIM import SerialForwarder, Tossim  # noqa: E402
t = Tossim([])
t.randomSeed(1)
log = open("tview.txt", "w")
t.addChannel("TVIEW", log)
r = t.radio()
NOS = [1] + NOS_M
for x, y in LINKS:
    r.add(x, y, -60.0)
    r.add(y, x, -60.0)
for n in NOS:
    m = t.getNode(n)
    for _ in range(100):
        m.addNoiseTraceReading(-98)
    m.createNoiseModel()
tps = t.ticksPerSecond()
for n in NOS:
    t.getNode(n).bootAtTime(n * 1000003)
pacotes = deploy(os.path.join(AQUI, "versao2_v1.vmx"))
blocos = {struct.unpack(">HH", d[:4])[1]: (am, d) for am, d in pacotes[1:]}
VER = {1: (pacotes, blocos)}
p2 = deploy(os.path.join(AQUI, "versao2_v2.vmx"), 2)
VER[2] = (p2, {struct.unpack(">HH", d[:4])[1]: (am, d) for am, d in p2[1:]})


def entrega(am, dados, quando):
    """Um pacote na serial da BS (nó 1), como o TerraControl manda."""
    p = t.newSerialPacket()
    p.setData(dados)
    p.setType(am)
    p.setDestination(1)
    p.setLength(len(dados))
    p.deliver(1, quando)


for k, (am, dados) in enumerate(pacotes):
    entrega(am, dados, int((2.0 + 0.1 * k) * tps))
for k, (am, dados) in enumerate(VER[2][0]):
    entrega(am, dados, int((T2 + 0.1 * k) * tps))

# A BS é só uma ponte: os pedidos de bloco dos nós vão para a serial e quem responde é o
# TerraControl (ControlCore.messageReceived). Aqui o papel dele: lê a serial da BS pelo
# SerialForwarder do TOSSIM e responde a cada reqProgBlock (AM 0xA2: reqOper, versionId, blockId)
# com o bloco pedido, ou com a versão se o versionId é 0. E guarda as mensagens de usuário.
sf = SerialForwarder(PORTA_SF)
cli = None
for _ in range(200):
    sf.process()
    try:
        cli = socket.create_connection(("127.0.0.1", PORTA_SF), timeout=0.05)
        break
    except OSError:
        pass
cli.sendall(b"U ")
cli.setblocking(False)
buf = b""
pedidos = 0


def serial():
    """Processa o SerialForwarder e responde aos pedidos que chegaram."""
    global buf, pedidos
    sf.process()
    try:
        buf += cli.recv(4096)
    except (BlockingIOError, OSError):
        pass
    if buf.startswith(b"U "):
        buf = buf[2:]
    while buf and len(buf) > buf[0]:
        pac, buf = buf[1:1 + buf[0]], buf[1 + buf[0]:]
        if len(pac) >= 13 and pac[0] == 0 and pac[7] == messages.AM_REQPROGBLOCK:
            oper, versao, bloco = messages.parse_req_prog_block(pac[8:13])
            if versao == 0:
                entrega(*VER[2 if t.time() > T2 * tps else 1][0][0], t.time() + int(0.01 * tps))
            elif versao in VER and bloco in VER[versao][1]:
                pedidos += 1
                entrega(*VER[versao][1][bloco], t.time() + int(0.01 * tps))


def roda(ate):
    while t.time() < ate:
        t.runNextEvent()
        serial()


roda(SEGUNDOS * tps)
log.close()
cli.close()

obtido = {}
for n in NOS_M:
    obtido[n] = [int(m.group(1)) for m in (re.search(r"<<: leds %d 3 (\d+) :>>" % n, l)
                                        for l in open("tview.txt")) if m]
ok = all(obtido[n] and obtido[n][-1] == v for n, v in ESPERADO_FIM.items())
print("test_versao2: LEDs %s; %d pedidos de bloco respondidos (último esperado %s): %s"
      % (obtido, pedidos, ESPERADO_FIM, "OK" if ok else "FALHOU"))
# O SerialForwarder do TOSSIM imprime uma estatística ao terminar, depois do resultado (e o
# build-tinyos.sh olha a última linha): sai sem passar pelo fim normal do processo.
sys.stdout.flush()
os._exit(0 if ok else 1)
