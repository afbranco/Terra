/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Module: TerraVMC
 * Virtual Machine main control - module file
 * 
 */
#include "TerraVM.h"


module TerraVMC @safe()
{
	// Main modules
	uses interface Boot as BSBoot;
	uses interface BSUpload;
	uses interface VMCustom;
	// Support modules
	uses interface Queue<evtData_t> as evtQ;
	uses interface BSTimer as BSTimerVM;
	uses interface BSTimer as BSTimerAsync;
}
implementation
{
    u32 old;
	// Mote Identifier
	nx_uint16_t MoteID;					
	// VM scrip memory
	char CEU_data[BLOCK_SIZE * CURRENT_MAX_BLOCKS];   // Ceu data room for 'tracks', 'mem', 'Prog', and 'Stack'
	// Program Counter (PC)
	uint16_t PC;
	// VM Halted Flag
	bool haltedFlag=TRUE;
	// VM Processing Flag
	bool procFlag=FALSE;

	// Ceu Environment vars
	uint16_t ProgStart;
	uint16_t ProgEnd;
//	uint16_t LblTab11,LblTab12,LblTab21,LblTab22,LblTabEnd;
	uint16_t nTracks;
	uint16_t wClocks;
	uint16_t asyncs;
	uint16_t wClock0;	
	uint16_t gate0;	
	uint16_t inEvts;	
	uint16_t async0;	
	char* MEM;
	
	// Stack control
	uint16_t currStack=(BLOCK_SIZE * CURRENT_MAX_BLOCKS)-1-4;


	/*
	 * Some prototypes
	 */
#ifndef ONLY_BSTATION
	task void procEvent();
	void Decoder(uint8_t Opcode, uint8_t Modifier);
	void ceu_boot();
#endif
// Ceu intrinsic functions
//	void ceu_out_wclock(uint32_t ms){ if (ms != CEU_WCLOCK_NONE ) call BSTimerVM.startOneShot(((ms)<1)?1:(ms)); }
	void ceu_out_wclock(uint32_t ms){ if (ms != CEU_WCLOCK_NONE ) call BSTimerVM.startOneShot(ms); }



	/**
	 * Initialization 
	 */
	event void BSBoot.booted(){
		MoteID = TOS_NODE_ID;
		if (MoteID==BStation) {
			haltedFlag = TRUE;
		}
		// Start VM enginne
#ifndef ONLY_BSTATION
		//ceu_boot();
#endif
	}	


	/*
	 * Auxiliary functions
	 */
#ifndef ONLY_BSTATION // Start large code ONLY_BSTATION suppression 

	uint8_t getOpCode(uint8_t* Opcode, uint8_t* Modifier){
		*Opcode = (uint8_t)(CEU_data[PC]);
		*Modifier = (uint8_t)(CEU_data[PC]);
		dbg(APPNAME,"VM::getOpCode(): CEU_data[%d]=%d (0x%02x)  %s \n",PC,*Opcode,*Opcode,(*Opcode==op_end)?"--> f_end":"");
//		dbg(APPNAME,"VM::getOpCode(): MEM[32/33/34]=%d,%d,%d \n",*(uint8_t*)(MEM+32),*(uint8_t*)(MEM+33),*(uint8_t*)(MEM+34));
		PC++;
		if (*Opcode <= LIMIT_8BIT_OPER){
			*Modifier=0;
		} else {
			if (*Opcode <= LIMIT_6BIT_OPER){
				*Opcode = (uint8_t)(*Opcode & 0xFC);
				*Modifier = (uint8_t)(*Modifier & 0x03);	
			} else {
				*Opcode = (uint8_t)(*Opcode & 0xF0);
				*Modifier = (uint8_t)(*Modifier & 0x0F);					
			}
		}
		return (*Opcode);
	}

	uint16_t getLblAddr(uint16_t lbl){
		dbg(APPNAME,"VM::getLblAddr(%d):\n",lbl);	
		return lbl;	
 	}


//------------------------ auxiliary functions --------


	/*
	 * Get constant values from program memory. Convert big-endian to the local type endian.
	 */
	uint8_t getPar8(uint8_t p_len){
		uint8_t temp=(uint8_t)CEU_data[PC];
		PC++;
		dbg(APPNAME,"VM::getPar8: PC=%d, p_len=%d, value=%d\n",PC,p_len,temp);
		return temp;
	}
	uint16_t getPar16(uint8_t p_len){
		uint16_t temp=0, temp2;
		uint8_t idx;
		for (idx=0;(idx < p_len);idx++){
			//if (idx < sizeof(uint16_t)) *(uint8_t*)((uint8_t*)&temp+idx) = CEU_data[PC];
			if (idx < sizeof(uint16_t)) {
				temp2 = (uint8_t)CEU_data[PC];
				temp = temp + (temp2 << ((p_len-1-idx)*8));
			}
			PC++;
		}
		dbg(APPNAME,"VM::getPar16: PC=%d, p_len=%d, value=%d\n",PC-idx,p_len,temp);
		return temp;
	}
	uint32_t getPar32(uint8_t p_len){
		uint32_t temp=0L, temp2;
		uint8_t idx;
		for (idx=0;(idx < p_len);idx++){
			// if (idx < sizeof(uint32_t)) *(uint8_t*)((uint8_t*)&temp+idx) = CEU_data[PC];
			if (idx < sizeof(uint32_t)) {
				temp2 = (uint8_t)CEU_data[PC];
				temp = temp + (temp2 << ((p_len-1-idx)*8));
			}
			PC++;
		}
		dbg(APPNAME,"VM::getPar32: PC=%d, p_len=%d, value=%d\n",PC-idx,p_len,temp);
		return temp;
	}

uint32_t unit2val(uint32_t val, uint8_t unit){
	switch (unit){  // result in 'ms'
		case 0: return (uint32_t)(val/1000L);		// us
		case 1: return (uint32_t)(val);				// ms
		case 2: return (uint32_t)(val*1000L);		// seg
		case 3: return (uint32_t)(val*60L*1000L);		// min
		case 4: return (uint32_t)(val*60L*60L*1000L);	// h
	}
	return val;
}

void push(uint32_t value){
	currStack = currStack - 4 ;
	*(int32_t*)(CEU_data+currStack)=value;
dbg(APPNAME,"VM::push(): newStack=%d, value=%d (0x%04x)\n",currStack,*(int32_t*)(CEU_data+currStack),*(int32_t*)(CEU_data+currStack));
}

uint32_t pop(){
	currStack = currStack + 4 ;
	return *(uint32_t*)(CEU_data+currStack-4);
}

int32_t getMVal(uint16_t Maddr, uint8_t v1_len){
	switch (v1_len){
		case 1 : return (int32_t)*(nx_uint8_t*)(MEM+Maddr);
		case 2 : return (int32_t)*(nx_uint16_t*)(MEM+Maddr);
		case 4 : return (int32_t)*(nx_uint32_t*)(MEM+Maddr);
	}
	dbg(APPNAME,"ERROR VM::getMVal(): Invalid v1_len=%d\n",v1_len);
	return 0;
}
void setMVal(int32_t value, uint16_t Maddr, uint8_t v1_len){
	switch (v1_len){
		case 1 : *(nx_uint8_t*)(MEM+Maddr) = (uint8_t)value; return;
		case 2 : *(nx_uint16_t*)(MEM+Maddr) = (uint16_t)value; return;
		case 4 : *(nx_int32_t*)(MEM+Maddr) = (int32_t)value; return;
	}
	dbg(APPNAME,"ERROR VM::setMVal(): Invalid v1_len=%d\n",v1_len);
}
 
// Convert Memory Signed v1_len bytes to s32 bits
int32_t MStoS32(uint16_t Maddr,uint8_t v1_len){
	switch (v1_len){
		case 1 : return (int32_t)*(nx_int8_t*)(MEM+Maddr);
		case 2 : return (int32_t)*(nx_int16_t*)(MEM+Maddr);
		case 4 : return (int32_t)*(nx_int32_t*)(MEM+Maddr);
	}
	dbg(APPNAME,"ERROR VM::MStoS32(): Invalid v1_len=%d\n",v1_len);
	return 0;
}
// Convert Memory Unsigned v1_len bytes to s32 bits
uint32_t MUtoS32(uint16_t Maddr,uint8_t v1_len){
	switch (v1_len){
		case 1 : return (int32_t)*(nx_uint8_t*)(MEM+Maddr);
		case 2 : return (int32_t)*(nx_uint16_t*)(MEM+Maddr);
		case 4 : return (int32_t)*(nx_uint32_t*)(MEM+Maddr);
	}
	dbg(APPNAME,"ERROR VM::MUtoS32(): Invalid v1_len=%d\n",v1_len);
	return 0;
}
// Convert Memory Unsigned v1_len bytes to U16 bits 
uint16_t MUtoU16(uint16_t Maddr,uint8_t v1_len){
	switch (v1_len){
		case 1 : return (uint16_t)*(nx_uint8_t*)(MEM+Maddr);
		case 2 : return (uint16_t)*(nx_uint16_t*)(MEM+Maddr);
		case 4 : return (uint16_t)*(nx_uint32_t*)(MEM+Maddr);
	}
	dbg(APPNAME,"ERROR VM::MUtoU16(): Invalid v1_len=%d\n",v1_len);
	return 0;
}
// Convert S32 bits to Memory Signed v1_len bytes
void S32toMS(int32_t value, uint16_t Maddr,uint8_t v1_len){
	switch (v1_len){
		case 1 : *(nx_int8_t*)(MEM+Maddr) = (int8_t)value; return;
		case 2 : *(nx_int16_t*)(MEM+Maddr) = (int16_t)value; return;
		case 4 : *(nx_int32_t*)(MEM+Maddr) = (int32_t)value; return;
	}
	dbg(APPNAME,"ERROR VM::S32toMS(): Invalid v1_len=%d\n",v1_len);
}
// Convert S32 bits to Memory Unsigned v1_len bytes
void S32toMU(int32_t value, uint16_t Maddr,uint8_t v1_len){
	switch (v1_len){
		case 1 : *(nx_uint8_t*)(MEM+Maddr) = (uint8_t)value; return;
		case 2 : *(nx_uint16_t*)(MEM+Maddr) = (uint16_t)value; return;
		case 4 : *(nx_uint32_t*)(MEM+Maddr) = (uint32_t)value; return;
	}
	dbg(APPNAME,"ERROR VM::S32toMU(): Invalid v1_len=%d\n",v1_len);
}
// Convert U16 bits to Memory Unsigned v1_len bytes
void U16toMU(uint16_t value, uint16_t Maddr,uint8_t v1_len){
	switch (v1_len){
		case 1 : *(nx_uint8_t*)(MEM+Maddr) = (uint8_t)value; return;
		case 2 : *(nx_uint16_t*)(MEM+Maddr) = (uint16_t)value; return;
		case 4 : *(nx_uint32_t*)(MEM+Maddr) = (uint32_t)value; return;
	}
	dbg(APPNAME,"ERROR VM::U16toMU(): Invalid v1_len=%d\n",v1_len);
}

// Return CEU internal slot offset for EvtId
uint16_t getEvtCeuId(uint8_t EvtId){
	uint8_t i=0;
	uint8_t slotSize; // Normal slot has 2 bytes.  Slot with auxId has 3 bytes. 
	uint16_t currSlot=gate0;
	slotSize = ((*(nx_uint8_t*)(MEM+currSlot)) <= 127)?2:3;
dbg(APPNAME,"VM::getEvtCeuId(): EvtId?=%d : currSlot=%d,  slotId=%d, slotSize=%d, i=%d, inEvts=%d\n", EvtId, currSlot,(*(nx_uint8_t*)(MEM+currSlot)),slotSize,i,inEvts );
//	while (EvtId > (*(nx_uint8_t*)(MEM+currSlot)) && i < inEvts) {
	while (EvtId != (*(nx_uint8_t*)(MEM+currSlot)) && i < inEvts) {
		i++;
		currSlot = 	currSlot + 1 + ((*(nx_uint8_t*)(MEM+currSlot+1))*slotSize) + 1;
		slotSize = ((*(nx_uint8_t*)(MEM+currSlot)) <= 127)?2:3;
dbg(APPNAME,"VM::getEvtCeuId(): EvtId?=%d : currSlot=%d,  slotId=%d, slotSize=%d, i=%d, inEvts=%d\n", EvtId, currSlot,(*(nx_uint8_t*)(MEM+currSlot)),slotSize,i,inEvts );
	}
	if (EvtId != (*(nx_uint8_t*)(MEM+currSlot))) { 
		dbg(APPNAME,"WARNING: Not found slot for event %d!\n",EvtId);
		return 0;
	}
	return currSlot+1; // Return addr of 'n' gates for EvtId

/*
	for (i=1; i<= EvtId;i++){
		CeuId = CeuId + ((*(nx_uint8_t*)(MEM+CeuId)) * 2) + 1;
dbg(APPNAME,"VM::getEvtCeuId(): Salto anterior: addr=%ld, value=%d\n",MEM+CeuId,*(nx_uint8_t*)(MEM+CeuId));
dbg(APPNAME,"VM::getEvtCeuId(): EvtId=%d, gate0=%d, i=%d ,CeuId=%d\n",EvtId,gate0,i,CeuId);
		}
dbg(APPNAME,"VM::getEvtCeuId(): EvtId=%d, gate0=%d, i=%d ,CeuId=%d\n",EvtId,gate0,i,CeuId);
	return CeuId;
*/
}

	// Get size from data type
	uint8_t getSizeFromType(uint8_t type){
		uint8_t size=0;
		switch (type){
			case U8 : size = 1; break;
			case U16: size = 2; break;
			case U32: size = 4; break;
			case S8 : size = 1; break;
			case S16: size = 2; break;
			case S32: size = 4; break;
			}
		dbg(APPNAME,"VM::getSizeFromType(): type=%d, size=%d\n", type,size);
		return size;
	}
	

//******************************************************************************
// Included here the code of _ceu_code.c
//******************************************************************************

typedef u16 tceu_noff;
typedef u16 tceu_nlbl;

typedef struct {
    s32 togo;
    tceu_nlbl lbl;
} tceu_wclock;

typedef struct {
    u8 stack;
    u8 tree;
    tceu_nlbl lbl;
} tceu_trk;

enum {
    Inactive = 0,
    Init = 1,

};

int ceu_go (int* ret);


typedef struct {
    int             tracks_n;
    u8              stack;
    void*           ext_data;
    int             ext_int;
    int             wclk_late;
    tceu_wclock*    wclk_cur;
    int             async_cur;
    tceu_trk*       p_tracks;  // 0 is reserved
    char*           p_mem;
} tceu;

#define CEU (&CEU_)

tceu CEU_ = {
    0,				// tracks_n
    CEU_STACK_MIN,	// stack
    (void*)0,		// ext_data
    0,				// ext_int
    0, 				// wclk_late
    (void*)0,		// wclk_cur
    0,				// async_cur
    (void*)0,		// p_tracks
    (void*)0		// p_mem
};

/**********************************************************************/

int ceu_track_cmp (tceu_trk* trk1, tceu_trk* trk2) {
	dbg(APPNAME,"CEU::ceu_track_cmp():: trk1->lbl=%d,stack=%d trk2->lbl=%d,stack=%d -- CEU->stack=%d\n",trk1->lbl,trk1->stack,trk2->lbl,trk2->stack,CEU->stack);

	if (trk1->stack != trk2->stack) {
        if (trk1->stack == CEU->stack)
            return 1;
        if (trk2->stack == CEU->stack)
            return 0;
        return (trk1->stack > trk2->stack);
    }
    return (trk1->tree > trk2->tree);
}


void ceu_track_ins (u8 stack, u8 tree, int chk, tceu_nlbl lbl)
{
	dbg(APPNAME,"CEU::ceu_track_ins():: track_n=%d, stack=%d tree=%d chk=%d lbl=%d\n",CEU->tracks_n,stack,tree,chk,lbl);
	{int i;
		if (chk) {
			for (i=1; i<=CEU->tracks_n; i++) {
				if (lbl==(CEU->p_tracks+i)->lbl) {
					return;
				}
			}
		}
	}

	{
		int i;

		tceu_trk trk = {
			stack,
			tree,
			lbl
		};


		for ( i = ++CEU->tracks_n;
					(i>1) && ceu_track_cmp(&trk,CEU->p_tracks+(i/2));
				i /= 2 ) {
			//CEU->tracks[i] = CEU->tracks[i/2];
			memcpy(CEU->p_tracks+i,CEU->p_tracks+(i/2),sizeof(tceu_trk));
			//   	   dbg(APPNAME,"CEU::ceu_track_ins():: Ceu_data[%d] \n",(char*)(CEU->p_tracks+i)-(char*)CEU->p_tracks);
		}
		//CEU->tracks[i] = trk;
		*(tceu_trk*)(CEU->p_tracks+i) = trk;
	}


}

int ceu_track_rem (tceu_trk* trk, u8 N)
{
//	dbg(APPNAME,"CEU::ceu_track_rem: track_n=%d\n",CEU->tracks_n);
    if (CEU->tracks_n == 0)
        return 0;

    {int i,cur;
    tceu_trk* last;

    if (trk)
        memcpy(trk,CEU->p_tracks+N,sizeof(tceu_trk));     // *trk = CEU->tracks[N];

    last = CEU->p_tracks + CEU->tracks_n--; //&CEU->tracks[CEU->tracks_n--];

    for (i=N; i*2<=CEU->tracks_n; i=cur)
    {
        cur = i * 2;
        if (cur!=CEU->tracks_n &&
            ceu_track_cmp(CEU->p_tracks+(cur+1),CEU->p_tracks+cur)) //ceu_track_cmp(&CEU->tracks[cur+1], &CEU->tracks[cur]))
            cur++;

        if (ceu_track_cmp(CEU->p_tracks+cur,last))
            memcpy(CEU->p_tracks+i,CEU->p_tracks+cur,sizeof(tceu_trk)); //CEU->tracks[i] = CEU->tracks[cur];
        else
            break;
    }
    memcpy(CEU->p_tracks+i,last,sizeof(tceu_trk)); // CEU->tracks[i] = *last;
    return 1;}
}

void ceu_track_clr (tceu_nlbl l1, tceu_nlbl l2) {
    int i;
    for (i=1; i<=CEU->tracks_n; i++) {
        tceu_trk* trk = CEU->p_tracks+i; //&CEU->tracks[i];
        if (trk->lbl>=l1 && trk->lbl<=l2) {
            ceu_track_rem(NULL, i);
            i--;
        }
    }
}

void ceu_spawn (tceu_nlbl* lbl)
{
    if (*(nx_uint16_t*)lbl != Inactive) {
        ceu_track_ins(CEU->stack, CEU_TREE_MAX, 0, *(nx_uint16_t*)lbl);
        *(nx_uint16_t*)lbl = Inactive;
    }
}

void ceu_trigger (tceu_noff off, uint8_t auxId)
{
    int i;
    uint8_t slotSize, evtId, slotAuxId;
    int n = *(char*)(CEU->p_mem+off); //int n = CEU->mem[off];
	evtId = *(char*)(CEU->p_mem+off-1);
	slotSize = (evtId<=127)?2:3;
    dbg(APPNAME,"CEU::ceu_trigger(): evtId=%d, auxId=%d, slotSize=%d, gate addr=%d, nGates=%d\n",evtId,auxId,slotSize,off,n);
    for (i=0 ; i<n ; i++) {
        //ceu_spawn((tceu_nlbl*)&CEU->mem[off+1+(i*sizeof(tceu_nlbl))]);
		if (evtId <= 127){
        	ceu_spawn((tceu_nlbl*)(CEU->p_mem+off+1+(i*slotSize)));
		} else {
			slotAuxId = *(char*)(CEU->p_mem+off+1+(i*slotSize));
			if (slotAuxId==auxId) {
	        	ceu_spawn((tceu_nlbl*)(CEU->p_mem+off+2+(i*slotSize)));
			}
		}
    }
}

/**********************************************************************/

// returns a pointer to the received value
int* ceu_ext_f (int v) {
    CEU->ext_int = v;
    return &CEU->ext_int;
}

int ceu_wclock_lt (tceu_wclock* tmr) {
	dbg(APPNAME,"CEU::ceu_wclock_lt(): wclk_cur=%ld, togo=%d, cur.togo=%d\n",(CEU->wclk_cur)?CEU->wclk_cur->togo:0,(nx_uint32_t)tmr->togo,(CEU->wclk_cur)?(nx_uint32_t)CEU->wclk_cur->togo:5555);
//afb    if (!CEU->wclk_cur || tmr->togo < CEU->wclk_cur->togo) {
    if (!CEU->wclk_cur || (!CEU->wclk_cur || CEU->wclk_cur->togo == 0) || (!CEU->wclk_cur || tmr->togo < CEU->wclk_cur->togo)) {
    	CEU->wclk_cur = tmr;
        return 1;
     } 
    return 0;
}

void ceu_wclock_enable (int gte, s32 us, tceu_nlbl lbl) {
	tceu_wclock* tmr = (tceu_wclock*)(MEM+wClock0+(gte*sizeof(tceu_wclock)));
    s32 dt = us - CEU->wclk_late;
//afb Prevent negative dt
	dt = (dt<0)?0:dt;

    dbg(APPNAME,"CEU::ceu_wclock_enable(): gate=%d, time=%d, lbl=%d, dt=%ld, wClock0=%d\n",gte,us,lbl,dt,wClock0);
//printf("[%d/%d] (%ld - %d) = %ld",gte,lbl,us,CEU->wclk_late,dt);printfflush();
    tmr->togo = dt;
    *(nx_uint16_t*)&(tmr->lbl)  = lbl;
	
    if (ceu_wclock_lt(tmr))
        ceu_out_wclock(dt);
}


void ceu_async_enable (int gte, tceu_nlbl lbl) {
    PTR(tceu_nlbl*,async0)[gte] = lbl;
	if (!call BSTimerAsync.isRunning()) 
		call BSTimerAsync.startOneShot(ASYNC_DELAY); // afb: moved to here to avoid timer cicles without active async 
}

/**********************************************************************/

int ceu_go_init (int* ret)
{
//	dbg(APPNAME,"CEU::ceu_go_init(): halted=%s\n",(haltedFlag)?"TRUE":"FALSE");
   if (haltedFlag) return(0);

   CEU->p_tracks = (tceu_trk*)CEU_data+0;
   CEU->p_mem = CEU_data+((nTracks+1)*sizeof(tceu_trk));
   MEM = CEU->p_mem;

   ceu_track_ins(CEU_STACK_MIN, CEU_TREE_MAX, 0, ProgStart);
    return ceu_go(ret);
}

int ceu_go_event (int* ret, int id, uint8_t auxId, void* data)
{
   dbg(APPNAME,"CEU::ceu_go_event(): halted=%s - evt slotAddr=%d, auxId=%d\n",(haltedFlag)?"TRUE":"FALSE",id,auxId);
    CEU->ext_data = data;
    CEU->stack = CEU_STACK_MIN;
    ceu_trigger(id,auxId);

    CEU->wclk_late--;

    return ceu_go(ret);
}


int ceu_go_async(int* ret, int* pending)
{
    int i,s=0;
    tceu_nlbl* ASY0 = PTR(tceu_nlbl*,async0);
   dbg(APPNAME,"CEU::ceu_go_async(): ret=%d, pending=%d, async0=%d,asyncs=%d, async_cur=%d, ASY0[0]=%d\n",
   				(ret==NULL?0:*ret),(pending==NULL?0:*pending),async0,asyncs,CEU->async_cur,ASY0[0]);

    for (i=0; i < asyncs; i++) {
        int idx = (CEU->async_cur+i) % asyncs;
        if (ASY0[idx] != Inactive) {

            ceu_track_ins(CEU_STACK_MIN, CEU_TREE_MAX, 0, ASY0[idx]);
            ASY0[idx] = Inactive;
            CEU->async_cur = (idx+1) % asyncs;

            CEU->wclk_late--;
            s = ceu_go(ret);
            break;
        }
    }

    if (pending != NULL)
    {
        *pending = 0;
        for (i=0 ; i < asyncs ; i++) {
            if (ASY0[i] != Inactive) {
                *pending = 1;
                break;
            }
        }
    }
    
    return s;
}


int ceu_go_wclock (int* ret, s32 dt, s32* nxt)
{
    int i;
    s32 min_togo = CEU_WCLOCK_NONE;
    tceu_wclock* CLK0 = PTR(tceu_wclock*,wClock0);
//    if (BStation!=TOS_NODE_ID && CEU->wclk_cur)
//    	dbg(APPNAME,"CEU::ceu_go_wclock(): dt=%d, togo=%d lbl=%d\n",dt, CEU->wclk_cur->togo,CEU->wclk_cur->lbl);


    CEU->stack = CEU_STACK_MIN;

    if (!CEU->wclk_cur) {
        if (nxt)
            *nxt = CEU_WCLOCK_NONE;
        ceu_out_wclock(CEU_WCLOCK_NONE);
        return 0;
    }

    if (CEU->wclk_cur->togo <= dt) {
        min_togo = CEU->wclk_cur->togo;
        CEU->wclk_late = dt - CEU->wclk_cur->togo;   // how much late the wclock is
//        if (BStation!=TOS_NODE_ID && CEU->wclk_cur)
//         	dbg(APPNAME,"CEU::ceu_go_wclock(): Ajustando togo: CEU->wclk_cur->togo=%d, dt=%d, lbl=%d\n",CEU->wclk_cur->togo, dt,CEU->wclk_cur->lbl);
     }

    // spawns all togo/ext
    // finds the next CEU->wclk_cur
    // decrements all togo
    CEU->wclk_cur = NULL;
    for (i=0; i<wClocks; i++)
    {
        tceu_wclock* tmr = &CLK0[i];
        if (BStation!=TOS_NODE_ID)
         	dbg(APPNAME,"CEU::ceu_go_wclock(): Loop1 nos wClocks: tmr->togo=%d, tmr->lbl=%d\n",(nx_uint32_t)(tmr->togo), *(nx_uint16_t*)&(tmr->lbl));
        if (tmr->lbl == Inactive)
            continue;

        if ( tmr->togo==min_togo ) {
            tmr->togo = 0;
            dbg("VMDBG","VM:: timer fired for label %d\n",*(nx_uint16_t*)&(tmr->lbl));
            ceu_spawn(&tmr->lbl);           // spawns sharing phys/ext
        } else {
            tmr->togo -= dt;
            if ( tmr->togo < 0 ) tmr->togo = 0L;
            ceu_wclock_lt(tmr);             // next? (sets CEU->wclk_cur)
        }
//        if (BStation!=TOS_NODE_ID)
//         	dbg(APPNAME,"CEU::ceu_go_wclock(): Loop2 nos wClocks: tmr->togo=%d, tmr->lbl=%d\n",tmr->togo, tmr->lbl);
    }

//    dbg(APPNAME,"CEU::ceu_go_wclock(): 1 \n",*(uint8_t*)(CEU->p_mem+4));

    {int s = ceu_go(ret);
    if (nxt)
        *nxt = (CEU->wclk_cur ? CEU->wclk_cur->togo : CEU_WCLOCK_NONE);
    CEU->wclk_late = 0;
    ceu_out_wclock(CEU->wclk_cur ? CEU->wclk_cur->togo : CEU_WCLOCK_NONE);
// 	dbg(APPNAME,"CEU::ceu_go_wclock(): 2 --- M[4]=%d\n",*(uint8_t*)(CEU->p_mem+4));
    return s;}

}


void execTrail(uint16_t lbl){
	uint8_t Opcode,Param1;
	dbg(APPNAME,"CEU::execTrail(%d)\n",lbl);
	// Get Label Addr
	PC = getLblAddr(lbl);
	if (PC == 0){
		dbg(APPNAME,"ERROR CEU::execTrail():Label %d not found!\n",lbl);
		return;  // Label not found
	}
	getOpCode(&Opcode,&Param1);
	while (Opcode != op_end){
		Decoder(Opcode,Param1);
		getOpCode(&Opcode,&Param1);
	}
	dbg(APPNAME,"CEU::execTrail(%d):: found an 'end' opcode\n",lbl);
}

int ceu_go (int* ret)
{
//fprintf(stderr, "===\n");
    tceu_trk trk;
    tceu_nlbl _lbl_;

    dbg(APPNAME,"CEU::ceu_go():\n");

	procFlag = TRUE;
    CEU->stack = CEU_STACK_MIN;
    while (ceu_track_rem(&trk, 1))
    {
        if (trk.stack != CEU->stack) {
            CEU->stack = trk.stack;
        }
        if (trk.lbl == Inactive)
            continue;   // an escape may have cleared a `defer´ or `cont´

        _lbl_ = trk.lbl;
        
        execTrail(_lbl_);

    }
	procFlag = FALSE;
	post procEvent();
    return 0;
}

int ceu_go_all ()
{
    int ret = 0;
    int async_cnt;
    
    if (ceu_go_init(&ret))
        return ret;

    for (;;) {
        if (ceu_go_async(&ret,&async_cnt))
            return ret;
        if (async_cnt == 0)
            break;              // returns nothing!
    }

    return ret;
}


// ****** End of ceu_boot
	
	/**
	 * Mote boot 
	 */
    void ceu_boot()
    {
        old = (u32)call BSTimerVM.getNow();
        ceu_go_init(NULL);
//		call BSTimerAsync.startOneShot(ASYNC_DELAY); // afb: moved to async_enable
    }

/**********************************************************************
 * OPCODE functions
 *********************************************************************/

void f_nop(uint8_t Modifier){ dbg(APPNAME,"VM::f_nop(%02x)\n",Modifier); }
void f_end(uint8_t Modifier){ 
	dbg(APPNAME,"VM::f_end(%02x)\n",Modifier); 
	dbg("VMDBG","VM:: End of Trail\n"); 
	}
void f_sub(uint8_t Modifier){ 
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_sub(%02x): v1=%d, v2=%d, sub=%d\n",Modifier,v1,v2,v1-v2);
	dbg("VMDBG","VM:: sub operation: (%d - %d) = %d \n",v1,v2,v1-v2);
	push(v1-v2);
 }

void f_add(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_add(%02x): v1=%d, v2=%d, add=%d\n",Modifier,v1,v2,v1+v2);
	dbg("VMDBG","VM:: add operation: (%d + %d) = %d \n",v1,v2,v1+v2);
	push(v1+v2);
 }

void f_mod(uint8_t Modifier){ 
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_mod(%02x): v1=%d, v2=%d, mod=%d\n",Modifier,v1,v2,v1%v2);
	dbg("VMDBG","VM:: mod operation: (%d % %d) = %d \n",v1,v2,v1%v2);
	push(v1%v2);
 }
 
void f_mult(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_mult(%02x): v1=%d, v2=%d, mult=%d\n",Modifier,v1,v2,v1*v2);
	dbg("VMDBG","VM:: mult operation: (%d * %d) = %d \n",v1,v2,v1*v2);
	push(v1*v2);
 }

void f_div(uint8_t Modifier){ 
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_div(%02x): v1=%d, v2=%d, div=%d\n",Modifier,v1,v2,(v2==0)?0:v1/v2);
	dbg("VMDBG","VM:: div operation: (%d / %d) = %d \n",v1,v2,(v2==0)?0:v1/v2);
	push((v2==0)?0:v1/v2);
 }
 
void f_bor(uint8_t Modifier){ 
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_bor(%02x): (v1=%d | v2=%d) = %d\n",Modifier,v1,v2,v1 | v2);
	dbg("VMDBG","VM:: binary OR operation: (0x%x | 0x%x) = 0x%x \n",v1,v2,v1|v2);
	push(v1 | v2);
 }
void f_band(uint8_t Modifier){ 
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_band(%02x): (v1=%d & v2=%d) = %d\n",Modifier,v1,v2,v1 & v2);
	dbg("VMDBG","VM:: binary AND operation: (0x%x & 0x%x) = 0x%x \n",v1,v2,v1&v2);
	push(v1 & v2);
 }
void f_lshft(uint8_t Modifier){ 
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_lshft(%02x): (v1=%d << v2=%d) = %d\n",Modifier,v1,v2,v1 << v2);
	dbg("VMDBG","VM:: left shift operation: (0x%x << %d) = 0x%x \n",v1,v2,v1<<v2);
	push(v1 << v2);
 }
void f_rshft(uint8_t Modifier){ 
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_rshft(%02x): (v1=%d >> v2=%d) = %d\n",Modifier,v1,v2,v1 >> v2);
	dbg("VMDBG","VM:: right shift operation: (0x%x >> %d) = 0x%x \n",v1,v2,v1>>v2);
	push(v1 >> v2);
 }
void f_bxor(uint8_t Modifier){ 
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_bxor(%02x): (v1=%d ^ v2=%d) = %d)\n",Modifier,v1,v2,v1 ^ v2);
	dbg("VMDBG","VM:: binary XOR operation: (0x%x ^ 0x%x) = 0x%x \n",v1,v2,v1 ^ v2);
	push(v1 ^ v2);
 }

