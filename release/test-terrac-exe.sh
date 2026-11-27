#!/bin/bash
# O terrac executável (#95) num Fedora sem Lua, lpeg nem cpp (o caso do laboratório): os .vmx dos
# exemplos e dos testes saem iguais aos commitados, um erro num #include aponta a linha do
# #include, e um #include que não existe dá E1004.
#   release/test-terrac-exe.sh <terrac executável> [docker|podman]
set -euo pipefail
EXE=$(realpath "${1:?executável}")
ENG=${2:-docker}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
FEDORA=docker.io/library/fedora:43@sha256:f01112b9a1f1d0504ad962d9adfa401425033f8ab067e0a821904ebdde5b8ca5
W=$(mktemp -d)
mkdir "$W/t"
cp "$ROOT"/terrac/samples/* "$W/t/"
for f in "$ROOT"/tests/*/*.terra "$ROOT"/tests/*/*.vmx; do [ -e "$f" ] && cp "$f" "$W/t/"; done
cp "$ROOT"/tests/terrac/diag/{incl.terra,inc_err.h,cppfalta.terra} "$W/t/"
mkdir "$W/esp" && cp "$W"/t/*.vmx "$W/esp/" && rm "$W"/t/*.vmx
cat > "$W/roda.sh" <<'EOS'
set -u
cd /w/t
for p in lua lua5.1 cpp gcc; do command -v $p > /dev/null && echo "fedora: $p instalado"; done
for v in /w/esp/*.vmx; do n=$(basename "$v" .vmx); /terrac "$n.terra" > /dev/null 2>&1; done
/terrac --diag=json incl.terra 2> incl.json > /dev/null
/terrac --diag=json cppfalta.terra 2> cppfalta.json > /dev/null
/terrac --version > /dev/null 2>&1; true
EOS
"$ENG" run --rm -v "$W:/w:Z" -v "$EXE:/terrac:ro,Z" "$FEDORA" bash /w/roda.sh | tee "$W/log"
fail=0
grep -q instalado "$W/log" && { echo "test-terrac-exe: a imagem tem o que não devia"; fail=1; }
n=0
for v in "$W"/esp/*.vmx; do
    if [ -e "$W/t/$(basename "$v")" ] && diff -b -q "$v" "$W/t/$(basename "$v")" > /dev/null; then n=$((n+1))
    else echo "test-terrac-exe: $(basename "$v") DIFERENTE ou não gerado"; fail=1; fi
done
echo "test-terrac-exe: $n .vmx iguais aos commitados"
grep -q '"code":"E3001".*"file":"incl.terra","line":2,.*"include":{"file":"inc_err.h","line":2' "$W/t/incl.json" ||
    { echo "test-terrac-exe: erro no #include fora da linha: $(cat "$W/t/incl.json")"; fail=1; }
grep -q '"code":"E1004".*"file":"cppfalta.terra","line":2' "$W/t/cppfalta.json" ||
    { echo "test-terrac-exe: #include que falta sem E1004: $(cat "$W/t/cppfalta.json")"; fail=1; }
rm -rf "$W"
[ $fail = 0 ] || { echo "FALHOU: test-terrac-exe"; exit 1; }
echo "OK test-terrac-exe (Fedora 43, sem Lua nem cpp)"
