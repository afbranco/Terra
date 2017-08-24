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