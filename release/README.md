# Releases do Terra

As releases a partir da 1.0 são geradas pelo workflow `.github/workflows/release.yml`. Ele usa a
imagem fixa do [tinyos-toolchain](https://github.com/afbranco/tinyos-toolchain), release
`2.1.2-r3`: `ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-0dded15`, cujo digest está no
workflow e no `BUILDINFO` de cada release.

## Anexos

| Arquivo | O que é |
|---|---|
| `terra-<v>-linux-x86_64.tar.gz` | O pacote para Linux (#95): `bin/terrac`, `bin/terractl`, o Python 3.14 do python-build-standalone, os dois simuladores, o firmware micaz e os `.defs`; sem instalar nada (ver "Pacote Linux") |
| `terrac-<v>-linux-x86_64` | O `terrac` executável (Lua, lpeg e mcpp dentro; `--licenses`) |
| `terra-<v>-net-tossim-py3-x86_64.tar.gz` | Simulador TerraNet: `_TOSSIM.so`, `TOSSIM.py` (Python 3.14, x86_64) e o `TerraNet.defs` dele |
| `terra-<v>-grp-tossim-py3-x86_64.tar.gz` | Simulador TerraGrp, idem |
| `terra-<v>-{net,grp}-micaz-nobs.{exe,ihex}` | Firmware micaz, nó comum (placa MDA100) |
| `terra-<v>-{net,grp}-micaz-nobs.defs` | O `.defs` desse firmware: compile com ele os programas para o micaz |
| `terra-<v>-{net,grp}-micaz-bs.{exe,ihex}` | Firmware micaz, estação base (nó 1, ligado ao computador) |
| `terrac-<v>.tar.gz` | Compilador `terrac`, `TerraNet.defs` e `TerraGrp.defs` (os do simulador) e `terra.lang` |
| `terrac-errors-<v>.json` | Catálogo dos códigos de erro e aviso do `terrac` (o mesmo de `terrac --catalog`) |
| `terra-docs-<v>.json` | Os símbolos dos `.defs` (eventos, funções, constantes, macros, registros) com descrição, para editores e documentação (ver abaixo) |
| `terra-vscode-<v>-linux-x64.vsix` | Extensão do VSCode para Linux, com o pacote `terra-<v>-linux-x86_64` dentro (#95) |
| `terra-vscode-<v>.vsix` | Extensão do VSCode (outros sistemas): destaque, hover pelo `terra-docs`, erros do `terrac`, comandos do `terractl` |
| `terractl-<v>.pyz` | `terractl`: carga de programas, mensagens da BS e gravação com ID (Python 3) |
| `TerraVMControl-<v>.jar` | TerraControl, com todas as bibliotecas dentro |
| `BUILDINFO`, `SHA256SUMS`, `logs.tar.gz` | Commit, imagem e logs de compilação e de teste |

As opções de compilação são as da produção (`RFPOWER=4`, o padrão; o Net com `MOD=MSGQ`). Os
comandos exatos estão em `build-tinyos.sh` e nos logs.

### Um `.defs` por firmware

Desde a 1.4.0 o `.defs` acompanha o build: só declara o que existe naquele firmware (#100). O
`make` o gera em `build/micaz/` a partir de `TerraVM/src/defs/Terra{Net,Grp}.defs.in`, conforme:

- os módulos (`MOD=MSGQ`: `qPut`, `qGet`, `qSize`, `qClear`, `Q_READY`; `MOD=FFT`: `fftAlloc`, `fft`);
- o hardware: portas e interrupções (`SET_PORT_*`, `CFG_PORT_*`, `REQ_PORT_*`, `CFG_INT_*`, `PORT_*`,
  `INT_*`) só nos mica, fora do simulador;
- a placa: `REQ_MIC`, `MIC`, `setupMic`, `BEEP` e `E_NOSETUP` só com `SENSOR=MTS300CA`/`MTS300CB`,
  no Net e no Grp;
- a memória para programa (`config`), a do build, só para a plataforma dele.

O build da release confere cada `.defs` contra o código compilado (`release/check-defs.py`): toda
saída e toda função declarada tem de ter tratamento na VM. Um programa que use o que o firmware
não tem não compila (nome desconhecido), em vez de compilar e travar no mote.

## Gravar um micaz

O `.ihex` sai com o ID 1. Para outro ID, use o `.exe` com o `terractl` (só precisa do `avrdude`, sem
o TinyOS): `python3 terractl-<v>.pyz flash terra-<v>-net-micaz-nobs.exe --node 2 --port /dev/ttyUSB0`.
Ou com a imagem do toolchain. Exemplo: nó 2 numa MIB520 em `/dev/ttyUSB0`:

```bash
podman run --rm -it --device /dev/ttyUSB0 -v "$PWD:/w:Z" -w /w \
  ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-0dded15 sh -c '
    tos-set-symbols --objcopy avr-objcopy --objdump avr-objdump --target ihex \
      terra-<v>-net-micaz-nobs.exe no2.ihex TOS_NODE_ID=2 ActiveMessageAddressC__addr=2 &&
    avrdude -cmib510 -P/dev/ttyUSB0 -pm128 -U hfuse:w:0xd9:m -U efuse:w:0xff:m \
      -C/etc/avrdude.conf -U flash:w:no2.ihex:a'
```

A estação base é o nó 1: grave `terra-<v>-net-micaz-bs.ihex` direto. A MIB520 abre duas portas:
a primeira grava o firmware e a segunda é a de dados, usada pelo SerialForwarder (por exemplo,
`java net.tinyos.sf.SerialForwarder -comm serial@/dev/ttyUSB1:micaz`).

## terrac

**Executável** (`terrac-<v>-linux-x86_64`, #95): Lua 5.1.5, lpeg 1.0.2 e o pré-processador mcpp
2.7.2 (com os patches da Debian 5.3) ligados estaticamente, com o `terrac` dentro. Roda em qualquer
Linux x86_64 sem instalar nada (testado no Ubuntu 24.04 e no Fedora 43, `release/test-terrac-exe.sh`).
Montado por `release/build-terrac-exe.sh` (fontes baixados com sha256 conferido). O `terrac.lua`
percebe que está no executável (`_TERRAC_EXE`) e chama o `mcpp` de dentro dele (`terrac --cpp`),
com `-N` (sem as macros predefinidas, como `linux` e `unix`) e `-I-` (sem as pastas do sistema).

Comparado com o script e o `cpp` do gcc nos 1.173 programas do corpus: os 506 `.vmx` iguais;
diferem os textos do E1004, que vem sem coluna; string sem fechar é E1004 (no `cpp`, W6001 e depois
um erro de sintaxe); o `#if` sem `#endif` aponta a linha do `#if`; e, numa linha com macro, a
coluna pode sair 1 ou 2 caracteres depois, porque o `mcpp` põe espaços em volta da expansão.
`tests/terrac/diag/json.mcpp.esperado` é o `json.esperado` com essas diferenças;
`TERRAC_EXE=<exe> release/build-terrac.sh` roda todos os testes do `terrac` com o executável.

**Script Lua** (`terrac-<v>.tar.gz`): requer Lua 5.1, o lpeg 1.x e o `cpp`. Em Ubuntu/Debian, o
lpeg da distribuição serve:

```bash
sudo apt-get install lua5.1 lua-lpeg cpp
lua5.1 terrac meuScript.terra      # gera meuScript.vmx; o .defs fica na mesma pasta
```

Até a 1.0.1 o `terrac` só funcionava com o lpeg 0.10.2 (`luarocks --lua-version=5.1 install lpeg
0.10.2-1`). Desde a 1.1.0 funciona com as duas, com o mesmo `.vmx` e as mesmas mensagens; o CI
testou as duas até 2026-11-27, quando o TerraSim passou para o `lua-lpeg` e o 0.10.2 saiu (#142).
Hoje só o lpeg 1.x é testado.

### Mensagens de erro e `--diag=json`

Cada erro e aviso tem um código estável (`E3001`, `W2003`...), listado em
`terrac-errors-<v>.json`. Um código nunca muda de significado; um erro novo ganha código novo.
Grupos: `E0` falha interna do compilador, `E1` entrada e pré-processador, `E2` sintaxe, `E3` nomes
e declarações, `E4` tipos e expressões, `E5` controle e contexto (`E5001` é o laço sem `await`),
`E6` limites, `E9` não implementado; `W1` conversões, `W2` não determinismo, `W3`
alcançabilidade, `W4` declarações, `W5` limites, `W6` pré-processador.

O padrão continua o texto de sempre (`ERR : line 4 : ...`). Com `--diag=json`, o stderr só tem
linhas JSON, um diagnóstico por linha, e termina sempre com uma linha de resumo:

```json
{"code":"W2003","severity":"warning","file":"p.terra","line":5,"col":3,"msg":"nondeterminism (write conflict) : variable/event `x´ (line 5) vs variable/event `x´ (line 7)","args":{"a":"variable/event `x´ (line 5)","b":"variable/event `x´ (line 7)"},"related":[{"file":"p.terra","line":7,"col":3}]}
{"summary":{"ok":true,"errors":0,"warnings":1,"optimized":true,"vm":{"name":"TerraNet_MsgQ","version":"000.002.000"},"memory":{"total":51,"code":35,"ctl_vars":16,"stack":0,"radio_msgs":3}}}
```

- `line` e `msg` são os mesmos do modo texto; `args` traz os valores que entram na mensagem.
- `col` (base 1, em caracteres) vem quando o compilador sabe a coluna; nos erros de sintaxe vem
  também `col_end`, a coluna logo depois do token (exclusiva).
- Erro dentro de um `#include`: `line` é a linha da diretiva no programa, e `include` traz
  `{file, line, col}` do ponto real.
- `related`: o segundo ponto do programa (avisos `W2xxx`). Nesses avisos, `args` traz também
  `kind_a`, `name_a`, `line_a` e os mesmos com `_b` (os `extra_args` do catálogo): o tipo do
  acesso (um dos `access_kinds` do catálogo, como `event`, `variable` ou `internal_event`), o
  nome e a linha, para não depender do texto de `a` e `b`.
- Erros do `cpp` saem como `E1004` (avisos, `W6001`), com o arquivo, a linha e a coluna dele.
- `E0001`: falha interna, com a mensagem do Lua em `args.lua`. É bug do `terrac`: favor relatar.
- O resumo traz `memory` só quando não há erro. Até a v1.4.0 trazia também `platforms`, a lista
  das plataformas do `config` do `.defs` (saiu na #122). Um diagnóstico do programa todo (o
  `W5003`: o programa passa da memória para programa da plataforma do `.defs`) vem sem `line`.

## terra-docs.json

Gerado pelo `TerraVM/src/defs/gendocs.py` a partir dos modelos `Terra{Net,Grp}.defs.in`, das
descrições de `TerraVM/src/defs/descricoes.toml` (em inglês) e dos `.defs` que os builds da release
geraram. Um símbolo por definição: quando o Net e o Grp declaram um nome do mesmo jeito, sai uma
entrada com `variants: ["net","grp"]`; quando diferem (no tipo, nos
parâmetros ou nos pares `unsafe`), uma por variante.

```json
{"schema":1,"terra":"1.5.0","variants":["net","grp"],"platforms":["tossim","micaz"],"groups":["leds",...],"symbols":[
 {"name":"RECEIVE","kind":"event","group":"radio","direction":"await","type":"radioMsg","id":45,
  "filter":{"type":"ubyte","id":44,"matches":"the type of the message"},
  "requires":[],"variants":["net"],"platforms":["tossim","micaz"],
  "short":"A radioMsg arrived from another node.","long":"...","example":"...","since":"1.0.0"}, ...]}
```

- `group`: a tabela do símbolo, um dos `groups` do topo (`leds`, `sensors`, `custom`, `radio`,
  `queue`, `ports`, `mic`, `fft`, `group`, `aggregation`, `errors`, `misc`). A lista sai em ordem
  alfabética do nome.
- `kind`: `event` (`direction` `emit` ou `await`), `function`, `constant`, `macro` ou `type`
  (registro: `type_kind` `packet` ou `regtype` e `fields` com `name`, `type` e `short`).
- `id`: o número no `.defs` (no `await`, o da forma sem argumento; `null` se só há a com filtro).
  `filter`: a forma `await EVT(x)`, com o tipo e o número dela e o que `x` seleciona.
- `params` (`emit`, funções, macros), `returns` e `attrs` (`pure`, `nohold`) das funções, `value`
  das constantes, `body` das macros, `unsafe_with` (pares que dão aviso de não determinismo).
- `requires`: o marcador do build (`MSGQ`, `FFT`, `MIC`, `PORTS`); `platforms`: as plataformas cujo
  `.defs` da release declara o símbolo (vazio: nenhum firmware da release tem, ex.: `MIC`).
- `since`: a primeira release com o símbolo. O que mudou em cada release fica nas notas dela.

O build reprova se faltar ou sobrar descrição, ou se um `.defs` gerado não bater com o modelo
(`release/test-gendocs.py` confere que reprova).

## Site (docs/)

O GitHub Pages publica o `docs/` do `master` (só a versão atual; as antigas ficam no histórico).
As páginas são Markdown em inglês (`docs/*.md`, layout `docs/_layouts/terra.html`). As tabelas de
referência são geradas pelo `docs/_tools/genpages.py` e ficam no repositório, em
`docs/_includes/generated/`: `terranet.md` e `terragrp.md` do `terra-docs-<v>.json`, `codes.md`
do `terrac-errors-<v>.json`. O CI reprova se estiverem desatualizadas. Para regenerar, com os
anexos de um build (do CI ou local):

```bash
python3 docs/_tools/genpages.py --docs terra-docs-<v>.json --out docs/_includes/generated
python3 docs/_tools/genpages.py --catalog terrac-errors-<v>.json --out docs/_includes/generated
```

Os exemplos Terra das páginas (blocos ```` ```terra ````) vêm depois de um comentário
`<!-- check: ok -->` (compila sem erro nem aviso), `<!-- check: E3001 -->` (dá esse código), com
` grp` no fim para o `TerraGrp.defs`, ou `<!-- check: skip -->` (esboço). O `build-terrac.sh`
compila todos com o `docs/_tools/checkexamples.lua`.

## terractl

Substitui o TerraControl em Java (#92; decisão do Prof. de 2026-11-26: o Java será aposentado).
Só o Python 3: o `pyserial` vai dentro do `.pyz` (#145), sem `pip` nem venv.

```bash
python3 terractl-<v>.pyz load prog.vmx --serial /dev/ttyUSB1          # MIB520 (a segunda porta)
python3 terractl-<v>.pyz load prog.vmx --sf localhost:9002 --listen    # SerialForwarder (TOSSIM)
python3 terractl-<v>.pyz listen --serial /dev/ttyUSB1 --terra prog.terra
python3 terractl-<v>.pyz flash terra-<v>-grp-micaz-nobs.exe --node 11 --port /dev/ttyUSB0
```

- `load`: anuncia a versão, manda os blocos e atende os pedidos de bloco por `--time` segundos (30;
  0 até Ctrl-C), reanunciando a cada `--every` (10). A versão guardada fica em
  `~/.local/state/terractl/version`; se um mote pede uma versão maior, a carga passa para a seguinte
  (o mote descarta versão igual ou menor que a dele). `--prog-version N` escolhe o número.
- `listen` (e `load --listen`): as mensagens que chegam à BS (Net: `SEND` com `target` 1, AM 145; Grp:
  `SEND_BS`, AM 150). Com `--terra prog.terra` (roda o `terrac --types`) ou `--types arq.json`,
  decodifica pelo `pktype` do programa; com mais de um, `--pktype N=nome` escolhe pelo `type` (Net)
  ou `msgId` (Grp). `--json` dá uma mensagem por linha em JSON; `--hex`, só os bytes. Inteiros em
  big-endian e `float` em little-endian (o `nx_float` do atm128).
- `sim`: simulação local (#94) com o `_TOSSIM.so` da release (`--tossim pasta`; Python 3.14, então
  na imagem do toolchain): grade `--grid LxC` (até 9x9, nós coluna*10+linha, 8 vizinhos, ganho 85 e
  o ruído do `TerraSim.py` da `.ova`), o `.vmx` carregado pela BS e os logs (TVIEW, mensagens à BS
  decodificadas) com o tempo simulado. `--late N --late-at S` liga as últimas colunas depois,
  `--vmdbg`, `--channel`, `--seed`; `--realtime` abre o SerialForwarder (9002) para um
  `terractl load --sf` de fora. Uso no `docs/tinyos.md`.
- `flash`: troca `TOS_NODE_ID` e `ActiveMessageAddressC__addr` no `.exe` (como o `tos-set-symbols`)
  e grava com o `avrdude` (`-c mib510`, fusíveis do micaz); `-o arq.ihex` só gera o arquivo.
- Fora: o "Set memory data" e o "Send Group Message" do TerraControl (decisão do Prof.).
- Testes: `release/test-terractl.py` (quadro serial, porta serial simulada, ID contra o
  `tos-set-symbols`, grade do `sim`) e `tests/terractl`, `tests/terractlgrp` (carga e decodificação
  no TOSSIM), `tests/terractlsim` (grade 3x3 com o `sim`).

## Pacote Linux

`release/build-bundle.sh <v> <anexos> <saída>` monta o `terra-<v>-linux-x86_64.tar.gz` (decisões do
Prof., 2026-11-27: o laboratório não tem admin nem contêiner; Fedora em dual boot):

- `bin/terrac`: o executável, com `-I defs/` (um `.defs` na pasta do programa tem prioridade);
- `bin/terractl`: o `.pyz` com o Python do pacote (`python3 -I`) e `TERRA_HOME`, pelo qual o
  `terractl` acha o `terrac` (`--terra`), os simuladores (`sim --vm net|grp`, sem `--tossim`) e o
  firmware (`flash net-bs|net-nobs|grp-bs|grp-nobs`);
- `python/`: o CPython 3.14 do python-build-standalone (release 20261110, sha256 conferido), sem
  testes, Tk, IDLE, pip e cabeçalhos. O `_TOSSIM.so` é do Python 3.14 do Ubuntu e roda com ele;
- `tossim/{net,grp}/`, `firmware/`, `defs/`, `licenses/` e `README.txt`.

Os links em `bin/` funcionam de qualquer lugar (`readlink -f`), também num link no `PATH`. Teste:
`release/test-bundle.sh` num Fedora 43 sem Python, Lua nem `cpp`, numa pasta com espaço no nome
(compila, simula Net e Grp com as mensagens decodificadas e grava um `.ihex` com ID).

## Extensão do VSCode

`code --install-extension terra-vscode-<v>.vsix` (ou "Install from VSIX..." no VSCode). Leva dentro
o `terractl` e o `terra-docs.json` da mesma release (#93). A `terra-vscode-<v>-linux-x64.vsix` leva
também o pacote `terra-<v>-linux-x86_64.tar.gz` em `bundle/` (#95): na ativação, o `src/bundle.ts`
o descompacta no `globalStorage` da extensão (uma pasta por versão, as antigas apagadas; o `tar`
guarda as permissões, o `.vsix` não), e o `terrac`, o `terractl` (com o Python do pacote), o
simulador (`sim --vm` pela variante do `#include`, sem contêiner) e o firmware (`flash net-bs`...)
passam a ser os do pacote. Uma configuração explícita vale por cima. Fonte em `vscode/` (TypeScript):

- `syntaxes/terra.tmLanguage.json` (gramática), `snippets/terra.json`, `language-configuration.json`;
- `src/diag.ts`: leitura do `--diag=json` (faixa pelo `col`/`col_end`, link do código no site);
- `src/docs.ts`: hover e complemento pelo `terra-docs.json`, pela variante do `#include`;
- `src/extension.ts`: compilar ao salvar (Problems), Carregar, Mensagens, Simular (na imagem do
  toolchain por padrão: `terra.simulation.containerImage`) e Gravar, cada um num terminal com o
  `terractl`; as mensagens decodificadas pelo `terrac --types` do programa.

Testes (`release/build-vscode.sh`): `node --test` (diag, docs sobre o `terra-docs` da release,
gramática com o `vscode-textmate`, `package.json` x código) e, com `xvfb-run` (no CI), a integração
num VSCode 1.85.2 de verdade (idioma, Problems com um `terrac` falso, hover, complemento sem os
símbolos da outra VM) e, de novo, com o pacote e o `terrac` de verdade de dentro dele. Sem
`xvfb-run` localmente, a integração é pulada. Marketplace e Open VSX
ficam para depois (conta de publicador do Prof.).

## TerraControl

`java -jar TerraVMControl-<v>.jar` (Java 8 ou mais novo). Ele conversa com o SerialForwarder do
TinyOS, ou com o simulador.

## Gerar localmente

```bash
podman run --rm -v "$PWD:/terra:ro,Z" -v "$PWD/dist:/out:Z" -w /terra \
  ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-0dded15 release/build-tinyos.sh dev /out
release/build-terrac.sh dev dist     # com Lua 5.1 e o lpeg instalados
```

O build do `build-tinyos.sh` é reproduzível (issue #18): com o mesmo commit, a mesma imagem
(pelo digest, ver `BUILDINFO`) e a mesma versão no lugar de `dev` (ex.: `1.2.0`, que entra no
nome dos anexos), os `tar.gz`, o firmware e o jar saem com o sha256 do `SHA256SUMS` da release (as releases geradas depois desta mudança).
`release/compare-builds.sh <saída 1> <saída 2>` compara dois builds.

## Testes no Avrora (micaz emulado)

O `release/test-avrora.sh` roda os testes da VM (`tests/*/`) no Avrora, que emula o ATmega128 e
o rádio CC2420, com o firmware micaz gerado acima. Pega o que o TOSSIM (x86) não mostra, como o
tamanho de struct da #41. A montagem é a do laboratório, com o mínimo de nós: a estação base, os
motes que o teste usa e o SerialForwarder do TinyOS ligado na serial da BS. Cada teste leva cerca
de 1 minuto, por isso no CI só roda na tag de release e quando o workflow é disparado à mão
(Actions > release > Run workflow).

```bash
podman run --rm -v "$PWD:/terra:ro,Z" -v "$PWD/dist:/fw:ro,Z" -v "$PWD/avrora:/out:Z" -w /terra \
  ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-0dded15 release/test-avrora.sh /fw /out
```

Não substitui o teste com o micaz real (#16): não passa pelo avrdude, pela MIB520, pelo rádio
físico nem pelos sensores.
