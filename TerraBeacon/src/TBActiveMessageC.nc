configuration TBActiveMessageC{

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
	components Atm328pSpiC as SpiC;
	AM.SpiByte -> SpiC;
	AM.SpiPacket -> SpiC;
	AM.FastSpiByte -> SpiC;
	AM.SpiResource -> SpiC.Resource[ CLIENT_ID ];

	components HplAtm328pExtInterruptC as ExtInt;
	AM.nRF24_IRQ -> ExtInt.Int0;
	components HplAtm328pGeneralIOC as IO;
	AM.CSNpin -> IO.PortB0;
	AM.CEpin -> IO.PortB1;
	AM.IRQpin -> IO.PortD2; // Int0
	
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