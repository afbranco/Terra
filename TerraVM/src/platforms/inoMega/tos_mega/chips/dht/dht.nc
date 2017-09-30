#include "dht.h"
interface dht{
	command uint8_t read(uint8_t intPin);
	event void readDone(dhtData_t* data);
}