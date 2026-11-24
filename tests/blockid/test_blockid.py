#!/usr/bin/env python3
"""Teste: bloco de programa com blockId fora da memória da VM (issue #49).

Entrega pelo rádio, direto aos nós 11 e 12 (sem estação base, como o test_inq.py), o blockid.vmx.
Aos 6 s, manda ao nó 11 um newProgBlock da versão certa com um blockId que, vezes 24 e com a
volta do uint16, aponta além da memória da VM do nó 11. No TOSSIM a memória de cada nó é uma
linha de um vetor só, então o endereço cai na memória do nó 12, sobre o buf[20] do programa dele.
Sem a correção, o nó 11 grava ali os 24 bytes do bloco (todos 5) e o nó 12 mostra 5 nos LEDs. Com a
correção, o nó 11 descarta o bloco e o 12 continua com 1.

O tamanho da memória da VM (VM_MEM_BLKS) vem do tamanho do símbolo TerraVMC$CEU_data no
_TOSSIM.so (1000 nós x 24 x VM_MEM_BLKS bytes).

Uso, na imagem do tinyos-toolchain: test_blockid.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import struct
import subprocess
import sys

SEGUNDOS = 12
BLOCK_SIZE = 24
NOS_TOSSIM = 1000
AQUI = os.path.dirname(os.path.abspath(__file__))
# O 0 do VM.reset e o 1 do programa (o 5 aparece se o bloco do 11 cai na memória do 12).
ESPERADO = [0, 1]

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


def blocos_vm():
    """VM_MEM_BLKS do _TOSSIM.so, pelo tamanho do TerraVMC$CEU_data."""
    nm = subprocess.run(["nm", "-S", os.path.join(sys.argv[1], "_TOSSIM.so")],
                        capture_output=True, text=True, check=True).stdout
    tam = next(int(l.split()[1], 16) for l in nm.splitlines() if l.endswith(" TerraVMC$CEU_data"))
    return tam // NOS_TOSSIM // BLOCK_SIZE


# blockId do bloco inválido: blockId * 24 (uint16) = 65536 + memória do nó 11 + 32, ou seja, o byte
# 32 da memória do nó 12 (o buf do programa começa no 17; o buf[20] está no 37). O bit desse
# blockId no mapa de blocos cai bem depois do nó 12 (num nó que não existe, com o bit zerado), então
# o bloco não é tomado por repetido.
mem_no = blocos_vm() * BLOCK_SIZE
ALVO = 32
assert (65536 + mem_no + ALVO) % BLOCK_SIZE == 0, mem_no
BLOCO_RUIM = (65536 + mem_no + ALVO) // BLOCK_SIZE

t = Tossim([])
t.randomSeed(1)
log = open("tview.txt", "w")
t.addChannel("TVIEW", log)
for n in (11, 12):
    m = t.getNode(n)
    for _ in range(100):
        m.addNoiseTraceReading(-98)
    m.createNoiseModel()
    m.bootAtTime(n * 1000003)
tps = t.ticksPerSecond()


def entrega(no, am, dados, quando):
    p = t.newPacket()
    p.setSource(2)
    p.setDestination(0xffff)
    p.setType(am)
    p.setData(dados)
    p.setLength(len(dados))
    p.deliver(no, int(quando * tps))


# O programa nos dois nós: a versão e, 10 ms depois, um bloco a cada 50 ms.
for no in (11, 12):
    for k, (am, dados) in enumerate(deploy(os.path.join(AQUI, "blockid.vmx"))):
        entrega(no, am, dados, 2.0 + (k > 0) * 0.01 + k * 0.05)
# O bloco inválido, ao nó 11.
entrega(11, 161, struct.pack('>HH24s', 1, BLOCO_RUIM, bytes([5] * BLOCK_SIZE)), 6.0)

while t.time() < SEGUNDOS * tps:
    t.runNextEvent()
log.close()

leds = {n: [int(x.group(1)) for x in (re.search(r"<<: leds %d 3 (\d+) :>>" % n, l)
                                      for l in open("tview.txt")) if x] for n in (11, 12)}
ok = leds[12] == ESPERADO
print("test_blockid: VM_MEM_BLKS=%d, blockId %d ao nó 11; LEDs do nó 12: %s (esperado %s; "
      "nó 11: %s): %s" % (mem_no // BLOCK_SIZE, BLOCO_RUIM, leds[12], ESPERADO, leds[11],
                          "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
