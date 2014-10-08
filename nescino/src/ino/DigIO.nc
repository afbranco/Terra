interface DigIO{
	command void write(uint8_t pin, uint8_t value);
	command bool get(uint8_t pin);
	command void set(uint8_t pin);
	command void clr(uint8_t pin);
	command void toggle(uint8_t pin);
	
	command void makeInput(uint8_t pin);
	command void makeOutput(uint8_t pin);
	command bool isInput(uint8_t pin);
	command bool isOutput(uint8_t pin);

}