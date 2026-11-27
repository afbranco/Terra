#!/usr/bin/env python3
"""Empacota o terractl (#92) num .pyz (zipapp: roda com `python3 terractl-<v>.pyz`), com a versão da
release e datas fixas, para o arquivo sair igual a cada build (#18). O pyserial (Python puro, BSD-3)
vai dentro (#145): o .pyz roda com o python3 da máquina, sem pip nem venv.
Uso: build-terractl.py <saída.pyz> <versão> <SOURCE_DATE_EPOCH>
O fonte do pyserial é baixado do PyPI (sha256 conferido), ou lido de $PYSERIAL_SDIST. É o sdist, não o
wheel, porque só ele traz a licença (BSD-3 exige a cópia)."""
import hashlib
import io
import os
import sys
import tarfile
import time
import urllib.request
import zipfile

PYSERIAL = ("https://files.pythonhosted.org/packages/1e/7d/ae3f0a63f41e4d2f6cb66a5b57197850f919f59e558159a4dd3a818f5082/"
            "pyserial-3.5.tar.gz",
            "3c77e014170dfffbd816e6ffc205e9842efb10be9f58ec16d3e8675b4925cddb")

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
saida, versao, sde = sys.argv[1], sys.argv[2], int(sys.argv[3])
data = time.gmtime(max(sde, 315532800))[:6]          # o zip não guarda datas antes de 1980
pasta = os.path.join(RAIZ, "terractl")
if os.environ.get("PYSERIAL_SDIST"):
    sd = open(os.environ["PYSERIAL_SDIST"], "rb").read()
else:
    sd = urllib.request.urlopen(PYSERIAL[0], timeout=60).read()
if hashlib.sha256(sd).hexdigest() != PYSERIAL[1]:
    sys.exit("build-terractl: sha256 do pyserial diferente do esperado")
tz = tarfile.open(fileobj=io.BytesIO(sd))
# o pacote serial/ (sem o miniterm, o terminal de linha de comando) e a licença
P = "pyserial-3.5/"
serial = sorted(m.name[len(P):] for m in tz.getmembers() if m.isfile() and m.name.startswith(P + "serial/")
                and m.name.endswith(".py") and "miniterm" not in m.name)
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
        # O ruído do simulador (terractl sim), o mesmo do TerraSim.py da .ova.
        poe("terractl/meyer-heavy_short.txt",
            open(os.path.join(RAIZ, "TerraVM", "src", "meyer-heavy_short.txt"), encoding="utf-8").read())
        for n in serial:
            poe(n, tz.extractfile(P + n).read())
        poe("serial/LICENSE.txt", tz.extractfile(P + "LICENSE.txt").read())
        poe("__main__.py", "import sys\n\nfrom terractl.cli import main\n\nsys.exit(main())\n")
os.chmod(saida, 0o755)
print("build-terractl: %s (%s, %d arquivos, pyserial 3.5 com %d)" % (saida, versao, len(arquivos), len(serial)))
