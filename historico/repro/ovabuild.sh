#!/bin/bash
# Executa o make do Terra no rootfs da .ova (Ubuntu 12.04 i386, gcc 4.6.3, nesC 1.3.4).
# Pré-requisito: handoff/ova/rootfs extraído do root.img com debugfs rdump.
# uso: [CFLAGS=...] ovabuild.sh <dir-fonte> <log> <args do make...>
# Um CFLAGS no ambiente é repassado ao make (o Makefile do Terra acrescenta a ele com +=).
src=$1; log=$2; shift 2
podman run --rm \
  -v $src:/home/branco/gitspace/Terra:Z -w /home/branco/gitspace/Terra/TerraVM/src \
  -e TOSROOT=/opt/tinyos-2.1.2 -e TOSDIR=/opt/tinyos-2.1.2/tos -e MAKERULES=/opt/tinyos-2.1.2/support/make/Makerules \
  -e CLASSPATH=/opt/tinyos-2.1.2/support/sdk/java/tinyos.jar -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin -e HOME=/root -e USER=branco ${CFLAGS:+-e CFLAGS="$CFLAGS"} \
  --rootfs $HOME/Terra/handoff/ova/rootfs \
  /usr/bin/setarch i686 nice -n 19 make "$@" > $log 2>&1
