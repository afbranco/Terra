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
	}
	uses {
		interface Counter<TMicro,uint32_t> as clock;
		interface Atm128Calibrate;
		interface Timer<TMilli> as pulseTimer0;
		interface Timer<TMilli> as pulseTimer1;
		interface Timer<TMilli> as pulseTimer2;
		interface Timer<TMilli> as pulseTimer3;
	}
}
implementation{
	
	/*
	 * Global state control
	 */
	analog_enum currAnalogPin;
	uint32_t pulseStart[4];
	uint32_t pulseEnd[4];
	pinvalue_enum pulseValue[4];
	bool isPulse[4];
	

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
			case INTERNAL 		: refVoltage = ATM128_ADC_VREF_1_1; break;
			case INTERNAL1V1 	: refVoltage = ATM128_ADC_VREF_1_1; break;
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
			default : break;
		}
	}

	command void InoIO.interruptFallingEdge(interrupt_enum intPin){
		switch (intPin) {
			case I0 : call pInt0.enableFallingEdge(); break;
			case I1 : call pInt1.enableFallingEdge(); break;
			case I2 : call pInt2.enableFallingEdge(); break;
			case I3 : call pInt3.enableFallingEdge(); break;
			default : break;
		}
	}

	command void InoIO.interruptDisable(interrupt_enum intPin){
		switch (intPin) {
			case I0 : call pInt0.disable(); break;
			case I1 : call pInt1.disable(); break;
			case I2 : call pInt2.disable(); break;
			case I3 : call pInt3.disable(); break;
			default : break;
		}
	}

	command void InoIO.pulseIn(interrupt_enum intPin, pinvalue_enum value, uint32_t timeout){
		switch (intPin) {
			case I0 : 	atomic{isPulse[0]=TRUE;}
						call pInt0.disable();
						call pulseTimer0.startOneShot(timeout);
						atomic{
							pulseStart[0] = 0;
							pulseEnd[0] = 0;
							pulseValue[0]=value;
						}
						if (value == HIGH)
							call pInt0.enableRisingEdge();
						else
							call pInt0.enableFallingEdge();
						break;
			default: break;
		}
	}
			
	task void pInt0_pulseLen(){
		uint32_t len;
		atomic{
			len = pulseEnd[0]-pulseStart[0];
			pulseEnd[0]=0;
			pulseStart[0]=0;
			isPulse[0]=FALSE;
		}
		signal InoIO.pulseLen(I0,pulseValue[0],len);
	}

	async event void pInt0.fired(){
		if (isPulse[0]==TRUE){	// is a pulse interruption
			if (pulseStart[0]==0) { // pulse start
				pulseStart[0] = getClockMicro();
				call pulseTimer0.stop();
				call pulseTimer0.startOneShot(5L*60L*1000L); // len max = 5 min.; 2nd timeout			
				if (pulseValue[0]== HIGH) // wait end of pulse
					call pInt0.enableFallingEdge();
				else
					call pInt0.enableRisingEdge();
			} else { // pulse end
				pulseEnd[0] = getClockMicro();
				call pulseTimer0.stop();
				isPulse[0]=FALSE;
				post pInt0_pulseLen();
			}
		} else { // is not a pulse interruption
			signal InoIO.interruptFired(I0);
		}
	}

	event void pulseTimer0.fired(){
		call pInt0.disable();
		atomic{
			isPulse[0]=0;
			pulseStart[0]=0;
			pulseEnd[0]=0;			
		}
		signal InoIO.pulseLen(I0,pulseValue[0],0);		
	}



	async event void pInt1.fired(){
		// TODO Auto-generated method stub
	}

	async event void pInt2.fired(){
		// TODO Auto-generated method stub
	}

	async event void pInt3.fired(){
		// TODO Auto-generated method stub
	}


	event void pulseTimer1.fired(){
		// TODO Auto-generated method stub
	}

	event void pulseTimer2.fired(){
		// TODO Auto-generated method stub
	}

	event void pulseTimer3.fired(){
		// TODO Auto-generated method stub
	}

	async event void clock.overflow(){
		// TODO Auto-generated method stub
	}
}