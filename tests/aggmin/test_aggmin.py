#!/usr/bin/env python3
"""Teste: TerraGrp, agregação MIN com leituras acima de 32767 (issue #49).

Grava o sensors.bin com temperatura 40000 em todos os nós e entrega pelo rádio, direto ao nó 11
(sem estação base, como o test_inq.py), o aggmin.vmx. O programa faz a agregação MIN e depois a
MAX da temperatura no próprio grupo e mostra 1 nos LEDs para cada uma que dá 40000. Sem a
correção, o MIN começava em 0x7fff e dava 32767 (LEDs 2).

Uso, na imagem do tinyos-toolchain: test_aggmin.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM lê ali o sensors.bin; sem o nó 1, ninguém o recria).
"""
import os
import re
import struct
import sys

SEGUNDOS = 15
AQUI = os.path.dirname(os.path.abspath(__file__))
# Este teste é do Grp: o release/build-tinyos.sh o roda com o _TOSSIM.so do Grp.
VM = "grp"
# O 0 do VM.reset, o 1 do MIN e o 1 do MAX.
ESPERADO = [0, 1, 1]
TEMP = 40000

sys.path.insert(0, sys.argv[1])
sys.path.insert(0, os.path.dirname(AQUI))
from vmtest import deploy  # noqa: E402
from TOSSIM import Tossim  # noqa: E402


# sensors.bin (XComps/dataSensorP.nc): 100 registros {uint16 temp, photo, volt}, na ordem do host.
with open("sensors.bin", "wb") as f:
    f.write(struct.pack("=3H", TEMP, 400, 1000) * 100)

t = Tossim([])
t.randomSeed(1)
log = open("tview.txt", "w")
t.addChannel("TVIEW", log)
m = t.getNode(11)
for _ in range(100):
    m.addNoiseTraceReading(-98)
m.createNoiseModel()
m.bootAtTime(1000003)
tps = t.ticksPerSecond()
for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "aggmin.vmx"))):
    p = t.newPacket()
    p.setSource(2)
    p.setDestination(0xffff)
    p.setType(am)
    p.setData(dados)
    p.setLength(len(dados))
    p.deliver(11, int((2.0 + (k > 0) * 0.01 + k * 0.05) * tps))
while t.time() < SEGUNDOS * tps:
    t.runNextEvent()
log.close()

leds = [int(x.group(1)) for x in (re.search(r"<<: leds 11 3 (\d+) :>>", l) for l in open("tview.txt")) if x]
ok = leds == ESPERADO
print("test_aggmin: temperatura %d; LEDs do nó 11 (MIN, MAX): %s (esperado %s): %s"
      % (TEMP, leds, ESPERADO, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
