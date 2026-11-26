// Hover e complemento a partir do terra-docs-<v>.json (release/README.md, "terra-docs.json"). Sem
// dependência do VSCode, para os testes rodarem no node.

export interface Param { name: string | null; type: string | null }
export interface Field { name: string; type: string; short?: string }

export interface Sym {
  name: string;
  kind: "event" | "function" | "constant" | "macro" | "type";
  group: string;
  direction?: "emit" | "await";
  type?: string | null;
  params?: Param[];
  returns?: string | null;
  attrs?: string[];
  value?: number | string;
  body?: string;
  type_kind?: string;
  fields?: Field[];
  filter?: { type: string; id: number; matches: string };
  unsafe_with?: string[];
  requires: string[];
  variants: string[];
  platforms: string[];
  short: string;
  long?: string;
  example?: string;
  since?: string;
}

export interface DocsFile { schema: number; terra: string; variants: string[]; symbols: Sym[] }

export const KEYWORDS = [
  "and", "async", "await", "break", "config", "dec", "do", "else", "else/if", "emit", "end", "event",
  "finally", "FOREVER", "from", "function", "if", "inc", "input", "loop", "nohold", "not", "null", "or",
  "output", "par", "par/and", "par/or", "pktype", "pure", "regtype", "return", "safe", "sizeof", "then",
  "unsafe", "var", "with",
  "ubyte", "ushort", "ulong", "byte", "short", "long", "float", "payload", "void",
];

// A variante do programa pelo .defs incluído: TerraNet.defs (net), TerraGrp.defs (grp).
export function variantOf(text: string): string | undefined {
  const m = /^\s*#\s*include\s*["<]Terra(Net|Grp)[^">]*\.defs[">]/m.exec(text);
  return m ? m[1].toLowerCase() : undefined;
}

export class Docs {
  readonly byName = new Map<string, Sym[]>();
  constructor(readonly file: DocsFile) {
    for (const s of file.symbols) {
      const l = this.byName.get(s.name) ?? [];
      l.push(s);
      this.byName.set(s.name, l);
    }
  }

  // A entrada da variante (ou a primeira, sem variante conhecida).
  lookup(name: string, variant?: string): Sym | undefined {
    const l = this.byName.get(name);
    if (!l) return undefined;
    return (variant && l.find((s) => s.variants.includes(variant))) || l[0];
  }

  symbols(variant?: string): Sym[] {
    const r: Sym[] = [];
    for (const [name] of this.byName) {
      const s = this.lookup(name, variant);
      if (s && (!variant || s.variants.includes(variant))) r.push(s);
    }
    return r;
  }
}

function params(ps?: Param[]): string {
  return (ps ?? []).map((p) => [p.type, p.name].filter(Boolean).join(" ")).join(", ");
}

export function signature(s: Sym): string {
  switch (s.kind) {
    case "event": {
      if (s.direction === "emit") return `emit ${s.name}(${params(s.params)});`;
      const v = s.type && s.type !== "void" ? `   // value: ${s.type}` : "";
      const f = s.filter ? `\nawait ${s.name}(${s.filter.type});   // ${s.filter.matches}` : "";
      return `await ${s.name};${v}${f}`;
    }
    case "function":
      return `${s.attrs?.length ? s.attrs.join(" ") + " " : ""}${s.returns ?? "void"} ${s.name}(${params(s.params)})`;
    case "constant":
      return `${s.type ? s.type + " " : ""}${s.name} = ${s.value}`;
    case "macro":
      return `${s.name}(${(s.params ?? []).map((p) => p.name).join(", ")})  =>  ${s.body ?? ""}`;
    case "type":
      return `${s.type_kind ?? "regtype"} ${s.name} with\n` +
        (s.fields ?? []).map((f) => `  var ${f.type} ${f.name};`).join("\n") + "\nend";
  }
}

// Texto em Markdown do hover.
export function hoverMarkdown(s: Sym, variant?: string): string {
  const out: string[] = ["```terra", signature(s), "```", s.short];
  if (s.long) out.push("", s.long);
  if (s.kind === "type" && s.fields?.some((f) => f.short)) {
    out.push("", ...s.fields.map((f) => `- \`${f.name}\`: ${f.short ?? ""}`));
  }
  if (s.example) out.push("", "```terra", s.example, "```");
  const notas: string[] = [];
  if (variant && !s.variants.includes(variant)) notas.push(`**not in Terra${variant === "net" ? "Net" : "Grp"}**`);
  notas.push(s.variants.map((v) => (v === "net" ? "TerraNet" : "TerraGrp")).join(", "));
  if (s.requires.length) notas.push(`build with ${s.requires.join(", ")}`);
  notas.push(s.platforms.length ? s.platforms.join(", ") : "no firmware of the release");
  if (s.unsafe_with?.length) notas.push(`unsafe with ${s.unsafe_with.join(", ")}`);
  if (s.since) notas.push(`since ${s.since}`);
  out.push("", "*" + notas.join(" · ") + "*");
  return out.join("\n");
}
