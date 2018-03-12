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
/*
 * Configuration: TerraVMAppC
 * Virtual Machine main control
 * 
 */
configuration TerraVMAppC
{
}
implementation
{
	// Main modules
    components TerraVMC as terra;
#ifdef VM_THIN
    components BasicServicesThinC as BS;
#else
    components BasicServicesC as BS;
#endif
	terra.BSBoot -> BS;
	terra.BSUpload -> BS;
	terra.BSTimerVM -> BS.BSTimerVM;
	terra.BSTimerAsync -> BS.BSTimerAsync;
#ifdef MODE_INTFLASH
	terra.ProgStorage -> BS;
#endif

    components VMCustomC as custom;
	terra.VMCustom -> custom; 

	components new QueueC(evtData_t,EVT_QUEUE_SIZE) as  evtQ;
	terra.evtQ -> evtQ;

//components PrintfC;
//components SerialStartC;

}