void f_eq(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_eq(%02x): (v1=%d == v2=%d) = %d\n",Modifier,v1,v2,v1==v2);
	dbg("VMDBG","VM:: equality test: (%d == %d) = %s \n",v1,v2,_TFstr(v1 == v2));
	push(v1==v2);
}

void f_neq(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_neq(%02x): (v1=%d != v2=%d) = %d\n",Modifier,v1,v2,v1!=v2);
	dbg("VMDBG","VM:: inequality test: (%d != %d) = %s \n",v1,v2,_TFstr(v1 != v2));
	push(v1!=v2);
}
void f_gte(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_gte(%02x): (v1=%d >= v2=%d) = %d\n",Modifier,v1,v2,v1>=v2);
	dbg("VMDBG","VM::  greater-than-equal test: (%d >= %d) = %s \n",v1,v2,_TFstr(v1 >= v2));
	push(v1>=v2);
}
void f_lte(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_lte(%02x): (v1=%d <= v2=%d) = %d\n",Modifier,v1,v2,v1<=v2);
	dbg("VMDBG","VM:: less-than-equal test: (%d <= %d) = %s \n",v1,v2,_TFstr(v1 <= v2));
	push(v1<=v2);
}
void f_gt(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_gt(%02x): (v1=%d > v2=%d) = %d\n",Modifier,v1,v2,v1>v2);
	dbg("VMDBG","VM::  greater-than test: (%d > %d) = %s \n",v1,v2,_TFstr(v1 > v2));
	push(v1>v2);
}
void f_lt(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_lt(%02x): (v1=%d < v2=%d) = %d\n",Modifier,v1,v2,v1<v2);
	dbg("VMDBG","VM:: less-than test: (%d < %d) = %s \n",v1,v2,_TFstr(v1 < v2));
	push(v1<v2);
}
void f_lor(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_lor(%02x): (v1=%d || v2=%d) = %d\n",Modifier,v1,v2,v1 || v2);
	dbg("VMDBG","VM:: logical OR operation: (%d || %d) = %s \n",v1,v2,_TFstr(v1 || v2));
	push(v1 || v2);
}
void f_land(uint8_t Modifier){
	int32_t v1,v2;
	v1 = pop();
	v2 = pop();
	dbg(APPNAME,"VM::f_land(%02x): (v1=%d && v2=%d) = %d\n",Modifier,v1,v2,v1 && v2);
	dbg("VMDBG","VM:: logical AND operation: (%d && %d) = %s \n",v1,v2,_TFstr(v1 && v2));
	push(v1 && v2);
}
void f_bnot(uint8_t Modifier){  
	int32_t v1;
	v1 = pop();
	dbg(APPNAME,"VM::f_bnot(%02x): ~(v1=%d) =%d\n",Modifier,v1,~v1);
	dbg("VMDBG","VM:: binary NOT operation: (~ 0x%x) = 0x%x \n",v1,~v1);
	push(~v1);
 }
