#include "InoPins.h"
interface InoIO{
	/*
	 * Digital IO interface
	 */
	 
	/**
	 * Configure digital pin operation mode
	 * @param pin - Dx digital pin identifier
	 * @param mode - pin operation mode - INPUT, OUTPUT, INPUT_PULLUP
	 */
	command void pinMode(digital_enum pin, pinmode_enum mode);
	 
	/**
	 * Write a HIGH or a LOW value to a digital pin.
	 * @param pin - Dx digital pin identifier
 	 * @param value - HIGH, LOW
  	 */
	command void digitalWrite(digital_enum pin, pinvalue_enum value);
	 
	/**
	 * Reads the value from a specified digital pin, either HIGH or LOW.
	 * @param pin - Dx digital pin identifier
	 */
	command pinvalue_enum digitalRead(digital_enum pin);

	/**
	 * Toggle pin value: 0->1 or 1->0
	 * @param pin - Dx digital pin identifier
  	 */
	command void digitalToggle(digital_enum pin);

	/*
	 * Analog IO interface
	 */

	/**
	 * Configures the reference voltage used for analog input.
	 * @param type - DEFAULT, INTERNAL, INTERNAL1V1, INTERNAL2V56, or EXTERNAL
	 */
	command void analogReference(analogref_enum type);
	
	/**
	 * Request an analog read
	 * @param pin - Ax analog pin identifier
	 * @return !SUCCESS if AD converter is already in use.
  	 */
	command error_t analogRead(analog_enum pin);
	
	/**
	 * Signal (return) an analog read
	 * @param pin - Ax analog pin identifier
 	 * @param value - analog value read (0..1024)
	 */
	event void analogReadDone(analog_enum pin, uint16_t value);


	/*
	 * External pins interruption 
	 */

	/**
	 * Enable to wait for a rising edge on pin
	 * @param intPin - an Ix interruption pin id 
	 */
	command void interruptRisingEdge(interrupt_enum intPin);

	/**
	 * Enable to wait for a falling edge on pin
	 * @param intPin - an Ix interruption pin id 
	 */
	command void interruptFallingEdge(interrupt_enum intPin);

	/**
	 * Disable pin interruption
	 * @param intPin - an Ix interruption pin id 
	 */
	command void interruptDisable(interrupt_enum intPin);

	/**
	 * Signals an interruption on pin
	 * @param intPin - an Ix interruption pin id 
	 */
	event void interruptFired(interrupt_enum intPin);

	/**
	 * Reads a pulse (either HIGH or LOW) on a pin. (Only interruption pins)
	 * @param intPin - an Ix interruption pin id 
	 * @param value - HIGH, LOW
 	 * @param timeout - time to wait for the pulse to start
  	 */
	command void pulseIn(interrupt_enum intPin, pinvalue_enum value, uint32_t timeout);

	/**
	 * Signal (return) the pulse len in microseconds
	 * @param intPin - an Ix interruption pin id 
	 * @param value - HIGH, LOW
 	 * @param len - pulse len in microseconds
  	 */
	event void pulseLen(interrupt_enum intPin, pinvalue_enum value, uint32_t len);

	/**
	 * Reads current micro seconds clock/counter
  	 */
	command uint32_t getClockMicro();
}