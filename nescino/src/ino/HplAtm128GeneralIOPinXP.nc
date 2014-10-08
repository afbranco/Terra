/// $Id: HplAtm128GeneralIOPinP.nc,v 1.8 2010-06-29 22:07:43 scipio Exp $

/*
 * Copyright (c) 2004-2005 Crossbow Technology, Inc.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of Crossbow Technology nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * Generic pin access for pins mapped into I/O space (for which the sbi, cbi
 * instructions give atomic updates). This can be used for ports A-E.
 *
 * @author Martin Turon <mturon@xbow.com>
 * @author David Gay <dgay@intel-research.net>
 */
 /**
  * Modified to receive all parameters by the interface
  * @author A.Branco
  * @date October, 2014
  */
 
module HplAtm128GeneralIOPinXP @safe()
{
  provides interface GeneralIOX as IO;
}
implementation
{

  inline async command bool IO.get(uint8_t pin_addr, uint8_t bit)        { return READ_BIT ((*TCAST(volatile uint8_t * ONE, pin_addr)), bit); }
  inline async command void IO.set(uint8_t port_addr, uint8_t bit)        { SET_BIT  ((*TCAST(volatile uint8_t * ONE, port_addr)), bit); }
  inline async command void IO.clr(uint8_t port_addr, uint8_t bit)        { CLR_BIT  ((*TCAST(volatile uint8_t * ONE, port_addr)), bit); }
  async command void IO.toggle(uint8_t port_addr, uint8_t bit)     { atomic FLIP_BIT ((*TCAST(volatile uint8_t * ONE, port_addr)), bit); }
    
  inline async command void IO.makeInput(uint8_t ddr_addr, uint8_t bit)  { CLR_BIT  ((*TCAST(volatile uint8_t * ONE, ddr_addr)), bit);  }
  inline async command bool IO.isInput(uint8_t ddr_addr, uint8_t bit) { return !READ_BIT((*TCAST(volatile uint8_t * ONE, ddr_addr)), bit); }
  inline async command void IO.makeOutput(uint8_t ddr_addr, uint8_t bit) { SET_BIT  ((*TCAST(volatile uint8_t * ONE, ddr_addr)), bit);  }
  inline async command bool IO.isOutput(uint8_t ddr_addr, uint8_t bit) { return READ_BIT((*TCAST(volatile uint8_t * ONE, ddr_addr)), bit); }
}

