m = require 'lpeg'

m.setmaxstack(1000)

function DBG (...)
    local t = {}
    for i=1, select('#',...) do
        t[#t+1] = tostring( select(i,...) )
    end
    if #t == 0 then
        t = { [1]=debug.traceback() }
    end
    io.stderr:write(table.concat(t,'\t')..'\n')
end

function MAX (v1, v2)
    return (v1 > v2) and v1 or v2
end

-- ASR e WRN estão em errors.lua (códigos de diagnóstico, #24).

_I2L = {}

local CNT = 1
local open = m.Cmt('/*{-{*/',
    function ()
        if _OPTS.join then
            CNT = CNT - 1
        end
    end )
local close = m.Cmt('/*}-}*/',
    function ()
        if _OPTS.join then
            CNT = CNT + 1
        end
    end )

local LINE = 1
local K = 1         -- a linha de _STR; _SRCLINE[K] é a linha no programa (terrac.lua)
local line = m.Cmt('\n',
    function (s,i)
        for i=#_I2L, i do
            _I2L[i] = (_SRCLINE and _SRCLINE[K]) or LINE
        end
        K = K + 1
        if CNT > 0 then
            LINE = LINE + 1
        end
    end )

local patt = (line + open + close + 1)^0
patt:match(_STR..'\n')
