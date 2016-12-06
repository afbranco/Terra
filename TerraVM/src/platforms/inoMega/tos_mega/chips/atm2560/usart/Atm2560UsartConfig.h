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

#ifndef _ATM2560USARTCONFIG_H_
#define _ATM2560USARTCONFIG_H_

typedef enum {
  ATM2560_USART_ASYNC    = 0x00,
  ATM2560_USART_SYNC     = 0x01,
  ATM2560_USART_MSPI     = 0x03,
} atm2560_usart_mode_t;

typedef enum {
  ATM2560_USART_BITS_5  = 0x00,
  ATM2560_USART_BITS_6  = 0x01,
  ATM2560_USART_BITS_7  = 0x02,
  ATM2560_USART_BITS_8  = 0x03,
  ATM2560_USART_BITS_9  = 0x07,
} atm2560_usart_bits_t;

typedef enum
{
  ATM2560_USART_PARITY_NONE = 0x00,
  ATM2560_USART_PARITY_EVEN = 0x02,
  ATM2560_USART_PARITY_ODD  = 0x03,
} atm2560_usart_parity_t;

typedef struct
{
  atm2560_usart_mode_t mode;
  atm2560_usart_bits_t bits;
  atm2560_usart_parity_t parity;
  bool two_stop_bits;
  bool polarity_rising_edge;
  bool double_speed;
  uint32_t baud;
} atm2560_usart_config_t;

#endif
