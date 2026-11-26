#ifndef SENS_ACT_H
#define SENS_ACT_H

// Portas e interrupções (SET/CFG/REQ_PORT, CFG_INT, PORT_A/B, INT_A/B): só no hardware mica, fora do
// TOSSIM (#100).
#if !defined(TOSSIM) && (defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS))
#define TERRA_PORTS 1
#endif

// Microfone e sounder: só com a placa MTS300 (SENSOR=MTS300CA/CB) nos mica, fora do TOSSIM. É a mesma
// condição do MIC no .defs gerado (TerraVM/src/defs, #100).
#if !defined(TOSSIM) && (defined(PLATFORM_MICAZ) || defined(PLATFORM_MICA2) || defined(PLATFORM_IRIS)) && SBOARD == 300
#define TERRA_MIC 1
#endif


enum{
	// Sensor control BIT (Identify request sources) max=4 - 0..3)
	SENSOR_CTL_BIT = 6,
	REQ_SOURCE1 = 0,	// Used for VM requests
	REQ_SOURCE2 = 1,	// Used for GRP-AggregReq
	REQ_SOURCE3 = 2,	// Used for GRP-AggregLocal
	REQ_SOURCE4 = 3,	// Used for GRP-Election
	
	// Actuator IDs (max 31)
	AID_LEDS = 1,
	AID_LED0 = 2,
	AID_LED1 = 3,
	AID_LED2 = 4,
	AID_LED0_TOGGLE = 5,
	AID_LED1_TOGGLE = 6,
	AID_LED2_TOGGLE = 7,
	AID_OUT1 = 8,
	AID_OUT2 = 9,
	AID_PIN1 =10,
	AID_PIN2 =11,
	AID_INT1 =12,
	AID_INT2 =13,
	AID_SOUNDER =14,

};
#endif /* SENS_ACT_H */
