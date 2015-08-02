
#include "SdInfo.h"
interface SdIO {
   
  command uint32_t cardSize(void);
  command uint8_t erase(uint32_t firstBlock, uint32_t lastBlock);
  command uint8_t eraseSingleBlockEnable(void);
  /**
   * \return error code for last error. See Sd2Card.h for a list of error codes.
   */
  command uint8_t errorCode(void);
  /** \return error data for last error. */
  command uint8_t errorData(void);

  command void partialBlockRead(uint8_t value);
  /** Returns the current value, true or false, for partial block read. */
  command uint8_t getPartialBlockRead(void);
  
  command uint8_t readBlock(uint32_t block, uint8_t* dst);
  command uint8_t readData(uint32_t block,uint16_t offset, uint16_t count, uint8_t* dst);
  /**
   * Read a cards CID register. The CID contains card identification
   * information such as Manufacturer ID, Product name, Product serial
   * number and Manufacturing date. */
  command uint8_t readCID(cid_t* cid);
  /**
   * Read a cards CSD register. The CSD contains Card-Specific Data that
   * provides information regarding access to the card's contents. */
  command uint8_t readCSD(union csd_t* csd);
  
  command void readEnd(void);

  /** Return the card type: SD V1, SD V2 or SDHC */
  command uint8_t getType(void);
  
  command uint8_t writeBlock(uint32_t blockNumber, const uint8_t* src);
  command uint8_t writeData(const uint8_t* src);
  command uint8_t writeStart(uint32_t blockNumber, uint32_t eraseCount);
  command uint8_t writeStop(void);
}
