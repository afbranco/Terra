/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#ifndef VMCUSTOM_H
#define VMCUSTOM_H

#include "../../VMData.h"
#include "../../VMError.h"


enum{
	
	// TerraNet local Output events
	O_INIT			=0,
	O_LEDS			=5,
	O_LED0			=6,
	O_LED1			=7,
	O_LED2			=8,
	O_TEMP			=9,
	O_PHOTO			=10,
	O_VOLTS			=22,
	O_PORT_A		=12,
	O_PORT_B		=13,
	O_CFG_PORT_A	=14,
	O_CFG_PORT_B	=15,
	O_REQ_PORT_A	=16,
	O_REQ_PORT_B	=17,
	O_CFG_INT_A		=18,
	O_CFG_INT_B		=19,
	O_CUSTOM_A		=20,	
	// TerraNet Custom Output events
	O_SEND			=40,
	O_SEND_ACK		=41,


	// TerraNet Local Input events
//	I_ERROR_id		=0,  // Defined in VMError.h
//	I_ERROR			=1,  // Defined in VMError.h
	I_TEMP			=5, 
	I_PHOTO			=6,
	I_VOLTS			=7,
	I_PORT_A		=8,
	I_PORT_B		=9,
	I_INT_A			=10,
	I_INT_B			=11,
	I_CUSTOM_A_ID	=12,
	I_CUSTOM_A		=13,
	// TerraNet Custom Input events
	I_SEND_DONE_ID		=40,
	I_SEND_DONE			=41,
	I_SEND_DONE_ACK_ID	=42,
	I_SEND_DONE_ACK		=43,
	I_RECEIVE_ID		=44,
	I_RECEIVE			=45,
	I_Q_READY 			=46,

	
	// TerraNet basic functions
	F_GETNODEID 	= 0,
	F_RANDOM		= 1,
	// TerraNet custom functions
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
	SENSOR_COUNT = 8,
	SID_TEMP = 1,
	SID_PHOTO = 2,
	SID_LEDS = 3,
	SID_VOLT = 4,
	SID_IN1 = 5,
	SID_IN2 = 6,
	SID_INT1 = 7,
	SID_INT2 = 8,
	
	// Sensor control BIT (Identify request sources) max=4 - 0..3)
	SENSOR_CTL_BIT = 6,
	REQ_SOURCE1 = 0,	// Used for VM requests
	REQ_SOURCE2 = 1,	// TDB
	REQ_SOURCE3 = 2,	// TDB
	REQ_SOURCE4 = 3,	// TDB
	
	// Actuator IDs (max 31)
	AID_LEDS = 1,
	AID_LED0 = 2,
	AID_LED1 = 3,
	AID_LED2 = 4,
	AID_LED0_TOGGLE = 5,
	AID_LED1_TOGGLE = 6,
	AID_LED2_TOGGLE = 7,
	AID_OUT1 = 8,
	AID_OUT2 = 9,
	AID_PIN1 =10,
	AID_PIN2 =11,
	AID_INT1 =12,
	AID_INT2 =13,
	
};

typedef nx_struct qData{
	nx_uint8_t id;
	nx_uint8_t data[SEND_DATA_SIZE];
	nx_uint8_t len;
} qData_t;


#endif /* VMCUSTOM_H */
