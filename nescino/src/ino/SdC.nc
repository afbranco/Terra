
configuration SdC {
	provides {
    		interface SplitControl as SdControl;
    		interface SdIO;
  	}
}

implementation {
	components SdP;
  	SdP.Control = SdControl;
  	SdP.SdIO = SdIO;
  
  	components Atm128SpiC as Spi;
  	components DigIOC;
  	SdP.spiControl -> Spi.Resource[unique("Atm128SpiC")];
  	SdP.SdSpi -> Spi.SpiByte;
	SdP.Select -> DigIOC.DigIO;

}
