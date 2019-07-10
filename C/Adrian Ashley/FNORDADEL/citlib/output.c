/*
 * output.c -- A couple of general output (and, ahem, input) functions.
 *
 * 90Nov07 AA	Rehacked to conform to 3.4a guidelines, plus gcc/ANSI hacks
 * 90Aug27 AA	Renamed from libout.c
 * 88Feb14 orc	Created.
 */
 
#include "ctdl.h"
#include "protocol.h"
#include "config.h"
#include "log.h"
#include "citlib.h"
#include "citadel.h"	/* it's a part of citadel.tos, I guess. */

char	prevchar = 0;
char    *CRfill = NULL;
void	(*CRftn)() = NULL;

/*
 * getnoecho() - get a character, don't echo
 */
int
getnoecho()
{
    return justLostCarrier ? 0 : cfg.filter[0x7f & modIn()];
}

/* 
 * retfmt() gives us a left margin for printing special formats
 */
void
retfmt(void)
{
    if (logBuf.lbwidth > 40)
	mprintf(CRfill, ' ');
}

/*
 * doCR() does a newline on modem and console
 */
void
doCR(void)
{
    doNL('\r');
    prevchar = '\r';
}

void
doNL(char c)
{
    register i;
    extern int column;

    prevchar = ' ';
    column = 1;
    if (outFlag == OUTOK || outFlag == IMPERVIOUS) {
	if (usingWCprotocol == CAPTURE)	/* leave in internal format */
	    (*sendPFchar)(c);
	else if (usingWCprotocol)
	    (*sendPFchar)('\n');
	else {
	    if (c == '\f')
		mprintf("^L");
	    conout('\n');
	    if (haveCarrier) {
		modout('\r');
		for (i = (int)logBuf.lbnulls;  i;  i--)
		    modout(0);
		if (readbit(logBuf,uLINEFEEDS))
		    modout('\n');
	    }

	}
	if (CRftn)
	    (*CRftn)();
    }
}

#if 0
void
doCR()	/* do a newline on modem and console */
{
    int i;

    crtColumn = 1;
    if (outFlag != OUTOK && outFlag != IMPERVIOUS)
	return;	/* output is being s(kip)ped	*/
    
    if (usingWCprotocol != ASCII)
	(*sendPFchar)('\n');
    else {
	conout('\n');
	if (haveCarrier) {
	    modout('\r');
	    for (i = (int)logBuf.lbnulls; i; i--)	/* (int) cast put in */
		modout(0);				/* by AA 90Aug14 */
	    if readbit(logBuf,uLINEFEEDS)
		modout('\n');
	}
    }
    prevChar = ' ';
    if (CRfill && logBuf.lbwidth >= 40)	/* for odd printing formats	*/
	mPrintf(CRfill, ' ');		/* like .RE			*/
}
#endif

/*
 * oChar() is the top-level user-output function.
 *
 * Sends to modem port and console both.
 */
void
oChar(char c)
{
    prevchar = c;			/* for end-of-paragraph code	*/
    if (outFlag == OUTOK || outFlag == IMPERVIOUS) {	/* s(kip) mode	*/
	if (c == '\n')			/* suck up soft newlines	*/
	    c = ' ';
	if (usingWCprotocol != ASCII)
	    (*sendPFchar)(c);
	else {
	    conout(c);
	    if (haveCarrier)
		modout(c);
	}
    }
}
