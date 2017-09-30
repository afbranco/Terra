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

// Analog Ref IDs
#define AN_DEFAULT 0
#define AN_INTERNAL1V1 1
#define AN_INTERNAL2V56 2
#define AN_EXTERNAL 3

enum{
	
	// TerraIno local Output events
//	O_INIT			=0,	
	O_LEDS			=5,
	O_LED0			=6,
	O_LED1			=7,
	O_LED2			=8,
	O_TEMP			=9,
	O_DHT			=10,
	O_CUSTOM_A		=20,
	O_CUSTOM		=23,
	
	O_ANA0_READ		=30,
	O_ANA1_READ		=31,
	O_ANA2_READ		=32,
	O_ANA3_READ		=33,
	// TerraNet Custom Output events
	O_SEND			=40,
	O_SEND_ACK		=41,




	// TerraNet Local Input events
//	I_ERROR_id		=0,  // Defined in VMError.h
//	I_ERROR			=1,  // Defined in VMError.h
	I_TEMP			=5,
	I_DHT			=6,
	
	I_CUSTOM_A_ID	=12,
	I_CUSTOM_A		=13,
	I_CUSTOM		=15,
	// Ino EVents
	I_ANA_READ_DONE_ID 	= 20,
	I_ANA_READ_DONE 	= 21,
	I_INT_FIRED			= 22,
	I_PCINT_FIRED		= 23,
	
	I_ANA0_READ_DONE	= 30,
	I_ANA1_READ_DONE	= 31,
	I_ANA2_READ_DONE	= 32,
	I_ANA3_READ_DONE	= 33,
	
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
	F_PIN_WRITE 		= 21,
	F_PIN_READ 			= 22,
	F_PIN_TOGGLE 		= 23,
	F_PORT_DDR			= 24,
	F_PORT_WRITE		= 25,
	F_PORT_READ			= 26,

	F_INT_ENABLE 		= 30,
	F_INT_DISABLE 		= 31,
	F_INT_CLEAR 		= 32,
	F_INT_CONFIG 		= 33,
	F_PCINT_ENABLE 		= 34,
	F_PCINT_DISABLE 	= 35,
	F_PCINT_CLEAR 		= 36,
	F_PCINT_MASK 		= 37,

	// Event Type ID - 3 msb bits of EvtId
	TID_SENSOR_DONE = 0 << 5,
	TID_TIMER_TRIGGER = 1 << 5,
	TID_MSG_DONE = 2 << 5,
	TID_MSG_REC = 3 << 5,

	// Sensor IDs (max 31)
	SENSOR_COUNT = 0,	
	
	// PORTs and PINs
	_portA	= 0,
	_portB	= 1,
	_portC	= 2,
	_portD	= 3,
	_portE	= 4,
	_portF	= 5,
	_portG	= 6,
	_portH	= 7,
	_portJ	= 8,
	_portK	= 9,
	_portL	= 10,
	
};

typedef nx_struct qData{
	nx_uint8_t id;
	nx_uint8_t data[SEND_DATA_SIZE];
	nx_uint8_t len;
} qData_t;


#endif /* VMCUSTOM_H */



