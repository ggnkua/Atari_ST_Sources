/*
 * statbar.c - k-k00l status bars for citadel
 *
 * 91Jan12 AA	Hack to ensure full update of statbar whenever it's created.
 * 90Nov08 AA	Hacked up for gcc
 * 88Sep06 orc	stat_upd() added, statmsg() made static
 * 88Mar12 orc	Created.
 */

/*
 * makebar()		create a status bar
 * * statmsg()		put a message on the status bar
 * stat_upd()		update the status bar
 * killbar()		remove the status bar
 */

#include "ctdl.h"
#include <linea.h>	/* gcc linea declarations */
#include "log.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

static char realline[81] = "";

/*
 * makebar() - create the status line
 *
 * The first line displayed following a call to makebar() will get stuck
 * in the status line.
 */
int
makebar(void)
{
    linea0();	/* saves the linea address in __aline */
    if (V_CEL_MX > 78) {
	V_CEL_MY--;
	realline[0] = 0;	/* AA 91Jan12 */
	xprintf("\n");		/* Scroll screen one line */
	return 1;
    }
    return 0;
}

/*
 * statmsg() - put a message on the status line
 */
static void
statmsg(char *msg, int x)
{
    V_CEL_MY++;
/* 'p' sets inverse mode; 'j' saves current cursor location; 'k' restores
   cursor position to that saved previously; 'q' restores normal video */
    xprintf("\033p\033j\033Y%c%c\033w%s\033k\033q",
	32 + V_CEL_MY, 32+x, msg);
    xprintf("\033v");
    V_CEL_MY--;
}

/*
 * killbar() - remove the status line
 */
void
killbar(void)
{
    statmsg("\033q\033K",0);
    ++V_CEL_MY;
}

/*
 * stat_upd() - print a status line message describing a caller
 */
void
stat_upd(void)
{
    char new[81], brs[11];
    register i;

    if (onConsole)
	strcpy(brs, "(console)");
    else
	sprintf(brs,"%4d0 baud", byteRate);

    sprintf(new, "%-22s%-12s%-10s%-10s%-22s%c%c%c%c",
		    loggedIn ? logBuf.lbname : "",
		    brs, marktime, tod(YES),
		    formRoom(thisRoom, YES),
		    (cfg.flags.NOCHAT) ? ' ':'C',
		    sysRequest ? 'R':' ',
		    readbit(logBuf, uTWIT) ? 'T':' ',
		    chatrequest ? '*':' ');

    for (i=0; realline[i] && realline[i] == new[i]; i++)
	;
    if (realline[i] != new[i]) {
	statmsg(&new[i], i);
	strcpy(realline, new);
    }
}
