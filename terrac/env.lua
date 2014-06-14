
local function ceil (v)
    local w = 2 --_OPTS.tp_word
    while true do
        if v % w == 0 then
            return v
        else
            v = v + 1
        end
    end
end


_ENV = {
    exts = {},
    c = {
        void = 0,

        ubyte=1, ushort=2, ulong=4,
        byte=1, short=2, long=4,

        pointer   = 2, --_OPTS.tp_pointer,
        tceu_noff = 2, --_OPTS.tp_off,
        tceu_nlbl = 2, --_OPTS.tp_lbl,
--        tceu_wclock = ceil(4 + _OPTS.tp_lbl + 2       -- TODO: perda de memoria :: +2 to adjust micaz struct size
--                          + (_OPTS.analysis_run and 4 or 0)),
        tceu_wclock = ceil(4 + 2 + 2),       -- TODO: perda de memoria :: +2 to adjust micaz struct size
                          
    },
    calls = {},     -- { _printf=true, _myf=true, ... }

    n_asyncs  = 0,
    n_wclocks = 0,
    n_emits   = 0,
    awaits    = {},
    gate0     = 0; --afb
    n_ins     = 0; --afb
    n_outs     = 0; --afb
    n_ins_active = 0; --afb	
    n_wrns = 0;       --afb Count warning messages
    dets  = {},
}

for k, v in pairs(_ENV.c) do
    _ENV.c[k] = { tag='type', id=k, len=v }
end

function newvar (me, blk, pre, tp, dim, id)
    for stmt in _AST.iter() do
        if stmt.tag == 'Async' then
            break
        elseif stmt.tag == 'Block' then
            for _, var in ipairs(stmt.vars) do
                WRN(var.id~=id, me,
                    'declaration of "'..id..'" hides the one at line '..var.ln)
            end
        end
    end

    local tp_raw = _TP.raw(tp)
    local c = _ENV.c[tp_raw]
    local isEvt = (pre ~= 'var')
