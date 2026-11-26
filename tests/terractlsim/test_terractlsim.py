#!/usr/bin/env python3
"""Teste: a simulação local (`terractl sim`, #94).

Grade 3x3 na VM Net, com a última coluna (31, 32, 33) ligada aos 8 s. O programa é o de
tests/terractl (o nó 11 manda três mensagens à BS). Confere que os 9 motes recebem o programa
(vmstart de cada um, os da última coluna depois de ligados), as três mensagens decodificadas pelo
pktype, os LEDs do 11 e que duas execuções com a mesma semente dão a mesma saída.

Uso, na imagem do tinyos-toolchain: test_terractlsim.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import os
import re
import subprocess
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(AQUI))
PROG = os.path.join(RAIZ, "tests", "terractl")
MOTES = [11, 12, 13, 21, 22, 23, 31, 32, 33]
CAMPOS = "type=7 source=11 target=1 n=%d u16=4660 s16=-2 s32=-100000 u32=3000000000 f=1.5 v=[1, 250] b=-7"


def roda():
    r = subprocess.run([sys.executable, "-m", "terractl", "sim", os.path.join(PROG, "terractl.vmx"),
                        "--tossim", sys.argv[1], "--grid", "3x3", "--time", "20", "--late", "1",
                        "--late-at", "8", "--types", os.path.join(PROG, "terractl.types.json")],
                       capture_output=True, text=True, timeout=300,
                       env=dict(os.environ, PYTHONPATH=RAIZ, PYTHONDONTWRITEBYTECODE="1"))
    return r.returncode, r.stdout + r.stderr


rc, saida = roda()
_, saida2 = roda()
linhas = saida.splitlines()
inicio = {}
for l in linhas:
    m = re.match(r"\s*([\d.]+)  <<: vmstart (\d+) ", l)
    if m:
        inicio.setdefault(int(m.group(2)), float(m.group(1)))
msgs = [l.split("leitura  ", 1)[1] for l in linhas if "BS: node 11  leitura  " in l]
leds = [int(m.group(1)) for m in (re.search(r"<<: leds 11 3 (\d+) :>>", l) for l in linhas) if m]
tardios_ok = all(inicio.get(n, 0) > 8 for n in (31, 32, 33))
ok = (rc == 0 and sorted(inicio) == MOTES and tardios_ok and msgs == [CAMPOS % i for i in range(3)]
      and leds == [0, 1, 2, 3] and saida == saida2 and "serial" not in saida)
print("test_terractlsim: vmstart em %s (31-33 depois de 8 s: %s); %d mensagens decodificadas; LEDs do 11: "
      "%s; mesma saída com a mesma semente: %s: %s"
      % (sorted(inicio), tardios_ok, len(msgs), leds, saida == saida2, "OK" if ok else "FALHOU"))
if not ok:
    print(saida[-3000:])
sys.exit(0 if ok else 1)
