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
configuration HplAtm2560ExtInterruptC
{
  provides
  {
    interface HplAtm8IoInterrupt as Int0;
    interface HplAtm8IoInterrupt as Int1;
    interface HplAtm8IoInterrupt as Int2;
    interface HplAtm8IoInterrupt as Int3;
    interface HplAtm8IoInterrupt as Int4;
    interface HplAtm8IoInterrupt as Int5;
    interface HplAtm8IoInterrupt as Int6;
    interface HplAtm8IoInterrupt as Int7;
  }
}
implementation
{
  components HplAtm2560IoIsrC,
    new HplAtm2560ExtInterruptP (0) as Interrupt0,
    new HplAtm2560ExtInterruptP (1) as Interrupt1,
    new HplAtm2560ExtInterruptP (2) as Interrupt2,
    new HplAtm2560ExtInterruptP (3) as Interrupt3,
    new HplAtm2560ExtInterruptP (4) as Interrupt4,
    new HplAtm2560ExtInterruptP (5) as Interrupt5,
    new HplAtm2560ExtInterruptP (6) as Interrupt6,
    new HplAtm2560ExtInterruptP (7) as Interrupt7;

  Interrupt0.HplAtm2560Isr -> HplAtm2560IoIsrC.Int0;
  Interrupt1.HplAtm2560Isr -> HplAtm2560IoIsrC.Int1;
  Interrupt2.HplAtm2560Isr -> HplAtm2560IoIsrC.Int2;
  Interrupt3.HplAtm2560Isr -> HplAtm2560IoIsrC.Int3;
  Interrupt4.HplAtm2560Isr -> HplAtm2560IoIsrC.Int4;
  Interrupt5.HplAtm2560Isr -> HplAtm2560IoIsrC.Int5;
  Interrupt6.HplAtm2560Isr -> HplAtm2560IoIsrC.Int6;
  Interrupt7.HplAtm2560Isr -> HplAtm2560IoIsrC.Int7;

  Int0 = Interrupt0;
  Int1 = Interrupt1;
  Int2 = Interrupt2;
  Int3 = Interrupt3;
  Int4 = Interrupt4;
  Int5 = Interrupt5;
  Int6 = Interrupt6;
  Int7 = Interrupt7;
}
