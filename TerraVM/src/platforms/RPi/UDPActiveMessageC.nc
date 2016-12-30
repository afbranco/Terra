configuration UDPActiveMessageC{
	
	provides {
		interface SplitControl;
		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];
    	interface Receive as Snoop[am_id_t id];
		interface AMPacket;
		interface Packet;
		interface PacketAcknowledgements;
    	interface LowPowerListening;
    	interface AMAux;
	}
	
}
implementation{
	
	components UDPActiveMessageP, new TimerMilliC() as SD_Timer, new TimerMilliC() as TimerDelay;
	
	SplitControl = UDPActiveMessageP;
	AMSend = UDPActiveMessageP;
	Receive = UDPActiveMessageP.Receive;
	Snoop = UDPActiveMessageP.Snoop;
	AMPacket = UDPActiveMessageP;
	Packet = UDPActiveMessageP;
	PacketAcknowledgements = UDPActiveMessageP; // provendo
	LowPowerListening = UDPActiveMessageP;
	AMAux = UDPActiveMessageP;
	
	UDPActiveMessageP.sendDoneTimer->SD_Timer; // usando
	UDPActiveMessageP.timerDelay->TimerDelay;
}

