
varType = {}
varType[0]='ubyte'
varType[1]='ushort'
varType[2]='ulong'
varType[3]='float'
varType[4]='byte'
varType[5]='short'
varType[6]='long'
varType[7]='----'


--------------------------------------------------
-- Replace ('push_c addr' + 'deref') -> 'push_v addr'
--------------------------------------------------
_AST.root.opcode_aux={}
for x,op in pairs(_AST.root.opcode) do
  if (string.sub(op,1,1) ~= 'L') then
    if (string.sub(op,1,1) ~= '.') and (string.sub(op,1,1) ~= '_') then
--print("...",op,_AST.root.code2[x])
      local op_num = tonumber('0x'..op)
      local op_code = math.floor(op_num/4)*4 -- push_c + 2bit flag
      local op_mod = op_num % 4
      if op_code == opcode.op_push_c  and string.sub((_AST.root.code2[x] or ''),1,6)=='push_c' then
        local next_op_num = tonumber('0x'.._AST.root.opcode[x+2+op_mod])
        local next_op_code = math.floor(next_op_num/8)*8 -- deref + 3bit flag
        local next_op_mod = next_op_num % 8
--print("optm::deref:*",op,op_num,op_code,op_mod,string.sub((_AST.root.code2[x] or ''),1,6))
        if  next_op_code == opcode.op_deref then
--print("optm::deref: ",_AST.root.opcode[x+2+op_mod],next_op_num,next_op_code,next_op_mod,string.sub((_AST.root.code2[x+2+op_mod] or ''),1,6))
          _AST.root.code2[x] = string.gsub(_AST.root.code2[x],"push_c", "push_v "..varType[next_op_mod]).." [Optm:: push_c addr + deref]"
          _AST.root.opcode[x]=string.format("%02x",opcode.op_push_v+ (op_mod*8) + next_op_mod)
          _AST.root.opcode[x+2+op_mod]='_'
        end
      end      
    end
  end 
end

--------------------------------------------------
-- Remove extra 'execs'
--------------------------------------------------

-- build Label2label Table - Label -> Exec operation => LabelExecOper
_AST.root.label2label={}
local lblL,lblH;
local labelOper, labelExec;
for x,op in ipairs(_AST.root.opcode) do
  if (string.sub(op,1,1) == 'L') then 
    labelOper = tonumber('0x'..string.sub(op,2,5))
  else
    if labelOper then
      if not labelExec then
        local op_num = tonumber('0x'..op)
        if op_num == opcode.op_exec+1 then -- exec + 1 bit flag
          labelExec = true
        elseif op_num == opcode.op_end then
           _AST.root.label2label[labelOper]= 0;
          labelExec = nil
          labelOper = nil
        else
          labelExec = nil
          labelOper = nil
        end
      else  
        if (string.sub(op,1,1) == '.') then
          if (lblH==nil) then
            lblH = string.sub(op,2,3)
          else
            lblL = string.sub(op,2,3)
            local lbl = tonumber(('0x'..lblH))*256 + tonumber('0x'..lblL)
            _AST.root.label2label[labelOper]= lbl;
            lblH = nil
            labelExec = nil
            labelOper = nil          
          end
        end
      end
    end
  end 
end
-- Minimize exec -> exec
local changed = true
while changed do
--print("+")
  changed = false
  for lbl,toLbl in pairs(_AST.root.label2label) do
--print(lbl,toLbl)
    _AST.root.label2label[lbl] = _AST.root.label2label[toLbl]  or toLbl
    changed = (changed or not (_AST.root.label2label[lbl] == toLbl))
  end
end
--print("-------")
for lbl,toLbl in pairs(_AST.root.label2label) do
  --print(lbl,toLbl)
end

-- Change label->exec1->exec2 to label->exec2
_AST.root.opcode_aux={}
local lblL,lblH;
for x,op in pairs(_AST.root.opcode) do
  if (string.sub(op,1,1) ~= 'L') then
    if (string.sub(op,1,1) == '.') then
      if (lblH==nil) then
        lblH = string.sub(op,2,3)
      else
        lblL = string.sub(op,2,3)
        local lbl = tonumber(('0x'..lblH))*256 + tonumber('0x'..lblL)
        local newLabel = (_AST.root.label2label[lbl]~=0 and _AST.root.label2label[lbl]) or lbl
        _AST.root.opcode[x-1]=string.format('.%02x',newLabel / 256)
        _AST.root.opcode[x]=string.format('.%02x',newLabel % 256)
        lblH = nil
      end
    end
  end 
