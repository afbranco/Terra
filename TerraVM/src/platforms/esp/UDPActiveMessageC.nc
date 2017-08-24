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
configuration UDPActiveMessageC{
	
	provides {
		interface SplitControl;
		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];
    	interface Receive as Snoop[am_id_t id];
		interface AMPacket;
		interface Packet;
		interface PacketAcknowledgements;
    	interface LowPowerListening;
    	interface AMAux;
	}
	
}
implementation{
	
	components UDPActiveMessageP;
	components new TimerMilliC() as SD_Timer, new TimerMilliC() as TimerDelay, new TimerMilliC() as TimerCheckConn;
	components new TimerMilliC() as receiveTaskTimer, new TimerMilliC() as sendDoneTaskTimer;
	
	SplitControl = UDPActiveMessageP;
	AMSend = UDPActiveMessageP;
	Receive = UDPActiveMessageP.Receive;
	Snoop = UDPActiveMessageP.Snoop;
	AMPacket = UDPActiveMessageP;
	Packet = UDPActiveMessageP;
	PacketAcknowledgements = UDPActiveMessageP; // provendo
	LowPowerListening = UDPActiveMessageP;
	AMAux = UDPActiveMessageP;
	
	UDPActiveMessageP.sendDoneTimer->SD_Timer; // usando
	UDPActiveMessageP.timerDelay->TimerDelay;
	UDPActiveMessageP.timerCheckConn -> TimerCheckConn;
	UDPActiveMessageP.receiveTaskTimer -> receiveTaskTimer;
	UDPActiveMessageP.sendDoneTaskTimer -> sendDoneTaskTimer;
}

