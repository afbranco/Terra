/***********************************************
 * wdvm - WSNDyn virtual machine project
 * July, 2012
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Module: SensAct
 * Local sensors and actuators
 * 
 */

//#include "VMCustomNet.h"
#include "SensAct.h"

module SensActP{
	provides interface SensAct as SA;
	uses interface Leds as A_LEDS;	
#if !(defined(M_VCN_DAT) && defined(PLATFORM_TELOSB))  // Disable sensors when using Volcano Data in TelosB
	uses interface Read<uint16_t> as S_TEMP;
	uses interface Read<uint16_t> as S_PHOTO;
	uses interface Read<uint16_t> as S_VOLT;
#endif

#if SBOARD == 300
	uses interface ReadStream<uint16_t> as S_MIC;
	uses interface MicSetting as S_MIC_CFG;
	uses interface Mts300Sounder as A_SOUNDER;
#endif

#ifndef TOSSIM
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
    uses interface GeneralIO as A_PIN1;
    uses interface GeneralIO as A_PIN2;
#if TOSVERSION >= 212
	uses interface GpioInterrupt as A_INT1;
	uses interface GpioInterrupt as A_INT2;
#endif
#if TOSVERSION <= 211
	uses interface HplAtm128Interrupt as A_INT1;
	uses interface HplAtm128Interrupt as A_INT2;
#endif
#elif defined(PLATFORM_TELOSB)
    // TelosB
#endif
#endif
}
implementation{
	nx_uint16_t dTemp,dPhoto,dLeds,dVolt,dIn1,dIn2,dPin1,dPin2,dMic;
	uint8_t sensorsReqs[SENSOR_COUNT+4];
	bool initFlag=FALSE;

	void TViewer(char* cmd,uint16_t p1, uint16_t p2){
		dbg("TVIEW","<<: %s %d %d %d :>>\n",cmd,TOS_NODE_ID,p1,p2);
		}

	bool getSReq(uint8_t reqSource, uint8_t sensorId){
		uint8_t i;
		if (initFlag==FALSE) {for (i=0;i<SENSOR_COUNT+4;i++) sensorsReqs[i]=0; initFlag=TRUE;}
		for (i=0;i<(SENSOR_COUNT+4);i++)
			if (sensorsReqs[i]==(sensorId + reqSource*(1<<SENSOR_CTL_BIT))){
				sensorsReqs[i]=0;
				return TRUE;
			}
		return FALSE;
	}

	void insertSReq(uint8_t reqSource, uint8_t sensorId){
		uint8_t i;
		bool foundFlag=FALSE;
		if (initFlag==FALSE) {for (i=0;i<(SENSOR_COUNT+4);i++) sensorsReqs[i]=0; initFlag=TRUE;}
		for (i=0;(i<(SENSOR_COUNT+4) && foundFlag==FALSE);i++){
			if (sensorsReqs[i]==(sensorId + reqSource*(1<<SENSOR_CTL_BIT))){
				foundFlag=TRUE;
			}
		}
		if (foundFlag==FALSE){
			for (i=0;i<(SENSOR_COUNT+4);i++){
				if (sensorsReqs[i]==0){
					sensorsReqs[i]=(uint8_t)(sensorId + reqSource*(1<<SENSOR_CTL_BIT));
					return;
				}
			}
		}
	}

	bool getPinX(int sid){
#ifndef TOSSIM
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
		if (sid==SID_IN1) if (call A_PIN1.isInput()) return call A_PIN1.get();
		if (sid==SID_IN2) if (call A_PIN2.isInput()) return call A_PIN2.get();
#elif defined(PLATFORM_TELOSB)
    // TelosB
#endif
#endif
		return FALSE;
	}
	void setPinX(int aid,bool val){
#ifndef TOSSIM
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
		if (aid==AID_OUT1) if (call A_PIN1.isOutput()) if (val==TRUE) call A_PIN1.set(); else call A_PIN1.clr();
		if (aid==AID_OUT2) if (call A_PIN2.isOutput()) if (val==TRUE) call A_PIN2.set(); else call A_PIN2.clr();
#elif defined(PLATFORM_TELOSB)
    // TelosB
#endif
#endif
	}


	command uint16_t SA.readSensor(uint8_t id){
		uint16_t value=0;
		switch(id){
			case SID_TEMP: value=dTemp;break;
			case SID_PHOTO: value=dPhoto;break;
			case SID_LEDS: value=dLeds;break;
			case SID_VOLT: value=dVolt;break;
			case SID_IN1: value=(getPinX(SID_IN1)==TRUE)?1:0;break;
			case SID_IN2: value=(getPinX(SID_IN2)==TRUE)?1:0;break;
		}
		dbg(APPNAME,"SA.readSensor(%d)=%d\n",id,value);
		return value;
	}

	command void SA.reqSensor(uint8_t reqSource, uint8_t id){
		dbg(APPNAME,"SA.reqSensor(): reSource=%d, id=%d\n",reqSource,id);
#if !(defined(M_VCN_DAT) && defined(PLATFORM_TELOSB))
		switch (id){
			case SID_TEMP : call S_TEMP.read(); insertSReq(reqSource,id); TViewer("sensor",SID_TEMP,0); break;
			case SID_PHOTO: call S_PHOTO.read(); insertSReq(reqSource,id);  TViewer("sensor",SID_PHOTO,0);break;
			case SID_LEDS: dLeds = call A_LEDS.get(); signal SA.Ready(reqSource, TID_SENSOR_DONE | SID_LEDS); break;
			case SID_VOLT: call S_VOLT.read(); insertSReq(reqSource,id);  TViewer("sensor",SID_VOLT,0); break;
			case SID_IN1: dIn1 = (getPinX(SID_IN1)==TRUE)?1:0; signal SA.Ready(reqSource, TID_SENSOR_DONE | SID_IN1); break;
			case SID_IN2: dIn2 = (getPinX(SID_IN2)==TRUE)?1:0; signal SA.Ready(reqSource, TID_SENSOR_DONE | SID_IN2); break;
		}
#endif
	}

// Adapt enable interrupt function for TinyOS Version
#ifndef TOSSIM
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
	void enableEdge_A_INT1(bool low_to_high){
#if TOSVERSION >= 212
    if (low_to_high)
    	call A_INT1.enableRisingEdge()
    else
		call A_INT1.enableFallingEdge())    
#endif
#if TOSVERSION <= 211
	call A_INT1.edge(low_to_high);
#endif		
	}
	void enableEdge_A_INT2(bool low_to_high){
#if TOSVERSION >= 212
    if (low_to_high)
    	call A_INT2.enableRisingEdge()
    else
		call A_INT2.enableFallingEdge())    
