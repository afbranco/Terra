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

configuration VMCustomC{
	provides interface VMCustom;
}
implementation{
	components VMCustomP as custom;
	components BasicServicesC as BS;
	custom.VM = VMCustom;
	custom.BSRadio -> BS;
	components RandomC;
	custom.Random -> RandomC;

	components HplAtm2560GeneralIOC as IO;
	// Ana0
	custom.PA_0 -> IO.PortA0;
	components new Analog0C() as Ana0;
	custom.Ana0 -> Ana0;
	// Ana1
	custom.PA_1 -> IO.PortA1;
	components new Analog1C() as Ana1;
	custom.Ana1 -> Ana1;
	// Ana2
	custom.PA_2 -> IO.PortA2;
	components new Analog2C() as Ana2;
	custom.Ana2 -> Ana2;
	// Ana3
	custom.PA_3 -> IO.PortA3;
	components new Analog3C() as Ana3;
	custom.Ana3 -> Ana3;

	// Interruptions
	components HplAtm2560ExtInterruptC as ExtInt;
	custom.Int0 -> ExtInt.Int0;
	custom.Int1 -> ExtInt.Int1;
	custom.Int2 -> ExtInt.Int2;
	custom.Int3 -> ExtInt.Int3;
	
	// DHT
	components dhtC as DHT;
	custom.dht -> DHT;

	// RTC
	components rtcC as rtc;
	custom.rtc -> rtc;
	
	// Custom Queues
#ifdef M_MSG_QUEUE
	components new dataQueueC(usrMsg_t,USRMSG_QSIZE,(char)unique("dataQueueC")) as usrDataQ;
	custom.usrDataQ -> usrDataQ;
#endif

}