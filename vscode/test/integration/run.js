// Teste de integração: a extensão num VSCode de verdade (baixado pelo @vscode/test-electron, a versão
// mínima do engines). Precisa de display: no CI, com xvfb-run. Roda da pasta montada pelo
// build-vscode.sh (com bin/ e docs/).
const fs = require("fs");
const os = require("os");
const path = require("path");
const { runTests } = require("@vscode/test-electron");

async function main() {
  const raiz = path.join(__dirname, "..", "..");
  const ws = fs.mkdtempSync(path.join(os.tmpdir(), "terra-ws-"));
  // Um terrac falso: o formato do --diag=json e do --types é testado no build-terrac.sh.
  const fake = path.join(ws, "fake-terrac");
  fs.writeFileSync(fake, `#!/bin/sh
case "$*" in
  *--types*) echo '{"format":1,"types":[]}' ;;
  *) echo '{"code":"E3001","severity":"error","file":"p.terra","line":3,"col":1,"msg":"variable/event/function \\"y\\" is not declared"}' >&2
     echo '{"summary":{"ok":false,"errors":1,"warnings":0}}' >&2
     exit 1 ;;
esac
`, { mode: 0o755 });
  fs.writeFileSync(path.join(ws, "p.terra"), '#include "TerraNet.defs"\nvar ubyte x;\ny = 1;\nemit LEDS(x);\n');
  fs.mkdirSync(path.join(ws, ".vscode"));
  fs.writeFileSync(path.join(ws, ".vscode", "settings.json"),
    JSON.stringify({ "terra.terracPath": fake, "terra.compileOnSave": false }));
  await runTests({
    version: "1.85.2",
    extensionDevelopmentPath: raiz,
    extensionTestsPath: path.join(__dirname, "suite.js"),
    launchArgs: [ws, "--disable-extensions", "--disable-workspace-trust",
      "--user-data-dir", fs.mkdtempSync(path.join(os.tmpdir(), "terra-ud-"))],
  });
  console.log("integração: OK");
}

main().catch((e) => {
  console.error("integração: FALHOU", e);
  process.exit(1);
});
