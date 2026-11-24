function OR_all (me, t)
    t = t or me
    me.awaits  = false
    me.returns = false
    me.blocks  = false
    me.s_awaits, me.s_returns, me.s_blocks = false, false, false
    for _, sub in ipairs(t) do
        if _AST.isNode(sub) then
            me.awaits  = me.awaits  or sub.awaits
            me.returns = me.returns or sub.returns
            me.blocks  = me.blocks or sub.blocks
            me.s_awaits  = me.s_awaits  or sub.s_awaits
            me.s_returns = me.s_returns or sub.s_returns
            me.s_blocks  = me.s_blocks  or sub.s_blocks
        end
    end
end

function AND_all (me, t)
    t = t or me
    me.awaits  = true
    me.returns = true
    me.blocks  = true
    me.s_awaits, me.s_returns, me.s_blocks = true, true, true
    for _, sub in ipairs(t) do
        if _AST.isNode(sub) then
            me.awaits  = me.awaits  and sub.awaits
            me.returns = me.returns and sub.returns
            me.blocks  = me.blocks and sub.blocks
            me.s_awaits  = me.s_awaits  and sub.s_awaits
            me.s_returns = me.s_returns and sub.s_returns
            me.s_blocks  = me.s_blocks  and sub.s_blocks
        end
    end
end

function SAME (me, sub)
    sub = sub or me[1]
    me.awaits  = sub.awaits
    me.returns = sub.returns
    me.blocks  = sub.blocks
    me.s_awaits, me.s_returns, me.s_blocks = sub.s_awaits, sub.s_returns, sub.s_blocks
end

-- Marca as duas contas (a normal e a "com certeza") de um nó que espera, retorna ou sai.
local function MARCA (me, awaits, returns)
    if awaits  then me.awaits,  me.s_awaits  = true, true end
    if returns then me.returns, me.s_returns = true, true end
    me.blocks, me.s_blocks = true, true
end

F = {
    Node_pre = function (me)
        me.awaits  = false
        me.returns = false
        me.blocks  = false
        me.s_awaits, me.s_returns, me.s_blocks = false, false, false
    end,
    Node = function (me)
        if not F[me.tag] then
            OR_all(me)
        end
    end,

    Block   = OR_all,
    BlockN  = OR_all,

    ParEver = OR_all,
    ParAnd  = OR_all,

    Finally = SAME,

    If = function (me)
        local c, t, f = unpack(me)
        t = t or c
        f = f or c
        if me.isBounded then
            SAME(me, f)
        else
            AND_all(me, {t,f})
        end
    end,

    ParOr = AND_all,

    Break = function (me)
        MARCA(me)
    end,
    Loop = function (me)
        local body = unpack(me)
        SAME(me, body)
--print("tight::Loop:",_AST.iter'Async'(),me.isBounded,body.blocks)
        ASR(_AST.iter'Async'() or me.isBounded or body.blocks,
        --afb ASR(_AST.iter'Async'() or body.blocks,
                me,'E5001')
        -- O laço só espera com certeza por meio de um `loop i, N´ interno se N for constante:
        -- com N variável e igual a 0 ele não executa e este laço fica sem await (#48).
        if not (_AST.iter'Async'() or me.isBounded) and not body.s_blocks then
            WRN(false, me, 'W3006')
        end
        me.blocks = body.awaits or body.returns
        me.s_blocks = body.s_awaits or body.s_returns
        if me.isBounded then
            if me.boundConst and me.boundConst <= 0 then
                -- nunca executa: não conta como espera
                me.awaits, me.returns, me.blocks = false, false, false
                me.s_awaits, me.s_returns, me.s_blocks = false, false, false
            elseif not me.boundConst then
                me.s_awaits, me.s_returns, me.s_blocks = false, false, false
            end
        end
    end,

    SetBlock = function (me)
        local _,blk = unpack(me)
        SAME(me, blk)
        me.returns, me.s_returns = false, false
    end,
    Return = function (me)
        MARCA(me, false, true)
    end,

    Async = function (me)
        local _,body = unpack(me)
        SAME(me, body)
        MARCA(me, true)
    end,

    AwaitExt = function (me) MARCA(me, true) end,
    AwaitInt = function (me) MARCA(me, true) end,
    AwaitT   = function (me) MARCA(me, true) end,
    AwaitN   = function (me) MARCA(me, true) end,
}

_AST.visit(F)
