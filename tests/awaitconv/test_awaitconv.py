#!/usr/bin/env python3
"""Teste: `x = await EVT´ converte o valor quando o tipo de x difere do evento (issue #117).

Grava o sensors.bin com temperatura 40000 em todos os nós e entrega pelo rádio, direto ao nó 11
(sem estação base, como o test_aggmin.py), o awaitconv.vmx. O programa lê a temperatura (ushort)
num ubyte, num ulong e num float, e o CUSTOM_A (ubyte) num ushort e num elemento de array, e
acende um bit por grupo certo. Sem a correção, nenhum (LEDs 0).

Só no TOSSIM (AVRORA = False): no Avrora a temperatura vem do ADC, não do sensors.bin.

Uso, na imagem do tinyos-toolchain: test_awaitconv.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM lê ali o sensors.bin; sem o nó 1, ninguém o recria).
"""
import os
import re
import struct
import sys

SEGUNDOS = 15
BLOCK_SIZE = 24
AQUI = os.path.dirname(os.path.abspath(__file__))
AVRORA = False
# O 0 do VM.reset e os três bits.
ESPERADO = [0, 7]
TEMP = 40000

sys.path.insert(0, sys.argv[1])
from TOSSIM import Tossim  # noqa: E402


def deploy(vmx, version_id=1):
    """As mensagens de disseminação para um .vmx: (AM, payload), como as do TerraControl."""
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
    pacotes = [(160, struct.pack('>12H', version_id, nblocos, start, *cab[:9]))]
    for b in range(start, start + nblocos):
        dados = bytes(mem.get(b * BLOCK_SIZE + j, 0) for j in range(BLOCK_SIZE))
        pacotes.append((161, struct.pack('>HH24s', version_id, b, dados)))
    return pacotes


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
for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "awaitconv.vmx"))):
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
print("test_awaitconv: temperatura %d; LEDs do nó 11: %s (esperado %s): %s"
      % (TEMP, leds, ESPERADO, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
