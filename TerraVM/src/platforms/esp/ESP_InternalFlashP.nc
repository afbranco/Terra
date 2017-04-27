module ESP_InternalFlashP{
	provides interface InternalFlash as IntFlash;
}
implementation{

	command error_t IntFlash.read( void* addr, void *buf, uint16_t size){
		uint16_t sec = (uint32_t)addr;
		dbg(APPNAME,"IntFlash.read(): addr=%d, size=%d\n",(uint32_t)addr,size);
		system_param_load(sec, 0, buf, size);
		return SUCCESS;
	}

	command error_t IntFlash.write(void* addr, void *buf, uint16_t size){
		uint16_t sec = (uint32_t)addr;
		dbg(APPNAME,"IntFlash.write(): addr=%d, size=%d\n",(uint32_t)addr,size);
		system_param_save_with_protect(sec, buf, size);
		return FAIL;
	}
}