#ifndef __STDINT__H__
#define __STDINT__H__ 1

#include <stddef.h>

#if defined(__PUREC__) && defined(__STDDEF)
typedef signed char             int8_t;
typedef short int               int16_t;
typedef long int                int32_t;
typedef unsigned char           uint8_t;
typedef unsigned short int      uint16_t;
typedef unsigned long int       uint32_t;
typedef unsigned long int       uintptr_t;
#define UINT32_C(c)    c ## UL
#ifndef __ORDER_BIG_ENDIAN__
#define __ORDER_LITTLE_ENDIAN__	1234
#define	__ORDER_BIG_ENDIAN__	4321
#define	__ORDER_PDP_ENDIAN__	3412
#define __BYTE_ORDER__ __ORDER_BIG_ENDIAN__
#endif
#else
#include <stdint.h>
#endif

#endif
