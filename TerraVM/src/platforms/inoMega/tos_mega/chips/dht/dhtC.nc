configuration dhtC{
	provides interface dht;	
}
implementation{
	components MainC;
	components dhtP, CounterMicro32C as CounterMicro;
	dht = dhtP.dht;
	dhtP.Boot -> MainC;
	dhtP.CounterMicro -> CounterMicro;

	components HplAtm2560ExtInterruptC as ExtInt;
	dhtP.Int0 -> ExtInt.Int0;
	dhtP.Int1 -> ExtInt.Int1;
	dhtP.Int2 -> ExtInt.Int2;
	dhtP.Int3 -> ExtInt.Int3;
	
	components new TimerMilliC() as Timer;
	dhtP.Timer -> Timer;
}