/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#include "VMCustomGrp.h"
#include "SensAct.h"

module VMCustomP{
	provides interface VMCustom as VM;
	uses interface Boot;
	uses interface SensAct as SA;

	// TerraGrp Custom
	uses interface GroupControl as GrCtl;
	uses interface Random;
#ifndef ONLY_BSTATION
	uses interface Queue<uint32_t> as aggQ;
	uses interface dataQueue as aggReqQ;
	uses interface dataQueue as aggLocalReqQ;
	uses interface Queue<uint8_t> as electionQ;
	uses interface Timer<TMilli> as AggTmr;
	uses interface Timer<TMilli> as ElectionTmr;
	uses interface Timer<TMilli> as renewTmr;
#endif

}
implementation{


// Keeps last data value for events (ExtDataxxx must be nx_ type. Because it is copied direct to VM memory.)
nx_uint8_t  ExtDataCustomA;			// last request custom event (internal loop-back)
usrSendGR_t ExtDataRecGR;			// last received radio group msg
aggDone_t   ExtDataAggDone; 			// last AggregDone calculation
nx_uint8_t  ExtDataQReady;			// last queue ready - queue size 
uint8_t 	ExtDataError;			// last error event
nx_uint16_t	ExtDataLeader;			// last leader identifier
nx_uint8_t	ExtDataSendBSStatus;	// last SENDBS_DONE Status
nx_uint8_t	ExtDataSendGRStatus;	// last SENDGR_DONE Status

// Maintain pointer to first and last Group/Aggreg Control
groupCtl_t* firstGrp = NULL;
groupCtl_t* lastGrp  = NULL;
uint8_t countGrp = 0;
aggregCtl_t* firstAgg = NULL;
aggregCtl_t* lastAgg  = NULL;
uint8_t countAgg = 0;
uint8_t firstElectionPend = TRUE;


// Aggregation Processing Flag and ...
bool aggFlag=FALSE;
uint8_t CurrentAggreg = 0;
uint16_t CurrAggStructAddr = 0;
aggData_t CurrAggData;
uint32_t AggTotal=0;
uint16_t AggSeq=0;

// Election current vote data
currVoteData_t currVote;
currElectionData_t currElection;	

/*
 * Initialization
 */
event void Boot.booted(){ 
	call GrCtl.init();
	}
event void GrCtl.initDone(){}

#ifndef ONLY_BSTATION

/*
 * Some proptotypes
 */
bool getGrpDefValue(uint8_t grpId, bool* inGrp, uint8_t* electionFlag, uint8_t* grParam, uint8_t* maxHops);
bool isGrpAddrInitated(groupCtl_t* grCtl);
bool isAggAddrInitated(aggregCtl_t* agCtl);
uint8_t wd2ceuSensorId(uint8_t wdId);
void tryFirstElection();
task void procAggreg();
// Aggregation internal functions
void agAvgP1(uint32_t Value);
void agSumP1(uint32_t Value);
void agMaxP1(uint32_t Value);
void agMinP1(uint32_t Value);
void agReservP1(uint32_t Value, uint16_t moteId);
void agAvgP2();
void agSumP2();
void agMaxP2();
void agMinP2();
void agReservP2();
void sendRetVote(uint8_t Id, uint16_t toMote, uint16_t vote);
bool getGrpDefValue(uint8_t grpId, bool* inGrp, uint8_t* electionFlag, uint8_t* grParam, uint8_t* maxHops);
void queueLeaderProc(uint8_t bitValue);
void setCurrMaxVote(uint16_t vote,uint16_t mote);
/*
 * General use functions
 */
uint32_t getMVal(uint16_t addr,uint8_t tp){return signal VM.getMVal(addr,tp);}
void setMVal(uint32_t value, uint16_t Maddr, uint8_t fromTp, uint8_t toTp){signal VM.setMVal(value, Maddr, fromTp,toTp);}


/*
 * Output Events implementation
 */
void  proc_leds(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_leds(): evt id=%d, val=%d\n",id,(uint8_t)value);
	call SA.setActuator(AID_LEDS, (uint8_t)(value & 0x07));
}
void  proc_led0(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led0(): evt id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED0_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED0, (uint8_t)(value & 0x01));
}
void  proc_led1(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led1(): evt id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED1_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED1, (uint8_t)(value & 0x01));
}
void  proc_led2(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led2(): evt id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED2_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED2, (uint8_t)(value & 0x01));
}
void  proc_req_temp(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_temp(): evt id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_TEMP);
	}
void  proc_req_photo(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_photo(): evt id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_PHOTO);
	}
void  proc_req_volts(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_volts(): evt id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_VOLT);
	}
void  proc_set_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_set_port_a(): evt id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_OUT1, (uint8_t)(value & 0x01));
}
void  proc_set_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_set_port_b(): evt id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_OUT2, (uint8_t)(value & 0x01));
}
void  proc_cfg_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_port_a(): evt id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_PIN1, (uint8_t)(value & 0x01));
}
void  proc_cfg_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_port_b(): evt id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_PIN2, (uint8_t)(value & 0x01));
}
void  proc_req_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_port_a(): evt id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_IN1);
	}
void  proc_req_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_port_b(): evt id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_IN2);
	}
void  proc_cfg_int_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_int_a(): evt id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_INT1, (uint8_t)value);
	}
void  proc_cfg_int_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_int_b(): evt id=%d value=%d\n",id,value);
	call SA.setActuator(AID_INT2, (uint8_t)value);
	}
void  proc_req_custom_a(uint16_t id, uint32_t value){
	uint8_t auxId ;
	ExtDataCustomA = (uint8_t)value;
	dbg(APPNAME,"Custom::proc_req_custom_a(): id=%d, ExtDataCustomA=%d\n",id,ExtDataCustomA);
	auxId = (uint8_t)value;
	// Queue the custom event
	signal VM.queueEvt(I_CUSTOM_A_ID,auxId, &ExtDataCustomA);
	signal VM.queueEvt(I_CUSTOM_A   ,    0, &ExtDataCustomA);
	}

void  proc_req_custom(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_custom(): id=%d\n",id);
	// Queue the custom event
	ExtDataCustomA = 0;
	signal VM.queueEvt(I_CUSTOM   ,    0, &ExtDataCustomA);
	}


void  proc_send_bs(uint16_t id, uint32_t addr){
	usrSendBS_t *usrMsg;
	uint8_t stat;
	usrMsg = (usrSendBS_t*)signal VM.getRealAddr((nx_uint16_t)addr);
	dbg(APPNAME,"Custom::proc_send_bs(): evt id=%d, addr=%d\n",id,addr);
	stat = call GrCtl.sendBS(usrMsg->evtId, SEND_DATA_SIZE, (uint8_t*)usrMsg->Data);
	// Queue a SENDBS_DONE event
	ExtDataSendBSStatus = stat;
	signal VM.queueEvt(I_SENDBS_DONE_ID, usrMsg->evtId, &ExtDataSendBSStatus);	
	signal VM.queueEvt(I_SENDBS_DONE   ,    0, &ExtDataSendBSStatus);	
	}
