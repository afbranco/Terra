#!/usr/bin/env python3
"""Teste: TerraGrp, a mensagem do SEND_BS chega à serial depois de um pacote da serial (#98).

BS (nó 1) e o nó 11. Carrega o bsdest.vmx pela serial (fazendo o papel do TerraControl) e, aos
13 s, repete pela serial o anúncio da versão (o TerraControl repete o anúncio; o mote o descarta).
Aos 20 s do programa o 11 manda uma mensagem à BS (SEND_BS, pelo CTP). A BS tirava o destino da
mensagem do que tinha sobrado no buffer: depois de um pacote da serial, mandava-a para o rádio, que
a recusava, e a descartava. O teste confere a mensagem na serial (AM 150, Sender 11, dados 90 165).

Uso, na imagem do tinyos-toolchain: test_bsdest.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import socket
import struct
import sys

SEGUNDOS = 45
BLOCK_SIZE = 24
PORTA_SF = 9002
AQUI = os.path.dirname(os.path.abspath(__file__))
# Este teste é do Grp: o release/build-tinyos.sh o roda com o _TOSSIM.so e o firmware do Grp.
VM = "grp"
# LEDs do mote: o 0 do VM.reset, 1 e 2.
ESPERADO = {11: [0, 1, 2]}
# Na serial da BS: AM 150 (sendBS_t), Sender 11 e os dados a = 90 e b = 165.
SERIAL_ESPERADO = (150, 11, bytes([90, 165]))
# Pacotes extras na serial da BS: (AM, payload em hexa, segundos depois de carregar o programa).
# A repetição do anúncio da versão (newProgVersion do bsdest.vmx; conferido com o deploy abaixo).
SERIAL_EXTRA = [(0xA0, "0001000300010026004e0001000100000000000800010008", 13)]

sys.path.insert(0, sys.argv[1])
from TOSSIM import SerialForwarder, Tossim  # noqa: E402

def deploy(vmx, version_id=1):
    """Os pacotes do TerraControl para um .vmx: (AM, payload)."""
    with open(vmx) as f:
        cab = [int(x) for x in f.readline().split()]
        mem = {}
        for linha in f:
            try:
                mem[int(linha[5:10])] = int(linha[0:2], 16)
            except ValueError:
                pass
    start = cab[0] // BLOCK_SIZE
    nblocos = max(mem) // BLOCK_SIZE + 1 - start
    # newProgVersion: versionId, blockLen, blockStart, startProg, endProg, nTracks, wClocks,
    # asyncs, wClock0, gate0, inEvts, async0 (big-endian, 12 x uint16)
    pacotes = [(0xA0, struct.pack('>12H', version_id, nblocos, start, *cab[:9]))]
    for b in range(start, start + nblocos):
        dados = bytes(mem.get(b * BLOCK_SIZE + j, 0) for j in range(BLOCK_SIZE))
        pacotes.append((0xA1, struct.pack('>HH24s', version_id, b, dados)))
    return pacotes


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
pacotes = deploy(os.path.join(AQUI, "bsdest.vmx"))
assert pacotes[0] == (SERIAL_EXTRA[0][0], bytes.fromhex(SERIAL_EXTRA[0][1])), "SERIAL_EXTRA desatualizado"
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
for am, hx, seg in SERIAL_EXTRA:
    entrega(am, bytes.fromhex(hx), int((2.0 + seg) * tps))

# A BS é só uma ponte: os pedidos de bloco dos nós vão para a serial e quem responde é o
# TerraControl (ControlCore.messageReceived). Aqui o papel dele: lê a serial da BS pelo
# SerialForwarder do TOSSIM e responde a cada reqProgBlock (AM 0xA2: reqOper, versionId, blockId)
# com o bloco pedido, ou com a versão se o versionId é 0.
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
mensagem = False


def serial():
    """Processa o SerialForwarder e responde aos pedidos que chegaram."""
    global buf, pedidos, mensagem
    sf.process()
    try:
        buf += cli.recv(4096)
    except (BlockingIOError, OSError):
        pass
    if buf.startswith(b"U "):
        buf = buf[2:]
    while buf and len(buf) > buf[0]:
        pac, buf = buf[1:1 + buf[0]], buf[1 + buf[0]:]
        am, sender, dados = SERIAL_ESPERADO
        if (len(pac) >= 10 and pac[0] == 0 and pac[7] == am
                and struct.unpack(">H", pac[8:10])[0] == sender and dados in pac[8:]):
            mensagem = True
        if len(pac) >= 13 and pac[0] == 0 and pac[7] == 0xA2:
            oper, versao, bloco = struct.unpack(">BHH", pac[8:13])
            if versao == 0:
                entrega(*pacotes[0], t.time() + int(0.01 * tps))
            elif bloco in blocos:
                pedidos += 1
                entrega(*blocos[bloco], t.time() + int(0.01 * tps))


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
ok = obtido == ESPERADO and mensagem
print("test_bsdest: LEDs %s (esperado %s); serial da BS: %s: %s"
      % (obtido, ESPERADO, "mensagem esperada" if mensagem else "SEM a mensagem",
         "OK" if ok else "FALHOU"))
# O SerialForwarder do TOSSIM imprime uma estatística ao terminar, depois do resultado (e o
# build-tinyos.sh olha a última linha): sai sem passar pelo fim normal do processo.
sys.stdout.flush()
os._exit(0 if ok else 1)
