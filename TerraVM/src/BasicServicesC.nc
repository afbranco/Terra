/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Configuration: BasicServicesC
 * Basic Services - Main VM Timer, Simple Radio, and Code Upload/Forwarder
 * 
 */
 
#include "BasicServices.h"
 
configuration BasicServicesC{
	provides interface Boot as BSBoot;
	provides interface BSTimer as BSTimerVM;
	provides interface BSTimer as BSTimerAsync;
	provides interface BSUpload;
	provides interface BSRadio;
}
implementation{
	components MainC;
    BS.TOSBoot  -> MainC;
    
/*******************************************
 * Basic Service components
 *******************************************/
	components BasicServicesP as BS;
   	// Provided interfaces wire
   	BSBoot = BS.BSBoot;	
	BSTimerVM = BS.BSTimerVM;
	BSTimerAsync = BS.BSTimerAsync;
	BSUpload = BS.BSUpload;
	BSRadio = BS.BSRadio;

// Radio RF Power + LPLSend
#ifdef TOSSIM
	components ActiveMessageC as RadioAux;

#elif defined(INOS) || defined(INOX) // INO must be before the others

#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB)
	components CC2420ActiveMessageC as RadioAux;
	BS.RadioAux -> RadioAux;

	#ifdef LPL_ON
	BS.LowPowerListening -> RadioAux.LowPowerListening;
	#endif

#elif defined(PLATFORM_IRIS)
	components RF230ActiveMessageC as RadioAux;
	BS.RadioAux -> RadioAux.PacketTransmitPower;

	#ifdef LPL_ON
	BS.LowPowerListening -> RadioAux.LowPowerListening;
	#endif


#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
	components CC1000ControlP as RadioPwr;
	BS.RadioAux -> RadioPwr;
	components ActiveMessageC as RadioAux;//components CC1000ActiveMessageC as RadioAux;
	//components CC1000CsmaRadioC as RadioAux;

	#ifdef LPL_ON
	BS.LowPowerListening -> RadioAux.LowPowerListening;
	#endif



#endif


	// Communication wire
#if defined(INOS)
// Ino Radio configurations
	components SerialActiveMessageC as SerialAM;
	BS.RadioControl -> SerialAM.SplitControl;
	BS.RadioSender -> SerialAM.AMSend;
	BS.RadioReceiver -> SerialAM.Receive;
	BS.RadioPacket -> SerialAM.Packet;
	BS.RadioAMPacket -> SerialAM.AMPacket;
	BS.RadioAck -> SerialAM.PacketAcknowledgements;

#elif defined(INOX)
// Ino Radio configurations
	components XBeeMsgC as RadioAM;
	BS.RadioControl -> RadioAM;
	BS.RadioAck -> RadioAM;
	BS.RadioSender -> RadioAM.AMSend;
	BS.RadioReceiver -> RadioAM.Receive;
	BS.RadioAMPacket -> RadioAM;
	BS.RadioPacket -> RadioAM;

#else
// TinyOS Radio configurations
	components ActiveMessageC as RadioAM;
	BS.RadioControl -> RadioAM.SplitControl;
	BS.RadioAMPacket -> RadioAM;
	BS.RadioPacket -> RadioAM.Packet;
	BS.RadioAck -> RadioAM.PacketAcknowledgements;
 #ifndef MODULE_CTP
	BS.RadioSender -> RadioAM.AMSend;
 #else
	BS.snd_NEWPROGVERSION -> RadioAux.AMSend[AM_NEWPROGVERSION];
	BS.snd_NEWPROGBLOCK -> RadioAux.AMSend[AM_NEWPROGBLOCK];
	BS.snd_REQPROGBLOCK -> RadioAux.AMSend[AM_REQPROGBLOCK]; 
  #ifdef MODE_SETDATA
	BS.snd_SETDATAND -> RadioAux.AMSend[AM_SETDATAND];
	BS.snd_REQDATA -> RadioAux.AMSend[AM_REQDATA];
  #endif

	BS.snd_PINGMSG -> RadioAux.AMSend[AM_PINGMSG];
	BS.snd_CUSTOM_0 -> RadioAux.AMSend[AM_CUSTOM_0];
	BS.snd_CUSTOM_1 -> RadioAux.AMSend[AM_CUSTOM_1];
	BS.snd_CUSTOM_2 -> RadioAux.AMSend[AM_CUSTOM_2];
	BS.snd_CUSTOM_3 -> RadioAux.AMSend[AM_CUSTOM_3];
	BS.snd_CUSTOM_4 -> RadioAux.AMSend[AM_CUSTOM_4];
	BS.snd_CUSTOM_5 -> RadioAux.AMSend[AM_CUSTOM_5];
	BS.snd_CUSTOM_6 -> RadioAux.AMSend[AM_CUSTOM_6];
	BS.snd_CUSTOM_7 -> RadioAux.AMSend[AM_CUSTOM_7];
	BS.snd_CUSTOM_8 -> RadioAux.AMSend[AM_CUSTOM_8];
	BS.snd_CUSTOM_9 -> RadioAux.AMSend[AM_CUSTOM_9];
 #endif

 #ifndef MODULE_CTP
	BS.RadioReceiver -> RadioAM.Receive;
 #else
	BS.rec_NEWPROGVERSION -> RadioAM.Receive[AM_NEWPROGVERSION];
	BS.rec_NEWPROGBLOCK -> RadioAM.Receive[AM_NEWPROGBLOCK];
	BS.rec_REQPROGBLOCK -> RadioAM.Receive[AM_REQPROGBLOCK];
  #ifdef MODE_SETDATA
	BS.rec_SETDATAND -> RadioAM.Receive[AM_SETDATAND];
	BS.rec_REQDATA -> RadioAM.Receive[AM_REQDATA];
  #endif
	BS.rec_PINGMSG -> RadioAM.Receive[AM_PINGMSG];
	BS.rec_CUSTOM_0 -> RadioAM.Receive[AM_CUSTOM_0];
	BS.rec_CUSTOM_1 -> RadioAM.Receive[AM_CUSTOM_1];
	BS.rec_CUSTOM_2 -> RadioAM.Receive[AM_CUSTOM_2];
	BS.rec_CUSTOM_3 -> RadioAM.Receive[AM_CUSTOM_3];
	BS.rec_CUSTOM_4 -> RadioAM.Receive[AM_CUSTOM_4];
	BS.rec_CUSTOM_5 -> RadioAM.Receive[AM_CUSTOM_5];
	BS.rec_CUSTOM_6 -> RadioAM.Receive[AM_CUSTOM_6];
	BS.rec_CUSTOM_7 -> RadioAM.Receive[AM_CUSTOM_7];
	BS.rec_CUSTOM_8 -> RadioAM.Receive[AM_CUSTOM_8];
	BS.rec_CUSTOM_9 -> RadioAM.Receive[AM_CUSTOM_9];
 #endif
#endif // INO x TinyOS

	// Base Station
#ifndef NO_BSTATION
	components SerialActiveMessageC as SerialAM;
	BS.SerialControl -> SerialAM.SplitControl;
	BS.SerialSender -> SerialAM.AMSend;
	BS.SerialReceiver -> SerialAM.Receive;
	BS.SerialPacket -> SerialAM.Packet;
#endif
	
	// setData queue - only NEW_DATA_LIST_SIZE last updates
#ifdef MODE_SETDATA
	components new dataQueueC(setDataBuff_t,SET_DATA_LIST_SIZE*2,(char)unique("dataQueueC")) as setDataQueue;
	BS.setDataQ -> setDataQueue;
#endif
	// Bit vector to control memory blocks
	components new vmBitVectorC(CURRENT_MAX_BLOCKS) as Bitmap;
	BS.BM -> Bitmap;	
	
	// IN & OUT Queues
#ifndef NO_BSTATION
#define  MSG_IN_QSIZE (IN_QSIZE * 2)
#define  MSG_OUT_QSIZE OUT_QSIZE
#else
#define  MSG_IN_QSIZE IN_QSIZE
#define  MSG_OUT_QSIZE OUT_QSIZE
#endif
	components new dataQueueC(GenericData_t,MSG_IN_QSIZE,(char)unique("dataQueueC")) as inQueue;
	components new dataQueueC(GenericData_t,MSG_OUT_QSIZE,(char)unique("dataQueueC")) as outQueue;
	BS.inQ -> inQueue;
	BS.outQ -> outQueue;	


	// Timers
	components new TimerMilliC() as TimerVM;	
	components new TimerMilliC() as TimerAsync;	
	components new TimerMilliC() as sendTimer;	
	components new TimerMilliC() as ProgReqTimer;	
	components new TimerMilliC() as SendDataFullTimer;	
	components new TimerMilliC() as DataReqTimer;	
	BS.TimerVM -> TimerVM;	
	BS.TimerAsync -> TimerAsync;	
	BS.sendTimer -> sendTimer;	
	BS.ProgReqTimer -> ProgReqTimer;
	BS.SendDataFullTimer -> SendDataFullTimer;
#ifdef MODE_SETDATA
	BS.DataReqTimer -> DataReqTimer;
#endif
	components LedsC;
	BS.Leds -> LedsC;
	components RandomC;
	BS.Random -> RandomC;


/*******************************************
 * Optional components
 *******************************************/
#ifdef MODULE_CTP
	components CollectionC as Collector;
	BS.RoutingControl -> Collector;
	BS.RootControl -> Collector;
	BS.CtpInfo -> Collector;
	BS.recSendBS -> Collector.Receive[AM_SENDBS];
	components new CollectionSenderC(AM_SENDBS) as sendBS;
	BS.sendBSNet -> sendBS;
#endif

#ifdef INOX
// afb
  components Atm128Uart0C as UART0;
  BS.Uart0 -> UART0;
  BS.Uart0Ctl -> UART0;
  components new QueueC(uint8_t, 100) as LogQ;
  BS.LogQ -> LogQ;
  components InoIOC;
  BS.InoIO -> InoIOC;
#endif	
#ifdef INOS

  components InoIOC;
  BS.InoIO -> InoIOC;
#endif	


}