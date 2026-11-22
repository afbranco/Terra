_WRN = {
    n_wrns = 0;       --afb Count warning messages
}
_TP = {}

local types = {
    void=true,
    ulong=true, long=true,
    ushort=true, short=true,
    ubyte=true,  byte=true,
    float=true,
}

function _TP.isBasicType(tp)
  return types[tp]
end
-- TODO: enforce passing parameter `c´ to isNumeric/deref/contains/max ?

function _TP.raw (tp)
    return (string.match(tp, '^([_%w]*)%**'))
end

function _TP.c (tp)
    return (string.gsub(tp, '^_', ''))
end

function _TP.len (tp)
    return (_ENV.c[tp] and _ENV.c[tp].len) or 0
end

function _TP.isNumeric (tp, c)
    return tp~='void' and types[tp] or (c and _TP.ext(tp))
end

function _TP.deref (tp, c)
--print("tp::deref:",tp)--,string.match(tp, '(.-)%*$'))
    return string.match(tp, '(.-)%*$') or (c and _TP.ext(tp))
end

function _TP.ext (tp)
    return (string.sub(tp,1,1) == '_') and
            (not string.match(tp, '(.-)%*$')) and tp
end


function _TP.getAuxTag(tp1,arr1)
    local aux={}
    aux.tp = tp1
    aux.ntp = tp1
    aux.arr = arr1
    aux.lvl=0
    aux.len=0
    aux.bType=nil
    aux.auxtag=nil
    while _TP.deref(aux.ntp) do aux.ntp = _TP.deref(aux.ntp); aux.lvl = aux.lvl+1 end
    aux.bType = _TP.isBasicType(aux.ntp)
--    aux.len = (aux.arr and aux.arr*_ENV.c[aux.ntp].len) or (_TP.isBasicType(aux.ntp) and ((aux.lvl==0 and _ENV.c[aux.ntp].len) or 2)) or _ENV.c[aux.ntp].len 
    aux.len = (aux.arr and aux.arr*_ENV.c[aux.ntp].len) or ((_ENV.packets[aux.ntp] and _ENV.packets[aux.ntp].len) or _ENV.c[aux.ntp].len) 

    aux.auxtag = 
          ((    aux.ntp == 'void'                       ) and 'void'    ) or
          ((not aux.bType and aux.lvl==1                ) and 'pointer' ) or
          ((not aux.bType and aux.lvl==0                ) and 'data'    ) or
          ((    aux.bType and aux.lvl==0                ) and 'var'     ) or
          ((    aux.bType and aux.lvl==1 and not aux.arr) and 'pointer' ) or
          ((    aux.bType and aux.lvl==1 and     aux.arr) and 'data'    ) or
          ((    aux.bType and aux.lvl==2 and not aux.arr) and 'pointer2') or
          ((    aux.bType and aux.lvl==2 and     aux.arr) and 'pointer2') or 'other'

--print("tp::getAuxTag:",aux.auxtag,aux.tp,aux.ntp,aux.lvl,aux.arr,aux.len)
return aux
end

function _TP.tpCompat(tp1,tp2,arr1,arr2)
    -- error == true -> incompatible types
    -- cast == true -> need cast
    local error = true 
    local cast = false
    local z1 = _TP.getAuxTag(tp1,arr1)
    local z2 = _TP.getAuxTag(tp2,arr2)
--print("tp::tpCompat:",tp1,tp2,arr1,arr2,z1.auxtag,z2.auxtag,z1.tp,z2.tp,z1.len,z2.len)

-- *************************
-- * Type Compatibility
-- *************************

--  type            -> auxtag;    tp;   size
-----------------------------------------------------
-- reg*             -> pointer;   ushort;   reg len
-- reg              -> data;      reg;      reg len
-- tpBasic          -> var;       tp;       tp len
-- tpBasic* + ~arr  -> pointer;   ushort;   arr*tp
-- tpBasic* +  arr  -> data;      arr*tp;   arr*tp
-- tpBasic** + ~arr -> pointer;   ushort;   arr*tp
-- tpBasic** +  arr -> pointer;   ushort;   arr*tp
-- void             -> void;      void;     0
-----------------------------------------------------

-- *** Valid operations ***
-- auxtag1  = auxtag2;  arr/data;   size limit;     cast
-------------------------------------------------------------
--R pointer  = pointer;  addr copy;  len1 <= len2;   len1 < len2
--R pointer  = data;     addr copy;  len1 <= len2;   len1 < len2
-- data     = data;     data copy;  min(len1,len2); len1 <> len2
-- var      = var;      data copy;  min(len1,len2); len1 < len2
-- ???      = void;     default 'invalid'
-------------------------------------------------------------

    if
        (z1.auxtag == 'var'      and z2.auxtag == 'var'    )                    
    then
        error = false
        cast = ((tp1~=tp2 and (tp1=='float' or tp2=='float'))) or
               ((tp1~='float' and tp2~='float') and (z1.len < z2.len))
    elseif
        (z1.auxtag == 'pointer'     and z2.auxtag == 'pointer'   ) and ((z1.len == z2.len and tp1~='float' and tp2~='float') or (tp1=='float' and tp2=='float'))                   
    then
        error = false
        cast = false
    elseif
        (z1.auxtag == 'data'     and z2.auxtag == 'data'   ) and (z1.tp == z2.tp)                   
    then
        error = false
        cast = false
    else
        error = true
        cast = false
    end
    return error, cast, z1.ntp, z2.ntp, z1.len, z2.len
end

function _TP.contains (tp1, tp2, c)
    local _tp1, _tp2 = _TP.deref(tp1), _TP.deref(tp2)
--print("tp::contains:",tp1, tp2,_tp1, _tp2, _TP.len(tp1), _TP.len(tp2),_TP.ext(tp1) , _TP.ext(tp2))
    if (not(_tp1) and tp1 == tp2) then
        return true
--    elseif _TP.isNumeric(tp1) and _TP.isNumeric(tp2) then
--        return true
    elseif (not(_tp1) and _TP.len(tp1) >= _TP.len(tp2)) then   -- afb
        return true                                         -- afb
--    elseif c and (_TP.ext(tp1) or _TP.ext(tp2)) then
--        return true
    elseif _tp1 and _tp2 then
        return tp1=='void*' or tp2=='void*' or _TP.contains(_tp1, _tp2, c)
    end
--print("tp::contains2:")
    return false
end

function _TP.max (tp1, tp2, c)
    if (tp1=='float' or tp2=='float') then return 'float'; end
    if _TP.contains(tp1, tp2, c) then
        return tp1
    elseif _TP.contains(tp2, tp1, c) then
        return tp2
    else
        return nil
    end
end

function _TP.getCastType(tp)
  return ((tp=='ubyte' or tp=='ushort' or tp=='ulong') and 'ulong') or ((tp=='byte' or tp=='short' or tp=='long') and 'long') or 'float'  
end

function _TP.getConstType(val,me,no_wrn)
  if ((string.find(val,'e') or string.find(val,'E') or string.find(val,'%.')) and tonumber(val)) and not(string.find(val,'x') or string.find(val,'X'))then
    local nval = tonumber(val)
    if (nval < -3.4E+38) or (nval > 3.4E+38)  then
      WRN(no_wrn,me,'Float constant out of range, got: "'.. val ..'", value must range (+/-) 3.4E+38')
    end    
    return 'float'
  else
    local nval = tonumber(val) or string.byte(val,2)
--print("tp::getConstTypeI:",val,nval)
  	if (nval <= 0xff) then return 'ubyte' end
    if (nval <= 0xffff) then return 'ushort' end
    if (nval <= 0xffffffff) then return 'ulong' end
    WRN(no_wrn,me,'Integer constant too large, got: "'.. val ..'", max value must be (2^32)-1')
  	return 'ulong'
  end
end

function _TP.getConstLen(val)
--print("tp::getConstLen:",val)
  local nval = tonumber(val) or string.byte(val,2)
  if (nval <= 0xff) then return 0 end
  if (nval <= 0xffff) then return 1 end
  if (nval <= 0xffffff) then return 2 end
  return 3
end

function _TP.getConstBytes(val,len)
  len = len or 0;
  nx=1
  local nval = tonumber(val) or string.byte(val,2)
  local bytes = string.format('%02x ',nval % 256)
  while (math.floor(nval/256) > 0 or len>1)  and nx < 4 do
    nx = nx+1;
    len = len - 1;
    nval = math.floor(nval/256)
    -- big-endian byte order
    bytes = string.format('%02x %s ',nval % 256,bytes)
  end
  return trim(bytes)
end

function _TP.getConstLenLbl(val)
--print("tp::getConstLenLbl:",val)
  local nval = tonumber(val) or string.byte(val,2)
  if (nval <= 0xff) then return 1 end
  if (nval <= 0xffff) then return 1 end
  if (nval <= 0xffffff) then return 2 end
  return 3
end
function _TP.getConstBytesLbl(val,len)
  len = 2;
  nx=1
  local nval = tonumber(val) or string.byte(val,2)
  local bytes = string.format('.%02x ',nval % 256)
  while (math.floor(nval/256) > 0 or len>1)  and nx < 4 do
    nx = nx+1;
    len = len - 1;
    nval = math.floor(nval/256)
    -- big-endian byte order
    bytes = string.format('.%02x %s ',nval % 256,bytes)
  end
  return trim(bytes)
end

--------------------------------------
-- Convert float to hex / hex to float
-- Tanks to François Perrad
-- lua-MessagePack : <http://fperrad.github.io/lua-MessagePack/>

function _TP.float2hex (n)
    if n == 0.0 then return 0.0 end

    local sign = 0
    if n < 0.0 then
        sign = 0x80
        n = -n
    end

    local mant, expo = math.frexp(n)
    local hext = {}

    if mant ~= mant then
        hext[#hext+1] = string.char(0xFF, 0x88, 0x00, 0x00)

    elseif mant == math.huge or expo > 0x80 then
        if sign == 0 then
            hext[#hext+1] = string.char(0x7F, 0x80, 0x00, 0x00)
        else
            hext[#hext+1] = string.char(0xFF, 0x80, 0x00, 0x00)
        end

    elseif (mant == 0.0 and expo == 0) or expo < -0x7E then
        hext[#hext+1] = string.char(sign, 0x00, 0x00, 0x00)

    else
        expo = expo + 0x7E
        mant = (mant * 2.0 - 1.0) * math.ldexp(0.5, 24)
        hext[#hext+1] = string.char(sign + math.floor(expo / 0x2),
                                    (expo % 0x2) * 0x80 + math.floor(mant / 0x10000),
                                    math.floor(mant / 0x100) % 0x100,
                                    mant % 0x100)
    end

    return tonumber(string.gsub(table.concat(hext),"(.)",
                                function (c) return string.format("%02X%s",string.byte(c),"") end), 16)
end


function _TP.hex2float (c)
    if c == 0 then return 0.0 end
    local c = string.gsub(string.format("%X", c),"(..)",function (x) return string.char(tonumber(x, 16)) end)
    local b1,b2,b3,b4 = string.byte(c, 1, 4)
    local sign = b1 > 0x7F
    local expo = (b1 % 0x80) * 0x2 + math.floor(b2 / 0x80)
    local mant = ((b2 % 0x80) * 0x100 + b3) * 0x100 + b4

    if sign then
        sign = -1
    else
        sign = 1
    end

    local n

    if mant == 0 and expo == 0 then
        n = sign * 0.0
    elseif expo == 0xFF then
        if mant == 0 then
            n = sign * math.huge
        else
            n = 0.0/0.0
        end
    else
        n = sign * math.ldexp(1.0 + mant / 0x800000, expo - 0x7F)
    end

    return n
end
--- =========================================


--------------------------------------
-- Copyright 2009: hans@hpelbers.org
-- This is freeware
 
function print_r (t, name, indent)
  local tableList = {}
  function table_r (t, name, indent, full)
    local id = not full and name
        or type(name)~="number" and tostring(name) or '['..name..']'
    local tag = indent .. id .. ' = '
    local out = {}    -- result
    if type(t) == "table" then
      if tableList[t] ~= nil then table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
      else
        tableList[t]= full and (full .. '.' .. id) or id
        if next(t) then -- Table not empty
          table.insert(out, tag .. '{')
          for key,value in pairs(t) do
            table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
          end
          table.insert(out,indent .. '}')
        else table.insert(out,tag .. '{}') end
      end
    else
      local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
      table.insert(out, tag .. val)
    end
    return table.concat(out, '\n')
  end
  return table_r(t,name or 'Value',indent or '')
end
--- =========================================