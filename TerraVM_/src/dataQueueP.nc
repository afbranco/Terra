#ifndef NO_DEBUG
#endif

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