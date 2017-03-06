/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Module: BasicServicesP
 * Basic Services - Main VM Timer, Simple Radio, and Code Upload/Forward
 * 
 */
#include "BasicServices.h"

module BasicServicesP{
	provides interface Boot as BSBoot;
	provides interface BSTimer as BSTimerVM;
	provides interface BSTimer as BSTimerAsync;
	provides interface BSUpload;
	provides interface BSRadio;

	uses interface Boot as TOSBoot;

	uses interface AMPacket as RadioAMPacket;
	uses interface SplitControl as RadioControl;
	uses interface Packet as RadioPacket;
    uses interface PacketAcknowledgements as RadioAck;
    uses interface AMSend as RadioSender[am_id_t id];
    uses interface Receive as RadioReceiver[am_id_t id];
	uses interface AMAux;



	uses {
		
		// setData queue
#ifdef MODE_SETDATA
		interface dataQueue as setDataQ;
#endif
		// Bitmap
		interface vmBitVector as BM;
		interface vmBitVector as BMaux;
		/* Messages Queue */
		interface dataQueue as inQ;
		interface dataQueue as outQ;
		
		// Timer
		interface Timer<TMilli> as TimerVM;
		interface Timer<TMilli> as TimerAsync;
		interface Timer<TMilli> as sendTimer;
		interface Timer<TMilli> as ProgReqTimer;
		interface Timer<TMilli> as SendDataFullTimer;
#ifdef MODE_SETDATA
		interface Timer<TMilli> as DataReqTimer;
#endif
		interface Random;

	}

#ifdef LPL_ON
	uses interface LowPowerListening;
#endif

	// CTP
#ifdef MODULE_CTP
	uses interface Receive as recSendBS;		// BS
	uses interface Send as sendBSNet;
	uses interface StdControl as RoutingControl;
	uses interface RootControl;
	uses interface CtpInfo;
#endif

#ifdef WITH_BSTATION
	uses interface SplitControl as SerialControl;
	uses interface AMSend as SerialSender[am_id_t id];
	uses interface Receive as SerialReceiver[am_id_t id];
	uses interface Packet as SerialPacket;

#ifdef WITH_AUX_BSTATION
	uses interface SplitControl as Serial1Control;
	uses interface AMSend as Serial1Sender[am_id_t id];
	uses interface Receive as Serial1Receiver[am_id_t id];
	uses interface Packet as Serial1Packet;
#endif
#endif

#ifdef TOSSIM
	uses interface Get<uint8_t> as MoteType;
#endif

}
implementation{

#ifndef MOTE_TYPE
#define MOTE_TYPE 1
#endif
	uint8_t TERRA_MOTE_TYPE =  MOTE_TYPE;

	uint32_t LocalClock=0;
	nx_uint16_t MoteID;					// Mote Identifier
	bool firstInic=TRUE;				// First initialization flag
	uint32_t reSendDelay;
	
	GenericData_t tempInputInQ;			// Temporarily input message buffer
	GenericData_t tempInputOutQ;			// Temporarily output message buffer
	GenericData_t tempOutputInQ;			// Temporarily input message buffer
	GenericData_t tempOutputOutQ;			// Temporarily output message buffer
	GenericData_t lastNewProgVersion;		// Last received NewProgVersion
	uint16_t lastRequestBlock;			// last block id requested
	message_t sendBuff;					// Message send buffer
	message_t usrMsgBuff;					// Message send buffer
#ifdef WITH_BSTATION
	message_t serialAux;					// Serial msg send buffer
	uint8_t lastFromSerial = FALSE;
#ifdef WITH_AUX_BSTATION
	message_t serial1Aux;					// Serial msg send buffer
#endif
#endif
	GenericData_t usrMsgOut;					// Temporarily output message buffer
	
	uint8_t sendCounter;				// Count the send retries
	reqProgBlock_t serialReqProgBlock;	// Serial Req Message buffer
	
	uint8_t userRFPowerIdx;				// Radio RF power Index defined by the user - default is RFPOWER_IDX 0..7

	// Request prog/data state
	uint8_t ReqState = ST_IDLE;

	// Program load control
	nx_uint16_t ProgVersion;
	nx_uint16_t ProgMoteSource;
	nx_uint16_t ProgBlockStart;
	nx_uint16_t ProgBlockLen;
	uint8_t loadingProgramFlag=FALSE;
	
	uint8_t ProgTimeOutCounter=0;
	uint16_t DsmBlockCount=0;
	nx_uint16_t lastRecNewProgVersion;
	uint16_t lastRecParentId=0; // Store the currentParentId. Used for send message to BS
	

	// New Data load control	
	nx_uint16_t NewDataSeq;
	nx_uint16_t maxSeenDataSeq;
	uint8_t DataTimeOutCounter=0;
	nx_uint16_t NewDataMoteSource;	

	// Filter others REQ_PROG_BLOCK
	uint16_t disseminatorRoot=0;
	
	// Controls where last program was too big to the local VM Memory 
	int32_t lastBigAppVersion = -1L;

	// Controls last NewProgBlock version to check if it is duplicated
	uint16_t lastRecNewProgBlock_versionId=0;
	


#ifdef MODULE_CTP
	// Rec SendBS - last msg info used to test duplicated CTP events
	nx_uint16_t recBS_last_Sender;
	nx_uint16_t recBS_last_seq;
#endif
	
	
/* **************************************************************\
*             Prototypes
\* **************************************************************/
 	void sendReqProgBlock(reqProgBlock_t* Data);
	void sendNewProgVersion(newProgVersion_t *Data);
	void sendNewProgBlock(newProgBlock_t *Data);
	void sendReqData(reqData_t *Data);
	task void ProgReqTimerTask();
#ifdef MODE_SETDATA
	void sendSetDataND(setDataND_t *Data);	
#endif	
	void TViewer(char* cmd,uint16_t p1, uint16_t p2){
		dbg("TVIEW","<<: %s %d %d %d :>>\n",cmd,TOS_NODE_ID,p1,p2);
		}	


/* **********************************************************************************
 *        Initialize parameters, switch-on the radio, and start protocols.
\* **********************************************************************************/

	/**
	 * Initialize the data  (reset all data)
	 */
	void inicCtlData(){
		dbg(APPNAME, "BS::inicCtlData().\n");
		// Only for first initialization (boot)
		if (firstInic){
			// First initialization
			ProgVersion = 0;
			NewDataSeq = 0;
			maxSeenDataSeq=0;
			NewDataMoteSource = AM_BROADCAST_ADDR;
			
			ProgBlockLen = CURRENT_MAX_BLOCKS;
			ProgMoteSource = 0;
		}
	}

	/**
	* Command to start the communication
	*/ 
	
	event void TOSBoot.booted(){
		uint32_t rnd=0;	
		dbg(APPNAME, "BS::TOSBoot.booted().\n");
		userRFPowerIdx = RFPOWER_IDX;
#ifdef RFPOWER_INIT_
			RFPOWER_INIT(userRFPowerIdx);	
#endif

		MoteID = TOS_NODE_ID;
		rnd = call Random.rand32() & 0x0f;
		reSendDelay = RESEND_DELAY + (rnd * 5);

		if (firstInic){
			inicCtlData();
#ifdef LPL_ON
			call LowPowerListening.setLocalWakeupInterval( SLEEP );
#endif
			if (call RadioControl.start() != SUCCESS) dbg(APPNAME,"BS::Error in RadioControl.start()\n");
#ifdef WITH_BSTATION
			if (call SerialControl.start() != SUCCESS) dbg(APPNAME,"BS::Error in SerialControl.start()\n");
#ifdef WITH_AUX_BSTATION
			if (call Serial1Control.start() != SUCCESS) dbg(APPNAME,"BS::Error in Serial1Control.start()\n");
#endif
#endif
		} else {
			signal BSBoot.booted();
		}
	}

	uint32_t getRequestTimeout(){return REQUEST_TIMEOUT;}

	/**
	 * Radio started event.
	 */
	event void RadioControl.startDone(error_t error) {
		MoteID = TOS_NODE_ID;

		// If got error, then retry to start
		if (error != SUCCESS){
			if (call RadioControl.start() != SUCCESS) dbg(APPNAME,"BS::Error in RETRY RadioControl.start()\n");
			return;
		}

#ifdef TOSSIM
		TERRA_MOTE_TYPE = call MoteType.get();
#endif		
		dbg(APPNAME, "BS::RadioControl.startDone(). TOS_NODE_ID=%d, TERRA_MOTE_TYPE = %d\n",TOS_NODE_ID,TERRA_MOTE_TYPE);
#ifdef MODULE_CTP
		call RoutingControl.start(); 		// CTP
#endif
		// Only for first initialization (boot)
		if (firstInic){
			reqProgBlock_t Data;
// EEPROM - incluir aqui a chamada para tentar carregar programa da EEPROM, atualizar version Id.
			firstInic = FALSE;
			// Request initial program version
			ReqState=RO_NEW_VERSION;
			Data.reqOper=RO_NEW_VERSION;
			Data.moteType = TERRA_MOTE_TYPE;
			Data.versionId = 0;
			Data.blockId = 0;
		 	lastRequestBlock = 0;
			ProgMoteSource = AM_BROADCAST_ADDR;
			sendReqProgBlock(&Data);
		 	// Wait next block up to time-out
		 	call ProgReqTimer.startOneShot(getRequestTimeout());
		}
#ifdef MODULE_CTP
#ifdef WITH_BSTATION
#ifdef TOSSIM
			if (TOS_NODE_ID==1)
#endif
			call RootControl.setRoot();
#endif		
#endif
		signal BSBoot.booted();
	}
	
	event void RadioControl.stopDone(error_t error) {
		dbg(APPNAME, "BS::RadioControl.stopDone().\n");
	}

	command void BSRadio.setRFPower(uint8_t powerIdx){
		dbg(APPNAME, "BS::BSRadio.setRFPower(%d).\n",powerIdx);
		if (powerIdx < 8) {
			userRFPowerIdx = powerIdx;
		}
	}
	
	
/*******************************
 * VM Main Timer operation
 *****************************/
	command uint32_t BSTimerVM.getNow(){return call TimerVM.getNow();}
	command void BSTimerVM.startOneShot(uint32_t dt){
		dbg(APPNAME, "BS::BSTimerVM.startOneShot() dt=%ld, getdt=%ld, isRunning=%s\n",dt,call TimerVM.getdt(),_TFstr(call TimerVM.isRunning()));
		if ( call TimerVM.isRunning() ) call TimerVM.stop();
		call TimerVM.startOneShot(dt);
		}
	command bool BSTimerVM.isRunning(){ return call TimerVM.isRunning();}
	command void BSTimerVM.stop(){ call TimerVM.stop();}	
	event void TimerVM.fired(){
		signal BSTimerVM.fired();
	}


/*******************************
 * VM Async Timer operation
 *****************************/
	command uint32_t BSTimerAsync.getNow(){return call TimerAsync.getNow();}
	command void BSTimerAsync.startOneShot(uint32_t dt){
		dbg(APPNAME, "BS::BSTimerAsync.startOneShot() dt=%ld, getdt=%ld, isRunning=%s\n",dt,call TimerAsync.getdt(),_TFstr(call TimerAsync.isRunning()));
		if ( call TimerAsync.isRunning() ) call TimerAsync.stop();
		call TimerAsync.startOneShot(dt);
		}
	command bool BSTimerAsync.isRunning(){ return call TimerAsync.isRunning();}
	command void BSTimerAsync.stop(){ call TimerAsync.stop();}
	event void TimerAsync.fired(){signal BSTimerAsync.fired();}
	
/* **********************************************************************************
 * 
 *                            Auxiliaries functions
 * 
\* **********************************************************************************/

	/**
	 * Return the next empty block
	 * Get next bit that is '0'. Return MAX_BLOCKS if all bits are set.
	 * @return Block id
	 */
	uint16_t getNextEmptyBlock(){
		uint16_t i;
		for (i=0;i<CURRENT_MAX_BLOCKS;i++){
			if (!call BM.get(i)) return i;
			}
		return CURRENT_MAX_BLOCKS;
	}

	/**
	 * Check if data queue has a dataSeq number
	 * 
	 * @param seq Sequence number to be checked
	 */
#ifdef MODE_SETDATA
	uint8_t hasDataSeq(uint16_t seq){
		uint16_t i=0;
		setDataBuff_t Buff;
		for (i=0; i < call setDataQ.size(); i++){
			call setDataQ.element(i,&Buff);
			dbg(APPNAME, "BS::hasDataSeq(): Buff.seq=%hhu,seq=%hhu \n",Buff.seq,seq);
			if (Buff.seq == (nx_uint16_t)seq) return i;
		}
		return (SET_DATA_LIST_SIZE*2);
	}
#endif

	void maxDataSeq(nx_uint16_t seq){	maxSeenDataSeq=(maxSeenDataSeq<seq)?seq:maxSeenDataSeq;}

/* **************************************************************\
*             Messages receive
\* **************************************************************/
	
#ifdef MODULE_CTP
	command uint16_t BSRadio.getParent(){
		uint16_t parent;
		if (call CtpInfo.getParent(&parent) == SUCCESS) return parent;
		return 0;		
	}
#endif

	/**
	* Sends out a DataBS message to Radio
	*/
#ifdef MODULE_CTP
	void sendBSN(){
		error_t stat;
		// Send to Radio
		memcpy(call sendBSNet.getPayload(&sendBuff,call sendBSNet.maxPayloadLength()), &tempOutputOutQ.Data, tempOutputOutQ.DataSize);
		dbg(APPNAME, "BS::sendBSNet(): Sending Message AM_ID=%d, size=%d, maxSize=%d\n", tempOutputOutQ.AM_ID,tempOutputOutQ.DataSize,call sendBSNet.maxPayloadLength());
		stat = call sendBSNet.send(&sendBuff, tempOutputOutQ.DataSize);
		if (stat != SUCCESS) {
			dbg(APPNAME,"BS::sendBSNet(): Error in Sending Message(%d))\n",stat);
			call sendTimer.startOneShot(reSendDelay);
		}
	}
#endif // MODULE_CTP
	

#ifdef MODULE_CTP
	event message_t* recSendBS.receive(message_t *msg, void *payload, uint8_t len){
		sendBS_t* xData;
		dbg(APPNAME, "BS::recSendBS.receive():\n");
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(sendBS_t));
		xData = (sendBS_t*)payload;
		if ( xData->Sender == recBS_last_Sender && xData->seq == recBS_last_seq) {
			dbg(APPNAME, "BS::recSendBS.receive(): discarding duplicated message\n");
			return msg;
		}
		recBS_last_Sender = xData->Sender; 
		recBS_last_seq = xData->seq;		
		tempInputInQ.AM_ID = AM_SENDBS;
		tempInputInQ.DataSize = sizeof(sendBS_t);
		tempInputInQ.fromSerial = FALSE;
		// put the message in OutQueue
		if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recSendBS.receive(): outQueue is full! Losting a message.\n");
		return msg;
	}
