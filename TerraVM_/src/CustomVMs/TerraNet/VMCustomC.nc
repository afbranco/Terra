/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
 #include "usrMsg.h"
configuration VMCustomC{
	provides interface VMCustom;
}
implementation{
	components VMCustomP as custom;
	components BasicServicesC as BS;
	custom.VM = VMCustom;
	custom.BSRadio -> BS;
	components RandomC;
	custom.Random -> RandomC;
	
	components SensActC as SA;
	custom.SA -> SA;
	
	// Custom Queues
#ifdef M_MSG_QUEUE
	components new dataQueueC(qData_t,USRMSG_QSIZE,(char)unique("dataQueueC")) as usrDataQ;
	custom.usrDataQ -> usrDataQ;
#endif

	// FFT Module
#ifdef M_FFT
	components kissFFTC as KF;
	custom.KF -> KF;
#endif
	// Volcano Data Module (GModel & Sensor Stream)
#ifdef M_VCN_DAT
	components VolcanoDataC as VCN;
	custom.ReadStream -> VCN.ReadStream;
	custom.SetSensorRtime -> VCN;
	custom.GetSensorRtime -> VCN;
	custom.GModelBlockRead -> VCN.BlockRead;
#endif

}