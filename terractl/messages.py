"""Mensagens entre o computador e a estação base (TerraVM/src/BasicServices.h) e a decodificação das
mensagens dos motes pelo pktype do programa (o layout vem de `terrac --types`)."""

import json
import os
import struct
import subprocess

AM_NEWPROGVERSION = 0xA0   # 160
AM_NEWPROGBLOCK = 0xA1     # 161
AM_REQPROGBLOCK = 0xA2     # 162
AM_USRMSG = 145            # Net: radioMsg que um mote mandou à BS (SEND com target 1)
AM_SENDBS = 150            # Grp: SEND_BS pela árvore do CTP
BLOCK_SIZE = 24

# Tipos básicos do Terra: formato do struct. Os inteiros ficam em big-endian na memória da VM (tipos
# nx do nesC). O float também é nx_float, mas no atm128 (micaz e o TOSSIM do micaz) a conversão é um
# memcpy (tos/chips/atm128/atm128hardware.h): fica na ordem da máquina, little-endian.
FMT = {"ubyte": ">B", "byte": ">b", "ushort": ">H", "short": ">h", "ulong": ">I", "long": ">i", "float": "<f"}


def new_prog_version(version, header, nblocks, start):
    """newProgVersion: versionId, blockLen, blockStart e os 9 valores do cabeçalho do .vmx."""
    return struct.pack(">12H", version, nblocks, start, *header[:9])


def new_prog_block(version, block, data):
    return struct.pack(">HH24s", version, block, data)


def parse_req_prog_block(p):
    """(reqOper, versionId, blockId) de um reqProgBlock."""
    return struct.unpack(">BHH", p[:5])


def run_types(terra, terrac="terrac"):
    """O JSON do `terrac --types` de um .terra (roda na pasta do fonte, por causa dos #include)."""
    pasta, nome = os.path.split(os.path.abspath(terra))
    r = subprocess.run([terrac, "--types", nome], cwd=pasta, capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit("terractl: terrac --types %s falhou:\n%s" % (terra, (r.stdout + r.stderr).strip()))
    return json.loads(r.stdout)


class Decoder:
    """Decodifica as mensagens dos motes. `pktypes`: o JSON do terrac --types (ou None); `mapa`:
    {valor do type (Net) ou msgId (Grp): nome do pktype}; `nome`: um pktype para todas."""

    def __init__(self, types=None, mapa=None, nome=None):
        self.types = {t["name"]: t for t in (types or {}).get("types", [])}
        self.mapa = dict(mapa or {})
        self.nome = nome
        for n in list(self.mapa.values()) + ([nome] if nome else []):
            if n not in self.types or self.types[n]["kind"] != "pktype":
                raise SystemExit("terractl: o programa não declara o pktype %r" % n)

    def _pktype(self, base, chave):
        if chave in self.mapa:
            return self.types[self.mapa[chave]]
        if self.nome:
            return self.types[self.nome]
        cands = [t for t in self.types.values() if t["kind"] == "pktype" and t.get("from") == base]
        return cands[0] if len(cands) == 1 else None

    @staticmethod
    def campos(tipo, img):
        r = {}
        for f in tipo["fields"]:
            if f["type"] == "payload":
                continue
            fmt = FMT.get(f["type"])
            pedaco = img[f["offset"]:f["offset"] + f["size"]]
            if fmt is None or len(pedaco) < f["size"]:
                continue
            n = f.get("dim") or 1
            vals = list(struct.unpack("%s%d%s" % (fmt[0], n, fmt[1]), pedaco))
            if f["type"] == "float":
                vals = [round(v, 6) for v in vals]
            r[f["name"]] = vals if f.get("dim") else vals[0]
        return r

    def decode(self, am, src, payload):
        """Um dict com a mensagem: am, nó, vm, pktype (ou None), campos e os bytes em hex."""
        m = {"am": am, "node": src, "raw": payload.hex()}
        if am == AM_USRMSG and len(payload) >= 5:
            tp, source, target = struct.unpack(">BHH", payload[:5])
            m.update(vm="net", node=source, type=tp, target=target)
            img, base, chave = payload, "radioMsg", tp
        elif am == AM_SENDBS and len(payload) >= 5:
            sender, seq, evt = struct.unpack(">HHB", payload[:5])
            m.update(vm="grp", node=sender, seq=seq, msgId=evt)
            img, base, chave = bytes([evt]) + payload[5:], "msgBS_t", evt   # a imagem de um msgBS_t
        else:
            return m
        t = self._pktype(base, chave)
        if t:
            m["pktype"] = t["name"]
            m["fields"] = self.campos(t, img)
        return m


def format_text(m):
    """Uma linha legível."""
    if "vm" not in m:
        return "AM %d de %d: %s" % (m["am"], m["node"], m["raw"])
    cab = "nó %d" % m["node"]
    if "pktype" in m:
        fs = " ".join("%s=%s" % (k, v) for k, v in m["fields"].items())
        return "%s  %s  %s" % (cab, m["pktype"], fs)
    if m["vm"] == "net":
        return "%s  type=%d target=%d data=%s" % (cab, m["type"], m["target"], m["raw"][10:])
    return "%s  msgId=%d seq=%d data=%s" % (cab, m["msgId"], m["seq"], m["raw"][10:])
