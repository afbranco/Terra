

configuration PlatformSerialC
{
  provides
  {
    interface StdControl;
    interface UartStream;
    interface SerialFlush;
  }
}
implementation
{
  components EspUsart0C as Usart;
  
  StdControl  = Usart;
  UartStream  = Usart;
  SerialFlush = Usart;

}
