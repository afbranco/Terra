generic configuration gAdcC(){
	provides interface gAdc;
}
implementation{
	components gAdcP;
	gAdc = gAdcP;
	
  components Atm128AdcC as Adcx;
  gAdcP.Resource -> Adcx.Resource[unique("gAdc")];
  gAdcP.Atm128AdcSingle -> Adcx;
  gAdcP.Atm128AdcMultiple -> Adcx;

}