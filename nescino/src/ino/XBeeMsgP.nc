
#include "XBeeApi.h"
#define RADIO_SEND_TIMEOUT 500

module XBeeMsgP{
	provides interface AMSend[am_id_t id];
	provides interface Receive[am_id_t id];
	provides interface xLog;
	provides interface SplitControl;
	provides interface PacketAcknowledgements;
	provides interface AMPacket;
	provides interface Packet;
	provides interface RadioPacket;
	
	uses interface Boot;
	uses interface XBeeApi;
	uses interface Timer<TMilli> as SendTimeOut;
}
implementation{
	uint8_t currAckId, radioBusy, initFlag;
	message_t* lastSend_p;
	
	event void Boot.booted(){
		currAckId = 1;
		initFlag = TRUE;
		radioBusy = TRUE;
	}

/**
 * Split control
 */
	

	command error_t SplitControl.start(){
		call SendTimeOut.startOneShot(RADIO_SEND_TIMEOUT);
//		call XBeeApi.commandAT(currAckId, "FR", NULL, 0);
		call XBeeApi.commandAT(currAckId, "MY", NULL, 0);
		return SUCCESS;
	}

	command error_t SplitControl.stop(){
		// TODO Auto-generated method stub
		return SUCCESS;
	}
	
	
/**
 * Send Msg control
 */

	command error_t AMSend.send[am_id_t id](am_addr_t addr, message_t *msg, uint8_t len){
		if (radioBusy == TRUE) return EBUSY;
		radioBusy = TRUE;
		msg->amid = id;
		msg->source = TOS_NODE_ID;
		msg->target = addr;
		msg->len = len;
		lastSend_p = msg;
		//signal xLog.logUSB0("#\n", 2);
		call XBeeApi.txReq(currAckId, addr, msg->opt, (uint8_t*)msg, (uint8_t)(sizeof(message_t) - TOSH_DATA_LENGTH + len));
		call SendTimeOut.startOneShot(RADIO_SEND_TIMEOUT);
		return SUCCESS;
	}

	event void XBeeApi.txReqDone(error_t status){
		// If it get a send error, return a sendDone with the error
		if (status != SUCCESS){
			radioBusy = FALSE;
			call SendTimeOut.stop();
			signal AMSend.sendDone[lastSend_p->amid](lastSend_p, status);
		}
	}

	event void XBeeApi.txStatus(uint8_t ackId, uint8_t status){
		currAckId++; if (currAckId==0) currAckId++;
		radioBusy = FALSE;
		call SendTimeOut.stop();
		signal AMSend.sendDone[lastSend_p->amid](lastSend_p, status);
	}

	event void SendTimeOut.fired(){
		uint8_t status;
		if (initFlag){
			call SendTimeOut.startOneShot(RADIO_SEND_TIMEOUT);
//			call XBeeApi.commandAT(currAckId, "FR", NULL, 0);
			call XBeeApi.commandAT(currAckId, "MY", NULL, 0);
		} else {
			radioBusy = FALSE;
			status = FAIL;
			signal AMSend.sendDone[lastSend_p->amid](lastSend_p, status);
		}
	}

	command error_t AMSend.cancel[am_id_t id](message_t *msg){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

	command void * AMSend.getPayload[am_id_t id](message_t *msg, uint8_t len){
		return msg->data;
	}

	command uint8_t AMSend.maxPayloadLength[am_id_t id](){
		return TOSH_DATA_LENGTH;
	}

/**
 * Receive message
 */
	event void XBeeApi.rxPacket(nx_uint16_t source, uint8_t rssi, uint8_t opt, uint8_t *Data, uint8_t dataLen){
		((message_t*)Data)->source = source;
		((message_t*)Data)->opt = opt;
		((message_t*)Data)->rssi = rssi;
		signal Receive.receive[((message_t*)Data)->amid]((message_t*)Data, ((message_t*)Data)->data, dataLen -(uint8_t)(sizeof(message_t) - 28));
	}


/**
 * Receive Automatic IO Reads
 */

	event void XBeeApi.rxPacketIO(nx_uint16_t source, uint8_t rssi, uint8_t opt, uint8_t *Data, uint8_t dataLen){
		// TODO Auto-generated method stub
	}


/**
 * Local AT Command
 */

	event void XBeeApi.commandATDone(error_t status){}

	event void XBeeApi.responseAT(uint8_t ackId, uint8_t *cmd, uint8_t status, uint8_t *values, uint8_t valuesLen){

		
		if (cmd[0]=='M' && cmd[1]=='Y'){
			call SendTimeOut.stop();
			TOS_NODE_ID = values[0]*256 + values[1];			
			initFlag=FALSE;
			radioBusy = FALSE;
			signal SplitControl.startDone(SUCCESS);
		}
/*
		{
		uint8_t logData[10];
		logData[0] = 'A';
		logData[1] = 'R';
		logData[2] = ':';
		logData[3] = cmd[0];
		logData[4] = cmd[1];
		logData[5] = '0'+status;
		logData[6] = '\n';
		signal xLog.logUSB0(logData, 7);
		}
*/
 	}

	event void XBeeApi.commandATQueueDone(error_t status){
		// TODO Auto-generated method stub
	}


/**
 * Remote AT Command
 */
	event void XBeeApi.remCommandATDone(error_t status){
		// TODO Auto-generated method stub
	}

	event void XBeeApi.remResponseAT(uint8_t ackId, nx_uint16_t source, uint8_t *cmd, uint8_t status, uint8_t *values, uint8_t valuesLen){
		// TODO Auto-generated method stub
	}


/**
 * Network status events
 */

	event void XBeeApi.modemStatus(uint8_t status){		
/*
		{uint8_t logData[10];
		logData[0] = '+';
		logData[1] = '<';
		logData[2] = '0'+status;
		logData[3] = '>';
		logData[4] = '\n';
		signal xLog.logUSB0(logData, 5);}
*/
 	}
/**
 * Log USB0 function
 */
	event void XBeeApi.logUSB0(uint8_t *data, uint8_t len){
		signal xLog.logUSB0(data, len);
	}

/**
 * PacketAcknowledgements interface
 */

	async command error_t PacketAcknowledgements.requestAck(message_t *msg){
		msg->opt = 0;
		return SUCCESS;
	}

	async command bool PacketAcknowledgements.wasAcked(message_t *msg){
		return msg->opt==0;
	}

	async command error_t PacketAcknowledgements.noAck(message_t *msg){
		msg->opt = 1;
		return SUCCESS;
	}

/**
 * AMPacket interface
 */

	command am_id_t AMPacket.type(message_t *amsg){
		return amsg->amid;
	}

	command am_addr_t AMPacket.address(){
		return TOS_NODE_ID;
	}

	command am_group_t AMPacket.localGroup(){
		// TODO Auto-generated method stub
		return 0;
	}

	command void AMPacket.setGroup(message_t *amsg, am_group_t grp){
		amsg->group = grp;
	}

	command am_addr_t AMPacket.destination(message_t *amsg){
		return amsg->target;
	}

	command void AMPacket.setType(message_t *amsg, am_id_t t){
		amsg->amid = t;
	}

	command am_addr_t AMPacket.source(message_t *amsg){
		return amsg->source;
	}

	command bool AMPacket.isForMe(message_t *amsg){
		return (TOS_NODE_ID == amsg->target);
	}

	command am_group_t AMPacket.group(message_t *amsg){
		return amsg->group;
	}

	command void AMPacket.setDestination(message_t *amsg, am_addr_t addr){
		amsg->target = (nx_uint16_t)addr;
	}

	command void AMPacket.setSource(message_t *amsg, am_addr_t addr){
		amsg->source = (nx_uint16_t)addr;
	}

/**
 * RadioPacket interface
 */

	async command void RadioPacket.clear(message_t *msg){
		// TODO Auto-generated method stub
	}

	async command void RadioPacket.setPayloadLength(message_t *msg, uint8_t length){
		msg->len = length;
	}

	async command uint8_t RadioPacket.payloadLength(message_t *msg){
		return msg->len;
	}

	async command uint8_t RadioPacket.headerLength(message_t *msg){
		return (sizeof(message_t)-TOSH_DATA_LENGTH);
	}

	async command uint8_t RadioPacket.maxPayloadLength(){
		return TOSH_DATA_LENGTH;
	}

	async command uint8_t RadioPacket.metadataLength(message_t *msg){
		return 0;
	}
	
/**
 * Packet interface
 */
	
	command void Packet.setPayloadLength(message_t *msg, uint8_t len){
		msg->len = len;
	}

	command uint8_t Packet.payloadLength(message_t *msg){
		return msg->len;
	}

	command void Packet.clear(message_t *msg){
		// TODO Auto-generated method stub
	}

	command void * Packet.getPayload(message_t *msg, uint8_t len){
		return msg->data;
	}

	command uint8_t Packet.maxPayloadLength(){
		return TOSH_DATA_LENGTH;
	}
}