

generic configuration Analog3C()
{
  provides interface Read<uint16_t>;
}
implementation
{
  components new AdcReadClientC() as ClientC, Analog3ConfigP;
  ClientC.AdcConfigure -> Analog3ConfigP;

  Read = ClientC;
}
