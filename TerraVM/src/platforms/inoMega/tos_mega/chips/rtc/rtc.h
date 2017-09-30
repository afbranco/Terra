#ifndef RTC_H
#define RTC_H

#define DS3231_ADDRESS  0x68
#define DS3231_CONTROL  0x0E
#define DS3231_STATUSREG 0x0F

typedef enum rtcState {
	IDLE,
	SET_DATETIME_IN,
	SET_DATETIME_PROC,
	GET_DATETIME_IN,
	GET_DATETIME_PROC,
	SET_ALARM_IN,
	SET_ALARM_PROC,
	SET_ALARMMODE_IN,
	SET_ALARMMODE_PROC,
	ENABLE_ALARM_IN,
	ENABLE_ALARM_PROC,
	DISABLE_ALARM_IN,
	DISABLE_ALARM_PROC,
} rtcState_t;

typedef nx_struct rtcDateTime {
	nx_uint8_t s;
	nx_uint8_t m;
	nx_uint8_t h;
	nx_uint8_t D;
	nx_uint8_t M;
	nx_uint8_t Y;
} rtcDateTime_t;

#endif /* RTC_H */
