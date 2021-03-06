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

#include<stdio.h>
#include <fcntl.h>
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
	uint8_t localMoteType=1;
	
	// State control
	enum state_t {START, SEND, DONE, EXIT};
	enum {RETRY_TIMER=3000};
	uint8_t state = START;
	uint16_t lastBlock = 0;
	uint8_t retry=0;
	bool persistFlag=FALSE;
	
void printMsg(uint8_t* msg, uint8_t len){
	uint8_t i;
	for (i=0; i< len; i++) printf("%02x:%03d, ",msg[i],msg[i]);
	printf("\n");
}

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
		newProgVersion.moteType = localMoteType;
		newProgVersion.persistFlag = persistFlag;
	
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
printf("Error: Could not open file %s to write -- errno=%d\n",filename,errno);
			exit(EXIT_FAILURE);	
		}
		sprintf(linein[0],"#%s",asctime(localtime(&t)));
		fprintf(file,linein[0]);
		fprintf(file,linein[1]);
		fprintf(file,"lastVersionSeq=%d\n",versionId);
		fclose(file);
printf("Passo 6\n");
		return versionId;
	}

	event void Boot.booted(){
		char inputLine[200];
		char filename[200], persistChar;
		char * pch;
		int count=0;
		int numRead;
		
		fcntl(0, F_SETFL, fcntl(0, F_GETFL) | O_NONBLOCK);
		numRead = read(0,inputLine,200);
		if (numRead < 3){
			printf("Error: missing input arguments.\n");
			printf("Syntax: echo \"/filepath/file.vmx flag\" | ./build/rpi/main.exe\n");
			exit(1);
		}
		inputLine[numRead]=0;
		//printf("len:%d,Input:|%s|\n",numRead,inputLine);

		localVersionId = getVersionId();

		pch = strtok(inputLine," ");
		if (pch == NULL) {
			printf("Error: missing input arguments.\n");
			printf("Syntax: echo \"/filepath/file.vmx flag\" | ./build/rpi/main.exe\n");
			exit(1);
		}
		strcpy(filename,pch);
		
		pch = strtok(NULL," ");
		if (pch == NULL) {
			printf("Error: missing input arguments.\n");
			printf("Syntax: echo \"/filepath/file.vmx flag\" | ./build/rpi/main.exe\n");
			exit(1);
		}
		persistChar = (pch[0]>'a')?pch[0]-('a'-'A'):pch[0];
		if (persistChar != 'Y' && persistChar != 'N') {
			printf("Error: Persistence Flag must be Y or N.\n");
			printf("Syntax: echo \"/filepath/file.vmx flag\" | ./build/rpi/main.exe\n");
			exit(1);
		}	
		printf("Filename=|%s|, persistFlag=|%c|\n",filename,persistChar);
		persistFlag = (persistChar == 'Y');
		ReadVMXFile(filename);
	
		call UDPControl.start();
	}
	
	event void UDPControl.startDone(error_t error){
		error_t stat;	
		state=SEND;
		memcpy(call Packet.getPayload(&sendMessage, call Packet.maxPayloadLength()), &newProgVersion, sizeof(newProgVersion_t));
		dbg(APPNAME, "UDP::UDPSender(): maxSize=%d\n", call Packet.maxPayloadLength());
		//printMsg(&sendMessage,sizeof(newProgVersion_t));
		stat =  call UDPSender.send[AM_NEWPROGVERSION](AM_BROADCAST_ADDR, &sendMessage, sizeof(newProgVersion_t));
		// Time out of x seconds -> to check state
		call Timer1.startOneShot(RETRY_TIMER);
printf("Passo 7\n");

	}

	event void UDPSender.sendDone[am_id_t id](message_t *msg, error_t error){
	}

	event message_t * UDPReceiver.receive[am_id_t id](message_t *msg, void *payload, uint8_t len){
		// TODO Auto-generated method stub
		newProgBlock_t* newProgBlock;
		dbg(APPNAME, "UDPReceiver::receive(): msg=%d, am_id=%d\n", call AMPacket.source(msg), id);
		if (id == AM_REQPROGBLOCK)
		{
			reqProgBlock_t* reqMsg = payload;
			call Timer1.stop();
			dbg(APPNAME, "UDPReceiver::receive(): reqOper=%d, versionId=%d, blockId=%d, localVersionId=%d\n", reqMsg->reqOper, reqMsg->versionId, reqMsg->blockId, localVersionId);
			if (localVersionId == reqMsg->versionId){
				newProgBlock = call Packet.getPayload(&sendMessage, call Packet.maxPayloadLength());
				
				newProgBlock->versionId = localVersionId;
				newProgBlock->blockId = reqMsg->blockId;
				newProgBlock->moteType = localMoteType;
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
