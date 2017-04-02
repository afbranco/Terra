/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
 /*
  * Include file to define only user message structure and AM_ID
  */
#ifndef USR_MSG_H
#define USR_MSG_H
#include "VMData.h"

enum{
USRMSG_QSIZE = 10,
AM_USRMSG = 145,

};

typedef nx_struct usrMsg {
	nx_uint8_t type;
	nx_uint16_t source;
	nx_uint16_t target;
	nx_uint8_t data[SEND_DATA_SIZE];
} usrMsg_t;

#endif /* USR_MSG_H */
