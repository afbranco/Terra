/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#ifndef VMCUSTOM_H
#define VMCUSTOM_H

#include "../../../VMData.h"
#include "../../../TerraVM.h"

enum{
	
	//AM_SENDBS 			= 150, It is defined in "BasicServices.h"
	AM_SENDGR 			= 140,
	AM_SENDGRND 		= 141,
	
#ifdef SHORT_QUEUES
	AGG_QUEUE_SIZE = 3,
	ELCT_QUEUE_SIZE = 3,
	AGGREQ_QUEUE_SIZE = 3,
	NHOPS_LIST_SIZE = 20,
#else
	AGG_QUEUE_SIZE = 8,
	ELCT_QUEUE_SIZE = 32,
	AGGREQ_QUEUE_SIZE = 5,
	NHOPS_LIST_SIZE = 90,
#endif
	
	// TerraGrp local Output events
//	O_INIT			=0,
	O_LEDS			=5,
	O_LED0			=6,
	O_LED1			=7,
	O_LED2			=8,
	O_TEMP			=9,
	O_PHOTO			=10,
	O_VOLTS			=11,
	O_PORT_A		=12,
	O_PORT_B		=13,
	O_CFG_PORT_A	=14,
	O_CFG_PORT_B	=15,
	O_REQ_PORT_A	=16,
	O_REQ_PORT_B	=17,
	O_CFG_INT_A		=18,
	O_CFG_INT_B		=19,
	O_CUSTOM_A		=20,	
	O_REQ_MIC		=21,	
	O_BEEP			=22,
	O_CUSTOM		=23,
	// TerraGrp custom output events IDs
	O_SEND_BS		=40,
	O_SEND_GR		=41,
	O_AGGREG		=42,	

	// TerraNet Local Input events
//	I_ERROR_id		=0,  // Defined in VMError.h
//	I_ERROR			=1,  // Defined in VMError.h
	I_TEMP			=5, 
	I_PHOTO			=6,
	I_VOLTS			=7,
	I_PORT_A		=8,
	I_PORT_B		=9,
	I_INT_A			=10,
	I_INT_B			=11,
	I_CUSTOM_A_ID	=12,
	I_CUSTOM_A		=13,
	I_MIC			=14,
	I_CUSTOM		=15,
	// TerraGrp custom input events IDs
	I_REC_GR_ID		=40,
	I_REC_GR		=41,
	I_SENDBS_DONE_ID=42,
	I_SENDBS_DONE	=43,
	I_AGGREG_DONE_ID=44,
	I_AGGREG_DONE	=45,
	I_LEADER_NEW_ID	=46,
	I_LEADER_NEW	=47,
	I_LEADER_LOST_ID=48,
	I_LEADER_LOST	=49,
	I_SENDGR_DONE_ID=50,
	I_SENDGR_DONE	=51,
	
	// TerraNet basic functions
	F_GETNODEID 	= 0,
	F_RANDOM		= 1,
	F_GETMEM		= 2,
	F_GETTIME		= 3,
	// TerraGrp Custom functions
	F_GROUPINIT 	= 10,
	F_AGGREGINIT 	= 11,
	F_SETUP_MIC		= 16,
	F_RFPOWER		= 17,
	F_GETPARENT		= 18,
	
	
	// Event Type ID - 3 msb bits of EvtId
	TID_SENSOR_DONE = 0 << 5,
	TID_TIMER_TRIGGER = 1 << 5,
	TID_MSG_DONE = 2 << 5,
	TID_MSG_REC = 3 << 5,
	TID_NEW_LEADER = 4 << 5,
	TID_LOST_LEADER = 5 << 5,
	TID_LOCAL_EVENT = 6 << 5,
	TID_AGGREG = 7 << 5,
		
	// Sensor IDs (max 31)
	SENSOR_COUNT = 10,
	SID_TEMP = 1,
	SID_PHOTO = 2,
	SID_LEDS = 3,
	SID_VOLT = 4,
	SID_IN1 = 5,
	SID_IN2 = 6,
	SID_INT1 = 7,
	SID_INT2 = 8,
	SID_MIC = 9,


	// Comparison operators type (Group definition and Trigger Value)
	COMP_LT  = 1,		// "<"
	COMP_LTE = 2,		// "<="
	COMP_GT  = 3,		// ">"
	COMP_GTE = 4,		// ">="
	COMP_EQ  = 5,		// "=="
	COMP_NEQ = 6,		// "!="

	/*
	 * Aggregation function types (AO-Aggregation Operation)
	 */
	AO_AVG = 0,		// Average
	AO_SUM = 1,		// Summation
	AO_MAX = 2,		// Maximum value
	AO_MIN = 3,		// Minimum value
	AO_RESERV = 5,	// Resource Reservation
	AO_CUSTOM=99,	// Custom operation (Not defined yet!)

	// Timer operations
	TMR_START_PERIODIC = 1,
	TMR_START_ONESHOT  = 2,
	TMR_STOP 		   = 3,
	
	// SetGroup Operations
	SET_GR_IN_GROUP 	= 1,
	SET_GR_OUT_GROUP	= 2,
	SET_GR_ACTIVE_ELECTION  = 3,
	SET_GR_PASSIVE_ELECTION = 4,
	SET_GR_OFF_ELECTION = 5,
	
	// Election Flags
	ELCT_ACTIVE = 1,
	ELCT_PASSIVE = 2,
	ELCT_OFF = 3,
	// Election bits
	ELCT_INIT_BIT = 7,

	// Election event IDs
	EEVT_REQ_LEADER_ID 		= 1,
	EEVT_RET_LEADER_ID 		= 2,
	EEVT_INIT_ELECTION_ID 	= 3,
	EEVT_RET_VOTE_ID 		= 4,
	EEVT_SET_LEADER_ID 		= 5,
	EEVT_NEW_LEADER_ID 		= 6,

	// Election States
	EST_OUT			= 1,
	EST_OK			= 2,
	EST_REQUESTED 	= 3,
	EST_ELECTING	= 4,
	EST_VOTING		= 5,
	EST_NEWRUN		= 6,
	EST_RENEW		= 7,
	
	// Msg BS Structure
	MBS_SIZE=17,
	MBS_msgId_idx=0,	MBS_msgId_len=1,
	MBS_usrData_idx=1,	MBS_usrData_len=16,

	// Msg GR/GRND Structure
	MGR_SIZE=20,
	MGR_msgId_idx=0,	MGR_msgId_len=1,
	MGR_grId_idx=1,		MGR_grId_len=1,
	MGR_node_idx=2,		MGR_node_len=2,
	MGR_usrData_idx=4,	MGR_usrData_len=16,

	// GroupData structure
	GRD_SIZE = 8, 
	GRD_id_idx = 0,		GRD_id_len = 1,			GRD_id_tp = U8,
	GRD_param_idx = 1,	GRD_param_len = 1,		GRD_param_tp = U8,
	GRD_nHops_idx = 2,	GRD_nHops_len = 1,		GRD_nHops_tp = U8,
	GRD_status_idx = 3,	GRD_status_len = 1,		GRD_status_tp = U8,
	GRD_elFlag_idx = 4,	GRD_elFlag_len = 1,		GRD_elFlag_tp = U8,
	GRD_elState_idx = 5,GRD_elState_len = 1,	GRD_elState_tp = U8,
	GRD_leader_idx = 6,	GRD_leader_len = 2,		GRD_leader_tp = U16,
	GRD_nextGrp_idx =8,	GRD_nextGrp_len = 2,	GRD_nextGrp_tp = U16,
	
	// group Flag bits/mask
	GR_ENABLED_BIT = 5, 
	GR_ENABLED_MASK = 0x01, 
	GR_ELECTION_BIT = 6, 
	GR_ELECTION_MASK = 0x03, 
	
	// Events and event vars spaces
	EVT_SIZE = 3, // evtId:1 + fAddr:2
	EVTVARS_SIZE = 4, // evtId:1 + vType/structFlag:1 + vAddr/strAddr:2

	// Timer vars spaces
	TMRD_SIZE = 3, // tmrId:1 + period:2
	TMRD_value_idx = 1,
	
	// SendMsg target types
	SM_BS = 1,
	SM_GR = 2,
	SM_GRND = 3,

	// Group ID - sendGR/sendGRND bit (start at 0))
	GRND_BIT = 5,
	// Group ID - Aggreg:sendGR/sendGRND bit
	AGGREG_BIT = 6,
	// Group ID - Aggreg:sendGR/sendGRND bit
	ELECTION_BIT = 7,

	// AggData Structure field indexes
	AG_SIZE = 11,
	AG_agId_idx = 0,		AG_agId_len = 1,	AG_agId_tp = U8,
	AG_seq_idx = 1,			AG_seq_len = 2,		AG_seq_tp = U16,
	AG_grId_idx = 3,		AG_grId_len = 1,	AG_grId_tp = U8,
	AG_sensorId_idx = 4,	AG_sensorId_len = 1,AG_sensorId_tp = U8,
	AG_agOper_idx = 5,		AG_agOper_len = 1,	AG_agOper_tp = U8,
	AG_agComp_idx = 6,		AG_agComp_len = 1,	AG_agComp_tp = U8,
	AG_refValue_idx = 7,	AG_refValue_len = 4,AG_refValue_tp = S32,
	AG_nextAgg_idx = 11,	AG_nextAgg_len = 2,	AG_nextAgg_tp = U16,
	
