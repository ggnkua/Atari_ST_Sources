/*
 * hangup.c -- hang up the modem, somehow.
 *
 * 90Aug27 AA	Split off from libmodem.c
 */

#include "ctdl.h"
#include "config.h"
#include "citlib.h"

long chkTimeSince();
void startTimer(), modemOpen(), modemClose(), modputs(), setBaud();

static void
rawmodeminit()
{
    modemOpen();				/* enable the modem	*/
    setBaud(cfg.probug);			/* setup baud rate	*/
    modputs(&cfg.codeBuf[cfg.modemSetup]);	/* reset the modem	*/
}

void
hangup()
{
    extern char doormode;	/* in ctdl.c */

    if (doormode)
	return;

    if (gotcarrier()) {
	modemClose();
	startTimer();
	while (gotcarrier() && chkTimeSince() < 30L)
	    ;
    }
    else				/* kick the modem out of dialing, */
	modputs("\r%5%");		/* then wait .5 seconds           */
    rawmodeminit();			/* reset the ol' modem.          */
}

