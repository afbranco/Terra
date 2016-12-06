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

#include <atm2560hardware.h>

configuration HplAtm2560GeneralIOC
{
  provides
  {
    interface GeneralIO as PortA0;
    interface GeneralIO as PortA1;
    interface GeneralIO as PortA2;
    interface GeneralIO as PortA3;
    interface GeneralIO as PortA4;
    interface GeneralIO as PortA5;
    interface GeneralIO as PortA6;
    interface GeneralIO as PortA7;

    interface GeneralIO as PortB0;
    interface GeneralIO as PortB1;
    interface GeneralIO as PortB2;
    interface GeneralIO as PortB3;
    interface GeneralIO as PortB4;
    interface GeneralIO as PortB5;
    interface GeneralIO as PortB6;
    interface GeneralIO as PortB7;

    interface GeneralIO as PortC0;
    interface GeneralIO as PortC1;
    interface GeneralIO as PortC2;
    interface GeneralIO as PortC3;
    interface GeneralIO as PortC4;
    interface GeneralIO as PortC5;
    interface GeneralIO as PortC6;
    interface GeneralIO as PortC7;

    interface GeneralIO as PortD0;
    interface GeneralIO as PortD1;
    interface GeneralIO as PortD2;
    interface GeneralIO as PortD3;
    interface GeneralIO as PortD4;
    interface GeneralIO as PortD5;
    interface GeneralIO as PortD6;
    interface GeneralIO as PortD7;

    interface GeneralIO as PortE0;
    interface GeneralIO as PortE1;
    interface GeneralIO as PortE2;
    interface GeneralIO as PortE3;
    interface GeneralIO as PortE4;
    interface GeneralIO as PortE5;
    interface GeneralIO as PortE6;
    interface GeneralIO as PortE7;

    interface GeneralIO as PortF0;
    interface GeneralIO as PortF1;
    interface GeneralIO as PortF2;
    interface GeneralIO as PortF3;
    interface GeneralIO as PortF4;
    interface GeneralIO as PortF5;
    interface GeneralIO as PortF6;
    interface GeneralIO as PortF7;

    interface GeneralIO as PortG0;
    interface GeneralIO as PortG1;
    interface GeneralIO as PortG2;
    interface GeneralIO as PortG3;
    interface GeneralIO as PortG4;
    interface GeneralIO as PortG5;

    interface GeneralIO as PortH0;
    interface GeneralIO as PortH1;
    interface GeneralIO as PortH2;
    interface GeneralIO as PortH3;
    interface GeneralIO as PortH4;
    interface GeneralIO as PortH5;
    interface GeneralIO as PortH6;
    interface GeneralIO as PortH7;

    interface GeneralIO as PortJ0;
    interface GeneralIO as PortJ1;
    interface GeneralIO as PortJ2;
    interface GeneralIO as PortJ3;
    interface GeneralIO as PortJ4;
    interface GeneralIO as PortJ5;
    interface GeneralIO as PortJ6;
    interface GeneralIO as PortJ7;

    interface GeneralIO as PortK0;
    interface GeneralIO as PortK1;
    interface GeneralIO as PortK2;
    interface GeneralIO as PortK3;
    interface GeneralIO as PortK4;
    interface GeneralIO as PortK5;
    interface GeneralIO as PortK6;
    interface GeneralIO as PortK7;

    interface GeneralIO as PortL0;
    interface GeneralIO as PortL1;
    interface GeneralIO as PortL2;
    interface GeneralIO as PortL3;
    interface GeneralIO as PortL4;
    interface GeneralIO as PortL5;
    interface GeneralIO as PortL6;
    interface GeneralIO as PortL7;
    }
}
implementation
{
  components
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTA, (uint8_t)&PINA, (uint8_t)&DDRA) as PortA,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTB, (uint8_t)&PINB, (uint8_t)&DDRB) as PortB,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTC, (uint8_t)&PINC, (uint8_t)&DDRC) as PortC,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTD, (uint8_t)&PIND, (uint8_t)&DDRD) as PortD,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTE, (uint8_t)&PINE, (uint8_t)&DDRE) as PortE,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTF, (uint8_t)&PINF, (uint8_t)&DDRF) as PortF;

  components
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTG, (uint8_t)&PING, (uint8_t)&DDRG) as PortG,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTH, (uint8_t)&PINH, (uint8_t)&DDRH) as PortH,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTJ, (uint8_t)&PINJ, (uint8_t)&DDRJ) as PortJ,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTK, (uint8_t)&PINK, (uint8_t)&DDRK) as PortK,
    new HplAtm2560GeneralIOPortP ((uint8_t)&PORTL, (uint8_t)&PINL, (uint8_t)&DDRL) as PortL;

  PortA0 = PortA.Pin0;
  PortA1 = PortA.Pin1;
  PortA2 = PortA.Pin2;
  PortA3 = PortA.Pin3;
  PortA4 = PortA.Pin4;
  PortA5 = PortA.Pin5;
  PortA6 = PortA.Pin6;
  PortA7 = PortA.Pin7;

  PortB0 = PortB.Pin0;
  PortB1 = PortB.Pin1;
  PortB2 = PortB.Pin2;
  PortB3 = PortB.Pin3;
  PortB4 = PortB.Pin4;
  PortB5 = PortB.Pin5;
  PortB6 = PortB.Pin6;
  PortB7 = PortB.Pin7;
  
  PortC0 = PortC.Pin0;
  PortC1 = PortC.Pin1;
  PortC2 = PortC.Pin2;
  PortC3 = PortC.Pin3;
  PortC4 = PortC.Pin4;
  PortC5 = PortC.Pin5;
  PortC6 = PortC.Pin6;
  PortC7 = PortC.Pin7;

  PortD0 = PortD.Pin0;
  PortD1 = PortD.Pin1;
  PortD2 = PortD.Pin2;
  PortD3 = PortD.Pin3;
  PortD4 = PortD.Pin4;
  PortD5 = PortD.Pin5;
  PortD6 = PortD.Pin6;
  PortD7 = PortD.Pin7;

  PortE0 = PortE.Pin0;
  PortE1 = PortE.Pin1;
  PortE2 = PortE.Pin2;
  PortE3 = PortE.Pin3;
  PortE4 = PortE.Pin4;
  PortE5 = PortE.Pin5;
  PortE6 = PortE.Pin6;
  PortE7 = PortE.Pin7;

  PortF0 = PortF.Pin0;
  PortF1 = PortF.Pin1;
  PortF2 = PortF.Pin2;
  PortF3 = PortF.Pin3;
  PortF4 = PortF.Pin4;
  PortF5 = PortF.Pin5;
  PortF6 = PortF.Pin6;
  PortF7 = PortF.Pin7;
  
  PortG0 = PortG.Pin0;
  PortG1 = PortG.Pin1;
  PortG2 = PortG.Pin2;
  PortG3 = PortG.Pin3;
  PortG4 = PortG.Pin4;
  PortG5 = PortG.Pin5;

  PortH0 = PortH.Pin0;
  PortH1 = PortH.Pin1;
  PortH2 = PortH.Pin2;
  PortH3 = PortH.Pin3;
  PortH4 = PortH.Pin4;
  PortH5 = PortH.Pin5;
  PortH6 = PortH.Pin6;
  PortH7 = PortH.Pin7;

  PortJ0 = PortJ.Pin0;
  PortJ1 = PortJ.Pin1;
  PortJ2 = PortJ.Pin2;
  PortJ3 = PortJ.Pin3;
  PortJ4 = PortJ.Pin4;
  PortJ5 = PortJ.Pin5;
  PortJ6 = PortJ.Pin6;
  PortJ7 = PortJ.Pin7;

  PortK0 = PortK.Pin0;
  PortK1 = PortK.Pin1;
  PortK2 = PortK.Pin2;
  PortK3 = PortK.Pin3;
  PortK4 = PortK.Pin4;
  PortK5 = PortK.Pin5;
  PortK6 = PortK.Pin6;
  PortK7 = PortK.Pin7;

  PortL0 = PortL.Pin0;
  PortL1 = PortL.Pin1;
  PortL2 = PortL.Pin2;
  PortL3 = PortL.Pin3;
  PortL4 = PortL.Pin4;
  PortL5 = PortL.Pin5;
  PortL6 = PortL.Pin6;
  PortL7 = PortL.Pin7;  
}

