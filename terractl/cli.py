"""terractl: loads Terra programs, shows the messages of the base station, simulates and flashes the firmware."""

import argparse
import glob
import json
import os
import re
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
    g = p.add_argument_group("connection to the base station")
    g.add_argument("--serial", metavar="PORT", help="serial port of the BS (on the MIB520, the second one: /dev/ttyUSB1)")
    g.add_argument("--baud", type=int, default=57600, help="serial speed (57600, the micaz one)")
    g.add_argument("--sf", metavar="HOST:PORT", help="SerialForwarder (default localhost:9002; TOSSIM or remote)")


def _decodificacao(p):
    g = p.add_argument_group("messages")
    g.add_argument("--terra", metavar="PROG.terra", help="decode by the pktypes of the program (runs terrac --types)")
    g.add_argument("--types", metavar="FILE.json", help="the output of terrac --types, instead of --terra")
    g.add_argument("--terrac", default=default_terrac(), help="the terrac (default: the one of the package, or the PATH)")
    g.add_argument("--pktype", action="append", default=[], metavar="[N=]NAME",
                   help="pktype of each message: NAME for all, or N=NAME for type (Net) or msgId (Grp) "
                        "N; can repeat. Not needed when the program has a single pktype")
    g.add_argument("--json", action="store_true", help="one message per line, in JSON")
    g.add_argument("--hex", action="store_true", help="only the bytes, not decoded")


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


def terra_home(*partes):
    """Pasta do pacote terra-<v>-linux-x86_64 (#95), que o bin/terractl dele põe em TERRA_HOME."""
    h = os.environ.get("TERRA_HOME")
    return os.path.join(h, *partes) if h else None


def default_terrac():
    t = terra_home("bin", "terrac")
    return t if t and os.path.exists(t) else "terrac"


def firmware_path(nome):
    """O caminho do .exe, ou um nome curto (net-bs, net-nobs, grp-bs, grp-nobs) do firmware do pacote."""
    if os.path.exists(nome) or not re.fullmatch(r"(net|grp)-(bs|nobs)", nome):
        return nome
    achados = sorted(glob.glob(terra_home("firmware", "terra-*-%s-micaz-%s.exe" % tuple(nome.split("-"))) or ""))
    if not achados:
        raise SystemExit("terractl: firmware %s not found (it comes in terra-<v>-linux-x86_64; "
                         "or give the path of the .exe)" % nome)
    return achados[-1]


def cmd_flash(a):
    a.firmware = firmware_path(a.firmware)
    elf = F.with_node_id(a.firmware, a.node)
    texto = F.ihex(elf.image())
    if a.output:
        open(a.output, "w").write(texto)
        print("terractl: %s with node %d in %s" % (a.firmware, a.node, a.output))
        if not a.port:
            return 0
    if not a.port:
        raise SystemExit("terractl: missing --port (the first port of the MIB520, /dev/ttyUSB0) or --output")
    with tempfile.TemporaryDirectory() as t:
        caminho = os.path.join(t, "no%d.ihex" % a.node)
        open(caminho, "w").write(texto)
        print("terractl: flashing %s with node %d on %s" % (os.path.basename(a.firmware), a.node, a.port))
        return F.flash(caminho, a.port, a.programmer, a.avrdude)


def cmd_sim(a):
    from . import sim
    if not a.tossim:
        a.tossim = terra_home("tossim", a.vm)
        if not a.tossim or not os.path.isdir(a.tossim):
            raise SystemExit("terractl: missing --tossim (the folder of terra-<v>-%s-tossim-py3-x86_64.tar.gz, "
                             "extracted; terra-<v>-linux-x86_64 brings it)" % a.vm)
    rc = sim.run(a, out=lambda s: print(s, flush=True))
    # O SerialForwarder do TOSSIM imprime uma estatística ao ser destruído: sai sem passar por ele.
    sys.stdout.flush()
    sys.stderr.flush()
    os._exit(rc)


