configuration dataSensorC{
	provides interface Read<uint16_t> as Temp;
	provides interface Read<uint16_t> as Photo;
	provides interface Read<uint16_t> as Volt;
}
implementation{
	components dataSensorP as sensor;
	components MainC;
	
	sensor.Boot -> MainC;
	Temp = sensor.Temp;
	Photo = sensor.Photo;
	Volt = sensor.Volt;
	
}