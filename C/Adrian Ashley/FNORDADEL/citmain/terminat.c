#define FULLVAPE

/*
 * terminat.c -- terminate code for Citadel bulletin board system
 */

/*
 * 91Feb10 RH	Split terminate-related stuff from log.c
 */

#include "ctdl.h"
#include "calllog.h"
#include "terminat.h"
#include "log.h"
#include "room.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * * backoutmsgs()	remove purged messages from room structs
 * * dopurge()		purge unworthy messages from system
 * terminate()		log off the system.
 */

extern void rundoor(struct doorway *door, char *tail);

/*
 * backoutmsgs() -- remove purged messages from room structs
 */
static int
backoutmsgs(int doaidemsg)
{
    int i, j;
    int nukeAide = NO;

    for (i=0; i < MAXROOMS; i++) {
	thisRoom = i;
#ifdef FULLVAPE
	if ( (i!=MAILROOM) && (i!=AIDEROOM || cfg.flags.VAPORIZE) &&
#else
	if ( (i!=MAILROOM) && (i!=AIDEROOM) &&
#endif
	     (roomTab[i].rtlastMessage > highlogin)) {

	    getRoom(i);

	    if (i == AIDEROOM)
		nukeAide = YES;

	    for (j = NUMMSGS - 1; roomBuf.msg[j].msgno > highlogin; j--) {
		pullMId = roomBuf.msg[j].msgno;
		pullMLoc = roomBuf.msg[j].msgloc;
		NUMMSGS--;
		roomBuf.msg = (theMessages *) realloc(roomBuf.msg,
		    MSG_BULK);
		noteRoom();	/* putRoom() done by aideMessage() */

		if (doaidemsg) {
		    sprintf(msgBuf.mbtext,
			"Following message deleted from %s> by %s",
			roomBuf.rbname, program);
		    aideMessage(YES);
		}
		else {
		    putRoom(thisRoom);
		}
	    }			
	}
    }
    return nukeAide;
}

/*
 * dopurge() -- wipes out all new messages from selected ruggies
 *
 * #ifdef FULLVAPE:
 * Vaporize mode can introduce glitches in Mail>.  It will also vaporize
 * messages in Aide>, if generated during the user's call.
 */
static int
dopurge(char *lastuser)
{
    int nukeAide;
    struct user *p;

#if 0
    if (onConsole || (cfg.sysopName &&
		stricmp(logBuf.lbname, &cfg.codeBuf[cfg.sysopName]) == 0))
#else
    if ((cfg.sysopName &&
		stricmp(logBuf.lbname, &cfg.codeBuf[cfg.sysopName]) == 0))
#endif
	return NO;
    else if (purgelist) {
	p = purgelist;			/* Look for user in purge list */
	while (p)
	    if (stricmp(p->name,lastuser) != 0)
		p = p->next;
	    else
		break;
	if (p) {			/* User is in purge list */
	    if (cfg.flags.VAPORIZE) {
		nukeAide = backoutmsgs(NO);
#ifdef FULLVAPE
		wipemsgs(oldcatSector, oldcatChar, cfg.catSector, cfg.catChar);
#endif
		sprintf(msgBuf.mbtext,
			"%d messages from `%s' vaporized, %ld bytes total.",
			(cfg.newest - highlogin), lastuser,
			((long)cfg.catSector * BLKSIZE + (long)cfg.catChar) -
			((long)oldcatSector * BLKSIZE + (long)oldcatChar));
		if (nukeAide)
		    strcat(msgBuf.mbtext, "  Some Aide> messages were lost.");
#ifdef FULLVAPE
		cfg.catChar = oldcatChar;	/* Roll back */
		cfg.catSector = oldcatSector;
		cfg.newest = highlogin;
#endif
		aideMessage(NO);
	    }
	    else {
		nukeAide = backoutmsgs(YES);
	    }
	    getRoom(LOBBY);	/* also updates thisRoom */
	    return YES;
	}
    }
    return NO;
}

/*
 * terminate() -- menu-level routine to exit system
 *
 * 1.  parameter <hangup> is YES or NO.
 * 2.  if <hangup> is YES, breaks modem connection
 *     or turns off onConsole, as appropriate.
 * 3.  modifies externs: struct logBuf,
 *			 struct *logTab
 * 4.  returns no values
 *	      modified	dvm 9-82
 */
void
terminate(int disconnect, char flag)
{
    int i, chk;
    extern char doormode;	/* defined in ctdl.c */

    badpw = NO;

    if (loggedIn) {
	if (msgpurge && dopurge(logBuf.lbname))		/* Purge this user? */
	    disconnect = YES;
	if (flag == tPUNT) {
	    memcpy(logBuf.lbgen, origlogBuf.lbgen, GEN_BULK);
	    copy_array(origlogBuf.lbvisit, logBuf.lbvisit);
	}
	else if ((flag == tNORMAL) || (flag == tSTAY) || (flag == tGREETING))
	    logBuf.lbgen[thisRoom] = roomBuf.rbgen << GENSHIFT;
	logTab[0].ltnewest = cfg.newest;
	if (flag != tPUNT)
	    logBuf.lbvisit[0] = cfg.newest;

	if (cfg.maxtime)			/* Track connect time? */
	    if (MINUTE(time(NULL)) > MINUTE(logBuf.lblast) + 
			(cfg.mincalltime ? cfg.mincalltime : 1))
		logBuf.lbtime = logBuf.lbtime + (MINUTE(time(NULL)) -
		    MINUTE(logBuf.lblast));
	    else
		logBuf.lbtime = logBuf.lbtime +
			(cfg.mincalltime ? cfg.mincalltime : 1);
	logBuf.lblast = time(NULL);

	putlog(&logBuf, logindex, logfl);

	if (heldMessage) {
	    heldMessage = NO;
	    if (!(cfg.flags.KEEPHOLD))
		killhold(logindex);
	}

	logMessage(L_OUT, "", flag);
	strcpy(marktime, "");
	if (flag == tSTAY)
	    sameuser = YES;
	if (logout_door)			/* AA 91Jan04 */
	    rundoor(logout_door, NULL);
	if ((flag != tPUNT && flag != tNORMAL) || !blurb("logout", NO))
	    mprintf("\r\r%s logged out\r", logBuf.lbname);
	loggedIn = NO;
	strcpy(prevuser.name, logBuf.lbname);
	prevuser.flags = logBuf.flags;
    }
    else if (flag == tRESTRICT || flag == tMAXCALLS || flag == tMAXTIME ||
	flag == tMAXCLOSECALLS) {

	/* Count this call for time-of-last-call purposes */
	if (flag != tRESTRICT) {
	    logBuf.lblast = time(NULL);
	    putlog(&logBuf, logindex, logfl);
	}

	logMessage(L_OUT, "", flag);
	strcpy(marktime, "");
	strcpy(prevuser.name, logBuf.lbname);
	prevuser.flags = logBuf.flags;
    }
    setlog();		/* Wipe out logBuf flags and stuff */

    if (disconnect && doormode) {
	Abandon = YES;
	return;
    }

    if (disconnect) {
	sameuser = NO;
	/* clear the msgs entered/room list */
	memset(msgsentered, 0, MAXROOMS * sizeof(int));
	chk = haveCarrier;
	hangup();
	if (onConsole) {
	    onConsole = NO;
	    xprintf("\n`MODEM' mode.\n");
	}
	else {
	    if (chk)
		modIn();
	    if (sysRequest) {
		sysRequest = NO;
		modemClose();			/* don't allow calls here */
		for (i=0; i<18 && !KBReady(); i++) {
		    xputc('\007');
		    for (startTimer(); chkTimeSince() < 5 && !KBReady(); )
			;
		}
		if (KBReady()) {
		    while (KBReady())
			getch();
		    xprintf("\n`CONSOLE' mode\n ");
		    onConsole = YES;
		    warned = NO;
		    if (!dropDTR)
			modemOpen();
		}
		else
		    modemOpen();
	    }
	}
	xprintf("%s %s\n", formDate(), tod(NO));
    }

    for (i = 0; i < MAXROOMS; i++)	/* Clear skip bits */
	clear(roomTab[i],SKIP);
    lastRoom = -1;
    chatrequest = NO;			/* No more chat requested */
}
