
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

function ATTR (me, n1, n2)
    if not _OPTS.analysis_run then
        LINE(me,'//> '..n1.val..' = '..n2.val..';')
        LINE(me,n2.code..' // TODO ? pop_'..n1.tp..n1.code..';')
    end
end

function EXP (me, e)
    if _OPTS.analysis_run and e.accs then
        for _, acc in ipairs(e.accs) do
            SWITCH(me, acc.lbl_ana)
            CASE(me, acc.lbl_ana)
        end
    end
end

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
    codeB = LINE(me,'goto '.._TP.getConstType(lbl.n,me.ln)..' '..lbl.n, nil,'// goto '..lbl.id)
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
		        BYTECODE(me,codeB,'op_memclr', n*_ENV.c.tceu_nlbl.len, _MEM.gtes[ext.n]+1)
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
        codeB = LINE(me, 'clear tracks from label '..me.lbls_emt[1]..' to label '..me.lbls_emt[2],nil,'// do not resume inner EMITS continuations (await/emit)') 
		BYTECODE(me,codeB,'op_tkclr',me.lbls_emt[1],me.lbls_emt[2])
    end
end

function PAUSE (me, N, PTR)
    if me.more then
        LINE(me, [[
{ short i;
for (i=0; i<]]..N..[[; i++) {
    if (]]..PTR..'['..i..']'..[[ >= Init) {
        ]]..PTR..'['..i..']'..[[ = Init-1;
    } else {
        ]]..PTR..'['..i..']'..[[--;
    }
} }
]])
    else
        LINE(me, [[
{ short i;
for (i=0; i<]]..N..[[; i++) {
    if (]]..PTR..'['..i..']'..[[ >= Init) {
        ]]..PTR..'['..i..']'..[[ = Init-1;
    } else {
        ]]..PTR..'['..i..']'..[[--;
    }
} }
]])
    end
end

function Op1_any(me,mnemonic)
        local op, e1 = unpack(me)
		CONC(me,e1)
       	codeB = LINE(me,mnemonic,nil,'// stack0 = '..mnemonic..'(stack0)')
       	BYTECODE(me,codeB,'op1_any',mnemonic)
end

function Op2_any(me,mnemonic)
    local op, e1, e2 = unpack(me)
--print("code::Op2_any:",op,e1.tag,e2.tag)
	CONC(me,me[3])
	CONC(me,me[2])
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
    codeB = LINE(me, 'clear all gates',nil,'// Clear the gates ') 
    BYTECODE(me,codeB,'op_memclr', _MEM.gtes.loc0, 0)
    for _,ext in ipairs(_ENV.exts) do
      if ((ext.pre == 'input') and ((_ENV.awaits[ext] or 0) >0)) then  -- save code to write 0
        --                LINE(me, '//> *PTR(ubyte*,IN_'..ext.id..') = '
        --                            ..(_ENV.awaits[ext] or 0)..';')
        -- event Id
        codeB = LINE(me, 'config gate '..ext.id..' idx= '..ext.idx ..' ',nil,'// Config gate idx')
        BYTECODE(me,codeB,'op_set_c','ubyte',_MEM.gtes[ext.n],ext.idx)
        -- qtd gates
        codeB = LINE(me, 'config gate '..ext.id..' with '..(_ENV.awaits[ext] or 0)..' await(s)',nil,'// Config gate')
        BYTECODE(me,codeB,'op_set_c','ubyte',_MEM.gtes[ext.n]+1,(_ENV.awaits[ext] or 0))
      end
    end

    CONC_ALL(me)

    if _OPTS.analysis_run then
      SWITCH(me, me.lbl_ana)
      CASE(me, me.lbl_ana)
    end

    if not (_OPTS.analysis_use and _ANALYSIS.isForever) then
      local ret = _AST.root[1].vars[1]    -- $ret
      --afb            LINE(me, 'if (ret) *ret = '..ret.val..';')
      codeB = LINE(me, 'end program',nil,'// end; ')
      BYTECODE(me,codeB,'op_end')
--      codeB = LINE(me, 'return',nil,'// return 1; ')
--      BYTECODE(me,codeB,'op_return')
    end
    HALT(me)
  end,

  Host = function (me)
    _CODE.host = _CODE.host .. me[1] .. '\n'
  end,

  SetExp = function (me)
    local e1, e2 = unpack(me)
print("code::SetExp:",e1[1].tag,e2.tag,e2[1].tag,"\n".. e1.code)
--DBG('.......... <|'..e1.val..'|'..e2.val..'|> ')
--DBG('.......... <|'..e1.code..'|'..e2.code..'|> ')
--DBG('.......... <|'..e1.tag..'|'..e2.tag..'|> ')
--        COMM(me, 'SET: '..tostring(e1[1]))    -- Var or C
    EXP(me, e2)
    EXP(me, e1)

    --ATTR(me, e1, e2)
    --COMM(me,'e2-tag:'..e2[1].tag)
    x1={} x1.tp = e1.tp x1.val = e1.val
    CONC(me,e2)
    if e1[1].tag == 'Var' then
      codeB = LINE(me,'push &'..e1[1][1],nil,'// Op1_&(push var/array address):: ')
      BYTECODE(me,codeB,'op_push_c',e1[1].val)
    elseif e1[1].tag == 'Op2_idx' then
      idx = e1[1][3]
      arrvar = e1[1][2]
      tp = _TP.deref(arrvar.tp) or arrvar.tp 
      if _TP.deref(tp) then tp = 'ushort' end -- tp is a pointer