void  proc_send_gr(uint16_t id, uint32_t addr){
	usrSendGR_t *usrMsg;
	uint8_t inGrp,electionFlag,grParam, maxHops;
	uint8_t stat;
	usrMsg = (usrSendGR_t*)signal VM.getRealAddr((nx_uint16_t)addr);
	dbg(APPNAME,"Custom::proc_send_gr(): evt id=%d, addr=%d\n",id,addr);
	getGrpDefValue(usrMsg->grId, &inGrp, &electionFlag, &grParam, &maxHops);
	stat = call GrCtl.sendGR(usrMsg->grId, grParam, maxHops, usrMsg->node, usrMsg->evtId, SEND_DATA_SIZE, (uint8_t*)usrMsg->Data);	
	// Queue a SENDGR_DONE event
	ExtDataSendGRStatus = stat;
	signal VM.queueEvt(I_SENDGR_DONE_ID, usrMsg->grId, &ExtDataSendGRStatus);	
	signal VM.queueEvt(I_SENDGR_DONE   ,    0, &ExtDataSendGRStatus);	
	}
void  proc_aggreg(uint16_t id, uint32_t addr){
	aggregCtl_t *agCtl;
	agCtl = (aggregCtl_t*)signal VM.getRealAddr((nx_uint16_t)addr);
	dbg(APPNAME,"Custom::proc_aggreg(): evt id=%d addr=%d\n",id,addr);
	// insert queue
	AggSeq++;
	dbg(APPNAME,"Custom::proc_aggreg(): aggId=%d, aggSeq=%d\n",agCtl->agId,AggSeq);
	call aggQ.enqueue((uint32_t)agCtl->agId + ((uint32_t)AggSeq<<16));
	if (aggFlag==FALSE) post procAggreg();
  	}
	
/*
 * Function implementation
 */
void  func_getNodeId(uint16_t id){
	uint16_t stat;
	// return NodeId
	stat = TOS_NODE_ID;
	dbg(APPNAME,"Custom::func_getNodeId(): func id=%d, NodeId=%d\n",id,stat);
	signal VM.push(stat);
	}	

void  func_random(uint16_t id){
	uint16_t stat;
	// return random16
	stat = call Random.rand16();
	dbg(APPNAME,"Custom::func_random(): func id=%d, Random=%d\n",id,stat);
	signal VM.push(stat);
	}	

void  func_getMem(uint16_t id){
	uint8_t val;
	uint16_t Maddr;
	Maddr = (uint16_t)signal VM.pop();
	val = (uint8_t)signal VM.getMVal(Maddr, 0);
	dbg(APPNAME,"Custom::func_getMem(): func id=%d, addr=%d, val=%d(%0x)\n",id,Maddr,val,val);
	signal VM.push(val);
	}
void  func_getTime(uint16_t id){
	uint32_t val;
	val = signal VM.getTime();
	dbg(APPNAME,"Custom::func_getTime(): func id=%d, val=%d(%0x)\n",id,val,val);
	signal VM.push(val);
	}


void  func_RFPower(uint16_t id){
	uint8_t powerIdx;
	powerIdx = (uint8_t)signal VM.pop();
	call GrCtl.setRFPower(powerIdx);
	signal VM.push(SUCCESS);
}

void  func_getParent(uint16_t id){
	uint16_t parent;
	parent = call GrCtl.getParent();
	signal VM.push(parent);
}

void func_groupInit(uint16_t id){
	groupCtl_t *grCtl;
	uint8_t elFlag,status,nhops,param,grId;
	uint16_t value,leader;
	dbg(APPNAME,"Custom::func_groupInit(): func id=%d\n",id);
	// pop values
	leader = (uint16_t)signal VM.pop();
	elFlag = (uint8_t)signal VM.pop();
	status = (uint8_t)signal VM.pop();
	nhops = (uint8_t)signal VM.pop();
	param = (uint8_t)signal VM.pop();
	grId = (uint8_t)signal VM.pop();
	value = (uint16_t)signal VM.pop();
	grCtl = (groupCtl_t*)signal VM.getRealAddr(value);
	// set struct
	grCtl->leader = leader;
	grCtl->elFlag = elFlag;
	grCtl->status = status;
	grCtl->nhops = nhops;
	grCtl->param = param;
	grCtl->grId = grId;

	dbg(APPNAME,"Custom::func_groupInit(): addr=%d, realAddr=%x, firstGrp->nextGrp=%d\n",value,grCtl,(firstGrp!=NULL)?firstGrp->nextGrp:0);
	if (isGrpAddrInitated(grCtl)==FALSE){ // Only update nextGrp if it is new
		grCtl->nextGrp = (uint16_t)NULL;
		countGrp++;
		if (firstGrp==NULL) {
			firstGrp = grCtl;
			lastGrp = grCtl;
		} else {
			lastGrp->nextGrp = (uint16_t)value; // mem addr
			lastGrp = grCtl;
		}
	}
	dbg(APPNAME,"Custom::func_groupInit(): addr=%d, realAddr=%x, firstGrp->nextGrp=%d\n",value,grCtl,(firstGrp!=NULL)?firstGrp->nextGrp:0);
	signal VM.push(SUCCESS);
	tryFirstElection();
	}		
void func_aggregInit(uint16_t id){
	aggregCtl_t *agCtl;
	groupCtl_t *grCtl;
	uint8_t agComp,agOper,sensorId;
	uint16_t value;
	uint32_t refVal;
	dbg(APPNAME,"Custom::func_aggregInit(): func id=%d\n",id);
	// pop values
	refVal = (uint32_t)signal VM.pop();
	agComp = (uint8_t)signal VM.pop();
	agOper = (uint8_t)signal VM.pop();
	sensorId = (uint8_t)signal VM.pop();
	value = (uint16_t)signal VM.pop(); // Grp Addr
	grCtl = (groupCtl_t*)signal VM.getRealAddr(value);
	value = (uint16_t)signal VM.pop(); // Agg addr
	agCtl = (aggregCtl_t*)signal VM.getRealAddr(value);
	// set struct
	agCtl->refVal = refVal;
	agCtl->agComp = agComp;
	agCtl->agOper = agOper;
	agCtl->sensorId = sensorId;
	agCtl->grId = grCtl->grId;

	if (isGrpAddrInitated(grCtl)==FALSE){
		signal VM.push(EINVAL); // EINVAL 6 -- An invalid parameter was passed 
		dbg(APPNAME,"ERROR Custom::func_aggregInit(): Group not initiated!\n",id);
		return;
	}
	if (isAggAddrInitated(agCtl)==FALSE){ // Only update nextAgg if it is new
		agCtl->nextAgg = (uint16_t)NULL;
		countAgg++;
		if (firstAgg==NULL) {
			firstAgg = agCtl;
			lastAgg = agCtl;
		} else {
			lastAgg->nextAgg = (uint16_t)value; // mem addr
			lastAgg = agCtl;
		}
	}
	signal VM.push(SUCCESS);
	}		

#endif // ONLY_BSTATION
	
/**
 *	procOutEvt(uint8_t id)
 *  	procOutEvt - process the out events (emit)
 * 
 *	id - Event ID
 */
