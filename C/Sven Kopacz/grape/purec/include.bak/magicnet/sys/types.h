/*  types.h

    Types for dealing with time.

*/

/* $Copyright: 1987$ */

#if !defined(__TYPES_H)
#define __TYPES_H

#ifndef  _TIME_T
#define  _TIME_T
typedef long time_t;
#endif

#if defined(__FLAT__)
typedef short dev_t;
typedef short ino_t;
typedef short mode_t;
typedef short nlink_t;
typedef int   uid_t;
typedef int   gid_t;
typedef long  off_t;

#endif  /* __FLAT__ */

/*
 *   Data types used throughout STinG
 */
#if defined(__MAGIC__) 
typedef          char  int8;          /*   Signed  8 bit (char)             */
typedef unsigned char u_char;          /* Unsigned  8 bit (byte, octet)      */
typedef          int   int16;         /*   Signed 16 bit (int)              */
typedef unsigned int  u_short;         /* Unsigned 16 bit (word)             */
typedef          long  int32;         /*   Signed 32 bit                    */
typedef unsigned long u_long;         /* Unsigned 32 bit (longword)         */

#endif	/* __MAGIC__ */
#endif  /* __TYPES_H */

