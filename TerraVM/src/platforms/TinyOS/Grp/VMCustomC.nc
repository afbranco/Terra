/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2014-2017  Adriano Branco
	
	This file is part of Terra IoT.
	
	Terra IoT is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Terra IoT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  
*/  

/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/

configuration VMCustomC{
	provides interface VMCustom;
}
implementation{
/*
 * Basic implementation from TerraNet
 */
	components VMCustomP as custom, MainC;
	custom.VM = VMCustom;
	custom.Boot -> MainC;
	
/*
 * Local Sensors and Actuators
 */
	components SensActC as SA;
	custom.SA -> SA;

/*
 * Terra Group Extension (TerraGrp)
 */
	components RandomC;
	custom.Random -> RandomC;
	components GroupControlC;
	custom.GrCtl -> GroupControlC;
#ifndef ONLY_BSTATION
    components new TimerMilliC() as Timer;
	components new TimerMilliC() as AggTmr;
	components new TimerMilliC() as ElectionTmr;
	components new TimerMilliC() as renewTmr;
	custom.AggTmr -> AggTmr;
	custom.ElectionTmr -> ElectionTmr;
	custom.renewTmr -> renewTmr;
#endif	
#ifndef ONLY_BSTATION
	components new QueueC(uint32_t,AGG_QUEUE_SIZE) as  aggQ;
	custom.aggQ -> aggQ;
	components new dataQueueC(aggReqData_t,AGGREQ_QUEUE_SIZE,1) as  aggReqQ;
	custom.aggReqQ -> aggReqQ;
	components new dataQueueC(uint16_t,AGGREQ_QUEUE_SIZE,2) as  aggLocalReqQ;
	custom.aggLocalReqQ -> aggLocalReqQ;
	components new QueueC(uint8_t,ELCT_QUEUE_SIZE) as  electionQ;
	custom.electionQ -> electionQ;
#endif

}