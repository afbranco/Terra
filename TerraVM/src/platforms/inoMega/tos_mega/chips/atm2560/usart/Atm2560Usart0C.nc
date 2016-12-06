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

configuration Atm2560Usart0C
{
  provides
  {
    interface StdControl;
    interface UartStream;
    interface UartByte;
    interface SerialFlush;
  }

  uses
  {
    interface BusyWait<TMicro, uint16_t>;
    interface Atm2560UsartConfig;
    interface McuPowerState;
  }
}
implementation
{
  components Atm2560Usart0P as Atm2560UsartP, HplAtm2560Usart0P as HplAtm2560UsartP, HplAtm2560PowerC;

  StdControl = Atm2560UsartP;
  UartStream = Atm2560UsartP;
  UartByte = Atm2560UsartP;
  SerialFlush = Atm2560UsartP;

  BusyWait = Atm2560UsartP;
  McuPowerState = Atm2560UsartP;
  Atm2560UsartConfig = Atm2560UsartP;
  Atm2560UsartConfig = HplAtm2560UsartP;

  Atm2560UsartP.HplUsartInit -> HplAtm2560UsartP;
  Atm2560UsartP.HplRxControl -> HplAtm2560UsartP.RxControl;
  Atm2560UsartP.HplTxControl -> HplAtm2560UsartP.TxControl;
  Atm2560UsartP.HplUsart -> HplAtm2560UsartP;
  Atm2560UsartP.HplPower -> HplAtm2560PowerC;
}