#endif //MODULE_CTP	


#ifdef MODULE_CTP
	event void sendBSNet.sendDone(message_t *msg, error_t error){
		if (error == SUCCESS) {						// Get next message
			dbg(APPNAME, "BS::sendBSNet.sendDone(): SUCCESS SendCounter=%hhu\n",sendCounter);
			call outQ.get(&tempOutputOutQ);
			sendCounter=0;
 			// If sendDataBS then signal the caller
 			if ( tempOutputOutQ.AM_ID==AM_SENDBS ) signal BSRadio.sendBSDone(msg,SUCCESS);
			call sendTimer.startOneShot(reSendDelay);
		} else {
			dbg(APPNAME, "BS::sendBSNet.sendDone(): FAIL\n");
			if (sendCounter < MAX_SEND_RETRIES) { 	// Try to send again
				dbg(APPNAME, "BS::sendBSNet.sendDone(): FAIL-Retry SendCounter=%hhu\n",sendCounter);
				call sendTimer.startOneShot(reSendDelay);
			} else {								// Discard message and get next message
				dbg(APPNAME, "BS::sendBSNet.sendDone(): FAIL-Discard SendCounter=%hhu\n",sendCounter);
				call outQ.get(&tempOutputOutQ);
				sendCounter=0;
 				// If sendDataBS then signal the caller
	 			if ( tempOutputOutQ.AM_ID==AM_SENDBS ) signal BSRadio.sendBSDone(msg,FAIL);
				call sendTimer.startOneShot(reSendDelay);
			}
		}
	}
