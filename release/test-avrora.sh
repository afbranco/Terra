#!/bin/bash
# Roda os testes da VM no Avrora, que emula o micaz (ATmega128 e rádio CC2420) com o firmware da
# release: pega o que só acontece no AVR e o TOSSIM (x86) não mostra, como o tamanho de struct
# da issue #41. Roda DENTRO da imagem do tinyos-toolchain, a partir da raiz do repositório:
#   release/test-avrora.sh <pasta com terra-<v>-{net,grp}-micaz-{bs,nobs}.exe> <pasta de saída>
# Cada teste usa o mínimo de nós: a estação base e os motes do ESPERADO (ver avrora_vmx.py).
# Lento (a CPU é emulada, cerca de 1 min por teste): no CI só roda na tag de release e quando o
# workflow é disparado à mão (decidido pelo Prof. em 2026-11-23).
set -euo pipefail
FW=$(cd "${1:?pasta do firmware}" && pwd)
OUT=$(mkdir -p "${2:?pasta de saída}" && cd "$2" && pwd)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
W=$(mktemp -d)
mkdir -p "$OUT/logs"
LOG="$OUT/logs/avrora.log"

# Entram os testes que carregam o programa pela estação base e têm ESPERADO.
fail=0
for t in "$ROOT"/tests/*/test_*.py; do
    grep -q '^ESPERADO' "$t" && grep -q 'setDestination(1)' "$t" || continue
    grep -q '^AVRORA = False' "$t" && continue   # topologia que o Avrora não monta (ex.: versao2)
    n=$(basename "$(dirname "$t")")
    mkdir -p "$W/$n"
    (cd "$W/$n" && python3 "$ROOT/tests/avrora/avrora_vmx.py" "$FW" "$ROOT/tests/$n") 2>&1 | tee -a "$LOG" || true
    tail -1 "$LOG" | grep -q ': OK$' || { fail=1; cp "$W/$n/avrora.txt" "$OUT/logs/avrora-$n.txt" 2>/dev/null || true; }
done
rm -rf "$W"
[ $fail = 0 ] || { echo "FALHOU: avrora"; exit 1; }
echo "OK test-avrora"
