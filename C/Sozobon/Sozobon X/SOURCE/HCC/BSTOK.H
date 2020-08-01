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
 *	bstok.h
 *
 *	basic token values
 *	(some compilers cant do enums, so use defines)
 */

#ifndef ENUMS
#define BADTOK	0
#define ID	1
#define ICON	2
#define FCON	3
#define SCON	4
#define DPARAM	6	/* parameter to #define */
#define EOFTOK	7
#define POSTINC 8	/* DOUBLE '+' is pre-inc */
#define POSTDEC 9	/* DOUBLE '-' is pre-dec */
#define TCONV	10	/* coertion */
#define TSIZEOF 11	/* sizeof(type expr) */
#define NL	12
#define WS	13	/* white space */
#define SCON2	14	/* <string> */
#define PTRDIFF 0x18
#define PTRADD	0x19
#define PTRSUB	0x1a
#define ARROW	0x1b
#define LTEQ	0x1c
#define GTEQ	0x1d
#define NOTEQ	0x1e
#else
enum {
	BADTOK, ID, ICON, FCON, SCON, DPARAM, EOFTOK,
	POSTINC, POSTDEC, TCONV, TSIZEOF, NL, WS, SCON2,
	PTRDIFF, PTRADD, PTRSUB, ARROW, LTEQ, GTEQ, NOTEQ
};
#endif

#define ASSIGN	0x100+	/* add to char of op */
#define DOUBLE	0x80+
#define UNARY	0x200+

#define STAR	(UNARY '*')	/* used a lot */

#define isassign(x)	(x >= 0x100)
