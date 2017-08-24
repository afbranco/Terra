/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2014-2017  Adriano Branco
	
	This file is part of Terra IoT.
	
	Terra IoT is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Terra IoT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  
*/ 
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
#ifdef MODE_INTFLASH
	provides interface ProgStorage;
#endif
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

	components TerraActiveMessageC as AMDriver;
	BS.RadioControl -> AMDriver.SplitControl;
	BS.RadioAMPacket -> AMDriver;
	BS.RadioPacket -> AMDriver.Packet;
	BS.RadioAck -> AMDriver.PacketAcknowledgements;
 	BS.RadioSender -> AMDriver.AMSend;
	BS.AMAux -> AMDriver;
#ifdef LPL_ON
	BS.LowPowerListening -> AMDriver.LowPowerListening;
#endif
	BS.RadioReceiver -> AMDriver.Receive;
	
#ifdef MODULE_CTP
	components CollectionC as Collector;
	BS.RoutingControl -> Collector;
	BS.RootControl -> Collector;
	BS.CtpInfo -> Collector;
	BS.recSendBS -> Collector.Receive[AM_SENDBS];
	components new CollectionSenderC(AM_SENDBS) as sendBS;
	BS.sendBSNet -> sendBS;
#endif

	
	// setData queue - only NEW_DATA_LIST_SIZE last updates
#ifdef MODE_SETDATA
	components new dataQueueC(setDataBuff_t,SET_DATA_LIST_SIZE*2,(char)unique("dataQueueC")) as setDataQueue;
	BS.setDataQ -> setDataQueue;
#endif
	// Bit vector to control memory blocks
	components new vmBitVectorC(CURRENT_MAX_BLOCKS) as Bitmap;
	BS.BM -> Bitmap;	
	// Bit vector to control Others blocks
	components new vmBitVectorC(GENERAL_MAX_BLOCKS) as Bitmap2;
	BS.BMaux -> Bitmap2;	
	
	// IN & OUT Queues
#define  MSG_IN_QSIZE IN_QSIZE
#define  MSG_OUT_QSIZE OUT_QSIZE
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
	components RandomC;
	BS.Random -> RandomC;
	
#ifdef WITH_BSTATION
	components SerialActiveMessageC as SerialAM;
	BS.SerialControl -> SerialAM.SplitControl;
	BS.SerialSender -> SerialAM.AMSend;
	BS.SerialReceiver -> SerialAM.Receive;
	BS.SerialPacket -> SerialAM.Packet;

#ifdef WITH_AUX_BSTATION
	components Serial1ActiveMessageC as Serial1AM;
	BS.Serial1Control -> Serial1AM.SplitControl;
	BS.Serial1Sender -> Serial1AM.AMSend;
	BS.Serial1Receiver -> Serial1AM.Receive;
	BS.Serial1Packet -> Serial1AM.Packet;
#endif
#endif

#ifdef TOSSIM
	components dataSensorC;
	BS.MoteType -> dataSensorC.MoteType;
#endif

/*******************************************
 * ProgStorage component
 *******************************************/
#ifdef MODE_INTFLASH
	components ProgStorageC;
	ProgStorage = ProgStorageC; 
#endif


}