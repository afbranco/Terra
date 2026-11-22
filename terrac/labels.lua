_LABELS = {
    list = {},      -- { [lbl]={}, [i]=lbl }
    code = '',
    gte2lbl = {},   --
}

function new (lbl)
    lbl.id = lbl[1] .. (lbl[2] and '' or '_' .. #_LABELS.list)
    lbl.id = string.gsub(lbl.id, '%$','_')

    _LABELS.list[lbl] = true
    lbl.n = #_LABELS.list                   -- starts from 0
    _LABELS.list[#_LABELS.list+1] = lbl
    lbl.par = {}                            -- { [lblK]=true }

    for n in _AST.iter() do
        if n.lbls_all then
            n.lbls_all[lbl] = true
        end
    end
    return lbl
end

F = {
    Exp = function (me)
        if me.accs then
            for _, acc in ipairs(me.accs) do
                acc.lbl_ana = new{'Exp', acc=acc}
            end
        end
    end,

    Root_pre = function (me)
        new{'Inactive', true}
        new{'Init', true}
    end,

    Root = function (me)
        assert(#_LABELS.list < 2^(_ENV.c.tceu_nlbl.len*8))
        me.lbl_ana = new{'Exit'}

        -- enum of labels
        for i, lbl in ipairs(_LABELS.list) do
            _LABELS.code = _LABELS.code..'    '..lbl.id..' = '..lbl.n..',\n'
        end
    end,

    _Escape_pre = function (me)
        me.lbls_emt = { #_LABELS.list }
    end,
    _Escape = function (me)
        me.lbls_emt[2] = #_LABELS.list-1
    end,

    Prog    = '_Escape',
--    CfgBlk  = '_Escape',


    SetBlock_pre = function (me)
        F._Escape_pre(me)
        me.lbl_ana_no = new{'SetBlock_no', to_reach=false,
                            me=me, err='end of block'}
        me.lbl_out = new{'Set_out', tree=me.depth,
                        me=me, err='`return´ from block'}
        if me[1][1][1] ~= '$ret' then
            me.lbl_out.to_reach = true
        end
    end,
    SetBlock = '_Escape',

    _Par_pre = function (me)
        me.lbls_in  = {}
        for i, sub in ipairs(me) do
            me.lbls_in[i] = new{me.tag..'_sub_'..i}
            sub.lbls_all = {}
        end
    end,
    ParEver_pre = function (me)
        F._Par_pre(me)
        me.lbl_tst = new{'ParEver_chk'}
        me.lbl_ana_out = new{'ParEver_out'}
        me.lbl_ana_no  = new{'ParEver_no', to_reach=false,
                        me=me, err='end of `par´'}
    end,
    ParOr_pre = function (me)
        F._Par_pre(me)
        me.lbl_out = new{'ParOr_out', tree=me.depth, to_reach=true,
                        me=me, err='end of `par/or´'}
        F._Escape_pre(me)
    end,
    ParAnd_pre = function (me)
        F._Par_pre(me)
        me.lbl_tst = new{'ParAnd_chk'}
        me.lbl_ana_out = new{'ParAnd_out', to_reach=true,
                        me=me, err='end of `par/and´'}
    end,

    ParEver = function (me)
        for i=1, #me do
            local t1 = me[i].lbls_all
            for j=i+1, #me do
                local t2 = me[j].lbls_all
                for lbl1 in pairs(t1) do
                    for lbl2 in pairs(t2) do
                        lbl1.par[lbl2] = true
                        lbl2.par[lbl1] = true
                    end
                end
            end
        end
    end,
    ParAnd = 'ParEver',
    ParOr = function (me)
        F.ParEver(me)
        F._Escape(me)
    end,

    If = function (me)
        local c, t, f = unpack(me)
        me.lbl_t = new{'True'}
        me.lbl_f = f and new{'False'}
        me.lbl_e = new{'EndIf'}
    end,

    Async_pre = function (me)
        me.lbls_all = {}
    end,
    Async = function (me)
        for lbl in pairs(me.lbls_all) do
            lbl.to_reach = nil                          -- they are not simulated
        end
        me.lbl = new{'Async_'..me.gte, to_reach=true,   -- after `for´ above
                    me=me, err='`async´'}
    end,

    Loop_pre = function (me)
        me.lbl_ini = new{'Loop_ini'}
        me.lbl_ana_mid = new{'Loop_mid', to_reach=true,
                        me=me, err='`loop´ iteration'}
        me.lbl_out = new{'Loop_out', tree=me.depth }
        F._Escape_pre(me)
    end,
    Loop = '_Escape',

    EmitExtS = function (me)
        local e1 = unpack(me)
        if e1.ext.pre == 'output' then   -- e1 not Exp
            me.lbl_ana_emt = new{'Emit_'..e1.ext.id, acc=e1.acc}
        end
        me.lbl_cnt = new{'Async_cont'}
    end,
    EmitT = function (me)
        me.lbl_cnt = new{'Async_cont'}
    end,

    EmitInt = function (me)
        local int = unpack(me)
        me.lbl_ana_emt = new{'Emit_ana_emt_'..int.var.id, acc=int.accs[1]} -- int not Exp
        me.lbl_mch     = new{'Emit_mch_'..int.var.id}
        me.lbl_cnt     = new{'Emit_cnt_'..int.var.id}
        me.lbl_ana_cnt = new{'Emit_ana_cnt_'..int.var.id, to_reach=true,
                            me=me, err='continuation of `emit´'}

        -- TODO
        --if string.sub(int.var.id,1,4) == '$fin' then
            --me.lbl_cnt.to_reach = nil
        --end
    end,

    AwaitInt = function (me)
        local int = unpack(me)
        me.lbl_ana = new{'Await_ana_'..me[1][1], acc=int.accs[1]}
        me.lbl_awt = new{'Await_'..me[1][1]}
        me.lbl_awk = new{'Awake_'..me[1][1], to_reach=true,
                        me=me, err='awake of `await´'}
    end,
    AwaitT = function (me)
        if me[1].tag == 'WCLOCKE' then
          if (me[1][1][1].tag=='Var') then
            me.lbl = new{'Awake_'..me[1][1][1][1], to_reach=true,me=me, err='awake of `await´'}
          else
            me.lbl = new{'Awake_'..'exp', to_reach=true,me=me, err='awake of `await´'}
          end
        else
            me.lbl = new{'Awake_'..me[1].ms, to_reach=true,
                        me=me, err='awake of `await´'}
        end
    end,
    AwaitExt = function (me)
        me.lbl = new{'Awake_'..me[1][1], to_reach=true,
                    me=me, err='awake of `await´'}
        _LABELS.gte2lbl[me.gte] = me.lbl.n
    end,
}

_AST.visit(F)
