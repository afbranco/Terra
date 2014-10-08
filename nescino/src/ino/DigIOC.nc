configuration DigIOC{
	provides interface DigIO;
}
implementation{
	components DigIOP, HplAtm128GeneralIOPinXP as IOPin;
	
	DigIO = DigIOP;
	DigIOP.GeneralIOX -> IOPin;
	
}