command void VM.procOutEvt(uint8_t id,uint32_t value){
	dbg(APPNAME,"Custom::procOutEvt(): id=%d\n",id);
#ifndef ONLY_BSTATION
	switch (id){
		/* Terra Local output events */
//		case O_INIT 		: proc_init(id,value); break;
		case O_LEDS 		: proc_leds(id,value); break;
		case O_LED0 		: proc_led0(id,value); break;
		case O_LED1 		: proc_led1(id,value); break;
		case O_LED2 		: proc_led2(id,value); break;
		case O_TEMP 		: proc_req_temp(id,value); break;
		case O_PHOTO 		: proc_req_photo(id,value); break;
		case O_VOLTS 		: proc_req_volts(id,value); break;
		case O_PORT_A 		: proc_set_port_a(id,value); break;
		case O_PORT_B 		: proc_set_port_b(id,value); break;
		case O_CFG_PORT_A 	: proc_cfg_port_a(id,value); break;
		case O_CFG_PORT_B 	: proc_cfg_port_b(id,value); break;
		case O_REQ_PORT_A 	: proc_req_port_a(id,value); break;
		case O_REQ_PORT_B 	: proc_req_port_b(id,value); break;
		case O_CFG_INT_A 	: proc_cfg_int_a(id,value); break;
		case O_CFG_INT_B 	: proc_cfg_int_b(id,value); break;
		case O_CUSTOM_A 	: proc_req_custom_a(id,value); break;
		case O_CUSTOM 		: proc_req_custom(id,value); break;
		/* TerraGrp custom output events */
		case O_SEND_BS 		: proc_send_bs(id,value); break;
		case O_SEND_GR 		: proc_send_gr(id,value); break;
		case O_AGGREG		: proc_aggreg(id,value); break;		
	}
#endif
}


	command void VM.callFunction(uint8_t id){
		dbg(APPNAME,"Custom::VM.callFunction(%d)\n",id);
#ifndef ONLY_BSTATION
		switch (id){
			/* Terra Local functions */
			case F_GETNODEID: func_getNodeId(id); break;
			case F_RANDOM 	: func_random(id); break;
			case F_GETMEM 	: func_getMem(id); break;
			case F_GETTIME 	: func_getTime(id); break;

			case F_RFPOWER: func_RFPower(id); break;
			case F_GETPARENT: func_getParent(id); break;
			/* TerraGrp custom functions */
			case F_GROUPINIT : func_groupInit(id); break;		
			case F_AGGREGINIT: func_aggregInit(id); break;		
		}
#endif
	}

	command void VM.reset(){
#ifndef ONLY_BSTATION
		// reset Grp and Agg control vars
		// Maintain pointer to first and last Group/Aggreg Control
		firstGrp = NULL;
		lastGrp  = NULL;
		countGrp = 0;
		firstAgg = NULL;
		lastAgg  = NULL;
		countAgg = 0;	
		// Aggregation Processing Flag and ...
		aggFlag=FALSE;
		CurrentAggreg = 0;
		CurrAggStructAddr = 0;
		AggTotal=0;
		AggSeq=0;
		firstElectionPend = TRUE;
		call renewTmr.stop();
		call ElectionTmr.stop();
		call AggTmr.stop();
		call GrCtl.init();
		// Reset leds
		call SA.setActuator(AID_LEDS, 0);
#endif
	}

#ifndef ONLY_BSTATION

	bool isGrpAddrInitated(groupCtl_t* grCtl){
		uint8_t n;
		groupCtl_t* next_ = firstGrp;
		for (n=0; n < countGrp; n++)
			if (grCtl==next_) return TRUE; else next_ = (void*)signal VM.getRealAddr(next_->nextGrp);
		return FALSE;
	}
	bool isAggAddrInitated(aggregCtl_t* agCtl){
		uint8_t n;
		aggregCtl_t* next_ = firstAgg;
		for (n=0; n < countAgg; n++)
			if (agCtl==next_) return TRUE; else next_ = (void*)signal VM.getRealAddr(next_->nextAgg);
		return FALSE;
	}

	uint16_t findGroupAddr(uint8_t grpId){
		uint8_t n;
		groupCtl_t* next_ = firstGrp;
		dbg(APPNAME,"VM::findGroupAddr(): grpId=%d/%d, countGrp=%d, firstGrp addr=%x\n",(grpId & 0x1F),grpId,countGrp,firstGrp);
		for (n=0; n < countGrp; n++){
			dbg(APPNAME,"VM::findGroupAddr(): n=%d of %d, Id=%d\n",n,countGrp,next_->grId);
			if (next_->grId == (grpId & 0x1F))
				return ((void*)next_ - (void*)signal VM.getRealAddr(0)); // Var VM addr = (Var Real Addr) - (MEM Real Addr)
			else
				next_ = (void*)signal VM.getRealAddr(next_->nextGrp);
		}
		return 0;
	}

	uint16_t findAggregAddr(uint8_t aggId){
		uint8_t n;
		aggregCtl_t* next_ = firstAgg;
		dbg(APPNAME,"VM::findAggregAddr(): aggId=%d/%d, countAgg=%d, firstAgg addr=%x\n",(aggId & 0x07),aggId,countGrp,firstAgg);
		for (n=0; n < countAgg; n++){
			dbg(APPNAME,"VM::findAggregAddr(): n=%d of %d, Id=%d\n",n,countAgg,next_->agId);
			if (next_->agId == (aggId & 0x07))
				return ((void*)next_ - (void*)signal VM.getRealAddr(0)); // Var VM addr = (Var Real Addr) - (MEM Real Addr)
			else
				next_ = (void*)signal VM.getRealAddr(next_->nextAgg);
		}
		return 0;
	}

	bool getGrpDefValue(uint8_t grpId, bool* inGrp, uint8_t* electionFlag, uint8_t* grParam, uint8_t* maxHops){
		uint16_t grAddr;
		grAddr = findGroupAddr(grpId);
		dbg(APPNAME,"VM::getGrpDefValue():grpId=%d, grAddr=%d\n",grpId,grAddr);
		if (grAddr==0) return FALSE;
		// Get values from MEM
		*inGrp = 		(bool)getMVal(grAddr+GRD_status_idx,GRD_status_tp); 
		*electionFlag = (uint8_t)getMVal(grAddr+GRD_elFlag_idx,GRD_elFlag_tp);
		*maxHops = 		(uint8_t)getMVal(grAddr+GRD_nHops_idx,GRD_nHops_tp);
		*grParam = 		(uint8_t)getMVal(grAddr+GRD_param_idx,GRD_param_tp);
		dbg(APPNAME,"VM::getGrpDefValue(): inGrp=%d, electionFlag=%d, grParam%d, maxHops=%d\n",*inGrp, *electionFlag, *grParam, *maxHops);
		return TRUE;
	}

	bool getGrpElctState(uint8_t grpId, uint8_t* electionFlag, uint8_t* electionState){
		uint16_t grAddr;
		// set default values
		*electionFlag  = ELCT_OFF;
		*electionState = EST_OUT;
		grAddr = findGroupAddr(grpId);
		dbg(APPNAME,"VM::getGrpElctState():grpId=%d, grAddr=%d\n",grpId,grAddr);
		if (grAddr==0) return FALSE;
		// Get values from MEM
		*electionFlag = (uint8_t)getMVal(grAddr+GRD_elFlag_idx,GRD_elFlag_tp);
		*electionState = (uint8_t)getMVal(grAddr+GRD_elState_idx,GRD_elState_tp);
		dbg(APPNAME,"VM::getGrpElctState(): grId=%d(%d), flag=%d, state=%d\n",grpId,(grpId & 0x01f),*electionFlag,*electionState);
		return TRUE;
	}
	bool setGrpElctState(uint8_t grpId, uint8_t electionState){
		uint16_t grAddr;
		grAddr = findGroupAddr(grpId);
		dbg(APPNAME,"VM::setGrpElctState():grpId=%d, grAddr=%d, state=%d\n",grpId,grAddr,electionState);
		if (grAddr==0) return FALSE;
		setMVal(electionState,grAddr+GRD_elState_idx,U32,GRD_elState_tp);
		return TRUE;
	}
	bool setGrpLeader(uint8_t grpId, uint16_t leaderId){
		uint16_t grAddr;
		dbg(APPNAME,"VM::setGrpLeader()\n");
		grAddr = findGroupAddr(grpId);
		dbg(APPNAME,"VM::setGrpLeader():grpId=%d, grAddr=%d\n",grpId,grAddr);
		if (grAddr==0) return FALSE;
		setMVal(leaderId,grAddr+GRD_leader_idx,U32,GRD_leader_tp);
			// Queue the message event
		ExtDataLeader = leaderId;
		if (leaderId==0){
			signal VM.queueEvt(I_LEADER_LOST_ID,grpId,&ExtDataLeader);
			signal VM.queueEvt(I_LEADER_LOST   ,    0,&ExtDataLeader);			
		} else {
			signal VM.queueEvt(I_LEADER_NEW_ID,grpId,&ExtDataLeader);
			signal VM.queueEvt(I_LEADER_NEW   ,    0,&ExtDataLeader);			
		}
		return TRUE;
	}
