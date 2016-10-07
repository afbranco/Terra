#include "kissFFT.h"

interface kissFFT{

	command uint8_t kiss_fftr_alloc(int nfft,int inverse_fft,void * mem, size_t * lenmem);
	command void kiss_fftr(kiss_fftr_cfg cfg,const kiss_fft_scalar *timedata,kiss_fft_cpx *freqdata);
	
}