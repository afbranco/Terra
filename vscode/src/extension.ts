// Extensão Terra para o VSCode (#93): destaque de sintaxe, trechos, hover e complemento pelo
// terra-docs.json, erros do `terrac --diag=json` no painel Problems e comandos que chamam o terractl
// (carregar, mensagens da BS, simular, gravar o micaz). O terractl e o terra-docs.json vêm dentro da
// extensão (bin/ e docs/), da mesma release. A extensão linux-x64 leva também o pacote
// terra-<v>-linux-x86_64.tar.gz (bundle/, #95): terrac, terractl com o Python dele, simuladores e
// firmware, descompactados na primeira ativação na pasta da extensão (globalStorage), por versão.

import * as fs from "fs";
import * as path from "path";
import * as vscode from "vscode";
import { ensureBundle, run } from "./bundle";
import { Diag, parseDiagOutput, range, summaryText } from "./diag";
import { Docs, KEYWORDS, hoverMarkdown, signature, variantOf } from "./docs";

const CODES_URL = "https://afbranco.github.io/Terra/terrac-codes.html#";

let diagnostics: vscode.DiagnosticCollection;
let status: vscode.StatusBarItem;
let output: vscode.OutputChannel;
let docs: Docs | undefined;
let ctx: vscode.ExtensionContext;
let home: string | undefined;           // o pacote descompactado (extensão linux-x64)
let homeReady: Promise<void> = Promise.resolve();

function cfg() {
  return vscode.workspace.getConfiguration("terra");
}

// Uma configuração explícita vale; senão o do pacote; senão o do PATH.
function terracPath(): string {
  return cfg().get<string>("terracPath") || (home ? path.join(home, "bin", "terrac") : "terrac");
}

function terractl(): string[] {
  const p = cfg().get<string>("terractlPath");
  if (!p && home) return [path.join(home, "bin", "terractl")];
  return [cfg().get<string>("pythonPath") || "python3", p || ctx.asAbsolutePath(path.join("bin", "terractl.pyz"))];
}

function loadDocs(): void {
  const p = cfg().get<string>("docsPath") || ctx.asAbsolutePath(path.join("docs", "terra-docs.json"));
  try {
    docs = new Docs(JSON.parse(fs.readFileSync(p, "utf8")));
  } catch (e) {
    docs = undefined;
    output.appendLine(`terra: could not read ${p}: ${e}`);
  }
}


function toDiagnostic(d: Diag, doc: vscode.TextDocument): vscode.Diagnostic {
  const lineNo = Math.min(Math.max((d.line ?? 1) - 1, 0), doc.lineCount - 1);
  const r = range({ ...d, line: lineNo + 1, col: d.include ? undefined : d.col }, doc.lineAt(lineNo).text);
  let msg = d.msg;
  if (d.include) msg += ` (in ${d.include.file}:${d.include.line})`;
  const v = new vscode.Diagnostic(new vscode.Range(r.line, r.start, r.line, r.end), msg,
    d.severity === "error" ? vscode.DiagnosticSeverity.Error : vscode.DiagnosticSeverity.Warning);
  v.source = "terrac";
  v.code = { value: d.code, target: vscode.Uri.parse(CODES_URL + d.code) };
  if (d.related?.length) {
    v.relatedInformation = d.related.filter((p) => p.line).map((p) => {
      const l = Math.min(p.line! - 1, doc.lineCount - 1);
      return new vscode.DiagnosticRelatedInformation(
        new vscode.Location(doc.uri, new vscode.Position(l, Math.max((p.col ?? 1) - 1, 0))), "the other access");
    });
  }
  return v;
}

// Compila o arquivo; devolve o caminho do .vmx se deu certo.
async function compile(doc: vscode.TextDocument, quiet = false): Promise<string | undefined> {
  if (doc.languageId !== "terra" || doc.uri.scheme !== "file") return undefined;
  if (doc.isDirty) await doc.save();
  await homeReady;
  const file = doc.uri.fsPath;
  const terrac = terracPath();
  const args = [...(cfg().get<string[]>("compileArgs") ?? []), "--diag=json", path.basename(file)];
  const r = await run(terrac, args, path.dirname(file));
  const res = parseDiagOutput(r.stderr);
  diagnostics.set(doc.uri, res.diags.map((d) => toDiagnostic(d, doc)));
  for (const l of res.other) output.appendLine(l);
  status.text = res.summary ? `$(${res.summary.ok ? "check" : "error"}) ${summaryText(res.summary)}` : "$(error) terrac";
  status.show();
  if (!res.summary) {
    output.appendLine(r.stderr);
    if (!quiet) {
      vscode.window.showErrorMessage(`terra: terrac did not run (${terrac}). Set terra.terracPath.`);
    }
    return undefined;
  }
  return res.summary.ok ? file.replace(/\.terra$/, ".vmx") : undefined;
}

