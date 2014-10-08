configuration test1AppC
{
}
implementation
{
  components MainC;
  components test1C;
  components new TimerMilliC() as T1;

  test1C -> MainC.Boot;
  test1C.Timer -> T1;
  
  components LedsC;
  test1C.Leds -> LedsC;

  
  components Atm128Uart0C as UART0;
  test1C.Uart0 -> UART0;
  test1C.Uart0Ctl -> UART0;


  components XBeeMsgC as XBee;
  test1C.RadioSnd -> XBee;
  test1C.RadioRec -> XBee;
  test1C.RadioCtl -> XBee;
  
  test1C.xLog -> XBee;
  
  components new QueueC(uint8_t, 100) as LogQ;
  test1C.LogQ -> LogQ;
  
}
