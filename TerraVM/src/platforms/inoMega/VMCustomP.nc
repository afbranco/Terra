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
#include "VMCustom.h"
#include "usrMsg.h"
#include "BasicServices.h"

/**
 * TerraIno
 */
module VMCustomP{
	provides interface VMCustom as VM;
	uses interface BSRadio;
	uses interface Random;
#ifdef M_MSG_QUEUE
	// usrMsg queue
	uses interface dataQueue as usrDataQ;
#endif

	// Analog 0
	uses interface GeneralIO as PA_0;
	uses interface Read<uint16_t> as Ana0;
	// Analog 1
	uses interface GeneralIO as PA_1;
	uses interface Read<uint16_t> as Ana1;
	// Analog 2
	uses interface GeneralIO as PA_2;
	uses interface Read<uint16_t> as Ana2;
	// Analog 3
	uses interface GeneralIO as PA_3;
	uses interface Read<uint16_t> as Ana3;

	// Interruptions
    uses interface HplAtm8IoInterrupt as Int0;
    uses interface HplAtm8IoInterrupt as Int1;
    uses interface HplAtm8IoInterrupt as Int2;
    uses interface HplAtm8IoInterrupt as Int3;

	uses interface dht;
	uses interface rtc;

}
implementation{

// Keeps last data value for events (ExtDataxxx must be nx_ type. Because it is copied direct to VM memory.)
nx_uint8_t ExtDataSysError;				// last system error code
nx_uint8_t ExtDataCustomA;				// last request custom event (internal loop-back)
usrMsg_t ExtDataRadioReceived;			// last radio received msg
nx_uint8_t ExtDataSendDoneError;
nx_uint8_t ExtDataWasAcked;
nx_uint8_t ExtDataQReady;			// last queue ready - queue size 
nx_uint32_t ExtDataTimeStamp;		// last SLPL_FIRED - timestamp 
nx_uint8_t ExtDataGModelRdDone;		// last GModelReadDone Status 
nx_uint16_t ExtDataBufferRdDone;	// last StreamReadDone [error=0 | Count>0]
nx_int32_t* UsrStreamBuffer;		// Pointer to user data stream buffer
nx_uint16_t ExtDataAnalog;			// last analog read. (1 channel by time.)
nx_uint8_t ExtDataInt;				// Last interrupt id
nx_uint8_t ExtDataPCInt;			// Last PC interrupt id
dhtData_t ExtDHTData;				// Last DHT data read

/*
 * Output Events implementation
 */
uint8_t pinMode(uint8_t port,uint8_t pin,uint8_t val);
uint8_t pinWrite(uint8_t port,uint8_t pin,uint8_t val);
uint8_t pinToggle(uint8_t port,uint8_t pin);
void  proc_leds(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_leds(): id=%d, val=%d\n",id,(uint8_t)value);
	pinMode(_portE,5,1);
	pinMode(_portG,5,1);
	pinMode(_portE,3,1);
	pinWrite(_portE,5,(value>>0)&0x01);
	pinWrite(_portG,5,(value>>1)&0x01);
	pinWrite(_portE,3,(value>>2)&0x01);
	
}
void  proc_led0(uint16_t id, uint32_t value){ // E5
	dbg(APPNAME,"Custom::proc_led0(): id=%d, value=%d\n",id,(uint8_t)value);
	pinMode(_portE,5,1);
	if (value > 1) 
		pinToggle(_portE,5);
	else
		pinWrite(_portE,5,value);
}
void  proc_led1(uint16_t id, uint32_t value){ // G5
	dbg(APPNAME,"Custom::proc_led1(): id=%d, value=%d\n",id,(uint8_t)value);
	pinMode(_portG,5,1);
	if (value > 1) 
		pinToggle(_portG,5);
	else
		pinWrite(_portG,5,value);
}
void  proc_led2(uint16_t id, uint32_t value){ // E3
	dbg(APPNAME,"Custom::proc_led2(): id=%d, value=%d\n",id,(uint8_t)value);
	pinMode(_portE,3,1);
	if (value > 1) 
		pinToggle(_portE,3);
	else
		pinWrite(_portE,3,value);
}

void  proc_send_x(uint16_t id,uint16_t addr,uint8_t ack){
	usrMsg_t* usrMsg;
	uint8_t reqRetryAck;
	usrMsg = (usrMsg_t*)signal VM.getRealAddr(addr);
	dbg(APPNAME,"Custom::proc_sendx(): id=%d, target=%d, addr=%d, realAddr=%x, ack=%d\n",
		id,usrMsg->target,addr,usrMsg, ack);
	reqRetryAck = (ack)?(1<<REQ_ACK_BIT):0; // Define only ack without retry.
	call BSRadio.send(AM_USRMSG,usrMsg->target, usrMsg, sizeof(usrMsg_t),reqRetryAck);
}

void  proc_send(uint16_t id, uint32_t addr){
	proc_send_x(id,(uint16_t)addr,FALSE);
	}
void  proc_send_ack(uint16_t id, uint32_t addr){
	proc_send_x(id,(uint16_t)addr,TRUE);
	}


void  proc_req_custom_a(uint16_t id, uint32_t value){
	uint8_t auxId ;
	ExtDataCustomA = (uint8_t)value;
	dbg(APPNAME,"Custom::proc_req_custom_a(): id=%d, ExtDataCustomA=%d\n",id,ExtDataCustomA);
	auxId = (uint8_t)value;//(uint8_t)signal VM.pop();
	// Queue the custom event
	signal VM.queueEvt(I_CUSTOM_A_ID,auxId, &ExtDataCustomA);
	signal VM.queueEvt(I_CUSTOM_A   ,    0, &ExtDataCustomA);
	}

void  proc_req_custom(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_custom(): id=%d\n",id);
	// Queue the custom event
	ExtDataCustomA = 0;
	signal VM.queueEvt(I_CUSTOM   ,    0, &ExtDataCustomA);
	}

// A/Ds
void  proc_req_ana0_read(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_ana0_read(): id=%d\n",id);
	// Request a Analog 0 read
	if (call PA_0.isOutput()) call PA_0.makeInput();
	call Ana0.read();
	}
event void Ana0.readDone(error_t result, uint16_t val){
	ExtDataAnalog = val;
	signal VM.queueEvt(I_ANA0_READ_DONE   ,    0, &ExtDataAnalog);
	signal VM.queueEvt(I_TEMP   ,    0, &ExtDataAnalog);
	}
void  proc_req_ana1_read(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_ana1_read(): id=%d\n",id);
	// Request a Analog 1 read
	if (call PA_1.isOutput()) call PA_1.makeInput();
	call Ana1.read();
	}
event void Ana1.readDone(error_t result, uint16_t val){
	ExtDataAnalog = val;
	signal VM.queueEvt(I_ANA1_READ_DONE   ,    0, &ExtDataAnalog);
	}
void  proc_req_ana2_read(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_ana2_read(): id=%d\n",id);
	// Request a Analog 2 read
	if (call PA_2.isOutput()) call PA_2.makeInput();
	call Ana2.read();
	}
event void Ana2.readDone(error_t result, uint16_t val){
	ExtDataAnalog = val;
	signal VM.queueEvt(I_ANA2_READ_DONE   ,    0, &ExtDataAnalog);
	}
void  proc_req_ana3_read(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_ana3_read(): id=%d\n",id);
	// Request a Analog 3 read
	if (call PA_3.isOutput()) call PA_3.makeInput();
	call Ana3.read();
	}
event void Ana3.readDone(error_t result, uint16_t val){
	ExtDataAnalog = val;
	signal VM.queueEvt(I_ANA3_READ_DONE   ,    0, &ExtDataAnalog);
	}


/*
 * DHT sensor
 */

void proc_req_dht_read(uint16_t id, uint32_t value){
	call dht.read((uint8_t)value);
}

	
/*
 * Function implementation
 */
void  func_getNodeId(uint16_t id){
	uint16_t stat;
	// return NodeId
	stat = TOS_NODE_ID;
	dbg(APPNAME,"Custom::func_getNodeId(): id=%d, NodeId=%d\n",id,stat);
	signal VM.push(stat);
	}	
void  func_random(uint16_t id){
	uint16_t stat;
	// return random16
	stat = call Random.rand16();
	dbg(APPNAME,"Custom::func_random(): func id=%d, Random=%d\n",id,stat);
	signal VM.push(stat);
	}
void  func_getMem(uint16_t id){
	uint8_t val;
	uint16_t Maddr;
	Maddr = (uint16_t)signal VM.pop();
	val = (uint8_t)signal VM.getMVal(Maddr, 0);
	dbg(APPNAME,"Custom::func_getMem(): func id=%d, addr=%d, val=%d(%0x)\n",id,Maddr,val,val);
	signal VM.push(val);
	}
void  func_getTime(uint16_t id){
	uint32_t val;
	val = signal VM.getTime();
	dbg(APPNAME,"Custom::func_getTime(): func id=%d, val=%d(%0x)\n",id,val,val);
	signal VM.push(val);
	}
#ifdef M_MSG_QUEUE
void  func_qPut(uint16_t id){
	error_t stat;
	qData_t* qData_p;
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::func_qPut(): id=%d, addr=%d\n",id,value);
	// queue the usrMsg data
	qData_p = (qData_t*)signal VM.getRealAddr(value);
	stat = call usrDataQ.put(qData_p);
	signal VM.push(stat);
	}
void  func_qGet(uint16_t id){
	error_t stat;
	qData_t* qData_p;
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::func_qGet(): id=%d, addr=%d\n",id,value);
	// get the usrMsg data
	qData_p = (qData_t*)signal VM.getRealAddr(value);
	stat = call usrDataQ.get(qData_p);
	signal VM.push(stat);
	}
void  func_qSize(uint16_t id){
	uint8_t stat;
	// return queue size
	stat = call usrDataQ.size();
	dbg(APPNAME,"Custom::func_qSize(): id=%d, size=%d\n",id,stat);
	signal VM.push(stat);
	}	
void  func_qClear(uint16_t id){
	error_t stat;
	dbg(APPNAME,"Custom::func_qClear(): id=%d\n",id);
	// return queue size
	stat = call usrDataQ.clearAll();
	signal VM.push(stat);
	}
#endif //M_MSG_QUEUE

void func_setRFPower(uint16_t id){
	uint8_t value;
	dbg(APPNAME,"Custom::func_setRFPower(): id=%d\n",id);
	value  = (uint8_t)signal VM.pop();
	call BSRadio.setRFPower(value);
	signal VM.push(SUCCESS);
}

/*
 * Arduino pin functions
 */
uint8_t pinMode(uint8_t port, uint8_t pin, uint8_t mode){
	uint8_t stat=0;
	uint8_t mode_pull=0;
	mode_pull = (mode==2)?1:0;
	mode = (mode==1)?1:0;
	switch (port){
		case _portA : DDRA = (mode==0)? DDRA & ~(1<<pin) : DDRA | (1<<pin); break;
		case _portB : DDRB = (mode==0)? DDRB & ~(1<<pin) : DDRB | (1<<pin); break;
		case _portC : DDRC = (mode==0)? DDRC & ~(1<<pin) : DDRC | (1<<pin); break;
		case _portD : DDRD = (mode==0)? DDRD & ~(1<<pin) : DDRD | (1<<pin); break;
		case _portE : DDRE = (mode==0)? DDRE & ~(1<<pin) : DDRE | (1<<pin); break;
		case _portF : DDRF = (mode==0)? DDRF & ~(1<<pin) : DDRF | (1<<pin); break;
		case _portG : DDRG = (mode==0)? DDRG & ~(1<<pin) : DDRG | (1<<pin); break;
		case _portH : DDRH = (mode==0)? DDRH & ~(1<<pin) : DDRH | (1<<pin); break;
		case _portJ : DDRJ = (mode==0)? DDRJ & ~(1<<pin) : DDRJ | (1<<pin); break;
		case _portK : DDRK = (mode==0)? DDRK & ~(1<<pin) : DDRK | (1<<pin); break;
		case _portL : DDRL = (mode==0)? DDRL & ~(1<<pin) : DDRL | (1<<pin); break;
		default: stat = 1; break;
	}
	if (mode == 0){ // if necessary, set internal PULL-UP input resistor: PORTx.n = 1
		pinWrite(port,pin,mode_pull);
	}
	return stat;
}
void func_pinMode(uint16_t id){
	uint8_t stat=0;
	uint8_t port, pin,mode;
	mode = (uint8_t)signal VM.pop(); // 0-IN 1-OUT 2-IN_PULL
	pin  = (uint8_t)signal VM.pop();
	port = (uint8_t)signal VM.pop();
	stat = pinMode(port,pin,mode);
	signal VM.push(stat);
}

uint8_t pinWrite(uint8_t port,uint8_t pin,uint8_t val){
	uint8_t stat=0;
	switch (port){
		case _portA : PORTA = (val==0)? PINA & ~(1<<pin) : PINA | (1<<pin); break;
		case _portB : PORTB = (val==0)? PINB & ~(1<<pin) : PINB | (1<<pin); break;
		case _portC : PORTC = (val==0)? PINC & ~(1<<pin) : PINC | (1<<pin); break;
		case _portD : PORTD = (val==0)? PIND & ~(1<<pin) : PIND | (1<<pin); break;
		case _portE : PORTE = (val==0)? PINE & ~(1<<pin) : PINE | (1<<pin); break;
		case _portF : PORTF = (val==0)? PINF & ~(1<<pin) : PINF | (1<<pin); break;
		case _portG : PORTG = (val==0)? PING & ~(1<<pin) : PING | (1<<pin); break;
		case _portH : PORTH = (val==0)? PINH & ~(1<<pin) : PINH | (1<<pin); break;
		case _portJ : PORTJ = (val==0)? PINJ & ~(1<<pin) : PINJ | (1<<pin); break;
		case _portK : PORTK = (val==0)? PINK & ~(1<<pin) : PINK | (1<<pin); break;
		case _portL : PORTL = (val==0)? PINL & ~(1<<pin) : PINL | (1<<pin); break;
		default: stat = 1; break;
	}	
	return stat;
}

void func_pinWrite(uint16_t id){
	uint8_t stat=0;
	uint8_t port, pin, val;
	val  = (uint8_t)signal VM.pop();
	pin  = (uint8_t)signal VM.pop();
	port = (uint8_t)signal VM.pop();
	stat = pinWrite(port,pin,val);
	signal VM.push(stat);
}

uint8_t pinRead(uint8_t port,uint8_t pin){
	uint8_t value=0;
	switch (port){
		case _portA : value = ((PINA & (1<<pin)) == 0)?0:1; break;
		case _portB : value = ((PINB & (1<<pin)) == 0)?0:1; break;
		case _portC : value = ((PINC & (1<<pin)) == 0)?0:1; break;
		case _portD : value = ((PIND & (1<<pin)) == 0)?0:1; break;
		case _portE : value = ((PINE & (1<<pin)) == 0)?0:1; break;
		case _portF : value = ((PINF & (1<<pin)) == 0)?0:1; break;
		case _portG : value = ((PING & (1<<pin)) == 0)?0:1; break;
		case _portH : value = ((PINH & (1<<pin)) == 0)?0:1; break;
		case _portJ : value = ((PINJ & (1<<pin)) == 0)?0:1; break;
		case _portK : value = ((PINK & (1<<pin)) == 0)?0:1; break;
		case _portL : value = ((PINL & (1<<pin)) == 0)?0:1; break;
	}
	return value;	
}
void func_pinRead(uint16_t id){
	uint8_t value=0;
	uint8_t port, pin;
	pin  = (uint8_t)signal VM.pop();
	port = (uint8_t)signal VM.pop();
	value=pinRead(port,pin);
	signal VM.push(value);
}

uint8_t pinToggle(uint8_t port,uint8_t pin){
	uint8_t stat=0;
	uint8_t value;
	value=pinRead(port,pin);
	switch (port){
		case _portA : PORTA = (value==1)? PINA & ~(1<<pin) : PINA | (1<<pin); break;
		case _portB : PORTB = (value==1)? PINB & ~(1<<pin) : PINB | (1<<pin); break;
		case _portC : PORTC = (value==1)? PINC & ~(1<<pin) : PINC | (1<<pin); break;
		case _portD : PORTD = (value==1)? PIND & ~(1<<pin) : PIND | (1<<pin); break;
		case _portE : PORTE = (value==1)? PINE & ~(1<<pin) : PINE | (1<<pin); break;
		case _portF : PORTF = (value==1)? PINF & ~(1<<pin) : PINF | (1<<pin); break;
		case _portG : PORTG = (value==1)? PING & ~(1<<pin) : PING | (1<<pin); break;
		case _portH : PORTH = (value==1)? PINH & ~(1<<pin) : PINH | (1<<pin); break;
		case _portJ : PORTJ = (value==1)? PINJ & ~(1<<pin) : PINJ | (1<<pin); break;
		case _portK : PORTK = (value==1)? PINK & ~(1<<pin) : PINK | (1<<pin); break;
		case _portL : PORTL = (value==1)? PINL & ~(1<<pin) : PINL | (1<<pin); break;
		default: stat=1; break;
	}	
	return stat;
}

void func_pinToggle(uint16_t id){
	uint8_t stat=0;
	uint8_t port, pin;
	pin  = (uint8_t)signal VM.pop();
	port = (uint8_t)signal VM.pop();
	stat=pinToggle(port,pin);
	signal VM.push(stat);
}

/**
 * Port operations
 */

uint8_t portDDR(uint8_t port, uint8_t val){
	uint8_t stat=0;
	switch (port){
		case _portA : DDRA = val; break;
		case _portB : DDRB = val; break;
		case _portC : DDRC = val; break;
		case _portD : DDRD = val; break;
		case _portE : DDRE = val; break;
		case _portF : DDRF = val; break;
		case _portG : DDRG = val; break;
		case _portH : DDRH = val; break;
		case _portJ : DDRJ = val; break;
		case _portK : DDRK = val; break;
		case _portL : DDRL = val; break;
		default: stat = 1; break;
	}
	return stat;
}
void func_portDDR(uint16_t id){
	uint8_t stat=0;
	uint8_t port, val;
	val = (uint8_t)signal VM.pop();
	port = (uint8_t)signal VM.pop();
	stat = portDDR(port,val);
	signal VM.push(stat);
}

uint8_t portWrite(uint8_t port, uint8_t val){
	uint8_t stat=0;
	switch (port){
		case _portA : PORTA = val; break;
		case _portB : PORTB = val; break;
		case _portC : PORTC = val; break;
		case _portD : PORTD = val; break;
		case _portE : PORTE = val; break;
		case _portF : PORTF = val; break;
		case _portG : PORTG = val; break;
		case _portH : PORTH = val; break;
		case _portJ : PORTJ = val; break;
		case _portK : PORTK = val; break;
		case _portL : PORTL = val; break;
		default: stat = 1; break;
	}
	return stat;
}
void func_portWrite(uint16_t id){
	uint8_t stat=0;
	uint8_t port, val;
	val = (uint8_t)signal VM.pop();
	port = (uint8_t)signal VM.pop();
	stat = portWrite(port,val);
	signal VM.push(stat);
}

uint8_t portRead(uint8_t port){
	uint8_t stat=0;
	switch (port){
		case _portA : return PINA; break;
		case _portB : return PINB; break;
		case _portC : return PINC; break;
		case _portD : return PIND; break;
		case _portE : return PINE; break;
		case _portF : return PINF; break;
		case _portG : return PING; break;
		case _portH : return PINH; break;
		case _portJ : return PINJ; break;
		case _portK : return PINK; break;
		case _portL : return PINL; break;
	}
	return stat;
}
void func_portRead(uint16_t id){
	uint8_t val=0;
	uint8_t port;
	port = (uint8_t)signal VM.pop();
	val = portRead(port);
	signal VM.push(val);
}


/**
 * Interruptions
 */
void func_intEnable(uint16_t id){
	uint8_t stat=0;
	uint8_t iid = (uint8_t)signal VM.pop();
	switch (iid){
		case 0: call Int0.enable(); break;
		case 1: call Int1.enable(); break;
		case 2: call Int2.enable(); break;
		case 3: call Int3.enable(); break;		
		default: stat=1; break;	
	}
	signal VM.push(stat);
}
void func_intDisable(uint16_t id){
	uint8_t stat=0;
	uint8_t iid = (uint8_t)signal VM.pop();
	switch (iid){
		case 0: call Int0.disable(); break;
		case 1: call Int1.disable(); break;
		case 2: call Int2.disable(); break;
		case 3: call Int3.disable(); break;		
		default: stat=1; break;	
	}
	signal VM.push(stat);
}
void func_intClear(uint16_t id){
	uint8_t stat=0;
	uint8_t iid = (uint8_t)signal VM.pop();
	switch (iid){
		case 0: call Int0.clear(); break;
		case 1: call Int1.clear(); break;
		case 2: call Int2.clear(); break;
		case 3: call Int3.clear(); break;		
		default: stat=1; break;	
	}
	signal VM.push(stat);
}
void func_intConfig(uint16_t id){
	uint8_t stat=0;
	uint8_t iid, mode;
	mode = (uint8_t)signal VM.pop();
	iid = (uint8_t)signal VM.pop();
	switch (iid){
		case 0: call Int0.configure(mode); break;
		case 1: call Int1.configure(mode); break;
		case 2: call Int2.configure(mode); break;
		case 3: call Int3.configure(mode); break;
		default: stat=1; break;		
	}
	signal VM.push(stat);
}

// PC INT
void func_pcintEnable(uint16_t id){
	uint8_t stat=0;
	uint8_t iid;
	iid = (uint8_t)signal VM.pop();
	switch (iid){
		case 0: PCICR = PCICR | (1<<PCIE0); break;
		case 1: PCICR = PCICR | (1<<PCIE1); break;
		case 2: PCICR = PCICR | (1<<PCIE2); break;
		default: stat=1; break;		
	}
	signal VM.push(stat);	
}
void func_pcintDisable(uint16_t id){
	uint8_t stat=0;
	uint8_t iid;
	iid = (uint8_t)signal VM.pop();
	switch (iid){
		case 0: PCICR = PCICR & ~(1<<PCIE0); break;
		case 1: PCICR = PCICR & ~(1<<PCIE1); break;
		case 2: PCICR = PCICR & ~(1<<PCIE2); break;
		default: stat=1; break;		
	}
	signal VM.push(stat);	
}
void func_pcintClear(uint16_t id){
	uint8_t stat=0;
	uint8_t iid;
	iid = (uint8_t)signal VM.pop();
	switch (iid){
		case 0: PCIFR = PCIFR & ~(1<<PCIF0); break;
		case 1: PCIFR = PCIFR & ~(1<<PCIF1); break;
		case 2: PCIFR = PCIFR & ~(1<<PCIF2); break;
		default: stat=1; break;		
	}
	signal VM.push(stat);	
}
void func_pcintMask(uint16_t id){
	uint8_t stat=0;
	uint8_t iid,mask;
	mask = (uint8_t)signal VM.pop();
	iid  = (uint8_t)signal VM.pop();
	switch (iid){
		case 0: PCMSK0 = mask; break;
		case 1: PCMSK1 = mask; break;
		case 2: PCMSK2 = mask; break;
		default: stat=1; break;		
	}
	signal VM.push(stat);	
}


/**
 *	procOutEvt(uint8_t id)
 *  	procOutEvt - process the out events (emit)
 * 
 *	id - Event ID
 */
command void VM.procOutEvt(uint8_t id,uint32_t value){
	dbg(APPNAME,"Custom::procOutEvt(): id=%d\n",id);
	switch (id){
//		case O_INIT 		: proc_init(id,value); break;
		case O_LEDS 		: proc_leds(id,value); break;
		case O_LED0 		: proc_led0(id,value); break;
		case O_LED1 		: proc_led1(id,value); break;
		case O_LED2 		: proc_led2(id,value); break;
		case O_TEMP			: proc_req_ana0_read(id,value); break;
		case O_DHT			: proc_req_dht_read(id,value); break;
		
		case O_SEND 		: proc_send(id,value); break;
		case O_SEND_ACK 	: proc_send_ack(id,value); break;
		case O_CUSTOM_A 	: proc_req_custom_a(id,value); break;
		case O_CUSTOM 		: proc_req_custom(id,value); break;

		case O_ANA0_READ 	: proc_req_ana0_read(id,value); break;
		case O_ANA1_READ 	: proc_req_ana1_read(id,value); break;
		case O_ANA2_READ 	: proc_req_ana2_read(id,value); break;
		case O_ANA3_READ 	: proc_req_ana3_read(id,value); break;
	}
}


	command void VM.callFunction(uint8_t id){
		dbg(APPNAME,"Custom::VM.callFunction(%d)\n",id);
		switch (id){
			case F_GETNODEID: func_getNodeId(id); break;
			case F_RANDOM 	: func_random(id); break;
			case F_GETMEM 	: func_getMem(id); break;
			case F_GETTIME 	: func_getTime(id); break;
#ifdef M_MSG_QUEUE
			case F_QPUT 	: func_qPut(id); break;
			case F_QGET 	: func_qGet(id); break;
			case F_QSIZE 	: func_qSize(id); break;
			case F_QCLEAR 	: func_qClear(id); break;		
#endif
			case F_SETRFPOWER	: func_setRFPower(id); break;
			case F_PIN_MODE		: func_pinMode(id); break;
			case F_PIN_WRITE	: func_pinWrite(id); break;
			case F_PIN_READ		: func_pinRead(id); break;
			case F_PIN_TOGGLE	: func_pinToggle(id); break;
			case F_PORT_DDR		: func_portDDR(id); break;
			case F_PORT_WRITE	: func_portWrite(id); break;
			case F_PORT_READ	: func_portRead(id); break;
			
			case F_INT_ENABLE	: func_intEnable(id); break;
			case F_INT_DISABLE	: func_intDisable(id); break;
			case F_INT_CLEAR	: func_intClear(id); break;
			case F_PCINT_ENABLE	: func_pcintEnable(id); break;
			case F_PCINT_DISABLE: func_pcintDisable(id); break;
			case F_PCINT_CLEAR	: func_pcintClear(id); break;
			case F_PCINT_MASK	: func_pcintMask(id); break;
		}
	}

	command void VM.reset(){
		// Reset leds
		//call LEDS.set(0);
#ifdef M_MSG_QUEUE
		// Clear msgQ
		call usrDataQ.clearAll();
#endif
	}

	task void BCRadio_receive(){
		signal VM.queueEvt(I_RECEIVE_ID, ExtDataRadioReceived.type, &ExtDataRadioReceived);	
		signal VM.queueEvt(I_RECEIVE   ,                         0, &ExtDataRadioReceived);	
	}

	event void BSRadio.receive(uint8_t am_id, message_t* msg, void* payload, uint8_t len){
		dbg(APPNAME,"Custom::BSRadio.receive(): AM_ID = %d\n",am_id);
		if (am_id == AM_USRMSG){
			memcpy(&ExtDataRadioReceived,payload,sizeof(usrMsg_t));
			post BCRadio_receive();
		} else {
			dbg(APPNAME,"Custom::BSRadio.receive(): Discarting AM_ID = %d\n",am_id);
		}
	}

	event void BSRadio.sendDone(uint8_t am_id,message_t* msg,void* dataMsg, error_t error){
		dbg(APPNAME,"Custom::BSRadio.sendDone(): AM_ID = %d, error=%d\n",am_id,error);
		if (am_id == AM_USRMSG){
			ExtDataSendDoneError = (uint8_t)error;
			signal VM.queueEvt(I_SEND_DONE_ID, ((usrMsg_t*)dataMsg)->type, &ExtDataSendDoneError);
			signal VM.queueEvt(I_SEND_DONE   ,                          0, &ExtDataSendDoneError);
		} else {
			dbg(APPNAME,"Custom::BSRadio.sendDone(): Discarting sendDone AM_ID = %d\n",am_id);
		}
	}
	event void BSRadio.sendDoneAck(uint8_t am_id,message_t* msg,void* dataMsg,error_t error, bool wasAcked){
		dbg(APPNAME,"Custom::BSRadio.sendDoneAck(): AM_ID = %d, error=%d, ack=%d\n",am_id,error,wasAcked);
		if (am_id == AM_USRMSG){
			ExtDataWasAcked = (uint8_t)wasAcked;
			signal VM.queueEvt(I_SEND_DONE_ACK_ID, ((usrMsg_t*)dataMsg)->type, &ExtDataWasAcked);
			signal VM.queueEvt(I_SEND_DONE_ACK   ,                          0, &ExtDataWasAcked);
		} else {
			dbg(APPNAME,"Custom::BSRadio.sendDoneAck(): Discarting sendDoneAck AM_ID = %d\n",am_id);
		}
	}



/**
 * Custom usrDataQueue
 */
#ifdef M_MSG_QUEUE
	event void usrDataQ.dataReady(){
		dbg(APPNAME,"Custom::usrDataQ.dataReady()\n");
		// Queue the custom event
		ExtDataQReady = call usrDataQ.size();
		signal VM.queueEvt(I_Q_READY, 0, &ExtDataQReady);
	}
#endif

/**
 * Interruptions
 */

	task void IntxFired(){
		uint8_t aux;
		atomic{aux=ExtDataInt;}
		signal VM.queueEvt(I_INT_FIRED, aux, &ExtDataInt);
		}

	async event void Int0.fired(){ExtDataInt = 0; post IntxFired();}
	async event void Int1.fired(){ExtDataInt = 1; post IntxFired();}
	async event void Int2.fired(){ExtDataInt = 2; post IntxFired();}
	async event void Int3.fired(){ExtDataInt = 3; post IntxFired();}

	task void PCIntxFired(){
		uint8_t aux;
		atomic{aux=ExtDataPCInt;}
		signal VM.queueEvt(I_PCINT_FIRED, aux, &ExtDataPCInt);
		}
	void dhtPinInt();
	AVR_ATOMIC_HANDLER(PCINT0_vect) {ExtDataPCInt = 0; post PCIntxFired();}
	AVR_ATOMIC_HANDLER(PCINT1_vect) {ExtDataPCInt = 1; post PCIntxFired();}
	AVR_ATOMIC_HANDLER(PCINT2_vect) {ExtDataPCInt = 2; post PCIntxFired();}

/**
 * DHT
 */

	event void dht.readDone(dhtData_t* data){
		memcpy(&ExtDHTData,data,sizeof(dhtData_t));
		signal VM.queueEvt(I_DHT, 0, &ExtDHTData);		
	}
	
}
