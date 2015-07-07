#include "message.h"
module TSerialC{
  uses interface Boot;
  uses interface Timer<TMilli> as Timer;
  uses interface Timer<TMilli> as Timer2;
  uses interface Leds;
  
  uses interface InoIO;
  
  uses interface Queue<uint8_t> as LogQ;  


  uses {
  	interface UartStream as Uart0;
  	interface StdControl as Uart0Ctl;
  }
/*
  uses {
  	interface XBeeApi as Serial;
 }
*/


}
implementation{
	
  uint8_t logdata[50];
  message_t msg1;
  uint8_t divTimer=0;
  
  void logS(uint8_t* logMsg, uint8_t len);

  #define LOG_BUFFER_LEN 100
  uint8_t logBuffer[LOG_BUFFER_LEN];
  uint8_t logIdx;
  uint8_t logLen;
  uint8_t logIdle;
  uint8_t d2h(uint8_t dig);

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
  
  event void Boot.booted()
  {
  	  uint8_t i;
  	  logIdx=0; logLen=0; logIdle=TRUE;

  	  call Uart0Ctl.start();
      call Timer.startPeriodic(1000);
      call Leds.led0On();
	  for (i=0;i<10;i++) logdata[i] = 0x40 + i;
	  
      call InoIO.pinMode(D52, OUTPUT); //9
      call InoIO.pinMode(D22, OUTPUT); //0
	  call InoIO.pinMode(D53, INPUT_PULLUP); //8

      call Timer2.startPeriodic((1024L*1000L)/1024L);
//      call Timer2.startOneShot(500);
      
	  //call InoIO.interruptRisingEdge(I0);
      call InoIO.pulseIn(I0, HIGH, 200000);
      logdata[0]='$';
      logdata[1]='\n';
      logdata[2]='$';
      logS(logdata, 2);
      
  }

	event void Timer2.fired(){
//		divTimer++;
//      	call Timer2.startOneShot(500*((divTimer%4) + 1));
		call InoIO.digitalToggle(D22);
	}

 
	event void InoIO.interruptFired(interrupt_enum intPin){
		//if (intPin == I0) 
			call InoIO.digitalToggle(D52);
	}
  
  event void Timer.fired(){
      call Leds.led0Toggle();
      logdata[0]++;
      logS(logdata, 1);
//      msg1.data[0]='a';
//      msg1.data[1]='b';
//      msg1.data[2]++;
//      msg1.data[3]='\n';
//      call Serial.txReq(1, 0xffff, 0x00, (uint8_t*)&msg1, sizeof(message_t));

//      msg1.data[0]='C';
 //     msg1.data[1]='H';
//      call Serial.commandAT(1, msg1.data, NULL, 0);

		call InoIO.analogRead(A0);
  	}
  	


	event void InoIO.pulseLen(interrupt_enum intPin, pinvalue_enum value, uint32_t data){
	  {uint8_t sdata[50]; 
	  sdata[0]='0'+ (data/1000000000L)%10;
	  sdata[1]='0'+ (data/100000000L)%10;
	  sdata[2]='0'+ (data/10000000L)%10;
	  sdata[3]='0'+ (data/1000000L)%10;
	  sdata[4]='0'+ (data/100000L)%10;
	  sdata[5]='0'+ (data/10000L)%10;
	  sdata[6]='0'+ (data/1000L)%10;
	  sdata[7]='0'+ (data/100L)%10;
	  sdata[8]='0'+ (data/10L)%10;
	  sdata[9]='0'+ (data/1L)%10;
	  sdata[10]='#';
	  sdata[11]=d2h((intPin&0x000f)>>0);
	  sdata[12]='\n';
	  logS(sdata, 13);}
	  call InoIO.pulseIn(I0, LOW, 200000);
	}

    uint8_t d2h(uint8_t dig){
    	switch (dig){
    		case 0:  return '0';
    		case 1:  return '1';
    		case 2:  return '2';
    		case 3:  return '3';
    		case 4:  return '4';
    		case 5:  return '5';
    		case 6:  return '6';
    		case 7:  return '7';
    		case 8:  return '8';
    		case 9:  return '9';
    		case 10:  return 'A';
    		case 11:  return 'B';
    		case 12:  return 'C';
    		case 13:  return 'D';
    		case 14:  return 'E';
    		case 15:  return 'F';
    	}
    	return 'X';
    }


	
	event void InoIO.analogReadDone(analog_enum pin, uint16_t data){
	  {uint8_t sdata[50]; 
	  sdata[0]=d2h((data&0xf000)>>12);
	  sdata[1]=d2h((data&0x0f00)>>8);
	  sdata[2]=d2h((data&0x00f0)>>4);
	  sdata[3]=d2h((data&0x000f)>>0);
	  sdata[4]=':';
	  sdata[5]=d2h((pin&0x000f)>>0);
	  sdata[6]='\n';
//	  logS(sdata, 7);
	  }
	}




/*
	event void Serial.logUSB0(uint8_t *datax, uint8_t len){
		call Uart0.send(datax, len);
	}

	event void Serial.rxPacketIO(nx_uint16_t source, uint8_t rssi, uint8_t opt, uint8_t *Data, uint8_t dataLen){
		// TODO Auto-generated method stub
	}

	event void Serial.commandATQueueDone(error_t status){
		// TODO Auto-generated method stub
	}

	event void Serial.rxPacket(nx_uint16_t source, uint8_t rssi, uint8_t opt, uint8_t *Data, uint8_t dataLen){
      printOK(0);	
    }

	event void Serial.txStatus(uint8_t ackId, uint8_t status){
      printOK(status);	
	}

	event void Serial.remResponseAT(uint8_t ackId, nx_uint16_t source, uint8_t *cmd, uint8_t status, uint8_t *values, uint8_t valuesLen){
		// TODO Auto-generated method stub
	}

	event void Serial.modemStatus(uint8_t status){
      printOK(2);	
   	}

	event void Serial.remCommandATDone(error_t status){
		// TODO Auto-generated method stub
	}

	event void Serial.commandATDone(error_t status){
//      printOK(3);	
    }

	event void Serial.txReqDone(error_t status){
//      printOK(4);	
    }

	event void Serial.responseAT(uint8_t ackId, uint8_t *cmd, uint8_t status, uint8_t *values, uint8_t valuesLen){
      printOK(5);	
    }
*/
	async event void Uart0.receivedByte(uint8_t byte){
		// TODO Auto-generated method stub
	}

	async event void Uart0.receiveDone(uint8_t *buf, uint16_t len, error_t error){
		// TODO Auto-generated method stub
	}



}