void f_lnot(uint8_t Modifier){  
	int32_t v1;
	v1 = pop();
	dbg(APPNAME,"VM::f_lnot(%02x): !(v1=%d) =%d\n",Modifier,v1,!v1);
	dbg("VMDBG","VM:: logical NOT operation: (! %d) = %s \n",v1,_TFstr(!v1));
	push(!v1);
 }
void f_neg(uint8_t Modifier){  
	int32_t v1;
	v1 = pop();
	dbg(APPNAME,"VM::f_neg(%02x): -(v1=%d) =%d\n",Modifier,v1,-1*v1);
	dbg("VMDBG","VM:: negative operation: (-%d) = %d \n",v1,-1*v1);
	push(-1*v1);
 }
 
void f_cast(uint8_t Modifier){
	uint32_t stack;
	uint8_t type;
	type = (uint8_t)(Modifier & 0x3);
	stack = pop();
	dbg(APPNAME,"VM::f_cast(%02x): type=%d, stack=%d, ",Modifier,type,stack);
	switch (type){
		case x8 : dbg_clear(APPNAME,"type='x8' , cast=%d\n",( uint8_t)stack); push(( uint8_t)stack); break;
		case x16: dbg_clear(APPNAME,"type='x16', cast=%d\n",(uint16_t)stack); push((uint16_t)stack); break;
		case x32: dbg_clear(APPNAME,"type='x32', cast=%d\n",(uint32_t)stack); push((uint32_t)stack); break;
	}
}

void f_inc(uint8_t Modifier){
	uint8_t v1_len;
	uint16_t Maddr;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr = (uint16_t)pop();
	dbg(APPNAME,"VM::f_inc(%02x): v1_len=%d, Maddr=%d, value+1=%d, \n",Modifier,v1_len,Maddr,getMVal(Maddr,v1_len)+1);
	setMVal((getMVal(Maddr,v1_len)+1),Maddr,v1_len);	
}

void f_dec(uint8_t Modifier){
	uint8_t v1_len;
	uint16_t Maddr;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr = (uint16_t)pop();
	dbg(APPNAME,"VM::f_dec(%02x): v1_len=%d, Maddr=%d, value-1=%d, \n",Modifier,v1_len,Maddr,getMVal(Maddr,v1_len)-1);
	setMVal((getMVal(Maddr,v1_len)-1),Maddr,v1_len);	
}


void f_memcpy(uint8_t Modifier){
	uint8_t p2_1len,p3_1len;
	uint16_t size,MaddrFrom,MaddrTo;
	p2_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p3_1len = (uint8_t)(1<<((Modifier & 0x01)));
	size 	  = getPar16(2);
	MaddrFrom = getPar16(p2_1len);
	MaddrTo   = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_memcpy(%02x): size=%d, p2_1len=%d, p3_1len=%d, AddrTo=%d, AddrFrom=%d \n",Modifier,size,p2_1len,p3_1len,MaddrTo,MaddrFrom);
	memcpy((void*)(MEM+MaddrTo),(void*)(MEM+MaddrFrom),size);
}