def main(argv=None):
    p = argparse.ArgumentParser(prog="terractl", description=__doc__)
    p.add_argument("--version", action="version", version="terractl " + __version__)
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("load", help="load a .vmx on the network through the base station")
    s.add_argument("vmx")
    _conexao(s)
    s.add_argument("--prog-version", dest="version", type=int,
                   help="version number (default: the last one used + 1; must be greater than the one in the network)")
    s.add_argument("--time", type=float, default=30, help="seconds serving the motes (0: until Ctrl-C)")
    s.add_argument("--every", type=float, default=10, help="announce the version again every N seconds (0: no)")
    s.add_argument("--listen", action="store_true", help="also show the messages of the motes")
    _decodificacao(s)
    s.set_defaults(func=cmd_load)

    s = sub.add_parser("listen", help="show the messages that reach the base station")
    _conexao(s)
    s.add_argument("--time", type=float, default=0, help="seconds (0: until Ctrl-C)")
    s.add_argument("--all", action="store_true", help="include the block requests of a load")
    _decodificacao(s)
    s.set_defaults(func=cmd_listen)

    s = sub.add_parser("flash", help="flash a firmware of the release (.exe) with a node id")
    s.add_argument("firmware", help="terra-<v>-{net,grp}-micaz-{bs,nobs}.exe, or net-bs, net-nobs, grp-bs, "
                                    "grp-nobs (the firmware of the package terra-<v>-linux-x86_64)")
    s.add_argument("--node", type=int, required=True, help="node id (the base station is 1)")
    s.add_argument("--port", help="programming port (on the MIB520, the first one: /dev/ttyUSB0)")
    s.add_argument("--programmer", default="mib510", help="avrdude programmer (mib510 works for the MIB520)")
    s.add_argument("--avrdude", default="avrdude")
    s.add_argument("--output", "-o", help="only write the .ihex with the id to this file")
    s.set_defaults(func=cmd_flash)

    s = sub.add_parser("sim", help="simulate a grid of motes with the _TOSSIM.so of the release and show the logs")
    s.add_argument("vmx", nargs="?", help="program loaded through the BS (without it, the network waits; "
                                         "with --realtime, load it from outside with terractl load --sf)")
    s.add_argument("--tossim", metavar="FOLDER",
                   help="folder of terra-<v>-{net,grp}-tossim-py3-x86_64.tar.gz, extracted (its VM is used); "
                        "default: the one of --vm in the package terra-<v>-linux-x86_64")
    s.add_argument("--vm", choices=["net", "grp"], default="net", help="VM of the package to simulate (net)")
    s.add_argument("--grid", default="3x3", help="LINESxCOLUMNS, up to 9x9 (default 3x3); nodes column*10+line")
    s.add_argument("--time", type=float, default=60, help="simulated seconds (default 60)")
    s.add_argument("--seed", type=int, default=1, help="TOSSIM seed (the same seed gives the same simulation)")
    s.add_argument("--gain", type=float, default=sim_gain(), help="link gain in dB (85, the one of TerraSim.py)")
    s.add_argument("--load-at", type=float, default=1, help="second when the BS receives the program (1)")
    s.add_argument("--every", type=float, default=10, help="announce the version again every N simulated seconds (0: no)")
    s.add_argument("--prog-version", dest="version", type=int, help="version number (default 1)")
    s.add_argument("--late", type=int, default=0, metavar="N", help="the last N columns boot later")
    s.add_argument("--late-at", type=float, default=30, help="second when they boot (30)")
    s.add_argument("--realtime", action="store_true", help="at the pace of the clock, to connect from outside through the SerialForwarder")
    s.add_argument("--sf-port", type=int, default=9002, help="port of the TOSSIM SerialForwarder (9002)")
    s.add_argument("--vmdbg", metavar="FILE", help="write the VMDBG channel (every instruction of the VM) to this file")
    s.add_argument("--channel", action="append", default=[], metavar="CHANNEL",
                   help="also show this TOSSIM dbg channel (AM, Serial...); can repeat")
    s.add_argument("--hide", default="serial,radio", metavar="CMD,...",
                   help="TVIEW commands not shown (default: serial, since the messages to the BS are "
                        "shown decoded, and radio, one line per packet; empty shows all)")
    s.add_argument("--logdir", default=".terractl-sim", help="folder of the channel files (.terractl-sim)")
    s.add_argument("--terra", metavar="PROG.terra", help="decode the messages to the BS by the pktypes (terrac --types)")
    s.add_argument("--types", metavar="FILE.json", help="the output of terrac --types, instead of --terra")
    s.add_argument("--terrac", default=default_terrac())
    s.set_defaults(func=cmd_sim)

    a = p.parse_args(argv)
    return a.func(a)


if __name__ == "__main__":
    sys.exit(main())
