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

# Build reproduzível (issue #18): dois builds do mesmo commit na mesma imagem dão os mesmos
# bytes. A cópia fica numa pasta aleatória ($W), e o caminho entraria no DWARF do _TOSSIM.so
# (comp_dir e nomes de arquivo) e, por ele, no build-id. O -fdebug-prefix-map troca esse
# caminho por /terra/TerraVM/src (onde o fonte está no contêiner do workflow) só na
# informação de depuração, que continua lá; o código e o __FILE__ não mudam. Vai pelo
# ambiente: o Makefile acrescenta ao CFLAGS (+=), e o CFLAGS chega ao nesC e ao g++.
# Os nomes arg_0x<endereço> do nesC são tratados no release/nesc-gcc.sh (GCC= do sim).
# Datas dos tar.gz e do jar: fixas, as do commit (SOURCE_DATE_EPOCH) ou, sem ele, 1980-01-02.
SDE=${SOURCE_DATE_EPOCH:-315619200}

# .defs da variante (#100): o build gera em build/micaz/; o check-defs confere cada entrada contra
# o app.c pré-processado do mesmo build. Uso: defs <app.c> <saída .defs> <nome do log>
defs() {
    local f
    f=$(ls "$W"/src/build/micaz/Terra*.defs)
    python3 "$ROOT/release/check-defs.py" "$f" "$1" | tee -a "$OUT/logs/$3.log"
    tail -1 "$OUT/logs/$3.log" | grep -q ': OK$' || { echo "FALHOU: check-defs $3"; exit 1; }
    cp "$f" "$2"
}

