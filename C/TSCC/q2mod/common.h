#ifndef __common_h__
#define __common_h__

// Includes /*fold00*/
#include <netinet/in.h>

// define conversion /*fold00*/
#define X16(val) (ntohs(val))
#define X32(val) (ntohl(val))

#define Y16(val) (htons(val))
#define Y32(val) (htonl(val))

#endif /*FOLD00*/
