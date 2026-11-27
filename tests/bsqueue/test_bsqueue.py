#!/usr/bin/env python3
"""Teste: a estação base passa à serial todas as mensagens que recebe (issue #74).

BS (nó 1) e os nós 11, 12 e 13 a um salto. Carrega o bsqueue.vmx pela serial (fazendo o papel do
TerraControl, que responde aos pedidos de bloco) e conta as mensagens de usuário (AM 145) que a BS
passa à serial pelo SerialForwarder do TOSSIM. Sem a correção, a BS tirava duas da fila a cada
envio e chegavam 2 de 4. No Avrora (tests/avrora) a contagem usa o SERIAL_USR.

Uso, na imagem do tinyos-toolchain: test_bsqueue.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import socket
import struct
import sys

SEGUNDOS = 25
PORTA_SF = 9002
AQUI = os.path.dirname(os.path.abspath(__file__))
# O 0 do VM.reset e o 1 depois do SEND_DONE, nos três motes.
ESPERADO = {11: [0, 1], 12: [0, 1], 13: [0, 1]}
# Mensagens de usuário na serial da BS: (AM, posição do v no payload, valores de v em ordem).
SERIAL_USR = (145, 5, [0, 11, 12, 13])

sys.path.insert(0, sys.argv[1])
sys.path.insert(0, os.path.dirname(AQUI))
from vmtest import deploy, messages  # noqa: E402
from TOSSIM import SerialForwarder, Tossim  # noqa: E402

t = Tossim([])
t.randomSeed(1)
log = open("tview.txt", "w")
t.addChannel("TVIEW", log)
r = t.radio()
NOS = (1,) + tuple(sorted(ESPERADO))
for a in NOS:
    for b in NOS:
        if a != b:
            r.add(a, b, -60.0)
for n in NOS:
    m = t.getNode(n)
    for _ in range(100):
        m.addNoiseTraceReading(-98)
    m.createNoiseModel()
    m.bootAtTime(n * 1000003)

tps = t.ticksPerSecond()
pacotes = deploy(os.path.join(AQUI, "bsqueue.vmx"))
blocos = {struct.unpack(">HH", d[:4])[1]: (am, d) for am, d in pacotes[1:]}


def entrega(am, dados, quando):
    """Um pacote na serial da BS (nó 1), como o TerraControl manda."""
    p = t.newSerialPacket()
    p.setData(dados)
    p.setType(am)
    p.setDestination(1)
    p.setLength(len(dados))
    p.deliver(1, quando)


# A versão e os blocos aos 2 s, um a cada 0,1 s.
for k, (am, dados) in enumerate(pacotes):
    entrega(am, dados, int((2.0 + 0.1 * k) * tps))

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
usr = []


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
                entrega(*pacotes[0], t.time() + int(0.01 * tps))
            elif bloco in blocos:
                pedidos += 1
                entrega(*blocos[bloco], t.time() + int(0.01 * tps))
        if len(pac) >= 8 and pac[0] == 0 and pac[7] == 145:
            usr.append(pac[8:])


def roda(ate):
    while t.time() < ate:
        t.runNextEvent()
        serial()


roda(SEGUNDOS * tps)
log.close()
cli.close()

obtido = {}
for n in sorted(ESPERADO):
    obtido[n] = [int(m.group(1)) for m in (re.search(r"<<: leds %d 3 (\d+) :>>" % n, l)
                                        for l in open("tview.txt")) if m]
vs = sorted(p[SERIAL_USR[1]] for p in usr if len(p) > SERIAL_USR[1])
ok = obtido == ESPERADO and vs == SERIAL_USR[2]
print("test_bsqueue: LEDs %s; mensagens de usuário na serial da BS: v = %s (esperado %s): %s"
      % (obtido, vs, SERIAL_USR[2], "OK" if ok else "FALHOU"))
# O SerialForwarder do TOSSIM imprime uma estatística ao terminar, depois do resultado (e o
# build-tinyos.sh olha a última linha): sai sem passar pelo fim normal do processo.
sys.stdout.flush()
os._exit(0 if ok else 1)
