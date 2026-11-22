#ifndef KISS_FFT_H
#define KISS_FFT_H

/****
 * Include pre-configuration
 */
#include "kissFFTConfig.h"

/********************************************************
 * definitions
 *******************************************************/

#ifdef FIXED_POINT
# if (FIXED_POINT == 32)
#  define kiss_fft_scalar int32_t
# else	
#  define kiss_fft_scalar int16_t
# endif
#else
# ifndef kiss_fft_scalar
/*  default is float */
#   define kiss_fft_scalar float
# endif
#endif

#define MAXFACTORS 32

/******************************************************************
 * types
 *****************************************************************/

typedef struct {
    kiss_fft_scalar r;
    kiss_fft_scalar i;
}kiss_fft_cpx;

struct kiss_fft_state{
    int nfft;
    int inverse;
    int factors[2*MAXFACTORS];
    kiss_fft_cpx twiddles[1];
};

typedef struct kiss_fft_state* kiss_fft_cfg;

typedef struct kiss_fftr_state *kiss_fftr_cfg;

struct kiss_fftr_state{
    kiss_fft_cfg substate;
    kiss_fft_cpx * tmpbuf;
    kiss_fft_cpx * super_twiddles;
};


#endif /* KISS_FFT_H */