void f_memcpyx(uint8_t Modifier){
	uint8_t p2_1len,p3_1len;
	uint16_t size,MaddrFrom,MaddrTo;
	p2_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p3_1len = (uint8_t)(1<<((Modifier & 0x01)));
	size 	  = getPar16(1);
	MaddrFrom = getPar16(p2_1len);
	MaddrTo   = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_memcpyx(%02x): size=%d, p2_1len=%d, p3_1len=%d, AddrTo=%d, AddrFrom=%d \n",Modifier,size,p2_1len,p3_1len,MaddrTo,MaddrFrom);
	memcpy((void*)(MEM+MaddrTo),(void*)(MEM+MaddrFrom),size);
}

void f_deref(uint8_t Modifier){
	uint16_t MAddr;
	uint8_t type, tlen;
	type = (uint8_t)(Modifier & 0x3);
	tlen = 1 << type;
	MAddr = (uint16_t)pop();
	dbg(APPNAME,"VM::f_deref(%02x): type=%d, MAddr=%d, ",Modifier,type,MAddr);
	switch (type){
		case x8 : dbg_clear(APPNAME,"type='x8' , value=%d\n",( uint8_t)getMVal(MAddr,tlen)); push(( uint8_t)getMVal(MAddr,tlen)); break;
		case x16: dbg_clear(APPNAME,"type='x16', value=%d\n",(uint16_t)getMVal(MAddr,tlen)); push((uint16_t)getMVal(MAddr,tlen)); break;
		case x32: dbg_clear(APPNAME,"type='x32', value=%d\n",(uint32_t)getMVal(MAddr,tlen)); push((uint32_t)getMVal(MAddr,tlen)); break;
	}
}

void f_push_c(uint8_t Modifier){
	uint8_t p1_len;
	uint32_t Const;
	p1_len = (uint8_t)((Modifier & 0x03)+1);
	Const = getPar32(p1_len);
	dbg(APPNAME,"VM::f_push_c(%02x): p1_len=%d, Const=%d, \n",Modifier,p1_len,Const);
	push(Const);
	}
	
void f_push_v(uint8_t Modifier){
	uint8_t v1_len;
	uint16_t Maddr;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr = getPar16(2);
	dbg(APPNAME,"VM::f_push_v(%02x): v1_len=%d, Maddr=%d, value=%d, \n",Modifier,v1_len,Maddr,getMVal(Maddr,v1_len));
	push(getMVal(Maddr,v1_len));
}

void f_pushx_v(uint8_t Modifier){
	uint8_t v1_len;
	uint16_t Maddr;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr = getPar16(1);
	dbg(APPNAME,"VM::f_pushx_v(%02x): v1_len=%d, Maddr=%d, value=%d, \n",Modifier,v1_len,Maddr,getMVal(Maddr,v1_len));
	push(getMVal(Maddr,v1_len));
}

void f_push_p(uint8_t Modifier){
	uint8_t v1_len;
	uint16_t Maddr;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr = getPar16(2);
	dbg(APPNAME,"VM::f_push_p(%02x): v1_len=%d, Maddr=%d, value=%d, \n",Modifier,v1_len,Maddr,getMVal(*(nx_uint16_t*)(MEM+Maddr),v1_len));
	push(getMVal(*(nx_uint16_t*)(MEM+Maddr),v1_len));
}

void f_pushx_p(uint8_t Modifier){
	uint8_t v1_len;
	uint16_t Maddr;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr = getPar16(1);
	dbg(APPNAME,"VM::f_pushx_p(%02x): v1_len=%d, Maddr=%d, value=%d, \n",Modifier,v1_len,Maddr,getMVal(*(nx_uint16_t*)(MEM+Maddr),v1_len));
	push(getMVal(*(nx_uint16_t*)(MEM+Maddr),v1_len));
}

void f_pusharr_v(uint8_t Modifier){
	uint8_t v1_len,p1_1len,v2_len,p2_1len,p3_1len,Aux;
	uint16_t Maddr,Vidx,Max;
	v1_len = (uint8_t)(1<<((Modifier & 0x03)));
	Aux = getPar8(1);
	p1_1len = (uint8_t)(1<<((Aux & 0x40)>>6));
	v2_len  = (uint8_t)(1<<((Aux & 0x30)>>4));
	p2_1len = (uint8_t)(1<<((Aux & 0x04)>>2));
	p3_1len = (uint8_t)(1<<((Aux & 0x01)));
	Maddr = getPar16(p1_1len);
 	Vidx  = getPar16(p2_1len);
	Max   = getPar16(p3_1len);
	dbg(APPNAME,"VM::f_pusharr_v(%02x):Maddr=%d, Vidx=%d, Max=%d, Val=%d, IDX OVERFLOW=%s idx=%d newIdx=%d\n",Modifier,Maddr,Vidx,Max,
			(getMVal(Maddr+(getMVal(Vidx,v2_len)*v1_len),v1_len)),_TFstr(getMVal(Vidx,v2_len) > Max),getMVal(Vidx,v2_len),getMVal(Vidx,v2_len)%Max);
//	(getMVal(Vidx,v2_len)<Max)?push(getMVal(Maddr+(getMVal(Vidx,v2_len)*v1_len),v1_len)):0;
// Alterado para fazer push de Addr+Id
	push(Maddr+((getMVal(Vidx,v2_len)%Max)*v1_len));
}

void f_pop(uint8_t Modifier){ 
	uint8_t v1_len;
	uint16_t Maddr;
	uint32_t Value;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr = getPar16(2);
	Value=pop();
	dbg(APPNAME,"VM::f_pop(%02x): v1_len=%d, Maddr=%d, value=%d, \n",Modifier,v1_len,Maddr,Value);
	setMVal(Value,Maddr,v1_len);
}

void f_popx(uint8_t Modifier){ 
	uint8_t v1_len;
	uint16_t Maddr;
	uint32_t Value;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr = getPar16(1);
	Value=pop();
	dbg(APPNAME,"VM::f_popx(%02x): v1_len=%d, Maddr=%d, value=%d, \n",Modifier,v1_len,Maddr,Value);
	setMVal(Value,Maddr,v1_len);
}

void f_poparr_v(uint8_t Modifier){
	uint8_t v1_len,p1_1len,v2_len,p2_1len,p3_1len,Aux;
	uint16_t Maddr,Vidx,Max;
	uint32_t Value;
	v1_len = (uint8_t)(1<<((Modifier & 0x03)));
	Aux = getPar8(1);
	p1_1len = (uint8_t)(1<<((Aux & 0x40)>>6));
	v2_len  = (uint8_t)(1<<((Aux & 0x30)>>4));
	p2_1len = (uint8_t)(1<<((Aux & 0x04)>>2));
	p3_1len = (uint8_t)(1<<((Aux & 0x01)));
	Maddr = getPar16(p1_1len);
 	Vidx  = getPar16(p2_1len);
	Max   = getPar16(p3_1len);
	Value=pop();
	dbg(APPNAME,"VM::f_poparr_v(%02x):Maddr=%d, Vidx=%d, Max=%d, Value=%d, IDX OVERFLOW=%s idx=%d newIdx=%d\n",
			Modifier,Maddr,Vidx,Max,Value,_TFstr(getMVal(Vidx,v2_len) > Max),getMVal(Vidx,v2_len),getMVal(Vidx,v2_len)%Max);
	setMVal(Value,Maddr+((getMVal(Vidx,v2_len)%Max)*v1_len),v1_len);
}


void f_setarr_vc(uint8_t Modifier){
	uint8_t v1_len,p1_1len,p2_1len,v2_len,p3_1len,p4_len,Aux;
	uint16_t Maddr,Vidx,Max;
	uint32_t Const;
	v1_len = (uint8_t)(1<<((Modifier & 0x03)));
	Aux = getPar8(1);
	p1_1len = (uint8_t)(1<<((Aux & 0x80)>>7));
	p2_1len = (uint8_t)(1<<((Aux & 0x40)>>6));
	v2_len  = (uint8_t)(1<<((Aux & 0x30)>>4));
	p3_1len = (uint8_t)(1<<((Aux & 0x08)>>3));
	p4_len = (uint8_t)((Aux & 0x03)+1);
	Maddr = getPar16(p1_1len);
 	Vidx  = getPar16(p2_1len);
	Max   = getPar16(p3_1len);
	Const = getPar32(p4_len);
	dbg(APPNAME,"VM::f_setarr_vc(%02x):Maddr=%d, Vidx=%d, Max=%d, Const=%d, IDX OVERFLOW=%s idx=%d newIdx=%d\n",
			Modifier,Maddr,Vidx,Max,Const,_TFstr(getMVal(Vidx,v2_len) > Max),getMVal(Vidx,v2_len),getMVal(Vidx,v2_len)%Max);
	memcpy((MEM+Maddr+((getMVal(Vidx,v2_len)%Max)*v1_len)),&Const,v1_len);
}
void f_setarr_vv(uint8_t Modifier){
	uint8_t v1_len,p1_1len,p2_1len,v2_len,p3_1len,p4_1len,v4_len,Aux;
	uint16_t Maddr1,Vidx,Max,Maddr2;
	v1_len = (uint8_t)(1<<((Modifier & 0x03)));
	Aux = getPar8(1);
	p1_1len = (uint8_t)(1<<((Aux & 0x80)>>7));
	p2_1len = (uint8_t)(1<<((Aux & 0x40)>>6));
	v2_len  = (uint8_t)(1<<((Aux & 0x30)>>4));
	p3_1len = (uint8_t)(1<<((Aux & 0x08)>>3));
	p4_1len = (uint8_t)(1<<((Aux & 0x04)>>2));
	v4_len  = (uint8_t)((Aux & 0x03)+1);
	Maddr1 = getPar16(p1_1len);
 	Vidx   = getPar16(p2_1len);
	Max    = getPar16(p3_1len);
	Maddr2 = getPar16(p4_1len);
	dbg(APPNAME,"VM::f_setarr_vv(%02x):Maddr1=%d, Vidx=%d, Max=%d, Madr2=%d, IDX OVERFLOW=%s idx=%d newIdx=%d\n",
				Modifier,Maddr1,Vidx,Max,Maddr2,_TFstr(getMVal(Vidx,v2_len) > Max),getMVal(Vidx,v2_len),getMVal(Vidx,v2_len)%Max);
	memcpy((MEM+Maddr1+((getMVal(Vidx,v2_len)%Max)*v1_len)),(MEM+Maddr2),v1_len);
}

