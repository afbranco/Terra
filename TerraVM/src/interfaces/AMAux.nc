interface AMAux{
	command void setPower(message_t* p_msg, uint8_t power );
	command uint8_t getPower(message_t* p_msg);
}