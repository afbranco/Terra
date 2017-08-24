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
#include <message.h>  // force to find message.h
interface BSRadio{
	command error_t send(uint8_t am_id, uint16_t target, void* dataMsg, uint8_t dataSize, uint8_t reqAck);
	event void sendDone(uint8_t am_id,message_t* msg,void* dataMsg,error_t error);
	event void sendDoneAck(uint8_t am_id,message_t* msg,void* dataMsg,error_t error, bool wasAcked);
	event void receive(uint8_t am_id, message_t* msg, void* payload, uint8_t len);
	command uint16_t source(message_t* msg);
	command void setRFPower(uint8_t powerIdx);
#ifdef MODULE_CTP
	command error_t sendBS(void* dataMsg, uint8_t dataSize);
	event void sendBSDone(message_t* msg,error_t error);
	command uint16_t getParent();
#endif
	

}