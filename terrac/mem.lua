_MEM = {
    off  = 0,
    max  = 0,
    gtes = {
        exts = {},
    },
    vars = {},
}

function alloc (n)
    local cur = _MEM.off
    _MEM.off = _MEM.off + n
    _MEM.max = MAX(_MEM.max, _MEM.off)
    return cur
end


local t2n = {
     ms = 10^0,
      s = 10^3,
    min = 60*10^3,
      h = 60*60*10^3,
}


local t2idx = {
     ms = 0,
      s = 1,
    min = 2,
      h = 3,
}

_MEM.t2idx=t2idx

function accs_join (dst, src)
    if src.accs then
        for _,v in ipairs(src.accs) do
            dst.accs[#dst.accs+1] = v
        end
    end
end

local _ceu2c = { ['or']='||', ['and']='&&', ['not']='!' }
local function ceu2c (op)
    return _ceu2c[op] or op
end

F = {

    Root_pre = function (me)
--print("mem::Root_pre: curr mem in",alloc(0))
--print("mem::Root_pre: wclocks/syncs/emits",_ENV.n_wclocks,_ENV.n_asyncs,_ENV.n_emits)
        _MEM.gtes.wclock0 = alloc(_ENV.n_wclocks * _ENV.c.tceu_wclock.len)
        _MEM.gtes.async0  = alloc(_ENV.n_asyncs  * _ENV.c.tceu_nlbl.len)
        _MEM.gtes.emit0   = alloc(_ENV.n_emits   * _ENV.c.tceu_nlbl.len)
--print("mem::Root_pre: curr mem after gtes",alloc(0))
        local int outcount=0;
        _ENV.gate0 = _MEM.off; --afb save gates0 offset value
        for _, ext in ipairs(_ENV.exts) do
            if ext.pre == 'input' and (_ENV.awaits[ext] or 0) > 0 then  -- only active events
--print("mem::Root_pre: in evt",ext.id,_ENV.awaits[ext],(2 +(_ENV.awaits[ext] or 0)*_ENV.c.tceu_nlbl.len))

              if not ext.inArg then
                  _MEM.gtes[ext.n] = alloc(2 + -- 1+2=2 -> idx, gates
                                      (_ENV.awaits[ext] or 0) * _ENV.c.tceu_nlbl.len) 
              else
                  _MEM.gtes[ext.n] = alloc(2 + -- 1+2=2 -> idx, gates
                                      (_ENV.awaits[ext] or 0) * (_ENV.c.tceu_nlbl.len + 1)) -- (idAux,addr)*             
              end

            else
              _MEM.gtes[ext.n] = alloc(0)
            end
--print("mem::Root_pre:",ext.id,_MEM.gtes[ext.n])
            if ext.pre == 'output' then
            	ext.seq = outcount;
            	outcount = outcount + 1;
            end
        end
        _MEM.gtes.loc0 = alloc(0)
--print("mem::Root_pre: curr mem out",_MEM.gtes.loc0)
    end,

    Block_pre = function (me)
--print(print_r(me,"mem::Block_pre: me"))
        me.off = _MEM.off

        for _, var in ipairs(me.vars) do
--print("mem::Block_pre: var",var.id,me.off,_MEM.off)
            local len
            if var.arr then
				        if _TP.deref(_TP.deref(var.tp)) then 
                    len = 2 * var.arr
                else
                	len = _ENV.c[_TP.deref(var.tp)].len * var.arr
                end
            elseif _TP.deref(var.tp) then
                len = _ENV.c.pointer.len
            else
                len = _ENV.c[var.tp].len
            end
            
            if _OPTS.analysis_run then
                var.off = 0
            else
                var.off = alloc(len)
            end
            -- afb build a var table in _MEM
            _MEM.vars[var.off]= (_MEM.vars[var.off] or '')..var.id..':'..len..', '
            
            if var.isEvt then
                var.awt0 = alloc(1)
				-- afb build a var table in _MEM
		        _MEM.vars[var.awt0]= (_MEM.vars[var.awt0] or '')..var.id..'_awt0, '
                local temp=alloc(_ENV.c.tceu_nlbl.len*var.n_awaits)
				-- afb build a var table in _MEM
		        if (var.n_awaits>0) then _MEM.vars[temp]=  (_MEM.vars[temp] or '') .. var.id..'_waits['..var.n_awaits..'], ' end
            end

-- afb            var.val = '(*(('.._TP.c(var.tp)..'*)(CEU->mem+'..var.off..')))'
            var.val = ''..var.off..''
            if var.arr then
-- afb                var.val = '(('.._TP.c(var.tp)..')(&'..var.val..'))'
                var.val = ''..var.off..''
            end

            -- Create relative field offset 'val'
            if var.fields then
              local offset = 0
              local lastSize = 0
              for k,field in ipairs(var.fields) do
--print('mem::Block_pre: fields:', k, field.tp, field.id)
                offset = offset + lastSize
                if field.arr then
                    if _TP.deref(_TP.deref(field.tp)) then 
                        len = 2 * field.arr
                    else
                      len = _ENV.c[_TP.deref(field.tp)].len * field.arr
                    end
                elseif _TP.deref(field.tp) then
                    len = _ENV.c.pointer.len
                else
                    len = _ENV.c[field.tp].len
                end
                lastSize = len
                field.offset = offset
                field.val = offset + var.val
              end
            end

        end

        me.max = _MEM.off
    end,
    Block = function (me)
        for blk in _AST.iter'Block' do
            blk.max = MAX(blk.max, _MEM.off)
        end
--print("mem::Block: me.off,_MEM.off",me.off,_MEM.off,'ln='.. me.ln)
        _MEM.off = me.off
    end,

    ParEver_aft = function (me, sub)
--print("mem::ParEver_aft: me.lst,_MEM.off,sub.max",me.lst,_MEM.off,sub.max,'ln='.. me.ln)
        me.lst = sub.max
    end,
    ParEver_bef = function (me, sub)
--print("mem::ParEver_bef: me.lst,_MEM.off",me.lst,_MEM.off,'ln='.. me.ln)
        _MEM.off = me.lst or _MEM.off
    end,
    ParOr_aft  = 'ParEver_aft',
    ParOr_bef  = 'ParEver_bef',
    ParAnd_aft = 'ParEver_aft',
    ParAnd_bef = 'ParEver_bef',

    ParAnd_pre = function (me)
--print("mem::ParAnd_pre:",'ParAnd_flag['..#me..']',me.off,_MEM.off)
        me.off = alloc(#me)        -- TODO: bitmap?
		-- afb build a var table in _MEM
        _MEM.vars[me.off]= ( _MEM.vars[me.off] or '')..'ParAnd_flag['..#me..'], '
    end,
    ParAnd = 'Block',

    -- for analysis_run, ParEver behaves like ParAnd (n_reachs)
    ParEver_pre = function (me)
        if _OPTS.analysis_run then
            F.ParAnd_pre(me)
        end
    end,
    ParEver = function (me)
        if _OPTS.analysis_run then
            F.Block(me)
        end
    end,

    Var = function (me)
--print("mem:Var:",me.var.id,me.var.val,me.var.arr)
--print(print_r(me,"mem:Var: me"))
        me.val = me.var.val
        me.accs = { {me.var, (me.var.arr and 'no') or 'rd', me.var.tp, false,
                    'variable/event `'..me.var.id..'´ (line '..me.ln..')'} }
    end,

    AwaitInt = function (me)
        local e = unpack(me)
        e.accs[1][2] = 'aw'
        if string.sub(e.var.id,1,4) == '$fin' then
            e.accs[1][2] = 'no'
        end
        me.val = e.val
    end,

    EmitInt = function (me)
        local e1, e2 = unpack(me)
        e1.accs[1][2] = 'tr'
        if string.sub(e1.var.id,1,4) == '$fin' then
            e1.accs[1][2] = 'no'
        end
    end,

    --------------------------------------------------------------------------

    SetAwait = 'SetExp',
    SetExp = function (me)
        local e1, e2 = unpack(me)
        e1.accs[1][2] = 'wr'
    end,

    EmitExtS = function (me)
        local e1, _ = unpack(me)
        if e1.ext.pre == 'output' then
            F.EmitExtE(me)
        end
    end,
    EmitExtE = function (me)
        local e1, e2 = unpack(me)
        e1.acc = {e1.ext.id, 'cl', '_', false,
                    'event `'..e1.ext.id..'´ (line '..me.ln..')'}
        local len, val, valType
        if e2 then
            local tp = _TP.deref(e1.ext.tp, true)
--print("mem::EmitExtE:",e1.ext.id, e1.ext.tp, e2.tp)
            if tp then
            ASR(_TP.deref(e2.tp),me,'invalid type. Expecting '..e1.ext.tp..' and received '.. e2.tp)
                len = _ENV.c[_TP.deref(_TP.deref(e2.tp)) or _TP.deref(e2.tp) or e2.tp].len --'sizeof('.._TP.c(tp)..')'
                val = e2.val
                valType = ''
                if e2.accs and tp then
                    e2.accs[1][4] = (e2.accs[1][2] ~= 'no')   -- &x does not become "any"
                    local c = _ENV.c[me.fid]
                    e2.accs[1][2] = (c and c.mod=='pure' and 'rd') or 'wr'
                    e2.accs[1][3] = tp
                end
            else
                len = _ENV.c[_TP.deref(e2.tp) or e2.tp].len -- 'sizeof('.._TP.c(e1.ext.tp)..')'
--afb                val = 'ceu_ext_f('..e2.val..')'
                val = e2.val
                valType = e2.tp
            end
            -- afb : Resize array len
            if (type(e2.fst)=='table' and e2.fst.arr) then
            	len = len * e2.fst.arr
            end
        else
            len = 0
-- afb            val = 'NULL'
            val = '0'
            valType = _TP.getConstType(val,me.ln)
        end
		
--        me.val = '\n'..[[
--     //> ceu_out_event(OUT_]]..e1.ext.id..','..len..','..val..[[)
--afb #if defined(ceu_out_event_]]..e1.ext.id..[[)
--afb     ceu_out_event_]]..e1.ext.id..'('..val..[[)
--afb #elif defined(ceu_out_event)
--afb     ceu_out_event(OUT_]]..e1.ext.id..','..len..','..val..[[)
--afb #else
--afb     0
--afb #endif
--afb ]]
    end,

    AwaitExt = function (me)
        local e1 = unpack(me)
        if _TP.deref(e1.ext.tp) then
            me.val = '(('.._TP.c(e1.ext.tp)..')CEU->ext_data)'
        else
            me.val = '*((int*)CEU->ext_data)'
        end
    end,

    AwaitT = function (me)
        me.val = 'CEU->wclk_late'
    end,

    LExp = function (me)
        me.val  = me[1].val
        me.accs = me[1].accs
    end,

    Exp = function (me)
        me.val  = me[1].val
        me.accs = me[1].accs
    end,

    Func = function (me)
        me.val  = me[1].val
        me.accs = me[1].accs
    end,


    Op2_call = function (me)
        local _, f, exps = unpack(me)
        local ps = {}
        me.accs = {}
        accs_join(me, f)
        f.accs[1][2] = 'cl'
        for i, exp in ipairs(exps) do
            ps[i] = exp.val
            accs_join(me, exp)
            local tp = _TP.deref(exp.tp, true)
            if exp.accs and tp then
                exp.accs[1][4] = (exp.accs[1][2] ~= 'no')   -- &x does not become "any"
                exp.accs[1][2] = (me.c and me.c.mod=='pure' and 'rd') or 'wr'
                exp.accs[1][3] = tp
            end
        end
        me.val = f.val..'('..table.concat(ps,',')..')'
    end,

    Op2_idx = function (me)
        local _, arr, idx = unpack(me)
-- afb        me.val = '('..arr.val..'['..idx.val..'])'
--print('mem::Op2_idx:',arr.val,idx.val)
        me.val = arr.val 
        me.accs = {}
        accs_join(me, arr)
        accs_join(me, idx)
    end,

    Op2_any = function (me)
        local op, e1, e2 = unpack(me)
        me.val = ' '
        me.accs = e1.accs
        me.accs = {}
        accs_join(me, e1)
        accs_join(me, e2)

    end,
    ['Op2_-']   = 'Op2_any',
    ['Op2_+']   = 'Op2_any',
    ['Op2_%']   = 'Op2_any',
    ['Op2_*']   = 'Op2_any',
    ['Op2_/']   = 'Op2_any',
    ['Op2_|']   = 'Op2_any',
    ['Op2_&']   = 'Op2_any',
    ['Op2_<<']  = 'Op2_any',
    ['Op2_>>']  = 'Op2_any',
    ['Op2_^']   = 'Op2_any',
    ['Op2_==']  = 'Op2_any',
    ['Op2_!=']  = 'Op2_any',
    ['Op2_>=']  = 'Op2_any',
    ['Op2_<=']  = 'Op2_any',
    ['Op2_>']   = 'Op2_any',
    ['Op2_<']   = 'Op2_any',
    ['Op2_or']  = 'Op2_any',
    ['Op2_and'] = 'Op2_any',

    Op1_any = function (me)
        local op, e1 = unpack(me)
        me.val = '('..ceu2c(op).. '`exp´' ..')'
        me.accs = e1.accs
    end,
    ['Op1_~']   = 'Op1_any',
    ['Op1_-']   = 'Op1_any',

    ['Op1_not'] = 'Op1_any',

--    ['Op1_*'] = function (me)
--        local op, e1 = unpack(me)
--        ASR(e1.val,me,'invalid operand to unary "*"')
--        me.val = '('..ceu2c(op)..e1.val..')'
--        me.accs = e1.accs
--        me.accs[1][3] = _TP.deref(me.accs[1][3], true)
--        me.accs[1][4] = true
--    end,
    ['Op1_&'] = function (me)
        local op, e1 = unpack(me)
        me.val = ' '
        me.accs = e1.accs
        me.accs[1][2] = 'no'
    end,

    ['Op2_.'] = function (me)
        local op, e1, id = unpack(me)
        local field = _ENV.c[_TP.deref(e1.tp) or e1.tp].fields[id]
--        me.val  = '('..e1.val..ceu2c(op)..e1.fst.fields[id].var..')'
        me.val  = field.var
        me.tp   = me.tp
        me.accs = e1.accs
    end,

    Op_var = function (me)
        me.val  = me[1].val
        me.accs = me[1].accs
    end,

    Op1_cast = function (me)
        local tp, exp = unpack(me)
        me.val = exp.val
        me.accs = exp.accs
        me.tp = tp
    end,

    WCLOCKK = function (me)
        local h,min,s,ms = unpack(me)
 --       me.us  = (ms*t2n.ms + s*t2n.s + min*t2n.min + h*t2n.h)*1000
        me.ms  = (ms*t2n.ms + s*t2n.s + min*t2n.min + h*t2n.h)
--afb        me.val = me.us
        me.val = _TP.getConstType(me.ms,me.ln)..' '..me.ms   -- uses milli
--afb        ASR(me.us>0 and me.us<=2000000000, me, 'constant is out of range')
        ASR(me.ms>0 and me.ms<= (math.pow(2,32))-1, me, 'constant is out of range')
    end,

    WCLOCKE = function (me)
        local exp, unit = unpack(me)
        me.ms   = nil
--afb        me.val  = exp.val .. '*' .. t2n[unit] .. 'L'
        me.val  = t2idx[unit]..' '..exp.tp..' '.. (exp.val or '--')
        me.accs = exp.accs
    end,

    WCLOCKR = function (me)
        me.val = 'PTR(tceu_wclock*,CEU_WCLOCK0)['..me.awt.gte..'].togo'
    end,

    C = function (me)
        me.val = string.sub(me[1], 2)
        me.accs = { {me[1], 'rd', '_', false,
                    'symbol `'..me[1]..'´ (line '..me.ln..')'} }
    end,
    SIZEOF = function (me)
      ASR(_ENV.c[_TP.deref(me[1]) or me[1]],me,'invalid type "'.. me[1] ..'"')
      local tp = (_TP.deref(me[1]) and 'ushort') or me[1]
--print("mem::SIZEOF:",_ENV.c[tp].len,_TP.getConstType(_ENV.c[tp].len),me.ln)
--        me.val = 'sizeof('.._TP.c(me[1])..')'
      me.val = _ENV.c[tp].len
      me.tp = _TP.getConstType(_ENV.c[tp].len,me.ln)
      me.accs = me[1].accs
    end,
--    STRING = function (me)
--        me.val = me[1]
--    end,
    CONST = function (me)
        me.val = me[1]
    end,
    NULL = function (me)
        me.val = '((void *)0)'
    end,
}

_AST.visit(F)
