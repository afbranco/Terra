"""Simulação local (#94) com o _TOSSIM.so da release: uma grade de motes, a estação base (nó 1) ligada
ao 11, o programa carregado pela serial da BS (como o terractl faz numa rede real) e os logs na tela.
É o TerraSim.py da .ova em Python 3, sem o visualizador (decisão do Prof., 2026-11-25).

Nós: coluna*10 + linha (11, 12, ... 21, 22, ...), até 9 linhas e 9 colunas; cada um ouve os 8 vizinhos
da grade, com o ganho e o ruído do TerraSim.py (85 dB e o meyer-heavy_short.txt).
"""

import os
import pkgutil
import re
import socket
import sys

from . import link as L
from . import loader as LD
from . import messages as M

GAIN = 85.0


def noise_trace():
    """O ruído do TerraSim.py antigo (10 mil leituras do meyer-heavy do TinyOS)."""
    try:
        d = pkgutil.get_data(__name__.rpartition(".")[0], "meyer-heavy_short.txt")
    except OSError:
        d = None
    if d is None:   # no repositório, fora do .pyz
        raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        d = open(os.path.join(raiz, "TerraVM", "src", "meyer-heavy_short.txt"), "rb").read()
    return [int(x) for x in d.split() if x.strip()]


def grid_nodes(lines, cols):
    return [c * 10 + l for c in range(1, cols + 1) for l in range(1, lines + 1)]


def grid_links(lines, cols):
    """Pares (a, b) de vizinhos (8 direções) na grade, cada par uma vez."""
    nos = set(grid_nodes(lines, cols))
    pares = set()
    for n in nos:
        for dc in (-1, 0, 1):
            for dl in (-1, 0, 1):
                m = n + dc * 10 + dl
                if m != n and m in nos and 1 <= m % 10 <= lines:
                    pares.add((min(n, m), max(n, m)))
    return sorted(pares)


def load_tossim(pasta):
    pasta = os.path.abspath(pasta)
    if not os.path.exists(os.path.join(pasta, "TOSSIM.py")):
        raise SystemExit("terractl sim: %s has no TOSSIM.py (extract terra-<v>-{net,grp}-tossim-"
                         "py3-x86_64.tar.gz of the release)" % pasta)
    sys.path.insert(0, pasta)
    try:
        import TOSSIM
    except ImportError as e:
        raise SystemExit("terractl sim: _TOSSIM.so did not load (%s). It is for Python 3.14 x86_64: "
                         "run it in the tinyos-toolchain image (see release/README.md)." % e)
    return TOSSIM


class TossimLink(L.Link):
    """A serial da BS simulada: os pacotes entram com newSerialPacket().deliver() e saem pelo
    SerialForwarder do TOSSIM, lido sem bloquear na mesma thread da simulação (o sf.process() não
    solta o GIL, ver link.SFLink). Os pacotes de entrada são espaçados de `gap` segundos simulados."""

    def __init__(self, tossim_mod, sim, port, gap=0.02):
        super().__init__()
        self.t, self.gap = sim, int(gap * sim.ticksPerSecond())
        self.sf = tossim_mod.SerialForwarder(port)
        self.s = socket.create_connection(("127.0.0.1", port))
        self.s.sendall(b"U ")          # já no socket quando o sf.process() aceitar a conexão
        self.s.setblocking(False)
        self.buf, self.hand = b"", False
        self.next = 0

    def send(self, am, payload, dest=L.BS_ADDR):
        quando = max(self.t.time() + 1, self.next)
        self.next = quando + self.gap
        p = self.t.newSerialPacket()
        p.setData(payload)
        p.setType(am)
        p.setDestination(dest)
        p.setLength(len(payload))
        p.deliver(L.BS_ADDR, quando)
        return True

    def poll(self):
        self.sf.process()
        try:
            self.buf += self.s.recv(65536)
        except (BlockingIOError, OSError):
            return
        if not self.hand and len(self.buf) >= 2:
            self.buf, self.hand = self.buf[2:], True
        while self.hand and self.buf and len(self.buf) > self.buf[0]:
            pac, self.buf = self.buf[1:1 + self.buf[0]], self.buf[1 + self.buf[0]:]
            self._deliver(pac)

    def close(self):
        super().close()
        try:
            self.s.close()
        except OSError:
            pass


class Tail:
    """Um canal de log do TOSSIM num arquivo; as linhas novas saem com o tempo simulado na frente."""

    def __init__(self, path):
        self.w = open(path, "w")
        self.r = open(path, "r")
        self.resto = ""

    def lines(self):
        d = self.r.read()
        if not d:
            return []
        d = self.resto + d
        *ls, self.resto = d.split("\n")
        return ls


