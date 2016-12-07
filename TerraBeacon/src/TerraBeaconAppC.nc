configuration TerraBeaconAppC{
}
implementation{
	components MainC, TerraBeaconP as TB;
    TB.TOSBoot  -> MainC;
    
    components TBActiveMessageC as AMDriver;
	TB.RadioControl -> AMDriver.SplitControl;
	TB.RadioAMPacket -> AMDriver;
	TB.RadioPacket -> AMDriver.Packet;
	TB.RadioAck -> AMDriver.PacketAcknowledgements;
 	TB.RadioSender -> AMDriver.AMSend;
	TB.AMAux -> AMDriver;
	TB.RadioReceiver -> AMDriver.Receive;
	
	components new TimerMilliC() as TimerBeacon;
	TB.TimerBeacon -> TimerBeacon;
	components new TimerMilliC() as sendTimer;
	TB.sendTimer -> sendTimer;
	components RandomC;
	TB.Random -> RandomC;

	components HplAtm328pGeneralIOC as IO;
	TB.PC0 -> IO.PortC0;	
	components new Analog0C() as Ana0;
	TB.Ana0 -> Ana0;
    	
	
}