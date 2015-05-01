
_CODE = {
    labels = { 'Inactive', 'Init' },
    host   = '',
}



function CONC_ALL (me)
    for _, sub in ipairs(me) do
--DBG('@ ',(sub.tag or '-'),sub)
        if _AST.isNode(sub) then
--DBG('- '.._AST.isNode(sub))
            CONC(me, sub)
        end
    end
end

function CONC (me, sub, tab)
    sub = sub or me[1]
    tab = string.rep(' ', tab or 0)
    me.code = me.code .. string.gsub(sub.code, '(.-)\n', tab..'%1\n')
    CONC_OP(me,sub)
end

function CONC_OP (me, sub)
    sub = sub or me[1]
    local offset = table.getn(me.opcode)
    for idxb,value in ipairs(sub.opcode) do
    	me.opcode[offset+idxb] = value
    	me.code2[offset+idxb] = sub.code2[idxb]
    	me.n_stack[offset+idxb] = sub.n_stack[idxb]
    end
end

--function ATTR (me, n1, n2)
--    if not _OPTS.analysis_run then
--        LINE(me,'//> '..n1.val..' = '..n2.val..';')
--        LINE(me,n2.code..' // TODO ? pop_'..n1.tp..n1.code..';')
--    end
--end

--function EXP (me, e)
--    if _OPTS.analysis_run and e.accs then
--        for _, acc in ipairs(e.accs) do
--            SWITCH(me, acc.lbl_ana)
--            CASE(me, acc.lbl_ana)
--        end
--    end
--end

function CASE (me, lbl)
    --LINE(me, '//> case '..lbl.id..':', 0)
    codeB = LINE(me, lbl.id..':', 0)
    BYTECODE(me,codeB,'lbl',lbl.n)
end

function LINE (me, line, spc,comment)
    spc = spc or 4
    spc = string.rep(' ', spc)
    spc2 = 30 - string.len(line) - string.len(spc)
    if (spc2 < 0) then spc2 = 2 end
    spc2 = string.rep(' ', spc2)
    me.code = me.code .. spc .. line .. spc2 .. (comment or '') .. '\n'
	return line
end

function HALT (me)
    --LINE(me, '//> break;')
    codeB = LINE(me, 'end')
    BYTECODE(me,codeB,'op_end')
end

function SWITCH (me, lbl)
--    LINE(me, [[
--//> _lbl_ = ]]..lbl.id..[[;
--//> goto _SWITCH_;
--]])
    codeB = LINE(me,'goto '..' '..lbl.n, nil,'// goto '..lbl.id)
    BYTECODE(me,codeB,'op_exec',lbl.n)
end

function COMM (me, comm)
    LINE(me, '// /* '..comm..' */', 0)
end

function BLOCK_GATES (me)
    -- TODO: test if out is reachable, test if has inner parallel
    -- in both cases, no need to run anything

    CASE(me, me.lbl_out)
--    COMM(me, 'close gates')

    -- do not resume inner ASYNCS
    local n = me.gtes.asyncs[2] - me.gtes.asyncs[1]
    if n > 0 then
--        LINE(me, '//> memset(PTR(char*,CEU_ASYNC0) + '
--                    ..me.gtes.asyncs[1]..'*sizeof(tceu_nlbl), 0, '
--                    ..n..'*sizeof(tceu_nlbl));')
        codeB = LINE(me, 'clear asyncs gates from '..me.gtes.asyncs[1]..' to '..me.gtes.asyncs[2],nil,'// close gates') 
        BYTECODE(me,codeB,'op_memclr', n*_ENV.c.tceu_nlbl.len, _MEM.gtes.async0 +me.gtes.asyncs[1]*_ENV.c.tceu_nlbl.len)
    end

    -- do not resume inner WCLOCKS
    local n = me.gtes.wclocks[2] - me.gtes.wclocks[1]
    if n > 0 then
--        LINE(me, '//> memset(PTR(char*,CEU_WCLOCK0) + '
--                    ..me.gtes.wclocks[1]..'*sizeof(tceu_wclock), 0, '
--                    ..n..'*sizeof(tceu_wclock));')
        codeB = LINE(me, 'clear WClocks gates from '..me.gtes.wclocks[1]..' to '..me.gtes.wclocks[2],nil,'// close gates') 
        BYTECODE(me,codeB,'op_memclr', n*_ENV.c.tceu_wclock.len, _MEM.gtes.wclock0 + me.gtes.wclocks[1]*_ENV.c.tceu_wclock.len)
    end

    -- stop awaiting inner EXTS
    for _, ext in ipairs(_ENV.exts) do
        local t = me.gtes[ext]
        if t then
            local n = t[2] - t[1]
            if n > 0 then
--                LINE(me, '//> memset(PTR_EXT(IN_'..ext.id..','..t[1]..'), 0, '
--                    ..n..'*sizeof(tceu_nlbl));')
		        codeB = LINE(me, 'clear EXT gates for '..ext.id,nil,'// stop awaiting inner externals') 
		        BYTECODE(me,codeB,'op_memclr', n*_ENV.c.tceu_nlbl.len, _MEM.gtes[ext.n]+2)
            end
        end
    end

    -- stop awaiting inner internal events
    for blk in _AST.iter'Block' do
        for _, var in ipairs(blk.vars) do
            if me.gtes[var] then
                local t = me.gtes[var]
                local n = t[2] - t[1]
                if n > 0 then
--                    LINE(me, '//> memset(CEU->mem+'..var.awt0..'+1+'
--                            ..t[1]..'*sizeof(tceu_nlbl), 0, '
--                            ..n..'*sizeof(tceu_nlbl));')
			        codeB = LINE(me, 'clear Internal gates for '..var.id,nil,'// stop awaiting inner intenals') 
					BYTECODE(me,codeB,'op_memclr', n*_ENV.c.tceu_nlbl.len, var.awt0 + 1 + t[1] * _ENV.c.tceu_nlbl.len)
                end
            end
        end
    end

    -- do not resume inner EMITS continuations (await/emit)
    -- TODO: check if needed
    if _PROPS.has_emits then
--        LINE(me, '//> ceu_track_clr('..me.lbls_emt[1]..','..me.lbls_emt[2]..');')

-- Testando sem o TkClr
--        codeB = LINE(me, 'clear tracks from label '..me.lbls_emt[1]..' to label '..me.lbls_emt[2],nil,'// do not resume inner EMITS continuations (await/emit)') 
--    		BYTECODE(me,codeB,'op_tkclr',me.lbls_emt[1],me.lbls_emt[2])
    end
end

--function PAUSE (me, N, PTR)
--    if me.more then
--        LINE(me, [[
--{ short i;
--for (i=0; i<]]..N..[[; i++) {
--    if (]]..PTR..'['..i..']'..[[ >= Init) {
--        ]]..PTR..'['..i..']'..[[ = Init-1;
--    } else {
--        ]]..PTR..'['..i..']'..[[--;
--    }
--} }
--]])
--    else
--        LINE(me, [[
--{ short i;
--for (i=0; i<]]..N..[[; i++) {
--    if (]]..PTR..'['..i..']'..[[ >= Init) {
--        ]]..PTR..'['..i..']'..[[ = Init-1;
--    } else {
--        ]]..PTR..'['..i..']'..[[--;
--    }
--} }
--]])
--    end
--end


function getAuxValues(e1)
    -- Calculate aux memory access
--print("code::getAuxValues: tags",e1.tag,e1[1].tag,e1[1][1])
    local x1
    x1={}
    x1.tag = e1.tag
    x1.tp = e1.tp
    x1.ntp = (_TP.deref(e1.tp) and 'ushort') or e1.tp  -- Redefine tp if it is a pointer
   
    -- **********************************************************
    -- * auxtag3 computation from _TP.getAuxTag() used in env.lua
    -- **********************************************************
    local z1 = _TP.getAuxTag(e1.tp,e1[1].arr)
    x1.auxtag3 = z1.auxtag

    -- **********************************
    -- * x1 parameter table computation 
    -- **********************************
    if not (e1.tag == 'AwaitInt') then   
      if e1[1].tag == 'CONST' then
          x1.auxtag1 = 'Const'
          x1.auxtag2 = 'Const'
          x1.val = e1.val
          x1.auxval = (x1.ntp=='float' and _TP.float2hex(tonumber(e1.val)))
--print("code::getAuxValues:",x1.val,x1.auxval)
          x1.id = e1.val
      elseif e1[1].tag == 'Var' then -- Var/Var*, Reg/Reg*
        if _TP.isBasicType(_TP.deref(e1.tp) or e1.tp) then
          if _TP.deref(e1.tp) then -- Var*
            if (e1[1].arr) then
              x1.auxtag1 = 'Arr'
              x1.auxtag2 = 'Var*'
              x1.val = e1.val
              x1.id = (e1.fst and e1.fst.id) or e1[1][1]
              x1.arr = e1[1].arr
            else
              x1.auxtag1 = 'Var*'
              x1.auxtag2 = 'Var*'
              x1.val = e1.val
              x1.id = (e1.fst and e1.fst.id) or e1[1][1]
            end
          else -- Var
            x1.auxtag1 = 'Var'
            x1.auxtag2 = 'Var'
            x1.val = e1.val
            x1.id = (e1.fst and e1.fst.id) or e1[1][1]
          end    
        else  -- Reg/Reg* (without field)
          if _TP.deref(e1.tp) then -- Reg*
            x1.auxtag1 = 'Reg*'
            x1.auxtag2 = 'Var*'
            x1.val = e1.val
            x1.id = (e1.fst and e1.fst.id) or e1[1][1]
          else -- Reg
            x1.auxtag1 = 'Reg'
            x1.auxtag2 = 'Reg'
            x1.val = e1.val
            x1.id = (e1.fst and e1.fst.id) or e1[1][1]
          end
        end
      elseif e1[1].tag == 'Op1_&' then
        if (e1[1][2].tag == 'Var') then
