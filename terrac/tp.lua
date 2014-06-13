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
    return string.match(tp, '(.-)%*$') or (c and _TP.ext(tp))
end

function _TP.ext (tp)
    return (string.sub(tp,1,1) == '_') and
            (not string.match(tp, '(.-)%*$')) and tp
end


function _TP.argsTp(tp1,tp2)
    -- error == true -> incompatible types
    -- cast == true -> need cast
    local error = true 
    local cast = false
    if (_TP.isBasicType(tp1) or _TP.isBasicType(_TP.deref(tp1))) then -- is a basic type
      if (_TP.deref(tp1)) then
          if (_TP.deref(tp2)) then
            error = (_ENV.c[_TP.deref(tp1)].len < _ENV.c[_TP.deref(tp2)].len) -- _TP.contains() like
            cast = error
          else
            error = true
            cast = false
          end
      else
          if _TP.isBasicType(tp2) then
            cast = (_ENV.c[tp1].len < _ENV.c[tp2].len)
            error = false
          else
            error = true
            cast = false
          end
      end
    else  -- is NOT a basic type
         error = not(tp1==tp2)
         cast = false
    end
    return error, cast
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

function _TP.getConstType(val,ln)
	local nval = tonumber(val)
--print("tp::getConstType:",val,nval)
	if (nval <= 0xff) then return 'ubyte' end
  if (nval <= 0xffff) then return 'ushort' end
  if (nval <= 0xffffffff) then return 'ulong' end
  DBG('WRN : line '..(ln or '?')..' : '..'Constant too large, got: "'.. val ..'", max value must be (2^32)-1')
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
