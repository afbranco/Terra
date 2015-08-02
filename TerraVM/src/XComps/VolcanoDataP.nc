module VolcanoDataP{
#if defined(INO)
  provides interface ReadStream<nx_int32_t>;
  provides interface Set<uint32_t>;
  provides interface Get<uint32_t>;
  provides interface BlockRead as BlockReadAux;
  uses interface SdStorage as BlockRead;
  uses interface SdStorage as AuxBlockRead;
#else
  provides interface ReadStream<nx_int32_t>;
  provides interface Set<uint32_t>;
  provides interface Get<uint32_t>;
  uses interface BlockRead;
#endif
}
implementation{
  typedef nx_struct blockentry {
    nx_uint32_t rtime;
    nx_uint32_t len;
    nx_int32_t data[128];
  } blockentry_t;

  //blockentry_t block;
  uint32_t m_addr = 0;
  blockentry_t blk;
  //uint32_t blk_rtime;
  //uint32_t blk_len;

  command void Set.set(uint32_t x) {
    m_addr = x * sizeof(blk);
  }

  command uint32_t Get.get() {
    //return blk_rtime;
    return blk.rtime;
  }

  command error_t ReadStream.postBuffer(nx_int32_t *buf, uint16_t count)
  {
//    uint16_t auxCount = (count==0)?sizeof(blockentry_t):count;
//    return (call BlockRead.read(m_addr, buf, auxCount));
    return (call BlockRead.read(m_addr, &blk, sizeof(blk)));
  }

  command error_t ReadStream.read(uint32_t usPeriod)
  {
    return SUCCESS;
  }

  event void BlockRead.readDone(storage_addr_t addr, void *buf, storage_len_t len, error_t error)
  {
  	//blockentry_t* pBlk = buf;
    m_addr += sizeof(blk);
	//blk_len = pBlk->len;
	//blk_rtime = pBlk->rtime;
    //if(blk_len != 0) {
    if(blk.len != 0) {
    	//signal ReadStream.bufferDone(SUCCESS, buf, len);
    	signal ReadStream.bufferDone(SUCCESS, blk.data , (blk.len>128)?128:blk.len);
    } else {
    	signal ReadStream.bufferDone(FAIL, NULL, 0);
    }
  }

#if defined(INO)
	event void BlockRead.writeDone(uint32_t addr, void* buf, uint32_t len, error_t error){}
	event void BlockRead.eraseDone(error_t error){}
	event void AuxBlockRead.writeDone(uint32_t addr, void* buf, uint32_t len, error_t error){}
	event void AuxBlockRead.eraseDone(error_t error){}
#endif

#if defined(INO)

#else
  event void BlockRead.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
#endif  
  
  /*
   * By pass for BlockReadAux
   */
 
#if defined(INO)
  command error_t BlockReadAux.read(storage_addr_t addr, void* buf, storage_len_t len){
    return (call AuxBlockRead.read(m_addr, buf, len));
  }
  event void AuxBlockRead.readDone(storage_addr_t addr, void *buf, storage_len_t len, error_t error)
  {
		signal BlockReadAux.readDone(addr, buf, len, error);
  }  
  storage_addr_t crc_addr; storage_len_t crc_len;uint16_t crc_crc;
  task void computeCrc_computeCrcDone(){
	signal BlockReadAux.computeCrcDone(crc_addr, crc_len,crc_crc, SUCCESS);
  }
  command error_t BlockReadAux.computeCrc(storage_addr_t addr, storage_len_t len,uint16_t crc){
  	crc_addr=addr; crc_len=len; crc_crc=crc;
	post computeCrc_computeCrcDone();
  }

  command storage_len_t BlockReadAux.getSize(){
  	call AuxBlockRead.getSize();
  	}   
#endif  
}
