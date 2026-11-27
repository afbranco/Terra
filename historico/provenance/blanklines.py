import sys, os, re
lines_file, base = sys.argv[1:3]
P = "/home/branco/gitspace/Terra/TerraVM/src/"
refs = {}
for l in open(lines_file):
    f, n = l.rstrip("\n").split("\t")
    if f and not f.startswith("/"): f = P + f
    if f.startswith(P): refs.setdefault(f[len(P):], set()).add(int(n))
for f in sorted(refs):
    p = os.path.join(base, f)
    if not os.path.exists(p): continue
    src = open(p, encoding="latin-1").read().split("\n")
    for n in sorted(refs[f]):
        if n <= len(src) and re.fullmatch(r"\s*(//.*|/\*.*|\*(\s.*)?|\*/.*)?\s*", src[n-1]):
            ctx = " ⏎ ".join(s.strip()[:40] for s in src[max(0,n-2):n+1])
            print("%-34s %5d  [%s]" % (f, n, ctx))
