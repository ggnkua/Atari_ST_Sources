/*      LIMITS.H

        Sizes of integral types

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __LIMITS )
#define __LIMITS

#define  CHAR_BIT            8
#define  SCHAR_MIN       (-128)
#define  SCHAR_MAX         127
#define  UCHAR_MAX         255U
#if ('\x80' < 0)
#define  CHAR_MIN        (-128)
#define  CHAR_MAX          127
#else
#define  CHAR_MIN          0
#define  CHAR_MAX          255
#endif
#define  MB_LEN_MAX          1
#define  SHRT_MIN      (-32767-1)
#define  SHRT_MAX        32767
#define  USHRT_MAX       65535U
#define  INT_MIN       (-32767-1)
#define  INT_MAX         32767
#define  UINT_MAX        65535U
#define  LONG_MIN (-2147483647L-1)
#define  LONG_MAX   2147483647L
#define  ULONG_MAX  4294967295LU

#endif

/************************************************************************/
