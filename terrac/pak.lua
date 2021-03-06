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

fout = assert(io.open('terrac','w'))
fin  = assert(io.open'terrac.lua'):read'*a'

function subst (name)
    local s, e = string.find(fin, "dofile '"..name.."'")
    fin = string.sub(fin, 1, (s-1)) ..
            '\ndo\n' ..
                assert(io.open(name)):read'*a' ..
            '\nend\n' ..
          string.sub(fin, (e+1))
end

subst 'tp.lua'
subst 'lines.lua'
subst 'parser.lua'
subst 'ast.lua'
subst 'env.lua'
subst 'props.lua'
subst 'mem.lua'
subst 'tight.lua'
subst 'labels.lua'
subst 'ana.lua'
subst 'acc.lua'
subst 'asm.lua'
subst 'code.lua'
subst 'optm.lua'

-- template.c
--do
--    local tpl = assert(io.open'template.c'):read'*a'
--
--    local s, e = string.find(fin, "assert%(io%.open'template%.c'%):read'%*a'")
--    fin = string.sub(fin, 1, (s-1))
--            .. "[===[" .. tpl .. "]===]" ..
--          string.sub(fin, (e+1))
--end

fout:write([=[
#!/usr/bin/env lua

--[[
-- This file is automatically generated.
-- Check the github repository for a readable version:
-- http://github.com/fsantanna/ceu
--
-- Céu is distributed under the MIT License:
--

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

--
--]]

]=] .. fin)

fout:close()
os.execute('chmod +x terrac')
