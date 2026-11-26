# Reprodução dos .so de produção (2026-11-22)

Os dois `_TOSSIMmodule.so` de produção (Net `8214f2c5...`, Grp `93cc11cf...`) foram reproduzidos
no ambiente da `.ova` (rootfs em `handoff/ova/rootfs`, via `ovabuild.sh`) com:

- fonte: `f02b8e6`, exceto `TerraVM/src/BasicServices.h` na versão de `f32dd25` (2015-07-21).
  O `f02b8e6` acrescenta 3 linhas `#elif defined(INOS)` que não geram código no micaz, mas
  deslocam as linhas de declaração no DWARF;
- montado em `/home/branco/gitspace/Terra` (o caminho que aparece no DWARF);
- Net: `make micaz sim-sf VM=NET MOD=MSGQ RFPOWER=4 TYPE=ALL HYB=YES QUEUE=SHORT`
- Grp: `make micaz sim-sf VM=GRP RFPOWER=4 TYPE=ALL HYB=YES QUEUE=SHORT`

Resultado, nos dois: mesmo tamanho; 33 de 36 seções ELF idênticas byte a byte (`.text`,
`.rodata`, `.data`, `.symtab`, `.debug_line` etc.). As 3 restantes:
- `.debug_str`: o mesmo multiconjunto de strings, depois de normalizar os nomes `arg_0x<endereço>`
  que o nesC gera com endereços do próprio heap;
- `.debug_info`: idêntico depois de decodificado, com a mesma normalização e com os offsets
  de string mascarados;
- `.note.gnu.build-id`: um hash do conteúdo.

Com `RFPOWER=3` (o valor do `CompilationStatus.txt` da TerraDist v0.3.0), 1 byte do `.text`
difere (`sim_main_start_mote`, a inicialização da potência); log em `build-net-rfpower3.log`.
