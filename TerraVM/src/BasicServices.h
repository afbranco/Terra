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
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#ifndef BASIC_SERVICES_H
#define BASIC_SERVICES_H

#include "VMData.h"

enum{
/*
 * AM_ID definitions for each message, used in TinyOS events dispatcher.
 */
	AM_NEWPROGVERSION 	= 160,
	AM_NEWPROGBLOCK 	= 161,
	AM_REQPROGBLOCK 	= 162,
	AM_SETDATAND 		= 131,
	AM_REQDATA 			= 132,
	AM_PINGMSG			= 133,

	AM_CUSTOM_START		= 140,
	AM_CUSTOM_END		= 149,
	AM_CUSTOM_0			= 140,
	AM_CUSTOM_1			= 141,
	AM_CUSTOM_2			= 142,
	AM_CUSTOM_3			= 143,
	AM_CUSTOM_4			= 144,
	AM_CUSTOM_5			= 145,
	AM_CUSTOM_6			= 146,
	AM_CUSTOM_7			= 147,
	AM_CUSTOM_8			= 148,
	AM_CUSTOM_9			= 149,

#ifdef MODULE_CTP
	AM_SENDBS = 150,
#endif
	AM_RESERVED_END = 127,

	// Send message control
	RESEND_DELAY = 20L,
	SEND_TIMEOUT = 1000L,
	MAX_SEND_RETRIES = 5,

	// Request data/prog timeout
#ifdef TOSSIM
	REQUEST_TIMEOUT = 800L,
	REQUEST_TIMEOUT_BS =  800L,
#else
	REQUEST_TIMEOUT = 500L,
	REQUEST_TIMEOUT_BS =  500L,
#endif
	REQUEST_VERY_LONG_TIMEOUT =600000L,
	DISSEMINATION_TIMEOUT = 300L,

#ifdef SHORT_QUEUES
	// Queues and Lists Size
#ifdef M_FFT
	IN_QSIZE  = 2,//5,
	OUT_QSIZE = 3,//10,//10, //6
#elif defined(INOS)
	IN_QSIZE  = 1,//5,
	OUT_QSIZE = 1,//10,//10, //6
#else
	IN_QSIZE  = 5,
	OUT_QSIZE = 10,//10, //6
#endif
#else
	// Queues and Lists Size
	IN_QSIZE  = 10,
	OUT_QSIZE = 20,//10, //6
#endif


	// SetData last commands list size
	SET_DATA_LIST_SIZE = 5,

	// Request data/prog states
	ST_IDLE = 1,		// Passive state. Not requesting or disseminating
	ST_WAIT_PROG_VER = 2,	// Prog.Version requested
	ST_WAIT_PROG_BLK = 3,	// Prog.block requested
	ST_WAIT_DATA = 4,	// Data requested
	ST_DSM_PROG = 5,	// Disseminating program blocks

	// Request program version/data operation
	RO_NEW_VERSION = 1,
	RO_DATA_FULL = 2,
	RO_DATA_SINGLE = 3,
	RO_IDLE = 4,

	// Ack & Retry bits
	REQ_ACK_BIT   = 0,
	REQ_RETRY_BIT = 1,

#ifdef LPL_ON
/**
 * SLEEP indica quanto tempo em mili-segundos o radio ficara dormindo.
 */
#ifndef SLEEP
#define SLEEP 90
#endif

#endif //LPL_ON
	
};

#ifndef RFPOWER_IDX
#define RFPOWER_IDX 3
#endif

#define RFPower_IDs 8

/**
 * Msg structures
 */
 
typedef nx_struct newProgVersion{
	nx_uint8_t  moteType;		// Hardware/Firmware type. Distinguishes different types of motes
	nx_uint16_t versionId; 		// Version ID
	nx_uint16_t blockLen; 		// Number of program blocks
	nx_uint16_t blockStart; 	// first block
	nx_uint16_t startProg; 		// Start prog addr. 
	nx_uint16_t endProg; 		// End prog addr. 
	nx_uint16_t nTracks; 		// Tracks number
	nx_uint16_t wClocks; 		// Clocks number
	nx_uint16_t asyncs; 		// Asyncs number
	nx_uint16_t wClock0; 		// Clock0 addr
	nx_uint16_t gate0;	 		// Gate0 addr
	nx_uint16_t inEvts;	 		// In Evts number
	nx_uint16_t async0;	 		// Async0 addr
	nx_uint16_t appSize;	 	// Application size in bytes. Used to check against VM memory size.
	nx_uint8_t  persistFlag;	// If TRUE it will backup the script into internal persistent memory
} newProgVersion_t;	
	
typedef nx_struct newProgBlock{	
	nx_uint8_t  moteType;		// Hardware/Firmware type. Distinguishes different types of motes
	nx_uint16_t versionId; // Version ID
	nx_uint16_t blockId; // Block number
	nx_uint8_t data[BLOCK_SIZE]; // Data buffer
} newProgBlock_t;	
	
typedef nx_struct reqProgBlock{	
	nx_uint8_t reqOper; 	// Request operation: Request newVersion, full data or single data
	nx_uint8_t  moteType;	// Hardware/Firmware type. Distinguishes different types of motes
	nx_uint16_t versionId; 	// Version ID
	nx_uint16_t blockId; 	// Block number
} reqProgBlock_t;	

	
typedef nx_struct setDataND{	
	nx_uint16_t versionId; // Version ID
	nx_uint16_t seq; // serial number
	nx_uint16_t targetMote; // To a specific target mote
	nx_uint8_t nSections; // Number of Sections
	nx_int8_t Data[SET_DATA_SIZE]; // Data buffer (max length = 18)
} setDataND_t;	

typedef nx_struct reqData{	
	nx_uint16_t versionId; // Version ID
	nx_uint16_t seq; // serial number
} reqData_t;	

typedef nx_struct setDataBuffer{	
	nx_uint16_t versionId; // Version ID
	nx_uint16_t seq; // serial number
	nx_uint8_t AM_ID; // Msg type: GR or ND
	nx_uint8_t buffer[MSG_BUFF_SIZE];
} setDataBuff_t;	

typedef nx_struct sendBS{	
	// CTP  
	nx_uint16_t Sender; 
	nx_uint16_t seq; 
	// Msg Definition  
	nx_uint8_t  evtId; // Event ID
	nx_int8_t  Data[SEND_DATA_SIZE]; // Data buffer
} sendBS_t;	

typedef nx_struct GenericData {
	nx_uint8_t AM_ID;
	nx_uint8_t DataSize;
	nx_uint16_t sendToMote;
	nx_uint8_t fromSerial;
	nx_uint8_t reqAck;
	nx_uint8_t RFPower;
	nx_uint8_t Data[MSG_BUFF_SIZE];
} GenericData_t;

typedef nx_struct ctpMsg {
	nx_uint8_t  data[MSG_BUFF_SIZE];
} ctpMsg_t;


#endif /* BASIC_SERVICES_H */
