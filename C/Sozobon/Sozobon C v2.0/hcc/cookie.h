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
 *	cookie.h
 */

/* restrictions on type */

#define R_INTEGRAL	1
#define R_FLOATING	2
#define R_POINTER	4
#define R_STRUCT	8
#define R_ARITH		(R_INTEGRAL|R_FLOATING)
#define R_SCALAR	(R_ARITH|R_POINTER)
#define R_ASSN		(R_SCALAR|R_STRUCT)

/* cookies */
#define FORSIDE		1
#define FORPUSH		2
#define FORCC		3
#define FORIMA		4
#define FORADR		5
#define FORINIT		6
#define IND0		7
#define RETSTRU		8
#define FORVALUE	9

/* eval flags derived from cookie */
#define NOVAL_OK	1	/* value is optional */
#define CC_OK		2	/* just setting cond. codes okay */
#define IMMA_OK		4	/* immediate OREG is okay */