--print("env::newvar:",id,"pre=",pre,"isEvt=",isEvt)

    ASR(c and c.tag=='type', me, 'undeclared type `'..tp_raw..'´')
    ASR(_TP.deref(tp) or (not c) or (tp=='void' and isEvt) or c.len>0, me,
        'cannot instantiate type "'..tp..'"')
    ASR((not dim) or dim>0, me, 'invalid array dimension')

    local nvar = {}
    if not(_TP.deref(tp)) and c.fields then
      local var = {
          ln    = me.ln,
          id    = id,
          tp    = (dim and tp..'*') or tp,
          blk   = blk,
          pre   = pre,
          isEvt = isEvt,
          arr   = dim,
          n_awaits = 0,
          fields ={}
      }
      blk.vars[#blk.vars+1] = var
      nvar[#nvar+1]=var
--print(print_r(c.fields,'env::newvar: c.fields'))
      for k, v in ipairs(c.fields) do
        local var = {
            ln    = me.ln,
            id    = id..'.'..v.id,
            field_id    = v.id,
            tp    = (v.dim and v.tp..'*') or v.tp,
            --blk   = blk,
            pre   = v.pre,
            isEvt = false,
            arr   = v.dim,
            lval  = true,
            n_awaits = 0,
        }
        blk.vars[#blk.vars].fields[#blk.vars[#blk.vars].fields+1] = var
        blk.vars[#blk.vars].fields[v.id] = var
        --nvar[#nvar+1]=var
      end
    else
        local var = {
            ln    = me.ln,
            id    = id,
            tp    = (dim and tp..'*') or tp,
            blk   = blk,
            pre   = pre,
            isEvt = isEvt,
            arr   = dim,
            n_awaits = 0,
        }
        blk.vars[#blk.vars+1] = var
        nvar[#nvar+1]=var
    end
    return nvar
end

-- identifiers for ID_c / ID_ext (allow to be defined after annotations)
-- variables for Var
function det2id (v)
    if type(v) == 'string' then
        return v
    else
        return v.var
    end
end

F = {
    Block_pre = function (me)
        me.vars = {}
        local async = _AST.iter()()
        if async.tag == 'Async' then
            local vars, blk = unpack(async)
            if vars then
                for _, n in ipairs(vars) do
                    local var = n[1].var
                    ASR(not var.arr, vars, 'invalid argument')
                    n.new = newvar(vars, blk, false, var.tp, nil, var.id)
                end
            end
        end
    end,

    Dcl_ext = function (me)
        local dir, tp, id, idx = unpack(me)
--print("env::Dcl_ext:", dir, tp, id, idx)
--print(print_r(_ENV.c,"ENV.c"))
--        ASR(tp=='void' or _TP.deref(tp)) or _ENV.c[tp],me, 'invalid event type')
  
--print("env::Dcl_ext:",id, tp, _TP.isBasicType(tp),_TP.deref(tp), (_TP.isBasicType(tp) or  _TP.deref(tp)) )
        ASR( (_TP.isBasicType(tp) or  _TP.deref(tp)),me, 'invalid event type')

        for k,val in ipairs(_ENV.exts) do
          if val.pre==dir then 
            ASR(not (val.id==id), me, 'event "'..id..'" is already declared at line '.. (val.ln or 0))
            ASR(not (val.idx==idx), me, dir..' event numeric id "'..idx..'" is already in use at line '.. (val.ln or 0))
          end
        end
        ASR(idx<255, me, dir..' event numeric id must be less than 255')

        me.ext = {
            ln    = me.ln,
            id    = id,
            n     = #_ENV.exts,
            tp    = tp,
            pre   = dir,
            isEvt = true,
            idx   = idx,
        }
        _ENV.exts[id] = me.ext
        _ENV.exts[#_ENV.exts+1] = me.ext
    end,

    Dcl_int = 'Dcl_var',
    Dcl_var = function (me)
        local pre, tp, dim, id, exp = unpack(me)
--print("env::Dcl_var:",tp,dim, _TP.isBasicType(_TP.deref(tp) or tp),(not dim) or  _TP.isBasicType(_TP.deref(tp) or tp))
        ASR( (not dim) or  _TP.isBasicType(_TP.deref(tp) or tp),me,'Arrays can have only basic types')
        me.var = newvar(me, _AST.iter'Block'(), pre, tp, dim, id)
    end,


    Dcl_regt = function(me)
--print(print_r(me,"env::Dcl_regt: me"))
      local RegId = me[1]
      local RegFields= {}
      local memsize = 0
      local offset = 0
      local lastSize = 0
      for i=2, #me do
        offset = offset + lastSize
        local var = me[i]
--print('env::Dcl_regt: var',var)
        local  pre, tp, dim, id = unpack(var)
        local len = ((dim and dim*_ENV.c[var[2]].len) or _ENV.c[var[2]].len)
        lastSize = len
        RegFields[id]={pre=pre,tp=tp,dim=dim,id=id,len=len,offset=offset}
        RegFields[i-1]=RegFields[id]
--print('env::Dcl_regt:',tp,id)
        memsize = memsize + len
      end
      _ENV.c[RegId] = { tag='type', id=RegId, len=memsize , fields=RegFields}
    end,

    Dcl_func = function (me)
       local op,tp,id,args,idx = unpack(me)
--print("env::Dcl_func:", op, tp, id, idx)
--print("env::Dcl_func:", tp=='void', _TP.deref(tp) , _ENV.c[tp]~=nil)
        ASR(not(tp=='void' or _TP.deref(tp)) and _ENV.c[tp],me, 'invalid function type "'..tp..'"')
        for k,val in ipairs(_ENV.exts) do
          if val.pre=='func' then 
            ASR(not (val.id==id), me, 'function "'..id..'" is already declared at line '.. (val.ln or 0))
            ASR(not (val.idx==idx), me, ' function numeric id "'..idx..'" is already in use at line '.. (val.ln or 0))
          end
        end
        ASR(idx<255, me,' function event numeric id must be less than 255')

        for k,tp in ipairs(args) do
--print("env::Dcl_func: arg:",k, tp, (_TP.isBasicType(tp) or _TP.isBasicType(_TP.deref(tp))) or _TP.deref(tp))
          ASR(not(tp=='void') and (_ENV.c[tp] or _ENV.c[_TP.deref(tp)]),me, '<'..tp..'> in position '..k..' is invalid argument type in function <'..id..'>')
          ASR((_TP.isBasicType(tp) or _TP.isBasicType(_TP.deref(tp))) or _TP.deref(tp),me, 'register <'..tp..'> in position '..k..' in function <'..id..'> must be a pointer.')
        end
        me.ext = {
            ln    = me.ln,
            id    = id,
            n     = #_ENV.exts,
            tp    = tp,
            pre   = 'func',
            isEvt = false,
            args  = args,
            idx   = idx,
        }
        _ENV.exts[#_ENV.exts+1] = me.ext
        _ENV.exts[id] = me.ext
    end,

    Ext = function (me)
        local id = unpack(me)
        me.ext = ASR(_ENV.exts[id],me, 'event "'..id..'" is not declared')
    end,

    Func = function (me)
--print("env::Func:",me[1])
        local id = unpack(me)
        me.ext = ASR(_ENV.exts[id],me, 'function "'..id..'" is not declared')
        me.tp = _ENV.exts[id].tp
    end,


   
    Var = function (me)
        local id, idField = unpack(me)
print("env::Var:",id, idField)
--print(print_r(me,"env::Var: me"))
        local blk = me.blk or _AST.iter('Block')()
        while blk do
            for i=#blk.vars, 1, -1 do   -- n..1 (hidden vars)
                local var = blk.vars[i]
                if var.id == id then
--print(print_r(var,"env::Var: var"))
print("env::Var: fields",var.fields,var.tp,idField)
                  if var.fields and idField then
                    ASR(var.fields[idField],me,'invalid field name "'..idField..'" for "'..id..'"')
print("env::Var: fields",var.fields[idField].tp)
                    me.var  = var.fields[idField]
                    me.tp   = var.fields[idField].tp
                    me.lval = (not var.fields[idField].arr)
                    me.fst  = var.fields[idField]
                  else
                    me.var  = var
                    me.tp   = var.tp
                    me.lval = (not var.arr)
                    me.fst  = var
                  end
                    return
                end
            end
            blk = blk.par
        end
        ASR(false, me, 'variable/event/function "'..id..'" is not declared')
    end,

    Dcl_c = function (me)
        local mod, tag, id, len = unpack(me)
        _ENV.c[id] = { tag=tag, id=id, len=len, mod=mod }
    end,

    Dcl_det = function (me)                 -- TODO: verify in _ENV.c
        local id1 = det2id(me[1])
        local t1 = _ENV.dets[id1] or {}
        _ENV.dets[id1] = t1
        for i=2, #me do
            local id2 = det2id(me[i])
            local t2 = _ENV.dets[id2] or {}
            _ENV.dets[id2] = t2
            t1[id2] = true
            t2[id1] = true
        end
    end,

    Pause = function (me)
        local exp, _ = unpack(me)
        ASR(exp.var.isEvt, me, 'event "'..exp.var.id..'" is not declared')
        ASR(_TP.isNumeric(exp.var.tp), me, 'event type must be numeric')
    end,

    AwaitExt = function (me)
        local e1,_ = unpack(me)
        local ext = e1.ext
        me.gte = (_ENV.awaits[ext] or 0)
        _ENV.awaits[ext] = (_ENV.awaits[ext] or 0) + 1
    end,

    AwaitInt = function (me)
        local exp,_ = unpack(me)
        local var = exp.var
        ASR(var and var.isEvt, me,
                'event "'..(var and var.id or '?')..'" is not declared')
        me.gte = var.n_awaits
        var.n_awaits = var.n_awaits + 1
        me.tp = var.tp
        me.id = var.id
    end,

    AwaitT = function (me)
        me.gte = _ENV.n_wclocks
        _ENV.n_wclocks = _ENV.n_wclocks + 1
    end,

    EmitInt = function (me)
        local e1, e2 = unpack(me)
        ASR(e1.var.isEvt, me, 'event "'..e1.var.id..'" is not declared')
        err, cast = _TP.argsTp(e1.var.tp,e2.tp)
        ASR(not err,me, 'invalid attribution ['..e2.tp..'] to ['..e1.var.tp..'].')
        WRN(not cast,me, 'automatic cast from ['..e2.tp..'] to ['..e1.var.tp..'].')

        me.gte = _ENV.n_emits
        _ENV.n_emits = _ENV.n_emits + 2     -- (cnt/awk)
    end,

    EmitExtS = function (me)
        local e1, _ = unpack(me)
        if e1.ext.pre=='output' then
            F.EmitExtE(me)
        end
    end,
    EmitExtE = function (me)
        local e1, e2 = unpack(me)
        ASR(e1.ext.pre=='output', me, 'invalid input `emit´')
        me.tp = e1.ext.tp

        if e2 then
          err, cast = _TP.argsTp(e1.ext.tp,e2.tp)
          ASR(not err,me, 'invalid attribution ['..e2.tp..'] to ['..e1.ext.tp..'].')
          WRN(not cast,me, 'automatic cast from ['..e2.tp..'] to ['..e1.ext.tp..'].')
--          ASR(_TP.contains(e1.ext.tp,e2.tp,true),me, "non-matching types on `emit´")
        else
            ASR(e1.ext.tp=='void',me, "missing parameters on `emit´")
        end
    end,

    Async = function (me)
        me.gte = _ENV.n_asyncs
        _ENV.n_asyncs = _ENV.n_asyncs + 1
    end,

    -- gates for cleaning
    ParOr_pre = function (me)
        me.gtes = {
            asyncs  = { _ENV.n_asyncs,  nil },
            wclocks = { _ENV.n_wclocks, nil },
            emits   = { _ENV.n_emits,   nil },
        }

        for _, ext in ipairs(_ENV.exts) do
            if ext.pre == 'input' then
                me.gtes[ext] = { _ENV.awaits[ext] or 0, nil }
            end
        end

        for blk in _AST.iter'Block' do
            for _, var in ipairs(blk.vars) do
                if var.isEvt then
                    me.gtes[var] = { var.n_awaits, nil }
                end
            end
        end
    end,
    ParOr = function (me)
        me.gtes.asyncs[2]  = _ENV.n_asyncs
        me.gtes.wclocks[2] = _ENV.n_wclocks
        me.gtes.emits[2]   = _ENV.n_emits

        for _, ext in ipairs(_ENV.exts) do
            if ext.pre == 'input' then
                local t = me.gtes[ext]
                if t then
                    t[2] = _ENV.awaits[ext] or 0
                end
            end
        end

        for blk in _AST.iter'Block' do
            for _, var in ipairs(blk.vars) do
                if var.isEvt then
                    me.gtes[var][2] = var.n_awaits
                end
            end
        end
    end,
    Loop_pre     = 'ParOr_pre',
    Loop         = 'ParOr',
    SetBlock_pre = 'ParOr_pre',
    SetBlock     = 'ParOr',

    --------------------------------------------------------------------------

    SetExp = function (me)
        local e1, e2, no_fin = unpack(me)
        e1 = e1 or _AST.iter'SetBlock'()[1]
print('env::SetExp:',e1.lval,e1.tp,e2.tp,no_fin,unpack(e2[1]))
--        WRN(e1.lval and _TP.contains(e1.tp,e2.tp,true),me, 'invalid attribution: ['.. e1.tp ..'] can not contain [' .. e2.tp ..']')

        error, cast = _TP.argsTp(e1.tp,e2.tp)
          ASR(not error,me,'incompatible types on an attribution: '.. e1.tp ..' and '.. e2.tp)
          WRN(not cast,me, 'automatic cast from ['.. e2.tp ..'] to [' .. e1.tp ..'].')

        
        if no_fin then
            return              -- no `finally´ required
        end

        if _TP.deref(e1.tp) then
            local blk1 = (e1.fst=='_' and _AST.root) or e1.fst.blk
            if e2.fst and e2.fst~='_' then
                local blk2 = e2.fst.blk
                ASR(blk2.fin or blk2.depth<=blk1.depth, me,
                    'block at line '..blk2.ln..' must contain `finally´')
                -- int a; pa=&a;    -- `a´ termination must consider `pa´
            else
                ASR(blk1.fin or e2[1].tag~='Op2_call' or e2[1].c.mod=='pure',
                    me, 'block at line '..blk1.ln..' must contain `finally´')
                -- int* pa = _f();   -- `pa´ termination must consider `_f´
            end
        end
    end,

    SetAwait = function (me)
        local e1, awt = unpack(me)
        ASR(e1.lval, me, 'invalid attribution: not a value')
        if awt.ret.tag == 'AwaitT' then
            ASR(_TP.isNumeric(e1.tp,true), me, 'invalid attribution: not a numeric value')
        else    -- AwaitInt / AwaitExt
            local evt = awt.ret[1].var or awt.ret[1].ext
            ASR(_TP.contains(e1.tp,evt.tp,true), me, 'invalid attribution: ['.. e1.tp ..'] can not contain [' .. evt.tp ..']')
        end
        me.fst = awt.fst
    end,

    CallStmt = function (me)
        local call = unpack(me)
--print("env::CallStmt:",call[1].tag)
        ASR(call[1].tag == 'Op2_call', me, 'invalid statement')
    end,

    --------------------------------------------------------------------------

    Exp = function (me)
--print("env::Exp:",me[1][1])
--print(print_r(me,"env::Exp: me"))
        me.lval = me[1].lval
        me.tp   = me[1].tp
        me.fst  = me[1].fst
    end,

    Op2_call = function (me)
        local _, f, exps = unpack(me)
--print("env::Op2_call:",f.tag)
        me.tp  = '_'
        me.fst = '_'
        if f.tag == 'C' then
            me.c = _ENV.c[ f[1] ]
            ASR(me.c.tag=='func', me,
                'C function "'..(f[1])..'" is not declared')
            me.fid = f[1]
        else
            me.fid = '$anon'
        end
        _ENV.calls[me.fid] = true
        ASR((not _OPTS.c_calls) or _OPTS.c_calls[me.fid],
            me, 'C calls are disabled')
        if not (me.c and (me.c.mod=='pure' or me.c.mod=='nohold')) then
            if me.org then
                error'oi'
            end
            for _, exp in ipairs(exps) do
                if _TP.deref(exp.tp) and exp.fst then
                    local blk = (exp.fst=='_' and _AST.root) or exp.fst.blk
                    ASR(blk.fin, me,
                        'block at line '..blk.ln..' must contain `finally´')
                    -- int* pa; _f(pa); -- `pa´ termination must consider `_f´
                end
            end
        end
    end,

    Op2_idx = function (me)
--print(print_r(me,"env:Op2_idx: me"))
print("env::Op2_idx:",me[2][1],me[2].tag,me[2].tp,me[2][2],me[3][1],me[3].tag,me[3].tp)
print("env::Op2_idx:",me[2][2])
        local _, arr, idx = unpack(me)
        local _arr = ASR(_TP.deref(arr.tp,true), me, 'cannot index a non array')
--        ASR(_arr and _TP.isNumeric(idx.tp,true), me, 'invalid array index')
        --me.tp   = _TP.deref(me[2].tp)
        me.tp   = _arr
        me.lval = true
        me.fst  = arr.fst
    end,

    Op2_int_int = function (me)
        local op, e1, e2 = unpack(me)
        ASR(_TP.isNumeric(e1.tp,true) and _TP.isNumeric(e2.tp,true),
            me, 'invalid operands to binary "'..op..'"')
        me.tp  = _TP.max(e1.tp,e2.tp,true)
    end,
    ['Op2_-']  = 'Op2_int_int',
    ['Op2_+']  = 'Op2_int_int',
    ['Op2_%']  = 'Op2_int_int',
    ['Op2_*']  = 'Op2_int_int',
    ['Op2_/']  = 'Op2_int_int',
    ['Op2_|']  = 'Op2_int_int',
    ['Op2_&']  = 'Op2_int_int',
    ['Op2_<<'] = 'Op2_int_int',
    ['Op2_>>'] = 'Op2_int_int',
    ['Op2_^']  = 'Op2_int_int',

    Op1_int = function (me)
        local op, e1 = unpack(me)
        ASR(_TP.isNumeric(e1.tp,true),
                me, 'invalid operand to unary "'..op..'"')
        me.tp  = e1.tp
    end,
    ['Op1_~']  = 'Op1_int',
    ['Op1_-']  = 'Op1_int',

    Op2_same = function (me)
        local op, e1, e2 = unpack(me)
        ASR(_TP.max(e1.tp,e2.tp,true),
                me, 'invalid operands to binary "'..op..'"')
        me.tp  = _TP.max(e1.tp,e2.tp,true)
    end,
    ['Op2_=='] = 'Op2_same',
    ['Op2_!='] = 'Op2_same',
    ['Op2_>='] = 'Op2_same',
    ['Op2_<='] = 'Op2_same',
    ['Op2_>']  = 'Op2_same',
    ['Op2_<']  = 'Op2_same',

    Op2_any = function (me)
        me.tp  = _TP.max(e1.tp,e2.tp,true)
    end,
    ['Op2_or']  = 'Op2_any',
    ['Op2_and'] = 'Op2_any',
    ['Op1_not'] = 'Op2_any',

    ['Op1_*'] = function (me)
        local op, e1 = unpack(me)
        local tp
--print(print_r(e1,"env::Op1_*: e1"))
      if (e1.tag=='Var') then  -- single var/field (not array) 
print("env::Op1_*:",e1.tp,e1.tag,e1[2])
        if (e1[2]) then -- field
          ASR(_TP.deref(e1.tp, true) and e1.tag=='Var', me, 'invalid operand to unary "*"')
          ASR(_ENV.c[_TP.deref(e1.tp)].fields[e1[2]], me, 'invalid field "'.. e1[2] ..'" for "'.. _TP.deref(e1.tp) ..'" register type.')
          tp   = _ENV.c[_TP.deref(e1.tp)].fields[e1[2]].tp
          me.offset = _ENV.c[_TP.deref(e1.tp)].fields[e1[2]].offset
        else  -- var
          ASR(_TP.deref(e1.tp, true) and e1.tag=='Var', me, 'invalid operand to unary "*"')
          tp   = _TP.deref(e1.tp, true)
        end
      else    -- Op2_idx
print("env::Op1_*:",e1.tag,e1[2][1],e1[2][2])
        if (e1[2][2]) then -- field array
--print("env::Op1_*:",e1.tp,e1.tag,e1[2][2])--,_ENV.c[e1.tp].fields[e1[2][2]].tp,_ENV.c[e1.tp].fields[e1[2][2]].dim)
          tp   = e1.tp
          me.dim = e1.dim
        else -- var array
          tp = _TP.deref(e1.tp)
        end
      end
      me.tp   = tp
      me.lval = true
      me.fst  = e1.fst        
    end,

    ['Op1_&'] = function (me)
        local op, e1 = unpack(me)
        ASR(e1.lval, me, 'invalid operand to unary "&"')
        me.tp   = e1.tp..'*'
        me.lval = false
        me.fst  = e1.fst
    end,

    ['Op2_.'] = function (me)
        local op, e1, id = unpack(me)
print("env::Op2_.",me[1],me[2].tp,me[3].tag)
        ASR(e1.fst.fields[id], me, 'invalid field name')
        me.tp   = e1.fst.fields[id].tp
        me.lval = true
        me.fst  = e1.fst
    end,

    Op_var = function (me)
        local op, exp = unpack(me)
--print("env::Op_var:", op,exp.tp, exp.tag, exp.var.id,_TP.isNumeric(exp.tp),_TP.deref(exp.tp))
        ASR(exp.tag=='Var' and _TP.isNumeric(exp.tp), me, 'invalid "inc/dec" target. Received a "'..exp.tag..'" of type "'..exp.tp..'"')
        me.tp   = exp.tp
        me.lval = exp.lval
        me.fst  = exp.fst
     end,

    Op1_cast = function (me)
        local tp, exp = unpack(me)
--print("env::Op1_cast:", tp)
        me.tp   = tp
        me.lval = exp.lval
        me.fst  = exp.fst
     end,

    C = function (me)
        local id = unpack(me)
        local c = _ENV.c[id]
        ASR(c and (c.tag=='var' or c.tag=='func'), me,
            'C variable/function "'..id..'" is not declared')
        me.tp   = '_'
        me.lval = '_'
        me.fst  = '_'
    end,

    WCLOCKK = function (me)
        me.tp   = 'ulong'
        me.lval = false
        me.fst  = false
    end,
    WCLOCKE = 'WCLOCKK',
    WCLOCKR = 'WCLOCKK',

    SIZEOF = function (me)
print("env::SIZEOF")
        me.tp   = 'ushort'
        me.lval = true
    end,

    STRING = function (me)
        ASR(false, me, 'strings are not allowed')
        me.tp   = 'char*'
        me.lval = false
        me.fst  = false
    end,
    CONST = function (me)
        local v = unpack(me)
        me.tp   = _TP.getConstType(v,me.ln)
        me.lval = false
        me.fst  = false
        ASR(string.sub(v,1,1)=="'" or tonumber(v), me, 'malformed number')
    end,
    NULL = function (me)
        me.tp   = 'void*'
        me.lval = false
        me.fst  = false
    end,
}

_AST.visit(F)
