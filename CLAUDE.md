# Terra: guia para o Claude Code

Sessão criada em 2026-11-21 a partir da sessão tinyos-toolchain. Este arquivo leva o contexto
de lá.

## GitHub (decidido pelo Prof. em 2026-11-22, revisto no mesmo dia)

- Repositório público `afbranco/Terra`. O **`master` volta à versão de produção**: um commit
  restaura a árvore do `f02b8e6`, sem reescrever o histórico. Depois vêm a licença (GPL v3) e o
  `docs/` (site do GitHub Pages) ajustado à produção. Ajustes e correções entram no `master`,
  um commit por mudança e com teste.
- A linha de 2016-06 a 2018-03 fica no galho **`integracao-heterogenea`** (`9b4bebe`). Foi uma
  pesquisa do Prof. sobre integrar plataformas diferentes com a VM Terra como meio comum (BS que
  executa Terra, multirede, MoteType, portes Linux/RPi/Arduino/ESP/Android). Se for retomada,
  entra por partes e com teste, nunca por merge. A branch `maintained` deixou de ser usada.
- Tags de referência: **`production-2016-05`** (`f02b8e6`, a versão base de produção) e
  **`snapshot-2018-03`** (`9b4bebe`, o último `master` publicado).
- **Releases** (decidido pelo Prof. em 2026-11-22):
  - **`v0.3.0` publicada** (tag no `380d863`): referência histórica, feita à mão. Os
    `_TOSSIMmodule.so` de produção originais (py2, i386, os da `.ova` e do TerraSim), o
    `SHA256SUMS` e a receita de reprodução nas notas.
  - **`v1.0.0`** (ainda não criada): a primeira do toolchain novo, gerada pelo workflow
    `.github/workflows/release.yml` (PR #13, no `master` desde `ff3f9f5`). Traz tudo, para ficar
    independente da `.ova`: `_TOSSIM.so` + `TOSSIM.py` Net/Grp (Python 3.14, x86_64), firmware
    micaz NOBS e BS (`.exe` e `.ihex`), `terrac` empacotado e `TerraVMControl.jar`. Uso e
    gravação com ID em `release/README.md`. Em PR só compila e testa; numa tag `v*` cria a
    release em **rascunho** (o Prof. revisa e publica).
  - Alinhada com a release **tinyos-toolchain `2.1.2-r2`** (decidido pelo Prof. em 2026-11-22;
    antes era a r1, `f42bac7`, digest `7e21b1b9…`). O workflow fixa a imagem
    `2.1.2-resolute-py3-21d8fb1@sha256:4198b12302181edd0e8b20ae06cd3af0a2d483a06355a78c1f83371250de47ec`.
    Cada release do Terra registra a imagem, o digest e a release do toolchain (`BUILDINFO`).
    A r2 só corrige scripts Python 2 (`tos-storage-*`, `tos-deluge`...) e acrescenta o
    `python3-serial`. Com o `master`, o firmware micaz sai idêntico byte a byte ao da r1 e o
    `_TOSSIM.so` tem o mesmo código e dados (só DWARF e build-id diferem), então o oráculo feito
    na r1 vale. `MOD=VCN_DAT` falha na r1 e compila na r2.
  - Testes do workflow (todos passaram no CI e localmente):
    - `.so`: boot de dois nós e 30 s simulados. A VM faz `exit(0)` se não consegue criar o
      `sensors.bin` na pasta corrente, então o teste roda numa pasta gravável e exige a linha OK;
    - firmware: cabe em 128 KB de flash e 4 KB de RAM;
    - `terrac`: os `.vmx` de `terrac/samples` saem iguais aos commitados (Count2Leds só em
      espaços de comentário). Exige Lua 5.1 e **lpeg 0.10.2**; com o lpeg 1.0 falha. O fonte pede
      `lpeg_0_10_2_1-lpeg` (nome do luarocks da época); o script da release injeta um alias;
    - `TerraVMControl.jar`: compilado do fonte com as bibliotecas da TerraDist v0.3.0 (idênticas
      às do jar de 2016); `app.ControlForm` e o `MoteIF` carregam.
  - Conferido contra a produção de 2016 (`handoff/ova/TerraNG/`, a distribuição da `.ova`): o
    `terrac` empacotado é igual, salvo o nome do lpeg e uma mensagem de erro (`c94fdc3`); os
    `.defs` são idênticos; o jar tem as mesmas classes e assinaturas (só métodos sintéticos
    do compilador diferem).

## Quem e o quê

- O dono é o Prof. Adriano Branco (PUC-Rio), autor do Terra. Conversar com ele em **português
  do Brasil**. Ele não gosta de travessão ("—"): usar dois-pontos, ponto ou parênteses.
- Terra: sistema de programação para redes de sensores. Uma VM pequena (`TerraVM`, nesC/TinyOS),
  o compilador `terrac` (Lua, linguagem baseada em Céu), o `TerraControl` (Java) e
  distribuições prontas (`TerraDist`).
- Três projetos em cadeia, cada um consumindo o anterior como artefato pronto:
  1. **tinyos-toolchain** (`~/tinyos-toolchain`, `afbranco/tinyos-toolchain`): TinyOS 2.1.2 +
     TOSSIM como imagem de contêiner, Python 3.
  2. **Terra** (este, `~/Terra`, `afbranco/Terra`): compila a VM dentro daquela imagem e publica
     releases do módulo TOSSIM. Expectativa do Prof.: o Terra não precisará de adaptação para o
     toolchain novo. No Python 3 o módulo se chama `_TOSSIM.so` (não `_TOSSIMmodule.so`).
  3. **TerraSim** (`~/TerraSim`, `afbranco/TerraSim`): simulador para sala de aula. Hoje usa
     `.so` vendorizados (`legacy/TerraNG/sim/{Net,Grp}/_TOSSIMmodule.so`, i386); vai trocá-los
     por uma release do Terra depois de um oráculo de equivalência.

## Objetivo (pedido do Prof., 2026-11-21)

Rastrear as evoluções feitas no Terra **depois da versão de produção** e decidir, uma a uma, se
vale mantê-las. Nas palavras dele: "fiz evoluções depois dela e não fui muito rigoroso nos
testes e no controle das inovações". Feito em 2026-11-22: relatório em
`handoff/avaliacao-vm-tinyos.md`, com 31 commits que tocam o build TinyOS e os bugs
encontrados. Alguns valem também para a produção e são candidatos a correção no `master`
(potência de RF do Grp, comparação de float). O oráculo do `.so` novo contra o de produção
passou (ver "Oráculo"). Próximo passo: a v1.0.0 e, depois, os ajustes e bugs de compilação que
o Prof. conhece.

## O que já se sabe (sessão tinyos-toolchain, 2026-11-21)

**Versão base de produção = commit `f02b8e6`** (2016-05-26, "TerraVM: Adaptação inicial para o
Arduino Uno"), com a estrutura de pastas da época (`TerraVM/src/CustomVMs/{TerraNet,TerraGrp}`,
`TerraVM/src/XComps`).

- Como se chegou lá: o `.so` de produção tem informação de depuração (DWARF) com as linhas de
  cada fonte que geraram código. Para cada commit que mexeu em `TerraVM/src`, conta-se quantas
  dessas linhas caem além do fim do arquivo (prova de versão diferente) ou numa linha sem
  código. `f02b8e6`: 0 além do fim e 6 (Net) / 7 (Grp) sem código, todas logo após o fim de uma
  função, o mesmo artefato do compilador visto nos arquivos do TinyOS (que não mudaram); o
  anterior, `b53382a` (2016-03-09), tem 80/90. Os commits seguintes até `e8df092` (2016-06-11)
  empatam na conta; o `BSUpload.nc` desempata: o `.so` tem funções para `getEnv` e `start`, que
  estão nas linhas citadas (23 e 26) só até o `f02b8e6` (no `74b669c` viram outros eventos).
- O `.so` é de 2016-05-07, o commit de 05-26: compilado com alterações locais, commitadas depois.
- **Limite**: mudança dentro de uma linha (ex.: uma constante) não aparece nesse método. Prova
  definitiva feita em 2026-11-22 (ver "Ambiente original"): achou `RFPOWER=4` e o
  `BasicServices.h` anterior.
- Mapa de pastas (o `master` usa o layout antigo; o galho de integração, o novo):
  `CustomVMs/TerraNet` = `platforms/TinyOS/Net`; `CustomVMs/TerraGrp` =
  `platforms/TinyOS/Grp`; `XComps` = `platforms/TinyOS/common`; `dataQueue*`, `vmBitVector*` =
  `system/`. A reorganização veio em 2016-10-07 ("Mudança do nome do Projeto").
- Depois do `f02b8e6`: **321 commits**, a maioria em docs, Arduino, ESP, RPi e `terrac`; **37**
  mexem na VM TinyOS. São esses os candidatos a "inovação" a avaliar.
- Ferramentas e dados em `handoff/provenance/` (fora do git, `.git/info/exclude`):
  `linecheck.py <linhas.tsv> <src da versão> <src a comparar>` e `blanklines.py`, as tabelas
  de linhas dos dois `.so` (`so-Net.lines.tsv`, `so-Grp.lines.tsv`) e a lista dos 430 commits.

**Os `.so` de produção** (idênticos aos vendorizados no TerraSim e aos da `.ova`):

| VM | Tamanho | SHA-256 |
|---|---|---|
| Net | 806184 | `8214f2c5fc585601b4f5462bcb3301b2517b445b5f3a5840c277b225731a99ed` |
| Grp | 1028648 | `93cc11cf74657c74c26153df46ce9dc173904fcc4466f62694151843a4288869` |

Compilados em `/home/branco/gitspace/Terra/TerraVM/src`, alvo `micaz sim-sf`, i386, GCC 4.6.3,
SWIG 1.3.31, Python 2.7. Nenhum `.so` do `TerraDist` (v0.1 a v0.3.0) bate com eles.

**A `.ova` pública** (`TerraNG_v0.3.0.ova`, site do Terra `www.inf.puc-rio.br/~prjterra/`,
arquivos internos de 2016-05-25): Ubuntu 12.04.5 **i386**; TinyOS 2.1.2 do pacote oficial, sem
alterações; **nesC 1.3.4**, gcc 4.6.3, avr-gcc 4.1.2 e avrdude 5.10 (pacotes do TinyOS),
Python 2.7.3, Oracle Java 7, `bc`. Lista completa: `handoff/provenance/ova-packages.txt`.
Ambiente do usuário: `ova-tinyos.sh`, `ova-terra_env.sh`. O Terra nela é a distribuição
`~/TerraNG` (binários) e um download do GitHub de 2015-04-21 (`~/Downloads/Terra-master`). A
`~/TerraNG` foi extraída para `handoff/ova/TerraNG/` (terrac, `TerraVMControl.jar` de
2016-05-04, sha256 `5755c38b…`, e os `.exe` de 2016-05-07).

**Terra no toolchain novo** (`ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3`):
- A produção (`f02b8e6`, sintaxe `NOME=valor`) compila sem adaptação: `make micaz sim-sf
  VM=NET|GRP TYPE=ALL` gera `_TOSSIM.so`. Hardware micaz, `master` (`RFPOWER=4`), bytes de ROM:
  Net ALL 50.488, NOBS 49.724, BS 43.990; Grp ALL 71.762, NOBS 65.952, BS 47.684 (com
  `RFPOWER=1`, o padrão antigo, são 4 B a menos).
- Bug da imagem r1: 5 scripts `tos-*` ainda eram Python 2 (`tos-storage-at45db`, `-stm25p`,
  `-pxa27xp30`, `tos-deluge`, `tos-dump.py`). No Terra só afeta `MOD=VCN_DAT` (usa
  `BlockStorageC`); o `|| rm` do make esconde a falha. Corrigido na `2.1.2-r2`.
- O snapshot de 2018 (sintaxe `NOME:valor`) também compila: sim-sf Net e Grp, micaz
  `VM:GRP TYPE:NOBS QUEUE:SHORT` (65.304 B). O Makefile precisa de `bc` (já na imagem).
- As 6 classes Java do `mig` saem idênticas às commitadas.
- O SerialForwarder Java (`net.tinyos.sf.SerialForwarder`, usado pelo TerraControl) funciona
  com o TOSSIM; porta serial real ainda não testada (o Prof. testa no lab com a MIB520).
- 64 bits: o TinyOS/TOSSIM não gera avisos de conversão ponteiro/inteiro. O Prof. lembrava de
  um problema de 64 bits na VM do Terra, sem registro encontrado (nem na sessão TerraSim).
  O núcleo público da VM não mostrou os padrões de risco. O oráculo de equivalência é o teste.

## Ambiente original (montado em 2026-11-22) e reprodução dos `.so` de produção

- Em `handoff/ova/` ficam o `.vmdk` e o `.ovf` originais (o Prof. quer mantê-los) e a
  `TerraNG/`. O rootfs foi montado e apagado duas vezes em 2026-11-22, a pedido do Prof.
- Para remontar (uns 10 minutos, 6,4 GB temporários): `7z e Terra_0.30_NG-disk1.vmdk 0.img`,
  `debugfs -R 'rdump /<dir> .' 0.img` para etc bin lib opt sbin usr var root home, dentro de
  `handoff/ova/rootfs` (os avisos de "changing ownership" são normais), criar tmp dev proc sys
  run, remover `/usr/share/doc`, man, `/lib/firmware` e `/var/cache` (fica 2,9 GB) e apagar o
  `0.img`. Rodar com `podman run ... --rootfs <dir>` (o `--rootfs` depois das outras opções;
  sem `podman import`, que faz cópia dupla) e `setarch i686`. Script:
  `handoff/repro/ovabuild.sh` (repassa um `CFLAGS` do ambiente).
- **Os dois `.so` de produção foram reproduzidos**: código, dados e tabela de linhas idênticos
  byte a byte. A receita está em `handoff/repro/README.md`: `f02b8e6` com o `BasicServices.h`
  de `f32dd25`, `RFPOWER=4`, Net com `MOD=MSGQ`. Desde `380d863` o `master` é essa receita
  (`RFPOWER` padrão 4 e o `BasicServices.h` sem as linhas do Uno): compilado na `.ova` só com
  `make micaz sim-sf VM=NET MOD=MSGQ TYPE=ALL` (ou `VM=GRP TYPE=ALL`), sai com `.text`, `.data`
  e `.debug_line` idênticos aos de produção. `HYB=YES` e `QUEUE=SHORT` são o padrão. Os `.so`
  reproduzidos estão em `handoff/repro/{Net,Grp}/`.

## Oráculo (sessão TerraSim, `~/TerraSim/tools/oraculo_tossim/`, 2026-11-22)

Saídas determinísticas por semente (1 a 5): o tempo de cada evento do escalonador e os canais
TVIEW/VMDBG, numa grade 4x4 com o `routing_tree.terra` carregado (até 31 mil passos da VM por
semente). Resultados do Net, todos **idênticos byte a byte** à referência do vendorizado:
- `.so` reproduzido no passo B (i386, py2);
- degrau 1, a mesma compilação com `CFLAGS="-mfpmath=sse -msse2"` (`handoff/repro/sse/`;
  disassembly das funções de CPM/ruído: x87 220→19, xmm 0→177). O ponto flutuante não pesa;
- **degrau 2 / oráculo A**: o `_TOSSIM.so` x86_64, Python 3.14, do CI do PR #13
  (`handoff/py3/`, sha256 Net `459a2091…`).

O avaliador estatístico (`measure_baseline.py`) do Net reproduzido ficou dentro do ruído. O Grp
não foi testado no TerraSim (só a reprodução binária). Seguem do lado TerraSim: o avaliador com
o daemon em py3, a medição de RAM em 64 bits e a troca do `.so` no servidor.

## Pendências para decidir com o Prof.

- Se o `handoff/` (scripts e tabelas da análise de versão) entra no repositório. Hoje está
  fora do git (`.git/info/exclude`).
- **v1.0.0**: falta o avaliador da TerraSim em py3 e o teste do Prof. com micaz real (MIB520,
  roteiro em `release/README.md`). Depois, criar a tag `v1.0.0`, e o workflow faz o rascunho.
- Quais correções de bugs achados na integração valem para a produção.

## Como trabalhar (mesmas regras do tinyos-toolchain)

- Testar antes de publicar; teste novo só vale depois de reprovar com a mudança desfeita.
- A máquina é a do Prof.: builds pesados com `nice -n 19`, e avisar antes de carga grande. A
  sessão TerraSim pode pedir pausa de CPU para gravar vídeo (congelar por PID com SIGSTOP,
  retomar com SIGCONT e avisar). Disco apertado (cerca de 10 GB livres em 2026-11-22).
- Matar processo só por PID. Restaurar a partir de cópias, nunca `git checkout`/`restore`/
  `stash` por cima de trabalho.
- Não mostrar credenciais nem cookies.
- Commit/push e PR: perguntar antes. Commits terminam com:
  ```
  Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
  ```