print("code::SetExp: op2_idx",arrvar[1], arrvar.tag,arrvar.tp,arrvar.fst.arr,idx.tag)
      if (idx.tag == 'CONST') then
        ASR(tonumber(idx.val) < tonumber(arrvar.fst.arr),me,'index >= array size')
        codeB = LINE(me,'push &'..arrvar.fst.id ..'['..idx[1] ..']',nil,'//  push array')
        BYTECODE(me,codeB,'op_push_c',arrvar.val+(idx.val*_ENV.c[tp].len))
      else -- Use stak operation
        codeB = LINE(me,'push &'..arrvar[1],nil,'// base addr')
        BYTECODE(me,codeB,'op_push_c',arrvar.val)
        CONC(me,idx);
        codeB = LINE(me,'push idx max '..arrvar.fst.arr,nil,'// push array max idx')
        BYTECODE(me,codeB,'op_push_c',arrvar.fst.arr)
        codeB = LINE(me,'mod: limmit idx')
        BYTECODE(me,codeB,'op2_any','mod')
        codeB = LINE(me,'push var len '..tp,nil,'// push array var len')
        BYTECODE(me,codeB,'op_push_c',_ENV.c[tp].len)
        codeB = LINE(me,'mult: varlen * idx')
        BYTECODE(me,codeB,'op2_any','mult')
        codeB = LINE(me,'add: array base addr + len position')
        BYTECODE(me,codeB,'op2_any','add')
      end    
    elseif e1[1].tag == 'Op2_.' then
      reg = e1[1][2]
      id = e1[1][3]
print("code::SetExp: op2_.",reg.tag, id)
      if (reg.tag == 'Var') then
        codeB = LINE(me,'push '..id ..' offset',nil,'// (push field position offset):: ')
        BYTECODE(me,codeB,'op_push_c',reg.fst.fields[id].var)
        codeB = LINE(me,'push '..reg[1] ..' addr',nil,'// (push reg addr):: ')
        BYTECODE(me,codeB,'op_push_c',e1[1].fst.val)
        codeB = LINE(me,'add: reg addr + field offset')
        BYTECODE(me,codeB,'op2_any','add')
      elseif (id.tag == 'Op2_idx') then
        codeB = LINE(me,'push '..id ..' offset',nil,'// (push field position offset):: ')
        BYTECODE(me,codeB,'op_push_c',reg.fst.fields[id].var)
  
        CONC(me,id)
        codeB = LINE(me,'push idx max '..e1[1].fst.arr,nil,'// push array max idx')
        BYTECODE(me,codeB,'op_push_c',e1[1].fst.arr)
        codeB = LINE(me,'mod: limmit idx')
        BYTECODE(me,codeB,'op2_any','mod')
        codeB = LINE(me,'push var len '..reg.tp,nil,'// push array var len')
        BYTECODE(me,codeB,'op_push_c',_ENV.c[reg.tp].len)
        codeB = LINE(me,'mult: varlen * idx')
        BYTECODE(me,codeB,'op2_any','mult')
        codeB = LINE(me,'add: array base addr + len position')
        BYTECODE(me,codeB,'op2_any','add')
  
        codeB = LINE(me,'add: reg-idx addr + field offset')
        BYTECODE(me,codeB,'op2_any','add')
      else
        ASR(false,me,'invalid var.field ')
      end
    else
      CONC(me,e1)
    end

    codeB = LINE(me,'set ('.. x1.tp ..')*(pop1) = pop2',nil,'// SetExp:: pop stk1 to stk2')         
    BYTECODE(me,codeB,'op_set_e',x1.tp)  