void f_memclr(uint8_t Modifier){
	uint8_t p1_1len,p2_1len;
	uint16_t Maddr,len;
	p1_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p2_1len = (uint8_t)(1<<((Modifier & 0x01)));
	Maddr = getPar16(p1_1len);
	len = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_memclr(%02x): Maddr=%d, len=%d\n",Modifier,Maddr,len);
	dbg("VMDBG","VM:: clear clock/gate entry.\n");
	memset((MEM+Maddr),0,len);
	//{int x; for (x=0; x< len;x++) *(uint8_t*)(MEM+Maddr+x)=0;} 
	}
	
void f_getextdt_p(uint8_t Modifier){
	uint8_t p1_1len,p2_1len;
	uint16_t Maddr,len;
	p1_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p2_1len = (uint8_t)(1<<((Modifier & 0x01)));
	Maddr = getPar16(p1_1len);
	len = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_getextdt_p(%02x): Maddr=%d, len=%d\n",Modifier,Maddr,len);
	dbg("VMDBG","VM:: reading input event data.\n");
	memcpy((MEM+(*(nx_uint16_t*)(MEM+Maddr))),CEU->ext_data,len);
	}
void f_getextdt_v(uint8_t Modifier){
	uint8_t p1_1len,p2_1len;
	uint16_t Maddr,len;
	p1_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p2_1len = (uint8_t)(1<<((Modifier & 0x01)));
	Maddr = getPar16(p1_1len);
	len = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_getextdt_v(%02x): Maddr=%d, len=%d\n",Modifier,Maddr,len);
	dbg("VMDBG","VM:: reading input event data.\n");
	memcpy((MEM+Maddr),CEU->ext_data,len);
	}
void f_getextdt_e(uint8_t Modifier){
	uint8_t p1_1len;
	uint16_t Maddr,len;
	p1_1len = (uint8_t)(1<<((Modifier & 0x01)));
	Maddr = (uint16_t)pop();
	len = getPar16(p1_1len);
	dbg(APPNAME,"VM::f_getextdt_e(%02x): Maddr=%d, len=%d\n",Modifier,Maddr,len);
	dbg("VMDBG","VM:: reading input event data.\n");
	memcpy((MEM+Maddr),CEU->ext_data,len);
	}

void f_chkret(uint8_t Modifier){
	uint8_t p1_1len;
	uint16_t Maddr;
	p1_1len = (uint8_t)(1<<(Modifier & 0x01));
	Maddr = getPar16(p1_1len);
	dbg(APPNAME,"VM::f_chkret(%02x): p1_1len=%d, MAddr=%d value=%d, \n",Modifier,p1_1len,Maddr,*(uint8_t*)(MEM+Maddr));
	dbg("VMDBG","VM:: test end of PAR.\n");
	if (*(uint8_t*)(MEM+Maddr)>0) PC=PC+1;
}

void f_asen(uint8_t Modifier){
	uint8_t p1_1len,p2_1len;
	uint16_t gate,lbl;
	p1_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p2_1len = (uint8_t)(1<<((Modifier & 0x01)));
	gate = getPar16(p1_1len);
	lbl = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_asen(%02x): gate=%d, lbl=%d\n",Modifier,gate,lbl);
	dbg("VMDBG","VM:: async enable: gate=%d; label=%d.\n",gate,lbl);
	ceu_async_enable(gate,lbl);
}

void f_exec(uint8_t Modifier){ 
	uint8_t p1_1len;
	uint16_t Const;
	p1_1len = (uint8_t)(1<<(Modifier & 0x01));
	Const = getPar16(p1_1len);
	dbg(APPNAME,"VM::f_exec(%02x): p1_1len=%d, Const=%d\n",Modifier,p1_1len,Const);
	dbg("VMDBG","VM:: executing trail: label=%d.\n",Const);
	PC = getLblAddr(Const);
}

void f_ifelse(uint8_t Modifier){
	uint8_t p1_1len,p2_1len;
	uint16_t lbl1,lbl2;
	p1_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p2_1len = (uint8_t)(1<<((Modifier & 0x01)));
	lbl1 = getPar16(p1_1len);
	lbl2 = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_ifelse(%02x): lbl1=%d, lbl2=%d\n",Modifier,lbl1,lbl2);
	dbg("VMDBG","VM:: if/else: TRUE label=%d; FALSE label=%d.\n",lbl1,lbl2);
	if (pop()) PC=getLblAddr(lbl1); else PC=getLblAddr(lbl2);
}

void f_outevt_e(uint8_t Modifier){
	uint8_t Cevt;
	uint32_t value;
	value = pop();
	Cevt  = getPar8(1);
	dbg(APPNAME,"VM::f_outevt_c(%02x): Cevt=%d\n",Modifier,Cevt);
	dbg("VMDBG","VM:: emitting output event %d\n",Cevt);
	call VMCustom.procOutEvt(Cevt,value);
}

void f_outevt_c(uint8_t Modifier){
	uint8_t Clen;
	uint8_t Cevt;
	uint32_t Const;
	Clen = (uint8_t)((Modifier & 0x03)+1);
	Cevt  = getPar8(1);
	Const = getPar32(Clen);
	dbg(APPNAME,"VM::f_outevt_c(%02x): Cevt=%d, Clen=%d, Const=%d\n",Modifier,Cevt,Clen,Const);
	call VMCustom.procOutEvt(Cevt,Const);
}

void f_outevt_v(uint8_t Modifier){
	uint8_t Cevt,tp_len;
	uint16_t Maddr;
	tp_len = (uint8_t)(1<<(Modifier & 0x02));
	Cevt  = getPar8(1);
	Maddr = getPar16(2);
	dbg(APPNAME,"VM::f_outevt_v(%02x): Cevt=%d, Maddr=%d\n",Modifier,Cevt,Maddr);
//	call VMCustom.procOutEvt(Cevt,getMVal(Maddr,tp_len));
	call VMCustom.procOutEvt(Cevt,Maddr);
}
void f_outevtx_v(uint8_t Modifier){
	uint8_t Cevt,tp_len;
	uint16_t Maddr;
	tp_len = (uint8_t)(1<<(Modifier & 0x02));
	Cevt  = getPar8(1);
	Maddr = getPar16(1);
	dbg(APPNAME,"VM::f_outevtx_v(%02x): Cevt=%d, Maddr=%d\n",Modifier,Cevt,Maddr);
//	call VMCustom.procOutEvt(Cevt,getMVal(Maddr,tp_len));
	call VMCustom.procOutEvt(Cevt,Maddr);
}

void f_outevt_z(uint8_t Modifier){
	uint8_t Cevt;
	Cevt = getPar8(1);
	dbg(APPNAME,"VM::f_outevt_z(%02x): Evt=%d, \n",Modifier,Cevt);
	call VMCustom.procOutEvt(Cevt,0);
	}
	
void f_tkclr(uint8_t Modifier){
	uint8_t p1_1len,p2_1len;
	uint16_t lbl1,lbl2;
	p1_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p2_1len = (uint8_t)(1<<((Modifier & 0x01)));
	lbl1 = getPar16(p1_1len);
	lbl2 = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_tkclr(%02x): lbl1=%d, lbl2=%d\n",Modifier,lbl1,lbl2);
	dbg("VMDBG","VM:: clear tracks for label %d to label %d\n",lbl1,lbl2);
	ceu_track_clr(lbl1,lbl2);	
	}

void f_trg(uint8_t Modifier){
	uint8_t p1_1len;
	uint16_t gtAddr;
	p1_1len = (uint8_t)(1<<(Modifier & 0x01));
	gtAddr = getPar16(p1_1len);
	dbg(APPNAME,"VM::f_trg(%02x): p1_1len=%d, gtAddr=%d, \n",Modifier,p1_1len,gtAddr);
	dbg("VMDBG","VM:: trigger event gate=%d, auxId=0\n",gtAddr);
	ceu_trigger(gtAddr,0);
}

void f_set16_c(uint8_t Modifier){
	uint8_t v1_len,p1_1len,p2_1len;
	uint16_t Maddr;
	uint32_t Const;
	v1_len = (uint8_t)(1<<((Modifier & 0x0C)>>2));
	p1_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p2_1len = (uint8_t)(1<<(Modifier & 0x01));
	Maddr = getPar16(p1_1len);
	Const = getPar32(p2_1len);
	dbg(APPNAME,"VM::f_set16_c(%02x): v1_len=%d, p1_1len=%d, p2_len=%d, Maddr=%d, Const=%d\n",Modifier,v1_len,p1_1len,p2_1len,Maddr,Const);
	//if (getLblAddr((uint16_t)Const) > 0) dbg("VMDBG","VM:: possible await EVENT for label %d\n",Const);
	setMVal(Const,Maddr,v1_len);
}

