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
	EVT_QUEUE_SIZE = 3,
#else
	EVT_QUEUE_SIZE = 5,
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
	
	// OpCodes
	op_nop=0,
	op_end=1,
	op_return=2,
	op_sub=3,
	op_add=4,
	op_mod=5,
	op_mult=6,
	op_div=7,
	op_bor=8,
	op_band=9,
	op_lshft=10,
	op_rshft=11,
	op_bxor=12,
	op_eq=13,
	op_neq=14,
	op_gte=15,
	op_lte=16,
	op_gt=17,
	op_lt=18,
	op_lor=19,
	op_land=20,
	op_bnot=21,
	op_lnot=22,
	op_neg=23,
	op_cast=24,
	
	
	
	op_push_c=28,
	
	op_push_v=36,
	
	op_pushx_v=44,
	
	op_push_p=52,
	
	op_pushx_p=60,
	op_pusharr_v=64,
	op_poparr_v=68,
	
	op_pop=76,
	
	op_popx=84,
	
	
	op_setarr_vc=96,
	op_setarr_vv=100,
	op_memclr=104,
	op_getextdt_p=108,
	op_getextdt_v=112,
	
	op_chkret=120,
	op_exec=124,
	op_ifelse=128,
	op_outevt_c=132,
	op_outevt_v=136,
	op_outevtx_c=140,
	op_outevtx_v=144,
	op_outevt_z=148,
	op_tkclr=152,
	op_trg=156,
	op_set_c=160,
	op_set_v=176,
	op_clken_c=192,
	op_clken_v=208,
	op_tkins_max=224,
	op_tkins_z=240,

};

// VM input event structure
typedef struct evtData{
	uint8_t evtId;
	void* data;
} evtData_t;

#endif /* TERRA_VM_H */