#endif
#if TOSVERSION <= 211
	call A_INT2.edge(low_to_high);
#endif		
	}
#elif defined(PLATFORM_TELOSB)
    // TelosB
#endif
#endif

	command void SA.setActuator(uint8_t id, uint16_t val){
		dbg(APPNAME,"SA.setActuator(%d)\n",id);		
		switch(id){
			case AID_LEDS: call A_LEDS.set((uint8_t)val);TViewer("leds",3,val); break;
			case AID_LED0: ((val & 0x0001)==1)?call A_LEDS.led0On():call A_LEDS.led0Off();TViewer("leds",0,val & 0x0001); break;
			case AID_LED1: ((val & 0x0001)==1)?call A_LEDS.led1On():call A_LEDS.led1Off();TViewer("leds",1,val & 0x0001); break;
			case AID_LED2: ((val & 0x0001)==1)?call A_LEDS.led2On():call A_LEDS.led2Off();TViewer("leds",2,val & 0x0001); break;
			case AID_LED0_TOGGLE: call A_LEDS.led0Toggle();TViewer("leds",0,3); break;
			case AID_LED1_TOGGLE: call A_LEDS.led1Toggle();TViewer("leds",1,3); break;
			case AID_LED2_TOGGLE: call A_LEDS.led2Toggle();TViewer("leds",2,3); break;
#ifndef TOSSIM
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
			case AID_OUT1: setPinX(AID_OUT1,(val==0)?FALSE:TRUE);break;
			case AID_OUT2: setPinX(AID_OUT2,(val==0)?FALSE:TRUE);break;
			case AID_PIN1: ((val & 0x0001)==1)? call A_PIN1.makeOutput():call A_PIN1.makeInput();break;
			case AID_PIN2: ((val & 0x0001)==1)? call A_PIN2.makeOutput():call A_PIN2.makeInput();break;
			case AID_INT1: if (val <=1) (val==0?enableEdge_A_INT1(TRUE):enableEdge_A_INT1(FALSE)); else if (val>1) call A_INT1.disable();break;
			case AID_INT2: if (val <=1) (val==0?enableEdge_A_INT2(TRUE):enableEdge_A_INT2(FALSE)); else if (val>1) call A_INT2.disable();break;
		#if SBOARD == 300
			case AID_SOUNDER: call A_SOUNDER.beep(val); break;
		#endif
#elif defined(PLATFORM_TELOSB)
    // TelosB
#endif
#endif
		}
		
	}



	command void* SA.getDatap(uint8_t id){
		dbg(APPNAME,"SA.getDatap(%d)\n",id);
		switch(id){
			case SID_TEMP: return &dTemp;
			case SID_PHOTO: return &dPhoto;
			case SID_LEDS: return &dLeds;
			case SID_VOLT: return &dVolt;
#ifndef TOSSIM
	#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
			case SID_IN1: dPin1=(getPinX(SID_IN1)==TRUE)?1:0;return &dPin1;
			case SID_IN2: dPin2=(getPinX(SID_IN2)==TRUE)?1:0;return &dPin2;
		#if SBOARD == 300
			case SID_MIC: return &dMic;

		#endif
	#endif
#endif
		}			
		return &dTemp;
	}

