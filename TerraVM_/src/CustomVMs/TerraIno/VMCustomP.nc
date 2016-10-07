/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#include "VMCustomIno.h"
#include "usrMsg.h"
#include "BasicServices.h"

module VMCustomP{
	provides interface VMCustom as VM;
	uses interface BSRadio;
	uses interface InoIO; 
	uses interface Random;
#ifdef M_MSG_QUEUE
	// usrMsg queue
	uses interface dataQueue as usrDataQ;
#endif
}
implementation{

// Keeps last data value for events (ExtDataxxx must be nx_ type. Because it is copied direct to VM memory.)
nx_uint8_t ExtDataSysError;				// last system error code
nx_uint8_t ExtDataCustomA;				// last request custom event (internal loop-back)
usrMsg_t ExtDataRadioReceived;	// last radio received msg
nx_uint8_t ExtDataSendDoneError;
nx_uint8_t ExtDataWasAcked;
nx_uint8_t ExtDataQReady;			// last queue ready - queue size 
nx_uint16_t ExtAnaData;				// last Analog read data
nx_uint8_t  ExtIntData;				// dummy var for last pin interrupt
nx_uint32_t ExtPulseData; 			// last Pulse len

/*
 * Output Events implementation
 */
/*
void  proc_init(uint16_t id, uint32_t value){
	uint32_t val = signal VM.pop();
	dbg(APPNAME,"Custom::proc_init(): id=%d, val=%d\n",id,(uint16_t)val);
	signal VM.setMVal(TOS_NODE_ID,(uint16_t)val,2);
}
*/


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
	auxId = (uint8_t)value;
	// Queue the custom event
	signal VM.queueEvt(I_CUSTOM_A_ID,auxId, &ExtDataCustomA);
	signal VM.queueEvt(I_CUSTOM_A   ,    0, &ExtDataCustomA);
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
	// Clear the queue
	stat = call usrDataQ.clearAll();
	signal VM.push(stat);
	}
#endif //M_MSG_QUEUE

/**
 * Ino functions
 */

void  func_pinMode(uint16_t id){
	error_t stat;
	digital_enum pin;
	pinmode_enum mode;
	dbg(APPNAME,"Custom::func_pinMode(): id=%d\n",id);
	mode = (uint8_t)signal VM.pop();
	pin = (uint8_t)signal VM.pop();
	stat = SUCCESS;
	call InoIO.pinMode(pin,mode);
	signal VM.push(stat);
	}


void  func_digitalWrite(uint16_t id){
	error_t stat;
	digital_enum pin;
	pinvalue_enum value;
	dbg(APPNAME,"Custom::func_digitalWrite(): id=%d\n",id);
	value = (uint8_t)signal VM.pop();
	pin = (uint8_t)signal VM.pop();
	stat = SUCCESS;
	call InoIO.digitalWrite(pin,value);
	signal VM.push(stat);
	}

void  func_digitalRead(uint16_t id){
	error_t stat;
	digital_enum pin;
	dbg(APPNAME,"Custom::func_digitalRead(): id=%d\n",id);
	pin = (uint8_t)signal VM.pop();
	stat = call InoIO.digitalRead(pin);
	signal VM.push(stat);
	}

void  func_digitalToggle(uint16_t id){
	error_t stat;
	digital_enum pin;
	dbg(APPNAME,"Custom::func_digitalToggle(): id=%d\n",id);
	pin = (uint8_t)signal VM.pop();
	stat = SUCCESS;
	call InoIO.digitalToggle(pin);
	signal VM.push(stat);
	}

void  func_analogReference(uint16_t id){
	error_t stat;
	analogref_enum type;
	dbg(APPNAME,"Custom::func_analogReference(): id=%d\n",id);
	type = (uint8_t)signal VM.pop();
	stat = SUCCESS;
	call InoIO.analogReference(type);
	signal VM.push(stat);
	}

void  func_analogRead(uint16_t id){
	error_t stat;
	analog_enum pin;
	dbg(APPNAME,"Custom::func_analogRead(): id=%d\n",id);
	pin = (uint8_t)signal VM.pop();
	stat = call InoIO.analogRead(pin);
	signal VM.push(stat);
	}

void  func_interruptRisingEdge(uint16_t id){
	error_t stat;
	interrupt_enum intPin;
	dbg(APPNAME,"Custom::func_interruptRisingEdge(): id=%d\n",id);
	intPin = (uint8_t)signal VM.pop();
	stat = SUCCESS;
	call InoIO.interruptRisingEdge(intPin);
	signal VM.push(stat);
	}

