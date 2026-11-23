-- Confere que o modo texto e o --diag=json dizem o mesmo (#24): para cada linha
-- "ERR : line N : msg" ou "WRN : line N : msg" do texto, o diagnóstico JSON de mesma ordem
-- tem o mesmo line e msg; e o JSON termina com uma única linha de resumo.
--   lua5.1 consistencia.lua <stderr do modo texto> <stderr do --diag=json>
local function lines (f)
    local t = {}
    for l in io.lines(f) do t[#t+1] = l end
    return t
end
local function jmsg (l)
    local m = string.match(l, '"msg":"(.-[^\\])"') or string.match(l, '"msg":""') and ''
    m = string.gsub(m, '\\(.)', { ['"']='"', ['\\']='\\', n='\n', t='\t' })
    return m
end
local txt, js = lines(arg[1]), lines(arg[2])
local fail = 0
local function bad (s) io.stderr:write('consistencia: ' .. s .. '\n'); fail = 1 end

local diags = {}
for i, l in ipairs(js) do
    if string.match(l, '^{"summary":') then
        if i ~= #js then bad('o resumo não é a última linha') end
    elseif string.match(l, '^{"code":"[EW]%d%d%d%d"') then
        diags[#diags+1] = l
    else
        bad('linha que não é diagnóstico nem resumo: ' .. l)
    end
end
if not string.match(js[#js] or '', '^{"summary":') then bad('falta o resumo') end

local k = 0
for _, l in ipairs(txt) do
    local kind, ln, msg = string.match(l, '^(%u%u%u) : line (%-?%d+) : (.*)$')
    if not kind then
        kind, msg = string.match(l, '^(WRN) : (.*)$')
    end
    if kind == 'ERR' or kind == 'WRN' then
        k = k + 1
        local d = diags[k]
        if not d then
            bad('o texto tem mais diagnósticos que o JSON: ' .. l)
        else
            local sev = string.match(d, '"severity":"(%a+)"')
            if (kind == 'ERR') ~= (sev == 'error') then bad('severidade: ' .. l .. ' / ' .. d) end
            local jl = string.match(d, '"line":(%-?%d+)')
            -- sem "line" no JSON: diagnóstico do programa todo (W5003); no texto a linha é a
            -- do nó raiz, que depende do cpp
            if ln and jl and jl ~= ln then bad('linha: ' .. l .. ' / ' .. d) end
            if not jl and not string.match(d, '"code":"W5003"') then bad('sem linha: ' .. d) end
            if jmsg(d) ~= msg then bad('mensagem: ' .. l .. ' / ' .. d) end
        end
    end
end
if k < #diags then
    -- só os do cpp (E1004/W6001) aparecem no texto em outro formato
    for i = k + 1, #diags do
        local c = string.match(diags[i], '"code":"(%w+)"')
        if c ~= 'E1004' and c ~= 'W6001' then bad('só no JSON: ' .. diags[i]) end
    end
end
os.exit(fail)
