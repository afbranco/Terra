// Leitura do `terrac --diag=json` (release/README.md): uma linha JSON por diagnóstico no stderr e uma
// linha de resumo no fim. Sem dependência do VSCode, para os testes rodarem no node.

export interface Pos { file?: string; line?: number; col?: number }

export interface Diag {
  code: string;
  severity: "error" | "warning";
  file?: string;
  line?: number;       // base 1; ausente num diagnóstico do programa todo (W5003)
  col?: number;        // base 1
  col_end?: number;    // exclusiva
  msg: string;
  include?: Pos;       // erro dentro de um #include: o ponto real
  related?: Pos[];
}

export interface Summary {
  ok: boolean;
  errors: number;
  warnings: number;
  vm?: { name: string; version: string };
  memory?: { total: number; code?: number; ctl_vars?: number; stack?: number; radio_msgs?: number };
}

export interface Result { diags: Diag[]; summary?: Summary; other: string[] }

export function parseDiagOutput(text: string): Result {
  const r: Result = { diags: [], other: [] };
  for (const raw of text.split(/\r?\n/)) {
    const l = raw.trim();
    if (!l) continue;
    let o: any;
    try {
      o = JSON.parse(l);
    } catch {
      r.other.push(l);            // o terrac antigo ou uma falha fora do formato
      continue;
    }
    if (o && o.summary) r.summary = o.summary;
    else if (o && typeof o.code === "string") r.diags.push(o as Diag);
    else r.other.push(l);
  }
  return r;
}

// Faixa (base 0, fim exclusivo) de um diagnóstico numa linha de texto: da coluna até col_end, ou a
// palavra que começa na coluna, ou a linha toda (sem espaços nas pontas) sem coluna.
export function range(d: Diag, lineText: string): { line: number; start: number; end: number } {
  const line = Math.max((d.line ?? 1) - 1, 0);
  if (d.col && d.col >= 1) {
    const start = Math.min(d.col - 1, lineText.length);
    let end: number;
    if (d.col_end && d.col_end > d.col) end = d.col_end - 1;
    else {
      const m = /^[A-Za-z0-9_]+/.exec(lineText.slice(start));
      end = start + (m ? m[0].length : 1);
    }
    return { line, start, end: Math.min(Math.max(end, start + 1), Math.max(lineText.length, start + 1)) };
  }
  const start = lineText.length - lineText.trimStart().length;
  return { line, start, end: Math.max(lineText.trimEnd().length, start + 1) };
}

export function summaryText(s?: Summary): string {
  if (!s) return "terrac: no summary";
  const n = `${s.errors} error(s), ${s.warnings} warning(s)`;
  if (!s.ok || !s.memory) return `terrac: ${n}`;
  return `terrac: ${n}; ${s.memory.total} bytes${s.vm ? ` (${s.vm.name})` : ""}`;
}
