/*
 * netmain.c -- the main network driver.
 *
 * 89Jan17 RH	dialer() recognises result codes to abort call
 * 88Feb14 orc	mail saving code moved to postmail.c
 * 88Feb05 orc	dialer code mangled for `Z' sysop option
 * 88Jan28 orc	modputs() extracted -- put into libmisc.c
 * 88Jan16 orc	implement netpoll() for STadel OONM networking; diddle
 *		`No Luck' hangup code a bit...
 * 88Jan11 orc	After unsuccessful callout, hang up twice.  If searchbaud
 *		system & check_for_init() returns true,	stick at the baudrate
 *		we saw the init sequence at
 * 87Dec22 orc	Add code to allow networking when not in net mode
 * 87Dec18 orc	Add code to use external autodialers.
 * 87Dec17 orc	Code added for net event chaining without bouncing the
 *		networker.  Allow system exit during networking.
 * 87Aug06 orc	split off from netmisc.c
 */

#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "msg.h"
#include "room.h"
#include "event.h"
#include "protocol.h"
#include "terminat.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

/*
 * increment()		copy a byte into sectBuf
 * readMail()		Integrates mail into the data base
 * inMail()		Integrates mail into database
 * openNet()		set up networker stuff
 * netmode() 		Handles the net stuff
 * closeNet()		restore citadel to normal
 * netSetTime()		Sets up some global variables
 * netTimeLeft()
 * callout()		Attempts to call some other system.
 */

FILE    *netLog = NULL;
char	logNetResults = NO;
char	inNet = NO;
char	sectBuf[SECTSIZE + 5];
int	counter;
int	rmtslot;
LABEL	rmtname, rmt_id;
struct alias *net_alias = (struct alias *)NULL;
long	netFin;		/* when the whole mess is done with	*/
char	netDebug = NO;	/* network-specific debugging flag	*/
int	noKill, errCount = 0;
struct nodeRoomsTab *sharedRooms;

char *strchr();

#define	inthisnet(x,what)	(readbit(netTab[x],N_INUSE) \
			     && !readbit(netTab[x],REC_ONLY) \
			     && (netTab[x].what_net & (1L<<what)))

#define mustpoll(x,day)	(netTab[x].poll_day & (1 << (day > 0 ? day-1 : 6)))

#define needtocall(i)	(readbit(netTab[i],MAILPENDING) \
		      || readbit(netTab[i],FILEPENDING) || netmesg(i))

/*
 * increment()
 */
int
increment(int c)
{
    /*
    xprintf( isprint(c) ? "%c " : "%02x ", 0xff & c);
     */
    if (counter > SECTSIZE+2) {
	hangup();
	return NO;
    }
    sectBuf[counter++] = (char)c;
    return YES;
}

/*
 * readMail() -- Integrates mail into the msgbase
 */
void
readMail(char zap, void (*mailer)())
{
    PATHBUF temp, tmp2;
    FILE *spl;

    ctdlfile(temp, cfg.netdir, netmlspool);

    if (spl = safeopen(temp, "rb")) {
	getRoom(MAILROOM);
	noKill = NO;
	while (getspool(spl))
	    if (stricmp(&cfg.codeBuf[cfg.nodeId], msgBuf.mborig) != 0)
		(*mailer)();

	fclose(spl);
	if (zap)
	    if (noKill) {
		ctdlfile(tmp2, cfg.netdir, "temp%d.$$$", errCount++);
		drename(temp, tmp2);
	    }
	    else
		dunlink(temp);
    }
    else
	neterror(YES, "No temp mail file.");
}

/*
 * inMail() -- integrates mail into database
 */
void
inMail(void)
{
    NETADDR to;

    if (msgBuf.mbto[0]) {
	strcpy(to, msgBuf.mbto);	/* postmail burns to: field */
	splitF(netLog, "%s mail to `%s' from `%s @ %s'.\n",
			postmail(YES) ? "Delivering" : "Cannot deliver",
			to, msgBuf.mbauth, msgBuf.mboname);
    }
    else {
	splitF(netLog, "No recipient for mail!\n");
	noKill = YES;
    }
}

/*
 * netDelay() -- Twiddle our thumbs for a while
 */
