

generic configuration Analog1C()
{
  provides interface Read<uint16_t>;
}
implementation
{
  components new AdcReadClientC() as ClientC, Analog1ConfigP;
  ClientC.AdcConfigure -> Analog1ConfigP;

  Read = ClientC;
}
