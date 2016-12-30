#if !defined(__CYGWIN__)
#if defined(__MSP430__)
#include <sys/inttypes.h>
#else
#include <inttypes.h>
#endif
#else //cygwin
#define _HAVE_STDC	// hack to force the definition _EXFNPTR under cygwin
#undef _ANSIDECL_H_	// which is used in reent.h
#include <unistd.h>	// reload _ansi.h
#include <stdio.h>
#include <sys/types.h>
#endif

#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stddef.h>
#include <ctype.h>

/* TEMPORARY: include the Safe TinyOS macros so that annotations get
 * defined away for non-safe users */
//#include "../lib/safe/include/annots_stage1.h" // afb - commented

typedef uint8_t bool;
enum { FALSE = 0, TRUE = 1 };

typedef nx_int8_t nx_bool;
#ifndef TERRA_NODE_ID
#define TERRA_NODE_ID 1
#endif
uint16_t TOS_NODE_ID = TERRA_NODE_ID;

/* This macro is used to mark pointers that represent ownership
   transfer in interfaces. See TEP 3 for more discussion. */
#define PASS

#ifdef NESC
struct @atmostonce { };
struct @atleastonce { };
struct @exactlyonce { };
#endif

/* This platform_bootstrap macro exists in accordance with TEP
   107. A platform may override this through a platform.h file. */
#include <platform.h>
#ifndef platform_bootstrap
#define platform_bootstrap() {}
#endif

#if defined(TOSSIM)

#elif defined(LINUX)
extern void dbgIx(char* canal, char* format, ...);
#ifndef NO_DEBUG
#define dbg dbgIx
#define dbg_clear dbgIx 
#define dbgerror dbgIx 
#define dbgerror_clear dbgIx 
#else
#define dbg(s, ...) 
#define dbg_clear(s, ...) 
#define dbgerror dbgIx 
#define dbgerror_clear dbgIx 
#endif
#else
#define dbg(s, ...) 
#define dbgerror(s, ...) 
#define dbg_clear(s, ...) 
#define dbgerror_clear(s, ...) 
#endif

