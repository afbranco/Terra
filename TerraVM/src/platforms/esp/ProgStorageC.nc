configuration ProgStorageC{
	provides interface ProgStorage;
}
implementation{
	components ProgStorageP;
#ifdef ESP
	components ESP_InternalFlashP as IntFlash;
#else
#error MMCU not expected.
#endif
	
	ProgStorageP.InternalFlash -> IntFlash;
	ProgStorage = ProgStorageP;
	
}