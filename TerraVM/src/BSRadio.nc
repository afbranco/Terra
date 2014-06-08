/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#include <message.h>  // force to find message.h
interface BSRadio{
	command error_t send(uint16_t target, void* dataMsg, uint8_t dataSize, uint8_t reqAck);
	event void sendDone(message_t* msg,error_t error);
	event void sendDoneAck(message_t* msg,error_t error, bool wasAcked);
	event void receive(message_t* msg, void* payload, uint8_t len);

}