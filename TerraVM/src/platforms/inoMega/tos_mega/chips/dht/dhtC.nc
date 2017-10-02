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
configuration dhtC{
	provides interface dht;	
}
implementation{
	components MainC;
	components dhtP, CounterMicro32C as CounterMicro;
	dht = dhtP.dht;
	dhtP.Boot -> MainC;
	dhtP.CounterMicro -> CounterMicro;

	components HplAtm2560ExtInterruptC as ExtInt;
	dhtP.Int0 -> ExtInt.Int0;
	dhtP.Int1 -> ExtInt.Int1;
	dhtP.Int2 -> ExtInt.Int2;
	dhtP.Int3 -> ExtInt.Int3;
	
	components new TimerMilliC() as Timer;
	dhtP.Timer -> Timer;
}