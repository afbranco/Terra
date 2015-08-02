
#include "SdInfo.h"
#include "Sd2Card_ino.h"
#include "InoPins.h"
module SdP {
	provides {
		interface SdIO;
		interface SplitControl as Control;
	}
	uses {
		interface SpiByte as SdSpi;
		interface DigIO as Select;
		interface Resource as spiControl;
	}
}

implementation {

	
#define SD_SS_PIN D4 
#define SPI_SS_PIN D53 


// Private vars
  uint32_t block_;
  uint8_t chipSelectPin_;
  uint8_t errorCode_;
  uint8_t inBlock_;
  uint16_t offset_;
  uint8_t partialBlockRead_;
  uint8_t status_;
  uint8_t type_;

// proptoptypes
uint8_t cardCommand(uint8_t cmd, uint32_t arg);
uint8_t readData(uint32_t block,uint16_t offset, uint16_t count, uint8_t* dst);
void readEnd(void);
uint8_t writeDataAux(uint8_t token, const uint8_t* src);

/** Return the card type: SD V1, SD V2 or SDHC */
uint8_t getType(void){return type_;}
void setType(uint8_t value) {type_ = value;}
uint8_t getPartialBlockRead(void){return partialBlockRead_;}
/** error log */
void error(uint8_t err){errorCode_= err;}
/** \return code data for last error. */
uint8_t errorCode(void){return errorCode_;}
/** \return error data for last error. */
uint8_t errorData(void){return status_;}
/** Send a byte to the card */
static void spiSend(uint8_t b) {call SdSpi.write(b);}
/** Receive a byte from the card */
static  uint8_t spiRec(void) {return call SdSpi.write(0xFF);}
//* Chip Select
void chipSelectHigh(){call Select.set(SD_SS_PIN);}
void chipSelectLow() {call Select.clr(SD_SS_PIN);}
/** wait for card to go not busy */
uint8_t waitNotBusy(uint16_t count){
	uint16_t i=count;
	uint8_t rec;
	do {
		rec=spiRec();
	} while (rec != 0xFF && i--);
	if (rec != 0xFF) return FALSE;
	return TRUE;
}
/** Auxiliary Card A Command */
uint8_t cardAcmd(uint8_t cmd, uint32_t arg) {cardCommand(CMD55, 0);return cardCommand(cmd, arg);}

/** Wait for start block token */
uint8_t waitStartBlock(void) {
  uint32_t t0;

  t0 = 1000L;
  status_ = spiRec();
  while (status_ == 0XFF) {
	t0--;
    if (t0==0) {
      error(SD_CARD_ERROR_READ_TIMEOUT+1);
      goto fail;
    }
    status_ = spiRec();
  }
  if (status_ != DATA_START_BLOCK) {
    error(SD_CARD_ERROR_READ);
    goto fail;
  }
  return TRUE;

 fail:
  chipSelectHigh();
  return FALSE;
}

/** read CID or CSR register */
uint8_t readRegister(uint8_t cmd, void* buf) {
  uint8_t* dst = (uint8_t*)buf;
  uint16_t i;
  if (cardCommand(cmd, 0)) {
    error(SD_CARD_ERROR_READ_REG);
    goto fail;
  }
  if (!waitStartBlock()) goto fail;
  // transfer data
  for (i = 0; i < 16; i++) dst[i] = spiRec();
  spiRec();  // get first crc byte
  spiRec();  // get second crc byte
  chipSelectHigh();
  return TRUE;

 fail:
  chipSelectHigh();
  return FALSE;
}
  /**
   * Read a cards CSD register. The CSD contains Card-Specific Data that
   * provides information regarding access to the card's contents. */
uint8_t readCSD(union csd_t* csd) {return readRegister(CMD9, csd);}
  
/** send command and return error code.  Return zero for OK */
uint8_t cardCommand(uint8_t cmd, uint32_t arg) {
  int8_t s;
  uint8_t i;
  uint8_t crc = 0XFF;

 	// end read if in partialBlockRead mode
	//  readEnd();

  // select card
  chipSelectLow();

  // wait up to 300 ms if busy
  waitNotBusy(100);
  // send command
  spiSend(cmd | 0x40);

  // send argument
  for (s = 24; s >= 0; s -= 8) spiSend(arg >> s);

  // send CRC
  if (cmd == CMD0) crc = 0X95;  // correct crc for CMD0 with arg 0
  if (cmd == CMD8) crc = 0X87;  // correct crc for CMD8 with arg 0X1AA
  spiSend(crc);

  // wait for response
  for (i = 0; ((status_ = spiRec()) & 0X80) && i != 0XFF; i++);
  return status_;
}	

/** Determine if card supports single block erase.
 *
 * \return The value one, true, is returned if single block erase is supported.
 * The value zero, false, is returned if single block erase is not supported.
 */
uint8_t eraseSingleBlockEnable(void) {
  union csd_t csd;
  return readCSD(&csd) ? csd.v1.erase_blk_en : 0;
}

/**
 * Determine the size of an SD flash memory card.
 *
 * \return The number of 512 byte data blocks in the card
 *         or zero if an error occurs.
 */
uint32_t cardSize(void) {
  union csd_t csd;
  if (!readCSD(&csd)) return 0;
  if (csd.v1.csd_ver == 0) {
    uint8_t read_bl_len = csd.v1.read_bl_len;
    uint16_t c_size = (csd.v1.c_size_high << 10)
                      | (csd.v1.c_size_mid << 2) | csd.v1.c_size_low;
    uint8_t c_size_mult = (csd.v1.c_size_mult_high << 1)
                          | csd.v1.c_size_mult_low;
    return (uint32_t)(c_size + 1) << (c_size_mult + read_bl_len - 7);
  } else if (csd.v2.csd_ver == 1) {
    uint32_t c_size = ((uint32_t)csd.v2.c_size_high << 16)
                      | (csd.v2.c_size_mid << 8) | csd.v2.c_size_low;
    return (c_size + 1) << 10;
  } else {
    error(SD_CARD_ERROR_BAD_CSD);
    return 0;
  }
}

/** Erase a range of blocks.
 *
 * \param[in] firstBlock The address of the first block in the range.
 * \param[in] lastBlock The address of the last block in the range.
 *
 * \note This function requests the SD card to do a flash erase for a
 * range of blocks.  The data on the card after an erase operation is
 * either 0 or 1, depends on the card vendor.  The card must support
 * single block erase.
 *
 * \return The value one, true, is returned for success and
 * the value zero, false, is returned for failure.
 */
uint8_t erase(uint32_t firstBlock, uint32_t lastBlock) {
  if (!eraseSingleBlockEnable()) {
    error(SD_CARD_ERROR_ERASE_SINGLE_BLOCK);
    goto fail;
  }
  if (type_ != SD_CARD_TYPE_SDHC) {
    firstBlock <<= 9;
    lastBlock <<= 9;
  }
  if (cardCommand(CMD32, firstBlock)
    || cardCommand(CMD33, lastBlock)
    || cardCommand(CMD38, 0)) {
      error(SD_CARD_ERROR_ERASE);
      goto fail;
  }
  if (!waitNotBusy(SD_ERASE_TIMEOUT)) {
    error(SD_CARD_ERROR_ERASE_TIMEOUT);
    goto fail;
  }
  chipSelectHigh();
  return TRUE;

 fail:
  chipSelectHigh();
  return FALSE;
}
	
	
/**
 * Initialize an SD flash memory card.
 *
 * \return The value one, true, is returned for success and
 * the value zero, false, is returned for failure.  The reason for failure
 * can be determined by calling errorCode() and errorData().
 */
uint8_t sdInit() {
  uint32_t t0;
  uint32_t arg;
  uint8_t i;
  errorCode_ = inBlock_ = partialBlockRead_ = type_ = 0;

  // SS must be in output mode even it is not chip select
  call Select.makeOutput(SPI_SS_PIN);
  call Select.set(SPI_SS_PIN); // disable any SPI device using hardware SS pin
  call Select.makeOutput(SD_SS_PIN);
  call Select.clr(SD_SS_PIN);

  // must supply min of 74 clock cycles with CS high.
  chipSelectHigh();
  for (i = 0; i < 10; i++) spiSend(0XFF);
  chipSelectLow();

  // command to go idle in SPI mode
  t0 = 100;
  while ((status_ = cardCommand(CMD0, 0)) != R1_IDLE_STATE) {
	t0--;
    if (t0 == 0) {
      error(SD_CARD_ERROR_CMD0);
      goto fail;
    }
  }

  // check SD version
  if ((cardCommand(CMD8, 0x1AA) & R1_ILLEGAL_COMMAND)) {
    setType(SD_CARD_TYPE_SD1);
  } else {
    // only need last byte of r7 response
    for (i = 0; i < 4; i++) status_ = spiRec();
    if (status_ != 0XAA) {
      error(SD_CARD_ERROR_CMD8);
      goto fail;
    }
    setType(SD_CARD_TYPE_SD2);
  }


  // initialize card and send host supports SDHC if SD2
  arg = getType() == SD_CARD_TYPE_SD2 ? 0X40000000 : 0;

  t0 = 6000L;
  while ((status_ = cardAcmd(ACMD41, arg)) != R1_READY_STATE) {
    // check for timeout
	t0--;
    if (t0==0) {
      error(SD_CARD_ERROR_ACMD41);
      goto fail;
    }
  }


  // if SD2 read OCR register to check for SDHC card
  if (getType() == SD_CARD_TYPE_SD2) {
    if (cardCommand(CMD58, 0)) {
      error(SD_CARD_ERROR_CMD58);
      goto fail;
    }
    if ((spiRec() & 0XC0) == 0XC0) setType(SD_CARD_TYPE_SDHC);
    // discard rest of ocr - contains allowed voltage range
    for (i = 0; i < 3; i++) spiRec();
  }
  chipSelectHigh();

  return TRUE;

 fail:
  chipSelectHigh();
  return FALSE;
}



//------------------------------------------------------------------------------
/**
 * Enable or disable partial block reads.
 *
 * Enabling partial block reads improves performance by allowing a block
 * to be read over the SPI bus as several sub-blocks.  Errors may occur
 * if the time between reads is too long since the SD card may timeout.
 * The SPI SS line will be held low until the entire block is read or
 * readEnd() is called.
 *
 * Use this for applications like the Adafruit Wave Shield.
 *
 * \param[in] value The value TRUE (non-zero) or FALSE (zero).)
 */
void partialBlockRead(uint8_t value) {
  readEnd();
  partialBlockRead_ = value;
}
//------------------------------------------------------------------------------
/**
 * Read a 512 byte block from an SD card device.
 *
 * \param[in] block Logical block to be read.
 * \param[out] dst Pointer to the location that will receive the data.

 * \return The value one, true, is returned for success and
 * the value zero, false, is returned for failure.
 */
uint8_t readBlock(uint32_t block, uint8_t* dst) {
  return readData(block, 0, 512, dst);
}
//------------------------------------------------------------------------------
/**
 * Read part of a 512 byte block from an SD card.
 *
 * \param[in] block Logical block to be read.
 * \param[in] offset Number of bytes to skip at start of block
 * \param[out] dst Pointer to the location that will receive the data.
 * \param[in] count Number of bytes to read
 * \return The value one, true, is returned for success and
 * the value zero, false, is returned for failure.
 */
uint8_t readData(uint32_t block,uint16_t offset, uint16_t count, uint8_t* dst) {
  uint16_t i;
  if (count == 0) return TRUE;
  if ((count + offset) > 512) {
	error(0x20);
    goto fail;
  }

  if (!inBlock_ || block != block_ || offset < offset_) {
    block_ = block;
    // use address if not SDHC card
    if (getType()!= SD_CARD_TYPE_SDHC) block <<= 9;
    if (cardCommand(CMD17, block)) {
      error(SD_CARD_ERROR_CMD17);
      goto fail;
    }
    if (!waitStartBlock()) {
      goto fail;
    }
    offset_ = 0;
    inBlock_ = 1;
  }

  // skip data before offset
  for (;offset_ < offset; offset_++) {
    spiRec();
  }
  // transfer data
  for (i = 0; i < count; i++) {
    dst[i] = spiRec();
  }

  offset_ += count;
  if (!partialBlockRead_ || offset_ >= 512) {
    // read rest of data, checksum and set chip select high
    readEnd();
  }
  return TRUE;

 fail:
  chipSelectHigh();
  return FALSE;
}
//------------------------------------------------------------------------------
/** Skip remaining data in a block when in partial block read mode. */
void readEnd(void) {
  if (inBlock_) {
      // skip data and crc
    while (offset_++ < 514) spiRec();
    chipSelectHigh();
    inBlock_ = 0;
  }
}	

//------------------------------------------------------------------------------
/**
 * Writes a 512 byte block to an SD card.
 *
 * \param[in] blockNumber Logical block to be written.
 * \param[in] src Pointer to the location of the data to be written.
 * \return The value one, true, is returned for success and
 * the value zero, false, is returned for failure.
 */
uint8_t writeBlock(uint32_t blockNumber, const uint8_t* src) {
#if SD_PROTECT_BLOCK_ZERO
  // don't allow write to first block
  if (blockNumber == 0) {
    error(SD_CARD_ERROR_WRITE_BLOCK_ZERO);
    goto fail;
  }
#endif  // SD_PROTECT_BLOCK_ZERO


  // use address if not SDHC card
  if (getType() != SD_CARD_TYPE_SDHC) blockNumber <<= 9;
  if (cardCommand(CMD24, blockNumber)) {
    error(SD_CARD_ERROR_CMD24);
    goto fail;
  }

  if (!writeDataAux(DATA_START_BLOCK, src)) goto fail;

  // wait for flash programming to complete
  if (!waitNotBusy(SD_WRITE_TIMEOUT)) {
    error(SD_CARD_ERROR_WRITE_TIMEOUT);
    goto fail;
  }

  // response is r2 so get and check two bytes for nonzero
  if (cardCommand(CMD13, 0) || spiRec()) {
    error(SD_CARD_ERROR_WRITE_PROGRAMMING);
    goto fail;
  }
  chipSelectHigh();
  return TRUE;

 fail:
  chipSelectHigh();
  return FALSE;
}
//------------------------------------------------------------------------------
// send one block of data for write block or write multiple blocks
uint8_t writeDataAux(uint8_t token, const uint8_t* src) {
  uint16_t i;
  spiSend(token);
  for (i = 0; i < 512; i++) {
    spiSend(src[i]);
  }

  spiSend(0xff);  // dummy crc
  spiSend(0xff);  // dummy crc

  status_ = spiRec();
  if ((status_ & DATA_RES_MASK) != DATA_RES_ACCEPTED) {
    error(SD_CARD_ERROR_WRITE);
    chipSelectHigh();
    return FALSE;
  }
  return TRUE;
}
//------------------------------------------------------------------------------
/** Write one data block in a multiple block write sequence */
uint8_t writeData(const uint8_t* src) {
  // wait for previous write to finish
  if (!waitNotBusy(SD_WRITE_TIMEOUT)) {
    error(SD_CARD_ERROR_WRITE_MULTIPLE);
    chipSelectHigh();
    return FALSE;
  }
  return writeDataAux(WRITE_MULTIPLE_TOKEN, src);
}
//------------------------------------------------------------------------------
/** Start a write multiple blocks sequence.
 *
 * \param[in] blockNumber Address of first block in sequence.
 * \param[in] eraseCount The number of blocks to be pre-erased.
 *
 * \note This function is used with writeData() and writeStop()
 * for optimized multiple block writes.
 *
 * \return The value one, true, is returned for success and
 * the value zero, false, is returned for failure.
 */
uint8_t writeStart(uint32_t blockNumber, uint32_t eraseCount) {
#if SD_PROTECT_BLOCK_ZERO
  // don't allow write to first block
  if (blockNumber == 0) {
    error(SD_CARD_ERROR_WRITE_BLOCK_ZERO);
    goto fail;
  }
#endif  // SD_PROTECT_BLOCK_ZERO
  // send pre-erase count
  if (cardAcmd(ACMD23, eraseCount)) {
    error(SD_CARD_ERROR_ACMD23);
    goto fail;
  }
  // use address if not SDHC card
  if (getType() != SD_CARD_TYPE_SDHC) blockNumber <<= 9;
  if (cardCommand(CMD25, blockNumber)) {
    error(SD_CARD_ERROR_CMD25);
    goto fail;
  }
  return TRUE;

 fail:
  chipSelectHigh();
  return FALSE;
}
//------------------------------------------------------------------------------
/** End a write multiple blocks sequence.
 *
* \return The value one, true, is returned for success and
 * the value zero, false, is returned for failure.
 */
uint8_t writeStop(void) {
  if (!waitNotBusy(SD_WRITE_TIMEOUT)) goto fail;
  spiSend(STOP_TRAN_TOKEN);
  if (!waitNotBusy(SD_WRITE_TIMEOUT)) goto fail;
  chipSelectHigh();
  return TRUE;

 fail:
  error(SD_CARD_ERROR_STOP_TRAN);
  chipSelectHigh();
  return FALSE;
}

		
/******************************************************************/
	task void Control_stopDone(){signal Control.stopDone(SUCCESS);}
	
	command error_t Control.stop(){
		post Control_stopDone();
		return call spiControl.release();
	}

	command error_t Control.start(){
		return call spiControl.request();
	}

	event void spiControl.granted(){
		uint8_t stat=0;
		stat=sdInit();
		if (!stat) call spiControl.release();
		signal Control.startDone(stat);
	}
/*****************************************************************
 * 
 * SdIO Interface
 */
 
	command uint8_t SdIO.getPartialBlockRead(){return getPartialBlockRead();}

	command uint8_t SdIO.eraseSingleBlockEnable(){return eraseSingleBlockEnable();}

	command uint8_t SdIO.readData(uint32_t block, uint16_t offset, uint16_t count, uint8_t *dst){
		return readData(block,offset,count,dst);
	}

	command uint8_t SdIO.writeData(const uint8_t *src){return writeData(src);}

	command uint8_t SdIO.readCID(cid_t *cid){return readRegister(CMD10, cid);}

	command uint8_t SdIO.writeBlock(uint32_t blockNumber, const uint8_t *src){
		return writeBlock(blockNumber, src);
	}

	command uint8_t SdIO.erase(uint32_t firstBlock, uint32_t lastBlock){
		return erase(firstBlock,lastBlock);
	}

	command uint32_t SdIO.cardSize(){return cardSize();}

	command uint8_t SdIO.writeStop(){return writeStop();}

	command uint8_t SdIO.writeStart(uint32_t blockNumber, uint32_t eraseCount){
		return writeStart(blockNumber, eraseCount);
	}

	command void SdIO.readEnd(){readEnd();}

	command uint8_t SdIO.getType(){return getType();}

	command uint8_t SdIO.errorData(){return errorData();}

	command uint8_t SdIO.readCSD(union csd_t *csd){ return readCSD(csd);}

	command uint8_t SdIO.errorCode(){return errorCode();}

	command uint8_t SdIO.readBlock(uint32_t block, uint8_t *dst){
		return readBlock(block, dst);
	}

	command void SdIO.partialBlockRead(uint8_t value){
		partialBlockRead(value);
	}
}
