#ifndef _ATM2560_SPI_H_
#define _ATM2560_SPI_H_

// Note: the SPI clock divisors are halved if double-speed is enabled
typedef enum
{
  ATM2560_SPI_CLOCK_DIV_4   = 0,
  ATM2560_SPI_CLOCK_DIV_16  = 1,
  ATM2560_SPI_CLOCK_DIV_64  = 2,
  ATM2560_SPI_CLOCK_DIV_128 = 3,
} atm2560_spi_clock_div_t;

#define UQ_SPI "atm2560.spi"

#endif
