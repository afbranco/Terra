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
#ifndef DHT_H
#define DHT_H


typedef enum dht_state {
	RESPONSE,
	DATA,
	ACQUIRED,
	STOPPED,
	ACQUIRING,
} dht_state_t;

#define IDDHTLIB_OK			0
#define IDDHTLIB_ACQUIRING		1
#define IDDHTLIB_ACQUIRED		2
#define IDDHTLIB_RESPONSE_OK	3

typedef enum dht_status {
	S_OK				= 0,
	S_ACQUIRING		= 1,
	S_ACQUIRED		= 2,
	S_RESPONSE_OK		= 3	
} dht_status_t;


typedef enum dht_error {
	E_CHECKSUM			= 1,
	E_ISR_TIMEOUT		= 2,
	E_RESPONSE_TIMEOUT	= 3,
	E_DATA_TIMEOUT		= 4,
	E_ACQUIRING	 		= 5,
	E_DELTA		 		= 6,
	E_NOTSTARTED		= 7,
	E_ISR_MISSING		= 8,
} dht_error_t;

enum int_mode {
	INT_LEVEL = 0,
	INT_TOGGLE = 1,
	INT_FALLING = 2,
	INT_RISING = 3
};

typedef nx_struct dhtData {
	nx_uint8_t stat;
	nx_uint8_t hum;
	nx_uint8_t temp;
} dhtData_t;



#endif /* DHT_H */
