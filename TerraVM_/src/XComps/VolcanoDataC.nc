#if defined(INO)
	#include "SdStorage.h"
#else
	#include "StorageVolumes.h"
#endif

configuration VolcanoDataC{
  provides interface ReadStream<nx_int32_t>;
  provides interface Set<uint32_t>;
  provides interface Get<uint32_t>;
  provides interface BlockRead;
}
implementation{
  components VolcanoDataP;
  Set = VolcanoDataP;
  Get = VolcanoDataP;
  ReadStream = VolcanoDataP.ReadStream;

#if defined(INO)
  BlockRead = VolcanoDataP.BlockReadAux;
  // Sensor Data
  components new SdStorageC(STORAGE_DATATRACE_START_BLK,STORAGE_DATATRACE_MAX_BLK) as DataTraceBlock;
  VolcanoDataP.BlockRead -> DataTraceBlock;

  // GModel Config Data
  components new SdStorageC(STORAGE_GMODEL_START_BLK,STORAGE_GMODEL_MAX_BLK) as GModelBlock;
  VolcanoDataP.AuxBlockRead -> GModelBlock;

#else
  // Sensor Data
  components new BlockStorageC(VOLUME_DATATRACE) as DataTraceBlock;
  VolcanoDataP.BlockRead -> DataTraceBlock.BlockRead;

  // GModel Config Data
  components new BlockStorageC(VOLUME_GMODEL) as GModelBlock;
  BlockRead = GModelBlock.BlockRead;
#endif
  
}