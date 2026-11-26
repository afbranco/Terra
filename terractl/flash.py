"""Gravação do firmware da release com o ID do nó, sem o TinyOS: o que o tos-set-symbols faz (trocar o
valor inicial de TOS_NODE_ID e ActiveMessageAddressC__addr na seção .data do .exe) e o avr-objcopy
-O ihex, em Python; depois o avrdude grava."""

import shutil
import struct
import subprocess

SYMBOLS = ("TOS_NODE_ID", "ActiveMessageAddressC__addr")
PT_LOAD = 1
SHT_SYMTAB, SHT_NOBITS = 2, 8
SHF_ALLOC = 2


class Elf:
    """ELF de 32 bits little-endian (o .exe do avr-gcc)."""

    def __init__(self, data):
        if data[:4] != b"\x7fELF" or data[4] != 1 or data[5] != 1:
            raise SystemExit("terractl: the firmware must be the .exe (32-bit ELF) of the release")
        self.data = bytearray(data)
        (_t, _m, _v, _e, phoff, shoff, _f, _eh, phsz, phn, shsz, shn, shstr) = struct.unpack_from(
            "<HHIIIIIHHHHHH", data, 16)
        self.ph = [struct.unpack_from("<IIIIIIII", data, phoff + i * phsz) for i in range(phn)]
        sh = [struct.unpack_from("<IIIIIIIIII", data, shoff + i * shsz) for i in range(shn)]
        nomes = sh[shstr]

        def nome(tab, off):
            i = tab[4] + off
            return bytes(data[i:data.index(b"\0", i)]).decode()
        self.secs = [dict(name=nome(nomes, s[0]), type=s[1], flags=s[2], addr=s[3], offset=s[4],
                          size=s[5], link=s[6], entsize=s[9]) for s in sh]
        self.syms = {}
        for s in self.secs:
            if s["type"] != SHT_SYMTAB:
                continue
            strtab = sh[s["link"]]
            for k in range(s["size"] // 16):
                st_name, value, size, _info, _other, shndx = struct.unpack_from(
                    "<IIIBBH", data, s["offset"] + 16 * k)
                if st_name and shndx < len(self.secs):
                    self.syms[nome(strtab, st_name)] = (value, size, self.secs[shndx]["name"])

    def section(self, name):
        for s in self.secs:
            if s["name"] == name:
                return s
        raise SystemExit("terractl: the firmware has no section %s" % name)

    def set_symbol(self, name, value):
        if name not in self.syms:
            raise SystemExit("terractl: the firmware has no symbol %s" % name)
        addr, size, sec = self.syms[name]
        if sec != ".data":
            raise SystemExit("terractl: %s is not in .data" % name)
        d = self.section(".data")
        pos = d["offset"] + addr - d["addr"]
        self.data[pos:pos + size] = struct.pack("<I", value)[:size]

    def get_symbol(self, name):
        addr, size, _ = self.syms[name]
        d = self.section(".data")
        pos = d["offset"] + addr - d["addr"]
        return int.from_bytes(self.data[pos:pos + size], "little")

    def image(self):
        """{endereço físico (LMA): byte} das seções carregadas (.text, .data...), como o objcopy."""
        mem = {}
        for s in self.secs:
            if not (s["flags"] & SHF_ALLOC) or s["type"] == SHT_NOBITS or s["size"] == 0:
                continue
            for p in self.ph:
                _tipo, off, vaddr, paddr, filesz = p[0], p[1], p[2], p[3], p[4]
                if p[0] == PT_LOAD and off <= s["offset"] < off + filesz:
                    lma = paddr + (s["offset"] - off)
                    for i in range(s["size"]):
                        mem[lma + i] = self.data[s["offset"] + i]
                    break
        return mem


def ihex(mem):
    """Intel HEX com registros de 16 bytes e registros de segmento (tipo 02) acima de 64 KB."""
    linhas, seg = [], 0

    def reg(tipo, addr, dados):
        b = bytes([len(dados), addr >> 8 & 0xFF, addr & 0xFF, tipo]) + bytes(dados)
        return ":" + (b + bytes([(-sum(b)) & 0xFF])).hex().upper()
    addrs = sorted(mem)
    i = 0
    while i < len(addrs):
        a = addrs[i]
        if a >> 16 != seg:
            seg = a >> 16
            linhas.append(reg(2, 0, struct.pack(">H", seg << 12)))
        dados = [mem[a]]
        while (i + 1 < len(addrs) and addrs[i + 1] == a + len(dados) and len(dados) < 16
               and (a + len(dados)) >> 16 == seg):
            i += 1
            dados.append(mem[addrs[i]])
        linhas.append(reg(0, a & 0xFFFF, dados))
        i += 1
    linhas.append(":00000001FF")
    return "\n".join(linhas) + "\n"


def with_node_id(exe_path, node):
    elf = Elf(open(exe_path, "rb").read())
    for s in SYMBOLS:
        elf.set_symbol(s, node)
    return elf


def avrdude_cmd(ihex_path, port, programmer="mib510", part="m128", avrdude="avrdude"):
    """Os fusíveis são os do make do TinyOS para o micaz."""
    return [avrdude, "-c" + programmer, "-P" + port, "-p" + part,
            "-U", "hfuse:w:0xd9:m", "-U", "efuse:w:0xff:m", "-U", "flash:w:%s:i" % ihex_path]


def flash(ihex_path, port, programmer="mib510", avrdude="avrdude"):
    if not shutil.which(avrdude):
        raise SystemExit("terractl: avrdude not found (apt install avrdude)")
    return subprocess.run(avrdude_cmd(ihex_path, port, programmer, avrdude=avrdude)).returncode
