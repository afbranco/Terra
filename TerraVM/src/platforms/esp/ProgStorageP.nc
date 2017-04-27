#include "VMData.h"
module ProgStorageP{
	provides interface ProgStorage;
	uses interface InternalFlash;
}
implementation{

#define PROGDATA_START_SEC 0x3D
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
		status = call InternalFlash.write((void*)PROGDATA_START_SEC,&data, BLOCK_SIZE);
		return status;	
	}

	command error_t ProgStorage.getEnv(progEnv_t *env){
		error_t status;
		status = call InternalFlash.read((void*)PROGDATA_START_SEC, &data, BLOCK_SIZE);
		if ( (status == SUCCESS) && (data.env.persistFlag == TRUE) && (data.env.Version > 0) && (data.env.ProgEnd > data.env.ProgStart)){
			memcpy(env,&data.env,sizeof(progEnv_t));
			return SUCCESS;	
		} else {
			return FAIL;
		}
	}

	command error_t ProgStorage.restore(uint8_t *bytecode, uint16_t len){
		error_t status;
		status = call InternalFlash.read((void*)PROGDATA_START_SEC, &data, BLOCK_SIZE);
		memcpy(bytecode,&data.bytecode,len);
		return status;
	}
	
}