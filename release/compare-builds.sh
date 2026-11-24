#!/bin/bash
# Teste do build reproduzível (issue #18): compara os anexos de dois builds do mesmo commit
# (release/build-tinyos.sh rodado duas vezes, cada um na sua pasta de saída). Os tar.gz, o
# firmware micaz e o jar têm de sair com o mesmo sha256. Se um _TOSSIM.so diferir, mostra em
# que seções do ELF.
#   release/compare-builds.sh <saída 1> <saída 2>
set -uo pipefail
A=${1:?saída 1}; B=${2:?saída 2}
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT

# sha256 de cada seção de um ELF, uma por linha. Temporário próprio: roda em paralelo no diff.
secoes() {
    local s x; x=$(mktemp -p "$T")
    for s in $(readelf -SW "$1" | sed -n 's/^ *\[ *[0-9]*\] \([^ ]*\) .*/\1/p' | grep -v '^NULL$'); do
        rm -f "$x"
        if objcopy --dump-section "$s=$x" "$1" /dev/null 2>/dev/null && [ -f "$x" ]; then
            echo "$s $(sha256sum < "$x" | cut -c1-16)"
        fi
    done
}

n=0; falhas=0
for f in "$A"/*.tar.gz "$A"/*.exe "$A"/*.ihex "$A"/*.jar; do
    [ -f "$f" ] || continue
    b=$(basename "$f"); n=$((n + 1))
    ha=$(sha256sum < "$f" | cut -d' ' -f1)
    hb=$(sha256sum < "$B/$b" 2>/dev/null | cut -d' ' -f1)
    if [ "$ha" = "$hb" ]; then
        echo "igual     $ha  $b"
    else
        falhas=$((falhas + 1))
        echo "DIFERENTE $b: $ha / ${hb:-ausente}"
    fi
    # O _TOSSIM.so de dentro do tar.gz: o sha256 dele e, se diferir, em que seções.
    if [[ $b == *.tar.gz && -n $hb ]]; then
        rm -rf "$T/a" "$T/b"; mkdir -p "$T/a" "$T/b"
        tar -C "$T/a" -xzf "$f"; tar -C "$T/b" -xzf "$B/$b"
        for so in "$T"/a/*/_TOSSIM.so; do
            r=${so#"$T/a/"}
            if cmp -s "$so" "$T/b/$r"; then
                echo "            $(sha256sum < "$so" | cut -d' ' -f1)  $r"
            else
                echo "  $r diferente, seções:"
                diff <(secoes "$so") <(secoes "$T/b/$r") | sed -n 's/^< \([^ ]*\) .*/    \1/p'
            fi
        done
    fi
done
[ $n -gt 0 ] || { echo "compare-builds: nenhum anexo em $A"; exit 1; }
if [ $falhas -gt 0 ]; then
    echo "compare-builds: $falhas de $n anexos diferentes: FALHOU"
    exit 1
fi
echo "compare-builds: $n anexos iguais: OK"
