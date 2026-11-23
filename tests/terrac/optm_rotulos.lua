-- Teste do otimizador do terrac (optm.lua, #22): depois da otimização, todo rótulo usado tem
-- de levar à mesma instrução que antes. O destino efetivo de um rótulo é a primeira instrução a
-- partir dele, pulando os '_' (removidos) e outros rótulos e seguindo os `exec`; um `end` vale
-- como qualquer outro `end`.
--   lua5.1 tests/terrac/optm_rotulos.lua <pasta terrac>
local dir = assert(arg[1], 'uso: optm_rotulos.lua <pasta terrac>')

opcode = { op_end = 1, op_exec = 56, op_push_c = 64, op_deref = 112, op_push_v = 144 }

-- código: lista de instruções; cada uma é { 'mnemônico', bytes... } ou 'L<n>' (rótulo)
local function asm (prog)
    local op, c2 = {}, {}
    for _, ins in ipairs(prog) do
        if type(ins) == 'string' then
            op[#op+1] = string.format('L%04x', tonumber(string.sub(ins, 2)))
        else
            local m = ins[1]
            if m == 'exec' then
                op[#op+1] = string.format('%02x', opcode.op_exec + 1)
                c2[#op] = 'exec'
                op[#op+1] = string.format('.%02x', math.floor(ins[2] / 256))
                op[#op+1] = string.format('.%02x', ins[2] % 256)
            elseif m == 'end' then
                op[#op+1] = '01'; c2[#op] = 'end'
            elseif m == 'ifelse' then      -- ifelse Lt Lf (76 + flags de 2 bytes)
                op[#op+1] = string.format('%02x', 76 + 3); c2[#op] = 'ifelse'
                for _, l in ipairs{ ins[2], ins[3] } do
                    op[#op+1] = string.format('.%02x', math.floor(l / 256))
                    op[#op+1] = string.format('.%02x', l % 256)
                end
            else                            -- outra instrução de 1 byte (ex.: 'nop')
                op[#op+1] = '29'; c2[#op] = m
            end
        end
    end
    return op, c2
end

local function labels (op)
    local pos = {}
    for x, o in ipairs(op) do
        if string.sub(o, 1, 1) == 'L' then pos[tonumber('0x' .. string.sub(o, 2))] = x end
    end
    return pos
end

-- destino efetivo do rótulo `l` (índice da instrução, ou 'end')
local function dest (op, pos, l, seen)
    seen = seen or {}
    if seen[l] then return 'ciclo' end
    seen[l] = true
    local x = assert(pos[l], 'rótulo inexistente: ' .. l) + 1
    while op[x] and (op[x] == '_' or string.sub(op[x], 1, 1) == 'L') do x = x + 1 end
    if not op[x] then return 'fim' end
    local n = tonumber('0x' .. op[x])
    if n == opcode.op_end then return 'end' end
    if n == opcode.op_exec + 1 then
        local t = tonumber('0x' .. string.sub(op[x+1], 2)) * 256 + tonumber('0x' .. string.sub(op[x+2], 2))
        return dest(op, pos, t, seen)
    end
    return x
end

-- rótulos referenciados nas instruções que sobraram ('.hh' '.ll')
local function refs (op)
    local r, h = {}, nil
    for _, o in ipairs(op) do
        if string.sub(o, 1, 1) == '.' then
            if h then r[#r+1] = h * 256 + tonumber('0x' .. string.sub(o, 2)); h = nil
            else h = tonumber('0x' .. string.sub(o, 2)) end
        end
    end
    return r
end

local fail = 0
local function caso (nome, prog)
    local op, c2 = asm(prog)
    local pos = labels(op)
    local antes = {}
    for l in pairs(pos) do antes[l] = dest(op, pos, l) end
    _AST = { root = { opcode = op, code2 = c2 } }
    dofile(dir .. '/optm.lua')
    local ok = true
    for _, l in ipairs(refs(op)) do
        local d = dest(op, pos, l)
        if d ~= antes[l] then
            ok = false
            print(string.format('optm: %s: o rótulo %d levava a %s e passou a levar a %s',
                                nome, l, tostring(antes[l]), tostring(d)))
        end
    end
    print('optm: ' .. nome .. ': ' .. (ok and 'ok' or 'ERRADO'))
    if not ok then fail = 1 end
end

-- Dois rótulos no mesmo endereço, seguidos de `exec`: os dois têm de ir para o L3.
caso('dois rótulos antes de exec', {
    { 'ifelse', 1, 2 },
    'L1', 'L2', { 'exec', 3 },
    { 'nop' }, { 'end' },
    'L3', { 'nop' }, { 'end' },
})
-- O mesmo, com a ordem dos rótulos trocada e um terceiro rótulo.
caso('três rótulos antes de exec', {
    { 'ifelse', 5, 4 }, { 'exec', 6 },
    'L4', 'L5', 'L6', { 'exec', 7 },
    { 'nop' }, { 'end' },
    'L7', { 'nop' }, { 'end' },
})
-- Cadeia de exec (o caso que o optm já tratava) e exec para um end.
caso('cadeia de exec', {
    { 'ifelse', 8, 9 },
    'L8', { 'exec', 9 },
    'L9', { 'exec', 10 },
    'L10', { 'nop' }, { 'exec', 11 },
    'L11', { 'end' },
})
os.exit(fail)
