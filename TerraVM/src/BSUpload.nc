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
 
#include "BasicServices.h"

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
	
#ifdef INO
	// Log data to USB0
	command void logS(uint8_t* data, uint8_t len);
#endif	
}