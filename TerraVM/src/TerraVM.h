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

#define LIMIT_8BIT_OPER 0x1B
#define LIMIT_6BIT_OPER 0x9F
#define LIMIT_4BIT_OPER 0xFF

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

// short names for types
typedef int64_t  s64;
typedef uint64_t u64;
typedef int32_t  s32;
typedef uint32_t u32;
typedef int16_t  s16;
typedef uint16_t u16;
typedef int8_t    s8;
typedef uint8_t   u8;


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
	S8  = 4,
	S16 = 5,
	S32 = 6,

	// Generic var time
	x8  = 0,
	x16 = 1,
	x32 = 2,
	
	// OpCodes
	op_nop=0,
	op_end=1,
	
	op_bnot=3,
	op_lnot=4,
	op_neg=5,
	op_sub=6,
	op_add=7,
	op_mod=8,
	op_mult=9,
	op_div=10,
	op_bor=11,
	op_band=12,
	op_lshft=13,
	op_rshft=14,
	op_bxor=15,
	op_eq=16,
	op_neq=17,
	op_gte=18,
	op_lte=19,
	op_gt=20,
	op_lt=21,
	op_lor=22,
	op_land=23,
	op_set_c=24,
	op_func=25,
	op_outevt_z=26,
	op_outevt_e=27,
	op_pop=28,
	op_popx=32,
	op_poparr_v=36,
	op_push_c=40,
	op_push_v=44,
	op_pushx_v=48,
	op_pusharr_v=52,
	op_deref=56,
	
	op_set_e=64,
	op_setarr_vc=68,
	op_setarr_vv=72,
	op_getextdt_e=76,
	op_getextdt_v=80,
	op_cast=84,
	op_inc=88,
	op_dec=92,
	op_memcpy=96,
	op_memcpyx=100,
	op_outevt_c=104,
	op_outevt_v=108,
	op_outevtx_v=112,
	op_exec=116,
	op_memclr=120,
	op_ifelse=124,
	op_trg=128,
	op_tkins_z=132,
	op_tkclr=136,
	op_chkret=140,
	op_asen=144,
	op_tkins_max=148,
	
	
	op_clken_c=160,
	op_clken_ve=176,
	op_set16_c=192,
	op_set8_v=208,
	op_set16_v=224,
	op_set32_v=240,

};

// VM input event structure
typedef struct evtData{
	uint8_t evtId;
	uint8_t auxId;
	void* data;
} evtData_t;

#endif /* TERRA_VM_H */
