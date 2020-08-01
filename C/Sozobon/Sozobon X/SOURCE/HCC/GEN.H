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
 *	gen.h
 */

#include "cookie.h"

/* parameters for case */
#define C_SIMPLE	8	/* use simple if n <= this */
#define C_RATIO		3	/* use table if max-min/n <= this */

/* branch types */
/* designed so that pairs (i,i+1) with odd i represent opposites */
#define B_EQ	1
#define B_NE	2
#define B_LT	3
#define B_GE	4
#define B_LE	5
#define B_GT	6
#define B_YES	7
#define B_NO	8
#define B_ULT	9
#define B_UGE	10
#define B_ULE	11
#define B_UGT	12

/* derived nodes */
/* re-use stmt keywords for now */
#ifndef ENUMS
#define ONAME	'a'
#define OREG	'b'
#define REGVAR	'c'
#define PUSHER	'd'
#define CMPBR	'e'
#define FIELDAS	'f'
#else
enum {
	ONAME = 'a', OREG, REGVAR, PUSHER, CMPBR, FIELDAS
};
#endif

#define BR_TOK	'i'

/* evaluation order values */
#define EV_NONE		0
#define EV_LEFT		1
#define EV_RIGHT	2
#define EV_LR		3
#define EV_RL		4
#define EV_LRSEP	5	/* left then right, but seperate */
