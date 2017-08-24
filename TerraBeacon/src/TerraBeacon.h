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
#ifndef TERRA_BEACON_H
#define TERRA_BEACON_H

enum {
	// Terra msg type/id
	BEACON_A_MSG_ID=128, // Temperature, SourceId,  Seq
	BEACON_B_MSG_ID=129,
	BEACON_C_MSG_ID=130,
	BEACON_PARENT_MSG_ID = 150,
	// System message AM ID
	DATA_MSG_AMID=145,
	AM_USRMSG = 145,	
	
//	BEACON_PERIOD = 5*60*1000,
	BEACON_PERIOD = 20*1000,
	RESEND_DELAY = 20L,
	MAX_SEND_RETRIES = 3,
	
};

typedef nx_struct terra_data{
	nx_uint8_t type;
	nx_uint16_t source;
	nx_uint16_t target;

	nx_uint8_t  d8[4];
	nx_uint16_t d16[4];
	nx_uint32_t d32[2];
	
} terra_data_t;

/*
	nx_uint8_t  id;
	nx_uint16_t	nodeId;
	nx_uint16_t	target;

 	nx_uint8_t  seq;
	nx_uint8_t  node_id;
	nx_uint8_t  retries;
	nx_uint8_t  xxx3;
	nx_uint16_t	temp;
	nx_uint16_t	volt;
	nx_uint16_t yyy[2];
 */
#endif /* TERRA_BEACON_H */
