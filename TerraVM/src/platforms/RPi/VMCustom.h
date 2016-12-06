
#ifndef VMCUSTOM_H
#define VMCUSTOM_H

#include "VMData.h" //"../../VMData.h"
#include "VMError.h" //"../../VMError.h"


enum{
	
	// TerraIx local Output events
//	O_INIT			=0,
	O_CUSTOM_A		=20,
	O_CUSTOM		=23,
	// TerraIx Custom Output events
	O_SEND			=40,
	O_SEND_ACK		=41,

	// TerraIx Local Input events
//	I_ERROR_id		=0,  // Defined in VMError.h
//	I_ERROR			=1,  // Defined in VMError.h
	I_CUSTOM_A_ID	=12,
	I_CUSTOM_A		=13,
	I_CUSTOM		=15,
	// TerraIx Custom Input events
	I_SEND_DONE_ID		=40,
	I_SEND_DONE			=41,
	I_SEND_DONE_ACK_ID	=42,
	I_SEND_DONE_ACK		=43,
	I_RECEIVE_ID		=44,
	I_RECEIVE			=45,
	I_Q_READY 			=46,
	
	// TerraIx basic functions
	F_GETNODEID 	= 0,
	F_RANDOM		= 1,
	F_GETMEM		= 2,
	F_GETTIME		= 3,
	// TerraIx custom functions
	F_QPUT 			= 10,
	F_QGET 			= 11,
	F_QSIZE 		= 12,
	F_QCLEAR 		= 13,

	
	// Event Type ID - 3 msb bits of EvtId
	TID_SENSOR_DONE = 0 << 5,
	TID_TIMER_TRIGGER = 1 << 5,
	TID_MSG_DONE = 2 << 5,
	TID_MSG_REC = 3 << 5,
	
	// Sensor IDs (max 31)
	SENSOR_COUNT = 0,
	
};


typedef nx_struct qData{
	nx_uint8_t id;
	nx_uint8_t data[SEND_DATA_SIZE];
	nx_uint8_t len;
} qData_t;


#endif /* VMCUSTOM_H */
