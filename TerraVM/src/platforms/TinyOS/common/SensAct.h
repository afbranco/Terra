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
#ifndef SENS_ACT_H
#define SENS_ACT_H


enum{
	// Sensor control BIT (Identify request sources) max=4 - 0..3)
	SENSOR_CTL_BIT = 6,
	REQ_SOURCE1 = 0,	// Used for VM requests
	REQ_SOURCE2 = 1,	// Used for GRP-AggregReq
	REQ_SOURCE3 = 2,	// Used for GRP-AggregLocal
	REQ_SOURCE4 = 3,	// Used for GRP-Election
	
	// Actuator IDs (max 31)
	AID_LEDS = 1,
	AID_LED0 = 2,
	AID_LED1 = 3,
	AID_LED2 = 4,
	AID_LED0_TOGGLE = 5,
	AID_LED1_TOGGLE = 6,
	AID_LED2_TOGGLE = 7,
	AID_OUT1 = 8,
	AID_OUT2 = 9,
	AID_PIN1 =10,
	AID_PIN2 =11,
	AID_INT1 =12,
	AID_INT2 =13,
	AID_SOUNDER =14,

};
#endif /* SENS_ACT_H */
