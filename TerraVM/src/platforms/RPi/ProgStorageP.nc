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

#define BLOCK_SIZE 4096

typedef struct progStorage {
	progEnv_t env;
	uint8_t bytecode[BLOCK_SIZE - sizeof(progEnv_t)];
} progStorage_t;

	progStorage_t data;
	
	command error_t ProgStorage.save(progEnv_t *env, uint8_t *bytecode, uint16_t len){
		error_t status;
		if ((len + sizeof(progEnv_t)) > INTFLASH_SIZE) return FAIL;
		memcpy(&data.env,env,sizeof(progEnv_t));
		memcpy(&data.bytecode,bytecode,len);
		status = call InternalFlash.write((void*)0,&data, BLOCK_SIZE);
		return status;	
	}

	command error_t ProgStorage.getEnv(progEnv_t *env){
		error_t status;
		status = call InternalFlash.read((void*)0, &data, BLOCK_SIZE);
		if ( (status == SUCCESS) && (data.env.persistFlag == TRUE) && (data.env.Version > 0) && (data.env.ProgEnd > data.env.ProgStart)){
			memcpy(env,&data.env,sizeof(progEnv_t));
			return SUCCESS;	
		} else {
			return FAIL;
		}
	}

	command error_t ProgStorage.restore(uint8_t *bytecode, uint16_t len){
		error_t status;
		status = call InternalFlash.read((void*)0, &data, BLOCK_SIZE);
		memcpy(bytecode,&data.bytecode,len);
		return status;
	}
	
}