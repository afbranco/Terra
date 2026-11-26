#!/usr/bin/env python3
"""Gera o terra-docs.json da release a partir dos modelos .defs.in e das descrições (#91).

Cada símbolo dos modelos (eventos, funções, constantes, macros e registros) sai com o que o .defs
diz (número, tipos, parâmetros, pares unsafe, campos) e o marcador de build que o condiciona
(requires: MSGQ, FFT, MIC, PORTS). As plataformas saem dos .defs que os builds da release geraram
de fato (--build): um símbolo está numa plataforma se o .defs dela o declara. O texto (short,
long, example, nomes de parâmetros) vem do arquivo de descrições (TOML).

Reprova (sai com erro) se:
- um símbolo não tem descrição, ou há descrição de símbolo que não existe;
- um .defs de build declara algo que o modelo não tem, ou com outro número ou tipo;
- símbolos com o mesmo requires não estão nas mesmas plataformas (o marcador não bate com o build).

Uso:
  gendocs.py --version V --descricoes descricoes.toml --out terra-docs.json \\
             net=TerraNet.defs.in grp=TerraGrp.defs.in \\
             --build net:tossim:TerraNet.defs --build net:micaz:terra-V-net-micaz-nobs.defs ...
  gendocs.py --lista net=TerraNet.defs.in grp=TerraGrp.defs.in   (os nomes, para as descrições)
"""
import argparse
import json
import re
import sys
import tomllib

TIPOS_BASICOS = {"void", "ubyte", "byte", "ushort", "short", "ulong", "long", "float"}


def erro(msg):
    sys.exit("gendocs: " + msg)


def limpa(linha):
    """Tira o comentário de linha (fora de strings não há strings no .defs)."""
    i = linha.find("//")
    return (linha[:i] if i >= 0 else linha).strip()


