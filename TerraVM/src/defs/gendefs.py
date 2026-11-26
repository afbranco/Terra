#!/usr/bin/env python3
"""Gera o .defs de uma variante da VM a partir do modelo (#100).

O .defs só declara o que existe no mote (princípio do Prof.): os módulos do build (MOD=MSGQ,
MOD=FFT), a placa (SENSOR=MTS300CA/CB) e o hardware (portas e interrupções só nos mica, fora do
TOSSIM). A memória do config é a do build (VM_MEM_BLKS blocos de 24 bytes).

Uso: gendefs.py <modelo .defs.in> <saída .defs> NOME PLATAFORMA BLOCOS [FLAG...]
  FLAG: MSGQ, FFT, MIC, PORTS.
Marcadores no modelo, cada um numa linha: //@if FLAG, //@else, //@endif (sem aninhar).
"""
import sys

BLOCK_SIZE = 24


def gera(modelo, nome, plataforma, blocos, flags):
    saida = []
    ativo = None  # None fora de bloco; True/False dentro
    for n, linha in enumerate(modelo.split("\n"), 1):
        marca = linha.strip()
        if marca.startswith("//@if "):
            if ativo is not None:
                sys.exit("%d: //@if aninhado" % n)
            ativo = marca[6:].strip() in flags
            continue
        if marca == "//@else":
            if ativo is None:
                sys.exit("%d: //@else fora de bloco" % n)
            ativo = not ativo
            continue
        if marca == "//@endif":
            if ativo is None:
                sys.exit("%d: //@endif fora de bloco" % n)
            ativo = None
            continue
        if ativo is False:
            continue
        saida.append(linha)
    if ativo is not None:
        sys.exit("//@if sem //@endif")
    texto = "\n".join(saida)
    for k, v in (("@NAME@", nome), ("@PLATFORM@", plataforma), ("@MEM@", str(blocos * BLOCK_SIZE))):
        if k not in texto:
            sys.exit("modelo sem " + k)
        texto = texto.replace(k, v)
    return texto


def main():
    if len(sys.argv) < 6:
        sys.exit(__doc__)
    modelo, destino, nome, plataforma, blocos = sys.argv[1:6]
    flags = set(f for f in sys.argv[6:] if f)
    desconhecidas = flags - {"MSGQ", "FFT", "MIC", "PORTS"}
    if desconhecidas:
        sys.exit("flag desconhecida: " + " ".join(sorted(desconhecidas)))
    texto = gera(open(modelo).read(), nome, plataforma, int(blocos), flags)
    with open(destino, "w") as f:
        f.write(texto)


if __name__ == "__main__":
    main()
