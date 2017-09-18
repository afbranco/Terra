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

#ifdef ANA3_REF
#if ANA3_REF==AN_DEFAULT
#define ADC3_REF ATM2560_ADC_REF_AVCC
#elif ANA3_REF==AN_INTERNAL1V1
#define ADC3_REF ATM2560_ADC_REF_INTERNAL_1_1
#elif ANA3_REF==AN_INTERNAL3V56
#define ADC3_REF ATM2560_ADC_REF_INTERNAL_2_56
#elif ANA3_REF==AN_EXTERNAL
#define ADC3_REF ATM2560_ADC_REF_AREF
#endif
#else
#define ADC3_REF ATM2560_ADC_REF_INTERNAL_1_1
#endif

module Analog3ConfigP
{
  provides interface AdcConfigure<const Atm2560AdcConfig_t *>;
}
implementation
{
  Atm2560AdcConfig_t cfg = {
    .reference = ADC3_REF,
    .prescale  = ATM2560_ADC_PRESCALE_128,
    .channel   = ATM2560_ADC_CHANNEL_3,
    .digital_input = FALSE,
  };

  async command const Atm2560AdcConfig_t *AdcConfigure.getConfiguration ()
  {
    return &cfg;
  }
}
