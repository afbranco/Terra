#include <string.h>
#include <limits.h>

//#define MAX_CEU_DATA 200      // max bytes reserved for ceu "tracks" and "mem"

#define CEU_STACK_MIN 0x01    // min prio for `stack´
#define CEU_TREE_MAX 0xFF     // max prio for `tree´

#define CEU_WCLOCK_NONE INT32_MAX

#define PTR(tp,str) ((tp)(CEU->p_mem + str))
#define PTR_EXT(id,idx) ((tceu_nlbl*)(PTR(char*,id)+1+idx*sizeof(tceu_nlbl)))

//#define N_MEM       (72)
//#define N_TRACKS    (8)
//#define CEU_WCLOCK0 (0)

// Macros that can be defined:
// ceu_out_pending() (1)
// ceu_out_wclock(us)
// ceu_out_async(has)
// ceu_out_event(id, len, data)

typedef u16 tceu_noff;
typedef u16 tceu_nlbl;

#include "ceu_defs.h"

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
    tceu_trk*       p_tracks;  // 0 is reserved
    char*           p_mem;
} tceu;

#define CEU (&CEU_)

tceu CEU_ = {
    0,
    CEU_STACK_MIN,
    0, 0,
    0, 0,
    0,
    0
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

// TODO: verificar otimizacao de parametros nao utilizados

void ceu_track_ins (u8 stack, u8 tree, int chk, tceu_nlbl lbl)
{
//	tceu_trk *track;
	dbg(APPNAME,"CEU::ceu_track_ins():: track_n=%d, stack=%d tree=%d chk=%d lbl=%d\n",CEU->tracks_n,stack,tree,chk,lbl);
    {int i;
    if (chk) {
        for (i=1; i<=CEU->tracks_n; i++) {
            if (lbl==(CEU->p_tracks+i)->lbl) {
                return;
            }
        }
    }}

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

void ceu_trigger (tceu_noff off)
{
    int i;
    int n = *(char*)(CEU->p_mem+off); //int n = CEU->mem[off];
    dbg(APPNAME,"CEU::ceu_trigger(): gate addr=%d, nGates=%d\n",off,n);


    for (i=0 ; i<n ; i++) {
        //ceu_spawn((tceu_nlbl*)&CEU->mem[off+1+(i*sizeof(tceu_nlbl))]);
        ceu_spawn((tceu_nlbl*)(CEU->p_mem+off+1+(i*sizeof(tceu_nlbl))));
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

    dbg(APPNAME,"CEU::ceu_wclock_enable(): gate=%d, time=%d, lbl=%d, dt=%d, wClock0=%d\n",gte,us,lbl,dt,wClock0);
//printf("[%d/%d] (%ld - %d) = %ld",gte,lbl,us,CEU->wclk_late,dt);printfflush();
    tmr->togo = dt;
    *(nx_uint16_t*)&(tmr->lbl)  = lbl;
	
#ifdef ceu_out_wclock
    if (ceu_wclock_lt(tmr))
        ceu_out_wclock(dt);
#else
    ceu_wclock_lt(tmr);
#endif
}



/**********************************************************************/

int ceu_go_init (int* ret)
{
//	dbg(APPNAME,"CEU::ceu_go_init(): halted=%s\n",(haltedFlag)?"TRUE":"FALSE");
   if (haltedFlag) return(0);

   CEU->p_tracks = (tceu_trk*)CEU_data+0;
   CEU->p_mem = CEU_data+((nTracks+1)*sizeof(tceu_trk));
   MEM = CEU->p_mem;

   ceu_track_ins(CEU_STACK_MIN, CEU_TREE_MAX, 0, Init);
    return ceu_go(ret);
}

int ceu_go_event (int* ret, int id, void* data)
{
   dbg(APPNAME,"CEU::ceu_go_event(): halted=%s - id=%d\n",(haltedFlag)?"TRUE":"FALSE",id);
    CEU->ext_data = data;
    CEU->stack = CEU_STACK_MIN;
    ceu_trigger(id);

    CEU->wclk_late--;

    return ceu_go(ret);
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
#ifdef ceu_out_wclock
        ceu_out_wclock(CEU_WCLOCK_NONE);
#endif
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
         	dbg(APPNAME,"CEU::ceu_go_wclock(): Loop1 nos wClocks: tmr->togo=%d, tmr->lbl=%d, --- M[4]=%d\n",(nx_uint32_t)(tmr->togo), *(nx_uint16_t*)&(tmr->lbl),*(uint8_t*)(CEU->p_mem+4));
        if (tmr->lbl == Inactive)
            continue;

        if ( tmr->togo==min_togo ) {
            tmr->togo = 0;
            ceu_spawn(&tmr->lbl);           // spawns sharing phys/ext
        } else {
            tmr->togo -= dt;
            ceu_wclock_lt(tmr);             // next? (sets CEU->wclk_cur)
        }
//        if (BStation!=TOS_NODE_ID)
//         	dbg(APPNAME,"CEU::ceu_go_wclock(): Loop2 nos wClocks: tmr->togo=%d, tmr->lbl=%d, --- M[4]=%d\n",tmr->togo, tmr->lbl,*(uint8_t*)(CEU->p_mem+4));
    }

//    dbg(APPNAME,"CEU::ceu_go_wclock(): 1 --- M[4]=%d\n",*(uint8_t*)(CEU->p_mem+4));

    {int s = ceu_go(ret);
    if (nxt)
        *nxt = (CEU->wclk_cur ? CEU->wclk_cur->togo : CEU_WCLOCK_NONE);
    CEU->wclk_late = 0;
#ifdef ceu_out_wclock
    ceu_out_wclock(CEU->wclk_cur ? CEU->wclk_cur->togo : CEU_WCLOCK_NONE);
#endif
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

    if (ceu_go_init(&ret))
        return ret;

#ifdef IN_START
    //*PVAL(int,IN_START) = (argc>1) ? atoi(argv[1]) : 0;
    if (ceu_go_event(&ret, IN_START, NULL))
        return ret;
#endif


    return ret;
}