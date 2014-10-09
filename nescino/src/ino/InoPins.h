#ifndef INO_PINS_H
#define INO_PINS_H

/**
 * Arduino <--> nesCino equivalence pins table (ArduinoMega2560)
 * 
 */

typedef enum{
	/*
	 * Digital Pins
	 */
	 D22 =  0,	// PA0
	 D23 =  1,	// PA1
	 D24 =  2,	// PA2
	 D25 =  3,	// PA3
	 D26 =  4,	// PA4
	 D27 =  5,	// PA5
	 D28 =  6,	// PA6
	 D29 =  7,	// PA7

	 D53 =  8,	// PB0 (SS)
	 D52 =  9,	// PB1 (SCK)
	 D51 = 10,	// PB2 (MOSI)
	 D50 = 11,	// PB3 (MISO)
	 D10 = 12,	// PB4 (PWM/OC2A)
	 D11 = 13,	// PB5 (PWM/OC1A)
	 D12 = 14,	// PB6 (PWM/OC1B)
	 D13 = 15,	// PB7 (PWM/OC0A/OC1C)
	 
	 D37 = 16, 	// PC0
	 D36 = 17, 	// PC1
	 D35 = 18, 	// PC2
	 D34 = 19, 	// PC3
	 D33 = 20, 	// PC4
	 D32 = 21, 	// PC5
	 D31 = 22, 	// PC6
	 D30 = 23, 	// PC7

	 D21 = 24, 	// PD0 (SCL)
	 D20 = 25, 	// PD1 (SDA)
	 D19 = 26, 	// PD2 (RX1)
	 D18 = 27, 	// PD3 (TX1)
	 //Dxx = 28, 	// PD4
	 //Dxx = 29, 	// PD5
	 //Dxx = 30, 	// PD6
	 D38 = 31, 	// PD7
	 
	 D0  = 32, 	// PE0 (RX0)
	 D1  = 33, 	// PE1 (TX0)
	 //Dxx = 34, 	// PE2
	 D5  = 35, 	// PE3 (PWM/OC3A)
	 D2  = 36, 	// PE4 (PWM/OC3B) [INT4]
	 D3  = 37, 	// PE5 (PWM/OC3C) [INT5]
	 //Dxx = 38, 	// PE6
	 //Dxx = 39, 	// PE7

	// PG ????
	
	// PH ???? 

	// PJ ???? 

} digital_enum;

typedef enum {
	A0  =  0, 	// PF0 (ADC0)  
	A1  =  1, 	// PF1 (ADC1)  
	A2  =  2, 	// PF2 (ADC2)  
	A3  =  3, 	// PF3 (ADC3)  
	A4  =  4, 	// PF4 (ADC4)  
	A5  =  5, 	// PF5 (ADC5)  
	A6  =  6, 	// PF6 (ADC6)  
	A7  =  7, 	// PF7 (ADC7)  

	// PK ????
	A8  =  8, 	// PK0 (ADC8)  
	A9  =  9, 	// PK1 (ADC9)  
	A10 = 10, 	// PK2 (ADC10)  
	A11 = 11, 	// PK3 (ADC11)  
	A12 = 12, 	// PK4 (ADC12)  
	A13 = 13, 	// PK5 (ADC13)  
	A14 = 14, 	// PK6 (ADC14)  
	A15 = 15, 	// PK7 (ADC15)  

	// PL ???? 

} analog_enum;

	/**
	 * Interruption pins
	 */
typedef enum {	
	I0 = 0, 
	I1 = 1, 
	I2 = 2, 
	I3 = 3, 
	I4 = 4, 
} interrupt_enum;	

typedef enum {
	INPUT = 0,
	OUTPUT = 1,
	INPUT_PULLUP = 2,
} pinmode_enum;

typedef enum {
	LOW = 0,
	HIGH = 1,
} pinvalue_enum;


typedef enum {
	DEFAULT=0, INTERNAL=1, INTERNAL1V1=2, INTERNAL2V56=3, EXTERNAL=4
} analogref_enum;

#endif /* INO_PINS_H */
