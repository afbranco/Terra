#ifndef DHT_H
#define DHT_H


typedef enum dht_state {
	RESPONSE,
	DATA,
	ACQUIRED,
	STOPPED,
	ACQUIRING,
} dht_state_t;

#define IDDHTLIB_OK			0
#define IDDHTLIB_ACQUIRING		1
#define IDDHTLIB_ACQUIRED		2
#define IDDHTLIB_RESPONSE_OK	3

typedef enum dht_status {
	S_OK				= 0,
	S_ACQUIRING		= 1,
	S_ACQUIRED		= 2,
	S_RESPONSE_OK		= 3	
} dht_status_t;


typedef enum dht_error {
	E_CHECKSUM			= 1,
	E_ISR_TIMEOUT		= 2,
	E_RESPONSE_TIMEOUT	= 3,
	E_DATA_TIMEOUT		= 4,
	E_ACQUIRING	 		= 5,
	E_DELTA		 		= 6,
	E_NOTSTARTED		= 7,
	E_ISR_MISSING		= 8,
} dht_error_t;

enum int_mode {
	INT_LEVEL = 0,
	INT_TOGGLE = 1,
	INT_FALLING = 2,
	INT_RISING = 3
};

typedef nx_struct dhtData {
	nx_uint8_t stat;
	nx_uint8_t hum;
	nx_uint8_t temp;
} dhtData_t;



#endif /* DHT_H */
