interface XBeeApi{
	
	command void commandAT(uint8_t ackId, uint8_t* cmd, uint8_t* param, uint8_t paramLen);
	command void commandATQueue(uint8_t ackId, uint8_t* cmd, uint8_t* param, uint8_t paramLen);
	command void remCommandAT(uint8_t ackId, nx_uint16_t target, uint8_t opt, uint8_t* cmd, uint8_t* param, uint8_t paramLen);
	command void txReq(uint8_t ackId, nx_uint16_t target, uint8_t opt, uint8_t* Data, uint8_t dataLen);
	
	event void commandATDone(error_t status);
	event void commandATQueueDone(error_t status);
	event void remCommandATDone(error_t status);
	event void txReqDone(error_t status);
	
	event void modemStatus(uint8_t status);
	event void responseAT(uint8_t ackId, uint8_t* cmd, uint8_t status, uint8_t* values,uint8_t valuesLen);
	event void remResponseAT(uint8_t ackId, nx_uint16_t source, uint8_t* cmd, uint8_t status, uint8_t* values,uint8_t valuesLen);
	event void txStatus(uint8_t ackId,uint8_t status);
	event void rxPacket(nx_uint16_t source, uint8_t rssi, uint8_t opt, uint8_t* Data, uint8_t dataLen);
	event void rxPacketIO(nx_uint16_t source, uint8_t rssi, uint8_t opt, uint8_t* Data, uint8_t dataLen);

	
	event void logUSB0(uint8_t* data, uint8_t len);
	
}