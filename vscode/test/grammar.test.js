// A gramática TextMate tokeniza os elementos da linguagem (com o motor do próprio VSCode).
const test = require("node:test");
const assert = require("node:assert");
const fs = require("fs");
const path = require("path");
const tm = require("vscode-textmate");
const onig = require("vscode-oniguruma");

const PROG = `#include "TerraNet.defs"
#define N 3
pktype msg from radioMsg with
  var ubyte[2] v;
end
var float f = 1.5; // comentário
loop i, N do
  par/or do
    await 1h20min;
  with
    emit LEDS(0x07);
  end
  if not f then f = 2.0; else/if f > 1 then f = 0; end
  getNodeId();
end
/* bloco */`;

let grammar;
test.before(async () => {
  const wasm = fs.readFileSync(require.resolve("vscode-oniguruma/release/onig.wasm")).buffer;
  await onig.loadWASM(wasm);
  const reg = new tm.Registry({
    onigLib: Promise.resolve({ createOnigScanner: (s) => new onig.OnigScanner(s), createOnigString: (s) => new onig.OnigString(s) }),
    loadGrammar: async () => tm.parseRawGrammar(
      fs.readFileSync(path.join(__dirname, "..", "syntaxes", "terra.tmLanguage.json"), "utf8"), "terra.tmLanguage.json"),
  });
  grammar = await reg.loadGrammar("source.terra");
});

function tokens() {
  const r = [];
  let st = tm.INITIAL;
  for (const linha of PROG.split("\n")) {
    const t = grammar.tokenizeLine(linha, st);
    for (const k of t.tokens) r.push([linha.slice(k.startIndex, k.endIndex), k.scopes[k.scopes.length - 1]]);
    st = t.ruleStack;
  }
  return r;
}

test("escopos", () => {
  const t = tokens();
  const escopo = (txt) => (t.find(([x]) => x === txt) || [])[1];
  const esperado = {
    "#include": "keyword.control.directive.include.terra",
    '"TerraNet.defs"': "string.quoted.other.include.terra",
    "#define": "keyword.control.directive.terra",
    pktype: "keyword.other.terra",
    from: "keyword.other.terra",
    radioMsg: "variable.other.terra",
    ubyte: "storage.type.terra",
    float: "storage.type.terra",
    "1.5": "constant.numeric.float.terra",
    "// comentário": "comment.line.double-slash.terra",
    loop: "keyword.control.terra",
    "par/or": "keyword.control.terra",
    "1h20min": "constant.numeric.time.terra",
    LEDS: "support.constant.terra",
    "0x07": "constant.numeric.hex.terra",
    not: "keyword.operator.logical.terra",
    "else/if": "keyword.control.terra",
    getNodeId: "entity.name.function.terra",
    "/*": "comment.block.terra",
    " bloco ": "comment.block.terra",
  };
  for (const [txt, sc] of Object.entries(esperado)) assert.strictEqual(escopo(txt), sc, txt);
});
