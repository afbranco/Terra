"""terractl: carga de programas Terra, mensagens da estação base e gravação do firmware."""

import argparse
import json
import os
import sys
import tempfile
import threading
import time

from . import __version__
from . import flash as F
from . import link as L
from . import loader as LD
from . import messages as M


def sim_gain():
    return 85.0


def _conexao(p):
    g = p.add_argument_group("conexão com a estação base")
    g.add_argument("--serial", metavar="PORTA", help="porta serial da BS (na MIB520, a segunda: /dev/ttyUSB1)")
    g.add_argument("--baud", type=int, default=57600, help="velocidade da serial (57600, a do micaz)")
    g.add_argument("--sf", metavar="HOST:PORTA", help="SerialForwarder (padrão localhost:9002; TOSSIM ou remoto)")


def _decodificacao(p):
    g = p.add_argument_group("mensagens")
    g.add_argument("--terra", metavar="PROG.terra", help="decodifica pelos pktype do programa (roda o terrac --types)")
    g.add_argument("--types", metavar="ARQ.json", help="a saída do terrac --types, em vez de --terra")
    g.add_argument("--terrac", default="terrac", help="o terrac (padrão: o do PATH)")
    g.add_argument("--pktype", action="append", default=[], metavar="[N=]NOME",
                   help="pktype de cada mensagem: NOME para todas, ou N=NOME para o type (Net) ou o "
                        "msgId (Grp) N; pode repetir. Com um só pktype no programa, não precisa")
    g.add_argument("--json", action="store_true", help="uma mensagem por linha, em JSON")
    g.add_argument("--hex", action="store_true", help="só os bytes, sem decodificar")


def _decoder(a):
    types = None
    if a.types:
        types = json.load(open(a.types))
    elif a.terra:
        types = M.run_types(a.terra, a.terrac)
    mapa, nome = {}, None
    for x in a.pktype:
        if "=" in x:
            k, v = x.split("=", 1)
            mapa[int(k, 0)] = v
        else:
            nome = x
    return M.Decoder(None if a.hex else types, mapa, nome)


class Saida:
    def __init__(self, a, t0):
        self.a, self.t0, self.dec = a, t0, _decoder(a)
        self.lock = threading.Lock()

    def mensagem(self, am, src, payload):
        m = self.dec.decode(am, src, payload)
        m["t"] = round(time.time() - self.t0, 3)
        with self.lock:
            if self.a.json:
                print(json.dumps(m, ensure_ascii=False), flush=True)
            else:
                print("%8.2f s  %s" % (m["t"], M.format_text(m)), flush=True)

    def log(self, txt):
        with self.lock:
            if self.a.json:
                print(json.dumps({"t": round(time.time() - self.t0, 3), "log": txt}, ensure_ascii=False),
                      flush=True)
            else:
                print("%8.2f s  %s" % (time.time() - self.t0, txt), file=sys.stderr, flush=True)


def _espera(segundos):
    try:
        if segundos > 0:
            time.sleep(segundos)
        else:
            while True:
                time.sleep(3600)
    except KeyboardInterrupt:
        pass


def cmd_load(a):
    prog = LD.Program(a.vmx)
    t0 = time.time()
    out = Saida(a, t0)
    lk = L.open_link(a.serial, a.sf, a.baud)
    ld = LD.Loader(lk, prog, a.version, log=out.log)

    def recebe(am, src, dest, payload):
        if not ld.handle(am, src, payload) and a.listen:
            out.mensagem(am, src, payload)
    lk.on_message = recebe
    ld.start()
    fim = t0 + a.time

    def reanuncia():
        while time.time() < fim or a.time <= 0:
            time.sleep(a.every)
            ld.announce()
    if a.every > 0:
        threading.Thread(target=reanuncia, daemon=True).start()
    _espera(a.time - (time.time() - t0) if a.time > 0 else 0)
    out.log(ld.resumo())
    lk.close()
    return 0


def cmd_listen(a):
    t0 = time.time()
    out = Saida(a, t0)
    lk = L.open_link(a.serial, a.sf, a.baud)
    lk.on_message = lambda am, src, dest, payload: (
        None if am == M.AM_REQPROGBLOCK and not a.all else out.mensagem(am, src, payload))
    _espera(a.time)
    lk.close()
    return 0


def cmd_flash(a):
    elf = F.with_node_id(a.firmware, a.node)
    texto = F.ihex(elf.image())
    if a.output:
        open(a.output, "w").write(texto)
        print("terractl: %s com o nó %d em %s" % (a.firmware, a.node, a.output))
        if not a.port:
            return 0
    if not a.port:
        raise SystemExit("terractl: falta --port (a primeira porta da MIB520, /dev/ttyUSB0) ou --output")
    with tempfile.TemporaryDirectory() as t:
        caminho = os.path.join(t, "no%d.ihex" % a.node)
        open(caminho, "w").write(texto)
        print("terractl: gravando %s com o nó %d em %s" % (os.path.basename(a.firmware), a.node, a.port))
        return F.flash(caminho, a.port, a.programmer, a.avrdude)


