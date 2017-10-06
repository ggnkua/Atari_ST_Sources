/* ------------------------------------------------------------------- *
 * Module Name          : portab.h                                     *
 * Module Version       : 1.00                                         *
 * Module Date          : 04-09-93                                     *
 * Last Change          : 04-09-93                                     *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1993, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#ifndef __PORTAB__
#define __PORTAB__

/* -------------------------------------------------------------------
 * Systemspezifisches
 * ------------------------------------------------------------------- */

#define	GEMDOS  1
#define WINAPI
#define _(x)	x

/* -------------------------------------------------------------------
 * Boolean
 * ------------------------------------------------------------------- */

#ifndef TRUE
#define TRUE    1
#endif

#ifndef FALSE
#define FALSE   0
#endif

/* -------------------------------------------------------------------
 * Typen
 * ------------------------------------------------------------------- */

#define NEAR
#define FAR
#define HUGE

#define BYTE    unsigned char
#define CHAR	char
#define UCHAR   unsigned char
#define UBYTE   unsigned char
#define INT     int
#define SHORT	int
#define UINT    unsigned int
#define USHORT	unsigned int
#define LONG    long
#define ULONG   unsigned long
#define SIZE_T	unsigned long
#define BOOL    int
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
 * Funktionen
 * ------------------------------------------------------------------- */

#define assign(x,y)     strcpy(y,x)
#define append(x,y)     strcat(y,x)
#define length(x)       (INT)strlen(x)
#define forever         while(1)
#define incl(x,y)       (x |= y)
#define excl(x,y)       (x &= ~y)
#define min(a,b)        (((a) < (b)) ? (a) : (b))
#define max(a,b)        (((a) > (b)) ? (a) : (b))
#define btst(x,y)	(( x & y ) != 0 )

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */


