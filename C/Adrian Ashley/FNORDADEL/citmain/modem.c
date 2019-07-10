/*
 * modem.c - modem code for Citadel bulletin board system
 *
 * 90Nov07 AA	Hacks for gcc/3.4a stuff
 * 88Feb14 orc	move oChar() to libio.c
 * 88Jan29 orc	move runhangup() to libmisc.c
 * 88Jan03 orc	Have `sleeping?' code properly kick you off the system
 * 87Oct23 orc	Tell what event is pending on warnings...
 * 87Oct12 orc	Don't allow remote ESC to drop you out of terminal mode
 * 87Jul08 orc	if no carrier, drop DTR when entering console mode
 * 87May10 orc	remove WC protocol functions.
 * 87Apr17 orc	Put hooks in for Ymodem upload.
 * 87Apr11 orc	Allow chat capture.
 * 87Mar28 orc	change chat mode to allow io buffering
 * 87Jan14 orc	moving over to the Atari ST (since 86Dec15)
 * 85Nov09 HAW	Warning bell before timeout.
 * 85Oct27 HAW	Cermetek support eliminated.
 * 85Oct18 HAW	2400 support.
 * 85Sep15 HAW	Put limit in ringSysop().
 * 85Aug17 HAW	Update for gotcarrier().
 * 85Jul05 HAW	Insert fix code (Brian Riley) for 1200 network.
 * 85Jun11 HAW	Fix readFile to recognize loss of carrier.
 * 85May27 HAW	Code for networking time out.
 * 85May06 HAW	Code for daily timeout.
 * 85Mar07 HAW	Stick in Sperry PC mods for MSDOS.
 * 85Feb22 HAW	Upload/download implemented.
 * 85Feb20 HAW	IMPERVIOUS flag implemented.
 * 85Feb17 HAW	Baud change functions installed.
 * 85Feb09 HAW and Sr.	Chat bug analyzed by Sr.
 * 85Jan16 JLS	fastIn modified for CR being first character from modem.
 * 85Jan04 HAW	Code added but not tested for new WC functions.
 * 84Sep12 HAW	Continue massacre of portability -- bye, pMIReady
 * 84Aug30 HAW	Wheeee!!  MS-DOS time!!
 * 84Aug22 HAW	Compilation directive for 8085 chips inserted.
 * 84Jul08 JLS & HAW ReadFile() fixed for the 255 rollover.
 * 84Jul03 JLS & HAW All references to putCh changed to putChar.
 * 84Jun23 HAW & JLS Local unused variables zapped.
 * 84Mar07 HAW	Upgrade to BDS 1.50a begun.
 * 83Mar01 CrT	FastIn() ignores LFs etc -- CRLF folks won't be trapped.
 * 83Feb25 CrT	Possible fix for backspace-in-message-entry problem.
 * 83Feb18 CrT	fastIn() upload mode cutting in on people.  Fixed.
 * 82Dec16 dvm	modemInit revised for FDC-1, with kludge for use with
 *		Big Board development system
 * 82Dec06 CrT	2.00 release.
 * 82Nov15 CrT	readfile() & sendfile() borrowed from TelEdit.c
 * 82Nov05 CrT	Individual history file established
 */

#include "ctdl.h"
#include "event.h"
#include "calllog.h"
#include "protocol.h"
#include "terminat.h"
#include "log.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * BBSCharReady()	returns true if user input is ready
 * iChar() 		top-level user-input function
 * connect()		chat mode
 * MIReady()		is there any input waiting on the modem
 * modIn() 		returns a user char
 * ringSysop()		signal chat-mode request
 */

char justLostCarrier = NO;	/* Modem <==> rooms connection		*/
char newCarrier      = NO;	/* Just got carrier			*/

char modStat;			/* Whether modem had carrier LAST time	*/
				/* you checked. 			*/
char haveCarrier;		/* set if DCD == YES			*/
char echo = YES;		/* Either YES or NO			*/
char usingWCprotocol;		/* True during WC protocol transfers	*/
char warned;
char sysRequest = NO;		/* sysop wants to use the console	*/

/*
 * BBSCharReady() returns YES if char is available from user
 *
 * NB: user may be on modem, or may be sysop in CONSOLE mode
 */
int
BBSCharReady(void)
{
    return onConsole ? KBReady() : (haveCarrier && MIReady());
}

/*
 * iChar() is the top-level user-input function -- this is the
 *	function the rest of Citadel uses to obtain user input
 */