#endif

	event bool GrCtl.isSameGroup(uint8_t GrId, uint8_t GrParam){
#ifndef ONLY_BSTATION
		bool inGrp=FALSE;
		uint8_t maxHops,grParam=0,electionFlag=0;
		if (getGrpDefValue(GrId,&inGrp,&electionFlag,&grParam,&maxHops) == TRUE){
			dbg(APPNAME,"VM::GrCtl.isSameGroup(): GrID=%d, GrParam=%d, is?=%s\n",GrId,GrParam,(inGrp && (GrParam == grParam))?"true":"false");
			return (inGrp && (GrParam == grParam));
		} else {
			dbg(APPNAME,"VM::GrCtl.isSameGroup(): GrID=%d, GrParam=%d, is?=%s\n",GrId,GrParam,"false");
			return FALSE;			
		}
#endif
	}


	event bool GrCtl.chkElection(uint8_t GrId, uint8_t GrParam){
#ifndef ONLY_BSTATION
		bool inGrp=FALSE;
		uint8_t maxHops,grParam=0,electionFlag=0;
		dbg(APPNAME,"VM::MSG.chkElection(%d)\n",GrId);
		if (signal VM.getHaltedFlag() == TRUE) return FALSE;
		if (getGrpDefValue(GrId,&inGrp,&electionFlag,&grParam,&maxHops) == TRUE){
			return ((electionFlag!=ELCT_OFF) && inGrp && GrParam == grParam);
		} else {
			return FALSE;			
		}
#endif
	}
	
	event void GrCtl.evtReady(uint8_t Id, uint8_t* msgData, uint8_t grId, uint16_t reqId){
#ifndef ONLY_BSTATION
		uint8_t EvtId;
		EvtId = (uint8_t)((Id & 0x07) | TID_MSG_REC);
		dbg(APPNAME,"VM::GrCtl.evtReady(): EvtId=%d[%d], grId=%d, reqId=%d\n",EvtId,Id,grId,reqId);
		if (signal VM.getHaltedFlag() == TRUE) return;		
		// Save data value in temp global ext_data
		ExtDataRecGR.evtId = Id;
		ExtDataRecGR.grId = grId;
		ExtDataRecGR.node = reqId;
		memcpy(ExtDataRecGR.Data,msgData,SEND_DATA_SIZE);
		// Queue the message event
		signal VM.queueEvt(I_REC_GR_ID,grId,&ExtDataRecGR);
		signal VM.queueEvt(I_REC_GR   ,   0,&ExtDataRecGR);
#endif
	}

	event void GrCtl.aggNewValue(uint8_t aggId, aggReqData_t *retData, uint16_t moteId){
#ifndef ONLY_BSTATION
		dbg(APPNAME,"VM::GrCtl.aggNewValue(): aggId=%d,value=%d\n",retData->aggId,retData->value);
		dbg(APPNAME,"VM::GrCtl.aggNewValue(): retData->aggId(%d)==CurrentAggreg(%d)) && (AggSeq(%d)==retData->aggSeq(%d) , CurrAggData.function(%d)\n",
			retData->aggId,CurrentAggreg,AggSeq,retData->aggSeq,CurrAggData.function);
		if ((retData->aggId==CurrentAggreg) && (AggSeq==retData->aggSeq)){
			switch (CurrAggData.function){
				case AO_AVG: 	agAvgP1(	retData->value); break;
				case AO_SUM: 	agSumP1(	retData->value); break;
				case AO_MAX: 	agMaxP1(	retData->value); break;
				case AO_MIN: 	agMinP1(	retData->value); break;
				case AO_RESERV: agReservP1(	retData->value, moteId); break;
			}			
		}
#endif
	}

#ifndef ONLY_BSTATION

	task void procNextAggReq(){
		aggReqData_t reqData;
		call aggReqQ.read(&reqData);
		call SA.reqSensor(REQ_SOURCE2, reqData.sensorId);		
	}
	task void procNextAggLocalReq(){
		uint8_t sensorId;
		call aggLocalReqQ.read(&sensorId);
		sensorId = (uint8_t)(sensorId & 0x00ff);
		call SA.reqSensor(REQ_SOURCE3, sensorId);	
	}

	event void aggReqQ.dataReady(){
		post procNextAggReq();
	}
	event void aggLocalReqQ.dataReady(){
		post procNextAggLocalReq();
	}
#endif

	event void GrCtl.aggReqValue(uint8_t CodeEvt_id, aggReqData_t *reqData){
#ifndef ONLY_BSTATION
		dbg(APPNAME,"VM::GrCtl.aggReqValue(): aggId=%d, grId=%d, \n",reqData->aggId,reqData->grId);
		call aggReqQ.put(reqData);
#endif
	}