--    if (_TP.deref(e1.tp)) then x1.tp='ushort' end
--    if (e2[1].tag=='CONST' or e2[1].tag=='Var') then
--      x2={} x2.tp = e2.tp x2.val = e2.val
--      if (_TP.deref(e2.tp)) then x2.tp=_TP.getConstType(e2.fst.off,me.ln) x2.val=e2.fst.off end
--
--      if (e1.fst.arr) then
--        idx={} idx.tp = e1[1][3].tp idx.tag = e1[1][3].tag idx.val = e1[1][3].val idx.max = e1.fst.arr
--        if (e2[1].tag=='CONST') then
--          if (idx.tag == 'CONST') then
--            --afb					codeB = LINE(me,'setarr_cc '..x1.tp..' '..x1.val..' '..x2.tp..' '..x2.val,nil,'// SetExp:: '.. e1.fst.id ..' '..e1[1][3].val ..'='.. e2[1][1] ..' | set array <type> <base addr> <idx> <arr size> <value>')
--            --						BYTECODE(me,codeB,'op_setarr_cc',x1.tp,x1.val,idx.val,idx.max,x2.val)
--            -- it uses 'set_c' for constant index
--            codeB = LINE(me,''..e1.fst.id..'['..idx.val..'] = '..x2.val,nil,'// set array[idx] with constant')        
--            BYTECODE(me,codeB,'op_set_c',x1.tp,x1.val+(idx.val*_ENV.c[x1.tp].len),x2.val)
--          else
--            --						codeB = LINE(me,'setarr_vc '..x1.tp..' '..x1.val..' '..x2.tp..' '..x2.val,nil,'// SetExp:: '.. e1.fst.id ..' ['..e1[1][3].val ..']='.. e2[1][1] ..' | set array <type> <base addr> <idx> <arr size> <value>')
--            codeB = LINE(me,''..e1.fst.id..'['..e1[1][3][1]..'] = '..x2.val,nil,'// set array[var] with constant')        
--            BYTECODE(me,codeB,'op_setarr_vc',x1.tp,x1.val,idx.tp,idx.val,idx.max,x2.val)
--          end
--        else
--          if (e1[1][3].tag == 'CONST') then
--            --afb					codeB = LINE(me,'setarr_cv '..x1.tp..' '..x1.val..' '..x2.tp..' '..x2.val,nil,'// SetExp:: '.. e1.fst.id ..' '..e1[1][3].val ..'='.. e2[1][1] ..' | set array <type> <base addr> <idx> <arr size> <value>')
--            --						BYTECODE(me,codeB,'op_setarr_cv',x1.tp,x1.val,idx.val,idx.max,x2.tp,x2.val)
--            -- it uses 'set_v' for constant index
--            codeB = LINE(me,''..e1.fst.id..'['..idx.val..'] = '..e2[1][1],nil,'// set array[idx] with var')        
--            BYTECODE(me,codeB,'op_set_v',x1.tp,x1.val+(idx.val*_ENV.c[x1.tp].len),x2.val)
--          else
--            codeB = LINE(me,''..e1.fst.id..'['..e1[1][3][1]..'] = '..e2[1][1],nil,'// set array[var] with var')        
--            BYTECODE(me,codeB,'op_setarr_vv',x1.tp,x1.val,idx.tp,idx.val,idx.max,x2.tp,x2.val)
--          end
--        end
--      else
--        if (e2[1].tag=='CONST') then
--          if (typelen[x1.tp] >= typelen[x2.tp]) then
--            codeB = LINE(me,e1.fst.id ..' = '.. e2[1][1],nil,'// SetExp:: set var=const' )        
--            BYTECODE(me,codeB,'op_set_c',x1.tp,x1.val,x2.val)
--          else
--            CONC(me,e2)
--            codeB = LINE(me,'pop '..e1.fst.id,nil,'// SetExp:: pop to var')
--            BYTECODE(me,codeB,'op_pop',x1.tp,x1.val)	
--          end
--        else
--          if (typelen[x1.tp] == typelen[x2.tp]) then
--            codeB = LINE(me,e1.fst.id ..'='.. e2[1][1],nil,'// SetExp:: set var=var')        
--            BYTECODE(me,codeB,'op_set_v',x1.tp,x1.val,x2.val)
--          else
--            CONC(me,e2)
--            codeB = LINE(me,'pop '..e1.fst.id,nil,'// SetExp:: pop to var')					
--            BYTECODE(me,codeB,'op_pop',x1.tp,x1.val)	
--          end
--        end
--      end
--    else
--      if (e1.fst.arr) then
--        CONC(me,me[2])
--        idx={} idx.tp = e1[1][3].tp idx.tag = e1[1][3].tag idx.val = e1[1][3].val idx.max = e1.fst.arr
--        if (idx.tag=='CONST') then
--          --afb				codeB = LINE(me,'poparr_c '..x1.tp..' '..x1.val..' '..idx.tp..' '..idx.val..' '..idx.max,nil,'// SetExp:: '..e1.fst.id..'[?] | pop array <type> <base addr> <idx> <array size>')
--          --					BYTECODE(me,codeB,'op_poparr_c',x1.tp,idx.val,idx.max,x1.val)
--          -- it uses 'pop' for constant index
--          codeB = LINE(me,'pop '..e1.fst.id..'['..idx.val..']',nil,'// pop to var[idx]')
--          BYTECODE(me,codeB,'op_pop',x1.tp,x1.val+(idx.val*_ENV.c[x1.tp].len))	
--        else
--          codeB = LINE(me,'pop '..e1.fst.id..'[ '..e1[1][3][1]..']',nil,'// pop to var[var]')
--          BYTECODE(me,codeB,'op_poparr_v',x1.tp,idx.tp,idx.val,idx.max,x1.val)
--        end
--      else
--        CONC(me,me[2])
--        if (_TP.deref(e1.tp)) then
--          codeB = LINE(me,'pop *'..e1.fst.id,nil,'// SetExp:: pop to pointer')
--          BYTECODE(me,codeB,'op_pop','ushort',x1.val)	
--        else
--          codeB = LINE(me,'pop '..e1.fst.id,nil,'// SetExp:: pop to var')
--          BYTECODE(me,codeB,'op_pop',x1.tp,x1.val)	
--        end
--      end
--    end
  end,

  SetAwait = function (me)
    local e1, e2 = unpack(me)