unsigned
iChar(void)
{
    unsigned c;

    if (c=getnoecho())
       mputchar(c);
    return c;
}

void
mputchar(char c)
{
    if (c == '\n')
	doCR();
    else if (echo) {
	if (haveCarrier)
	    modout(c);
	conout(c);
    }
    else if (onConsole)
	conout(c);
    else
	modout(c);
}

/*
 * connect() - talk straight to the modem
 */
void
connect(int line_echo, int mapCR, int local_echo)
{
    register char c;
    register FILE *capture = NULL;
    PATHBUF chatFile;

    xprintf("<ESC> to exit\n");
    ctdlfile(chatFile, cfg.auditdir, "chat.rec");
    modemOpen();

    /* incredibly ugly code.  Rethink sometime: */
    /* it's been rethought & it's still* incredibly ugly    orc 4-87 */
    /* it's been rethought some more -- not quite so ugly.. orc 8-87 */
    /* it's been rehacked extensively -- maybe it will work?orc 4-88 */

    while (1) {
	if (MIReady() && (c = cfg.filter[getMod()])) {
	    if (capture)		/* we got it -- we save it?	*/
		putc(c, capture);
	    conout(c);
	    if (c == '\n') {
		if (line_echo)
		    modout('\r');
		if (!mapCR)		/* don't print the \n out in	*/
		    continue;		/* this case			*/
	    }
	    if (line_echo)		/* now print the xlated char	*/
		modout(c);
	}
	if (KBReady()) {
	    c = getch();
	    if (c == '\\') {
		putch('^');
		putch('\b');
		c = getch();
	    }
	    else if (c == ESC)
		break;
	    else if (c == 'R'-'@') {
		if (capture) {
		    xputs("\n(CAPTURE OFF)");
		    fclose(capture);
		    capture = NULL;
		}
		else if (capture=safeopen(chatFile, "ab"))
		    xputs("\n(CAPTURE ON)");
		continue;
	    }
	    modout(c);
	    if (c == '\r') {
		c = '\n';
		if (mapCR)
		    modout(c);
	    }
	    if (local_echo) {
		conout(c);
		if (capture)
		    putc(c, capture);
	    }
	}
#ifdef event_blat
	if (forceOut && timeLeft(evtClock) < evtTrig) {
	    if (warned) {		/* system going down now! */
		eventExit = YES;
		break;
	    }
	    warned = YES;
	    iprintf("\rWARNING: System going to %s mode at %d:%02d\r",
			    nextEvt->evtMsg,
			    nextEvt->evtTime/60, nextEvt->evtTime%60);
	    evtTrig = 0L;	/* reset trigger to immediate dropout */
	}
#endif
    }
    if (capture)
	fclose(capture);
    if (dropDTR && !gotcarrier())
	modemClose();
}

/*
 * modIn() - toplevel modem-input function
 *
 * If DCD status has changed since the last access, reports carrier present
 * or absent and sets flags as appropriate.  In case of a carrier loss, waits
 * 20 ticks and rechecks carrier to make sure it was not a temporary glitch.
 * If carrier is newly received, returns newCarrier = YES; if carrier lost
 * returns 0.  If carrier is present and state has not changed, gets a
 * character if present and returns it.
 */

#define MAX_TIME	210L		/* Time out is 210 seconds	*/

