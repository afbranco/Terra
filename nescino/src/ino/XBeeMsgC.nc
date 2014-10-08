configuration XBeeMsgC{
	provides interface AMSend[am_id_t id];
	provides interface Receive[am_id_t id];
	provides interface SplitControl as RadioCtl;
	provides interface xLog;
	provides interface PacketAcknowledgements;
	provides interface AMPacket;
	provides interface Packet;
}
implementation{

	components XBeeMsgP, MainC;
	XBeeMsgP.Boot -> MainC;
	AMSend = XBeeMsgP;
	Receive = XBeeMsgP;
	RadioCtl = XBeeMsgP;
	PacketAcknowledgements = XBeeMsgP;
	AMPacket = XBeeMsgP;
	Packet = XBeeMsgP;
	
  	components XBeeApiC;
  	XBeeMsgP.XBeeApi -> XBeeApiC;
  	
  	xLog =XBeeMsgP;
  	
  	components new TimerMilliC() as SendTimeOut;
  	XBeeMsgP.SendTimeOut -> SendTimeOut;
}