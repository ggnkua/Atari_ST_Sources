/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#ifndef __nkcc__
#define __nkcc__

/* ------------------------------------------------------------------- */

#include	<portab.h>

/* ------------------------------------------------------------------- */

int 	nkc_init	(unsigned long flags,int vdihnd,int *pglobal);
int 	nkc_exit	(void);
int 	nkc_tconv	(long toskey);
int 	nkc_gconv	(int gemkey);
long 	nkc_n2tos	(int nkcode);
int 	nkc_n2gem	(int nkcode);
UBYTE   nkc_toupper	(unsigned char chr);
UBYTE   nkc_tolower	(unsigned char chr);

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */
