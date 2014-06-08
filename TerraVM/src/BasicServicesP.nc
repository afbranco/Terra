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
#include "usrMsg.h"
module BasicServicesP{
	provides interface Boot as BSBoot;
	provides interface BSTimer as BSTimerVM;
	provides interface BSTimer as BSTimerAsync;
	provides interface BSUpload;
	provides interface BSRadio;

	uses interface AMPacket as RadioAMPacket;
	uses interface SplitControl as RadioControl;
	uses interface Boot as TOSBoot;
	uses interface Packet as RadioPacket;
    uses interface AMSend as RadioSender[am_id_t id];
    uses interface Receive as RadioReceiver[am_id_t id];
    uses interface PacketAcknowledgements as RadioAck;

	// Base Station
#ifndef NO_BSTATION
	uses interface SplitControl as SerialControl;
	uses interface AMSend as SerialSender[am_id_t id];
	uses interface Receive as SerialReceiver[am_id_t id];
	uses interface Packet as SerialPacket;
#endif



	uses {
		
		// setData queue
		interface dataQueue as setDataQ;
		// Bitmap
		interface vmBitVector as BM;
		/* Messages Queue */
		interface dataQueue as inQ;
		interface dataQueue as outQ;
		
		// Timer
		interface Timer<TMilli> as TimerVM;
		interface Timer<TMilli> as TimerAsync;
		interface Timer<TMilli> as sendTimer;
		interface Timer<TMilli> as ProgReqTimer;
		interface Timer<TMilli> as SendDataFullTimer;
		interface Timer<TMilli> as DataReqTimer;

		interface Leds;
		interface Random;

	}
}
implementation{

	nx_uint16_t MoteID;					// Mote Identifier
	bool firstInic=TRUE;				// First initialization flag
	uint32_t reSendDelay;
	
	GenericData_t tempInputInQ;			// Temporarily input message buffer
	GenericData_t tempInputOutQ;			// Temporarily output message buffer
	GenericData_t tempOutputInQ;			// Temporarily input message buffer
	GenericData_t tempOutputOutQ;			// Temporarily output message buffer
	GenericData_t lastNewProgVersion;		// Last received NewProgVersion
	message_t sendBuff;					// Message send buffer
	message_t usrMsgBuff;					// Message send buffer
	GenericData_t usrMsgOut;					// Temporarily output message buffer
	
	uint8_t sendCounter;				// Count the send retries
	reqProgBlock_t serialReqProgBlock;	// Serial Req Message buffer

	// Request prog/data state
	uint8_t ReqState = ST_IDLE;

	// Program load control
	nx_uint16_t ProgVersion;
	nx_uint16_t ProgMoteSource;
	nx_uint8_t ProgBlockStart;
	nx_uint8_t ProgBlockLen;
	
	uint8_t ProgTimeOutCounter=0;
	uint8_t DsmBlockCount=0;
	nx_uint16_t lastRecNewProgVersion;

	// New Data load control	
	nx_uint16_t NewDataSeq;
	nx_uint16_t maxSeenDataSeq;
	uint8_t DataTimeOutCounter=0;
	nx_uint16_t NewDataMoteSource;	
	
	
/* **************************************************************\
*             Prototypes
\* **************************************************************/
 	void sendReqProgBlock(reqProgBlock_t* Data);
	void sendNewProgVersion(newProgVersion_t *Data);
	void sendNewProgBlock(newProgBlock_t *Data);
	void sendReqData(reqData_t *Data);
	void sendSetDataND(setDataND_t *Data);	
	
	void TViewer(char* cmd,uint16_t p1, uint16_t p2){
		dbg("TVIEW","<<: %s %d %d %d :>>\n",cmd,TOS_NODE_ID,p1,p2);
		}	
/* **********************************************************************************
 *        Initialize parameters, switch-on the radio, and startup protocols.
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
			
// para teste
//if (MoteID==BStation) {ProgVersion = 1; ProgBlockStart=0; call BM.setAll(); ReqState=ST_IDLE;}
			ProgBlockLen = 10;//CURRENT_MAX_BLOCKS;
			ProgMoteSource = 0;
		}
	}


	/**
	* Command to start the communication
	*/ 
	
	event void TOSBoot.booted(){
		uint32_t rnd=0;
		dbg(APPNAME, "BS::TOSBoot.booted().\n");
		MoteID = TOS_NODE_ID;
		rnd = call Random.rand32() & 0x0f;
		reSendDelay = RESEND_DELAY + (rnd * 5);

		if (firstInic){
			inicCtlData();
			if (call RadioControl.start() != SUCCESS) dbg(APPNAME,"BS::Error in RadioControl.start()\n");
#ifndef NO_BSTATION
			if (MoteID == BStation)	if (call SerialControl.start() != SUCCESS) dbg(APPNAME,"BS::Error in SerialControl.start()\n");
#endif
		} else {
			signal BSBoot.booted();
		}
	}

	/**
	 * Radio started event.
	 */
	event void RadioControl.startDone(error_t error) {
		dbg(APPNAME, "BS::RadioControl.startDone().\n");
		// Only for first initialization (boot)
		if (firstInic && MoteID!=BStation){
			reqProgBlock_t Data;
			firstInic = FALSE;
			call Leds.set(0);
			call Leds.led1On();
			// Request initial program version
			ReqState=RO_NEW_VERSION;
			Data.reqOper=RO_NEW_VERSION;
			Data.versionId = 0;
			Data.blockId = 0;
			ProgMoteSource = AM_BROADCAST_ADDR;
			if (MoteID != BStation){
				sendReqProgBlock(&Data);
			 	// Wait next block up to time-out
			 	call ProgReqTimer.startOneShot(REQUEST_TIMEOUT);
		 	}
		signal BSBoot.booted();
		}
//		signal BSBoot.booted();
	}
	event void RadioControl.stopDone(error_t error) {
		dbg(APPNAME, "BS::RadioControl.stopDone().\n");
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
	event void TimerVM.fired(){signal BSTimerVM.fired();}


/*******************************
 * VM Async Timer operation
 *****************************/
	command uint32_t BSTimerAsync.getNow(){return call TimerAsync.getNow();}
	command void BSTimerAsync.startOneShot(uint32_t dt){
		dbg(APPNAME, "BS::BSTimerAync.startOneShot() dt=%ld, getdt=%ld, isRunning=%s\n",dt,call TimerAsync.getdt(),_TFstr(call TimerAsync.isRunning()));
		if ( call TimerAsync.isRunning() ) call TimerAsync.stop();
		call TimerAsync.startOneShot(dt);
		}
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
	uint8_t getNextEmptyBlock(){
		uint8_t i;
		for (i=0;i<CURRENT_MAX_BLOCKS;i++){
			if (!call BM.get(i)) return i;
			}
		return CURRENT_MAX_BLOCKS;
	}

/*
	void printBM(){
		uint16_t BMidx,Stridx=0;
		char text[80];
		for (BMidx=0;BMidx < (CURRENT_MAX_BLOCKS);BMidx++){
			if ((BMidx%8)==0) {text[Stridx]=',';Stridx++;}
			text[Stridx]=(call BM.get(BMidx))?'1':'0';
			Stridx++;
			}
		text[Stridx]=0;
		dbg(APPNAME, "BS::printBM():%s\n",text);
	}
*/	
	/**
	 * Check if data queue has a dataSeq number
	 * 
	 * @param seq Sequence number to be checked
	 */
	uint8_t hasDataSeq(uint16_t seq){
		uint8_t i=0;
		setDataBuff_t Buff;
		for (i=0; i < call setDataQ.size(); i++){
			call setDataQ.element(i,&Buff);
			dbg(APPNAME, "BS::hasDataSeq(): Buff.seq=%hhu,seq=%hhu \n",Buff.seq,seq);
			if (Buff.seq == (nx_uint16_t)seq) return i;
		}
		return (SET_DATA_LIST_SIZE*2);
	}

	void maxDataSeq(nx_uint16_t seq){	maxSeenDataSeq=(maxSeenDataSeq<seq)?seq:maxSeenDataSeq;}


/* **************************************************************\
*             Messages receive
\* **************************************************************/
	

	
	/**
	 * Receive NewProgVersionNet and queue it in input queue
	 */
	void recNewProgVersionNet_receive(message_t *msg, void *payload, uint8_t len){
		newProgVersion_t *xmsg;
#ifndef NO_BSTATION		
		if (MoteID == BStation) return;
#endif
		dbg(APPNAME, "BS::recNewProgVersionNet_receive(). from %hhu\n",call RadioAMPacket.source(msg));
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(newProgVersion_t));
		xmsg = (newProgVersion_t*)tempInputInQ.Data;
		tempInputInQ.AM_ID = AM_NEWPROGVERSION;
		tempInputInQ.DataSize = sizeof(newProgVersion_t);
		// Discard duplicated message
		if ((xmsg->versionId <= ProgVersion) || (xmsg->versionId == lastRecNewProgVersion)) { dbg(APPNAME, "BS::recNewProgVersionNet_receive(): Discarding duplicated message!\n"); return;}
		// put the message in inQueue
		if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recNewProgVersionNet_receive(): inQueue is full! Losting a message.\n");
		// get source mote.
		ProgMoteSource = call RadioAMPacket.source(msg);
		lastRecNewProgVersion = xmsg->versionId; 
		// Save NewProgVersion to Forward it later (after first NewProgBlock)
		tempInputInQ.sendToMote = AM_BROADCAST_ADDR;
		memcpy(&lastNewProgVersion,&tempInputInQ,sizeof(GenericData_t));
	}

	/**
	 * Receive NewProgBlockNet and queue it in input queue
	 */
	 
	void recNewProgBlockNet_receive(message_t *msg, void *payload, uint8_t len){
		newProgBlock_t *xmsg;
#ifndef NO_BSTATION		
		if (MoteID == BStation) return;
#endif
		dbg(APPNAME, "BS::recNewProgBlockNet_receive().\n");
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(newProgBlock_t));
		xmsg = (newProgBlock_t*)tempInputInQ.Data;
		tempInputInQ.AM_ID = AM_NEWPROGBLOCK;
		tempInputInQ.DataSize = sizeof(newProgBlock_t);
		// Discard duplicated/Old message
		dbg(APPNAME, "BS::recNewProgBlockNet_receive(): (xmsg->versionId=%d,ProgVersion=%d, xmsg->blockId=%d, ProgBlockStart=%d\n",xmsg->versionId,ProgVersion,xmsg->blockId,ProgBlockStart);
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
			dbg(APPNAME, "BS::recNewProgBlockNet_receive(): Discarding different version message!\n");
		}
	}

	/**
	 * Receive ReqProgBlockNet and queue it in input queue
	 */
	void recReqProgBlockNet_receive(message_t *msg, void *payload, uint8_t len){
		reqProgBlock_t *xmsg;
		dbg(APPNAME, "BS::recReqProgBlockNet_receive().\n");
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(reqProgBlock_t));
		xmsg = (reqProgBlock_t*)tempInputInQ.Data;
		tempInputInQ.AM_ID = AM_REQPROGBLOCK;
		tempInputInQ.DataSize = sizeof(reqProgBlock_t);
		// put message in the inQueue
		if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recReqProgBlockNet_receive(): inQueue is full! Losting a message.\n");
	}


	/**
	* Receive SetDataNDNet and queue it in input queue
	*/
	void recSetDataNDNet_receive(message_t *msg, void *payload, uint8_t len){
		setDataND_t *xmsg;
//#ifndef NO_BSTATION		
		if (MoteID == BStation) return;
//#endif
		dbg(APPNAME, "BS::recSetDataNDNet_receive().\n");
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(setDataND_t));
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


	void recUsrMsgNet_receive(message_t *msg, void *payload, uint8_t len){
		dbg(APPNAME,"BS::recUsrMsgNet.receive():\n");
		if (MoteID != BStation){ 
			dbg("VMDBG","Radio: Received user msg from %d\n",call RadioAMPacket.source(msg));
			signal BSRadio.receive(msg,payload,len);
		} else {
			dbg(APPNAME, "BS::recUsrMsgNet(): insert in outQueue\n");		
			memcpy(&tempInputOutQ.Data,payload,len);
			tempInputOutQ.AM_ID = AM_USRMSG;
			tempInputOutQ.DataSize = len;
			tempInputOutQ.sendToMote = AM_BROADCAST_ADDR;
			tempInputOutQ.reqAck = FALSE;
			if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
				dbg(APPNAME, "BS::recUsrMsgNet(): outQueue is full! Losting a message.\n");
			}
		}
	}

	/**
	* Receive ReqDataNet and queue it in input queue
	*/
	void recReqDataNet_receive(message_t *msg, void *payload, uint8_t len){
		reqData_t *xmsg;
//#ifndef NO_BSTATION		
//		if (MoteID == BStation) return;
//#endif
		dbg(APPNAME, "BS::recReqDataNet_receive().\n");
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(reqData_t));
		xmsg = (reqData_t*)tempInputInQ.Data;
		tempInputInQ.AM_ID = AM_REQDATA;
		tempInputInQ.DataSize = sizeof(reqData_t);
		// put message in the inQueue
		if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recReqDataNet_receive(): inQueue is full! Losting a message.\n");
	}

	// Centralized receiver
	event message_t * RadioReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
		dbg(APPNAME, "BS::RadioReceiver.receive(). AM=%hhu from %hhu\n",id,call RadioAMPacket.source(msg));
		// Switch AM_ID
		switch (id){
			case AM_NEWPROGVERSION : 
				recNewProgVersionNet_receive(msg,payload,len);
				break;	
			case AM_NEWPROGBLOCK :
				recNewProgBlockNet_receive(msg,payload,len);
				break;	
			case AM_REQPROGBLOCK :
				recReqProgBlockNet_receive(msg,payload,len);
				break;	
			case AM_SETDATAND :
				recSetDataNDNet_receive(msg,payload,len);
				break;	
			case AM_REQDATA :
				recReqDataNet_receive(msg,payload,len);
				break;	
			case AM_USRMSG :
				recUsrMsgNet_receive(msg,payload,len);
				break;	
			default :
				dbg(APPNAME, "BS::RadioReceiver.receive(). Received a undefined AM=%hhu from %hhu\n",id,call RadioAMPacket.source(msg));	
				break;	
		
		}
		return msg;
	}
	

