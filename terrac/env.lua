
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
    exts = {}, -- List of External Events
    ints = {}, -- List of Internal Events: {id=id,ln=ln}
    c = {
        void = 0,

        ubyte=1, ushort=2, ulong=4,
        byte=1, short=2, long=4,
        float=4,
        payload=1,

        pointer   = 2, --_OPTS.tp_pointer,
        tceu_noff = 2, --_OPTS.tp_off,
        tceu_nlbl = 2, --_OPTS.tp_lbl,
--        tceu_wclock = ceil(4 + _OPTS.tp_lbl + 2       -- TODO: perda de memoria :: +2 to adjust micaz struct size
--                          + (_OPTS.analysis_run and 4 or 0)),
        tceu_wclock = ceil(4 + 2 + 2),       -- TODO: perda de memoria :: +2 to adjust micaz struct size
                          
    },
    calls = {},     -- { _printf=true, _myf=true, ... }

    packets = {},
    n_asyncs  = 0,
    n_wclocks = 0,
    n_emits   = 0,
    awaits    = {},
    gate0     = 0; --afb
    n_ins     = 0; --afb
    n_outs     = 0; --afb
    n_ins_active = 0; --afb	
    vm_version = '0';
    extOut_nArgs={},
    func_nArgs={},
    dets  = {},
}

for k, v in pairs(_ENV.c) do
    _ENV.c[k] = { tag='type', id=k, len=v }
end

function newvar (me, blk, pre, tp, dim, id, read_only)

    -- Cheks if name is used by internal event
    for k,evt in ipairs(_ENV.ints) do
