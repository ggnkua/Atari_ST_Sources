#include        <stdio.h>
#include        "c.h"
#include        "expr.h"
#include        "gen.h"
/*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or question
s
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

/*      global definitions      */

FILE            *input = 0,
                *list = 0,
                *output = 0;

int             lineno = 0;
int             nextlabel = 0;
int             lastch = 0;
int             lastst = 0;
char            lastid[20] = "";
char            laststr[MAX_STRLEN + 1] = "";
long            ival = 0;
double          rval = 0.0;

TABLE           gsyms = {0,0},
                lsyms = {0,0};
SYM             *lasthead = NULL;
struct slit     *strtab = 0;
int             lc_static = 0;
int             lc_auto = 0;
struct snode    *bodyptr = 0;
int             global_flag = 1;
TABLE           defsyms = {0,0};
int             save_mask = 0;          /* register save mask */

