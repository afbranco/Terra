configuration ProgStorageC{
	provides interface ProgStorage;
}
implementation{
	components ProgStorageP;
#ifdef __AVR__
	components Avr_InternalFlashC as IntFlash;
#else
#error MMCU not expected.
#endif
	
	ProgStorageP.InternalFlash -> IntFlash;
	ProgStorage = ProgStorageP;
	
}