#if !(defined(M_VCN_DAT) && defined(PLATFORM_TELOSB))
	event void S_TEMP.readDone(error_t result, uint16_t val){
		uint8_t source;
		dbg(APPNAME,"S_TEMP.readDone(): val=%d\n",val);		
		dTemp = val;
		for (source=0;source<4;source++)
			if (getSReq (source,SID_TEMP) == TRUE) signal SA.Ready(source, TID_SENSOR_DONE | SID_TEMP);		
	}

	event void S_PHOTO.readDone(error_t result, uint16_t val){
		uint8_t source;
		dbg(APPNAME,"S_PHOTO.readDone(): val=%d\n",val);		
		dPhoto = val;
		for (source=0;source<4;source++)
			if (getSReq (source,SID_PHOTO) == TRUE) signal SA.Ready(source, TID_SENSOR_DONE | SID_PHOTO);		
	}
	
	event void S_VOLT.readDone(error_t result, uint16_t val){
		uint8_t source;
		dbg(APPNAME,"S_VOLT.readDone(): val=%d\n",val);		
		dVolt = val;
//		dVolt = TOS_NODE_ID;
		for (source=0;source<4;source++)
			if (getSReq (source,SID_VOLT) == TRUE) signal SA.Ready(source, TID_SENSOR_DONE | SID_VOLT);		
	}	
#endif
#ifndef TOSSIM
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
	task void sigInt1(){signal SA.Ready(0,(uint8_t)(TID_SENSOR_DONE | SID_INT1));}
	task void sigInt2(){signal SA.Ready(0,(uint8_t)(TID_SENSOR_DONE | SID_INT2));}
	async event void A_INT1.fired(){post sigInt1();}
	async event void A_INT2.fired(){post sigInt2();}
#elif defined(PLATFORM_TELOSB)
    // TelosB
#endif
#endif


	/**
	 * Mic and Sounder implementation --> only for mts300 sensorboard
	 */

	command void SA.reqStreamSensor(uint8_t reqSource, uint8_t id, uint16_t *buf, uint16_t count, uint32_t usPeriod, uint8_t gain){
		dbg(APPNAME,"SA.reqStreamSensor(): reSource=%d, id=%d\n",reqSource,id);
#ifndef TOSSIM
	#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
		#if SBOARD == 300
		switch (id){
			case SID_MIC :
				call S_MIC_CFG.muxSel(1); // raw voice-band output
				call S_MIC_CFG.gainAdjust(gain);
				call S_MIC.postBuffer(buf, count); 
				call S_MIC.read(usPeriod); 
				insertSReq(reqSource,id); 
				TViewer("sensor",SID_MIC,0); 
				break;
		}
		#endif		
	#endif		
#endif		
	}
	
#if SBOARD == 300
	event void S_MIC.readDone(error_t result, uint32_t usActualPeriod){
		dbg(APPNAME,"S_MIC.readDone(): ***dummy***\n");		
		// TODO Auto-generated method stub
	}

	event void S_MIC.bufferDone(error_t result, uint16_t *buf, uint16_t count){
		uint8_t source; uint16_t i;
		dbg(APPNAME,"S_MIC.bufferDone(): count=%d\n",count);		
		for (source=0;source<4;source++)
			if (getSReq (source,SID_MIC) == TRUE){ 
				dMic = result;
				// convert data array to 'nx' type (big endian)
				for (i=0; i<count;i++) *(nx_uint16_t*)(buf+i) = buf[i];   					
				signal SA.Ready(source, TID_SENSOR_DONE | SID_MIC);
			}		
	}

	async event error_t S_MIC_CFG.toneDetected(){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

#endif
}