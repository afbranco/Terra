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
#include "dht.h"
#include <util/delay_basic.h>

module dhtP{
	provides interface dht;
	uses interface Counter<TMicro,uint32_t> as CounterMicro;
	uses interface Boot;
	uses interface HplAtm8IoInterrupt as Int0;
	uses interface HplAtm8IoInterrupt as Int1;
	uses interface HplAtm8IoInterrupt as Int2;
	uses interface HplAtm8IoInterrupt as Int3;
	uses interface Timer<TMilli> as Timer;
}
implementation{

	volatile dht_state_t state;
	volatile uint8_t status;
	volatile uint8_t bits[5];
	volatile uint8_t cnt;
	volatile uint8_t idx;
	volatile uint32_t micros;
	volatile uint8_t hum,temp;
	dhtData_t retData;
	uint8_t timerOper=0; // 0-> 18ms, 1-> full TimeOut
	volatile uint8_t dhtIntPin = 1 ;

	void delay_us(uint16_t us) {_delay_loop_2(us * (F_CPU/4000000ul));}


// define Int0..3 PORT/DDR/PIN
#define DHT_PORT PORTD
#define DHT_DDR DDRD
#define DHT_PIN PIND



	void setPin(){
		DHT_DDR  |= (1<<dhtIntPin); // set output
		DHT_PORT |= (1<<dhtIntPin); // set 1
	}
	void clrPin(){
		DHT_DDR  |=  (1<<dhtIntPin); // set output
		DHT_PORT &= ~(1<<dhtIntPin); // set 0
	}
	void inPin(){
		DHT_PORT |=  (1<<dhtIntPin); // set pullup
		DHT_DDR  &= ~(1<<dhtIntPin); // set input
	}	

	uint8_t getPin(){
		return ( DHT_PIN >> dhtIntPin) | 0x01;
	}
	
	void enableInt(){
		switch(dhtIntPin){
			case 0 : call Int0.configure(INT_FALLING); call Int0.enable();break;
			case 1 : call Int1.configure(INT_FALLING); call Int1.enable();break;
			case 2 : call Int2.configure(INT_FALLING); call Int2.enable();break;
			case 3 : call Int3.configure(INT_FALLING); call Int3.enable();break;
		}	
	}
		
	void disableInt(){
		switch(dhtIntPin){
			case 0: call Int0.disable(); break;
			case 1: call Int1.disable(); break;
			case 2: call Int2.disable(); break;
			case 3: call Int3.disable(); break;
		}
	}
	void clearInt(){
		switch(dhtIntPin){
			case 0: call Int0.clear(); break;
			case 1: call Int1.clear(); break;
			case 2: call Int2.clear(); break;
			case 3: call Int3.clear(); break;
		}
	}

	event void Boot.booted(){
		setPin();
		atomic{state = STOPPED;}
		atomic{status = E_NOTSTARTED;}
	}

	task void doneOK(){
		call Timer.stop();
		atomic{retData.stat = status;}
		atomic{retData.hum = hum;}
		atomic{retData.temp = temp;}
		signal dht.readDone(&retData);
	}
	task void doneNOK(){
		call Timer.stop();
		atomic{retData.stat = status;}
		retData.hum = 0;
		retData.temp = 0;
		signal dht.readDone(&retData);
	}


	command uint8_t dht.read(uint8_t intPin){
		uint8_t i;
		uint8_t cond;
		atomic{dhtIntPin = intPin;}
		atomic{cond = state == STOPPED || state == ACQUIRED;}
		if (cond) {	
			atomic{state = RESPONSE;}
			// Init vars
			for (i=0; i< 5; i++) atomic{bits[i] = 0;}
			atomic{cnt = 7;}
			atomic{idx = 0;}
		
			// REQUEST SAMPLE
			clrPin();
			timerOper = 0;
			call Timer.startOneShot(18);
			return S_ACQUIRING;
		} else {
			post doneNOK();
			return E_ACQUIRING;
		}
	}

	// Continue the "start-read" after 18ms
	void read_cont(){
			setPin();
			delay_us(40);	
			inPin();
			
			// Analize the data in an interrupt
			atomic{micros = call CounterMicro.get();}
			enableInt();
			timerOper = 1;
			call Timer.startOneShot(300);
	}

	void IntFired(){
		uint32_t newUs = call CounterMicro.get();
		uint32_t delta = (newUs-micros);
		micros = newUs;
		if (delta>6000) {
			status = E_ISR_TIMEOUT;
			state = STOPPED;
			disableInt();
			post doneNOK();
			return;
		}
		switch(state) {
			case RESPONSE:
				if(delta<25){
					micros -= delta;
					break; //do nothing, it started the response signal
				} if(125<delta && delta<190) {
					state = DATA;
				} else {
					disableInt();
					status = E_RESPONSE_TIMEOUT;
					state = STOPPED;
					post doneNOK();
				}
				break;
			case DATA:
				if(delta<10) {
					disableInt();
					status = E_DELTA;
					state = STOPPED;
					post doneNOK();
				} else if(60<delta && delta<155) { //valid in timing
					if(delta>90) //is a one
						bits[idx] |= (1 << cnt);
					if (cnt == 0) {  // whe have fullfilled the byte, go to next
							cnt = 7;    // restart at MSB
							if(idx++ == 4) {      // go to next byte, if whe have got 5 bytes stop.
								uint8_t sum;
								disableInt();
								// WRITE TO RIGHT VARS
								// as bits[1] and bits[3] are allways zero they are omitted in formulas.
								hum    = bits[0]; 
								temp = bits[2]; 
								sum = bits[0] + bits[2];  
								if (bits[4] != sum) {
									status = E_CHECKSUM;
									state = STOPPED;
									post doneNOK();
								} else {
									status = S_OK;
									state = ACQUIRED;
									post doneOK();
								}
								break;
							}
					} else cnt--;
				} else {
					disableInt();
					status = E_DATA_TIMEOUT;
					state = STOPPED;
					post doneNOK();
				}
				break;
			default:
				break;
		}
	clearInt();
	}

	async event void Int0.fired() { if (dhtIntPin==0) IntFired();}
	async event void Int1.fired() { if (dhtIntPin==1) IntFired();}
	async event void Int2.fired() { if (dhtIntPin==2) IntFired();}
	async event void Int3.fired() { if (dhtIntPin==3) IntFired();}
	

	async event void CounterMicro.overflow(){
		call CounterMicro.clearOverflow();
	}
	
	event void Timer.fired(){
		if (timerOper==0){
			read_cont();	
		} else {		
			atomic{status = E_ISR_MISSING;}
			atomic{state = STOPPED;}
			post doneNOK();
		}
	}		
}