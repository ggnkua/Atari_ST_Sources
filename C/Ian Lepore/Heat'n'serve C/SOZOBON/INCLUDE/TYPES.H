#pragma idempotent

/*
 *  TYPES.H
 */

#ifndef _TYPES_H
#define _TYPES_H

#ifndef VOID
  #define VOID    void
#endif

typedef unsigned char   BYTE;       /* 8-bit unsigned */
typedef unsigned int    WORD;       /* 16-bit unsigned */
typedef unsigned long   LONG;       /* 32-bit unsigned */

typedef unsigned char   uchar;      /* 8-bit unsigned */
typedef unsigned short  ushort;     /* 16-bit unsigned */
typedef unsigned int    uint;       /* 16-bit unsigned */
typedef unsigned long   ulong;      /* 32-bit unsigned */

typedef unsigned char   u_char;     /* 8-bit unsigned */
typedef unsigned short  u_short;    /* 16-bit unsigned */
typedef unsigned int    u_int;      /* 16-bit unsigned */
typedef unsigned long   u_long;     /* 32-bit unsigned */

typedef unsigned char   dev_t;      /* device (drive) id */
typedef unsigned long   fpos_t;     /* file position offset */

#ifndef _TIME_T_DEFINED
  #define _TIME_T_DEFINED
  typedef unsigned long   time_t;   /* raw date/time */
#endif

#ifndef _CLOCK_T_DEFINED
  #define _CLOCK_T_DEFINED
  typedef unsigned long   clock_t;  /* 200Hz clock ticks */
#endif

#endif _TYPES_H
