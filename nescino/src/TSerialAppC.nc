configuration TSerialAppC{
}
implementation{
	
  components MainC;
  components TSerialC as App;
  components new TimerMilliC() as T1;
  components new TimerMilliC() as T2;

  App -> MainC.Boot;
  App.Timer -> T1;
  App.Timer2 -> T2;
  
  components LedsC;
  App.Leds -> LedsC;
 
  components InoIOC;
  App.InoIO -> InoIOC;
  
  
/*
  components Atm128SpiC as SPI;
  App.Spi -> SPI;
  App.SpiCtl -> SPI;
  App.SpiResource -> SPI.Resource[1];
*/

  components Atm128Uart0C as UART0;
  App.Uart0 -> UART0;
  App.Uart0Ctl -> UART0;
/*  
  components XBeeApiC as SERIAL;
  App.Serial -> SERIAL;
*/

  components new QueueC(uint8_t, 100) as LogQ;
  App.LogQ -> LogQ;
  
}