static void
netDelay(long time)
{
    int c;

    time = (1L + time) * 15L;		/* at least 15 second delay */
    for (startTimer(); timeLeft(netFin) > 0 && chkTimeSince() < time
					    && !(KBReady() || gotcarrier()); )
	;
    if(KBReady()) {
	xprintf("%s left.\n", plural("minute", (long)netTimeLeft()) );
	c = getch();
#ifdef ATARIST
	if (c == 'Z'-'@' && multiTask) {
	    xprintf("%s: detached\n", &cfg.codeBuf[cfg.nodeName]);
	    active = NO;
	}
	else
#endif
	if (c == 'Q' && conGetYesNo("Quit Fnordadel?")) {
	    Abandon = YES;
	    exitValue = SYSOP_EXIT;
	}
	while (KBReady())		/* gobble type-ahead */
	    getch();
    }
}

/*
 * openNet() -- set up networker stuff
 */
void
openNet(void)
{
    PATHBUF name;

    rmtname[0] = 0;
    if (logNetResults) {
	ctdlfile(name, cfg.auditdir, "netlog.sys");
	if ((netLog = safeopen(name, "a")) == NULL)
	    neterror(NO, "Couldn't open file `%s'.", name);
    }
    else
	netLog = NULL;
    inNet = YES;
}

/*
 * netSetTime() -- Start the net timer
 */
static void
netSetTime(int length)
{
    int delayed;

    timeis(&now);
    delayed = ((now.tm_hour * 60) + now.tm_min) - nextEvt->evtTime;
 
   /* allow 59 seconds slop time */
    netFin = upTime() + (length-delayed) * 60L + 59L;
}

/*
 * netTimeLeft()
 */
int
netTimeLeft(void)
{
    return timeLeft(netFin) / 60L;
}

/*
 * netmode()
 */
void
netmode(int length, int whichnet)
{
    int	x, dow, first, start=0;
    char *missed, *needto, *polled;

    polled = xmalloc(cfg.netSize);
    needto = xmalloc(cfg.netSize);
    missed = xmalloc(cfg.netSize);

    openNet();

    netSetTime(length);

    splitF(netLog,
	"\n-------Networking Mode (net %d) for ~%s--------\n%s %s\n",
	whichnet, plural("minute", (long)netTimeLeft()), formDate(), tod(NO));

    modemOpen();

    dow = now.tm_wday;

    /*
     * as a general rule, call l-d systems once a night, local systems
     * 5 times a night MAXIMUM.
     */
    for (x=0; x<cfg.netSize; x++) {
	if (inthisnet(x,whichnet)) {
	    polled[x] = netTab[x].ld ? netTab[x].ld : 5;
	    needto[x] = mustpoll(x,dow);
	    missed[x] = needtocall(x) || needto[x];
	}
	else
	    missed[x] = polled[x] = needto[x] = 0;
    }

    while (timeLeft(netFin) > 0) {
	netDelay(Random() % 16);	/* Random() is in osbind.h */
	if (Abandon)
	    break;
	if (gotcarrier())
	    nmcalled();

	if (cfg.netSize != 0) {
	    first = start;
	    do {
		x = start;
		start = (1+start) % cfg.netSize;
		if (polled[x] && (needto[x] || needtocall(x))) {
		    if (callout(x)) {
			--polled[x];
			if (caller() != NOT_STABILISED)
			    needto[x] = missed[x] = 0;
		    }
		    break;
		}
	    } while (start != first);
	}
    }

    for (msgBuf.mbtext[0]=0, x=0, first=YES; x < cfg.netSize; x++)
	if (missed[x]) {
	    if (first)
		first = NO;
	    else
		strcat(msgBuf.mbtext,", ");
	    getNet(x);
	    strcat(msgBuf.mbtext, netBuf.netName);
	}
    if (!first) {
	rmtname[0] = 0;
	neterror(NO, "Couldn't reach `%s'.", msgBuf.mbtext);
    }

    free(polled);
    free(needto);
    free(missed);

    closeNet();
}

/*
 * checkpolling() -- Try to poll all the active #polling systems
 */
int
checkpolling(void)
{
    int timenow, act, day, t1, t2, j, count, which;
    int idx;

    timenow = minutes(&day);
    for (idx=0; idx < cfg.poll_count; idx++) {
	if (poll_today(pollTab[idx].p_days, day)) {
	    t1 = (timenow > pollTab[idx].p_start);
	    t2 = (timenow < pollTab[idx].p_end);

	    if (pollTab[idx].p_start > pollTab[idx].p_end)
		act = t1 || t2;
	    else
		act = t1 && t2;

	    if (act) {
		which = pollTab[idx].p_net;
		for (count=j=0; j<cfg.netSize; j++)
		    if (inthisnet(j,which) && needtocall(j))
			count++;

		if (count)
		    pollnet(which);
	    }
	}
    }
    return NO;
}

