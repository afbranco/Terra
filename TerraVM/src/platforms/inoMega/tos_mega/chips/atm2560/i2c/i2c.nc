interface i2c{
	command uint8_t write(void *const TXdata, uint8_t dataLen, uint8_t repStart);
	command uint8_t read(uint8_t TWIaddr, uint8_t bytesToRead, uint8_t repStart);
	
	async event void writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t *data);
	async event void readDone(error_t error, uint16_t addr, uint8_t length, uint8_t *data);


}