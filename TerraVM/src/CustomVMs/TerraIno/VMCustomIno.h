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

#include "kissFFTConfig.h"

enum{
	
	// TerraIno local Output events
//	O_INIT			=0,
	
	O_CUSTOM_A		=20,
	// TerraNet Custom Output events
	O_SEND			=40,
	O_SEND_ACK		=41,
	// Volcano Output event
	O_RD_STREAM		=50,

	// TerraNet Local Input events
//	I_ERROR_id		=0,  // Defined in VMError.h
//	I_ERROR			=1,  // Defined in VMError.h
	I_CUSTOM_A_ID 		= 10,
	I_CUSTOM_A 			= 11,
	
	// Ino EVents
	I_ANA_READ_DONE_ID 	= 20,
	I_ANA_READ_DONE 	= 21,
	I_INT_FIRED_ID		= 22,
	I_INT_FIRED			= 23,
	I_PULSE_LEN_ID 		= 24,
	I_PULSE_LEN 		= 25,	
	// TerraNet Custom Input events
	I_SEND_DONE_ID		=40,
	I_SEND_DONE			=41,
	I_SEND_DONE_ACK_ID	=42,
	I_SEND_DONE_ACK		=43,
	I_RECEIVE_ID		=44,
	I_RECEIVE			=45,
	I_Q_READY 			=46,
	// Volcano Input events
	I_GMODEL_RD_DONE 	=50,
	I_STREAM_RD_DONE	=51,
	
	// Terra basic functions
	F_GETNODEID 	= 0,
	F_RANDOM		= 1,
	// Terra Queue custom functions
	F_QPUT 			= 10,
	F_QGET 			= 11,
	F_QSIZE 		= 12,
	F_QCLEAR 		= 13,
	F_FFT_ALLOC 	= 14,
	F_FFT 			= 15,
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
	F_LOGS 				= 30,
	// Volcano custom functions
	F_GMODEL_READ	= 50,
	F_GET_RTIME		= 51,
	F_SET_RTIME		= 52,
	F_GET_NSAMPLES	= 53,
	F_DETECT		= 54,
	
	// GModel internal constants
	GMODEL_SIZE = (8*FEATURE_DIM) + 4  + ((8*MS_GAUSS_SCALES)*(1 + FEATURE_DIM)),
	

	// Event Type ID - 3 msb bits of EvtId
	TID_SENSOR_DONE = 0 << 5,
	TID_TIMER_TRIGGER = 1 << 5,
	TID_MSG_DONE = 2 << 5,
	TID_MSG_REC = 3 << 5,
	
	
};

typedef nx_struct qData{
	nx_uint8_t id;
	nx_uint8_t data[SEND_DATA_SIZE];
	nx_uint8_t len;
} qData_t;


#endif /* VMCUSTOM_H */
