// Leitura do terrac --diag=json (o formato do release/README.md).
const test = require("node:test");
const assert = require("node:assert");
const { parseDiagOutput, range, summaryText } = require("../out/diag");

const SAIDA = [
  '{"code":"W2003","severity":"warning","file":"p.terra","line":5,"col":3,"msg":"nondeterminism","args":{},"related":[{"file":"p.terra","line":7,"col":3}]}',
  '{"code":"E2001","severity":"error","file":"p.terra","line":2,"col":5,"col_end":9,"msg":"expected `end´"}',
  '{"code":"W5003","severity":"warning","msg":"too big"}',
  "lixo fora do formato",
  '{"summary":{"ok":false,"errors":1,"warnings":2}}',
].join("\n");

test("diagnósticos, resumo e linhas fora do formato", () => {
  const r = parseDiagOutput(SAIDA);
  assert.deepStrictEqual(r.diags.map((d) => d.code), ["W2003", "E2001", "W5003"]);
  assert.strictEqual(r.summary.errors, 1);
  assert.deepStrictEqual(r.other, ["lixo fora do formato"]);
  assert.strictEqual(r.diags[0].related[0].line, 7);
});

test("faixa: col_end, palavra na coluna, linha sem coluna", () => {
  assert.deepStrictEqual(range({ line: 2, col: 5, col_end: 9 }, "var ubyte x;"), { line: 1, start: 4, end: 8 });
  assert.deepStrictEqual(range({ line: 1, col: 5 }, "var ubyte x;"), { line: 0, start: 4, end: 9 });
  assert.deepStrictEqual(range({ line: 3 }, "   emit LEDS(1);  "), { line: 2, start: 3, end: 16 });
  assert.deepStrictEqual(range({}, ""), { line: 0, start: 0, end: 1 });     // W5003, sem linha
  assert.deepStrictEqual(range({ line: 1, col: 40 }, "x"), { line: 0, start: 1, end: 2 });
});

test("resumo", () => {
  assert.match(summaryText({ ok: true, errors: 0, warnings: 1, vm: { name: "TerraNet_MsgQ" }, memory: { total: 51 } }),
    /0 error\(s\), 1 warning\(s\); 51 bytes \(TerraNet_MsgQ\)/);
  assert.strictEqual(summaryText({ ok: false, errors: 2, warnings: 0 }), "terrac: 2 error(s), 0 warning(s)");
});
