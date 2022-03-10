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
 * Boolean
 * ------------------------------------------------------------------- */

#ifndef TRUE
#define TRUE    1
#endif

#ifndef FALSE
#define FALSE   0
#endif

#define ON	1
#define OFF	0

/* -------------------------------------------------------------------
 * Typen
 * ------------------------------------------------------------------- */

#define BYTE    unsigned char
#define UBYTE   unsigned char
#define INT     int
#define UINT    unsigned int
#define LONG    long
#define ULONG   unsigned long
#define BOOL    int
#define FLOAT   float
#define DOUBLE  double
#define WORD    int
#define UWORD   unsigned int

#define REG     register
#define EXTERN  extern
#define CDECL   cdecl
#define LOCAL   static
#define GLOBAL
#define VOID    void
#define PASCAL  pascal
#define CONST   const

#ifndef NULL
#define NULL    ((void *)0L)
#endif

/* -------------------------------------------------------------------
 * Funktionen
 * ------------------------------------------------------------------- */

#define CICONBLK	BYTE
#define CICON		BYTE

/* ------------------------------------------------------------------- */

#define assign(x,y)     strcpy(y,x)
#define append(x,y)     strcat(y,x)
#define length(x)       (int)strlen(x)
#define forever         while(1)
#define incl(x,y)       (x |= y)
#define excl(x,y)       (x &= ~y)
#define min(a,b)        (( a < b ) ? a : b )
#define max(a,b)        (( a > b ) ? a : b )

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */


