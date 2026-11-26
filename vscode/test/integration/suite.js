// Roda dentro do VSCode (extensionTestsPath): cada passo lança exceção se falhar.
const assert = require("assert");
const path = require("path");
const vscode = require("vscode");

async function espera(cond, ms = 10000) {
  const fim = Date.now() + ms;
  while (!(await cond())) {
    if (Date.now() > fim) throw new Error("tempo esgotado");
    await new Promise((r) => setTimeout(r, 100));
  }
}

exports.run = async function () {
  const ws = vscode.workspace.workspaceFolders[0].uri.fsPath;
  const doc = await vscode.workspace.openTextDocument(path.join(ws, "p.terra"));
  await vscode.window.showTextDocument(doc);
  assert.strictEqual(doc.languageId, "terra", "idioma");

  const cmds = await vscode.commands.getCommands(true);
  for (const c of ["terra.compile", "terra.load", "terra.listen", "terra.simulate", "terra.flash"]) {
    assert.ok(cmds.includes(c), c);
  }

  await vscode.commands.executeCommand("terra.compile");
  await espera(() => vscode.languages.getDiagnostics(doc.uri).length > 0);
  const [d] = vscode.languages.getDiagnostics(doc.uri);
  assert.strictEqual(d.severity, vscode.DiagnosticSeverity.Error);
  assert.strictEqual(d.range.start.line, 2);
  assert.strictEqual(d.code.value, "E3001");
  assert.match(String(d.code.target), /terrac-codes\.html#E3001$/);

  const hov = await vscode.commands.executeCommand("vscode.executeHoverProvider", doc.uri, new vscode.Position(3, 6));
  const txt = hov.flatMap((h) => h.contents.map((c) => c.value || String(c))).join("\n");
  assert.match(txt, /emit LEDS\(/, "hover do LEDS");

  const comp = await vscode.commands.executeCommand("vscode.executeCompletionItemProvider", doc.uri, new vscode.Position(3, 0));
  const nomes = comp.items.map((i) => (typeof i.label === "string" ? i.label : i.label.label));
  assert.ok(nomes.includes("getNodeId") && nomes.includes("par/or"), "complemento");
  assert.ok(!nomes.includes("SEND_BS"), "SEND_BS é do Grp");
};
