_ANA.ana.acc  = 0      -- nd accesses
_ANA.ana.abrt  = 0      -- nd flows
_ANA.ana.excpt = 0      -- nd excpt

-- any variable access calls this function
-- to be inserted on parent Parallel sub[i] or Class
function iter (n)
    local par = n.__par and n.__par.tag
--print("acc::iter:",n.tag,par)
    return par=='ParOr' or par=='ParAnd' or par=='ParEver'
--        or n.tag=='Dcl_cls'
end

function INS (acc, exists)
-- afb comment 'cls'
--    if not exists then
--        acc.cls = CLS()                     -- cls that acc resides
--    end
    local n = _AST.iter(iter)()             -- child Block from PAR
--print("acc::INS:",n)
    if n then
        n.ana.accs[#n.ana.accs+1] = acc
    end
    return acc
end

F = {
-- accs need to be I-indexed (see CHK_ACC)
    Dcl_cls_pre = function (me)
        me.ana.accs = {}
    end,
    ParOr_pre = function (me)
        for _, sub in ipairs(me) do
            sub.ana.accs = {}
        end
    end,
    ParAnd_pre  = 'ParOr_pre',
    ParEver_pre = 'ParOr_pre',

    ParOr_pos = function (me)
        -- insert all my subs on my parent Par
        if _AST.iter(_AST.pred_par) then -- requires ParX_pos
            for _, sub in ipairs(me) do
                for _,acc in ipairs(sub.ana.accs) do
    -- check par/enter only against immediate pars
                    if acc.md ~= 'par' then
    -- check ParOr esc only against immediate pars
                    if not (acc.md=='esc' and acc.id.tag=='ParOr') then
    -- check Loop esc only against nested pars
                    --if not (acc.md=='esc' and acc.id.tag=='Loop'
                            --and acc.id.depth>me.depth) then
                        INS(acc, true)
                    --end
                    end
                    end
                end
            end
        end
    end,
    ParAnd_pos  = 'ParOr_pos',
    ParEver_pos = 'ParAnd_pos',

    Spawn = 'SetNew',
    SetNew = function (me)
        for _,acc in ipairs(me.cls.ana.accs) do
            INS(acc, true)
        end
    end,

-- TODO: usar o Dcl_var p/ isso
--[=[
    Orgs = function (me)
        -- insert cls accs on my parent ParOr
        for _, var in ipairs(me.vars) do
            for _,acc in ipairs(var.cls.ana.accs) do
                INS(acc, true)
            end
        end
    end,
]=]

    EmitExtS = function (me)
        local e1, _ = unpack(me)
--        if e1.evt.pre == 'output' then
        if e1.ext.pre == 'output' then
            F.EmitExtE(me)
        end
    end,
    EmitExtE = function (me)
        local e1, e2 = unpack(me)
        INS {
            path = me.ana.pre,
--            id  = e1.evt.id,    -- like functions (not table events)
            id  = e1.ext.id,    -- like functions (not table events)
            md  = 'cl',
            tp  = '_',
            any = false,
--            err = 'event `'..e1.evt.id..'´ (line '..me.ln..')'
            err = 'event `'..e1.ext.id..'´ (line '..me.ln..')',
            tag = 'EmitExt'
        }
--[[
        if e2 then
            local tp = _TP.deref(e1.evt.tp, true)
            if e2.accs and tp then
                e2.accs[1][4] = (e2.accs[1][2] ~= 'no')   -- &x does not become 
                    "any"
                e2.accs[1][2] = (me.c and me.c.mod=='pure' and 'rd') or 'wr'
                e2.accs[1][3] = tp
            end
        end
]]
    end,

    Func = function (me)
        local f = unpack(me)
        INS {
            path = me.ana.pre,
            id  = f,    -- like functions (not table events)
            md  = 'cl',
            tp  = '_',
            any = false,
            err = 'function `'.. f ..'´ (line '..me.ln..')',
            tag = 'Func'
        }
    end,

    Op2_call = function (me)
        local _, f, exps = unpack(me)
        local ps = {}
        f.ref.acc.md = 'cl'
        for i, exp in ipairs(exps) do
            local tp = _TP.deref(exp.tp, true)
            if tp then
                local v = exp.ref
                if v then   -- ignore constants
--DBG(exp.tag, exp.ref)
                    v.acc.any = exp.lval    -- f(&x) // a[N] f(a) // not "any"
                    v.acc.md  = (me.c and me.c.mod=='pure' and 'rd') or 'wr'
                    v.acc.tp  = tp
                end
            end
        end
    end,

    EmitInt = function (me)
        local e1, e2 = unpack(me)
--print("acc::EmitInt:",e1[1])
        if string.sub(e1[1],1,4) == '$fin' then
          e1.ref.acc.md   = 'no'
        else
          e1.ref.acc.md   = 'tr'
        end
        e1.ref.acc.node = me        -- emtChk
        me.emtChk = false
        e1.ref.acc.tag = 'EmitInt'
    end,

    SetAwait = 'SetExp',
    SetExp = function (me)
--print("acc::SetExp1:",me.tag, me[1][1][1] ,me[1].tag,me[1][1].ref,me[1][1].ref.acc.md)
        me[1][1].ref.acc.md = 'wr'
        me[1][1].ref.acc.setEvt = ((me[2].tag=='AwaitExt' or me[2].tag=='AwaitInt') and me[2]) or nil
    end,
    AwaitInt = function (me)
        me[1].ref.acc.md = 'aw'
        F.AwaitExt(me)  -- flow
    end,
    
    Op_var = function (me)
        local op, exp = unpack(me)
        exp.ref.acc.md = 'wr'
    end,

    ['Op1_*'] = function (me)
        me.ref.acc.any = true
        me.ref.acc.tp  = _TP.deref(me.ref.acc.tp,true)
    end,
    ['Op1_&'] = function (me)
        me.ref.acc.md = 'no'
    end,

    ['Op2_.'] = function (me)
        if me.org then
            me.ref.acc.org = me.org.ref
        end
    end,

--    Global = function (me)
--        me.acc = INS {
--            path = me.ana.pre,
--            id  = 'Global',
--            md  = 'rd',
--            tp  = me.tp,
--            any = true,
--            err = 'variable `global´ (line '..me.ln..')',
--        }
--    end,
--
--    This = function (me)
--        me.acc = INS {
--            path = me.ana.pre,
--            id  = me,
--            md  = 'rd',
--            tp  = me.tp,
--            any = true,
--            err = 'variable `this´ (line '..me.ln..')',
--        }
--    end,

    Var = function (me)
        me.acc = INS {
            path = me.ana.pre,
            id  = me.var,
            md  = 'rd',
            tp  = me.var.tp,
            any = false,
            err = 'variable/event `'..me.var.id..'´ (line '..me.ln..')',
        }
    end,

--    Nat = function (me)
--        me.acc = INS {
--            path = me.ana.pre,
--            id  = me[1],
--            md  = 'rd',
--            tp  = '_',
--            any = false,
--            err = 'symbol `'..me[1]..'´ (line '..me.ln..')',
--        }
--    end,

    -- FLOW --

    Break = function (me, TAG, PRE)
        TAG = TAG or 'Loop'
        PRE = PRE or me.ana.pre
        local top = _AST.iter(TAG)()
        INS {
            path = PRE,
            id  = top,
            md  = 'esc',
            err = 'escape (line '..me.ln..')',
        }
    end,
    Return = function (me)
        F.Break(me, 'SetBlock')
    end,
    Node = function (me)
        local top = me.__par and me.__par.tag
        if top == 'ParOr' then
            if not me.ana.pos[false] then
                F.Break(me, 'ParOr', me.ana.pos)
            end
        end

        if top=='ParOr' or top=='ParAnd' or top=='ParEver' then
            if not me.ana.pre[false] then
                me.parChk = false           -- only chk if ND flw
                INS {
                    path = me.ana.pre,
                    id   = me,--.__par,
                    md   = 'par',
                    err  = 'par enter (line '..me.ln..')',
                }
            end
        end
    end,

    AwaitExt = function (me)
        INS {
            path = me.ana.pos,
            id  = me,--_AST.iter(TAG)(),
            md  = 'awk',
            err = 'awake (line '..me.ln..')',
        }
    end,
    AwaitT = 'AwaitExt',
    --AwaitInt = <see above>,
}

_AST.visit(F)

------------------------------------------------------------------------------

local ND = {
    acc = { par={},awk={},esc={},
        cl  = { cl=true, tr=true,  wr=true,  rd=true,  aw=true  },
--        tr  = { cl=true, tr=true,  wr=false, rd=false, aw=true  },
        tr  = { cl=true, tr=true,  wr=false, rd=false, aw=false  },
        wr  = { cl=true, tr=false, wr=true,  rd=true,  aw=false },
        rd  = { cl=true, tr=false, wr=true,  rd=false, aw=false },
        aw  = { cl=true, tr=true,  wr=false, rd=false, aw=false },
        no  = {},   -- never ND ('ref')
    },

    flw = { cl={},tr={},wr={},rd={},aw={},no={},
        par = { par=false, awk=false, esc=true },
        awk = { par=false, awk=false, esc=true },
        esc = { par=true,  awk=true,  esc=true },
    },
}

local ALL = nil     -- holds all emits starting from top-most PAR

--[[
    ana = {
        acc = 1,  -- false positive
    },
    ana = {
        isForever = true,
        n_unreachs = 1,
    },
]]

-- {path [A]=true, [a]=true } => {ret [A]=true, [aX]=true,[aY]=true }
-- {T [a]={[X]=true,[Y]=true} } (emits2pres)
local function int2exts (path, NO_emts, ret)
    ret = ret or {}

    local more = false                  -- converged
    for int in pairs(path) do
        if type(int)=='table' and int[1].pre=='event' then
            for emt_acc in pairs(ALL) do
                if int[1]==emt_acc.id and (not NO_emts[emt_acc]) then
                    for ext in pairs(emt_acc.path) do
                        if not ret[ext] then
                            more = true         -- not converged yet
                            ret[ext] = true     -- insert new ext
                        end
                    end
                end
            end
        else
            ret[int] = true             -- already an ext
        end
    end
    if more then
        return int2exts(ret, NO_emts, ret, cache) -- not converged
    else
        if next(ret)==nil then
            ret[false] = true   -- include "never" if empty
        end
        return ret
    end
end

function par_rem (path, NO_par)
    for id in pairs(path) do
        if NO_par[id] then
            path[id] = nil
        end
    end
    if next(path)==nil then
        path[true] = true       -- include "tight" became empty
    end
    return path
end

function par_isConc (path1, path2, T)
    for id1 in pairs(path1) do
        for id2 in pairs(path2) do
            if (id1 == false) then
            elseif (id1 == id2) or
                     (type(id1) == 'table') and (type(id2) == 'table') and
                     (id1[1] == id2[1])
            then
                return true
            end
        end
    end
end

--local CACHE = setmetatable({},
    --{__index=function(t,k) t[k]={} return t[k] end})

function CHK_ACC (accs1, accs2, NO_par, NO_emts)

--print(print_r(accs1,"acc::CHK_ACC: accs1"))

--print("acc:CHK_ACC:",#accs1,#accs2,#NO_par, #NO_emts)
-- afb comment 'cls'
--    local cls = CLS()

    -- "acc": i/j are concurrent, and have incomp. acc
    -- accs need to be I-indexed
    for _, acc1 in ipairs(accs1) do
        local path1 = int2exts(acc1.path, NO_emts)
              path1 = par_rem(path1, NO_par)
        for _, acc2 in ipairs(accs2) do
            local path2 = int2exts(acc2.path, NO_emts)
                  path2 = par_rem(path2, NO_par)
--print("acc:CHK_ACC: acc1.id",acc1.err,acc2.err)
            if par_isConc(path1,path2) then

-- FLOW
--print("acc:CHK_ACC:ND.flw...",acc1.md,acc2.md,ND.flw[acc1.md][acc2.md])
                if ND.flw[acc1.md][acc2.md] then
                    if _AST.isChild(acc1.id, acc2.id)
                    or _AST.isChild(acc2.id, acc1.id)
                    then
                        WRN(false,nil,'abortion : '..
                                acc1.err..' vs '..acc2.err)
                        _ANA.ana.abrt = _ANA.ana.abrt + 1
--[[
DBG'==============='
DBG(acc1.cls.id, acc1, acc1.id, acc1.md, acc1.tp, acc1.any, acc1.err)
for k in pairs(path1) do
    DBG('path1', acc1.path, type(k)=='table' and k[1].id or k)
end
DBG(acc2.cls.id, acc2, acc2.id, acc2.md, acc2.tp, acc2.any, acc2.err)
for k in pairs(path2) do
    DBG('path2', acc2.path, type(k)=='table' and k[1].id or k)
end
DBG'==============='
]]
                        if acc1.md == 'par' then
                            acc1.id.parChk = true
                        end
                        if acc2.md == 'par' then
                            acc2.id.parChk = true
                        end
                    end
                end

-- ACC
--print("acc:CHK_ACC:ND.acc...",acc1.md,acc2.md,ND.acc[acc1.md][acc2.md])
                if ND.acc[acc1.md][acc2.md] then

-- afb comment 'cls'
                    -- this.x vs this.x (both accs bounded to cls)
--                    local cls_ = (acc1.cls == cls) or
--                                 (acc2.cls == cls)

-- afb comment 'org'
                    -- a.x vs this.x
--                    local _nil = {}
--                    local o1 = (acc1.org or acc2.org)
--                    o1 = o1 and o1.acc or _nil
--                    local o2 = (acc2.org or acc1.org)
--                    o2 = o2 and o2.acc or _nil

--                    -- orgs are compatible
--                    local org_ = (o1 == o2)
--                              or o1.any
--                              or o2.any
--
--                    -- orgs are compatible
--                    local org_ = o1.id == o2.id
--                              or o1.any
--                              or o2.any

                    -- ids are compatible
                    local id_ = acc1.id == acc2.id
                             or acc1.md=='cl' and acc2.md=='cl'
                             or acc1.any and _TP.contains(acc1.tp,acc2.tp)
                             or acc2.any and _TP.contains(acc2.tp,acc1.tp)

                    -- C's are det
                    local c1 = _ENV.c[acc1.id] or _ENV.exts[acc1.id]
                    c1 = c1 and (c1.mod=='pure' or c1.mod=='constant')
                    local c2 = _ENV.c[acc2.id]  or _ENV.exts[acc1.id]
                    c2 = c2 and (c2.mod=='pure' or c2.mod=='constant')
                    local c_ = c1 or c2
                            or (_ENV.exts[acc1.id] and not(_ENV.dets[acc1.id] and _ENV.dets[acc1.id][acc2.id]))

        --DBG(id_, c_,c1,c2, acc1.any,acc2.any)
-- afb                    if cls_ and org_ and id_ and (not c_)
--print("acc:CHK_ACC:id_, not c_",id_, not c_,acc1.md,acc2.md,acc1.trg,acc2.trg,not (acc1.trg == '_') , acc1.trg==acc2.trg)
                    if id_ and (not c_)
                    then
--print("acc:CHK_ACC:",acc1.md,acc2.md,acc1.trg,acc2.trg)
                        --if not(acc1.trg=='_') and acc1.trg==acc2.trg then
                            if acc1.md=='cl' and acc1.md==acc2.md  then
                              if not(acc1.trg=='_') and acc1.trg==acc2.trg then
                                WRN(not _OPTS.wstrong,nil,'nondeterminism (call conflict) : '..acc1.err..' vs '..acc2.err)
                              else
                                WRN(not _OPTS.wweak,nil,'nondeterminism (weak call conflict) : '..acc1.err..' vs '..acc2.err)
                              end
                            elseif not(acc1.md=='rd') and acc1.md==acc2.md  then
                              if not(acc1.trg=='_') and acc1.trg==acc2.trg then
                                WRN(not _OPTS.wstrong,nil,'nondeterminism (write conflict) : '..acc1.err..' vs '..acc2.err)
                              else
                                WRN(not _OPTS.wweak,nil,'nondeterminism (weak write conflict) : '..acc1.err..' vs '..acc2.err)
                              end
                            else
                              WRN(not _OPTS.wweak,nil,'nondeterminism (weak read conflict) : '..acc1.err..' vs '..acc2.err)
                            end
--                        else
--                            if not(acc1.md=='rd') and acc1.md==acc2.md then
--                              WRN(not _OPTS.wweak,nil,'nondeterminism (weak write conflict) : '..acc1.err..' vs '..acc2.err)
--                            else
--                              WRN(not _OPTS.wweak,nil,'nondeterminism (weak read conflict) : '..acc1.err..' vs '..acc2.err)
--                            end
--                        end
                        _ANA.ana.acc = _ANA.ana.acc + 1
                    end
                end
            end
        end
    end
end

function _chk (n, id)
    for k in pairs(n) do
        if type(k)=='table' and k[1]==id then
            return true
        end
    end
    return false
end

-- TODO: join with CHK_ACC
-- emits vs rets/ors/breaks (the problem is that emits are considered in par)
function CHK_EXCPT (s1, s2, isOR)
    for _, ana in ipairs(s1.ana.accs) do
        if ana.md == 'tr' then
            if _chk(s2.ana.pos,ana.id) and isOR or -- terminates w/ same event
               s2.ana.pos[false] --or       -- ~terminates (return/break)
               --s2.ana.pos[true]                 -- terminates tight
            then
                WRN(false,nil,'exception : line '..s2.ln..' vs '..ana.err)
                _ANA.ana.excpt = _ANA.ana.excpt + 1
                ana.node.emtChk = true
            end
        end
    end
end

G = {
-- take all emits from top-level PAR
    ParOr_pre = function (me)
        if ALL then
            return
        end
        ALL = {}
        for _, sub in ipairs(me) do
            for _,acc in ipairs(sub.ana.accs) do
                if acc.md == 'tr' then
                    ALL[acc] = true
                end
            end
        end
    end,
    ParAnd_pre  = 'ParOr_pre',
    ParEver_pre = 'ParOr_pre',

-- look for nondeterminism
    ParOr = function (me)
--print("acc::ParOr:#me",#me)

-- afb :: Leave out all vars 'rd' if it has a first var 'wr' in the same trail. Also define its trigger event.
        for z=1, #me do
          local first_md = {}
          local trail_trigger = string.sub(tostring(me[1].ana.accs),8)
          for k,acc in ipairs(me[z].ana.accs) do
          local tag = acc.tag or acc.id.tag or (acc.id.pre and 'var') 
--print("acc::ParOr: wr+rd",z,'[', acc.tag,acc.id.tag, acc.id.pre,']', tag,acc.id.id, acc.md,trail_trigger)
            if tag=='var' or tag=='event' then -- is a Var/VarEvent
--print(print_r(acc,"acc::ParOr: var/evet acc"))
              if acc.setEvt then
--print("acc::ParOr: SetExp?",z, k,acc.setEvt.tag, acc.setEvt[1][1], (acc.setEvt[2] and acc.setEvt[2][1].tag),(acc.setEvt[2] and acc.setEvt[2][1][1]))
                trail_trigger = acc.setEvt[1][1]
                trail_trigger = trail_trigger .. '$' .. (((acc.setEvt.tag=='AwaitExt' and (acc.setEvt[2] and acc.setEvt[2][1].tag=='CONST')) and acc.setEvt[2][1][1]) or '0')
              end
              if not first_md[acc.id.id] then first_md[acc.id.id] = acc.md end
              if acc.md == 'rd' and first_md[acc.id.id]=='wr' then acc.md='no' end
              acc.trg = trail_trigger
            else -- is not a var, then it is a new trail
--print("acc::ParOr: tag",tag)--,string.sub(tag or ' ',1,5) == 'Await')
              if string.sub(tag or ' ',1,5) == 'Await' then
                first_md = {}
                trail_trigger = ((acc.id.tag=='AwaitExt' or acc.id.tag=='AwaitInt') and ((acc.id[1] and acc.id[1][1]) or acc.id.id)) or string.sub(tostring(acc),8)
                trail_trigger = trail_trigger .. '$' .. (((acc.id.tag=='AwaitExt' and (acc.id[2] and acc.id[2][1].tag=='CONST')) and acc.id[2][1][1]) or '0')
                acc.trg = trail_trigger
              else
                acc.trg = trail_trigger -- ((acc.id[1] and acc.id[1][1]) or acc.id.id or acc.id) 
              end
--print("acc::ParOr: not var",z,acc.trg,'$'..(((acc.id.tag=='AwaitExt' and acc.id[2] and acc.id[2][1].tag=='CONST') and acc.id[2][1][1]) or '0'), acc.id.tag, acc.md, (acc.id[1] and acc.id[1][1]) or acc.id.id, acc.trg)
--print(print_r(acc.id,"acc::ParOr: acc.id"))
            end
          end
        end


        for i=1, #me do
            for j=i+1, #me do

                -- holds invalid emits
                local NO_emts = {}
                for _,acc in ipairs(me[i].ana.accs) do
                    if acc.md == 'tr' then
                        NO_emts[acc] = true -- same trail (happens bef or aft)
                    end
                end
--print("acc::ParOr:#me[i].ana.accs",#me[i].ana.accs,#NO_emts)

                for _,acc in ipairs(me[j].ana.accs) do
                    if acc.md == 'tr' then
                        NO_emts[acc] = true -- same trail (happens bef or aft)
                    end
                end
--print("acc::ParOr:#me[j].ana.accs",#me[j].ana.accs,#NO_emts)

                for acc in pairs(ALL) do
                    if _ANA.CMP(acc.path, me.ana.pre) then
                        NO_emts[acc] = true -- instantaneous emit
                    end
                end
--print("acc::ParOr:#ALL",#ALL,#NO_emts)

                CHK_ACC(me[i].ana.accs, me[j].ana.accs,
                        me.ana.pre,
                        --_ANA.union(me.ana.pre,me.ana.pos),
                        NO_emts)
                CHK_EXCPT(me[i], me[j], me.tag=='ParOr')
                CHK_EXCPT(me[j], me[i], me.tag=='ParOr')
            end
        end
    end,
    ParAnd  = 'ParOr',
    ParEver = 'ParOr',

-- TODO: workaround
    -- Loop can only be repeated after nested PARs evaluate CHK_*
    Loop = function (me)
        -- pre = pre U pos
        if not me[1].ana.pos[false] then
            _ANA.union(me[1], next(me.ana.pre), me[1].ana.pos)
        end
    end,
}

_AST.visit(G)