// O layout dos pktype do programa (terrac --types), num arquivo para o terractl.
async function types(file: string): Promise<string | undefined> {
  const terrac = terracPath();
  const r = await run(terrac, ["--types", path.basename(file)], path.dirname(file));
  if (r.code !== 0) return undefined;
  const dir = ctx.globalStorageUri.fsPath;
  fs.mkdirSync(dir, { recursive: true });
  const out = path.join(dir, path.basename(file, ".terra") + ".types.json");
  fs.writeFileSync(out, r.stdout);
  return out;
}

function connection(): string[] {
  return cfg().get<string>("connection") === "sf"
    ? ["--sf", cfg().get<string>("sfAddress") || "localhost:9002"]
    : ["--serial", cfg().get<string>("serialPort") || "/dev/ttyUSB1"];
}

function terminal(name: string, argv: string[], cwd?: string): void {
  const t = vscode.window.createTerminal({ name, shellPath: argv[0], shellArgs: argv.slice(1), cwd });
  t.show();
}

function activeTerra(): vscode.TextDocument | undefined {
  const d = vscode.window.activeTextEditor?.document;
  if (!d || d.languageId !== "terra") {
    vscode.window.showWarningMessage("terra: open a .terra file first");
    return undefined;
  }
  return d;
}

async function cmdLoad(): Promise<void> {
  const doc = activeTerra();
  if (!doc) return;
  const vmx = await compile(doc);
  if (!vmx) return void vscode.window.showErrorMessage("terra: the program has errors (see Problems)");
  const tj = await types(doc.uri.fsPath);
  terminal(`Terra: load ${path.basename(vmx)}`, [...terractl(), "load", vmx, ...connection(), "--listen",
    "--time", "0", ...(tj ? ["--types", tj] : [])], path.dirname(vmx));
}

async function cmdListen(): Promise<void> {
  const d = vscode.window.activeTextEditor?.document;
  const tj = d?.languageId === "terra" ? await types(d.uri.fsPath) : undefined;
  terminal("Terra: messages", [...terractl(), "listen", ...connection(), ...(tj ? ["--types", tj] : [])]);
}

async function cmdSimulate(): Promise<void> {
  const doc = activeTerra();
  if (!doc) return;
  const vmx = await compile(doc);
  if (!vmx) return void vscode.window.showErrorMessage("terra: the program has errors (see Problems)");
  const variant = variantOf(doc.getText()) ?? "net";
  let tossim = cfg().get<string>(`simulation.tossimPath.${variant}`) || "";
  const tj = await types(doc.uri.fsPath);
  const work = path.join(ctx.globalStorageUri.fsPath, "sim");
  fs.mkdirSync(work, { recursive: true });
  const common = ["--grid", cfg().get<string>("simulation.grid") || "3x3",
    "--time", String(cfg().get<number>("simulation.time") ?? 60), ...(tj ? ["--types", tj] : [])];
  if (home && !tossim) {
    // o simulador e o Python do pacote: sem contêiner
    terminal(`Terra: simulate ${path.basename(vmx)}`, [...terractl(), "sim", vmx, "--vm", variant, ...common], work);
    return;
  }
  if (!tossim) {
    const pick = await vscode.window.showOpenDialog({
      canSelectFolders: true, canSelectFiles: false,
      openLabel: `Folder of terra-<v>-${variant}-tossim-py3-x86_64`,
    });
    if (!pick?.length) return;
    tossim = pick[0].fsPath;
    await cfg().update(`simulation.tossimPath.${variant}`, tossim, vscode.ConfigurationTarget.Global);
  }
  const [py, pyz] = terractl();
  let argv = [py, pyz, "sim", vmx, "--tossim", tossim, ...common];
  const image = cfg().get<string>("simulation.containerImage") || "";
  if (image) {
    // O _TOSSIM.so é do Python 3.14: roda na imagem do tinyos-toolchain, com as pastas montadas no
    // mesmo caminho (a pasta de trabalho gravável: a VM cria nela o sensors.bin).
    const dirs = new Set([work, path.dirname(vmx), tossim, path.dirname(pyz), ...(tj ? [path.dirname(tj)] : [])]);
    const engine = cfg().get<string>("simulation.containerEngine") || "podman";
    argv = [engine, "run", "--rm", "-it", ...[...dirs].flatMap((d) => ["-v", `${d}:${d}:Z`]), "-w", work, image,
      "python3", ...argv.slice(1)];
  }
  terminal(`Terra: simulate ${path.basename(vmx)}`, argv, work);
}

