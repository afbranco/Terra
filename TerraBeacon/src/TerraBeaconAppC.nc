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
configuration TerraBeaconAppC{
}
implementation{
	components MainC, TerraBeaconP as TB;
    TB.TOSBoot  -> MainC;
    
    components TBActiveMessageC as AMDriver;
	TB.RadioControl -> AMDriver.SplitControl;
	TB.RadioAMPacket -> AMDriver;
	TB.RadioPacket -> AMDriver.Packet;
	TB.RadioAck -> AMDriver.PacketAcknowledgements;
 	TB.RadioSender -> AMDriver.AMSend;
	TB.AMAux -> AMDriver;
	TB.RadioReceiver -> AMDriver.Receive;
	
	components new TimerMilliC() as TimerBeacon;
	TB.TimerBeacon -> TimerBeacon;
	components new TimerMilliC() as sendTimer;
	TB.sendTimer -> sendTimer;
	components new TimerMilliC() as radioStop;
	TB.radioStop -> radioStop;
	components RandomC;
	TB.Random -> RandomC;

	components HplAtm328pGeneralIOC as IO;
	TB.PC0 -> IO.PortC0;
	TB.PD3 -> IO.PortD3;
	TB.LED -> IO.PortD6; // LED Aux
	
	components new Analog0C() as Ana0;
	TB.Ana0 -> Ana0;
    	
	
}