/* 
 * Real Math. Library
 * 
 * Copyright (C) 1984, 1987, 1988 IMAGEN Corporation
 *
 * $Log:	areal.h,v $
 * Revision 1.2  88/06/01  19:22:23  djk
 * Release: fsm2
 * 
 * Revision 1.1  88/06/01  18:44:02  djk
 * Interface for Atari
 * 
 * Revision 1.1  88/04/18  15:27:28  djk
 * Initial revision
 * 
 * 
 */

/*
 * 07/05/88 Changed REAL_ZERO (etc.) to longs.
 */

typedef long	 real;

/*
 * Constants in real
 */
#define REAL_ZERO	0L
#define REAL_ONE	0x10000L
#define REAL_TWO	0x20000L
#define REAL_NEG_ONE	0xffff0000L
#define REAL_ALMOST1	0x0000ffffL
#define REAL_HALF	0x08000L
#define	REAL_1000	(1000<<16)L
#define REAL_PI		0x3243fL
#define REAL_BIG	0x7fffffffL                   /* largest real number */

/*
 * Conversions to/from other types.
 * Note rrou and rrtoi are identical except in the way they treat negative
 * multiples of 1/2:  rrou(-1.5) = -2, whereas rrtoi(-1.5) = -1.
 */
#define rrou(a)  (((a) < REAL_ZERO)  ?\
                 -((-((a) & 0xffff0000L) + ((a) & 0xffffL) + REAL_HALF) >> 16)\
                 : ((a) + REAL_HALF) >> 16)              /* round to int     */



/* truncate to int */
#define rtrunc(a)       (((a) < REAL_ZERO)  ? -((-(a)) >> 16) : (a) >> 16)

#define rceil(a)        (((a) + REAL_ALMOST1) >> 16)     /* round up to int  */
#define rfloor(a)       ((a) >> 16)                      /* floor to int     */

#define rrtoi(a)        (((a) < REAL_ZERO) ? ((int)((a) >> 16))\
                       : ((int)(((a) + REAL_HALF) >> 16)))  /* round to int  */


#define rrtoip(a)	((int)(((a) + REAL_HALF) >> 16)) /*rnd to int as pos */

#define ritor(a)	((real)((a) << 16))		 /* int to real      */
#define riftor(i,f)	(((i) << 16)|(((f) << 16)/10))	 /* "i.f" to real    */
#define rpqtor(p, q)	(((p) << 16) / (q))              /* ints p/q to real */

/*
 * Operations on reals
 */
#define rround(a) 	(((a)+REAL_HALF) & ~REAL_ALMOST1)   /* round to real */
#define rroundup(a) 	(((a)+REAL_ALMOST1) & ~REAL_ALMOST1)/* round up      */
#define rrounddown(a) 	((a) & ~REAL_ALMOST1)          /* round down to real */

#define rgt(a, b)	((a) > (b))
#define rge(a, b)	((a) >= (b))
#define rlt(a, b)	((a) < (b))
#define rle(a, b)	((a) <= (b))
#define req(a, b)	((a) == (b))
#define rne(a, b)	((a) != (b))
#define rneg(a)		(-(a))
#define radd(a, b)	((a) + (b))
#define rsub(a, b)	((a) - (b))
                       
#define rfrac(a)    ((a) & REAL_ALMOST1)        /* fractional part of a real */
