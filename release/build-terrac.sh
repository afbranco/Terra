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

tar -C "$W" -czf "$OUT/terrac-$VER.tar.gz" "terrac-$VER"
rm -rf "$W"
[ $fail = 0 ] || { echo "FALHOU: terrac"; exit 1; }
echo "OK build-terrac $VER"
