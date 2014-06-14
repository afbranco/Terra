_PARSER = {
}

local P, C, V, Cc, Ct = m.P, m.C, m.V, m.Cc, m.Ct

local S = V'_SPACES'

local ERR_msg
local ERR_i
local LST_i

local I2TK

local f = function (s, i, tk)
    if tk == '' then
        tk = '<BOF>'
        LST_i = 1           -- restart parsing
        ERR_i = 0           -- ERR_i < 1st i
        ERR_msg = '?'
        I2TK = { [1]='<BOF>' }
    elseif i > LST_i then
        LST_i = i
        I2TK[i] = tk
    end
    return true
end
local K = function (patt, key)
    key = key and -m.R('09','__','az','AZ','\127\255')
            or P(true)
    ERR_msg = '?'
    return #P(1) * m.Cmt(patt*key, f) * S
end
local CK = function (patt, key)
    key = key and -m.R('09','__','az','AZ','\127\255')
            or P(true)
    ERR_msg = '?'
    return C(m.Cmt(patt*key, f))*S
end
local EK = function (tk, key)
    key = key and -m.R('09','__','az','AZ','\127\255')
            or P(true)
    return K(P(tk)*key) + m.Cmt(P'',
        function (_,i)
            if i > ERR_i then
                ERR_i = i
                ERR_msg = 'expected `'..tk.."´"
            end
            return false
        end) * P(false)
end

local KEY = function (str)
    return K(str,true)
end
local EKEY = function (str)
    return EK(str,true)
end
local CKEY = function (str)
    return CK(str,true)
end

local _V2NAME = {
    Exp = 'expression',
    _Exp = 'expression',
    _Stmt = 'statement',
    Ext = 'event',
    Var = 'variable/event',
    ID_c  = 'identifier',
    ID_var  = 'a not reserved identifier beginning with lowercase',
    ID_int  = 'identifier',
    ID_ext  = 'identifier all uppercase',
    ID_type = 'type',
    _Dcl_var = 'declaration',
    _Dcl_int = 'declaration',
    __ID = 'identifier',

    ID_version  = 'version identifier <num.num.num> ',
    CfgBlk = 'Config block declaration',
    ID_field_type = 'a valid basic type',
    _Dcl_struct = 'declaration',
--    ID_evt  = 'identifier',
    Op_var = 'variable'

}
local EV = function (rule)
    return V(rule) + m.Cmt(P'',
        function (_,i)
            if i > ERR_i then
                ERR_i = i
                ERR_msg = 'expected ' .. _V2NAME[rule]
            end
            return false
        end)
end

local EM = function (msg)
    return m.Cmt(P'',
        function (_,i)
            if i > ERR_i then
                ERR_i = i
                ERR_msg = 'expected ' .. msg
                return false
            end
        end)
end

TYPES = P'void'
      + 'ubyte' + 'ushort' + 'ulong'
      + 'byte' + 'short' + 'long'

KEYS = P'and'     
     + 'async'    
     + 'await'    + 'break'    + 'C'
     + 'constant' + 'deterministic'         + 'do'       + 'else'
     + 'else/if'  + 'emit'     + 'end'      + 'event'    --+ 'external'
     + 'finally'  + 'FOREVER'  + 'if'       + 'input'    + 'loop'
     + 'nohold'   + 'not'      + 'null'     + 'or'       + 'output'
     + 'par'      + 'par/and'  + 'par/or'   + 'pause/if' + 'pure'
     + 'return'   + 'sizeof'   + 'then'     + 'var'      + 'with'
     + 'function' + 'config'   + 'regtype'  + 'inc'      + 'dec'
     + TYPES

KEYS = KEYS * -m.R('09','__','az','AZ','\127\255')

local Alpha    = m.R'az' + '_' + m.R'AZ'
local Alphanum = Alpha + m.R'09'
local ALPHANUM = m.R'AZ' + '_' + m.R'09'
local alphanum = m.R'az' + '_' + m.R'09'

NUM = CK(m.R'09'^1) / tonumber
PNUM = -K'-'*CK(m.R'09'^1) / tonumber + EM'a positive integer number'

_GG = { 
      [1] = CK'' * V'Prog' * P(-1)-- + EM'expected EOF')

      , Prog = CK'' * EV'CfgBlk' * EV'Block' * P(-1) + EM'config block + program'

