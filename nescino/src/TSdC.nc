
#include "InoPins.h"
module TSdC{
	uses interface Boot;
	uses interface Timer<TMilli> as Timer;
	uses {
		interface UartStream as Uart0;
		interface StdControl as Uart0Ctl;
		interface Queue<uint8_t> as LogQ;  
	}
	uses interface SdIO;
	uses interface SplitControl as SdControl;
	uses interface InoIO;
	
}
implementation{


	uint8_t readBuff[512];
	uint8_t logData[200];
	
	
	/**
	 * Queue Control to write to USB0 -- logS()
	 */
  #define LOG_BUFFER_LEN 100
  uint8_t logBuffer[LOG_BUFFER_LEN];
  uint8_t logIdx;
  uint8_t logLen;
  uint8_t logIdle;
	task void logProc(){
  	uint8_t logByte;
	if (call LogQ.size() > 0) {
		logIdle=FALSE;
		logByte = call LogQ.dequeue();
		call Uart0.send(&logByte, 1);
		//call Uart0.send("X", 1);
  	} else
  		logIdle = TRUE;
  }

	async event void Uart0.sendDone(uint8_t *buf, uint16_t len, error_t error){
		post logProc();
	}

  void logS(uint8_t* logMsg, uint8_t len){
  	uint8_t idx;
  	for (idx=0; idx<len;idx++) call LogQ.enqueue(logMsg[idx]);
  	if (logIdle) post logProc();
  }

  void int2Dec(uint8_t *data, uint32_t value, uint8_t bytelen){
	uint8_t i;
	uint32_t dig=1;
	for (i=1; i<=bytelen; i++){
		data[bytelen-i]='0'+(value%(dig*10)/dig);
		dig = dig*10;
		}
  }

    uint8_t d2h(uint8_t dig){
    	if (dig < 10) return ('0'+dig);
    	switch (dig){
    		case 10:  return 'A';
    		case 11:  return 'B';
    		case 12:  return 'C';
    		case 13:  return 'D';
    		case 14:  return 'E';
    		case 15:  return 'F';
    	}
    	return 'X';
    }

  uint8_t* buf2Hex(uint8_t *dataOut, uint8_t *dataIn, uint8_t inlen){
	uint8_t i;
	for (i=0; i<inlen; i++){
		dataOut[2*i]   = d2h(dataIn[i]>>4);
		dataOut[2*i+1] = d2h(dataIn[i]%16);
		}
	return dataOut;
  }	
	async event void Uart0.receiveDone(uint8_t *buf, uint16_t len, error_t error){}
	async event void Uart0.receivedByte(uint8_t byte){}

/*********************************************
 * Program
 */

#include "InoPins.h"
bool wr=FALSE;
  event void Boot.booted()
  {
  	  uint8_t i;
  	  logIdx=0; logLen=0; logIdle=TRUE;
  	  
  	  call Uart0Ctl.start();
      call Timer.startOneShot(1000);
      logS("ProgInit\n",9);
      call InoIO.interruptFallingEdge(I0);
  }

uint32_t block=0;
	event void Timer.fired(){
	  error_t stat;
	  block++;
      logS("SDStart:",8);
  	  stat = call SdControl.start();
	  logData[0]='0'+stat;
	  logData[1]=':';
	  logS(logData,2);
      call Timer.startOneShot(2000);
	}

	event void SdControl.startDone(error_t error){
	  uint16_t count;
	  error_t stat;
	  double cardSize;
	  int2Dec(logData,error,3);
	  logData[3]='\n';
	  logS(logData,4);
	  if (!wr){
	  	  wr=TRUE;
	      logS("SDWrite:",8);
	      for (count=0;count<512;count++) readBuff[count]=(count%2==0)?0x55:0xAA;
	  	  stat = call SdIO.writeBlock(3, readBuff);
		  int2Dec(logData,stat,3);
		  logData[3]='\n';
		  logS(logData,4);
	  	  call SdControl.stop();
	  } else {
	      logS("SDRead:",7);
	      stat = call SdIO.readData(block, 0, 32, readBuff);
	//	  int2Dec(logData,call SdIO.errorCode(),3);
		  int2Dec(logData,stat,3);
		  logData[3]='\n';
		  logS(logData,4);
	//	  cardSize = call SdIO.cardSize()*512.0/1000000.0;
	//	  int2Dec(logData,(uint16_t)cardSize,5);
	//	  logData[5]='\n';
	//	  logS(logData,6);
	  	  call SdControl.stop();
		  logS(buf2Hex(logData,readBuff,32),64);
		  logS("\n",1);
	  }
	}


	event void SdControl.stopDone(error_t error){
      logS("SDStop\n",7);
	}



	event void InoIO.analogReadDone(analog_enum pin, uint16_t value){
		// TODO Auto-generated method stub
	}

	event void InoIO.pulseLen(interrupt_enum intPin, pinvalue_enum value, uint32_t len){
		// TODO Auto-generated method stub
	}

	event void InoIO.interruptFired(interrupt_enum intPin){
		logS(".",1);		
	}
}