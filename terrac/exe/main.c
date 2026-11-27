/* terrac executável (#95): o Lua 5.1, o lpeg e o mcpp ligados num arquivo só, com o terrac (o script
 * gerado pelo pak.lua) dentro. Não precisa de nada instalado na máquina.
 *   terrac [opções] prog.terra   compila (o terrac de sempre)
 *   terrac --cpp [opções] ...     o pré-processador (mcpp); é o que o terrac chama para o #include
 *   terrac --licenses             as licenças do Lua, do lpeg e do mcpp, que vão dentro
 * Montado pelo release/build-terrac-exe.sh. */
#include <limits.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"

#include "terrac_lua.h" /* terrac_lua[] e notices_txt[] (as licenças), gerados pelo build */

int luaopen_lpeg(lua_State *L);
int mcpp_lib_main(int argc, char **argv);

static int traceback(lua_State *L) {
    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");
    lua_pushvalue(L, 1);
    lua_pushinteger(L, 2);
    lua_call(L, 2, 1);
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1 && strcmp(argv[1], "--licenses") == 0) {
        fwrite(notices_txt, 1, notices_txt_len, stdout);
        return 0;
    }
    if (argc > 1 && strcmp(argv[1], "--cpp") == 0) {
        /* o mcpp lê a codificação do LC_ALL/LC_CTYPE/LANG (e não conhece "C.UTF-8" nem
         * "pt_BR.UTF-8": avisa em todo programa) e pastas de include do C_INCLUDE_PATH: sem elas,
         * a saída não depende da máquina, e é a que foi comparada com a do cpp */
        unsetenv("LC_ALL");
        unsetenv("LC_CTYPE");
        unsetenv("LANG");
        unsetenv("C_INCLUDE_PATH");
        unsetenv("CPLUS_INCLUDE_PATH");
        argv[1] = "mcpp";
        return mcpp_lib_main(argc - 1, argv + 1);
    }
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    /* require 'lpeg' sem biblioteca dinâmica */
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    lua_pushcfunction(L, luaopen_lpeg);
    lua_setfield(L, -2, "lpeg");
    lua_pop(L, 2);
    /* o próprio executável (para chamar o --cpp) e a pasta corrente (para encurtar os caminhos
     * das mensagens do mcpp) */
    char buf[PATH_MAX];
    ssize_t n = readlink("/proc/self/exe", buf, sizeof(buf) - 1);
    if (n > 0) {
        buf[n] = 0;
        lua_pushstring(L, buf);
        lua_setglobal(L, "_TERRAC_EXE");
    }
    if (getcwd(buf, sizeof(buf))) {
        lua_pushstring(L, buf);
        lua_setglobal(L, "_TERRAC_CWD");
    }
    lua_newtable(L);
    for (int i = 0; i < argc; i++) {
        lua_pushstring(L, argv[i]);
        lua_rawseti(L, -2, i);
    }
    lua_setglobal(L, "arg");
    lua_pushcfunction(L, traceback);
    /* o script começa com "#!": vira comentário, sem mudar as linhas */
    if (terrac_lua_len > 1 && terrac_lua[0] == '#') terrac_lua[0] = terrac_lua[1] = '-';
    if (luaL_loadbuffer(L, (const char *)terrac_lua, terrac_lua_len, "@terrac")) {
        fprintf(stderr, "terrac: %s\n", lua_tostring(L, -1));
        return 1;
    }
    for (int i = 1; i < argc; i++) lua_pushstring(L, argv[i]);
    if (lua_pcall(L, argc - 1, 0, 1)) { /* 1: o traceback */
        fprintf(stderr, "terrac: %s\n", lua_tostring(L, -1));
        return 1;
    }
    lua_close(L);
    return 0;
}
