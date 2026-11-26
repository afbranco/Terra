#!/usr/bin/env python3
"""Empacota o terractl (#92) num .pyz (zipapp: roda com `python3 terractl-<v>.pyz`), com a versão da
release e datas fixas, para o arquivo sair igual a cada build (#18).
Uso: build-terractl.py <saída.pyz> <versão> <SOURCE_DATE_EPOCH>"""
import os
import sys
import time
import zipfile

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
saida, versao, sde = sys.argv[1], sys.argv[2], int(sys.argv[3])
data = time.gmtime(max(sde, 315532800))[:6]          # o zip não guarda datas antes de 1980
pasta = os.path.join(RAIZ, "terractl")
arquivos = sorted(f for f in os.listdir(pasta) if f.endswith(".py"))
with open(saida, "wb") as f:
    f.write(b"#!/usr/bin/env python3\n")
    with zipfile.ZipFile(f, "w", zipfile.ZIP_DEFLATED) as z:
        def poe(nome, texto):
            info = zipfile.ZipInfo(nome, data)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            z.writestr(info, texto)
        for a in arquivos:
            texto = open(os.path.join(pasta, a), encoding="utf-8").read()
            if a == "__init__.py":
                texto = texto.replace('__version__ = "dev"', '__version__ = "%s"' % versao)
            poe("terractl/" + a, texto)
        poe("__main__.py", "import sys\n\nfrom terractl.cli import main\n\nsys.exit(main())\n")
os.chmod(saida, 0o755)
print("build-terractl: %s (%s, %d arquivos)" % (saida, versao, len(arquivos)))
