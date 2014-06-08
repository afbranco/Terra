


generic configuration dataQueueC(typedef dataType, uint8_t qLenth, uint8_t qId){
	provides interface dataQueue;
}
implementation{
	
	components new dataQueueP(dataType, qLenth, qId) as dQueue;
	dataQueue=dQueue.dataQueue;
	
}