#ifndef ONLY_BSTATION

	void SA_aggReady(uint8_t codeEvt_id){
		aggReqData_t reqData;
		uint8_t grId,maxHops;
		uint8_t grParam,electionFlag;
		bool inGrp;
		call aggReqQ.get(&reqData);
		dbg(APPNAME,"VM::SA.aggReady: aggId=%d, grId=%d, reqMote=%d\n", reqData.aggId, reqData.grId, reqData.reqMote);
		reqData.value=0;
		// get sensor value
		reqData.value = (nx_uint32_t)call SA.readSensor((uint8_t)(codeEvt_id & 0x01f));
		// Send return message to request mote
		grId = (uint8_t)(reqData.grId | (1<<GRND_BIT) | (1<<AGGREG_BIT));
		getGrpDefValue(grId, &inGrp, &electionFlag, &grParam, &maxHops);
		dbg(APPNAME,"VM::SA.aggReady: sendMsg() GRND: grId=%d[%d], grParam=%d, TargetMote=%d \n",grId, grId&0x01f, grParam, reqData.reqMote);
		call GrCtl.sendGR(grId, grParam, maxHops, reqData.reqMote, reqData.aggId, sizeof(aggReqData_t),(uint8_t*)&reqData);
		// Try next request
		if (call aggReqQ.isFree()==FALSE) post procNextAggReq(); 
	}
	void SA_localAggReady(uint8_t codeEvt_id){
		uint16_t qData;
		uint8_t aggId;
		uint32_t value=0;
		call aggLocalReqQ.get(&qData);
		aggId= (uint8_t)(qData>>8);
		dbg(APPNAME,"VM::SA.localAggReady: aggId=%d, vType=%d\n", aggId,CurrAggData.vType);
		if (aggId == CurrentAggreg){
			// get sensor value
			value = call SA.readSensor((uint8_t)(codeEvt_id & 0x01f));
			// Process local aggregation request
			switch (CurrAggData.function){
				case AO_AVG: 	agAvgP1(	value); break;
				case AO_SUM: 	agSumP1(	value); break;
				case AO_MAX: 	agMaxP1(	value); break;
				case AO_MIN: 	agMinP1(	value); break;
				//case AO_RESERV: agReservP1(	value); break; // Ignore local value on RESERV mode
			}			// Try next request
			if (call aggReqQ.isFree()==FALSE) post procNextAggReq();
		}
	}


	uint8_t wd2ceuSensorId(uint8_t wdId){
		switch (wdId & 0x01f){
			case SID_TEMP: return I_TEMP;
			case SID_PHOTO: return I_PHOTO;
			case SID_VOLT: return I_VOLTS;
			case SID_IN1: return I_PORT_A;
			case SID_IN2: return I_PORT_B;
			case SID_INT1: return I_INT_A;
			case SID_INT2: return I_INT_B;
		}
		return 0;
	}

	void SA_vmReady(uint8_t Id){
		uint8_t EvtId;
		EvtId = (uint8_t)((Id & 0x07) | TID_SENSOR_DONE);
		dbg(APPNAME,"VM::SA.evtReady(): Id=%d, EvtId=%d\n",Id,EvtId);
		if (signal VM.getHaltedFlag() == TRUE) return;
		// Queue the sensor event
		signal VM.queueEvt(wd2ceuSensorId(Id), 0, call SA.getDatap(Id));	
	}

 	void SA_voteReady(uint8_t codeEvt_id){
		currVote.lastVote = call SA.readSensor(SID_VOLT);
		dbg(APPNAME,"VM::SA.voteReady(): evt=%d, vote=%d\n",codeEvt_id,currVote.lastVote);
		if (TOS_NODE_ID != currVote.reqMote){
			sendRetVote(currVote.grId,currVote.reqMote,currVote.lastVote);
		} else {
			setCurrMaxVote(currVote.lastVote,TOS_NODE_ID);
		}
	}
#endif
		
	event void SA.Ready(uint8_t reqSource,uint8_t codeEvt_id){
		dbg(APPNAME,"Custom::SA.Ready(): reqSource=%d, codeEvt_id=%d\n",reqSource,codeEvt_id);
#ifndef ONLY_BSTATION
		switch (reqSource) {
			case REQ_SOURCE1 : SA_vmReady(codeEvt_id); break;
			case REQ_SOURCE2 : SA_aggReady(codeEvt_id); break;
			case REQ_SOURCE3 : SA_localAggReady(codeEvt_id); break;
			case REQ_SOURCE4 : SA_voteReady(codeEvt_id); break;
			default:dbg(APPNAME,"Custom::SA.Ready(): reqSource not defined - %d\n",reqSource);
		}
#endif
	}

#ifndef ONLY_BSTATION
	bool getAggDefValue(uint8_t aggId, uint16_t newSeq, uint8_t* grpId, uint16_t* structAddr, uint8_t* type, uint8_t* function, uint8_t* sensorId, uint8_t* compOper,uint32_t* refValue){
		uint16_t agAddr;
		agAddr = findAggregAddr(aggId);
		dbg(APPNAME,"VM::getAggDefValue(): aggId=%d, agAddr=%d\n",aggId,agAddr);
		if (agAddr==0) return FALSE;
		// get aggreg data
		*structAddr = agAddr;
		*type = S32; // Force to use always S32 type var
		*grpId = 	(uint8_t)getMVal(agAddr+AG_grId_idx		,AG_grId_tp);
		*function = (uint8_t)getMVal(agAddr+AG_agOper_idx	,AG_agOper_tp);
		*sensorId= 	(uint8_t)getMVal(agAddr+AG_sensorId_idx	,AG_sensorId_tp);
		*compOper = (uint8_t)getMVal(agAddr+AG_agComp_idx	,AG_agComp_tp);
		*refValue = (uint32_t)getMVal(agAddr+AG_refValue_idx,AG_refValue_tp);
		setMVal(newSeq,agAddr+AG_seq_idx,U32,AG_seq_tp);
		return TRUE;
	}
	
	task void procAggreg(){
		uint8_t grId=0;
		bool inGrp,readLocal;
		uint8_t maxHops,grParam,electionFlag;
		uint32_t aggCtl;
		aggReqData_t reqData;
		
		// Try to dequeue next aggregation
		if (call aggQ.size()==0){
			aggFlag=FALSE;
			return;
		}
		// Start a new aggregation
		AggTotal=0;
		aggFlag=TRUE;
		aggCtl = call aggQ.dequeue();
		CurrentAggreg = (uint8_t)(aggCtl & 0x000000ff);
		// Populate CurrAggData global structure
		CurrAggData.aggSeq = (uint16_t)(aggCtl >> 16);
		getAggDefValue(CurrentAggreg,CurrAggData.aggSeq,&grId, &CurrAggStructAddr,&CurrAggData.vType,&CurrAggData.function,&CurrAggData.sensorId,&CurrAggData.compOper,&CurrAggData.refValue);
		CurrAggData.count=0;
		CurrAggData.countTrue=0;
		CurrAggData.countFalse=0;
		CurrAggData.value = 0;
		
		// Set AggTotal with big positive number in MIN aggregation
		AggTotal = (CurrAggData.function==AO_MIN)?0x7fff:0;
		
		// Populate reqData struct
		reqData.reqMote= TOS_NODE_ID;
		reqData.aggSeq = CurrAggData.aggSeq;
		reqData.grId = grId;
		reqData.aggId = CurrentAggreg;
		reqData.sensorId = CurrAggData.sensorId;
		reqData.vType = CurrAggData.vType;
		reqData.value = 0;
		
		grId = (uint8_t)(grId | 1<<AGGREG_BIT);
		dbg(APPNAME,"VM::procAggreg(): aggId=%d, grId=%d, structAddr=%d, vType=%d\n",CurrentAggreg,grId,CurrAggStructAddr,CurrAggData.vType);
		readLocal = getGrpDefValue(grId, &inGrp, &electionFlag, &grParam, &maxHops);
		dbg(APPNAME,"VM::procAggreg() GR: grId=%d, grParam=%d\n",grId, grParam);
		call GrCtl.aggreg(grId, grParam, maxHops, CurrentAggreg, &reqData);
		// start Aggreg Timeout timer
		call AggTmr.startOneShot(maxHops * AG_DELTA_TIMEOUT);
		// Reads local sensor if is in group
		if (readLocal == TRUE){
			uint16_t qData = CurrAggData.sensorId + (CurrentAggreg<<8);
			call aggLocalReqQ.put(&qData);
			dbg(APPNAME,"VM::procAggreg(): grId=%d, localSensor=%d, CurrentAggreg=%d\n",grId, CurrAggData.sensorId,CurrentAggreg);
		}

	}

	event void AggTmr.fired(){
		uint8_t EvtId;
		if (aggFlag==TRUE){
			switch (CurrAggData.function){
				case AO_AVG: agAvgP2(); break;
				case AO_SUM: agSumP2(); break;
				case AO_MAX: agMaxP2(); break;
				case AO_MIN: agMinP2(); break;
				case AO_RESERV: agReservP2(); break;
			}	

			EvtId = (uint8_t)((CurrentAggreg & 0x07) | TID_AGGREG);
			dbg(APPNAME,"VM::AggTmr.fired(): EvtId=%d[%d]\n",EvtId,CurrentAggreg);
			if (signal VM.getHaltedFlag() == TRUE) return;		
			dbg(APPNAME,"VM::AggTmr.fired() CurrAggStructAddr=%d\n",CurrAggStructAddr);
			dbg(APPNAME,"VM::AggTmr.fired() count=%d, value=%d\n",CurrAggData.count,CurrAggData.value);
			// Save data value to a temp global 'ext_data'
			ExtDataAggDone.agId = EvtId;
			ExtDataAggDone.count = CurrAggData.count;
			ExtDataAggDone.countTrue = CurrAggData.countTrue;
			ExtDataAggDone.countFalse = CurrAggData.countFalse;
			ExtDataAggDone.value = CurrAggData.value;
 			// Queue the message event
			signal VM.queueEvt(I_AGGREG_DONE_ID, EvtId, &ExtDataAggDone);
			signal VM.queueEvt(I_AGGREG_DONE   ,     0, &ExtDataAggDone);
			// Try next aggregation
			post procAggreg();
		}		
	}	
