module gAdcP{
	provides interface gAdc;
	uses {
  		interface Resource;
    	interface Atm128AdcSingle;
    	interface Atm128AdcMultiple;
  	}
}
implementation{
	
	// Global Parameters
	bool Multiple = FALSE;
	uint8_t PinId = 0;
	uint8_t RefVoltage = ATM128_ADC_VREF_AVCC;
	uint8_t Prescaler = ATM128_ADC_PRESCALE;

	command error_t gAdc.Read(){
		return call Resource.request();
	}

	command void gAdc.setMultiple(bool value){Multiple = value;}
	command void gAdc.setPin(uint8_t pin){PinId = pin;}
	command void gAdc.setPrescaler(uint8_t prescaler){ Prescaler = prescaler;}
	command void gAdc.setRefVoltage(uint8_t refVoltage){RefVoltage = refVoltage;}

	command void gAdc.set(bool multiple, uint8_t pin, uint8_t refVoltage, uint8_t prescaler){
		Multiple = multiple;
		PinId = pin;
		Prescaler = prescaler;
		RefVoltage = refVoltage;
	}


	event void Resource.granted(){
		if (Multiple)
			call Atm128AdcMultiple.getData(PinId, RefVoltage, FALSE, Prescaler);
		else
			call Atm128AdcSingle.getData(PinId, RefVoltage, FALSE, Prescaler);
	}

	async event void Atm128AdcSingle.dataReady(uint16_t data, bool precise){
		signal gAdc.readDone(data);
		call Resource.release();
	}

	async event bool Atm128AdcMultiple.dataReady(uint16_t data, bool precise, uint8_t channel, uint8_t *newChannel, uint8_t *newRefVoltage){
		signal gAdc.readDone(data);
		// If Multiple was reset, stop multiple reads here!
		if (Multiple) 
			return TRUE;
		else {
			call Resource.release();
			return FALSE;
		}
	}
}