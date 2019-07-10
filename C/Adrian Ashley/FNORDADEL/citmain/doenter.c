/*
 * doenter.c -- [E]nter command drivers
 *
 * 91Feb10 RH	Brought over changepw() from old log.c & made it static
 * 90Nov60 AA	Munging for 3.4a stuff plus gcc (2-yes-2-yes-2 hacks in 1!)
 * 88Jul08 orc	Extracted from ctdl.c
 */

#include "ctdl.h"
#include "protocol.h"
#include "log.h"
#include "room.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * readBatch() - accepts file from the modem via a batch protocol
 */
static void
readBatch(void)
{
    char msg[80];

    if (xchdir(roomBuf.rbdirname)) {
	sprintf(msg, "Ready for %s batch upload", protocol[WC]);
	if (getNo(msg)) {
	    iprintf("Hit ^X once or twice to cancel...\n");
	    /*
	     * grab files -- recWCfile returns -1 on null batch header
	     *               or got notbatch file when expected.
	     */
	    batchWC = YES;
	    while (recXfile(sendARchar) == 0)
		;
	    batchWC = NO;
	}
    }
}

/*
 * configure: reset user configuration
 */
static void
configure(void)
{
    char c;
    char *uname();

    if (loggedIn)
	showcfg();			/* show initial configuration  */
    while (onLine()) {			/* then drop into another mode */
	iprintf("Config cmd: ");	/* where we do the dirty work  */
	if ((c=toupper(getnoecho())) != 'X' && c != '\n')
	    config(c);
	else {
	    mprintf("exit\r");		/* AA 90Dec04 */
	    break;
	}
    }
}

/*
 * changepw() - change the user's password.
 *
 * If the user can't provide his/her old password, assume it's an illegal
 * user and don't let him/her change the password.
 */
static void
changepw(void)
{
    LABEL pw;
    struct logBuffer temp;

    /*
     * save password so we can find current user again
     */
    getNormStr("\rOld password", pw, NAMESIZE, NO);
    if (stricmp(pw, logBuf.lbpw) != 0)
	return;

    initlogBuf(&temp);
    while(1) {
	echo = NO;
	getNormStr("New password", pw, NAMESIZE, NO);
	echo = YES;
	if (strlen(pw) < 1 || !onLine()) {
	    killlogBuf(&temp);
	    return;
	}
	if (strlen(pw) > 1 && getpwlog(pw, &temp) == ERROR)
	    break;
	mprintf("Poor password\r");
    }
    killlogBuf(&temp);

    strcpy(logBuf.lbpw, pw);
    logTab[0].ltpwhash = hash(pw);
    putlog(&logBuf, logindex, logfl);

    mprintf("\rname: %s\r", logBuf.lbname);
    echo = NO;
    mprintf("password: %s\r", logBuf.lbpw);
    echo = YES;
}

/*
 * doEnter() - Enter something
 */
void
doEnter(int prefix, char cmd)
{
    if (cmd == 'F') {	/* hook for (u)pload */
	mprintf("upload ");
	switch ((logBuf.flags & (uPROTO1 | uPROTO2 | uPROTO3)) >> 10) {
	    case 0: WC = XMODEM;	break;
	    case 1: WC = YMODEM;	break;
	    case 2: WC = WXMODEM;	break;
	    default: WC = XMODEM;	break;
	}
    }
    else {
	WC = ASCII;
	mprintf("enter ");
	if (prefix)
	    do {
		cmd = toupper(getnoecho());
	    } while (rwProtocol(cmd));
	else
	    cmd = toupper(cmd);
    }

    switch (cmd) {
    case 'B':
    case 'F':
	if (!(loggedIn || onConsole)) {
	    mprintf("- [L]og in first!\r");
	    return;
	}
	/* No files wanted from twits */
	if (readbit(logBuf,uTWIT)) {
	    whazzit();
	    break;
	}
	if (!readbit(roomBuf,ISDIR))
	    mprintf("- This is not a directory room\r");
	else if (cmd == 'B' && (WC == XMODEM || WC == YMODEM) && SomeSysop()) {
	    mprintf("batch\r");
	    readBatch();
	}
	else if (readbit(roomBuf,UPLOAD) || SomeSysop()) {
	    mformat("file ");
	    upload(WC);
	}
	else
	    mprintf("- You may not upload to this room.\r");
	break;
    case 'O':
	mprintf("option ");
	config(toupper(getnoecho()));
	break;
    case 'C':
	mprintf("configuration\r");
	configure();
	break;
    case 'P':
	mprintf("password");
	if (loggedIn) {
	    changepw();
	    break;
	}
	else {
	    mprintf("- [L]og in first!\r");
	    return;
	}
    case 'N':
    case 'L':
    case 'H':
    case 'M':
	mprintf("%sessage", (cmd=='N')?"net-m":((cmd=='H')?"held-m":
	    ((cmd=='L')?"local-m":"m")));
#if 0
    case '\n':
#endif
	if (!(loggedIn || (cfg.flags.ENTEROK) || thisRoom == MAILROOM)) {
	    mprintf("- [L]og in first!\r");
	    return;
	}
	if (readbit(roomBuf,READONLY) && !readbit(logBuf,uAIDE)) {
	    mprintf("- this room is READONLY\r");
	    break;
	}
	if ((thisRoom == MAILROOM) && !(readbit(logBuf,uAIDE) || (onConsole)) &&
	    !readbit(logBuf,uMAILPRIV)) {
	    mprintf("\rSorry, you don't have mail privileges.\r");
	    break;
	}
	if (!(readbit(logBuf,uAIDE) || onConsole) &&
	     (	((thisRoom != MAILROOM) && cfg.maxmsgs &&
			(msgsentered[thisRoom] >= cfg.maxmsgs)) ||
		((thisRoom == MAILROOM) && cfg.maxmailmsgs &&
			(msgsentered[thisRoom] >= cfg.maxmailmsgs))
	     )
	   ) {
	    if (!blurb("maxmsg", YES))
		mprintf("\rSorry, you have reached the limit of %d messages.\r",
		    (thisRoom != MAILROOM) ? cfg.maxmsgs : cfg.maxmailmsgs);
		break;
	}
	doCR();
	echo = (onConsole || thisRoom != MAILROOM);
	if (cmd == 'H') {
	    if (heldMessage)
		heldmesg(WC);
	    else
		mprintf("None held\r");
	}
	else if (cmd == 'N')
	    nettedmesg(WC);
	else if (cmd == 'L')
	    localmesg(WC);
	else
	    entermesg(WC);
	echo = YES;
	break;
    case 'R':
	if (readbit(logBuf,uTWIT)) {	/* No rooms from twits */
	    whazzit();
	    break;
	}
	mprintf("room");
	if (!loggedIn) {
	    mprintf("- [L]og in first!\r");
	    return;
	}
	if (!((cfg.flags.ROOMOK) || readbit(logBuf,uAIDE)))
	    mprintf("- only AIDES may create rooms\r");
	else {
	    makeRoom();
	}
	break;
    case '?':
	menu("entopt");
	break;
    default:
	whazzit();
    }
}
