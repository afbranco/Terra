/***********************************************
 * TerraVM - Terra virtual machine project
 * September, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#ifndef VMCUSTOM_H
#define VMCUSTOM_H

#include "VMData.h" //"../../VMData.h"
#include "VMError.h" //"../../VMError.h"

enum{
	
	// TerraIno local Output events
//	O_INIT			=0,	
	O_LEDS			=5,
	O_LED0			=6,
	O_LED1			=7,
	O_LED2			=8,
	O_TEMP			=9,
	O_CUSTOM_A		=20,
	O_CUSTOM		=23,
	
	O_ANA0_READ		=30,
	// TerraNet Custom Output events
	O_SEND			=40,
	O_SEND_ACK		=41,




	// TerraNet Local Input events
//	I_ERROR_id		=0,  // Defined in VMError.h
//	I_ERROR			=1,  // Defined in VMError.h
	I_TEMP			=5,
	
	I_CUSTOM_A_ID	=12,
	I_CUSTOM_A		=13,
	I_CUSTOM		=15,
	// Ino EVents
	I_ANA_READ_DONE_ID 	= 20,
	I_ANA_READ_DONE 	= 21,
	I_INT_FIRED_ID		= 22,
	I_INT_FIRED			= 23,
	I_PULSE_LEN_ID 		= 24,
	I_PULSE_LEN 		= 25,
	
	I_ANA0_READ_DONE	= 30,
	
	// TerraNet Custom Input events
	I_SEND_DONE_ID		=40,
	I_SEND_DONE			=41,
	I_SEND_DONE_ACK_ID	=42,
	I_SEND_DONE_ACK		=43,
	I_RECEIVE_ID		=44,
	I_RECEIVE			=45,
	I_Q_READY 			=46,
	
	// Terra basic functions
	F_GETNODEID 	= 0,
	F_RANDOM		= 1,
	F_GETMEM		= 2,
	F_GETTIME		= 3,
	F_GETCLOCKMICRO	= 4,
	// Terra Queue custom functions
	F_QPUT 			= 10,
	F_QGET 			= 11,
	F_QSIZE 		= 12,
	F_QCLEAR 		= 13,
	F_SETRFPOWER	= 17,
	// TerraIno Specific custom functions
	F_PIN_MODE 			= 20,
	F_DIGITAL_WRITE 	= 21,
	F_DIGITAL_READ 		= 22,
	F_DIGITAL_TOGGLE 	= 23,
	F_ANALOG_REFERENCE 	= 24,
	F_ANALOG_READ 		= 25,
	F_INT_RISING_EDGE 	= 26,
	F_INT_FALLING_EDGE	= 27,
	F_INT_DISABLE 		= 28,
	F_PULSE_IN 			= 29,

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