def le_defs(texto, origem):
    """Os símbolos de um .defs (ou modelo): lista de dicts, na ordem do arquivo."""
    simbolos = []
    requires = None
    em_comentario = False
    registro = None
    em_config = False
    for n, bruta in enumerate(texto.split("\n"), 1):
        marca = bruta.strip()
        if marca.startswith("//@if "):
            requires = marca[6:].strip()
            continue
        if marca in ("//@endif", "//@else"):
            requires = None if marca == "//@endif" else requires
            continue
        # comentários de bloco (o .defs não usa /** , ver o aviso no topo dos modelos)
        linha = bruta
        if em_comentario:
            if "*/" not in linha:
                continue
            linha = linha[linha.index("*/") + 2:]
            em_comentario = False
        while "/*" in linha:
            a = linha.index("/*")
            if "*/" in linha[a + 2:]:
                b = linha.index("*/", a + 2)
                linha = linha[:a] + " " + linha[b + 2:]
            else:
                linha = linha[:a]
                em_comentario = True
        comentario = bruta.split("//", 1)[1].strip() if "//" in bruta and not marca.startswith("//") else None
        linha = limpa(linha)
        if not linha:
            continue
        req = [requires] if requires else []
        onde = "%s:%d" % (origem, n)

        if em_config:
            if linha == "do":
                em_config = False
            continue
        if linha == "config":
            em_config = True
            continue
        if registro is not None:
            if linha == "end":
                simbolos.append(registro)
                registro = None
                continue
            m = re.match(r"var\s+(\w+(?:\[\w+\])?)\s+(\w+)\s*;$", linha)
            if not m:
                erro("%s: campo de registro: %r" % (onde, linha))
            registro["fields"].append({"name": m.group(2), "type": m.group(1)})
            continue

        m = re.match(r"(packet|regtype)\s+(\w+)\s+with$", linha)
        if m:
            registro = {"name": m.group(2), "kind": "type", "type_kind": m.group(1), "fields": [],
                        "requires": req, "onde": onde}
            continue
        m = re.match(r"#define\s+(\w+)\(([^)]*)\)\s+(.*)$", linha)
        if m:
            simbolos.append({"name": m.group(1), "kind": "macro",
                             "params": [{"name": p.strip(), "type": None} for p in m.group(2).split(",")],
                             "body": m.group(3).strip(), "requires": req, "onde": onde})
            continue
        m = re.match(r"#define\s+(\w+)\s+(\S+)$", linha)
        if m:
            v = m.group(2)
            try:
                valor = int(v, 0)
            except ValueError:
                erro("%s: constante não numérica: %r" % (onde, linha))
            simbolos.append({"name": m.group(1), "kind": "constant", "value": valor,
                             "type": "ubyte" if 0 <= valor <= 255 else "ushort" if 0 <= valor <= 65535 else "ulong",
                             "comment": comentario, "requires": req, "onde": onde})
            continue
        if re.match(r"#(ifndef|define|endif)\b", linha) or linha in ("do", "end"):
            continue   # guarda do .defs e o bloco config ... do ... end
        m = re.match(r"output\s+void\s+(\w+)\s+(\w+)\s+(\d+)\s*;$", linha)
        if m:
            arg = m.group(2)
            simbolos.append({"name": m.group(1), "kind": "event", "direction": "emit", "type": None,
                             "params": [] if arg == "void" else [{"name": None, "type": arg}],
                             "id": int(m.group(3)), "requires": req, "onde": onde})
            continue
        m = re.match(r"input\s+(\w+)\s+(\w+)\s+(\w+)\s+(\d+)\s*;$", linha)
        if m:
            simbolos.append({"name": m.group(2), "kind": "event", "direction": "await",
                             "type": m.group(1), "arg": m.group(3), "id": int(m.group(4)),
                             "requires": req, "onde": onde})
            continue
        m = re.match(r"function\s+((?:(?:pure|nohold)\s+)*)(\w+)\s+(\w+)\(([^)]*)\)\s+(\d+)\s*;$", linha)
        if m:
            params = [p.strip() for p in m.group(4).split(",") if p.strip()]
            simbolos.append({"name": m.group(3), "kind": "function", "returns": m.group(2),
                             "params": [{"name": None, "type": p} for p in params],
                             "attrs": m.group(1).split(), "id": int(m.group(5)),
                             "requires": req, "onde": onde})
            continue
        m = re.match(r"unsafe\s+(\w+)\s+with\s+(.*);$", linha)
        if m:
            simbolos.append({"name": m.group(1), "kind": "unsafe",
                             "with": [x.strip() for x in m.group(2).split(",")], "requires": req,
                             "onde": onde})
            continue
        erro("%s: linha não reconhecida: %r" % (onde, linha))
    if registro is not None or em_comentario or requires is not None:
        erro("%s: fim do arquivo dentro de bloco" % origem)
    return simbolos


