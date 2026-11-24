#!/usr/bin/env python3
"""Roda um teste da VM (tests/<nome>/) no Avrora, com o firmware micaz de verdade, em vez do TOSSIM.

Pega o que o TOSSIM (x86) não pega: tamanho de tipos e alinhamento do AVR (#41), int de 16 bits,
o código do avr-gcc, o rádio CC2420 e a serial da estação base.

Montagem, como no laboratório: o nó 0 do Avrora é a estação base (firmware BS, TOS_NODE_ID 1) e os
seguintes são os motes (NOBS) com os IDs das chaves do ESPERADO do test_<nome>.py (uma lista vale
para o nó 11). O mínimo de nós: a CPU é emulada e cada nó custa. O monitor real-time segura a simulação
no ritmo do relógio: numa máquina rápida ela andaria à frente e acabaria antes de o programa chegar
pela serial (aconteceu no CI). A serial da BS fica num socket
(monitor serial do Avrora); nele se liga o SerialForwarder do TinyOS (net.tinyos.sf, o mesmo que o
TerraControl usa com a MIB520), e este script fala com o SerialForwarder: manda o <nome>.vmx nos
pacotes do TerraControl e lê o que a BS manda para a serial. Os LEDs vêm do monitor de LEDs.

O Avrora só mostra mudança de LED: dois valores iguais seguidos aparecem como um. Por isso a
comparação é com o ESPERADO sem repetições seguidas. Num teste da VM o 1 é acerto e outro valor
é erro, então um erro continua aparecendo.

Uso, na imagem do tinyos-toolchain:
  avrora_vmx.py <pasta com terra-*-{net,grp}-micaz-{bs,nobs}.exe> <pasta do teste>
Roda numa pasta gravável (grava ali os .exe com os IDs e a saída do Avrora, avrora.txt).
Cada teste leva de 1 a 2 minutos.
"""
import glob
import os
import re
import socket
import struct
import subprocess
import sys
import threading
import time

CPU_HZ = 7372800
BLOCK_SIZE = 24
PORTA_AVRORA = 2390
PORTA_SF = 9002
TINYOS_JAR = "/opt/tinyos-2.1.2/support/sdk/java/tinyos.jar"
fw, pasta = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])
nome = os.path.basename(pasta)
fonte = open(os.path.join(pasta, "test_%s.py" % nome)).read()


def constante(var):
    m = re.search(r"^%s = (.*)$" % var, fonte, re.M)
    return eval(m.group(1), {}) if m else None   # o arquivo é do próprio repositório


ESPERADO = constante("ESPERADO")
if isinstance(ESPERADO, list):
    ESPERADO = {11: ESPERADO}
SEGUNDOS = constante("SEGUNDOS")
SERIAL_ESPERADO = constante("SERIAL_ESPERADO")   # (AM, Sender, bytes que aparecem nos dados)
VM = constante("VM") or "net"
MOTES = sorted(ESPERADO)
esperado = {n: [v for i, v in enumerate(e) if i == 0 or v != e[i - 1]] for n, e in ESPERADO.items()}


def com_id(exe, no):
    """O .exe com o ID do nó gravado, como o tos-set-symbols faz na instalação."""
    saida = "no%d.exe" % no
    subprocess.run(["tos-set-symbols", "--exe", exe, saida, "TOS_NODE_ID=%d" % no,
                    "ActiveMessageAddressC__addr=%d" % no], check=True, stdout=subprocess.DEVNULL)
    return saida


exes = [com_id(glob.glob(os.path.join(fw, "terra-*-%s-micaz-bs.exe" % VM))[0], 1)]
nobs = glob.glob(os.path.join(fw, "terra-*-%s-micaz-nobs.exe" % VM))[0]
exes += [com_id(nobs, n) for n in MOTES]


def deploy(vmx, version_id=1):
    """Os pacotes do TerraControl para um .vmx: (AM, payload). Igual aos testes do TOSSIM."""
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
    pacotes = [(0xA0, struct.pack('>12H', version_id, nblocos, start, *cab[:9]))]
    for b in range(start, start + nblocos):
        dados = bytes(mem.get(b * BLOCK_SIZE + j, 0) for j in range(BLOCK_SIZE))
        pacotes.append((0xA1, struct.pack('>HH24s', version_id, b, dados)))
    return pacotes


cmd = ["java", "-jar", "/opt/avrora.jar", "-simulation=sensor-network", "-platform=micaz",
       "-input=elf", "-nodecount=" + ",".join(["1"] * len(exes)), "-update-node-id=false",
       "-colors=false", "-monitors=leds,serial,packet,real-time", "-ports=0:0:%d" % PORTA_AVRORA,
       "-seconds=%d" % (SEGUNDOS + 15)] + exes
av = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)

# Lê a saída do Avrora numa thread: LEDs de cada mote e quantos pacotes a BS (nó 0) já mandou pelo
# rádio, para só passar o pacote seguinte depois que ela repassou o anterior.
leds = {n: [] for n in MOTES}
estado = {"bs_tx": 0}
saida = open("avrora.txt", "w")


