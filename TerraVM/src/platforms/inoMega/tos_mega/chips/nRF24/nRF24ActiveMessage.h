#ifndef N_RF24_ACTIVE_MESSAGE_H
#define N_RF24_ACTIVE_MESSAGE_H

#ifndef F_CPU
#define F_CPU 16000000
#endif

#ifndef TERRA_NODE_ID
#defined TERRA_NODE_ID 1
#endif

/*
 * nRF24 state machine
 */
#define SETUP_AW_VAL 2
#define NRF24_MAX_PAYLOAD_LEN 29
enum {NONE,START,STOP,SEND, RECEIVE};

// nRF24 address must have a fixed mask with only last byte varying.
// Mask: 0x04nn
// NODE_ID: 001.. 254 -- 1024 .. 1278 (0x0400 .. 0x04FE)
// BROADCAST: 255 --  1279 (0x04FF)
enum {nRF24_ADDR_MASK=0x0400, nRF24_BROADCAST_ADDR = 0x00FF, nRF24_NODE_ID = TERRA_NODE_ID};

typedef struct lastSend{
	nx_am_id_t id;
	nx_am_addr_t target;
	message_t* msg;
	uint8_t len;
} lastSend_t;

// Radio payload data structure
typedef nx_struct nRF24_msg{
	nx_am_addr_t source;
	nx_am_id_t am_id;
	nx_uint8_t len;
	nx_uint8_t payload[TOSH_DATA_LENGTH];
}nRF24_msg_t;

// Config register value combinations

// RESET Config
#define RESET_CONFIG (0<<MASK_RX_DR | 0<<MASK_TX_DS | 0<<MASK_MAX_RT |1<<EN_CRC | 1<< CRCO | 0<<PWR_UP | 0<<PRIM_RX)
// START
#define START_CONFIG (0<<MASK_RX_DR | 1<<MASK_TX_DS | 1<<MASK_MAX_RT |1<<EN_CRC | 1<< CRCO | 1<<PWR_UP | 0<<PRIM_RX)
// STOP CONF
#define STOP_CONFIG  (1<<MASK_RX_DR | 1<<MASK_TX_DS | 1<<MASK_MAX_RT |1<<EN_CRC | 1<< CRCO | 0<<PWR_UP | 1<<PRIM_RX)
// SEND CONF
#define SEND_CONFIG  (1<<MASK_RX_DR | 0<<MASK_TX_DS | 0<<MASK_MAX_RT |1<<EN_CRC | 1<< CRCO | 1<<PWR_UP | 0<<PRIM_RX)
// RX CONF
#define REC_CONFIG (0<<MASK_RX_DR | 1<<MASK_TX_DS | 1<<MASK_MAX_RT |1<<EN_CRC | 1<< CRCO | 1<<PWR_UP | 1<<PRIM_RX)



#endif /* N_RF24_ACTIVE_MESSAGE_H */
