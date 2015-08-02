configuration TSdAppC{
}
implementation{

  components MainC;
  components TSdC as App;
  components new TimerMilliC() as T1;
  
  App -> MainC.Boot;
  App.Timer -> T1;
  
  components Atm128Uart0C as UART0;
  App.Uart0 -> UART0;
  App.Uart0Ctl -> UART0;
  components new QueueC(uint8_t, 200) as LogQ;
  App.LogQ -> LogQ;
    
  components SdC;
  App.SdIO -> SdC;
  App.SdControl -> SdC;
 
  components InoIOC;
  App.InoIO -> InoIOC.InoIO; 
}