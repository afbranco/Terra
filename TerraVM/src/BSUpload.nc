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
 * Interface: BSUpload
 * Used to upload code and variables values into VM controller.
 * 
 */

#ifdef IX 
  #include "BasicServicesIx.h"
#else
  #include "BasicServices.h"
#endif
interface BSUpload{	
	// Stops de current vm procenssing
	event void stop();

	// Sets environment values
	event void setEnv(newProgVersion_t* data);

	// Gets environment values
	event void getEnv(newProgVersion_t* data);
	
	// Starts the vm processing
	event void start(bool resetFlag);
	
	// Clear all program memory - M[]
	event void resetMemory();
	
	// load a received program section
	event void loadSection(uint16_t Addr, uint8_t Size, uint8_t Data[]);
	
	// get program section
	event uint8_t* getSection(uint16_t Addr);
	
	// Try to restore a program from flash
	// return ProgVersion or 0
	event uint16_t progRestore();
	
#if defined(INOS)
#elif defined(INOX)
	// Log data to USB0
	command void logS(uint8_t* data, uint8_t len);
#endif	
}