/* ******************************************************************************
*                       Upload control functions
\* ******************************************************************************/
 	/**
 	 * Process a received newProgVersion message
 	 * @param Data Message data
 	 */ 
 	void procNewProgVersion(newProgVersion_t* Data){
 		reqProgBlock_t xData;
		dbg(APPNAME, "BS::procNewProgVersion().\n");
		call Leds.set(7);
		// Stop the VM
 		signal BSUpload.stop();
 		signal BSUpload.resetMemory();
 		TViewer("vmstop",0,0);
 		// Get new version ID - If it is the BStation, use last loaded version + 1.
 		if (MoteID != BStation){
 			ProgVersion = Data->versionId;
 		} else {
 			ProgVersion++;
 		}
 		ProgBlockStart = Data->blockStart;
 		ProgBlockLen = Data->blockLen;
 		// Update environment values: StartProg addr, etc..
 		signal BSUpload.setEnv(Data);
 		// reset all memory (leave set unused blocks)
 		atomic call BM.resetRange(ProgBlockStart,(ProgBlockStart+ProgBlockLen)-1);
 		//printBM();
 		// send a recProgBlock full
 		ProgTimeOutCounter=0;
	 	xData.reqOper=RO_DATA_FULL;
	 	ReqState = RO_DATA_FULL;
	 	xData.versionId = ProgVersion;
	 	xData.blockId = ProgBlockStart;
	 	sendReqProgBlock(&xData);
	 	// Wait next block up to time-out
		if (MoteID != BStation)
	 		call ProgReqTimer.startOneShot(REQUEST_TIMEOUT);
	 	else
	 		call ProgReqTimer.startOneShot(REQUEST_TIMEOUT_BS);	 	
 	}
 	/**
 	 * Process a received newProgBlock message
 	 * @param Data Message data
 	 */ 
	 void procNewProgBlock(newProgBlock_t* Data){
		 uint8_t lData[BLOCK_SIZE],i;
		 uint16_t Addr=0;
		 newProgVersion_t xVersion;
		 dbg(APPNAME, "BS::procNewProgBlock(). version=%hhu, blockId=%hhu, ReqState=%d\n",Data->versionId,Data->blockId,ReqState);
		 call Leds.led0Toggle();		 
//		printf("prc_nb%d.",Data->blockId);printfflush();
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
//		printf("pend%d.",call BM.countPend());printfflush();
		 // Check if it was the last block
		 if ( call BM.isAllBitSet()) {
		 	call Leds.set(0);
		 	if (MoteID != BStation){
			 	// Start the VM
	 			ReqState=ST_IDLE;
				TViewer("vmstart",0,0);
				signal BSUpload.start(TRUE);
			} else {
				// BStation - Do not start VM and broadcast newProgVersion.
				xVersion.versionId = ProgVersion;
			 	xVersion.blockLen = ProgBlockLen;
			 	xVersion.blockStart = ProgBlockStart;
			 	signal BSUpload.getEnv(&xVersion);
			 	sendNewProgVersion(&xVersion);				
			}
		 } else {
		 	// Wait next block
 			ReqState=ST_WAIT_PROG_BLK;
			if (MoteID != BStation){
		 		call ProgReqTimer.startOneShot(REQUEST_TIMEOUT);
		 	} else {
		 		// if BS, request next block 
			 	serialReqProgBlock.reqOper=RO_DATA_FULL;
				ReqState = RO_DATA_FULL;
				serialReqProgBlock.versionId = ProgVersion;
				serialReqProgBlock.blockId = Data->blockId+1;
				sendReqProgBlock(&serialReqProgBlock);
		 		call ProgReqTimer.startOneShot(REQUEST_TIMEOUT_BS);
		 		}
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
		 uint8_t i=0;
		 dbg(APPNAME, "BS::procRecReqProgBlock(). Local version=%hhu, Req Version %hhu Oper=%hhu, BM.isAllBitSet=%s\n", ProgVersion, Data->versionId, Data->reqOper,_TFstr(call BM.isAllBitSet()));
		switch (Data->reqOper){
			case RO_NEW_VERSION: 
				if ((ProgVersion > Data->versionId) && (ProgVersion > 0) && call BM.isAllBitSet()){
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
	 event void ProgReqTimer.fired(){
		 uint8_t nextBlock=CURRENT_MAX_BLOCKS;
		 reqProgBlock_t Data;
		 uint32_t timeout=REQUEST_TIMEOUT;
		 nextBlock = getNextEmptyBlock();
		 dbg(APPNAME, "BS::ProgReqTimer.fired(). nextBlock=%d\n",nextBlock);
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
			 	Data.versionId = 0;
			 	Data.blockId = ProgBlockStart;
			 	ProgMoteSource = AM_BROADCAST_ADDR;
			 	sendReqProgBlock(&Data);
			 	// Wait next block up to time-out
			 	call ProgReqTimer.startOneShot(timeout);
		 		break;
		 	case RO_DATA_FULL:
		 		// timeout on full data request, retry for the next block
		 		nextBlock = getNextEmptyBlock();
			 	if (nextBlock < ProgBlockLen){
				 	Data.reqOper=RO_DATA_FULL;
					ReqState = RO_DATA_FULL;
					Data.versionId = ProgVersion;
					Data.blockId = nextBlock;
					sendReqProgBlock(&Data);
					// Wait next block up to time-out
					if (MoteID != BStation)
						call ProgReqTimer.startOneShot(REQUEST_TIMEOUT);
					else
						call ProgReqTimer.startOneShot(REQUEST_TIMEOUT_BS);					
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
		 		nextBlock = getNextEmptyBlock();
			 	if (nextBlock < CURRENT_MAX_BLOCKS){
				 	Data.reqOper=RO_DATA_SINGLE;
				 	ReqState = RO_DATA_SINGLE;
				 	Data.versionId = ProgVersion;
				 	Data.blockId = nextBlock;
				 	sendReqProgBlock(&Data);
				 	// Wait next block up to time-out
				 	call ProgReqTimer.startOneShot(REQUEST_TIMEOUT);
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



	event void SendDataFullTimer.fired(){
		newProgBlock_t xBlock;
		 dbg(APPNAME, "BS::SendDataFullTimer.fired().\n");
		// Disseminating Prog blocks
		if (call BM.get(DsmBlockCount+ProgBlockStart)){
			uint8_t *mem, i;
			xBlock.versionId = ProgVersion;
			xBlock.blockId = (uint8_t)(DsmBlockCount + ProgBlockStart);
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
	void procSetDataND(setDataND_t* Data){
 		setDataBuff_t buff;
		uint8_t lData[SET_DATA_SIZE],i,x,secp=0,secLen;
		uint16_t secAddr;
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
				if (MoteID != BStation) {
					//signal BSUpload.stop();
					secp=0;
					for (x=0;x<Data->nSections;x++){
						secAddr=Data->Data[secp++];
						secAddr = secAddr + (Data->Data[secp++] << 8); 
						secLen = Data->Data[secp++];
						for (i=0; i < secLen; i++) lData[i] = Data->Data[secp++];
						signal BSUpload.loadSection(secAddr , secLen, &lData[0]);
					}
					//signal BSUpload.start(TRUE);
				} else {
					for (x=0;x<Data->nSections;x++){
						secAddr=Data->Data[secp++];
						secAddr = secAddr + (Data->Data[secp++] << 8); 
						secLen = Data->Data[secp++];
						for (i=0; i < secLen; i++) lData[i] = Data->Data[secp++];
						signal BSUpload.loadSection(secAddr , secLen, &lData[0]);
					}
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
				call DataReqTimer.startOneShot((MoteID!=BStation)?REQUEST_TIMEOUT:REQUEST_TIMEOUT_BS);
			} else { // DataSeq is not too old, Request Current value
				if ((Data->seq < (NewDataSeq + SET_DATA_LIST_SIZE)) && (Data->seq > NewDataSeq)){
				xData.versionId = ProgVersion;
				xData.seq = NewDataSeq+1;
				sendReqData(&xData);
				// Reset retry counter
				DataTimeOutCounter=0;
				// wait for new data
				call DataReqTimer.startOneShot((MoteID!=BStation)?REQUEST_TIMEOUT:REQUEST_TIMEOUT_BS);
				}
			}
		}	
 	}
 	/**
 	 * Process a received reqData message
 	 * @param Data Message data
 	 */
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
			call DataReqTimer.startOneShot((MoteID!=BStation)?REQUEST_TIMEOUT:REQUEST_TIMEOUT_BS);		
		} else {
			dbg(APPNAME, "BS::DataReqTimer.fired(): Requested all expected setData\n");
		}
	}

	/**
	* Process each event from input Queue
	*/
	task void procInputEvent(){
		{
			dbg(APPNAME, "BS::procInputEvent().\n");
	
			if (call inQ.read(&tempOutputInQ)==SUCCESS) {
				call inQ.get(&tempOutputInQ);
//				printf("inEvt%d.",tempOutputInQ.AM_ID);printfflush();
				switch (tempOutputInQ.AM_ID) {
					case AM_NEWPROGVERSION: procNewProgVersion((newProgVersion_t*) &tempOutputInQ.Data); break;
					case AM_NEWPROGBLOCK: procNewProgBlock((newProgBlock_t*) &tempOutputInQ.Data); break;
					case AM_REQPROGBLOCK: procRecReqProgBlock((reqProgBlock_t*) &tempOutputInQ.Data); break;
					case AM_SETDATAND: procSetDataND((setDataND_t*) &tempOutputInQ.Data); break;
					case AM_REQDATA: procReqData((reqData_t*) &tempOutputInQ.Data); break;
					default: dbg(APPNAME, "BS::procInputEvent(): Unknow AM_ID=%hhu\n",tempOutputInQ.AM_ID); break;
				}
#ifndef ONLY_BSTATION
				dbg(APPNAME, "BS::procInputEvent(): nextMessage.\n");
				call inQ.get(&tempOutputInQ);
				post procInputEvent();
#endif
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

	/**
	* Sends out a xxxx message
	*/
	void sendRadioN(){
		error_t err;
		dbg(APPNAME,"BS::sendRadioN(): AM=%hhu to %hhu, reqAck=%s\n",tempOutputOutQ.AM_ID, tempOutputOutQ.sendToMote, _TFstr(tempOutputOutQ.reqAck));
		memcpy(call RadioPacket.getPayload(&sendBuff,call RadioPacket.maxPayloadLength()), &tempOutputOutQ.Data, tempOutputOutQ.DataSize);
		if ( tempOutputOutQ.reqAck == TRUE){
			if (call RadioAck.requestAck(&sendBuff) != SUCCESS) dbg(APPNAME, "BS::sendRadioN()(): requestAck() error!\n");
		}
		err = call RadioSender.send[tempOutputOutQ.AM_ID](tempOutputOutQ.sendToMote, &sendBuff, tempOutputOutQ.DataSize);
		if (err != SUCCESS) {
			dbg(APPNAME,"BS::sendRadioN(): Error %hhu in sending Message AM=%hhu to node=%hhu via radio\n",err,tempOutputOutQ.AM_ID, tempOutputOutQ.sendToMote);
			call sendTimer.startOneShot(reSendDelay);
		} else {
			TViewer("radio",tempOutputOutQ.sendToMote,0);
			}		
	}
	void sendSerialN(){
#ifndef NO_BSTATION
		error_t err;
		dbg(APPNAME,"BS::sendSerialN(): AM=%hhu\n",tempOutputOutQ.AM_ID);
		memcpy(call SerialPacket.getPayload(&sendBuff,call SerialPacket.maxPayloadLength()), &tempOutputOutQ.Data, tempOutputOutQ.DataSize);
		err = call SerialSender.send[tempOutputOutQ.AM_ID](AM_BROADCAST_ADDR, &sendBuff, tempOutputOutQ.DataSize);
		if ( err != SUCCESS) {
			dbg(APPNAME,"BS::sendSerialN(): Error %hhu in sending Message AM=%hhu via UART\n",err,tempOutputOutQ.AM_ID);
			call sendTimer.startOneShot(reSendDelay);	
		}
#endif
	}


	/**
	* Process each event from output Queue
	*/
	task void sendMessage(){
		sendCounter++;
		if (call outQ.read(&tempOutputOutQ)==SUCCESS) {
		dbg(APPNAME, "BS::sendMessage():AM=%hhu, senToMote=%hhu.\n",tempOutputOutQ.AM_ID, tempOutputOutQ.sendToMote);
//		printf("snd_%d.",tempOutputOutQ.AM_ID); printfflush();
		switch (tempOutputOutQ.AM_ID) {
			case AM_NEWPROGVERSION: sendRadioN(); break;
			case AM_NEWPROGBLOCK: sendRadioN(); break;
			case AM_REQPROGBLOCK: 
				// Send to Radio or UART
				if (MoteID != BStation){
					sendRadioN();
				} else {
					sendSerialN();
				}			
				break;
			case AM_SETDATAND: sendRadioN(); break;
			case AM_REQDATA: 
				// Send to Radio or UART
				if (MoteID != BStation){
					sendRadioN();
				} else {
					sendSerialN();
				}
				break;
			case AM_USRMSG: 
				// Send to Radio or UART
				if (MoteID != BStation){
					sendRadioN();
				} else {
					sendSerialN();
				}				
				break;
			} 
		} else {
			call outQ.get(&tempOutputOutQ); // eventually clean the queue
//		printf("snd_empty."); printfflush();
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
//		printf("sndTmr_q%d.",sendCounter); printfflush();
			post sendMessage();
		} else {								// Discard message and get next message
//		printf("sndTmr_discard."); printfflush();
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
	* Generic sendDone(). Called by originals *.sendDone().
	* @param error Error status
	*/


	event void RadioSender.sendDone[am_id_t id](message_t *msg, error_t error){
		if (error == SUCCESS) {						// Get next message
			dbg(APPNAME, "BS::sendDone(): SUCCESS SendCounter=%hhu\n",sendCounter);
			call outQ.get(&tempOutputOutQ);
			sendCounter=0;
			call sendTimer.startOneShot(reSendDelay);
			if ( tempOutputOutQ.AM_ID == AM_USRMSG){
				dbg(APPNAME,"BS::sendDone(): UsrMsg err=%d ack=%d, \n",error,call RadioAck.wasAcked(msg));
				if (tempOutputOutQ.reqAck == TRUE) 
					signal BSRadio.sendDoneAck(msg,error, call RadioAck.wasAcked(msg));
				else
					signal BSRadio.sendDone(msg,error);
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
			}
		}
	}
	

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
		tempInputOutQ.reqAck = FALSE;
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
		tempInputOutQ.reqAck = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendNewProgBlock(): outQueue is full! Losting a message.\n");
		}
	}

	/**
	* Insert a ReqProgBlock message in output queue
	* @param Data Message data
	*/
 	void sendReqProgBlock(reqProgBlock_t* Data){
		dbg(APPNAME, "BS::sendReqProgBlock(): insert in outQueue --- BlkId=%d\n",Data->blockId);
//		printf("rb%d.",Data->blockId); printfflush();
		memcpy(&tempInputOutQ.Data,Data,sizeof(reqProgBlock_t));
		tempInputOutQ.AM_ID = AM_REQPROGBLOCK;
		tempInputOutQ.DataSize = sizeof(reqProgBlock_t);
		tempInputOutQ.sendToMote = ProgMoteSource;
		tempInputOutQ.reqAck = FALSE;
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
		tempInputOutQ.reqAck = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendReqData(): outQueue is full! Losting a message.\n");
		}
	}

	/**
	* Insert a SetDataND message in output queue
	* @param Data Message data
	*/
	void sendSetDataND(setDataND_t *Data){
		dbg(APPNAME, "BS::sendSetDataND(): insert in outQueue\n");		
		memcpy(&tempInputOutQ.Data,Data,sizeof(setDataND_t));
		tempInputOutQ.AM_ID = AM_SETDATAND;
		tempInputOutQ.DataSize = sizeof(setDataND_t);
		tempInputOutQ.sendToMote = AM_BROADCAST_ADDR;
		tempInputOutQ.reqAck = FALSE;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendSetDataND(): outQueue is full! Losting a message.\n");
		}
	}	


/* *****************************************************************************************
*             User messages doesn't use queue and are discarded during code upload.
\* *****************************************************************************************/

uint8_t usrReqAck = FALSE;

/*
	task void BSRadio_send(){
		usrReqAck = FALSE;
		memcpy(call sendUsrMsgNet.getPayload(&usrMsgBuff,call sendUsrMsgNet.maxPayloadLength()), &usrMsgOut.Data, usrMsgOut.DataSize);
		dbg(APPNAME, "BS::BSRadio.send(): Sending Message ID=%hhu, ReqMote=%hhu, d8_1=%hhu to %d\n", 
				((usrMsg_t*)&usrMsgOut.Data)->id, ((usrMsg_t*)&usrMsgOut.Data)->source, ((usrMsg_t*)&usrMsgOut.Data)->d8_1,((usrMsg_t*)&usrMsgOut.Data)->target);
		if (call sendUsrMsgNet.send(usrMsgOut.sendToMote, &usrMsgBuff, usrMsgOut.DataSize) != SUCCESS)
					dbg(APPNAME,"BS::BSRadio.send(): ERROR!!! Try to send sendUsrMsgNet\n");
	}
	task void BSRadio_sendAck(){
		usrReqAck = TRUE;
		memcpy(call sendUsrMsgNet.getPayload(&usrMsgBuff,call sendUsrMsgNet.maxPayloadLength()), &usrMsgOut.Data, usrMsgOut.DataSize);
		dbg(APPNAME, "BS::BSRadio.send(): Sending Message ID=%hhu, ReqMote=%hhu, d8_1=%hhu to %d\n", 
				((usrMsg_t*)&usrMsgOut.Data)->id, ((usrMsg_t*)&usrMsgOut.Data)->source, ((usrMsg_t*)&usrMsgOut.Data)->d8_1,((usrMsg_t*)&usrMsgOut.Data)->target);
		dbg(APPNAME,"BS::BSRadio.send(): Requesting ack\n");
		if (call sendUsrMsgNetAck.requestAck(&usrMsgBuff) != SUCCESS) dbg(APPNAME, "BS::BSRadio.send()(): requestAck() error!\n");
 * 		if (call sendUsrMsgNet.send(usrMsgOut.sendToMote, &usrMsgBuff, usrMsgOut.DataSize) != SUCCESS)
					dbg(APPNAME,"BS::BSRadio.send(): ERROR!!! Try to send sendUsrMsgNet\n");
	}
*/
	command error_t BSRadio.send(uint16_t target, void* dataMsg, uint8_t dataSize, uint8_t reqAck){
		dbg(APPNAME, "BS::BSRadio.send(): insert in outQueue. Target=%d\n",target);		
		memcpy(&tempInputOutQ.Data,dataMsg,dataSize);
		tempInputOutQ.AM_ID = AM_USRMSG;
		tempInputOutQ.DataSize = dataSize;
		tempInputOutQ.sendToMote = target;
		tempInputOutQ.reqAck = reqAck;
		dbg("VMDBG","Radio: Sending user msg to node %d\n",target);		
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::BSRadio.send(): outQueue is full! Losting a message.\n");
			return FAIL;
		}
		return SUCCESS;
	}

/* *****************************************************************************************
*             Base Station Events - Disabled when compiled for generic real Mote
\* *****************************************************************************************/
	void dummy(message_t *msg, void *payload, uint8_t len){}

#ifndef NO_BSTATION
	
	event void SerialControl.startDone(error_t error){
		dbg(APPNAME, "BS::SerialControl.startDone():\n");		
	}

	event void SerialControl.stopDone(error_t error){}

	event void SerialSender.sendDone[am_id_t am_id](message_t *msg, error_t error){
		if (MoteID != BStation) return;
		dbg(APPNAME, "BS::SerialSender.sendDone[%hhu]():\n",am_id);		
		call outQ.get(&tempOutputOutQ);
		sendCounter=0;
		call sendTimer.startOneShot(reSendDelay);
	}

/*	
	event void sendSerialReqProgBlock.sendDone(message_t *msg, error_t error){
		if (MoteID != BStation) return;
		dbg(APPNAME, "BS::sendSerialReqProgBlock.sendDone():\n");		
		call outQ.get(&tempOutputOutQ);
		sendCounter=0;
		call sendTimer.startOneShot(reSendDelay);
	}
*/

	void recSerialNewProgVersion_receive(message_t *msg, void *payload, uint8_t len){
		newProgVersion_t Data;
		dbg(APPNAME, "BS::recSerialNewProgVersion_receive():\n");
		memcpy(&Data,payload,sizeof(newProgVersion_t));
		procNewProgVersion(&Data);
	}
	
	void recSerialNewProgBlock_receive(message_t *msg, void *payload, uint8_t len){
		newProgBlock_t Data;
		dbg(APPNAME, "BS::recSerialNewProgBlock_receive():\n");
		memcpy(&Data,payload,sizeof(newProgBlock_t));
		procNewProgBlock(&Data);
	}

	void recSerialSetDataND_receive(message_t *msg, void *payload, uint8_t len){
		setDataND_t *xmsg;
		dbg(APPNAME, "BS::recSerialSetDataND_receive():\n");
		if (MoteID != BStation) return;
		// Copy data to temporarily buffer
		memcpy(tempInputInQ.Data,payload,sizeof(setDataND_t));
		xmsg = (setDataND_t*)tempInputInQ.Data;
		tempInputInQ.AM_ID = AM_SETDATAND;
		tempInputInQ.DataSize = sizeof(setDataND_t);
		// Discard old message
		if (xmsg->versionId != ProgVersion) { dbg(APPNAME, "BS::recSerialSetDataND_receive(): Discarding old version!\n"); return;}
		if (xmsg->seq < ((NewDataSeq>=SET_DATA_LIST_SIZE)?(NewDataSeq-SET_DATA_LIST_SIZE):NewDataSeq)) { dbg(APPNAME, "BS::recSerialSetDataND_receive(): Discarding very old data!\n"); return;}
		// Proccess received data
		procSetDataND(xmsg);  // this call will increment/jump NewDataSet
		// if it is a normal message, then broadcast it
		if (xmsg->seq == NewDataSeq){
			tempInputInQ.sendToMote=AM_BROADCAST_ADDR;
			if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recSerialSetDataND_receive(): outQueue is full! Losting a message.\n");		
			}
	}


	event message_t * SerialReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
		dbg(APPNAME, "BS::SerialReceiver.receive(): AM=%hhu\n",id);
		switch (id){
			case AM_NEWPROGVERSION:
				recSerialNewProgVersion_receive(msg,payload,len);
				break;			
			case AM_NEWPROGBLOCK:
				recSerialNewProgBlock_receive(msg,payload,len);
				break;			
			case AM_SETDATAND:
				recSerialSetDataND_receive(msg,payload,len);
				break;						
			default:
				break;
		}
		return msg;
	}

#endif


	// Not using Queue dataReady event
	event void setDataQ.dataReady(){}


}
