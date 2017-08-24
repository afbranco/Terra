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
generic module dataQueueP(typedef dataType, uint8_t qLenth, uint8_t qId){
	provides interface dataQueue;
}
implementation{
	
	bool flagFreeQ=TRUE;

	//Pool & Queue Data
	dataType qData[qLenth];
	uint8_t  qHead=0, qTail=0, qSize=0;
	dataType *pData;
	
	task void dataReady(){
		if (qSize > 0)
			signal  dataQueue.dataReady();
	}

	command error_t dataQueue.put(void* Data){
		dbg(APPNAME, "dataQ[%hhu]::put(). Size and FlagFree before %hhu : %s\n",qId,qSize,(flagFreeQ==TRUE)?"TRUE":"FALSE");
		// Test if the queue is full
		if (qSize >= qLenth) { 
			return FAIL;
		}
		// insert data		
		memcpy((void*)&qData[qTail], Data,sizeof(dataType));
		qTail++; qTail = (uint8_t)(qTail%qLenth);
		qSize++;
		if (flagFreeQ == TRUE) {
			flagFreeQ =FALSE; post dataReady();
			}
		return SUCCESS;
	}
	
	command error_t dataQueue.get(void *Data){
		dbg(APPNAME, "dataQ[%hhu]::get(%x[%d]). Size and FlagFree before %hhu : %s\n",qId,Data,sizeof(dataType),qSize,(flagFreeQ==TRUE)?"TRUE":"FALSE");
		// Test if the queue is empty
		if (qSize <= 0)	{ flagFreeQ = TRUE; return FAIL;}
		// get data		
		memcpy(Data,(void*)&qData[qHead],sizeof(dataType));
		qHead++; qHead = (uint8_t)(qHead%qLenth);
		qSize--;
		if (qSize<=0) flagFreeQ = TRUE;
		return SUCCESS;
	}	

	command error_t dataQueue.remove(){
		dbg(APPNAME, "dataQ[%hhu]::get()",qId);
		// Test if the queue is empty
		if (qSize <= 0)	{ flagFreeQ = TRUE; return FAIL;}
		// get data		
		qHead++; qHead = (uint8_t)(qHead%qLenth);
		qSize--;
		if (qSize<=0) flagFreeQ = TRUE;
		return SUCCESS;
	}

	command error_t dataQueue.read(void *Data){
		dbg(APPNAME, "dataQ[%hhu]::read(). Size and FlagFree before %hhu : %s\n",qId,qSize,(flagFreeQ==TRUE)?"TRUE":"FALSE");
		// Test if the queue is empty
		if (qSize <= 0)	return FAIL;
		// read data		
		memcpy(Data,(void*)&qData[qHead],sizeof(dataType));
		return SUCCESS;
	}


	command uint8_t dataQueue.size(){
//		dbg(APPNAME, "dataQ::size(%hhu)\n",qSize);
		return qSize;
	}
	command uint8_t dataQueue.maxSize(){
//		dbg(APPNAME, "dataQ::size(%hhu)\n",qSize);
		return qLenth;
	}

	command bool dataQueue.isFree(){
//		dbg(APPNAME, "dataQ::isFree().\n");
		return flagFreeQ;
	}

	command error_t dataQueue.clearAll(){
		qHead=0; 
		qTail=0; 
		qSize=0;
		flagFreeQ=TRUE;
		return SUCCESS;
	}

	command error_t dataQueue.element(uint8_t id, void* Data){
		dbg(APPNAME, "dataQ[%hhu]::element(%hhu)",qId,id);
		// Test if the id exists
		if (id >= qSize) return FAIL;
		// read data		
		memcpy(Data,(void*)&qData[id],sizeof(dataType));
		return SUCCESS;
	}

}