#!/bin/bash
# Empacota o terrac num script Lua único (terrac/pak.lua) e testa compilando os exemplos de
# terrac/samples contra os .vmx commitados. Precisa de lua5.1, do lpeg (0.10 ou 1.x) e do cpp.
#   release/build-terrac.sh <versão> <pasta de saída>
set -euo pipefail
VER=${1:?versão}
OUT=$(mkdir -p "${2:?pasta de saída}" && cd "$2" && pwd)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
W=$(mktemp -d)
mkdir -p "$OUT/logs"
LOG="$OUT/logs/terrac.log"

cp -a "$ROOT/terrac" "$W/terrac"
(cd "$W/terrac" && lua5.1 pak.lua)
cp "$W/terrac/terrac" "$W/terrac.out"
lua5.1 -e 'print("terrac: lpeg " .. require("lpeg").version())' | tee -a "$LOG"

D="$W/terrac-$VER"
mkdir -p "$D"
install -m 755 "$W/terrac.out" "$D/terrac"
cp "$ROOT/terrac/terra.lang" "$ROOT/terrac/samples/TerraNet.defs" "$ROOT/terrac/samples/TerraGrp.defs" "$D/"

# Teste: cada exemplo com .vmx commitado deve compilar para o mesmo .vmx.
fail=0
mkdir -p "$W/t"
cp "$ROOT"/terrac/samples/* "$W/t/"
# Os programas dos testes da VM (tests/*/) também: o .vmx commitado tem de ser o que o terrac gera.
for f in "$ROOT"/tests/*/*.terra "$ROOT"/tests/*/*.vmx; do [ -e "$f" ] && cp "$f" "$W/t/"; done
for vmx in "$ROOT"/terrac/samples/*.vmx "$ROOT"/tests/*/*.vmx; do
    [ -e "$vmx" ] || continue
    name=$(basename "$vmx" .vmx)
    echo "== terrac $name.terra" >> "$LOG"
    (cd "$W/t" && rm -f "$name.vmx" && lua5.1 "$D/terrac" "$name.terra") >> "$LOG" 2>&1 || true
    if [ -f "$W/t/$name.vmx" ] && cmp -s "$vmx" "$W/t/$name.vmx"; then
        echo "terrac: $name.vmx idêntico" | tee -a "$LOG"
    elif [ -f "$W/t/$name.vmx" ] && diff -b -q "$vmx" "$W/t/$name.vmx" > /dev/null; then
        # O .vmx é texto; o alinhamento da coluna de comentários mudou desde 2015.
        echo "terrac: $name.vmx idêntico, salvo espaços nos comentários" | tee -a "$LOG"
    else
        echo "terrac: $name.vmx DIFERENTE ou não gerado" | tee -a "$LOG"
        fail=1
    fi
done

# Teste: cada programa de tests/terrac/erros.esperado dá o erro esperado, com a linha certa
# (#23: com ou sem o stdc-predef.h do cpp). Com o lpeg 0.10 e com o 1.x tem de ser o mesmo.
while IFS= read -r esperado; do
    case "$esperado" in ''|'#'*) continue;; esac
    name=${esperado%%: *}
    obtido="$name: $(cd "$W/t" && lua5.1 "$D/terrac" "$name.terra" 2>&1 | head -1 |
        sed -E 's/^ERR : //; s/[[:space:]]+$//' || true)"
    if [ "$obtido" = "$esperado" ]; then
        echo "terrac: $name: mensagem esperada" | tee -a "$LOG"
    else
        echo "terrac: $name: mensagem DIFERENTE: $obtido" | tee -a "$LOG"
        fail=1
    fi
done < "$ROOT/tests/terrac/erros.esperado"

