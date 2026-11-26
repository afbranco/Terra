#!/usr/bin/env python3
"""Confere o .defs gerado de um build contra o app.c pré-processado do mesmo build (#100).

Cada saída (output) e cada função (function) declarada no .defs tem de ter um `case` no
procOutEvt / callFunction do VMCustomP; cada entrada (input) tem de ter um evento I_* com o mesmo
número usado fora da definição do enum (a VM o põe na fila em algum lugar). Sem isso o programa
compila, mas no mote a saída não faz nada, a função desalinha a pilha ou o await nunca dispara.

Uso: check-defs.py <arquivo .defs> <app.c>
"""
import re
import sys

DECL = re.compile(r"^\s*(output|input)\s+\w+\s+(\w+)\s+\w+\s+(\d+)\s*;|"
                  r"^\s*function\b[^(]*?\b(\w+)\s*\([^)]*\)\s*(\d+)\s*;")


def declaracoes(texto):
    saidas, entradas, funcoes = {}, {}, {}
    for linha in texto.split("\n"):
        if linha.strip().startswith("//"):
            continue
        m = DECL.match(linha)
        if not m:
            continue
        if m.group(1) == "output":
            saidas[int(m.group(3))] = m.group(2)
        elif m.group(1) == "input":
            entradas.setdefault(int(m.group(3)), m.group(2))
        else:
            funcoes[int(m.group(5))] = m.group(4)
    return saidas, entradas, funcoes


def corpo(app, nome):
    """O corpo da função `nome` (a primeira definição com chave), até a chave que a fecha."""
    # O nesC junta os nomes com "__" no build do mote e com "$" no do TOSSIM.
    padrao = r"(?<![\w$])" + r"(?:__|\$)".join(map(re.escape, nome.split(".")))
    m = re.search(padrao + r"\s*\([^;{)]*\)\s*(?:#line[^\n]*\n\s*)*\{", app)
    if not m:
        sys.exit("função não encontrada no app.c: " + nome)
    i, nivel = m.end(), 1
    while nivel:
        c = app[i]
        nivel += (c == "{") - (c == "}")
        i += 1
    return app[m.end():i]


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    defs = open(sys.argv[1]).read()
    app = open(sys.argv[2]).read()
    saidas, entradas, funcoes = declaracoes(defs)
    if not (saidas and entradas and funcoes):
        sys.exit("nenhuma declaração lida em " + sys.argv[1])
    enum = {}
    for nome, valor in re.findall(r"\b([OIF]_\w+)\s*=\s*(\d+)\b", app):
        enum.setdefault(nome, int(valor))

    def casos(func, prefixo):
        ids = set()
        for rotulo in re.findall(r"\bcase\s+(\w+)\s*:", corpo(app, func)):
            if rotulo.isdigit():
                ids.add(int(rotulo))
            elif rotulo.startswith(prefixo) and rotulo in enum:
                ids.add(enum[rotulo])
        return ids

    erros = []
    tem = casos("VMCustomP.VM.procOutEvt", "O_")
    erros += ["output %s (%d) sem case no procOutEvt" % (n, i) for i, n in sorted(saidas.items()) if i not in tem]
    tem = casos("VMCustomP.VM.callFunction", "F_")
    erros += ["function %s (%d) sem case no callFunction" % (n, i) for i, n in sorted(funcoes.items()) if i not in tem]
    usados = set()
    for nome, valor in enum.items():
        if nome.startswith("I_") and len(re.findall(r"\b" + nome + r"\b", app)) > 1:
            usados.add(valor)
    erros += ["input %s (%d) sem evento I_* usado na VM" % (n, i) for i, n in sorted(entradas.items()) if i not in usados]
    for e in erros:
        print("check-defs: " + e)
    print("check-defs: %s: %d saídas, %d entradas, %d funções: %s" % (
        sys.argv[1], len(saidas), len(entradas), len(funcoes), "FALHOU" if erros else "OK"))
    sys.exit(1 if erros else 0)


if __name__ == "__main__":
    main()
