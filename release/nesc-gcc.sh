#!/bin/bash
# Compilador C do nesC no build do TOSSIM (make ... GCC=<este script>; ver build-tinyos.sh).
# O nesc1 dá aos parâmetros sem nome (ex.: o índice de interface parametrizada) o nome
# arg_0x<endereço>, com o endereço do próprio heap. Com ASLR o endereço muda a cada build, o
# nome entra no DWARF e o _TOSSIM.so não sai igual bit a bit (issue #18). Dentro do contêiner
# não dá para desligar o ASLR (o seccomp padrão bloqueia o personality), então aqui, antes do
# gcc, o C gerado pelo nesc1 tem esses nomes trocados por um contador, na ordem em que
# aparecem: arg_0x000000000001, arg_0x000000000002... Mesmo tamanho do nome original e o
# mesmo código (nome de parâmetro não muda o código gerado).
# Só mexe no passo final do nesc-compile (gcc -c ... -fdollars-in-identifiers <arquivo>.c,
# um temporário do próprio nesC); as outras chamadas passam direto para o gcc.
c=${!#}
case " $* " in
    *" -fdollars-in-identifiers "*)
        if [[ $c == *.c && -f $c ]]; then
            perl -pi -e 's/arg_0x([0-9a-f]+)\b/$m{$1} \/\/= sprintf("arg_0x%012x", ++$n)/ge' "$c" || exit 1
        fi ;;
esac
exec gcc "$@"
