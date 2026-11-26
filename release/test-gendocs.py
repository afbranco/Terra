#!/usr/bin/env python3
"""Teste do gendocs.py (#91): gera o terra-docs.json com os .defs do TOSSIM de terrac/samples e
confere que ele reprova quando falta uma descrição, quando sobra uma, quando um .defs de build
declara algo com outro tipo e quando o marcador de build não bate com as plataformas.
Uso: test-gendocs.py (da raiz do repositório ou de qualquer lugar)."""
import json, os, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFS = os.path.join(ROOT, "TerraVM/src/defs")
SAMPLES = os.path.join(ROOT, "terrac/samples")
falhas = []


def roda(desc, builds, out):
    cmd = [sys.executable, os.path.join(DEFS, "gendocs.py"), "--version", "teste",
           "--descricoes", desc, "--out", out,
           "net=" + os.path.join(DEFS, "TerraNet.defs.in"), "grp=" + os.path.join(DEFS, "TerraGrp.defs.in")]
    for b in builds:
        cmd += ["--build", b]
    r = subprocess.run(cmd, capture_output=True, text=True)
    return r.returncode, (r.stdout + r.stderr).strip()


with tempfile.TemporaryDirectory() as t:
    desc = os.path.join(DEFS, "descricoes.toml")
    texto = open(desc).read()
    net = os.path.join(SAMPLES, "TerraNet.defs")
    grp = os.path.join(SAMPLES, "TerraGrp.defs")
    builds = ["net:tossim:" + net, "grp:tossim:" + grp]
    out = os.path.join(t, "docs.json")

    rc, msg = roda(desc, builds, out)
    print(msg)
    if rc != 0:
        falhas.append("caso bom reprovou")
    else:
        j = json.load(open(out))
        nomes = {s["name"] for s in j["symbols"]}
        q = [s for s in j["symbols"] if s["name"] == "qPut"]
        if any(s.get("group") not in j["groups"] for s in j["symbols"]):
            falhas.append("símbolo sem group válido no JSON")
        if not ({"TEMP", "groupInit", "radioMsg", "await_until", "E_TIMEOVF"} <= nomes):
            falhas.append("símbolos faltando no JSON")
        if not (q and q[0]["requires"] == ["MSGQ"] and q[0]["variants"] == ["net"]
                and q[0]["platforms"] == ["tossim"]):
            falhas.append("qPut sem requires/variants/platforms certos: %r" % q)
        mic = [s for s in j["symbols"] if s["name"] == "MIC"]
        if not (mic and mic[0]["platforms"] == []):
            falhas.append("MIC deveria estar sem plataforma no TOSSIM: %r" % mic)

    def caso(nome, desc_txt=None, net_txt=None, esperado=""):
        d = desc
        if desc_txt is not None:
            d = os.path.join(t, nome + ".toml"); open(d, "w").write(desc_txt)
        n = net
        if net_txt is not None:
            n = os.path.join(t, nome + ".defs"); open(n, "w").write(net_txt)
        rc, msg = roda(d, ["net:tossim:" + n, "grp:tossim:" + grp], os.path.join(t, nome + ".json"))
        if rc == 0 or esperado not in msg:
            falhas.append("%s: devia reprovar com %r; saiu %d: %s" % (nome, esperado, rc, msg))
        else:
            print("reprova como esperado (%s): %s" % (nome, msg.splitlines()[-1]))

    defs_net = open(net).read()
    caso("falta", desc_txt=texto.replace("[getParent]", "[getParentX]"), esperado="faltam ['getParent']")
    caso("grupo", desc_txt=texto.replace('[getParent]\ngroup = "radio"', '[getParent]\ngroup = "radios"'),
         esperado="sem group válido")
    caso("sobra", desc_txt=texto + '\n[NAO_EXISTE]\nshort = "x"\n', esperado="sobram ['NAO_EXISTE']")
    caso("tipo", net_txt=defs_net.replace("input ushort \tTEMP", "input ubyte \tTEMP"),
         esperado="TEMP difere do modelo")
    caso("extra", net_txt=defs_net.replace("\tinput ushort \tTEMP",
                                           "\tinput ubyte NOVO void 99;\n\tinput ushort \tTEMP"),
         esperado="NOVO, que o modelo")
    # qSize (MSGQ) fora do build e o resto do MSGQ dentro: marcador e build discordam
    caso("requires", net_txt=defs_net.replace("function pure ubyte qSize()", "//"),
         esperado="requires ['MSGQ']")

print("test-gendocs: " + ("; ".join(falhas) if falhas else "OK"))
sys.exit(1 if falhas else 0)