def run(a, out=print):
    """`a`: os argumentos do `terractl sim` (cli.py)."""
    T = load_tossim(a.tossim)
    try:
        lines, cols = (int(x) for x in a.grid.lower().split("x"))
    except ValueError:
        raise SystemExit("terractl sim: --grid is LINESxCOLUMNS, e.g. 3x3")
    if not (1 <= lines <= 9 and 1 <= cols <= 9 and 0 <= a.late < cols):
        raise SystemExit("terractl sim: up to 9 lines and 9 columns (and --late below the number of columns)")
    if not os.access(".", os.W_OK):
        raise SystemExit("terractl sim: the current folder must be writable (the VM creates sensors.bin there)")

    t = T.Tossim([])
    t.randomSeed(a.seed)
    tps = t.ticksPerSecond()
    logdir = a.logdir
    os.makedirs(logdir, exist_ok=True)
    tails = {"TVIEW": Tail(os.path.join(logdir, "tview.txt"))}
    t.addChannel("TVIEW", tails["TVIEW"].w)
    for ch in a.channel:
        tails[ch] = Tail(os.path.join(logdir, ch + ".txt"))
        t.addChannel(ch, tails[ch].w)
    vmdbg = None
    if a.vmdbg:
        vmdbg = open(a.vmdbg, "w")
        t.addChannel("VMDBG", vmdbg)

    nos = grid_nodes(lines, cols)
    r = t.radio()
    r.add(1, 11, a.gain)
    r.add(11, 1, a.gain)
    for x, y in grid_links(lines, cols):
        r.add(x, y, a.gain)
        r.add(y, x, a.gain)
    ruido = noise_trace()
    for n in [1] + nos:
        m = t.getNode(n)
        for v in ruido:
            m.addNoiseTraceReading(v)
        m.createNoiseModel()

    tardios = set(n for n in nos if n // 10 > cols - a.late)
    for i, n in enumerate([1] + [n for n in nos if n not in tardios]):
        t.getNode(n).bootAtTime(1 + i * 1000)       # 0,1 ms entre um boot e outro

    def agora():
        return t.time() / tps

    def emite(texto):
        out("%9.3f  %s" % (agora(), texto))

    lk = TossimLink(T, t, a.sf_port)
    dec = M.Decoder(M.run_types(a.terra, a.terrac) if a.terra else
                    (__import__("json").load(open(a.types)) if a.types else None))
    ld = None
    if a.vmx:
        ld = LD.Loader(lk, LD.Program(a.vmx), a.version, log=lambda s: emite("terractl: " + s),
                       gap=0, persist=False)

    def recebe(am, src, dest, payload):
        if ld and ld.handle(am, src, payload):
            return
        if am in (M.AM_NEWPROGVERSION, M.AM_NEWPROGBLOCK):
            return      # a BS repassa à serial o anúncio e os blocos que ouve dos motes
        emite("BS: " + M.format_text(dec.decode(am, src, payload)))
    lk.on_message = recebe

    th = None
    if a.realtime:
        th = T.Throttle(t, 10)
        th.initialize()
    emite("grid %dx%d (%d motes and the BS), %s, %.0f s simulated%s" % (
        lines, cols, len(nos), os.path.basename(os.path.abspath(a.tossim)), a.time,
        ", real time, SerialForwarder on port %d" % a.sf_port if a.realtime else ""))

    marcos = []          # (tempo, ação)
    if ld:
        marcos.append((a.load_at, ld.start))
        if a.every > 0:
            k = a.load_at + a.every
            while k < a.time:
                marcos.append((k, ld.announce))
                k += a.every
    if tardios:
        def liga():
            for n in sorted(tardios):
                t.getNode(n).bootAtTime(t.time() + 1)
            emite("motes %s switched on" % sorted(tardios))
        marcos.append((a.late_at, liga))
    marcos.sort(key=lambda x: x[0])

    esconde = set(x for x in a.hide.split(",") if x)
    fim = a.time * tps
    try:
        while t.time() < fim:
            while marcos and t.time() >= marcos[0][0] * tps:
                marcos.pop(0)[1]()
            if not t.runNextEvent():
                break
            lk.poll()
            if th:
                th.checkThrottle()
            for nome, tl in tails.items():
                for linha in tl.lines():
                    if nome == "TVIEW":
                        linha = re.sub(r"^DEBUG \(\d+\): ", "", linha)   # o nó já está na linha
                        cmd = re.match(r"<<: (\w+)", linha)
                        if cmd and cmd.group(1) in esconde:
                            continue
                    else:
                        linha = "%s: %s" % (nome, linha)
                    emite(linha)
    except KeyboardInterrupt:
        pass
    if ld:
        emite("terractl: " + ld.resumo())
    lk.close()
    if vmdbg:
        vmdbg.close()
    return 0