# Compila TerraVM/src numa cópia limpa. Uso: vm <nome do log> <argumentos do make>
vm() {
    local name=$1; shift
    rm -rf "$W/src"
    cp -a "$ROOT/TerraVM/src" "$W/src"
    echo "== make $*" | tee "$OUT/logs/$name.log"
    if ! (cd "$W/src" && CFLAGS="-fdebug-prefix-map=$W/src=/terra/TerraVM/src" make "$@") \
            >> "$OUT/logs/$name.log" 2>&1; then
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
    vm "tossim-$v" micaz sim-sf $args GCC="$ROOT/release/nesc-gcc.sh"
    d="$W/terra-$VER-$v-tossim-py3-x86_64"
    rm -rf "$d"; mkdir -p "$d"
    cp "$W/src/_TOSSIM.so" "$W/src/TOSSIM.py" "$d/"
    defs "$W/src/simbuild/micaz/app.c" "$d/" "tossim-$v"
    # O .defs do TOSSIM é o que vai com o terrac (terrac/samples): tem de ser o commitado.
    n=$(basename "$(ls "$d"/Terra*.defs)")
    cmp -s "$d/$n" "$ROOT/terrac/samples/$n" || { echo "FALHOU: terrac/samples/$n difere do gerado"; exit 1; }
    tar -C "$W" --sort=name --mtime="@$SDE" --owner=0 --group=0 --numeric-owner \
        -cf - "$(basename "$d")" | gzip -n > "$OUT/$(basename "$d").tar.gz"
    # Roda numa pasta gravável: a VM cria ali o sensors.bin e, se não conseguir, sai com
    # exit(0). Por isso o teste exige a linha "OK" e não confia só no código de saída.
    mkdir -p "$W/run-$v"
    (cd "$W/run-$v" && python3 "$ROOT/release/smoke-tossim.py" "$d") | tee -a "$OUT/logs/tossim-$v.log"
    tail -1 "$OUT/logs/tossim-$v.log" | grep -q '^smoke-tossim: .* OK$' || { echo "FALHOU: smoke $v"; exit 1; }
    # Testes da VM com programa Terra carregado (tests/*/test_*.py): os marcados com VM = "grp"
    # rodam com o módulo do Grp, os outros com o do Net.
    for t in "$ROOT"/tests/*/test_*.py; do
        if grep -q '^VM = "grp"' "$t"; then tv=grp; else tv=net; fi
        [ $tv = $v ] || continue
        n=$(basename "$(dirname "$t")")
        mkdir -p "$W/run-$v-$n"
        (cd "$W/run-$v-$n" && python3 "$t" "$d") | tee -a "$OUT/logs/tossim-$v.log"
        tail -1 "$OUT/logs/tossim-$v.log" | grep -q ': OK$' || { echo "FALHOU: $n"; exit 1; }
    done
done

# Firmware micaz (placa MDA100, o padrão do Makefile). O ID do nó é gravado na instalação (ver
# release/README.md).
# O Net leva a fila de mensagens (MOD=MSGQ), como o TOSSIM e a produção de 2016: o TerraNet.defs
# declara qPut/qGet/qSize/qClear. Até a v1.3.0 saía sem ela (#99).
for v in net grp; do
    mod=""; [ "$v" = net ] && mod="MOD=MSGQ"
    for t in nobs bs; do
        vm "micaz-$v-$t" micaz VM=${v^^} $mod TYPE=${t^^}
        grep -E 'bytes in (ROM|RAM)' "$OUT/logs/micaz-$v-$t.log"
        rom=$(awk '/bytes in ROM/{print $1}' "$OUT/logs/micaz-$v-$t.log")
        ram=$(awk '/bytes in RAM/{print $1}' "$OUT/logs/micaz-$v-$t.log")
        # micaz: ATmega128, 128 KB de flash e 4 KB de RAM.
        [ "$rom" -le 131072 ] && [ "$ram" -le 4096 ] || { echo "FALHOU: não cabe no micaz"; exit 1; }
        cp "$W/src/build/micaz/main.exe" "$OUT/terra-$VER-$v-micaz-$t.exe"
        cp "$W/src/build/micaz/main.ihex" "$OUT/terra-$VER-$v-micaz-$t.ihex"
        # A BS não roda programas: só o NOBS tem .defs.
        if [ $t = nobs ]; then
            defs "$W/src/build/micaz/app.c" "$OUT/terra-$VER-$v-micaz-$t.defs" "micaz-$v-$t"
        fi
    done
done

# terra-docs.json (#91): os símbolos dos modelos .defs.in com as descrições de
# TerraVM/src/defs/descricoes.toml e as plataformas dos .defs gerados acima. O gendocs reprova se
# faltar ou sobrar descrição, ou se um .defs gerado não bater com o modelo. O test-gendocs confere
# que ele reprova nesses casos.
python3 "$ROOT/release/test-gendocs.py" | tee -a "$OUT/logs/docs.log"
tail -1 "$OUT/logs/docs.log" | grep -q ': OK$' || { echo "FALHOU: test-gendocs"; exit 1; }
python3 "$ROOT/TerraVM/src/defs/gendocs.py" --version "$VER" \
    --descricoes "$ROOT/TerraVM/src/defs/descricoes.toml" --out "$OUT/terra-docs-$VER.json" \
    net="$ROOT/TerraVM/src/defs/TerraNet.defs.in" grp="$ROOT/TerraVM/src/defs/TerraGrp.defs.in" \
    --build net:tossim:"$W/terra-$VER-net-tossim-py3-x86_64/TerraNet.defs" \
    --build grp:tossim:"$W/terra-$VER-grp-tossim-py3-x86_64/TerraGrp.defs" \
    --build net:micaz:"$OUT/terra-$VER-net-micaz-nobs.defs" \
    --build grp:micaz:"$OUT/terra-$VER-grp-micaz-nobs.defs" | tee -a "$OUT/logs/docs.log"
# As tabelas do site (docs/_includes/generated) têm de ser as geradas deste JSON.
python3 "$ROOT/docs/_tools/genpages.py" --docs "$OUT/terra-docs-$VER.json" \
    --check "$ROOT/docs/_includes/generated" | tee -a "$OUT/logs/docs.log"
tail -1 "$OUT/logs/docs.log" | grep -q ': OK$' || { echo "FALHOU: docs/_includes/generated desatualizado"; exit 1; }

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
# Entradas em ordem de nome e com data fixa, para o jar sair igual a cada build.
(cd "$J/classes" && find . -type f | LC_ALL=C sort | sed 's|^\./||') > "$J/lista"
(cd "$J/classes" && jar --create --file "$OUT/TerraVMControl-$VER.jar" --manifest "$J/manifest" \
    --date="$(date -u -d "@$SDE" +%Y-%m-%dT%H:%M:%SZ)" @"$J/lista")
# Teste: a classe principal carrega com todas as dependências resolvidas.
java -cp "$OUT/TerraVMControl-$VER.jar" -Djava.awt.headless=true \
    "$ROOT/release/LoadCheck.java" app.ControlForm net.tinyos.message.MoteIF \
    | tee -a "$OUT/logs/terracontrol.log"

rm -rf "$W"
echo "OK build-tinyos $VER"
