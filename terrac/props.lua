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

function MAX_all (me, t)
    t = t or me
    me.n_tracks = 1
    for _, sub in ipairs(t) do
        if _AST.isNode(sub) then
            me.n_tracks = MAX(me.n_tracks, sub.n_tracks)
        end
    end
end

function ADD_all (me, t)
    t = t or me
    me.n_tracks = 0
    for _, sub in ipairs(t) do
        if _AST.isNode(sub) then
            me.n_tracks = me.n_tracks + sub.n_tracks
        end
    end
end

_PROPS = {
    has_exts    = false,
    has_wclocks = false,
    has_asyncs  = false,
    has_emits   = false,
}

local NO_fin = {
    Loop=true, Finally=true, Break=true,
    Host=true, Return=true, Async=true,
    ParEver=true, ParOr=true, ParAnd=true,
    AwaitExt=true, AwaitInt=true, AwaitN=true, AwaitT=true,
    EmitInt=true,
}

local NO_async = {
    ParEver=true, ParOr=true, ParAnd=true,
    EmitInt=true,
    Async=true,
    Finally=true,
    AwaitExt=true, AwaitInt=true, AwaitN=true, AwaitT=true,
}

F = {
    Node_pre = function (me)
        me.n_tracks = 1
    end,
    Node = function (me)
        if not F[me.tag] then
            MAX_all(me)
        end
        if NO_fin[me.tag] then
            ASR(not _AST.iter'Finally'(), me, 'not permitted inside `finally´')
        end
        if NO_async[me.tag] then
            ASR(not _AST.iter'Async'(), me,'not permitted inside `async´')
        end
    end,

    Root    = ADD_all,
    Block   = MAX_all,
    BlockN  = MAX_all,
    ParEver = ADD_all,
    ParAnd  = ADD_all,
    ParOr   = ADD_all,

    Dcl_ext = function (me)
        _PROPS.has_exts = true
    end,

    Async = function (me)
        _PROPS.has_asyncs = true
    end,

    If = function (me)
        local c, t, f = unpack(me)
        f = f or c
        MAX_all(me, {t,f})
    end,

    ParOr_pre = function (me)
        me.nd_join = true
    end,

    Loop_pre = function (me)
        F.ParOr_pre(me)
        me.brks = {}
    end,
    Break = function (me)
        local loop = _AST.iter'Loop'()
        ASR(loop, me, 'break without loop')
        loop.brks[me] = true

        local fin = _AST.iter'Finally'()
        ASR(not fin or fin.depth<loop.depth, me, 'not permitted inside `finally´')

        local async = _AST.iter'Async'()
        if async then
            local loop = _AST.iter'Loop'()
            ASR(loop.depth>async.depth, me, '`break´ without loop')
        end
    end,

    SetBlock_pre = function (me)
        F.ParOr_pre(me)
        me.rets = {}
    end,
    Return = function (me)
        local blk = _AST.iter'SetBlock'()
        blk.rets[me] = true

        local async = _AST.iter'Async'()    
        if async then
            local setblk = _AST.iter'SetBlock'()
            ASR(async.depth<=setblk.depth+1, me, '`return´ without block')
        end
    end,

    AwaitT = function (me)
        _PROPS.has_wclocks = true
    end,

    EmitInt = function (me)
        me.n_tracks = 2     -- cont / match
        _PROPS.has_emits = true
    end,

    EmitExtS = function (me)
        if _AST.iter'Async'() then
            ASR(me[1].ext.pre=='input',  me, 'not permitted inside `async´')
        else
            ASR(me[1].ext.pre=='output', me, 'not permitted outside `async´')
        end
    end,
    EmitExtE = function (me)
        F.EmitExtS(me)
    end,
    EmitT = function (me)
        ASR(_AST.iter'Async'(), me,'not permitted outside `async´')
    end,

    SetExp = function (me)
        local e1, e2 = unpack(me)
        local async = _AST.iter'Async'()
        if async and (not e1) then
            ASR( async.depth <= _AST.iter'SetBlock'().depth+1,
                    me, 'invalid access from async')
        end
    end,

    Var = function (me)
        local async = _AST.iter'Async'()
        if async then
--print("props:Var",me[1])
            --ASR(not(string.sub(me[1],1,1) == '$' and me[1]~='$ret'),me,'`finally´ is not implemented inside async')
            ASR(_AST.iter'VarList'() or         -- param list
                me.ret or                       -- var assigned on return
                async.depth < me.var.blk.depth, -- var is declared inside
                    me, 'invalid access from async')
        end
    end,
}

_AST.visit(F)
