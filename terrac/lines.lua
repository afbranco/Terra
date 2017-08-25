--[[
Copyright (C) 2012 Francisco Sant'Anna

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

--m = require 'lpeg_0_10_2_1-lpeg'
m = require 'lpeg'

print(m.version())

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

function WRN (cond, me, msg)
    local ln = (me and ((type(me)=='number' and me) or me.ln) or 0)
    if not cond  and _OPTS.warn then
      if me then
        DBG('WRN : line '..ln..' : '..msg)
      else
        DBG('WRN : '..msg)
      end
        _WRN.n_wrns = _WRN.n_wrns + 1;
    end
    return cond
end
function ASR (cond, me, msg)
    local ln = (type(me)=='number' and me) or me.ln
    if _CEU then
        if not cond then
            DBG('ERR : line '..ln..' : '..msg)
            os.exit(1)
        end
        return cond
    else
        return assert(cond, 'ERR : line '..ln..' : '..msg)
    end
end

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
local line = m.Cmt('\n',
    function (s,i)
        for i=#_I2L, i do
            _I2L[i] = LINE
        end
        if CNT > 0 then
            LINE = LINE + 1
        end
    end )

local patt = (line + open + close + 1)^0
patt:match(_STR..'\n')
