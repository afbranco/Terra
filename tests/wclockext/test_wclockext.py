#!/usr/bin/env python3
"""Teste: timer criado depois de um evento externo (issue #40).

Carrega o wclockext.vmx pela estação base, como o test_floatcmp.py, nos motes 11 e 12. O 12 manda
duas mensagens ao 11, com 1,5 s entre elas; o 11 mede 2 s com dois await de 1 s a partir da
primeira. Com o bug, o segundo await saía na hora (ver o .terra). Também roda no Avrora.

Uso, na imagem do tinyos-toolchain: test_wclockext.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import sys

SEGUNDOS = 30
AQUI = os.path.dirname(os.path.abspath(__file__))
# LEDs de cada mote: o 0 do VM.reset; no 11, 1 (mensagem 2) e depois 2 (os 2 s); no 12, 3 no fim.
ESPERADO = {11: [0, 1, 2], 12: [0, 3]}

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
    for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "wclockext.vmx"))):
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
print("test_wclockext: LEDs por nó: %s (esperado %s): %s" % (obtido, ESPERADO, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