# Diagnósticos (#24): o catálogo cobre tudo o que o terrac pode dizer; o --diag=json dá a saída
# esperada (tests/terrac/diag/json.esperado), só com linhas JSON e o resumo no fim; o texto e o
# JSON têm a mesma linha e mensagem; uma falha interna vira E0001.
if lua5.1 "$ROOT/tests/terrac/catalogo.lua" "$ROOT/terrac" | tee -a "$LOG"; then :; else fail=1; fi
# Otimizador (#22): todo rótulo leva à mesma instrução antes e depois do optm.lua.
if lua5.1 "$ROOT/tests/terrac/optm_rotulos.lua" "$ROOT/terrac" | tee -a "$LOG"; then :; else fail=1; fi
mkdir -p "$W/d"
cp "$ROOT"/terrac/samples/*.defs "$ROOT"/tests/terrac/*.terra "$ROOT"/tests/terrac/diag/*.terra \
   "$ROOT"/tests/terrac/diag/*.h "$W/d/"
: > "$W/json.obtido"
for f in "$ROOT"/tests/terrac/*.terra "$ROOT"/tests/terrac/diag/*.terra; do
    name=$(basename "$f" .terra)
    (cd "$W/d" && lua5.1 "$D/terrac" "$name.terra" > /dev/null 2> "$name.txt" || true)
    (cd "$W/d" && lua5.1 "$D/terrac" --diag=json "$name.terra" > /dev/null 2> "$name.json" || true)
    { echo "== $name"; cat "$W/d/$name.json"; } >> "$W/json.obtido"
    if ! lua5.1 "$ROOT/tests/terrac/consistencia.lua" "$W/d/$name.txt" "$W/d/$name.json" 2>&1 | tee -a "$LOG"; then
        fail=1
    elif [ -s "$W/d/$name.json" ] && command -v python3 > /dev/null &&
         ! python3 -c 'import json,sys; [json.loads(l) for l in open(sys.argv[1])]' "$W/d/$name.json"; then
        echo "terrac: $name: JSON inválido" | tee -a "$LOG"; fail=1
    fi
done
if diff -u "$ROOT/tests/terrac/diag/json.esperado" "$W/json.obtido" | tee -a "$LOG"; then
    echo "terrac: --diag=json: saída esperada" | tee -a "$LOG"
else
    echo "terrac: --diag=json: saída DIFERENTE" | tee -a "$LOG"; fail=1
fi
mkdir -p "$W/e" && cp "$ROOT/terrac/samples/TerraNet.defs" "$ROOT/terrac/samples/Count2Leds.terra" "$W/e/"
mkdir "$W/e/Count2Leds.vmx"     # o .vmx não pode ser gravado: o assert do terrac falha
rc=0; (cd "$W/e" && lua5.1 "$D/terrac" --diag=json Count2Leds.terra > /dev/null 2> err) || rc=$?
if [ $rc = 1 ] && grep -q '^{"code":"E0001"' "$W/e/err" && tail -1 "$W/e/err" | grep -q '^{"summary":{"ok":false'; then
    echo "terrac: falha interna: E0001" | tee -a "$LOG"
else
    echo "terrac: falha interna sem E0001 (rc $rc)" | tee -a "$LOG"; cat "$W/e/err" >> "$LOG"; fail=1
fi
# O catálogo vai na release como anexo (com o sha256 no SHA256SUMS).
lua5.1 "$D/terrac" --catalog > "$OUT/terrac-errors-$VER.json"
if command -v python3 > /dev/null && ! python3 -m json.tool "$OUT/terrac-errors-$VER.json" > /dev/null; then
    echo "terrac: catálogo JSON inválido" | tee -a "$LOG"; fail=1
fi

# Site (#91): a tabela dos códigos tem de ser a gerada deste catálogo, e os exemplos das páginas
# (blocos ```terra com <!-- check: ... -->) têm de compilar como dizem. No CI o python3 é
# obrigatório; fora dele (imagem local sem python3) a conferência da tabela é pulada.
if command -v python3 > /dev/null; then
    if python3 "$ROOT/docs/_tools/genpages.py" --catalog "$OUT/terrac-errors-$VER.json" \
            --check "$ROOT/docs/_includes/generated" | tee -a "$LOG" | grep -q ': OK$'; then :; else fail=1; fi
elif [ -n "${CI:-}" ]; then
    echo "terrac: sem python3 no CI para conferir docs/_includes/generated/codes.md" | tee -a "$LOG"; fail=1
else
    echo "terrac: sem python3, docs/_includes/generated/codes.md não conferido" | tee -a "$LOG"
fi
if lua5.1 "$ROOT/docs/_tools/checkexamples.lua" "$D/terrac" "$ROOT/terrac/samples" \
        "$ROOT"/docs/*.md "$ROOT"/docs/_includes/generated/*.md 2>&1 | tee -a "$LOG" | tail -1 | grep -q ': OK$'; then :; else fail=1; fi

tar -C "$W" -czf "$OUT/terrac-$VER.tar.gz" "terrac-$VER"
rm -rf "$W"
[ $fail = 0 ] || { echo "FALHOU: terrac"; exit 1; }
echo "OK build-terrac $VER"
