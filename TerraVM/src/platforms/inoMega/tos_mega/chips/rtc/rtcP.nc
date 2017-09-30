#include "rtc.h"
module rtcP{
	provides interface rtc;
	uses interface i2c;
	uses interface Boot;
    uses interface Timer<TMilli> as TestTimer;
}
implementation{

	rtcState_t state = IDLE;
	rtcDateTime_t dataBuffer;
	uint8_t alarmModeBuffer;

	static uint8_t bcd2bin (uint8_t val) { return val - 6 * (val >> 4); }
	static uint8_t bin2bcd (uint8_t val) { return val + 6 * (val / 10); }
	uint8_t * struct2reg(uint8_t* msg){
		msg[0]=0; // start at location 0
		msg[1]=(bin2bcd(dataBuffer.s));
		msg[2]=(bin2bcd(dataBuffer.m));
		msg[3]=(bin2bcd(dataBuffer.h));
		msg[4]=(bin2bcd(0));
		msg[5]=(bin2bcd(dataBuffer.D));
		msg[6]=(bin2bcd(dataBuffer.M));
		msg[7]=(bin2bcd(dataBuffer.Y));
		return msg;
	}
	
	void reg2struc(uint8_t* msg){
		dataBuffer.s = bcd2bin(msg[0]&0x7F);
		dataBuffer.m = bcd2bin(msg[1]);
		dataBuffer.h = bcd2bin(msg[2]);
		dataBuffer.D = bcd2bin(msg[4]);
		dataBuffer.M = bcd2bin(msg[5]);
		dataBuffer.Y = bcd2bin(msg[6]);
	}
	
	
	event void Boot.booted(){
		DDRK=0xff;
		DDRB=0xff;
		PORTK=0x11;
		atomic{state = IDLE;}
		call TestTimer.startOneShot(2000);
	}

	command void rtc.setDateTime(rtcDateTime_t* data){
		uint8_t msg[16];
		msg[0] = (DS3231_ADDRESS << 1) & 0xFE;
		msg[1] = 0; // 1st reg addr
		memcpy(&dataBuffer,data,sizeof(rtcDateTime_t));
		struct2reg(&msg[2]); // binary to BCD
		state = SET_DATETIME_IN;
		call i2c.write(msg, 10,0);
		
		//??
//		uint8_t statreg = read_i2c_register(DS3231_ADDRESS, DS3231_STATUSREG);
//  		statreg &= ~0x80; // flip OSF bit
//		write_i2c_register(DS3231_ADDRESS, DS3231_STATUSREG, statreg);
	}

	command void rtc.getDateTime(rtcDateTime_t* data){
		uint8_t msg[10];
		memcpy(&dataBuffer,data,sizeof(rtcDateTime_t));
		state = GET_DATETIME_IN;
		msg[0]=0;
//		call i2c.write(I2C_START | I2C_STOP,DS3231_ADDRESS, 1, msg);		
//		call i2c.read(I2C_START | I2C_STOP, DS3231_ADDRESS, 7, msg);
		reg2struc(msg);		
	}

	// Alarm
	command void rtc.setAlarm(rtcDateTime_t* data){
		memcpy(&dataBuffer,data,sizeof(rtcDateTime_t));
		state = SET_ALARM_IN;
		
	}
	command void rtc.setAlarmMode(uint8_t mode){
		alarmModeBuffer = mode;
		state = SET_ALARMMODE_IN;
		
	}
	command void rtc.enableAlarm(){
		state = ENABLE_ALARM_IN;
		
	}
	command void rtc.disableAlarm(){
		state = DISABLE_ALARM_IN;
		
	}



	async event void i2c.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t *data){
		PORTB |= (1<<7);
		switch(state){
			case SET_DATETIME_PROC 	: PORTK = data[0]; PORTB |= (1<<4); break;
			case GET_DATETIME_PROC 	: break;
			case SET_ALARM_PROC 	: break;
			case SET_ALARMMODE_PROC : break;
			case ENABLE_ALARM_PROC 	: break;
			case DISABLE_ALARM_PROC : break;
			default: break;
		}	
	}

	async event void i2c.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t *data){
		switch(state){
			case IDLE				: break;
			case SET_DATETIME_PROC 	: break;
			case GET_DATETIME_PROC 	: break;
			case SET_ALARM_PROC 	: break;
			case SET_ALARMMODE_PROC : break;
			case ENABLE_ALARM_PROC 	: break;
			case DISABLE_ALARM_PROC : break;
			default: break;
		}	
	}

	event void TestTimer.fired(){
		rtcDateTime_t data;
		atomic{call rtc.setDateTime(&data);}
	}
}