--print("code::SetWait: tag",e2.tag)
--print(print_r(me,"code::SetWait: me"))
    CONC(me, e2)
    --ATTR(me, e1, e2.ret)

    if (e2.tag =="AwaitInt") then
      codeB = LINE(me,'push '..e2.id..':'..e2.tp,nil,'// push Var ')
      BYTECODE(me,codeB,'op_push_v',e2.tp,e2.val)
      CONC(me,e1)
      codeB = LINE(me,'set ('.. e1.tp ..')*(pop1) = pop2',nil,'// SetExp:: pop stk1 to stk2')         
      BYTECODE(me,codeB,'op_set_e',e1.tp)     
    else
      if _TP.deref(e1.tp) then
        codeB = LINE(me,'get Ext Data *'..e1[1][1]..' '..(_ENV.c[_TP.deref(e1.tp)].len),nil,'// getExtDtp <localVar pointer> <len>')
        BYTECODE(me,codeB,'op_getextdt_p',e1.val,_ENV.c[_TP.deref(e1.tp)].len)
      else
        codeB = LINE(me,'get Ext Data '..e1[1][1]..' '.._ENV.c[e1.tp].len,nil,'// getExtDt <localVarAddr> <len>')
        BYTECODE(me,codeB,'op_getextdt_v',e1.val,_ENV.c[e1.tp].len)
      end
    end	        

    EXP(me, e1)     -- after awaking
  end,

    SetBlock = function (me)
        local _,blk = unpack(me)
        CONC(me, blk)
        if _OPTS.analysis_run then
            SWITCH(me, me.lbl_ana_no)
            CASE(me, me.lbl_ana_no)
        end
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
            if var.isEvt then
--                LINE(me, '//> *PTR(ubyte*,'..var.awt0..') = '..var.n_awaits..';')  -- #gtes
                codeB = LINE(me, 'event '..var.id..' = '..var.n_awaits..' gates',nil,'// set event ')
				BYTECODE(me,codeB,'op_set_c','ubyte',var.awt0,var.n_awaits)
--                LINE(me, '//> memset(CEU->mem+'..var.awt0..'+1, 0, '   -- gtes[i]=0
--                        ..(var.n_awaits*_ENV.c.tceu_nlbl.len)..');')
				codeB = LINE(me, 'clear '.. var.id ..' '..var.n_awaits..' wait(s) ',nil,'// clear event waits') 
				BYTECODE(me,codeB,'op_memclr', var.n_awaits*_ENV.c.tceu_nlbl.len, var.awt0+1)
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
        if _OPTS.analysis_run then
            F.ParAnd(me)
            SWITCH(me, me.lbl_ana_no)
            CASE(me, me.lbl_ana_no)
            HALT(me)
            return
        end

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
			codeB = LINE(me,'if (gate '..(i-1)..' == 0) PC=PC+1',nil,'')
			BYTECODE(me,codeB,'op_chkret', (me.off+i-1))
            HALT(me)
        end

        if _OPTS.analysis_run then
            SWITCH(me, me.lbl_ana_out)
            CASE(me, me.lbl_ana_out)
        end
    end,

    If = function (me)
        local c, t, f = unpack(me)
        -- TODO: If cond assert(c==ptr or int)
        if _OPTS.analysis_run then
--afb            EXP(me, c)
--afb            local id = (me.lbl_f and me.lbl_f.id) or me.lbl_e.id
--afb            LINE(me, [[
--afb CEU_ANA_PRE(1);
--afb ceu_track_ins(CEU->stack, CEU_TREE_MAX, 0, ]]..id..[[);
--afb CEU_ANA_POS();
--afb ]])
--afb            SWITCH(me, me.lbl_t);
        else
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
        end

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
--    	ASR(false,me,'"Async" is not implemented')
        local vars,blk = unpack(me)
        for _, n in ipairs(vars) do
            --ATTR(me, n.new, n[1].var)
            EXP(me, n)
--print(print_r(n.new,"code:Async_pos: n.new"))
--print("code::Async_pos:",n.new[1].id,n.new[1].tp,n.new[1].val,n[1].var.tp,n[1].var.id,n[1].var.val)
            codeB = LINE(me,n.new[1].id .."'=".. n[1].var.id,nil,'// SetExp:: set var=var')        
            BYTECODE(me,codeB,'op_set_v',n.new[1].tp,n.new[1].val,n[1].var.val)
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

        if _OPTS.analysis_run then         -- verifies the loop "loops"
            SWITCH(me, me.lbl_ana_mid)
            CASE(me, me.lbl_ana_mid)
        end

        local async = _AST.iter'Async'()
        if async then
        codeB = LINE(me, 'ceu_async_enable '..async.gte..' '..me.lbl_ini.id,nil,'// async enable')      
        BYTECODE(me,codeB,'op_asen',async.gte,me.lbl_ini.n)

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
        if (not _OPTS.analysis_run) or me.blocks then
            SWITCH(me, me.lbl_ini)
        end

        BLOCK_GATES(me)
    end,

    Break = function (me)
        local top = _AST.iter'Loop'()
