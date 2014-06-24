_TP = {}

local types = {
    void=true,
    ulong=true, long=true,
    ushort=true, short=true,
    ubyte=true,  byte=true,
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


function _TP.tpCompat(tp1,tp2,arr1,arr2)
    -- error == true -> incompatible types
    -- cast == true -> need cast
print("tp::tpCompat:",tp1,tp2)
    local error = true 
    local cast = false
    local ntp1 = tp1
    local ntp2 = tp2
    local lvl1=0
    local lvl2=0
    local len1,len2
    local bType1,bType2
    local auxtag1,auxtag2
    while _TP.deref(ntp1) do ntp1 = _TP.deref(ntp1); lvl1 = lvl1+1 end
    while _TP.deref(ntp2) do ntp2 = _TP.deref(ntp2); lvl2 = lvl2+1 end
    bType1 = _TP.isBasicType(ntp1)
    bType2 = _TP.isBasicType(ntp2)

    len1 = (arr1 and arr1*_ENV.c[ntp1].len) or (_TP.isBasicType(ntp1) and ((lvl1==0 and _ENV.c[ntp1].len) or 2)) or _ENV.c[ntp1].len 

    len2 = (arr2 and arr2*_ENV.c[ntp2].len) or (_TP.isBasicType(ntp2) and ((lvl2==0 and _ENV.c[ntp2].len) or 2)) or _ENV.c[ntp2].len 


auxtag1 = ((not bType1 and lvl1==1             ) and 'pointer') or
          ((not bType1 and lvl1==0             ) and 'data') or
          ((    bType1 and lvl1==0             ) and 'var') or
          ((    bType1 and lvl1==1 and not arr1) and 'pointer') or
          ((    bType1 and lvl1==1 and     arr1) and 'data') or
          ((    bType1 and lvl1==2 and not arr1) and 'pointer2') or
          ((    bType1 and lvl1==2 and     arr1) and 'pointer2') or 'other'

auxtag2 = ((not bType2 and lvl2==1             ) and 'pointer') or
          ((not bType2 and lvl2==0             ) and 'data') or
          ((    bType2 and lvl2==0             ) and 'var') or
          ((    bType2 and lvl2==1 and not arr2) and 'pointer') or
          ((    bType2 and lvl2==1 and     arr2) and 'data') or
          ((    bType2 and lvl2==2 and not arr2) and 'pointer2') or
          ((    bType2 and lvl2==2 and     arr2) and 'pointer2') or 'other'

print("tp::tpCompat:1",auxtag1,tp1,ntp1,lvl1,arr1,len1)
print("tp::tpCompat:2",auxtag2,tp2,ntp2,lvl2,arr2,len2)

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
-----------------------------------------------------

-- *** Valid operations ***
-- auxtag1  = auxtag2;  arr/data;   size limit;     cast
-------------------------------------------------------------
-- pointer  = pointer;  addr copy;  len1 <= len2;   len1 < len2
-- pointer  = data;     addr copy;  len1 <= len2;   len1 < len2
-- data     = data;     data copy;  min(len1,len2); len1 < len2
-- var      = var;      data copy;  min(len1,len2); len1 < len2
-------------------------------------------------------------

    if
        (auxtag1 == 'pointer'  and auxtag2 == 'pointer')  and (len1 <= len2) or
        (auxtag1 == 'pointer2' and auxtag2 == 'pointer2') and (len1 <= len2) or
        (auxtag1 == 'pointer'  and auxtag2 == 'data'   )  and (len1 <= len2) or
        (auxtag1 == 'var'      and auxtag2 == 'var'    )                    
    then
        error = false
        cast = (len1 < len2)
    elseif
        (auxtag1 == 'data'     and auxtag2 == 'data'   )                    
    then
        error = false
        cast = (len1 ~= len2)
    else
        error = true
        cast = false
    end
    return error, cast, ntp1, ntp2, len1, len2

--    if (lvl1==lvl2) then
--      if (lvl1==0 and (ntp1=='void' or ntp2=='void')) then -- lvl==0 -> always basic type
--        error = true
--        cast = false
--      elseif (lvl1==1) then
--        error = true
--        cast = len1 < len2
--      elseif (lvl1==1 and (ntp1 == ntp2)) then
--        error = false
--        cast = false
--      elseif (lvl1==1 and not(not arr1 ~= not arr2) and not(not _TP.isBasicType(ntp1) ~= not _TP.isBasicType(ntp2)))then -- ... (arr1 xor arr2)
--        error = true
--        cast = false
--      else
--        if _TP.isBasicType(ntp1) and _TP.isBasicType(ntp2) then
--          error = false -- _TP.contains() like
--          cast = (_ENV.c[ntp1].len < _ENV.c[ntp2].len)
--        else
--           error = (len2<len1) --not(tp1==tp2) -- Pointer swap len 
--           cast = false
--        end
--      end
--    else
--      if      (lvl1==0 and lvl2==1 and not(_TP.isBasicType(tp1)) and arr2)  
--          or  (lvl1==1 and lvl2==0 and not(_TP.isBasicType(tp2)) and arr1)
--      then
--        error = false
--        cast = false
--      else
--        error = true
--        cast = false
--      end
--    end
--    return error, cast, ntp1, ntp2, len1, len2
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
    if _TP.contains(tp1, tp2, c) then
        return tp1
    elseif _TP.contains(tp2, tp1, c) then
        return tp2
    else
        return nil
    end
end

function _TP.getConstType(val,me)
	local nval = tonumber(val)
--print("tp::getConstType:",val,nval)
	if (nval <= 0xff) then return 'ubyte' end
  if (nval <= 0xffff) then return 'ushort' end
  if (nval <= 0xffffffff) then return 'ulong' end
  WRN(flase,me,'Constant too large, got: "'.. val ..'", max value must be (2^32)-1')
	return 'ulong'
end

function _TP.getConstLen(val)
--print("tp::getConstLen:",val)
	local nval = tonumber(val)
	if (nval <= 0xff) then return 0 end
	if (nval <= 0xffff) then return 1 end
	if (nval <= 0xffffff) then return 2 end
	return 3
end

function _TP.getConstBytes(val,len)
  len = len or 0;
  nx=1
  local nval = tonumber(val)
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

function _TP.getConstBytesLbl(val,len)
  len = 2;
  nx=1
  local nval = tonumber(val)
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
