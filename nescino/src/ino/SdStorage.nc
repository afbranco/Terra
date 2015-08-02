interface SdStorage{

	/**
	 * write data block to the storage
	 * @param addr - data storage addr
	 * @param buf - input buffer pointer
	 * @param len - data len
	 */
	command error_t write(uint32_t addr, void* buf, uint32_t len);
	event void writeDone(uint32_t addr, void* buf, uint32_t len, error_t error);

	/**
	 * read data block from the storage
	 * @param addr - data storage addr
	 * @param buf - output buffer pointer
	 * @param len - data len
	 */
	command error_t read(uint32_t addr, void* buf, uint32_t len);
	event void readDone(uint32_t addr, void* buf, uint32_t len, error_t error);

	/**
	 * Erase all storage
	 */ 
	command error_t erase();
	event void eraseDone(error_t error);
	
	/**
	 * getSize return the volume size
	 */
	command uint32_t getSize();	 
}
