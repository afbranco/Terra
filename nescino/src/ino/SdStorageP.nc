generic module SdStorageP(uint32_t startBlk, uint32_t maxBlk){
	provides interface SdStorage;
	uses{
		interface SdIO;
		interface SplitControl as Control;
	}
}
implementation{

	typedef enum { FREE, READING, WRITING, ERASING } oper_t ;
	oper_t currOper = FREE;

	// Original request parameters
	uint32_t reqAddr;
	void *reqBuf;
	uint32_t reqLen;

	// Current Operation parameters
	uint32_t currBlk;
	uint16_t currOffSet;
	uint32_t currPending;
	uint8_t* currBufPointer;
	error_t currStatus;

	task void rdNext(){
		uint16_t count = (currPending > (512 - currOffSet))?(512 - currOffSet):currPending;
		if (call SdIO.readData(currBlk, currOffSet, count, currBufPointer)){
			currPending -= count;
			if (currPending>0){
				currBufPointer = currBufPointer+count;
				currOffSet=0;
				currBlk++;
				post rdNext();
			} else {
				currStatus = SUCCESS;
				call Control.stop();
			}
		} else {
			currStatus = FAIL;
			call Control.stop();
		}		
	}
	
	task void wrNext(){
		uint8_t wrBuff[512];
		uint16_t count = (currPending > (512 - currOffSet))?(512 - currOffSet):currPending;
		if (count < 512){
			if (!call SdIO.readData(currBlk, 0, 512, wrBuff)){
				currStatus = FAIL;
				call Control.stop();			
			}
		}
		memcpy(wrBuff+currOffSet,currBufPointer, count);
		if (call SdIO.writeBlock(currBlk, wrBuff)){
			currPending -= count;
			if (currPending>0){
				currBufPointer = currBufPointer+count;
				currOffSet=0;
				currBlk++;
				post wrNext();
			} else {
				currStatus = SUCCESS;
				call Control.stop();
			}
		} else {
			//currStatus = FAIL;
			//currStatus = currBlk;
			currStatus = call SdIO.errorCode();
			call Control.stop();
		}			
	}

	task void erase(){
		if (call SdIO.erase(startBlk, startBlk+maxBlk-1)){
			currStatus = SUCCESS;
		} else {
			currStatus = FAIL;
		}
		call Control.stop();		
	}

	event void Control.startDone(error_t error){
		currBlk = startBlk + (reqAddr>>9);
		currOffSet = reqAddr & 0x01ff;
		currPending = reqLen;
		currBufPointer = reqBuf;
		switch (currOper){
			case READING : post rdNext(); break;
			case WRITING : post wrNext(); break;
			case ERASING : post erase(); break;
			case FREE    : call Control.stop(); break;
		}

	}

	command error_t SdStorage.read(uint32_t addr, void *buf, uint32_t len){
		if (currOper!=FREE) return EBUSY;
		if (((addr+len)>>9) > maxBlk) return ESIZE;
		currOper = READING;
		reqAddr=addr;
		reqBuf=buf;
		reqLen=len;
		return call Control.start();
	}

	command error_t SdStorage.write(uint32_t addr, void *buf, uint32_t len){
		if (currOper!=FREE) return EBUSY;
		if (((addr+len)>>9) > maxBlk) return ESIZE; 
		currOper = WRITING;
		reqAddr=addr;
		reqBuf=buf;
		reqLen=len;
		return call Control.start();
	}

	event void Control.stopDone(error_t error){
		switch (currOper){
			case READING : signal SdStorage.readDone(reqAddr, reqBuf, reqLen, currStatus); break;
			case WRITING : signal SdStorage.writeDone(reqAddr, reqBuf, reqLen, currStatus); break;
			case ERASING : signal SdStorage.eraseDone(currStatus); break;
			case FREE    : break;
		}
		currOper=FREE;
	}

	command error_t SdStorage.erase(){
		if (currOper!=FREE) return EBUSY;
		currOper = ERASING;
		return call Control.start();
	}

	command uint32_t SdStorage.getSize(){
		return maxBlk*512;
	}
}
