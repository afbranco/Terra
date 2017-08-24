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
#ifndef AM_H
#define AM_H

// These are the right types, but ncc currently does not 
// like parameters being network types
typedef nx_uint8_t nx_am_id_t;
typedef nx_uint8_t nx_am_group_t;
typedef nx_uint16_t nx_am_addr_t;

typedef uint8_t am_id_t;
typedef uint8_t am_group_t;
typedef uint16_t am_addr_t;

enum {
  AM_BROADCAST_ADDR = 0xffff,
};

#ifndef DEFINED_TOS_AM_GROUP
#define DEFINED_TOS_AM_GROUP 0x22
#endif

#ifndef DEFINED_TOS_AM_ADDRESS
#define DEFINED_TOS_AM_ADDRESS 1
#endif

enum {
  TOS_AM_GROUP = DEFINED_TOS_AM_GROUP,
  TOS_AM_ADDRESS = DEFINED_TOS_AM_ADDRESS
};

#define UQ_AMQUEUE_SEND "amqueue.send"

#endif

