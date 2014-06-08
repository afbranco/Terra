//$Id: BitVectorC.nc,v 1.5 2010/01/20 19:59:07 scipio Exp $

/* "Copyright (c) 2000-2003 The Regents of the University of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement
 * is hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY
 * OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 */

/**
 * Generic bit vector implementation. Note that if you use this bit vector
 * from interrupt code, you must use appropriate <code>atomic</code>
 * statements to ensure atomicity.
 *
 * @param max_bits Bit vector length.
 *
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 */
/**
 * WDVM project: Adapted to check if all bits are set
 * @author A.Branco <branco@inf.puc-rio.br>
 */

generic module vmBitVectorC(uint16_t max_bits)
{
  provides interface Init;
  provides interface vmBitVector as BitVector;
}
implementation
{
  typedef uint8_t int_type;

  enum
  {
    ELEMENT_SIZE = 8*sizeof(int_type),
    ARRAY_SIZE = (max_bits + ELEMENT_SIZE-1) / ELEMENT_SIZE,
  };

  int_type m_bits[ ARRAY_SIZE ];

  uint16_t getIndex(uint16_t bitnum)
  {
    return bitnum / ELEMENT_SIZE;
  }

  uint16_t getMask(uint16_t bitnum)
  {
    return 1 << (bitnum % ELEMENT_SIZE);
  }

  command error_t Init.init()
  {
    call BitVector.clearAll();
    return SUCCESS;
  }

  async command void BitVector.clearAll()
  {
  	uint16_t bitnum;
    memset(m_bits, 0, sizeof(m_bits));
    // Set unused bits
    for (bitnum=max_bits; bitnum <  (ARRAY_SIZE*ELEMENT_SIZE);bitnum++)
    	atomic {m_bits[getIndex(bitnum)] |= getMask(bitnum);}
  }

  async command void BitVector.setAll()
  {
    memset(m_bits, 255, sizeof(m_bits));
  }

  async command bool BitVector.get(uint16_t bitnum)
  {
dbg(APPNAME,"VM::BitVector.get(): bitnum=%d, bits=%0x, ARRAY_SIZE=%d\n",bitnum,(uint8_t)m_bits[getIndex(bitnum)],ARRAY_SIZE);
    atomic {return (m_bits[getIndex(bitnum)] & getMask(bitnum)) ? TRUE : FALSE;}
  }

  async command void BitVector.set(uint16_t bitnum)
  {
    atomic {m_bits[getIndex(bitnum)] |= getMask(bitnum);}
  }

  async command void BitVector.clear(uint16_t bitnum)
  {
    atomic {m_bits[getIndex(bitnum)] &= ~getMask(bitnum);}
  }

  async command void BitVector.toggle(uint16_t bitnum)
  {
    atomic {m_bits[getIndex(bitnum)] ^= getMask(bitnum);}
  }

  async command void BitVector.assign(uint16_t bitnum, bool value)
  {
    if(value)
      call BitVector.set(bitnum);
    else
      call BitVector.clear(bitnum);
  }

  async command uint16_t BitVector.size()
  {
    return max_bits;
  }
  
  async command bool BitVector.isAllBitSet()
  {
  	uint16_t elnum;
  	for (elnum=0;elnum<ARRAY_SIZE;elnum++)
  	  atomic {if (m_bits[elnum] != 0xff) return FALSE;}
  	return TRUE; 
  }  

  async command void BitVector.resetRange(uint16_t from, uint16_t to)
  {
  	uint16_t bitnum;
	// set all
    memset(m_bits, 255, sizeof(m_bits));
  	// reset  range
 	for (bitnum=from;bitnum <= to;bitnum++) atomic {m_bits[getIndex(bitnum)] &= ~getMask(bitnum);};
dbg(APPNAME,"VM::BitVector.resetRange(): from=%d, to=%d, bits=%0x\n",from,to,(uint8_t)m_bits[0]);
  }
  
  async command uint16_t BitVector.countPend(){
  	uint16_t bitnum,count=0;
    for (bitnum=0; bitnum < (ARRAY_SIZE*ELEMENT_SIZE);bitnum++)
		atomic {if (!(m_bits[getIndex(bitnum)] & getMask(bitnum))) count++;}   	
  	return count;
  }
}

