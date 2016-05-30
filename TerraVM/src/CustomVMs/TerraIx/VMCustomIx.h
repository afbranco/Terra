/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#ifndef VMCUSTOM_H
#define VMCUSTOM_H

#include "VMData.h" //"../../VMData.h"
#include "VMError.h" //"../../VMError.h"

#include "kissFFTConfig.h"


enum{
	
	// TerraIx local Output events
//	O_INIT			=0,
	O_CUSTOM_A		=20,
	O_CUSTOM		=23,
	// TerraIx Custom Output events

	// TerraIx Local Input events
//	I_ERROR_id		=0,  // Defined in VMError.h
//	I_ERROR			=1,  // Defined in VMError.h
	I_CUSTOM_A_ID	=12,
	I_CUSTOM_A		=13,
	I_CUSTOM		=15,
	// TerraIx Custom Input events
	
	// TerraIx basic functions
	F_GETNODEID 	= 0,
	F_RANDOM		= 1,
	F_GETMEM		= 2,
	F_GETTIME		= 3,
	// TerraIx custom functions

	
	// Event Type ID - 3 msb bits of EvtId
	TID_SENSOR_DONE = 0 << 5,
	TID_TIMER_TRIGGER = 1 << 5,
	TID_MSG_DONE = 2 << 5,
	TID_MSG_REC = 3 << 5,
	
	// Sensor IDs (max 31)
	SENSOR_COUNT = 0,
	
};


#endif /* VMCUSTOM_H */
