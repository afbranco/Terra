
#include "XBeeApi.h"

module XBeeApiP{
	provides interface XBeeApi;
	uses interface Boot;
	uses interface SerialFrameComm as UART1_BYTE;
	uses interface StdControl as XBeeCtl;

}
implementation{

	uint8_t state;
	nx_uint16_t recFrameLen;
	nx_uint16_t recFrameLenAux;
	uint8_t frameLengthCtl;
	uint8_t recFrame[MAX_API_FRAME_LEN];
	uint8_t recFrameAux[MAX_API_FRAME_LEN];
	nx_uint16_t  recFrameIdx;
	uint8_t recCheckSum;

	uint8_t sendFrame[MAX_API_FRAME_LEN];
	uint8_t sendFrameAux[MAX_API_FRAME_LEN];
	nx_uint16_t sendFrameIdx;
	nx_uint16_t sendFrameLen;
	error_t sendStatus;

	uint8_t configIdx;
	
//	uint8_t logData[10];

	// prototypes
	task void procRecFrame();

	event void Boot.booted(){
		atomic{state = SM_CONFIG;}
		call XBeeCtl.start();
		state = SM_WAITING_DELIMITER;

		//logData[0]=':';
		//signal XBeeApi.logUSB0(logData,1);
	}

	async event void UART1_BYTE.delimiterReceived(){
		state = SM_WAITING_LENGTH;
		recFrameLen = 0;
		frameLengthCtl=0;
	}
	async event void UART1_BYTE.dataReceived(uint8_t data){
		switch (state) {
			case SM_WAITING_DELIMITER :
				dbg("XBeeApi","XBeeApi::UART1_BYTE.dataReceived(): Discarding any data before delimiter.\n"); 
				break;
			case SM_WAITING_LENGTH : 
				if (frameLengthCtl == 0) {
					recFrameLen = data*256;
					frameLengthCtl = 1;
				} else {
					frameLengthCtl = 2;
					recFrameLen = recFrameLen + data;
					if (recFrameLen > MAX_API_FRAME_LEN) {
						state = SM_WAITING_DELIMITER;
						dbg("XBeeApi","XBeeApi::UART1_BYTE.dataReceived(): Wrong frame length = %d.\n",frameLength); 
					} else {
						state = SM_READING_FRAME_DATA;
						recFrameIdx = 0;
						recCheckSum = 0;
					}
				}
				break;
			case SM_READING_FRAME_DATA : 
				recFrame[recFrameIdx] = data;
				recCheckSum = (uint8_t)((recCheckSum + data) & 0x00ff);
				recFrameIdx++;
				if (recFrameIdx >= recFrameLen) state = SM_WAITING_CHECKSUM;
				break;
			case SM_WAITING_CHECKSUM : 
				recCheckSum = (uint8_t)(recCheckSum + data);
				if (recCheckSum == 0xff) {
					memcpy(recFrameAux,recFrame,recFrameLen);
					recFrameLenAux = recFrameLen;
					post procRecFrame();
				} else {
					dbg("XBeeApi","XBeeApi::UART1_BYTE.dataReceived(): Rec Checksum error - %d.\n",recCheckSum);
				}
				state = SM_WAITING_DELIMITER;
				break;
		}

	}

	void xApiStatus(){
		signal XBeeApi.modemStatus(recFrameAux[1]);
	}
	void xApiATCommResp(){
		uint8_t valuesLen = (uint8_t)(*(nx_uint16_t*)&recFrameAux[1] - 5);
		signal XBeeApi.responseAT(recFrameAux[1], &recFrameAux[2], recFrameAux[4], &recFrameAux[5], valuesLen);
	}
	void xApiATRemCommResp(){
		uint8_t valuesLen = (uint8_t)(*(nx_uint16_t*)&recFrameAux[1] - 15);
		signal XBeeApi.remResponseAT(recFrameAux[1], *(nx_uint16_t*)&recFrameAux[10], &recFrameAux[12], recFrameAux[14], &recFrameAux[15], valuesLen);
	}
	void xApiTxStat(){
		signal XBeeApi.txStatus(recFrameAux[1], recFrameAux[2]);		
	}
	void xApiRxPacket(){
		uint8_t dataLen = (uint8_t)(recFrameLenAux - 5);
		signal XBeeApi.rxPacket((recFrameAux[1]*256+recFrameAux[2]), recFrameAux[3], recFrameAux[4], recFrameAux+5, dataLen);		
	}
	void xApiRxPacketIO(){
		uint8_t dataLen = (uint8_t)(*(nx_uint16_t*)&recFrameAux[1] - 5);
		signal XBeeApi.rxPacket(*(nx_uint16_t*)&recFrameAux[1], recFrameAux[3], recFrameAux[4], &recFrameAux[5], dataLen);		
	}

	task void procRecFrame(){
		uint8_t cmdId;
		cmdId = recFrameAux[0]
		dbg("XBeeApi","XBeeApi::procFrame(): cmdId=%02x\n",cmdId);
		switch(cmdId){
			case XAPI_STATUS           : xApiStatus();        break;
			case XAPI_AT_COMM_RESP     : xApiATCommResp();    break;
			case XAPI_AT_REM_COMM_RESP : xApiATRemCommResp(); break;
			case XAPI_TX_STAT          : xApiTxStat();        break;
			case XAPI_RX_PACKET        : xApiRxPacket();      break;
			case XAPI_RX_PACKET_IO     : xApiRxPacketIO();    break;
			default : break;
		}
	}

	uint8_t calcChecksum(uint8_t* data){
		uint8_t checksum = 0;
		uint16_t i;
		nx_uint16_t len;
		len = data[1]*256 + data[2];
		for (i=0; i<len; i++) checksum = ((checksum + data[i+3]) & 0x00ff);
		checksum = 0xff-checksum;
		return checksum;
	}

	task void signalCommandStatus(){
		switch (sendFrame[3]) {
			case XAPI_AT_COMM_REQ : signal XBeeApi.commandATDone(sendStatus); break;
			case XAPI_AT_COMMQ_REQ : signal XBeeApi.commandATQueueDone(sendStatus); break;
			case XAPI_AT_REM_COMM_REQ : signal XBeeApi.remCommandATDone(sendStatus); break;
			case XAPI_TX_REQ :  signal XBeeApi.txReqDone(sendStatus); break;			
		}
	}
	
	task void procSendFrame(){
		sendStatus = SUCCESS;
		if (sendFrameIdx >= sendFrameLen+4) {
			post signalCommandStatus();
		} else {
			if (sendFrameIdx==0){
				sendStatus = call UART1_BYTE.putDelimiter();
				sendFrameIdx++;
			} else {
				sendStatus = call UART1_BYTE.putData(sendFrame[sendFrameIdx]);
				sendFrameIdx++;			
			}
			if (sendStatus != SUCCESS) post signalCommandStatus();
		}
	}


	async event void UART1_BYTE.putDone(){
		post procSendFrame();		
	}

	/**
	 * XBee API Commands
	 */

	command void XBeeApi.commandAT(uint8_t ackId, uint8_t *cmd, uint8_t *param, uint8_t paramLen){
		uint8_t i;
		sendFrameAux[0] = 0; // start delimiter dummy
		sendFrameLen = 1 + 1 + 2 + paramLen;
		*(nx_uint16_t*)&sendFrameAux[1] = sendFrameLen;
		sendFrameAux[3] = XAPI_AT_COMM_REQ;
		sendFrameAux[4] = ackId;
		sendFrameAux[5] = cmd[0];
		sendFrameAux[6] = cmd[1];
		for (i=0; i < paramLen; i++) sendFrameAux[7+i]=param[i];
		sendFrameAux[7+paramLen]= calcChecksum(sendFrameAux);
		memcpy(sendFrame,sendFrameAux,sendFrameLen+4);
		sendFrameIdx=0;
		post procSendFrame();
	}

	command void XBeeApi.commandATQueue(uint8_t ackId, uint8_t *cmd, uint8_t *param, uint8_t paramLen){
		uint8_t i;
		sendFrameAux[0] = 0; // start delimiter dummy
		sendFrameLen = 1 + 1 + 2 + paramLen;
		*(nx_uint16_t*)&sendFrameAux[1] = sendFrameLen;
		sendFrameAux[3] = XAPI_AT_COMMQ_REQ;
		sendFrameAux[4] = ackId;
		sendFrameAux[5] = cmd[0];
		sendFrameAux[6] = cmd[1];
		for (i=0; i < paramLen; i++) sendFrameAux[7+i]=param[i];
		sendFrameAux[7+paramLen]= calcChecksum(sendFrameAux);
		memcpy(sendFrame,sendFrameAux,sendFrameLen+4);
		sendFrameIdx=0;
		post procSendFrame();
	}

	command void XBeeApi.remCommandAT(uint8_t ackId, nx_uint16_t target, uint8_t opt, uint8_t *cmd, uint8_t *param, uint8_t paramLen){
		uint8_t i;
		sendFrameAux[0] = 0; // start delimiter dummy
		sendFrameLen = 1 + 1 + 8 + 2 + 1 + 2 + paramLen;
		*(nx_uint16_t*)&sendFrameAux[1] = sendFrameLen;
		sendFrameAux[3] = XAPI_AT_REM_COMM_REQ;
		sendFrameAux[4] = ackId;
		for (i=0; i < 8; i++) sendFrameAux[5+i]=0; // don't use 64-bit address
		*(nx_uint16_t*)&sendFrameAux[13] = target;
		sendFrameAux[15] = opt;
		sendFrameAux[16] = cmd[0];
		sendFrameAux[17] = cmd[1];
		for (i=0; i < paramLen; i++) sendFrameAux[18+i]=param[i];
		sendFrameAux[18+paramLen]= calcChecksum(sendFrameAux);
		memcpy(sendFrame,sendFrameAux,sendFrameLen+4);
		sendFrameIdx=0;
		post procSendFrame();
	}

	command void XBeeApi.txReq(uint8_t ackId, nx_uint16_t target, uint8_t opt, uint8_t *Data, uint8_t dataLen){
		uint8_t i;
		sendFrameAux[0] = 0; // start delimiter dummy
		sendFrameLen = 1 + 1 + 2 + 1 + dataLen;
		sendFrameAux[1] = (uint8_t)(sendFrameLen >> 8);
		sendFrameAux[2] = (uint8_t)(sendFrameLen & 0x00ff);
		sendFrameAux[3] = XAPI_TX_REQ;
		sendFrameAux[4] = ackId;
		sendFrameAux[5] = (uint8_t)(target >> 8);
		sendFrameAux[6] = (uint8_t)(target & 0x00ff);
		sendFrameAux[7] = opt;
		for (i=0; i < dataLen; i++) sendFrameAux[8+i]= Data[i];
		sendFrameAux[8+dataLen]= calcChecksum(sendFrameAux);
		memcpy(sendFrame,sendFrameAux,sendFrameLen+4);
		sendFrameIdx=0;
		post procSendFrame();
	}
}