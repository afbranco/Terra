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


enum{
USRMSG_QSIZE = 10,
AM_USRMSG = 151,

};

typedef nx_struct usrMsg {
	nx_uint8_t id;
	nx_uint16_t source;
	nx_uint16_t target;
	nx_uint8_t d8_1;
	nx_uint8_t d8_2;
	nx_uint8_t d8_3;
	nx_uint8_t d8_4;
	nx_uint16_t d16_1;
	nx_uint16_t d16_2;
	nx_uint16_t d16_3;
	nx_uint16_t d16_4;
	nx_uint32_t d32_1;
	nx_uint32_t d32_2;
} usrMsg_t;

#endif /* USR_MSG_H */