#endif // MODULE_CTP	


	/**
	 * Receive NewProgVersionNet and queue it in input queue
	 */
	void recNewProgVersionNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial){
		newProgVersion_t *xmsg;
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(newProgVersion_t));
		tempInputInQ.fromSerial = fromSerial;
		xmsg = (newProgVersion_t*)tempInputInQ.Data;
		dbg(APPNAME, "BS::recNewProgVersionNet_receive(): from %d, local MoteType= %d, Msg MoteType=%d\n",
						call RadioAMPacket.source(msg),TERRA_MOTE_TYPE, xmsg->moteType);
#ifdef ESP
/*
dbg(APPNAME,"\n\n len=%d\n",len);
dbg(APPNAME,"%02x:%03d, %02x:%03d, %02x:%03d, %02x:%03d, ",
		*(uint8_t*)(payload+0),*(uint8_t*)(payload+0),*(uint8_t*)(payload+1),*(uint8_t*)(payload+1),
		*(uint8_t*)(payload+2),*(uint8_t*)(payload+2),*(uint8_t*)(payload+3),*(uint8_t*)(payload+3));
dbg(APPNAME,"%02x:%03d, %02x:%03d, %02x:%03d, %02x:%03d\n",
		*(uint8_t*)(payload+4),*(uint8_t*)(payload+4),*(uint8_t*)(payload+5),*(uint8_t*)(payload+5),
		*(uint8_t*)(payload+6),*(uint8_t*)(payload+6),*(uint8_t*)(payload+7),*(uint8_t*)(payload+7));
dbg(APPNAME,"%02x:%03d, %02x:%03d, %02x:%03d, %02x:%03d\n ",
		tempInputInQ.Data[0],tempInputInQ.Data[0],tempInputInQ.Data[1],tempInputInQ.Data[1],
		tempInputInQ.Data[2],tempInputInQ.Data[2],tempInputInQ.Data[3],tempInputInQ.Data[3]);

*/
#endif
dbg(APPNAME,"BS::recNewProgVersionNet_receive(): versionId=%04x:%d, blockLen=%04x:%d, blockStart=%04x:%d, startProg=%04x:%d, endProg=%04x:%d, appSize=%04x:%d, \n",
		xmsg->versionId,xmsg->versionId,xmsg->blockLen,xmsg->blockLen,xmsg->blockStart,xmsg->blockStart,
		xmsg->startProg,xmsg->startProg,xmsg->endProg,xmsg->endProg,xmsg->appSize);

		// Discard duplicated message
		if ((xmsg->versionId <= ProgVersion) || (xmsg->versionId == lastRecNewProgVersion)) { dbg(APPNAME, "BS::recNewProgVersionNet_receive(): Discarding duplicated message!\n"); return;}
		// Store the last received ProgVersion
		lastRecNewProgVersion = xmsg->versionId; 
		call BMaux.clearAll();
		// Store the new ParentId
		if (lastRecParentId==0) {
			lastRecParentId = call RadioAMPacket.source(msg);
			dbg(APPNAME, "BS::recNewProgVersionNet_receive(): ParentId=%d \n",lastRecParentId);	
		}

		// Test if has the same MoteType. if not, only forward the message
		if ( xmsg->moteType == TERRA_MOTE_TYPE) {
//	dbg(APPNAME,"---> passo 1\n");
			// Test if the Local VM memory may accept the new app
			if (xmsg->appSize > (BLOCK_SIZE * CURRENT_MAX_BLOCKS)) {
				lastBigAppVersion = xmsg->versionId;		
//	dbg(APPNAME,"---> passo 1.1\n");
				return;
			} else {
				lastBigAppVersion = -1L;
//	dbg(APPNAME,"---> passo 1.2\n");
			}
			
//	dbg(APPNAME,"---> passo 2\n");
			tempInputInQ.AM_ID = AM_NEWPROGVERSION;
			tempInputInQ.DataSize = sizeof(newProgVersion_t);
//	dbg(APPNAME,"---> passo 3\n");
			// put the message in inQueue
			if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recNewProgVersionNet_receive(): inQueue is full! Losting a message.\n");
			// get source mote.
			ProgMoteSource = call RadioAMPacket.source(msg);
			// Save NewProgVersion to Forward it later (after first NewProgBlock)
			tempInputInQ.sendToMote = AM_BROADCAST_ADDR;
			memcpy(&lastNewProgVersion,&tempInputInQ,sizeof(GenericData_t));
//	dbg(APPNAME,"---> passo 4\n");			
		} else {
			// Forward the message
			// put the message in outQueue
			tempInputInQ.AM_ID = AM_NEWPROGVERSION;
			tempInputInQ.DataSize = sizeof(newProgVersion_t);
			tempInputInQ.sendToMote = AM_BROADCAST_ADDR;
			if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recNewProgVersionNet_receive(): inQueue is full! Losting a message.\n");
			
		}
	}

	/**
	 * Receive NewProgBlockNet and queue it in input queue
	 */
	 
	void recNewProgBlockNet_receive(message_t *msg, void *payload, uint8_t len,uint8_t fromSerial){
		newProgBlock_t *xmsg;
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(newProgBlock_t));
		tempInputInQ.fromSerial = fromSerial;
		xmsg = (newProgBlock_t*)tempInputInQ.Data;
		tempInputInQ.AM_ID = AM_NEWPROGBLOCK;
		tempInputInQ.DataSize = sizeof(newProgBlock_t);
		dbg(APPNAME, "BS::recNewProgBlockNet_receive(): xmsg->moteType=%d, local MoteType=%d, xmsg->versionId=%d,ProgVersion=%d, xmsg->blockId=%d, ProgBlockStart=%d\n",
						xmsg->moteType, TERRA_MOTE_TYPE, xmsg->versionId,ProgVersion,xmsg->blockId,ProgBlockStart);

		// Discard duplicated/Old message and forward different MoteType
		if ( xmsg->moteType == TERRA_MOTE_TYPE) {
			if (xmsg->versionId == ProgVersion) {
				if (!call BM.get(xmsg->blockId)){
					if (xmsg->blockId == ProgBlockStart){
						// Now can forward NewProgVersion message
						if (call outQ.put(&lastNewProgVersion)!=SUCCESS) dbg(APPNAME, "BS::recNewProgBlockNet_receive(): outQueue is full! Losting a message.\n");		
					}
					// put message in the inQueue
					if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recNewProgBlockNet_receive(): inQueue is full! Losting a message.\n");
					// get source mote.
					ProgMoteSource = call RadioAMPacket.source(msg);
					// Forward the message
					if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recNewProgBlockNet_receive(): outQueue is full! Losting a message.\n");
				} else {
					dbg(APPNAME, "BS::recNewProgBlockNet_receive(): Discarding duplicated message - block is 0!\n");
				}
			} else {
				if (xmsg->versionId > ProgVersion){
					// Retry request. Avoids previous big program.
					if (xmsg->versionId != lastBigAppVersion){
						call ProgReqTimer.startOneShot(getRequestTimeout());
					}
				} else
					dbg(APPNAME, "BS::recNewProgBlockNet_receive(): Discarding old version message!\n");
			}
		} else {
			// Forward the message -- different MoteType
			dbg(APPNAME, "BS::recNewProgBlockNet_receive(): xmsg->versionId=%d, lastRecNewProgBlock_versionId=%d, xmsg->blockId=%d, BMaux.get()=%d\n",
							xmsg->versionId,lastRecNewProgBlock_versionId,xmsg->blockId,call BMaux.get(xmsg->blockId));
			if (xmsg->versionId != lastRecNewProgBlock_versionId || call BMaux.get(xmsg->blockId)==0 ){
				lastRecNewProgBlock_versionId = xmsg->versionId;
				call BMaux.set(xmsg->blockId);
				tempInputInQ.sendToMote = AM_BROADCAST_ADDR;
				dbg(APPNAME, "BS::recNewProgBlockNet_receive(): Forwarding different MoteType message!\n" );
				if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recNewProgBlockNet_receive(): outQueue is full! Losting a message. (forwarding different MoteType)\n");
			} else {
				dbg(APPNAME, "BS::recNewProgBlockNet_receive(): Discarding different MoteType message!\n");
			}
		}
	}

	/**
	 * Receive ReqProgBlockNet and queue it in input queue
	 */
	void recReqProgBlockNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial){
		reqProgBlock_t *xmsg;
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(reqProgBlock_t));
		tempInputInQ.fromSerial = fromSerial;
		xmsg = (reqProgBlock_t*)tempInputInQ.Data;
		dbg(APPNAME, "BS::recReqProgBlockNet_receive(). Local MoteType=%d, Msg MoteType=%d\n", TERRA_MOTE_TYPE,xmsg->moteType );
		// Test if it has same MoteType
		if ( xmsg->moteType == TERRA_MOTE_TYPE){
			tempInputInQ.AM_ID = AM_REQPROGBLOCK;
			tempInputInQ.DataSize = sizeof(reqProgBlock_t);
			// put message in the inQueue
			if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recReqProgBlockNet_receive(): inQueue is full! Losting a message.\n");			
		} else {
			// TODO - Testar se é segunda mensagem e repassar para a Raiz
			dbg(APPNAME, "BS::recReqProgBlockNet_receive(): Different MoteType. Forwarding to my Parent = %d.\n",lastRecParentId);
				// Reset last values when blockId==0
				if ( xmsg->blockId == 0 ){
					call BMaux.clear(xmsg->blockId);
					lastRecNewProgVersion=0;
				}
				tempInputInQ.AM_ID = AM_REQPROGBLOCK;
				tempInputInQ.DataSize = sizeof(reqProgBlock_t);
				tempInputInQ.sendToMote = lastRecParentId;
				if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recReqProgBlockNet_receive(): outQueue is full! Losting a message to my parent.\n");			
		}		
	}


	/**
	* Receive SetDataNDNet and queue it in input queue
	*/
	void recSetDataNDNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial){
		setDataND_t *xmsg;
		dbg(APPNAME, "BS::recSetDataNDNet_receive().\n");
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(setDataND_t));
		tempInputInQ.fromSerial = fromSerial;
		xmsg = (setDataND_t*)tempInputInQ.Data;
		tempInputInQ.AM_ID = AM_SETDATAND;
		tempInputInQ.DataSize = sizeof(setDataND_t);
		// Discard old message
		if (xmsg->versionId != ProgVersion) { dbg(APPNAME, "BS::recSetDataNDNet_receive(): Discarding old version!\n"); return;}
		if (xmsg->seq < (NewDataSeq+1)) { dbg(APPNAME, "BS::recSetDataNDNet_receive(): Discarding old data!\n"); return;}
		// put message in the inQueue
		if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recSetDataNDNet_receive(): inQueue is full! Losting a message.\n");
		// Get source mote.
		NewDataMoteSource = call RadioAMPacket.source(msg);
		// if it is a normal message, then broadcast it
		if (xmsg->seq == (NewDataSeq+1)){
			tempInputInQ.sendToMote=AM_BROADCAST_ADDR;
			if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recSetDataNDNet_receive(): outQueue is full! Losting a message.\n");		
			}
	}


	void recCustomMsgNet_receive(message_t *msg, void *payload, uint8_t len){
		uint8_t am_id= (uint8_t)call RadioAMPacket.type(msg);
		dbg(APPNAME,"BS::recCustomMsgNet.receive():\n");
		dbg("VMDBG","Radio: Received Custom Msg AM=%d from %d\n", am_id , call RadioAMPacket.source(msg));
		signal BSRadio.receive(am_id,msg,payload,len);
	}

	/**
	* Receive ReqDataNet and queue it in input queue
	*/
	void recReqDataNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial){
		//reqData_t *xmsg;
		dbg(APPNAME, "BS::recReqDataNet_receive().\n");
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(reqData_t));
		tempInputInQ.fromSerial = fromSerial;
		//xmsg = (reqData_t*)tempInputInQ.Data;
		tempInputInQ.AM_ID = AM_REQDATA;
		tempInputInQ.DataSize = sizeof(reqData_t);
		// put message in the inQueue
		if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recReqDataNet_receive(): inQueue is full! Losting a message.\n");
	}

	// Centralized Radio Receiver
	event message_t * RadioReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
		dbg(APPNAME, "BS::RadioReceiver.receive(). AM=%hhu from %d.  disseminatorRoot=%d\n",id,call RadioAMPacket.source(msg),disseminatorRoot);
		// Switch AM_ID
		switch (id){
			case AM_NEWPROGVERSION : 
				recNewProgVersionNet_receive(msg,payload,len,FALSE);
				break;	
			case AM_NEWPROGBLOCK :
				recNewProgBlockNet_receive(msg,payload,len,FALSE);
				break;	
			case AM_REQPROGBLOCK :
				recReqProgBlockNet_receive(msg,payload,len,FALSE);
				break;	
			case AM_SETDATAND :
				recSetDataNDNet_receive(msg,payload,len,FALSE);
				break;	
			case AM_REQDATA :
				recReqDataNet_receive(msg,payload,len,FALSE);
				break;	
			default:
				if (id >= AM_CUSTOM_START && id <= AM_CUSTOM_END) { // AM_CUSTOM Range
					if (loadingProgramFlag == FALSE){
						recCustomMsgNet_receive(msg,payload,len);
						}
				} else {
					dbg(APPNAME, "BS::RadioReceiver.receive(). Received a undefined AM=%hhu from %hhu\n",id,call RadioAMPacket.source(msg));	 		
				}
				break;
		}
		return msg;
	}


