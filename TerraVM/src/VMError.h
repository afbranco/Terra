#ifndef VMERROR_H
#define VMERROR_H

enum {
	
// Event ID only for System Error (from VMCustom*.h)
	I_ERROR_ID		=0,
	I_ERROR			=1,

// VM Error codes

	E_DIVZERO 	= 10, // Division by zero
	E_IDXOVF 	= 11, // Array index overflow
	E_TIMEOVF 	= 12, // await time above the maximum (about 24.8 days), clamped (#47)
	E_STKOVF 	= 20, // Stack overflow
	E_NOSETUP 	= 21, // Missing operation setup

};

#endif /* VMERROR_H */
