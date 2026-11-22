#!/usr/bin/env python3
"""Teste: um `await` de 0 ms não pode congelar o relógio simulado (issue #19).

Carrega o await0.vmx (laço com `await (z)ms`, z = 0, que troca o LED0 a cada 100 voltas) no nó 11,
pela estação base (nó 1), como o TerraControl faz: a versão (AM 0xA0) e os blocos (AM 0xA1)
entram como pacote serial no nó 1. Depois simula até SEGUNDOS, com um teto de eventos.

Passa se o relógio chega a SEGUNDOS e o nó 11 trocou o LED (o programa rodou). Com o bug, o timer
de 0 ms é reagendado no mesmo instante para sempre: o teto de eventos estoura com o relógio
parado.

Uso, na imagem do tinyos-toolchain: test_wclock.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import struct
import sys

SEGUNDOS = 30
TETO_DE_EVENTOS = 2000000
BLOCK_SIZE = 24
AQUI = os.path.dirname(os.path.abspath(__file__))

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
    for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "await0.vmx"))):
        p = t.newSerialPacket()
        p.setData(dados)
        p.setType(am)
        p.setDestination(1)
        p.setLength(len(dados))
        p.deliver(1, int((rodada + 0.1 * k) * tps))

fim, eventos = SEGUNDOS * tps, 0
while t.time() < fim and eventos < TETO_DE_EVENTOS:
    t.runNextEvent()
    eventos += 1
log.close()

leds = sum(1 for linha in open("tview.txt") if "<<: leds 11 " in linha)
ok = t.time() >= fim and leds > 0
print("test_wclock: %d eventos, t=%.3f s, LED do nó 11 trocado %d vezes: %s"
      % (eventos, t.time() / tps, leds, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