void f_set_c(uint8_t Modifier){
	uint8_t v1_len,p1_1len,p2_len, param;
	uint16_t Maddr;
	uint32_t Const;
	param = getPar8(1);
	v1_len = (uint8_t)(1<<((param & 0x30)>>4));
	p1_1len = (uint8_t)(1<<((param & 0x04)>>2));
	p2_len = (uint8_t)(1<<(param & 0x03));
	Maddr = getPar16(p1_1len);
	Const = getPar32(p2_len);
	dbg(APPNAME,"VM::f_set_c(%02x): v1_len=%d, p1_1len=%d, p2_len=%d, Maddr=%d, Const=%d\n",Modifier,v1_len,p1_1len,p2_len,Maddr,Const);
	//if (getLblAddr((uint16_t)Const) > 0) dbg("VMDBG","VM:: possible await EVENT for label %d\n",Const);
	setMVal(Const,Maddr,v1_len);
}

void f_set_e(uint8_t Modifier){
	uint8_t v1_len;
	uint16_t Maddr1;
	uint32_t Value;
	v1_len = (uint8_t)(1<<(Modifier & 0x03));
	Maddr1 = (uint16_t)pop();
	Value = pop();
	setMVal(Value,Maddr1,v1_len);
	dbg(APPNAME,"VM::f_set_e(%02x): v1_len=%d, Maddr1=%d, Value=%d, ValuePos=%d\n",Modifier,v1_len,Maddr1,Value,getMVal(Maddr1,v1_len));
}


void f_func(uint8_t Modifier){ 
	uint8_t fID;
	fID  = getPar8(1);
	dbg(APPNAME,"VM::f_func(%02x): fID=%d\n",Modifier,fID);
	dbg("VMDBG","VM:: call function %d\n",fID);
	call VMCustom.callFunction(fID);
}


void f_set_v(uint8_t Modifier){
	uint8_t v1_len,p1_1len,p2_1len;
	uint16_t Maddr1,Maddr2;
	v1_len = (uint8_t)(1<<((Modifier & 0x0C)>>2));
	p1_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	p2_1len = (uint8_t)(1<<(Modifier & 0x01));
	Maddr1 = getPar16(p1_1len);
	Maddr2 = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_set_v(%02x): v1_len=%d, p1_1len=%d, p2_1len=%d, Maddr1=%d, Maddr2=%d\n",Modifier,v1_len,p1_1len,p2_1len,Maddr1,Maddr2);
	setMVal(getMVal(Maddr2,v1_len),Maddr1,v1_len);
}


void f_clken_c(uint8_t Modifier){
	uint8_t p1_1len,p2_len,p3_1len;
	uint16_t gate,lbl;
	uint32_t Ctime;
	p1_1len = (uint8_t)(1<<((Modifier & 0x08)>>3));
	p3_1len = (uint8_t)(1<<((Modifier & 0x04)>>2));
	p2_len = (uint8_t)((Modifier & 0x03)+1);
	gate = getPar16(p1_1len);
	Ctime = getPar32(p2_len);
	lbl = getPar16(p3_1len);
	dbg(APPNAME,"VM::f_clken_c(%02x): p1_1len=%d, p2_len=%d, p3_1len=%d, gate=%d, Ctime=%d, lbl=%d\n",Modifier,p1_1len,p2_len,p3_1len,gate,Ctime,lbl);
	dbg("VMDBG","VM:: await timer %ld for label %d\n",(s32)Ctime, lbl);
	ceu_wclock_enable(gate, (s32)Ctime, lbl);

}

void f_clken_v(uint8_t Modifier){
	uint8_t p1_1len,p4_1len,v3_len,unit;
	uint16_t gate,lbl,VtimeAddr;
	uint32_t Time=0;
	p1_1len = (uint8_t)(1<<((Modifier & 0x08)>>3));
	p4_1len = (uint8_t)(1<<((Modifier & 0x04)>>2));
	v3_len = (uint8_t)(1<<(Modifier & 0x03));
	gate = getPar16(p1_1len);
	unit = getPar8(1);
	VtimeAddr = getPar16(2);
	lbl = getPar16(p4_1len);
	Time = getMVal(((uint16_t)MEM+VtimeAddr),v3_len); 
	dbg(APPNAME,"VM::f_clken_v(%02x): p1_1len=%d, v3_len=%d, p4_1len=%d, gate=%d, unit=%d, Vtime=%d, lbl=%d\n",
		Modifier,p1_1len,v3_len,p4_1len,gate,unit,VtimeAddr,lbl);
	dbg("VMDBG","VM:: await timer %ld for label %d\n",(s32)unit2val(Time,unit), lbl);
	ceu_wclock_enable(gate, (s32)unit2val(Time,unit), lbl);
}

void f_clken_e(uint8_t Modifier){
	uint8_t p1_1len,p2_1len,unit;
	uint16_t gate,lbl;
	uint32_t Time=0;
	p1_1len = (uint8_t)(1<<((Modifier & 0x08)>>3));
	p2_1len = (uint8_t)(1<<((Modifier & 0x04)>>2));
	unit = (uint8_t)(1<<(Modifier & 0x03));
	gate = getPar16(p1_1len);
	lbl = getPar16(p2_1len);
	Time = pop();
	dbg(APPNAME,"VM::f_clken_e(%02x): p1_1len=%d, p2_1len=%d, gate=%d, unit=%d, Time=%d, lbl=%d\n",
		Modifier,p1_1len,p2_1len,gate,unit,Time,lbl);
	dbg("VMDBG","VM:: await timer %ld for label %d\n",(s32)unit2val(Time,unit), lbl);
	ceu_wclock_enable(gate, (s32)unit2val(Time,unit), lbl);
}

void f_tkins_max(uint8_t Modifier){
	uint8_t stack,p1_1len;
	uint16_t lbl;
	stack = (uint8_t)(CEU->stack + (Modifier >> 2));
	p1_1len = (uint8_t)(1<<(Modifier & 0x01));
	lbl = getPar16(p1_1len);
	dbg(APPNAME,"VM::f_tkins_max(%02x): stack=%d, p1_1len=%d, lbl=%d, \n",Modifier,stack,p1_1len,lbl);
	dbg("VMDBG","VM:: enable track for label %d\n", lbl);
	ceu_track_ins(stack,255,0,lbl);
}

void f_tkins_z(uint8_t Modifier){ 
	uint8_t tree,chk,p2_1len;
	uint16_t lbl;
	p2_1len = (uint8_t)(1<<((Modifier & 0x02)>>1));
	chk = (uint8_t)(Modifier & 0x01);
	tree = getPar8(1);
	lbl = getPar16(p2_1len);
	dbg(APPNAME,"VM::f_tkins_z(%02x): tree=%d, chk=%d, p2_1len=%d, lbl=%d, \n",Modifier,tree,chk,p2_1len,lbl);
	dbg("VMDBG","VM:: enable track for label %d\n", lbl);
	ceu_track_ins(0,tree,chk,lbl);
}


	/*
	 * Operation decoder
	 */
	void Decoder(uint8_t Opcode,uint8_t Modifier){
//		dbg(APPNAME,"VM::Decoder()\n");
		// Execute the respective operation
		dbg(APPNAME,"VM::Decoder(): PC= %d opcode= %hhu modifier=%d\n",PC-1,Opcode,Modifier);
		switch (Opcode){
			case op_nop : f_nop(Modifier); break;
			case op_end : f_end(Modifier); break;

			case op_bnot : f_bnot(Modifier); break;
			case op_lnot : f_lnot(Modifier); break;
			case op_neg : f_neg(Modifier); break;
			case op_sub : f_sub(Modifier); break;
			case op_add : f_add(Modifier); break;
			case op_mod : f_mod(Modifier); break;
			case op_mult : f_mult(Modifier); break;
			case op_div : f_div(Modifier); break;
			case op_bor : f_bor(Modifier); break;
			case op_band : f_band(Modifier); break;
			case op_lshft : f_lshft(Modifier); break;
			case op_rshft : f_rshft(Modifier); break;
			case op_bxor : f_bxor(Modifier); break;
			case op_eq : f_eq(Modifier); break;
			case op_neq : f_neq(Modifier); break;
			case op_gte : f_gte(Modifier); break;
			case op_lte : f_lte(Modifier); break;
			case op_gt : f_gt(Modifier); break;
			case op_lt : f_lt(Modifier); break;
			case op_lor : f_lor(Modifier); break;
			case op_land : f_land(Modifier); break;
			case op_set_c : f_set_c(Modifier); break;
			case op_func : f_func(Modifier); break;
			case op_outevt_z : f_outevt_z(Modifier); break;
			case op_outevt_e : f_outevt_e(Modifier); break;
			case op_pop : f_pop(Modifier); break;
			case op_popx : f_popx(Modifier); break;
			case op_poparr_v : f_poparr_v(Modifier); break;
			case op_push_c : f_push_c(Modifier); break;
			case op_push_p : f_push_p(Modifier); break;
			case op_push_v : f_push_v(Modifier); break;
			case op_pushx_p : f_pushx_p(Modifier); break;
			case op_pushx_v : f_pushx_v(Modifier); break;
			case op_pusharr_v : f_pusharr_v(Modifier); break;
			case op_set_e : f_set_e(Modifier); break;
			case op_setarr_vc : f_setarr_vc(Modifier); break;
			case op_setarr_vv : f_setarr_vv(Modifier); break;
			case op_getextdt_p : f_getextdt_p(Modifier); break;
			case op_getextdt_v : f_getextdt_v(Modifier); break;
			case op_cast : f_cast(Modifier); break;
			case op_inc : f_inc(Modifier); break;
			case op_dec : f_dec(Modifier); break;
			case op_memcpy : f_memcpy(Modifier); break;
			case op_memcpyx : f_memcpyx(Modifier); break;
			case op_outevt_c : f_outevt_c(Modifier); break;
			case op_outevt_v : f_outevt_v(Modifier); break;
			case op_outevtx_v : f_outevtx_v(Modifier); break;
			case op_exec : f_exec(Modifier); break;
			case op_memclr : f_memclr(Modifier); break;
			case op_ifelse : f_ifelse(Modifier); break;
			case op_trg : f_trg(Modifier); break;
			case op_tkins_z : f_tkins_z(Modifier); break;
			case op_tkclr : f_tkclr(Modifier); break;
			case op_chkret : f_chkret(Modifier); break;
			case op_asen : f_asen(Modifier); break;
			case op_deref : f_deref(Modifier); break;
			case op_getextdt_e : f_getextdt_e(Modifier); break;
			case op_clken_c : f_clken_c(Modifier); break;
			case op_clken_v : f_clken_v(Modifier); break;
			case op_clken_e : f_clken_e(Modifier); break;
			case op_tkins_max : f_tkins_max(Modifier); break;
			case op_set16_c : f_set16_c(Modifier); break;
			case op_set_v : f_set_v(Modifier); break;
		}
	
	}

