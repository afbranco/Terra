#ifndef UDPACTIVE_MESSAGE_H
#define UDPACTIVE_MESSAGE_H
  
//#include "espconn.h"

#define MAX_LENGTH 256
#define PORT 5000
#define GROUP "224.0.2.1"
//#define GROUP "255.255.255.255"
#define GROUP_BYTES {224,0,2,1}
//#define GROUP_BYTES {255,255,255,255}

#define SENDDONE_WAITTIME 100
#define ACK_TRUE 1
#define ACK_FALSE 0

#ifndef WIFI_SSID
#define WIFI_SSID "iot_terra"
#endif

#ifndef WIFI_PASSWORD
#define WIFI_PASSWORD "projeto_terra"
#endif

#endif /* UDPACTIVE_MESSAGE_H */
