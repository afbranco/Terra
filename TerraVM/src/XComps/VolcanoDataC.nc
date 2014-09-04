#include "StorageVolumes.h"

configuration VolcanoDataC{
  provides interface ReadStream<int32_t>;
  provides interface Set<uint32_t>;
  provides interface Get<uint32_t>;
  provides interface BlockRead;
}
implementation{
  components VolcanoDataP;

  // Sensor Data
  components new BlockStorageC(VOLUME_DATATRACE) as DataTraceBlock;
  VolcanoDataP.BlockRead -> DataTraceBlock.BlockRead;
  ReadStream = VolcanoDataP.ReadStream;
  Set = VolcanoDataP;
  Get = VolcanoDataP;

  // GModel Config Data
  components new BlockStorageC(VOLUME_GMODEL) as GModelBlock;
  BlockRead = GModelBlock.BlockRead;
  
}