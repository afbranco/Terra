// O package.json e o código combinam: cada comando declarado é registrado, cada arquivo existe.
const test = require("node:test");
const assert = require("node:assert");
const fs = require("fs");
const path = require("path");

const raiz = path.join(__dirname, "..");
const pkg = JSON.parse(fs.readFileSync(path.join(raiz, "package.json"), "utf8"));
const js = fs.readFileSync(path.join(raiz, "out", "extension.js"), "utf8");

test("comandos registrados", () => {
  for (const c of pkg.contributes.commands) assert.ok(js.includes(`registerCommand("${c.command}"`), c.command);
});

test("configurações usadas existem no package.json", () => {
  const props = Object.keys(pkg.contributes.configuration.properties);
  const usadas = [...js.matchAll(/get\(\s*[`"]([\w.${}]+)[`"]/g)].map((m) => m[1]);
  for (const u of usadas) {
    const nomes = u.includes("${variant}") ? ["net", "grp"].map((v) => u.replace("${variant}", v)) : [u];
    for (const n of nomes) assert.ok(props.includes("terra." + n), n);
  }
});

test("arquivos do contributes", () => {
  const c = pkg.contributes;
  for (const p of [c.languages[0].configuration, c.grammars[0].path, c.snippets[0].path]) {
    assert.ok(fs.existsSync(path.join(raiz, p)), p);
    JSON.parse(fs.readFileSync(path.join(raiz, p), "utf8"));
  }
});
