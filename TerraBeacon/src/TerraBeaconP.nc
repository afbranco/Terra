
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
	uses interface Timer<TMilli> as radioStop;
	uses interface Random;
	
	uses interface GeneralIO as PC0; // Analog 0
	uses interface GeneralIO as PD3; // TempSensor Power
	uses interface Read<uint16_t> as Ana0;
	uses interface GeneralIO as LED; // LED
	
	
}
implementation{

	nx_uint16_t MoteID;					// Mote Identifier
	message_t sendBuff;					// Message send buffer
	uint32_t reSendDelay;
	uint8_t sendCounter;				// Count the send retries
	terra_data_t lastUsrMsg;			// Last sent message
	uint32_t globalSeq;
	uint16_t targetMote;

	event void TOSBoot.booted(){
		uint32_t rnd=0;	
//DDRD &= 0x7f;
		dbg(APPNAME, "TB::TOSBoot.booted().\n");
		sendCounter = 0;
		globalSeq = 0;
		targetMote = AM_BROADCAST_ADDR;
		rnd = call Random.rand32() & 0x0f;
		reSendDelay = RESEND_DELAY + (rnd * 5);
		call PC0.makeInput();
		call PD3.makeOutput();
		call LED.makeOutput();
		call LED.clr();
		// First radio start
		if (call RadioControl.start() != SUCCESS) {dbg(APPNAME,"TB::Error in RadioControl.start()\n");}
		// Power on the TempSensor
		call PD3.clr();
		// Starts the periodic timer
		call TimerBeacon.startPeriodic(BEACON_PERIOD);
	}

	event void RadioControl.startDone(error_t error){
		dbg(APPNAME, "TB::RadioControl.startDone().\n");
		MoteID = TOS_NODE_ID;
		// Request ADC0
		call Ana0.read();
	}
	event void RadioControl.stopDone(error_t error){
//PORTD &= 0x7f;
		dbg(APPNAME, "TB::RadioControl.stopDone().\n");
	}

	event void TimerBeacon.fired(){
		// Next radio start
		call PD3.set();
		if (call RadioControl.start() != SUCCESS) dbg(APPNAME,"TB::Error in RadioControl.start()\n");
	}
	
	task void sendMessage(){
		error_t stat;
		sendCounter++;
		// Send to Radio
		memcpy(call RadioPacket.getPayload(&sendBuff,call RadioPacket.maxPayloadLength()), &lastUsrMsg, sizeof(terra_data_t));
		dbg(APPNAME, "BT::send(): Sending Message AM_ID=%d, size=%d, maxSize=%d\n", AM_USRMSG,sizeof(terra_data_t),call RadioPacket.maxPayloadLength());
		call AMAux.setPower(&sendBuff,1);
		stat = call RadioSender.send[(am_id_t)AM_USRMSG]((am_addr_t)lastUsrMsg.target,&sendBuff, sizeof(terra_data_t));
		if (stat != SUCCESS) {
			dbg(APPNAME,"BT::send(): Error in Sending Message(%d))\n",stat);
			call sendTimer.startOneShot(reSendDelay);
		}
	}

	event void Ana0.readDone(error_t result, uint16_t val){		
		// Power down the TempSensor
		call PD3.clr();
		// reset targetMote every 60 sends
		globalSeq++;
		if (globalSeq%60 == 0) targetMote = AM_BROADCAST_ADDR;
		// Build Terra Message
		lastUsrMsg.type		= BEACON_A_MSG_ID;
		lastUsrMsg.source	= MoteID;
		lastUsrMsg.target	= targetMote;
		lastUsrMsg.d16[0] 	= val;
		lastUsrMsg.d16[3] 	= MoteID;
		lastUsrMsg.d32[0] 	= globalSeq;
		post sendMessage();		
	}
	event void sendTimer.fired(){
		dbg(APPNAME, "BS::sendTimer.fired(): \n");
		if (sendCounter < MAX_SEND_RETRIES) { 	// Try to send again
			post sendMessage();
		} else {								// Discard message and stop the radio
			sendCounter=0;
			// Stop the radio
			call RadioControl.stop();
		}	
	}

	event void RadioSender.sendDone[am_id_t id](message_t *msg, error_t error){
		if (error == SUCCESS) {
			sendCounter=0;
			// Stop the radio or wait a parent message
			if (targetMote == AM_BROADCAST_ADDR){
				call radioStop.startOneShot(300);
			} else {		
				call RadioControl.stop();
			}
		} else {
			call sendTimer.startOneShot(reSendDelay);
		}
	}

	event void radioStop.fired(){
		call RadioControl.stop();
	}

	event message_t * RadioReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
//call LED.toggle();
		// Handle only DATA_MSG_AMID and BEACON_PARENT_MSG_ID
		if (id == DATA_MSG_AMID){
			terra_data_t *pmsg = payload;
			// if targetMote is broadcast, then set it with message source id
			if ((pmsg->type == BEACON_PARENT_MSG_ID) && (targetMote == AM_BROADCAST_ADDR)){
				targetMote = call RadioAMPacket.source(msg);
			}
		}
		return msg;
	}

}