#ifdef WITH_BSTATION	
	// Centralized Serial Receiver -- Used only with WITH_BSTATION
	event message_t * SerialReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
#ifdef TOSSIM
			if (TOS_NODE_ID==1)
#endif
			{
			dbg(APPNAME, "BS::SerialReceiver.receive(). AM=%hhu from %hhu.  disseminatorRoot=%d\n",id,call RadioAMPacket.source(msg) ,disseminatorRoot);
			// Switch AM_ID
			switch (id){
				case AM_NEWPROGVERSION : 
					recNewProgVersionNet_receive(msg,payload,len,TRUE);
					break;	
				case AM_NEWPROGBLOCK :
					recNewProgBlockNet_receive(msg,payload,len,TRUE);
					break;	
				case AM_REQPROGBLOCK :
					recReqProgBlockNet_receive(msg,payload,len,TRUE);
					break;	
				default:
					if (id >= AM_CUSTOM_START && id <= AM_CUSTOM_END) { // AM_CUSTOM Range
						if (loadingProgramFlag == FALSE){
							recCustomMsgNet_receive(msg,payload,len);
						}
					} else {
						dbg(APPNAME, "BS::SerialReceiver.receive(). Received a undefined AM=%hhu from %hhu\n",id,call RadioAMPacket.source(msg));	 		
					}
					break;
			}
			}
		return msg;		
	}

#ifdef WITH_AUX_BSTATION	
	// Centralized Serial Receiver -- Used only with WITH_AUX_BSTATION
	event message_t * Serial1Receiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
#ifdef TOSSIM
			if (TOS_NODE_ID==1)
#endif
			{
			dbg(APPNAME, "BS::Serial1Receiver.receive(). AM=%hhu from %hhu.  disseminatorRoot=%d\n",id,0,disseminatorRoot);
			// Switch AM_ID
			switch (id){
				case AM_NEWPROGVERSION : 
					recNewProgVersionNet_receive(msg,payload,len,TRUE);
					break;	
				case AM_NEWPROGBLOCK :
					recNewProgBlockNet_receive(msg,payload,len,TRUE);
					break;	
				default:
					if (id >= AM_CUSTOM_START && id <= AM_CUSTOM_END) { // AM_CUSTOM Range
						if (loadingProgramFlag == FALSE){
							recCustomMsgNet_receive(msg,payload,len);
						}
					} else {
						dbg(APPNAME, "BS::Serial1Receiver.receive(). Received a undefined AM=%hhu from %hhu\n",id,0);	 		
					}
					break;
			}
			}
		return msg;		
	}
#endif // WITH_AUX_BSTATION	

#endif // WITH_BSTATION	

	

