#!/usr/bin/env python3
"""Teste mínimo de um módulo TOSSIM do Terra: importa, dá boot em dois nós com rádio entre
eles e simula 30 s. Falha se o módulo não carregar, se a simulação não avançar ou se algum
nó não ligar. Uso: smoke-tossim.py <pasta com _TOSSIM.so e TOSSIM.py>"""
import sys

sys.path.insert(0, sys.argv[1])
from TOSSIM import Tossim  # noqa: E402

t = Tossim([])
r = t.radio()
for a, b in ((1, 2), (2, 1)):
    r.add(a, b, -60.0)
for n in (1, 2):
    m = t.getNode(n)
    for _ in range(100):
        m.addNoiseTraceReading(-98)
    m.createNoiseModel()
    m.bootAtTime(n * 1000)

end = 30 * t.ticksPerSecond()
events = 0
while t.time() < end:
    if not t.runNextEvent():
        break
    events += 1

ok = t.time() >= end and all(t.getNode(n).isOn() for n in (1, 2)) and events > 100
print(f"smoke-tossim: {events} eventos, t={t.time() / t.ticksPerSecond():.1f} s:",
      "OK" if ok else "FALHOU")
sys.exit(0 if ok else 1)
