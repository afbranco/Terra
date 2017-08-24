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

/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Interface: SensAct
 * Local sensors and actuators
 * 
 */

interface SensAct{
	
	// Request a reading to sensor 'id'
	command void reqSensor(uint8_t reqSource, uint8_t id);
	
	// Signal a sensor done event
	event void Ready(uint8_t reqSource,uint8_t codeEvt_id);
	
	// gets the last sensor read value
	command uint16_t readSensor(uint8_t id);

	// Writes 'val' to actuator 'id'
	command void setActuator(uint8_t id, uint16_t val);

	command void* getDatap(uint8_t id);
	
	// Request a Stream sensor data -- only for stream sensors
	command void reqStreamSensor(uint8_t reqSource, uint8_t id, uint16_t* buf, uint16_t count, uint32_t usPeriod, uint8_t gain);	
}
 