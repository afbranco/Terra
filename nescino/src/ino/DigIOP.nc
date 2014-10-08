module DigIOP{
	provides interface DigIO;
	uses interface GeneralIOX;
	
}
implementation{
	

	uint8_t pin2port(uint8_t pin){
		switch (pin/8){
			case 0 : return (uint8_t)&PORTA; break;
			case 1 : return (uint8_t)&PORTB; break;
			case 2 : return (uint8_t)&PORTC; break;
			case 3 : return (uint8_t)&PORTD; break;
			case 4 : return (uint8_t)&PORTE; break;
			case 5 : return (uint8_t)&PORTF; break;
		}
		return (uint8_t)&PORTF;
	}
	uint8_t pin2ddr(uint8_t pin){
		switch (pin/8){
			case 0 : return (uint8_t)&DDRA; break;
			case 1 : return (uint8_t)&DDRB; break;
			case 2 : return (uint8_t)&DDRC; break;
			case 3 : return (uint8_t)&DDRD; break;
			case 4 : return (uint8_t)&DDRE; break;
			case 5 : return (uint8_t)&DDRF; break;
		}
		return (uint8_t)&DDRF;
	}
	uint8_t pin2pin(uint8_t pin){
		switch (pin/8){
			case 0 : return (uint8_t)&PINA; break;
			case 1 : return (uint8_t)&PINB; break;
			case 2 : return (uint8_t)&PINC; break;
			case 3 : return (uint8_t)&PIND; break;
			case 4 : return (uint8_t)&PINE; break;
			case 5 : return (uint8_t)&PINF; break;
		}
		return (uint8_t)&PINF;
	}

	command bool DigIO.get(uint8_t pin){return call GeneralIOX.get(pin2pin(pin), pin%8);}
	command void DigIO.set(uint8_t pin){call GeneralIOX.set(pin2port(pin), pin%8);}
	command void DigIO.clr(uint8_t pin){call GeneralIOX.clr(pin2port(pin), pin%8);}
	command void DigIO.toggle(uint8_t pin){call GeneralIOX.toggle(pin2port(pin), pin%8);}
	command void DigIO.write(uint8_t pin, uint8_t value){
		if (value==0)
			call GeneralIOX.clr(pin2port(pin), pin%8);
		else
			call GeneralIOX.set(pin2port(pin), pin%8);
	}

	command void DigIO.makeOutput(uint8_t pin){call GeneralIOX.makeOutput(pin2ddr(pin), pin%8);}
	command void DigIO.makeInput(uint8_t pin){call GeneralIOX.makeInput(pin2ddr(pin), pin%8);}
	command bool DigIO.isInput(uint8_t pin){return call GeneralIOX.isInput(pin2ddr(pin), pin%8);}
	command bool DigIO.isOutput(uint8_t pin){return call GeneralIOX.isOutput(pin2ddr(pin), pin%8);}



}