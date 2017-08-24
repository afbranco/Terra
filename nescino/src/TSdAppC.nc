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
configuration TSdAppC{
}
implementation{

  components MainC;
  components TSdC as App;
  components new TimerMilliC() as T1;
  
  App -> MainC.Boot;
  App.Timer -> T1;
  
  components Atm128Uart0C as UART0;
  App.Uart0 -> UART0;
  App.Uart0Ctl -> UART0;
  components new QueueC(uint8_t, 200) as LogQ;
  App.LogQ -> LogQ;
    
  components SdC;
  App.SdIO -> SdC;
  App.SdControl -> SdC;
 
  components InoIOC;
  App.InoIO -> InoIOC.InoIO; 
}