def cmd_sim(a):
    from . import sim
    rc = sim.run(a, out=lambda s: print(s, flush=True))
    # O SerialForwarder do TOSSIM imprime uma estatística ao ser destruído: sai sem passar por ele.
    sys.stdout.flush()
    sys.stderr.flush()
    os._exit(rc)


def main(argv=None):
    p = argparse.ArgumentParser(prog="terractl", description=__doc__)
    p.add_argument("--version", action="version", version="terractl " + __version__)
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("load", help="carrega um .vmx na rede pela estação base")
    s.add_argument("vmx")
    _conexao(s)
    s.add_argument("--prog-version", dest="version", type=int,
                   help="número da versão (padrão: a última usada + 1; tem de ser maior que a da rede)")
    s.add_argument("--time", type=float, default=30, help="segundos atendendo os motes (0: até Ctrl-C)")
    s.add_argument("--every", type=float, default=10, help="reanuncia a versão a cada N segundos (0: não)")
    s.add_argument("--listen", action="store_true", help="mostra também as mensagens dos motes")
    _decodificacao(s)
    s.set_defaults(func=cmd_load)

    s = sub.add_parser("listen", help="mostra as mensagens que chegam à estação base")
    _conexao(s)
    s.add_argument("--time", type=float, default=0, help="segundos (0: até Ctrl-C)")
    s.add_argument("--all", action="store_true", help="inclui os pedidos de bloco da carga")
    _decodificacao(s)
    s.set_defaults(func=cmd_listen)

    s = sub.add_parser("flash", help="grava o firmware da release (.exe) com o ID do nó")
    s.add_argument("firmware", help="terra-<v>-{net,grp}-micaz-{bs,nobs}.exe")
    s.add_argument("--node", type=int, required=True, help="ID do nó (a estação base é o 1)")
    s.add_argument("--port", help="porta de gravação (na MIB520, a primeira: /dev/ttyUSB0)")
    s.add_argument("--programmer", default="mib510", help="programador do avrdude (mib510 serve à MIB520)")
    s.add_argument("--avrdude", default="avrdude")
    s.add_argument("--output", "-o", help="só grava o .ihex com o ID neste arquivo")
    s.set_defaults(func=cmd_flash)

    s = sub.add_parser("sim", help="simula uma grade de motes com o _TOSSIM.so da release e mostra os logs")
    s.add_argument("vmx", nargs="?", help="programa carregado pela BS (sem ele, a rede fica esperando; "
                                         "com --realtime, carregue de fora com terractl load --sf)")
    s.add_argument("--tossim", required=True, metavar="PASTA",
                   help="pasta do terra-<v>-{net,grp}-tossim-py3-x86_64.tar.gz extraído (a VM é a dele)")
    s.add_argument("--grid", default="3x3", help="LINHASxCOLUNAS, até 9x9 (padrão 3x3); nós coluna*10+linha")
    s.add_argument("--time", type=float, default=60, help="segundos simulados (padrão 60)")
    s.add_argument("--seed", type=int, default=1, help="semente do TOSSIM (a simulação se repete com ela)")
    s.add_argument("--gain", type=float, default=sim_gain(), help="ganho dos enlaces em dB (85, o do TerraSim.py)")
    s.add_argument("--load-at", type=float, default=1, help="segundo em que a BS recebe o programa (1)")
    s.add_argument("--every", type=float, default=10, help="reanuncia a versão a cada N segundos simulados (0: não)")
    s.add_argument("--prog-version", dest="version", type=int, help="número da versão (padrão 1)")
    s.add_argument("--late", type=int, default=0, metavar="N", help="as últimas N colunas ligam depois")
    s.add_argument("--late-at", type=float, default=30, help="segundo em que elas ligam (30)")
    s.add_argument("--realtime", action="store_true", help="no ritmo do relógio, para conectar de fora pelo SerialForwarder")
    s.add_argument("--sf-port", type=int, default=9002, help="porta do SerialForwarder do TOSSIM (9002)")
    s.add_argument("--vmdbg", metavar="ARQ", help="grava o canal VMDBG (cada instrução da VM) neste arquivo")
    s.add_argument("--channel", action="append", default=[], metavar="CANAL",
                   help="mostra também este canal de dbg do TOSSIM (AM, Serial...); pode repetir")
    s.add_argument("--hide", default="serial", metavar="CMD,...",
                   help="comandos do TVIEW que não aparecem (padrão: serial, já que as mensagens à BS "
                        "saem decodificadas; vazio mostra tudo)")
    s.add_argument("--logdir", default=".terractl-sim", help="pasta dos arquivos dos canais (.terractl-sim)")
    s.add_argument("--terra", metavar="PROG.terra", help="decodifica as mensagens à BS pelos pktype (terrac --types)")
    s.add_argument("--types", metavar="ARQ.json", help="a saída do terrac --types, em vez de --terra")
    s.add_argument("--terrac", default="terrac")
    s.set_defaults(func=cmd_sim)

    a = p.parse_args(argv)
    return a.func(a)


if __name__ == "__main__":
    sys.exit(main())
