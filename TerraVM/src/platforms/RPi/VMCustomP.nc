#include "VMCustom.h"
#include "usrMsg.h"
#include "BasicServices.h"

module VMCustomP{
	provides interface VMCustom as VM;
	uses interface BSRadio;
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
nx_uint32_t ExtDataTimeStamp;		// last SLPL_FIRED - timestamp 
nx_uint8_t ExtDataGModelRdDone;		// last GModelReadDone Status 
nx_uint16_t ExtDataBufferRdDone;	// last StreamReadDone [error=0 | Count>0]
nx_int32_t* UsrStreamBuffer;		// Pointer to user data stream buffer

uint8_t MIC_flag;					// Indicate if Mic Sensor was setup
nx_uint16_t* MIC_buf;				// Mic Sensor read buffer
uint16_t MIC_count;				// Mic Sensor read count
uint32_t MIC_usPeriod;			// Mic Sensor read period
uint8_t MIC_gain;				// Mic Sensor gain adjust

/*
 * Output Events implementation
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
		case O_CUSTOM_A 	: proc_req_custom_a(id,value); break;
		case O_CUSTOM 		: proc_req_custom(id,value); break;
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

		}
	}

	command void VM.reset(){
		// Reset leds
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
 * Custom usrDataueue
 */
#ifdef M_MSG_QUEUE
	event void usrDataQ.dataReady(){
		dbg(APPNAME,"Custom::usrDataQ.dataReady()\n");
		// Queue the custom event
		ExtDataQReady = call usrDataQ.size();
		signal VM.queueEvt(I_Q_READY, 0, &ExtDataQReady);
	}
#endif


}
