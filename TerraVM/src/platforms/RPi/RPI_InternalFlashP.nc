module RPI_InternalFlashP{
	provides interface InternalFlash as IntFlash;
}
implementation{

	FILE* getFD(char* mode){
		char fname[80];
		sprintf(fname,"Terra_ProgStorage_%d.bin",TOS_NODE_ID);
		return fopen(fname,mode);
		}

	command error_t IntFlash.read( void* addr, void *buf, uint16_t size){
		FILE* fd;
		error_t stat;
		dbg(APPNAME,"IntFlash.read(): addr=%d, size=%d\n",(uint32_t)addr,size);
		fd = getFD("r");
		if (fd == NULL) return FAIL;
		stat = fread(buf,size,1,fd);
		if (stat != SUCCESS) return FAIL;
		return SUCCESS;
	}

	command error_t IntFlash.write(void* addr, void *buf, uint16_t size){
		FILE* fd;
		error_t stat;
		dbg(APPNAME,"IntFlash.write(): addr=%d, size=%d\n",(uint32_t)addr,size);
		fd = getFD("w");
		if (fd == NULL) return FAIL;
		stat = fwrite(buf,size,1,fd);
		if (stat != SUCCESS) return FAIL;
		return SUCCESS;
	}
}