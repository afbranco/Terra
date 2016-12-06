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

	// Custom Queues
#ifdef M_MSG_QUEUE
	components new dataQueueC(qData_t,USRMSG_QSIZE,(char)unique("dataQueueC")) as usrDataQ;
	custom.usrDataQ -> usrDataQ;
#endif

}