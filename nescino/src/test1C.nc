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
#include <stdio.h>
module test1C @safe()
{
  uses interface Boot;
  uses interface Timer<TMilli> as Timer;
  uses interface Leds;
  
  uses interface Queue<uint8_t> as LogQ;
  
  uses {
  	interface UartStream as Uart0;
  	interface StdControl as Uart0Ctl;
 }

 uses {
 	interface AMSend as RadioSnd[am_id_t id];
 	interface Receive as RadioRec[am_id_t id];
 	interface SplitControl as RadioCtl;
 	interface xLog;
 }

}
implementation
{
  uint8_t data[10];
  message_t msg1;
  uint8_t radioBusy=FALSE;
  
  #define LOG_BUFFER_LEN 100
  uint8_t logBuffer[LOG_BUFFER_LEN];
  uint8_t logIdx;
  uint8_t logLen;
  uint8_t logIdle;
  
void logS(uint8_t* logMsg, uint8_t len);

  event void Boot.booted()
  {
  	  uint8_t i;
  	  
  	  logIdx=0; logLen=0; logIdle=TRUE;
  	  
      //call Leds.led0On();

      call Uart0Ctl.start();
	  for (i=0;i<10;i++) data[i] = 0x40 + i;

	  call RadioCtl.start();

      //call Uart0.send("@\n", 2);
data[0]='*';
      logS(data, 1);
data[0]='A';
  }

/**
 * Wait Radio Initialization
 */

	event void RadioCtl.startDone(error_t error){
      call Timer.startPeriodic(2000);
	}

	event void RadioCtl.stopDone(error_t error){}


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
  
  event void Timer.fired(){
  	  error_t stat;
      //call Leds.led0Toggle();
      
      msg1.data[0]='f';
      msg1.data[1]='g';
      msg1.opt = 0x00; // Request Ack
	  if (!radioBusy) {
        logS(data, 1); data[0]++;
	  	radioBusy = TRUE;
	    stat = call RadioSnd.send[130]((TOS_NODE_ID==2)?3:2, &msg1, 2);
	    if (stat != SUCCESS) {
		  	data[1]='^'; logS(&data[1], 1);
	    	radioBusy = FALSE; 
	    }
	  } else {
	  	data[1]='?'; logS(&data[1], 1);
	  }
	   
  	}
  

	async event void Uart0.receivedByte(uint8_t byte){
	  uint8_t nl = 0x0f;
//      call Uart0.send(&nl, 1);
//      call Uart0.send(&byte, 1);
//	  data[9]= '\n';
      //call Uart0.send(data, 10);
	}

	async event void Uart0.receiveDone(uint8_t *buf, uint16_t len, error_t error){
	}

	uint8_t datax[10];

	event void RadioSnd.sendDone[am_id_t amid](message_t *msg, error_t error){
		radioBusy = FALSE;
		datax[0]=msg->data[0];
		datax[1]=msg->data[1];
		datax[2]='-';
		datax[3]='0'+error;
		datax[4]='\n';
    	logS(datax, 5);
	}

	event message_t * RadioRec.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
		data[0]=*(uint8_t*)payload;
		
		// TODO Auto-generated method stub
		datax[0]='r';
		datax[1]='0'+((msg->source & 0xf000)>>12);
		datax[2]='0'+((msg->source & 0x0f00)>>8);
		datax[3]='0'+((msg->source & 0x00f0)>>4);
		datax[4]='0'+ (msg->source & 0x000f);
		datax[5]='0'+(msg->len >> 4);
		datax[6]='0'+(msg->len & 0x0f);
		datax[7]='\n';
    	logS(datax, 8);
    	{
    		uint8_t i;uint8_t dStr[100];
    		uint8_t nBytes = (len);
    	  	for (i=0;i<nBytes;i++) sprintf(dStr+(3*i),"%02x.",*(uint8_t*)(payload+i));
    	  	logS(dStr, nBytes*3);
		}
		return msg;
	}


	event void xLog.logUSB0(uint8_t *data1, uint8_t len){
		logS(data1, len);
	}


}
