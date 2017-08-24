/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2012-2017  Adriano Branco
	
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
 * wdvm - WSNDyn virtual machine project
 * July, 2012
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Configuration: SensAct
 * Local sensors and actuators
 * Signal reads for up to 4 different requesters
 * 
 */

configuration SensActC{
	provides interface SensAct as SAinterface;
}
implementation{
	components SensActP;
#ifdef TOSSIM
	components dataSensorC as dtSensor;
	SensActP.S_TEMP -> dtSensor.Temp;
	SensActP.S_PHOTO -> dtSensor.Photo;
	SensActP.S_VOLT -> dtSensor.Volt;
/*  
	// TOSSIM sensor components
	components new DemoSensorC() as S_TEMP;
	components new DemoSensorC() as S_PHOTO;
	components new DemoSensorC() as S_VOLT;
	SensActP.S_TEMP -> S_TEMP;
	SensActP.S_PHOTO -> S_PHOTO;
	SensActP.S_VOLT -> S_VOLT;
*/
#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
	components new TempC() as S_TEMP;
	components new PhotoC() as S_PHOTO;
	components new VoltageC() as S_VOLT;
	SensActP.S_TEMP -> S_TEMP;
	SensActP.S_PHOTO -> S_PHOTO;
	SensActP.S_VOLT -> S_VOLT;
	#if SBOARD == 300
		// MicStream and Sounder
		components new MicStreamC() as MicStream, SounderC;
		SensActP.S_MIC -> MicStream;
		SensActP.S_MIC_CFG -> MicStream;
		SensActP.A_SOUNDER -> SounderC;
	#endif

#elif defined(PLATFORM_MICA2DOT)
	components new TempC() as S_TEMP;
	components new DemoSensorC() as S_PHOTO; // USe DemoSensor for Photo and Volt
	components new DemoSensorC() as S_VOLT;
	SensActP.S_TEMP -> S_TEMP;
	SensActP.S_PHOTO -> S_PHOTO;
	SensActP.S_VOLT -> S_VOLT;

#elif defined(PLATFORM_TELOSB)
#ifndef M_VCN_DAT  // Disable sensors when using Volcano Data in TelosB
	components new SensirionSht11C() as S_TEMP;
	components new HamamatsuS1087ParC() as S_PHOTO;
	components new VoltageC() as S_VOLT;
	SensActP.S_TEMP -> S_TEMP.Temperature;
	SensActP.S_PHOTO -> S_PHOTO;
	SensActP.S_VOLT -> S_VOLT;
#endif
#endif
	components LedsC as A_LEDS;

	SAinterface = SensActP.SA;
	SensActP.A_LEDS -> A_LEDS;

#ifndef TOSSIM
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)
	components MicaBusC as Bus;
	SensActP.A_PIN1 -> Bus.PW4;
	SensActP.A_PIN2 -> Bus.PW5;
#if TOSVERSION >= 212
	SensActP.A_INT1 -> Bus.Int0_Interrupt;
	SensActP.A_INT2 -> Bus.Int1_Interrupt;
#endif // TOSVERSION >= 212
#if TOSVERSION <= 211
	components HplAtm128InterruptC as GenIOCInt;
	SensActP.A_INT1 -> GenIOCInt.Int0;
	SensActP.A_INT2 -> GenIOCInt.Int1;
#endif //TOSVERSION <= 211
//--	components HplAtm128GeneralIOC as GenIOC; // MicaZ
//	components HplAtm128InterruptC as GenIOCInt; // MicaZ
//--	SensActP.A_PIN1 -> GenIOC.PortC4;
//--	SensActP.A_PIN2 -> GenIOC.PortC5;
//	SensActP.A_INT1 -> GenIOCInt.Int0;
//	SensActP.A_INT2 -> GenIOCInt.Int1;
#elif defined(PLATFORM_TELOSB)


#endif // #if defined(...)

#endif	// TOSSIM
	
}