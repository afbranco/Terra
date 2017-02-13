
configuration EspUsart0C
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
  components EspUsart0P as EspUsartP;

  StdControl = EspUsartP;
  UartStream = EspUsartP;
  SerialFlush = EspUsartP;

}
