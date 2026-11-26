# Histórico: a versão de produção e a avaliação das evoluções (2026-11-21 e 22)

Material da análise que identificou a versão de produção do Terra (os `_TOSSIMmodule.so` de 2016,
distribuídos na `.ova` TerraNG v0.3.0) e avaliou o que mudou depois dela. Levou ao `master` atual
(tag `production-2016-05`, commit `f02b8e6`) e às tags e ao galho descritos no `CLAUDE.md`.

Os caminhos `handoff/...` citados nos arquivos são da pasta de trabalho local, fora do git, onde
ficam também o que não entra aqui: a `.ova` (`.vmdk` e `.ovf`), o rootfs extraído e os `.so`
gerados (os de produção estão anexos à release `v0.3.0`; os reproduzidos, só os sha256 abaixo).

| Arquivo | O que é |
|---|---|
| `avaliacao-vm-tinyos.md` | Relatório: os 31 commits depois da produção que tocam o build TinyOS e os bugs achados |
| `provenance/linecheck.py` | Conta as linhas do DWARF de um `.so` que caem além do fim do arquivo, ou em linha sem código, numa versão do fonte |
| `provenance/blanklines.py` | Auxiliar do `linecheck.py` (linhas sem código de um fonte) |
| `provenance/so-{Net,Grp}.lines.tsv` | As linhas de cada fonte que geraram código nos `.so` de produção (tabela de linhas do DWARF) |
| `provenance/terra-commits.txt` | Os 430 commits do repositório usados na comparação |
| `provenance/ova-packages.txt` | Os pacotes instalados na `.ova` (Ubuntu 12.04.5 i386, nesC 1.3.4, gcc 4.6.3...) |
| `provenance/ova-{tinyos,terra_env}.sh` | O ambiente do usuário na `.ova` |
| `repro/README.md` | A receita que reproduziu os dois `.so` de produção (código, dados e linhas idênticos) |
| `repro/ovabuild.sh` | Compila dentro do rootfs da `.ova` (podman `--rootfs`, `setarch i686`) |
| `repro/*/build.log`, `repro/build-net-rfpower3.log` | Logs dessas compilações (com `RFPOWER=3`, 1 byte do `.text` difere) |
| `repro/sse/` | A mesma compilação com `-mfpmath=sse -msse2` (degrau 1 do oráculo; ponto flutuante não pesa) |
| `repro/SHA256SUMS`, `repro/sse/SHA256SUMS` | sha256 dos `.so` reproduzidos (diferem dos de produção só no `.debug_str`, `.debug_info` e build-id, como explica o `repro/README.md`) |
| `py3/SHA256SUMS` | O `_TOSSIM.so` x86_64 do CI do PR #13 usado no oráculo do TerraSim (degrau 2) |

Os `.so` de produção, para comparar: Net `8214f2c5fc585601b4f5462bcb3301b2517b445b5f3a5840c277b225731a99ed`
(806184 bytes), Grp `93cc11cf74657c74c26153df46ce9dc173904fcc4466f62694151843a4288869` (1028648 bytes).