def le_avrora():
    for linha in av.stdout:
        saida.write(linha)
        m = re.match(r"\s*(\d+)\s+(\d+)\s+(on|off)\s+(on|off)\s+(on|off)\s*$", linha)
        if m and int(m.group(1)) > 0:
            v = (m.group(5) == "on") + 2 * (m.group(4) == "on") + 4 * (m.group(3) == "on")
            leds[MOTES[int(m.group(1)) - 1]].append((int(m.group(2)), v))
        elif re.match(r"\s*0\s+\d+\s+---->", linha):
            estado["bs_tx"] += 1


threading.Thread(target=le_avrora, daemon=True).start()


def espera(cond, limite):
    fim = time.time() + limite
    while not cond() and time.time() < fim and av.poll() is None:
        time.sleep(0.05)


# O SerialForwarder liga na serial da BS (o Avrora espera essa conexão para começar).
time.sleep(1)
sf = subprocess.Popen(["java", "-cp", TINYOS_JAR, "net.tinyos.sf.SerialForwarder", "-no-gui",
                       "-comm", "network@127.0.0.1:%d" % PORTA_AVRORA, "-port", str(PORTA_SF)],
                      stdout=open("sf.txt", "w"), stderr=subprocess.STDOUT)
s = None
for _ in range(300):
    try:
        s = socket.create_connection(("127.0.0.1", PORTA_SF))
        break
    except OSError:
        time.sleep(0.2)
# Protocolo do SerialForwarder: os dois lados mandam "U " e depois pacotes com 1 byte de tamanho.
s.sendall(b"U ")
assert s.recv(2) == b"U ", "SerialForwarder não respondeu"
recebidos = []


def le_sf():
    buf = b""
    while True:
        try:
            d = s.recv(4096)
        except OSError:
            return
        if not d:
            return
        buf += d
        while buf and len(buf) > buf[0]:
            recebidos.append(buf[1:1 + buf[0]])
            buf = buf[1 + buf[0]:]


threading.Thread(target=le_sf, daemon=True).start()


def envia(am, payload):
    """Pacote AM da serial (despacho 0, destino 1, origem 0, tamanho, grupo 0x22, tipo)."""
    pac = bytes([0]) + struct.pack(">HHBBB", 1, 0, len(payload), 0x22, am) + payload
    s.sendall(bytes([len(pac)]) + pac)


def depois_do_boot(n):
    return [v for c, v in leds[n] if c >= 1.5 * CPU_HZ]


espera(lambda: all(len(leds[n]) >= 2 for n in MOTES), 120)   # padrão de LEDs do boot
# Rodadas, como o TerraControl repete o anúncio, até todos os motes receberem o programa (o
# VM.reset apaga os LEDs). Um pacote que a BS não repassou pelo rádio vai de novo.
for rodada in range(5):
    for am, dados in deploy(os.path.join(pasta, nome + ".vmx")):
        for tentativa in range(3):
            antes = estado["bs_tx"]
            envia(am, dados)
            espera(lambda: estado["bs_tx"] > antes, 5)
            if estado["bs_tx"] > antes:
                break
    espera(lambda: all(depois_do_boot(n) for n in MOTES), 10)
    if all(depois_do_boot(n) for n in MOTES) or av.poll() is not None:
        break


def obtido():
    """LEDs de cada mote depois do boot, um valor por emit, sem repetições seguidas."""
    r = {}
    for n in MOTES:
        # Um emit LEDS(n) muda até 3 LEDs, um de cada vez, a poucos ciclos um do outro: junta as
        # mudanças a menos de 1000 ciclos. Ignora o primeiro segundo e meio (boot).
        grupos = []
        for c, v in list(leds[n]):
            if c < 1.5 * CPU_HZ:
                continue
            if grupos and c - grupos[-1][0] < 1000:
                grupos[-1] = (c, v)
            else:
                grupos.append((c, v))
        r[n] = [v for i, (c, v) in enumerate(grupos) if i == 0 or v != grupos[i - 1][1]]
    return r


def serial_ok():
    """A BS passou para a serial a mensagem esperada (AM, Sender nos 2 primeiros bytes, dados)."""
    if SERIAL_ESPERADO is None:
        return True
    am, sender, dados = SERIAL_ESPERADO
    for p in list(recebidos):
        if len(p) >= 8 and p[0] == 0 and p[7] == am:
            payload = p[8:]
            if struct.unpack(">H", payload[:2])[0] == sender and dados in payload:
                return True
    return False


# Para cedo quando tudo fecha (e mais uns segundos, para ver se vem algo a mais).
espera(lambda: obtido() == esperado and serial_ok(), 900)
if av.poll() is None and obtido() == esperado and serial_ok():
    time.sleep(8)
    av.terminate()
av.wait()
sf.terminate()
saida.close()

res = obtido()
ok = res == esperado and serial_ok()
extra = ""
if SERIAL_ESPERADO is not None:
    extra = "; serial da BS: %s" % ("mensagem esperada" if serial_ok() else
                                     "SEM a mensagem (%d pacotes)" % len(recebidos))
print("avrora %s (%s, %d nós): LEDs: %s (esperado %s)%s: %s"
      % (nome, VM, len(exes), res, esperado, extra, "OK" if ok else "FALHOU"))
sys.exit(0 if ok else 1)
