

/**
 * Customized dataQueueC with 'dataReady' to signal a new data in an empty queue.
 * 
 * @param dataType - Data structure type
 * @param qLength  - Queue length
 * @param qId      - Unique identifier (suggest to use '(char)unique("dataQueueC")' 
 * 
 */
 
generic configuration dataQueueC(typedef dataType, uint8_t qLength, uint8_t qId){
	provides interface dataQueue;
}
implementation{
	
	components new dataQueueP(dataType, qLength, qId) as dQueue;
	dataQueue=dQueue.dataQueue;
	
}