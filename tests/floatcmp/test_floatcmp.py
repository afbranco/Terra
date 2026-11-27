#!/usr/bin/env python3
"""Teste: comparação de float guardada numa variável inteira (issue #17).

Carrega o floatcmp.vmx no nó 11 pela estação base (nó 1), como o test_wclock.py, e lê no TVIEW
os valores que o programa mostra nos LEDs, um por segundo: o resultado de cada comparação de
float. Passa se a sequência é a esperada (o verdadeiro vale 1 em qualquer tipo inteiro).

Uso, na imagem do tinyos-toolchain: test_floatcmp.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import sys

SEGUNDOS = 30
AQUI = os.path.dirname(os.path.abspath(__file__))
# O 0 do VM.reset (a VM apaga os LEDs ao receber o programa); depois a, b, c, d, e, h (verdadeiros,
# em ubyte), k + 2 (falso), y (ushort), z == 1 (ulong), (f > g) == 1 e o `if f > g` direto.
ESPERADO = [0, 1, 1, 1, 1, 1, 1, 2, 1, 4, 6, 3]

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
    for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "floatcmp.vmx"))):
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
print("test_floatcmp: LEDs do nó 11: %s (esperado %s): %s" % (leds, ESPERADO, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