--print("env::newvar():",k,evt.id,evt.ln)
      ASR(not(evt.id==id), me,'event "'..id..'" was previously declared at line '..evt.ln)
    end
    -- Cheks for context definitions
    for stmt in _AST.iter() do
        if stmt.tag == 'Async' then
            break
        elseif stmt.tag == 'Block' then
            for _, var in ipairs(stmt.vars) do
                ASR(not(var.id==id and blk==stmt ), me,'var "'..id..'" was defined for same context at line '..var.ln)
                WRN(var.id~=id, me,'declaration of "'..id..'" hides the one at line '..var.ln)
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

    if isEvt then
      _ENV.ints[id] = {id=id,ln=me.ln}
      _ENV.ints[#_ENV.ints+1] = {id=id,ln=me.ln}
    end

    local nvar = {}
    if not(_TP.deref(tp)) and c.fields then
      local z1 = _TP.getAuxTag(tp,dim)
      local var = {
          ln    = me.ln,
          id    = id,
          tp    = (dim and tp..'*') or tp,
          blk   = blk,
          pre   = pre,
          isEvt = isEvt,
          arr   = dim,
          n_awaits = 0,
          fields ={},
          auxtag = z1.auxtag,
          supertp = c.supertp
      }
--print("env::newvar:",id,tp,c.supertp)
      blk.vars[#blk.vars+1] = var
      nvar[#nvar+1]=var
--print(print_r(c.fields,'env::newvar: c.fields'))
      for k, v in ipairs(c.fields) do
        local z1 = _TP.getAuxTag(tp,dim)
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
            auxtag = z1.auxtag,
        }
        blk.vars[#blk.vars].fields[#blk.vars[#blk.vars].fields+1] = var
        blk.vars[#blk.vars].fields[v.id] = var
        --nvar[#nvar+1]=var
      end
    else
        local z1 = _TP.getAuxTag(tp,dim)
        local var = {
            ln    = me.ln,
            id    = id,
            tp    = (dim and tp..'*') or tp,
            blk   = blk,
            pre   = pre,
            isEvt = isEvt,
            arr   = dim,
            n_awaits = 0,
            auxtag = z1.auxtag,
            read_only = read_only,
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

    Block_pos = function (me)
--print('env::Block_pos:',me.tag,#me.vars)
        for _, var in ipairs(me.vars) do
--print('env::Block_pos: var:',var.id,var.ln,var.auxtag,var.firstOper)
          ASR(not(var.auxtag=='pointer' and var.firstOper == 'Exp'),{ln=var.firstOperLn},'pointer "'.. var.id ..'" not initialized at this point.')
        end
    end,

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

    CfgBlk = function (me)
        local cfgParams = me[1]
        local name, n1, n2, n3 = unpack(cfgParams)
--print("env::CfgBlk:", unpack(cfgParams)) 
        _ENV.vm_name = name
        _ENV.vm_version = string.format("%03d.%03d.%03d",(n1 or 0),(n2 or 0),(n3 or 0))
        _ENV.motes_max_size = {}
        for i=5,#cfgParams,2 do
          _ENV.motes_max_size[cfgParams[i]]=cfgParams[i+1]
        end
    end,
    
    Dcl_ext = function (me)
        local dir, mod, retTp, id, argTp, idx = unpack(me)
--print(print_r(_ENV.c,"ENV.c"))
--        ASR(tp=='void' or _TP.deref(tp)) or _ENV.c[tp],me, 'invalid event type')
  
--print("env::Dcl_ext:",id, tp, _TP.isBasicType(tp),_TP.deref(tp), (_TP.isBasicType(tp) or  _TP.deref(tp)) )
--        ASR( (_TP.isBasicType(tp) or  _TP.deref(tp)),me, 'invalid event type')
        local tp,idAux
        idAux = id .. (( (dir=='input' and argTp~='void') and '()') or '')
        tp = (dir=='output' and argTp) or retTp
--print("env::Dcl_ext:", dir, retTp, id, argTp, idx, '|', idAux,tp)

        for k,val in ipairs(_ENV.exts) do
          if val.pre==dir then 
            ASR(not (val.id==idAux), me, 'event "'..idAux..'" is already declared at line '.. (val.ln or 0))
            ASR(not (val.idx==idx), me, dir..' event numeric id "'..idx..'" is already in use at line '.. (val.ln or 0))
          end
        end
        ASR(_ENV.c[tp] or _ENV.packets[tp],me,'type/packet not defined')
        ASR(idx<255, me, dir..' event numeric id must be less than 255')
        me.ext = {
            ln    = me.ln,
            id    = idAux,
            n     = #_ENV.exts,
            tp    = tp,
            pre   = dir,
            isEvt = true,
            idx   = idx,
            inArg = (dir=='input' and argTp~='void'),
            mod = mod
        }
        _ENV.exts[idAux] = me.ext
        _ENV.exts[#_ENV.exts+1] = me.ext
        -- Force 0 or 1 args -- void or non void
        if dir == 'output' then 
          _ENV.extOut_nArgs[idx] = ((tp=='void') and 0) or 1
        end
    end,

    Dcl_int = 'Dcl_var',
    Dcl_var = function (me)
        local pre, tp, dim, id, exp = unpack(me)
        ASR(_ENV.c[tp] or _ENV.c[_TP.deref(tp)],me,'invalid type')
        local z =  _TP.getAuxTag(tp,dim)
        ASR( z.lvl <= 1, me,'invalid pointer to pointer type')
--print("env::Dcl_var:",tp,dim,id, _TP.isBasicType(_TP.deref(tp) or tp),(not dim) or  _TP.isBasicType(_TP.deref(tp) or tp),me.read_only)
        ASR( (not dim) or  _TP.isBasicType(_TP.deref(tp) or tp),me,'Arrays can have only basic types')
        me.var = newvar(me, _AST.iter'Block'(), pre, tp, dim, id,me.read_only)
    end,

    Dcl_regt = function(me)
--print(print_r(me,"env::Dcl_regt: me"))
      local RegId = me[1]
      ASR(not _ENV.c[RegId],me,'Register type `'.. RegId ..'´ is already declared as Register.')
      ASR(not _ENV.packets[RegId],me,'Register type `'.. RegId ..'´ is already declared as Packet.')
      local RegFields= {}
      local memsize = 0
      local offset = 0
      local lastSize = 0
      for i=2, #me do
        offset = offset + lastSize
        local var = me[i]
--print('env::Dcl_regt: var',var)
        local  pre, tp, dim, id = unpack(var)
        ASR(not RegFields[id],var,'duplicated field id `'..id ..'´')
        local len = ((dim and dim*_ENV.c[var[2]].len) or _ENV.c[var[2]].len)
        lastSize = len
        RegFields[id]={pre=pre,tp=tp,dim=dim,id=id,len=len,offset=offset}
        RegFields[i-1]=RegFields[id]
--print('env::Dcl_regt:',tp,id)
        memsize = memsize + len
      end
      _ENV.c[RegId] = { tag='type', id=RegId, len=memsize , fields=RegFields}
    end,

    Dcl_packet = function(me)
--print(print_r(me,"env::Dcl_packet: me"))
      local RegId = me[1]
      ASR(not _ENV.packets[RegId],me,'Packet type `'.. RegId ..'´ is already declared as Packet.')
      ASR(not _ENV.c[RegId],me,'Packet type `'.. RegId ..'´ is already declared as Register.')
      local RegFields= {}
      local memsize = 0
      local offset = 0
      local lastSize = 0
      local payloadCount=0
      for i=2, #me do
        offset = offset + lastSize
        local var = me[i]
--print('env::Dcl_regt: var',var)
        local  pre, tp, dim, id = unpack(var)
        ASR(not RegFields[id],var,'duplicated field id `'..id ..'´')
        local len = ((dim and dim*_ENV.c[var[2]].len) or _ENV.c[var[2]].len)
        lastSize = len
        RegFields[id]={pre=pre,tp=tp,dim=dim,id=id,len=len,offset=offset}
        RegFields[i-1]=RegFields[id]
--print('env::Dcl_regt:',tp,id)
        memsize = memsize + len
        if tp == 'payload' then payloadCount = payloadCount + 1 end
      end
      ASR(payloadCount == 1, me,'packet needs exactly one `payload´ type, it received '..payloadCount)
      _ENV.packets[RegId] = { tag='type', id=RegId, len=memsize , fields=RegFields}
    end,

    Dcl_pktype = function(me)
--print(print_r(me,"env::Dcl_pktype: me"))
      local RegId = me[1]
      local packet = me[2]
      ASR(not _ENV.c[RegId],me,'Register type `'.. RegId ..'´ is already declared.')
      ASR(_ENV.packets[packet],me,'packet type `'.. packet ..'´ is not defined.')
      local RegFields= {}
      local memsize = 0
      local offset = 0
      local lastSize = 0
      local pos = 1
--print('env::Dcl_pktype: subtype:supertype',RegId,packet,_ENV.packets[packet].fields)
--print(print_r(RegFields,"env::Dcl_pktype: RegFields"))

      for x, field in ipairs(_ENV.packets[packet].fields) do
        if field.tp ~= 'payload' then
          RegFields[field.id] = field
          RegFields[pos] = field
          pos = pos + 1
        else
          offset = field.offset
          lastSize=0
          for i=3, #me do
            offset = offset + lastSize
            local var = me[i]
--print('env::Dcl_pktype: var',var)
            local  pre, tp, dim, id = unpack(var)
            ASR(not RegFields[id],var,'duplicated field id `'..id ..'´')
            local len = ((dim and dim*_ENV.c[var[2]].len) or _ENV.c[var[2]].len)
            lastSize = len
            RegFields[id]={pre=pre,tp=tp,dim=dim,id=id,len=len,offset=offset}
            RegFields[pos]=RegFields[id]
            pos = pos + 1
--print('env::Dcl_pktype:',tp,id)
            memsize = memsize + len
            ASR(memsize<=field.len,me,'subtype size '.. memsize ..' is  greater than payload size '..field.len)
          end
          if memsize < field.len then -- complete remain bytes
            local dim = (field.len - memsize)
            RegFields._remain={pre=field.pre,tp='ubyte',dim=dim,id='_remain',len=(dim*1),offset=offset + lastSize}
            RegFields[pos]=RegFields._remain
            pos = pos + 1
          end
        end
      end
--print(print_r(RegFields,"env::Dcl_pktype: RegFields"))
      _ENV.c[RegId] = { tag='type', supertp=packet, id=RegId, len=_ENV.packets[packet].len , fields=RegFields}
    end,

    Dcl_func = function (me)
       local op,mod,tp,id,args,idx = unpack(me)
--print("env::Dcl_func:", op, mod, tp, id, #args, idx)
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
          ASR(not(tp=='void') and (_ENV.c[tp] or _ENV.c[_TP.deref(tp)] or _ENV.packets[tp]) ,me, '<'..tp..'> in position '..k..' is invalid argument type in function <'..id..'>')
          ASR((_TP.isBasicType(tp) or _TP.isBasicType(_TP.deref(tp))) or not _TP.deref(tp),me, 'register <'..tp..'> in position '..k..' in function <'..id..'> can not be a pointer.')
        end
        me.ext = {
            ln    = me.ln,
            mod   = mod,
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
        _ENV.func_nArgs[idx] = #args
    end,

    Ext = function (me)
        local id = unpack(me)
--print("env::Ext:",id,_ENV.exts[id], _ENV.exts[id .. '()'])
        me.ext = ASR(_ENV.exts[id] or _ENV.exts[id .. '()'],me, 'event "'..id..'" is not declared') -- moved to AwaitExt
    end,

    Func = function (me)
--print("env::Func:",me[1],me.blk)
--print(print_r(me,"env::Func: me"))
        local id = unpack(me)
        ASR(_ENV.exts[id],me, 'function "'..id..'" is not declared')
        me.ext = _ENV.exts[id]
        me.tp = _ENV.exts[id].tp
        
        if not (me.ext and (me.ext.mod=='pure' or me.ext.mod=='nohold')) then
            for pos, tp in ipairs(me.ext.args) do
                if _TP.deref(tp) or not _TP.isBasicType(tp)  then
                    local blk = me.blk or _AST.iter('Block')()
                    ASR(blk.fin, me,
                        'block at line '..blk.ln..' must contain `finally´')
                end
            end
        end

    end,


   
    Var = function (me)
        local id, idField = unpack(me)
--print("env::Var:",id)
--print(print_r(me,"env::Var: me"))
        local blk = me.blk or _AST.iter('Block')()
--print(print_r(blk.vars,"env::Var: blk.vars"))
        while blk do
            for i=#blk.vars, 1, -1 do   -- n..1 (hidden vars)
                local var = blk.vars[i]
                if var.id == id then
--print("env::Var:",id,me.read_only)
--print(print_r(var,"env::Var: var"))
                  me.var  = var
                  me.tp   = var.tp
                  me.lval = (not var.arr)
                  me.fst  = var
                  me.arr = var.arr
                  me.auxtag = var.auxtag
                  me.supertp = var.supertp
                  me.ref = me
                  me.read_only = var.read_only
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
        ASR(_ENV.exts[id1],me,'event or function `' .. id1 .. '´ was not found.')
        local t1 = _ENV.dets[id1] or {}
        _ENV.dets[id1] = t1
        for i=2, #me do
            local id2 = det2id(me[i])
            ASR(_ENV.exts[id2],me,'event or function `' .. id2 .. '´ was not found.')
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
        local e1,e2 = unpack(me)
        local idAux = e1[1] .. ((e2 and '()') or '')
--print("env::AwaitExt:",idAux..'|'..((e2 and '()') or '')..'|')
        me[1].ext =  _ENV.exts[idAux] or me[1].ext -- Try to overhide value got in 'Exp'
--print("env::AwaitExt:",e1.ext.id,e1.ext.idx, e1.ext.pre, e2, (e2 and e2.tag),(e2 and e2.tp),(e2 and e2[1].tag))
        ASR(e1.ext.pre == 'input',me,'await expect an input event, a time expression, or a var event.')

        if e2 then
          ASR(_ENV.exts[idAux],me,'event '.. e1[1] ..' doesn´t expect any argument.')
          local err,cast = _TP.tpCompat('ubyte',e2.tp,nil,nil)
          ASR(not err,me,'type/size incompatibility: '.. 'ubyte' ..' <--> '.. e2.tp..'')
          WRN(not cast,me, 'Automatic casting from `'.. e2.tp ..'´ to `' .. 'ubyte' ..'´. ')
        else
          ASR(_ENV.exts[idAux] ,me,'event '.. e1[1] ..' expect an `ubyte/byte´ argument.')
        end
        
        me.gte = (_ENV.awaits[e1.ext] or 0)
        _ENV.awaits[e1.ext] = (_ENV.awaits[e1.ext] or 0) + 1
    end,

    AwaitInt = function (me)
        local exp,_ = unpack(me)
        local var = exp.var
        ASR(var and var.isEvt, me,'event "'..(var and var.id or '?')..'" is not declared')
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
        if (e2) then
print("env::EmitInt:",e1.var.tp,e2.tp)
          err, cast,_,_, len1, len2 = _TP.tpCompat(e1.var.tp,e2.tp)
          ASR(not err,me,'type/size incompatibility: '.. e1.var.tp..'/'..len1 ..' <--> '.. e2.tp..'/'..len2..'')
          WRN(not cast,me, 'Automatic casting from `'.. e2.tp ..'´ to `' .. e1.var.tp ..'´. ')
        end
        me.gte = _ENV.n_emits
        _ENV.n_emits = _ENV.n_emits + 2     -- (cnt/awk)
    end,

    EmitExtS = function (me)
        local e1, _ = unpack(me)
        ASR(e1.ext.pre=='output', me, 'emit expect an output event or a var event.')
        if e1.ext.pre=='output' then
            F.EmitExtE(me)
        end
    end,
    EmitExtE = function (me)
        local e1, e2 = unpack(me)
        ASR(e1.ext.pre=='output', me, 'invalid input `emit´')
        me.tp = e1.ext.tp

        if e2 then
          err, cast,_,_,len1,len2 = _TP.tpCompat((e1.ext.supertp or e1.ext.tp),(e2.supertp or e2.tp),nil,e2.arr)
          ASR(not err,me,'type/size incompatibility: '.. e1.ext.tp..'/'..len1 ..' <--> '.. e2.tp..'/'..len2..'')
          WRN(not cast,me, 'Automatic casting from `'.. e2.tp ..'´ to `' .. e1.ext.tp ..'´. ')
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
--print('env::SetExp:',e1.tag,e2.tag, e1[1].tag, e2[1].tag, e1.lval,e1.tp,e2.tp,e1[1].arr,e2[1].arr,no_fin)
--        WRN(e1.lval and _TP.contains(e1.tp,e2.tp,true),me, 'invalid attribution: ['.. e1.tp ..'] can not contain [' .. e2.tp ..']')
          ASR(not (e1[1].tag=='CONST'),me,'constant at left side of attribution.')
          ASR(not (e1[1].tag=='Op1_&'),me,'VarAddr at left side of attribution.')

        local error, cast, tp1,tp2,len1,len2 = _TP.tpCompat((e1.supertp or e1.tp),(e2.supertp or e2.tp),e1[1].arr,e2[1].arr)
          ASR(not error,me,'type incompatibility: `'.. (e1.supertp or e1.tp) ..'´ <--> `'.. (e2.supertp or e2.tp) ..'´')
          WRN(not cast,me, 'Automatic casting from `'.. (e2.supertp or e2.tp) ..'´ to `' .. (e1.supertp or e1.tp) ..'´. ')

        if no_fin then
            return              -- no `finally´ required
        end

-- :: afb ::
-- Can't pass here, current function implementation only returns a non pointer integer type. 
-- If it changes, the below code must be reviewed.

--        if _TP.deref(e1.tp) then
--            local blk1 = (e1.fst=='_' and _AST.root) or e1.fst.blk
--            if e2.fst and e2.fst~='_' then
--                local blk2 = e2.fst.blk
--                ASR(blk2.fin or blk2.depth<=blk1.depth, me,
--                    'block at line '..blk2.ln..' must contain `finally´')
--                -- int a; pa=&a;    -- `a´ termination must consider `pa´
--            else
--                ASR(blk1.fin or e2[1].tag~='Op2_call' or e2[1].c.mod=='pure',
--                    me, 'block at line '..blk1.ln..' must contain `finally´')
--                -- int* pa = _f();   -- `pa´ termination must consider `_f´
--            end
--        end
    end,

    SetAwait = function (me)
        local e1, awt = unpack(me)
        ASR(e1.lval, me, 'invalid attribution: not a value')
        if awt.ret.tag == 'AwaitT' then
            ASR(_TP.isNumeric(e1.tp,true), me, 'invalid attribution: not a numeric value')
        else    -- AwaitInt / AwaitExt
            local evt = awt.ret[1].var or awt.ret[1].ext
--print("env::SetAwait:",e1.supertp, e1.tp)
            -- ASR(_TP.contains(e1.tp,evt.tp,true), me, 'invalid attribution: ['.. e1.tp ..'] can not contain [' .. evt.tp ..']')
            local error, cast, tp1,tp2,len1,len2 = _TP.tpCompat((e1.supertp or e1.tp),evt.tp,e1[1].arr,awt[1].arr)
            ASR(not error,me,'type/size incompatibility: '.. e1.tp..'/'..len1 ..' <--> '.. evt.tp..'/'..len2..'')
            WRN(not cast,me, 'Automatic casting from `'.. evt.tp ..'´ to `' .. e1.tp ..'´. ')
        end
        me.fst = awt.fst
    end,

    CallStmt = function (me)
        local call = unpack(me)
--print("env::CallStmt:",call[1].tag)
        ASR(call[1].tag == 'Op2_call', me, 'invalid statement')
    end,

    --------------------------------------------------------------------------

    LExp = function (me)
--print("env::LExp:",me.tag,me[1].auxtag,me[1].tag, me[1].arr, me[1][1],me[1].read_only)
--print(print_r(me,"env::Exp: me"))
--        ASR(not(me[1].tag=='Var' and (me[1].arr)),me,'missing array index for "'..me[1][1]..'".')
        ASR(not(me[1].read_only),me,'`'.. me[1][1] .. '´ is a read only variable')

        me.lval = me[1].lval
        me.tp   = me[1].tp
        me.fst  = me[1].fst
        me.supertp = me[1].supertp
    end,

    Exp = function (me)
--print("env::Exp:",me.tag,me[1].auxtag,me[1].tag,me[1][1])
--print(print_r(me,"env::Exp: me"))
--        ASR(not(me[1].tag=='Var' and (me[1].arr)),me,'missing array index for "'..me[1][1]..'".')
        me.lval = me[1].lval
        me.tp   = me[1].tp
        me.fst  = me[1].fst
        me.supertp = me[1].supertp
    end,

--[[ -- C Calls are not used in Terra
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
--]]

    Op2_idx = function (me)
--print(print_r(me,"env:Op2_idx: me"))
--print("env::Op2_idx:",me[2][1],me[2].tag,me[2].tp,me[2][2],me[3][1],me[3].tag,me[3].tp)
        local _, arr, idx = unpack(me)
--print("env::Op2_idx:",arr.tp)
        ASR(arr.arr, me, 'cannot index a non array')
        local _arr = ASR(_TP.deref(arr.tp,true), me, 'cannot index a non array')
--        ASR(_arr and _TP.isNumeric(idx.tp,true), me, 'invalid array index')
        --me.tp   = _TP.deref(me[2].tp)
        me.tp   = _arr
        me.lval = true
        me.fst  = arr.fst
        me.ref = arr.ref
    end,

    Op2_int_int = function (me)
        local op, e1, e2 = unpack(me)
--print("env::Op2_int_int:",e2.tag,e2[1])
        ASR(_TP.isNumeric(e1.tp,true) and _TP.isNumeric(e2.tp,true),me, 'invalid operands to binary "'..op..'"')
--        ASR((e2.tag=='CONST' and tonumber(e2[1])>0) or (e2.tag~='CONST'),me, 'division by zero')
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
        me.tp  = (op=='not' and 'ubyte')  or e1.tp
    end,
    ['Op1_~']  = 'Op1_int',
    ['Op1_-']  = 'Op1_int',

    Op2_same = function (me)
        local op, e1, e2 = unpack(me)
        ASR(_TP.max(e1.tp,e2.tp,true),
                me, 'invalid operands to binary "'..op..'"')
        me.tp  = 'ubyte'
    end,
    ['Op2_=='] = 'Op2_same',
    ['Op2_!='] = 'Op2_same',
    ['Op2_>='] = 'Op2_same',
    ['Op2_<='] = 'Op2_same',
    ['Op2_>']  = 'Op2_same',
    ['Op2_<']  = 'Op2_same',

    Op2_any = function (me)
        local op, e1, e2 = unpack(me)
        me.tp  = 'ubyte'
    end,
    ['Op2_or']  = 'Op2_any',
    ['Op2_and'] = 'Op2_any',
    ['Op1_not'] = 'Op1_int',

--    ['Op1_*'] = function (me)
--        local op, e1 = unpack(me)
--        local tp
--        
----print("env::Op1_*:",e1.tp,e1.tag,e1[2])
--        ASR(_TP.deref(e1.tp, true) and e1.tag~='CONST', me, 'invalid operand to unary "*"')
--        me.tp   = _TP.deref(e1.tp, true)
--        me.lval = true
--        me.fst  = e1.fst
--        
------print(print_r(e1,"env::Op1_*: e1"))
----      if (e1.tag=='Var') then  -- single var/field (not array) 
----        if (e1[2]) then -- field
----          ASR(_TP.deref(e1.tp, true) and e1.tag=='Var', me, 'invalid operand to unary "*"')
----          ASR(_ENV.c[_TP.deref(e1.tp)].fields[e1[2]], me, 'invalid field "'.. e1[2] ..'" for "'.. _TP.deref(e1.tp) ..'" register type.')
----          tp   = _ENV.c[_TP.deref(e1.tp)].fields[e1[2]].tp
----          me.offset = _ENV.c[_TP.deref(e1.tp)].fields[e1[2]].offset
----        else  -- var
----          ASR(_TP.deref(e1.tp, true) and e1.tag=='Var', me, 'invalid operand to unary "*"')
----          tp   = _TP.deref(e1.tp, true)
----        end
----      else    -- Op2_idx
----print("env::Op1_*:",e1.tag,e1[2][1],e1[2][2])
----        if (e1[2][2]) then -- field array
------print("env::Op1_*:",e1.tp,e1.tag,e1[2][2])--,_ENV.c[e1.tp].fields[e1[2][2]].tp,_ENV.c[e1.tp].fields[e1[2][2]].dim)
----          tp   = e1.tp
----          me.dim = e1.dim
----        else -- var array
----          tp = _TP.deref(e1.tp)
----        end
----      end
----      me.tp   = tp
----      me.lval = true
----      me.fst  = e1.fst        
--    end,

    ['Op1_&'] = function (me)
        local op, e1 = unpack(me)
        ASR(e1.lval, me, 'invalid operand to unary "&"')
        me.tp   = e1.tp..'*'
        me.lval = false
        me.fst  = e1.fst
        me.ref = e1.ref
    end,

    ['Op2_.'] = function (me)
        local op, e1, id = unpack(me)
        ASR(_ENV.c[_TP.deref(e1.tp) or e1.tp].fields, me,'var "'.. e1[1]..'" is not a register. ')
        local field = _ENV.c[_TP.deref(e1.tp) or e1.tp].fields[id]
        ASR(field, me, 'invalid field name')
        me.tp   = (field.dim and field.tp..'*') or field.tp
        me.lval = true
        me.fst  = e1.fst
        me.arr = field.dim
        me.ref = e1.ref
    end,

    Op_var = function (me)
        local op, exp = unpack(me)
--print("env::Op_var:", op,exp[1].tag,exp[1].tp, exp[1].tag,exp[1].lval,exp[1].fst,_TP.isNumeric(exp.tp),_TP.deref(exp.tp))
        ASR((exp.tag=='Var' or exp.tag=='Op2_idx' or exp.tag=='Op2_.') and _TP.isBasicType(exp.tp), me, 'invalid "inc/dec" target. Received a "'..exp.tag..'" of type "'..exp.tp..'"')
        me.tp   = exp.tp
        me.lval = exp.lval
        me.fst  = exp.fst
        me.ref = exp.ref
     end,

    Op1_cast = function (me)
        local tp, exp = unpack(me)
--print("env::Op1_cast:", tp)
        ASR(not _TP.deref(exp.tp),me,'can not cast an address value')
        ASR(_TP.isBasicType(exp.tp),me,'can not cast register types')
        me.tp   = tp
        me.lval = exp.lval
        me.fst  = exp.fst
        me.ref = exp.ref
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
--print("env::SIZEOF")
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
        --ASR(_TP.getConstLen(v) < 3,me,'Constant > 32bits size')
        me.tp   = _TP.getConstType(v,me)
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
