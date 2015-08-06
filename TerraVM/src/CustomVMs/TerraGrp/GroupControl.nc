/***********************************************
 * wdvm - WSNDyn virtual machine project
 * July, 2012
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Interface: GroupControl
 * Group control support
 */
#include "VMCustomGrp.h"

interface GroupControl{
	
	// Module initialization
	command void init();
 	event void initDone();
 	
 	/**
 	 *  Verify group participation
 	 * 
	 * @param grId Group type identifier
	 * @param grParam Group parameter value (identify the subgroup)
 	 */
 	event bool isSameGroup(uint8_t grId, uint8_t grParam);
 	
	/**
	 * Broadcast message to all group members or to a specifc mote
	 * Bit 5 of GrId indicate Group[0]/Mote[1]
	 * 
	 * @param grId Group type identifier
	 * @param grParam Group parameter value (identify the subgroup)
	 * @param maxHops Maximum hops to reach all group nodes
	 * @param targetNode Target mote to send the message
 	 * @param evtId Event identifier
	 * @param dataSize Data structure size
	 * @param data Pointer to data structure
  	 */
 	command uint8_t sendGR(uint8_t grId, uint8_t grParam, uint8_t maxHops, uint16_t targetNode, uint8_t evtId, uint8_t dataSize, uint8_t* data);

	/**
	 * Set RF Power for group radio messages
	 * 
	 * @param powerIdx index of Power Table
	 */
	command void setRFPower(uint8_t powerIdx);

	/**
	 * Process an aggregation value for a specific group
  	 * 
	 * @param grId Group type identifier
	 * @param grParam Group parameter value (identify the subgroup)
	 * @param maxHops Maximum hops to reach all group nodes
 	 * @param aggId Event identifier
	 * @param reqData Pointer to Aggreg data structure
  	 */
 	command void aggreg(uint8_t grId, uint8_t grParam, uint8_t maxHops, uint8_t aggId, aggReqData_t *reqData);

	
	/**
	 * Send message to BaseStation (root mote on CTP)
	 * 
	 * @param evtId Event identifier
 	 * @param dataSize Data structure size
	 * @param data Pointer to data structure
	 */
#ifdef MODULE_CTP
	command uint8_t sendBS(uint8_t evtId, uint8_t dataSize, uint8_t* data);
	command uint16_t getParent();
#endif // MODULE_CTP

	// Signals a received message event
	event void evtReady(uint8_t CodeEvt_id, uint8_t* data, uint8_t grId, uint16_t reqMote);
	
	// Signals a received New Value Aggregation event
	event void aggNewValue(uint8_t CodeEvt_id, aggReqData_t* retData, uint16_t moteId);
	
	// Signals a received Request Value Aggregation event
	event void aggReqValue(uint8_t CodeEvt_id, aggReqData_t* reqData);

	// Signals a received Election event
	event void electionMsg(uint8_t CodeEvt_id, leaderData_t* recData);

	// check for election participation
	event bool chkElection(uint8_t GrId, uint8_t GrParam);
	
}
