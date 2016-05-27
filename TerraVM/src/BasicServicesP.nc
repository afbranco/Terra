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
//#include "AvroraPrint.h"

module BasicServicesP{
	provides interface Boot as BSBoot;
	provides interface BSTimer as BSTimerVM;
	provides interface BSTimer as BSTimerAsync;
	provides interface BSUpload;
	provides interface BSRadio;

	uses interface Boot as TOSBoot;

#if defined(INOS)
// Ino Radio Configuration
/*
    uses interface AMSend as RadioSender[am_id_t id];
    uses interface Receive as RadioReceiver[am_id_t id];
	uses interface SplitControl as RadioControl;
	uses interface Packet as RadioPacket;

    uses interface PacketAcknowledgements as RadioAck;
	uses interface AMPacket as RadioAMPacket;
*/
	uses interface SplitControl as RadioControl;
	uses interface AMSend as RadioSender[am_id_t id];
	uses interface Receive as RadioReceiver[am_id_t id];
	uses interface Packet as RadioPacket;
	uses interface AMPacket as RadioAMPacket;
    uses interface PacketAcknowledgements as RadioAck;
#elif defined(INOX)
// Ino Radio Configuration
    uses interface AMSend as RadioSender[am_id_t id];
    uses interface Receive as RadioReceiver[am_id_t id];
	uses interface SplitControl as RadioControl;
    uses interface PacketAcknowledgements as RadioAck;
	uses interface AMPacket as RadioAMPacket;
	uses interface Packet as RadioPacket;
#else
// TinyOS Radio configurations
	uses interface AMPacket as RadioAMPacket;
	uses interface SplitControl as RadioControl;
	uses interface Packet as RadioPacket;
    uses interface PacketAcknowledgements as RadioAck;
#ifndef MODULE_CTP
    uses interface AMSend as RadioSender[am_id_t id];
#else
    uses interface AMSend as snd_NEWPROGVERSION;
    uses interface AMSend as snd_NEWPROGBLOCK;
    uses interface AMSend as snd_REQPROGBLOCK;
#ifdef MODE_SETDATA
    uses interface AMSend as snd_SETDATAND;
    uses interface AMSend as snd_REQDATA;
#endif
    uses interface AMSend as snd_PINGMSG;
    uses interface AMSend as snd_CUSTOM_0;
    uses interface AMSend as snd_CUSTOM_1;
    uses interface AMSend as snd_CUSTOM_2;
    uses interface AMSend as snd_CUSTOM_3;
    uses interface AMSend as snd_CUSTOM_4;
    uses interface AMSend as snd_CUSTOM_5;
    uses interface AMSend as snd_CUSTOM_6;
    uses interface AMSend as snd_CUSTOM_7;
    uses interface AMSend as snd_CUSTOM_8;
    uses interface AMSend as snd_CUSTOM_9;
#endif
#ifndef MODULE_CTP
    uses interface Receive as RadioReceiver[am_id_t id];
#else
    uses interface Receive as rec_NEWPROGVERSION;
    uses interface Receive as rec_NEWPROGBLOCK;
    uses interface Receive as rec_REQPROGBLOCK;
#ifdef MODE_SETDATA
    uses interface Receive as rec_SETDATAND;
    uses interface Receive as rec_REQDATA;
#endif
    uses interface Receive as rec_PINGMSG;
    uses interface Receive as rec_CUSTOM_0;
    uses interface Receive as rec_CUSTOM_1;
    uses interface Receive as rec_CUSTOM_2;
    uses interface Receive as rec_CUSTOM_3;
    uses interface Receive as rec_CUSTOM_4;
    uses interface Receive as rec_CUSTOM_5;
    uses interface Receive as rec_CUSTOM_6;
    uses interface Receive as rec_CUSTOM_7;
    uses interface Receive as rec_CUSTOM_8;
    uses interface Receive as rec_CUSTOM_9;
#endif
#endif // INO x TinyOS


// Radio RF Power
#if defined(TOSSIM)

#elif defined(INOS) || defined(INOX) // INO must be before to avoid radio chip component

#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB) && !((defined(PLATFORM_IRIS) || defined(INOS) || defined(INOX)))
//#error "Passei no MICAZ"
	uses interface CC2420Packet as RadioAux;
#elif (defined(PLATFORM_IRIS) && !(defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB) || defined(INOS) || defined(INOX)))
//#error "Passei no IRIS"
	uses interface PacketField<uint8_t> as RadioAux;
#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
	uses interface CC1000Control as RadioAux;

#endif

	// Base Station
#ifndef NO_BSTATION
	uses interface SplitControl as SerialControl;
	uses interface AMSend as SerialSender[am_id_t id];
	uses interface Receive as SerialReceiver[am_id_t id];
	uses interface Packet as SerialPacket;
#endif



