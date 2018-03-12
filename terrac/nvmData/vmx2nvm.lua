#!/usr/bin/env lua
--[[
    Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
    Copyright (C) 2014-2018  Adriano Branco
  
  This file is part of Terra IoT.
  
  Terra IoT is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Terra IoT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  

--]]

--[[
  vmx2nvm
  
  Convert a .vmx file to the eeprom memory (nvm) format. 
  The eeprom format file is to be used as default bytecode script when running the avrora emulator.

typedef struct progEnv {
  uint16_t Version;
  uint16_t ProgStart;
  uint16_t ProgEnd;
  uint16_t nTracks;
  uint16_t wClocks;
  uint16_t asyncs;
  uint16_t wClock0; 
  uint16_t gate0; 
  uint16_t inEvts;  
  uint16_t async0;  
  uint16_t appSize;
  uint8_t  persistFlag; 
} progEnv_t;1
  
--]]

function wr8Bits(fd,value)
  fd:write(string.char(value%255))
end
function wr16Bits(fd,value)
  --print(value%255,math.floor(value/255)%255)
  fd:write(string.char(value%255))
  fd:write(string.char(math.floor(value/255)%255))
end


-- Parse argument - File namoutfile.writee
local filename = arg[1]

-- Open input file
local infile, err = io.open (filename,"r")
if infile == nil then print(err); return; end

-- Parse first line as environment data EnvData structure
local line = infile:read()
if line == nil then print("File format error."); return; end
local envArgs={}
table.insert(envArgs,"1") -- Fisrt number is the script version.
for substring in line:gmatch("%S+") do -- Read from ProtStart up to appSize.
   table.insert(envArgs, tonumber(substring))
end
table.insert(envArgs,1) -- Last number is the persitFlag.

-- Read bytecode data
local pos=0
local val=0
local byteCount=envArgs[3]-envArgs[2]
local bytecodes={}
line = infile:read()
while (line and pos <= byteCount) do
  val = tonumber(line:sub(1,2),16)
  table.insert(bytecodes,val)
  --print(#bytecodes,val)
  line = infile:read()
end
-- Close input file
infile:close()
-- Open output file
local outfilename = filename:sub(1,filename:len()-3) .. "eeprom"
--print(outfilename)
local outfile, err = io.open (outfilename,"w")
if outfile == nil then print(err); return; end

-- Write EnvData
for i=1, 11 do
  wr16Bits(outfile,envArgs[i])
end
--print(envArgs[12],"\n\n")
wr8Bits(outfile,envArgs[12])

-- Write bytecode data
--print(envArgs[2], envArgs[3])
for i=envArgs[2]+1, envArgs[3] do
  wr8Bits(outfile,bytecodes[i])
end
-- close output file
outfile:close()


