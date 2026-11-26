// Hover e complemento pelo terra-docs.json da release (TERRA_DOCS, ou o docs/ da extensão).
const test = require("node:test");
const assert = require("node:assert");
const fs = require("fs");
const path = require("path");
const { Docs, hoverMarkdown, signature, variantOf } = require("../out/docs");

const arq = process.env.TERRA_DOCS || path.join(__dirname, "..", "docs", "terra-docs.json");
const docs = new Docs(JSON.parse(fs.readFileSync(arq, "utf8")));

test("variante pelo .defs incluído", () => {
  assert.strictEqual(variantOf('#include "TerraNet.defs"\nvar ubyte x;'), "net");
  assert.strictEqual(variantOf('// x\n  #include <TerraGrp.defs>'), "grp");
  assert.strictEqual(variantOf("var ubyte x;"), undefined);
});

test("cada variante acha a sua entrada", () => {
  // Um nome declarado de jeito diferente em cada VM sai com uma entrada por variante.
  const base = { kind: "constant", group: "misc", requires: [], platforms: ["tossim"], short: "x" };
  const d2 = new Docs({ schema: 1, terra: "t", variants: ["net", "grp"], symbols: [
    { ...base, name: "K", value: 1, variants: ["net"] }, { ...base, name: "K", value: 2, variants: ["grp"] }] });
  assert.strictEqual(d2.lookup("K", "net").value, 1);
  assert.strictEqual(d2.lookup("K", "grp").value, 2);
  assert.strictEqual(d2.lookup("K").value, 1);
  assert.deepStrictEqual(d2.symbols("grp").map((s) => s.value), [2]);
  assert.ok(!docs.symbols("net").some((s) => !s.variants.includes("net")));
  assert.ok(docs.symbols("grp").some((s) => s.name === "SEND_BS"));
  assert.ok(!docs.symbols("net").some((s) => s.name === "SEND_BS"));
});

test("hover de cada tipo de símbolo", () => {
  for (const s of docs.file.symbols) {
    const md = hoverMarkdown(s, s.variants[0]);
    assert.ok(md.includes(s.short), s.name);
    assert.ok(signature(s).includes(s.name), s.name);
  }
  assert.match(signature(docs.lookup("LEDS", "net")), /^emit LEDS\(ubyte/);
  assert.match(signature(docs.lookup("BROADCAST", "net")), /BROADCAST = 65535/);
  assert.match(hoverMarkdown(docs.lookup("SEND_BS", "grp"), "net"), /not in TerraNet/);
});