void
pollnet(int which)
{
    int j;

    if (loggedIn)
	terminate(YES, tPOLLPUNT);
    openNet();
    modemOpen();

    splitF(netLog, "\n----Polling systems in net %d----\n%s %s\n",
					which, formDate(), tod(NO));

    for (j=0; j<cfg.netSize; j++) {
	if (inthisnet(j,which) && needtocall(j)) {
	    if (callout(j))
		caller();
	}
    }
    closeNet();
    return;
}

/*
 * closeNet() -- restore citadel to normal
 */
void
closeNet(void)
{
    FILE *spl;

    usingWCprotocol = ASCII;
    if (errfile) {
	fclose(errfile);
	errfile = NULL;
	if (spl = safeopen(logfile, "rb")) {
	    getspool(spl);
	    fclose(spl);
	    aideMessage(NO);
	}
    }
    haveCarrier = modStat = inNet = NO;
    if (netLog) {
	fclose(netLog);
	netLog = NULL;		/* added by AA 90Aug19 */
    }
}

/*
 * callsys() -- Call net node #i
 */

static int
callsys(int i)
{
    char call[80];
    char dialprg[80];

    getNet(rmtslot = i);
    normID(netBuf.netId, rmt_id);		/* Cosmetics */
    strcpy(rmtname, netBuf.netName);

    splitF(netLog, "Calling %s @ %s: ", netBuf.netName, tod(NO));

    setBaud(MIN(netBuf.baudCode, cfg.sysBaud));	/* set up baudrate */
    mflush();

    call[0] = 0;
    if (strlen(netBuf.access) > 0)
	strcat(call, netBuf.access);
    else if (netBuf.ld || !(cfg.flags.USA)) {
	if (cfg.flags.USA)
	    strcat(call, "1");
	strcat(call, &rmt_id[2]);
    }
    else
	strcat(call, &rmt_id[5]);

    if (netBuf.dialer) {
#ifdef ATARIST
	ctdlfile(dialprg, cfg.netdir, "dial_%d.prg", 0xff & netBuf.dialer);
#endif
#ifdef MSDOS
	ctdlfile(dialprg, cfg.netdir, "dial_%d.exe", 0xff & netBuf.dialer);
#endif
	return dosexec(dialprg, call);
    }

    modputs(&cfg.codeBuf[cfg.dialPrefix]);
    modputs(call);
    modputs(&cfg.codeBuf[cfg.dialSuffix]);
    return 0;
}

/*
 * callout() -- call some other system
 */
int
callout(int i)
{
    if (dialer(i,NO)) {
	splitF(netLog, "No luck.\n");
	return NO;
    }
    return YES;
}

int
dialer(int i, int abort)
{
    long tick;
    char blah;

    if (callsys(i) == 0) {
	tick = (long)(netBuf.ld ? cfg.ld_time : cfg.local_time);
	for (startTimer(); chkTimeSince() < tick; ) {
	    if (gotcarrier())
		return 0;
/* Following else if block added by RH 89Jan17. */
	    else if ((cfg.flags.HAYES) && MIReady()) {
		blah = getMod();
		if ((blah == '3') || (blah == '7')) {
			xputc(blah);
			hangup();
			return 1;
		}
	    }
	    else if (abort && KBReady()) {
		getch();
		hangup();
		return 2;
	    }
	}
    }
    hangup();
    return 1;
}

/*
 * OutOfNet() -- talk to a network caller when not networking
 */
void
OutOfNet(void)
{
    openNet();
    splitF(netLog, "\n----Network caller----\n%s %s\n", formDate(), tod(NO));
    called();
    closeNet();
}

/*
 * netAck() -- respond to a 7-13-69 network init sequence
 */
int
netAck(void)
{
    register c=0, click;

    if (gotcarrier()) {
	modout(~7 );
	modout(~13);
	modout(~69);
	/*
	 * wait for an ACK to show up...
	 */
	for (click=0; click < 200; click++) {
	    if (MIReady()) {		/* got a character? */
		c = getraw();
		if (netDebug)
		    splitF(netLog, "<%d>", c);
		if (c == ACK) {
		    if (netDebug)
			splitF(netLog, "-ACK\n");
		    return YES;
		}
	    }
	    pause(1);
	}
	if (netDebug)
	    splitF(netLog, "-NAK\n");
    }
    return NO;
}
