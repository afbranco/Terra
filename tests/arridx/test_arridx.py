#!/usr/bin/env python3
"""Teste: índice de array fora do limite sem desandar a pilha (issue #43).

Carrega o arridx.vmx no nó 11 pela estação base (nó 1), como o test_floatcmp.py, e lê no TVIEW
os LEDs. Sem a correção, a VM reinicia no meio do laço (ver o arridx.terra).

Uso, na imagem do tinyos-toolchain: test_arridx.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import struct
import sys

SEGUNDOS = 30
BLOCK_SIZE = 24
AQUI = os.path.dirname(os.path.abspath(__file__))
# O 0 do VM.reset, 1 no começo e 2 depois das 1000 voltas.
ESPERADO = [0, 1, 2]

sys.path.insert(0, sys.argv[1])
from TOSSIM import Tossim  # noqa: E402

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
r.add(1, 11, -60.0)
r.add(11, 1, -60.0)
for n in (1, 11):
    m = t.getNode(n)
    for _ in range(100):
        m.addNoiseTraceReading(-98)
    m.createNoiseModel()
    m.bootAtTime(n * 1000003)

tps = t.ticksPerSecond()
# Duas rodadas, como o TerraControl repete o anúncio: na primeira, um bloco pode se perder.
for rodada in (2.0, 10.0):
    for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "arridx.vmx"))):
        p = t.newSerialPacket()
        p.setData(dados)
        p.setType(am)
        p.setDestination(1)
        p.setLength(len(dados))
        p.deliver(1, int((rodada + 0.1 * k) * tps))

fim = SEGUNDOS * tps
while t.time() < fim:
    t.runNextEvent()
log.close()

leds = [int(m.group(1)) for m in (re.search(r"<<: leds 11 3 (\d+) :>>", l) for l in open("tview.txt")) if m]
ok = leds == ESPERADO
print("test_arridx: LEDs do nó 11: %s (esperado %s): %s" % (leds, ESPERADO, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
