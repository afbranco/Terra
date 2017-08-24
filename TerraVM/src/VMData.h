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

#ifndef VMDATA_H
#define VMDATA_H

#define APPNAME "terra"


enum{

	MSG_BUFF_SIZE = 28,
	BLOCK_SIZE = 22, // Must be conform to newProgBlock data structure
	SET_DATA_SIZE = 18, // Must be conform to setDataGR data structure
	SENDGR_DATA_SIZE = 16, // Must be conform to sendDataGR data structure
	SEND_DATA_SIZE = 22, // Must be conform to usrMsg_t data structure

#ifdef VM_MEM_BLKS
	CURRENT_MAX_BLOCKS = VM_MEM_BLKS, // Max memory (in blocks of BLOCK_SIZE) allocated for VM script/data - Defined from Makefile
#else
	CURRENT_MAX_BLOCKS = 24,
#endif

#ifdef GENERAL_MAX__BLKS
	GENERAL_MAX_BLOCKS = GENERAL_MAX__BLKS, // Max memory (in blocks of BLOCK_SIZE) allocated for VM script/data - Defined from Makefile
#else
	GENERAL_MAX_BLOCKS = 100,
#endif
		
};

/***
 * Env and Storage  structures
 * 
 */
typedef struct progEnv {
	// Ceu Environment vars
	uint16_t Version;
	uint16_t ProgStart;
	uint16_t ProgEnd;
	uint16_t nTracks;
	uint16_t wClocks;
	uint16_t asyncs;
	uint16_t wClock0;	
	uint16_t gate0;	
	uint16_t inEvts;	
	uint16_t async0;	
	uint16_t appSize;
	uint8_t  persistFlag;	
} progEnv_t;

#endif /* VMDATA_H */