--print("code::getAuxValues: Pointer = &Var,",e1[1][2].tag,e1.tp,e1[1][2][1]) -- TODO fazer um set_v addr, mas tem que testar Var/Var.Field/Var.Field[idx]/var[idx]/???var[]/Var.Fieled[]
          if(_TP.deref(e1.tp)) then
            x1.auxtag1 = 'Var*'
            x1.auxtag2 = '&Var*'
            x1.val = e1[1][2].val
            x1.tp = e1.tp
            x1.id = '&'.. e1[1][2][1]
          else
            x1.auxtag1 = 'Var*'
            x1.auxtag2 = '&Var'
            x1.val = e1[1][2].val
            x1.tp = e1.tp
            x1.id = '&'.. e1[1][2][1]
          end
        elseif (e1[1][2].tag == 'Op2_idx'  and e1[1][2][2].tag == 'Var') then
--print("code::getAuxValues: Pointer = &Op2_idx Var : ,",e1[1][2][2].tag,e1.tp,e1[1][2][3].val) 
          if(_TP.deref(e1.tp)) then
            x1.auxtag1 = 'Var*'
            x1.auxtag2 = '&Var*'
            x1.val = e1[1][2].val + e1[1][2][3].val
            x1.tp = e1.tp
            x1.id = '&'.. e1[1][2][2][1]..'['.. e1[1][2][3].val ..']'
          else
            x1.auxtag1 = 'Var*'
            x1.auxtag2 = '&Var'
            x1.val = e1[1][2].val
            x1.tp = e1.tp
            x1.id = '&'.. e1[1][2][1]
          end
        elseif (e1[1][2].tag == 'Op2_idx'  and e1[1][2][2].tag == 'Op2_.' and e1[1][2][3].tag == 'CONST') then
          local field = _ENV.c[_TP.deref(e1[1][2][2][2].tp) or e1[1][2][2][2].tp].fields[e1[1][2][2][3]]
--print("code::getAuxValues: Pointer = &Op2_idx Filed : ",e1[1][2][2][2].tag,e1[1][2][2][2][1],field.id,e1[1][2][2][2].val,field.offset,e1[1][2][3].tag,e1[1][2][3].val) 
            x1.auxtag1 = 'Var*'
            x1.auxtag2 = '&Var*'
            x1.val = e1[1][2][2][2].val + field.offset + e1[1][2][3].val
            x1.tp = e1.tp
            x1.id = '&'.. e1[1][2][2][2][1]..'.'.. field.id..'['.. e1[1][2][3].val ..']'
        elseif (e1[1][2].tag == 'Op2_.' and e1[1][2][2].tag == 'Var') then
          local field = _ENV.c[_TP.deref(e1[1][2][2].tp) or e1[1][2][2].tp].fields[e1[1][2][3]]
--print("code::getAuxValues: Pointer = &Op2_. Var : ",e1[1][2][2].tag,e1.tp,e1[1][2][2][1],field.id,e1[1][2][2].val,field.offset) 
            x1.auxtag1 = 'Var*'
            x1.auxtag2 = '&Var*'
            x1.val = e1[1][2][2].val + field.offset
            x1.tp = e1.tp
            x1.id = '&'.. e1[1][2][2][1]..'.'.. field.id
        else
          x1.auxtag1 = 'Exp'
          x1.auxtag2 = 'Exp'
        end
      elseif e1[1].tag == 'Op2_.' then
          local field = _ENV.c[_TP.deref(e1[1][2].tp) or e1[1][2].tp].fields[e1[1][3]]
          if _TP.deref(e1[1][2].tp) then -- Var*.field
--  print("code::getAuxValues: Var.field",e1[1][2].tp,e1[1][2].val,field.offset)
            x1.auxtag1 = 'Exp'
            x1.auxtag2 = 'Exp'
          else
            if field.dim then -- Var.Field[] (without index)
              x1.auxtag1 = 'Var.field*'
              x1.auxtag2 = 'Var*'
              x1.val = e1[1][2].val+field.offset
              x1.id = e1[1][2][1]..'.'..e1[1][3]
              x1.arr = field.dim
            else
              x1.auxtag1 = 'Var.field'
              x1.auxtag2 = 'Var'
              x1.val = e1[1][2].val+field.offset
              x1.id = e1[1][2][1]..'.'..e1[1][3]
            end
          end
        elseif e1[1].tag == 'Op2_idx' then
        if e1[1][2].tag == 'Var' then
          if _TP.deref(_TP.deref(e1[1][2].tp)) then
            if e1[1][3].tag == 'CONST' then
--  print("code::getAuxValues: Var*[idx]",e1[1][2].tag,e1[1][2].tp,e1[1][3].tag)
              x1.auxtag1 = 'Var*[idx]'
              x1.auxtag2 = 'Var*'
              x1.val = e1[1][2].val+(e1[1][3].val*_ENV.c[x1.ntp].len)
              x1.id = e1[1][2][1]..'*['..e1[1][3].val..']'
            elseif e1[1][3].tag == 'Var' then
 -- print("code::getAuxValues: Var*[Var]",e1[1][2].tag,e1[1][2].tp,e1[1][3].tag,e1[1][3].tp,e1[1][3].val,e1.fst.arr)
              x1.auxtag1 = 'Var*[Var]'
              x1.auxtag2 = 'Var*[Var]'
              x1.val = e1[1][2].val
              x1.id = e1[1][2][1]..'*['..e1[1][3][1]..']'
              x1.idxval = e1[1][3].val
              x1.idxtp = e1[1][3].tp
              x1.idxmax = e1.fst.arr            
            else
              x1.auxtag1 = 'Exp'
              x1.auxtag2 = 'Exp'
            end
          else
            if e1[1][3].tag == 'CONST' then
 -- print("code::getAuxValues: Var[idx]",e1[1][2].tag,e1[1][2].tp,e1[1][3].tag)
              x1.auxtag1 = 'Var[idx]'
              x1.auxtag2 = 'Var'
              x1.val = e1[1][2].val+(e1[1][3].val*_ENV.c[x1.ntp].len)
              x1.id = e1[1][2][1]..'['..e1[1][3].val..']'
            elseif e1[1][3].tag == 'Var' then
 -- print("code::getAuxValues: Var[Var]",e1[1][2].tag,e1[1][2].tp,e1[1][3].tag,e1[1][3].tp,e1[1][3].val,e1.fst.arr)
              x1.auxtag1 = 'Var[Var]'
              x1.auxtag2 = 'Var[Var]'
              x1.val = e1[1][2].val
              x1.id = e1[1][2][1]..'['..e1[1][3][1]..']'
              x1.idxval = e1[1][3].val
              x1.idxtp = e1[1][3].tp
              x1.idxmax = e1.fst.arr
            else
              x1.auxtag1 = 'Exp'
              x1.auxtag2 = 'Exp'
            end
          end
        elseif e1[1][2].tag == 'Op2_.' then
          local field = _ENV.c[_TP.deref(e1[1][2][2].tp) or e1[1][2][2].tp].fields[e1[1][2][3]]
          if _TP.deref(e1[1][2][2].tp) then
            x1.auxtag1 = 'Exp'
            x1.auxtag2 = 'Exp'
          else
            if e1[1][3].tag == 'CONST' then
--print("code::getAuxValues: Var.field[idx]",e1[1][2][2].val,field.offset,(e1[1][3].val*_ENV.c[x1.ntp].len))
              x1.auxtag1 = 'Var.field[idx]'
              x1.auxtag2 = 'Var'
              x1.val = e1[1][2][2].val + field.offset + (e1[1][3].val*_ENV.c[x1.ntp].len)
              x1.id = e1[1][2][2][1]..'.'..e1[1][2][3]..'['..e1[1][3].val..']'
            else
              x1.auxtag1 = 'Exp'
              x1.auxtag2 = 'Exp'
            end
          end
        else
          x1.auxtag1 = 'Exp'
          x1.auxtag2 = 'Exp'
        end
      else
        x1.auxtag1 = 'Exp'
        x1.auxtag2 = 'Exp'
      end
    else -- AwaitInt
      x1.auxtag1 = 'Var'
      x1.auxtag2 = 'AwaitInt'
      x1.val = e1.val
      x1.id = (e1.fst and e1.fst.id) or e1[1][1]
    end
--print("code::getAuxValues:-->:",x1.tag,x1.auxtag1,x1.auxtag2,x1.auxtag3)
--print("code::getAuxValues:var:",x1.tp,x1.ntp,x1.val,x1.id,x1.arr)
--print("code::getAuxValues:idx:",x1.idxval,x1.idxtp,x1.idxmax)
  return x1
end

function tryDerefCode(me,tag,tp)
    local ntp = (_TP.deref(tp) and 'ushort') or tp
