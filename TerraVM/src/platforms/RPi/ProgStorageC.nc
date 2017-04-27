configuration ProgStorageC{
	provides interface ProgStorage;
}
implementation{
	components ProgStorageP;
#ifdef LINUX
	components RPI_InternalFlashP as IntFlash;
#else
#error MMCU not expected.
#endif
	
	ProgStorageP.InternalFlash -> IntFlash;
	ProgStorage = ProgStorageP;
	
}