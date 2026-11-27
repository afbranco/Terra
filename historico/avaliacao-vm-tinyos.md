# Evoluções da VM TinyOS depois da produção (f02b8e6 → 9b4bebe)

Levantamento de 2026-11-22. Só leitura: nenhum código foi alterado.

## Motivação (contada pelo Prof. em 2026-11-22)

Em 2016-2017 o Prof. avaliava a integração de plataformas diferentes usando a VM do Terra como
meio comum. Daí a BS que executa Terra, a multirede (cada BS como roteador entre redes; dois
nós heterogêneos ligados por serial, cada um com um rádio diferente) e os portes para Linux,
Arduino Mega etc. Essas mudanças são uma linha de pesquisa coerente, não deriva sem controle.

## Recorte

Commits entre `f02b8e6` e `9b4bebe` que tocam arquivos usados no build TinyOS:
`TerraVM/src/*.nc *.h Makefile`, `CustomVMs/TerraNet|TerraGrp`, `XComps`, `platforms/TinyOS`,
`system`, `interfaces` e `lib`. Com esse critério são **31 commits** (o CLAUDE.md fala em 37,
com critério não registrado). Lista em ordem: ver a tabela abaixo.

## Evidência empírica (toolchain novo, imagem 2.1.2-resolute-py3)

- `9b4bebe` compila: `micaz sim-sf` Net e Grp (geram `_TOSSIM.so`), `micaz` Net (51.442 B ROM)
  e Grp (71.118 B ROM), todos com `TYPE:BOTH`.
- `f02b8e6` (produção) também compila no toolchain novo: `make micaz sim-sf VM=NET|GRP
  TYPE=ALL` gera `_TOSSIM.so` Net e Grp, sem adaptação.
- `8478d13` (dez/2016) não gera `.so` TOSSIM: falta `platform.h`. O `-I.../platforms/micaz` do
  Makefile de 2018 é a correção.
- O Makefile de 2018 põe `-I interfaces -I system -I lib/serial` em **todos** os alvos, então
  cópias locais sombreiam o TinyOS. O `.so` de produção usava só os originais (DWARF).
  - TOSSIM: as cópias usadas equivalem ao TinyOS 2.1.2. Exceções: comentários, um campo
    `rf_power` em `serial_metadata_t` (usado só no Mega) e o `Grp/sim/TossimActiveMessageC.nc`.
  - micaz real: entram as cópias modificadas `SerialP` (aceita `PACKET_NOACK`), `tos.h`
    (sem o include do safe, `TOS_NODE_ID = TERRA_NODE_ID`), `FcfsResourceQueueC`
    (`qTail%size`, inócuo), `SchedulerBasicP` e `RealMainP` (só `#ifdef ANDROID` e `x123_`).
  - O `rf_power` não muda o tamanho do `message_t` no micaz: fica numa união com o
    `cc2420_metadata_t`, que é maior.

## Mudanças de comportamento que quebram a equivalência com a produção

1. **Estação Base reescrita (8478d13).** Antes, o nó 1 era só ponte (VM parada) e numerava
   as versões. Agora o `ROOT_ID` roda a VM como qualquer nó e a serial vira "mais um rádio".
   `newProgVersion_t` ganhou `appSize`. O TerraControl e o terrac antigos não conversam com
   ela.
2. **Scripts por MoteType (da5227e, 6f80b19).** `moteType` nas mensagens, `BLOCK_SIZE`
   24 → 22, segundo bitmap. Descarte de `versionId <= ProgVersion` sempre ativo.
3. **Pilha da VM em `nx_` (da5227e).** Big-endian, sem alinhamento. Muda o layout de memória
   e pode ter relação com o problema de 64 bits que o Prof. lembrava.
4. **`update_wclk_late()` em evento externo (da5227e).** Muda a semântica temporal do Céu.
   Forte candidato a divergência no oráculo.
5. **Multirede (ae3bbbc, c3ee400).** Rede = ID>>11, `SEND_DATA_SIZE` separado (GR 16,
   usr 22).
6. **`sensors.bin` de 600 para 800 bytes (6b1d5c2).** 4º valor (MoteType). Incompatível com
   o arquivo de produção usado pelo TerraSim.
7. **Comparação de float (8478d13).** Agora empilha 0/1 inteiro. Antes empilhava 1.0f, e
   guardar o resultado num inteiro dava 1065353216. É correção de bug, mas muda o resultado.
8. **Despacho de opcodes por tabela, getPar desenrolado (95feb4f, TPC).** Equivalência
   conferida por inspeção: 256 opcodes, p_len possíveis.

## Bugs encontrados (presentes em 9b4bebe)

- **Potência de RF no Grp:** `Grp/AMAuxC.nc` passa o índice 0..7 cru ao chip, sem
  `RFPowerTab`. Com `RFPOWER_IDX=3`, o micaz transmite com PA 3 (≈ -25 dBm) em vez de 15
  (≈ -7 dBm). O Net converte certo. Origem: 8478d13.
