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
#ifdef IX
    components BasicServicesIxC as BS;
#else
    components BasicServicesC as BS;
#endif
	terra.BSBoot -> BS;
	terra.BSUpload -> BS;
	terra.BSTimerVM -> BS.BSTimerVM;
	terra.BSTimerAsync -> BS.BSTimerAsync;

#ifdef PRINTF
	components PrintfC, SerialStartC;
#endif
    components VMCustomC as custom;
	terra.VMCustom -> custom; 

	components new QueueC(evtData_t,EVT_QUEUE_SIZE) as  evtQ;
	terra.evtQ -> evtQ;

}