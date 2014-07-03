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

	// Communication wire
	components ActiveMessageC as RadioAM;
	BS.RadioControl -> RadioAM.SplitControl;
	BS.RadioAMPacket -> RadioAM;
	BS.RadioPacket -> RadioAM.Packet;
	BS.RadioAck -> RadioAM.PacketAcknowledgements;
#ifndef MODULE_CTP
	BS.RadioSender -> RadioAM.AMSend;
#else
	BS.snd_NEWPROGVERSION -> RadioAM.AMSend[AM_NEWPROGVERSION];
	BS.snd_NEWPROGBLOCK -> RadioAM.AMSend[AM_NEWPROGBLOCK];
	BS.snd_REQPROGBLOCK -> RadioAM.AMSend[AM_REQPROGBLOCK];
	BS.snd_SETDATAND -> RadioAM.AMSend[AM_SETDATAND];
	BS.snd_REQDATA -> RadioAM.AMSend[AM_REQDATA];
	BS.snd_PINGMSG -> RadioAM.AMSend[AM_PINGMSG];
	BS.snd_CUSTOM_0 -> RadioAM.AMSend[AM_CUSTOM_0];
	BS.snd_CUSTOM_1 -> RadioAM.AMSend[AM_CUSTOM_1];
	BS.snd_CUSTOM_2 -> RadioAM.AMSend[AM_CUSTOM_2];
	BS.snd_CUSTOM_3 -> RadioAM.AMSend[AM_CUSTOM_3];
	BS.snd_CUSTOM_4 -> RadioAM.AMSend[AM_CUSTOM_4];
	BS.snd_CUSTOM_5 -> RadioAM.AMSend[AM_CUSTOM_5];
	BS.snd_CUSTOM_6 -> RadioAM.AMSend[AM_CUSTOM_6];
	BS.snd_CUSTOM_7 -> RadioAM.AMSend[AM_CUSTOM_7];
	BS.snd_CUSTOM_8 -> RadioAM.AMSend[AM_CUSTOM_8];
	BS.snd_CUSTOM_9 -> RadioAM.AMSend[AM_CUSTOM_9];
#endif

#ifndef MODULE_CTP
	BS.RadioReceiver -> RadioAM.Receive;
#else
	BS.rec_NEWPROGVERSION -> RadioAM.Receive[AM_NEWPROGVERSION];
	BS.rec_NEWPROGBLOCK -> RadioAM.Receive[AM_NEWPROGBLOCK];
	BS.rec_REQPROGBLOCK -> RadioAM.Receive[AM_REQPROGBLOCK];
	BS.rec_SETDATAND -> RadioAM.Receive[AM_SETDATAND];
	BS.rec_REQDATA -> RadioAM.Receive[AM_REQDATA];
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


	// Base Station
#ifndef NO_BSTATION
	components SerialActiveMessageC as SerialAM;
	BS.SerialControl -> SerialAM.SplitControl;
	BS.SerialSender -> SerialAM.AMSend;
	BS.SerialReceiver -> SerialAM.Receive;
	BS.SerialPacket -> SerialAM.Packet;
#endif
	
	// setData queue - only NEW_DATA_LIST_SIZE last updates
	components new dataQueueC(setDataBuff_t,SET_DATA_LIST_SIZE*2,(char)unique("dataQueueC")) as setDataQueue;
	BS.setDataQ -> setDataQueue;

	// Bit vector to control memory blocks
	components new vmBitVectorC(CURRENT_MAX_BLOCKS) as Bitmap;
	BS.BM -> Bitmap;	
	
	// IN & OUT Queues
	components new dataQueueC(GenericData_t,IN_QSIZE,(char)unique("dataQueueC")) as inQueue;
	components new dataQueueC(GenericData_t,OUT_QSIZE,(char)unique("dataQueueC")) as outQueue;
	BS.inQ -> inQueue;
	BS.outQ -> outQueue;	

	// Timers
	components new TimerMilliC() as TimerAsync;	
	BS.TimerVM -> TimerVM;	
	components new TimerMilliC() as TimerVM;	
	BS.TimerAsync -> TimerAsync;	
	components new TimerMilliC() as sendTimer;	
	BS.sendTimer -> sendTimer;	
	components new TimerMilliC() as ProgReqTimer;	
	BS.ProgReqTimer -> ProgReqTimer;
	components new TimerMilliC() as SendDataFullTimer;	
	BS.SendDataFullTimer -> SendDataFullTimer;
	components new TimerMilliC() as DataReqTimer;	
	BS.DataReqTimer -> DataReqTimer;

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
	BS.recSendBS -> Collector.Receive[AM_SENDBS];
	components new CollectionSenderC(AM_SENDBS) as sendBS;
	BS.sendBSNet -> sendBS;
#endif


	
}