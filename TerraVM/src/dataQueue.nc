

/**
 * dataQueue interface
 */

interface dataQueue{
	command error_t put(void* Data);
	command error_t get(void* Data);
	command error_t remove();
	command error_t read(void* Data);
	command uint8_t size();
	command uint8_t maxSize();
	command bool isFree();
	event void dataReady();
	command error_t clearAll();
	command error_t element(uint8_t id, void* Data);
}