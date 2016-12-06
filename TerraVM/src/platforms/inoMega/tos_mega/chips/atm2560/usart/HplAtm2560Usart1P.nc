/*
 * Copyright (c) 2012 Johny Mattsson
 * All rights reserved.
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
 * - Neither the name of the copyright holders nor the names of
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

#include "Atm2560UsartConfig.h"

module HplAtm2560Usart1P
{
  provides
  {
    interface Init;
    interface StdControl as RxControl;
    interface StdControl as TxControl;
    interface HplAtm2560Usart as Usart;
  }
  uses interface Atm2560UsartConfig as Config;
}
implementation
{
  // NOTE: need to always write FE0/DOR0/UPE0 to zero when writing to UCSR1A
  enum { UCSR1A_WMASK = ~((1 << FE1) | (1 << DOR1) | (1 << UPE1)) };

  command error_t Init.init ()
  {
    atm2560_usart_config_t *cfg = call Config.getConfig ();
    if (!cfg)
      return FAIL;

    atomic
    {
      uint16_t ubrr;
      uint8_t ubrr_div;

      // Note: we don't even pretend to know about multi-processor comm mode
      // and always disable it. Someone who can actually test it is welcome to
      // add support for it...
      if (cfg->mode == ATM2560_USART_ASYNC && cfg->double_speed)
        UCSR1A = (1 << U2X1);
      else
        UCSR1A = 0;

      UCSR1B |= ((cfg->bits & 0x04) >> 2) << UCSZ12;

      UCSR1C =
        (cfg->mode << UMSEL10) |
        (cfg->parity << UPM10) |
        (cfg->two_stop_bits ? (1 << USBS1) : 0) |
        ((cfg->bits & 0x03) << UCSZ10) |           // top bit is in UCSR1B
        (cfg->polarity_rising_edge << UCPOL1);

      if (cfg->mode == ATM2560_USART_ASYNC)
        ubrr_div = cfg->double_speed ? 8 : 16;
      else
        ubrr_div = 2;

      // we very much care about rounding correctly, truncating would be bad
      ubrr = (uint16_t)((float)(F_CPU / ubrr_div) / cfg->baud - 1 + 0.5);

      UBRR1 = (ubrr & 0x0fff);
    }

    return SUCCESS;
  }

  command error_t RxControl.start ()
  {
    UCSR1B |= (1 << RXEN1);
    return SUCCESS;
  }

  command error_t RxControl.stop ()
  {
    UCSR1B &= ~(1 << RXEN1);
    return SUCCESS;
  }

  command error_t TxControl.start ()
  {
    UCSR1B |= (1 << TXEN1);
    return SUCCESS;
  }

  command error_t TxControl.stop ()
  {
    UCSR1B &= ~(1 << TXEN1);
    return SUCCESS;
  }

  async command void Usart.enableRxcInterrupt ()
  {
    UCSR1B |= (1 << RXCIE1);
  }

  async command void Usart.disableRxcInterrupt ()
  {
    UCSR1B &= ~(1 << RXCIE1);
  }

  async command void Usart.enableTxcInterrupt ()
  {
    UCSR1B |= (1 << TXCIE1);
  }

  async command void Usart.disableTxcInterrupt ()
  {
    UCSR1B &= ~(1 << TXCIE1);
  }

  async command void Usart.enableDreInterrupt ()
  {
    UCSR1B |= (1 << UDRIE1);
  }

  async command void Usart.disableDreInterrupt ()
  {
    UCSR1B &= ~(1 << UDRIE1);
  }

  async command bool Usart.rxComplete ()
  {
    return (UCSR1A & (1 << RXC1));
  }

  async command bool Usart.txComplete ()
  {
    return (UCSR1A & (1 << TXC1));
  }

  async command bool Usart.txEmpty ()
  {
    return (UCSR1A & (1 << UDRE1));
  }

  async command bool Usart.frameError ()
  {
    return (UCSR1A & (1 << FE1));
  }

  async command bool Usart.dataOverrun ()
  {
    return (UCSR1A & (1 << DOR1));
  }

  async command bool Usart.parityError ()
  {
    return (UCSR1A & (1 << UPE1));
  }

  async command bool Usart.rxBit8 ()
  {
    return (UCSR1B & (1 << RXB81));
  }

  async command uint8_t Usart.rx ()
  {
    return UDR1;
  }

  async command void Usart.txBit8 (bool bit)
  {
    UCSR1B |= ((bit ? 1 : 0) << TXB81);
  }

  async command void Usart.tx (uint8_t data)
  {
    atomic
    {
      UCSR1A = (UCSR1A & UCSR1A_WMASK) | (1 << TXC1);
      UDR1 = data;
    }
  }

  AVR_ATOMIC_HANDLER(USART1_RX_vect)
  {
    signal Usart.rxDone ();
  }

  AVR_ATOMIC_HANDLER(USART1_UDRE_vect)
  {
    signal Usart.txNowEmpty ();
  }

  AVR_ATOMIC_HANDLER(USART1_TX_vect)
  {
    signal Usart.txDone ();
  }

}
