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
module HplAtm2560IoIsrC
{
  provides
  {
    interface HplAtm2560Isr as Int0;
    interface HplAtm2560Isr as Int1;
    interface HplAtm2560Isr as Int2;
    interface HplAtm2560Isr as Int3;
    interface HplAtm2560Isr as Int4;
    interface HplAtm2560Isr as Int5;
    interface HplAtm2560Isr as Int6;
    interface HplAtm2560Isr as Int7;
  }
}
implementation
{
  AVR_ATOMIC_HANDLER(INT0_vect) { signal Int0.fired ();}
  AVR_ATOMIC_HANDLER(INT1_vect) { signal Int1.fired ();}
  AVR_ATOMIC_HANDLER(INT2_vect) { signal Int2.fired ();}
  AVR_ATOMIC_HANDLER(INT3_vect) { signal Int3.fired ();}
  AVR_ATOMIC_HANDLER(INT4_vect) { signal Int4.fired ();}
  AVR_ATOMIC_HANDLER(INT5_vect) { signal Int5.fired ();}
  AVR_ATOMIC_HANDLER(INT6_vect) { signal Int6.fired ();}
  AVR_ATOMIC_HANDLER(INT7_vect) { signal Int7.fired ();}
}
