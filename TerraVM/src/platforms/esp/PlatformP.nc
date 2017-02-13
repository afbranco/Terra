module PlatformP{
	
	provides interface Init;
	
}
implementation{

	command error_t Init.init(){	
	// Configure baudrate here if not using BStation, otherwise it is configured in EspUSart0p.nc

		// Initialize GPIO operations - Pin14 and 12
		gpio_init();
		PIN_FUNC_SELECT(PERIPHS_IO_MUX_MTMS_U, FUNC_GPIO14); // Power of the temperature sensor
		PIN_FUNC_SELECT(PERIPHS_IO_MUX_MTDI_U, FUNC_GPIO12); // Power of the photo sensor
		PIN_FUNC_SELECT(LED0_PINSELEC_ARG1,  LED0_PINSELEC_ARG2);  // Led0
		// Set as OUTPUT
		gpio_output_set(0, 0, BIT14, 0);
		gpio_output_set(0, 0, BIT12, 0);
		gpio_output_set(0, 0, LED0_GPIO_BIT, 0);
		// Power down all sensors and Led0
		gpio_output_set(0, BIT14, BIT14, 0);
		gpio_output_set(0, BIT12, BIT12, 0);
		gpio_output_set(LED0_GPIO_BIT, 0, LED0_GPIO_BIT, 0);

		uart_div_modify(0, UART_CLK_FREQ / 115200);
		uart_div_modify(1, UART_CLK_FREQ / 115200);

		return SUCCESS;
	}
}