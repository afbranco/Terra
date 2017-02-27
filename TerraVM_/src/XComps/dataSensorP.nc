#include "stdio.h"
module dataSensorP{
	provides interface Read<uint16_t> as Temp;
	provides interface Read<uint16_t> as Photo;
	provides interface Read<uint16_t> as Volt;
	uses interface Boot;
}
implementation{
#define MAX_SENSORS 1000
#define F_NAME "sensors.bin"

	bool initialized = FALSE;
	FILE *file;
	typedef struct {uint16_t temp;uint16_t photo; uint16_t volt;} reg_t;
	reg_t lastReg;

    void resetDataFile(){
    	uint16_t i;
    	initialized = TRUE;
		dbg(APPNAME,"dataSensor.resetDataFile():\n");
    	file = fopen(F_NAME,"wb");
    	if (!file) {
			dbg(APPNAME,"dataSensor.resetDataFile(): Unable to create %s file!\n",F_NAME);
    		printf("*******\n    Unable to create %s file!\n *******\n",F_NAME);
    		exit(0);
    	} else {
    		reg_t reg;
	    	for (i=0;i<MAX_SENSORS;i++){
	    		reg.temp=500;	
	    		reg.photo=400;	
	    		reg.volt=1000;	
	    		fwrite(&reg,sizeof(reg_t),1,file);
	    		if (i%100 == 0){
	    			fflush(file);
					//dbg("TVIEW","flush step %d!\n",i);
	    			}
	    	}
    		fclose(file);
			//dbg("TVIEW","Created new data sensor file!\n");
    	}
    }

	event void Boot.booted(){
		if (TOS_NODE_ID == 1) resetDataFile();
	}
	
	
	void readReg(uint16_t id){
		reg_t reg;
    	file = fopen(F_NAME,"rb");
    	if (!file) {
			dbg(APPNAME,"dataSensor.readReg(): Unable to open %s file!\n",F_NAME);
    		printf("*******\n    Unable to open %s file!\n *******\n",F_NAME);
    	} else {
    		fseek(file,id*sizeof(reg_t),SEEK_SET);
    		fread(&reg,sizeof(reg_t),1,file);
    		fclose(file);
    		lastReg.temp = reg.temp;
    		lastReg.photo = reg.photo;
    		lastReg.volt = reg.volt;
    	}
		
	}
	
	task void tempRead(){
		readReg(TOS_NODE_ID);
		signal Temp.readDone(SUCCESS, lastReg.temp);
	}
	task void photoRead(){
		readReg(TOS_NODE_ID);
		signal Photo.readDone(SUCCESS, lastReg.photo);
	}
	task void voltRead(){
		readReg(TOS_NODE_ID);
		signal Volt.readDone(SUCCESS, lastReg.volt);
	}

	command error_t Temp.read(){post tempRead(); return SUCCESS;}
	command error_t Photo.read(){post photoRead(); return SUCCESS;}
	command error_t Volt.read(){post voltRead(); return SUCCESS;}
	
}