--        LINE(me, '//> ceu_track_ins(CEU->stack,' ..top.lbl_out.tree..', 1,'
--                    ..top.lbl_out.id..');')
        codeB = LINE(me, 'insert track '.. top.lbl_out.id .. ' tree '.. top.lbl_out.tree,nil,'// Break:: ')
		BYTECODE(me,codeB,'op_tkins_z',1,top.lbl_out.tree,top.lbl_out.n)
        HALT(me)
    end,

    Pause = function (me)
        local exp, blk = unpack(me)
        CONC(me,blk)
    end,

    CallStmt = function (me)
        local call = unpack(me)
        EXP(me, call)
        if not _OPTS.analysis_run then
            LINE(me, call.val..';')
        end
    end,

    EmitExtS = function (me)
        local e1, e2 = unpack(me)
        local ext = e1.ext
    if ext.pre == 'output' then  -- e1 not Exp
      --printTable(e2[1])
--      ASR(e2 and (e2[1].tag == 'CONST' or e2[1].tag == 'Var'),me,'cannot use expressions in "emit <event>(value);". ')

        if (e2) then
          -- get event type data len
          local par_len,par_tp
          if (_TP.deref(e2[1].tp)) then
            par_tp = 'ushort' -- force 2 bytes pointer. Includes RegType only as pointer
          else
            par_tp = e2[1].tp
          end
          par_len = _ENV.c[par_tp].len
--          par_tp = _TP.deref(_TP.deref(e2[1].tp) or '') or _TP.deref(e2[1].tp) or e2[1].tp
--          if (_ENV.c[par_tp]) then 
--            par_len = _ENV.c[par_tp].len 
--          else 
--            par_len=0  
--          end

          if(e2[1].tag=='CONST') then
            codeB = LINE(me,'emit '..e1.ext.id..' len='..par_len..' const='..e2[1].val,nil,'// EmitExtS:: const ')
            BYTECODE(me,codeB,'op_outevt_c',e1.ext.seq,e2[1].val)
          elseif (e2[1].tag=='Var') then
            codeB = LINE(me,'emit '..e1.ext.id..' len='..par_len..' var='..e2[1][1],nil,'// EmitExtS:: var')
            BYTECODE(me,codeB,'op_outevt_v',e1.ext.seq,e2[1].val, par_tp)
          else -- as expression
            CONC(me,me[2])
            codeB = LINE(me,'emit '..e1.ext.id,nil,'// EmitExtS::')
            BYTECODE(me,codeB,'op_outevt_e',e1.ext.idx,e2[1].tp)
          end
        else
          codeB = LINE(me,'emit '..e1.ext.id ,nil,'// EmitExtS:: void ')
          BYTECODE(me,codeB,'op_outevt_z',e1.ext.seq)
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
          BYTECODE(me,codeB,'op_set_c',int.tp,int.val,exp.val)
        else
          CONC(me,exp)
          codeB = LINE(me,'emit '..int.fst.id..' from stack',nil,'// EmitInt:: pop to ')					
          BYTECODE(me,codeB,'op_pop',int.tp,int.val)	
        end
      elseif (exp[1].tag == "Var") then
        if (typelen[int.tp] == typelen[exp.tp]) then
          codeB = LINE(me,'emit '..int.var.id..'('..exp[1][1]..')',nil,'// EmitInt:: Var')
          BYTECODE(me,codeB,'op_set_v',int.tp,int.val,exp.val)
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
    --    COMM(me, 'emit '..int.var.id)

    --        -- emit vs await
    --        if _OPTS.analysis_run then -- int not Exp
    --            SWITCH(me, me.lbl_ana)
    --            CASE(me, me.lbl_ana)
    --        end

    -- defer await: can only react once (0=defer_to_end_of_reaction)
    if not zero then
      --            LINE(me, '//> ceu_track_ins(0, CEU_TREE_MAX, 0,'
      --                        ..me.lbl_awt.id..');')
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
    BYTECODE(me,codeB,'op_set_c','ushort',(int.var.awt0+1+me.gte*_ENV.c.tceu_nlbl.len),me.lbl_awk.n)

    HALT(me)

    -- awake
    CASE(me, me.lbl_awk)
  end,

    AwaitN = function (me)
--        COMM(me, 'Never')
        HALT(me)
    end,
    AwaitT = function (me)
        local exp = unpack(me)
        CONC(me, exp)
        local val = exp.val
        if _OPTS.analysis_run and
            (exp.tag=='WCLOCKE' or exp.tag=='WCLOCKR') then
            val = 'CEU_WCLOCK_ANY'
        end
