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
	components SensActC as SA;
	
	custom.VM = VMCustom;
	custom.BSRadio -> BS;
	custom.SA -> SA;
	
	// Custom Queues
	components new dataQueueC(qData_t,USRMSG_QSIZE,(char)unique("dataQueueC")) as usrDataQ;
	custom.usrDataQ -> usrDataQ;
}