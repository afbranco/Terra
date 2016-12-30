#include "hal_nrf_reg.h"
#include "nRF24ActiveMessage.h"
#include <util/delay_basic.h>



module nRF24ActiveMessageP{
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
 uses {
    interface SpiByte;
    interface SpiPacket;
    interface FastSpiByte;
    interface Resource as SpiResource;
    interface HplAtm8IoInterrupt as nRF24_IRQ;
    interface GeneralIO as CSNpin;
    interface GeneralIO as CEpin;
    interface GeneralIO as IRQpin;
    interface Timer<TMilli> as TimerDelay;
 }
}
implementation{


	// State for operation control
	uint8_t stmOper=NONE;
	uint8_t stmStep=0;

	// message controls
	lastSend_t lastSendMsg;
	message_t  lastRecMsg;	
	am_id_t  lastRecMsg_targetAddr;
	nRF24_msg_t nRF24_msg;
	uint8_t* spi_buffer;

	// Operation control task
	task void stmProc();
	
	// Radio power operations (nRF24 values)
	uint8_t nRF_getPower();
	void nRF_setPower(uint8_t nRFpower);
	// Ack field
	bool getAckField(message_t *msg);
	void setAckField(message_t *msg, bool value);

	// I/O pins operation
	void ssOn() {call CSNpin.clr();}
	void ssOff(){call CSNpin.set();}
	void CEStrobe(){call CEpin.set(); _delay_loop_2(10 * (F_CPU/4000000ul)); call CEpin.clr();}
	void CEHigh(){call CEpin.set();}
	void CELow() {call CEpin.clr();}
	void delay_us(uint16_t us) {_delay_loop_2(us * (F_CPU/4000000ul));}

	task void startDone(){ signal SplitControl.startDone(SUCCESS);}	
	task void stopDone(){ signal SplitControl.stopDone(SUCCESS);}	

	command error_t SplitControl.start(){
		// Configure non SPI IO
		call CSNpin.makeOutput(); call CSNpin.set();
		call CEpin.makeOutput();  call CEpin.set();
		// Configure Int pin	
		call nRF24_IRQ.disable();
		call IRQpin.makeInput();
		call nRF24_IRQ.configure(INTR_FALLING_EDGE);
		call nRF24_IRQ.clear ();
		// Start procedure
		stmOper = START;
		stmStep = 0;
		post stmProc();
		return SUCCESS;
	}

	command error_t SplitControl.stop(){
		stmOper = STOP;
		stmStep = 0;
		post stmProc();
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


	task void receive(){
		signal Receive.receive[call AMPacket.type(&lastRecMsg)](
				&lastRecMsg, 
				call Packet.getPayload(&lastRecMsg, call Packet.maxPayloadLength()), 
				call Packet.payloadLength(&lastRecMsg)
				);
	}

	// Creating tasks to process interruption avoiding concurrent access
	task void sendDoneOK(){
		signal AMSend.sendDone[lastSendMsg.id](lastSendMsg.msg, SUCCESS);
		}
	task void sendDoneERR(){
		signal AMSend.sendDone[lastSendMsg.id](lastSendMsg.msg, FAIL);
		}
	task void sendDoneAckTrue(){
		setAckField(lastSendMsg.msg,TRUE);
		signal AMSend.sendDone[lastSendMsg.id](lastSendMsg.msg, SUCCESS);
		}
	task void sendDoneAckFalse(){
		setAckField(lastSendMsg.msg,FALSE);
		signal AMSend.sendDone[lastSendMsg.id](lastSendMsg.msg, SUCCESS);
		}

	command error_t AMSend.send[am_id_t id](am_addr_t addr, message_t *msg, uint8_t len){
//return EBUSY;
		if (stmOper != NONE) {
			return EBUSY;
			}
		// save msg pointer to post process
		lastSendMsg.msg = msg;
		lastSendMsg.target = (addr==AM_BROADCAST_ADDR)? nRF24_BROADCAST_ADDR : addr;
		lastSendMsg.len = len;
		lastSendMsg.id = id;
		// start sending
		stmOper = SEND;
		stmStep = 0;
		post stmProc();
		return SUCCESS;
	}

	command uint8_t AMAux.getPower(message_t *p_msg){
		message_metadata_t* meta = (message_metadata_t*)p_msg->metadata;
		return meta->rf_power;
	}

	command void AMAux.setPower(message_t *p_msg, uint8_t power){
		message_metadata_t* meta = (message_metadata_t*)p_msg->metadata;
		meta->rf_power = power;
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
		return ( header->dest == TOS_NODE_ID || header->dest == nRF24_BROADCAST_ADDR);
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
		message_metadata_t* meta = (message_metadata_t*)msg->metadata;
		meta->ack = TRUE;
		return SUCCESS;
	}

	async command bool PacketAcknowledgements.wasAcked(message_t *msg){
		message_metadata_t* meta = (message_metadata_t*)msg->metadata;
		return meta->ack;
	}

	async command error_t PacketAcknowledgements.noAck(message_t *msg){
		message_metadata_t* meta = (message_metadata_t*)msg->metadata;
		meta->ack = FALSE;
		return SUCCESS;
	}
	
	bool getAckField(message_t *msg){
		message_metadata_t* meta = (message_metadata_t*)msg->metadata;
		return meta->ack;
	}
	void setAckField(message_t *msg, bool value){
		message_metadata_t* meta = (message_metadata_t*)msg->metadata;
		meta->ack=value;
	}
	
/*
 * nRF24 Interface via SPI
 * 
 */


uint8_t nRF_getStatus(){
	uint8_t stat;
	ssOn();
	stat = call SpiByte.write(NOP); // NOP command returns the status register
	ssOff();
	return stat;
}

uint8_t nRF_flushTX(){
	uint8_t stat;
	ssOn();
	stat = call SpiByte.write(FLUSH_TX);					
	ssOff();
	return stat;
}
uint8_t nRF_flushRX(){
	uint8_t stat;
	ssOn();
	stat = call SpiByte.write(FLUSH_RX);					
	ssOff();
	return stat;
}


uint8_t nRF_wrReg(uint8_t reg, uint8_t value){
	uint8_t stat;
	ssOn();
	call SpiByte.write(reg | WRITE_REG);					
	stat = call SpiByte.write(value);
	ssOff();
	return stat;
}
uint8_t nRF_rdReg(uint8_t reg){
	uint8_t stat;
	ssOn();
	call SpiByte.write(reg );					
	stat = call SpiByte.write(0x00);
	ssOff();
	return stat;
}

uint8_t nRF_toggleFeature(){
	uint8_t stat;
	ssOn();
	call SpiByte.write(LOCK_UNLOCK);					
	stat = call SpiByte.write(0x73);
	ssOff();
	return stat;
}

uint8_t nRF_wrAddr(uint8_t reg, uint16_t addr){
	uint8_t stat;
	uint16_t maskAddr;
	maskAddr = addr | nRF24_ADDR_MASK;
	ssOn();
	stat=call SpiByte.write(reg | WRITE_REG);
	// First byte for all Registers			
  	call SpiByte.write(maskAddr&0x00ff);
	// next 4 bytes only for P0, P1 and TX Registers			
	if (reg == RX_ADDR_P0 || reg==RX_ADDR_P1 || reg==TX_ADDR){
		call SpiByte.write(0xCC);
		call SpiByte.write((maskAddr>>8)&0x00ff);
		call SpiByte.write(0xCC);
		call SpiByte.write(0xCC);
	}
 	ssOff();
	return stat;
}

uint16_t unpackAddr(uint8_t* nRF_addr){
	return nRF_addr[3]<<8 | nRF_addr[1]; 	
}

uint8_t nRF_getPower(){
	uint8_t rf_setup;
	// First get RF_SEUP value
	ssOn();
	call SpiByte.write(RF_SETUP);					
	rf_setup = call SpiByte.write(0);
	ssOff();
	// Then combine with new power value
	return (rf_setup & 0x06)>>1;
}
void nRF_setPower(uint8_t nRFpower){
	uint8_t rf_setup;
	// First get RF_SEUP value
	ssOn();
	call SpiByte.write(RF_SETUP);					
	rf_setup = call SpiByte.write(0);
	ssOff();
	// Then combine with new power value
	rf_setup = (rf_setup & 0xF8) | (nRFpower << 1);
	ssOn();
	call SpiByte.write(RF_SETUP | WRITE_REG);					
	call SpiByte.write(rf_setup);
	ssOff();
}

/*
 * nRF24 state machine
 */

/*
Procedimento para inicialização do rádio 
1. Esperar 5ms após o ligar a placa
2. Reset NRF_CONFIG and enable 16-bit CRC.: write_register( NRF_CONFIG, 0b00001100 ) ;
3. Set retries. setRetries(5,15); ->  write_register(SETUP_RETR,(delay&0xf)<<ARD | (count&0xf)<<ARC);
4. Set data rate 1MBPS.  RF_SETUP = RF_SETUP + Bits modificados
5. Features
 		_SPI.transfer( ACTIVATE ); _SPI.transfer( 0x73 ); --> toggle_features()
 		write_register(FEATURE,0 );
  		write_register(DYNPD,0);
6. Reset current status. Notice reset and flush is the last thing we do
 		 write_register(NRF_STATUS,_BV(RX_DR) | _BV(TX_DS) | _BV(MAX_RT) );
7. Set up default configuration.  Callers can always change it later.
	write_register(RF_CH,rf24_min(channel,max_channel));
8. Flush RX/TX - FLUSH_RX & FLUSH_TX 
9. Power Up	+ Delay
	write_register(NRF_CONFIG, cfg | _BV(PWR_UP));
	delay 5ms	 
10. Enable PTX, do not write CE high so radio will remain in standby I mode
	write_register(NRF_CONFIG, ( read_register(NRF_CONFIG) ) & ~_BV(PRIM_RX) );
 
*/ 
 
 
	void stmProcStart(){
		switch (stmStep){
			case 0: // Waits 5ms - Radio power on  
				stmStep++; // point to next step
				call TimerDelay.startOneShot(5);
			case 1: // Request SPI bus
				stmStep++; // point to next step
				call SpiResource.request(); 
				break;
			case 2: // Configure radio registers
				stmStep++; // point to next step
				nRF_wrReg(CONFIG,RESET_CONFIG);// Reset the Config register
//			nRF_wrReg(CONFIG,0b00001100);// Reset the Config register
//				nRF_wrReg(SETUP_RETR, 0);	// Enable retransmissions up to 3 & delay of 1500us			
				nRF_wrReg(SETUP_RETR, ((1500/250)-1)<<4 | 3);	// Enable retransmissions up to 3 & delay of 1500us			
//			nRF_wrReg(SETUP_RETR, ((1500/250)-1)<<4 | 3);	// Enable retransmissions up to 3 & delay of 1500us			
				nRF_wrReg(RF_SETUP,HAL_NRF_1MBPS<<3  | HAL_NRF_18DBM<<1);// Set bandwidth to 1Mps and RF Power
//			nRF_wrReg(RF_SETUP,0x00);// Set bandwidth to 2Mps and RF Power
			nRF_toggleFeature(); // Toggle feature
				nRF_wrReg(FEATURE,0x01);	// Configue FEATURE register - enable TX_ACK, disable Dynamic Payload and ACK-payload
//			nRF_wrReg(FEATURE,0);	// Configue FEATURE register - enable TX_ACK, disable Dynamic Payload and ACK-payload
				nRF_wrReg(DYNPD,0);	// Disable  Dynamic payload for all pipes
//			nRF_wrReg(DYNPD,0);	// Disable  Dynamic payload for all pipes

				nRF_wrReg(RF_CH,0x4c);		// Set radio frequency - default 2402MHs
				// Flush the buffers
				nRF_flushRX();
				nRF_flushTX();
		CELow();
				nRF_wrReg(CONFIG,START_CONFIG);// Config register - Power up the radio to StandBy mode, etc.
//		nRF_wrReg(CONFIG,0b00001110);// Config register - Power up the radio to StandBy mode, etc.
				// Waits for POWER UP MODE
				call TimerDelay.startOneShot(5);
				break;
			case 3: // Configure radio registers for Receive mode
				stmStep++; // point to next step
				nRF_wrReg(SETUP_AW,0x03);	// Setup 5bytes node Addrs
				// Set null addr to Pipe Addr 0
				nRF_wrAddr(RX_ADDR_P0,0);
				// Set broadcast  addr to Pipe Addr 1 (0xnn00)
				nRF_wrAddr(RX_ADDR_P1,nRF24_BROADCAST_ADDR);
				// Set node addr to Pipe Addr 2 (0x00nn)
				nRF_wrAddr(RX_ADDR_P2,nRF24_NODE_ID);

				nRF_wrReg(RX_PW_P0,0x20); // Set payload size for pipe 0 
				nRF_wrReg(RX_PW_P1,0x20); // Set payload size for pipe 1 
				nRF_wrReg(RX_PW_P2,0x20); // Set payload size for pipe 2 
				nRF_wrReg(EN_AA,0x07);		// Enable Auto Ack, when requested by sent message	
				nRF_wrReg(EN_RXADDR,0x7);	// Enable Addrs 0,1&2, disable ,3,4,5				
				nRF_wrReg(CONFIG,REC_CONFIG);// Config register - RX mode
				nRF_wrReg(STATUS,nRF_getStatus() | 1<<RX_DR | 1<<TX_DS | 1<<MAX_RT); // Reset Int flags
				// Flush the buffers
				nRF_flushRX();
				nRF_flushTX();
				// Enable IRQ
				call nRF24_IRQ.clear();
				call nRF24_IRQ.enable();
				// Change to RX mode
				CEHigh();
				// Release SPI
				//call SpiResource.release();
				post startDone();
				stmOper = NONE;
				break;
		}
	}
	void stmProcStop(){
		switch (stmStep){
			case 0: // Request SPI bus
				stmStep++; // point to next step
//				stat = call SpiResource.request(); 
//				break;
//			case 1: 
				stmStep++; // point to next step
				call nRF24_IRQ.clear();
				call nRF24_IRQ.disable(); // Disable IRQ
				CELow(); // Guarantee CE is low on powerDown
				nRF_wrReg(CONFIG,STOP_CONFIG);	// Reconfigure radio register with PWR_UP=0
				call SpiResource.release();	// Release SPI
				post stopDone();
				stmOper = NONE;
				break;
		}
	}
	void stmProcSend(){
		switch (stmStep){
			case 0: // Request SPI bus			
				stmStep++; // point to next step
//				call SpiResource.request(); 
//				break;
//			case 1: 
				stmStep++; // point to next step
				CELow(); // Move to Standby mode
				// Fill radio Msg
				nRF_flushTX();
				nRF24_msg.am_id=lastSendMsg.id;
				nRF24_msg.len = lastSendMsg.len;
				nRF24_msg.source = TOS_NODE_ID;
				memcpy( nRF24_msg.payload, call Packet.getPayload(lastSendMsg.msg,lastSendMsg.len),lastSendMsg.len);
				nRF_setPower(call AMAux.getPower(lastSendMsg.msg)>>1);
				// Force noAck for BROADCAST messages
				if (lastSendMsg.target == nRF24_BROADCAST_ADDR){
					setAckField(lastSendMsg.msg,FALSE);
				}
				// Target Addr
				nRF_wrAddr(RX_ADDR_P0,	lastSendMsg.target);
				nRF_wrAddr(TX_ADDR,		lastSendMsg.target);
				// TX_PAYLOAD command
				spi_buffer = (uint8_t*)&nRF24_msg;
				ssOn();
				call SpiByte.write(getAckField(lastSendMsg.msg)?WR_TX_PLOAD:WR_NAC_TX_PLOAD);
				call SpiPacket.send(spi_buffer,NULL,sizeof(nRF24_msg_t)); 
				break;
			case 2: 
				ssOff();
				stmStep++; // point to next step
				nRF_wrReg(CONFIG,SEND_CONFIG); // Reconfigure to TX mode
				call nRF24_IRQ.clear();
				call nRF24_IRQ.enable(); // Enable IRQ
				// Send data
				CEStrobe();
				break;
			case 3: // from the IRQ
				stmStep++; // point to next step
				// IRQ is Send or MaxRT
				if (nRF_getStatus() & (1<<TX_DS)){ // sendDoneOK or sendDoneAckTrue
					if (getAckField(lastSendMsg.msg))
						post sendDoneAckTrue();
					else
						post sendDoneOK();
				}  else { // was MaxRT in ack mode
					post sendDoneAckFalse();
				}
				nRF_wrReg(STATUS,nRF_getStatus() | 1<<TX_DS | 1<< MAX_RT);	// Clear TX/MaxRT IRQ bit from STATUS register
				// Reset broadcast addr to Pipe Addr 0
				nRF_wrAddr(RX_ADDR_P0,0);
				// Set broadcast  addr to Pipe Addr 1 (0xnn00)
				nRF_wrAddr(RX_ADDR_P1,nRF24_BROADCAST_ADDR);
				nRF_wrReg(CONFIG,REC_CONFIG);	// Reconfigure CONFIG Register to RX mode (is the same of START_CONFIG)
				nRF_wrReg(STATUS,nRF_getStatus() | 1<<RX_DR | 1<<TX_DS | 1<<MAX_RT); // Reset Int flags
				// Change to RX mode
				nRF_flushRX();
				CEHigh();
				// Release SPI
//				call SpiResource.release();
				// Enable IRQ
				call nRF24_IRQ.clear();
				call nRF24_IRQ.enable();
				stmOper = NONE;
				break;
		}
	}


	void stmProcReceive(){
		uint8_t status;
		switch (stmStep){
			case 0: // Request SPI bus
				stmStep++; // point to next step
//				stat = call SpiResource.request(); 
//				break;
//			case 1: 
				stmStep++; // point to next step
				// Disable receive state
				CELow();
				{
					uint8_t payloadLen;
					uint8_t pipeNo;
					// Get received pipe to discover target addr
					status = nRF_getStatus();
					pipeNo = ((status>>RX_P_NO)&0x07);
					lastRecMsg_targetAddr = (pipeNo==1)?nRF24_BROADCAST_ADDR:nRF24_NODE_ID;
					// Get payload size
					ssOn();
					call SpiByte.write(RD_RX_PLOAD_W);
					payloadLen = call SpiByte.write(0);
					ssOff();
					if (payloadLen == sizeof(nRF24_msg_t)){
						spi_buffer = (uint8_t*)&nRF24_msg;
						// Read payload
						ssOn();
						call SpiByte.write(RD_RX_PLOAD);
						call SpiPacket.send(NULL,spi_buffer,sizeof(nRF24_msg_t));
					} else { // discard payload and change to REC state
						nRF_flushRX();
						// Get FIFO_STATUS to check any pending message
						ssOn();
						call SpiByte.write(FIFO_STATUS);
						status = call SpiByte.write(0);
						ssOff();
						if ((status & 1<<RX_EMPTY)==0) {
							// Read next buffered message
							stmOper=RECEIVE;
							stmStep=0;	
							post stmProc();				
							// Release SPI
							//call SpiResource.release();
						} else {
							// Reconfigure CONFIG Register to RX mode
							nRF_wrReg(CONFIG,REC_CONFIG);
							CEHigh();
							stmOper=NONE;	
							// Enable IRQ
							call nRF24_IRQ.clear();
							call nRF24_IRQ.enable();
							// Release SPI
							//call SpiResource.release();
						}
					}
				}
				break;						 
			case 2: 
				ssOff(); // End of SPI transfer
				stmStep++; // point to next step
				nRF_wrReg(STATUS,1<<RX_DR);	// Clear RX IRQ bit from STATUS register
				// Copy received payload
				memcpy(call Packet.getPayload(&lastRecMsg, call Packet.maxPayloadLength()), nRF24_msg.payload, nRF24_msg.len);
				call Packet.setPayloadLength(&lastRecMsg, nRF24_msg.len);
				call AMPacket.setType(&lastRecMsg,nRF24_msg.am_id);
				call AMPacket.setGroup(&lastRecMsg,TOS_AM_GROUP);
				call AMPacket.setDestination(&lastRecMsg,lastRecMsg_targetAddr);
				call AMPacket.setSource(&lastRecMsg, nRF24_msg.source);
				post receive();
				// Change to Receive state
				// Reconfigure CONFIG Register to RX mode
				nRF_flushRX();
				nRF_wrReg(CONFIG,REC_CONFIG);
				// Get FIFO_STATUS to check any pending message
				ssOn();
				call SpiByte.write(FIFO_STATUS);
				status = call SpiByte.write(0);
				ssOff();
				if ((status & 1<<RX_EMPTY)==0) {
					stmOper=RECEIVE;
					stmStep=0;	
					post stmProc();				
				} else {
					stmOper=NONE;	
					CEHigh();
					// Enable IRQ
					call nRF24_IRQ.clear();
					call nRF24_IRQ.enable();
					// Release SPI
					// call SpiResource.release();
				}
				break;
		}
	}

	task void stmProc(){
		switch (stmOper){
			case START: 	stmProcStart(); break;
			case STOP: 		stmProcStop(); break;
			case SEND: 		stmProcSend(); break;		
			case RECEIVE: 	stmProcReceive(); break;		
		}	
	}


	async event void SpiPacket.sendDone(uint8_t *txBuf, uint8_t *rxBuf, uint16_t len, error_t error){
		post stmProc();
	}

	event void SpiResource.granted(){
		post stmProc();
	}

	event void TimerDelay.fired(){
		post stmProc();
	}

uint8_t irqStat;

	task void IRQ_fired() {
		uint8_t irqStatAux;
		atomic{irqStatAux=irqStat;}
		// IRQ is a RX and has RX_FIFO and stmOper==NONE --> Is a valid received message
		if ((irqStatAux & (1<<HAL_NRF_RX_DR)) && (((irqStatAux & 0x0f)>>1)<6) && (stmOper==NONE)){
			stmOper=RECEIVE;
			stmStep=0;	
			post stmProc();
			return;
		}
		// IRQ is a TX done or a MaxRetries and stmOper==SEND --> continue in stmProc()
		if ((irqStatAux & ((1<<HAL_NRF_TX_DS) | (1<<HAL_NRF_MAX_RT))) && (stmOper==SEND)){
			post stmProc();
			return;	
		}
		//post stmProc();
		//call nRF24_IRQ.enable();
	}

	async event void nRF24_IRQ.fired(){ 
//PORTD |= 0x80;

//PORTF = (PORTF  & 0xf0) | ((PORTF+2) & 0x0f);	
		call nRF24_IRQ.clear();
		call nRF24_IRQ.disable();
		post IRQ_fired();
		irqStat = nRF_getStatus();
	}

}