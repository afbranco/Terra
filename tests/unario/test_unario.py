#!/usr/bin/env python3
"""Teste: operador unário em campo de registro e em elemento de array (issue #104).

O nó 11 e a estação base (nó 1, que carrega o unario.vmx pela serial), na VM Grp. Ver o
unario.terra.

Uso, na imagem do tinyos-toolchain: test_unario.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import sys

SEGUNDOS = 20
AQUI = os.path.dirname(os.path.abspath(__file__))
VM = "grp"
# O 0 do VM.reset; no 11, as três checagens certas.
ESPERADO = {11: [0, 7]}

sys.path.insert(0, sys.argv[1])
sys.path.insert(0, os.path.dirname(AQUI))
from vmtest import deploy  # noqa: E402
from TOSSIM import Tossim  # noqa: E402

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
# Duas rodadas, como o TerraControl repete o anúncio: na primeira, um bloco pode se perder.
for rodada in (2.0, 10.0):
    for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "unario.vmx"))):
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

obtido = {n: [int(m.group(1)) for m in (re.search(r"<<: leds %d 3 (\d+) :>>" % n, l)
                                    for l in open("tview.txt")) if m] for n in ESPERADO}
ok = obtido == ESPERADO
print("test_unario: LEDs por nó: %s (esperado %s): %s" % (obtido, ESPERADO, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
