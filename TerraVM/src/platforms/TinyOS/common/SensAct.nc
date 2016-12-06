/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Interface: SensAct
 * Local sensors and actuators
 * 
 */

interface SensAct{
	
	// Request a reading to sensor 'id'
	command void reqSensor(uint8_t reqSource, uint8_t id);
	
	// Signal a sensor done event
	event void Ready(uint8_t reqSource,uint8_t codeEvt_id);
	
	// gets the last sensor read value
	command uint16_t readSensor(uint8_t id);

	// Writes 'val' to actuator 'id'
	command void setActuator(uint8_t id, uint16_t val);

	command void* getDatap(uint8_t id);
	
	// Request a Stream sensor data -- only for stream sensors
	command void reqStreamSensor(uint8_t reqSource, uint8_t id, uint16_t* buf, uint16_t count, uint32_t usPeriod, uint8_t gain);	
}
 