/* ******************************************************************************
*                       Upload control functions
\* ******************************************************************************/
 	/**
 	 * Process a received newProgVersion message
 	 * @param Data Message data
 	 */ 
 	void procNewProgVersion(newProgVersion_t* Data){
		dbg(APPNAME, "BS::procNewProgVersion().\n");
		// Stop the VM
 		signal BSUpload.stop();
 		signal BSUpload.resetMemory();
 		TViewer("vmstop",0,0);
 		// Get new version ID
		ProgVersion = Data->versionId;
 		ProgBlockStart = Data->blockStart;
 		ProgBlockLen = Data->blockLen;
 		// Update environment values: StartProg addr, etc..
 		signal BSUpload.setEnv(Data);
		dbg(APPNAME, "BS::procNewProgVersion(). ProgVersion=%d, ProgBlockStart=%d, ProgBlockLen=%d \n",ProgVersion,ProgBlockStart,ProgBlockLen);
 		// reset all memory (leave set unused blocks)
 		atomic call BM.resetRange(ProgBlockStart,(ProgBlockStart+ProgBlockLen)-1);
		{
	 		reqProgBlock_t xData;
	 		// send a reqProgBlock full
	 		ProgTimeOutCounter=0;
		 	xData.reqOper=RO_DATA_FULL;
		 	ReqState = RO_DATA_FULL;
			xData.moteType = TERRA_MOTE_TYPE;
		 	xData.versionId = ProgVersion;
		 	xData.blockId = ProgBlockStart;
		 	loadingProgramFlag = TRUE;
		 	sendReqProgBlock(&xData);
		 	// Wait next block up to time-out
	 		call ProgReqTimer.startOneShot(getRequestTimeout());
		}
 	}
 	/**
 	 * Process a received newProgBlock message
 	 * @param Data Message data
 	 */ 
	 void procNewProgBlock(newProgBlock_t* Data){
		 uint8_t lData[BLOCK_SIZE];
		 uint16_t i;
		 uint16_t Addr=0;
		 dbg(APPNAME, "BS::procNewProgBlock(). version=%hhu, blockId=%hhu, ReqState=%d\n",Data->versionId,Data->blockId,ReqState);
		 call ProgReqTimer.stop();
		 // Convert nx_uint8_t to uint8_t
		 for (i=0; i < BLOCK_SIZE; i++) lData[i]=(uint8_t)Data->data[i];
		 // Calculate memory position (Addr)
		 Addr = Data->blockId * BLOCK_SIZE;
		 // Update memory and BitMap
		 signal BSUpload.loadSection(Addr , (uint8_t)BLOCK_SIZE, &lData[0]);
		 call BM.set((uint16_t)Data->blockId);
		 // Reset timeOut counter
		 ProgTimeOutCounter = 0;
		 // Check if it was the last block
		 if ( call BM.isAllBitSet()) {
		 	loadingProgramFlag = FALSE;
		 	// Start the VM
 			ReqState=ST_IDLE;
			TViewer("vmstart",0,0);
			signal BSUpload.start(TRUE);
		 } else {
		 	// Wait next block
 			ReqState=ST_WAIT_PROG_BLK;
	 		call ProgReqTimer.startOneShot(getRequestTimeout());
		 }
	 }
 	/**
 	* Process a received recProgBlock message
 	* @param Data Message data
 	\**/ 
	 void procRecReqProgBlock(reqProgBlock_t* Data){
		 newProgVersion_t xVersion;
		 newProgBlock_t xBlock;
		 uint8_t* mem;
		 uint16_t i=0;
		 dbg(APPNAME, "BS::procRecReqProgBlock(). Local version=%hhu, Req Version %hhu Oper=%hhu, BM.isAllBitSet=%s\n", ProgVersion, Data->versionId, Data->reqOper,_TFstr(call BM.isAllBitSet()));
		switch (Data->reqOper){
			case RO_NEW_VERSION: 
				if ((ProgVersion > Data->versionId) && (ProgVersion > 0) && call BM.isAllBitSet()){
					xVersion.moteType = TERRA_MOTE_TYPE;
					xVersion.versionId = ProgVersion;
				 	xVersion.blockLen = ProgBlockLen;
				 	xVersion.blockStart = ProgBlockStart;
				 	signal BSUpload.getEnv(&xVersion);
				 	sendNewProgVersion(&xVersion);
				 } else {
					 dbg(APPNAME, "BS::procRecReqProgBlock(). Request RO_NEW_VERSION discarted!\n");
				 }
				break;
			case RO_DATA_FULL:
				// Schedule the dissemination
				if ((ProgVersion == Data->versionId) && (ProgVersion > 0) && call BM.isAllBitSet()){
					DsmBlockCount=0;
				 	call SendDataFullTimer.startOneShot(DISSEMINATION_TIMEOUT);
				 } else {
					 dbg(APPNAME, "BS::procRecReqProgBlock(). Request RO_DATA_FULL discarted!\n");
				 }
				break;
			case RO_DATA_SINGLE:
				 if ((ProgVersion == Data->versionId) && (ProgVersion > 0) && call BM.get(Data->blockId)){
					  xBlock.moteType = TERRA_MOTE_TYPE;
					  xBlock.versionId = ProgVersion;
					  xBlock.blockId = Data->blockId;
					  mem = signal BSUpload.getSection((Data->blockId * BLOCK_SIZE));
					  for (i=0; i < BLOCK_SIZE; i++) xBlock.data[i] = *(nx_uint8_t*)(mem+i);
			 	 	  ReqState=ST_WAIT_PROG_BLK;
					  sendNewProgBlock(&xBlock);
				  } else {
					  dbg(APPNAME, "BS::procRecReqProgBlock(). Request RO_DATA_SINGLE discarted! Block=%hhu\n",call BM.get(Data->blockId));
				  }
				  break;
		}
	 }
	 /**
 	 * Request a missing data block
 	 */  	
	 task void ProgReqTimerTask(){
		 uint16_t nextBlock=CURRENT_MAX_BLOCKS;
		 reqProgBlock_t Data;
		 uint32_t timeout=getRequestTimeout();
		 nextBlock = getNextEmptyBlock();
		 dbg(APPNAME, "BS::ProgReqTimer.fired(). nextBlock=%d lastRequestBlock=%d, ReqState=%d, ProgTimeOutCounter=%d\n",nextBlock,lastRequestBlock,ReqState,ProgTimeOutCounter);
		 lastRecNewProgVersion = 0;
		 switch (ReqState){
		 	case RO_NEW_VERSION:
				 ProgTimeOutCounter++;
		 		// If it reach the retry limit, wait for long time and retry again
				 if (ProgTimeOutCounter>=3) {
					ProgTimeOutCounter = 0;
				 	lastRecNewProgVersion=0;
				 	timeout = REQUEST_VERY_LONG_TIMEOUT;
				 } 
			 	Data.reqOper=RO_NEW_VERSION;
				Data.moteType = TERRA_MOTE_TYPE;
			 	Data.versionId = 0;
			 	Data.blockId = ProgBlockStart;
			 	lastRequestBlock = 0;
			 	ProgMoteSource = AM_BROADCAST_ADDR;
			 	sendReqProgBlock(&Data);
			 	// Wait next block up to time-out
			 	call ProgReqTimer.startOneShot(timeout);
		 		break;
		 	case RO_DATA_FULL:
		 		// timeout on full data request, retry for the next block
		 		//nextBlock = getNextEmptyBlock();
			 	if (nextBlock < ProgBlockLen){
					// Check repeated requests
					if (lastRequestBlock == nextBlock) ProgTimeOutCounter++;
					if (ProgTimeOutCounter<=3) {
						lastRequestBlock = nextBlock;
					 	Data.reqOper=RO_DATA_FULL;
						ReqState = RO_DATA_FULL;
						Data.moteType = TERRA_MOTE_TYPE;
						Data.versionId = ProgVersion;
						Data.blockId = nextBlock;
						sendReqProgBlock(&Data);
						// Wait next block up to time-out
						call ProgReqTimer.startOneShot(getRequestTimeout());
					} else {
						ReqState = RO_NEW_VERSION;
					 	Data.reqOper=RO_NEW_VERSION;
						Data.moteType = TERRA_MOTE_TYPE;
					 	Data.versionId = 0;
					 	Data.blockId = ProgBlockStart;
						ProgTimeOutCounter=0;
					 	lastRequestBlock = 0;
					 	ProgMoteSource = AM_BROADCAST_ADDR;
					 	sendReqProgBlock(&Data);
					 	// Wait next block up to time-out
					 	call ProgReqTimer.startOneShot(timeout);
					}
				 } else {
					 // fill data has finished
					 if ( call BM.isAllBitSet()) {
						 // Start the VM
						 ReqState = RO_IDLE;
						 TViewer("vmstart",0,0);
						 signal BSUpload.start(TRUE);
					 }				 	
				 }
		 		break;		 	
		 	case RO_DATA_SINGLE:
		 		// timeout on single data request, retry for the next block
		 		//nextBlock = getNextEmptyBlock();
			 	if (nextBlock < CURRENT_MAX_BLOCKS){
				 	Data.reqOper=RO_DATA_SINGLE;
				 	ReqState = RO_DATA_SINGLE;
					Data.moteType = TERRA_MOTE_TYPE;
				 	Data.versionId = ProgVersion;
				 	Data.blockId = nextBlock;
				 	sendReqProgBlock(&Data);
				 	// Wait next block up to time-out
				 	call ProgReqTimer.startOneShot(getRequestTimeout());
				 } else {
				 	// fill data has finished
					 if ( call BM.isAllBitSet()) {
					 	// Start the VM
				 		ReqState = RO_IDLE;
				 		TViewer("vmstart",0,0);
						signal BSUpload.start(TRUE);
					 }				 	
				 }
		 		break;		 	
		 } // end switch
	 }

	 event void ProgReqTimer.fired(){
	 	post ProgReqTimerTask();
	 }


	event void SendDataFullTimer.fired(){
		newProgBlock_t xBlock;
		 dbg(APPNAME, "BS::SendDataFullTimer.fired().\n");
		// Disseminating Prog blocks
		if (call BM.get(DsmBlockCount+ProgBlockStart)){
			uint8_t *mem;
			uint16_t i;
 		    xBlock.moteType = TERRA_MOTE_TYPE;
			xBlock.versionId = ProgVersion;
			xBlock.blockId = (uint16_t)(DsmBlockCount + ProgBlockStart);
			mem = signal BSUpload.getSection(((DsmBlockCount+ProgBlockStart) * BLOCK_SIZE));
			for (i=0; i < BLOCK_SIZE; i++) xBlock.data[i] = *(nx_uint8_t*)(mem+i);
			sendNewProgBlock(&xBlock);
		}
		DsmBlockCount++;
		if (DsmBlockCount < ProgBlockLen){
			// Wait to send next block
			call SendDataFullTimer.startOneShot(DISSEMINATION_TIMEOUT);
		} else {
			ReqState = ST_IDLE;
		}
	}

 
 	/**
 	 * Process a received setDataND message
 	 * @param Data Message data
 	 */ 	
