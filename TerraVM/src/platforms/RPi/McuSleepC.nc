#include <unistd.h>
module McuSleepC @safe() {
	
  provides {
    interface McuSleep;
    interface McuPowerState;
  }
}
implementation{
	
	async command void McuSleep.sleep(){
		// sleep until a signal arrives (linux signal)
		sleep(30);
	}

	async command void McuPowerState.update(){
		// TODO Auto-generated method stub
	}
}
