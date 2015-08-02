/* Arduino Sd2Card Library
 * Copyright (C) 2009 by William Greiman
 *
 * This file is part of the Arduino Sd2Card Library
 *
 * This Library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This Library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Arduino Sd2Card Library.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
#ifndef Sd2Card_h
#define Sd2Card_h
/**
 * \file
 * Sd2Card class
 */

#include "SdInfo.h"


/** Set SCK to max rate of F_CPU/2. See Sd2Card::setSckRate(). */
uint8_t const SPI_FULL_SPEED = 0;
/** Set SCK rate to F_CPU/4. See Sd2Card::setSckRate(). */
uint8_t const SPI_HALF_SPEED = 1;
/** Set SCK rate to F_CPU/8. Sd2Card::setSckRate(). */
uint8_t const SPI_QUARTER_SPEED = 2;
/**
 * Define MEGA_SOFT_SPI non-zero to use software SPI on Mega Arduinos.
 * Pins used are SS 10, MOSI 11, MISO 12, and SCK 13.
 *
 * MEGA_SOFT_SPI allows an unmodified Adafruit GPS Shield to be used
 * on Mega Arduinos.  Software SPI works well with GPS Shield V1.1
 * but many SD cards will fail with GPS Shield V1.0.
 */
#define MEGA_SOFT_SPI 0
//------------------------------------------------------------------------------
#if MEGA_SOFT_SPI && (defined(__AVR_ATmega1280__)||defined(__AVR_ATmega2560__))
#define SOFTWARE_SPI
#endif  // MEGA_SOFT_SPI
//------------------------------------------------------------------------------
// SPI pin definitions
//
#ifndef SOFTWARE_SPI
// hardware pin defs
/**
 * SD Chip Select pin
 *
 * Warning if this pin is redefined the hardware SS will pin will be enabled
 * as an output by init().  An avr processor will not function as an SPI
 * master unless SS is set to output mode.
 */
/** The default chip select pin for the SD card is SS. */
//uint8_t const  SD_CHIP_SELECT_PIN = SS_PIN;
// The following three pins must not be redefined for hardware SPI.
/** SPI Master Out Slave In pin */
//uint8_t const  SPI_MOSI_PIN = MOSI_PIN;
/** SPI Master In Slave Out pin */
//uint8_t const  SPI_MISO_PIN = MISO_PIN;
/** SPI Clock pin */
//uint8_t const  SPI_SCK_PIN = SCK_PIN;
/** optimize loops for hardware SPI */
#define OPTIMIZE_HARDWARE_SPI

#else  // SOFTWARE_SPI
// define software SPI pins so Mega can use unmodified GPS Shield
/** SPI chip select pin */
uint8_t const SD_CHIP_SELECT_PIN = 10;
/** SPI Master Out Slave In pin */
uint8_t const SPI_MOSI_PIN = 11;
/** SPI Master In Slave Out pin */
uint8_t const SPI_MISO_PIN = 12;
/** SPI Clock pin */
uint8_t const SPI_SCK_PIN = 13;
#endif  // SOFTWARE_SPI
//------------------------------------------------------------------------------
/** Protect block zero from write if nonzero */
#define SD_PROTECT_BLOCK_ZERO 0
/** init timeout ms */
uint16_t const SD_INIT_TIMEOUT = 10000;//2000;
/** erase timeout ms */
uint16_t const SD_ERASE_TIMEOUT = 5000;//10000;
/** read timeout ms */
uint16_t const SD_READ_TIMEOUT = 1000;//300;
/** write time out ms */
uint16_t const SD_WRITE_TIMEOUT = 5000;//600;
//------------------------------------------------------------------------------
// SD card errors
/** timeout error for command CMD0 */
uint8_t const SD_CARD_ERROR_CMD0 = 0X1;
/** CMD8 was not accepted - not a valid SD card*/
uint8_t const SD_CARD_ERROR_CMD8 = 0X2;
/** card returned an error response for CMD17 (read block) */
uint8_t const SD_CARD_ERROR_CMD17 = 0X3;
/** card returned an error response for CMD24 (write block) */
uint8_t const SD_CARD_ERROR_CMD24 = 0X4;
/**  WRITE_MULTIPLE_BLOCKS command failed */
uint8_t const SD_CARD_ERROR_CMD25 = 0X05;
/** card returned an error response for CMD58 (read OCR) */
uint8_t const SD_CARD_ERROR_CMD58 = 0X06;
/** SET_WR_BLK_ERASE_COUNT failed */
uint8_t const SD_CARD_ERROR_ACMD23 = 0X07;
/** card's ACMD41 initialization process timeout */
uint8_t const SD_CARD_ERROR_ACMD41 = 0X08;
/** card returned a bad CSR version field */
uint8_t const SD_CARD_ERROR_BAD_CSD = 0X09;
/** erase block group command failed */
uint8_t const SD_CARD_ERROR_ERASE = 0X0A;
/** card not capable of single block erase */
uint8_t const SD_CARD_ERROR_ERASE_SINGLE_BLOCK = 0X0B;
/** Erase sequence timed out */
uint8_t const SD_CARD_ERROR_ERASE_TIMEOUT = 0X0C;
/** card returned an error token instead of read data */
uint8_t const SD_CARD_ERROR_READ = 0X0D;
/** read CID or CSD failed */
uint8_t const SD_CARD_ERROR_READ_REG = 0X0E;
/** timeout while waiting for start of read data */
uint8_t const SD_CARD_ERROR_READ_TIMEOUT = 0X0F;
/** card did not accept STOP_TRAN_TOKEN */
uint8_t const SD_CARD_ERROR_STOP_TRAN = 0X10;
/** card returned an error token as a response to a write operation */
uint8_t const SD_CARD_ERROR_WRITE = 0X11;
/** attempt to write protected block zero */
uint8_t const SD_CARD_ERROR_WRITE_BLOCK_ZERO = 0X12;
/** card did not go ready for a multiple block write */
uint8_t const SD_CARD_ERROR_WRITE_MULTIPLE = 0X13;
/** card returned an error to a CMD13 status check after a write */
uint8_t const SD_CARD_ERROR_WRITE_PROGRAMMING = 0X14;
/** timeout occurred during write programming */
uint8_t const SD_CARD_ERROR_WRITE_TIMEOUT = 0X15;
/** incorrect rate selected */
uint8_t const SD_CARD_ERROR_SCK_RATE = 0X16;
//------------------------------------------------------------------------------
// card types
/** Standard capacity V1 SD card */
uint8_t const SD_CARD_TYPE_SD1 = 1;
/** Standard capacity V2 SD card */
uint8_t const SD_CARD_TYPE_SD2 = 2;
/** High Capacity SD card */
uint8_t const SD_CARD_TYPE_SDHC = 3;
//------------------------------------------------------------------------------

#endif  // Sd2Card_h