char
modIn(void)
{
    register char c;
    register long ts;
    register char beepidle = YES;

    startTimer();
    while (YES) {
	if (!onConsole && (c=gotcarrier()) != modStat) {
	    /* carrier changed	 */
	    if (c)  {	   /* carrier present	*/
		xprintf("Carrier detected\n");
		if (scanbaud()) {
		    warned = justLostCarrier = NO;
		    haveCarrier = newCarrier = YES;
		    modStat = c;
		    logMessage(BAUD, "", NO);
		}
		else
		    hangup();
		return HUP;
	    }
	    else {
		pause(50);			/* confirm it's not a glitch */
		if (!gotcarrier()) {		/* check again */
		    xprintf("Carrier lost\n");	/* to `do' carrier loss */
		    hangup();
		    haveCarrier = modStat = NO;
		    justLostCarrier = YES;
		    return HUP;
		}
	    }
	}

	if (!onConsole && MIReady() && haveCarrier)
	    return getMod();

	if (KBReady()) {
	    c = getch()&0x7f;
#ifdef ATARIST
	    if ((c == 'Z'-'@') && multiTask) {
		if (onConsole)
		    xprintf("WARNING: System is in CONSOLE mode!\n");
		xprintf("%s: detached\n", &cfg.codeBuf[cfg.nodeName]);
		active = NO;
	    }
	    else
#endif
	    if (onConsole)
		return c;
	    else if (c == ESC) {
		xprintf("`CONSOLE' mode\n");
		onConsole = YES;
		warned = NO;
		if (dropDTR && !gotcarrier())
		    modemClose();
		return HUP;
	    }
	    else if (c == 'R'-'@' && (sysRequest = !sysRequest))
		xprintf("(Request system)");
	    else if ((c == 'E'-'@') && loggedIn) {
		if (!blurb("fakeerr", YES))
		    iprintf("\rWhoops! Think I'll die now...\r");
		sysRequest = YES;
		hangup();
		haveCarrier = modStat = NO;
		justLostCarrier = YES;
		terminate(YES, tPUNT);
		return HUP;
	    }
	    else if ((c == 'T'-'@') && loggedIn) {
		flip(logBuf, uTWIT);
		xprintf("(User now %sa twit)", readbit(logBuf, uTWIT) ?
			"" : "not ");
	    }
	}

	if (evtRunning && timeLeft(evtClock) < evtTrig) {
	    if (haveCarrier || onConsole) {
		if (!forceOut)
		    continue;
		if (!warned) {
		    warned = YES;
		    evtTrig = 0L;	/* reset trigger to immediate dropout */
		    iprintf("\rWARNING: System going to %s mode at %d:%02d\r",
				    nextEvt->evtMsg,
				    nextEvt->evtTime/60, nextEvt->evtTime%60);
		    continue;
		}
		else {
		    iprintf("Going to %s mode. Bye!\n", nextEvt->evtMsg);
		    terminate(YES, tEVENTPUNT);
		}
	    }
	    /* nobody logged in, so wait for the end of the line */
	    else if (timeLeft(evtClock) > 0)
		continue;
	    eventExit = YES;
	    return HUP;
	}
	/*
	 * check for no input.	(Short-circuit evaluation, remember!)
	 */
	ts = chkTimeSince();
	if (haveCarrier || (!(cfg.flags.SYSOPSLEEP) && onConsole)) {
	    if (ts >= MAX_TIME) {
		mprintf("Sleeping? Call again :-)\r");
		terminate(YES, tTIMEOUT);
		return HUP;
	    }
	    else if (beepidle && ts >= MAX_TIME - 15L) {
		oChar(BELL);
		beepidle = NO;
	    }
	}
	else if (!onConsole && ts > cfg.poll_delay)
	    if (checkpolling())
		return HUP;
	    else
		startTimer();
#if 0
	if (!onConsole) {
	    ts = chkTimeSince();
	    if (haveCarrier) {
		if (ts >= MAX_TIME) {
		    mprintf("\n Sleeping? Call again :-)\n ");
		    terminate(YES, tTIMEOUT);
		    xprintf("Carrier lost\n");
		    haveCarrier = modStat = NO;
		    justLostCarrier = YES;
		    return HUP;
		}
		else if (!signal && ts >= MAX_TIME - 15L) {
		    oChar(BELL);
		    signal = YES;
		}
	    }
	    else if (ts > cfg.poll_delay)
		if (checkpolling())
		    return HUP;
		else
		    startTimer();
	}
#endif
	if (statbar)
	    stat_upd();
    }
}

/*
 * ringSysop() - signals a chat mode request.
 *
 * Exits on input from modem or keyboard.
 */

#define RING_LIMIT 6

void
ringSysop(void)
{
    int i, ring;

    mprintf("\rRinging sysop.\r");

    for (i=ring=0; ring < RING_LIMIT && !(MIReady() || KBReady()); ) {
	xputc(BELL);
	modout(BELL);
	
	pause( 0xff & cfg.shave[i] );
	if (++i >= 7) {
	    i = 0;
	    ring++;
	}
	if (!gotcarrier())
	    return;
    }

    if (KBReady()) {
	getch();
	onConsole = YES;
	xprintf("`CHAT' mode\n");
	connect(YES, YES, YES);
	onConsole = NO;
	chatrequest = NO;
    }
    else if (ring >= RING_LIMIT) {
	chatrequest = YES;
	cfg.flags.NOCHAT = 1;
	mprintf("Sorry, the Sysop is not around...\r");
    }
    else getraw();
}
