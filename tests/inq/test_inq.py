#!/usr/bin/env python3
"""Teste: fila de entrada do nó com mensagens em rajada (issue #39).

Entrega pelo rádio, direto ao nó 11, o anúncio de versão e, 10 ms depois, todos os blocos do
inq.vmx no mesmo instante (sem estação base: nenhum vizinho responde a um pedido de bloco). Cada mensagem tem de ser
processada: se um bloco se perde, a VM não começa e os LEDs não mudam. Passa se os LEDs mostram a
sequência do programa. Uma segunda rodada, com 50 ms entre as mensagens, serve de controle.

Uso, na imagem do tinyos-toolchain: test_inq.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin). Cada rodada é um processo: o TOSSIM é um
só por processo, e uma segunda simulação herdaria o relógio e os nós da primeira.
"""
import os
import re
import subprocess
import sys

SEGUNDOS = 15
AQUI = os.path.dirname(os.path.abspath(__file__))
# O 0 do VM.reset (a VM apaga os LEDs ao receber o programa) e os cinco valores do programa.
ESPERADO = [0, 1, 2, 3, 4, 5]

sys.path.insert(0, sys.argv[1])
sys.path.insert(0, os.path.dirname(AQUI))
from vmtest import deploy  # noqa: E402
from TOSSIM import Tossim  # noqa: E402


def rodar(intervalo):
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
    pacotes = deploy(os.path.join(AQUI, "inq.vmx"))
    for k, (am, dados) in enumerate(pacotes):
        p = t.newPacket()
        p.setSource(2)
        p.setDestination(0xffff)
        p.setType(am)
        p.setData(dados)
        p.setLength(len(dados))
        # a versão primeiro, e os blocos 10 ms depois: um bloco que chega antes de a versão ser
        # processada é descartado na recepção (e, no mesmo instante, o TOSSIM não garante a ordem)
        p.deliver(11, int((2.0 + (k > 0) * 0.01 + k * intervalo) * tps))
    while t.time() < SEGUNDOS * tps:
        t.runNextEvent()
    log.close()
    leds = [int(x.group(1)) for x in (re.search(r"<<: leds 11 3 (\d+) :>>", l) for l in open("tview.txt")) if x]
    return len(pacotes), leds


if len(sys.argv) > 2:          # uma rodada: test_inq.py <pasta> <intervalo>
    n, leds = rodar(float(sys.argv[2]))
    print(n, " ".join(map(str, leds)))
    sys.exit(0)


def rodada(intervalo):
    out = subprocess.run([sys.executable, __file__, sys.argv[1], str(intervalo)],
                         capture_output=True, text=True, check=True).stdout.split("\n")[-2].split()
    return int(out[0]), [int(x) for x in out[1:]]


n, controle = rodada(0.05)
n, rajada = rodada(0.0)
ok = rajada == ESPERADO and controle == ESPERADO
print("test_inq: %d mensagens; LEDs do nó 11 com 50 ms entre elas: %s; todas juntas: %s "
      "(esperado %s): %s" % (n, controle, rajada, ESPERADO, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
