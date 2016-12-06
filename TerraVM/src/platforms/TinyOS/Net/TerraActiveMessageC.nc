configuration TerraActiveMessageC{

  provides {
    interface SplitControl;

    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];

    interface Packet;
    interface AMPacket;
    interface PacketAcknowledgements;
#ifdef LPL_ON
    interface LowPowerListening;
#endif
    interface AMAux;
  }
}
implementation{
	components ActiveMessageC as AM;
	components AMAuxC;
	
	SplitControl = AM;
  
	AMSend       = AM;
	Receive      = AM.Receive;
	Snoop        = AM.Snoop;
	Packet       = AM;
	AMPacket     = AM;
	PacketAcknowledgements = AM;
//	LowPowerListening	 = AM;

	AMAux = AMAuxC;

// Radio RF Power + LPLSend
#ifdef TOSSIM
	components ActiveMessageC as RadioAux;
#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_TELOSB)
	components CC2420ActiveMessageC as RadioAux;
	AMAuxC.RadioAux -> RadioAux;

	#ifdef LPL_ON
	LowPowerListening = RadioAux.LowPowerListening;
	#endif

#elif defined(PLATFORM_IRIS)
	components RF230ActiveMessageC as RadioAux;
	AMAuxC.RadioAux -> RadioAux.PacketTransmitPower;

	#ifdef LPL_ON
	LowPowerListening = RadioAux.LowPowerListening;
	#endif


#elif defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
	components CC1000ControlP as RadioPwr;
	AMAuxC.RadioAux -> RadioPwr;
	components ActiveMessageC as RadioAux;

	#ifdef LPL_ON
	LowPowerListening = RadioAux.LowPowerListening;
	#endif
#endif
  
}