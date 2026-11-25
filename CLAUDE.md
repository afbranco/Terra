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
  - **`v1.0.0` publicada** (tag no `e6ef49f`, 2026-11-22, a pedido do Prof.): a primeira do
    toolchain novo, gerada pelo workflow
    `.github/workflows/release.yml` (PR #13, no `master` desde `ff3f9f5`). Traz tudo, para ficar
    independente da `.ova`: `_TOSSIM.so` + `TOSSIM.py` Net/Grp (Python 3.14, x86_64), firmware
    micaz NOBS e BS (`.exe` e `.ihex`), `terrac` empacotado e `TerraVMControl.jar`. Uso e
    gravação com ID em `release/README.md`. Em PR só compila e testa; numa tag `v*` cria a
    release em **rascunho**; depois completo as notas (commit, imagem e digest, sha256 dos anexos
    e dos `_TOSSIM.so` de dentro dos tar.gz) e publico, com o ok do Prof.
  - **`v1.0.1` publicada** (tag no `e77a509`, merge do PR #20, 2026-11-22): o `await` de 0 ms
    não congela mais o relógio (mínimo de 1 tick, #19). Teste `tests/wclock`. Oráculo do
    TerraSim: 18 de 20 pares iguais à v1.0.0; os 2 restantes são o efeito esperado
    (`routing_target`, sementes 1 e 3). O TerraSim cria a v1.1.0 em cima dela.
  - **`v1.1.0` publicada** (tag no `8d84077`, 2026-11-22, a pedido do Prof.): só o `terrac`
    muda (#21 lpeg 1.x, #23 linhas, #24 códigos e `--diag=json`, anexo novo
    `terrac-errors-1.1.0.json`). Firmware idêntico ao da v1.0.1; `_TOSSIM.so` com `.text`,
    `.data` e `.rodata` iguais aos da v1.0.1.
  - **`v1.1.1` publicada** (tag no `0980c2c`, 2026-11-22, a pedido do Prof.): correções no
    `terrac` (#28 cpp sem coluna; PR #30, otimizador, `Refs #22`). Firmware, catálogo e código
    dos `_TOSSIM.so` iguais aos da v1.1.0. TerraSim avisado.
  - **`v1.2.0` publicada** (tag no `73bc84e`, 2026-11-24, a pedido do Prof.): as correções da
    revisão de 2026-11-23 (#34 a #44, #46 parte, #55), primeira com o job do Avrora. Muda
    `.vmx` (#37: `routing_tree`, `routing_tree_ack`, `count2radio`, `tdma_slotted`; #38:
    `routing_target`, `aluno_hash_offset`, dos 14 programas do TerraSim) e o tempo (#40).
    Catálogo igual ao da v1.1.1. TerraSim avisado (refazer o oráculo).
  - **`v1.3.0` publicada** (tag no `0a0314f`, 2026-11-24, a pedido do Prof.): PRs #67 a #72, #77
    a #79 e #84 a #86 (lista "Para aplicar no TerraSim"). Muda VM (`op_uop`, #74 na BS...) e
    catálogo (161 códigos: W3006, E6007). `_TOSSIM.so` Net `8ea40f6b…`, Grp `ce415913…`. Dos 14
    programas do TerraSim só o `count2radio` muda (3 bytes, cast `<ubyte>`, #46). TerraSim
    avisado com a lista e o passo a passo (trocar anexos, refazer o oráculo, catálogo, release). A TerraSim
    v1.3.0 entrou em produção com ela em 2026-11-25 (oráculo diverge na BS pela #74, avaliador
    dentro do ruído).
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
    - `terrac`: os `.vmx` de `terrac/samples` e `tests/*/` saem iguais aos commitados (Count2Leds
      só em espaços de comentário), e os programas de `tests/terrac/` dão o erro e a linha de
      `erros.esperado`. Roda com o lpeg 0.10.2 (luarocks; o anexo da release sai dele) e com o da
      distribuição (1.x): as saídas têm de ser iguais. Até a v1.0.1 só o 0.10.2 servia (#21);
    - `TerraVMControl.jar`: compilado do fonte com as bibliotecas da TerraDist v0.3.0 (idênticas
      às do jar de 2016); `app.ControlForm` e o `MoteIF` carregam.
  - Conferido contra a produção de 2016 (`handoff/ova/TerraNG/`, a distribuição da `.ova`): o
    `terrac` empacotado é igual, salvo o nome do lpeg e uma mensagem de erro (`c94fdc3`); os
    `.defs` são idênticos; o jar tem as mesmas classes e assinaturas (só métodos sintéticos
    do compilador diferem).

## Backlog (GitHub Issues, desde 2026-11-22)

- O backlog são as issues de `afbranco/Terra`. Uma issue por mudança, com checklist e o teste
  previsto; o commit ou PR que resolve cita a issue (`Fixes #N`).
- Rótulos: prioridade `P1`/`P2`/`P3`; área `vm`, `terrac`, `terracontrol`, `build`, `release`;
  tipo `bug`/`enhancement`. `integracao-heterogenea` marca o que é da linha 2016-2018 (as
  issues #2 a #12, de 2017) e não vale para o `master`.
- Abertas em 2026-11-22: #15 release v1.0.0 (acompanhamento), #16 teste com micaz real, #17
  comparação de float na VM (a confirmar), #18 build reproduzível bit a bit, #19 await de 0 ms
  (fechada pelo PR #20, na v1.0.1).
- `terrac`, relatados pelo Prof. em 2026-11-22:
  - #21 lpeg 1.x: **fechada** (PR #25). As mensagens de erro `EM`/`EV`/`EK` terminam em `* P(1)`.
    44 de 90 mensagens de sintaxe ficaram mais precisas; nenhum `.vmx` mudou.
  - #23 número de linha: **fechada** (PR #26). Com `libc6-dev`, o `cpp -C` inclui o
    `stdc-predef.h` e as linhas saíam 42 acima; agora vêm dos marcadores do `cpp` (`_SRCLINE`).
    O `server/terrac_linhas.py` do TerraSim compensava isso e tem de ser desligado na troca
    (avisado em 2026-11-22). Saiu na v1.1.0.
  - #24 códigos de erro e `--diag=json`: **fechada** (PR #27, `5e8b4d4`). O catálogo fica em
    `terrac/errors.lua` (159 códigos; `terrac --catalog` gera o JSON, anexo
    `terrac-errors-<v>.json` da release). O texto continua igual, salvo as plataformas em ordem
    de nome (comparado com o antigo em 760 programas). Os W2xxx trazem `kind/name/line_{a,b}`,
    pedido do TerraSim, que revisou e aprovou o formato. Formato em `release/README.md`.
    Testes: `tests/terrac/{catalogo,consistencia}.lua` e `diag/json.esperado`. Também corrigiu a
    queda em `sizeof<5>` (`_V2NAME` incompleto). Saíram na v1.1.0.
  - #22 (P1) otimização (`optm.lua`) às vezes quebra a execução na VM. Ligada **por padrão**; o
    TerraSim compila com `--no-opt`. Não reproduzida:
    - Net: 20 programas com e sem `--opt`, comparados pelo VMDBG nó a nó (sem os
      `executing trail`) e pelo TVIEW;
    - Grp: 19 programas, com o `_TOSSIM.so` Grp da v1.1.0 montado na imagem do TerraSim;
    - todos se comportam igual.
    Para comparar, completar o `.vmx` otimizado com `end` até o tamanho do outro: senão o deploy
    muda de tamanho e o rádio diverge sem bug. Achado e corrigido (PR #30, `6544e3f`, `Refs #22`): rótulos
    no mesmo endereço antes de `exec` perdiam o redirecionamento. O padrão não aparece em 876
    programas otimizados. `tests/terrac/optm_rotulos.lua` confere o destino de cada rótulo. Falta
    um programa que quebre.
  - #28 erro do cpp sem coluna (`#if` sem `#endif`) saía como E1005: **fechada** (PR #29,
    `56e4edb`), relatado pelo TerraSim. Saiu na v1.1.1.
- Depois da v1.1.1 (2026-11-23), no `master`, para a próxima release:
  - #17 comparação de float empilhava 1.0f: **fechada** (PR #31). Teste `tests/floatcmp`;
  - #32 `nota` lido como `not a` (e `and`/`or`/`void`): **fechada** (PR #33).
    Teste `tests/terrac/palavras.terra`.
- **Revisão de 2026-11-23** (pedido do Prof.): três agentes de leitura (parser/tipos, geração
  de código, VM). Viraram as issues #34 a #49 (P1: #34 a #41). As P1 têm **verificação
  dobrada**: reproduzir com programa próprio antes de corrigir; o que o agente disse pode
  estar errado (ex.: na #34 o efeito no micaz é o mesmo do TOSSIM, não pior). Corrigidas:
  - #34 gravação de float (`setMVal` sem `return`): PR #50, teste `tests/floatset`;
  - #35 otimizador apagava o `end` depois do `chkret` do par/and: PR #51 (`Refs #22`), teste
    `tests/parand`. Primeiro programa que quebra só com `--opt`; aparece em ~4% do corpus;
  - #37 fim de par/or limpava o gate externo errado: PR #52, teste `tests/parorgate`. Muda o
    `.vmx` do `routing_tree` (o do oráculo do TerraSim) e de outros programas de rádio:
    avisar o TerraSim na release;
  - #36 break/return/par-or disparavam todos os finally: PR #53, teste `tests/finally`;
  - #38 dobra de constantes (divisão inteira, negativos): PR #54, teste `tests/dobra`. Muda
    `.vmx` de dois programas do TerraSim (mesmo valor, código menor);
  - #39 fila de entrada da BS (`inQ.get` duplo): PR #56, teste `tests/inq`;
  - #40 timer criado depois de evento externo contava a partir de agora, e os outros a partir
    do último disparo: o `await` seguinte saía com 1 tick. PR #59, teste `tests/wclockext`.
    Muda o tempo de programas com `await` depois de `RECEIVE` (oráculo do TerraSim);
  - #41 `tceu_wclock` tinha 6 bytes no AVR e o `terrac` conta 8: o `memclr` do par/or apagava
    outros timers no micaz. PR #58: `u16 pad` e checagem de tamanho na compilação. Teste
    `tests/wclocksize`, que só reprova no AVR (no Avrora).
  - #55 CI também no push para o `master`: PR #60.
  Depois das P1, a pedido do Prof. (2026-11-23, "sem esperar confirmação"), P2 que afetam a
  sala de aula:
  - #42 `x % 0` e `INT32_MIN / -1` matavam o TOSSIM (SIGFPE): PR #61, teste `tests/divmod`;
  - #43 índice de array fora do limite desandava a pilha: PR #62, teste `tests/arridx`;
  - #44 nó parava de pedir blocos (`blockStart >= blockLen`): PR #63, teste `tests/reqblock`,
    que faz o papel do TerraControl na serial da BS (`SerialForwarder` do TOSSIM; a BS é só
    ponte, quem responde aos pedidos de bloco é o TerraControl);
  - #46, só a parte que derrubava o compilador (`x+1 = 3`, `sizeof<ubyte> = 3`): PR #64,
    E4016, testes `tests/terrac/atrib_*`. A issue segue aberta (cast e arrays como lado esquerdo).
  Em 2026-11-24, a pedido do Prof. ("fechar o que já foi feito, ainda sem a release"), entraram
  no `master`, nesta ordem:
  - #46 resto (PR #67): cast e array como lado esquerdo; cast para inteiro menor corta o valor.
    Teste `tests/castint`;
  - #48 (PR #68): checagens menores e o aviso **W3006** (laço cujo único await está num
    `loop i,N` com N variável; aviso, não erro, decidido com o Prof.). Também o nome do limite
    do `loop i,N`, que usava um endereço de tabela Lua e mudava o `.vmx` a cada compilação.
    Teste `tests/checagens`;
  - #45 (PR #69): float convertido em `emit`, `await` e argumento; `%`, `~`, `inc` e índice
    com float dão E4030. A parte F_S32 no AVR não se reproduziu no Avrora (a VM não mudou).
    Teste `tests/floatconv`;
  - #18 (PR #70): build reproduzível (`-fdebug-prefix-map`, tar e jar determinísticos,
    `release/compare-builds.sh`);
  - #66 e #47 (PR #71): `op_uop` (opcode 128) para `ulong` sem sinal; deslocamento >= 32 dá 0
    (-1 no `>>` de negativo); `await` constante acima de 2147483646 ms é **E6007**, e variável
    ou expressão que estoura fica no máximo e gera `ERROR(E_TIMEOVF)` (12, nos `.defs`).
    Corpus: nenhum `.vmx` mudou. Testes `tests/{ulongop,awaitmax}`;
  - #49 (PR #72): MIN vazio dá 0 (decisão do Prof.), `blockId` do rádio validado, **dois
    buffers de RECEIVE** com contador de eventos pendentes (`VMCustom.evtDone`). Provado no
    Avrora: com um buffer, uma mensagem chegando com a VM ocupada sobrescrevia a anterior.
    Testes `tests/{aggmin,blockid,rxbuf}` (o `rxbuf` só reprova no Avrora).
  Catálogo: 161 códigos (W3006, E6007). Saíram na v1.3.0.
- **Para aplicar no TerraSim** (pedido do Prof., 2026-11-24: as mudanças também têm de ser
  aplicadas lá; avisar na release, com esta lista):
  - VM: `op_uop` (um `.vmx` com ele não roda em VM antiga), deslocamento >= 32, limite do tempo do
    `await` com `ERROR(E_TIMEOVF)` = 12 nos `.defs` (#66, #47); MIN vazio dá 0, dois buffers de
    RECEIVE no Net (#49); a BS não perde mais mensagens a caminho da serial e descarta, depois de 5
    tentativas, a que o `send` recusa (#74); agregação do Grp com as respostas certas com dois
    AGGREG seguidos (#75) e `AGGREG_DONE(id)`/`done.agId` com o agId do programa (#76);
    `SETDATAND`/`REQDATA` descartados sem `MODE_SETDATA` (#81); `reqSensor` responde na hora
    (valor 0) a sensor sem leitura (#82); depois da v1.3.0, Grp: requisitante fora do grupo
    recebe as respostas dos membros e não conta a própria leitura (#87); eleição em mais de 3
    grupos (fila trocada por máscaras, +2 B de RAM, #88); status do `SENDBS_DONE`/`SENDGR_DONE` (Grp)
    e do `SEND_DONE()` (Net) com 2 bytes: antes vinha status*256 + byte vizinho (PR #96, #83);
    fila local de agregação do Grp lida em 2 bytes e reacionada depois de cada leitura (PR #97);
    **firmware micaz do Net com `MOD=MSGQ`** (até a v1.3.0 saía sem a fila que o `.defs` declara;
    memória para programa 1920 B, PR #101, #99);
  - terrac: catálogo com W3006 e E6007 (161 códigos); `.vmx` com `loop i,N` com nomes de limite
    novos (#48); cast para inteiro menor corta o valor (#46); float convertido em `emit`, `await`
    e argumento, e E4030 nos casos inválidos (#45);
  - o oráculo do TerraSim tem de ser refeito (tempo e mensagens na serial mudam com a #74).
  TerraControl no backlog (#73).
- **Revisão da disseminação e do Grp** (2026-11-24, a pedido do Prof.; dois agentes de leitura,
  verificação dobrada). Reproduzidos e corrigidos, no `master`:
  - #74 (PR #77): a BS tirava duas mensagens da `outQ` por envio (chegavam à serial 2 de 4). A
    mensagem sai só no `sendDone`; o `send()` recusado na BS tenta até `MAX_SEND_RETRIES` e
    descarta (`sendFailed`; sem isso o SEND_BS do Grp, AM 150 sem envio pelo rádio, travava a
    fila: o `grpbs` reprovou no Avrora). Teste `tests/bsqueue`; o `avrora_vmx.py` ganhou o
    `SERIAL_USR`;
  - #75 (PR #78): agregação comparava as respostas com o `AggSeq` do último AGGREG. Teste
    `tests/aggseq`;
  - #76 (PR #79): `AGGREG_DONE` com `agId | 0xE0` (resto dos bits `TID_*`). O Prof. confirmou
    que o 224 não era intencional; docs e exemplos não o usam. Teste `tests/aggdoneid`.
  Não reproduzido: buffer único do REC_GR (TOSSIM e Avrora, com e sem parâmetro): a cópia e o
  `queueEvt` são da mesma tarefa. Documentação dos parâmetros dos eventos do Grp: #80.
  Verificação dos P2/P3 (2026-11-24):
  - #81 (PR #84): `SETDATAND` (o *New Set Value* do TerraControl) ficava na cabeça da `outQ` do
    mote, sem `case` no envio, e o mote não transmitia mais nada. Sem `MODE_SETDATA` (o padrão),
    `SETDATAND`/`REQDATA` caem no `default` (descarte). Teste `tests/setdatand`; o
    `avrora_vmx.py` ganhou o `SERIAL_EXTRA`;
  - #82 (PR #85): `SA.reqSensor` sem `default`: um sensor sem leitura (`SID_INT_A`) na agregação
    nunca sinalizava `Ready` e travava as agregações seguintes. Teste `tests/aggsensor`;
  - PR #86, só teste: `tests/versao2` (versão nova no meio da disseminação, linha 1-11-12-13). Na
    v1.2.0 os nós ficavam na versão 1 (efeito da #74, não do `ReqState`); no `master` 30 de 30
    passam. Só TOSSIM (`AVRORA = False`, que o `test-avrora.sh` pula).
  - O resto (confirmados só na leitura, a decidir, só no hardware, não reproduzidos, TerraControl)
    ficou na #83 (backlog, P3).
  - Decisões da #83 (2026-11-25, com o Prof.): #87 (PR #89), requisitante de AGGREG fora do grupo
    descartava as respostas no `isSameGroup`; agora recebe só dos membros (decisão do Prof.).
    Teste `tests/aggmembro`. #88 (PR #90): com 4 ou mais grupos eletivos a fila de eleição
    (3 com `QUEUE=SHORT`) enchia e os excedentes nunca elegiam; virou `elctPend`/`elctInit` com
    rodízio (+2 B de RAM, +420 B de flash no Grp NOBS). Teste `tests/elect4`. O `currVote`
    sobrescrito por eleições simultâneas não se reproduziu (1, 2 e 4 grupos, até 8 sementes):
    só documentado, sem gastar RAM. Ainda não estão em release.
  - PR #96 (#83): o `.defs` declara `SENDBS_DONE`, `SENDGR_DONE` e o `SEND_DONE()` do Net como
    `ushort` e a VM guardava o status em 1 byte; o `await` lia status*256 + o byte vizinho (no
    micaz do Net, o `rxPend` da #49). Buffers de 2 bytes, `.defs` e `.vmx` iguais, +2 B de RAM.
    Teste `tests/sendbsdone` (EBUSY é 5 no TinyOS). A parte do Net entrou sem teste que reprove
    (decisão do Prof.): no Avrora não se conseguiu um RECEIVE pendente na hora do SEND_DONE,
    porque a VM não cede a CPU no meio de uma reação. O `SEND_DONE_ACK` já estava certo.
  - PR #97 (#83): fila local de agregação do Grp. O `procNextAggLocalReq` lia 2 bytes num
    `uint8_t` e, depois da leitura local, a fila local não era reacionada (a `dataQueue` só avisa ao
    sair de vazia). Sem teste que reprove (decisão do Prof.): a fila não chegou a ter dois pedidos.
    `nhops = 0` no `groupInit` dá timeout 0 e `count` sempre 0: decidido documentar (#91), sem
    aviso no `terrac`. O `tests/grpbs` é instável no Avrora, também sem a mudança (#98).
  - PR #101 (#99): o firmware micaz do Net das releases v1.0.0 a v1.3.0 saía sem `MOD=MSGQ` (o
    TOSSIM e a produção de 2016 tinham): `qPut`/`qGet`/`qSize`/`qClear` não existiam no mote e a
    pilha desalinhava. Teste `tests/msgq` (reprova só no Avrora). Causa geral: o `.defs` não
    acompanha o build (princípio do Prof.: só declara o que o mote tem); variantes geradas pelo
    build na #100. No Grp, `REQ_MIC`/`MIC`/`setupMic`/`BEEP` estão no `.defs` desde 2015-06
    (`841aa59`) e nunca foram implementados; no Net dependem da MTS300 (`SBOARD=300`, `167a54e`).
  - O `gh pr merge` não acusa branch desatualizada (o repositório não exige): conferir com
    `git merge-base --is-ancestor origin/master <head>` e atualizar antes do merge.
  Os testes de VM (`tests/*/test_*.py`) carregam o `.vmx` no nó 11 e leem os LEDs (3 bits)
  no TVIEW. Corpus de comparação dos compiladores (1.173 programas) no scratchpad da sessão.
- **Avrora** (micaz emulado, #57, PR #58, 2026-11-23): `tests/avrora/avrora_vmx.py` roda um teste
  de `tests/*/` com o firmware micaz BS e NOBS (Net ou Grp, `VM = "grp"` no teste), o mínimo
  de nós (BS + motes do `ESPERADO`) e o SerialForwarder do TinyOS na serial da BS; responde aos
  pedidos de bloco como o TerraControl; monitor `real-time` (sem ele, no CI a simulação acabava
  antes do deploy). `release/test-avrora.sh` roda todos; o job `avrora` do workflow só roda na
  tag `v*` e na execução manual (decidido pelo Prof.: é lento, ~4 min no CI). Testes novos
  `tests/radio` (Net, 3 nós) e `tests/grpbs` (Grp, `SEND_BS` até a serial). O Avrora só mostra
  mudança de LED (valores repetidos seguidos viram um). Não substitui o micaz real (#16).
- Imagens locais de teste do terrac: `localhost/terrac-lpeg:0.10.2`, `:1.0.2` (ambas com
  `libc6-dev`) e `:semlibc` (1.0.2 sem `libc6-dev`); Containerfiles no scratchpad da sessão.
- Correções vindas de outras sessões (ex.: TerraSim) entram como issue aqui antes do código.

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
passou (ver "Oráculo"). A v1.0.0 e a v1.0.1 saíram em 2026-11-22. Próximo passo: os
ajustes e bugs de compilação que o Prof. conhece.

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
não foi testado no TerraSim (só a reprodução binária). O avaliador com o daemon em py3 também
ficou dentro do ruído (6 rodadas: 4x4 96,9%, 8x8 79,0%, 9x9 75,9%, contra 97,1/78,5/72,4 da
produção). O TerraSim está em produção com o `.so` do CI do PR #13 (`459a2091…`, r1) desde o
557b0b8. Ele vai trocá-lo pelo anexo da v1.0.0 (`_TOSSIM.so` Net `6ddea5c4…`: `.text`, `.data`
e `.rodata` iguais aos do `459a2091`), refazer o oráculo e criar a TerraSim v1.1.0.

## Pendências para decidir com o Prof.

- Se o `handoff/` (scripts e tabelas da análise de versão) entra no repositório. Hoje está
  fora do git (`.git/info/exclude`).
- Teste do Prof. com micaz real (MIB520, #16, roteiro em `release/README.md`): não bloqueou a
  v1.0.0 nem a v1.0.1 e consta como pendente nas notas delas.
- Quais correções de bugs achados na integração valem para a produção.

## Como trabalhar (mesmas regras do tinyos-toolchain)

- Testar antes de publicar; teste novo só vale depois de reprovar com a mudança desfeita.
- **Painel de status** em `STATUS.md` na raiz (fora do git, em `.git/info/exclude`; o repositório
  é público). É lido pela sessão de acompanhamento do Prof. (`~/admin`). Ao concluir uma tarefa
  que muda o estado do projeto (release, PR, bug corrigido, decisão) e antes de encerrar,
  atualizar o painel, no formato que já está lá (até ~8 pendências, "com:" diz quem age).
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
