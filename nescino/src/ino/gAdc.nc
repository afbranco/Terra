interface gAdc{
	/**
	 * Start the A/D conversion. The result is signaled wuth 'readDone()' event.
	 */
	command error_t Read();
	
	/**
	 * Return a A/D conversion value.
	 * @param data -- A/D read value.
	 */
	event void readDone(uint16_t data);


	/**
	 * Define conversion mode: Multiple reads or Single Read.
	 * @param value -- TRUE define multiple reads mode. FALSE means a single read.
	 */
	command void setMultiple(bool value);
	
	/**
	 * Define analog input pin.
	 * @param pin -- Pin identifier 0--8. (Default value is 0)
	 */
	command void setPin(uint8_t pin);
	
	/**
	 * Define Reference Voltage value.
	 * @param refVoltage -- ATM128_ADC_VREF_XXX where XXX must be: OFF, AVCC, 1_1, or 2_56. (Default value is ATM128_ADC_VREF_AVCC) 
	 */
	command void setRefVoltage(uint8_t refVoltage);
	
	/**
	 * Define prescaler value. It changes conversion precision and time.
	 * @param prescaler -- Prescaler ADC counter value. Default ATM128_ADC_PRESCALE gives full precision. Possible value is an ATM128_ADC_PRESCALE_XX where XX must be: 2,2b,4,8,16,32,64,128.
	 */
	command void setPrescaler(uint8_t prescaler);
	
	/**
	 * Define all parameters.
	 * @param multiple -- TRUE define multiple reads mode. FALSE means a single read.
	 * @param pin -- Pin identifier 0--8. (Default value is 0)
	 * @param refVoltage -- ATM128_ADC_VREF_XXX where XXX must be: OFF, AVCC, 1_1, or 2_56. (Default value is ATM128_ADC_VREF_AVCC) 
	 * @param prescaler -- Prescaler ADC counter value. Default ATM128_ADC_PRESCALE gives full precision. Possible value is an ATM128_ADC_PRESCALE_XX where XX must be: 2,2b,4,8,16,32,64,128.
     */
	command void set(bool multiple,uint8_t pin, uint8_t refVoltage, uint8_t prescaler);
	
	
}