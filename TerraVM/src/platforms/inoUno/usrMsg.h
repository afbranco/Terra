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
 /*
  * Include file to define only user message structure and AM_ID
  */
#ifndef USR_MSG_H
#define USR_MSG_H
#include "VMData.h"

enum{
USRMSG_QSIZE = 10,
AM_USRMSG = 145,

};

typedef nx_struct usrMsg {
	nx_uint8_t type;
	nx_uint16_t source;
	nx_uint16_t target;
	nx_uint8_t data[SEND_DATA_SIZE];
} usrMsg_t;

#endif /* USR_MSG_H */
