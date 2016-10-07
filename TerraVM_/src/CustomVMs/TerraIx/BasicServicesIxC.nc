/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Configuration: BasicServicesIxC
 * Basic Services - Main VM Timer, Simple Radio, and Code Upload/Forwarder
 * 
 */
 
#include "BasicServicesIx.h"
 
configuration BasicServicesIxC{
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
	components BasicServicesIxP as BS;
   	// Provided interfaces wire
   	BSBoot = BS.BSBoot;	
	BSTimerVM = BS.BSTimerVM;
	BSTimerAsync = BS.BSTimerAsync;
	BSUpload = BS.BSUpload;
	BSRadio = BS.BSRadio;



	// Communication wire

	// Bit vector to control memory blocks
	components new vmBitVectorC(CURRENT_MAX_BLOCKS) as Bitmap;
	BS.BM -> Bitmap;	

	// Timers
	components new TimerMilliC() as TimerVM;	
	components new TimerMilliC() as TimerAsync;
	BS.TimerVM -> TimerVM;
	BS.TimerAsync -> TimerAsync;


/*******************************************
 * Optional components
 *******************************************/

}