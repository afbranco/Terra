#ifndef BAYES_MODEL_H
#define BAYES_MODEL_H

#include "kissFFTConfig.h"

/* multi-scale Gaussian model */
typedef nx_struct  ms_gauss_model_
{
     /* for H0 */
     nx_float h0_mean[FEATURE_DIM];
     nx_float h0_ln_det; // ln(|C|)
     nx_float h0_inverse_cov[FEATURE_DIM];

     /* for H1 */
     nx_int32_t nsample[MS_GAUSS_SCALES]; // the number of samples for each scale
     nx_float mean[MS_GAUSS_SCALES][FEATURE_DIM]; // the mean vector for each scale
     nx_float ln_det[MS_GAUSS_SCALES]; // ln(|C|)
     nx_float inverse_cov[MS_GAUSS_SCALES][FEATURE_DIM];
} ms_gauss_model;
#endif
