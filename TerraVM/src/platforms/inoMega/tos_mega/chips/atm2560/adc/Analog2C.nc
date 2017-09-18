

generic configuration Analog2C()
{
  provides interface Read<uint16_t>;
}
implementation
{
  components new AdcReadClientC() as ClientC, Analog2ConfigP;
  ClientC.AdcConfigure -> Analog2ConfigP;

  Read = ClientC;
}
