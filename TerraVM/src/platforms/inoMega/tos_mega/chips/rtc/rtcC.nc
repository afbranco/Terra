configuration rtcC{
	provides interface rtc;
}
implementation{
	components rtcP, MainC, i2cC as i2c;
	rtc = rtcP;
	rtcP.Boot -> MainC;
	rtcP.i2c -> i2c;
	
	components new TimerMilliC() as Timer;
	rtcP.TestTimer -> Timer;
}