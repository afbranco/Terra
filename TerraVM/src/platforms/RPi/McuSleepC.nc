module McuSleepC @safe() {
	
  provides {
    interface McuSleep;
    interface McuPowerState;
  }
}
implementation{
	
	async command void McuSleep.sleep(){
		// TODO Auto-generated method stub
	}

	async command void McuPowerState.update(){
		// TODO Auto-generated method stub
	}
}