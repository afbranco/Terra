#ifndef __MESSAGE_H__
#define __MESSAGE_H__

#include "platform_message.h"

#ifndef TOSH_DATA_LENGTH
#define TOSH_DATA_LENGTH 28
#endif

#ifndef TOS_BCAST_ADDR
#define TOS_BCAST_ADDR 0xFFFF
#endif

#if defined(INOX)

typedef nx_struct message_t {
  nx_uint16_t target;
  nx_uint16_t source;
  nx_uint8_t len;
  nx_uint8_t group;
  nx_uint8_t amid;
  nx_uint8_t opt;
  nx_uint8_t rssi;
  nx_uint8_t metadata;
  nx_uint8_t data[TOSH_DATA_LENGTH];
} message_t;

#elif defined(INOS)
typedef nx_struct message_t {
  nx_uint8_t header[sizeof(message_header_t)];
  nx_uint8_t data[TOSH_DATA_LENGTH];
  nx_uint8_t footer[sizeof(message_footer_t)];
  nx_uint8_t metadata[sizeof(message_metadata_t)];
} message_t;
#endif
/*
 * This resource is used to arbitrate access between ActiveMessageC,
 * Ieee154MessageC and possibly future MessageC components to the 
 * underlying radio driver.
 */
#define RADIO_SEND_RESOURCE "RADIO_SEND_RESOURCE"

#endif