	uses {
		
		// setData queue
#ifdef MODE_SETDATA
		interface dataQueue as setDataQ;
#endif
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
#ifdef MODE_SETDATA
		interface Timer<TMilli> as DataReqTimer;
#endif
		interface Leds;
		interface Random;

	}
	// CTP
#ifdef MODULE_CTP
	uses interface Receive as recSendBS;		// BS
	uses interface Send as sendBSNet;
	uses interface StdControl as RoutingControl;
	uses interface RootControl;
	uses interface CtpInfo;
#endif


#if defined(INOS)
// afb log
  uses {
#if defined(INOS)
#else
  	interface UartStream as Uart0;
  	interface StdControl as Uart0Ctl;
  	interface Queue<uint8_t> as LogQ;
#endif
  	interface InoIO;
  }
#elif defined(INOX)
// afb log
  uses {
  	interface UartStream as Uart0;
  	interface StdControl as Uart0Ctl;
  	interface Queue<uint8_t> as LogQ;
  	interface InoIO;
  }

#endif


#ifdef LPL_ON
	uses interface LowPowerListening;
#endif

}
implementation{

	uint32_t LocalClock=0;
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

	// New Data load control	
	nx_uint16_t NewDataSeq;
	nx_uint16_t maxSeenDataSeq;
	uint8_t DataTimeOutCounter=0;
	nx_uint16_t NewDataMoteSource;	

	// Filter others REQ_PROG_BLOCK
	uint16_t disseminatorRoot=0;


#ifndef NO_BSTATION
#ifdef MODULE_CTP
	// Rec SendBS - last msg info used to test duplicated CTP events
	nx_uint16_t recBS_last_Sender;
	nx_uint16_t recBS_last_seq;
#endif
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
// afb
  uint8_t logData[10];  
#if defined(INOS)

#elif defined(INOX)
  uint8_t logIdle=TRUE;
  task void logProc(){
  	uint8_t logByte;
	if (call LogQ.size() > 0) {
		logIdle=FALSE;
		logByte = call LogQ.dequeue();
		call Uart0.send(&logByte, 1);
		//call Uart0.send("X", 1);
  	} else
  		logIdle = TRUE;
  }

	async event void Uart0.sendDone(uint8_t *buf, uint16_t len, error_t error){
		post logProc();
	}
  void logS(uint8_t* logMsg, uint8_t len){
  	uint8_t idx;
  	for (idx=0; idx<len;idx++) call LogQ.enqueue(logMsg[idx]);
  	if (logIdle) post logProc();
  }
#else
  void logS(uint8_t* logMsg, uint8_t len){}
#endif

// afb

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
#if defined(INOS)
	TOS_NODE_ID = 2;	
#endif

#if defined(INOS) || defined(INOX) 
		userRFPowerIdx=0;
#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB) || defined(PLATFORM_IRIS) 
		userRFPowerIdx = RFPOWER_IDX;
#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
		userRFPowerIdx = RFPOWER_IDX;
		atomic{call RadioAux.setRFPower(RFPowerTab[userRFPowerIdx]);};
#else
		userRFPowerIdx=0;
#endif

// log afb
#if defined(INOS)

#elif defined(INOX)
call Uart0Ctl.start();
#endif
//logS("A",1);
		MoteID = TOS_NODE_ID;
		rnd = call Random.rand32() & 0x0f;
		reSendDelay = RESEND_DELAY + (rnd * 5);

		if (firstInic){
			inicCtlData();
#ifdef LPL_ON
#if defined(INOS) || defined(INOX)

#else
			call LowPowerListening.setLocalWakeupInterval( SLEEP );
#endif
#endif
			if (call RadioControl.start() != SUCCESS) dbg(APPNAME,"BS::Error in RadioControl.start()\n");
#ifndef NO_BSTATION
			if (MoteID == BStation)	if (call SerialControl.start() != SUCCESS) dbg(APPNAME,"BS::Error in SerialControl.start()\n");
#endif
		} else {
			signal BSBoot.booted();
		}
	}

	uint32_t getRequestTimeout(){return (ProgMoteSource==1)?REQUEST_TIMEOUT_BS:REQUEST_TIMEOUT;}

	/**
	 * Radio started event.
	 */
	event void RadioControl.startDone(error_t error) {
//logS("B",1);
		dbg(APPNAME, "BS::RadioControl.startDone().\n");
#ifdef MODULE_CTP
		call RoutingControl.start(); 		// CTP
#endif
		MoteID = TOS_NODE_ID;
		// Only for first initialization (boot)
		if (firstInic && MoteID!=BStation){
			reqProgBlock_t Data;
			firstInic = FALSE;
//			call Leds.set(0);
//			call Leds.led1On();
			// Request initial program version
			ReqState=RO_NEW_VERSION;
			Data.reqOper=RO_NEW_VERSION;
			Data.versionId = 0;
			Data.blockId = 0;
			ProgMoteSource = AM_BROADCAST_ADDR;
			if (MoteID != BStation){
				sendReqProgBlock(&Data);
			 	// Wait next block up to time-out
			 	call ProgReqTimer.startOneShot(getRequestTimeout());
		 	}
		}
#ifndef NO_BSTATION
#ifdef MODULE_CTP
		if (MoteID==BStation) { 
			call RootControl.setRoot();
		}
#endif
#endif
		signal BSBoot.booted();
call Leds.led1On();
	}
	
	event void RadioControl.stopDone(error_t error) {
		dbg(APPNAME, "BS::RadioControl.stopDone().\n");
	}

	command void BSRadio.setRFPower(uint8_t powerIdx){
		dbg(APPNAME, "BS::BSRadio.setRFPower(%d).\n",powerIdx);
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB) || defined(PLATFORM_IRIS) || defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
		if (powerIdx < RFPower_IDs) {
			userRFPowerIdx = powerIdx;
		}
