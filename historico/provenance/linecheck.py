import sys, os, re
lines_file, base15, gh = sys.argv[1:4]
P = "/home/branco/gitspace/Terra/TerraVM/src/"
ghmap = [("CustomVMs/TerraNet/", "platforms/TinyOS/Net/"), ("CustomVMs/TerraGrp/", "platforms/TinyOS/Grp/"),
         ("XComps/", "platforms/TinyOS/common/"), ("dataQueue", "system/dataQueue"), ("vmBitVector", "system/vmBitVector")]
refs = {}
for l in open(lines_file):
    f, n = l.rstrip("\n").split("\t")
    if f and not f.startswith("/"): f = P + f
    if f.startswith(P):
        refs.setdefault(f[len(P):], set()).add(int(n))
def bad(path, ns):
    if not os.path.exists(path): return None, None
    src = open(path, encoding="latin-1").read().split("\n")
    out = [n for n in ns if n > len(src)]
    blank = [n for n in ns if n <= len(src) and re.fullmatch(r"\s*(//.*|/\*.*|\*(\s.*)?|\*/.*)?\s*", src[n-1])]
    return out, blank
print("%-36s %5s | %-18s | %-18s" % ("arquivo", "linhas", "ova 2015 (fora/vazias)", "GitHub 2018 (fora/vazias)"))
for f in sorted(refs):
    ns = refs[f]
    g = f
    for a, b in ghmap:
        if g.startswith(a): g = b + g[len(a):]; break
    r15 = bad(os.path.join(base15, f), ns); rgh = bad(os.path.join(gh, g), ns)
    fmt = lambda r: "não existe" if r[0] is None else "%d / %d" % (len(r[0]), len(r[1]))
    print("%-36s %5d | %-22s | %-18s" % (f, len(ns), fmt(r15), fmt(rgh)))