- **Índice 0 de potência nunca é aplicado** (`if RFPower > 0`).
- **`RFPOWER_INIT` do mica2** é definido em `Net/AMAuxC.nc`, mas testado em
  `BasicServicesP.nc`. Não chega lá: a potência inicial nunca é aplicada.
- **Makefile ~792:** no bloco do STAT, o `else` faz `DM_MSGQ = 0` (devia ser `DM_STAT`). Com
  `MOD:MSGQ` sem `STAT`, a reserva da fila é zerada no cálculo de `VM_MEM_BLKS`. O `DM_STAT`
  nem entra na conta.
- **Grp com BS:** o `#ifdef MODULE_CTP` vazio em `RadioSender_send` sugere que o `sendBS`
  do raiz não chega à serial. A confirmar.
- **`TYPE` padrão virou `NOBS` (a722474):** sem `TYPE:` explícito, a BS sai sem o código de
  BS.
- **VM:THIN não compila:** faltam `BasicServicesThinC` e `ProgStorageHardCodedP`. Há
  caminho fixo `msp430-gcc` e `-I/home/mauricio/...`.
- **Restos:** `x123_` em `SchedulerBasicP`, `SerialP_original.nc`, precedência enganosa
  `!x.sendToMote==0` em `BasicServicesP.nc:1198`.

## Tabela por commit

| Commit | Data | Assunto | Afeta TinyOS | Teste | Recomendação |
|---|---|---|---|---|---|
| 74b669c | 16-05-29 | `#ifdef IX` (Linux) | não | não | manter |
| e8df092 | 16-06-11 | `BSID` | sim (substituído por ROOT_ID) | não | absorvido |
| 2343c76 | 16-10-07 | remove a VM (reorganização) | n/a | n/a | n/a |
| 8478d13 | 16-12-06 | reintroduz no layout novo; BS reescrita; float cmp; ReceiveUser no Grp | **sim, muito** | não | **rever** por partes |
| 2293a4f | 16-12-07 | remove DDRF; rf_power | pouco | não | manter |
| a788667 | 16-12-30 | RPi; tos.h | pouco | não | manter |
| 6b1d5c2 | 17-02-12 | dataSensor 4º valor | sim (TOSSIM) | não | **rever** (formato) |
| da5227e | 17-02-13 | MoteType; nx_; wclk_late; SerialP NOACK | **sim, muito** | não | **rever** |
| ae3bbbc | 17-03-06 | multirede | sim | não | rever |
| c3ee400 | 17-04-02 | multirede, tamanhos de msg | sim | não | rever |
| 4d27ef0 | 17-04-27 | Makefile reescrito | build | compila | manter |
| 6f80b19 | 17-04-27 | ProgStorage/flash interna; filtros de versão | parcial | não | rever |
| fa6d43c | 17-05-01 | SSID minúsculo | não | n/a | manter |
| bf5456c | 17-08-24 | GPL | não | n/a | manter |
| a722474 | 17-08-28 | Android; TYPE padrão NOBS | sim (padrão) | não | rever padrão |
| beffa8d | 17-09-14 | InternalFlash.nc | não | n/a | manter |
| 6d8d6f1 | 17-09-14 | -DUNO/-DMEGA | não | n/a | manter |
| f6b5911 | 17-09-14 | warnings MEGA | não | n/a | manter |
| 0c9f371 | 17-09-14 | idem | não | n/a | manter |
| efd8f6e | 17-09-16 | baud mega | não | n/a | manter |
| 59a8a85 | 17-09-17 | ANA refs (Ino) | não | n/a | manter |
| c5538e7 | 17-09-30 | cópias FcfsArbiterC/NoLedsC | não | diff = TinyOS | manter |
| c840e91 | 17-10-01 | bugfix esp | não | n/a | manter |
| 8131f3d | 17-10-07 | ESP | só comentários | n/a | manter |
| 9aace4c | 17-10-08 | INO_TOOLS_PATH | não | n/a | manter |
| 81c4106 | 17-10-08 | warnings | não | n/a | manter |
| 7a1fbb9 | 17-11-02 | NO_DEBUG; qTail%size | mínimo | não | manter; reverter %size |
| 57aac04 | 17-11-02 | NO_DEBUG | não | sim compila com NO_DEBUG | manter |
| ef82604 | 17-11-02 | NO_DEBUG | não | idem | manter |
| 95feb4f | 18-03-12 | TPC: despacho por tabela, STAT, THIN, x123_ | sim (núcleo) | só dados TPC | manter a otimização após o oráculo; rever o resto |
| 153eb0e | 18-03-12 | VM Thin (rsa64, sense64) | só VM:THIN | relatórios TPC | rever (não compila) |

## Consequência para o oráculo

Comparar o `.so` de produção com uma release de 2018 vai divergir por desenho: protocolo da
BS, MoteType, `sensors.bin`, float e `wclk_late`. Antes do oráculo é preciso decidir o que
se quer equivalente. Duas saídas:
- (a) a release de referência sai de `f02b8e6` compilado no toolchain novo;
- (b) o oráculo compara só a execução de programas (saídas e tempos), com adaptadores para o
  protocolo.