#endif // End large ONLY_BSTATION 
//******************************************************************************
// Final da re-edição de WDCeuVM
//******************************************************************************

	/**
	 * Inserts an event in the event queue
	 */
	event void VMCustom.queueEvt(uint8_t evtId, uint8_t auxId, void *data){
#ifndef ONLY_BSTATION
		evtData_t evtData;
		dbg(APPNAME,"VM::VMCustom.queueEvt(): queueing evtId=%d, auxId=%d. procFlag=%s\n",evtId,auxId,(procFlag)?"TRUE":"FALSE");
		// Queue the message event
		evtData.evtId = evtId;
		evtData.auxId = auxId;
		evtData.data = data;
		call evtQ.enqueue(evtData);
		if (procFlag==FALSE) post procEvent();		
#endif
	}
	
	/**
	 * Process next event, if it exists
	 */
#ifndef ONLY_BSTATION
	task void procEvent(){
		evtData_t evtData;
		uint16_t ceuId;
		dbg(APPNAME,"VM::procEvent(): haltedFlag = %s, procFlag=%s\n",(haltedFlag)?"TRUE":"FALSE",(procFlag)?"TRUE":"FALSE");
		if (haltedFlag == TRUE) {call evtQ.dequeue(); return;}
		// Verify if the queue has some event and if the processing is stopped
		if ((call evtQ.size() > 0) && (procFlag==FALSE)){
			// Send next event to CEU
			dbg(APPNAME,"VM::procEvent(): Dequeue an event and ...\n");
			evtData=call evtQ.dequeue();
			dbg(APPNAME,"VM::procEvent(): ... calling ceu_go_event() for evtId=%d, auxId=%d\n", evtData.evtId,evtData.auxId );
			ceuId = getEvtCeuId(evtData.evtId);
			if (ceuId==0) {
				dbg(APPNAME,"VM::procEvent(): Discarding event %d\n",evtData.evtId);
				post procEvent(); // Try next event
			} else
				ceu_go_event(NULL,ceuId,evtData.auxId,evtData.data);
		}
		dbg(APPNAME,"VM::procEvent()...\n");
	}
#endif

	event int32_t VMCustom.getMVal(uint16_t Maddr, uint8_t v1_len){
#ifndef ONLY_BSTATION
		return getMVal(Maddr,v1_len);
#else
		return 0;
#endif
		}
	event void VMCustom.setMVal(uint32_t value,uint16_t Maddr, uint8_t v1_len){
#ifndef ONLY_BSTATION
		setMVal(value, Maddr,v1_len);
#endif
		}

	event void* VMCustom.getRealAddr(uint16_t Maddr, uint8_t v1_len){
#ifndef ONLY_BSTATION
//		dbg(APPNAME,"VM::VMCustom.getRealAddr(): Maddr=%d, v1_len=%d,MVal = %x, RealMEM=%x\n",Maddr,v1_len,getMVal(Maddr,v1_len),(MEM + getMVal(Maddr,v1_len)));
//		return (MEM + getMVal(Maddr,v1_len));
		dbg(APPNAME,"VM::VMCustom.getRealAddr(): Maddr=%d, v1_len=%d,RealMEM=%x\n",Maddr,v1_len,(MEM + Maddr));
		return (MEM + Maddr);
#else
		return 0;
#endif
		}

	event uint32_t VMCustom.pop(){
#ifndef ONLY_BSTATION
		currStack = currStack + 4 ;
		return *(uint32_t*)(CEU_data+currStack-4);
#endif
	}
	event void VMCustom.push(uint32_t value){
#ifndef ONLY_BSTATION
		currStack = currStack - 4 ;
		*(uint32_t*)(CEU_data+currStack)=value;
#endif
	}
	event bool VMCustom.getHaltedFlag(){
		return haltedFlag;
	}

    event void BSTimerVM.fired()
    {
#ifndef ONLY_BSTATION
        u32 now = (u32)call BSTimerVM.getNow();
        s32 dt = now - old;
        old = now;
		dbg(APPNAME,"VM::BSTimerVM.fired(): dt=%d\n",dt);
        ceu_go_wclock(NULL, dt, NULL); // TODO: "binary" time
#endif
    }
    
	bool hasAsync(){
#ifndef ONLY_BSTATION
		uint8_t i;
	    tceu_nlbl* ASY0 = PTR(tceu_nlbl*,async0);
        for (i=0 ; i < asyncs ; i++) {
            if (ASY0[i] != Inactive) {
                return TRUE;
            }
        }
#endif
        return FALSE;
	}
    
	event void BSTimerAsync.fired()
    {
#ifndef ONLY_BSTATION
		dbg(APPNAME,"VM::BSTimerAsync.fired()\n");
		if (hasAsync()) call BSTimerAsync.startOneShot(ASYNC_DELAY);
	    ceu_go_async(NULL,NULL);
	     
#endif
    }


/* *********************************************************************************
*                         Upload program and data functions
\* ********************************************************************************/

	event void BSUpload.stop(){
		dbg(APPNAME,"VM::BSUpload.stop()\n");
		haltedFlag = TRUE;
	}

	event void BSUpload.setEnv(newProgVersion_t* data){
		ProgStart = (uint16_t)data->startProg;
		ProgEnd = (uint16_t)data->endProg;
		nTracks = data->nTracks;
		wClocks = data->wClocks;
		asyncs = data->asyncs;
		wClock0 = data->wClock0;
		gate0 = data->gate0;
		inEvts = data->inEvts;
		async0 = data->async0;

		dbg(APPNAME,"VM::BSUpload.setEnv(): ProgStart=%d, ProgEnd=%d, nTracks=%d, wClocks=%d, asyncs=%d, wClock0=%d, gate0=%d, async0=%d\n",
				ProgStart, ProgEnd, nTracks,wClocks,asyncs,wClock0,gate0,async0);
	} 
	
	event void BSUpload.getEnv(newProgVersion_t* data){
		dbg(APPNAME,"VM::BSUpload.getEnv()\n");
		data->startProg = ProgStart;
		data->endProg = ProgEnd;
		data->nTracks = nTracks;
		data->wClocks = wClocks;
		data->asyncs = asyncs;
		data->wClock0 = wClock0;
		data->gate0 = gate0;
		data->inEvts = inEvts;
		data->async0 = async0;
		dbg(APPNAME,"VM::BSUpload.getEnv(): ProgStart=%d, ProgEnd=%d, nTracks=%d, wClocks=%d, asyncs=%d, wClock0=%d, gate0=%d, async0=%d\n",
				ProgStart, ProgEnd,nTracks,wClocks,asyncs,wClock0,gate0,async0);
	}


	event void BSUpload.start(bool resetFlag){
		uint8_t i, size;
		dbg(APPNAME,"VM::BSUpload.start(%s)\n",(resetFlag)?"TRUE":"FALSE");
		if (resetFlag==TRUE){ // Reset all stuff
			//Clean up Event Queue
			size = call evtQ.size();
			for (i=0; i < size; i++) call evtQ.dequeue();
		}
		haltedFlag = FALSE;	

#ifndef ONLY_BSTATION
		// Reset VMCustom
		call VMCustom.reset();
		// Give control do Ceu
		ceu_boot();
#endif
	}

	event uint8_t* BSUpload.getSection(uint16_t Addr){
		return (uint8_t*)&CEU_data[Addr];
	}

	event void BSUpload.resetMemory(){
		uint16_t i;
		uint8_t size;
		dbg(APPNAME,"VM::BSUpload.resetMemory()\n");
		haltedFlag = TRUE;
		// Reset CEU_data[]
		for (i=0; i < (uint16_t)(BLOCK_SIZE * CURRENT_MAX_BLOCKS); i++) CEU_data[i]=0;
		//Clean up Event Queue
		size = call evtQ.size();
		for (i=0; i < size; i++) call evtQ.dequeue();
	}


	event void BSUpload.loadSection(uint16_t Addr, uint8_t Size, uint8_t Data[]){
		memcpy(&CEU_data[Addr],Data,Size);		
		dbg(APPNAME,"VM::BSUpload.loadSection(): blk=%d, Addr=%d, Size=%d 1stByte=%d\n",(uint8_t)(Addr/BLOCK_SIZE),Addr,Size,CEU_data[Addr]);
	}
	
	
	
}