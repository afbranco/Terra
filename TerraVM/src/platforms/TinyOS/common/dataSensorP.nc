#include "stdio.h"
module dataSensorP{
	provides interface Get<uint8_t> as MoteType;
	provides interface Read<uint16_t> as Temp;
	provides interface Read<uint16_t> as Photo;
	provides interface Read<uint16_t> as Volt;
	uses interface Boot;
}
implementation{
#define MAX_SENSORS 100
#define F_NAME "sensors.bin"

	bool initialized = FALSE;
	FILE *file;
	typedef struct {uint16_t temp;uint16_t photo; uint16_t volt; uint16_t moteType;} reg_t;
	reg_t lastReg;

    void resetDataFile(){
    	uint8_t i;
		reg_t data[MAX_SENSORS];
    	initialized = TRUE;
		dbg(APPNAME,"dataSensor.resetDataFile():\n");
    	for (i=0;i<MAX_SENSORS;i++){
    		data[i].temp=500;	
    		data[i].photo=400;	
    		data[i].volt=1000;	
    		data[i].moteType=1;	
    	}
    	file = fopen(F_NAME,"wb");
    	if (!file) {
			dbg(APPNAME,"dataSensor.resetDataFile(): Unable to create %s file!\n",F_NAME);
    		printf("*******\n    Unable to create %s file!\n *******\n",F_NAME);
    		exit(0);
    	} else {
    		fwrite(&data,MAX_SENSORS*sizeof(reg_t),1,file);
    		fclose(file);
    	}
    }

	event void Boot.booted(){
		if (TOS_NODE_ID == 1) {
    		file = fopen(F_NAME,"rb");
	    	if (!file) {
				resetDataFile();
			} else {
	    		fclose(file);
			}
		}
	}
	
	
	void readReg(){
		reg_t data[MAX_SENSORS];
    	file = fopen(F_NAME,"rb");
    	if (!file) {
			dbg(APPNAME,"dataSensor.readReg(): Unable to open %s file!\n",F_NAME);
    		printf("*******\n    Unable to open %s file!\n *******\n",F_NAME);
    		lastReg.temp = 0;
    		lastReg.photo = 0;
    		lastReg.volt = 0;
    		lastReg.moteType = 0;
    	} else {
    		fread(data,MAX_SENSORS*sizeof(reg_t),1,file);
    		fclose(file);
    		lastReg.temp = data[TOS_NODE_ID].temp;
    		lastReg.photo = data[TOS_NODE_ID].photo;
    		lastReg.volt = data[TOS_NODE_ID].volt;
    		lastReg.moteType = data[TOS_NODE_ID].moteType;
    	}
		
	}
	
	task void tempRead(){
		readReg();
		signal Temp.readDone(SUCCESS, lastReg.temp);
	}
	task void photoRead(){
		readReg();
		signal Photo.readDone(SUCCESS, lastReg.photo);
	}
	task void voltRead(){
		readReg();
		signal Volt.readDone(SUCCESS, lastReg.volt);
	}

	command uint8_t MoteType.get(){readReg(); return (uint8_t)lastReg.moteType;}
	
	command error_t Temp.read(){post tempRead(); return SUCCESS;}
	command error_t Photo.read(){post photoRead(); return SUCCESS;}
	command error_t Volt.read(){post voltRead(); return SUCCESS;}
	
}

