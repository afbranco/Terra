

generic configuration Analog0C()
{
  provides interface Read<uint16_t>;
}
implementation
{
  components new AdcReadClientC() as ClientC, Analog0ConfigP;
  ClientC.AdcConfigure -> Analog0ConfigP;

  Read = ClientC;
}
