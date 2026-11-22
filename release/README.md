# Releases do Terra

As releases a partir da 1.0 são geradas pelo workflow `.github/workflows/release.yml`. Ele usa a
imagem fixa do [tinyos-toolchain](https://github.com/afbranco/tinyos-toolchain), release
`2.1.2-r2`: `ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-21d8fb1`, cujo digest está no
workflow e no `BUILDINFO` de cada release.

## Anexos

| Arquivo | O que é |
|---|---|
| `terra-<v>-net-tossim-py3-x86_64.tar.gz` | Simulador TerraNet: `_TOSSIM.so` e `TOSSIM.py` (Python 3.14, x86_64) |
| `terra-<v>-grp-tossim-py3-x86_64.tar.gz` | Simulador TerraGrp, idem |
| `terra-<v>-{net,grp}-micaz-nobs.{exe,ihex}` | Firmware micaz, nó comum |
| `terra-<v>-{net,grp}-micaz-bs.{exe,ihex}` | Firmware micaz, estação base (nó 1, ligado ao computador) |
| `terrac-<v>.tar.gz` | Compilador `terrac`, `TerraNet.defs`, `TerraGrp.defs` e `terra.lang` |
| `TerraVMControl-<v>.jar` | TerraControl, com todas as bibliotecas dentro |
| `BUILDINFO`, `SHA256SUMS`, `logs.tar.gz` | Commit, imagem e logs de compilação e de teste |

As opções de compilação são as da produção (`RFPOWER=4`, o padrão; o Net com `MOD=MSGQ` no
simulador). Os comandos exatos estão em `build-tinyos.sh` e nos logs.

## Gravar um micaz

O `.ihex` sai com o ID 1. Para outro ID, use o `.exe` e a imagem do toolchain. Exemplo: nó 2
numa MIB520 em `/dev/ttyUSB0`:

```bash
podman run --rm -it --device /dev/ttyUSB0 -v "$PWD:/w:Z" -w /w \
  ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-21d8fb1 sh -c '
    tos-set-symbols --objcopy avr-objcopy --objdump avr-objdump --target ihex \
      terra-<v>-net-micaz-nobs.exe no2.ihex TOS_NODE_ID=2 ActiveMessageAddressC__addr=2 &&
    avrdude -cmib510 -P/dev/ttyUSB0 -pm128 -U hfuse:w:0xd9:m -U efuse:w:0xff:m \
      -C/etc/avrdude.conf -U flash:w:no2.ihex:a'
```

A estação base é o nó 1: grave `terra-<v>-net-micaz-bs.ihex` direto. A MIB520 abre duas portas:
a primeira grava o firmware e a segunda é a de dados, usada pelo SerialForwarder (por exemplo,
`java net.tinyos.sf.SerialForwarder -comm serial@/dev/ttyUSB1:micaz`).

## terrac

Requer Lua 5.1, o lpeg (0.10.2 ou 1.x) e o `cpp`. Em Ubuntu/Debian, o lpeg da distribuição
serve:

```bash
sudo apt-get install lua5.1 lua-lpeg cpp
lua5.1 terrac meuScript.terra      # gera meuScript.vmx; o .defs fica na mesma pasta
```

Até a 1.0.1 o `terrac` só funcionava com o lpeg 0.10.2 (`luarocks --lua-version=5.1 install lpeg
0.10.2-1`). O CI testa as duas versões, e elas têm de gerar o mesmo `.vmx` e as mesmas mensagens.

## TerraControl

`java -jar TerraVMControl-<v>.jar` (Java 8 ou mais novo). Ele conversa com o SerialForwarder do
TinyOS, ou com o simulador.

## Gerar localmente

```bash
podman run --rm -v "$PWD:/terra:ro,Z" -v "$PWD/dist:/out:Z" -w /terra \
  ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-21d8fb1 release/build-tinyos.sh dev /out
release/build-terrac.sh dev dist     # com Lua 5.1 e o lpeg instalados
```
