/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Configuration: TerraVMAppC
 * Virtual Machine main control
 * 
 */
configuration TerraVMAppC
{
}
implementation
{
	// Main modules
    components TerraVMC as terra;
    components VMCustomC as custom;
    components BasicServicesC as BS;
#ifdef PRINTF
	components PrintfC, SerialStartC;
#endif

	terra.BSBoot -> BS;
	terra.BSUpload -> BS;
	terra.VMCustom -> custom; 
	terra.BSTimerVM -> BS.BSTimerVM;
	terra.BSTimerAsync -> BS.BSTimerAsync;
	
	// Support modules
	components new QueueC(evtData_t,EVT_QUEUE_SIZE) as  evtQ;
	terra.evtQ -> evtQ;
	

}