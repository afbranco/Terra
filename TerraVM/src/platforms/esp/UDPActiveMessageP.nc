#include "espconn.h"
#include "UDPActiveMessage.h"

module UDPActiveMessageP{
	
	provides{		
		interface SplitControl;
		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];		
    	interface Receive as Snoop[am_id_t id];
		interface AMPacket;
		interface Packet;
		interface PacketAcknowledgements;
		
    	interface LowPowerListening;
    	interface AMAux;	
	}
	
	uses interface Timer<TMilli> as sendDoneTimer;
	uses interface Timer<TMilli> as timerDelay;
	uses interface Timer<TMilli> as timerCheckConn;
	
}
implementation{	
	int socket_sender;
	int socket_receiver;

	int counter = 0;
	message_t* lastSendMessage;
	message_t lastReceiveMessage;	
	struct sockaddr_in addrSender;	

	LOCAL struct espconn espconnSender;
	LOCAL struct espconn espconnReceiver;
	LOCAL esp_udp udpSender, udpReceiver;

	serial_header_t* ONE getHeader(message_t* ONE msg) {
		return TCAST(serial_header_t* ONE, (uint8_t*)msg + offsetof(message_t, data) - sizeof(serial_header_t));
	}
	serial_metadata_t* getMetadata(message_t* msg) {
		return (serial_metadata_t*)(msg->metadata);
	}
  
	task void send_doneAck(){
		getMetadata(lastSendMessage)->ackID = TRUE;
		signal AMSend.sendDone[getHeader(lastSendMessage)->type](lastSendMessage, SUCCESS);
	}
	
	task void send_done(){
		getMetadata(lastSendMessage)->ackID = FALSE;
		signal AMSend.sendDone[getHeader(lastSendMessage)->type](lastSendMessage, SUCCESS);
	}
	
	task void start_done(){ 
		signal SplitControl.startDone(SUCCESS);
		}
	task void start_done_fail(){ signal SplitControl.startDone(FAIL);}
	task void stop_done(){signal SplitControl.stopDone(SUCCESS);}
	

	void task receiveTask(){
		signal Receive.receive[call AMPacket.type(&lastReceiveMessage)](&lastReceiveMessage, call Packet.getPayload(&lastReceiveMessage, call Packet.payloadLength(&lastReceiveMessage)), call Packet.payloadLength(&lastReceiveMessage));
	}	

	void user_udp_recv_cb(void *arg, char *dgram, unsigned short length) {
		message_t *msg;
		ackMessage_t receiveAckMsg;
		int size;
		
		size = length;
		if (size < 0) { dbgerror("UDP","UDP::Ignoring message with size < 0\n"); return;}

		if ((*(nx_uint16_t*)dgram) == ACK_CODE){
			// verificando se eh pra mim
			memcpy (&receiveAckMsg, (ackMessage_t*)dgram, sizeof(ackMessage_t));
			if (receiveAckMsg.dest == TOS_NODE_ID){
//				os_printf("Recebi mensagem ACK %d\n", (*(nx_uint16_t*)dgram));
//				os_printf("EH ACK! Dest: %d Src: %d AckID: %d\n", receiveAckMsg.dest, receiveAckMsg.src, receiveAckMsg.ackID);
//				os_printf("Tos_node_id: %d, ackID: %d, dest: %d, Timer: %s\n", TOS_NODE_ID, getHeader(lastSendMessage)->ackID, getHeader(lastSendMessage)->dest, (call sendDoneTimer.isRunning())?"true":"false");
	
				dbg("UDP","UDP::received an ack: %d \n", (uint16_t)call sendDoneTimer.getNow());
				if (receiveAckMsg.src == getHeader(lastSendMessage)->dest
							&& receiveAckMsg.ackID == getMetadata(lastSendMessage)->ackID
						&& call sendDoneTimer.isRunning()){
					dbg("UDP","UDP::ACK RECEBIDO\n");
					call sendDoneTimer.stop();
					post send_doneAck();				
				}	
			}	
		}
		else{ // eh o msg_t
			msg = (message_t*) dgram;
	
			if (call AMPacket.isForMe(msg)) {	
				memcpy(&lastReceiveMessage, msg, sizeof(message_t));
				dbg("UDP","UDP::Received from %d -- reqAck: %d\n", call AMPacket.source(msg), getMetadata(msg)->ackID);

				// soh mando ack se for pra mim e se o remente requerir
				if (getMetadata(msg)->ackID != 0 && getHeader(msg)->dest == TOS_NODE_ID){
					call timerDelay.startOneShot(1); // ack mto rápido
				}
				post receiveTask();
			}
		}		
	}

	// ESP USP send done event
	void user_udp_sent_cb(void *arg) {
		struct espconn *pespconn = arg;
		// sucesso no send sem ack
		if(getMetadata(lastSendMessage)->ackID == 0)
			post send_done();
		else{ // inicio timeout do ack
			call sendDoneTimer.startOneShot(SENDDONE_WAITTIME);
		}
	}

	// Check IP connection was done
	event void timerCheckConn.fired(){
		struct ip_info ipconfig;
		//get ip info of ESP8266 station
		wifi_get_ip_info(STATION_IF, &ipconfig);	
	    if (wifi_station_get_connect_status() == STATION_GOT_IP && ipconfig.ip.addr != 0) {
			const char udp_remote_ip[4] = GROUP_BYTES; 
			const int port = PORT;
			ip_addr_t multicastIP, hostIP;
			//os_printf("got ip: %s \r\n",IP2STR(ipconfig.ip.addr));
			wifi_set_broadcast_if(STATIONAP_MODE); // send UDP broadcast from both station and soft-AP interface
			
			espconnSender.type = ESPCONN_UDP;
			espconnSender.proto.udp = &udpSender;
			espconnSender.proto.udp->local_port = espconn_port();  // set a available  port
	     
			espconnSender.proto.udp->remote_port = port;  // ESP8266 udp remote port
			os_memcpy(espconnSender.proto.udp->remote_ip, udp_remote_ip, 4); // ESP8266 udp remote IP

			// Join in the multicast ip addr
			IP4_ADDR(&multicastIP,udp_remote_ip[0],udp_remote_ip[1],udp_remote_ip[2],udp_remote_ip[3]);
			hostIP.addr = ipconfig.ip.addr;
			espconn_igmp_join(&hostIP,&multicastIP);

			//espconn_regist_recvcb(&user_udp_espconn, user_udp_recv_cb); // register a udp packet receiving callback
			espconn_regist_sentcb(&espconnSender, user_udp_sent_cb); // register a udp packet sent callback
			espconn_create(&espconnSender);   // create udp
			
			// Register a receiver conn
			espconnReceiver.type = ESPCONN_UDP;
			espconnReceiver.proto.udp = &udpReceiver;
			espconnReceiver.proto.udp->local_port = port;
			os_memcpy(espconnReceiver.proto.udp->remote_ip, udp_remote_ip, 4);
			espconn_regist_recvcb(&espconnReceiver, user_udp_recv_cb);
			espconn_create(&espconnReceiver);
		
			// Set global NODE_ID -- removed! NODE_ID comes from compilation time
//			TOS_NODE_ID = (uint16_t)((ipconfig.ip.addr >> 16)*256 + (ipconfig.ip.addr >> 24)); //(ip4_addr3(ipconfig.ip.addr)*256 + ip4_addr4(ipconfig.ip.addr));
			post start_done(); // signal a succesful start done 
		} else {
			if ((wifi_station_get_connect_status() == STATION_WRONG_PASSWORD ||
	                wifi_station_get_connect_status() == STATION_NO_AP_FOUND ||
	                wifi_station_get_connect_status() == STATION_CONNECT_FAIL)) {
				dbgerror("UDP","UDP::Conncetion fail - status=%d",wifi_station_get_connect_status());
				post start_done_fail();
			} else {
	           //re-arm timer to check ip
	           call timerCheckConn.startOneShot(100);
	        }
	    }
	}

	event void timerDelay.fired(){	
		ackMessage_t ackMsg;
 		const char udp_remote_ip[4] = GROUP_BYTES;
 		uint8_t stat; 
	
		ackMsg.ackCode = ACK_CODE;
		ackMsg.src = TOS_NODE_ID;
		ackMsg.dest = getHeader(&lastReceiveMessage)->src;
		ackMsg.ackID = getMetadata(&lastReceiveMessage)->ackID;
	
		// Send Ack message via ESP UDP
		os_memcpy(espconnSender.proto.udp->remote_ip, udp_remote_ip, 4); // ESP8266 udp remote IP need to be set everytime we call espconn_sent
 		espconnSender.proto.udp->remote_port = PORT;  // ESP8266 udp remote port need to be set everytime we call espconn_sent
		stat=espconn_sendto(&espconnSender, (char*)&ackMsg, sizeof(ackMessage_t));
		if (stat != 0) {
			dbgerror("UDP","UDP ERROR:: Fail to send Ack! stat=%d\n",stat);
		}

	}
	

	command error_t SplitControl.start(){
		char ssid[32] = WIFI_SSID ;
		char password[64] = WIFI_PASSWORD ;
		struct station_config stationConf;

		int status;

	    //Set station mode
	    wifi_set_opmode(STATION_MODE);

		//Set ap settings
		stationConf.bssid_set = 0; //do not need mac address
		os_memcpy(&stationConf.ssid, ssid, 32);
		os_memcpy(&stationConf.password, password, 64);
		wifi_station_set_config(&stationConf);
	
		//set a timer to check whether got ip from router succeed or not.
		call timerCheckConn.startOneShot(100);	

		return SUCCESS;
	}
	
	event void sendDoneTimer.fired(){
		getMetadata(lastSendMessage)->ackID = FALSE;
		signal AMSend.sendDone[getHeader(lastSendMessage)->type](lastSendMessage, SUCCESS);
	}

	command error_t AMSend.send[am_id_t id](am_addr_t am_addr, message_t *msg, uint8_t len){

		message_header_t *header;
		uint8_t stat;
 		const char udp_remote_ip[4] = GROUP_BYTES; 
		const int port = PORT;

		call AMPacket.setSource(msg, TOS_NODE_ID);
		call AMPacket.setDestination(msg, am_addr);
		call AMPacket.setGroup(msg, TOS_AM_GROUP);
		call AMPacket.setType(msg, id);
		dbg("UDP","UDP::Sending to %d am_d=%d\n",am_addr,id);
		// setar o counter se houver ack
		if (getMetadata(msg)->ackID != 0){			
			counter = (counter==0)?1:counter+1; // se for diferente de zero, mantém; caso contrário, soma
			getMetadata(msg)->ackID = counter;
		}
		lastSendMessage = msg; // salva o endereço da ultima mensagem

		// Send message via ESP UDP
 		espconnSender.proto.udp->remote_port = port;  // ESP8266 udp remote port need to be set everytime we call espconn_sent
		os_memcpy(espconnSender.proto.udp->remote_ip, udp_remote_ip, 4); // ESP8266 udp remote IP need to be set everytime we call espconn_sent
		stat=espconn_sendto(&espconnSender, (char*)msg, sizeof(message_t));
		if (stat != 0) {
			dbgerror("UDP","UDP ERROR:: Fail to send data! stat=%d\n",stat);
			return FAIL;
		}
		return SUCCESS;		
	}

	command error_t AMSend.cancel[am_id_t id](message_t *msg){
		return FAIL;
	}

	command uint8_t AMSend.maxPayloadLength[am_id_t id](){
		return call Packet.maxPayloadLength();
	}

	command void * AMSend.getPayload[am_id_t id](message_t *msg, uint8_t len){ 
		return call Packet.getPayload(msg, len);
	}

	command bool AMPacket.isForMe(message_t *amsg){
		return (call AMPacket.destination(amsg) == call AMPacket.address() ||
				call AMPacket.destination(amsg) == AM_BROADCAST_ADDR);
	}

	command void AMPacket.setSource(message_t *amsg, am_addr_t addr){ 
		serial_header_t* header = getHeader(amsg);
		header->src = addr;
	}

	command void AMPacket.setType(message_t *amsg, am_id_t t){ 
		serial_header_t* header = getHeader(amsg);
		header->type = t;
	}

	command am_id_t AMPacket.type(message_t *amsg){ 
		serial_header_t* header = getHeader(amsg);
		return header->type;
	}

	command am_addr_t AMPacket.destination(message_t *amsg){ 
		serial_header_t* header = getHeader(amsg);
		return header->dest;
	}

	command am_addr_t AMPacket.address(){
		return TOS_NODE_ID;
	}

	command void AMPacket.setDestination(message_t *amsg, am_addr_t addr){ 
		serial_header_t* header = getHeader(amsg);
		header->dest = addr;
	}

	command am_addr_t AMPacket.source(message_t *amsg){ 
		serial_header_t* header = getHeader(amsg);
		return header->src;
	}

	command void AMPacket.setGroup(message_t *amsg, am_group_t grp){ 
		serial_header_t* header = getHeader(amsg);
		header->group = grp;
	}

	command am_group_t AMPacket.group(message_t *amsg){ 
		serial_header_t* header = getHeader(amsg);
		return header->group;
	}

	command am_group_t AMPacket.localGroup(){ 
		return TOS_AM_GROUP;
	}

	command void Packet.setPayloadLength(message_t *msg, uint8_t len){ 
		getHeader(msg)->length  = len;
	}

	command uint8_t Packet.payloadLength(message_t *msg){ 		
		serial_header_t* header = getHeader(msg); 		
		return header->length;
	}

	command void * Packet.getPayload(message_t *msg, uint8_t len){ 
		if (len > call Packet.maxPayloadLength()) {
			return NULL;
		}
		else {
			return (void * COUNT_NOK(len))msg->data;
		}
	}

	command uint8_t Packet.maxPayloadLength(){ 
		return TOSH_DATA_LENGTH;;
	}

	command void Packet.clear(message_t *msg){ 
		memset(getHeader(msg), 0, sizeof(serial_header_t));
		return;
	}


	command error_t SplitControl.stop(){ 
// TODO TODO
/*..
		dbg("UDP","UDP::Closing sockets..\n");
		close(socket_sender);
		close(socket_receiver);
		dbg("UDP","UDP::Stopped..\n");
		post stop_done();
		return SUCCESS;
*/
	}

	async command bool PacketAcknowledgements.wasAcked(message_t *msg){
	
		return getMetadata(msg)->ackID == ACK_TRUE;
	}

	async command error_t PacketAcknowledgements.requestAck(message_t *msg){
		// tem ack
		getMetadata(msg)->ackID = ACK_TRUE;
		return SUCCESS;
	}

	async command error_t PacketAcknowledgements.noAck(message_t *msg){
		// não tem ack
		getMetadata(msg)->ackID = ACK_FALSE;
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