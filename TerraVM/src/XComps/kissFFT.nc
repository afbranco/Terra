#include "kissFFT.h"

interface kissFFT{

	command uint8_t kiss_fftr_alloc(nx_uint16_t nfft,nx_uint16_t inverse_fft,uint8_t * mem, nx_uint16_t * lenmem);
	command void kiss_fftr(kiss_fftr_cfg cfg,const kiss_fft_scalar *timedata,kiss_fft_cpx *freqdata);
	
}