#endif

/* *********************************************************************************
*                         Leader election
\* ********************************************************************************/
#ifndef ONLY_BSTATION

	void removeElectionQ(uint8_t grId){
		uint8_t i, qSize, grIdAux;
		qSize = call electionQ.size();
		dbg(APPNAME,"VM::removeElectionQ: grId=%d, QSize before:%d\n",grId,qSize);
		for (i=0; i < qSize; i++){
			grIdAux = call electionQ.dequeue();
			dbg(APPNAME,"VM::removeElectionQ: grIdAux=%d\n",grIdAux);
			if ((grIdAux & 0x1f) != (grId & 0x1f)) call electionQ.enqueue(grIdAux);
		}
		qSize = call electionQ.size();
		dbg(APPNAME,"VM::removeElectionQ: grId=%d, QSize after:%d\n",grId,qSize);
	}

	void setCurrMaxVote(uint16_t vote,uint16_t mote){
		dbg(APPNAME,"VM::setCurrMaxVote()\n");
		if (vote > currElection.maxVote){
			currElection.maxVote = vote;
			currElection.moteVote = mote;	
		} else {
			if ((vote == currElection.maxVote) && (mote > currElection.moteVote)){
				currElection.moteVote = mote;			
			}
		}
		dbg(APPNAME,"VM::setCurrMaxVote():mote:%d, vote=%d - max=%d from mote %d\n",mote,vote,currElection.maxVote,currElection.moteVote);
	}

	void setElectionState(uint8_t grId,uint8_t state){
		dbg(APPNAME,"VM::setElectionState: grID=%d, state=%d\n",grId,state);
		setGrpElctState(grId,state);
	}
	void setElectionLeader(uint8_t grId,uint16_t leader){
		dbg(APPNAME,"VM::setElectionLeader: grId=%d, leader=%d\n",grId,leader);
		setGrpLeader(grId,leader);
	}
	uint16_t getElectionLeader(uint8_t grId){
		uint16_t grAddr;
		grAddr = findGroupAddr(grId);
		dbg(APPNAME,"VM::getElectionLeader():grpId=%d, grAddr=%d\n",grId,grAddr);
		if (grAddr==0) return 0;
		dbg(APPNAME,"VM::getElectionLeader(): grId=%d, leader%d\n",grId,getMVal(grAddr+GRD_leader_idx,GRD_leader_tp));
		return (uint16_t)getMVal(grAddr+GRD_leader_idx,GRD_leader_tp);
	}

	void readElectionVote(uint8_t grId, uint16_t reqMote){
		dbg(APPNAME,"VM::readElectionVote: grId=%d, reqMote=%d\n",grId,reqMote);
		currVote.grId=grId;
		currVote.reqMote = reqMote;
		call SA.reqSensor(REQ_SOURCE4, SID_VOLT);		
	}


	void sendElectionXX(uint8_t Id, uint8_t GRND, uint16_t toMote, uint8_t evt, uint16_t newLeader, uint16_t vote){
		leaderData_t data;
		uint8_t grId;
		bool inGrp; uint8_t electionFlag; uint8_t grParam; uint8_t maxHops;
		dbg(APPNAME,"VM::sendElectionXX: grId=%d(%d), evt=%d\n",Id,(uint8_t)(Id & 0x01f),evt);
		data.grId = (uint8_t)(Id & 0x01f);
		getGrpDefValue(data.grId, &inGrp, &electionFlag, &grParam, &maxHops);
		data.senderId = TOS_NODE_ID;
		data.param=grParam;
		data.newLeader=newLeader;
		data.vote=vote;
		grId = (uint8_t)(data.grId | 1<<ELECTION_BIT | GRND<<GRND_BIT) ; // Election=1. GR[0]/GRND[1]. AGGREG=0.
		call GrCtl.sendGR(grId, grParam, maxHops, toMote, evt, sizeof(leaderData_t),(uint8_t*)&data);
	}

	void sendReqLeader(uint8_t Id){sendElectionXX(Id,0,0,EEVT_REQ_LEADER_ID,0,0);}
	void sendRetLeader(uint8_t Id, uint16_t toMote){sendElectionXX(Id,1,toMote,EEVT_RET_LEADER_ID,TOS_NODE_ID,0);}
	void sendRetVote(uint8_t Id, uint16_t toMote, uint16_t vote){sendElectionXX(Id,1,toMote,EEVT_RET_VOTE_ID,0,vote);}
	void sendInitElection(uint8_t Id){sendElectionXX(Id,0,0,EEVT_INIT_ELECTION_ID,0,0);}
	void sendSetLeader(uint8_t Id, uint16_t toMote){sendElectionXX(Id,1,toMote,EEVT_SET_LEADER_ID,toMote,0);}
	void sendNewLeader(uint8_t Id){sendElectionXX(Id,0,0,EEVT_NEW_LEADER_ID,TOS_NODE_ID,0);}

	uint32_t getElectionTimeOut(uint8_t grId){
		bool inGrp; uint8_t electionFlag; uint8_t grParam; uint8_t maxHops;
		getGrpDefValue(grId, &inGrp, &electionFlag, &grParam, &maxHops);
		return (maxHops*ELCT_DELTA_TIMEOUT + 300);
	}

	
	task void procLeaderQ(){
		uint8_t grId;
		uint32_t delay;
		dbg(APPNAME,"VM::procLeaderQ:\n");
		if (call electionQ.size()<=0) return;
		// Dequeue grId
		grId = call electionQ.dequeue();
		// Set global current election data
		currElection.grId = (uint8_t)(grId & 0x1f);
		currElection.maxVote = 0; currElection.moteVote=0;
		delay = ((call Random.rand32() & 0x0f) * 100);
		dbg(APPNAME,"VM::procLeaderQ: grId=%d(%d), delay=%d\n",grId,(grId&0x1f),delay);
		// Process init/renew operation
		if ((grId & 1<<ELCT_INIT_BIT)>1){ // initLeader
			setElectionState(grId,EST_NEWRUN);
		} else { // renewLeader
			setElectionState(grId,EST_RENEW);
		}
		call ElectionTmr.startOneShot(delay);		
	}


	task void firstElection(){
		// queue all groups id to process initLeader (bit=1)
		queueLeaderProc(1);
		// re-start renew election periodic timer
		call renewTmr.startPeriodic(ELCT_RENEW_TIMEOUT);
	}
	void tryFirstElection(){
		dbg(APPNAME,"VM::tryFirstElection: firstElectionPend=%s\n",_TFstr(firstElectionPend));
		if (firstElectionPend) post firstElection();
		firstElectionPend = FALSE;
	}

	void queueLeaderProc(uint8_t bitValue){
		uint8_t n;
		groupCtl_t* next_ = firstGrp;
		uint8_t electionFlag, electionState;

		dbg(APPNAME,"VM::queueLeaderProc():  countGrp=%d, firstGrp = %x\n",countGrp,(uint16_t)firstGrp);
		for (n=0; n < countGrp; n++){
			// Test if leader is enabled and queue a init/review Leader evt.
			dbg(APPNAME,"VM::queueLeaderProc(): n=%d of %d, Id=%d, bitValue=%d\n",n,countGrp,next_->grId,bitValue);
			getGrpElctState(next_->grId, &electionFlag, &electionState);
			dbg(APPNAME,"VM::queueLeaderProc(): n=%d of %d, Id=%d, bitValue=%d, electionFlag=%d\n",n,countGrp,next_->grId,bitValue,electionFlag);
			if (electionFlag!=ELCT_OFF){
				removeElectionQ(next_->grId);
				call electionQ.enqueue((uint8_t)(next_->grId | (bitValue<<ELCT_INIT_BIT)));
			}
			next_ = (void*)signal VM.getRealAddr(next_->nextGrp);
		}
		post procLeaderQ();
	}
	
	event void ElectionTmr.fired(){
		uint8_t electionFlag; uint8_t state;
		dbg(APPNAME,"VM::ElectionTmr.fired:\n");
		if (getGrpElctState(currElection.grId, &electionFlag, &state) == TRUE){
			switch (state){
				case EST_NEWRUN:
					sendReqLeader(currElection.grId);
					setElectionState(currElection.grId,EST_REQUESTED);
					setElectionLeader(currElection.grId,0);
					call ElectionTmr.startOneShot(getElectionTimeOut(currElection.grId));						
					break;
				case EST_RENEW:
					sendInitElection((uint8_t)(currElection.grId & 0x1f));
					setElectionState(currElection.grId,EST_ELECTING);
					setElectionLeader(currElection.grId,0);
					getGrpElctState(currElection.grId, &electionFlag, &state);
					if (electionFlag != ELCT_ACTIVE){
						setCurrMaxVote(0,TOS_NODE_ID);
					} else {
						readElectionVote(currElection.grId,TOS_NODE_ID);
					}
					call ElectionTmr.startOneShot(getElectionTimeOut(currElection.grId));						
					break;
				case EST_REQUESTED : 
					removeElectionQ(currElection.grId);
					call electionQ.enqueue((uint8_t)(currElection.grId));
					post procLeaderQ();
					break;
				case EST_ELECTING : 
					if (currElection.moteVote != TOS_NODE_ID){
						sendSetLeader(currElection.grId,currElection.moteVote);
						call ElectionTmr.startOneShot(getElectionTimeOut(currElection.grId));						
					} else {
						sendNewLeader(currElection.grId);
						//call ElectionTmr.stop();
						setElectionState(currElection.grId,EST_OK);
						setElectionLeader(currElection.grId,TOS_NODE_ID);
						removeElectionQ(currElection.grId);
						post procLeaderQ();					
					}		
					break;
				case EST_VOTING : 
					sendReqLeader(currElection.grId);
					setElectionState(currElection.grId,EST_REQUESTED);
					setElectionLeader(currElection.grId,0);
					call ElectionTmr.startOneShot(getElectionTimeOut(currElection.grId));		
					break;				
			}
		}
	}

	event void renewTmr.fired(){
		// queue all groups id to process reviewLeader (bit=0)
		queueLeaderProc(0);
	}
