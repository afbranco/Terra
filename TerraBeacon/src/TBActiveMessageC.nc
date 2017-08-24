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

configuration TBActiveMessageC{

  provides {
    interface SplitControl;
    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Packet;
    interface AMPacket;
    interface PacketAcknowledgements;
    interface Receive as Snoop[am_id_t id];
    interface LowPowerListening;
    interface AMAux;
  }
}
implementation{
  enum {
    CLIENT_ID = unique( "nRFSpi.Resource" ),
  };

#ifdef NRF24
	components nRF24ActiveMessageP as AM;
	components Atm328pSpiC as SpiC;
	AM.SpiByte -> SpiC;
	AM.SpiPacket -> SpiC;
	AM.FastSpiByte -> SpiC;
	AM.SpiResource -> SpiC.Resource[ CLIENT_ID ];

	components HplAtm328pExtInterruptC as ExtInt;
	AM.nRF24_IRQ -> ExtInt.Int0;
	components HplAtm328pGeneralIOC as IO;
	AM.CSNpin -> IO.PortB0;
	AM.CEpin -> IO.PortD7;
	AM.IRQpin -> IO.PortD2; // Int0
		
	components new TimerMilliC() as TimerDelay;
	AM.TimerDelay -> TimerDelay;
	

#elif defined(NO_RADIO)
	components DummyActiveMessageP as AM;
#elif defined(XBEE0)

#elif defined(XBEE1)
	
#endif

	SplitControl = AM;
	AMSend       = AM;
	Receive      = AM.Receive;
	Packet       = AM;
	AMPacket     = AM;
	PacketAcknowledgements = AM;
	Snoop        = AM.Snoop;
	LowPowerListening = AM;
	AMAux		= AM;
  
}