#endif		
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
#if defined(INOS)

#else
					if (call outQ.put(&lastNewProgVersion)!=SUCCESS) dbg(APPNAME, "BS::recNewProgBlockNet_receive(): outQueue is full! Losting a message.\n");		
#endif
				}
				// put message in the inQueue
				if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recNewProgBlockNet_receive(): inQueue is full! Losting a message.\n");
				// get source mote. Doesn't change it if the original is from the BS
				if (ProgMoteSource != BStation) ProgMoteSource = call RadioAMPacket.source(msg);
				// Forward the message
#if defined(INOS)

#else
				if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recNewProgBlockNet_receive(): outQueue is full! Losting a message.\n");
#endif
			} else {
				dbg(APPNAME, "BS::recNewProgBlockNet_receive(): Discarding duplicated message - block is 0!\n");
			}
		} else {
			if (xmsg->versionId > ProgVersion){
				// Retry request
				call ProgReqTimer.startOneShot(getRequestTimeout());
			} else
				dbg(APPNAME, "BS::recNewProgBlockNet_receive(): Discarding old version message!\n");
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
#if defined(INOS)

#else
		if (xmsg->seq == (NewDataSeq+1)){
			tempInputInQ.sendToMote=AM_BROADCAST_ADDR;
			if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recSetDataNDNet_receive(): outQueue is full! Losting a message.\n");		
			}
#endif
	}


	void recCustomMsgNet_receive(message_t *msg, void *payload, uint8_t len){
		uint8_t am_id= (uint8_t)call RadioAMPacket.type(msg);
		dbg(APPNAME,"BS::recCustomMsgNet.receive():\n");
		if (MoteID != BStation){ 
#ifndef ONLY_BSTATION
			dbg("VMDBG","Radio: Received Custom Msg AM=%d from %d\n", am_id , call RadioAMPacket.source(msg));
			signal BSRadio.receive(am_id,msg,payload,len);
#endif
		} else {
#ifndef NO_BSTATION
			dbg(APPNAME, "BS::recCustomMsgNet(): insert in outQueue\n");		
			memcpy(&tempInputOutQ.Data,payload,len);
			tempInputOutQ.AM_ID = am_id;
			tempInputOutQ.DataSize = len;
			tempInputOutQ.sendToMote = AM_BROADCAST_ADDR;
			tempInputOutQ.reqAck = 0;
			if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
				dbg(APPNAME, "BS::recCustomMsgNet(): outQueue is full! Losting a message.\n");
			}
#endif
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
#ifndef MODULE_CTP
	event message_t * RadioReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
#else
	message_t * RadioReceiver_receive(am_id_t id,message_t *msg, void *payload, uint8_t len){
#endif
//logS("r",1);
		dbg(APPNAME, "BS::RadioReceiver.receive(). AM=%hhu from %hhu.  disseminatorRoot=%d\n",id,call RadioAMPacket.source(msg),disseminatorRoot);
		if (MoteID == BStation) {
			uint16_t source = call RadioAMPacket.source(msg);	
			if (id==AM_REQPROGBLOCK && disseminatorRoot==0) disseminatorRoot=source;
			if ((id!=AM_REQPROGBLOCK) || (id==AM_REQPROGBLOCK && disseminatorRoot==source) ) {
				// Copy data to temporarily buffer
				memcpy(tempInputInQ.Data,payload,len);
				tempInputInQ.AM_ID = (uint8_t)id;
				tempInputInQ.DataSize = len;
				tempInputInQ.sendToMote = source | 0x8000; // (mote | 0x8000) means send to serial
				// put message in the inQueue
				if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::RadioReceiver.receive(): inQueue is full! Losting a message.\n");
			} else {
				dbg(APPNAME, "BS::RadioReceiver.receive(). Discarding... \n");		
			}
		} else {

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
		}
		return msg;
	}
	
#ifdef MODULE_CTP
    event message_t * rec_NEWPROGVERSION.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_NEWPROGVERSION,msg,payload,len);}
    event message_t * rec_NEWPROGBLOCK.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_NEWPROGBLOCK,msg,payload,len);}
    event message_t * rec_REQPROGBLOCK.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_REQPROGBLOCK,msg,payload,len);}