--        LINE(me, '//> ceu_wclock_enable('..me.gte..', '..val
--                    ..', '..me.lbl.id..');')
--        LINE(me, 'clken '.._TP.getConstType(me.gte,me.ln)..' '..me.gte..' '.._TP.getConstType(val,me.ln)..' '..val..' '.._TP.getConstType(me.lbl.n,me.ln)..' '..me.lbl.n,nil,'// AwaitT '..me.lbl.id)


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
        local e1,_ = unpack(me)
--print("code::AwaitExt: ",e1.ext.n,me.gte,me.lbl.n,_MEM.gtes[e1.ext.n])
--        LINE(me, '//> *PTR_EXT(IN_'..e1.ext.id..','..me.gte..') = '..me.lbl.id..';')
        codeB = LINE(me, 'await '..e1.ext.id..'['..me.gte..']',nil,'// AwaitExt:: ')
		BYTECODE(me,codeB,'op_set_c','ushort',(_MEM.gtes[e1.ext.n]+2+(me.gte*2)),me.lbl.n)

        HALT(me) 
        CASE(me, me.lbl)
    end,
    Op2_call = function (me)
        local _, f, exps = unpack(me)
--print(print_r(me,"code::Op2_call: me"))
        ASR(false,me,'"call" is not implemented! ')

    end,
    ['Op2_-'] = function (me) Op2_any(me,'sub') end,  
    ['Op2_+'] = function (me) Op2_any(me,'add') end,  
    ['Op2_%']   = function (me) Op2_any(me,'mod') end,
    ['Op2_*']   = function (me) Op2_any(me,'mult') end,
    ['Op2_/']   = function (me) Op2_any(me,'div') end,
    ['Op2_|']   = function (me) Op2_any(me,'bor') end,
    ['Op2_&']   = function (me) Op2_any(me,'band') end,
    ['Op2_<<']  = function (me) Op2_any(me,'lshft') end,
    ['Op2_>>']  = function (me) Op2_any(me,'rsfth') end,
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
    ['Op1_*'] = function (me)
        local op, e1 = unpack(me)
print("code::Op1_*:",e1[2],me.tp,e1.tp)
		ASR(not _TP.deref(_TP.deref(e1.tp)),me,'"**Var" is not implemented! ')
        if (e1.tag == 'Var') then -- var or field (not array)
          if (e1[2]) then -- field
print("code::Op1_*:",e1[2],me.tp,me.offset)
            codeB = LINE(me,'push '..e1[2] ..' offset',nil,'// (push field position offset):: ')
            BYTECODE(me,codeB,'op_push_c',me.offset)
            codeB = LINE(me,'push *'..e1[1],nil,'// Op1_*(push pointer content):: ')
            BYTECODE(me,codeB,'op_push_p',e1.tp,e1.val)
            codeB = LINE(me,'add: pointed addr + field offset')
            BYTECODE(me,codeB,'op2_any','add')
            -- Get value pointed by the indexed addr
            codeB = LINE(me,'deref '..me.tp,nil,'// push Var ')
            BYTECODE(me,codeB,'op_deref',me.tp)
          else -- var
            codeB = LINE(me,'push *'..e1[1],nil,'// Op1_*(push pointer content):: ')
            BYTECODE(me,codeB,'op_push_p',e1.tp,e1.val)
          end
        else
          if (e1[2][2]) then -- field array
  -- TODO
          else -- var array
print("code::Op1_*: field_array: ",me[2][2][1],me[2][2][2]) -- field = me[2][2][2]
            local idx = me[2][3]
            local arr = me[2]
            if (idx.tag == 'CONST') then
              ASR(tonumber(idx.val) < tonumber(me.fst.arr),me,'index >= array size')
              codeB = LINE(me,'push '..me.fst.id ..'['..idx[1] ..']',nil,'//  push array')
              BYTECODE(me,codeB,'op_push_v',me.tp,arr.val+(idx.val*_ENV.c[_TP.deref(me.tp) or me.tp].len))
            else
              if (me[2][2][2]) then  -- field var
                codeB = LINE(me,'push &'..me[2][2][1]..'.'..me[2][2][2],nil,'// base addr')
                BYTECODE(me,codeB,'op_push_c',me[2][2].val)
              else  -- single var
                codeB = LINE(me,'push &'..me[2][2][1],nil,'// base addr')
                BYTECODE(me,codeB,'op_push_c',me[2][2].val)
              end
              CONC(me,me[2][3]); -- idx
              codeB = LINE(me,'push idx max '..arr.fst.arr,nil,'// push array max idx')
              BYTECODE(me,codeB,'op_push_c',arr.fst.arr)
              codeB = LINE(me,'mod: limmit idx')
              BYTECODE(me,codeB,'op2_any','mod')
              codeB = LINE(me,'push var len '.._TP.deref(arr.tp),nil,'// push array var len')
              BYTECODE(me,codeB,'op_push_c',_ENV.c[_TP.deref(arr.tp)].len)
              codeB = LINE(me,'mult: varlen * idx')
              BYTECODE(me,codeB,'op2_any','mult')
              codeB = LINE(me,'add: array base addr + len position')
              BYTECODE(me,codeB,'op2_any','add')
              -- Get value pointed by the indexed addr
              codeB = LINE(me,'deref '.._TP.deref(arr.tp),nil,'// push Var ')
              BYTECODE(me,codeB,'op_deref',_TP.deref(arr.tp))
            end  
          end
        end
    end,
  ['Op2_.'] = function (me)
    local op, e1, id = unpack(me)
