/***********************************************
 * wdvm - WSNDyn virtual machine project
 * July, 2012
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Module: GroupControlP
 * Group control support
 * 
 */

#include "VMCustomGrp.h"
#include "BasicServices.h"

module GroupControlP{
	provides interface GroupControl as GrCtl;
	uses interface BSRadio;
	
}
implementation{

	bool firstInic=TRUE;	// First initialization flag
	uint16_t sendSeq;		// Send msg sequential number
	NHopsList_t NHopsList;	// Control list to avoid duplicated NHops events
	uint16_t MoteID;


	/**
	* Insert a NHops id in NHopsList. Return FAIL if already exists.
	* 
	* @param TargetMote Requester mote id
	* @param PrevMote Router mote id to find the TargetMote
	* @param ReqNum Request sequence to avoid duplicated messages
   	*/
	error_t insertNHopsList(nx_uint16_t TargetMote, nx_uint16_t PrevMote,nx_uint16_t ReqNum){
		nx_uint8_t i;
		dbg(APPNAME, "GrCtl::insertNHopsList(): Target=%hhu, Prev=%hhu, ReqNum=%hhu, nextPos=%hhu\n",TargetMote,PrevMote,ReqNum,NHopsList.nextPos);
		dbg(APPNAME, "GrCtl::insertNHopsList(): NHopsList addr=%x , size=%d\n",(int)&NHopsList,sizeof(NHopsList_t));
		i=0;
		while (i<NHOPS_LIST_SIZE) {
			if ((NHopsList.TargetMote[i] == TargetMote) && ( NHopsList.RequestNumber[i] == ReqNum )){
				dbg(APPNAME, "GrCtl::insertNHopsList(): Duplicated entry\n");
				return FAIL;
			}
			i++;
		}
		NHopsList.TargetMote[NHopsList.nextPos]=TargetMote;
		NHopsList.PrevMote[NHopsList.nextPos]=PrevMote;
		NHopsList.RequestNumber[NHopsList.nextPos]=ReqNum;
		NHopsList.nextPos = (nx_uint8_t)((NHopsList.nextPos+1)%NHOPS_LIST_SIZE);
		return SUCCESS;
	}
	/**
	 * Read from list the routing information
	 */
	error_t getNHopsList(nx_uint16_t TargetMote, nx_uint16_t* NextMote){
		int i;
		i=0;
		while (i<NHOPS_LIST_SIZE) {
			if (NHopsList.TargetMote[i] == TargetMote) {
				*NextMote = NHopsList.PrevMote[i];				
				dbg(APPNAME, "GrCtl::getNHopsList(): Target=%hhu. Next=%hhu.\n",TargetMote,*NextMote);
				return SUCCESS;
				}
			i++;
			}
		dbg(APPNAME, "GrCtl::getNHopsList(): Target=%hhu. Next not found!\n",TargetMote);
		return FAIL;
	}
	/**
	 * Clear the routing information
	 */
	void clearNHopsList(){
		int i;
		i=0;
		while (i<NHOPS_LIST_SIZE) {
			NHopsList.TargetMote[i] =0;
			NHopsList.PrevMote[i]=0;
			i++;
			}
		dbg(APPNAME, "GrCtl::clearNHopsList(): \n");
	}
	
	/**
	 * Initialize the data  (reset all data)
	 */
	command void GrCtl.init(){
		dbg(APPNAME, "GrCtl:GrCtl.initComm().\n");
		MoteID = TOS_NODE_ID;
		clearNHopsList();
		// Only for first initialization (boot)
		if (firstInic){
			sendSeq = 0;
		}
	}



/* ****************************************************************************
 *         Send commands
\* ***************************************************************************/

	/**
	 * Broadcast message to all group members
	 * 
	 * @param grId Group type identifier
	 * @param grParam Group parameter value (identify the subgroup)
	 * @param maxHops Maximum hops to reach all group nodes
	 * @param targetNode Target mote to send the message
 	 * @param evtId Event identifier
	 * @param dataSize Data structure size
	 * @param data Pointer to data structure
  	 */
 	command uint8_t GrCtl.sendGR(uint8_t grId, uint8_t grParam, uint8_t maxHops, uint16_t targetNode, uint8_t evtId, uint8_t dataSize, uint8_t* data){
		sendGR_t xData;
 		uint8_t i=0,reqRetryAck;
		bool toGr=TRUE;
		nx_uint16_t sendToMote;
		dbg(APPNAME, "GrCtl:GrCtl.sendGR(): dataSize=%d\n",dataSize);
 		// Copy data value
 		xData.grId = (nx_uint8_t)grId;
 		xData.grParam = (nx_uint8_t)grParam;
 		xData.MaxHops = (nx_uint8_t)maxHops;
 		xData.evtId = (nx_uint8_t)evtId;
 		xData.TargetMote = (nx_uint16_t)targetNode;
 		if ((grId & (1<<AGGREG_BIT)) == 0) { // Normal event
	 		// copy data
	 		for (i=0; i < dataSize; i++) { 
	 			xData.Data[i] = data[i];
				dbg(APPNAME, "GrCtl:GrCtl.sendGR(): byte[%d]=%d\n",i,data[i]);
	 		}
	 	} else {
	 		// Copy data agg retData as is.
	 		memcpy(&xData.Data[0],data,dataSize);
	 	}
 		// Populate message control values
 		xData.HopNumber=1;
 		xData.ReqMote = TOS_NODE_ID;
 		xData.ReqSeq = sendSeq++;

		if ((grId & (1<<GRND_BIT)) > 0) toGr = FALSE;
		sendToMote = AM_BROADCAST_ADDR;
		reqRetryAck= (1<<REQ_RETRY_BIT) | (1<< REQ_ACK_BIT);
		if (toGr==FALSE){
			if (getNHopsList(targetNode,&sendToMote)!=SUCCESS ) {
				dbg(APPNAME, "GrCtl:GrCtl.sendGR(): Can't find sendToMote. Broadcasting the message!\n");
				sendToMote = AM_BROADCAST_ADDR;
				reqRetryAck=0;
			}
		} else {
			sendToMote = AM_BROADCAST_ADDR;
			reqRetryAck=0;
		}
		dbg(APPNAME, "GrCtl:GrCtl.sendGR(): [toGr=%s] senToMote=%d, grId=%hhu[%hhu], grParam=%d\n",(toGr)?"true":"false",sendToMote,grId,grId&0x01f,grParam );  
		// Send via BSRadio Custom Message
		return call BSRadio.send(AM_SENDGR, sendToMote, &xData, sizeof(sendGR_t), reqRetryAck);

 	}

	/**
	 * Set RF Power for group radio messages
	 * 
	 * @param powerIdx index of Power Table
	 */
	command void GrCtl.setRFPower(uint8_t powerIdx){
		call BSRadio.setRFPower(powerIdx);
	}

	/**
	 * Process an aggregation value for a specific group
  	 * 
	 * @param grId Group type identifier
	 * @param grParam Group parameter value (identify the subgroup)
	 * @param maxHops Maximum hops to reach all group nodes
	 * @param Requester Request mote to return message
 	 * @param aggId Aggregation identifier
	 * @param dataSize Aggreg data structure size
	 * @param data Pointer to Aggreg data structure
  	 */
	command void GrCtl.aggreg(uint8_t grId, uint8_t grParam, uint8_t maxHops, uint8_t aggId, aggReqData_t *reqData){
 		sendGR_t xData;
		dbg(APPNAME, "GrCtl:GrCtl.aggreg()\n");
 		// Populate message control values
 		xData.HopNumber = 1;
 		xData.ReqMote = (nx_uint16_t)TOS_NODE_ID;
 		xData.TargetMote = (nx_uint16_t)AM_BROADCAST_ADDR;
 		// Copy data value
 		xData.grId = grId;
 		xData.grParam = grParam;
 		xData.MaxHops = maxHops;
 		xData.evtId = aggId;

		// Copy reqData to xData.Data
		memcpy(xData.Data,reqData,sizeof(aggReqData_t));
 		xData.ReqSeq = sendSeq++;

		dbg(APPNAME, "GrCtl:GrCtl.aggreg(): grId=%hhu[%hhu], grParam=%hhu\n",grId,grId&0x01f,grParam );  
		// Send via BSRadio Custom Message
		call BSRadio.send(AM_SENDGR, AM_BROADCAST_ADDR, &xData, sizeof(sendGR_t), FALSE);
  	}
  	
	/**
	 * Returns the parent node in the CTP tree
	 * 
	 * @return the parent node or 0
	 */	
#ifdef MODULE_CTP
	command uint16_t GrCtl.getParent(){
		return call BSRadio.getParent();
	}	
#endif // MODULE_CTP

	/**
	 * Send message to BaseStation (root mote on CTP)
	 * 
	 * @param evtId Event identifier
 	 * @param dataSize Data structure size
	 * @param data Pointer to data structure
	 */
#ifdef MODULE_CTP
	sendBS_t yData;
	command uint8_t GrCtl.sendBS(uint8_t evtId, uint8_t dataSize, uint8_t* data){
		uint8_t i=0;
		dbg(APPNAME, "GrCtl:GrCtl.sendBS(): evtId=%d, dataSize=%d, data[0]=%d\n", evtId,dataSize, *(uint8_t*)data);
		yData.evtId = evtId;
 		for (i=0; i < dataSize; i++) yData.Data[i] = data[i];
		yData.Sender = TOS_NODE_ID;
 		yData.seq = sendSeq++;
 		return call BSRadio.sendBS(&yData, sizeof(sendBS_t));
	}
#endif // MODULE_CTP
	event void BSRadio.sendDone(uint8_t am_id,message_t* msg,void* dataMsg,error_t error) {
	// Do nothing by now!
		// In future may return an event to VM.
	}
	event void BSRadio.sendDoneAck(uint8_t am_id,message_t* msg,void* dataMsg,error_t error, bool wasAcked) {
		// Do nothing by now!
		// In future may return an event to VM.
	}
#ifdef MODULE_CTP
	event void BSRadio.sendBSDone(message_t* msg,error_t error){
		// Do nothing by now!
		// In future may return an event to VM.
	}
#endif // MODULE_CTP

	event void BSRadio.receive(uint8_t am_id, message_t* msg, void* payload, uint8_t len){
		nx_uint16_t prevMote,sendToMote;
		uint8_t lData[SEND_DATA_SIZE];
		uint8_t i=0,reqRetryAck;
		dbg(APPNAME, "GrCtl::BSRadio.receive(): AM_ID =%d.\n",am_id);

		if (am_id == AM_SENDGR) { // receiving a SendGrp message	
			sendGR_t *Data = payload;
			// Get source mote
			prevMote = call BSRadio.source(msg);

			/*
			 * Manipulate input message
			 */
			dbg(APPNAME, "GrCtl::BSRadio.receive(): Data->grId=0x%02x, Data->TargetMote=%d\n",Data->grId,Data->TargetMote); 	
			// Save NHopsList data, discard message if is already there.
			if (insertNHopsList(Data->ReqMote,prevMote,Data->ReqSeq)==FAIL) { dbg(APPNAME, "GrCtl::BSRadio.receive(): Discarding duplicated message!\n"); return;}
			// IF sendGR or sendGRND
			if ((Data->grId & (1<<GRND_BIT)) == 0){ // is sendGR
				// Discard self message
				if (Data->ReqMote == MoteID) { dbg(APPNAME, "GrCtl::BSRadio.receive(): Discarding self message!\n"); return;}
				// if necessary,forward the message
				if (Data->HopNumber+1 <= Data->MaxHops) {
					Data->HopNumber++;
					call BSRadio.send(AM_SENDGR, AM_BROADCAST_ADDR, Data, sizeof(sendGR_t), FALSE);
				}
			} else {
				if (Data->TargetMote != MoteID) { // Isn't a sendGRND to me
					 // Is not to me, I need to forward it and return
					dbg(APPNAME, "GrCtl::BSRadio.receive(): toGr=%s\n",(Data->grId & (1<<GRND_BIT))?"true":"false");
					// SendGRND - Forward to getNHopsList mote
					sendToMote = AM_BROADCAST_ADDR;
					reqRetryAck= (1<<REQ_RETRY_BIT) | (1<< REQ_ACK_BIT);
					if (getNHopsList(Data->TargetMote,&sendToMote)!=SUCCESS ) {
						dbg(APPNAME, "GrCtl::BSRadio.receive(): Can't find sendToMote. Broadcasting the message!\n");
						sendToMote = AM_BROADCAST_ADDR;
						reqRetryAck=0;
					}
					Data->HopNumber++;
					call BSRadio.send(AM_SENDGR, sendToMote, Data, sizeof(sendGR_t), reqRetryAck);
					return;
				}
			}

			/*
			 * Proccess received message
			 */

			// Not to me! Discard it.
			if (!(signal GrCtl.isSameGroup((uint8_t)Data->grId,(uint8_t)Data->grParam))) return;
			// test if it is an aggregation or a common event or an election single Msg
			if ((Data->grId & (1<<AGGREG_BIT)) > 0) { // Aggregation event
				aggReqData_t *aggData = (aggReqData_t*)(Data->Data);
				// If it is an aggregation message, then check if it is a request or a new value
				if ((Data->grId & (1<<GRND_BIT)) > 0) {  // new item
					// Receive an new item for current aggregation
					signal GrCtl.aggNewValue((uint8_t)(Data->evtId & 0x07),aggData, Data->ReqMote);
				} else { // request value
					// Receive an request value
					signal GrCtl.aggReqValue((uint8_t)(Data->evtId & 0x07),aggData);		
				}
			} else { // VM Event or Election Msg
				if ((Data->grId & (1<<ELECTION_BIT)) > 0) {
					leaderData_t *elctData = (leaderData_t*)Data->Data;
					signal GrCtl.electionMsg((uint8_t) Data->evtId, elctData);							
				} else {
					// Discard others message
					if (Data->TargetMote !=AM_BROADCAST_ADDR && Data->TargetMote != MoteID) { dbg(APPNAME, "GrCtl::BSRadio.receive(): Discarding others message!\n"); return;}
					// Copy data from nx_uint8_t to uint8_t
					for (i=0; i < SEND_DATA_SIZE; i++) lData[i] = (uint8_t)Data->Data[i];
					signal GrCtl.evtReady((uint8_t) Data->evtId, lData, (uint8_t)Data->grId,(uint16_t)Data->ReqMote);					
				}
			}
		} else {
			dbg(APPNAME, "GrCtl::BSRadio.receive(): Discarding unknow message ID=%d\n",am_id);			
		}
	}


} // end