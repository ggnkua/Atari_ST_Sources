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
 *	tok.h
 *
 *	establish token values
 */

struct tok {
	char	*name;
	int	tnum;
	long	ival;
	double	fval;
	char	prec;
	int	flags;
};

#include "flags.h"
#include "bstok.h"

#define is_sclass(x)	(x >= K_EXTERN && x <= K_STATIC)
#define is_tadj(x)	(x >= K_LONG && x <= K_UNSIGNED)
#define is_btype(x)	(x >= K_INT && x <= K_VOID)
#define is_tykw(x)	(x >= K_EXTERN && x <= K_STRUCT)

#define is_stkw(x)	(x >= K_GOTO && x <= K_ASM)
#define is_brast(x)	(x >= K_GOTO && x <= K_CONTINUE)
#define is_blkst(x)	(x >= K_IF && x <= K_SWITCH)
#define is_lblst(x)	(x >= K_CASE && x <= K_DEFAULT)

#include "tytok.h"
#include "sttok.h"

/* modifier seen flags */
#define SAW_SHORT	1
#define SAW_LONG	2
#define SAW_UNS		4
