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
module RPI_InternalFlashP{
	provides interface InternalFlash as IntFlash;
}
implementation{

	FILE* getFD(char* mode){
		char fname[80];
		sprintf(fname,"Terra_ProgStorage_%d.bin",TOS_NODE_ID);
		return fopen(fname,mode);
		}

	command error_t IntFlash.read( void* addr, void *buf, uint16_t size){
		FILE* fd;
		error_t stat;
		dbg(APPNAME,"IntFlash.read(): addr=%d, size=%d\n",(uint32_t)addr,size);
		fd = getFD("r");
		if (fd == NULL) return FAIL;
		stat = fread(buf,size,1,fd);
		if (stat != SUCCESS) return FAIL;
		return SUCCESS;
	}

	command error_t IntFlash.write(void* addr, void *buf, uint16_t size){
		FILE* fd;
		error_t stat;
		dbg(APPNAME,"IntFlash.write(): addr=%d, size=%d\n",(uint32_t)addr,size);
		fd = getFD("w");
		if (fd == NULL) return FAIL;
		stat = fwrite(buf,size,1,fd);
		if (stat != SUCCESS) return FAIL;
		return SUCCESS;
	}
}