/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#include <message.h>  // force to find message.h
interface BSRadio{
	command error_t send(uint8_t am_id, uint16_t target, void* dataMsg, uint8_t dataSize, uint8_t reqAck);
	event void sendDone(uint8_t am_id,message_t* msg,void* dataMsg,error_t error);
	event void sendDoneAck(uint8_t am_id,message_t* msg,void* dataMsg,error_t error, bool wasAcked);
	event void receive(uint8_t am_id, message_t* msg, void* payload, uint8_t len);
	command uint16_t source(message_t* msg);
	command void setRFPower(uint8_t powerIdx);
#ifdef MODULE_CTP
	command error_t sendBS(void* dataMsg, uint8_t dataSize);
	event void sendBSDone(message_t* msg,error_t error);
	command uint16_t getParent();
#endif
#if defined(INOS)
#elif defined(INOX)
	// Log data to USB0
	command void logS(uint8_t* data, uint8_t len);
#endif	

}