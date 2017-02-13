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
	
}
implementation{	
	
	int socket_sender;
	int socket_receiver;

	int counter = 0;
	message_t* lastSendMessage;
	message_t lastReceiveMessage;	
	struct sockaddr_in addrSender;	
	
	serial_header_t* ONE getHeader(message_t* ONE msg) {
		return TCAST(serial_header_t* ONE, (uint8_t*)msg + offsetof(message_t, data) - sizeof(serial_header_t));
	}
	
	serial_metadata_t* getMetadata(message_t* msg) {
		return (serial_metadata_t*)(msg->metadata);
	}

	uint16_t getID_fromIP(){
	
		struct ifaddrs *ifaddr, *ifa;
			int family, s;
		char host[NI_MAXHOST];
		unsigned int addrHost[4];

		if (getifaddrs(&ifaddr) == -1) {
			perror("getifaddrs");
			exit(EXIT_FAILURE);
		}

		/* Walk through linked list, maintaining head pointer so we
		can free list later */

		for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
			if (ifa->ifa_addr == NULL)
				continue;
	
			family = ifa->ifa_addr->sa_family;
	
			if (family == AF_INET){
				s = getnameinfo(ifa->ifa_addr, sizeof(struct sockaddr_in), host, NI_MAXHOST, NULL, 0, NI_NUMERICHOST);
				if (s != 0) {
					dbgerror("UDP","UDP::getnameinfo() failed: %s\n", gai_strerror(s));
					exit(EXIT_FAILURE);
				}
	
				sscanf(host, "%u.%u.%u.%u", &addrHost[0], &addrHost[1], &addrHost[2], &addrHost[3]);
	
				if (addrHost[0] != 127) return (uint16_t) (addrHost[2]*256 + addrHost[3]);
			}
		}
		return 0;
	}
	
	task void send_doneAck(){
		getMetadata(lastSendMessage)->ackID = TRUE;
		signal AMSend.sendDone[getHeader(lastSendMessage)->type](lastSendMessage, SUCCESS);
	}
	
	task void send_done(){
		getMetadata(lastSendMessage)->ackID = FALSE;
		signal AMSend.sendDone[getHeader(lastSendMessage)->type](lastSendMessage, SUCCESS);
	}
	
	void task receiveTask(){
		signal Receive.receive[call AMPacket.type(&lastReceiveMessage)](&lastReceiveMessage, call Packet.getPayload(&lastReceiveMessage, call Packet.payloadLength(&lastReceiveMessage)), call Packet.payloadLength(&lastReceiveMessage));
	}

	void UDP_HandleReceiver(int signum)
	{
		char dgram[MAX_LENGTH];
		struct sockaddr_in addr;
		int fromlen = sizeof(addr);
		message_t *msg;
		ackMessage_t receiveAckMsg;
		int size;
		//struct sockaddr *addrRcv;
		//struct socklen_t *addRcvLen;
		size = recvfrom(socket_receiver, dgram, MAX_LENGTH, 0, (struct sockaddr*)&addr, (socklen_t*)&fromlen);
//printf("Received some data - len=%d\n",size);	
		dbgerror("UDP","UDP::UDP_HandleReceiver() - Received some data - len=%d\n",size);

		if (size < 0) dbgerror("UDP","UDP::Erro recvfrom\n"); // incluir o signal do receive()
		else{
				dgram[size]='\0';	
		}
		if ((*(nx_uint16_t*)dgram) == ACK_CODE){
			// verificando se eh pra mim
			memcpy (&receiveAckMsg, (ackMessage_t*)dgram, sizeof(ackMessage_t));
			if (receiveAckMsg.dest == TOS_NODE_ID){
//				printf("Recebi mensagem ACK %d\n", (*(nx_uint16_t*)dgram));
//				printf("EH ACK! Dest: %d Src: %d AckID: %d\n", receiveAckMsg.dest, receiveAckMsg.src, receiveAckMsg.ackID);
//				printf("Tos_node_id: %d, ackID: %d, dest: %d, Timer: %s\n", TOS_NODE_ID, getMetadatata(lastSendMessage)->ackID, getHeader(lastSendMessage)->dest, (call sendDoneTimer.isRunning())?"true":"false");
	
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

	event void timerDelay.fired(){	
		ackMessage_t ackMsg;
	
		ackMsg.ackCode = ACK_CODE;
		ackMsg.src = TOS_NODE_ID;
		ackMsg.dest = getHeader(&lastReceiveMessage)->src;
		ackMsg.ackID = getMetadata(&lastReceiveMessage)->ackID;
	
		sendto(socket_sender, &ackMsg, sizeof(message_t), 0, (struct sockaddr *)&addrSender, sizeof(struct sockaddr_in));
	
	}
	

	task void start_done(){
		signal SplitControl.startDone(SUCCESS);
	}
	task void stop_done(){
		signal SplitControl.stopDone(SUCCESS);
	}

	command error_t SplitControl.start(){
 
		const unsigned int reuse = 1;
		struct sockaddr_in addr;
		struct ip_mreq mcast_group;
		pid_t pid;
		int a_flags;
		struct sigaction a_sa;
		int ttl;
	
		const unsigned int zero = 0;
		const unsigned int one = 1;
		int status;
	
//		TOS_NODE_ID = getID_fromIP(); // NODE_ID comes from compilation time
		if(getID_fromIP() == 0){
			dbgerror("UDP","UDP::Nenhuma interface ethernet AF_INET foi encontrada\n");
			return FAIL;
		}
		dbgerror("UDP","UDP::Addr/NODE_ID: %d\n", TOS_NODE_ID);
	
		// INIT RECEIVER
		socket_receiver = socket(AF_INET, SOCK_DGRAM, 0);
		if(socket_receiver < 0) {
			dbgerror("UDP","UDP::Erro.1 - %d\n", errno);
			return FAIL;
		}
	
		if(setsockopt(socket_receiver, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
			close(socket_receiver);
			dbgerror("UDP","UDP::Erro.2 - %d\n", errno);
			return FAIL;
		}

		if(fcntl(socket_receiver, F_SETFL, O_NONBLOCK) < 0) {
			close(socket_receiver);
			dbgerror("UDP","UDP::Erro.3 - %d\n", errno);
			return FAIL;
		}

		memset((char*)&addr, 0, sizeof(addr));
		addr.sin_family = AF_INET;
		addr.sin_port = htons(PORT);
		addr.sin_addr.s_addr =  INADDR_ANY;
		if(bind(socket_receiver, (struct sockaddr*)&addr, sizeof(addr))) {
			close(socket_receiver);
			dbgerror("UDP","UDP::Erro.4 - %d\n", errno);
			return FAIL;
		}

		mcast_group.imr_multiaddr.s_addr = inet_addr(GROUP);
		mcast_group.imr_interface.s_addr = INADDR_ANY; //inet_addr(interface);
		if(setsockopt(socket_receiver, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char*)&mcast_group, sizeof(mcast_group))) {
			close(socket_receiver);
			dbgerror("UDP","UDP::Erro.5 - %d\n", errno);
			return FAIL;
		}
		
		ttl = 2;
		if(setsockopt(socket_receiver, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl))) {
			close(socket_receiver);
			dbgerror("UDP","UDP::Erro.5.1 - %d\n", errno);
			return FAIL;
		}
		
		
		pid = getpid();

		a_flags = fcntl(socket_receiver, F_GETFL);
		fcntl(socket_receiver, F_SETFL, a_flags | O_ASYNC);

		a_sa.sa_flags = 0;
		a_sa.sa_handler = UDP_HandleReceiver;
		sigemptyset(&a_sa.sa_mask);
	
		sigaction(SIGIO, &a_sa, NULL);
		fcntl(socket_receiver, F_SETOWN, pid);
	
		//INIT SENDER
		memset((char*)&addrSender, 0, sizeof(addrSender));
		addrSender.sin_addr.s_addr = inet_addr(GROUP);
		addrSender.sin_family = AF_INET;
		addrSender.sin_port = htons(PORT);
	
		socket_sender = socket(AF_INET, SOCK_DGRAM, 0);
		if(socket_sender < 0) {
			dbgerror("UDP","UDP::Erro.6 - %d\n", errno);
			return FAIL;
		}

		if(setsockopt(socket_sender, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(unsigned int)) < 0) {
			close(socket_sender);
			dbgerror("UDP","UDP::Erro.7 - %d\n", errno);
			return FAIL;
		}

		if(setsockopt(socket_sender, IPPROTO_IP, IP_MULTICAST_LOOP, &zero, sizeof(unsigned int)) < 0) {
			close(socket_sender);
			dbgerror("UDP","UDP::Erro.8 - %d\n", errno);
			return FAIL;
		}

		mcast_group.imr_multiaddr.s_addr = inet_addr(GROUP);
		mcast_group.imr_interface.s_addr = INADDR_ANY; //inet_addr(interface);
		status = setsockopt(socket_sender, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char*)&mcast_group, sizeof(mcast_group));
		if(status) {
			dbgerror("UDP","UDP::Erro.9 - %d\n", errno);
			close(socket_sender);
			return FAIL;
		}
	
		dbg("UDP","UDP::Started - pid: %d\n", pid);
	
		post start_done();
	
		return SUCCESS;
	}
	
	event void sendDoneTimer.fired(){
		getMetadata(lastSendMessage)->ackID = FALSE;
		signal AMSend.sendDone[getHeader(lastSendMessage)->type](lastSendMessage, SUCCESS);
	}

	command error_t AMSend.send[am_id_t id](am_addr_t am_addr, message_t *msg, uint8_t len){

		//struct ip_mreq mcast_group;
		//message_header_t *header;
	
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
		sendto(socket_sender, msg, sizeof(message_t), 0, (struct sockaddr *)&addrSender, sizeof(struct sockaddr_in));	
	
		// sucesso no send sem ack
		if(getMetadata(msg)->ackID == 0)
			post send_done();
		else{ // inicio timeout do ack
			call sendDoneTimer.startOneShot(SENDDONE_WAITTIME);
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
		dbg("UDP","UDP::Closing sockets..\n");
		close(socket_sender);
		close(socket_receiver);
		dbg("UDP","UDP::Stopped..\n");
		post stop_done();
		return SUCCESS;
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