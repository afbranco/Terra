configuration ProgStorageC{
	provides interface ProgStorage;
}
implementation{
	components ProgStorageP;
#ifdef __AVR__
	components Avr_InternalFlashC as IntFlash;
#elif __MSP430__
	components Msp430_InternalFlashC as IntFlash;
#elif TOSSIM
	components TOSSIM_InternalFlashP as IntFlash;
#else
#error MMCU not expected.
#endif
	
	ProgStorageP.InternalFlash -> IntFlash;
	ProgStorage = ProgStorageP;
	
}