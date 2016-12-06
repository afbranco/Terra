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
    components BasicServicesC as BS;
	terra.BSBoot -> BS;
	terra.BSUpload -> BS;
	terra.BSTimerVM -> BS.BSTimerVM;
	terra.BSTimerAsync -> BS.BSTimerAsync;

    components VMCustomC as custom;
	terra.VMCustom -> custom; 

	components new QueueC(evtData_t,EVT_QUEUE_SIZE) as  evtQ;
	terra.evtQ -> evtQ;

}