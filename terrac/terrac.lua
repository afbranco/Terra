_CEU = true

_OPTS = {
    input     = nil,
    output    = '_ceu_code.cterra',
    output2   = '_ceu_opcode.vmx',

    opt       = true,
    join      = true,
    warn      = true,
    wstrong   = true,
    wweak     = false,
    includePath="",

}

_OPTS_NPARAMS = {
    input     = nil,
    output    = 1,

    opt       = 0,
    join      = 0,
    warn      = 0,
    wstrong   = 0,
    wweak     = 0,
}

function trim (s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local params = {...}
local i = 1
--print("terrac::params:",#params)
while i <= #params
do
    local p = params[i]

--print("terrac::param:",params[i])
    if p:sub(1,2) == '-I' then
        _OPTS.includePath = _OPTS.includePath .. " ".. p

    elseif p == '-' then
        _OPTS.input = '-'

    elseif string.sub(p, 1, 2) == '--' then
        local no = false
        local opt = string.gsub(string.sub(p,3), '%-', '_')
        if string.find(opt, '^no_') then
            no = true
            opt = string.sub(opt, 4)
        end
        if _OPTS[opt]==nil then
          _OPTS.input = nil
          break
        end
        if _OPTS_NPARAMS[opt] == 0 then
            _OPTS[opt] = not no
        else
            local opt = string.gsub(string.sub(p,3), '%-', '_')
            _OPTS[opt] = string.match(params[i], "%'?(.*)%'?")
            --i = i + 1
        end

    else
        _OPTS.input = p
    end
    i = i + 1
end

--os.exit(0)

if not _OPTS.input then
    io.stderr:write([[

    ./terrac <filename>          # Terra input file, or `-´ for stdin
        --output <filename>      # vmx output file (input.vmx)
        --join    (--no-join)    # join lines enclosed by /*{-{*/ and /*}-}*/ (join)
        --opt     (--no-opt)     # activate code optimization (opt)
        --warn    (--no-warn)    # activate warnings (warn)
        --wstrong (--no-wstrong) # warning strong nondeterminism (wstrong)
        --wweak   (--no-wweak)   # warning weak nondeterminism (no-wweak)
        -Ipath                   # Path for include files (.defs)
]])
    os.exit(1)
end
if not string.match(_OPTS.input, "(.*)%.terra") then 
  io.stderr:write([[
  Invalid input file name. It needs a `.terra´ sufix.
  
]])
  os.exit(1)
end

local test_file = io.open(_OPTS.input)
if  test_file then
   io.close(test_file)
else
  io.stderr:write([[
  File `]].. _OPTS.input .. [[´ not found.
  
]])
  os.exit(1)
end


local cpp_file = 'precomp.terra'
-- Pre-processor phase
--    local cpp = assert(io.popen('cpp -C '.._OPTS.input..' ' ..cpp_file, 'w'))
    local cpp = assert(io.popen('cpp -C '.._OPTS.input..' ' ..cpp_file .. _OPTS.includePath, 'w'))
    cpp:close()

local test_file = io.open(cpp_file)
if  test_file then
   io.close(test_file)
else
  io.stderr:write([[
  Preprocessor error!
  
]])
  os.exit(1)
end


-- INPUT
local inp
--inp = io.stdin
--inp = assert(io.open(cpp_file))
--_STR = inp:read'*a'
_STR=""

-- Remove '#' lines generated from cpp
for line in io.lines(cpp_file) do
--  print(string.sub(line,1,1))
  if string.sub(line,1,1) ~= '#' then
    _STR = _STR..line..'\n'
  end
end
os.remove(cpp_file)

-- PARSE
do
    dofile 'tp.lua'
    dofile 'lines.lua'
    dofile 'parser.lua'
    dofile 'ast.lua'
    dofile 'env.lua'
--    _AST.dump(_AST.root)
    dofile 'props.lua'
    dofile 'ana.lua'
    dofile 'acc.lua'
--print(print_r(_AST.root,"terrac: root"))
    dofile 'mem.lua'
    dofile 'tight.lua'
    dofile 'labels.lua'
--os.exit()
--    _AST.dump(_AST.root)
--print(print_r(_AST.root,"terrac: root"))
    dofile 'asm.lua'
    dofile 'code.lua'
--    _AST.dump(_AST.root)
end

local tps = { [1]='ubyte', [2]='ushort', [4]='ulong' }

local ALL = {
    n_tracks = _AST.root.n_tracks, --_ANALYSIS.n_tracks,
    n_mem = _MEM.max,
    tceu_noff = tps[_ENV.c.tceu_noff.len],
    tceu_nlbl = tps[MAX(_ENV.c.tceu_nlbl.len,_ENV.c.tceu_noff.len)],
}

assert(_MEM.max < 2^(_ENV.c.tceu_noff.len*8))

-- TEMPLATE
local tpl
do
--    tpl = assert(io.open'template.c'):read'*a'
--
--    local sub = function (str, from, to)
--        local i,e = string.find(str, from)
--        return string.sub(str, 1, i-1) .. to .. string.sub(str, e+1)
--    end
--
--    tpl = sub(tpl, '=== N_TRACKS ===',  ALL.n_tracks)
--    tpl = sub(tpl, '=== N_MEM ===',     ALL.n_mem)
--
--    --afb tpl = sub(tpl, '=== HOST ===',      (_OPTS.analysis_run and '') or _CODE.host)
--    tpl = sub(tpl, '=== CODE ===',      _AST.root.code)
--
--    -- lbl >= off (EMITS)
--    --afb tpl = sub(tpl, '=== TCEU_OFF ===',  ALL.tceu_noff)
--    --afb tpl = sub(tpl, '=== TCEU_LBL ===',  ALL.tceu_nlbl)
--
--    -- GTES
--    tpl = sub(tpl, '=== CEU_WCLOCK0 ===', _MEM.gtes.wclock0)
--    tpl = sub(tpl, '=== CEU_ASYNC0 ===',  _MEM.gtes.async0)

    -- LABELS
    --afb tpl = sub(tpl, '=== N_LABELS ===', #_LABELS.list)
    --afb tpl = sub(tpl, '=== LABELS ===',   _LABELS.code)

    -- DEFINITIONS: constants & defines
    do
        -- EVENTS
        local str = ''
        local t = {}
        local outs = 0
        local ins  = {}
        for _, ext in ipairs(_ENV.exts) do
            if ext.pre == 'input' then
                --str = str..'#define IN_'..ext.id..' '.._MEM.gtes[ext.n]..'\n'
                ins[#ins+1] = _MEM.gtes[ext.n]
--print("terrac:: evts:",ext.id,ext.idx,_ENV.awaits[ext] or 0)
                if ((_ENV.awaits[ext] or 0) > 0) then
                  _ENV.n_ins_active = _ENV.n_ins_active + 1;
                end
            else
                --str = str..'#define OUT_'..ext.id..' '..ext.seq..'\n'
                outs = outs + 1
            end
        end
        _ENV.n_ins = #ins
        _ENV.n_outs = outs
        --str = str..'#define OUT_n '..outs..'\n'
        if _OPTS.analysis_run then
            --str = str..'#define IN_n '..#ins..'\n'
            --str = str .. 'short IN_vec[] = { '..table.concat(ins,',')..' };\n'
        end

        -- FUNCTIONS called
        for id in pairs(_ENV.calls) do
            if id ~= '$anon' then
                --str = str..'#define FUNC'..id..'\n'
            end
        end

        -- DEFINES
        if _PROPS.has_exts then
            --str = str .. '#define CEU_EXTS\n'
            ALL.exts = true
        end
        if _PROPS.has_wclocks then
            --str = str .. '#define CEU_WCLOCKS '.._ENV.n_wclocks..'\n'
            ALL.wclocks = true
        end
        if _PROPS.has_asyncs then
            --str = str .. '#define CEU_ASYNCS '.._ENV.n_asyncs..'\n'
            ALL.asyncs = true
        end
        if _PROPS.has_emits then
            --str = str .. '#define CEU_STACK\n'
            ALL.emits = true
        end
--        if _ANALYSIS.needsTree then
--            str = str .. '#define CEU_TREE\n'
--            ALL.tree = true
--        end
--        if _ANALYSIS.needsChk then
--            str = str .. '#define CEU_TREE_CHECK\n'
--            ALL.chk = true
--        end

        if _OPTS.defs_file then
            --local f = io.open(_OPTS.defs_file,'w')
            --f:write(str)
            --f:close()
            --afb tpl = sub(tpl, '=== DEFS ===','#include "'.. _OPTS.defs_file ..'"')
        else
            --afb tpl = sub(tpl, '=== DEFS ===', str)
        end
    end
end

-- outputs compilation parameters
local t = {}
for k,v in pairs(ALL) do
    if v == true then
        t[#t+1] = k
    else
        t[#t+1] = k..'='..v
    end
end
table.sort(t)
--DBG('[ '..table.concat(t,' | ')..' ]')
--[[
]]

-- OUTPUT
local out
if _OPTS.output == '-' then
--    out = io.stdout
else
--    out = assert(io.open(_OPTS.output,'w'))
end
--out:write(tpl)

-- run code optimization routine
do
  if _OPTS.opt then
    dofile 'optm.lua'
  end
end
-- Count Opcode address
_AST.root.op_addr={}

codeAddr = ((ALL.n_tracks+1)*4) + ALL.n_mem
--print("terrac:: n_tracks=",ALL.n_tracks)

pos = codeAddr
nLbl=0
for x,op in ipairs(_AST.root.opcode) do
--print(x,op)
  _AST.root.op_addr[x]=pos
  if string.sub(op,1,1) ~= '_' then
    if string.sub(op,1,1) ~= 'L'  then 
      pos = pos + 1
    else
      nLbl=nLbl+1
    end 
  end
end
endCode = pos;



-- build Label x Addr Table
_AST.root.labeltable={}
for x,op in ipairs(_AST.root.opcode) do
	if (string.sub(op,1,1) == 'L') then 
--print("terrac::L",op, tonumber('0x'..string.sub(op,2,5)))
		_AST.root.labeltable[tonumber('0x'..string.sub(op,2,5))]={addr=_AST.root.op_addr[x]};
	end	
end


-- Rebuild 'op' with real addrs lbls in opcode_aux field
_AST.root.opcode_aux={}
local lblL,lblH;
for x,op in pairs(_AST.root.opcode) do
--print(x,op, lblH)
  if (string.sub(op,1,1) ~= 'L') then
    _AST.root.opcode_aux[x] = op
    if (string.sub(op,1,1) == '.') then
      if (lblH==nil) then
        lblH = string.sub(op,2,3)
      else
        lblL = string.sub(op,2,3)
        local lbl = tonumber(('0x'..lblH))*256 + tonumber('0x'..lblL)
--print("terrac::--",lbl,lblH,lblL,_AST.root.labeltable[lbl])
        local addr = ((_AST.root.labeltable[lbl] and _AST.root.labeltable[lbl] .addr) or 0)
--print(string.format('>>%04d',_AST.root.op_addr[x-1]),lbl,addr,_TP.getConstBytes(addr,2))
        _AST.root.opcode_aux[x-1]=string.format('%02x',addr / 256)
        _AST.root.opcode_aux[x]=string.format('%02x',addr % 256)
        _AST.root.code2[x-1] = 'addr:'..(addr or 0)
        lblH = nil
      end
    end
  end 
end


pos=endCode
idx=table.getn(_AST.root.opcode)+1


-- ====  Environment parameters  ====
-- codeAddr,LblTable11_addr,LblTable12_addr,LblTable21_addr,LblTable22_addr,LblTableEnd_addr,n_tracks,n_wavlocks,wclock0,gate0
asmText = codeAddr..' '..endCode --LblTable11_addr..' '..LblTable12_addr..' '..LblTable21_addr..' '..LblTable22_addr..' '..LblTableEnd_addr
asmText = asmText ..' '..ALL.n_tracks..' '.._ENV.n_wclocks..' '.. _ENV.n_asyncs ..' '.._MEM.gtes.wclock0
asmText = asmText ..' '.._ENV.gate0..' '.._ENV.n_ins_active..' '.._MEM.gtes.async0..'\n'
-- === Tracks ===
xAddr=0
for x=1,ALL.n_tracks+1,1 do
  asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '.. 0 ..' '..'track '.. x-1 ..'\n'; xAddr=xAddr+1;
  for y=1,(4-1),1 do
    asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '.. 0 ..'\n'; xAddr=xAddr+1;
  end
end
xMemAddr=(ALL.n_tracks+1)*4;
-- === WClocks ===
for x=1,_ENV.n_wclocks,1 do
  asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..' '..'wClock '.. x-1 ..'\n'; xAddr=xAddr+1;
  for y=1,_ENV.c.tceu_wclock.len-1,1 do
    asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..'\n'; xAddr=xAddr+1;
  end
end
-- === Asyncs ===
for x=1,_ENV.n_asyncs,1 do
  asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..' '..'async_'.. x-1 ..'\n'; xAddr=xAddr+1;
  for y=1,_ENV.c.tceu_nlbl.len-1,1 do
    asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..'\n'; xAddr=xAddr+1;
  end
end
-- === Emits ===
for x=1,_ENV.n_emits,1 do
  asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..' '..'emits '.. x-1 ..'\n'; xAddr=xAddr+1;
  for y=1,_ENV.c.tceu_nlbl.len-1,1 do
    asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..'\n'; xAddr=xAddr+1;
  end
end
-- === Gates ===
for _,ext in ipairs(_ENV.exts) do
  if (ext.pre == 'input') and (_ENV.awaits[ext] or 0) > 0 then  -- save code to write 0
--print("terrac:: gates",_ENV.awaits[ext],xAddr)
    asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '..string.format('%04d',xAddr-xMemAddr)..' inEvt '.. string.format('%03d',ext.idx) ..' : '.. ext.id  ..'\n'; xAddr=xAddr+1;
    asmText = asmText ..'00 | '..string.format('%05d',xAddr)..' '..string.format('%04d',xAddr-xMemAddr)..'           : '.. string.format('%02d',(_ENV.awaits[ext] or 0)) ..' gates\n'; xAddr=xAddr+1;
    for x= 0, (_ENV.awaits[ext] or 0)-1,1 do 
--print("terrac:: gate",x,xAddr)
	    asmText = asmText .. '00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..'\n'; xAddr=xAddr+1;
      asmText = asmText .. '00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..'\n'; xAddr=xAddr+1;
      if (ext.inArg) then  -- more one line for auxId in events with one arg
        asmText = asmText .. '00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr) ..'\n'; xAddr=xAddr+1;
      end
	  end
  end
end
-- === Vars ===
--print("terrac:: $ret offset",_AST.root[1][1].var[1].val+xMemAddr,xAddr)
for x=xAddr,codeAddr-1,1 do
	  asmText = asmText .. '00 | '..string.format('%05d',xAddr)..' '.. string.format('%04d',xAddr-xMemAddr)..' '..(_MEM.vars[xAddr-xMemAddr] or '')..'\n'; xAddr=xAddr+1;
end
-- === Opcodes ===
nlines=0;
lastBytes=0
_AST.root.x_stack = 0;
_AST.root.max_stack = 0;
for x,op in pairs(_AST.root.opcode) do
  if x > endCode then break end
	if (string.sub(op,1,1) ~= 'L' and string.sub(op,1,1) ~= '_') then 
		_AST.root.x_stack = _AST.root.x_stack + (_AST.root.n_stack[x] or 0);
		_AST.root.max_stack = math.max(_AST.root.max_stack,_AST.root.x_stack);
--    asmText = asmText ..trim(op)..' | '..string.format('%05d',_AST.root.op_addr[x])..' '..op..' '..(_AST.root.code2[x] or '')..'\n'
    asmText = asmText .. (_AST.root.opcode_aux[x] or '--') ..' | '..string.format('%05d',_AST.root.op_addr[x])..' '..op..' '..(_AST.root.code2[x] or '')..'\n'
		nlines=nlines+1;
		lastBytes=_AST.root.op_addr[x];
	else
		_AST.root.x_stack = 0;
	end	
end

local CodeSize = endCode-codeAddr
local CtlVars  = codeAddr
--local LblTab   = LblTableEnd_addr-endCode
local Stack    = _AST.root.max_stack*4
local TotalMem = CtlVars + CodeSize + Stack
local RadioMsgs = ((codeAddr%24) == 0 and math.ceil((CodeSize)/24)) or 1+math.ceil((CodeSize-(24-codeAddr%24))/24)
local lowMaxMem=999999
--print((codeAddr%24) == 0 , ((LblTableEnd_addr-codeAddr)/24) , 1,LblTableEnd_addr-codeAddr,(24-codeAddr%24))
print('---------------------------------------------------------------------')
print('-- Terra Compiler: '..string.format('%-20s',_ENV.vm_name)..'     VM Code: '.. string.format('%12s',_ENV.vm_version) .. '  --')
print('---------------------------------------------------------------------')
print('--   Memory allocation in bytes:  '.. ((_OPTS.opt and '(code optimized)    ') or '(code not optimized)') ..'             --')
print('--   Total =  Code + Ctl/Vars + Stack           |    Radio Msgs    --')
print(string.format('--    %4d    %4d     %4d     %4d            |      %4d        --',
                    TotalMem,CodeSize,CtlVars,Stack,RadioMsgs))
print('---------------------------------------------------------------------')
print('--   Target platforms x Max program size                           --')
for k,v in pairs(_ENV.motes_max_size) do
  print(string.format('--   %16s = %4s bytes %1s                               --',k,v,(TotalMem>v and '?')or ' '))
  lowMaxMem = ( v < lowMaxMem  and v) or lowMaxMem 
end
print('---------------------------------------------------------------------')

if (TotalMem > lowMaxMem) then
  WRN(false,_AST.root,'Please check the maximum program size for each mote type!')
end

if _WRN.n_wrns > 0 then
  if _WRN.n_wrns > 1 then
    print('** Success with  '.. _WRN.n_wrns ..' warning messages **')
  else
    print('** Success with  '.. _WRN.n_wrns ..' warning message **')
  end
end

-- OUTPUT_ASM
local out2
if _OPTS.output2 == '-' then
    out2 = io.stdout
else
	out2_fname = string.match(_OPTS.input, "(.*)%.terra")..'.vmx'
    out2 = assert(io.open(out2_fname,'w'))
end
out2:write(asmText)

