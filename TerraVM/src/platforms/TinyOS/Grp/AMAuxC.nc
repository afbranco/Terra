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

	command void AMAux.setPower(message_t *p_msg, uint8_t power){
#ifdef TOSSIM

#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB)
		call RadioAux.setPower(p_msg,power);
#elif defined(PLATFORM_IRIS)
		call RadioAux.set(p_msg,power);
#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
		atomic {call RadioAux.setRFPower(power);};
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