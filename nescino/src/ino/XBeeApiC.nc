configuration XBeeApiC{
	provides interface XBeeApi;
}
implementation{
	
	components XBeeApiP, MainC;
	XBeeApiP.Boot -> MainC;
	XBeeApi = XBeeApiP;
	
	components HdlcTranslateC as UART1_BYTE;
	components Atm128Uart1C as UART1_RAW;

  	XBeeApiP -> UART1_BYTE.SerialFrameComm;
  	UART1_BYTE.UartStream -> UART1_RAW;
  	XBeeApiP.XBeeCtl -> UART1_RAW;

}