#include "kissFFTConfig.h"
#include "bayes_model.h"
#include "kissFFT.h"

int bandwidth = SAMPLING_RATE / FEATURE_DIM / 2;

/* Mahalanobis distance */
float mahalanobis_distance(float x[FEATURE_DIM], nx_float m[FEATURE_DIM], nx_float inverse_cov[FEATURE_DIM])
{
     float result = 0;
     int i;

     for(i = 0; i < FEATURE_DIM; i++) {
	  result += (x[i] - m[i]) * (x[i] - m[i]) * inverse_cov[i];
     }

     return result;
}

uint8_t detect(ms_gauss_model *gModel, int scale, kiss_fft_cpx* out_data)
{

     float feature[FEATURE_DIM];
     float d0, d1;
     float spectrum[SAMPLING_RATE/2];
     float sum_energy = 0;
     int i;
     
     // ignore the DC part
     for(i = 1; i <= SAMPLING_RATE/2; i++) {
	  spectrum[i-1] = out_data[i].r * out_data[i].r + out_data[i].i * out_data[i].i;
	  sum_energy += spectrum[i-1];
     }
     for(i = 0; i < SAMPLING_RATE/2; i++) {
	  //spectrum[i] /= sum_energy;
	  spectrum[i] = 100 * spectrum[i] / sum_energy; // unit is percentage
     }

     // extract the feature
     for(i = 0; i < FEATURE_DIM; i++) {
	  feature[i] = 0;
     }
     for(i = 0; i < SAMPLING_RATE/2; i++) {
	  feature[(int)(i / bandwidth)] += spectrum[i];
     }
     d0 = lnP0 - 0.5F * gModel->h0_ln_det  	  - 0.5F * mahalanobis_distance(feature, gModel->h0_mean,     gModel->h0_inverse_cov    );
     d1 = lnP1 - 0.5F * gModel->ln_det[scale] - 0.5F * mahalanobis_distance(feature, gModel->mean[scale], gModel->inverse_cov[scale]);

     if(d1 > d0) return 1;

     return 0;
}


