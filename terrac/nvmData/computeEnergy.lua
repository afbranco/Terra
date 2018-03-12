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
	computeEnergy.lua

--]]

local energy={}
energy.FRAM =0.76175
energy.SRAM = 0.2581875

local addrMap={}
local addrException={}

function getType(addr)
	for k,v in ipairs(addrMap) do
		--print (addr,v.first,v.last)
		if addr >= addrException.first and addr < addrException.last then
			return "SRAM",v.var, 0
		end
		if addr >= v.first and addr < v.last then
			return "FRAM",v.var, (v.last - v.first)
		end
	end
	return "SRAM","---", 0
end

-- Build Reference Map

-- from> nm -n -S gitspace/Terra/TerraVM/src/build/micaz/main.elf | grep -e"B TerraVMC"
local strMap =
[[
00800146 00000001 B TerraVMC__procFlag
00800147 00000001 B TerraVMC__progRestored
0080033a 00000017 B TerraVMC__envData
0080036d 00000001 B TerraVMC__ExtDataSysError
0080037b 00000002 B TerraVMC__MoteID
00800396 00000002 B TerraVMC__MEM
008003fa 00000002 B TerraVMC__PC
00800462 00000004 B TerraVMC__old
0080046c 00000898 B TerraVMC__CEU_data
]]

local vmxEnv= "177 379 1 2 0 0 16 1 16 393"

for line in strMap:gmatch("(.-)\n") do
--	local addrStart=tonumber(line:sub(1,8),16)%0x000fffff
	local addrStart=tonumber(line:sub(4,8),16)
	local size=tonumber(line:sub(10,18),16)
	local addrEnd=addrStart+size
	local addrVar = line:sub(31)
	--print(addrStart,addrEnd,size)
	local tempTab={}
	tempTab.first = addrStart
	tempTab.last = addrEnd
	tempTab.var = addrVar
	table.insert(addrMap,tempTab)
end

-- Get VM code section
local lineVals={}
for substring in vmxEnv:gmatch("%S+") do
	--print(substring)
   table.insert(lineVals, substring)
