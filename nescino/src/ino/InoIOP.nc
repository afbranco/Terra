#include "InoPins.h"
module InoIOP{
	provides interface InoIO;
	uses interface DigIO;
	uses interface gAdc;
	uses {
		interface GpioInterrupt as pInt0;
		interface GpioInterrupt as pInt1;
		interface GpioInterrupt as pInt2;
		interface GpioInterrupt as pInt3;
		interface GpioInterrupt as pInt4;
		interface GpioInterrupt as pInt5;
	}
	uses {
		interface Counter<TMicro,uint32_t> as clock;
		interface Atm128Calibrate;
		interface Timer<TMilli> as pulseTimer0;
		interface Timer<TMilli> as pulseTimer1;
		interface Timer<TMilli> as pulseTimer2;
		interface Timer<TMilli> as pulseTimer3;
		interface Timer<TMilli> as pulseTimer4;
		interface Timer<TMilli> as pulseTimer5;
	}
}
implementation{
	
	/*
	 * Global state control
	 */
	analog_enum currAnalogPin;
	uint32_t pulseStart[6];
	uint32_t pulseEnd[6];
	pinvalue_enum pulseValue[6];
	bool isPulse[6];
	

	/**
	 * Function to get Clock Micro
	 */
	uint32_t getClockMicro(){
//		return ((call clock.get() / call Atm128Calibrate.cyclesPerJiffy())*1000)/1024;
		return call Atm128Calibrate.actualMicro(call clock.get());
	}
	
	/*
	 * Digital pins operation
	 */

	command void InoIO.pinMode(digital_enum pin, pinmode_enum mode){
		switch (mode){
			case INPUT 			: call DigIO.makeInput(pin); break;
			case OUTPUT 		: call DigIO.makeOutput(pin); break;
			case INPUT_PULLUP 	: call DigIO.makeInput(pin); call DigIO.set(pin); break;
		}
	}

	command void InoIO.digitalWrite(digital_enum pin, pinvalue_enum value){
		call DigIO.write(pin, value);
	}

	command pinvalue_enum InoIO.digitalRead(digital_enum pin){
		return call DigIO.get(pin);
	}

	command void InoIO.digitalToggle(digital_enum pin){
		call DigIO.toggle(pin);
	}

	/*
	 * Analog Pins operation
	 */

	command void InoIO.analogReference(analogref_enum type){
		uint8_t refVoltage;
		switch (type){
			case DEFAULT 		: refVoltage = ATM128_ADC_VREF_AVCC; break;
#ifdef MEGA
			case INTERNAL 		: refVoltage = ATM128_ADC_VREF_1_1; break;
			case INTERNAL1V1 	: refVoltage = ATM128_ADC_VREF_1_1; break;
#endif
			case INTERNAL2V56 	: refVoltage = ATM128_ADC_VREF_2_56; break;
			case EXTERNAL 		: refVoltage = ATM128_ADC_VREF_OFF; break;
			default 			: refVoltage = ATM128_ADC_VREF_AVCC; break;
		}
		call gAdc.setRefVoltage(refVoltage);
	}

	command error_t InoIO.analogRead(analog_enum pin){
		error_t stat;
		call gAdc.setPin(pin);
		stat =  call gAdc.Read();
		if (stat == SUCCESS) currAnalogPin = pin;
		return stat;
	}
	
	event void gAdc.readDone(uint16_t data){
		signal InoIO.analogReadDone(currAnalogPin, data);
	}



	/*
	 * Interrupt pins operation
	 */

	command void InoIO.interruptRisingEdge(interrupt_enum intPin){
		switch (intPin) {
			case I0 : call pInt0.enableRisingEdge(); break;
			case I1 : call pInt1.enableRisingEdge(); break;
			case I2 : call pInt2.enableRisingEdge(); break;
			case I3 : call pInt3.enableRisingEdge(); break;
			case I4 : call pInt4.enableRisingEdge(); break;
			case I5 : call pInt5.enableRisingEdge(); break;
			default : break;
		}
	}

	command void InoIO.interruptFallingEdge(interrupt_enum intPin){
		switch (intPin) {
			case I0 : call pInt0.enableFallingEdge(); break;
			case I1 : call pInt1.enableFallingEdge(); break;
			case I2 : call pInt2.enableFallingEdge(); break;
			case I3 : call pInt3.enableFallingEdge(); break;
			case I4 : call pInt4.enableFallingEdge(); break;
			case I5 : call pInt5.enableFallingEdge(); break;
			default : break;
		}
	}

	command void InoIO.interruptDisable(interrupt_enum intPin){
		switch (intPin) {
			case I0 : call pInt0.disable(); break;
			case I1 : call pInt1.disable(); break;
			case I2 : call pInt2.disable(); break;
			case I3 : call pInt3.disable(); break;
			case I4 : call pInt4.disable(); break;
			case I5 : call pInt5.disable(); break;
			default : break;
		}
	}

	command void InoIO.pulseIn(interrupt_enum intPin, pinvalue_enum value, uint32_t timeout){
		switch (intPin) {
			case I0 : 	atomic{isPulse[intPin]=TRUE;}
						call pInt0.disable();
						call pulseTimer0.startOneShot(timeout);
						atomic{pulseStart[intPin] = 0; pulseEnd[intPin] = 0; pulseValue[intPin]=value;}
						if (value == HIGH) call pInt0.enableRisingEdge(); else call pInt0.enableFallingEdge();
						break;
			case I1 : 	atomic{isPulse[intPin]=TRUE;}
						call pInt1.disable();
						call pulseTimer1.startOneShot(timeout);
						atomic{pulseStart[intPin] = 0; pulseEnd[intPin] = 0; pulseValue[intPin]=value;}
						if (value == HIGH) call pInt1.enableRisingEdge(); else call pInt1.enableFallingEdge();
						break;
			case I2 : 	atomic{isPulse[intPin]=TRUE;}
						call pInt2.disable();
						call pulseTimer2.startOneShot(timeout);
						atomic{pulseStart[intPin] = 0; pulseEnd[intPin] = 0; pulseValue[intPin]=value;}
						if (value == HIGH) call pInt2.enableRisingEdge(); else call pInt2.enableFallingEdge();
						break;
			case I3 : 	atomic{isPulse[intPin]=TRUE;}
						call pInt3.disable();
						call pulseTimer3.startOneShot(timeout);
						atomic{pulseStart[intPin] = 0; pulseEnd[intPin] = 0; pulseValue[intPin]=value;}
						if (value == HIGH) call pInt3.enableRisingEdge(); else call pInt3.enableFallingEdge();
						break;
			case I4 : 	atomic{isPulse[intPin]=TRUE;}
						call pInt4.disable();
						call pulseTimer4.startOneShot(timeout);
						atomic{pulseStart[intPin] = 0; pulseEnd[intPin] = 0; pulseValue[intPin]=value;}
						if (value == HIGH) call pInt4.enableRisingEdge(); else call pInt4.enableFallingEdge();
						break;
			case I5 : 	atomic{isPulse[intPin]=TRUE;}
						call pInt5.disable();
						call pulseTimer5.startOneShot(timeout);
						atomic{pulseStart[intPin] = 0; pulseEnd[intPin] = 0; pulseValue[intPin]=value;}
						if (value == HIGH) call pInt5.enableRisingEdge(); else call pInt5.enableFallingEdge();
						break;
			default: break;
		}
	}
			

	void pulseLen(uint8_t intPin){
		uint32_t len;
		atomic{
			len = pulseEnd[intPin]-pulseStart[intPin];
			pulseEnd[intPin]=0;
			pulseStart[intPin]=0;
			isPulse[intPin]=FALSE;
		}
		signal InoIO.pulseLen(intPin,pulseValue[intPin],len);		
	}
	task void pInt0_pulseLen(){ pulseLen(0);}
	task void pInt1_pulseLen(){ pulseLen(1);}
	task void pInt2_pulseLen(){ pulseLen(2);}
	task void pInt3_pulseLen(){ pulseLen(3);}
	task void pInt4_pulseLen(){ pulseLen(4);}
	task void pInt5_pulseLen(){ pulseLen(5);}

	async event void pInt0.fired(){
		uint8_t intPin = 0;
		if (isPulse[intPin]==TRUE){	// is a pulse interruption
			if (pulseStart[intPin]==0) { // pulse start
				pulseStart[intPin] = getClockMicro();
				//call pulseTimer0.stop();
				//call pulseTimer0.startOneShot(5L*60L*1000L); // len max = 5 min.; 2nd timeout			
				// wait end of pulse
				if (pulseValue[intPin]== HIGH) call pInt0.enableFallingEdge(); else call pInt0.enableRisingEdge();
			} else { // pulse end
				pulseEnd[intPin] = getClockMicro();
				call pulseTimer0.stop();
				isPulse[intPin]=FALSE;
				post pInt0_pulseLen();
			}
		} else { // is not a pulse interruption
			signal InoIO.interruptFired(intPin);
		}
	}

	async event void pInt1.fired(){
		uint8_t intPin = 1;
		if (isPulse[intPin]==TRUE){	// is a pulse interruption
			if (pulseStart[intPin]==0) { // pulse start
				pulseStart[intPin] = getClockMicro();
				//call pulseTimer0.stop();
				//call pulseTimer0.startOneShot(5L*60L*1000L); // len max = 5 min.; 2nd timeout			
				// wait end of pulse
				if (pulseValue[intPin]== HIGH) call pInt1.enableFallingEdge(); else call pInt1.enableRisingEdge();
			} else { // pulse end
				pulseEnd[intPin] = getClockMicro();
				call pulseTimer1.stop();
				isPulse[intPin]=FALSE;
				post pInt1_pulseLen();
			}
		} else { // is not a pulse interruption
			signal InoIO.interruptFired(intPin);
		}
	}

	async event void pInt2.fired(){
		uint8_t intPin = 2;
		if (isPulse[intPin]==TRUE){	// is a pulse interruption
			if (pulseStart[intPin]==0) { // pulse start
				pulseStart[intPin] = getClockMicro();
				//call pulseTimer0.stop();
				//call pulseTimer0.startOneShot(5L*60L*1000L); // len max = 5 min.; 2nd timeout			
				// wait end of pulse
				if (pulseValue[intPin]== HIGH) call pInt2.enableFallingEdge(); else call pInt2.enableRisingEdge();
			} else { // pulse end
				pulseEnd[intPin] = getClockMicro();
				call pulseTimer2.stop();
				isPulse[intPin]=FALSE;
				post pInt2_pulseLen();
			}
		} else { // is not a pulse interruption
			signal InoIO.interruptFired(intPin);
		}
	}

	async event void pInt3.fired(){
		uint8_t intPin = 3;
		if (isPulse[intPin]==TRUE){	// is a pulse interruption
			if (pulseStart[intPin]==0) { // pulse start
				pulseStart[intPin] = getClockMicro();
				//call pulseTimer0.stop();
				//call pulseTimer0.startOneShot(5L*60L*1000L); // len max = 5 min.; 2nd timeout			
				// wait end of pulse
				if (pulseValue[intPin]== HIGH) call pInt3.enableFallingEdge(); else call pInt3.enableRisingEdge();
			} else { // pulse end
				pulseEnd[intPin] = getClockMicro();
				call pulseTimer3.stop();
				isPulse[intPin]=FALSE;
				post pInt3_pulseLen();
			}
		} else { // is not a pulse interruption
			signal InoIO.interruptFired(intPin);
		}
	}

	async event void pInt4.fired(){
		uint8_t intPin = 4;
		if (isPulse[intPin]==TRUE){	// is a pulse interruption
			if (pulseStart[intPin]==0) { // pulse start
				pulseStart[intPin] = getClockMicro();
				//call pulseTimer0.stop();
				//call pulseTimer0.startOneShot(5L*60L*1000L); // len max = 5 min.; 2nd timeout			
				// wait end of pulse
				if (pulseValue[intPin]== HIGH) call pInt4.enableFallingEdge(); else call pInt4.enableRisingEdge();
			} else { // pulse end
				pulseEnd[intPin] = getClockMicro();
				call pulseTimer4.stop();
				isPulse[intPin]=FALSE;
				post pInt4_pulseLen();
			}
		} else { // is not a pulse interruption
			signal InoIO.interruptFired(intPin);
		}
	}

	async event void pInt5.fired(){
		uint8_t intPin = 5;
		if (isPulse[intPin]==TRUE){	// is a pulse interruption
			if (pulseStart[intPin]==0) { // pulse start
				pulseStart[intPin] = getClockMicro();
				//call pulseTimer0.stop();
				//call pulseTimer0.startOneShot(5L*60L*1000L); // len max = 5 min.; 2nd timeout			
				// wait end of pulse
				if (pulseValue[intPin]== HIGH) call pInt5.enableFallingEdge(); else call pInt5.enableRisingEdge();
			} else { // pulse end
				pulseEnd[intPin] = getClockMicro();
				call pulseTimer5.stop();
				isPulse[intPin]=FALSE;
				post pInt5_pulseLen();
			}
		} else { // is not a pulse interruption
			signal InoIO.interruptFired(intPin);
		}
	}

	void pulseTimerx_fired(uint8_t intPin){
		atomic{
			isPulse[intPin]=0;
			pulseStart[intPin]=0;
			pulseEnd[intPin]=0;			
		}
		signal InoIO.pulseLen(intPin,pulseValue[intPin],0);			
	}
	event void pulseTimer0.fired(){ call pInt0.disable(); pulseTimerx_fired(0); }
	event void pulseTimer1.fired(){ call pInt1.disable(); pulseTimerx_fired(1); }
	event void pulseTimer2.fired(){ call pInt2.disable(); pulseTimerx_fired(2); }
	event void pulseTimer3.fired(){ call pInt3.disable(); pulseTimerx_fired(3); }
	event void pulseTimer4.fired(){ call pInt4.disable(); pulseTimerx_fired(4); }
	event void pulseTimer5.fired(){ call pInt5.disable(); pulseTimerx_fired(5); }

	/*
	 * Get micro seconds clock/counter
	 */
	command uint32_t InoIO.getClockMicro(){
		return getClockMicro();
	}


	async event void clock.overflow(){
		// TODO Auto-generated method stub
	}
}