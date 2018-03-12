/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2014-2017  Adriano Branco
	
	This file is part of Terra IoT.
	
	Terra IoT is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Terra IoT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  
*/  
/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
#include "VMCustom.h"
#include "BasicServices.h"
#include "rsa64.h"
#include "sense64.h"

#define M_RSA
#define M_ACLM

module VMCustomP{
	provides interface VMCustom as VM;
	uses interface Random;
}
implementation{

// Keeps last data value for events (ExtDataxxx must be nx_ type. Because it is copied direct to VM memory.)
nx_uint8_t ExtDataSysError;				// last system error code
nx_uint8_t ExtDataCustomA;				// last request custom event (internal loop-back)
nx_uint32_t ExtDataTimeStamp;		// last SLPL_FIRED - timestamp 

uint8_t testVar;

/*
 * Output Events implementation
 */


void  proc_req_custom_a(uint16_t id, uint32_t value){
	uint8_t auxId ;
	ExtDataCustomA = (uint8_t)value;
	dbg(APPNAME,"Custom::proc_req_custom_a(): id=%d, ExtDataCustomA=%d\n",id,ExtDataCustomA);
	auxId = (uint8_t)value;//(uint8_t)signal VM.pop();
	// Queue the custom event
	signal VM.queueEvt(I_CUSTOM_A_ID,auxId, &ExtDataCustomA);
	signal VM.queueEvt(I_CUSTOM_A   ,    0, &ExtDataCustomA);
	}

void  proc_req_custom(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_custom(): id=%d\n",id);
	// Queue the custom event
	ExtDataCustomA = 0;
	signal VM.queueEvt(I_CUSTOM   ,    0, &ExtDataCustomA);
	}

#ifdef M_RSA
void adcDone(unsigned retVal);
void  proc_req_aclm(uint16_t id, uint32_t value){
	dbg(APPNAME,"Custom::proc_req_aclm(): id=%d\n",id);
	startSample(&adcDone);
	}
#endif

/*
 * Function implementation
 */
void  func_getNodeId(uint16_t id){
	uint16_t stat;
	// return NodeId
	stat = TOS_NODE_ID;
	dbg(APPNAME,"Custom::func_getNodeId(): id=%d, NodeId=%d\n",id,stat);
	signal VM.push(stat);
	}	
void  func_random(uint16_t id){
	uint16_t stat;
	// return random16
	stat = call Random.rand16();
	dbg(APPNAME,"Custom::func_random(): func id=%d, Random=%d\n",id,stat);
	signal VM.push(stat);
	}
void  func_getMem(uint16_t id){
	uint8_t val;
	uint16_t Maddr;
	Maddr = (uint16_t)signal VM.pop();
	val = (uint8_t)signal VM.getMVal(Maddr, 0);
	dbg(APPNAME,"Custom::func_getMem(): func id=%d, addr=%d, val=%d(%0x)\n",id,Maddr,val,val);
	signal VM.push(val);
	}
void  func_getTime(uint16_t id){
	uint32_t val;
	val = signal VM.getTime();
	dbg(APPNAME,"Custom::func_getTime(): func id=%d, val=%d(%0x)\n",id,val,val);
	signal VM.push(val);
	}

void __attribute__ ((noinline)) trigF1(){ testVar=1;}
void __attribute__ ((noinline)) trigF2(){ testVar=2;}
void __attribute__ ((noinline)) trigF3(){ testVar=3;}
void __attribute__ ((noinline)) trigF4(){ testVar=4;}

void func_trigFx(uint16_t id){
	uint8_t fx;
	fx = (uint8_t)signal VM.pop();
	switch (fx){
	case 1: trigF1(); break;
	case 2: trigF2(); break;
	case 3: trigF3(); break;
	case 4: trigF4(); break;
	}
	signal VM.push(SUCCESS);
}

#ifdef M_STAT
void func_stat1(uint16_t id){
	uint16_t i;
	nx_uint16_t *sensorReads;
	uint16_t arraySize;
	uint16_t max,min,avg;
	uint32_t sum;
	stat1_ret_t *retData;
	uint16_t bufAddr;

	bufAddr = (uint16_t)signal VM.pop();
	retData = (stat1_ret_t*)signal VM.getRealAddr(bufAddr);
	arraySize = (uint16_t)signal VM.pop();
	bufAddr = (uint16_t)signal VM.pop();
	sensorReads = (nx_uint16_t*)signal VM.getRealAddr(bufAddr);

	max = 65535U;
	min = 0;
	sum=0;
	for (i=0; i<arraySize; i++){
		sum = sum + sensorReads[i];
		if (max < sensorReads[i]) max = sensorReads[i];
		if (min > sensorReads[i]) min = sensorReads[i];
		}
	avg = sum / arraySize;
	retData->max = max;
	retData->min = min;
	retData->avg = avg;	
	signal VM.push(avg);
}
#endif

#ifdef M_RSA
void func_mp_bit_length(uint16_t id){
// int mp_bit_length(uint16_t * e_, uint16_t wordlength){
	uint16_t wordlength;
	uint16_t dataAddr;
	uint16_t* e_;
	int16_t ret;

	wordlength = (uint16_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	e_ = (uint16_t*)signal VM.getRealAddr(dataAddr);
	ret = mp_bit_length(e_,wordlength);	
	signal VM.push(ret);	
}
void func_set_to_zero(uint16_t id){
// void set_to_zero(uint16_t * c, uint8_t wordlength)
	uint8_t wordlength;
	uint16_t dataAddr;
	uint16_t* c;

	wordlength = (uint8_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	c = (uint16_t*)signal VM.getRealAddr(dataAddr);

	set_to_zero(c,wordlength);
	signal VM.push(SUCCESS);		
}
void func_multiply_mp_elements(uint16_t id){
// void multiply_mp_elements(uint16_t * c, uint16_t * a, uint16_t * b, uint8_t wordlength)
	uint8_t  wordlength;
	uint16_t dataAddr;
	uint16_t* b;
	uint16_t* a;
	uint16_t* c;

	wordlength = (uint8_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	b = (uint16_t*)signal VM.getRealAddr(dataAddr);
	dataAddr = (uint16_t)signal VM.pop();
	a = (uint16_t*)signal VM.getRealAddr(dataAddr);
	dataAddr = (uint16_t)signal VM.pop();
	c = (uint16_t*)signal VM.getRealAddr(dataAddr);

	multiply_mp_elements(c,a,b,wordlength);
	signal VM.push(SUCCESS);
}
void func_divide_mp_elements(uint16_t id){
// void divide_mp_elements(uint16_t * q, uint16_t * r, uint16_t * x_in, int n_, uint16_t * y, int t)
	int16_t  t;
	uint16_t dataAddr;
	uint16_t* y;
	int16_t  n_;
	uint16_t* x_in;
	uint16_t* r;
	uint16_t* q;

	t = (int16_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	y = (uint16_t*)signal VM.getRealAddr(dataAddr);
	n_ = (int16_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	x_in = (uint16_t*)signal VM.getRealAddr(dataAddr);
	dataAddr = (uint16_t)signal VM.pop();
	r = (uint16_t*)signal VM.getRealAddr(dataAddr);
	dataAddr = (uint16_t)signal VM.pop();
	q = (uint16_t*)signal VM.getRealAddr(dataAddr);

	divide_mp_elements(q,r,x_in,n_,y,t);
	signal VM.push(SUCCESS);        	
}
void func_copy_mp(uint16_t id){
// void copy_mp(uint16_t * out, uint16_t * in, int wordlength)
	int16_t  wordlength;
	uint16_t dataAddr;
	uint16_t* in;
	uint16_t* out;

	wordlength = (int16_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	in = (uint16_t*)signal VM.getRealAddr(dataAddr);
	dataAddr = (uint16_t)signal VM.pop();
	out = (uint16_t*)signal VM.getRealAddr(dataAddr);
	
	copy_mp(out,in,wordlength);
	signal VM.push(SUCCESS);        	
}
void func_mp_ith_bit(uint16_t id){
// int mp_ith_bit(uint16_t * e_, int i)
	int16_t i;
	uint16_t dataAddr;
	uint16_t* e_;
	int16_t ret;
	
	i = (int16_t)signal VM.pop();
	dataAddr = (uint16_t)signal VM.pop();
	e_ = (uint16_t*)signal VM.getRealAddr(dataAddr);
	ret = mp_ith_bit(e_,i);
	signal VM.push(ret);        	
}
#endif



#ifdef M_ACLM
void func_fast_sqrt(uint16_t id){
// unsigned fast_sqrt (unsigned radicand)
	uint16_t val;
	val = (int16_t)signal VM.pop();
	val = fast_sqrt(val);
	signal VM.push(val);    		
}
void func_aclm_setup(uint16_t id){
// void aclm_setup (void)
	setup();
	signal VM.push(SUCCESS);        			
}
void func_aclm(uint16_t id){
// unsigned aclm()
	uint8_t ret = sample3();
	signal VM.push(ret);        			
}
void func_store(uint16_t id){
//void store (void)
	store();
	signal VM.push(SUCCESS);	
}

uint16_t ExtDataAdc;
task void adcDoneTask(){
	// Queue the custom event
	signal VM.queueEvt(I_ACLM   ,    0, &ExtDataAdc);	
}

void adcDone(unsigned retVal){
	ExtDataAdc = retVal;
	signal VM.queueEvt(I_ACLM   ,    0, &ExtDataAdc);	
	//post adcDoneTask();
}

#endif

/**
 *	procOutEvt(uint8_t id)
 *  	procOutEvt - process the out events (emit)
 * 
 *	id - Event ID
 */
command void VM.procOutEvt(uint8_t id,uint32_t value){
	dbg(APPNAME,"Custom::procOutEvt(): id=%d\n",id);
	switch (id){
//		case O_INIT 		: proc_init(id,value); break;
		case O_CUSTOM_A 	: proc_req_custom_a(id,value); break;
		case O_CUSTOM 		: proc_req_custom(id,value); break;
		
		case O_ACLM			: proc_req_aclm(id,value); break;
	}
}


	command void VM.callFunction(uint8_t id){
		dbg(APPNAME,"Custom::VM.callFunction(%d)\n",id);
		switch (id){
			case F_GETNODEID: func_getNodeId(id); break;
			case F_RANDOM 	: func_random(id); break;
			case F_GETMEM 	: func_getMem(id); break;
			case F_GETTIME 	: func_getTime(id); break;
			case F_TRIGFX	: func_trigFx(id); break;

#ifdef M_STAT
			case F_STAT1 	: func_stat1(id); break;
#endif

#ifdef M_RSA
			case F_MP_BIT_LENGTH		: func_mp_bit_length(id); break;
			case F_SET_TO_ZERO			: func_set_to_zero(id); break;
			case F_MULTIPLY_MP_ELEMENTS	: func_multiply_mp_elements(id); break;
			case F_DIVIDE_MP_ELEMENTS	: func_divide_mp_elements(id); break;
			case F_COPY_MP				: func_copy_mp(id); break;
			case F_MP_ITH_BIT			: func_mp_ith_bit(id); break;
#endif

#ifdef M_ACLM
			case F_FAST_SQRT			: func_fast_sqrt(id); break;
			case F_ACLM_SETUP			: func_aclm_setup(id); break;
			case F_ACLM					: func_aclm(id); break;
			case F_STORE				: func_store(id); break;
#endif


		}
	}

	command void VM.reset(){
	}


}
