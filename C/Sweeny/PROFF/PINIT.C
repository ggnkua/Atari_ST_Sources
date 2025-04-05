#include <stdio.h>
#include <ctype.h>
#include "proff.h"
#include "debug.h"

/*
 * finit - initialise parameters, set default values
 *	   used by .reset command
 *
 */
finit()
{
	int i;

	inval = 0;
	rmval = PAGEWIDTH;
	tival = 0;
	lsval = 1;
	fill = YES;
	ceval = 0;
	ulval = 0;
	boval = 0;
	cchar = '.';
	genesc = '_';
	tjust[0] = LEFT;
	tjust[1] = CENTER;
	tjust[2] = RIGHT;
	bsval = 0;
	rjust = YES;
	ulblnk = BLANK;

	for (i = 0; i < INSIZE; i++)
		if (i % 8 == 0)
			tabs[i] = YES;
		else
			tabs[i] = NO;

	lineno = 0;
	curpag = 0;
	newpag = 1;
	plval = PAGELEN;
	m1val = 3;
	m2val = 2;
	m3val = 2;
	m4val = 3;
	bottom = plval - m3val - m4val;
	ehead[0] = '\n';
	ehead[1] = EOS;
	ohead[0] = '\n';
	ohead[1] = EOS;
	efoot[0] = '\n';
	efoot[1] = EOS;
	ofoot[0] = '\n';
	ofoot[1] = EOS;
	ehlim[0] = inval;
	ehlim[1] = rmval;
	ohlim[0] = inval;
	ohlim[1] = rmval;
	eflim[0] = inval;
	eflim[1] = rmval;
	oflim[0] = inval;
	oflim[1] = rmval;
	verbose = NO;
	stopx = 0;
	frstpg = 0;
	lastpg = HUGE;
	print = YES;
	offset = 0;
	outp = 0;
	outw = 0;
	outwds = 0;
	bp = -1;
	for (i = 0; i < 26; i++)
		nr[i] = 0;

	CEon = FALSE;
	ULon = FALSE;
	BDon = FALSE;

	onlyrunoff = FALSE;
	roman = FALSE;
	bolding = YES;
	autopar = NO;
}
