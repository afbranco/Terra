#include "setTimer.h"

module SingleTimerMilliP{
 
	provides interface Timer<TMilli> as TimerFrom;
	provides interface Init as SoftwareInit;
}
implementation{

	bool isRunning;
	uint32_t now;
	struct itimerval timer;
	
	// inicializo com zero
	struct timeval t_initial={0};
	struct timeval t_current={0};		
	
	task void tarefaTimer();
	
	task void tarefaTimer(){
		signal TimerFrom.fired();
	}
	
	void sigalrm_handler(int signum)
	{
//		uint32_t currentTime;
//		printf("SIGALRM received - isRunning=%d\n",isRunning);
//		currentTime = call TimerFrom.getNow();
//		if (currentTime>0) printf("Resultado Timer.getNow: %d\n", currentTime);
	
		if (isRunning) post tarefaTimer();
	}
	
	command void TimerFrom.startOneShot( uint32_t dt )
	{				
//		printf("startoneshot\n");
		/* Initial timeout value */
		timer.it_value.tv_sec = dt/1000;
		timer.it_value.tv_usec = (dt%1000)*1000;

		timer.it_interval.tv_sec = 0;
	
		setSignal(SIGALRM, &sigalrm_handler);
		setTimer(ITIMER_REAL, &timer, NULL);		
	}
	
	command void TimerFrom.stop(){
	
		// para parar o timer basta setar o value e o interval para zero
		/*
		timer.it_value.tv_sec = 0;
		timer.it_value.tv_usec = 0;
		timer.it_interval.tv_sec = 0;
		timer.it_interval.tv_usec = 0;
		 */
		isRunning = FALSE;
	
		//printf("STOP\n");
	
		// setSignal(SIGALRM, &sigalrm_handler);
		// setTimer(ITIMER_REAL, &timer, NULL);
	}

	// extended interface
	
	command void TimerFrom.startOneShotAt( uint32_t t0, uint32_t dt ) {		
		uint32_t t1;				
		isRunning = TRUE;
	
		t1 = (t0+dt) - (call TimerFrom.getNow());
	
		timer.it_value.tv_sec = t1/1000;
		timer.it_value.tv_usec = (t1%1000)*1000;
	
		setSignal(SIGALRM, &sigalrm_handler);
		setTimer(ITIMER_REAL, &timer, NULL);	
	}
	
	command uint32_t TimerFrom.getNow(){ 
		uint32_t result;
		//long t1,t2;
	
		gettimeofday(&t_current, NULL);
	
		result= ((t_current.tv_sec*1000) - (t_initial.tv_sec*1000)); // sec to millisec
		result+= ((t_current.tv_usec/1000) - (t_initial.tv_usec/1000)); // microsec to millisec
	
		now+=result;
		//t1 = t_current.tv_sec;
		//t2 = t_initial.tv_sec;
		//printf("Resultado: %d Corrente Sec: %ld Inicial Sec: %ld\n", result, t1, t2);
		//printf("Now: %d\n", now);
	
		t_initial.tv_sec = t_current.tv_sec;
		t_initial.tv_usec = t_current.tv_usec;	
	
//		 dbg(APPNAME,"TimerP::TimerFrom.getNow(): now=%d\n",now);
	
		return now;
	}
	
	command void TimerFrom.startPeriodic( uint32_t dt ){}
	command bool TimerFrom.isRunning(){return 0;}
	command bool TimerFrom.isOneShot(){return 0;}
	command void TimerFrom.startPeriodicAt( uint32_t t0, uint32_t dt ){}
	command uint32_t TimerFrom.gett0() {return 0;}
	command uint32_t TimerFrom.getdt() {return 0;}

	command error_t SoftwareInit.init(){
	
		//printf("inicializei o timer\n");
		gettimeofday(&t_initial, NULL);	
		now = 0;
		isRunning = TRUE;		
		return SUCCESS;
	}
}