--print('________________________________________________________')
print('code:Op2_.::',me.val,me.tp, e1.tag,id)
print('code:Op2_.::',me.fst.val, id,e1.fst.fields[id].var,e1.fst.fields[id].tp,e1.fst.fields[id].arr)
--print(print_r(me,'code::Op2_.:me'))
--print('--------------------------------------------------------')
--- TODO afb
-- 1) Falta tratar campo array: e1.fst.fields[id].arr
-- 2) Falta testar/tratar array de registers???? Vai precisar???

    if (e1.tag == 'Var') then
print('code:Op2_.::',e1.fst.fields[id].arr)
    
      if e1.fst.fields[id].arr then
print('code:Op2_.:: field é um array\n',me[2].tp)
      
      else
        codeB = LINE(me,'push '..e1[1]..'.'..id..':'..e1.fst.fields[id].tp,nil,'// push Var ')
        BYTECODE(me,codeB,'op_push_v', e1.fst.fields[id].tp, e1.fst.fields[id].var + me.fst.val)
      end

--      codeB = LINE(me,'push '..id ..' offset',nil,'// (push field position offset):: ')
--      BYTECODE(me,codeB,'op_push_c',e1.fst.fields[id].var)
--      codeB = LINE(me,'push '..e1[1] ..' addr',nil,'// (push reg addr):: ')
--      BYTECODE(me,codeB,'op_push_c',me.fst.val)
--      codeB = LINE(me,'add: reg addr + field offset')
--      BYTECODE(me,codeB,'op2_any','add')
--      -- Get value pointed by the indexed addr
--      codeB = LINE(me,'deref '..e1.fst.fields[id].tp,nil,'// push Var ')
--      BYTECODE(me,codeB,'op_deref',e1.fst.fields[id].tp)
 
    elseif (e1.tag == 'Op2_idx') then
      codeB = LINE(me,'push '..id ..' offset',nil,'// (push field position offset):: ')
      BYTECODE(me,codeB,'op_push_c',e1.fst.fields[id].var)

      CONC(me,e1[3])
      codeB = LINE(me,'push idx max '..me.fst.arr,nil,'// push array max idx')
      BYTECODE(me,codeB,'op_push_c',me.fst.arr)
      codeB = LINE(me,'mod: limmit idx')
      BYTECODE(me,codeB,'op2_any','mod')
      codeB = LINE(me,'push var len '..e1.tp,nil,'// push array var len')
      BYTECODE(me,codeB,'op_push_c',_ENV.c[e1.tp].len)
      codeB = LINE(me,'mult: varlen * idx')
      BYTECODE(me,codeB,'op2_any','mult')
      codeB = LINE(me,'add: array base addr + len position')
      BYTECODE(me,codeB,'op2_any','add')

      codeB = LINE(me,'add: reg-idx addr + field offset')
      BYTECODE(me,codeB,'op2_any','add')
      -- Get value pointed by the indexed addr
      codeB = LINE(me,'deref '..e1.tp,nil,'// push Var ')
      BYTECODE(me,codeB,'op_deref',e1.tp)
    else
      ASR(false,me,'invalid var.field ')
    end
  end,
    
  ['Op1_&'] = function (me)
    local op, e1 = unpack(me)
    if (e1.tag == 'Var' or e1.tag == 'Op2_idx') then
      codeB = LINE(me,'push &'..me.fst.id,nil,'// Op1_&(push var/array address):: ')
      BYTECODE(me,codeB,'op_push_c',me.fst.off)
    end
    -- "Work around" to get '&' of array[var]
    if (e1.tag == 'Op2_idx') then
      CONC(me,e1[3])
      codeB = LINE(me,'push idx max '..me.fst.arr,nil,'// push array max idx')
      BYTECODE(me,codeB,'op_push_c',me.fst.arr)
      codeB = LINE(me,'mod: limmit idx')
      BYTECODE(me,codeB,'op2_any','mod')
      codeB = LINE(me,'push var len '..e1.tp,nil,'// push array var len')
      BYTECODE(me,codeB,'op_push_c',_ENV.c[e1.tp].len)
      codeB = LINE(me,'mult: varlen * idx')
      BYTECODE(me,codeB,'op2_any','mult')
      codeB = LINE(me,'add: array base addr + len position')
      BYTECODE(me,codeB,'op2_any','add')
    end
  end,

  Op_var = function (me)
    local op, exp = unpack(me)
