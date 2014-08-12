/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#include "VMCustomNet.h"
#include "usrMsg.h"
#include "BasicServices.h"

module VMCustomP{
	provides interface VMCustom as VM;
	uses interface BSRadio;
	uses interface SensAct as SA;
	uses interface Random;

	// usrMsg queue
	uses interface dataQueue as usrDataQ;
}
implementation{

// Keeps last data value for events (ExtDataxxx must be nx_ type. Because it is copied direct to VM memory.)
nx_uint8_t ExtDataSysError;				// last system error code
nx_uint8_t ExtDataCustomA;				// last request custom event (internal loop-back)
usrMsg_t ExtDataRadioReceived;	// last radio received msg
nx_uint8_t ExtDataSendDoneError;
nx_uint8_t ExtDataWasAcked;
nx_uint8_t ExtDataQReady;			// last queue ready - queue size 
nx_uint32_t ExtDataTimeStamp;		// last SLPL_FIRED - timestamp 

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
void  proc_leds(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_leds(): id=%d, val=%d\n",id,(uint8_t)value);
	call SA.setActuator(AID_LEDS, (uint8_t)(value & 0x07));
}
void  proc_led0(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led0(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED0_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED0, (uint8_t)(value & 0x01));
}
void  proc_led1(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led1(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED1_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED1, (uint8_t)(value & 0x01));
}
void  proc_led2(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led2(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED2_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED2, (uint8_t)(value & 0x01));
}
void  proc_req_temp(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_temp(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_TEMP);
	}
void  proc_req_photo(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_photo(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_PHOTO);
	}
void  proc_req_volts(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_volts(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_VOLT);
	}

void  proc_send_x(uint16_t id,uint16_t addr,uint8_t ack){
	usrMsg_t* usrMsg;
	uint8_t reqRetryAck;
	usrMsg = (usrMsg_t*)signal VM.getRealAddr(addr,2);
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


void  proc_set_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_set_port_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_OUT1, (uint8_t)(value & 0x01));
}
void  proc_set_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_set_port_b(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_OUT2, (uint8_t)(value & 0x01));
}
void  proc_cfg_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_port_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_PIN1, (uint8_t)(value & 0x01));
}
void  proc_cfg_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_port_b(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_PIN2, (uint8_t)(value & 0x01));
}
void  proc_req_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_port_a(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_IN1);
	}
void  proc_req_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_port_b(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_IN2);
	}
void  proc_cfg_int_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_int_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_INT1, (uint8_t)value);
	}
void  proc_cfg_int_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_int_b(): id=%d value=%d\n",id,value);
	call SA.setActuator(AID_INT2, (uint8_t)value);
	}
void  proc_req_custom_a(uint16_t id, uint32_t value){
	uint8_t auxId ;
	ExtDataCustomA = (uint8_t)value;
	dbg(APPNAME,"Custom::proc_req_custom_a(): id=%d, ExtDataCustomA=%d\n",id,ExtDataCustomA);
	auxId = (uint8_t)signal VM.pop();
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
void  func_qPut(uint16_t id){
	error_t stat;
	qData_t* qData_p;
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::func_qPut(): id=%d, addr=%d\n",id,value);
	// queue the usrMsg data
	qData_p = (qData_t*)signal VM.getRealAddr(value,2);
	stat = call usrDataQ.put(qData_p);
	signal VM.push(stat);
	}
void  func_qGet(uint16_t id){
	error_t stat;
	qData_t* qData_p;
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::func_qGet(): id=%d, addr=%d\n",id,value);
	// get the usrMsg data
	qData_p = (qData_t*)signal VM.getRealAddr(value,2);
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
		case O_TEMP 	: proc_req_temp(id,value); break;
		case O_PHOTO 	: proc_req_photo(id,value); break;
		case O_VOLTS 	: proc_req_volts(id,value); break;
		case O_SEND 		: proc_send(id,value); break;
		case O_SEND_ACK 	: proc_send_ack(id,value); break;
		case O_PORT_A : proc_set_port_a(id,value); break;
		case O_PORT_B : proc_set_port_b(id,value); break;
		case O_CFG_PORT_A : proc_cfg_port_a(id,value); break;
		case O_CFG_PORT_B : proc_cfg_port_b(id,value); break;
		case O_REQ_PORT_A : proc_req_port_a(id,value); break;
		case O_REQ_PORT_B : proc_req_port_b(id,value); break;
		case O_CFG_INT_A 	: proc_cfg_int_a(id,value); break;
		case O_CFG_INT_B 	: proc_cfg_int_b(id,value); break;
		case O_CUSTOM_A : proc_req_custom_a(id,value); break;
	}
}


	command void VM.callFunction(uint8_t id){
		dbg(APPNAME,"Custom::VM.callFunction(%d)\n",id);
		switch (id){
			case F_GETNODEID: func_getNodeId(id); break;
			case F_RANDOM 	: func_random(id); break;
			case F_QPUT 	: func_qPut(id); break;
			case F_QGET 	: func_qGet(id); break;
			case F_QSIZE 	: func_qSize(id); break;
			case F_QCLEAR 	: func_qClear(id); break;		
		}
	}

	command void VM.reset(){
		// Reset leds
		call SA.setActuator(AID_LEDS, 0);
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

	uint8_t wd2ceuSensorId(uint8_t wdId){
		switch (wdId & 0x01f){
			case SID_TEMP: return I_TEMP;
			case SID_PHOTO: return I_PHOTO;
			case SID_VOLT: return I_VOLTS;
			case SID_IN1: return I_PORT_A;
			case SID_IN2: return I_PORT_B;
			case SID_INT1: return I_INT_A;
			case SID_INT2: return I_INT_B;
		}
		return 0;
	}
	event void SA.Ready(uint8_t reqSource, uint8_t codeEvt_id){
		dbg(APPNAME,"Custom::SA.Ready()\n");
		switch (reqSource) {
			case REQ_SOURCE1 : signal VM.queueEvt(wd2ceuSensorId(codeEvt_id), 0, call SA.getDatap((uint8_t)(codeEvt_id & 0x1f))); break;			
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
		signal VM.queueEvt(I_Q_READY, 0, &ExtDataQReady);
	}

}