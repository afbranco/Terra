/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2014-2017  Adriano Branco
	
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
*/

/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/**
 * Interface: VMCustom
 * Virtual Machine custom component interface
 * 
 */
interface VMCustom{
	command void procOutEvt(uint8_t id, uint32_t value);
	command void callFunction(uint8_t id);
	command void reset();
	event  uint32_t pop();
	event  void push(uint32_t val);
	event void queueEvt(uint8_t evtId, uint8_t auxId,void* data);
	event int32_t getMVal(uint16_t Maddr, uint8_t tp);
	event void setMVal(uint32_t value,uint16_t Maddr, uint8_t fromTp, uint8_t tpTp);
	event void* getRealAddr(uint16_t Maddr);
	event bool getHaltedFlag();
	event void evtError(uint8_t ecode);
	event uint32_t getTime();

}