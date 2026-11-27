#!/bin/bash
# O pacote terra-<v>-linux-x86_64.tar.gz (#95) num Fedora 43 sem Python, Lua nem cpp (o caso do
# laboratório), descompactado numa pasta com espaço no nome e chamado por um link no PATH:
# compila um exemplo (os .defs vêm do pacote) com o .vmx igual ao commitado, simula a TerraNet e a
# TerraGrp com as mensagens decodificadas (terrac --types do pacote), grava um .ihex com ID.
#   release/test-bundle.sh <terra-<v>-linux-x86_64.tar.gz> [docker|podman]
set -euo pipefail
TGZ=$(realpath "${1:?pacote}")
ENG=${2:-docker}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
FEDORA=docker.io/library/fedora:43@sha256:f01112b9a1f1d0504ad962d9adfa401425033f8ab067e0a821904ebdde5b8ca5
W=$(mktemp -d)
mkdir "$W/p"
cp "$ROOT/terrac/samples/Count2Leds.terra" "$ROOT/tests/terractl/terractl.terra" \
   "$ROOT/tests/terractlgrp/terractlgrp.terra" "$W/p/"
cat > "$W/roda.sh" <<'EOS'
set -u
for p in python3 python lua lua5.1 cpp gcc; do command -v $p > /dev/null && echo "fedora: $p instalado"; done
mkdir -p "/opt/com espaço" /usr/local/bin && cd "/opt/com espaço" && tar xzf /w/pacote.tar.gz
ln -s "/opt/com espaço"/terra-*/bin/terrac "/opt/com espaço"/terra-*/bin/terractl /usr/local/bin/
cd /w/p
echo "== versão"; terractl --version
echo "== compila"; terrac Count2Leds.terra | tail -1
terrac terractl.terra > /dev/null; terrac terractlgrp.terra > /dev/null
echo "== net"; terractl sim terractl.vmx --terra terractl.terra --grid 2x2 --time 15 2>&1 | grep -c "BS: node 11  leitura"
echo "== grp"; terractl sim terractlgrp.vmx --vm grp --terra terractlgrp.terra --grid 2x2 --time 15 2>&1 | grep -c "dado"
echo "== flash"; terractl flash net-nobs --node 5 -o no5.ihex
EOS
cp "$TGZ" "$W/pacote.tar.gz"
"$ENG" run --rm -v "$W:/w:Z" "$FEDORA" bash /w/roda.sh 2>&1 | tee "$W/log"
fail=0
# confere <seção> <regex>: alguma linha da seção (até o próximo "==") casa
confere() { awk -v s="== $1" '$0 == s {p=1; next} /^== / {p=0} p' "$W/log" | grep -Eq "$2" ||
    { echo "test-bundle: $1 falhou"; fail=1; }; }
grep -q instalado "$W/log" && { echo "test-bundle: a imagem tem o que não devia"; fail=1; }
confere versão '^terractl [0-9]'
confere compila 'Success'
diff -b -q "$ROOT/terrac/samples/Count2Leds.vmx" "$W/p/Count2Leds.vmx" > /dev/null ||
    { echo "test-bundle: Count2Leds.vmx diferente do commitado"; fail=1; }
confere net '^[1-9]'
confere grp '^[1-9]'
grep -q '^:' "$W/p/no5.ihex" 2>/dev/null || { echo "test-bundle: flash -o sem .ihex"; fail=1; }
rm -rf "$W"
[ $fail = 0 ] || { echo "FALHOU: test-bundle"; exit 1; }
echo "OK test-bundle (Fedora 43, sem Python, Lua nem cpp)"
