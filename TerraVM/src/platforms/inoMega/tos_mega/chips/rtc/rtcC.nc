configuration rtcC{
	provides interface rtc;
}
implementation{
	components rtcP, MainC;
	//components i2cC as i2c;
	components new Atm128I2CMasterC(TI2CBasicAddr) as i2c;
	rtc = rtcP;
	rtcP.Boot -> MainC;
	rtcP.i2c -> i2c;
	
	components new TimerMilliC() as Timer;
	rtcP.TestTimer -> Timer;
}