#ifdef MODE_SETDATA
    event message_t * rec_SETDATAND.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_SETDATAND,msg,payload,len);}
    event message_t * rec_REQDATA.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_REQDATA,msg,payload,len);}
#endif
    event message_t * rec_PINGMSG.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_PINGMSG,msg,payload,len);}
    event message_t * rec_CUSTOM_0.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_0,msg,payload,len);}
    event message_t * rec_CUSTOM_1.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_1,msg,payload,len);}
    event message_t * rec_CUSTOM_2.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_2,msg,payload,len);}
    event message_t * rec_CUSTOM_3.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_3,msg,payload,len);}
    event message_t * rec_CUSTOM_4.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_4,msg,payload,len);}
    event message_t * rec_CUSTOM_5.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_5,msg,payload,len);}
    event message_t * rec_CUSTOM_6.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_6,msg,payload,len);}
    event message_t * rec_CUSTOM_7.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_7,msg,payload,len);}
    event message_t * rec_CUSTOM_8.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_8,msg,payload,len);}
    event message_t * rec_CUSTOM_9.receive(message_t *msg, void *payload, uint8_t len){return RadioReceiver_receive(AM_CUSTOM_9,msg,payload,len);}
#endif

/* ******************************************************************************
*                       Upload control functions
\* ******************************************************************************/
 	/**
 	 * Process a received newProgVersion message
 	 * @param Data Message data
 	 */ 
 	void procNewProgVersion(newProgVersion_t* Data){
		dbg(APPNAME, "BS::procNewProgVersion().\n");
//		call Leds.set(7);
		// Stop the VM
 		signal BSUpload.stop();
 		signal BSUpload.resetMemory();
 		TViewer("vmstop",0,0);
//logS("I",1);
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
		dbg(APPNAME, "BS::procNewProgVersion(). ProgBlockStart=%d, ProgBlockLen=%d \n",ProgBlockStart,ProgBlockLen);
 		// reset all memory (leave set unused blocks)
 		atomic call BM.resetRange(ProgBlockStart,(ProgBlockStart+ProgBlockLen)-1);
 		//printBM();
		{
	 		reqProgBlock_t xData;
	 		// send a reqProgBlock full
	 		ProgTimeOutCounter=0;
		 	xData.reqOper=RO_DATA_FULL;
		 	ReqState = RO_DATA_FULL;
		 	xData.versionId = ProgVersion;
		 	xData.blockId = ProgBlockStart;
		 	loadingProgramFlag = TRUE;
		 	sendReqProgBlock(&xData);
		 	// Wait next block up to time-out
			if (MoteID != BStation)
		 		call ProgReqTimer.startOneShot(getRequestTimeout());
		 	else
		 		call ProgReqTimer.startOneShot(REQUEST_TIMEOUT_BS);	
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
//		 call Leds.led0Toggle();		 
//		printf("prc_nb%d.",Data->blockId);printfflush();
		 call ProgReqTimer.stop();
		 // Convert nx_uint8_t to uint8_t
		 for (i=0; i < BLOCK_SIZE; i++) lData[i]=(uint8_t)Data->data[i];
		 // Calculate memory position (Addr)
		 Addr = Data->blockId * BLOCK_SIZE;
		 // Update memory and BitMap
		 signal BSUpload.loadSection(Addr , (uint8_t)BLOCK_SIZE, &lData[0]);
		 call BM.set((uint16_t)Data->blockId);
//logData[0]='M';
//logData[1]='0'+(Data->blockId%100)/10;
//logData[2]='0'+(Data->blockId%10)/1;
//logS(logData,3);
		 // Reset timeOut counter
		 ProgTimeOutCounter = 0;
//		printf("pend%d.",call BM.countPend());printfflush();
		 // Check if it was the last block
		 if ( call BM.isAllBitSet()) {
//logData[0]='F';
//logS(logData,1);
//		 	call Leds.set(0);
		 	loadingProgramFlag = FALSE;
		 	if (MoteID != BStation){
			 	// Start the VM
	 			ReqState=ST_IDLE;
				TViewer("vmstart",0,0);
				signal BSUpload.start(TRUE);
			} else {
#ifndef NO_BSTATION
		 		newProgVersion_t xVersion;
				// BStation - Do not start VM and broadcast newProgVersion.
				xVersion.versionId = ProgVersion;
			 	xVersion.blockLen = ProgBlockLen;
			 	xVersion.blockStart = ProgBlockStart;
			 	signal BSUpload.getEnv(&xVersion);
			 	sendNewProgVersion(&xVersion);				
#endif
			}
		 } else {
		 	// Wait next block
 			ReqState=ST_WAIT_PROG_BLK;
			if (MoteID != BStation){
		 		call ProgReqTimer.startOneShot(getRequestTimeout());
		 	} else {
#ifndef NO_BSTATION
		 		// if BS, request next block 
			 	serialReqProgBlock.reqOper=RO_DATA_FULL;
				ReqState = RO_DATA_FULL;
				serialReqProgBlock.versionId = ProgVersion;
				serialReqProgBlock.blockId = Data->blockId+1;
				sendReqProgBlock(&serialReqProgBlock);
		 		call ProgReqTimer.startOneShot(REQUEST_TIMEOUT_BS);
#endif
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
		 uint16_t i=0;
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
	 task void ProgReqTimerTask(){
		 uint16_t nextBlock=CURRENT_MAX_BLOCKS;
		 reqProgBlock_t Data;
		 uint32_t timeout=getRequestTimeout();
//logData[0]='T';
//logData[1]='0'+ReqState;
//logS(logData,2);
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
						call ProgReqTimer.startOneShot(getRequestTimeout());
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
#ifndef NO_BSTATION

					for (x=0;x<Data->nSections;x++){
						secAddr=Data->Data[secp++];
						secAddr = secAddr + (Data->Data[secp++] << 8); 
						secLen = Data->Data[secp++];
						for (i=0; i < secLen; i++) lData[i] = Data->Data[secp++];
						signal BSUpload.loadSection(secAddr , secLen, &lData[0]);
					}
#endif
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
//				printf("inEvt%d.",tempOutputInQ.AM_ID);printfflush();
				if (MoteID == BStation){
					if (call outQ.put(&tempOutputInQ)!= SUCCESS) {
						dbg(APPNAME, "BS::procInputEvent(): outQueue is full! Losting a message.\n");
					}
					post procInputEvent();
				} else {
				
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
#ifndef ONLY_BSTATION
					dbg(APPNAME, "BS::procInputEvent(): nextMessage.\n");
					call inQ.get(&tempOutputInQ);
					post procInputEvent();
#endif
				}
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
#ifndef ONLY_BSTATION
		error_t stat;
		// Send to Radio
		if (MoteID != BStation){
			memcpy(call sendBSNet.getPayload(&sendBuff,call sendBSNet.maxPayloadLength()), &tempOutputOutQ.Data, tempOutputOutQ.DataSize);
			dbg(APPNAME, "BS::sendBSNet(): Sending Message AM_ID=%d, size=%d, maxSize=%d\n", tempOutputOutQ.AM_ID,tempOutputOutQ.DataSize,call sendBSNet.maxPayloadLength());
			stat = call sendBSNet.send(&sendBuff, tempOutputOutQ.DataSize);
			if (stat != SUCCESS) {
				dbg(APPNAME,"BS::sendBSNet(): Error in Sending Message(%d))\n",stat);
				call sendTimer.startOneShot(reSendDelay);
			}
		}
#endif
	}
#endif // MODULE_CTP
	/**
	* Sends out a xxxx message
	*/


		error_t RadioSender_send(uint8_t am_id, uint16_t target, message_t* msg, uint8_t len){
#ifndef MODULE_CTP
//logS("s",1);
			return call RadioSender.send[tempOutputOutQ.AM_ID](tempOutputOutQ.sendToMote, &sendBuff, tempOutputOutQ.DataSize);
#else
			switch (am_id){
				case AM_NEWPROGVERSION	: return call snd_NEWPROGVERSION.send(target, msg, len); break;
				case AM_NEWPROGBLOCK 	: return call snd_NEWPROGBLOCK.send(target, msg, len); break;
				case AM_REQPROGBLOCK 	: return call snd_REQPROGBLOCK.send(target, msg, len); break;
#ifdef MODE_SETDATA
				case AM_SETDATAND 		: return call snd_SETDATAND.send(target, msg, len); break;
				case AM_REQDATA 		: return call snd_REQDATA.send(target, msg, len); break;
#endif
				case AM_PINGMSG 		: return call snd_PINGMSG.send(target, msg, len); break;
				case AM_CUSTOM_0 		: return call snd_CUSTOM_0.send(target, msg, len); break;
				case AM_CUSTOM_1 		: return call snd_CUSTOM_1.send(target, msg, len); break;
				case AM_CUSTOM_2 		: return call snd_CUSTOM_2.send(target, msg, len); break;
				case AM_CUSTOM_3 		: return call snd_CUSTOM_3.send(target, msg, len); break;
				case AM_CUSTOM_4 		: return call snd_CUSTOM_4.send(target, msg, len); break;
				case AM_CUSTOM_5 		: return call snd_CUSTOM_5.send(target, msg, len); break;
				case AM_CUSTOM_6 		: return call snd_CUSTOM_6.send(target, msg, len); break;
				case AM_CUSTOM_7 		: return call snd_CUSTOM_7.send(target, msg, len); break;
				case AM_CUSTOM_8 		: return call snd_CUSTOM_8.send(target, msg, len); break;
				case AM_CUSTOM_9 		: return call snd_CUSTOM_9.send(target, msg, len); break;
			}	
			return FAIL;
#endif
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

#ifdef TOSSIM

#elif defined(INOS) || defined(INOX)

#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB)
		if (tempOutputOutQ.RFPower > 0) call RadioAux.setPower(&sendBuff,tempOutputOutQ.RFPower);
#elif defined(PLATFORM_IRIS)
		if (tempOutputOutQ.RFPower > 0) call RadioAux.set(&sendBuff,tempOutputOutQ.RFPower);
#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
		if (tempOutputOutQ.RFPower > 0) atomic {call RadioAux.setRFPower(tempOutputOutQ.RFPower);};

#endif
		err = RadioSender_send(tempOutputOutQ.AM_ID,tempOutputOutQ.sendToMote, &sendBuff, tempOutputOutQ.DataSize);
		if (err != SUCCESS) {
			dbg(APPNAME,"BS::sendRadioN(): Error %hhu in sending Message AM=%hhu to node=%d via radio\n",err,tempOutputOutQ.AM_ID, tempOutputOutQ.sendToMote);
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
//		err = call SerialSender.send[tempOutputOutQ.AM_ID](AM_BROADCAST_ADDR, &sendBuff, tempOutputOutQ.DataSize);
		err = call SerialSender.send[tempOutputOutQ.AM_ID]( (tempOutputOutQ.sendToMote & 0x7fff), &sendBuff, tempOutputOutQ.DataSize);
		if ( err != SUCCESS) {
			dbg(APPNAME,"BS::sendSerialN(): Error %hhu in sending Message AM=%hhu via UART\n",err,tempOutputOutQ.AM_ID);
			call sendTimer.startOneShot(reSendDelay);	
		} else {
			TViewer("serial",0,0);
		}
#endif
	}


	/**
	* Process each event from output Queue
	*/
	task void sendMessage(){
		sendCounter++;
		if (call outQ.read(&tempOutputOutQ)==SUCCESS) {
		dbg(APPNAME, "BS::sendMessage():AM=%hhu, senToMote=%d.\n",tempOutputOutQ.AM_ID, tempOutputOutQ.sendToMote);
//		printf("snd_%d.",tempOutputOutQ.AM_ID); printfflush();

		if (MoteID == BStation){
			// Send to Radio or UART
			if ( (tempOutputOutQ.sendToMote < AM_BROADCAST_ADDR) && (tempOutputOutQ.sendToMote >= 0x8000)) {
				sendSerialN();
			} else {
				if (tempOutputOutQ.AM_ID==AM_NEWPROGVERSION) {
					disseminatorRoot = 0;
					dbg(APPNAME, "BS::sendMessage(): reset disseminatorRoot=%d.\n",disseminatorRoot);
				}
				sendRadioN();
			}						
			call outQ.get(&tempOutputOutQ);  // Remove message from buffer
		} else {

			switch (tempOutputOutQ.AM_ID) {
	#ifdef MODULE_CTP
				case AM_SENDBS: 
					// Send to Radio/CTP or UART
					if (MoteID != BStation){
						sendBSN();
					} else {
						sendSerialN();
					}			
					break;
	#endif // MODULE_CTP
				case AM_NEWPROGVERSION: sendRadioN(); break;
				case AM_NEWPROGBLOCK:  sendRadioN(); break;
				case AM_REQPROGBLOCK: 
					// Send to Radio or UART
					if (MoteID != BStation){
						sendRadioN();
					} else {
						sendSerialN();
					}			
					break;
	#ifdef MODE_SETDATA
				case AM_SETDATAND: sendRadioN(); break;
				case AM_REQDATA: 
					// Send to Radio or UART
					if (MoteID != BStation){
						sendRadioN();
					} else {
						sendSerialN();
					}
					break;
	#endif
				default: 
					if (tempOutputOutQ.AM_ID >= AM_CUSTOM_START && tempOutputOutQ.AM_ID <= AM_CUSTOM_END) { // AM_CUSTOM Range
						// Send to Radio or UART
						if (MoteID != BStation){
							sendRadioN();
						} else {
							if ( (tempOutputOutQ.sendToMote < AM_BROADCAST_ADDR) && (tempOutputOutQ.sendToMote >= 0x8000)) {
								sendRadioN();
								}
							else
								sendSerialN();
						}
					}				
					break;
				} 
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
#ifndef MODULE_CTP
	event void RadioSender.sendDone[am_id_t id](message_t *msg, error_t error){
#else
	void RadioSender_sendDone(am_id_t id,message_t *msg, error_t error){
#endif
	  bool doneStatus, reqRetry, reqAck;
	  //GenericData_t tempBuff;		
	  if (id > AM_RESERVED_END) {
	  	call outQ.read(&tempOutputOutQ);
	  	doneStatus = (error == SUCCESS);
	  	reqAck   = (tempOutputOutQ.reqAck & (1<<REQ_ACK_BIT)) > 0; 
	  	reqRetry = (tempOutputOutQ.reqAck & (1<<REQ_RETRY_BIT)) > 0; 
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


#ifdef MODULE_CTP
    event void snd_NEWPROGVERSION.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_NEWPROGVERSION,msg,error);}
    event void snd_NEWPROGBLOCK.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_NEWPROGBLOCK,msg,error);}
    event void snd_REQPROGBLOCK.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_REQPROGBLOCK,msg,error);}
#ifdef MODE_SETDATA
    event void snd_SETDATAND.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_SETDATAND,msg,error);}
    event void snd_REQDATA.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_REQDATA,msg,error);}
#endif
    event void snd_PINGMSG.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_PINGMSG,msg,error);}
    event void snd_CUSTOM_0.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_0,msg,error);}
    event void snd_CUSTOM_1.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_1,msg,error);}
    event void snd_CUSTOM_2.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_2,msg,error);}
    event void snd_CUSTOM_3.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_3,msg,error);}
    event void snd_CUSTOM_4.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_4,msg,error);}
    event void snd_CUSTOM_5.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_5,msg,error);}
    event void snd_CUSTOM_6.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_6,msg,error);}
    event void snd_CUSTOM_7.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_7,msg,error);}
    event void snd_CUSTOM_8.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_8,msg,error);}
    event void snd_CUSTOM_9.sendDone(message_t *msg, error_t error){RadioSender_sendDone(AM_CUSTOM_9,msg,error);}
