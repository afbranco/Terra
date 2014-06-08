/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#include "VMCustom.h"
#include "usrMsg.h"

module VMCustomP{
	provides interface VMCustom as VM;
	uses interface BSRadio;
	uses interface SensAct as SA;

	// usrMsg queue
	uses interface dataQueue as usrDataQ;
}
implementation{


// Keeps last data value for events (ExtDataxxx must be nx_ type. Because it is copied direct to VM memory.)
nx_uint8_t ExtDataCustomA;				// last request custom event (internal loop-back)
usrMsg_t ExtDataRadioReceived;	// last radio received msg
nx_uint8_t ExtDataSendDoneError;
nx_uint8_t ExtDataWasAcked;
nx_uint8_t ExtDataQReady;			// last queue ready - queue size 
nx_uint32_t ExtDataTimeStamp;		// last SLPL_FIRED - timestamp 

/**
 * Customized function 
 */
void  proc_init(uint16_t id){
	uint32_t val = signal VM.pop();
	dbg(APPNAME,"Custom::proc_init(): id=%d, val=%d\n",id,(uint16_t)val);
	signal VM.setMVal(TOS_NODE_ID,(uint16_t)val,2);
}
void  proc_leds(uint16_t id){
	uint32_t value = signal VM.pop();
	dbg(APPNAME,"Custom::proc_leds(): id=%d, val=%d\n",id,(uint8_t)value);
	call SA.setActuator(AID_LEDS, (uint8_t)(value & 0x07));
}
void  proc_led0(uint16_t id){
	uint32_t value = signal VM.pop();
	dbg(APPNAME,"Custom::proc_led0(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED0_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED0, (uint8_t)(value & 0x01));
}
void  proc_led1(uint16_t id){
	uint32_t value = signal VM.pop();
	dbg(APPNAME,"Custom::proc_led1(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED1_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED1, (uint8_t)(value & 0x01));
}
void  proc_led2(uint16_t id){
	uint32_t value = signal VM.pop();
	dbg(APPNAME,"Custom::proc_led2(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED2_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED2, (uint8_t)(value & 0x01));
}
void  proc_req_temp(uint16_t id){
	dbg(APPNAME,"Custom::proc_req_temp(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_TEMP);
	}
void  proc_req_photo(uint16_t id){
	dbg(APPNAME,"Custom::proc_req_photo(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_PHOTO);
	}
void  proc_req_volts(uint16_t id){
	dbg(APPNAME,"Custom::proc_req_volts(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_VOLT);
	}

void  proc_send_x(uint16_t id,uint16_t target,uint16_t addr,uint8_t len,uint8_t ack){
	void* usrMsg;
	dbg(APPNAME,"Custom::proc_sendx(): id=%d, target=%d, addr=%d, len=%d, dtAddr=%d, ack=%d\n",
		id,target,addr,len,(uint16_t)signal VM.getMVal(addr,2), ack);
	usrMsg = (void*)signal VM.getRealAddr((uint16_t)addr,2);
	call BSRadio.send(target, usrMsg, sizeof(usrMsg_t),ack);
}

void  proc_send(uint16_t id){
	uint16_t target,addr;
	uint8_t len;
	target = (uint16_t)signal VM.pop();
	addr = (uint16_t)signal VM.pop();
	len = (uint8_t)signal VM.pop();
	proc_send_x(id,target,addr, len,FALSE);
	}
void  proc_send_ack(uint16_t id){
	uint16_t target,addr;
	uint8_t len;
	target = (uint16_t)signal VM.pop();
	addr = (uint16_t)signal VM.pop();
	len = (uint8_t)signal VM.pop();
	proc_send_x(id,target,addr, len,TRUE);
	}


void  proc_set_port_a(uint16_t id){
	uint8_t value = (uint8_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_set_port_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_OUT1, (value & 0x01));
}
void  proc_set_port_b(uint16_t id){
	uint8_t value = (uint8_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_set_port_b(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_OUT2, (value & 0x01));
}
void  proc_cfg_port_a(uint16_t id){
	uint8_t value = (uint8_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_cfg_port_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_PIN1, (value & 0x01));
}
void  proc_cfg_port_b(uint16_t id){
	uint8_t value = (uint8_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_cfg_port_b(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_PIN2, (value & 0x01));
}
void  proc_req_port_a(uint16_t id){
	dbg(APPNAME,"Custom::proc_req_port_a(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_IN1);
	}
void  proc_req_port_b(uint16_t id){
	dbg(APPNAME,"Custom::proc_req_port_b(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_IN2);
	}
void  proc_cfg_int_a(uint16_t id){
	uint8_t value = (uint8_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_cfg_int_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_INT1, value);
	}
void  proc_cfg_int_b(uint16_t id){
	uint8_t value = (uint8_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_cfg_int_b(): id=%d value=%d\n",id,value);
	call SA.setActuator(AID_INT2, value);
	}
void  proc_req_custom_a(uint16_t id){
	ExtDataCustomA = (uint8_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_req_custom_a(): id=%d, ExtDataCustomA=%d\n",id,ExtDataCustomA);
	// Queue the custom event
	signal VM.queueEvt(CUSTOM_A, &ExtDataCustomA);
	}
void  proc_q_put(uint16_t id){
	qData_t* qData_p;
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_q_put(): id=%d, addr=%d\n",id,value);
	// queue the usrMsg data
	qData_p = (qData_t*)signal VM.getRealAddr(value,2);
	call usrDataQ.put(qData_p);
	}
void  proc_q_get(uint16_t id){
	qData_t* qData_p;
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_q_get(): id=%d, addr=%d\n",id,value);
	// get the usrMsg data
	qData_p = (qData_t*)signal VM.getRealAddr(value,2);
	call usrDataQ.get(qData_p);
	}
void  proc_q_size(uint16_t id){
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::proc_q_size(): id=%d, addr=%d\n",id,value);
	// return queue size
	*(uint8_t*)signal VM.getRealAddr(value,2)=call usrDataQ.size();
	}	
void  proc_q_clear(uint16_t id){
	dbg(APPNAME,"Custom::proc_q_clear(): id=%d\n",id);
	// return queue size
	call usrDataQ.clearAll();
	}
	
/**
 *	procOutEvt(uint16_t id, uint16_t len, uint32_t val, uint8_t cv)
 *  	procOutEvt - process the out events (emit)
 * 
 *	id - Event ID
 *	len - data parameter length
 *	val - Variable address or Constant value
 *	cv  - if 0 then val is a constant else val is an address
 */
command void VM.procOutEvt(uint16_t id){
	dbg(APPNAME,"Custom::procOutEvt(): id=%d\n",id);
	switch (id){
		case INIT 		: proc_init(id); break;
		case LEDS 		: proc_leds(id); break;
		case LED0 		: proc_led0(id); break;
		case LED1 		: proc_led1(id); break;
		case LED2 		: proc_led2(id); break;
		case REQ_TEMP 	: proc_req_temp(id); break;
		case REQ_PHOTO 	: proc_req_photo(id); break;
		case REQ_VOLTS 	: proc_req_volts(id); break;
		case SEND 		: proc_send(id); break;
		case SEND_ACK 	: proc_send_ack(id); break;
		case SET_PORT_A : proc_set_port_a(id); break;
		case SET_PORT_B : proc_set_port_b(id); break;
		case CFG_PORT_A : proc_cfg_port_a(id); break;
		case CFG_PORT_B : proc_cfg_port_b(id); break;
		case REQ_PORT_A : proc_req_port_a(id); break;
		case REQ_PORT_B : proc_req_port_b(id); break;
		case CFG_INT_A 	: proc_cfg_int_a(id); break;
		case CFG_INT_B 	: proc_cfg_int_b(id); break;
		case REQ_CUSTOM_A : proc_req_custom_a(id); break;
		case Q_PUT 		: proc_q_put(id); break;
		case Q_GET 		: proc_q_get(id); break;
		case Q_SIZE 	: proc_q_size(id); break;
		case Q_CLEAR 	: proc_q_clear(id); break;
	}
}

	task void BCRadio_receive(){
		signal VM.queueEvt(RECEIVE, &ExtDataRadioReceived);		
	}

	event void BSRadio.receive(message_t* msg, void* payload, uint8_t len){
		dbg(APPNAME,"Custom::BSRadio.receive()\n");
		memcpy(&ExtDataRadioReceived,payload,sizeof(usrMsg_t));
		post BCRadio_receive();
	}

	event void BSRadio.sendDone(message_t *msg, error_t error){
		dbg(APPNAME,"Custom::BSRadio.sendDone(): error=%d\n",error);
		ExtDataSendDoneError = (uint8_t)error;
		signal VM.queueEvt(SEND_DONE, &ExtDataSendDoneError);
	}
	event void BSRadio.sendDoneAck(message_t *msg, error_t error, bool wasAcked){
		dbg(APPNAME,"Custom::BSRadio.sendDone(): error=%d, ack=%d\n",error,wasAcked);
		ExtDataWasAcked = (uint8_t)wasAcked;
		signal VM.queueEvt(SEND_DONE_ACK, &ExtDataWasAcked);
	}

	uint8_t wd2ceuSensorId(uint8_t wdId){
		switch (wdId & 0x01f){
			case SID_TEMP: return TEMP;
			case SID_PHOTO: return PHOTO;
			case SID_LEDS: return LEDS;
			case SID_VOLT: return VOLTS;
			case SID_IN1: return PORT_A;
			case SID_IN2: return PORT_B;
			case SID_INT1: return INT_A;
			case SID_INT2: return INT_B;
		}
		return 0;
	}
	event void SA.Ready(uint8_t reqSource, uint8_t codeEvt_id){
		dbg(APPNAME,"Custom::SA.Ready()\n");
		switch (reqSource) {
			case REQ_SOURCE1 : signal VM.queueEvt(wd2ceuSensorId(codeEvt_id), call SA.getDatap((uint8_t)(codeEvt_id & 0x1f))); break;			
//			case REQ_SOURCE2 : break;  // TBD
//			case REQ_SOURCE3 : break;  // TBD
//			case REQ_SOURCE4 : break;  // TBD
			default:dbg(APPNAME,"Custom::SA.Ready(): reqSource not defined - %d\n",reqSource);
		}
		
	}


/**
 * Custom usrDataueue
 */
	event void usrDataQ.dataReady(){
		dbg(APPNAME,"Custom::usrDataQ.dataReady()\n");
		// Queue the custom event
		ExtDataQReady = call usrDataQ.size();
		signal VM.queueEvt(Q_READY, &ExtDataQReady);
	}

}