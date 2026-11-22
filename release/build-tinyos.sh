#!/bin/bash
# Gera os artefatos de release que dependem do TinyOS: módulos TOSSIM (Net e Grp), firmware
# micaz (NOBS e BS, Net e Grp) e o TerraVMControl.jar. Roda DENTRO da imagem do
# tinyos-toolchain (ver .github/workflows/release.yml), a partir da raiz do repositório:
#   release/build-tinyos.sh <versão> <pasta de saída>
set -euo pipefail
VER=${1:?versão}
OUT=$(mkdir -p "${2:?pasta de saída}" && cd "$2" && pwd)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
W=$(mktemp -d)
mkdir -p "$OUT/logs"

# Compila TerraVM/src numa cópia limpa. Uso: vm <nome do log> <argumentos do make>
vm() {
    local name=$1; shift
    rm -rf "$W/src"
    cp -a "$ROOT/TerraVM/src" "$W/src"
    echo "== make $*" | tee "$OUT/logs/$name.log"
    if ! (cd "$W/src" && make "$@") >> "$OUT/logs/$name.log" 2>&1; then
        tail -40 "$OUT/logs/$name.log"
        echo "FALHOU: make $*"
        exit 1
    fi
}

# Módulos TOSSIM. As opções são as do .so de produção (RFPOWER=4 é o padrão do Makefile).
for v in net grp; do
    case $v in
        net) args="VM=NET MOD=MSGQ TYPE=ALL" ;;
        grp) args="VM=GRP TYPE=ALL" ;;
    esac
    vm "tossim-$v" micaz sim-sf $args
    d="$W/terra-$VER-$v-tossim-py3-x86_64"
    rm -rf "$d"; mkdir -p "$d"
    cp "$W/src/_TOSSIM.so" "$W/src/TOSSIM.py" "$d/"
    tar -C "$W" -czf "$OUT/$(basename "$d").tar.gz" "$(basename "$d")"
    # Roda numa pasta gravável: a VM cria ali o sensors.bin e, se não conseguir, sai com
    # exit(0). Por isso o teste exige a linha "OK" e não confia só no código de saída.
    mkdir -p "$W/run-$v"
    (cd "$W/run-$v" && python3 "$ROOT/release/smoke-tossim.py" "$d") | tee -a "$OUT/logs/tossim-$v.log"
    tail -1 "$OUT/logs/tossim-$v.log" | grep -q '^smoke-tossim: .* OK$' || { echo "FALHOU: smoke $v"; exit 1; }
done

# Firmware micaz. O ID do nó é gravado na instalação (ver release/README.md).
for v in net grp; do
    for t in nobs bs; do
        vm "micaz-$v-$t" micaz VM=${v^^} TYPE=${t^^}
        grep -E 'bytes in (ROM|RAM)' "$OUT/logs/micaz-$v-$t.log"
        rom=$(awk '/bytes in ROM/{print $1}' "$OUT/logs/micaz-$v-$t.log")
        ram=$(awk '/bytes in RAM/{print $1}' "$OUT/logs/micaz-$v-$t.log")
        # micaz: ATmega128, 128 KB de flash e 4 KB de RAM.
        [ "$rom" -le 131072 ] && [ "$ram" -le 4096 ] || { echo "FALHOU: não cabe no micaz"; exit 1; }
        cp "$W/src/build/micaz/main.exe" "$OUT/terra-$VER-$v-micaz-$t.exe"
        cp "$W/src/build/micaz/main.ihex" "$OUT/terra-$VER-$v-micaz-$t.ihex"
    done
done

# TerraVMControl.jar: compilado do fonte, num jar único. As bibliotecas (tinyos.jar inclusive)
# vêm do jar da TerraDist v0.3.0: são idênticas às do jar de produção de 2016 (.ova).
J="$W/jar"
rm -rf "$J"; mkdir -p "$J/deps" "$J/classes"
(cd "$J/deps" && jar xf "$ROOT/TerraDist/TerraNet_v0.3.0/tools/TerraVMControl.jar" \
    tinyos.jar jep-2.4.1.jar log4j.jar RXTXcomm.jar xbee-api-0.9.jar)
cp=$(ls "$J"/deps/*.jar | tr '\n' :)
find "$ROOT/TerraControl/src" -name '*.java' > "$J/sources"
javac -nowarn --release 8 -encoding UTF-8 -d "$J/classes" -cp "$cp" @"$J/sources" \
    > "$OUT/logs/terracontrol.log" 2>&1 || { cat "$OUT/logs/terracontrol.log"; exit 1; }
for f in "$J"/deps/*.jar; do
    (cd "$J/classes" && jar xf "$f")
done
rm -rf "$J/classes/META-INF"
printf 'Main-Class: app.ControlForm\n' > "$J/manifest"
jar cfm "$OUT/TerraVMControl-$VER.jar" "$J/manifest" -C "$J/classes" .
# Teste: a classe principal carrega com todas as dependências resolvidas.
java -cp "$OUT/TerraVMControl-$VER.jar" -Djava.awt.headless=true \
    "$ROOT/release/LoadCheck.java" app.ControlForm net.tinyos.message.MoteIF \
    | tee -a "$OUT/logs/terracontrol.log"

rm -rf "$W"
echo "OK build-tinyos $VER"
