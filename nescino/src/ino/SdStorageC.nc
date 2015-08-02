#include "SdStorage.h"
generic configuration SdStorageC(uint32_t startBlk, uint32_t maxBlk){
	provides interface SdStorage;
	
}
implementation{
	components new SdStorageP(startBlk,maxBlk);
	SdStorage = SdStorageP;
	
	components SdC;
	SdStorageP.SdIO -> SdC;
	SdStorageP.Control -> SdC;
}