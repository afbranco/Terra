module VolcanoDataP{
  provides interface ReadStream<int32_t>;
  provides interface Set<uint32_t>;
  provides interface Get<uint32_t>;
  uses interface BlockRead;
}
implementation{
  typedef struct blockentry {
    uint32_t rtime;
    uint32_t len;
    int32_t data[128];
  } blockentry_t;

  blockentry_t block;
  uint32_t m_addr = 0;

  command void Set.set(uint32_t x) {
    m_addr = x * sizeof(block);
  }

  command uint32_t Get.get() {
    return block.rtime;
  }

  command error_t ReadStream.postBuffer(int32_t *buf, uint16_t count)
  {
    return (call BlockRead.read(m_addr, &block, sizeof(block)));
  }

  command error_t ReadStream.read(uint32_t usPeriod)
  {
    return SUCCESS;
  }

  event void BlockRead.readDone(storage_addr_t addr, void *buf, storage_len_t len, error_t error)
  {
    m_addr += sizeof(block);
    if(block.len != 0) signal ReadStream.bufferDone(SUCCESS, (void*)block.data, block.len);
    else signal ReadStream.bufferDone(FAIL, NULL, 0);
  }

  event void BlockRead.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
}