------
    , CfgBlk = (KEY'config') * V'ID_version' * EKEY'do' * V'CfgStmts' * EKEY'end'
    , CfgStmts = (V'_CfgStmt' * (EK';'*K';'^0) +
                  V'_CfgStmtB' * (K';'^-1*K';'^0))^0 + EM'AAA'

    , _CfgStmt = V'_Dcl_ext' + V'_Dcl_func'
            + EM'config statement (usually a missing `input/output/function/regtype´)'
    , _CfgStmtB = V'_Dcl_regt'
            + EM'config statement (usually a missing `regtype varName with varDefs end´)'
    ,_Dcl_func = (CKEY'function' * CKEY(TYPES) * V'ID_c' * K'(' * V'Arg_list' * K')') * PNUM
    
    , Arg_list = ( V'ID_type' * (EK',' * EV'ID_type')^0  )^-1
------
    , _Block = ( V'_Stmt' * (EK';'*K';'^0) +
                 V'_StmtB' * (K';'^-1*K';'^0)
               )^0
             * ( V'_LstStmt' * (EK';'*K';'^0) +
                 V'_LstStmtB' * (K';'^-1*K';'^0)
               )^-1
    , Block  = V'_Block'
    , BlockN = V'_Block'

    , _Stmt = V'AwaitT'   + V'AwaitExt'  + V'AwaitInt'
            + V'EmitT'    + V'EmitExtS'  + V'EmitInt'
            + V'_Dcl_int' + V'_Dcl_var'
            + V'Dcl_det'  
            + V'_Set'     + V'CallStmt' -- must be after Set
            + EM'statement ' + V'Op_var'

    , _StmtB = V'_Do'   
             + V'Async'  
             + V'Host'
             + V'ParOr' + V'ParAnd' + V'ParEver'
             + V'If'    + V'Loop'
             + V'Pause' + V'_Dcl_regt'

    , _LstStmt  = V'_Return' + V'Break' + V'AwaitN'
    , _LstStmtB = V'ParEver'

    , _SetBlock = ( V'_Do'     
                    + V'Async' 
                    + V'ParEver' + V'If'    + V'Loop' )

    , __ID      = V'ID_c' + V'ID_ext' + V'Var'
    , Dcl_det   = KEY'deterministic' * EV'__ID' * EKEY'with' *
                     EV'__ID' * (K',' * EV'__ID')^0

    , _Set  = V'Exp' * V'_Sets'
    , _Sets = (CK'=' + CK':=') * (
                Cc'SetAwait' * (V'AwaitT'+V'AwaitExt'+V'AwaitInt') +
                Cc'SetBlock' * V'_SetBlock' +
                Cc'SetExp'   * V'Exp' +
                EM'expression'
              )

    , Op_var = ((CKEY'inc' + CKEY'dec') * EV'Var') 

    , CallStmt = m.Cmt(V'Exp',
                    function (s,i,...)
                        return (string.sub(s,i-1,i-1)==')'), ...
                    end)

    , _Do     = KEY'do' * V'BlockN' *
                    (KEY'finally'*V'BlockN' + Cc(false)) *
                EKEY'end'

    , Async   = K'async' * V'VarList' * V'_Do'
    , VarList = ( EK'(' * EV'Var' * (EK',' * EV'Var')^0 * EK')' )^-1

    , _Return = K'return' * EV'Exp'

    , ParOr   = KEY'par/or' * EKEY'do' *
                    V'Block' * (EKEY'with' * V'Block')^1 *
                EKEY'end'
    , ParAnd  = KEY'par/and' * EKEY'do' *
                    V'Block' * (EKEY'with' * V'Block')^1 *
                EKEY'end'
    , ParEver = KEY'par' * EKEY'do' *
                    V'Block' * (EKEY'with' * V'Block')^1 *
                EKEY'end'

    , If      = KEY'if' * EV'Exp' * EKEY'then' *
                    V'Block' *
                (KEY'else/if' * EV'Exp' * EKEY'then' *
                    V'Block')^0 *
                (KEY'else' *
                    V'Block' + Cc(false)) *
                EKEY'end'

    , Loop    = KEY'loop' *
                    (V'ID_var'* (EK','*EV'Exp' + Cc(false)) +
                        Cc(false)*Cc(false)) *
                V'_Do'
    , Break   = K'break'

    , Exp     = V'_Exp'
    , _Exp    = V'_1'
    , _1      = V'_2'  * (CK'or'  * V'_2')^0
    , _2      = V'_3'  * (CK'and' * V'_3')^0
    , _3      = V'_4'  * ((CK'|'-'||') * V'_4')^0
    , _4      = V'_5'  * (CK'^' * V'_5')^0
    , _5      = V'_6'  * (CK'&' * V'_6')^0
    , _6      = V'_7'  * ((CK'!='+CK'==') * V'_7')^0
    , _7      = V'_8'  * ((CK'<='+CK'>='+(CK'<'-'<<')+(CK'>'-'>>')) * V'_8')^0
    , _8      = V'_9'  * ((CK'>>'+CK'<<') * V'_9')^0
    , _9      = V'_10' * ((CK'+'+(CK'-'-'->')) * V'_10')^0
    , _10     = V'_11' * ((CK'*'+(CK'/'-'//'-'/*')+CK'%') * V'_11')^0
    , _11     = ( Cc(true) * ( CK'not' + CK'&' + CK'-' + CK'~' + CK'*' -- + CK'+' 
                             + (K'<'*EV'ID_type'*K'>') )
                )^0 * V'_12'
    , _12     = V'_13' *
                    (
--                        K'(' * Cc'call' * V'ExpList' * EK')' +
                        K'[' * Cc'idx'  * V'_Exp'    * EK']' 
--                       + (CK':' + CK'.')
--                            * (CK(Alpha * (Alphanum+'?')^0) /
--                                function (id)
--                                    return (string.gsub(id,'%?','_'))
--                                end)
                    )^0
    , _13     = V'_Prim'
    , _Prim   = V'_Parens' + V'Func' + V'Field'
              + V'Var'   + V'C'   + V'SIZEOF'
              + V'NULL'    + V'CONST' --+ V'STRING'
              + V'EmitExtE'

    , ExpList = ( V'_Exp'*(K','*EV'_Exp')^0 )^-1

    , _Parens  = K'(' * EV'_Exp' * EK')'

    , SIZEOF = KEY'sizeof' * EK'<' * EV'ID_type' * EK'>'
    , CONST = CK( #m.R'09' * (m.R'09'+m.S'xX'+m.R'AF'+m.R'af')^1 )
            + CK( "'" * (P(1)-"'")^0 * "'" )

    , NULL = CK'null'

    , WCLOCKK = #NUM *
                (NUM * K'h'   + Cc(0)) *
                (NUM * K'min' + Cc(0)) *
                (NUM * K's'   + Cc(0)) *
                (NUM * K'ms'  + Cc(0)) *
--                (NUM * K'us'  + Cc(0)) *
--                (NUM * EM'<h,min,s,ms,us>')^-1
                (NUM * EM'<h,min,s,ms,us>')^-1
    , WCLOCKE = K'(' * V'Exp' * EK')' * C(
                    K'h' + K'min' + K's' + K'ms' --+ K'us'
--                  + EM'<h,min,s,ms,us>'
                  + EM'<h,min,s,ms>'
              )

    , Pause    = KEY'pause/if' * EV'Var' * V'_Do'

    , AwaitExt = KEY'await' * EV'Ext'
    , AwaitInt = KEY'await' * EV'Var'
    , AwaitN   = KEY'await' * KEY'FOREVER'
    , AwaitT   = KEY'await' * (V'WCLOCKK'+V'WCLOCKE')

    , _EmitExt = KEY'emit' * EV'Ext' * (K'(' * V'Exp'^-1 * EK')')^-1
    , EmitExtS = V'_EmitExt'
    , EmitExtE = V'_EmitExt'

    , EmitT    = KEY'emit' * (V'WCLOCKK'+V'WCLOCKE')

    , EmitInt  = KEY'emit' * EV'Var' * (K'(' * V'Exp'^-1 * EK')')^-1

    , _Dcl_ext = (CKEY'input'+CKEY'output') * EV'ID_type' * EV'ID_ext' * PNUM

    , _Dcl_int  = CKEY'event' * CKEY(TYPES) * Cc(false) *
                    V'__Dcl_int' * (K','*V'__Dcl_int')^0
--    , _Dcl_int  = CKEY'event' * EV'ID_type' * Cc(false) *
--                    V'__Dcl_int' * (K','*V'__Dcl_int')^0
    , __Dcl_int = EV'ID_int' * (V'_Sets' + Cc(false)*Cc(false)*Cc(false))

    , _Dcl_var  = CKEY'var' * EV'ID_type' * (K'['*NUM*K']'+Cc(false)) *
                    V'__Dcl_var' * (K','*V'__Dcl_var')^0
    , __Dcl_var = EV'ID_var' * (V'_Sets' + Cc(false)*Cc(false)*Cc(false))

    , _Dcl_field  = CKEY'var' * EV'ID_field_type' * (K'['*PNUM*K']'+Cc(false)) *
                    V'ID_var' * (K','*V'ID_var')^0
                        
    , _Dcl_regt = KEY'regtype' * EV'ID_var' * EKEY'with' * (V'_Dcl_field' * (EK';'*K';'^0))^0 * EKEY'end'
    
--    , Func     = V'ID_var' * K'(' * Cc'call' * V'ExpList' * EK')'
    , Func     = V'ID_var' * K'(' * V'ExpList' * EK')'
    , Ext      = V'ID_ext'
    , Field    = V'ID_field'
    , Var      = V'ID_var'
    , C        = V'ID_c'

--    , ID_version  = PNUM*K'.'*PNUM*K'.'*PNUM + EM'config NUM.NUM.NUM do ... end'
    , ID_version  = PNUM + EM'config NUM.NUM.NUM do ... end'

    , ID_ext  = -KEYS * CK(m.R'AZ'*ALPHANUM^0)
 
    , ID_field = (-KEYS * CK(m.R'az'*(Alphanum+'?')^0)) * K'.' * (-KEYS * CK(m.R'az'*(Alphanum+'?')^0))
--                    / function(id) return (string.gsub(id,'%?','_')) end
 
    , ID_var  = -KEYS * CK(m.R'az'*(Alphanum+'?')^0)
                    / function(id) return (string.gsub(id,'%?','_')) end
    , ID_int  = V'ID_var'
    , ID_c    = V'ID_var' --CK(  P'_' *Alphanum^0)
    , ID_type = (CKEY(TYPES)+V'ID_c') * C(K'*'^0) /
                  function (id, star)
                    return (string.gsub(id..star,' ',''))
                  end
    , ID_field_type = CKEY(TYPES)
    
--    , STRING = CK( CK'"' * (P(1)-'"'-'\n')^0 * EK'"' )

    , Host    = K'C' * (#EK'do')*'do' * m.S' \n\t'^0 *
                    ( C(V'_C') + C((P(1)-'end')^0) )
                *S* EK'end'

    --, _C = '/******/' * (P(1)-'/******/')^0 * '/******/'
    , _C      = m.Cg(V'_CSEP','mark') *
                    (P(1)-V'_CEND')^0 *
                V'_CEND'
    , _CSEP = '/***' * (1-P'***/')^0 * '***/'
    , _CEND = m.Cmt(C(V'_CSEP') * m.Cb'mark',
                    function (s,i,a,b) return a == b end)

    , _SPACES = (  m.S'\t\n\r @'
                + ('//' * (P(1)-'\n')^0 * P'\n'^-1)
                + V'_COMM'
                )^0

    , _COMM    = '/' * m.Cg(P'*'^1,'comm') * (P(1)-V'_COMMCMP')^0 * V'_COMMCL'
                    / function () end
    , _COMMCL  = C(P'*'^1) * '/'
    , _COMMCMP = m.Cmt(V'_COMMCL' * m.Cb'comm',
                    function (s,i,a,b) return a == b end)
}

function err ()
    local x = (ERR_i<LST_i) and 'before' or 'after'
--DBG(LST_i, ERR_i, ERR_msg, _I2L[LST_i], I2TK[LST_i])
    return 'ERR : line '.._I2L[LST_i]..
              ' : '..x..' `'..(I2TK[LST_i] or '?').."´"..
              ' : '..ERR_msg
end

if _CEU then
    if not m.P(_GG):match(_STR) then
        DBG(err())
        os.exit(1)
    end
else
    assert(m.P(_GG):match(_STR), err())
end