--print("code::tryDerefCode:",tag,tp, ntp)
    if (  tag == 'Op2_idx' or tag == 'Op2_.')
     then
      codeB = LINE(me,'deref '..tp,nil,'// deref Var ')
      BYTECODE(me,codeB,'op_deref',ntp)
    end
end

function Op1_any(me,mnemonic)
    local op, e1 = unpack(me)
		CONC(me,e1)
--print("code::Op1_any",e1.tag)
    mnemonic = (e1.tp=='float' and opcode['op_'..mnemonic..'_f'] and mnemonic..'_f') or mnemonic 
    codeB = LINE(me,mnemonic,nil,'// stack0 = '..mnemonic..'(stack0)')
    BYTECODE(me,codeB,'op1_any',mnemonic)
end

function Op2_any(me,mnemonic)
    local op, e1, e2 = unpack(me)
--print("code::Op2_any:",op,e1.tag,e1.tp,e2.tag,e2.tp,e1.arr,e2.arr,_TP.max(e1.tp,e2.tp))
  local err,cast, _, _, len1, len2 = _TP.tpCompat(e1.tp,e2.tp,e1.arr,e2.arr)
  ASR(not err ,me,'type/size incompatibility: "'..e1.tp..'/'..len1 .. '" <--> "'..e2.tp..'/'..len2)
  --WRN(not cast,me,'automatic cast from ['.. e2.tp ..'] to [' .. e1.tp ..'].')
  local maxTp =  _TP.max(e1.tp,e2.tp)
  local toTp = _TP.getCastType(maxTp)  
  local from2Tp = _TP.getCastType(e2.tp)  
  local from1Tp = _TP.getCastType(e1.tp) 

--print("code::Op2_any:",toTp,opcode['op_'..mnemonic..'_f'],mnemonic..'_f')  
  mnemonic = (toTp=='float' and opcode['op_'..mnemonic..'_f'] and mnemonic..'_f') or mnemonic 
  -- exp 2
	CONC(me,me[3])
  tryDerefCode(me,e2.tag,e2.tp)
  if (from2Tp~=toTp and (from2Tp=='float' or toTp=='float')) then
--print("code::Op2_any: cast exp2",e1.tp,e2.tp,from2Tp,toTp)
    codeB = LINE(me,'cast '..from2Tp..' '..toTp,nil,'// cast <type> ')
    BYTECODE(me,codeB,'op_cast',from2Tp,toTp)
  end
  -- exp 1
	CONC(me,me[2])
  tryDerefCode(me,e1.tag,e1.tp)
  if (from1Tp~=toTp and (from1Tp=='float' or toTp=='float')) then
--print("code::Op2_any: cast exp1",e1.tp,e2.tp,from2Tp,toTp)
    codeB = LINE(me,'cast '..from1Tp..' '..toTp,nil,'// cast <type> ')
    BYTECODE(me,codeB,'op_cast',from1Tp,toTp)
  end
  -- operation
	codeB = LINE(me,mnemonic,nil,'// stack0 = stack0 '..mnemonic..' stack1')
  BYTECODE(me,codeB,'op2_any',mnemonic)
end

function INC_STACK()
	_AST.root.n_stack=_AST.root.n_stack+1;
	_AST.root.max_stack = math.max(_AST.root.max_stack,_AST.root.n_stack)
--print('inc stack=',_AST.root.max_stack,_AST.root.n_stack)
end
function DEC_STACK()
	_AST.root.n_stack=_AST.root.n_stack-1;
end
function CLR_STACK()
	_AST.root.n_stack=0;
end

-- *******************************************************
-- * -- SetExp() function                                *
-- * -- Code generation for different kinds of SetExp -- *
-- *                                                     *
-- *  Includes code optimization for simple attribution  *
-- *******************************************************
function SetExp(me)
    local e1, e2 = unpack(me)
--print("code::SetExp():",e1.tag,e2.tag,e1[1].tag,e2[1].tag,e1.arr,e2.arr)

    local x1 = getAuxValues(e1)
    local x2 = getAuxValues(e2)

--print("code::SetExp: e1:",x1.auxtag1,x1.auxtag2, x1.tp, x1.ntp, x1.val,x1.id)
--print("code::SetExp: e2:",x2.auxtag1,x2.auxtag2, x2.tp, x2.ntp, x2.val,x2.id)

-- ********************************************************
-- *** getAuxValues() translation: tag -> auxtag2; auxtag3
-- *******************************************************
-----------------------------------------------------
-- CONST                  -> Const
-- Var & BasicType        -> Var
-- Var* & BasicType & arr -> Var* & arr
-- Var & ~BasicType       -> Reg
-- Var* & ~BasicType      -> Var*
-- Var[Const]             -> Var
-- Var*[Const]            -> Var*
-- Var[Var|Exp]           -> Exp
-- Var*[Var|Exp]          -> Exp
-- Var.Field              -> Var
-- Var.Field & arr        -> Var*
-- Var*.Field             -> Exp
-- Var.Field[Const]       -> Var
-- Var*.Field[Const       -> Exp
-- Var.Field[Var|Exp]     -> Exp
-- Var*.Field[Var|Exp]    -> Exp
-- AwaitInt               -> AwaitInt  ... used in SetAwait
-- &Var                   -> &Var
-- &Var*                  -> &Var*
-----------------------------------------------------

--  type            -> auxtag3;    tp;   size   (from _TP.tpCompat() used in 'env.lua')
-----------------------------------------------------
-- reg*             -> pointer;   ushort;   reg len
-- reg              -> data;      reg;      reg len
-- tpBasic          -> var;       tp;       tp len
-- tpBasic* + ~arr  -> pointer;   ushort;   arr*tp
-- tpBasic* +  arr  -> data;      arr*tp;   arr*tp
-- tpBasic** + ~arr -> pointer;   ushort;   arr*tp
-- tpBasic** +  arr -> pointer;   ushort;   arr*tp
-----------------------------------------------------

-- **********************************************
-- *** SetExp operation
-- **********************************************
-----------------------------------------------------
--R  Var*,arr   = Var*,arr  -> [memcpy]
--R+ data      = data
--R Var*,~arr  = Var*      -> [set_v]
--R+ pointer   = pointer
--R Var*,~arr  = Reg|&Var|&Var*|Var*,arr -> [set_c]
--R+ pointer   = data | pointer
-- Var        = Const     -> [set_c] | [CONC(e2),pop]
--+ var       = var
-- Var        = Var       -> [set_v]
--+ var       = var
-- Var        = AwaitInt  -> [Conc(e2),set_v]
--+ var       = var
--R Var*,~arr  = Exp       -> [Conc(e2),pop]
--R+ pointer   = pointer
-- Var        = Exp       -> [Conc(e2),pop]
--+ var       = var
-- Var[Var]   = Var       -> [setarr_vv]
--+ var       = var
-- Var[Var]   = AwaitInt  -> [Conc(e2),setarr_vv]
--+ var       = var
--R Var*[Var]  = Var*      -> [setarr_vv]
--R+ pointer   = pointer
-- Var[Var]   = Const     -> [setarr_vc]
--+ var       = var
-- Var[Var]   = Exp       -> [poparr_v]
--+ var       = var
-- Reg        = Reg       -> [memcpy]
--+ data      = data
--R Reg        = Var*,arr  -> [memcpy]
--R+ data      = data
--R Var*,arr   = Reg       -> [memcpy]
--R+ data      = data

--
--
-----------------------------------------------------
-- pending...
--R Exp:*varp  = Const       -> [push_c,push_v,set_e]
--R+ var       = var
--R Exp:*varp  = Var         -> [push_v,push_v,set_e]
--R+ var       = var
--R Var* ~arr  = Var* & Arr
--R+ pointer   = data



    if     x1.auxtag2 == 'Var' and x2.auxtag2 == 'Const'  then
      local toTp = _TP.getCastType(x1.tp)  
      local fromTp = _TP.getCastType(x2.tp)          
      if (toTp~=fromTp and (toTp=='float' or fromTp=='float')) then
        CONC(me,e2)
        codeB = LINE(me,'cast '..fromTp..' '..toTp,nil,'// cast <type> ')
        BYTECODE(me,codeB,'op_cast',fromTp,toTp)      
        codeB = LINE(me,'pop '..x1.id,nil,'// SetExp:: pop to var')
        BYTECODE(me,codeB,'op_pop',x1.tp,x1.val)  
      else  codeB = LINE(me,x1.id ..' = '.. x2.id,nil,'// SetExp:: set var=const' )        
        codeB = LINE(me,x1.id ..' = '.. x2.id,nil,'// SetExp:: set var=const' )        
        BYTECODE(me,codeB,'op_set_c',x1.tp,x1.val,x2.auxval or x2.val)
      end
  
    elseif x1.auxtag2 == 'Var' and x2.auxtag2 == 'Var'  and (x1.tp~= 'float' and x2.tp~='float') then
        codeB = LINE(me,x1.id ..' = '.. x2.id..'',nil,'// SetExp:: set var = var')        
        BYTECODE(me,codeB,'op_set_v',x1.ntp,x2.ntp,x1.val,x2.val)
      
    elseif x1.auxtag2 == 'Var' and x2.auxtag2 == 'AwaitInt'  then
        CONC(me,e2)
        codeB = LINE(me,x1.id ..' = '.. x2.id..'',nil,'// SetExp:: set var = var')        
        BYTECODE(me,codeB,'op_set_v',x1.ntp,x2.ntp,x1.val,x2.val)

    elseif x1.auxtag2 == 'Var' and x2.auxtag2 == 'Exp'  then
      CONC(me,e2)
      local toTp = _TP.getCastType(x1.tp)  
      local fromTp = _TP.getCastType(x2.tp)          
      if (toTp~=fromTp and (toTp=='float' or fromTp=='float')) then
        codeB = LINE(me,'cast '..fromTp..' '..toTp,nil,'// cast <type> ')
        BYTECODE(me,codeB,'op_cast',fromTp,toTp)
      end      
        codeB = LINE(me,'pop '..x1.id,nil,'// SetExp:: pop to var')
        BYTECODE(me,codeB,'op_pop',x1.tp,x1.val)  
      
    elseif x1.auxtag2 == 'Var[Var]' and x2.auxtag2 == 'Var' and (x1.tp~= 'float' and x2.tp~='float') then
        codeB = LINE(me,''..x1.id..' = '..x2.id,nil,'// set array[var] with var')        
        BYTECODE(me,codeB,'op_setarr_vv',x1.ntp,x1.val,x1.idxtp,x1.idxval,x1.idxmax,x2.tp,x2.val)

    elseif x1.auxtag2 == 'Var[Var]' and x2.auxtag2 == 'AwaitInt' then
        CONC(me,e2)
        codeB = LINE(me,''..x1.id..' = '..x2.id,nil,'// set array[var] with var')        
        BYTECODE(me,codeB,'op_setarr_vv',x1.ntp,x1.val,x1.idxtp,x1.idxval,x1.idxmax,x2.tp,x2.val)

    elseif x1.auxtag2 == 'Var[Var]' and x2.auxtag2 == 'Const' and (x1.tp~= 'float' and x2.tp~='float') then
        codeB = LINE(me,''..x1.id..' = '..x2.id,nil,'// set array[var] with Const')        
        BYTECODE(me,codeB,'op_setarr_vc',x1.ntp,x1.val,x1.idxtp,x1.idxval,x1.idxmax,x2.val)
    elseif x1.auxtag2 == 'Var[Var]' and x2.auxtag2 == 'Exp' and (x1.tp~= 'float' and x2.tp~='float') then
        CONC(me,e2)
        codeB = LINE(me,'pop to '..x1.id,nil,'// pop to array[var] ')        
        BYTECODE(me,codeB,'op_poparr_v',x1.ntp,x1.idxtp,x1.idxval,x1.idxmax,x1.val)

    elseif x1.auxtag2 == 'Reg' and x2.auxtag2 == 'Reg' and (x1.tp~= 'float' and x2.tp~='float') then
        codeB = LINE(me,'memcpy '..math.min(_ENV.c[x1.tp].len,_ENV.c[x2.tp].len)..'B. '..x2.id..' -> '..x1.id,nil,'// memcpy v2 v1')        
        BYTECODE(me,codeB,'op_memcpy',math.min(_ENV.c[x1.tp].len,_ENV.c[x2.tp].len),x2.val,x1.val)
        
    else
      -- ??) All other cases
      CONC(me,e2)
      local toTp = _TP.getCastType(x1.tp)  
      local fromTp = _TP.getCastType(x2.tp)          
      if (toTp~=fromTp and (toTp=='float' or fromTp=='float')) then
