#ifndef KISS_FFTCONFIG_H
#define KISS_FFTCONFIG_H

/* FFT settings */
#define FIXED_POINT 32 // use 32bit integer FFT. To use float version, comment this line
#define USE_ARITH_FUNC // use functions instead of macros to reduce code size, but a bit increase of execution time (less than 10ms on telosb)
/* FFT end */

#define SAMPLING_RATE 100 // 100 Hz
//#define SAMPLING_PERIOD 1500 // in millisecond
#define BUFFER_LEN 128//128 // maximum supported sampling rate: 128 Hz
#define POOL_LEN 5
#define BUFFER_POOL_LEN 640 //640 // 640=5 * 128
#define INVALID_MEASUREMENT -2147483648 // invalid measurement in data trace
#define NSENSOR 12 // the maximum possible number of sensors
#define BS_NODE 0 // base station

#define FEATURE_DIM 10 /* feature dimension is 10 */
#define MS_GAUSS_SCALES 10

/* the distribution with support of less than 30 samples will be ignored */
/* according to probability theory, a distribution should have more than 30 samples
 * to achieve satisfactory statistical significance
 */
#define STAT_SIGNIFICANCE 30

/* prior probabilities */
#define P0 (1.0 - 1e-4)
#define P1 (1e-4)
#define lnP0 -0.000100005F // hard coded ln(P0)
#define lnP1 -9.210340372F // hard coded ln(P1)

#endif /* KISS_FFTCONFIG_H */

