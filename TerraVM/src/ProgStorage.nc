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

#include "VMData.h"

interface ProgStorage {
	
	/**
	 * Save Env+Bytecode in the persistent memory
	 * @param env Pointer to Prog Environment structure
	 * @param bytecode Pointer to prog bytecode (first bytecode after data space of VM MEM)
	 * @param len Byecode len
	 * @return Returns SUCCESS for a valid write.
 	 */
	command error_t save(progEnv_t* env, uint8_t* bytecode, uint16_t len);
	
	/**
	 * Get Prog Environment from the persistent memory
	 * @param env Pointer to Prog Environment structure
	 * @return Returns SUCCESS for a valid read.
 	 */
	command error_t getEnv(progEnv_t* env);
	
	/**
	 * Get Bytecode from the persistent memory
	 * @param bytecode Pointer to prog bytecode (first bytecode after data space of VM MEM)
	 * @param len Byecode len
	 * @return Returns SUCCESS for a valid read.
	 */
	command error_t restore(uint8_t* bytecode, uint16_t len);
	

}