#ifdef MODE_SETDATA
	void procSetDataND(setDataND_t* Data){
 		setDataBuff_t buff;
		uint8_t lData[SET_DATA_SIZE],secp=0,secLen;
		uint16_t secAddr,x,i;
		reqData_t xData;
		maxDataSeq(Data->seq);
		dbg(APPNAME, "BS::procSetDataND(): Seq=%hhu. localSeq+1=%hhu.\n",Data->seq,NewDataSeq+1);
		if (Data->seq == NewDataSeq+1){
			NewDataSeq++;
			// Reset retry counter
			DataTimeOutCounter=0;
			// Insert update information in queue
			buff.versionId = Data->versionId;
			buff.seq = Data->seq;
			buff.AM_ID = AM_SETDATAND;
			memcpy(&buff.buffer[0], Data, sizeof(setDataND_t));
			if (call setDataQ.size() == call setDataQ.maxSize()) call setDataQ.remove();
			call setDataQ.put(&buff);
			// If msg is to me, then Update the memory
			if (Data->targetMote == TOS_NODE_ID){
				secp=0;
				for (x=0;x<Data->nSections;x++){
					secAddr=Data->Data[secp++];
					secAddr = secAddr + (Data->Data[secp++] << 8); 
					secLen = Data->Data[secp++];
					for (i=0; i < secLen; i++) lData[i] = Data->Data[secp++];
					signal BSUpload.loadSection(secAddr , secLen, &lData[0]);
				}
			} else {
				dbg(APPNAME, "BS::procSetDataND(): Is not to me! Target=%hhu.\n",Data->targetMote);				
			}
		} else {
			// if local DataSeq is too old, jump to near received DataSeq and request newData.
			if (Data->seq >= (NewDataSeq + SET_DATA_LIST_SIZE)){
				NewDataSeq = ((Data->seq - SET_DATA_LIST_SIZE)>0)?(Data->seq - SET_DATA_LIST_SIZE):0;
				xData.versionId = ProgVersion;
				xData.seq = NewDataSeq+1;
				sendReqData(&xData);
				// Reset retry counter
				DataTimeOutCounter=0;
				// wait for new data
				call DataReqTimer.startOneShot(getRequestTimeout());
			} else { // DataSeq is not too old, Request Current value
				if ((Data->seq < (NewDataSeq + SET_DATA_LIST_SIZE)) && (Data->seq > NewDataSeq)){
					xData.versionId = ProgVersion;
					xData.seq = NewDataSeq+1;
					sendReqData(&xData);
					// Reset retry counter
					DataTimeOutCounter=0;
					// wait for new data
					call DataReqTimer.startOneShot(getRequestTimeout());
				}
			}
		}	
 	}
#endif
 	/**
 	 * Process a received reqData message
 	 * @param Data Message data
 	 */
#ifdef MODE_SETDATA
	void procReqData(reqData_t* Data){
		uint8_t idx=0;
		setDataBuff_t Buff;
		setDataND_t xData;
		idx = hasDataSeq(Data->seq);
		dbg(APPNAME, "BS::procReqData(). Data->seq=%hhu, idx=%hhu\n",Data->seq,idx);
		// if data queue has DataSeq, then broadcast information
		if (idx < (SET_DATA_LIST_SIZE*2)){
			call setDataQ.element(idx,&Buff);
			call setDataQ.element(idx,&xData);
			sendSetDataND(&xData);				
		} else {
			dbg(APPNAME, "BS::procReqData(). idx=%hhu >= SET_DATA_LIST_SIZE=%hhu\n",idx,SET_DATA_LIST_SIZE);
		}
	}
	/**
	 * Try to request a new setData message
	 */
	event void DataReqTimer.fired(){
		reqData_t xData;
		dbg(APPNAME, "BS::DataReqTimer.fired().\n");
		if ((DataTimeOutCounter < 3) && (NewDataSeq < maxSeenDataSeq)) {
			// Send reqData
			xData.versionId = ProgVersion;
			xData.seq = NewDataSeq+1;
			sendReqData(&xData);			
			// Reset retry counter
			DataTimeOutCounter=0;
			// wait for new data
			call DataReqTimer.startOneShot(getRequestTimeout());		
		} else {
			dbg(APPNAME, "BS::DataReqTimer.fired(): Requested all expected setData\n");
		}
	}
#endif
	/**
	* Process each event from input Queue
	*/
	task void procInputEvent(){
		{
			dbg(APPNAME, "BS::procInputEvent().\n");
			if (call inQ.read(&tempOutputInQ)==SUCCESS) {
				call inQ.get(&tempOutputInQ);
				switch (tempOutputInQ.AM_ID) {
					case AM_NEWPROGVERSION: procNewProgVersion((newProgVersion_t*)&tempOutputInQ.Data); break;
					case AM_NEWPROGBLOCK: procNewProgBlock((newProgBlock_t*) &tempOutputInQ.Data); break;
					case AM_REQPROGBLOCK: procRecReqProgBlock((reqProgBlock_t*) &tempOutputInQ.Data); break;
					#ifdef MODE_SETDATA
					case AM_SETDATAND: procSetDataND((setDataND_t*) &tempOutputInQ.Data); break;
					case AM_REQDATA: procReqData((reqData_t*) &tempOutputInQ.Data); break;
					#endif
					default: dbg(APPNAME, "BS::procInputEvent(): Unknow AM_ID=%hhu\n",tempOutputInQ.AM_ID); break;
				}
				dbg(APPNAME, "BS::procInputEvent(): nextMessage.\n");
				call inQ.get(&tempOutputInQ);
				post procInputEvent();
			} else {
				call inQ.get(&tempOutputInQ);
				dbg(APPNAME, "BS::procInputEvent(): inQueue is empty!\n");			
			}
		}		
	}
	
	/**
	* Process new dequeued received message
	*/
	event void inQ.dataReady(){
		dbg(APPNAME, "BS::inQ.dataReady().\n");
		post procInputEvent();
	}


/* *********************************************************************
*              Messages send
\* *********************************************************************/
task void forceRadioDone(){
	uint8_t id = tempOutputOutQ.AM_ID;
	dbg(APPNAME, "BS::forceRadioDone(): am_id=%d \n",id);
	signal RadioSender.sendDone[id](&sendBuff, SUCCESS);
}

