/***********************************************
 * TerraVM - Terra virtual machine project
 * MArch, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Include File: TerraVM
 * Main control - Constant definitions
 * 
 */
#ifndef TERRA_VM_H
#define TERRA_VM_H

#include "VMData.h"
#include "VMError.h"

/*
 * Instruction Set Range & Mask
 * {start,end,mask}
 */
#define IS_RangeMask_size 	6
const uint8_t IS_RangeMask[][3]={
	{0,47,0x00},	// 8 Bits Group
	{48,63,0x01},	// 7 Bits Group
	{64,103,0x03},	// 6 Bits Group
	{104,143,0x07},	// 5 Bits Group
	{144,191,0x0f},	// 4 Bits Group
	{192,255,0x3f},	// 2 Bits Group
};

#define CEU_STACK_MIN 0x01    // min prio for `stack´
#define CEU_TREE_MAX 0xFF     // max prio for `tree´

#if TOSVERSION >= 212
#define CEU_WCLOCK_NONE INT32_MAX
#else
#define CEU_WCLOCK_NONE 0x7FFFFFFF
#endif

#define PTR(tp,str) ((tp)(CEU->p_mem + str))
#define PTR_EXT(id,idx) ((tceu_nlbl*)(PTR(char*,id)+1+idx*sizeof(tceu_nlbl)))

#define ASYNC_DELAY 2

#ifdef PRINTF
#include "printf.h"
#endif

#define _TFstr(n) (n)?"TRUE":"FALSE"

#ifdef TOSSIM
typedef float nx_float;
#endif

// short names for types
typedef int64_t  s64;
typedef uint64_t u64;
typedef int32_t  s32;
typedef uint32_t u32;
typedef int16_t  s16;
typedef uint16_t u16;
typedef int8_t    s8;
typedef uint8_t   u8;
typedef float	 f32;

enum {
	
// Define event queue size - short or long from makefile definition
#ifdef SHORT_QUEUES
	EVT_QUEUE_SIZE = 6,
#else
	EVT_QUEUE_SIZE = 10,
#endif

	// Ctl section pointers
	DEFAULT_VARS			=  0,
	STRUC_DEF				=  2,
	VAR_SPACE				=  4,
	EVT_VARS				=  6,
	TMR_DEFS				=  8,
	GR_DEFS					=  10,
	AGG_DEFS				=  12,
	EVT_SPACE				= 14,
	FUNCTION_SPACE			= 16,
	INIT_FUNCTION			= 18,
	MOTE_ID					= 20,
	RESULT					= 22,

	// Var Types
	U8  = 0,
	U16 = 1,
	U32 = 2,
	F32 = 3,
	S8  = 4,
	S16 = 5,
	S32 = 6,

	// Generic var type
	x8  = 0,
	x16 = 1,
	x32 = 2,

	// Cast modes
	U32_F = 0,
	S32_F = 1,
	F_U32 = 2,
	F_S32 = 3, 
	
	// OpCodes
	op_nop=0,
	op_end=1,
	op_bnot=2,
	op_lnot=3,
	op_neg=4,
	op_sub=5,
	op_add=6,
	op_mod=7,
	op_mult=8,
	op_div=9,
	op_bor=10,
	op_band=11,
	op_lshft=12,
	op_rshft=13,
	op_bxor=14,
	op_eq=15,
	op_neq=16,
	op_gte=17,
	op_lte=18,
	op_gt=19,
	op_lt=20,
	op_lor=21,
	op_land=22,
	op_popx=23,

	op_neg_f=25,
	op_sub_f=26,
	op_add_f=27,
	op_mult_f=28,
	op_div_f=29,
	op_eq_f=30,
	op_neq_f=31,
	op_gte_f=32,
	op_lte_f=33,
	op_gt_f=34,
	op_lt_f=35,
	op_func=36,
	op_outEvt_e=37,
	op_outevt_z=38,
	op_clken_e=39,
	op_clken_v=40,
	op_clken_c=41,
	op_set_v=42,
	op_setarr_vc=43,
	op_setarr_vv=44,
	
	op_poparr_v=48,
	op_pusharr_v=50,
	op_getextdt_e=52,
	op_trg=54,
	op_exec=56,
	op_chkret=58,
	op_tkins_z=60,
	
	op_push_c=64,
	op_cast=68,
	op_memclr=72,
	op_ifelse=76,
	op_asen=80,
	op_tkclr=84,
	op_outEvt_c=88,
	op_getextdt_v=92,
	op_inc=96,
	op_dec=100,
	op_set_e=104,
	op_deref=112,
	op_memcpy=120,

	op_tkins_max=136,
	op_push_v=144,
	op_pop=160,
	op_outEvt_v=176,
	op_set_c=192,

};

// VM input event structure
typedef struct evtData{
	uint8_t evtId;
	uint8_t auxId;
	void* data;
} evtData_t;

#endif /* TERRA_VM_H */
