#include "kissFFTConfig.h"


  /* the following average algorithm is not real-time, and hence might overflow when the raw data is big.
   * But the raw data are around 300, the sum of a hundred of raw data would not exceeds the range of int32_t.
   * To avoid overflow issue, we can first remove a value (e.g., the first datum) from all raw data. Here,
   * we don't handle this to accelerate the execution
   */
uint32_t intensityMean(nx_int32_t* data,uint16_t count, nx_uint16_t* valid_countp){
	uint16_t i;
	uint32_t intensity_mean = 0;
	uint16_t valid_count = 0;
	for(i = 0; i < count; i++) {
		if(*(nx_int32_t*)(data+i) != INVALID_MEASUREMENT) {
  			intensity_mean += *(nx_int32_t*)(data+i);
  			valid_count ++;
		}
  	}
  	*(nx_uint16_t*)valid_countp = valid_count;
	return (valid_count>0)?(intensity_mean/valid_count):0;
}


uint32_t seismicEnergy(nx_uint32_t* data, uint16_t count, uint32_t intensity_mean){
	uint32_t sum_sq = 0;
	uint16_t i;
	uint16_t valid_count=0;
	int32_t buf1;
	for(i = 0; i < count; i++) {
		if(*(nx_int32_t*)(data+i) != INVALID_MEASUREMENT) {
			buf1 = *(nx_int32_t*)(data+i) - intensity_mean;
			sum_sq += buf1 * buf1;
			valid_count++;
		}
	}
	return (valid_count>0)?(sum_sq / valid_count):0;
}


typedef nx_struct  buffer_pool_reg_ {
	nx_uint8_t avail_map[POOL_LEN];
	nx_uint8_t scale[POOL_LEN];
	nx_uint16_t count[POOL_LEN];
	nx_uint32_t rtime_map[POOL_LEN];
//	nx_int32_t  data[POOL_LEN*BUFFER_LEN];
}  buffer_pool_reg;

// copy the data to buffer pool
void copyBufferPool(buffer_pool_reg* buffer_pool_pars,uint16_t count,nx_int32_t* data, int32_t intensity_mean, uint8_t scale, uint32_t rtime){	
	int8_t oldest_index;	
	uint8_t i,j;
	uint16_t pos;
	
	oldest_index = -1;
	
	for(i = 0; i < POOL_LEN; i++) {
		if(*(nx_uint8_t*)(buffer_pool_pars->avail_map+i)) {
			for(j = 0; j < count; j++) {
				buffer_pool[i][j] = 0;
				if (*(nx_int32_t*)(data+j) != INVALID_MEASUREMENT){ 
					buffer_pool[i][j] = *(nx_int32_t*)(data+j) - intensity_mean;
				}
			}
			*(nx_uint8_t*)(buffer_pool_pars->scale+i) = scale;
			*(nx_uint16_t*)(buffer_pool_pars->count+i) = count;
			*(nx_uint32_t*)(buffer_pool_pars->rtime_map+i) = rtime;
			*(nx_uint8_t*)(buffer_pool_pars->avail_map+i) = FALSE;
			break;

		} else {

			if(oldest_index == -1) 
				oldest_index = i;
			else 
				oldest_index = (*(nx_uint32_t*)(buffer_pool_pars->rtime_map+i) < *(nx_uint32_t*)(buffer_pool_pars->rtime_map+oldest_index)) ? i : oldest_index;

		}
	}
	//if (oldest_index == -1) oldest_index = i;
	if(i >= POOL_LEN) {
		for(j = 0; j < count; j++) {
			buffer_pool[oldest_index][j] = 0;
			if (*(nx_int32_t*)(data+j) != INVALID_MEASUREMENT){ 
				buffer_pool[oldest_index][j] = *(nx_int32_t*)(data+j) - intensity_mean;
			}
		}
		*(nx_uint8_t*)(buffer_pool_pars->scale+oldest_index) = scale;
		*(nx_uint16_t*)(buffer_pool_pars->count+oldest_index) = count;
		*(nx_uint32_t*)(buffer_pool_pars->rtime_map+oldest_index) = rtime;
		*(nx_uint8_t*)(buffer_pool_pars->avail_map+oldest_index) = FALSE;
	}
}



 