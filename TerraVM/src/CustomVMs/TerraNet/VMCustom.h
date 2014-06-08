/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#ifndef VMCUSTOM_H
#define VMCUSTOM_H

#include "../../VMData.h"

enum{
	// CEU Event IDs - OUT
	INIT=0,
	LEDS=1,
	LED0=2,
	LED1=3,
	LED2=4,
	REQ_TEMP=5,
	REQ_PHOTO=6,
	REQ_VOLTS=7,
	SEND=8,
	SEND_ACK=9,
	SET_PORT_A=10,
	SET_PORT_B=11,
	CFG_PORT_A=12,
	CFG_PORT_B=13,
	REQ_PORT_A=14,
	REQ_PORT_B=15,
	CFG_INT_A=16,
	CFG_INT_B=17,
	REQ_CUSTOM_A=18,
	Q_PUT = 19,
	Q_GET = 20,
	Q_SIZE = 21,
	Q_CLEAR = 22,
	

	// CEU Event IDs - IN	
	TEMP=0,
	PHOTO=1,
	VOLTS=2,
	SEND_DONE=3,
	SEND_DONE_ACK=4,
	RECEIVE=5,
	Q_READY =6,
	PORT_A=7,
	PORT_B=8,
	INT_A=9,
	INT_B=10,
	CUSTOM_A=11,
	
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
