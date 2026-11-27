#!/bin/bash
# O pacote terra-<v>-linux-x86_64.tar.gz (#95): tudo para compilar, simular, carregar e gravar, sem
# instalar nada nem precisar de admin. Descompactar numa pasta qualquer e usar bin/terrac e
# bin/terractl. A extensão do VSCode (linux-x64) leva o mesmo conteúdo.
#   release/build-bundle.sh <versão> <pasta com os anexos da release> <pasta de saída>
# Anexos usados: terrac-<v>-linux-x86_64, terractl-<v>.pyz, terra-<v>-{net,grp}-tossim-py3-x86_64.tar.gz,
# terra-<v>-{net,grp}-micaz-{bs,nobs}.{exe,ihex} e terra-<v>-{net,grp}-micaz-nobs.defs.
# O Python é o do python-build-standalone (o do uv), baixado com o sha256 conferido (ou de
# $PYTHON_STANDALONE): o _TOSSIM.so é do Python 3.14, e o do sistema pode ser outro ou não existir.
set -euo pipefail
VER=${1:?versão}
IN=$(cd "${2:?pasta dos anexos}" && pwd)
OUT=$(mkdir -p "${3:?saída}" && cd "$3" && pwd)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PBS_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20261110/cpython-3.14.10%2B20261110-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz"
PBS_SHA=c2ff2e97422f5d3896a16e0317fd212ba977bbf2688d93a6f7a03d817506bd30
NOME="terra-$VER-linux-x86_64"
W=$(mktemp -d)
P="$W/$NOME"
mkdir -p "$P"/{bin,lib,tossim,firmware,defs}

# Python 3.14, sem o que o terractl não usa (testes, Tk, IDLE, pip, cabeçalhos)
PBS=${PYTHON_STANDALONE:-$W/python.tar.gz}
[ -e "$PBS" ] || curl -sfL --retry 3 -o "$PBS" "$PBS_URL"
echo "$PBS_SHA  $PBS" | sha256sum -c --quiet || { echo "build-bundle: sha256 do Python errado"; exit 1; }
tar xzf "$PBS" -C "$P"
L="$P/python/lib/python3.14"
rm -rf "$L"/{test,idlelib,tkinter,turtledemo,ensurepip,pydoc_data,__phello__} "$L"/site-packages/pip* \
       "$L"/config-3.14-* "$L"/lib-dynload/_tkinter* "$L"/lib-dynload/*_test* \
       "$P"/python/lib/{libtcl,libtk,itcl,tcl,tk,thread}* "$P"/python/{include,share} \
       "$P"/python/bin/{idle*,pip*,pydoc*,python3*-config}
find "$L" -depth -name __pycache__ -path '*/test*' -exec rm -rf {} +

# terrac (o executável, com o pré-processador dentro) e terractl
install -m 755 "$IN/terrac-$VER-linux-x86_64" "$P/lib/terrac"
cp "$IN/terractl-$VER.pyz" "$P/lib/terractl.pyz"
cat > "$P/bin/terrac" <<'EOS'
#!/bin/sh
# terrac do pacote: os .defs do simulador ficam em defs/ (um .defs na pasta do programa tem prioridade)
H=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)
exec "$H/lib/terrac" -I"$H/defs" "$@"
EOS
cat > "$P/bin/terractl" <<'EOS'
#!/bin/sh
# terractl do pacote: o Python dele (-I: sem os pacotes nem as variáveis do Python da máquina) e,
# por TERRA_HOME, o terrac, os simuladores (sim --vm) e o firmware (flash net-bs...) do pacote
H=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)
TERRA_HOME=$H exec "$H/python/bin/python3" -I "$H/lib/terractl.pyz" "$@"
EOS
chmod 755 "$P"/bin/*

# simuladores, firmware e .defs
for vm in net grp; do
    mkdir -p "$P/tossim/$vm"
    tar xzf "$IN/terra-$VER-$vm-tossim-py3-x86_64.tar.gz" -C "$P/tossim/$vm" --strip-components=1
    mv "$P"/tossim/$vm/Terra*.defs "$P/defs/"
    cp "$IN/terra-$VER-$vm-micaz-nobs.defs" "$P/defs/"
    for t in bs nobs; do cp "$IN/terra-$VER-$vm-micaz-$t".{exe,ihex} "$P/firmware/"; done
done

# licenças e leia-me
mkdir "$P/licenses"
cp "$ROOT/LICENSE.txt" "$P/licenses/Terra-GPL-3.0.txt"
"$P/lib/terrac" --licenses > "$P/licenses/terrac-lua-lpeg-mcpp.txt"
cp "$L/LICENSE.txt" "$P/licenses/Python.txt"
python3 -c 'import sys,zipfile; sys.stdout.buffer.write(zipfile.ZipFile(sys.argv[1]).read("serial/LICENSE.txt"))' \
    "$P/lib/terractl.pyz" > "$P/licenses/pyserial.txt"
sed "s/@VER@/$VER/g" "$ROOT/release/bundle-README.txt" > "$P/README.txt"

# tar.gz reproduzível (#18)
SDE=${SOURCE_DATE_EPOCH:-$(git -C "$ROOT" log -1 --format=%ct)}
tar --sort=name --owner=0 --group=0 --numeric-owner --mtime="@$SDE" -C "$W" -cf - "$NOME" |
    gzip -n -9 > "$OUT/$NOME.tar.gz"
echo "build-bundle: $OUT/$NOME.tar.gz ($(du -sh "$P" | cut -f1) descompactado, $(du -h "$OUT/$NOME.tar.gz" | cut -f1))"
rm -rf "$W"
