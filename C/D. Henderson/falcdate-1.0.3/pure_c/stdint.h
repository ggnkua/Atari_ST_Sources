/*
 *  ISO C99: Integer types <stdint.h> for Pure C
 *  based on stdint.h from GCC
 *
 *  adapted to Pure C by Simon Sunnyboy / Paradize <marndt@asmsoftware.de>
 *
 *  limitations: no 64 bit datatypes
 */  
  
#ifndef __PUREC__
#error Pure C only!
#endif   /* 
	  */
  
#ifndef _STDINT_H
#define _STDINT_H   1
  
/* Exact integral types */ 
  
/* Signed.  */ 
typedef signed char int8_t;
typedef int int16_t;
typedef long int32_t;
  
/* Unsigned.  */ 
typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;

/* Small types.  */ 
/* Signed.  */ 
typedef int8_t int_least8_t;
typedef int16_t int_least16_t;
typedef int32_t int_least32_t;

/* Unsigned.  */ 
typedef uint8_t uint_least8_t;
typedef uint16_t uint_least16_t;
typedef uint32_t uint_least32_t;

/* Fast types.  */ 
  
/* Signed.  */ 
typedef int int_fast8_t;
typedef int int_fast16_t;
typedef long int_fast32_t;

/* Unsigned.  */ 
typedef unsigned int uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned int uint_fast32_t;

/* Types for `void *' pointers.  */ 
typedef int intptr_t;
typedef unsigned int uintptr_t;

/* Limits of integral types.  */ 
  
/* Minimum of signed integral types.  */ 
# define INT8_MIN      (-128)
# define INT16_MIN      (-32767-1)
# define INT32_MIN      (-2147483647-1)
/* Maximum of signed integral types.  */ 
# define INT8_MAX      (127)
# define INT16_MAX      (32767)
# define INT32_MAX      (2147483647)
  
/* Maximum of unsigned integral types.  */ 
# define UINT8_MAX      (255)
# define UINT16_MAX      (65535)
# define UINT32_MAX      (4294967295U)
  
/* Minimum of signed integral types having a minimum size.  */ 
# define INT_LEAST8_MIN      INT8_MIN
# define INT_LEAST16_MIN   INT16_MIN
# define INT_LEAST32_MIN   INT32_MIN
/* Maximum of signed integral types having a minimum size.  */ 
# define INT_LEAST8_MAX      INT8_MAX
# define INT_LEAST16_MAX   INT16_MAX
# define INT_LEAST32_MAX   INT32_MAX
  
/* Maximum of unsigned integral types having a minimum size.  */ 
# define UINT_LEAST8_MAX   (255)
# define UINT_LEAST16_MAX   (65535)
# define UINT_LEAST32_MAX   (4294967295U)
  
/* Minimum of fast signed integral types having a minimum size.  */ 
#  define INT_FAST8_MIN      INT8_MIN
#  define INT_FAST16_MIN   INT16_MIN
#  define INT_FAST32_MIN   INT32_MIN
  
/* Maximum of fast signed integral types having a minimum size.  */ 
# define INT_FAST8_MAX      (127)
# define INT_FAST16_MAX     (32767)
# define INT_FAST32_MAX     (2147483647)
  
/* Maximum of fast unsigned integral types having a minimum size.  */ 
# define UINT_FAST8_MAX      (255)
  
#  define INTPTR_MIN      INT16_MIN
#  define INTPTR_MAX      INT16_MAX
#  define UINTPTR_MAX      UINT16_MAX
  
#  define SIZE_MAX      (4294967295U)
  
#endif   /* stdint.h */
