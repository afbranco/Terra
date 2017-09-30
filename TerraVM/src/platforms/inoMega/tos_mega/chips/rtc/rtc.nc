#include "rtc.h"
interface rtc{
	// DateTime
	command void setDateTime(rtcDateTime_t* data);
	command void getDateTime(rtcDateTime_t* data);

	// Alarm
	command void setAlarm(rtcDateTime_t* data);
	// ?? command void getAlarm(rtcDateTime_t* data);
	command void setAlarmMode(uint8_t mode);
	command void enableAlarm();
	command void disableAlarm();
	// Alarm interrupt must be handled by generic interrup support
}