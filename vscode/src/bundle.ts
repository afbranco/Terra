// O pacote terra-<v>-linux-x86_64 dentro da extensão linux-x64 (#95). Sem o vscode, para os testes.

import { execFile } from "child_process";
import * as fs from "fs";
import * as path from "path";

export function run(cmd: string, args: string[], cwd: string): Promise<{ code: number; stdout: string; stderr: string }> {
  return new Promise((resolve) => {
    execFile(cmd, args, { cwd, maxBuffer: 16 * 1024 * 1024 }, (err: any, stdout, stderr) => {
      if (err && typeof err.code !== "number") {
        resolve({ code: -1, stdout: "", stderr: `${cmd}: ${err.message}` });
      } else resolve({ code: err ? err.code : 0, stdout, stderr });
    });
  });
}

// Descompacta o pacote que vem na extensão (bundle/terra-<v>-linux-x86_64.tar.gz), uma vez por
// versão, e apaga as versões antigas. O tar guarda as permissões de execução, que o .vsix não guarda.
export async function ensureBundle(extDir: string, storage: string,
  log: (s: string) => void = () => {}): Promise<string | undefined> {
  const dir = path.join(extDir, "bundle");
  const tgz = fs.existsSync(dir) ? fs.readdirSync(dir).find((f) => /^terra-.+-linux-x86_64\.tar\.gz$/.test(f)) : undefined;
  if (!tgz) return undefined;
  const nome = tgz.replace(/\.tar\.gz$/, "");
  const dest = path.join(storage, nome);
  if (!fs.existsSync(path.join(dest, "bin", "terractl"))) {
    fs.mkdirSync(storage, { recursive: true });
    const tmp = fs.mkdtempSync(path.join(storage, ".unpack-"));
    log(`terra: unpacking ${tgz} into ${storage}`);
    const r = await run("tar", ["xzf", path.join(dir, tgz), "-C", tmp], storage);
    if (r.code !== 0) {
      fs.rmSync(tmp, { recursive: true, force: true });
      throw new Error(`tar: ${r.stderr}`);
    }
    try {
      fs.renameSync(path.join(tmp, nome), dest);
    } catch (e) {
      if (!fs.existsSync(path.join(dest, "bin", "terractl"))) throw e;   // outra janela chegou antes
    }
    fs.rmSync(tmp, { recursive: true, force: true });
  }
  for (const f of fs.readdirSync(storage)) {
    if (/^terra-.+-linux-x86_64$/.test(f) && f !== nome) fs.rmSync(path.join(storage, f), { recursive: true, force: true });
  }
  return dest;
}

