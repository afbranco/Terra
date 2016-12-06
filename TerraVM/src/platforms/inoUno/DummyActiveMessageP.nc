module DummyActiveMessageP{
  provides {
    interface SplitControl;
    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];
    interface AMAux;
    interface LowPowerListening;
    interface Packet;
    interface AMPacket;
    interface PacketAcknowledgements;
 	}
}
implementation{

	task void startDone(){ signal SplitControl.startDone(SUCCESS);}	
	task void stopDone(){ signal SplitControl.stopDone(SUCCESS);}	

	command error_t SplitControl.start(){
		post startDone();
		return SUCCESS;
	}

	command error_t SplitControl.stop(){
		post stopDone();
		return SUCCESS;
	}

	command void * AMSend.getPayload[am_id_t id](message_t *msg, uint8_t len){
		return msg->data;
	}

	command error_t AMSend.cancel[am_id_t id](message_t *msg){
		return SUCCESS;
	}

	command uint8_t AMSend.maxPayloadLength[am_id_t id](){
		return TOSH_DATA_LENGTH;
	}

	am_id_t g_id;
	message_t* g_msg;
	task void sendDone(){signal AMSend.sendDone[g_id](g_msg, SUCCESS);}
	command error_t AMSend.send[am_id_t id](am_addr_t addr, message_t *msg, uint8_t len){
		g_id=id;
		g_msg = msg;
		post sendDone();	
		return SUCCESS;
	}

	command uint8_t AMAux.getPower(message_t *p_msg){
		return 0;
	}

	command void AMAux.setPower(message_t *p_msg, uint8_t power){
	}

	command void LowPowerListening.setLocalWakeupInterval(uint16_t intervalMs){
	}

	command uint16_t LowPowerListening.getLocalWakeupInterval(){
		return 0;
	}

	command void LowPowerListening.setRemoteWakeupInterval(message_t *msg, uint16_t intervalMs){
	}

	command uint16_t LowPowerListening.getRemoteWakeupInterval(message_t *msg){
		return 0;
	}

	command void * Packet.getPayload(message_t *msg, uint8_t len){
		return msg->data;
	}

	command void Packet.setPayloadLength(message_t *msg, uint8_t len){
	}

	command uint8_t Packet.maxPayloadLength(){
		return TOSH_DATA_LENGTH;
	}

	command void Packet.clear(message_t *msg){
	}

	command uint8_t Packet.payloadLength(message_t *msg){
		message_header_t *header = (message_header_t*)msg->header;
		return header->length;
	}

	command am_group_t AMPacket.localGroup(){
		return TOS_AM_GROUP;
	}

	command void AMPacket.setGroup(message_t *amsg, am_group_t grp){
		message_header_t *header = (message_header_t*)amsg->header;
		header->group = (nx_am_group_t)grp;
	}

	command am_group_t AMPacket.group(message_t *amsg){
		message_header_t *header = (message_header_t*)amsg->header;
		return header->group;
	}

	command void AMPacket.setType(message_t *amsg, am_id_t t){
		message_header_t *header = (message_header_t*)amsg->header;
		header->type = (nx_am_id_t)t;
	}

	command am_id_t AMPacket.type(message_t *amsg){
		message_header_t *header = (message_header_t*)amsg->header;
		return header->type;
	}

	command bool AMPacket.isForMe(message_t *amsg){
		message_header_t *header = (message_header_t*)amsg->header;
		return ( header->dest == TOS_NODE_ID || header->dest == AM_BROADCAST_ADDR);
	}

	command void AMPacket.setSource(message_t *amsg, am_addr_t addr){
		message_header_t *header = (message_header_t*)amsg->header;
		header->src = addr;
	}

	command void AMPacket.setDestination(message_t *amsg, am_addr_t addr){
		message_header_t *header = (message_header_t*)amsg->header;
		header->dest = addr;
	}

	command am_addr_t AMPacket.source(message_t *amsg){
		message_header_t *header = (message_header_t*)amsg->header;
		return header->src;
	}

	command am_addr_t AMPacket.destination(message_t *amsg){
		message_header_t *header = (message_header_t*)amsg->header;
		return header->dest;
	}

	command am_addr_t AMPacket.address(){
		return TOS_AM_ADDRESS;
	}

	async command error_t PacketAcknowledgements.requestAck(message_t *msg){
		return SUCCESS;
	}

	async command bool PacketAcknowledgements.wasAcked(message_t *msg){
		return TRUE;
	}

	async command error_t PacketAcknowledgements.noAck(message_t *msg){
		return SUCCESS;
	}
}