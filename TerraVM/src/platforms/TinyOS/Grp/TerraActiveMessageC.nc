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

configuration TerraActiveMessageC{

  provides {
    interface SplitControl;

    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];

    interface Packet;
    interface AMPacket;
    interface PacketAcknowledgements;
#ifdef LPL_ON
    interface LowPowerListening;
#endif
    interface AMAux;
  }
}
implementation{
	components AMAuxC;

// ActiveMessage + Radio RF Power + LPLSend
#if defined(PLATFORM_MICAZ) && defined(TOSSIM)
	components ActiveMessageC as AM;
#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB)
	components CC2420ActiveMessageC as AM;
	AMAuxC.RadioAux -> AM;

	#ifdef LPL_ON
	LowPowerListening = AM.LowPowerListening;
	#endif

#elif defined(PLATFORM_IRIS)
	components RF230ActiveMessageC as AM;
	AMAuxC.RadioAux -> AM.PacketTransmitPower;

	#ifdef LPL_ON
	LowPowerListening = AM.LowPowerListening;
	#endif


#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
	components CC1000ActiveMessageC as AM;
	components CC1000ControlP as RadioPwr;
	AMAuxC.RadioAux -> RadioPwr;

	#ifdef LPL_ON
	LowPowerListening = AM.LowPowerListening;
	#endif
#endif
  
	
	SplitControl = AM;
  
	AMSend       = AM;
	Receive      = AM.ReceiveUser;
	Snoop        = AM.Snoop;
	Packet       = AM;
	AMPacket     = AM;
	PacketAcknowledgements = AM;
//	LowPowerListening	 = AM;

	AMAux = AMAuxC;

}