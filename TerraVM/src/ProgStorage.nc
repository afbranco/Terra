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