end


-- Remove inactive 'execs' or change to 'end' opcode
--print("-------")
local action, labelOper, steps
steps=0
for x,op in pairs(_AST.root.opcode) do
  if (string.sub(op,1,1) == 'L') then
    labelOper = tonumber('0x'..string.sub(op,2,5))
    action = ((_AST.root.label2label[labelOper] and _AST.root.label2label[labelOper]>0) and 'rem') or nil
--print(x,op, action)
    --_AST.root.opcode[x]='_'
  else
--print(x,op, action)
    if action=='rem' then
      _AST.root.opcode[x]='_'
      steps = steps + 1
      if steps >=3 then action = nil; steps=0; end
    elseif action == 'end' then
      if steps == 0 then 
        _AST.root.opcode[x]=string.format("%02x",opcode.op_end)
      else
        _AST.root.opcode[x]='_'
      end 
      steps = steps + 1
      if steps >=3 then action = nil; steps=0; end
    end  
  end
end



--------------------------------------------------
-- Remove 'exec' near 'end'
--------------------------------------------------
local lblL,lblH;
local lastOp,execOp,lastLabel, execLabel, prevLabel
for x,op in pairs(_AST.root.opcode) do
--print(x,op)
  if (string.sub(op,1,1) ~= 'L') then
    if (string.sub(op,1,1) == '.') then
      if (lblH==nil) then
        lblH = string.sub(op,2,3)
        local op_num = tonumber('0x'..lastOp)
        if op_num == opcode.op_exec+1 then
          execOp = true
          prevLabel = lastLabel 
        end
      else
        lblL = string.sub(op,2,3)
        execLabel = tonumber(('0x'..lblH))*256 + tonumber('0x'..lblL)
        lblH = nil
      end
    else
      local op_num = tonumber('0x'..op)
      if execOp and op_num==opcode.op_end then -- next opcode is an 'end'
--print('*********************:', prevLabel,execLabel,lastLabel) 
        if (prevLabel~=execLabel and execLabel==lastLabel) then -- remove the 'exec' oper
          local count = 1
          local remove = true
          while remove do
            if (string.sub(_AST.root.opcode[x-count],1,1) == '.') then
--print('removing: ',x-count-2,_AST.root.opcode[x-count-2],_AST.root.opcode[x-count-1],_AST.root.opcode[x-count])
              _AST.root.opcode[x-count]   = '_'
              _AST.root.opcode[x-count-1] = '_'
              _AST.root.opcode[x-count-2] = '_'
              remove = false
              execOp = false
            else
              count = count + 1
            end
          end
        end      
      else
        execOp = false
      end 
    end
  else
    lastLabel = tonumber('0x'..string.sub(op,2,5))  
  end
  lastOp = op 
end



--------------------------------------------------
-- Convert to 'end' any 'exec' pointing to 'end'
--------------------------------------------------
local lblL,lblH;
local lastOp,execOp,execLabel
for x,op in pairs(_AST.root.opcode) do
--print(x,op)
  if (string.sub(op,1,1) ~= 'L') then
    if (string.sub(op,1,1) == '.') then
      if (lblH==nil) then
        lblH = string.sub(op,2,3)
        local op_num = tonumber('0x'..lastOp)
        if op_num == opcode.op_exec+1 then
          execOp = true
        end
      else
        lblL = string.sub(op,2,3)
        execLabel = tonumber(('0x'..lblH))*256 + tonumber('0x'..lblL)
        lblH = nil
        if execOp and _AST.root.label2label[execLabel]==0 then -- point to an 'end' opcode
              _AST.root.opcode[x]   = '_'
              _AST.root.opcode[x-1] = '_'
              _AST.root.opcode[x-2] = string.format("%02x",opcode.op_end)
              _AST.root.code2[x-2] = 'end                           | end'
        end
        execOp = false
      end 
    end
  end
  lastOp = op 
end


--------------------------------------------------
-- Remove 'end' + 'end'
--------------------------------------------------
for x,op in pairs(_AST.root.opcode) do
--print(x,op)
  if (string.sub(op,1,1) ~= 'L') then
    local op_num = tonumber('0x'..op)
    if op_num == opcode.op_end  and string.sub((_AST.root.code2[x] or ''),1,3)=='end' then
      if _AST.root.opcode[x-1]==string.format("%02x",opcode.op_end) and string.sub((_AST.root.code2[x-1] or ''),1,3)=='end' then
        _AST.root.opcode[x-1]='_'
      end
    end
  end
end


