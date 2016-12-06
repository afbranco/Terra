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

#include "Atm2560Adc.h"

configuration Atm2560AdcC
{
  provides
  {
    interface StdControl;

    interface ReadNow<uint16_t>[uint8_t id];
    interface Resource[uint8_t];

    interface Read<uint16_t>[uint8_t id];
    interface ReadStream<uint16_t>[uint8_t id];

    interface ArbiterInfo;
    interface ResourceDefaultOwner;
  }
  uses interface AdcConfigure<const Atm2560AdcConfig_t *>[uint8_t id];
}
implementation
{
  components Atm2560AdcP as AdcP;
  components new RoundRobinArbiterC(UQ_ATM2560_ADC_HAL) as Arbiter;
  AdcP.Resource -> Arbiter;

  components HplAtm2560AdcP;
  AdcP.Adc -> HplAtm2560AdcP;
  AdcP.AdcControl -> HplAtm2560AdcP;

  components Atm2560Alarms1C;
  AdcP.Alarm -> Atm2560Alarms1C.Alarm[1]; // Note: has to be COMP B (Alarm[1])

  components HplAtm2560PowerC;
  AdcP.HplPower -> HplAtm2560PowerC;

  StdControl = AdcP;
  ReadNow = AdcP;
  Resource = Arbiter;
  Read = AdcP;
  ReadStream = AdcP;
  ArbiterInfo = Arbiter;
  ResourceDefaultOwner = Arbiter;

  AdcP.AdcConfigure = AdcConfigure;
}