#endif

	event void GrCtl.electionMsg(uint8_t CodeEvt_id, leaderData_t* recData){
#ifndef ONLY_BSTATION
		uint8_t electionFlag; uint8_t state;
		dbg(APPNAME,"VM::GCTL.electionMsg: evt=%d\n",CodeEvt_id);	
		getGrpElctState(recData->grId, &electionFlag, &state);
		if (electionFlag == ELCT_OFF) return;
		switch (CodeEvt_id){
			case EEVT_REQ_LEADER_ID :
				if ((electionFlag == ELCT_ACTIVE) && (state == EST_OK) && (TOS_NODE_ID == getElectionLeader(recData->grId))){
					sendRetLeader(recData->grId,recData->senderId);
				}
				break;
			case EEVT_RET_LEADER_ID : 
				if (state == EST_REQUESTED)
				if (currElection.grId == recData->grId){
					//call ElectionTmr.stop();
					setElectionLeader(recData->grId,recData->newLeader);
					setElectionState(recData->grId,EST_OK);
					removeElectionQ(recData->grId);
					post procLeaderQ();
				} else {
					dbg(APPNAME,"VM::GCTL.electionMsg: evt=%d, Current grId=%d <> msg grId=%d\n",CodeEvt_id,currElection.grId,recData->grId);
				}
				break;
			case EEVT_INIT_ELECTION_ID : 
				if (currElection.grId == recData->grId){
					if (((state == EST_ELECTING) && (TOS_NODE_ID < recData->senderId)) || ((state != EST_ELECTING) && (state != EST_VOTING))){
						if (electionFlag == ELCT_ACTIVE){
							readElectionVote(recData->grId,recData->senderId);
						} else {
							sendRetVote(recData->grId,recData->senderId,0);
						}
						setElectionState(recData->grId,EST_VOTING);
						call ElectionTmr.stop();
						call ElectionTmr.startOneShot(getElectionTimeOut(currElection.grId));
					} else {
						if (state == EST_VOTING){
							if (electionFlag == ELCT_ACTIVE){
								sendRetVote(recData->grId,recData->senderId,currVote.lastVote);
							} else {
								sendRetVote(recData->grId,recData->senderId,0);
							}
							call ElectionTmr.stop();
							call ElectionTmr.startOneShot(getElectionTimeOut(currElection.grId));
						}
					}
				} else {
					if (electionFlag == ELCT_ACTIVE){
						readElectionVote(recData->grId,recData->senderId);
					} else {
						sendRetVote(recData->grId,recData->senderId,0);
					}
				}
				break;
			case EEVT_RET_VOTE_ID : 
				if (currElection.grId == recData->grId){
					if (state == EST_ELECTING) {
						setCurrMaxVote(recData->vote,recData->senderId);
					}			
				}
				break;
			case EEVT_SET_LEADER_ID :
				if (currElection.grId == recData->grId){
					if ((electionFlag == ELCT_ACTIVE) && (state == EST_VOTING)){
						sendNewLeader(recData->grId);
						//call ElectionTmr.stop();
						setElectionState(recData->grId,EST_OK);
						setElectionLeader(recData->grId,TOS_NODE_ID);
						removeElectionQ(recData->grId);
						post procLeaderQ();
					}
				} else {
					sendNewLeader(recData->grId);
					//call ElectionTmr.stop();
					setElectionState(recData->grId,EST_OK);
					setElectionLeader(recData->grId,TOS_NODE_ID);
					removeElectionQ(recData->grId);
					post procLeaderQ();
				}
				break;
			case EEVT_NEW_LEADER_ID :
				if (TOS_NODE_ID != recData->newLeader){
					//call ElectionTmr.stop();
					setElectionState(recData->grId,EST_OK);
					setElectionLeader(recData->grId,recData->newLeader);
					removeElectionQ(recData->grId);
					post procLeaderQ();
				}
				break;			
		}
#endif
	}
	