def junta(simbolos, origem):
    """Um símbolo por nome: as duas formas de um input viram um (filter), os unsafe vão para o
    símbolo. Devolve {nome: símbolo}."""
    por_nome = {}
    unsafes = []
    for s in simbolos:
        if s["kind"] == "unsafe":
            unsafes.append(s)
            continue
        ant = por_nome.get(s["name"])
        if ant is None:
            if s["kind"] == "event" and s["direction"] == "await":
                arg = s.pop("arg")
                if arg == "void":
                    s["filter"] = None
                else:
                    s["filter"] = {"type": arg, "id": s.pop("id")}
                    s["id"] = None
            por_nome[s["name"]] = s
            continue
        if s["kind"] == "constant" and ant["kind"] == "constant" and s["value"] == ant["value"]:
            continue   # #define repetido com o mesmo valor (pIN/pOUT no Grp)
        # segunda forma de um input
        if not (ant["kind"] == "event" and ant["direction"] == "await" and s["kind"] == "event"
                and s["direction"] == "await"):
            erro("%s: %s declarado duas vezes" % (s["onde"], s["name"]))
        if ant["type"] != s["type"]:
            erro("%s: %s com dois tipos (%s e %s)" % (s["onde"], s["name"], ant["type"], s["type"]))
        if ant["requires"] != s["requires"]:
            erro("%s: as formas de %s com requires diferentes" % (s["onde"], s["name"]))
        if s["arg"] == "void":
            if ant["id"] is not None:
                erro("%s: %s sem argumento duas vezes" % (s["onde"], s["name"]))
            ant["id"] = s["id"]
        else:
            if ant["filter"] is not None:
                erro("%s: %s com filtro duas vezes" % (s["onde"], s["name"]))
            ant["filter"] = {"type": s["arg"], "id": s["id"]}
    for u in unsafes:
        alvo = por_nome.get(u["name"])
        if alvo is None:
            erro("%s: unsafe de %s, que não existe" % (u["onde"], u["name"]))
        for w in u["with"]:
            if w not in por_nome:
                erro("%s: unsafe com %s, que não existe" % (u["onde"], w))
        alvo.setdefault("unsafe_with", [])
        alvo["unsafe_with"] += [w for w in u["with"] if w not in alvo["unsafe_with"]]
    return por_nome


ASSINATURA = ("kind", "direction", "type", "id", "filter", "returns", "value", "attrs", "fields",
              "body", "type_kind")


