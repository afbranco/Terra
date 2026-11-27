-- Compila os exemplos Terra das páginas do docs/ (#91).
--
-- Cada bloco ```terra de uma página tem de vir logo depois de um comentário
--   <!-- check: ok -->          compila sem erro e sem aviso (com o TerraNet.defs)
--   <!-- check: ok grp -->      idem, com o TerraGrp.defs
--   <!-- check: W2001 -->       compila e dá esse código (erro ou aviso); "grp" no fim vale também
--   <!-- check: skip -->        não compila (esboço de sintaxe, com <block> etc.)
-- O programa compilado é o bloco com `#include "TerraNet.defs"` (ou Grp) antes.
--
-- Uso: lua5.1 checkexamples.lua <terrac> <pasta com os .defs> <página.md>...
-- Sai com 1 se algum exemplo não der o esperado ou se algum bloco terra não tiver o comentário.

local terrac, defsdir = arg[1], arg[2]
local tmp = os.tmpname()
os.remove(tmp)
assert(os.execute('mkdir -p ' .. tmp) == 0)
for _, d in ipairs({ 'TerraNet.defs', 'TerraGrp.defs' }) do
    assert(os.execute(string.format('cp %q/%s %q/', defsdir, d, tmp)) == 0, 'sem ' .. d)
end

local falhas, total, pulados = 0, 0, 0
local function falha(onde, msg)
    falhas = falhas + 1
    io.write('FALHOU ', onde, ': ', msg, '\n')
end

local function compila(code, grp)
    local f = assert(io.open(tmp .. '/ex.terra', 'w'))
    f:write('#include "', grp and 'TerraGrp.defs' or 'TerraNet.defs', '"\n', code)
    f:close()
    -- <terrac> é o script (roda com o lua5.1) ou o comando: "lua5.1 /x/terrac" ou o executável (#95)
    local tc = string.find(terrac, ' ') and terrac or ('lua5.1 ' .. string.format('%q', terrac))
    if not string.find(terrac, ' ') and io.open(terrac) and io.open(terrac):read(2) == '\127E' then
        tc = string.format('%q', terrac)
    end
    local cmd = string.format('cd %q && %s --diag=json ex.terra 2> ex.err > /dev/null', tmp, tc)
    os.execute(cmd)
    local codes, txt = {}, ''
    for l in io.lines(tmp .. '/ex.err') do
        txt = txt .. l .. '\n'
        local c = string.match(l, '^{"code":"(%w+)"')
        if c then codes[#codes + 1] = c end
    end
    return codes, txt
end

for i = 3, #arg do
    local pag = arg[i]
    local n, spec, inblock, buf, ini = 0, nil, false, nil, 0
    for l in io.lines(pag) do
        n = n + 1
        if inblock then
            if string.match(l, '^```%s*$') then
                inblock = false
                local onde = pag .. ':' .. ini
                if not spec then
                    falha(onde, 'bloco terra sem <!-- check: ... -->')
                elseif spec == 'skip' then
                    pulados = pulados + 1
                else
                    total = total + 1
                    local esperado, grp = string.match(spec, '^(%w+)%s*(%a*)$')
                    if not esperado or (grp ~= '' and grp ~= 'grp') then
                        falha(onde, 'check inválido: ' .. spec)
                    else
                        local codes, txt = compila(table.concat(buf, '\n') .. '\n', grp == 'grp')
                        if esperado == 'ok' then
                            if #codes > 0 then falha(onde, 'esperava ok, deu ' .. table.concat(codes, ' ') .. '\n' .. txt) end
                        else
                            local achou = false
                            for _, c in ipairs(codes) do achou = achou or c == esperado end
                            if not achou then falha(onde, 'esperava ' .. esperado .. ', deu ' .. (#codes > 0 and table.concat(codes, ' ') or 'ok') .. '\n' .. txt) end
                        end
                    end
                end
                spec = nil
            else
                buf[#buf + 1] = l
            end
        else
            local s = string.match(l, '^<!%-%- check: (.-) %-%->%s*$')
            if s then
                spec = s
            elseif string.match(l, '^```terra%s*$') then
                inblock, buf, ini = true, {}, n
            elseif l ~= '' then
                spec = nil   -- o comentário vale só para o bloco logo abaixo
            end
        end
    end
end
os.execute(string.format('rm -rf %q', tmp))
io.write(string.format('checkexamples: %d exemplos compilados, %d esboços: %s\n', total, pulados,
    falhas == 0 and 'OK' or (falhas .. ' falhas')))
os.exit(falhas == 0 and 0 or 1)
