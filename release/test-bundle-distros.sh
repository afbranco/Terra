#!/bin/bash
# O pacote terra-<v>-linux-x86_64.tar.gz (#95) em várias distros (o test-bundle.sh em cada uma).
# As imagens são as oficiais, fixadas pelo digest (2026-11-27); a tabela do release/README.md é a
# saída deste script.
#   release/test-bundle-distros.sh <terra-<v>-linux-x86_64.tar.gz> [docker|podman]
set -uo pipefail
TGZ=${1:?pacote}
ENG=${2:-docker}
DIR=$(cd "$(dirname "$0")" && pwd)
IMAGENS=(
    docker.io/library/ubuntu:20.04@sha256:8feb4d8ca5354def3d8fce243717141ce31e2c428701f6682bd2fafe15388214
    docker.io/library/ubuntu:22.04@sha256:b000e69a50ff940390233025e7a337fb8469b509e2334fa4d018ac30f3e18cdb
    docker.io/library/ubuntu:24.04@sha256:562111b88caa79c71391c0c4d3c2114a7d5c35915c20561fd893cb1e07929e6b
    docker.io/linuxmintd/mint22-amd64@sha256:34ff53d1dca48a73486c3051425306421278225ae02b6d5066a3c940183cae1f
    docker.io/library/debian:11@sha256:6f519a81440354a85eb592c5f32109ab80605f6b892455983a6f618bf87fabe9
    docker.io/library/debian:12@sha256:1d04200c2ece1d4d75a2a6f8e11ebce7d86a2ae28b34bb2c9cbb3ee9f4953e75
    docker.io/library/debian:13@sha256:3cda3ca472ce45507a5109c6a3907093e24d9ae67d55954c9a07a45665dafba2
    docker.io/library/fedora:41@sha256:f1a3fab47bcb3c3ddf3135d5ee7ba8b7b25f2e809a47440936212a3a50957f3d
    docker.io/library/fedora:43@sha256:f01112b9a1f1d0504ad962d9adfa401425033f8ab067e0a821904ebdde5b8ca5
    docker.io/opensuse/leap:15.6@sha256:79be7751205ea84559990fb76b1bec71e38d6fad41c70a4f6c921b803b58f421
    docker.io/opensuse/tumbleweed@sha256:3c2c571495d6042c4472041bd2413e95e3ba02f68b1f20b6c94e2e36467f8720
    docker.io/library/archlinux@sha256:375a401bb3c6376b37f40b6dfa25067db37ec78d0b7af67ae6315f43a0184a9d
    docker.io/rockylinux/rockylinux:9@sha256:bb5755f96bec05ff26165e779ec843d7167544be9e50770508f307019a6d05c4
    docker.io/library/almalinux:9@sha256:02df05719ef287ebd0df0a1eedb9172a00bd70703aed7b25660e426b8e0d6047
)
fail=0
echo "| Imagem | Distro (/etc/os-release) | glibc | Resultado | Na imagem |"
echo "|---|---|---|---|---|"
for img in "${IMAGENS[@]}"; do
    out=$(QUIET=1 "$DIR/test-bundle.sh" "$TGZ" "$ENG" "$img" 2>&1)
    r=$?
    l=$(echo "$out" | tail -1)
    info=${l#*test-bundle: }
    distro=${info%% | *}; resto=${info#* | }; glibc=${resto%% | *}; tem=${resto#*tem: }
    if [ $r = 0 ]; then res=OK; else res="FALHOU ($(echo "$out" | grep '^test-bundle:' | sed 's/^test-bundle: //' | head -2 | tr '\n' ';'))"; fail=1; fi
    nome=${img#docker.io/}; nome=${nome#library/}; nome=${nome%@*}
    echo "| \`$nome\` | $distro | ${glibc#glibc } | $res | ${tem:-?} |"
done
exit $fail