void  func_interruptFallingEdge(uint16_t id){
	error_t stat;
	interrupt_enum intPin;
	dbg(APPNAME,"Custom::func_interruptFallingEdge(): id=%d\n",id);
	intPin = (uint8_t)signal VM.pop();
	stat = SUCCESS;
	call InoIO.interruptFallingEdge(intPin);
	signal VM.push(stat);
	}

void  func_interruptDisable(uint16_t id){
	error_t stat;
	interrupt_enum intPin;
	dbg(APPNAME,"Custom::func_interruptDisable(): id=%d\n",id);
	intPin = (uint8_t)signal VM.pop();
	stat = SUCCESS;
	call InoIO.interruptDisable(intPin);
	signal VM.push(stat);
	}	

void  func_pulseIn(uint16_t id){
	error_t stat;
	interrupt_enum intPin;
	pinvalue_enum value;
	uint32_t timeout;
	dbg(APPNAME,"Custom::func_pulseIn(): id=%d\n",id);
	timeout= (uint32_t)signal VM.pop();
	value  = (uint8_t) signal VM.pop();
	intPin = (uint8_t) signal VM.pop();
	stat = SUCCESS;
	call InoIO.pulseIn(intPin,value,timeout);
	signal VM.push(stat);
	}

void func_getClockMicro(uint16_t id){
	dbg(APPNAME,"Custom::func_getClockMicro(): id=%d\n",id);
	signal VM.push(call InoIO.getClockMicro());
	
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
		case O_SEND 		: proc_send(id,value); break;
		case O_SEND_ACK 	: proc_send_ack(id,value); break;
		case O_CUSTOM_A : proc_req_custom_a(id,value); break;
	}
}


	command void VM.callFunction(uint8_t id){
		dbg(APPNAME,"Custom::VM.callFunction(%d)\n",id);
		switch (id){
			case F_GETNODEID		: func_getNodeId(id); break;
			case F_RANDOM 			: func_random(id); break;
			case F_GETCLOCKMICRO	: func_getClockMicro(id); break;
#ifdef M_MSG_QUEUE
			case F_QPUT 	: func_qPut(id); break;
			case F_QGET 	: func_qGet(id); break;
			case F_QSIZE 	: func_qSize(id); break;
			case F_QCLEAR 	: func_qClear(id); break;		
#endif
			case F_PIN_MODE			: func_pinMode(id); break;
			case F_DIGITAL_WRITE	: func_digitalWrite(id); break;
			case F_DIGITAL_READ 	: func_digitalRead(id); break;
			case F_DIGITAL_TOGGLE 	: func_digitalToggle(id); break;
			case F_ANALOG_REFERENCE	: func_analogReference(id); break;
			case F_ANALOG_READ		: func_analogRead(id); break;
			case F_INT_RISING_EDGE	: func_interruptRisingEdge(id); break;
			case F_INT_FALLING_EDGE	: func_interruptFallingEdge(id); break;
			case F_INT_DISABLE 		: func_interruptDisable(id); break;
			case F_PULSE_IN 		: func_pulseIn(id); break;
		}
	}

	command void VM.reset(){
		// Reset leds
//		call SA.setActuator(AID_LEDS, 0);
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
 * Ino Events
 */

	event void InoIO.analogReadDone(analog_enum pin, uint16_t value){
		ExtAnaData = value;
		signal VM.queueEvt(I_ANA_READ_DONE_ID, (uint8_t)pin, &ExtAnaData);
		signal VM.queueEvt(I_ANA_READ_DONE,               0, &ExtAnaData);
	}

	event void InoIO.interruptFired(interrupt_enum intPin){
		ExtIntData = 0;
		signal VM.queueEvt(I_INT_FIRED_ID, (uint8_t)intPin, &ExtIntData);
		signal VM.queueEvt(I_INT_FIRED,                  0, &ExtIntData);
	}

	event void InoIO.pulseLen(interrupt_enum intPin, pinvalue_enum value, uint32_t len){
		ExtPulseData = len;
		signal VM.queueEvt(I_PULSE_LEN_ID, (uint8_t)intPin, &ExtPulseData);
		signal VM.queueEvt(I_PULSE_LEN,                  0, &ExtPulseData);
	}
}