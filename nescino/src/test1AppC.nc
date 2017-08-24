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
configuration test1AppC
{
}
implementation
{
  components MainC;
  components test1C;
  components new TimerMilliC() as T1;

  test1C -> MainC.Boot;
  test1C.Timer -> T1;
  
  components LedsC;
  test1C.Leds -> LedsC;

  
  components Atm128Uart0C as UART0;
  test1C.Uart0 -> UART0;
  test1C.Uart0Ctl -> UART0;


  components XBeeMsgC as XBee;
  test1C.RadioSnd -> XBee;
  test1C.RadioRec -> XBee;
  test1C.RadioCtl -> XBee;
  
  test1C.xLog -> XBee;
  
  components new QueueC(uint8_t, 100) as LogQ;
  test1C.LogQ -> LogQ;
  
}
