/*
 * printmsg.c -- functions to print messages
 *
 * 90Nov06 AA	Stuff for gcc & STadel 3.4a
 * 90Oct31 AA	Check for (cfg,SHOWRECD) in showHdr()
 * 90Aug27 AA	Split off from libmsg.c
 */

#include "ctdl.h"
#include "msg.h"
#include "room.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

/* FIXME: */
extern char remoteSysop;	/* for TheSysop() macro */

/*
 * putheader() - display a message header
 */
void
putheader(int leftover)
{
    LABEL dummy;	/* added for parsepath call by RH 90Dec12 */
    extern char *program;

    mformat("\r   ");

    if (!msgBuf.mbauth[0] && msgBuf.mbid)
	mprintf("Msg #%ld / ", msgBuf.mbid);

    if (readbit(msgBuf,mANONMESSAGE) && readbit(roomBuf,ANON)) {
	mprintf("****");
#if 0
	if (readbit(msgBuf,mNETMESSAGE) && msgBuf.mboname[0])
#else
	if (msgBuf.mboname[0])
#endif
	    mprintf(" @ %s%s%s", msgBuf.mboname,
	    msgBuf.mbdomain[0] ? "." : "", msgBuf.mbdomain);
    }
    else {
	mprintf("%s", msgBuf.mbdate[0] ? msgBuf.mbdate : formDate());
	if (readbit(logBuf,uSHOWTIME))
	    mprintf(" %s", msgBuf.mbtime[0] ? msgBuf.mbtime : tod(YES));

	if (msgBuf.mbauth[0]) {
	    mprintf(" from %s", msgBuf.mbauth);
	    if (msgBuf.mboname[0])
		mprintf(" @ %s%s%s", msgBuf.mboname,
		msgBuf.mbdomain[0] ? "." : "", msgBuf.mbdomain);
	    if (msgBuf.mborg[0] && !msgBuf.mbto[0])
		mprintf(" (%s)", msgBuf.mborg);
	}

	if (msgBuf.mbid && stricmp(msgBuf.mbroom, roomBuf.rbname) != 0)
	    mprintf(" in %s>", msgBuf.mbroom);

	if (msgBuf.mbto[0]) {
	    mprintf(" to %s", msgBuf.mbto);
	    if (((cfg.flags.SHOWRECD) || TheSysop())
		&& !msgBuf.mboname[0]
		&& !readbit(msgBuf,mMULTIMAIL)		/* not a multi-mail */
		&& !readbit(msgBuf,mNETMESSAGE)		/* not a net message */
		&& !parsepath(msgBuf.mbto,dummy,NO)	/* above will replace
							   this, but not yet */
		&& stricmp(msgBuf.mbto,program) != 0	/* not to "Citadel" */
		) {
		register int i = MAILSLOTS - 1;

		while (i > -1 && MAILNUM(logBuf.lbmail[i].msgno) != msgBuf.mbid)
		    i--;
		if (i != -1)
		    mprintf(" (%s)", (logBuf.lbmail[i].msgno & RECEIVED) ?
			"Rec'd" : "Not rec'd");
	    }
	}
    }

    if (leftover && readbit(logBuf,uNUMLEFT))
	mprintf(" (%d left)", leftover); 

    doCR();
}


#if 0		/* here's the old stuff for comparison */

extern char *program;


void
doPrintMsg(slot)
int slot;
{
    prtHdr(slot);
    prtBody();
}

void
prtHdr(slot)
int slot;
{
    LABEL dummy;	/* added for parsepath call by AA 89Sep11 */

    doCR();

    if (!msgBuf.mbauth[0])
	mPrintf("   Msg #%s /", msgBuf.mbid);
    else mPrintf("  ");
    if (msgBuf.mbdate[0])
	mPrintf(" %s", msgBuf.mbdate);
    if (msgBuf.mbtime[0] && readbit(logBuf,uSHOWTIME))
	mPrintf(" %s", msgBuf.mbtime);
    if (msgBuf.mbauth[0])
	mPrintf(" from %s", msgBuf.mbauth);

    if (msgBuf.mboname[0])
	mPrintf(" @ %s", msgBuf.mboname);
    if (msgBuf.mborg[0] && !msgBuf.mbto[0])
	mPrintf(" (%s)", msgBuf.mborg);

    if (stricmp(msgBuf.mbroom, roomBuf.rbname) != 0)
	mPrintf(" in %s>", msgBuf.mbroom);
    if (msgBuf.mbto[0]) {
	mPrintf(" to %s", msgBuf.mbto);
	if (((cfg.flags.SHOWRECD) || TheSysop())  /* let TheSysop() see it */
		&& (slot > -1)	/* `slot' is the msg slot in logBuf/roomBuf */
		&& !msgBuf.mboname[0]
		&& !parsepath(msgBuf.mbto,dummy,NO)	/* not a net message */
		&& stricmp(msgBuf.mbto,program) != 0	/* not to "Citadel" */
	    )
	    mPrintf(" (%s)", (logBuf.lbmail[slot].msgno > 0) ? 
		"Rec'd" : "Not rec'd");
    }
}

void
prtBody()
{
    register incoming;

    doCR();
    do {
	incoming = msggetword(msgBuf.mbtext, 150);
	printword(msgBuf.mbtext);
	if (incoming && mAbort()) {
	    if (outFlag == OUTNEXT) 	/* If <N>ext, extra line */
		doCR();
	    break;
	}
    } while (incoming);
    doCR();
}


#endif
