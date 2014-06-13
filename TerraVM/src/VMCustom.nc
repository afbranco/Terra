/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Interface: VMCustom
 * Virtual Machine custom component interface
 * 
 */
interface VMCustom{
	command void procOutEvt(uint8_t id);
	command void callFunction(uint8_t id);
	event  uint32_t pop();
	event void queueEvt(uint8_t evtId,void* data);
	event int32_t getMVal(uint16_t Maddr, uint8_t v1_len);
	event void setMVal(uint32_t value,uint16_t Maddr, uint8_t v1_len);
	event void* getRealAddr(uint16_t Maddr, uint8_t v1_len);

}