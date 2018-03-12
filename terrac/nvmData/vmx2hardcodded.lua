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
  vmx2hardcoded
  
  Convert a .vmx file to the hardcoded format. 

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
local outfilename = filename:sub(1,filename:len()-3) .. "hd"
--print(outfilename)
local outfile, err = io.open (outfilename,"w")
if outfile == nil then print(err); return; end

-- Write EnvData
outfile:write("progEnv_t _env;\n\n")
outfile:write("void initData() {\n")
outfile:write("_env.Version="..envArgs[1] .. ";\n")
outfile:write("_env.ProgStart="..envArgs[2] .. ";\n")
outfile:write("_env.ProgEnd="..envArgs[3] .. ";\n")
outfile:write("_env.nTracks="..envArgs[4] .. ";\n")
outfile:write("_env.wClocks="..envArgs[5] .. ";\n")
outfile:write("_env.asyncs="..envArgs[6] .. ";\n")
outfile:write("_env.wClock0="..envArgs[7] .. ";\n") 
outfile:write("_env.gate0="..envArgs[8] .. ";\n") 
outfile:write("_env.inEvts="..envArgs[9] .. ";\n")  
outfile:write("_env.async0="..envArgs[10] .. ";\n")
outfile:write("_env.appSize="..envArgs[11] .. ";\n")
outfile:write("_env.persistFlag="..envArgs[12] .. ";\n")
outfile:write("}\n\n")

-- Write bytecode data
outfile:write("\nuint8_t _bytecode[]={\n")
for i=envArgs[2]+1, envArgs[3] do
  outfile:write(bytecodes[i] .. ", ")
end
outfile:write("};\n")

-- close output file
outfile:close()


