configuration TerraActiveMessageC{

  provides {
    interface SplitControl;
    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Packet;
    interface AMPacket;
    interface PacketAcknowledgements;
    interface Receive as Snoop[am_id_t id];
    interface LowPowerListening;
    interface AMAux;
  }
}
implementation{
  enum {
    CLIENT_ID = unique( "nRFSpi.Resource" ),
  };

#ifdef NRF24
	components nRF24ActiveMessageP as AM;
	components Atm2560SpiC as SpiC;
	AM.SpiByte -> SpiC;
	AM.SpiPacket -> SpiC;
	AM.FastSpiByte -> SpiC;
	AM.SpiResource -> SpiC.Resource[ CLIENT_ID ];

	components HplAtm2560ExtInterruptC as ExtInt;
	AM.nRF24_IRQ -> ExtInt.Int4;
	components HplAtm2560GeneralIOC as IO;
	AM.CSNpin -> IO.PortB4;
	AM.CEpin -> IO.PortB5;
	AM.IRQpin -> IO.PortE4; // Int4
	
	components new TimerMilliC() as TimerDelay;
	AM.TimerDelay -> TimerDelay;
	

#elif defined(NO_RADIO)
	components DummyActiveMessageP as AM;
#elif defined(XBEE0)

#elif defined(XBEE1)
	
#endif

	SplitControl = AM;  
	AMSend       = AM;
	Receive      = AM.Receive;
	Packet       = AM;
	AMPacket     = AM;
	PacketAcknowledgements = AM;
	Snoop        = AM.Snoop;
	LowPowerListening = AM;
	AMAux		= AM;
  
}