#endif

#ifdef MODULE_CTP
	event void sendBSNet.sendDone(message_t *msg, error_t error){
#ifndef ONLY_BSTATION
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
#endif
	}
#endif // MODULE_CTP	

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
		tempInputOutQ.reqAck = 0;
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
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::sendSetDataND(): outQueue is full! Losting a message.\n");
		}
	}	
#endif
	/**
	 * Custom Send Message - queue the message to send via radio
	 */
	command error_t BSRadio.send(uint8_t am_id, uint16_t target, void* dataMsg, uint8_t dataSize, uint8_t reqAck){
		dbg(APPNAME, "BS::BSRadio.send(): insert in outQueue. AM_ID=%d, Target=%d\n",am_id,target);		
		memcpy(&tempInputOutQ.Data,dataMsg,dataSize);
		tempInputOutQ.AM_ID = am_id;
		tempInputOutQ.DataSize = dataSize;
		tempInputOutQ.sendToMote = target;
		tempInputOutQ.reqAck = reqAck;
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB) || defined(PLATFORM_IRIS) || defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
		tempInputOutQ.RFPower = RFPowerTab[userRFPowerIdx];
#else
		tempInputOutQ.RFPower = 0;
#endif
		dbg("VMDBG","Radio: Sending user msg AM_ID=%d to node %d\n",am_id, target);		
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
#ifndef ONLY_BSTATION
		dbg(APPNAME, "BS::CM.sendBS(): insert in outQueue\n");		
		memcpy(&tempInputOutQ.Data,Data,(len>MSG_BUFF_SIZE)?MSG_BUFF_SIZE:len);
		tempInputOutQ.AM_ID = AM_SENDBS;
		tempInputOutQ.DataSize = (nx_uint8_t)(len>MSG_BUFF_SIZE)?(uint8_t)MSG_BUFF_SIZE:len;
		tempInputOutQ.sendToMote = 0; // Use the CTP
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::CM.sendBS(): outQueue is full! Losting a message.\n");
			return EBUSY;
		}
