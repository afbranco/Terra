-- Diagnósticos do terrac: catálogo de códigos estáveis, saída em texto e em JSON (issue #24).
--
-- Regras do catálogo:
--   * um código nunca muda de significado nem é reaproveitado; um erro novo ganha código novo;
--   * o modelo (msg) gera exatamente o texto do modo texto: `{nome}` é trocado por args.nome;
--   * grupos: E0 interno, E1 entrada, E2 sintaxe, E3 nomes e declarações, E4 tipos e
--     expressões, E5 controle e contexto, E6 limites, E9 não implementado; W1 conversões,
--     W2 não determinismo, W3 alcançabilidade, W4 declarações, W5 limites, W6 pré-processador.
--
-- Modo texto (o padrão): igual ao terrac antigo, `ERR : line N : msg` e `WRN : line N : msg`.
-- Modo `--diag=json`: no stderr só há linhas JSON, um diagnóstico por linha e, no fim, sempre,
-- uma linha {"summary": ...}. `line` e `msg` são os mesmos do modo texto.

_DIAG = {
    json   = false,
    errors = 0,
    warnings = 0,
}

_DIAG.GROUPS = {
    E0 = 'internal', E1 = 'input', E2 = 'syntax', E3 = 'names and declarations',
    E4 = 'types and expressions', E5 = 'control and context', E6 = 'limits',
    E9 = 'not implemented',
    W1 = 'conversions', W2 = 'nondeterminism', W3 = 'reachability', W4 = 'declarations',
    W5 = 'limits', W6 = 'preprocessor',
}

-- O que vem depois de "expected " nas mensagens de sintaxe (parser.lua: EK, EKEY, EV, EM).
local SYNTAX = {
    { 'E2001', '`;´' },
    { 'E2002', '`)´' },
    { 'E2003', '`(´' },
    { 'E2004', '`,´' },
    { 'E2005', '`<´' },
    { 'E2006', '`>´' },
    { 'E2007', '`]´' },
    { 'E2008', '`do´' },
    { 'E2009', '`end´' },
    { 'E2010', '`from´' },
    { 'E2011', '`then´' },
    { 'E2012', '`with´' },
    { 'E2013', '`"´' },
    { 'E2020', 'expression' },
    { 'E2021', 'statement (not last statement as `return´ or `break´) ' },
    { 'E2022', 'event' },
    { 'E2023', 'variable/event' },
    { 'E2024', 'a not reserved identifier beginning with lower-case' },
    { 'E2025', 'identifier' },
    { 'E2026', 'identifier all upper-case' },
    { 'E2027', 'type' },
    { 'E2028', ' a valid basic type' },
    { 'E2029', ' a valid basic type/pointer or a register type' },
    { 'E2030', 'Config block declaration' },
    { 'E2031', 'a valid non pointer basic type or payload[n]' },
    { 'E2032', 'program block' },
    { 'E2033', 'a valid basic type or payload' },
    { 'E2040', 'a basic type' },
    { 'E2041', 'always `void´' },
    { 'E2042', 'a positive integer number' },
    { 'E2043', 'a valid function identifier' },
    { 'E2044', 'a valid identifier' },
    { 'E2045', 'config block + program' },
    { 'E2046', 'config NUM.NUM.NUM SIZE do ... end' },
    { 'E2047', 'expected EOF' },
    { 'E2048', '<h,min,s,ms>' },
    { 'E2049', '"name: xxxx"' },
    { 'E2050', '`ubyte´ or `void´ type' },
    { 'E2051', 'statement' },
    { 'E2052', 'declaration' },
    { 'E2053', 'variable' },
    { 'E2054', 'version identifier <num.num.num> ' },
    { 'E2055', '<h,min,s,ms,us>' },
    { 'E2056', 'config statement (usually a missing `input/output/function/regtype/packet´)' },
    { 'E2057', 'config statement (usually a missing `regtype varName with varDefs end´)' },
}

_DIAG.CATALOG = {
    -- E0 interno
    { 'E0001', 'error', 'internal compiler error: {lua}' },
    -- E1 entrada
    { 'E1001', 'error', 'missing input file' },
    { 'E1002', 'error', 'Invalid input file name. It needs a `.terra´ sufix.' },
    { 'E1003', 'error', 'File `{file}´ not found.' },
    { 'E1004', 'error', '{msg}' },
    { 'E1005', 'error', 'Preprocessor error!' },
    { 'E1006', 'error', 'invalid option `{option}´' },
    -- E2 sintaxe (os modelos E20xx-E205x são gerados de SYNTAX, abaixo)
    { 'E2000', 'error', '{where} `{token}´ : {expected}' },
    -- E3 nomes e declarações
    { 'E3001', 'error', 'variable/event/function "{name}" is not declared' },
    { 'E3002', 'error', 'event "{name}" is not declared' },
    { 'E3003', 'error', 'function "{name}" is not declared' },
    { 'E3004', 'error', 'C function "{name}" is not declared' },
    { 'E3005', 'error', 'C variable/function "{name}" is not declared' },
    { 'E3006', 'error', 'event "{name}" was previously declared at line {line}' },
    { 'E3007', 'error', 'var "{name}" was defined for same context at line {line}' },
    { 'E3008', 'error', 'undeclared type `{type}´' },
    { 'E3009', 'error', 'event "{name}" is already declared at line {line}' },
    { 'E3010', 'error', '{dir} event numeric id "{id}" is already in use at line {line}' },
    { 'E3011', 'error', 'function "{name}" is already declared at line {line}' },
    { 'E3012', 'error', ' function numeric id "{id}" is already in use at line {line}' },
    { 'E3013', 'error', 'duplicated field id `{name}´' },
    { 'E3014', 'error', 'Register type `{name}´ is already declared as Register.' },
    { 'E3015', 'error', 'Register type `{name}´ is already declared as Packet.' },
    { 'E3016', 'error', 'Packet type `{name}´ is already declared as Packet.' },
    { 'E3017', 'error', 'Packet type `{name}´ is already declared as Register.' },
    { 'E3018', 'error', 'Register type `{name}´ is already declared.' },
    { 'E3019', 'error', 'packet type `{name}´ is not defined.' },
    { 'E3020', 'error', 'type/packet not defined' },
    { 'E3021', 'error', 'event or function `{name}´ was not found.' },
    { 'E3022', 'error', 'var "{name}" is not a register. ' },
    { 'E3023', 'error', 'invalid field name' },
    -- E4 tipos e expressões
    { 'E4001', 'error', 'cannot instantiate type "{type}"' },
    { 'E4002', 'error', 'invalid array dimension' },
    { 'E4003', 'error', 'pointer "{name}" not initialized at this point.' },
    { 'E4004', 'error', 'invalid argument' },
    { 'E4005', 'error', 'invalid type' },
    { 'E4006', 'error', 'invalid pointer to pointer type' },
    { 'E4007', 'error', 'Arrays can have only basic types' },
    { 'E4008', 'error', 'Arrays can have only basic types.' },
    { 'E4009', 'error', 'packet needs exactly one `payload´ type, it received {count}' },
    { 'E4010', 'error', 'invalid function type "{type}"' },
    { 'E4011', 'error', '<{type}> in position {position} is invalid argument type in function <{function}>' },
    { 'E4012', 'error', 'register <{type}> in position {position} in function <{function}> can not be a pointer.' },
    { 'E4013', 'error', 'type/size incompatibility: {left} <--> {right}' },
    { 'E4014', 'error', 'type/size incompatibility: "{left}" <--> "{right}' },
    { 'E4015', 'error', 'type incompatibility: `{left}´ <--> `{right}´' },
    { 'E4016', 'error', 'invalid attribution: not a value' },
    { 'E4017', 'error', 'invalid attribution: not a numeric value' },
    { 'E4018', 'error', 'constant at left side of attribution.' },
    { 'E4019', 'error', 'VarAddr at left side of attribution.' },
    { 'E4020', 'error', '`{name}´ is a read only variable' },
    { 'E4021', 'error', 'cannot index a non array' },
    { 'E4022', 'error', 'invalid operands to binary "{op}"' },
    { 'E4023', 'error', 'invalid operand to unary "{op}"' },
    { 'E4024', 'error', 'invalid "inc/dec" target. Received a "{tag}" of type "{type}"' },
    { 'E4025', 'error', 'can not cast an address value' },
    { 'E4026', 'error', 'can not cast register types' },
    { 'E4027', 'error', 'strings are not allowed' },
    { 'E4028', 'error', 'malformed number' },
    { 'E4029', 'error', 'division by zero.' },
    { 'E4030', 'error', 'Invalid float operation.' },
    { 'E4031', 'error', 'invalid type. Expecting {expected} and received {received}' },
    { 'E4032', 'error', 'invalid type "{type}"' },
    { 'E4033', 'error', 'argument #{n} in function [{function}] must be compatible to "{expected}" type, it received "{received}" type' },
    { 'E4034', 'error', 'invalid number of arguments for function [{function}], received {received} and it was expecting {expected}' },
    -- E5 controle e contexto
    { 'E5001', 'error', 'tight loop' },
    { 'E5002', 'error', 'all trails must terminate' },
    { 'E5003', 'error', 'not permitted inside `finally´' },
    { 'E5004', 'error', 'not permitted inside `async´' },
    { 'E5005', 'error', 'not permitted outside `async´' },
    { 'E5006', 'error', 'break without loop' },
    { 'E5007', 'error', '`break´ without loop' },
    { 'E5008', 'error', '`return´ without block' },
    { 'E5009', 'error', 'invalid access from async' },
    { 'E5010', 'error', 'block at line {line} must contain `finally´' },
    { 'E5011', 'error', 'C calls are disabled' },
    { 'E5012', 'error', 'await expect an input event, a time expression, or a var event.' },
    { 'E5013', 'error', 'event {name} doesn´t expect any argument.' },
    { 'E5014', 'error', 'event {name} expect an `ubyte/byte´ argument.' },
    { 'E5015', 'error', 'emit expect an output event or a var event.' },
    { 'E5016', 'error', 'invalid input `emit´' },
    { 'E5017', 'error', 'missing parameters on `emit´' },
    { 'E5018', 'error', 'event type must be numeric' },
    { 'E5019', 'error', 'invalid statement' },
    -- E6 limites
    { 'E6001', 'error', 'array index out of range, 0..{max}.' },
    { 'E6002', 'error', 'max depth of 127' },
    { 'E6003', 'error', '{dir} event numeric id must be less than 255' },
    { 'E6004', 'error', ' function event numeric id must be less than 255' },
    { 'E6005', 'error', 'constant is out of range' },
    { 'E6006', 'error', 'subtype size {size} is  greater than payload size {max}' },
    { 'E6007', 'error', 'await time {ms} ms is above the maximum of {max} ms (about 24.8 days)' },
    -- E9 não implementado
    { 'E9001', 'error', 'Emit INPUT_EVENT inside Async is not implemented.' },
    { 'E9002', 'error', '"EmitT" is not implemented.' },
    { 'E9003', 'error', '"call" is not implemented! ' },
    -- W1 conversões
    { 'W1001', 'warning', 'Automatic casting from `{from}´ to `{to}´. ' },
    { 'W1002', 'warning', 'Discarding ineffective "cast" from {from} to {to}.' },
    { 'W1003', 'warning', 'Applying the minimum size: "{left}" <--> "{right}". ' },
    -- W2 não determinismo (o segundo ponto do programa vai em "related")
    { 'W2001', 'warning', 'nondeterminism (call conflict) : {a} vs {b}', { 'kind_a', 'name_a', 'line_a', 'kind_b', 'name_b', 'line_b' } },
    { 'W2002', 'warning', 'nondeterminism (weak call conflict) : {a} vs {b}', { 'kind_a', 'name_a', 'line_a', 'kind_b', 'name_b', 'line_b' } },
    { 'W2003', 'warning', 'nondeterminism (write conflict) : {a} vs {b}', { 'kind_a', 'name_a', 'line_a', 'kind_b', 'name_b', 'line_b' } },
    { 'W2004', 'warning', 'nondeterminism (weak write conflict) : {a} vs {b}', { 'kind_a', 'name_a', 'line_a', 'kind_b', 'name_b', 'line_b' } },
    { 'W2005', 'warning', 'nondeterminism (weak read conflict) : {a} vs {b}', { 'kind_a', 'name_a', 'line_a', 'kind_b', 'name_b', 'line_b' } },
    { 'W2006', 'warning', 'abortion : {a} vs {b}', { 'kind_a', 'name_a', 'line_a', 'kind_b', 'name_b', 'line_b' } },
    { 'W2007', 'warning', 'exception : line {line} vs {b}', { 'kind_b', 'name_b', 'line_b' } },
    -- W3 alcançabilidade
    { 'W3001', 'warning', 'statement is not reachable' },
    { 'W3002', 'warning', 'at least one trail should terminate' },
    { 'W3003', 'warning', 'trail should terminate' },
    { 'W3004', 'warning', 'missing `return´ statement for the block' },
    { 'W3005', 'warning', '`loop´ iteration is not reachable' },
    { 'W3006', 'warning', 'tight loop if an inner `loop´ with a variable count runs zero times' },
    -- W4 declarações
    { 'W4001', 'warning', 'declaration of "{name}" hides the one at line {line}' },
    { 'W4002', 'warning', 'event "{name}" without any await.' },
    -- W5 limites
    { 'W5001', 'warning', 'Float constant out of range, got: "{value}", value must range (+/-) 3.4E+38' },
    { 'W5002', 'warning', 'Integer constant too large, got: "{value}", max value must be (2^32)-1' },
    { 'W5003', 'warning', 'Please check the maximum program size for each mote type!' },
    -- W6 pré-processador
    { 'W6001', 'warning', '{msg}' },
}

-- Valores de kind_a/kind_b nos avisos W2xxx (acc.lua): extra_args, fora do texto da mensagem.
_DIAG.ACCESS_KINDS = { 'awake', 'escape', 'event', 'function', 'internal_event', 'par_enter',
                       'variable' }

_DIAG.BYCODE = {}
_DIAG.SYNTAX = {}       -- "expected X" -> código
for _, e in ipairs(SYNTAX) do
    local code, exp = e[1], e[2]
    _DIAG.SYNTAX['expected ' .. exp] = code
    table.insert(_DIAG.CATALOG, { code, 'error', '{where} `{token}´ : expected ' .. exp })
end
table.sort(_DIAG.CATALOG, function (a, b) return a[1] < b[1] end)
for _, e in ipairs(_DIAG.CATALOG) do
    assert(not _DIAG.BYCODE[e[1]], 'código repetido no catálogo: ' .. e[1])
    _DIAG.BYCODE[e[1]] = { code = e[1], severity = e[2], msg = e[3], extra = e[4] }
end

-- Texto da mensagem: o modelo do código com os args. Falta de um arg é erro do terrac (E0001).
function _DIAG.render (code, args)
    local e = assert(_DIAG.BYCODE[code], 'código de diagnóstico desconhecido: ' .. tostring(code))
    return (string.gsub(e.msg, '{(%w+)}', function (k)
        local v = args and args[k]
        assert(v ~= nil, 'diagnóstico ' .. code .. ' sem o argumento ' .. k)
        return tostring(v)
    end))
end

---------------------------------------------------------------------------------------------
-- JSON (só o necessário: chaves em ordem fixa, strings em UTF-8)

local function jstr (s)
    s = string.gsub(tostring(s), '[%c"\\]', function (c)
        local map = { ['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }
        return map[c] or string.format('\\u%04x', string.byte(c))
    end)
    return '"' .. s .. '"'
end

local jval
-- obj: lista de pares {chave, valor}; valores nil são omitidos
local function jobj (pairs_)
    local t = {}
    for _, kv in ipairs(pairs_) do
        if kv[2] ~= nil then
            t[#t+1] = jstr(kv[1]) .. ':' .. jval(kv[2])
        end
    end
    return '{' .. table.concat(t, ',') .. '}'
end
jval = function (v)
    local tp = type(v)
    if tp == 'string' then
        return jstr(v)
    elseif tp == 'number' then
        if v == math.floor(v) and math.abs(v) < 2^53 then
            return string.format('%d', v)
        end
        return string.format('%.14g', v)
    elseif tp == 'boolean' then
        return tostring(v)
    elseif tp == 'table' then
        if v.__obj then
            return jobj(v.__obj)
        end
        if #v > 0 or next(v) == nil then
            local t = {}
            for i, x in ipairs(v) do t[i] = jval(x) end
            return '[' .. table.concat(t, ',') .. ']'
        end
        -- tabela comum (args): chaves em ordem alfabética
        local ks = {}
        for k in pairs(v) do ks[#ks+1] = k end
        table.sort(ks)
        local kv = {}
        for i, k in ipairs(ks) do kv[i] = { k, v[k] } end
        return jobj(kv)
    end
    return 'null'
end
local function OBJ (pairs_) return { __obj = pairs_ } end
_DIAG.OBJ, _DIAG.jval = OBJ, jval

---------------------------------------------------------------------------------------------
-- Posição no fonte

-- coluna (em caracteres, base 1) da posição `pos` de _STR
local function utf8len (s)
    local n = 0
    for _ in string.gmatch(s, '[^\128-\191]') do n = n + 1 end
    return n
end
_DIAG.utf8len = utf8len

local function colOf (pos)
    local ls = pos
    while ls > 1 and string.sub(_STR, ls-1, ls-1) ~= '\n' do
        ls = ls - 1
    end
    return utf8len(string.sub(_STR, ls, pos-1)) + 1
end

-- a linha k de _STR que contém `pos`
local function kOf (pos)
    local _, n = string.gsub(string.sub(_STR, 1, pos-1), '\n', '')
    return n + 1
end

-- Local de um diagnóstico: `me` é um nó da AST (com .ln e, se veio do parser, .pos), um número
-- (só a linha) ou nil. Devolve line, col e, se o ponto está dentro de um #include, `include`.
-- `col` é a coluna no texto depois do cpp: igual à do fonte, salvo macro expandida antes dela.
local function where (me, pos)
    local ln = (type(me) == 'number' and me) or (me and me.ln)
    pos = pos or (type(me) == 'table' and me.pos)
    if pos and _STR and _I2L and _I2L[pos] ~= ln then
        pos = nil           -- nó copiado para outra linha: a posição não vale
    end
    if ln == 0 then
        pos = nil           -- o programa todo (nó raiz): sem coluna
    end
    local r = { line = ln }
    if pos and _STR then
        local k = kOf(pos)
        local real = _SRCREAL and _SRCREAL[k]
        local col = colOf(pos)
        if real and real.file ~= _OPTS.input then
            r.include = OBJ{ {'file', real.file}, {'line', real.line}, {'col', col} }
        else
            r.col = col
        end
    end
    return r
end
_DIAG.where = where

---------------------------------------------------------------------------------------------
-- Saída

function _DIAG.emit (code, me, args, opt)
    opt = opt or {}
    local e = assert(_DIAG.BYCODE[code], 'código de diagnóstico desconhecido: ' .. tostring(code))
    local msg = _DIAG.render(code, args)
    local isErr = (e.severity == 'error')
    if isErr then
        _DIAG.errors = _DIAG.errors + 1
    else
        _DIAG.warnings = _DIAG.warnings + 1
    end
    if not _DIAG.json then
        local ln = (type(me) == 'number' and me) or (me and me.ln)
        if opt.text then
            io.stderr:write(opt.text)
        elseif isErr then
            io.stderr:write('ERR : line ' .. tostring(ln) .. ' : ' .. msg .. '\n')
        elseif me then
            io.stderr:write('WRN : line ' .. tostring(ln) .. ' : ' .. msg .. '\n')
        else
            io.stderr:write('WRN : ' .. msg .. '\n')
        end
        return
    end
    local w = opt.loc or where(opt.at or me, opt.pos)
    local related
    if opt.related then
        related = {}
        for _, n in ipairs(opt.related) do
            local r = where(n)
            if r.line then
                related[#related+1] = OBJ{ {'file', opt.file or _OPTS.input}, {'line', r.line},
                                           {'col', r.col}, {'include', r.include} }
            end
        end
        if #related == 0 then related = nil end
    end
    -- só os argumentos do modelo e os extra_args do catálogo (conferido nos testes)
    for k in pairs(args or {}) do
        assert(string.find(e.msg, '{' .. k .. '}', 1, true) or
               (e.extra and table.concat(e.extra, ' '):find('%f[%w_]' .. k .. '%f[^%w_]')),
               'diagnóstico ' .. code .. ' com argumento fora do catálogo: ' .. k)
    end
    local hasArgs = args and next(args) ~= nil
    io.stderr:write(jval(OBJ{
        {'code', code},
        {'severity', e.severity},
        {'file', opt.file or _OPTS.input},
        {'line', w.line},
        {'col', w.col},
        {'col_end', w.col and opt.col_end},
        {'msg', msg},
        {'args', hasArgs and args or nil},
        {'include', w.include},
        {'related', related},
    }) .. '\n')
end

-- Resumo final (só no modo JSON): sempre a última linha do stderr.
function _DIAG.summary ()
    if not _DIAG.json or _DIAG.summary_done then
        return
    end
    _DIAG.summary_done = true
    local vm
    if _ENV and _ENV.vm_name then
        vm = OBJ{ {'name', _ENV.vm_name}, {'version', _ENV.vm_version} }
    end
    local ok = (_DIAG.errors == 0)
    local m = ok and _DIAG.memory or nil       -- com erro, sem memória nem plataformas
    io.stderr:write(jval(OBJ{ {'summary', OBJ{
        {'ok', ok},
        {'errors', _DIAG.errors},
        {'warnings', _DIAG.warnings},
        {'optimized', _OPTS.opt and true or false},
        {'vm', vm},
        {'memory', m and OBJ{ {'total', m.total}, {'code', m.code}, {'ctl_vars', m.ctl_vars},
                              {'stack', m.stack}, {'radio_msgs', m.radio_msgs} }},
        {'platforms', ok and _DIAG.platforms or nil},
    }} }) .. '\n')
end

function _DIAG.exit (status)
    _DIAG.summary()
    os.exit(status)
end

-- Erro do aluno (ou de entrada): emite e encerra.
function ASR (cond, me, code, args, opt)
    if not cond then
        if not _CEU then
            error('ERR : line ' .. tostring((type(me) == 'number' and me) or me.ln) ..
                  ' : ' .. _DIAG.render(code, args))
        end
        _DIAG.emit(code, me, args, opt)
        _DIAG.exit(1)
    end
    return cond
end

-- Aviso: emite se `cond` é falso e os avisos estão ligados.
function WRN (cond, me, code, args, opt)
    if not cond and _OPTS.warn then
        _DIAG.emit(code, me, args, opt)
        _WRN.n_wrns = _WRN.n_wrns + 1
    end
    return cond
end

-- Catálogo em JSON (`terrac --catalog`): o anexo terrac-errors-<versão>.json da release.
function _DIAG.catalog ()
    local codes = {}
    for _, e in ipairs(_DIAG.CATALOG) do
        local args = {}
        for k in string.gmatch(e[3], '{(%w+)}') do args[#args+1] = k end
        codes[#codes+1] = OBJ{ {'code', e[1]}, {'severity', e[2]},
                               {'group', _DIAG.GROUPS[string.sub(e[1], 1, 2)]},
                               {'msg', e[3]}, {'args', args}, {'extra_args', e[4]} }
    end
    local groups = {}
    local gk = {}
    for k in pairs(_DIAG.GROUPS) do gk[#gk+1] = k end
    table.sort(gk)
    for _, k in ipairs(gk) do groups[#groups+1] = OBJ{ {'prefix', k}, {'name', _DIAG.GROUPS[k]} } end
    return jval(OBJ{ {'format', 1}, {'groups', groups}, {'access_kinds', _DIAG.ACCESS_KINDS},
                     {'codes', codes} }) .. '\n'
end
