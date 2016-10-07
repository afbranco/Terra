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
#include "BasicServicesIx.h"
//#include "AvroraPrint.h"

module BasicServicesIxP{
	provides interface Boot as BSBoot;
	provides interface BSTimer as BSTimerVM;
	provides interface BSTimer as BSTimerAsync;
	provides interface BSUpload;
	provides interface BSRadio;

	uses interface Boot as TOSBoot;



	uses {
		// Bitmap
		interface vmBitVector as BM;
		
		// Timer
		interface Timer<TMilli> as TimerVM;
		interface Timer<TMilli> as TimerAsync;
	}

}
implementation{

	uint32_t LocalClock=0;
	nx_uint16_t MoteID;					// Mote Identifier
	bool firstInic=TRUE;				// First initialization flag
	
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
	
	
/* **************************************************************\
*             Prototypes
\* **************************************************************/

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
			ProgBlockLen = CURRENT_MAX_BLOCKS;
			ProgMoteSource = 0;

			signal BSBoot.booted();
		} else {
			firstInic = FALSE;
		}
	}

	/**
	* Command to start the communication
	*/ 
	
	event void TOSBoot.booted(){
		uint32_t rnd=0;	
		dbg(APPNAME, "BS::TOSBoot.booted().\n");
		TOS_NODE_ID = 2;	

		MoteID = TOS_NODE_ID;
		
		if (firstInic){
			inicCtlData();
		} else {
			signal BSBoot.booted();
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

/* **************************************************************\
*             Messages receive
\* **************************************************************/
	

	

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
//		 	sendReqProgBlock(&xData);
		 	// Wait next block up to time-out
			if (MoteID != BStation)
;//		 		call ProgReqTimer.startOneShot(getRequestTimeout());
		 	else
;//		 		call ProgReqTimer.startOneShot(REQUEST_TIMEOUT_BS);	
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
//		 call ProgReqTimer.stop();
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
			}
		 } else {
		 	// Wait next block
 			ReqState=ST_WAIT_PROG_BLK;
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
//				 	sendNewProgVersion(&xVersion);
				 } else {
					 dbg(APPNAME, "BS::procRecReqProgBlock(). Request RO_NEW_VERSION discarted!\n");
				 }
				break;
			case RO_DATA_FULL:
				// Schedule the dissemination
				if ((ProgVersion == Data->versionId) && (ProgVersion > 0) && call BM.isAllBitSet()){
					DsmBlockCount=0;
//				 	call SendDataFullTimer.startOneShot(DISSEMINATION_TIMEOUT);
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
//					  sendNewProgBlock(&xBlock);
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
		 uint32_t timeout=100; //getRequestTimeout();
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
//			 	sendReqProgBlock(&Data);
			 	// Wait next block up to time-out
//			 	call ProgReqTimer.startOneShot(timeout);
		 		break;
		 	case RO_DATA_FULL:
		 		// timeout on full data request, retry for the next block
		 		nextBlock = getNextEmptyBlock();
			 	if (nextBlock < ProgBlockLen){
				 	Data.reqOper=RO_DATA_FULL;
					ReqState = RO_DATA_FULL;
					Data.versionId = ProgVersion;
					Data.blockId = nextBlock;
//					sendReqProgBlock(&Data);
					// Wait next block up to time-out
					if (MoteID != BStation)
;//						call ProgReqTimer.startOneShot(getRequestTimeout());
					else
;//						call ProgReqTimer.startOneShot(REQUEST_TIMEOUT_BS);					
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
//				 	sendReqProgBlock(&Data);
				 	// Wait next block up to time-out
//				 	call ProgReqTimer.startOneShot(getRequestTimeout());
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

 

	/**
	 * Custom Send Message - queue the message to send via radio
	 */
	command error_t BSRadio.send(uint8_t am_id, uint16_t target, void* dataMsg, uint8_t dataSize, uint8_t reqAck){
		dbg(APPNAME, "BS::BSRadio.send(): insert in outQueue. AM_ID=%d, Target=%d\n",am_id,target);		
		// TODO
		dbg("VMDBG","Radio: Sending user msg AM_ID=%d to node %d\n",am_id, target);		
		return SUCCESS;
	}
	
		command uint16_t BSRadio.source(message_t* msg){
			// TODO
			return 0; 
			}


	command void BSRadio.setRFPower(uint8_t powerIdx){
		// TODO Auto-generated method stub
	}
}
