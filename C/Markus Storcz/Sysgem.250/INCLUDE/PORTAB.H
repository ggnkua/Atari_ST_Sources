/* ------------------------------------------------------------------- *
 * Module Name          : portab.h                                     *
 * Module Version       : 1.00                                         *
 * ------------------------------------------------------------------- */

#ifndef __PORTAB__
#define __PORTAB__

/* -------------------------------------------------------------------
 * Systemspezifisches
 * ------------------------------------------------------------------- */

#define _(x)	x

/* -------------------------------------------------------------------
 * Boolean
 * ------------------------------------------------------------------- */

#define FALSE	0
#define TRUE	1

/* -------------------------------------------------------------------
 * Typen
 * ------------------------------------------------------------------- */

#define BOOL	int
#define BYTE    unsigned char
#define CHAR	signed   char
#define UCHAR   unsigned char
#define UBYTE   unsigned char

#define INT     int
#define SHORT	short

#define UINT    unsigned int
#define USHORT	unsigned short

#define LONG    signed   long
#define ULONG   unsigned long

#define SIZE_T	unsigned long
#define BOOLEAN BOOL

#define FLOAT   float
#define DOUBLE  double
#define WORD    INT
#define UWORD   UINT

#define REG     register
#define EXTERN  extern
#define CDECL   cdecl
#define LOCAL   static
#define GLOBAL
#define VOID    void
#define CONST   const

#ifndef NULL
#define NULL    ((void *)0L)
#endif

/* -------------------------------------------------------------------
 * wegen portab von Geiû fÅr vdi.h und aes.h													
 * ------------------------------------------------------------------- */

#define GEM1       0x0001               /* ATARI GEM version           */
#define GEM        GEM1                 /* GEMDOS default is GEM1      */
#define NEAR                            /* Near pointer                */
#define FAR                             /* Far pointer                 */
#define HUGE                            /* Huge pointer                */

/* -------------------------------------------------------------------
 * Funktionen
 * ------------------------------------------------------------------- */

#define assign(x,y)     strcpy(y,x)
#define append(x,y)     strcat(y,x)
#define length(x)       (INT)strlen(x)

/* ------------------------------------------------------------------- */

#define forever         while(1)

/* ------------------------------------------------------------------- */

#define incl(x,y)       (x |= y)
#define excl(x,y)       (x &= ~y)

/* ------------------------------------------------------------------- */

#define min(a,b)        (((a) < (b)) ? (a) : (b))
#define max(a,b)        (((a) > (b)) ? (a) : (b))

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */


