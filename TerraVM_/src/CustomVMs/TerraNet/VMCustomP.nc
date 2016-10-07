/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#include "VMCustomNet.h"
#include "usrMsg.h"
#include "BasicServices.h"
#include "SensAct.h"

module VMCustomP{
	provides interface VMCustom as VM;
	uses interface BSRadio;
	uses interface SensAct as SA;
	uses interface Random;
#ifdef M_FFT
	uses interface kissFFT as KF;
#endif
#ifdef M_VCN_DAT
    uses interface ReadStream<nx_int32_t>;
    uses interface Set<uint32_t> as SetSensorRtime;
    uses interface Get<uint32_t> as GetSensorRtime;
    uses interface BlockRead as GModelBlockRead;
#endif
#ifdef M_MSG_QUEUE
	// usrMsg queue
	uses interface dataQueue as usrDataQ;
#endif
}
implementation{

// Keeps last data value for events (ExtDataxxx must be nx_ type. Because it is copied direct to VM memory.)
nx_uint8_t ExtDataSysError;				// last system error code
nx_uint8_t ExtDataCustomA;				// last request custom event (internal loop-back)
usrMsg_t ExtDataRadioReceived;	// last radio received msg
nx_uint8_t ExtDataSendDoneError;
nx_uint8_t ExtDataWasAcked;
nx_uint8_t ExtDataQReady;			// last queue ready - queue size 
nx_uint32_t ExtDataTimeStamp;		// last SLPL_FIRED - timestamp 
nx_uint8_t ExtDataGModelRdDone;		// last GModelReadDone Status 
nx_uint16_t ExtDataBufferRdDone;	// last StreamReadDone [error=0 | Count>0]
nx_int32_t* UsrStreamBuffer;		// Pointer to user data stream buffer

uint8_t MIC_flag;					// Indicate if Mic Sensor was setup
nx_uint16_t* MIC_buf;				// Mic Sensor read buffer
uint16_t MIC_count;				// Mic Sensor read count
uint32_t MIC_usPeriod;			// Mic Sensor read period
uint8_t MIC_gain;				// Mic Sensor gain adjust

/*
 * Output Events implementation
 */

void  proc_leds(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_leds(): id=%d, val=%d\n",id,(uint8_t)value);
	call SA.setActuator(AID_LEDS, (uint8_t)(value & 0x07));
}
void  proc_led0(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led0(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED0_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED0, (uint8_t)(value & 0x01));
}
void  proc_led1(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led1(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED1_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED1, (uint8_t)(value & 0x01));
}
void  proc_led2(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_led2(): id=%d, value=%d\n",id,(uint8_t)value);
	if (value > 1) 
		call SA.setActuator(AID_LED2_TOGGLE, (uint8_t)(value & 0x07));
	else
		call SA.setActuator(AID_LED2, (uint8_t)(value & 0x01));
}
void  proc_req_temp(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_temp(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_TEMP);
	}
void  proc_req_photo(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_photo(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_PHOTO);
	}
void  proc_req_volts(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_volts(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_VOLT);
	}

void  proc_send_x(uint16_t id,uint16_t addr,uint8_t ack){
	usrMsg_t* usrMsg;
	uint8_t reqRetryAck;
	usrMsg = (usrMsg_t*)signal VM.getRealAddr(addr);
	dbg(APPNAME,"Custom::proc_sendx(): id=%d, target=%d, addr=%d, realAddr=%x, ack=%d\n",
		id,usrMsg->target,addr,usrMsg, ack);
	reqRetryAck = (ack)?(1<<REQ_ACK_BIT):0; // Define only ack without retry.
	call BSRadio.send(AM_USRMSG,usrMsg->target, usrMsg, sizeof(usrMsg_t),reqRetryAck);
}

void  proc_send(uint16_t id, uint32_t addr){
	proc_send_x(id,(uint16_t)addr,FALSE);
	}
void  proc_send_ack(uint16_t id, uint32_t addr){
	proc_send_x(id,(uint16_t)addr,TRUE);
	}


void  proc_set_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_set_port_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_OUT1, (uint8_t)(value & 0x01));
}
void  proc_set_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_set_port_b(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_OUT2, (uint8_t)(value & 0x01));
}
void  proc_cfg_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_port_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_PIN1, (uint8_t)(value & 0x01));
}
void  proc_cfg_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_port_b(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_PIN2, (uint8_t)(value & 0x01));
}
void  proc_req_port_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_port_a(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_IN1);
	}
void  proc_req_port_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_port_b(): id=%d\n",id);
	call SA.reqSensor(REQ_SOURCE1,SID_IN2);
	}
void  proc_cfg_int_a(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_int_a(): id=%d, value=%d\n",id,value);
	call SA.setActuator(AID_INT1, (uint8_t)value);
	}
void  proc_cfg_int_b(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_cfg_int_b(): id=%d value=%d\n",id,value);
	call SA.setActuator(AID_INT2, (uint8_t)value);
	}
void  proc_req_custom_a(uint16_t id, uint32_t value){
	uint8_t auxId ;
	ExtDataCustomA = (uint8_t)value;
	dbg(APPNAME,"Custom::proc_req_custom_a(): id=%d, ExtDataCustomA=%d\n",id,ExtDataCustomA);
	auxId = (uint8_t)value;//(uint8_t)signal VM.pop();
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


#ifdef M_VCN_DAT
void  proc_rd_stream(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_rd_stream(): id=%d value=%d\n",id,value);
	UsrStreamBuffer = (nx_int32_t*)signal VM.getRealAddr(value);
	call ReadStream.postBuffer(NULL, 0);
}
#endif

void  proc_req_mic(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_mic(): id=%d, value=%d, MIC Flad=%d\n",id,value, MIC_flag);
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
	#if SBOARD == 300
	if (MIC_flag)
		call SA.reqStreamSensor(REQ_SOURCE1, SID_MIC, (uint16_t*)MIC_buf, MIC_count, MIC_usPeriod, MIC_gain);
	else
		signal VM.evtError(E_NOSETUP);
	#endif
#endif
}

void  proc_beep(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_beep(): id=%d, val=%d\n",id,(uint16_t)value);
	call SA.setActuator(AID_SOUNDER, (uint16_t)value);
}
	
/*
 * Function implementation
 */
void  func_getNodeId(uint16_t id){
	uint16_t stat;
	// return NodeId
	stat = TOS_NODE_ID;
	dbg(APPNAME,"Custom::func_getNodeId(): id=%d, NodeId=%d\n",id,stat);
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
#ifdef M_MSG_QUEUE
void  func_qPut(uint16_t id){
	error_t stat;
	qData_t* qData_p;
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::func_qPut(): id=%d, addr=%d\n",id,value);
	// queue the usrMsg data
	qData_p = (qData_t*)signal VM.getRealAddr(value);
	stat = call usrDataQ.put(qData_p);
	signal VM.push(stat);
	}
void  func_qGet(uint16_t id){
	error_t stat;
	qData_t* qData_p;
	uint16_t value = (uint16_t)signal VM.pop();
	dbg(APPNAME,"Custom::func_qGet(): id=%d, addr=%d\n",id,value);
	// get the usrMsg data
	qData_p = (qData_t*)signal VM.getRealAddr(value);
	stat = call usrDataQ.get(qData_p);
	signal VM.push(stat);
	}
void  func_qSize(uint16_t id){
	uint8_t stat;
	// return queue size
	stat = call usrDataQ.size();
	dbg(APPNAME,"Custom::func_qSize(): id=%d, size=%d\n",id,stat);
	signal VM.push(stat);
	}	
void  func_qClear(uint16_t id){
	error_t stat;
	dbg(APPNAME,"Custom::func_qClear(): id=%d\n",id);
	// return queue size
	stat = call usrDataQ.clearAll();
	signal VM.push(stat);
	}
#endif //M_MSG_QUEUE

#ifdef M_FFT
  /* the memory required by FFT routine, the length
     of if should be tested on each platform */
  size_t fft_mem_len = 1138; // 1138 is for 100-point FFT on TelosB
  int8_t fft_mem[1138];
  const int fft_points = 100;
  kiss_fftr_cfg fft_cfg;
  kiss_fft_cpx outdata[SAMPLING_RATE/2 + 1];

  int32_t buffer_pool[POOL_LEN][BUFFER_LEN]; // use integer to store data, to accelerate execution
  
void  func_fftAlloc(uint16_t id){
	error_t stat;
	dbg(APPNAME,"Custom::func_fftAlloc(): id=%d\n",id);
	stat = call KF.kiss_fftr_alloc(fft_points, 0, fft_mem, &fft_mem_len);
	if (stat!=SUCCESS) signal VM.evtError(E_IDXOVF);
	signal VM.push(stat);
	}

void  func_fft(uint16_t id){
	error_t stat=SUCCESS;

	signal VM.push(stat);
	}
#endif	

void  func_setupMic(uint16_t id){
	error_t stat;
	uint16_t bufAddr;
	MIC_gain = (uint8_t)signal VM.pop();
	MIC_usPeriod = (uint32_t)signal VM.pop();
	MIC_count = (uint16_t)signal VM.pop();
	bufAddr = (uint16_t)signal VM.pop();
	MIC_buf = (nx_uint16_t*)signal VM.getRealAddr(bufAddr);
	MIC_flag = TRUE;
	stat = SUCCESS;
	signal VM.push(stat);

}

void  func_RFPower(uint16_t id){
	uint8_t powerIdx;
	powerIdx = (uint8_t)signal VM.pop();
	call BSRadio.setRFPower(powerIdx);
	signal VM.push(SUCCESS);
}

#ifdef M_VCN_DAT
#include "bayes_model.h"
void  func_GModelRead(uint16_t id){
	error_t stat;
	uint8_t* gmodel;
	uint16_t varGModel;
	uint32_t m_addr=0;
	dbg(APPNAME,"Custom::func_GModelRead(): id=%d\n",id);
	varGModel = (uint16_t)signal VM.pop();
	gmodel = (void*)signal VM.getRealAddr(varGModel);
	stat = call GModelBlockRead.read(m_addr, gmodel, sizeof(ms_gauss_model));
	signal VM.push(stat);
}
void  func_getRTime(uint16_t id){
	uint32_t rtime;
	dbg(APPNAME,"Custom::func_getRTime(): id=%d\n",id);
	rtime = call GetSensorRtime.get();
	signal VM.push(rtime);
}
void  func_setRTime(uint16_t id){
	uint32_t rtime;
	dbg(APPNAME,"Custom::func_setRTime(): id=%d\n",id);
	rtime = (uint32_t)signal VM.pop();
	call SetSensorRtime.set(rtime);
	signal VM.push(SUCCESS);
}

void  func_getNSamples(uint16_t id){
	uint8_t scale;
	uint16_t varGModel;
	int32_t samples;
	ms_gauss_model* gModel;
	dbg(APPNAME,"Custom::func_getNSamples(): id=%d\n",id);
	scale = (uint16_t)signal VM.pop();
	varGModel = (uint16_t)signal VM.pop();
	gModel = (ms_gauss_model*)signal VM.getRealAddr(varGModel);
	// return nSample value
	if (scale < MS_GAUSS_SCALES){
		samples = *(nxle_int32_t*)(gModel->nsample+scale);
		signal VM.push(samples);
		}
	else
		signal VM.push(0);
}
#endif
#ifdef M_VCN_DET
#include "detect.c"

void  func_detect(uint16_t id){
	uint8_t scale,decision,bufIdx;
	uint16_t varGModel;
	const kiss_fft_scalar * timedata;
	ms_gauss_model* gModel;
	kiss_fftr_cfg st;
	kiss_fft_cpx* freqdata;
	
	dbg(APPNAME,"Custom::func_setRTime(): id=%d\n",id);
	
	bufIdx = (uint8_t)signal VM.pop();	
	scale = (uint16_t)signal VM.pop();
	varGModel = (uint16_t)signal VM.pop();

	st = (kiss_fftr_cfg)fft_mem;
	freqdata = (kiss_fft_cpx *)outdata;
	timedata = (kiss_fft_scalar *)&buffer_pool[bufIdx][0];
	gModel = (ms_gauss_model*)signal VM.getRealAddr(varGModel);

	// call FFT
	call KF.kiss_fftr(st, timedata, freqdata);
	// calculate detect()
	decision = detect(gModel,scale,freqdata);

	// return 'detect' value
	//
	//signal VM.push(st->substate->nfft);
	signal VM.push(decision);
}

#include "energy.c"
//ulong intensityMean(ulong* sData.val,ushort count,ushort* valid_count)	
void  func_intensityMean(uint16_t id){
	nx_int32_t* datap;
	uint16_t count, dataAddr,valid_countAddr;
	nx_uint16_t* valid_countp;
	uint32_t intensity;
	dbg(APPNAME,"Custom::func_intensityMean(): id=%d\n",id);
	valid_countAddr = (uint16_t)signal VM.pop();
	count = (uint16_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	valid_countp = (nx_uint16_t*)signal VM.getRealAddr(valid_countAddr);
	datap = (nx_int32_t*)signal VM.getRealAddr(dataAddr);
	intensity = intensityMean(datap,count,valid_countp);
	signal VM.push(intensity);
}

//ulong seismicEnergy(ulong* sData.val, ushort count, ulong intensity_mean)
void  func_seismicEnergy(uint16_t id){
	nx_uint32_t* datap;
	uint16_t dataAddr, count;
	uint32_t intensity;
	uint32_t sEnergy;
	dbg(APPNAME,"Custom::func_seismicEnergy(): id=%d\n",id);
	intensity = (uint32_t)signal VM.pop();
	count = (uint16_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	datap = (nx_uint32_t*)signal VM.getRealAddr(dataAddr);
	sEnergy = seismicEnergy(datap,count,intensity);
	signal VM.push(sEnergy);
}

//ubyte energyScale(ulong seismic_energy)
uint32_t possible_scales[8] = {10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000};
void  func_energyScale(uint16_t id){
	//return (int) log10(energy);
	uint32_t seismic_energy;
	uint8_t i;
	dbg(APPNAME,"Custom::func_energyScale(): id=%d\n",id);
	seismic_energy = (uint32_t)signal VM.pop();	
	for(i = 0; i < 8; i++) {
		if (seismic_energy < possible_scales[i]) {
			break;
		};
	}
	signal VM.push(i);
}

//ubyte copyBufferPool(buffer_pool_reg* buffer_pool,ushort count,ulong* sData.val, long intensity_mean, ubyte scale, ulong rtime)
void  func_copyBufferPool(uint16_t id){
	uint16_t dataAddr, count;
	uint32_t rtime;
	int32_t intensity;
	uint8_t scale;
	uint16_t buffer_poolAddr;
	nx_int32_t* datap;
	buffer_pool_reg* buffer_poolp;
	dbg(APPNAME,"Custom::func_copyBufferPool(): id=%d\n",id);
	rtime = (uint32_t)signal VM.pop();
	scale = (uint8_t)signal VM.pop();
	intensity=(uint32_t)signal VM.pop();
	dataAddr=(uint16_t)signal VM.pop();
	count=(uint16_t)signal VM.pop();
	buffer_poolAddr=(uint16_t)signal VM.pop();
	
	datap = (nx_uint32_t*)signal VM.getRealAddr(dataAddr);
	buffer_poolp = (buffer_pool_reg*)signal VM.getRealAddr(buffer_poolAddr);
	copyBufferPool(buffer_poolp,count,datap,intensity,scale,rtime);
	signal VM.push(SUCCESS);
}
#endif

/**
 *	procOutEvt(uint8_t id)
 *  	procOutEvt - process the out events (emit)
 * 
 *	id - Event ID
 */
command void VM.procOutEvt(uint8_t id,uint32_t value){
	dbg(APPNAME,"Custom::procOutEvt(): id=%d\n",id);
	switch (id){
//		case O_INIT 		: proc_init(id,value); break;
		case O_LEDS 		: proc_leds(id,value); break;
		case O_LED0 		: proc_led0(id,value); break;
		case O_LED1 		: proc_led1(id,value); break;
		case O_LED2 		: proc_led2(id,value); break;
		case O_TEMP 		: proc_req_temp(id,value); break;
		case O_PHOTO 		: proc_req_photo(id,value); break;
		case O_VOLTS 		: proc_req_volts(id,value); break;
		case O_SEND 		: proc_send(id,value); break;
		case O_SEND_ACK 	: proc_send_ack(id,value); break;
		case O_PORT_A 		: proc_set_port_a(id,value); break;
		case O_PORT_B 		: proc_set_port_b(id,value); break;
		case O_CFG_PORT_A 	: proc_cfg_port_a(id,value); break;
		case O_CFG_PORT_B 	: proc_cfg_port_b(id,value); break;
		case O_REQ_PORT_A 	: proc_req_port_a(id,value); break;
		case O_REQ_PORT_B 	: proc_req_port_b(id,value); break;
		case O_CFG_INT_A 	: proc_cfg_int_a(id,value); break;
		case O_CFG_INT_B 	: proc_cfg_int_b(id,value); break;
		case O_CUSTOM_A 	: proc_req_custom_a(id,value); break;
		case O_REQ_MIC		: proc_req_mic(id,value); break;
		case O_BEEP			: proc_beep(id,value); break;
		case O_CUSTOM 		: proc_req_custom(id,value); break;
#ifdef M_VCN_DAT
		case O_RD_STREAM : proc_rd_stream(id,value); break;
#endif
	}
}


	command void VM.callFunction(uint8_t id){
		dbg(APPNAME,"Custom::VM.callFunction(%d)\n",id);
		switch (id){
			case F_GETNODEID: func_getNodeId(id); break;
			case F_RANDOM 	: func_random(id); break;
			case F_GETMEM 	: func_getMem(id); break;
			case F_GETTIME 	: func_getTime(id); break;
#ifdef M_MSG_QUEUE
			case F_QPUT 	: func_qPut(id); break;
			case F_QGET 	: func_qGet(id); break;
			case F_QSIZE 	: func_qSize(id); break;
			case F_QCLEAR 	: func_qClear(id); break;		
#endif
#ifdef M_FFT
			case F_FFT_ALLOC: func_fftAlloc(id); break;
			case F_FFT 		: func_fft(id); break;
#endif

			case F_SETUP_MIC: func_setupMic(id); break;
			case F_RFPOWER: func_RFPower(id); break;

#ifdef M_VCN_DAT
			case F_GMODEL_READ   : func_GModelRead(id); break;
			case F_GET_RTIME     : func_getRTime(id); break;
			case F_SET_RTIME     : func_setRTime(id); break;
			case F_GET_NSAMPLES  : func_getNSamples(id); break;
#endif
#ifdef M_VCN_DET
			case F_DETECT        	: func_detect(id); break;
			case F_INTENSITY_MEAN	: func_intensityMean(id); break;
			case F_SEISMIC_ENERGY   : func_seismicEnergy(id); break;
			case F_ENERGY_SCALE     : func_energyScale(id); break;
			case F_COPY_BUFFER_POOL : func_copyBufferPool(id); break;
			
#endif
		}
	}

	command void VM.reset(){
		// Reset leds
		call SA.setActuator(AID_LEDS, 0);
	}

	task void BCRadio_receive(){
		signal VM.queueEvt(I_RECEIVE_ID, ExtDataRadioReceived.type, &ExtDataRadioReceived);	
		signal VM.queueEvt(I_RECEIVE   ,                         0, &ExtDataRadioReceived);	
	}

	event void BSRadio.receive(uint8_t am_id, message_t* msg, void* payload, uint8_t len){
		dbg(APPNAME,"Custom::BSRadio.receive(): AM_ID = %d\n",am_id);
		if (am_id == AM_USRMSG){
			memcpy(&ExtDataRadioReceived,payload,sizeof(usrMsg_t));
			post BCRadio_receive();
		} else {
			dbg(APPNAME,"Custom::BSRadio.receive(): Discarting AM_ID = %d\n",am_id);
		}
	}

	event void BSRadio.sendDone(uint8_t am_id,message_t* msg,void* dataMsg, error_t error){
		dbg(APPNAME,"Custom::BSRadio.sendDone(): AM_ID = %d, error=%d\n",am_id,error);
		if (am_id == AM_USRMSG){
			ExtDataSendDoneError = (uint8_t)error;
			signal VM.queueEvt(I_SEND_DONE_ID, ((usrMsg_t*)dataMsg)->type, &ExtDataSendDoneError);
			signal VM.queueEvt(I_SEND_DONE   ,                          0, &ExtDataSendDoneError);
		} else {
			dbg(APPNAME,"Custom::BSRadio.sendDone(): Discarting sendDone AM_ID = %d\n",am_id);
		}
	}
	event void BSRadio.sendDoneAck(uint8_t am_id,message_t* msg,void* dataMsg,error_t error, bool wasAcked){
		dbg(APPNAME,"Custom::BSRadio.sendDoneAck(): AM_ID = %d, error=%d, ack=%d\n",am_id,error,wasAcked);
		if (am_id == AM_USRMSG){
			ExtDataWasAcked = (uint8_t)wasAcked;
			signal VM.queueEvt(I_SEND_DONE_ACK_ID, ((usrMsg_t*)dataMsg)->type, &ExtDataWasAcked);
			signal VM.queueEvt(I_SEND_DONE_ACK   ,                          0, &ExtDataWasAcked);
		} else {
			dbg(APPNAME,"Custom::BSRadio.sendDoneAck(): Discarting sendDoneAck AM_ID = %d\n",am_id);
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
			case SID_MIC: return I_MIC;
		}
		return 0;
	}
	event void SA.Ready(uint8_t reqSource, uint8_t codeEvt_id){
		dbg(APPNAME,"Custom::SA.Ready()\n");
		switch (reqSource) {
			case REQ_SOURCE1 : signal VM.queueEvt(wd2ceuSensorId(codeEvt_id), 0, call SA.getDatap((uint8_t)(codeEvt_id & 0x1f))); break;			
//			case REQ_SOURCE2 : break;  // TBD
//			case REQ_SOURCE3 : break;  // TBD
//			case REQ_SOURCE4 : break;  // TBD
			default:dbg(APPNAME,"Custom::SA.Ready(): reqSource not defined - %d\n",reqSource);
		}
		
	}


/**
 * Custom usrDataueue
 */
#ifdef M_MSG_QUEUE
	event void usrDataQ.dataReady(){
		dbg(APPNAME,"Custom::usrDataQ.dataReady()\n");
		// Queue the custom event
		ExtDataQReady = call usrDataQ.size();
		signal VM.queueEvt(I_Q_READY, 0, &ExtDataQReady);
	}
#endif

/**
 * Volcano module
 */
#ifdef M_VCN_DAT
	event void ReadStream.bufferDone(error_t result, nx_int32_t* buf, uint16_t count){
		uint16_t i;
		ExtDataBufferRdDone = (result==SUCCESS)?count:0;
		for (i=0; i < count;i++) UsrStreamBuffer[i] = buf[i];
		signal VM.queueEvt(I_STREAM_RD_DONE, 0, &ExtDataBufferRdDone);		
	}
	
	event void ReadStream.readDone(error_t result, uint32_t usActualPerid){}

	event void GModelBlockRead.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}

	event void GModelBlockRead.readDone(storage_addr_t addr, void *buf_, storage_len_t len, error_t error) {
		ExtDataGModelRdDone = error;
		signal VM.queueEvt(I_GMODEL_RD_DONE, 0, &ExtDataGModelRdDone);  	
  }
#endif

#ifdef MODULE_CTP
	event void BSRadio.sendBSDone(message_t* msg,error_t error){
		// Do nothing by now!
		// In future may return an event to VM.
	}
#endif // MODULE_CTP

}
