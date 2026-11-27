#!/bin/bash
# terrac executável (#95): Lua 5.1.5, lpeg 1.0.2 e mcpp 2.7.2 (com os patches da Debian) ligados
# estaticamente num arquivo só, com o terrac dentro. Roda em qualquer Linux x86_64, sem instalar nada.
#   release/build-terrac-exe.sh <saída> [pasta dos fontes baixados]
# Precisa de gcc, make e patch (num Ubuntu: build-essential). Os fontes são baixados e conferidos
# pelo sha256; com a pasta, são lidos (ou guardados) nela.
set -euo pipefail
OUT=$(realpath -m "${1:?saída}")
ROOT=$(cd "$(dirname "$0")/.." && pwd)
W=$(mktemp -d)
SRC=${2:-$W/src}; mkdir -p "$SRC"; SRC=$(cd "$SRC" && pwd)
export SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-$(git -C "$ROOT" log -1 --format=%ct 2>/dev/null || echo 0)}
baixa() {   # baixa <url> <sha256>
    local f="$SRC/$(basename "$1")"
    [ -e "$f" ] || curl -sfL --retry 3 -o "$f" "$1"
    echo "$2  $f" | sha256sum -c --quiet || { echo "build-terrac-exe: sha256 errado: $f"; exit 1; }
}
baixa https://www.lua.org/ftp/lua-5.1.5.tar.gz 2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333
baixa https://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.2.tar.gz 48d66576051b6c78388faad09b70493093264588fcd0f258ddaab1cdd4a15ffe
baixa http://deb.debian.org/debian/pool/main/m/mcpp/mcpp_2.7.2.orig.tar.gz 3b9b4421888519876c4fc68ade324a3bbd81ceeb7092ecdbbc2055099fcb8864
baixa http://deb.debian.org/debian/pool/main/m/mcpp/mcpp_2.7.2-5.3.debian.tar.xz 280ba2407e3251d406eb1aeb70fb8219d191ced28a56245c4beda0db461f174a
cd "$W"
tar xzf "$SRC/lua-5.1.5.tar.gz"; tar xzf "$SRC/lpeg-1.0.2.tar.gz"; tar xzf "$SRC/mcpp_2.7.2.orig.tar.gz"
(cd mcpp-2.7.2 && tar xJf "$SRC/mcpp_2.7.2-5.3.debian.tar.xz" &&
 while read -r p; do [ -n "$p" ] && patch -s -p1 < "debian/patches/$p"; done < debian/patches/series &&
 ./configure -q --enable-mcpplib > /dev/null)
CF=(-O2 -std=gnu99 -ffile-prefix-map="$W"=. -ffile-prefix-map="$ROOT"=. -w)
mkdir o
L=lua-5.1.5/src
for c in $L/*.c; do case $(basename "$c") in lua.c|luac.c|print.c) continue;; esac
    gcc "${CF[@]}" -DLUA_USE_POSIX -c "$c" -o "o/lua_$(basename "$c" .c).o"; done
gcc "${CF[@]}" -DLUA_USE_POSIX -o luahost $L/lua.c o/lua_*.o -lm      # para rodar o pak.lua
for c in lpeg-1.0.2/lp*.c; do gcc "${CF[@]}" -I$L -c "$c" -o "o/lpeg_$(basename "$c" .c).o"; done
for c in main directive eval expand mbchar preproc support system; do
    gcc "${CF[@]}" -DHAVE_CONFIG_H -DMCPP_LIB=1 -Imcpp-2.7.2/src -Imcpp-2.7.2 -c mcpp-2.7.2/src/$c.c -o o/mcpp_$c.o; done
# o terrac empacotado (pak.lua) como um vetor C
cp -a "$ROOT/terrac" t && (cd t && LUA_PATH="$W/lpeg-1.0.2/?.lua;;" ../luahost pak.lua)
./luahost -e '
local s = assert(io.open("t/terrac", "rb")):read("*a")
local o = assert(io.open("terrac_lua.h", "w"))
o:write("unsigned char terrac_lua[] = {\n")
for i = 1, #s, 20 do
  local t = {}
  for j = i, math.min(i + 19, #s) do t[#t + 1] = string.byte(s, j) end
  o:write(table.concat(t, ","), ",\n")
end
o:write("};\nunsigned int terrac_lua_len = ", #s, ";\n")'
gcc "${CF[@]}" -static -s -I$L -I. -o "$OUT" "$ROOT/terrac/exe/main.c" o/*.o -lm -Wl,--build-id=none
rm -rf "$W"
echo "build-terrac-exe: $OUT ($(stat -c %s "$OUT") bytes)"
