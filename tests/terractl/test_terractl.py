#!/usr/bin/env python3
"""Teste: o terractl (#92) carrega um programa e decodifica as mensagens pelo pktype.

A estação base (nó 1) e o nó 11, na VM Net, com o SerialForwarder do TOSSIM na serial da BS e a
simulação em tempo real (Throttle). Numa thread, o terractl, como biblioteca, faz o papel do
TerraControl: anuncia a versão, manda os blocos, responde aos pedidos de bloco e lê as mensagens.
O 11 manda três mensagens com campos de todos os tipos; o teste confere cada campo decodificado
pelo terractl.types.json (a saída do terrac --types, conferida no build-terrac.sh).

Uso, na imagem do tinyos-toolchain: test_terractl.py <pasta com _TOSSIM.so e TOSSIM.py>
Roda numa pasta gravável (a VM cria ali o sensors.bin).
"""
import json
import os
import re
import sys
import tempfile
import threading
import time
import traceback

SEGUNDOS = 25
NOME = "test_terractl"
PORTA_SF = 9013
AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(AQUI))
ESPERADO_LEDS = [0, 1, 2, 3]
CAMPOS = {"type": 7, "source": 11, "target": 1, "u16": 4660, "s16": -2, "s32": -100000,
          "u32": 3000000000, "f": 1.5, "v": [1, 250], "b": -7}

sys.path.insert(0, sys.argv[1])
sys.path.insert(0, RAIZ)
from TOSSIM import SerialForwarder, Throttle, Tossim  # noqa: E402
from terractl import link, loader, messages  # noqa: E402

os.environ["XDG_STATE_HOME"] = tempfile.mkdtemp()     # a versão guardada não vem de fora

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

def desiste(motivo):
    """O teste nunca fica preso: imprime o motivo e sai (os._exit, como no fim)."""
    print("%s: %s: FALHOU" % (NOME, motivo))
    sys.stdout.flush()
    os._exit(1)


threading.Timer(SEGUNDOS * 4, desiste, ("passou de %d s de relógio" % (SEGUNDOS * 4),)).start()
sf = SerialForwarder(PORTA_SF)
th = Throttle(t, 10)
th.initialize()
tps = t.ticksPerSecond()
fim_sim = [False]


def simula():
    try:
        while not fim_sim[0] and t.time() < SEGUNDOS * tps:
            t.runNextEvent()
            sf.process()
            th.checkThrottle()
    except Exception:
        traceback.print_exc()
        desiste("a simulação parou com exceção")
    fim_sim[0] = True


# Conecta antes de a simulação começar: o sf.process() do TOSSIM lê o "U " do cliente bloqueado e
# sem soltar o GIL; com o "U " já no socket, não espera (ver link.SFLink).
try:
    lk = link.SFLink("127.0.0.1", PORTA_SF)
except OSError:
    traceback.print_exc()
    desiste("sem conexão com o SerialForwarder do TOSSIM")
threading.Thread(target=simula, daemon=True).start()

recebidas = []
registro = []
dec = messages.Decoder(json.load(open(os.path.join(AQUI, "terractl.types.json"))))
ld = loader.Loader(lk, loader.Program(os.path.join(AQUI, "terractl.vmx")), log=registro.append)


def recebe(am, src, dest, payload):
    if not ld.handle(am, src, payload):
        recebidas.append(dec.decode(am, src, payload))


lk.on_message = recebe
time.sleep(1)               # as duas VMs dão boot
ld.start()
while not fim_sim[0]:
    time.sleep(0.2)
lk.close()
log.close()

leds = [int(x.group(1)) for x in (re.search(r"<<: leds 11 3 (\d+) :>>", l) for l in open("tview.txt")) if x]
msgs = [m for m in recebidas if m.get("pktype") == "leitura"]
ns = [m["fields"]["n"] for m in msgs]
certos = all({k: m["fields"][k] for k in CAMPOS} == CAMPOS for m in msgs)
ok = leds == ESPERADO_LEDS and ns == [0, 1, 2] and certos
print("test_terractl: %s; %s; LEDs do 11: %s (esperado %s); mensagens n = %s (esperado [0, 1, 2]); "
      "campos %s: %s" % (registro[0] if registro else "-", ld.resumo(), leds, ESPERADO_LEDS, ns,
                         "certos" if certos else ("ERRADOS: %s" % (msgs[:1],)), "OK" if ok else "FALHOU"))
sys.stdout.flush()
os._exit(0 if ok else 1)
