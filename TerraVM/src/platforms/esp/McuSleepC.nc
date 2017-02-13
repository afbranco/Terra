
module McuSleepC @safe() {
	
  provides {
    interface McuSleep;
    interface McuPowerState;
  }
}
implementation{
	
	async command void McuSleep.sleep(){
		// sleep until a signal arrives (linux signal)
		//os_printf("'");
		//system_soft_wdt_feed();
		//os_delay_us(500);
	}

	async command void McuPowerState.update(){
		// TODO Auto-generated method stub
	}
}
