module SingleTimerMilliP{

  provides interface Init;
  provides interface Timer<TMilli> as TimerMilli;
}
implementation{



	command error_t Init.init(){
		// TODO Auto-generated method stub
		return SUCCESS;
	}

	command uint32_t TimerMilli.getdt(){
		// TODO Auto-generated method stub
		return 0;
	}

	command uint32_t TimerMilli.gett0(){
		// TODO Auto-generated method stub
		return 0;
	}

	command uint32_t TimerMilli.getNow(){
		// TODO Auto-generated method stub
		return 0;
	}

	command void TimerMilli.startOneShotAt(uint32_t t0, uint32_t dt){
		// TODO Auto-generated method stub
	}

	command void TimerMilli.startPeriodicAt(uint32_t t0, uint32_t dt){
		// TODO Auto-generated method stub
	}

	command bool TimerMilli.isOneShot(){
		// TODO Auto-generated method stub
		return TRUE;
	}

	command bool TimerMilli.isRunning(){
		// TODO Auto-generated method stub
		return TRUE;
	}

	command void TimerMilli.stop(){
		// TODO Auto-generated method stub
	}

	command void TimerMilli.startOneShot(uint32_t dt){
		// TODO Auto-generated method stub
	}

	command void TimerMilli.startPeriodic(uint32_t dt){
		// TODO Auto-generated method stub
	}
}