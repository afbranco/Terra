#include<stdio.h>
#include<stdlib.h>
#include <errno.h>
#include <time.h>
#include "BasicServices.h"

#define LINE_SIZE 1000

module TerraUdpUploadC{
	
	uses { 
		interface Boot;
		interface AMPacket;
		interface AMSend as UDPSender[am_id_t id];
		interface Receive as UDPReceiver[am_id_t id];
		interface SplitControl as UDPControl;
		interface Packet;
		interface PacketAcknowledgements;
	
		interface Timer<TMilli> as Timer1;
	}
	
}
implementation{
	
	message_t sendMessage;
	FILE *file;
	newProgVersion_t newProgVersion;
	
	char line[LINE_SIZE];
	nx_uint8_t blocks[CURRENT_MAX_BLOCKS][BLOCK_SIZE];
	
	int j=-1, k=0;
	int start,end,tracks,wClocks,asyncs,wClock0,gate0,inEvts,async0;
	
	uint16_t Addr=0;
	uint16_t blockId = 0;
	uint16_t localVersionId = 2;
	
	// State control
	enum state_t {START, SEND, DONE, EXIT};
	enum {RETRY_TIMER=3000};
	uint8_t state = START;
	uint16_t lastBlock = 0;
	uint8_t retry=0;
	
	void ReadVMXFile(char* file_name){
		dbg(APPNAME, "ReadVMXFile:%s\n",file_name);
		file = fopen(file_name, "r");
		if (file == NULL){
			dbgerror(APPNAME, "Error::Could not open file %s\n",file_name);
			exit(EXIT_FAILURE);	
		}	
	
		// populando a estrutura com a primeira linha
		fscanf(file, "%d%d%d%d%d%d%d%d%d", &start, &end, &tracks, &wClocks, &asyncs, &wClock0, 
				&gate0, &inEvts, &async0);
	
		newProgVersion.versionId = (nx_uint16_t) localVersionId;
		newProgVersion.blockStart = (nx_uint16_t) start/BLOCK_SIZE;
		newProgVersion.blockLen = (nx_uint16_t) (end/BLOCK_SIZE)+1-(newProgVersion.blockStart);
		lastBlock = (end/BLOCK_SIZE);
		
		newProgVersion.startProg = (nx_uint16_t) start;
		newProgVersion.endProg = (nx_uint16_t) end;
		newProgVersion.nTracks = (nx_uint16_t) tracks; 
		newProgVersion.wClocks = (nx_uint16_t) wClocks;
		newProgVersion.asyncs = (nx_uint16_t) asyncs;
		newProgVersion.wClock0 = (nx_uint16_t) wClock0;
		newProgVersion.gate0 = (nx_uint16_t) gate0;
		newProgVersion.inEvts = (nx_uint16_t) inEvts;
		newProgVersion.async0 = (nx_uint16_t) async0;
	
		while(fgets(line,LINE_SIZE,file) != NULL){
			if (j>=0){ // ignores first line
				if(k<BLOCK_SIZE){
					sscanf(line, "%x\n", &blocks[blockId][k]);
					//printf("%2x\n", blocks[blockId][k]);// ok
				}
				k++;
			}
			j++;
			if (k==BLOCK_SIZE){
				blockId++;
				j=0;
				k=0;
			}
		}
		fclose(file);
		if(k<BLOCK_SIZE && k!=0){ // if the last block doesn't have 24 bytes
			// complete with zeros
			while(k<BLOCK_SIZE){
				blocks[blockId][k] = 0;
				k++;
			}
		}	
	}

	uint16_t getVersionId(){
		uint16_t versionId;
		char linein[3][100];
		uint8_t len=100;
		int readLen;
		char filename[500];
		time_t t = time(NULL);

		strcpy(filename,getenv("HOME"));
		strcat(filename,"/.TerraConfig");
		file = fopen(filename, "r");
printf("Passo 1\n");
		if (file == NULL){ // File doesn't exist, start from Version=2;
			versionId = 2;
			sprintf(linein[1],"lastDir=%s\n",getenv("HOME"));
printf(linein[0]);
printf(linein[1]);
printf("Passo 2\n");
		} else { // Read file version number
printf("Passo 3\n");
			fgets(linein[0],len,file);
			fgets(linein[1],len,file);
printf(linein[0]);
printf(linein[1]);
printf("Passo 3.1\n");
			if (fgets(linein[2], len, file) == NULL){
				dbgerror(APPNAME,"Error::Invalid value inside '~/.TerraConfig': %s\n",line);
				exit(0);
			} else {
				char* pos = strchr(linein[2],'=');
printf(linein[2]);
printf(&pos[1]);
printf("Passo 4\n");
				errno=0;
				versionId = strtol(&pos[1],NULL,10);
				if (errno != 0) {
					dbgerror(APPNAME,"Error::Invalid value inside '~/.TerraConfig': %s\n",line);
					exit(0);
				}
			}	
			fclose(file);
		}
printf("Passo 5\n");
		// Increment VersionId value
		versionId++;
		if (versionId > 0xfffe) versionId=2;
		// Save the new value
		file = fopen(filename, "w");
		if (file == 0){ // Write permission?!
			dbgerror(APPNAME, "Error::Could not open file %s to write -- errno=%d\n",filename,errno);
			exit(EXIT_FAILURE);	
		}
		sprintf(linein[0],"#%s",asctime(localtime(&t)));
		fprintf(file,linein[0]);
		fprintf(file,linein[1]);
		fprintf(file,"lastVersionSeq=%d\n",versionId);
		fclose(file);
		return versionId;
	}

	event void Boot.booted(){
		char filename[200];
		localVersionId = getVersionId();
		gets(filename);
		ReadVMXFile(filename);
	
		call UDPControl.start();
	}
	
	event void UDPControl.startDone(error_t error){
		error_t stat;	
		state=SEND;
		memcpy(call Packet.getPayload(&sendMessage, call Packet.maxPayloadLength()), &newProgVersion, sizeof(newProgVersion_t));
		dbg(APPNAME, "UDP::UDPSender(): maxSize=%d\n", call Packet.maxPayloadLength());
		stat =  call UDPSender.send[AM_NEWPROGVERSION](AM_BROADCAST_ADDR, &sendMessage, sizeof(newProgVersion_t));
		// Time out of x seconds -> to check state
		call Timer1.startOneShot(RETRY_TIMER);
	}

	event void UDPSender.sendDone[am_id_t id](message_t *msg, error_t error){
	}

	event message_t * UDPReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
		// TODO Auto-generated method stub
		newProgBlock_t* newProgBlock;
		dbg(APPNAME, "UDPReceiver::receive(): msg=%d, am_id=%d\n", call AMPacket.source(&msg), id);
		if (id == AM_REQPROGBLOCK)
		{
			reqProgBlock_t* reqMsg = payload;
			call Timer1.stop();
			dbg(APPNAME, "UDPReceiver::receive(): reqOper=%d, versionId=%d, blockId=%d, localVersionId=%d\n", reqMsg->reqOper, reqMsg->versionId, reqMsg->blockId, localVersionId);
			if (localVersionId == reqMsg->versionId){
				newProgBlock = call Packet.getPayload(&sendMessage, call Packet.maxPayloadLength());
				
				newProgBlock->versionId = localVersionId;
				newProgBlock->blockId = reqMsg->blockId;
				memcpy(newProgBlock->data, blocks[reqMsg->blockId], BLOCK_SIZE);
				call UDPSender.send[AM_NEWPROGBLOCK](AM_BROADCAST_ADDR, &sendMessage, sizeof(newProgBlock_t));
				
				dbg(APPNAME, "UDPReceiver::receive(): ENVIOU\n");
				if (reqMsg->blockId == lastBlock) state = DONE; else state=SEND;
			}
			call Timer1.startOneShot(RETRY_TIMER);
		}	
		return msg;
	}

	event void Timer1.fired(){
		retry++;
		if (state == SEND){
			error_t stat;	
			dbg(APPNAME, "Re-sending.. %d times\n",retry);
			state=SEND;
			memcpy(call Packet.getPayload(&sendMessage, call Packet.maxPayloadLength()), &newProgVersion, sizeof(newProgVersion_t));
			dbg(APPNAME, "UDP::UDPSender(): maxSize=%d\n", call Packet.maxPayloadLength());
			stat =  call UDPSender.send[AM_NEWPROGVERSION](AM_BROADCAST_ADDR, &sendMessage, sizeof(newProgVersion_t));
			call Timer1.startOneShot(RETRY_TIMER);
		}
		if (state == DONE || retry >= 3){
			dbg(APPNAME, "Finalizando..\n");
			call Timer1.stop();
			call UDPControl.stop();
		}
		
	}

	event void UDPControl.stopDone(error_t error){
		exit(SUCCESS);
	}
}