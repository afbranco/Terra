/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Interface: BSTimer
 * Main VM Timer operation
 * 
 */
 
interface BSTimer{	

	command void startOneShot(uint32_t dt);
	command uint32_t getNow();
	command bool isRunning();
	command void stop();
	event void fired();
	
}