async function cmdFlash(): Promise<void> {
  await homeReady;
  let firmware: string | undefined;
  if (home) {
    // o firmware do pacote, pelo nome curto que o terractl entende
    const OUTRO = "Another file...";
    const q = await vscode.window.showQuickPick([
      { label: "net-nobs", description: "TerraNet, common node" },
      { label: "net-bs", description: "TerraNet, base station (node 1)" },
      { label: "grp-nobs", description: "TerraGrp, common node" },
      { label: "grp-bs", description: "TerraGrp, base station (node 1)" },
      { label: OUTRO }], { placeHolder: "Firmware to flash" });
    if (!q) return;
    if (q.label !== OUTRO) firmware = q.label;
  }
  if (!firmware) {
    const pick = await vscode.window.showOpenDialog({
      canSelectMany: false, filters: { Firmware: ["exe"] }, openLabel: "Firmware (terra-<v>-*-micaz-*.exe)",
    });
    if (!pick?.length) return;
    firmware = pick[0].fsPath;
  }
  const node = await vscode.window.showInputBox({
    prompt: "Node id (the base station is 1)", validateInput: (v) => (/^\d+$/.test(v) && +v > 0 && +v < 65535 ? null : "1 to 65534"),
  });
  if (!node) return;
  const port = await vscode.window.showInputBox({
    prompt: "Programming port (on the MIB520, the first one)", value: cfg().get<string>("flashPort") || "/dev/ttyUSB0",
  });
  if (!port) return;
  terminal(`Terra: flash node ${node}`, [...terractl(), "flash", firmware, "--node", node, "--port", port]);
}

function wordAt(doc: vscode.TextDocument, pos: vscode.Position): string | undefined {
  const r = doc.getWordRangeAtPosition(pos, /[A-Za-z_][A-Za-z0-9_]*/);
  return r ? doc.getText(r) : undefined;
}

export function activate(context: vscode.ExtensionContext): void {
  ctx = context;
  output = vscode.window.createOutputChannel("Terra");
  diagnostics = vscode.languages.createDiagnosticCollection("terrac");
  status = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left);
  status.command = "workbench.actions.view.problems";
  loadDocs();
  homeReady = ensureBundle(context.extensionPath, context.globalStorageUri.fsPath, (s) => output.appendLine(s))
    .then((h) => { home = h; })
    .catch((e) => { output.appendLine(`terra: could not unpack the package: ${e}`); });
  const sel: vscode.DocumentSelector = { language: "terra" };

  context.subscriptions.push(
    output, diagnostics, status,
    vscode.commands.registerCommand("terra.compile", async () => {
      const d = activeTerra();
      if (d) await compile(d);
    }),
    vscode.commands.registerCommand("terra.load", cmdLoad),
    vscode.commands.registerCommand("terra.listen", cmdListen),
    vscode.commands.registerCommand("terra.simulate", cmdSimulate),
    vscode.commands.registerCommand("terra.flash", cmdFlash),
    vscode.workspace.onDidSaveTextDocument((d) => {
      if (d.languageId === "terra" && cfg().get<boolean>("compileOnSave")) void compile(d, true);
    }),
    vscode.workspace.onDidCloseTextDocument((d) => diagnostics.delete(d.uri)),
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (e.affectsConfiguration("terra.docsPath")) loadDocs();
    }),
    vscode.languages.registerHoverProvider(sel, {
      provideHover(doc, pos) {
        const w = wordAt(doc, pos);
        const s = w && docs?.lookup(w, variantOf(doc.getText()));
        if (!s) return undefined;
        const md = new vscode.MarkdownString(hoverMarkdown(s, variantOf(doc.getText())));
        return new vscode.Hover(md);
      },
    }),
    vscode.languages.registerCompletionItemProvider(sel, {
      provideCompletionItems(doc) {
        const v = variantOf(doc.getText());
        const items = KEYWORDS.map((k) => new vscode.CompletionItem(k, vscode.CompletionItemKind.Keyword));
        for (const s of docs?.symbols(v) ?? []) {
          const kind = { event: vscode.CompletionItemKind.Event, function: vscode.CompletionItemKind.Function,
            constant: vscode.CompletionItemKind.Constant, macro: vscode.CompletionItemKind.Snippet,
            type: vscode.CompletionItemKind.Struct }[s.kind];
          const it = new vscode.CompletionItem(s.name, kind);
          it.detail = signature(s).split("\n")[0];
          it.documentation = new vscode.MarkdownString(hoverMarkdown(s, v));
          items.push(it);
        }
        return items;
      },
    }),
  );
  for (const d of vscode.workspace.textDocuments) {
    if (d.languageId === "terra" && cfg().get<boolean>("compileOnSave")) void compile(d, true);
  }
}

export function deactivate(): void {}
