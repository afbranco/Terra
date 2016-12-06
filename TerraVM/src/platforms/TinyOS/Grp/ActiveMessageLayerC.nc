/*
 * Copyright (c) 2009, Vanderbilt University
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
 * - Neither the name of the copyright holder nor the names of
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
 *
 * Author: Miklos Maroti
 */

generic configuration ActiveMessageLayerC()
{
	provides
	{
		interface AMPacket;
		interface Packet;
		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];
		interface Receive as ReceiveUser[am_id_t id];
		interface Receive as Snoop[am_id_t id];	
		interface SendNotifier[am_id_t id];

		// for TOSThreads
		interface Receive as ReceiveDefault[am_id_t id];
		interface Receive as SnoopDefault[am_id_t id];
	}

	uses
	{
		interface RadioPacket as SubPacket;
		interface BareSend as SubSend;
		interface BareReceive as SubReceive;
		interface ActiveMessageConfig as Config;
	}
}

implementation
{
	components new ActiveMessageLayerP(), ActiveMessageAddressC;
	ActiveMessageLayerP.ActiveMessageAddress -> ActiveMessageAddressC;

	AMPacket = ActiveMessageLayerP;
	Packet = ActiveMessageLayerP;
	AMSend = ActiveMessageLayerP;
	Receive = ActiveMessageLayerP.Receive;
	ReceiveUser = ActiveMessageLayerP.ReceiveUser;
	Snoop = ActiveMessageLayerP.Snoop;
	SendNotifier = ActiveMessageLayerP;

	ReceiveDefault = ActiveMessageLayerP.ReceiveDefault;
	SnoopDefault = ActiveMessageLayerP.SnoopDefault;

	SubPacket = ActiveMessageLayerP;
	SubSend = ActiveMessageLayerP;
	SubReceive = ActiveMessageLayerP;
	Config = ActiveMessageLayerP;
}
