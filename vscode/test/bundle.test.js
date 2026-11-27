// O pacote dentro da extensão (#95): descompactado uma vez por versão, com as permissões, e as
// versões antigas apagadas.
const test = require("node:test");
const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");
const { ensureBundle } = require("../out/bundle");

function pacote(ext, ver) {
  const w = fs.mkdtempSync(path.join(os.tmpdir(), "terra-pk-"));
  const nome = `terra-${ver}-linux-x86_64`;
  fs.mkdirSync(path.join(w, nome, "bin"), { recursive: true });
  fs.writeFileSync(path.join(w, nome, "bin", "terractl"), "#!/bin/sh\necho ok\n", { mode: 0o755 });
  fs.mkdirSync(path.join(ext, "bundle"), { recursive: true });
  for (const f of fs.readdirSync(path.join(ext, "bundle"))) fs.rmSync(path.join(ext, "bundle", f));
  execFileSync("tar", ["czf", path.join(ext, "bundle", nome + ".tar.gz"), "-C", w, nome]);
  return nome;
}

test("pacote descompactado, executável e só a versão atual", async () => {
  const ext = fs.mkdtempSync(path.join(os.tmpdir(), "terra-ext-"));
  const sto = path.join(fs.mkdtempSync(path.join(os.tmpdir(), "terra-sto-")), "com espaço");
  assert.strictEqual(await ensureBundle(ext, sto), undefined, "sem bundle/");
  const v1 = pacote(ext, "1.7.0");
  const h1 = await ensureBundle(ext, sto);
  assert.strictEqual(h1, path.join(sto, v1));
  assert.strictEqual(execFileSync(path.join(h1, "bin", "terractl")).toString().trim(), "ok");
  fs.writeFileSync(path.join(h1, "marca"), "x");
  assert.strictEqual(await ensureBundle(ext, sto), h1, "segunda ativação");
  assert.ok(fs.existsSync(path.join(h1, "marca")), "não descompacta de novo");
  const v2 = pacote(ext, "1.8.0");
  const h2 = await ensureBundle(ext, sto);
  assert.strictEqual(h2, path.join(sto, v2));
  assert.deepStrictEqual(fs.readdirSync(sto).filter((f) => !f.startsWith(".")), [v2], "a versão antiga sai");
});