uint8_t isOtherNet(uint16_t addr){return (addr!=AM_BROADCAST_ADDR) && (addr>>11) != (TOS_NODE_ID>>11);}

	/**
	* Sends out a xxxx message
	*/


		error_t RadioSender_send(uint8_t am_id, uint16_t target, message_t* msg, uint8_t len, uint8_t fromSerial){
			error_t stat=SUCCESS;
#ifdef WITH_BSTATION
			memcpy(&serialAux,&sendBuff,sizeof(message_t));
			lastFromSerial = fromSerial;
#ifdef WITH_AUX_BSTATION
			memcpy(&serial1Aux,&sendBuff,sizeof(message_t));
#endif
#ifdef MODULE_CTP
			if (tempOutputOutQ.AM_ID != AM_SENDBS && target != 0){
#endif
#endif
				dbg(APPNAME, "BS::RadioSender_send(): MoteID=%d, AM=%d, to=%d, sendCounter=%d, fromSerial=%d\n",MoteID,tempOutputOutQ.AM_ID,tempOutputOutQ.sendToMote,sendCounter,fromSerial);			
				if (!isOtherNet(tempOutputOutQ.sendToMote) && !tempOutputOutQ.sendToMote==0){
					stat =  call RadioSender.send[tempOutputOutQ.AM_ID](tempOutputOutQ.sendToMote, &sendBuff, tempOutputOutQ.DataSize);
				} else {
					dbg(APPNAME, "BS::RadioSender_send():bypassing radio \n");
					post forceRadioDone();
				}
#ifdef WITH_BSTATION
#ifdef MODULE_CTP
			} else {
				// Remove from queue and do not retry to send.
				call outQ.get(&tempOutputOutQ);
				sendCounter=0;
			}
#endif
#endif
			return stat;
		}

	void sendRadioN(){
		error_t err;
		dbg(APPNAME,"BS::sendRadioN(): AM=%hhu to %d, reqAck=%s\n",tempOutputOutQ.AM_ID, tempOutputOutQ.sendToMote, _TFstr((tempOutputOutQ.reqAck & (1<<REQ_ACK_BIT)) > 0));
		memcpy(call RadioPacket.getPayload(&sendBuff,call RadioPacket.maxPayloadLength()), &tempOutputOutQ.Data, tempOutputOutQ.DataSize);
#ifdef LPL_ON
		call LowPowerListening.setRemoteWakeupInterval( &sendBuff, SLEEP );
#endif

		if ( (tempOutputOutQ.reqAck & (1<<REQ_ACK_BIT)) > 0){
			if (call RadioAck.requestAck(&sendBuff) != SUCCESS) dbg(APPNAME, "BS::sendRadioN()(): requestAck() error!\n");
		} else {
			if (call RadioAck.noAck(&sendBuff) != SUCCESS) dbg(APPNAME, "BS::sendRadioN()(): requestNoAck() error!\n");			
		}

		if (tempOutputOutQ.RFPower > 0) call AMAux.setPower(&sendBuff,tempOutputOutQ.RFPower);
		err = RadioSender_send(tempOutputOutQ.AM_ID,tempOutputOutQ.sendToMote, &sendBuff, tempOutputOutQ.DataSize, tempOutputOutQ.fromSerial);
		if (err != SUCCESS) {
			dbg(APPNAME,"BS::sendRadioN(): Error %hhu in sending Message AM=%hhu to node=%d via radio\n",err,tempOutputOutQ.AM_ID, tempOutputOutQ.sendToMote);
			call sendTimer.startOneShot(reSendDelay);
		} else {
			TViewer("radio",tempOutputOutQ.sendToMote,0);
			}		
	}


	/**
	* Process each event from output Queue
	*/
	task void sendMessage(){
		sendCounter++;
		if (call outQ.read(&tempOutputOutQ)==SUCCESS) {
		dbg(APPNAME, "BS::sendMessage(): AM=%d, sendToMote=%d.\n",tempOutputOutQ.AM_ID, tempOutputOutQ.sendToMote);
		switch (tempOutputOutQ.AM_ID) {
#ifdef MODULE_CTP
			case AM_SENDBS: 
				// Send to Radio/CTP or UART
#ifdef WITH_BSTATION
#ifdef TOSSIM
			if (TOS_NODE_ID==1)
#endif
				// WITH_BSTATION
				sendRadioN(); 
#else
				// NO_BS
				sendBSN();
#endif
				break;
#endif // MODULE_CTP
			case AM_NEWPROGVERSION: sendRadioN(); break;
			case AM_NEWPROGBLOCK:	sendRadioN(); break;
			case AM_REQPROGBLOCK:	sendRadioN(); break;
#ifdef MODE_SETDATA
			case AM_SETDATAND: 		sendRadioN(); break;
			case AM_REQDATA: 		sendRadioN(); break;
#endif
			default: 
				if (tempOutputOutQ.AM_ID >= AM_CUSTOM_START && tempOutputOutQ.AM_ID <= AM_CUSTOM_END) { // AM_CUSTOM Range
					sendRadioN();
				}				
				break;
			} 
		} else {
			call outQ.get(&tempOutputOutQ); // eventually clean the queue
			dbg(APPNAME, "BS::sendMessage(): outQueue is empty!\n");			
		}
	}

	/**
	 * Schedule next send from output queue
	 */
	event void outQ.dataReady(){
		dbg(APPNAME, "BS::outQ.dataReady().\n");
		sendCounter=0;
		call sendTimer.startOneShot(reSendDelay);
	}
	

	/**
	 * Process next send from output queue
	 */
	task void sendNextMsg(){
		dbg(APPNAME, "BS::sendNextMsg(): \n");
		if (sendCounter < MAX_SEND_RETRIES) { 	// Try to send again
			post sendMessage();
		} else {								// Discard message and get next message
			call outQ.get(&tempOutputOutQ);
			sendCounter=0;
			post sendMessage();
		}	
	}
	event void sendTimer.fired(){
		dbg(APPNAME, "BS::sendTimer.fired(): \n");
		post sendNextMsg();
	}




	/**
	* General sendDone().
	* @param error Error status
	*/
	void RadioSender_sendDone(am_id_t id,message_t *msg, error_t error){
	  bool doneStatus, reqAck;
	  //bool reqRetry;
	  //GenericData_t tempBuff;		
	  if (id > AM_RESERVED_END) {
	  	call outQ.read(&tempOutputOutQ);
	  	doneStatus = (error == SUCCESS);
	  	reqAck   = (tempOutputOutQ.reqAck & (1<<REQ_ACK_BIT)) > 0; 
	  	//reqRetry = (tempOutputOutQ.reqAck & (1<<REQ_RETRY_BIT)) > 0; 
	  	if (doneStatus && reqAck) doneStatus = (uint8_t)call RadioAck.wasAcked(msg);  
		if (doneStatus) {						// Get next message
			dbg(APPNAME, "BS::sendDone(): SUCCESS SendCounter=%hhu\n",sendCounter);
			call outQ.get(&tempOutputOutQ); 
			sendCounter=0;
			call sendTimer.startOneShot(reSendDelay);
			if ( tempOutputOutQ.AM_ID >= AM_CUSTOM_START && tempOutputOutQ.AM_ID <= AM_CUSTOM_END){
				dbg(APPNAME,"BS::sendDone(): UsrMsg err=%d ack=%d, \n",error,call RadioAck.wasAcked(msg));
				if (reqAck == TRUE) 
					signal BSRadio.sendDoneAck(tempOutputOutQ.AM_ID,msg,tempOutputOutQ.Data,error, call RadioAck.wasAcked(msg));
				else
					signal BSRadio.sendDone(tempOutputOutQ.AM_ID,msg,tempOutputOutQ.Data,error);
			}
		} else {
			dbg(APPNAME, "BS::sendDone(): FAIL\n");
			if (sendCounter < MAX_SEND_RETRIES) { 	// Try to send again
				dbg(APPNAME, "BS::sendDone(): FAIL-Retry SendCounter=%hhu\n",sendCounter);
				call sendTimer.startOneShot(reSendDelay);
			} else {								// Discard message and get next message
				dbg(APPNAME, "BS::sendDone(): FAIL-Discard SendCounter=%hhu\n",sendCounter);
				call outQ.get(&tempOutputOutQ);
				sendCounter=0;
				call sendTimer.startOneShot(reSendDelay);
				if ( tempOutputOutQ.AM_ID >= AM_CUSTOM_START && tempOutputOutQ.AM_ID <= AM_CUSTOM_END){
					dbg(APPNAME,"BS::sendDone(): FAIL-UsrMsg err=%d ack=%d, \n",error,call RadioAck.wasAcked(msg));
					if (reqAck == TRUE) 
						signal BSRadio.sendDoneAck(tempOutputOutQ.AM_ID,msg,tempOutputOutQ.Data,error, FALSE);
//						signal BSRadio.sendDoneAck(tempOutputOutQ.AM_ID,msg,tempOutputOutQ.Data,error, call RadioAck.wasAcked(msg));
					else
						signal BSRadio.sendDone(tempOutputOutQ.AM_ID,msg,tempOutputOutQ.Data,error);
				}
			}
		}
	  }
	}

	event void RadioSender.sendDone[am_id_t id](message_t *msg, error_t error){
#ifdef WITH_BSTATION
#ifdef TOSSIM
		if (TOS_NODE_ID==1) {
#endif
			// Only sends to Serial if it is not to a specific node, to node 0, or to another NET_ID
			if (sendCounter==1 && lastFromSerial==FALSE && (tempOutputOutQ.sendToMote==0 || tempOutputOutQ.sendToMote==AM_BROADCAST_ADDR || isOtherNet(tempOutputOutQ.sendToMote))){
				if (
					tempOutputOutQ.AM_ID == AM_REQPROGBLOCK || 
					tempOutputOutQ.AM_ID == AM_NEWPROGVERSION || 
					tempOutputOutQ.AM_ID == AM_NEWPROGBLOCK || 
					(tempOutputOutQ.AM_ID >= AM_CUSTOM_START && tempOutputOutQ.AM_ID <= AM_CUSTOM_END)) {
					dbg(APPNAME, "BS::RadioSender_send(): calling SerialSender(): \n");
					call SerialSender.send[tempOutputOutQ.AM_ID](0, &serialAux, tempOutputOutQ.DataSize);
#ifdef WITH_AUX_BSTATION
					call Serial1Sender.send[tempOutputOutQ.AM_ID](0, &serial1Aux, tempOutputOutQ.DataSize);
#endif
				}
			} else {
				RadioSender_sendDone(id, msg, error);
			}
#ifdef TOSSIM
		} else {
			RadioSender_sendDone(id, msg, error);
		}
#endif
#else
	RadioSender_sendDone(id, msg, error);

#endif

	}

