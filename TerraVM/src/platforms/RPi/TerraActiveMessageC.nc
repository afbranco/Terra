configuration TerraActiveMessageC{

  provides {
    interface SplitControl;

    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];

    interface Packet;
    interface AMPacket;
    interface PacketAcknowledgements;
    interface LowPowerListening;
    interface AMAux;
  }
}
implementation{
	components UDPActiveMessageC as AM;
	
	SplitControl = AM;
  
	AMSend       = AM;
	Receive      = AM.Receive;
	Snoop        = AM.Snoop;
	Packet       = AM;
	AMPacket     = AM;
	PacketAcknowledgements = AM;
	LowPowerListening = AM;
	AMAux		= AM;
  
}