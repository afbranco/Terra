#ifndef ACK_MESSAGE_H
#define ACK_MESSAGE_H

#define ACK_CODE 0xFFFE

typedef nx_struct ackMessage_t{	
	nx_uint16_t ackCode;
	nx_am_addr_t src;
	nx_am_addr_t dest;
	nx_uint16_t ackID;	
}ackMessage_t;

#endif /* ACK_MESSAGE_H */
