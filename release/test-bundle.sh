#!/bin/bash
# O pacote terra-<v>-linux-x86_64.tar.gz (#95) num Fedora 43 sem Python, Lua nem cpp (o caso do
# laboratório), descompactado numa pasta com espaço no nome e chamado por um link no PATH:
# compila um exemplo (os .defs vêm do pacote) com o .vmx igual ao commitado, simula a TerraNet e a
# TerraGrp com as mensagens decodificadas (terrac --types do pacote), grava um .ihex com ID.
#   release/test-bundle.sh <terra-<v>-linux-x86_64.tar.gz> [docker|podman] [imagem]
# Com outra imagem (release/test-bundle-distros.sh), o mesmo teste noutra distro; a última linha diz
# a distro, a glibc e o que ela tem instalado. Só no Fedora 43 (o padrão) ter Python, Lua ou cpp
# reprova: a prova de que o pacote não depende deles.
set -euo pipefail
TGZ=$(realpath "${1:?pacote}")
ENG=${2:-docker}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
FEDORA=docker.io/library/fedora:43@sha256:f01112b9a1f1d0504ad962d9adfa401425033f8ab067e0a821904ebdde5b8ca5
IMG=${3:-$FEDORA}
W=$(mktemp -d)
mkdir "$W/p"
# descompactado aqui (a imagem pode não ter tar nem gzip), numa pasta com espaço no nome
mkdir "$W/com espaço" && tar xzf "$TGZ" -C "$W/com espaço"
cp "$ROOT/terrac/samples/Count2Leds.terra" "$ROOT/tests/terractl/terractl.terra" \
   "$ROOT/tests/terractlgrp/terractlgrp.terra" "$W/p/"
# (os logs da simulação vão para o /tmp do contêiner: com o docker, o que ele cria na pasta montada
# é do root e o rm -rf do fim não apagaria)
cat > "$W/roda.sh" <<'EOS'
set -u
tem=""
for p in python3 python lua lua5.1 cpp gcc; do command -v $p > /dev/null && tem="$tem $p"; done
echo "== distro"; (. /etc/os-release; echo "$PRETTY_NAME")
echo "== glibc"; getconf GNU_LIBC_VERSION 2>/dev/null || ldd --version 2>&1 | head -1
echo "== tem"; echo "${tem:- nada}"
mkdir -p /usr/local/bin
ln -s "/w/com espaço"/terra-*/bin/terrac "/w/com espaço"/terra-*/bin/terractl /usr/local/bin/
cd /w/p
echo "== versão"; terractl --version
echo "== compila"; terrac Count2Leds.terra | tail -1
terrac terractl.terra > /dev/null; terrac terractlgrp.terra > /dev/null
echo "== net"; terractl sim terractl.vmx --terra terractl.terra --grid 2x2 --time 15 --logdir /tmp/sim1 2>&1 | grep -c "BS: node 11  leitura"
echo "== grp"; terractl sim terractlgrp.vmx --vm grp --terra terractlgrp.terra --grid 2x2 --time 15 --logdir /tmp/sim2 2>&1 | grep -c "dado"
echo "== flash"; terractl flash net-nobs --node 5 -o no5.ihex
EOS
"$ENG" run --rm -v "$W:/w:Z" "$IMG" bash /w/roda.sh > "$W/log" 2>&1 || true
[ -n "${QUIET:-}" ] || cat "$W/log"
fail=0
# confere <seção> <regex>: alguma linha da seção (até o próximo "==") casa
confere() { awk -v s="== $1" '$0 == s {p=1; next} /^== / {p=0} p' "$W/log" | grep -Eq "$2" ||
    { echo "test-bundle: $1 falhou"; fail=1; }; }
secao() { awk -v s="== $1" '$0 == s {p=1; next} /^== / {p=0} p' "$W/log" | head -1; }
if [ "$IMG" = "$FEDORA" ] && [ "$(secao tem)" != " nada" ]; then
    echo "test-bundle: a imagem tem o que não devia:$(secao tem)"; fail=1
fi
confere versão '^terractl [0-9a-z]'
confere compila 'Success'
diff -b -q "$ROOT/terrac/samples/Count2Leds.vmx" "$W/p/Count2Leds.vmx" > /dev/null ||
    { echo "test-bundle: Count2Leds.vmx diferente do commitado"; fail=1; }
confere net '^[1-9]'
confere grp '^[1-9]'
grep -q '^:' "$W/p/no5.ihex" 2>/dev/null || { echo "test-bundle: flash -o sem .ihex"; fail=1; }
linha="$(secao distro) | glibc $(secao glibc | grep -o '[0-9][0-9.]*' | head -1) | tem:$(secao tem)"
# o que o contêiner criou como root (docker) sai por ele mesmo
"$ENG" run --rm -v "$W:/w:Z" "$IMG" rm -rf "/w/p" "/w/com espaço" > /dev/null 2>&1 || true
rm -rf "$W"
[ $fail = 0 ] || { echo "FALHOU: test-bundle: $linha"; exit 1; }
echo "OK test-bundle: $linha"
