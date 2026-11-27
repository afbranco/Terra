#!/bin/bash
# Extensão do VSCode (#93): testes e o .vsix, com o terractl e o terra-docs.json da mesma release
# dentro. Precisa do node (20 ou mais novo) e dos anexos do build-tinyos.sh.
#   release/build-vscode.sh <versão> <pasta com terra-docs-<v>.json e terractl-<v>.pyz> <pasta de saída>
# Se a pasta tiver o terra-<v>-linux-x86_64.tar.gz (#95), sai também a terra-vscode-<v>-linux-x64.vsix,
# com o pacote dentro (bundle/), testada na integração com o terrac de verdade do pacote.
set -euo pipefail
VER=${1:?versão}
IN=$(cd "${2:?pasta dos anexos}" && pwd)
OUT=$(mkdir -p "${3:?pasta de saída}" && cd "$3" && pwd)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
W=$(mktemp -d)
mkdir -p "$OUT/logs"
LOG="$OUT/logs/vscode.log"

cp -a "$ROOT/vscode/." "$W/"
rm -rf "$W/node_modules" "$W/out" "$W/bin" "$W/docs" "$W"/*.vsix
mkdir -p "$W/bin" "$W/docs"
cp "$IN/terractl-$VER.pyz" "$W/bin/terractl.pyz"
cp "$IN/terra-docs-$VER.json" "$W/docs/terra-docs.json"
cp "$ROOT/LICENSE.txt" "$W/LICENSE"
# O Marketplace só aceita X.Y.Z: os builds que não são de release (dev-<commit>) saem com 0.0.0.
if [[ $VER =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then EXT=$VER; else EXT=0.0.0; fi
(cd "$W" && npm ci --no-audit --no-fund >> "$LOG" 2>&1 &&
    npm pkg set version="$EXT" >> "$LOG" &&
    npm test 2>&1 | tee -a "$LOG" | grep -E '^# (tests|pass|fail)') || { tail -40 "$LOG"; echo "FALHOU: vscode"; exit 1; }
grep -q '^# fail 0$' "$LOG" || { echo "FALHOU: testes da extensão"; exit 1; }
# Integração num VSCode de verdade (baixado): precisa de display. No CI, VSCODE_INTEGRATION=1 exige.
if command -v xvfb-run > /dev/null; then
    (cd "$W" && xvfb-run -a node test/integration/run.js 2>&1 | tee -a "$LOG" | grep -E '^integração') ||
        { tail -40 "$LOG"; echo "FALHOU: integração"; exit 1; }
    grep -q '^integração: OK' "$LOG" || { tail -40 "$LOG"; echo "FALHOU: integração"; exit 1; }
elif [ "${VSCODE_INTEGRATION:-0}" = 1 ]; then
    echo "FALHOU: sem xvfb-run para o teste de integração"; exit 1
else
    echo "build-vscode: sem xvfb-run, teste de integração pulado" | tee -a "$LOG"
fi
(cd "$W" && npx --no-install vsce package --no-dependencies --allow-missing-repository \
    -o "$OUT/terra-vscode-$VER.vsix" >> "$LOG" 2>&1) || { tail -20 "$LOG"; echo "FALHOU: vsce"; exit 1; }
# O .vsix leva o terractl, o terra-docs.json, a gramática e o código compilado.
unzip -l "$OUT/terra-vscode-$VER.vsix" > "$W/lista"
for f in extension/bin/terractl.pyz extension/docs/terra-docs.json extension/out/extension.js \
         extension/syntaxes/terra.tmLanguage.json extension/package.json; do
    grep -q " $f\$" "$W/lista" || { echo "FALHOU: $f fora do .vsix"; exit 1; }
done
if grep -qE ' extension/(src|test|node_modules)/' "$W/lista"; then echo "FALHOU: .vsix com src/test/node_modules"; exit 1; fi
echo "OK build-vscode $VER: terra-vscode-$VER.vsix (versão da extensão $EXT)" | tee -a "$LOG"

PK="$IN/terra-$VER-linux-x86_64.tar.gz"
[ -e "$PK" ] || { echo "build-vscode: sem $(basename "$PK"), só a extensão universal" | tee -a "$LOG"; exit 0; }
mkdir -p "$W/bundle" && cp "$PK" "$W/bundle/"
if command -v xvfb-run > /dev/null; then
    # sem terrac falso: o do pacote, descompactado na ativação (no runner não há terrac no PATH)
    (cd "$W" && TERRA_INTEGRATION_BUNDLE=1 xvfb-run -a node test/integration/run.js 2>&1 | tee -a "$LOG" |
        grep -E '^integração') || { tail -40 "$LOG"; echo "FALHOU: integração com o pacote"; exit 1; }
    grep -q '^integração: OK (terrac do pacote)' "$LOG" || { tail -40 "$LOG"; echo "FALHOU: integração com o pacote"; exit 1; }
elif [ "${VSCODE_INTEGRATION:-0}" = 1 ]; then
    echo "FALHOU: sem xvfb-run para o teste de integração"; exit 1
fi
(cd "$W" && npx --no-install vsce package --no-dependencies --allow-missing-repository --target linux-x64 \
    -o "$OUT/terra-vscode-$VER-linux-x64.vsix" >> "$LOG" 2>&1) || { tail -20 "$LOG"; echo "FALHOU: vsce linux-x64"; exit 1; }
unzip -l "$OUT/terra-vscode-$VER-linux-x64.vsix" | grep -q " extension/bundle/terra-$VER-linux-x86_64.tar.gz\$" ||
    { echo "FALHOU: pacote fora da linux-x64"; exit 1; }
echo "OK build-vscode $VER: terra-vscode-$VER-linux-x64.vsix (com o pacote)" | tee -a "$LOG"