--print("code::Op_var:",op,exp.var.id,exp.var.val,exp.tp)
    codeB = LINE(me,op..' '..exp.var.id..':'..exp.tp,nil,'// Op_var <type> ')
    BYTECODE(me,codeB,'op_'..op,exp.tp,exp.var.val)
  end,

  Op1_cast = function (me)
    local tp, exp = unpack(me)
    CONC(me,exp)
    codeB = LINE(me,'cast '..tp,nil,'// cast <type> ')
    BYTECODE(me,codeB,'op_cast',tp)
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
    BYTECODE(me,codeB,'op_push_c',me[1])
  end,  
  ['Var'] = function (me)
    --		ASR(typelen[me.var.tp] or _TP.deref(me.var.tp),me,'must use custom type only as pointer.')
    codeB = LINE(me,'push '..me.var.id..':'..me.var.tp,nil,'// push Var ')
    BYTECODE(me,codeB,'op_push_v',me.var.tp,me.var.val)
  end,
  Exp = function (me)
--print("code::Exp:",me[1].tag,me[1].tp)
    if (me[1].code=="") then me[1].code='TODO' end
    CONC(me,me[1]);
  end,
  ExpList = function (me)
--print("code::ExpList:",me[1].tag)
--print(print_r(me,"code::ExpList: me"))
    for k,arg in ipairs(me) do
--print("code::ExpList: arg=",k, arg.tag,arg.tp)    
      CONC(me,arg);
    end
  end,

  Func = function (me)
--print("code::Func:",me.ext.id, me.ext.tp,me.ext.idx)
--print("code::Func: args:",#me[2],#me.ext.args)
    ASR(#me[2]==#me.ext.args,me,'invalid number of arguments for function ['.. me.ext.id ..'], received '.. #me[2] .. ' and it was expecting '..#me.ext.args  )
    for k,arg in ipairs(me.ext.args) do
      ASR(not _TP.argsTp(arg,me[2][k].tp),me,'argument #'..k ..' in function ['.. me.ext.id ..'] must be compatible to ['.. arg ..'] type, it received ['.. me[2][k].tp .. '] type')
    end
    CONC(me,me[2]);
    codeB = LINE(me,'call func '.. me.ext.idx ..' - ' ..me.ext.id..':'..me.ext.tp,nil,'// call func ')
    BYTECODE(me,codeB,'op_func',me.ext.idx)
  end,
  
  Op2_idx = function (me)
    local _, arr, idx = unpack(me)
--print(print_r(me,"code::Op2_idx: me"))
print("code::Op2_idx:",idx.tag,arr.tp,me.tp,arr.val,idx.val,me[2][1],me[2][2])
    ASR(_TP.isBasicType( _TP.deref(_TP.deref(arr.tp)) or _TP.deref(arr.tp)),me,'Arrays can have only basic types.')
    --ASR((idx.tag == 'CONST' or idx.tag=='Var'),me,'array index cannot be an expression! ')

    if _TP.isBasicType(_TP.deref(arr.tp) or arr.tp) then
      if (idx.tag == 'CONST') then
        ASR(tonumber(idx.val) < tonumber(me.fst.arr),me,'index >= array size')
        codeB = LINE(me,'push '..me.fst.id ..'['..idx[1] ..']',nil,'//  push array')
        BYTECODE(me,codeB,'op_push_v',me.tp,arr.val+(idx.val*_ENV.c[_TP.deref(me.tp) or me.tp].len))
      else
        if (me[2][2]) then  -- field var
          codeB = LINE(me,'push &'..me[2][1]..'.'..me[2][2],nil,'// base addr')
          BYTECODE(me,codeB,'op_push_c',me[2].val)
        else  -- single var
          codeB = LINE(me,'push &'..me[2][1],nil,'// base addr')
          BYTECODE(me,codeB,'op_push_c',me[2].val)
        end
        CONC(me,me[3]); -- idx
        codeB = LINE(me,'push idx max '..arr.fst.arr,nil,'// push array max idx')
        BYTECODE(me,codeB,'op_push_c',arr.fst.arr)
        codeB = LINE(me,'mod: limmit idx')
        BYTECODE(me,codeB,'op2_any','mod')
        codeB = LINE(me,'push var len '.._TP.deref(arr.tp),nil,'// push array var len')
        BYTECODE(me,codeB,'op_push_c',_ENV.c[_TP.deref(arr.tp)].len)
        codeB = LINE(me,'mult: varlen * idx')
        BYTECODE(me,codeB,'op2_any','mult')
        codeB = LINE(me,'add: array base addr + len position')
        BYTECODE(me,codeB,'op2_any','add')
        -- Get value pointed by the indexed addr
        codeB = LINE(me,'deref '.._TP.deref(arr.tp),nil,'// push Var ')
        BYTECODE(me,codeB,'op_deref',_TP.deref(arr.tp))
      end
    else
--print("code::Op2_idx: é um vetor de register",idx.tag,arr.tp,me.tp)
--print(print_r(arr,"code::Ope_idx: arr"))
    end
--    if (idx.tag=='Var') then
--      codeB = LINE(me,'push '..me.fst.id ..'['..idx[1] ..']',nil,'// push array')
--      BYTECODE(me,codeB,'op_pusharr_v',me.tp,idx.tp,idx.val,me.fst.arr,arr.val)
--    end
  end   
}
_AST.visit(F)
