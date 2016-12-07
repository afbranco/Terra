
#include "TerraBeacon.h"

module TerraBeaconP{
	uses interface Boot as TOSBoot;
	uses interface AMPacket as RadioAMPacket;
	uses interface SplitControl as RadioControl;
	uses interface Packet as RadioPacket;
    uses interface PacketAcknowledgements as RadioAck;
    uses interface AMSend as RadioSender[am_id_t id];
    uses interface Receive as RadioReceiver[am_id_t id];
	uses interface AMAux;
	
	uses interface Timer<TMilli> as TimerBeacon;
	uses interface Timer<TMilli> as sendTimer;
	uses interface Random;
	
	uses interface GeneralIO as PC0; // Analog 0
	uses interface Read<uint16_t> as Ana0;
	
	
}
implementation{

	nx_uint16_t MoteID;					// Mote Identifier
	message_t sendBuff;					// Message send buffer
	uint32_t reSendDelay;
	uint8_t sendCounter;				// Count the send retries
	terra_data_t lastUsrMsg;			// Last sent message
	uint8_t globalSeq;

	event void TOSBoot.booted(){
		dbg(APPNAME, "TB::TOSBoot.booted().\n");
		if (call RadioControl.start() != SUCCESS) dbg(APPNAME,"TB::Error in RadioControl.start()\n");
	}

	event void RadioControl.startDone(error_t error){
		uint32_t rnd=0;	
		dbg(APPNAME, "TB::RadioControl.startDone().\n");
		MoteID = TOS_NODE_ID;
		sendCounter = 0;
		globalSeq = 0;
		rnd = call Random.rand32() & 0x0f;
		reSendDelay = RESEND_DELAY + (rnd * 5);
		call PC0.makeInput();
		// Starts the periodic timer
		call TimerBeacon.startPeriodic(BEACON_PERIOD);
	}
	event void RadioControl.stopDone(error_t error){dbg(APPNAME, "TB::RadioControl.stopDone().\n");}

	event void TimerBeacon.fired(){
		// Request ADC0
		call Ana0.read();
	}
	
	task void sendMessage(){
		error_t stat;
		sendCounter++;
		// Send to Radio
		memcpy(call RadioPacket.getPayload(&sendBuff,call RadioPacket.maxPayloadLength()), &lastUsrMsg, sizeof(terra_data_t));
		dbg(APPNAME, "BT::send(): Sending Message AM_ID=%d, size=%d, maxSize=%d\n", AM_USRMSG,sizeof(terra_data_t),call RadioPacket.maxPayloadLength());
		stat = call RadioSender.send[(am_id_t)AM_USRMSG]((am_addr_t)lastUsrMsg.target,&sendBuff, sizeof(terra_data_t));
		if (stat != SUCCESS) {
			dbg(APPNAME,"BT::send(): Error in Sending Message(%d))\n",stat);
			call sendTimer.startOneShot(reSendDelay);
		}
	}

	event void Ana0.readDone(error_t result, uint16_t val){		
		// Build Terra Message		
		lastUsrMsg.type		= DATA_MSG_ID;
		lastUsrMsg.source	= MoteID;
		lastUsrMsg.target	= AM_BROADCAST_ADDR;
		lastUsrMsg.d8[0]	= globalSeq++;
		lastUsrMsg.d8[1]	= (uint8_t)MoteID;
		lastUsrMsg.d8[2]	= sendCounter-1;
		lastUsrMsg.d16[0] 	= val;
		lastUsrMsg.d16[1] 	= 0;
		post sendMessage();		
	}
	event void sendTimer.fired(){
		dbg(APPNAME, "BS::sendTimer.fired(): \n");
		if (sendCounter < MAX_SEND_RETRIES) { 	// Try to send again
			post sendMessage();
		} else {								// Discard message and get next message
			sendCounter=0;
		}	
	}

	event void RadioSender.sendDone[am_id_t id](message_t *msg, error_t error){
		if (error == SUCCESS) {
			sendCounter=0;			
		} else {
			call sendTimer.startOneShot(reSendDelay);
		}
	}

	event message_t * RadioReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
		// TODO Auto-generated method stub
		return msg;
	}

}