#!/usr/bin/env python3
"""Teste: TerraGrp, mensagem do mote para a estação base (SEND_BS, pelo CTP).

Carrega o grpbs.vmx pela estação base (nó 1) no nó 11, como o test_floatcmp.py, mas com o
_TOSSIM.so do Grp. O mote acende 1, manda a mensagem e acende 2 no SENDBS_DONE. No Avrora
(tests/avrora/avrora_vmx.py) também se confere a mensagem na serial da BS (SERIAL_ESPERADO).

Uso, na imagem do tinyos-toolchain: test_grpbs.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import sys

SEGUNDOS = 30
AQUI = os.path.dirname(os.path.abspath(__file__))
# Este teste é do Grp: o release/build-tinyos.sh o roda com o _TOSSIM.so e o firmware do Grp.
VM = "grp"
# LEDs do mote: o 0 do VM.reset, 1 e 2.
ESPERADO = {11: [0, 1, 2]}
# Na serial da BS (só no Avrora): AM 150 (sendBS_t), Sender 11 e os dados a = 90 e b = 165.
SERIAL_ESPERADO = (150, 11, bytes([90, 165]))

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
    for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "grpbs.vmx"))):
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
print("test_grpbs: LEDs por nó: %s (esperado %s): %s" % (obtido, ESPERADO, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
