module TOSSIM_InternalFlashP{
	provides interface InternalFlash as IntFlash;
}
implementation{
	uint8_t flashData[INTFLASH_SIZE];

	command error_t IntFlash.read(void *addr, void *buf, uint16_t size){
		void * x = &flashData[(uint16_t)addr];
		dbg(APPNAME,"IntFlash.read(): addr=%d, size=%d\n",(uint16_t)addr,size);
		memcpy(buf,x,size);
		return SUCCESS;
	}

	command error_t IntFlash.write(void *addr, void *buf, uint16_t size){
		void * x = &flashData[(uint16_t)addr];
		dbg(APPNAME,"IntFlash.write(): addr=%d, size=%d\n",(uint16_t)addr,size);
		memcpy(x,buf,size);
		return FAIL;
	}
}