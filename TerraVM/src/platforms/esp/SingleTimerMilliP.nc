/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2014-2017  Adriano Branco
	
	This file is part of Terra IoT.
	
	Terra IoT is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Terra IoT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  
*/

module SingleTimerMilliP{
 
	provides interface Timer<TMilli> as TimerFrom;
	provides interface Init as SoftwareInit;
}
implementation{

	bool isRunning;
	uint32_t now;
	static os_timer_t localTimer;
	
	// inicializo com zero
	uint32_t t_initial=0;
	uint32_t t_current=0;		
	
	task void tarefaTimer(){ signal TimerFrom.fired();}
	void timer_handler()
	{
		uint32_t currentTime;
//		printf("TimerCalllBack received - isRunning=%d\n",isRunning);
		currentTime = call TimerFrom.getNow();
//		if (currentTime>0) printf("Resultado Timer.getNow: %d\n", currentTime);
		if (isRunning) post tarefaTimer();
//		os_printf("4\n");
	}
	
	command void TimerFrom.startOneShot( uint32_t dt )
	{				
		isRunning = TRUE;
		os_timer_disarm(&localTimer);
		os_timer_setfn(&localTimer, (os_timer_func_t*)timer_handler, NULL);
		os_timer_arm(&localTimer,dt,0);
  	}
	
	command void TimerFrom.stop(){
		os_timer_disarm(&localTimer);
		isRunning = FALSE;
	}

	// extended interface
	
	command void TimerFrom.startOneShotAt( uint32_t t0, uint32_t dt ) {		
		uint32_t t1;				
		isRunning = TRUE;
	
		t1 = (t0+dt) - (call TimerFrom.getNow());
		os_timer_disarm(&localTimer);
		os_timer_setfn(&localTimer, (os_timer_func_t*)timer_handler, NULL);
		os_timer_arm(&localTimer,t1,0);
	}
	
	command uint32_t TimerFrom.getNow(){ 
		uint32_t result;
	
		t_current = system_get_time()/1000; 
		result = (t_current>t_initial)?(t_current - t_initial):(t_current + (0xffffffff - t_initial));
		now+=result;
		//printf("Resultado: %d Corrente Sec: %ld Inicial Sec: %ld\n", result, t_current, t_initial);
		//printf("Now: %d\n", now);
		t_initial = t_current;	
//		 dbg(APPNAME,"TimerP::TimerFrom.getNow(): now=%d\n",now);
		return now;
	}
	
	command void TimerFrom.startPeriodic( uint32_t dt ){}
	command bool TimerFrom.isRunning(){return isRunning;}
	command bool TimerFrom.isOneShot(){return 0;}
	command void TimerFrom.startPeriodicAt( uint32_t t0, uint32_t dt ){}
	command uint32_t TimerFrom.gett0() {return 0;}
	command uint32_t TimerFrom.getdt() {return 0;}

	command error_t SoftwareInit.init(){
		t_initial = system_get_time()/1000;	
		now = 0;
		isRunning = FALSE;		
		return SUCCESS;
	}
}