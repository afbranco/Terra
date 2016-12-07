#ifndef TERRA_BEACON_H
#define TERRA_BEACON_H

enum {
	DATA_MSG_ID=1,
	DATA_MSG_AMID=145,
	AM_USRMSG = 145,	
	
	BEACON_PERIOD = 5*60*1000,
	RESEND_DELAY = 20L,
	MAX_SEND_RETRIES = 3,
	
};

typedef nx_struct terra_data{
	nx_uint8_t type;
	nx_uint16_t source;
	nx_uint16_t target;

	nx_uint8_t  d8[4];
	nx_uint16_t d16[4];
	nx_uint32_t d32[2];
	
} terra_data_t;

/*
	nx_uint8_t  id;
	nx_uint16_t	nodeId;
	nx_uint16_t	target;

 	nx_uint8_t  seq;
	nx_uint8_t  node_id;
	nx_uint8_t  retries;
	nx_uint8_t  xxx3;
	nx_uint16_t	temp;
	nx_uint16_t	volt;
	nx_uint16_t yyy[2];
 */
#endif /* TERRA_BEACON_H */
