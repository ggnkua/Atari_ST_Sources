/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	param.h
 *
 *	basic parameters
 */

#ifndef MMCC
#define MMCC	0
#endif

#ifndef CC68
#define CC68	0
#endif

#ifndef dLibs
#define dLibs	0
#endif

#undef NULL
#define NULL 0L

#ifndef LAT_HOST
#ifndef ACK_HOST
#define ENUMS	1	/* define if host compiler can do enums */
#endif
#endif

#define DEBUG	1

#define NHASH	32

#define ROPEN	"r"
#define WOPEN	"w"
#define FLTFORM "%.3g"

#define MAXSTR	256
#define MAXINCL 10
#define NMSIZE	12	/* must be at least 12 */
#define NMXSIZE	32

/* sizes of basic types */
#ifndef NOLONGS
#define SIZE_C	1	/* char */
#define SIZE_I	2	/* int */
#define SIZE_S	2	/* short */
#define SIZE_L	4	/* long */
#define SIZE_U	2	/* unsigned */
#define SIZE_F	4	/* float */
#define SIZE_D	4	/* double */
#define SIZE_P	4	/* pointer */
#define MAXINT	0x7fffL
#define MININT	-0x8000L
#define MAXUNS	0xffffL
#else
#define SIZE_C	1	/* char */
#define SIZE_I	4	/* int */
#define SIZE_S	2	/* short */
#define SIZE_L	4	/* long */
#define SIZE_U	4	/* unsigned */
#define SIZE_F	4	/* float */
#define SIZE_D	4	/* double */
#define SIZE_P	4	/* pointer */
#define MAXINT	0x7fffffff
#endif

/* alignment requirements */
#define ALN_C	0	/* char */
#define ALN_I	1	/* int */
#define ALN_S	1	/* short */
#define ALN_L	1	/* long */
#define ALN_U	1	/* unsigned */
#define ALN_F	1	/* float */
#define ALN_D	1	/* double */
#define ALN_P	1	/* pointer */

#define STACKALN 1

/* usage for registers */
#ifndef OUT_AZ
#define DRV_START	3
#define DRV_END		7
#define AREG		8
#define ARV_START	AREG+3
#define ARV_END		AREG+5
#define FRAMEP		AREG+6
#else
#define DRV_START	4
#define DRV_END		7
#define AREG		8
#define ARV_START	AREG+3
#define ARV_END		AREG+4
#define FRAMEP		AREG+5
#endif

/* definition of stack frame */
#define ARG_BASE	8
#define LOC_BASE	0

/* need for own buffers (ALCYON hack ) ? */
#define NEEDBUF		0

