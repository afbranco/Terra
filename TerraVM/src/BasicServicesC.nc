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
#include "CustomVMs/TerraNet/usrMsg.h"
 
configuration BasicServicesC{
	provides interface Boot as BSBoot;
	provides interface BSTimer as BSTimerVM;
	provides interface BSTimer as BSTimerAsync;
	provides interface BSUpload;
	provides interface BSRadio;
}
implementation{
	components MainC;
	components BasicServicesP as BS;

    BS.TOSBoot  -> MainC;
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
	BS.RadioSender -> RadioAM.AMSend;
	BS.RadioAck -> RadioAM.PacketAcknowledgements;
	BS.RadioReceiver -> RadioAM.Receive;

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

	
}