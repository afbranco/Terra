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

interface HplAtm2560Adc
{
  async command void setReference (Atm2560AdcRef_t ref);
  async command Atm2560AdcRef_t getReference ();

  async command void setChannel (Atm2560AdcChannel_t channel);
  async command Atm2560AdcChannel_t getChannel ();

  async command void startConversion ();
  async command bool isConverting ();

  async command void enableAutoTrigger ();
  async command void disableAutoTrigger ();
  async command bool isAutoTriggered ();
  async command void setAutoTriggerSource (Atm2560AdcTriggerSource_t source);
  async command Atm2560AdcTriggerSource_t getAutoTriggerSource ();

  async command void enableInterrupt ();
  async command void disableInterrupt ();
  async command bool interruptEnabled ();
  async event void done ();

  async command void setPrescaler (Atm2560AdcPrescale_t prescale);
  async command Atm2560AdcPrescale_t getPrescaler ();

  async command void enableDigitalInput (Atm2560AdcChannel_t channel);
  async command void disableDigitalInput (Atm2560AdcChannel_t channel);
  async command bool digitalInputEnabled (Atm2560AdcChannel_t channel);

  async command uint16_t get ();
}
