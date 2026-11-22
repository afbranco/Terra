#!/bin/bash
# Empacota o terrac num script Lua único (terrac/pak.lua) e testa compilando os exemplos de
# terrac/samples contra os .vmx commitados. Precisa de lua5.1, do lpeg e do cpp.
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
# O fonte pede o lpeg com o nome versionado do luarocks da época ('lpeg_0_10_2_1-lpeg').
# O script da release aceita também o lpeg instalado com o nome comum.
{
    head -1 "$W/terrac/terrac"
    echo "package.preload['lpeg_0_10_2_1-lpeg'] = package.preload['lpeg_0_10_2_1-lpeg'] or function() return require 'lpeg' end"
    tail -n +2 "$W/terrac/terrac"
} > "$W/terrac.out"

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

tar -C "$W" -czf "$OUT/terrac-$VER.tar.gz" "terrac-$VER"
rm -rf "$W"
[ $fail = 0 ] || { echo "FALHOU: terrac"; exit 1; }
echo "OK build-terrac $VER"
