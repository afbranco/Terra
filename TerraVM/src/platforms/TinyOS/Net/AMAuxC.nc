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
module AMAuxC{
	provides interface AMAux;

// Radio RF Power
#if defined(TOSSIM)

#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB) && !((defined(PLATFORM_IRIS) || defined(INOS) || defined(INOX)))
	uses interface CC2420Packet as RadioAux;
#elif (defined(PLATFORM_IRIS) && !(defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB) || defined(INOS) || defined(INOX)))
	uses interface PacketField<uint8_t> as RadioAux;
#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
	uses interface CC1000Control as RadioAux;
#endif
	
}
implementation{

// Define the TxPower value for each radio chip
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB)
	// CC2420
	uint8_t RFPowerTab[8]={3, 7, 11, 15, 19, 23, 27, 31}; 	// DBm=[-25;-15;-10;-7;-5;-3;-1;0]
#elif defined(PLATFORM_IRIS)
	// AT86RF230
	uint8_t RFPowerTab[8]={10, 07, 6, 4, 3, 2, 1, 0};		// DBm=[-7.2;-4.2;-3.2;-1.9;-1.4;-0.9;-0.4;0]
#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
	// CC1000
	uint8_t RFPowerTab[8]={2, 9, 64, 96, 128, 176, 240, 255};	// DBm=[-20;-10;-5;-2;1;2;4;5]
	#define RFPOWER_INIT(power) atomic{call AMAux.setPower(null,RFPowerTab[power]);}
	#define RFPOWER_INIT_ 0
#endif

	command void AMAux.setPower(message_t *p_msg, uint8_t power){
#ifdef TOSSIM

#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB)
		call RadioAux.setPower(p_msg,RFPowerTab[power%8]);
#elif defined(PLATFORM_IRIS)
		call RadioAux.set(p_msg,RFPowerTab[power%8]);
#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
		atomic {call RadioAux.setRFPower(RFPowerTab[power%8]);};
#else

#endif
	}

	command uint8_t AMAux.getPower(message_t *p_msg){
#ifdef TOSSIM
		return 0;
#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB)
		return call RadioAux.getPower(p_msg);
#elif defined(PLATFORM_IRIS)
		return call RadioAux.get(p_msg);
#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
		return call RadioAux.getRFPower();
#else
		return 0;
#endif
	}
}