#endif // ONLY_BSTATION
		return SUCCESS;
	}
#endif // MODULE_CTP
	
		command uint16_t BSRadio.source(message_t* msg){return call RadioAMPacket.source(msg);}


/* *****************************************************************************************
*             Base Station Events - Disabled when compiled for generic real Mote
\* *****************************************************************************************/
	void dummy(message_t *msg, void *payload, uint8_t len){}

 	/**
 	 * Process a received sendBS message
 	 * @param Data Message data
 	 */ 
#ifdef MODULE_CTP
	void procSendBS(sendBS_t* Data){
#ifndef NO_BSTATION
		dbg(APPNAME, "BS::procSendBS():insert in outQueue\n");
		if (MoteID == BStation){
		memcpy(&tempInputOutQ.Data,Data,sizeof(sendBS_t));
		tempInputOutQ.AM_ID = AM_SENDBS;
		tempInputOutQ.DataSize = sizeof(sendBS_t);
		tempInputOutQ.sendToMote = AM_BROADCAST_ADDR;
		if (call outQ.put(&tempInputOutQ)!= SUCCESS) {
			dbg(APPNAME, "BS::procSendBS(): outQueue is full! Losting a message.\n");
		}		
		}
#endif
	}
#endif //MODULE_CTP	


#ifdef MODULE_CTP
	event message_t * recSendBS.receive(message_t *msg, void *payload, uint8_t len){
#ifndef NO_BSTATION
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
		// put the message in inQueue
//		if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recSendBS.receive(): inQueue is full! Losting a message.\n");
		if (call outQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::recSendBS.receive(): outQueue is full! Losting a message.\n");
#endif
		return msg;
	}
#endif //MODULE_CTP	

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
//		call sendTimer.startOneShot(reSendDelay);
		call sendTimer.startOneShot(1); // Doesn't wait too long to send next serial message'
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
#ifdef MODE_SETDATA
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
#endif

	void recSerialCustomMsg_receive(message_t *msg, void *payload, uint8_t len){
		dbg(APPNAME, "BS::recSerialCustomMsg_receive():\n");
		memcpy(&tempInputOutQ.Data,payload,len);
		tempInputOutQ.AM_ID = call RadioAMPacket.type(msg);
		tempInputOutQ.DataSize = len;
		tempInputOutQ.sendToMote = 0;
		tempInputOutQ.reqAck = 0;
		if (call outQ.put(&tempInputOutQ)!=SUCCESS) dbg(APPNAME, "BS::recSerialCustomMsg_receive(): outQueue is full! Losting a message.\n");		
	}

	event message_t * SerialReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
		dbg(APPNAME, "BS::SerialReceiver.receive(): AM=%hhu\n",id);
		TViewer("serial",1,0);

		if (MoteID == BStation) {
			// Copy data to temporarily buffer
			memcpy(tempInputInQ.Data,payload,len);
			tempInputInQ.AM_ID = id;
			tempInputInQ.DataSize = len;	
			tempInputInQ.sendToMote = AM_BROADCAST_ADDR; //(call RadioAMPacket.destination(msg)==0)?AM_BROADCAST_ADDR:call RadioAMPacket.destination(msg);
			// put message in the inQueue
			if (call inQ.put(&tempInputInQ)!=SUCCESS) dbg(APPNAME, "BS::SerialReceiver.receive(): inQueue is full! Losting a message.\n");
		}

/* Removing old BS
 
		switch (id){
			case AM_NEWPROGVERSION:
				recSerialNewProgVersion_receive(msg,payload,len);
				break;			
			case AM_NEWPROGBLOCK:
				recSerialNewProgBlock_receive(msg,payload,len);
				break;			
#ifdef MODE_SETDATA
			case AM_SETDATAND:
				recSerialSetDataND_receive(msg,payload,len);
				break;						
#endif
			default:
				if (id >= AM_CUSTOM_START && id <= AM_CUSTOM_END) { // AM_CUSTOM Range
					if (loadingProgramFlag == FALSE) recSerialCustomMsg_receive(msg,payload,len);
		 		} else {
					dbg(APPNAME, "BS::SerialReceiver.receive(). Received a undefined AM=%hhu from %hhu\n",id,call RadioAMPacket.source(msg));	 		
		 		}
		 		break;
		}
*/
		return msg;
	}


#endif


	// Not using Queue dataReady event
#ifdef MODE_SETDATA
	event void setDataQ.dataReady(){}
#endif


// afb

	// Log data to USB0
#if defined(INOS)

	event void InoIO.interruptFired(interrupt_enum intPin){}
	event void InoIO.pulseLen(interrupt_enum intPin, pinvalue_enum value, uint32_t data){}
	event void InoIO.analogReadDone(analog_enum pin, uint16_t data){}
#elif defined(INOX)
	command void BSUpload.logS(uint8_t* data, uint8_t len){logS(data,len);}
	command void BSRadio.logS(uint8_t* data, uint8_t len){logS(data,len);}

	async event void Uart0.receivedByte(uint8_t byte){
		// TODO Auto-generated method stub
	}

	async event void Uart0.receiveDone(uint8_t *buf, uint16_t len, error_t error){
		// TODO Auto-generated method stub
	}

	event void InoIO.interruptFired(interrupt_enum intPin){}
	event void InoIO.pulseLen(interrupt_enum intPin, pinvalue_enum value, uint32_t data){}
	event void InoIO.analogReadDone(analog_enum pin, uint16_t data){}
#endif

}