#ifdef WITH_BSTATION
	// SendDone from Serial
	event void SerialSender.sendDone[am_id_t id](message_t *msg, error_t error){
		RadioSender_sendDone(id, msg, error);
	}
#endif



/* **************************************************************\
*             Insert message in output Queue
\* **************************************************************/


	/**
	* Insert a NewProgVersion message in output queue
	* @param Data Message data
	*/
	void sendNewProgVersion(newProgVersion_t *Data){
		dbg(APPNAME, "BS::sendNewProgVersion(): insert in outQueue\n");		
		memcpy(&tempInputOutQ.Data,Data,sizeof(newProgVersion_t));
		tempInputOutQ.AM_ID = AM_NEWPROGVERSION;
		tempInputOutQ.DataSize = sizeof(newProgVersion_t);
		tempInputOutQ.sendToMote = AM_BROADCAST_ADDR;
		tempInputOutQ.reqAck = 0;
		tempInputOutQ.fromSerial = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendNewProgVersion(): outQueue is full! Losting a message.\n");
		}
	}

	/**
	* Insert a NewProgBlock message in output queue
	* @param Data Message data
	*/
	void sendNewProgBlock(newProgBlock_t *Data){
		dbg(APPNAME, "BS::sendNewProgBlock(): insert in outQueue\n");		
		memcpy(&tempInputOutQ.Data,Data,sizeof(newProgBlock_t));
		tempInputOutQ.AM_ID = AM_NEWPROGBLOCK;
		tempInputOutQ.DataSize = sizeof(newProgBlock_t);
		tempInputOutQ.sendToMote = AM_BROADCAST_ADDR;
		tempInputOutQ.reqAck = 0;
		tempInputOutQ.fromSerial = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendNewProgBlock(): outQueue is full! Losting a message.\n");
		}
	}

	/**
	* Insert a ReqProgBlock message in output queue
	* @param Data Message data
	*/
 	void sendReqProgBlock(reqProgBlock_t* Data){
		dbg(APPNAME, "BS::sendReqProgBlock(): insert in outQueue --- BlkId=%d, versionId=%d, moteType=%d\n",Data->blockId, Data->versionId, Data->moteType );
		memcpy(&tempInputOutQ.Data,Data,sizeof(reqProgBlock_t));
		tempInputOutQ.AM_ID = AM_REQPROGBLOCK;
		tempInputOutQ.DataSize = sizeof(reqProgBlock_t);
		tempInputOutQ.sendToMote = ProgMoteSource;
		tempInputOutQ.reqAck = 0;
		tempInputOutQ.fromSerial = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendReqProgBlock(): outQueue is full! Losting a message.\n");
		}
 	}	
 
	/**
	* Insert a ReqData message in output queue
	* @param Data Message data
	*/
	void sendReqData(reqData_t *Data){
		dbg(APPNAME, "BS::sendReqData(): insert in outQueue\n");		
		memcpy(&tempInputOutQ.Data,Data,sizeof(reqData_t));
		tempInputOutQ.AM_ID = AM_REQDATA;
		tempInputOutQ.DataSize = sizeof(reqData_t);
		tempInputOutQ.sendToMote = NewDataMoteSource;
		tempInputOutQ.reqAck = 0;
		tempInputOutQ.fromSerial = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendReqData(): outQueue is full! Losting a message.\n");
		}
	}

	/**
	* Insert a SetDataND message in output queue
	* @param Data Message data
	*/
#ifdef MODE_SETDATA
	void sendSetDataND(setDataND_t *Data){
		dbg(APPNAME, "BS::sendSetDataND(): insert in outQueue\n");		
		memcpy(&tempInputOutQ.Data,Data,sizeof(setDataND_t));
		tempInputOutQ.AM_ID = AM_SETDATAND;
		tempInputOutQ.DataSize = sizeof(setDataND_t);
		tempInputOutQ.sendToMote = AM_BROADCAST_ADDR;
		tempInputOutQ.reqAck = 0;
		tempInputOutQ.fromSerial = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendSetDataND(): outQueue is full! Losting a message.\n");
		}
	}	
#endif
	/**
	 * Custom Send Message - queue the message to send via radio
	 */
	command error_t BSRadio.send(uint8_t am_id, uint16_t target, void* dataMsg, uint8_t dataSize, uint8_t reqAck){
		dbg(APPNAME, "BS::BSRadio.send(): insert in outQueue. AM_ID=%d, Target=%u, dataSize=%d, reqAck=%d\n",am_id,target,dataSize,reqAck);		
		memcpy(&tempInputOutQ.Data,dataMsg,dataSize);
		tempInputOutQ.AM_ID = am_id;
		tempInputOutQ.DataSize = dataSize;
		tempInputOutQ.sendToMote = target;
		tempInputOutQ.reqAck = reqAck;
		tempInputOutQ.RFPower = userRFPowerIdx;
		tempInputOutQ.fromSerial = FALSE;
		dbg("VMDBG","Radio: Sending user msg AM_ID=%d to node %u\n",am_id, target);		
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::BSRadio.send(): outQueue is full! Losting a message.\n");
			return EBUSY;
		}
		return SUCCESS;
	}

	/**
	* Insert a sendBS message in output queue
	* @param Data 	Message data
	* @param len 	Data len
	*/
#ifdef MODULE_CTP
	command error_t BSRadio.sendBS(void *Data, uint8_t len){
		dbg(APPNAME, "BS::CM.sendBS(): insert in outQueue\n");		
		memcpy(&tempInputOutQ.Data,Data,(len>MSG_BUFF_SIZE)?MSG_BUFF_SIZE:len);
		tempInputOutQ.AM_ID = AM_SENDBS;
		tempInputOutQ.DataSize = (nx_uint8_t)(len>MSG_BUFF_SIZE)?(uint8_t)MSG_BUFF_SIZE:len;
		tempInputOutQ.sendToMote = 0; // Use the CTP
		tempInputOutQ.fromSerial = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::CM.sendBS(): outQueue is full! Losting a message.\n");
			return EBUSY;
		}
		return SUCCESS;
	}
#endif // MODULE_CTP
	
	command uint16_t BSRadio.source(message_t* msg){return call RadioAMPacket.source(msg);}

	// Not using Queue dataReady event
#ifdef MODE_SETDATA
	event void setDataQ.dataReady(){}
#endif

#ifdef WITH_BSTATION
	event void SerialControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void SerialControl.startDone(error_t error){
		// TODO Auto-generated method stub
	}
#endif

#ifdef WITH_BSTATION
#ifdef WITH_AUX_BSTATION
	event void Serial1Control.stopDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void Serial1Control.startDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void Serial1Sender.sendDone[am_id_t id](message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

#endif
#endif

}
