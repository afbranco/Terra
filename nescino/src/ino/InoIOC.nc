configuration InoIOC{
	provides interface InoIO;
}
implementation{
  components InoIOP;
  InoIO = InoIOP.InoIO;
  components new gAdcC();
  InoIOP.gAdc -> gAdcC;  
 
  components DigIOC;
  InoIOP.DigIO -> DigIOC;
  
  components MicaBusC as Bus;
  InoIOP.pInt0 -> Bus.Int0_Interrupt;
  InoIOP.pInt1 -> Bus.Int1_Interrupt;
  InoIOP.pInt2 -> Bus.Int2_Interrupt;
  InoIOP.pInt3 -> Bus.Int3_Interrupt;
  
  components CounterMicro32C as Clock;
  components MeasureClockC;
  InoIOP.clock -> Clock;
  InoIOP.Atm128Calibrate -> MeasureClockC;
  
  components new TimerMilliC() as TimerPulse0;
  components new TimerMilliC() as TimerPulse1;
  components new TimerMilliC() as TimerPulse2;
  components new TimerMilliC() as TimerPulse3;
  InoIOP.pulseTimer0 -> TimerPulse0;
  InoIOP.pulseTimer1 -> TimerPulse1;
  InoIOP.pulseTimer2 -> TimerPulse2;
  InoIOP.pulseTimer3 -> TimerPulse3;

}