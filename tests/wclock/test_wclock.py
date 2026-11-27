#!/usr/bin/env python3
"""Teste: um `await` de 0 ms não pode congelar o relógio simulado (issue #19).

Carrega o await0.vmx (laço com `await (z)ms`, z = 0, que troca o LED0 a cada 100 voltas) no nó 11,
pela estação base (nó 1), como o TerraControl faz: a versão (AM 0xA0) e os blocos (AM 0xA1)
entram como pacote serial no nó 1. Depois simula até SEGUNDOS, com um teto de eventos.

Passa se o relógio chega a SEGUNDOS e o nó 11 trocou o LED (o programa rodou: a linha de LED do
VM.reset, na carga, não conta). Com o bug, o timer
de 0 ms é reagendado no mesmo instante para sempre: o teto de eventos estoura com o relógio
parado.

Uso, na imagem do tinyos-toolchain: test_wclock.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import sys

SEGUNDOS = 30
TETO_DE_EVENTOS = 2000000
AQUI = os.path.dirname(os.path.abspath(__file__))

sys.path.insert(0, sys.argv[1])
sys.path.insert(0, os.path.dirname(AQUI))
from vmtest import deploy  # noqa: E402
from TOSSIM import Tossim  # noqa: E402


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
# a primeira linha é a do VM.reset na carga: o programa rodou se houve mais alguma (#164)
ok = t.time() >= fim and leds > 1
print("test_wclock: %d eventos, t=%.3f s, LED do nó 11 trocado %d vezes: %s"
      % (eventos, t.time() / tps, leds, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
