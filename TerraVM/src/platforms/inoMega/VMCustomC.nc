
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
	components LedsC;
	custom.LEDS -> LedsC;

	components HplAtm2560GeneralIOC as IO;
	custom.D22 -> IO.PortA0;
	
	components new Analog0C() as Ana0;
	custom.Ana0 -> Ana0;
	
	// Custom Queues
#ifdef M_MSG_QUEUE
	components new dataQueueC(usrMsg_t,USRMSG_QSIZE,(char)unique("dataQueueC")) as usrDataQ;
	custom.usrDataQ -> usrDataQ;
#endif

}