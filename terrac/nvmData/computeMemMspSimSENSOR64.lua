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
	computeMemMspSim.lua

--]]


local addrMap={}
local symbolAddr={}
local addrException={}

function getType(addr)
	for k,v in ipairs(addrMap) do
		--print (addr,v.first,v.last)
		if addr >= addrException.first and addr < addrException.last then
			return "FRAM2",addrException.var, 0
		end
		if addr >= v.first and addr < v.last then
			return "FRAM",v.var, (v.last - v.first)
		end
	end
	return "SRAM","---", 0
end

-- Build Reference Map

-- from> nm -n -S ~/gitspace/Terra/TerraVM/src/build/telosb/main.exe | grep -e"B TerraVMC"
local strMap =
[[
00001206 00000001 B TerraVMC__procFlag
00001208 00000001 B TerraVMC__progRestored
00001302 00000018 B TerraVMC__envData
00001328 00000001 B TerraVMC__ExtDataSysError
0000132e 00000002 B TerraVMC__MoteID
00001330 00000002 B TerraVMC__MEM
0000134a 00000002 B TerraVMC__PC
00001366 00000004 B TerraVMC__old
00001370 00001130 B TerraVMC__CEU_data
]]

local vmxEnv= "173 355 1 2 0 0 16 0 16 369"

for line in strMap:gmatch("(.-)\n") do
	if line:sub(10,10) == "0" then
		local addrStart=tonumber(line:sub(4,8),16)
		local size=tonumber(line:sub(10,18),16)
		local symbolName= line:sub(21)
		local addrEnd=addrStart+size
		local addrVar = line:sub(21)
		--print(addrVar,addrStart,addrEnd,size)
		local tempTab={}
		tempTab.first = addrStart
		tempTab.last = addrEnd
		tempTab.var = addrVar
		table.insert(addrMap,tempTab)
		symbolAddr[symbolName] = addrStart
	end
end

-- Get VM code section
local lineVals={}
for substring in vmxEnv:gmatch("%S+") do
	--print(substring)
   table.insert(lineVals, substring)
end
addrException.first = tonumber(lineVals[1]) + addrMap[#addrMap].first
addrException.last =  tonumber(lineVals[2]) + addrMap[#addrMap].first
addrException.var = "TerraVMC__CEU_data"
print(addrMap[#addrMap].first)
print(addrException.first,addrException.last)

-- Parse argument - File name
local filename = arg[1]

-- Open input file
local infile, err = io.open (filename,"r")
if infile == nil then print(err); return; end


local total={}
local totalVar={}
local memList={}
-- Filter file
line = infile:read()
while line ~= nil do
	local lineVals={}
	if line:sub(1,3) == "***" then
		for substring in line:gmatch("%S+") do
		   --print(substring:gsub("%$","0x"))
		   local substr = substring:gsub("%$","0x")
		   table.insert(lineVals, substr)
		end
		--print(line)
		--print(lineVals[2],tonumber(symbolAddr[lineVals[#lineVals-2]] or lineVals[#lineVals-2]),lineVals[#lineVals-2],lineVals[#lineVals])

		local addr = tonumber(symbolAddr[lineVals[#lineVals-2]] or lineVals[#lineVals-2]) or 0
		--print(">>",addr,lineVals[#lineVals-2],symbolAddr[lineVals[#lineVals-2]])
		local read = ((lineVals[2] == "Read") and 1) or 0
		local write = ((lineVals[2] == "Write") and 1) or 0
		local memType, memVar, size = getType(addr)
		if total[memType] == nil then 
			total[memType]={}
			total[memType].reads = 0
			total[memType].writes = 0
			total[memType].sum = 0
		end
		total[memType].reads = total[memType].reads + read
		total[memType].writes = total[memType].writes + write
		total[memType].sum = total[memType].sum + read + write

		if memList[addr] == nil then
			memList[addr]={}
			memList[addr].reads = 0 
			memList[addr].writes = 0 
			memList[addr].sum = 0
			memList[addr].var = memVar 
			memList[addr].type = memType 
		end
		memList[addr].reads = memList[addr].reads + read 
		memList[addr].writes = memList[addr].writes + write 
		memList[addr].sum = memList[addr].sum + read + write 


		if totalVar[memVar] == nil then
			totalVar[memVar]={}
			totalVar[memVar].reads = 0
			totalVar[memVar].writes = 0
			totalVar[memVar].sum = 0
			totalVar[memVar].size = size
		end 
		totalVar[memVar].reads = totalVar[memVar].reads + read
		totalVar[memVar].writes = totalVar[memVar].writes + write
		totalVar[memVar].sum = totalVar[memVar].sum + read + write
		--print(lineVals[1],addr,reads,writes,memType)
	end



	line = infile:read()
end


print("=============")
-- Print data
for k,v in pairs(total) do
	print(k,v.sum)
end
print("=============")

for k,v in pairs(totalVar) do
	print(k,v.sum)
end
print("=============")

for k,v in pairs(memList) do
	--print(k,string.format("0x%0x",k),v.reads,v.writes,v.sum,v.var,v.type)
end



