-- Confere o catálogo de diagnósticos do terrac (#24):
--   * toda mensagem de sintaxe que o parser.lua pode dar (EK, EV/_V2NAME, EM) tem código próprio;
--   * todo código usado nos fontes (ASR/WRN/emit) está no catálogo, e todo código do catálogo
--     é usado em algum lugar (salvo os gerados de SYNTAX, conferidos acima).
--   lua5.1 tests/terrac/catalogo.lua <pasta terrac>
local dir = assert(arg[1], 'uso: catalogo.lua <pasta terrac>')
_OPTS = {}
dofile(dir .. '/errors.lua')

local fail = 0
local function bad (s) io.stderr:write('catalogo: ' .. s .. '\n'); fail = 1 end
local function read (f) return (assert(io.open(dir .. '/' .. f)):read('*a'):gsub('\r', '')) end

-- 1. mensagens de sintaxe
local p = read('parser.lua')
local exp = {}
for tk in string.gmatch(p, "EK[EY]*%s*%(?'([^']*)'") do exp['expected `' .. tk .. '´'] = true end
for tk in string.gmatch(p, 'EK[EY]*%s*%(?"([^"]*)"') do exp['expected `' .. tk .. '´'] = true end
local v2 = string.match(p, '_V2NAME = (%b{})')
for line in string.gmatch(v2, '[^\n]+') do
    if not string.match(line, '^%s*%-%-') then
        local v = string.match(line, "=%s*'(.*)',")
        if v then exp['expected ' .. v] = true end
    end
end
for m in string.gmatch(p, "EM%s*%(?'([^']*)'") do exp['expected ' .. m] = true end
for m in string.gmatch(p, 'EM%s*%(?"([^"]*)"') do exp['expected ' .. m] = true end
local n = 0
for e in pairs(exp) do
    n = n + 1
    if not _DIAG.SYNTAX[e] then bad('mensagem de sintaxe sem código: ' .. e) end
end
for e, c in pairs(_DIAG.SYNTAX) do
    if not exp[e] then bad('código de sintaxe que o parser não gera: ' .. c .. ' ' .. e) end
end

-- 2. códigos usados nos fontes
local used = {}
for _, f in ipairs{ 'acc.lua', 'ana.lua', 'ast.lua', 'code.lua', 'env.lua', 'mem.lua',
                    'props.lua', 'tight.lua', 'tp.lua', 'terrac.lua', 'parser.lua' } do
    local s = read(f)
    for line in string.gmatch(s, '[^\n]+') do
        if not string.match(line, '^%s*%-%-') then
            for c in string.gmatch(line, "'([EW]%d%d%d%d)'") do used[c] = true end
        end
    end
end
for c in pairs(used) do
    if not _DIAG.BYCODE[c] then bad('código usado e fora do catálogo: ' .. c) end
end
local gen = {}
for _, c in pairs(_DIAG.SYNTAX) do gen[c] = true end
for _, e in ipairs(_DIAG.CATALOG) do
    if not used[e[1]] and not gen[e[1]] and e[1] ~= 'E2000' then
        bad('código do catálogo sem uso: ' .. e[1])
    end
end
-- 3. tipos de acesso dos W2xxx (kind_a/kind_b)
local kinds = {}
for _, k in ipairs(_DIAG.ACCESS_KINDS) do kinds[k] = true end
local acc = read('acc.lua')
for k in string.gmatch(acc, "kind = %(?[^\n]-'([%w_]+)'") do
    if not kinds[k] then bad('tipo de acesso fora de ACCESS_KINDS: ' .. k) end
end
for k in string.gmatch(acc, "or '([%w_]+)'%), name") do
    if not kinds[k] then bad('tipo de acesso fora de ACCESS_KINDS: ' .. k) end
end

print(string.format('catalogo: %d códigos, %d mensagens de sintaxe conferidas', #_DIAG.CATALOG, n))
os.exit(fail)
