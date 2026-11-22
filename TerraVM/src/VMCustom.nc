/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/**
 * Interface: VMCustom
 * Virtual Machine custom component interface
 * 
 */
interface VMCustom{
	command void procOutEvt(uint8_t id, uint32_t value);
	command void callFunction(uint8_t id);
	command void reset();
	event  uint32_t pop();
	event  void push(uint32_t val);
	event void queueEvt(uint8_t evtId, uint8_t auxId,void* data);
	event int32_t getMVal(uint16_t Maddr, uint8_t tp);
	event void setMVal(uint32_t value,uint16_t Maddr, uint8_t fromTp, uint8_t tpTp);
	event void* getRealAddr(uint16_t Maddr);
	event bool getHaltedFlag();
	event void evtError(uint8_t ecode);
	event uint32_t getTime();

}