def assinatura(s):
    a = {k: s.get(k) for k in ASSINATURA}
    a["params"] = [p["type"] for p in s.get("params", [])]
    a["unsafe_with"] = sorted(s.get("unsafe_with", []))
    return json.dumps(a, sort_keys=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("modelos", nargs="+", help="variante=modelo.defs.in")
    ap.add_argument("--version")
    ap.add_argument("--descricoes")
    ap.add_argument("--out")
    ap.add_argument("--build", action="append", default=[], help="variante:plataforma:arquivo.defs")
    ap.add_argument("--lista", action="store_true")
    a = ap.parse_args()

    variantes = []
    modelos = {}
    for m in a.modelos:
        v, _, caminho = m.partition("=")
        variantes.append(v)
        modelos[v] = junta(le_defs(open(caminho).read(), caminho), caminho)

    if a.lista:
        for nome in sorted(set().union(*modelos.values())):
            print(nome)
        return
    if not (a.version and a.descricoes and a.out and a.build):
        erro("faltam --version, --descricoes, --out ou --build")

    # Plataformas: o que cada .defs de build declara, conferido com o modelo da variante.
    plataformas = {v: {} for v in variantes}   # variante -> nome -> [plataformas]
    todas = []
    for b in a.build:
        v, plat, caminho = b.split(":", 2)
        if v not in modelos:
            erro("build de variante sem modelo: " + b)
        if plat not in todas:
            todas.append(plat)
        dele = junta(le_defs(open(caminho).read(), caminho), caminho)
        for nome, s in dele.items():
            mod = modelos[v].get(nome)
            if mod is None:
                erro("%s declara %s, que o modelo de %s não tem" % (caminho, nome, v))
            sm, sb = dict(mod), dict(s)
            sb["requires"] = sm["requires"]
            # o unsafe de um build pode ter só parte da lista (o resto sai com o //@if)
            sb["unsafe_with"] = [w for w in mod.get("unsafe_with", []) if w in dele]
            sm["unsafe_with"] = sb["unsafe_with"]
            if assinatura(sm) != assinatura(sb):
                erro("%s: %s difere do modelo de %s" % (caminho, nome, v))
            plataformas[v].setdefault(nome, []).append(plat)

    # Mesmo requires, mesmas plataformas (por variante).
    for v in variantes:
        grupos = {}
        for nome, s in modelos[v].items():
            chave = tuple(s["requires"])
            grupos.setdefault(chave, {}).setdefault(tuple(sorted(plataformas[v].get(nome, []))), []).append(nome)
        for req, por_plat in grupos.items():
            if len(por_plat) > 1:
                erro("%s, requires %s: plataformas diferentes: %s" % (v, list(req) or "nenhum", por_plat))

    desc = tomllib.load(open(a.descricoes, "rb"))
    padrao_since = desc.pop("since_default", None)
    nomes = set().union(*modelos.values())
    sobra = sorted(set(desc) - nomes)
    falta = sorted(n for n in nomes if n not in desc or not desc[n].get("short"))
    if sobra or falta:
        erro("descrições: faltam %s; sobram %s" % (falta, sobra))

    simbolos = []
    for nome in sorted(nomes, key=lambda n: (n.lower(), n)):
        # um símbolo por definição: igual nas variantes, um só; diferente, um por variante
        defs = {}
        for v in variantes:
            s = modelos[v].get(nome)
            if s is not None:
                defs.setdefault(assinatura(s) + json.dumps(s["requires"]), []).append(v)
        d = desc[nome]
        for _, vs in defs.items():
            s = modelos[vs[0]][nome]
            dv = dict(d)
            for v in vs:                        # texto próprio de uma variante ([NOME.grp])
                dv.update(d.get(v, {}) if isinstance(d.get(v), dict) else {})
            plats = [p for p in todas if any(p in plataformas[v].get(nome, []) for v in vs)]
            o = {"name": nome, "kind": s["kind"]}
            if s["kind"] == "event":
                o["direction"] = s["direction"]
                o["type"] = s["type"]
                o["id"] = s["id"]
                if s["direction"] == "await":
                    f = s["filter"]
                    o["filter"] = None if f is None else {"type": f["type"], "id": f["id"],
                                                          "matches": dv.get("filter")}
                    if f is not None and not dv.get("filter"):
                        erro("descrição de %s sem o 'filter' (o que o argumento do await filtra)" % nome)
            if s["kind"] in ("function", "macro") or s.get("direction") == "emit":
                nomes_p = dv.get("params", [])
                ps = s.get("params", [])
                if nomes_p and len(nomes_p) != len(ps):
                    erro("%s: %d nomes de parâmetro para %d parâmetros" % (nome, len(nomes_p), len(ps)))
                if s["kind"] == "function" and ps and not nomes_p:
                    erro("descrição de %s sem os nomes dos parâmetros ('params')" % nome)
                o["params"] = [{"name": (nomes_p[i] if nomes_p else p["name"]), "type": p["type"]}
                               for i, p in enumerate(ps)]
            if s["kind"] == "function":
                o["returns"] = s["returns"]
                o["attrs"] = s["attrs"]
                o["id"] = s["id"]
            if s["kind"] == "constant":
                o["value"] = s["value"]
                o["type"] = s["type"]
            if s["kind"] == "macro":
                o["body"] = s["body"]
            if s["kind"] == "type":
                o["type_kind"] = s["type_kind"]
                fd = dv.get("fields", {})
                extra = set(fd) - {f["name"] for f in s["fields"]}
                if extra:
                    erro("descrição de %s com campos que não existem: %s" % (nome, sorted(extra)))
                o["fields"] = [dict(f, short=fd.get(f["name"])) for f in s["fields"]]
            if s.get("unsafe_with"):
                o["unsafe_with"] = s["unsafe_with"]
            o["requires"] = s["requires"]
            o["variants"] = vs
            o["platforms"] = plats
            o["short"] = dv["short"]
            for k in ("long", "example"):
                if dv.get(k):
                    o[k] = dv[k].strip("\n")
            o["since"] = dv.get("since", padrao_since)
            simbolos.append(o)

    saida = {"schema": 1, "terra": a.version, "variants": variantes, "platforms": todas,
             "symbols": simbolos}
    with open(a.out, "w") as f:
        json.dump(saida, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print("gendocs: %d símbolos (%d nomes), variantes %s, plataformas %s"
          % (len(simbolos), len(nomes), variantes, todas))


if __name__ == "__main__":
    main()
