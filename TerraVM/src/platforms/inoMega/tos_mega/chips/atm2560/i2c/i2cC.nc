configuration i2cC{
	provides interface i2c;
}
implementation{
	components i2cP, MainC;
	i2c = i2cP;
	i2cP.Boot -> MainC;
}