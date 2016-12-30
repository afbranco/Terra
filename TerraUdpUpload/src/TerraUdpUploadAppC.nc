configuration TerraUdpUploadAppC{
}
implementation{
	components TerraUdpUploadC,  MainC, UDPActiveMessageC as UDP, new TimerMilliC() as Timer;
	
	TerraUdpUploadC.Boot->MainC;
	TerraUdpUploadC.AMPacket->UDP;	
	TerraUdpUploadC.UDPSender->UDP;	
	TerraUdpUploadC.Packet->UDP;	
	TerraUdpUploadC.UDPReceiver->UDP.Receive;
	TerraUdpUploadC.UDPControl->UDP;
	TerraUdpUploadC.PacketAcknowledgements->UDP;
	TerraUdpUploadC.Timer1->Timer;
	
}