end
addrException.first = tonumber(lineVals[1]) + addrMap[#addrMap].first
addrException.last =  tonumber(lineVals[2]) + addrMap[#addrMap].first
print(addrMap[#addrMap].first)
print(addrException.first,addrException.last)

-- Parse argument - File namoutfile.writee
local filename = arg[1]

-- Open input file
local infile, err = io.open (filename,"r")
if infile == nil then print(err); return; end

-- LEDS
-- jump to event data
local found = nil
while found == nil do
	line = infile:read()
	--print(line)
	found = line:find("Simulation events")
	--print(found)
end
-- jump 2 lines
line = infile:read()
line = infile:read()

-- read data and compute read/writes
local LEDS={}
LEDS[1]={}
LEDS[2]={}
LEDS[3]={}

local ledPos={}
ledPos[1]=1
ledPos[2]=1
ledPos[3]=1
LEDS[1][1]={time=0,state="off"}
LEDS[2][1]={time=0,state="off"}
LEDS[3][1]={time=0,state="off"}


line = infile:read()
while line:find("===") == nil do
	local lineVals={}
	for substring in line:gmatch("%S+") do
		--print(substring)
	   table.insert(lineVals, substring)
	end
	if #lineVals > 1 then
		for k,v in ipairs(LEDS) do
			if v[ledPos[k]].state ~= lineVals[k+2] then
				ledPos[k] = ledPos[k] + 1
				LEDS[k][ledPos[k]]={}
				LEDS[k][ledPos[k]].state=lineVals[k+2]
				LEDS[k][ledPos[k]].time=lineVals[2]
			end
		end
	end
	line = infile:read()
end

--[[
for l,w in ipairs(LEDS) do
	print("Led".. l .. ":")
	for k,v in ipairs(w) do
		print("Led".. l .. ":",k,v.state,v.time - ((LEDS[l][k-1] and LEDS[l][k-1].time) or 0))
	end
end
--]]

-- MEMORY
-- jump to memory data
local found = nil
while found == nil do
	line = infile:read()
	--print(line)
	found = line:find("Memory profiling")
	--print(found)
end
-- jump 2 lines
line = infile:read()
line = infile:read()


-- read data and compute read/writes
local total={}
local totalVar={}
line = infile:read()
while line:find("total") == nil do
	local lineVals={}
	for substring in line:gmatch("%S+") do
		--print(substring)
		if substring == "." then break; end
	   table.insert(lineVals, substring)
	end
	if #lineVals > 1 then
		local addr = tonumber(lineVals[1]:sub(1,6),16)
		local reads = tonumber(lineVals[2])
		local writes = tonumber(lineVals[5])
		local memType, memVar, size = getType(addr)
		if total[memType] == nil then 
			total[memType]={}
			total[memType].reads = 0
			total[memType].writes = 0
			total[memType].sum = 0
		end
		total[memType].reads = total[memType].reads + reads
		total[memType].writes = total[memType].writes + writes
		total[memType].sum = total[memType].sum + reads + writes

		if totalVar[memVar] == nil then
			totalVar[memVar]={}
			totalVar[memVar].reads = 0
			totalVar[memVar].writes = 0
			totalVar[memVar].sum = 0
			totalVar[memVar].size = size
		end 
		totalVar[memVar].reads = totalVar[memVar].reads + reads
		totalVar[memVar].writes = totalVar[memVar].writes + writes
		totalVar[memVar].sum = totalVar[memVar].sum + reads + writes
		--print(lineVals[1],addr,reads,writes,memType)
	end
	line = infile:read()
end

-- jump to Execution time
local found = nil
while found == nil do
	line = infile:read()
	--print(line)
	found = line:find("Node lifetime")
	--print(found)
end
-- Get TotalCpuCycles and Execution time
local lineVals={}
for substring in line:gmatch("%S+") do
   table.insert(lineVals, substring)
end
local execTime =  lineVals[5]
local cpuTime = lineVals[3]
-- jump 1 lines
line = infile:read()
-- Get Total CPU energy
local lineVals={}
line = infile:read()
for substring in line:gmatch("%S+") do
   table.insert(lineVals, substring)
end
local totalEnergy =  lineVals[2]

-- Get CPU Energy and Cycles
--[[
   Active: 0.02533156648055013 Joule, 8227478 cycles
   Idle: 0.0 Joule, 0 cycles
   ADC Noise Reduction: 0.0014602113886718747 Joule, 3630732 cycles
   Power Down: 0.0 Joule, 0 cycles
   Power Save: 0.0012957429032389323 Joule, 25743070 cycles
   RESERVED 1: 0.0 Joule, 0 cycles
   RESERVED 2: 0.0 Joule, 0 cycles
   Standby: 0.0 Joule, 0 cycles
   Extended Standby: 0.0 Joule, 0 cycles
   
--]]

local cpuElement={}

for i=1,9 do
	local lineVals={}
	cpuElement[i]={}
	line = infile:read()
	for substring in line:gmatch("%S+") do
	   table.insert(lineVals, substring)
	end
	cpuElement[i].energy=lineVals[#lineVals - 3]
	cpuElement[i].cycles=lineVals[#lineVals - 1]
end

local CPU={}
CPU.active=cpuElement[1];
CPU.idle=cpuElement[2];
CPU.adcNoiseReduction=cpuElement[3];
CPU.powerDown=cpuElement[4];
CPU.powerSave=cpuElement[5];
CPU.reserv1=cpuElement[6];
CPU.reserv1=cpuElement[7];
CPU.standby=cpuElement[8];
CPU.extendedStandby=cpuElement[9];



-- Print data
local sumTotal = 0;
local EnergyTotal = 0
for k,v in pairs(total) do
	sumTotal = sumTotal + v.sum
	total[k].energy = energy[k]*total[k].sum
	EnergyTotal = EnergyTotal + total[k].energy
end

local printAll = true

if printAll then
	print("\n==========================================")
	print(string.format("%20s",""),"size","Sum","RDs","WRs")
	for k,v in pairs(totalVar) do
		print(string.format("%20s",k), v.size,v.sum,v.reads,v.writes)
	end
	print("\n------------------------------------------")
	print("tp","  RDs     ","  WRs     ","  Total   ","%","Energy(nJ)","% ngy")
	for k,v in pairs(total) do
		print(k,string.format("%10d",v.reads),string.format("%10d",v.writes),string.format("%10d",v.sum), string.format("%3.1f",(v.sum/sumTotal)*100),string.format("%10.1f",v.energy),string.format("%3.1f",100*v.energy/EnergyTotal))
	end
	print(execTime,sumTotal,total.SRAM.sum,total.FRAM.sum,CPU.active.energy,totalEnergy-CPU.active.energy, (#LEDS[2]-1)/2,#LEDS[3])
	print("==========================================")
else
	print(execTime,sumTotal,total.SRAM.sum,total.FRAM.sum,CPU.active.energy,totalEnergy-CPU.active.energy, (#LEDS[2]-1)/2,#LEDS[3])
end

-- close file