#ifndef ONLY_BSTATION
	/**************************************************************************
	 * Aggregation internal functions
	 **************************************************************************/

	/**
	 * Generic counting function
	 * Count TRUE and FALSE for (Value .compOper. RefValue)
	 */ 
	void countTrueFalse(uint32_t Value){
		if(CurrAggData.vType <= U32){
			switch (CurrAggData.compOper){
				case COMP_LT : ((uint32_t)Value <  (uint32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_LTE: ((uint32_t)Value <= (uint32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_GT : ((uint32_t)Value >  (uint32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_GTE: ((uint32_t)Value >= (uint32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_EQ : ((uint32_t)Value == (uint32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_NEQ: ((uint32_t)Value != (uint32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
			}
		} else {
			switch (CurrAggData.compOper){
				case COMP_LT : (( int32_t)Value <  ( int32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_LTE: (( int32_t)Value <= ( int32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_GT : (( int32_t)Value >  ( int32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_GTE: (( int32_t)Value >= ( int32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_EQ : (( int32_t)Value == ( int32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
				case COMP_NEQ: (( int32_t)Value != ( int32_t)CurrAggData.refValue)?CurrAggData.countTrue++:CurrAggData.countFalse++; break;
			}
		}		
	}

	/**
	 * Average
	 */
	void agAvgP1(uint32_t Value){
		dbg(APPNAME,"VM::agAvgP1(): value=%d\n",Value);
		CurrAggData.count++;
			if(CurrAggData.vType <= U32){
				*(uint32_t*)&AggTotal = (uint32_t)((uint32_t)AggTotal + (uint32_t)Value);
			} else {
				*( int32_t*)&AggTotal = ( int32_t)(( int32_t)AggTotal + ( int32_t)Value);
			}
		countTrueFalse(Value);
	}
	void agAvgP2(){
		dbg(APPNAME,"VM::agAvgP2(): Total=%d, count=%d\n",AggTotal,CurrAggData.count);
		if (CurrAggData.count>0) {
			if(CurrAggData.vType <= U32){
				*(uint32_t*)&CurrAggData.value = (uint32_t)(*(uint32_t*)&AggTotal / CurrAggData.count);
			} else {
				*( int32_t*)&CurrAggData.value = ( int32_t)(*( int32_t*)&AggTotal / CurrAggData.count);
			}
		} else {
			CurrAggData.value = 0;
		}
	}

	
	/**
	 * Summation
	 */
	void agSumP1(uint32_t Value){
		dbg(APPNAME,"VM::agSumP1(): value=%d\n",Value);
		CurrAggData.count++;
		if(CurrAggData.vType <= U32){
			*(uint32_t*)&AggTotal = (uint32_t)((uint32_t)AggTotal + (uint32_t)Value);
		} else {
			*( int32_t*)&AggTotal = ( int32_t)(( int32_t)AggTotal + ( int32_t)Value);
		}
		countTrueFalse(Value);
	}
	void agSumP2(){
		dbg(APPNAME,"VM::agSumP2():\n");
		CurrAggData.value = AggTotal;
	}
	
	/**
	 * Maximum
	 */
	void agMaxP1(uint32_t Value){
		dbg(APPNAME,"VM::agMaxP1(): value=%d\n",Value);
		CurrAggData.count++;
		if(CurrAggData.vType <= U32){
			*(uint32_t*)&AggTotal = ((uint32_t)AggTotal < (uint32_t)Value)?Value:AggTotal;
		} else {
			*( int32_t*)&AggTotal = (( int32_t)AggTotal < ( int32_t)Value)?Value:AggTotal;
		}
		countTrueFalse(Value);
	}
	void agMaxP2(){
		dbg(APPNAME,"VM::agMaxP2():\n");
		CurrAggData.value = AggTotal;
	}
	

	/**
	 * Minimum
	 */
	void agMinP1(uint32_t Value){
		dbg(APPNAME,"VM::agMinP1(): value=%d AggTotal=%d\n",Value,AggTotal);
		CurrAggData.count++;
		if(CurrAggData.vType <= U32){
			*(uint32_t*)&AggTotal = ((uint32_t)AggTotal > (uint32_t)Value)?Value:AggTotal;
		} else {
			*( int32_t*)&AggTotal = (( int32_t)AggTotal > ( int32_t)Value)?Value:AggTotal;
		}
		countTrueFalse(Value);
	}
	void agMinP2(){
		dbg(APPNAME,"VM::agMinP2():\n");
		CurrAggData.value = AggTotal;
	}


	/**
	 * Reserv 
	 */
	void agReservP1(uint32_t Value, uint16_t moteId){
		dbg(APPNAME,"VM::agReservP1(): value=%d\n",Value);
		CurrAggData.count++;
		countTrueFalse(Value);
		if (((uint16_t)AggTotal==0)&&((uint16_t)CurrAggData.countTrue>0)){
			AggTotal=moteId;
		}
	}
	void agReservP2(){
		dbg(APPNAME,"VM::agReservP2():\n");
		CurrAggData.value = AggTotal;
		CurrAggData.countFalse = CurrAggData.count - CurrAggData.countTrue;
	}	

#endif // ONLY_BSTATION 


}