--print("code::SetExp: additional cast from "..fromTp..' to '..toTp)
        codeB = LINE(me,'cast '..fromTp..' '..toTp,nil,'// cast <type> ')
        BYTECODE(me,codeB,'op_cast',fromTp,toTp)      
      end


      if x1.auxtag2 == 'Var' then
        codeB = LINE(me,'push_c &'..x1.id..':'..x1.tp,nil,'// push Var ')
        BYTECODE(me,codeB,'op_push_c',x1.val)
      else
        CONC(me,e1)
      end

      codeB = LINE(me,'set ('.. e1.tp ..')*(pop1) = pop2',nil,'// SetExp:: pop stk1 to stk2')         
      BYTECODE(me,codeB,'op_set_e',x1.ntp)  
  end

end


F = {
    Node_pre = function (me)
        me.code = ''
        me.code2 = {}
        me.opcode={}
        me.n_stack={}
    end,

  Root = function (me)
    --        LINE(me, '//> memset(CEU->mem, 0, '.._MEM.gtes.loc0..');')
    --		LINE(me, 'main:',0,'// program main entry ')
    codeB = LINE(me, 'init_1:',0,'// program main entry ')
    local bytecode = string.format('L%04x',1)
    OPCODE(me,bytecode,codeB)
-- Nao precisa limpar na inicializacao
--    codeB = LINE(me, 'clear all gates',nil,'// Clear the gates ') 
--    BYTECODE(me,codeB,'op_memclr', _MEM.gtes.loc0, 0)
    for _,ext in ipairs(_ENV.exts) do
      if ((ext.pre == 'input') and ((_ENV.awaits[ext] or 0) >0)) then  -- save code to write 0
        --                LINE(me, '//> *PTR(ubyte*,IN_'..ext.id..') = '
        --                            ..(_ENV.awaits[ext] or 0)..';')

        -- event Id + nGates
        local Id_nGts = (ext.idx*256) + ((_ENV.awaits[ext] or 0) * 1) + ((ext.inArg and 128) or 0) -- if auxId set bit 7 in nGts
        local nGtsText = string.format("0x%04x = %d",Id_nGts,Id_nGts)
        codeB = LINE(me, 'config gate '..ext.id..' with '..(_ENV.awaits[ext] or 0)..' await(s) - '..nGtsText,nil,'// Config gate')
        BYTECODE(me,codeB,'op_set_c','ushort',_MEM.gtes[ext.n],Id_nGts)
      end
    end

    CONC_ALL(me)

--    if _OPTS.analysis_run then
--      SWITCH(me, me.lbl_ana)
--      CASE(me, me.lbl_ana)
--    end

    if not (_OPTS.analysis_use and _ANALYSIS.isForever) then
      local ret = _AST.root[1].vars[1]    -- $ret
      --afb            LINE(me, 'if (ret) *ret = '..ret.val..';')
      codeB = LINE(me, 'end program',nil,'// end; ')
      BYTECODE(me,codeB,'op_end')
    end
    HALT(me)
  end,

  Host = function (me)
    _CODE.host = _CODE.host .. me[1] .. '\n'
  end,

  SetExp = function (me)
    SetExp(me)
  end,

  SetAwait = function (me)
    local e1, e2 = unpack(me)
--print("code::SetWait:",e1.tp,e1[1].tag,e1[1].val,e2.tag)
--print(print_r(me,"code::SetWait: me"))
    --ATTR(me, e1, e2.ret)

    if (e2.tag =="AwaitInt") then
      SetExp(me)
    else -- e2.tag == AwaitExt
      CONC(me, e2)
      if e1[1].tag=='Var' then
        local x1 = getAuxValues(e1)
--print("code::SetAwait: var:",x1.auxtag1,x1.auxtag2, x1.tp, x1.ntp, x1.val,x1.id)
        codeB = LINE(me,'getExtData '..x1.id..' '.._ENV.c[e1.tp].len,nil,'// getExtDt <localVarAddr> <len>')
        BYTECODE(me,codeB,'op_getextdt_v',x1.val,_ENV.c[e1.tp].len)
      else
        CONC(me,e1)
        codeB = LINE(me,'getExtData stack len='.._ENV.c[e1.tp].len,nil,'// getExtDt <Stack:localVar Addr> <len>')
        BYTECODE(me,codeB,'op_getextdt_e',_ENV.c[e1.tp].len)
      end
    end	        

--    EXP(me, e1)     -- after awaking
  end,

    SetBlock = function (me)
        local _,blk = unpack(me)
        CONC(me, blk)
--        if _OPTS.analysis_run then
--            SWITCH(me, me.lbl_ana_no)
--            CASE(me, me.lbl_ana_no)
--        end
        HALT(me)        -- must escape with `return´
        BLOCK_GATES(me)
    end,
    Return = function (me)
        local top = _AST.iter'SetBlock'()
--        LINE(me, '//> ceu_track_ins(CEU->stack,' ..top.lbl_out.tree..', 1,'
--                    ..top.lbl_out.id..');')
        codeB = LINE(me, 'insert track '.. top.lbl_out.id .. ' tree '.. top.lbl_out.tree,nil,'// Return to '..top.lbl_out.id)
		    BYTECODE(me,codeB,'op_tkins_z',1,top.lbl_out.tree,top.lbl_out.n)
        HALT(me)
    end,

    Block = function (me)
        for _, var in ipairs(me.vars) do
--print("code::Block:",me[1].tag,var.id,var.ln)
            if var.isEvt then
--                LINE(me, '//> *PTR(ubyte*,'..var.awt0..') = '..var.n_awaits..';')  -- #gtes
              codeB = LINE(me, 'event '..var.id..' = '..var.n_awaits..' gates',nil,'// set event ')
      				BYTECODE(me,codeB,'op_set_c','ubyte',var.awt0,var.n_awaits)
--                LINE(me, '//> memset(CEU->mem+'..var.awt0..'+1, 0, '   -- gtes[i]=0
--                        ..(var.n_awaits*_ENV.c.tceu_nlbl.len)..');')
              WRN(var.n_awaits > 0, var.ln,'event "'..var.id ..'" without any await.')
              if var.n_awaits > 0 then
          				codeB = LINE(me, 'clear '.. var.id ..' '..var.n_awaits..' wait(s) ',nil,'// clear event waits') 
          				BYTECODE(me,codeB,'op_memclr', var.n_awaits*_ENV.c.tceu_nlbl.len, var.awt0+1)
              else
          		end
            end
        end
        CONC_ALL(me)
    end,

    BlockN  = CONC_ALL,
    Finally = CONC,

    _Par = function (me)
        -- Ever/Or/And spawn subs
        COMM(me, me.tag..': spawn subs')
        for i, sub in ipairs(me) do
--            LINE(me, '//> ceu_track_ins(CEU->stack, CEU_TREE_MAX, 0, '
--                        ..me.lbls_in[i].id ..');')
	        codeB = LINE(me, 'insert track '.. me.lbls_in[i].id ,nil,'// insert track (Par)')
			BYTECODE(me,codeB,'op_tkins_max',0,me.lbls_in[i].n)
        end
        HALT(me)
    end,


    ParEver = function (me)
        -- behave as ParAnd, but halt on termination (TODO: +ROM)
--        if _OPTS.analysis_run then
--            F.ParAnd(me)
--            SWITCH(me, me.lbl_ana_no)
--            CASE(me, me.lbl_ana_no)
--            HALT(me)
--            return
--        end

        F._Par(me)
        for i, sub in ipairs(me) do
            CASE(me, me.lbls_in[i])
            CONC(me, sub)
            HALT(me)
        end
    end,

    ParOr = function (me)
        F._Par(me)
        for i, sub in ipairs(me) do
            CASE(me, me.lbls_in[i])
            CONC(me, sub)
--            COMM(me, 'PAROR JOIN')
--            LINE(me, '//> ceu_track_ins(CEU->stack,' .. 255 ..', 1,'
--                        ..me.lbl_out.id..');')
	        codeB = LINE(me, 'insert track '.. me.lbl_out.id,nil,'// Insert track (ParOr)')
			BYTECODE(me,codeB,'op_tkins_max',0,me.lbl_out.n)
            HALT(me)
        end
        BLOCK_GATES(me)
    end,

    ParAnd = function (me)
        -- close AND gates
--        LINE(me, '//> memset(PTR(char*,'..me.off..'), 0, '..#me..');')
		codeB = LINE(me, 'clear gates from addr '.. me.off ..' to addr '..me.off+#me-1,nil,'// close gates (ParAnd)') 
		BYTECODE(me,codeB,'op_memclr', #me, me.off)

        F._Par(me)

        for i, sub in ipairs(me) do
            CASE(me, me.lbls_in[i])
            CONC(me, sub)
--            LINE(me, '//> *PTR(ubyte*,'..(me.off+i-1)..') = 1; // open and')  -- open gate
            codeB = LINE(me, 'open gate '..i,nil,'// open gate (ParAnd)') 
			BYTECODE(me,codeB,'op_set_c','ubyte',(me.off+i-1),1)

            SWITCH(me, me.lbl_tst)
        end

        -- AFTER code :: test gates
        CASE(me, me.lbl_tst)
        for i, sub in ipairs(me) do
--afb             LINE(me, 'if (! *PTR(ubyte*,'..(me.off+i-1)..'))')
			codeB = LINE(me,me.lbl_ana_out.id .. ' -- if (gate '..(i-1)..' == 0) PC=PC+1',nil,'')
			BYTECODE(me,codeB,'op_chkret', (me.off+i-1))
            HALT(me)
        end

--        if _OPTS.analysis_run then
--            SWITCH(me, me.lbl_ana_out)
--            CASE(me, me.lbl_ana_out)
--        end
    end,

    If = function (me)
        local c, t, f = unpack(me)
        -- TODO: If cond assert(c==ptr or int)
--        if _OPTS.analysis_run then
--afb            EXP(me, c)
--afb            local id = (me.lbl_f and me.lbl_f.id) or me.lbl_e.id
--afb            LINE(me, [[
--afb CEU_ANA_PRE(1);
--afb ceu_track_ins(CEU->stack, CEU_TREE_MAX, 0, ]]..id..[[);
--afb CEU_ANA_POS();
--afb ]])
--afb            SWITCH(me, me.lbl_t);
--        else
--afb            LINE(me, [[if (]]..c.val..[[) {]])
--afb            SWITCH(me, me.lbl_t)
--afb
--afb            LINE(me, [[} else {]])
--afb            if me.lbl_f then
--afb                SWITCH(me, me.lbl_f)
--afb            else
--afb                SWITCH(me, me.lbl_e)
--afb            end
--afb            LINE(me, [[}]])

--			LINE(me,'exp_ubyte '..c.val)
			CONC(me,c)
			if me.lbl_f then
				codeB = LINE(me, 'ifelse '..me.lbl_t.id..' '..me.lbl_f.id,nil,'// ifelse ')
				BYTECODE(me,codeB,'op_ifelse',me.lbl_t.n,me.lbl_f.n)
			else
				codeB = LINE(me, 'ifelse '..me.lbl_t.id..' '..me.lbl_e.id,nil,'// ifelse')			
				BYTECODE(me,codeB,'op_ifelse',me.lbl_t.n,me.lbl_e.n)
			end
--        end

        CASE(me, me.lbl_t)
        CONC(me, t, 4)
        SWITCH(me, me.lbl_e)

        if me.lbl_f then
            CASE(me, me.lbl_f)
            CONC(me, f, 4)
            SWITCH(me, me.lbl_e)
        end
        CASE(me, me.lbl_e)
    end,

    Async_pos = function (me)
        local vars,blk = unpack(me)
        for _, n in ipairs(vars) do
            --ATTR(me, n.new, n[1].var)
--            EXP(me, n)
--print(print_r(n.new,"code:Async_pos: n.new"))
--print("code::Async_pos:",n.new[1].id,n.new[1].tp,n.new[1].val,n[1].var.tp,n[1].var.id,n[1].var.val)
            codeB = LINE(me,n.new[1].id .."'=".. n[1].var.id,nil,'// SetExp:: set var=var')        
            BYTECODE(me,codeB,'op_set_v',n.new[1].tp,n[1].var.tp,n.new[1].val,n[1].var.val)
        end
--        LINE(me, 'ceu_async_enable('..me.gte..', '..me.lbl.id..');')
        codeB = LINE(me, 'ceu_async_enable '..me.gte..' '..me.lbl.id,nil,'// async enable')      
        BYTECODE(me,codeB,'op_asen',me.gte,me.lbl.n)

        HALT(me)
        CASE(me, me.lbl)
--        if _OPTS.analysis_run then
--            -- skip `blk´ on analysis
--            local set = _AST.iter()()       -- requires `Async_pos´
--            if set.tag == 'SetBlock' then
--                SWITCH(me, set.lbl_out)
--            end
--        else
            CONC(me, blk)
--        end
    end,

    Loop = function (me)
        local body = unpack(me)

--        COMM(me, 'Loop ($0):')
        CASE(me, me.lbl_ini)
        CONC(me, body)

--        if _OPTS.analysis_run then         -- verifies the loop "loops"
--            SWITCH(me, me.lbl_ana_mid)
--            CASE(me, me.lbl_ana_mid)
--        end

        local async = _AST.iter'Async'()
        if async then
          codeB = LINE(me, 'ceu_async_enable '..async.gte..' '..me.lbl_ini.id,nil,'// async enable')      
          BYTECODE(me,codeB,'op_asen',async.gte,me.lbl_ini.n)
          HALT(me)
--            LINE(me, [[
--#ifdef ceu_out_pending
--if (ceu_out_pending()) {
--#else
--{
--#endif
--    ceu_async_enable(]]..async.gte..', '..me.lbl_ini.id..[[);
--    break;
--}
--]])
        end

        -- a single iter is enough on analysis a tight loop
--        if (not _OPTS.analysis_run) or me.blocks then
            SWITCH(me, me.lbl_ini)
--        end

        BLOCK_GATES(me)
    end,

    Break = function (me)
        local top = _AST.iter'Loop'()
        if _AST.iter'Finally'() then
            SWITCH(me, top.lbl_out)     -- can't use prios inside a `finally´
        else
--            LINE(me, 'ceu_track_ins(CEU->stack,' ..top.lbl_out.tree..', 1,'
--                        ..top.lbl_out.id..');')
--print("code::Break:",top.lbl_out.tree,top.lbl_out.n)
          codeB = LINE(me, 'insert track '.. top.lbl_out.id .. ' tree '.. top.lbl_out.tree,nil,'// Break:: ')
          BYTECODE(me,codeB,'op_tkins_z',1,top.lbl_out.tree,top.lbl_out.n)
        end
        HALT(me)
    end,

    Pause = function (me)
        local exp, blk = unpack(me)
        CONC(me,blk)
    end,

-- afb: Not implemented in Terra
--    CallStmt = function (me)
--        local call = unpack(me)
--        EXP(me, call)
--        if not _OPTS.analysis_run then
--            LINE(me, call.val..';')
--        end
--    end,

    EmitExtS = function (me)
        local e1, e2 = unpack(me)
        local ext = e1.ext
    if ext.pre == 'output' then  -- e1 not Exp
        if (e2) then
          -- get event type data len
          local par_len,par_tp
          par_tp = (_TP.deref(e2[1].tp) and 'ushort') or e2[1].tp -- force 2 bytes pointer.
          par_len = (_ENV.c[par_tp] and _ENV.c[par_tp].len) or 0

          local x1 = getAuxValues(e2);

          if(e2[1].tag=='CONST') then
            codeB = LINE(me,'emit '..e1.ext.id..' len='..par_len..' const='..e2[1].val,nil,'// EmitExtS:: const ')
            local auxval = (e2[1].tp=='float' and _TP.float2hex(tonumber(e2[1].val))) or e2[1].val
            BYTECODE(me,codeB,'op_outevt_c',e1.ext.idx,auxval)
          elseif (x1.auxtag2=='Var' and _TP.deref(e1.ext.tp)) then
            codeB = LINE(me,'emit '..e1.ext.id..' len='..par_len..' var='..x1.id,nil,'// EmitExtS:: var')
            BYTECODE(me,codeB,'op_outevt_v',e1.ext.idx,x1.val, par_tp)
          elseif (_ENV.packets[e1.ext.tp]) then
            codeB = LINE(me,'emit '..e1.ext.id..' len='..par_len..' var='..x1.id,nil,'// EmitExtS:: var')
            BYTECODE(me,codeB,'op_outevt_v',e1.ext.idx,e2.val, 'ushort')

--          elseif (e2[1].tag=='Var' and not _TP.deref(e2[1].tp)) then -- not pointer 
--            codeB = LINE(me,'emit '..e1.ext.id..' len='..par_len..' var='..e2[1][1],nil,'// EmitExtS:: var')
--            BYTECODE(me,codeB,'op_outevt_v',e1.ext.seq,e2[1].val, par_tp)
--          elseif (e2[1].tag=='Var' and _TP.deref(e2[1].tp)) then -- pointer 
--            CONC(me,me[2])
--            codeB = LINE(me,'emit '..e1.ext.id,nil,'// EmitExtS::')
--            BYTECODE(me,codeB,'op_outevt_e',e1.ext.idx)
--          elseif (e2[1].tag=='Op1_&' and e2[1][2].tag=='Var') then -- &Var 
--            codeB = LINE(me,'emit '..e1.ext.id..' len='..par_len..' var='..e2[1][2][1],nil,'// EmitExtS:: var')
--            BYTECODE(me,codeB,'op_outevt_v',e1.ext.seq,e2[1][2].val, par_tp)
          else -- as expression
            CONC(me,me[2])
            codeB = LINE(me,'emit '..e1.ext.id,nil,'// EmitExtS::')
            BYTECODE(me,codeB,'op_outevt_e',e1.ext.idx)
          end
        else
          codeB = LINE(me,'emit '..e1.ext.id ,nil,'// EmitExtS:: void ')
          BYTECODE(me,codeB,'op_outevt_z',e1.ext.idx)
        end

     else
      ASR(false,me,'Emit INPUT_EVENT inside Async is not implemented.')
--        assert(ext.pre == 'input')
--        local async = _AST.iter'Async'()
--        LINE(me, 'ceu_async_enable('..async.gte..', '..me.lbl_cnt.id..');')
--        if e2 and (not _OPTS.analysis_run) then
--            if _TP.deref(ext.tp) then
--                LINE(me, 'return ceu_go_event(ret, IN_'..ext.id
--                        ..', (void*)'..e2.val..');')
--            else
--                LINE(me, 'return ceu_go_event(ret, IN_'..ext.id
--                        ..', (void*)ceu_ext_f('..e2.val..'));')
--            end
--
--        else
--            LINE(me, 'return ceu_go_event(ret, IN_'..ext.id ..', NULL);')
--        end
--        CASE(me, me.lbl_cnt)
    end
    return 

    end,

    EmitT = function (me)
    	ASR(false,me,'"EmitT" is not implemented.')

--        local exp = unpack(me)
--        local async = _AST.iter'Async'()
--        EXP(me, exp)
--        LINE(me, [[
--ceu_async_enable(]]..async.gte..', '..me.lbl_cnt.id..[[);
--#ifdef CEU_WCLOCKS
--{ long nxt;
--  int s = ceu_go_wclock(ret,]]..exp.val..[[, &nxt);
--  while (!s && nxt<=0)
--      s = ceu_go_wclock(ret, 0, &nxt);
--  return s;
--}
--#else
--return 0;
--#endif
--]])
 --       CASE(me, me.lbl_cnt)
    end,

  EmitInt = function (me)
    local int, exp = unpack(me)
    --        COMM(me, 'emit '..int.var.id)

--    CONC(me,exp)
--    codeB = LINE(me,'emit '..int.fst.id..' from stack',nil,'// EmitInt:: pop to ')          
--    BYTECODE(me,codeB,'op_pop',int.tp,int.val)  

    -- attribution
    if exp then
--print("code::EmitInt:",int.fst.id,exp[1].tag,typelen[int.tp], typelen[exp.tp])      
      --afb  		ATTR(me, int, exp)
      if (exp[1].tag == "CONST") then
        if (typelen[int.tp] >= typelen[exp.tp]) then
          codeB = LINE(me,'emit '..int.var.id..'('..exp.val..')',nil,'// EmitInt:: Const')
          local auxval = (exp.tp=='float' and _TP.float2hex(tonumber(exp.val))) or exp.val
          BYTECODE(me,codeB,'op_set_c',int.tp,int.val,auxval)
        else
          CONC(me,exp)
          codeB = LINE(me,'emit '..int.fst.id..' from stack',nil,'// EmitInt:: pop to ')					
          BYTECODE(me,codeB,'op_pop',int.tp,int.val)	
        end
      elseif (exp[1].tag == "Var") then
        if (typelen[int.tp] == typelen[exp.tp]) then
          codeB = LINE(me,'emit '..int.var.id..'('..exp[1][1]..')',nil,'// EmitInt:: Var')
          BYTECODE(me,codeB,'op_set_v',int.tp,exp.tp,int.val,exp.val)
        else
          CONC(me,exp)
          codeB = LINE(me,'emit '..int.fst.id..' from stack',nil,'// EmitInt:: pop to ')          
          BYTECODE(me,codeB,'op_pop',int.tp,int.val)  
        end
      else -- is Expression
          CONC(me,exp)
          codeB = LINE(me,'emit '..int.fst.id..' from stack',nil,'// EmitInt:: pop to ')          
          BYTECODE(me,codeB,'op_pop',int.tp,int.val)  
      end
    end
--
--    -- emit vs await
--    if _OPTS.analysis_run then -- int not Exp
--      if exp then
--        EXP(me, exp)
--      end
--      SWITCH(me, me.lbl_ana_emt)
--      CASE(me, me.lbl_ana_emt)
--    end

    -- defer match: reaction must have a higher stack depth
    --        LINE(me, '//> ceu_track_ins(CEU->stack+2, CEU_TREE_MAX, 0,'
    --                    ..me.lbl_mch.id..');')
    codeB = LINE(me, 'insert track '.. me.lbl_mch.id,nil,'// EmitInt:: defer match')
    BYTECODE(me,codeB,'op_tkins_max',2,me.lbl_mch.n)
    -- defer continuation: all trails must react before I resume
    --        LINE(me, '//> ceu_track_ins(CEU->stack+1, CEU_TREE_MAX, 0,'
    --                    ..me.lbl_cnt.id..');')
    codeB = LINE(me, 'insert track '.. me.lbl_cnt.id,nil,'// EmitInt:: defer continuation')
    BYTECODE(me,codeB,'op_tkins_max',1,me.lbl_cnt.n)
    HALT(me)

    -- emit
    CASE(me, me.lbl_mch)
    --        LINE(me, '//> ceu_trigger('..int.var.awt0..');')
    codeB = LINE(me, 'trigger '..int.var.id,nil,'// EmitInt:: trigger')
    BYTECODE(me,codeB,'op_trg',int.var.awt0)

    HALT(me)

    -- continuation
    CASE(me, me.lbl_cnt)
    SWITCH(me, me.lbl_ana_cnt)
    CASE(me, me.lbl_ana_cnt)
  end,

  AwaitInt = function (me)
    local int, zero = unpack(me)
    if not zero then
      codeB = LINE(me, 'insert track '.. me.lbl_awt.id,nil,'// AwaitInt:: defer await')
      BYTECODE(me,codeB,'op_tkins_max',0,me.lbl_awt.n)
      HALT(me)
    end

    -- await
    CASE(me, me.lbl_awt)
    --        LINE(me, '//> *PTR(tceu_nlbl*,'
    --                    ..(int.var.awt0+1+me.gte*_ENV.c.tceu_nlbl.len)
    --                    ..') = '..me.lbl_awk.id..';')
    codeB = LINE(me, 'await '..me.lbl_awk.id,nil,'// AwaitInt:: wait')
    BYTECODE(me,codeB,'op_set_c','ushort',(int.var.awt0+1+me.gte*_ENV.c.tceu_nlbl.len),me.lbl_awk.n,true)

    HALT(me)

    -- awake
    CASE(me, me.lbl_awk)

-- mover para ???
--      codeB = LINE(me,'push$ '..me.id..':'..me.tp,nil,'// push Var ')
--      BYTECODE(me,codeB,'op_push_v',me.tp,me.val)

  end,

    AwaitN = function (me)
--        COMM(me, 'Never')
        HALT(me)
    end,
    AwaitT = function (me)
        local exp = unpack(me)
        CONC(me, exp)
        local val = exp.val
--        if _OPTS.analysis_run and
--            (exp.tag=='WCLOCKE' or exp.tag=='WCLOCKR') then
--            val = 'CEU_WCLOCK_ANY'
--        end
--        LINE(me, '//> ceu_wclock_enable('..me.gte..', '..val
--                    ..', '..me.lbl.id..');')
--        LINE(me, 'clken '.._TP.getConstType(me.gte,me)..' '..me.gte..' '.._TP.getConstType(val,me)..' '..val..' '.._TP.getConstType(me.lbl.n,me)..' '..me.lbl.n,nil,'// AwaitT '..me.lbl.id)


--print("code::AwaitT:",exp.tag)
		if (exp.tag=='WCLOCKK') then
     	codeB = LINE(me, 'clock enable '..me.lbl.id..' '..exp.ms..'msec',nil,'// AwaitT ')
			BYTECODE(me,codeB,'op_clken_c',me.gte,exp.ms,me.lbl.n)
		else
--print("code::AwaitT:",exp.tag,unpack(exp[1][1]))
			if (exp[1][1].tag=='Var') then
       	codeB = LINE(me, 'clock enable '..me.lbl.id..' ('.. exp[1][1][1]..':'..exp[1].tp ..')' .. exp[2],nil,'// AwaitT ')
				BYTECODE(me,codeB,'op_clken_v',me.gte,_MEM.t2idx[exp[2]],exp[1].tp,exp[1].val,me.lbl.n)
			else
--				ASR(false,me,'cannot use expressions in "await". ')
        CONC(me,exp[1])
        codeB = LINE(me, 'clock enable '..me.lbl.id..' '.. '(stack)' .. exp[2],nil,'// AwaitT ')
        BYTECODE(me,codeB,'op_clken_e',me.gte,_MEM.t2idx[exp[2]],me.lbl.n)
			end
		end
        HALT(me)
        CASE(me, me.lbl)
    end,
    
    AwaitExt = function (me)
        local e1,e2 = unpack(me)
--print("code::AwaitExt: ",e1.ext.idx,e1.ext.n,me.gte,me.lbl.n,_MEM.gtes[e1.ext.n])
--        LINE(me, '//> *PTR_EXT(IN_'..e1.ext.id..','..me.gte..') = '..me.lbl.id..';')

        if not e1.ext.inArg then -- evtId, nGtes, [addr]*
          codeB = LINE(me, 'await '..e1.ext.id..'['..me.gte..']',nil,'// AwaitExt:: ')
          BYTECODE(me,codeB,'op_set_c','ushort',(_MEM.gtes[e1.ext.n]+2+(me.gte*2)),me.lbl.n,true)
        else -- evtId, nGtes, [idAux,addr]*
          CONC(me,e2)
          codeB = LINE(me, 'evt '..e1.ext.id..' auxId = pop',nil,'// AwaitExt:: ')
          BYTECODE(me,codeB,'op_pop','ubyte', (_MEM.gtes[e1.ext.n]+2+(me.gte*3))) 
          codeB = LINE(me, 'await '..e1.ext.id..'['..me.gte..']',nil,'// AwaitExt:: ')
          BYTECODE(me,codeB,'op_set_c','ushort',(_MEM.gtes[e1.ext.n]+2+1+(me.gte*3)),me.lbl.n,true)
        end

        HALT(me) 
        CASE(me, me.lbl)
    end,
--[[
    Op2_call = function (me)
        local _, f, exps = unpack(me)
--print(print_r(me,"code::Op2_call: me"))
        ASR(false,me,'"call" is not implemented! ')
    end,
--]]    
    ['Op2_-'] = function (me) Op2_any(me,'sub') end,  
    ['Op2_+'] = function (me) Op2_any(me,'add') end,  
    ['Op2_%']   = function (me) Op2_any(me,'mod') end,
    ['Op2_*']   = function (me) Op2_any(me,'mult') end,
    ['Op2_/']   = function (me) Op2_any(me,'div') end,
    ['Op2_|']   = function (me) Op2_any(me,'bor') end,
    ['Op2_&']   = function (me) Op2_any(me,'band') end,
    ['Op2_<<']  = function (me) Op2_any(me,'lshft') end,
    ['Op2_>>']  = function (me) Op2_any(me,'rshft') end,
    ['Op2_^']   = function (me) Op2_any(me,'bxor') end,
    ['Op2_==']  = function (me) Op2_any(me,'eq') end,
    ['Op2_!=']  = function (me) Op2_any(me,'neq') end,
    ['Op2_>=']  = function (me) Op2_any(me,'gte') end,
    ['Op2_<=']  = function (me) Op2_any(me,'lte') end,
    ['Op2_>']   = function (me) Op2_any(me,'gt') end,
    ['Op2_<']   = function (me) Op2_any(me,'lt') end,
    ['Op2_or']  = function (me) Op2_any(me,'lor') end,
    ['Op2_and'] = function (me) Op2_any(me,'land') end,
    
    ['Op1_~']   = function (me) Op1_any(me,'bnot') end,
    ['Op1_-']   = function (me) Op1_any(me,'neg') end, 
    ['Op1_not']  = function (me) Op1_any(me,'lnot') end,

--    ['Op1_*'] = function (me)
--        local op, e1, e2 = unpack(me)
--        local tp = (_TP.deref(_TP.deref(e1.tp)) and 'ushort') or (_TP.deref(e1.tp) or e1.tp)
----print("code::Op1_*:",e1.tag,e1.val,e1.tp,tp,e1[1])
--		ASR(not _TP.deref(_TP.deref(e1.tp)),me,'"**Var" is not implemented! ')
--    ASR(_TP.isBasicType(tp),me,'type of "'..e1[1]..'" is not a basic type.')
--    CONC(me,e1)
--    codeB = LINE(me,'deref_ *'..e1[1],nil,'// Op1_*(push pointer content):: ')
--    BYTECODE(me,codeB,'op_deref',tp)
--    end,
    
  ['Op2_.'] = function (me)
    local op, e1, id = unpack(me)
    local field = _ENV.c[_TP.deref(e1.tp) or e1.tp].fields[id]
--print('________________________________________________________')
--print('code:Op2_.::',me.val,me.tp, e1.tag,e1.val,e1.tp,id)
--print('code:Op2_.::',me.fst.val, id,field.offset,field.tp,field.arr)
--print(print_r(me,'code::Op2_.:me'))
--print('--------------------------------------------------------')

    if _TP.deref(e1.tp) then
      CONC(me,e1) -- Reg Addr
      if (field.offset > 0) then -- 'add' only if offset > 0
        codeB = LINE(me,'push '..id ..' offset',nil,'// (push field position offset):: ')
        BYTECODE(me,codeB,'op_push_c',field.offset)
        codeB = LINE(me,'add: reg addr + field offset')
        BYTECODE(me,codeB,'op2_any','add')
      end
    else -- push varAddr+FieldPos
      codeB = LINE(me,'push '..e1[1]..'.'..id,nil,'// push &Var ')
      BYTECODE(me,codeB,'op_push_c',e1.val+field.offset)
    end
  end,
    
  ['Op1_&'] = function (me)
    local op, e1 = unpack(me)
--print("code::Op1_&",e1.tag)
    if e1.tag == 'Var' then
      codeB = LINE(me,'push &'..e1[1],nil,'// push &Var ')
      BYTECODE(me,codeB,'op_push_c',e1.val)
    else
      CONC(me,e1)
    end
  end,

  Op_var = function (me)
    local op, exp = unpack(me)
    if exp.tag == 'Var' then
--print("code::Op_var: Var",op,exp.var.id,exp.var.val,exp.tp)
      codeB = LINE(me,'push &'..exp[1],nil,'// push &Var ')
      BYTECODE(me,codeB,'op_push_c',exp.val)
    else
--print("code::Op_var: Var",op,exp[2][1],exp[3],exp.tp)
      CONC(me,exp)
    end
    codeB = LINE(me,op..' '..exp.tp,nil,'// Op_var <type> ')
    BYTECODE(me,codeB,'op_'..op,exp.tp)
  end,

  Op1_cast = function (me)
    local tp, exp = unpack(me)
    CONC(me,exp)
    local fromTp = ((exp.tp=='ubyte' or exp.tp=='ushort' or exp.tp=='ulong') and 'ulong') or ((exp.tp=='byte' or exp.tp=='short' or exp.tp=='long') and 'long') or 'float'  
    local toTp = ((tp=='ubyte' or tp=='ushort' or tp=='ulong') and 'ulong') or ((tp=='byte' or tp=='short' or tp=='long') and 'long') or 'float'  
    codeB = LINE(me,'cast '..fromTp..' '..toTp,nil,'// cast <type> ')
--print("code::Op1_cast:",tp,exp.tp,fromTp,toTp)
    if (fromTp~=toTp and (fromTp=='float' or toTp=='float')) then
      BYTECODE(me,codeB,'op_cast',fromTp,toTp)
    else
      WRN(false,me, 'Discarding ineffective "cast" from '..fromTp..' to '..toTp..'.')    
    end
  end,
  ['SIZEOF'] = function (me)
    --      LINE(me,'push '..me.tp..' '.. me[1]..'   // CONST| '..me[1])
    --      codeB = LINE(me,'push_c '.._TP.getConstLen(me[1])..' '..me[1],nil,'// push '.. me.tp ..' '.. me[1]..' :: CONST| '..me[1])
    codeB = LINE(me,'push '..me.val,nil,'// push sizeof<> ')
    BYTECODE(me,codeB,'op_push_c',me.val)
  end, 
  ['CONST'] = function (me)
    --    	LINE(me,'push '..me.tp..' '.. me[1]..'   // CONST| '..me[1])
    --    	codeB = LINE(me,'push_c '.._TP.getConstLen(me[1])..' '..me[1],nil,'// push '.. me.tp ..' '.. me[1]..' :: CONST| '..me[1])
    codeB = LINE(me,'push '..me[1],nil,'// push Const ')
    local auxval = (me.tp=='float' and _TP.float2hex(tonumber(me[1]))) or me[1]
--print("code::CONST:",me.tp,me[1],auxval)
    BYTECODE(me,codeB,'op_push_c',auxval)
  end,  
  
  ['Var'] = function (me)
    --		ASR(typelen[me.var.tp] or _TP.deref(me.var.tp),me,'must use custom type only as pointer.')
    local tp = (_TP.deref(me.var.tp) and 'ushort') or me.var.tp
--print("Code::Var:",me.var.id,me.var.tp,tp,me.var.arr,_TP.isBasicType( _TP.deref(me.var.tp) or me.var.tp))
    if _TP.isBasicType( (_TP.deref(me.var.tp) and _TP.deref(_TP.deref(me.var.tp))) or _TP.deref(me.var.tp) or me.var.tp) then
      if me.var.arr then -- needs addr
        codeB = LINE(me,'push_c &'..me.var.id..':'..me.var.tp,nil,'// push &Var ')
        BYTECODE(me,codeB,'op_push_c',me.var.val)
      else -- needs value
        codeB = LINE(me,'push '..me.var.id..':'..me.var.tp,nil,'// push Var ')
        BYTECODE(me,codeB,'op_push_v',tp,me.var.val)
      end
    else -- is a register var/pointer
      if _TP.deref(me.var.tp) then -- is a register pointer
        codeB = LINE(me,'push '..me.var.id..':'..me.var.tp,nil,'// push Var ')
        BYTECODE(me,codeB,'op_push_v',tp,me.var.val)
      else -- is a register var = addr
        codeB = LINE(me,'push_c &'..me.var.id..':'..me.var.tp,nil,'// push &Var ')
        BYTECODE(me,codeB,'op_push_c',me.var.val)
      end
    end
  end,
  
  LExp = function (me)
--print("code::LExp:",me[1].tag,me[1].tp,(_TP.deref(me[1].tp) and 'ushort') or me[1].tp,me.tp,me[1][2].tag,me.val)
    local tp = (_TP.deref(me[1].tp) and 'ushort') or me[1].tp
    if (me[1].code=="") then me[1].code='TODO' end -- ???? very old!! why??
    if me[1].tag=='Var' then
        codeB = LINE(me,'push_c &'..me[1][1]..':'..tp,nil,'// push Var ')
        BYTECODE(me,codeB,'op_push_c',me.val)
--    elseif me[1].tag == 'Op1_*' then
--      CONC(me,me[1][2]); -- Ignore this "Op1_*"  
    else
      CONC(me,me[1]);
    end
  end,

  Exp = function (me)
--print("code::Exp:",me[1].tag,me[1].tp,(_TP.deref(me[1].tp) and 'ushort') or me[1].tp,me.tp,me[1].arr)
    local tp = (_TP.deref(me[1].tp) and 'ushort') or me[1].tp
--    ASR(not me[1].arr,me,'missing array index.')
    if (me[1].code=="") then me[1].code='TODO' end
    CONC(me,me[1]);
    if (not me[1].arr)  then tryDerefCode(me,me[1].tag,me[1].tp) end
  end,
  
  ExpList = function (me)
--print("code::ExpList:",me[1].tag)
--print(print_r(me,"code::ExpList: me"))
    for k,arg in ipairs(me) do
--print("code::ExpList: arg=",k, arg.tag,arg.tp)    
      CONC(me,arg);
    end
  end,

  -- Terra call --- function without attribution
  Call = function (me)
    CONC(me,me[2]);
    codeB = LINE(me,'popx ',nil,'')
    BYTECODE(me,codeB,'op_popx')
  end,

  Func = function (me)
--print("code::Func:",me.ext.id, me.ext.tp,me.ext.idx)
--print("code::Func: args:",#me[2],#me.ext.args)
    ASR(#me[2]==#me.ext.args,me,'invalid number of arguments for function ['.. me.ext.id ..'], received '.. #me[2] .. ' and it was expecting '..#me.ext.args  )
    for k,arg in ipairs(me.ext.args) do
      local error, cast, ntp1, ntp2, len1, len2 =  _TP.tpCompat(arg,(me[2][k].supertp or me[2][k].tp))
      ASR(not error ,me,'argument #'..k ..' in function ['.. me.ext.id ..'] must be compatible to "'.. arg.. '/'.. len1 ..'" type, it received "'.. (me[2][k].supertp or me[2][k].tp) ..'/'.. len2 .. '" type')
      WRN(not cast,me, 'Applying the minimum size: "'.. arg..'/'..len1 ..'" <--> "' .. me[2][k].tp ..'/'..len2 ..'". ')
    end
    CONC(me,me[2]);
    codeB = LINE(me,'func '..me.ext.id,nil,'')
    BYTECODE(me,codeB,'op_func',me.ext.idx)
  end,
  
  Op2_idx = function (me)
    local _, arr, idx = unpack(me)
    local idx_tp = (_TP.deref(idx.tp) and 'ushort') or idx.tp
--print(print_r(me,"code::Op2_idx: me"))
--print("code::Op2_idx:",arr.tag,arr.tp,arr.arr,idx.val, idx_tp)
--print("code::Op2_idx:",idx.tag,arr.tp,me.tp,arr.val,idx.val,me[2][1],me[2][2])
    ASR(_TP.isBasicType( _TP.deref(_TP.deref(arr.tp)) or _TP.deref(arr.tp)),me,'Arrays can have only basic types.')

    if (arr.tag == 'Var') and (idx.tag=='CONST') then  -- push direct the addr+idx
        ASR((idx.val*1 < arr.arr*1),me,'array index out of range, 0..'.. arr.arr-1 ..'.')
        codeB = LINE(me,'push_c &'..arr[1]..'['..idx.val..']',nil,'')
        BYTECODE(me,codeB,'op_push_c',arr.val+(idx.val*(_ENV.c[_TP.deref(_TP.deref(arr.tp)) or _TP.deref(arr.tp)].len)))  
    elseif (arr.tag == 'Var') and (idx.tag=='Var') then  -- push direct the addr and idx
        codeB = LINE(me,'pusharr_v &'..arr[1]..'['..idx[1]..']',nil,'')
        BYTECODE(me,codeB,'op_pusharr_v',_TP.deref(arr.tp),idx.tp,idx.val,arr.arr*1,arr.val)  
    elseif (arr.tag == 'Op2_.')  and not(_TP.deref(arr[2].tp)) and (idx.tag=='CONST') then  -- push direct the var.field addr + idx
        ASR((idx.val*1 < arr.arr*1),me,'array index out of range, 0..'.. arr.arr-1 ..'.')
--print("code::Op2_idx: ",arr[2][1]..'.'..arr[3]..'['..idx.val..']', arr[2].val, arr[2].fst.fields[arr[3]].val, me.tp, (idx.val*_ENV.c[me.tp].len))
      codeB = LINE(me,'push_c '..arr[2][1]..'.'..arr[3]..'['..idx.val..']',nil,'')
      BYTECODE(me,codeB,'op_push_c',arr[2].fst.fields[arr[3]].val + (idx.val*_ENV.c[me.tp].len))  
    else
      CONC(me,arr) -- var addr
      if (idx.tag=='CONST') then -- Constant can have a small code
        ASR((idx.val*1 < arr.arr*1),me,'array index out of range, 0..'.. arr.arr-1 ..'.')
        if (idx.val*1) > 0 then -- push only idx > 0
          codeB = LINE(me,'push_c '..'['..idx.val..'] offset',nil,'')
--          BYTECODE(me,codeB,'op_push_c',(idx.val*_ENV.c[idx_tp].len))  
          BYTECODE(me,codeB,'op_push_c',(idx.val*(_ENV.c[_TP.deref(_TP.deref(arr.tp)) or _TP.deref(arr.tp)].len)))  
          codeB = LINE(me,'add: array base addr + len position')
          BYTECODE(me,codeB,'op2_any','add')
        end
      else
        codeB = LINE(me,'push idx max '..arr.arr,nil,'// push array max idx')
        BYTECODE(me,codeB,'op_push_c',arr.arr)
        CONC(me,idx); -- idx
        codeB = LINE(me,'mod: limmit idx')
        BYTECODE(me,codeB,'op2_any','mod')
        codeB = LINE(me,'push var len '.._TP.deref(arr.tp),nil,'// push array var len')
        BYTECODE(me,codeB,'op_push_c',_ENV.c[_TP.deref(_TP.deref(arr.tp)) or _TP.deref(arr.tp)].len)
        codeB = LINE(me,'mult: varlen * idx')
        BYTECODE(me,codeB,'op2_any','mult')
        codeB = LINE(me,'add: array base addr + len position')
        BYTECODE(me,codeB,'op2_any','add')
      end
    end
  end   
}
_AST.visit(F)
