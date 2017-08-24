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
module ProgStorageP{
	provides interface ProgStorage;
	uses interface InternalFlash;
}
implementation{
#define FLASH_START_ADDR 0x00L
#define env_addr FLASH_START_ADDR
#define bytecode_addr (FLASH_START_ADDR + sizeof(progEnv_t))
	
	command error_t ProgStorage.save(progEnv_t *env, uint8_t *bytecode, uint16_t len){
		error_t status;
		if ((len + sizeof(progEnv_t)) > INTFLASH_SIZE) return FAIL;
		status = call InternalFlash.write((uint8_t *)env_addr, (uint8_t*)env, sizeof(progEnv_t));
		if (status == SUCCESS) {
			status = call InternalFlash.write((uint8_t *)bytecode_addr, (uint8_t*)bytecode, len);
		}
		dbg(APPNAME,"ProgStorage::save(): status=%d\n",status);
		return status;	
	}

	command error_t ProgStorage.getEnv(progEnv_t *env){
		error_t status;
		status = call InternalFlash.read((uint8_t *)env_addr, (uint8_t*)env, sizeof(progEnv_t));		
		if ( (status == SUCCESS) && (env->persistFlag == TRUE) && (env->Version > 0) && (env->ProgEnd > env->ProgStart)){
			return SUCCESS;	
		} else {
			return FAIL;
		}
	}

	command error_t ProgStorage.restore(uint8_t *bytecode, uint16_t len){
		error_t status;
		status = call InternalFlash.read((uint8_t *)bytecode_addr, (uint8_t*)bytecode, len);
		return status;
	}
	
}