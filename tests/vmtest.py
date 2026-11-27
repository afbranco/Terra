"""O que os testes de VM (tests/*/test_*.py e tests/avrora/avrora_vmx.py) usam do terractl (#162).

A carga de um programa é a mesma do `terractl load`: o .vmx lido por `terractl.loader.Program` e os
pacotes montados por `terractl.messages`. Os testes entregam os pacotes eles mesmos, no tempo
simulado (alguns perdem ou trocam pacotes de propósito), em vez do `Loader`, que usa o relógio real.
Se a carga do terractl quebrar, os testes de VM reprovam.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from terractl import link, messages  # noqa: E402,F401  (os testes de pedido de bloco e o Avrora usam)
from terractl.loader import Program  # noqa: E402


def deploy(vmx, version_id=1):
    """Os pacotes do TerraControl para um .vmx, em ordem: (AM, payload) do newProgVersion e de cada
    newProgBlock."""
    p = Program(vmx)
    pacotes = [(messages.AM_NEWPROGVERSION, messages.new_prog_version(version_id, p.header, p.nblocks, p.start))]
    for b in sorted(p.blocks):
        pacotes.append((messages.AM_NEWPROGBLOCK, messages.new_prog_block(version_id, b, p.blocks[b])))
    return pacotes