	AGD_SIZE = 11,
	AGD_agId_idx = 0,		AGD_agId_len=1,			AGD_agId_tp = U8,
	AGD_count_idx = 1,		AGD_count_len=2,		AGD_count_tp = U16,
	AGD_countTrue_idx = 3,	AGD_countTrue_len=2,	AGD_countTrue_tp = U16,
	AGD_countFalse_idx= 5,	AGD_countFalse_len=2,	AGD_countFalse_tp = U16,
	AGD_value_idx=7,		AGD_value_len=4,		AGD_value_tp = S32,
	
	// Aggregation timeout
	AG_DELTA_TIMEOUT = 200,
	// Election timeout
	ELCT_DELTA_TIMEOUT = 200,
	// Renew Leader (re-election timeout)
	ELCT_RENEW_TIMEOUT = 1000L * 60L * 5L, // 30 min = 1000 * 60 * 30 
	
};

/*
 * Data/Msg structure definitions
 */
 
// Group control structure
typedef nx_struct groupCtl {
	nx_uint8_t   grId;
	nx_uint8_t  param;
	nx_uint8_t   nhops;
	nx_uint8_t   status;
	nx_uint8_t   elFlag;
	nx_uint8_t   elState;
	nx_uint16_t  leader;
	nx_uint16_t	 nextGrp;
} groupCtl_t;

// Aggregation control structure
typedef nx_struct aggregCtl {
	nx_uint8_t   agId;
	nx_uint16_t  seq;
	nx_uint8_t   grId;
	nx_uint8_t   sensorId;
	nx_uint8_t   agOper;
	nx_uint8_t   agComp;
	nx_uint32_t  refVal;	
	nx_uint16_t	 nextAgg;
} aggregCtl_t;

typedef nx_struct aggDone{
	nx_uint8_t  agId;
	nx_uint16_t count;
	nx_uint16_t countTrue;
	nx_uint16_t countFalse;
	nx_uint32_t  value;
} aggDone_t;

typedef struct aggData{
	uint16_t aggSeq;
	uint8_t sensorId;
	uint8_t function;
	uint8_t compOper;
	uint8_t vType;
	uint32_t refValue;
	uint16_t count;
	uint16_t countTrue;
	uint16_t countFalse;
	uint32_t value;
} aggData_t;

typedef nx_struct aggReqData{
	nx_uint16_t reqMote;
	nx_uint16_t aggSeq;
	nx_uint8_t grId;
	nx_uint8_t aggId;
	nx_uint8_t sensorId;
	nx_uint8_t vType;
	nx_uint32_t value;
} aggReqData_t;

typedef nx_struct leaderData{
	nx_uint16_t senderId;
	nx_uint8_t  grId;
	nx_uint8_t  param;
	nx_uint16_t newLeader;
	nx_uint16_t vote;
} leaderData_t;

typedef struct currElectionData{
	uint8_t grId;
	uint16_t maxVote;
	uint16_t moteVote;
	
} currElectionData_t;

typedef struct currVoteData{
	uint8_t grId;
	uint16_t reqMote;
	uint16_t lastVote;
} currVoteData_t;

typedef nx_struct usrSendGR{		
	// Group/[mote] definitions  
	nx_uint8_t  grId; // Group ID[b0..4] + TargetBit[b5]
	nx_uint16_t node; // To a specific target mote in group or the sender when received
	// Msg Definition  
	nx_uint8_t  evtId; // Event ID
	nx_int8_t  Data[SEND_DATA_SIZE]; // Data buffer
} usrSendGR_t;	

typedef nx_struct sendGR{		
	nx_uint16_t  ReqMote; // Request Mote Id
	nx_uint16_t ReqSeq; // Request sequential Id
	nx_uint8_t  MaxHops; // Max hops
	nx_uint8_t  HopNumber; // Hops count (current step)
	
	// Group/[mote] definitions  
	nx_uint8_t  grId; // Group ID[b0..4] + TargetBit[b5]
	nx_uint8_t  grParam; // Group ID parameter
	nx_uint16_t  TargetMote; // To a specific target mote in group
	// Msg Definition  
	nx_uint8_t  evtId; // Event ID
	nx_int8_t  Data[SEND_DATA_SIZE]; // Data buffer
} sendGR_t;	


typedef nx_struct usrSendBS{	
	nx_uint8_t  evtId; // Event ID
	nx_int8_t  Data[SEND_DATA_SIZE]; // Data buffer
} usrSendBS_t;	


// Control list to avoid duplicated events
typedef nx_struct receivedList {
	nx_uint8_t nextPos;
	nx_uint16_t TargetMote[NHOPS_LIST_SIZE];	// Target Mote Id
	nx_uint16_t PrevMote[NHOPS_LIST_SIZE];	// Request Mote Id
	nx_uint16_t RequestNumber[NHOPS_LIST_SIZE];	// Request sequential Id	
} NHopsList_t;


#endif /* VMCUSTOM_H */
