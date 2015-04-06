configuration XBeeApiC{
	provides interface XBeeApi;
}
implementation{
	
	components XBeeApiP, MainC;
	XBeeApiP.Boot -> MainC;
	XBeeApi = XBeeApiP;
	
	components HdlcTranslateC as UART1_BYTE;
#if INO_XBEE_USB == 0
	components Atm128Uart0C as UART_RAW;
#else
	components Atm128Uart1C as UART_RAW;
#endif
  	XBeeApiP -> UART1_BYTE.SerialFrameComm;
  	UART1_BYTE.UartStream -> UART_RAW;
  	XBeeApiP.XBeeCtl -> UART_RAW;

}