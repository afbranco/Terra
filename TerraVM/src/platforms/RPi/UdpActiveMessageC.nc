module UdpActiveMessageC{
	
  provides {
    interface SplitControl;

    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];

    interface Packet;
    interface AMPacket;
    interface PacketAcknowledgements;
    interface LowPowerListening;
    interface AMAux;
  }
}
implementation{
	
	
	command error_t SplitControl.start(){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

	command error_t SplitControl.stop(){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

	command uint8_t AMSend.maxPayloadLength[am_id_t id](){
		// TODO Auto-generated method stub
		return 0;
	}

	command void * AMSend.getPayload[am_id_t id](message_t *msg, uint8_t len){
		// TODO Auto-generated method stub
		return msg;
	}

	command error_t AMSend.send[am_id_t id](am_addr_t addr, message_t *msg, uint8_t len){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

	command error_t AMSend.cancel[am_id_t id](message_t *msg){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

	command void Packet.clear(message_t *msg){
		// TODO Auto-generated method stub
	}

	command uint8_t Packet.payloadLength(message_t *msg){
		// TODO Auto-generated method stub
		return 0;
	}

	command void * Packet.getPayload(message_t *msg, uint8_t len){
		// TODO Auto-generated method stub
		return msg;
	}

	command void Packet.setPayloadLength(message_t *msg, uint8_t len){
		// TODO Auto-generated method stub
	}

	command uint8_t Packet.maxPayloadLength(){
		// TODO Auto-generated method stub
		return 0;
	}

	command bool AMPacket.isForMe(message_t *amsg){
		// TODO Auto-generated method stub
		return TRUE;
	}

	command void AMPacket.setSource(message_t *amsg, am_addr_t addr){
		// TODO Auto-generated method stub
	}

	command void AMPacket.setType(message_t *amsg, am_id_t t){
		// TODO Auto-generated method stub
	}

	command am_id_t AMPacket.type(message_t *amsg){
		// TODO Auto-generated method stub
		return 0;
	}

	command void AMPacket.setGroup(message_t *amsg, am_group_t grp){
		// TODO Auto-generated method stub
	}

	command am_group_t AMPacket.group(message_t *amsg){
		// TODO Auto-generated method stub
		return 0;
	}

	command am_group_t AMPacket.localGroup(){
		// TODO Auto-generated method stub
		return 0;
	}

	command am_addr_t AMPacket.destination(message_t *amsg){
		// TODO Auto-generated method stub
		return 0;
	}

	command am_addr_t AMPacket.address(){
		// TODO Auto-generated method stub
		return 0;
	}

	command void AMPacket.setDestination(message_t *amsg, am_addr_t addr){
		// TODO Auto-generated method stub
	}

	command am_addr_t AMPacket.source(message_t *amsg){
		// TODO Auto-generated method stub
		return 0;
	}

	async command error_t PacketAcknowledgements.requestAck(message_t *msg){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

	async command bool PacketAcknowledgements.wasAcked(message_t *msg){
		// TODO Auto-generated method stub
		return TRUE;
	}

	async command error_t PacketAcknowledgements.noAck(message_t *msg){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

	command uint16_t LowPowerListening.getLocalWakeupInterval(){
		// TODO Auto-generated method stub
		return 0;
	}

	command void LowPowerListening.setLocalWakeupInterval(uint16_t intervalMs){
		// TODO Auto-generated method stub
	}

	command uint16_t LowPowerListening.getRemoteWakeupInterval(message_t *msg){
		// TODO Auto-generated method stub
		return 0;
	}

	command void LowPowerListening.setRemoteWakeupInterval(message_t *msg, uint16_t intervalMs){
		// TODO Auto-generated method stub
	}

	command uint8_t AMAux.getPower(message_t *p_msg){
		// TODO Auto-generated method stub
		return 0;
	}

	command void AMAux.setPower(message_t *p_msg, uint8_t power){
		// TODO Auto-generated method stub
	}
}