/*
 * misc.c -- citadel/etc/functions
 *
 * 90Nov09 AA	moved in initCit, exitCit, plus a bunch of other stuff
 * 90Nov05 AA	Lots of ANSIfication munging for gcc port
 * 88Sep15 orc	add uname() function.
 * 88Jul30 orc	add whazzit() function.
 * 88Jul17 orc	Split download() into two functions.
 * 88Jul15 orc	Move functions in from xymodem.c
 * 88Jun30 orc	move crashout() to sysdep.c
 * 88May29 orc	date parsing functions added for read-from-date
 * 88Mar08 orc	Add showdays() function.
 * 88Feb16 orc	Have crashout append records to the crashfile instead of
 *		overwriting it.
 * 88Feb11 orc	Add support for download limits
 * 88Jan17 orc	clear out fields in tempMess when doing ^LF into an empty
 *		message
 * 87Aug24 orc	Ooops -- plural() bombs the system.
 * 87Aug22 orc	Functions removed for libmisc.c
 * 87Aug08 orc	when configuring, don't ask for 'time messages created'
 *		unless the user is an expert.
 * 87Apr21 orc	Kludge in | print in doCR for .RE
 * 87Apr18 orc	have crashout tell time & date of system demise
 * 87Apr01 orc	change to Hjr type tags.
 * 87Mar28 orc	add helpfile directory support.
 * 87Feb06 orc	add tagged file support
 * 87Jan20 orc	remove cookie code
 * 87Jan14 orc	#ifdef out all networking stuff, add cookie code
 * 87Jan04 orc	clean up character sign extention problem in filter[]
 * 87Jan02 orc	Diddles for 68000 implementation
 * 86Aug19 HAW	Kill history because of space problems.
 * 84Jun10 JLS	Function setclock() installed.
 * 84May01 HAW	Starting 1.50a upgrade.
 * 83Mar12 CrT	from msg.c
 * 83Mar03 CrT & SB   Various bug fixes...
 * 83Feb27 CrT	Save private mail for sender as well as recipient.
 * 83Feb23	Various.  sendfile() won't drop first char on WC...
 * 82Dec06 CrT	2.00 release.
 * 82Nov05 CrT	Stream retrieval.  Handles messages longer than MAXTEXT.
 * 82Nov04 CrT	Revised disk format implemented.
 * 82Nov03 CrT	Individual history begun.  General cleanup.
 */

#include "ctdl.h"
#include "net.h"
#include "dirlist.h"
#include "calllog.h"
#include "event.h"
#include "protocol.h"
#include "dateread.h"
#include "room.h"
#include "config.h"
#include "log.h"
#include "floor.h"
#include "msg.h"
#include "browser.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * setclock()		allow changing of date
 * showcfg()		displays a user's current setup
 * config()		sets terminal parameters
 * typeWC()		send a file via WC protocol
 * ingestFile()		puts file in held message buffer
 * download()		display a file via a protocol
 * typefile()		display a file via ascii
 * upload()		menu-level enter-file-via-protocol
 * writeformatted() 	prints a helpfile.
 * plural()		pluralise a message
 * showdays()		print a day_of_week mask
 * parsedate()		convert a citadel-format date
 * dateok()		is this item okay to print?
 * dl_not_ok()		Check that this download can be done..
 * dlstat()		print a download statistics message
 * WCHeader()		Give the `ready for WC download' message
 * batch()		Set up/shut down a batch transfer.
 * whazzit()		print a `huh' message on bad input
 * uname()		return user name or "<anonymous>"
 */

FILE	*upfd;
int	masterCount;

char *protocol[] = { "ascii",
		     "vanilla",
		     "xmodem",
		     "ymodem",
		     "wxmodem",
		     "kermit",
		     "zmodem",
		     "capture",
		     "journal" };

/*
 * getNormStr() - gets a string and deletes leading & trailing blanks etc.
 */
void
getNormStr(char *prompt, char *s, int size, int doEcho)
{
    getString(prompt, s, size, 0, doEcho);
    normalise(s);
}

/*
 * givePrompt()
 */
void
givePrompt(void)
{
    int prevfloor;

    if (statbar)
	stat_upd();
    else if (loggedIn)
	xprintf("(%s%s%s)\n", logBuf.lbname,
		chatrequest ? " [chat requested]" : "",
		readbit(logBuf, uTWIT) ? " [TWIT]" : "");

    prevfloor = thisFloor;
    if ((thisFloor = findFloor(roomBuf.rbfloorGen)) == ERROR) {
	thisFloor = roomBuf.rbfloorGen = LOBBYFLOOR;
	noteRoom();
	putRoom(thisRoom);
    }
    if (prevfloor != thisFloor && readbit(logBuf,uFLOORMODE))
	iprintf("%s[%s]\r", readbit(logBuf,uEXPERT) ? "" : "Now on floor ",
	    floorTab[thisFloor].flName);
    if (!readbit(logBuf,uEXPERT))
	iprintf("[?]=menu, [H]elp, [I]nfo, %s\r",
	    loggedIn ? "[T]erminate":"[L]ogin");
    iprintf("%s ", formRoom(thisRoom, NO));
    if (strcmp(roomBuf.rbname, roomTab[thisRoom].rtname) != 0)
	crashout("room %d mismatch; rbname=<%s>, rtname=<%s>\n",
		thisRoom, roomBuf.rbname, roomTab[thisRoom].rtname);
}


/*
 * asknumber() - gets a number between (bottom, top)
 */
long
asknumber(char *prompt, long bottom, long top, int def)
{
    long try;
    long atol();
    LABEL numstring;

    do {
	if (prompt[0])
	    mprintf((def>=0 && def>=bottom) ? "%s (%d): " : "%s: ",prompt,def);
	getString("", numstring, NAMESIZE, 0, YES);
	try = (strlen(numstring) > 0) ? atol(numstring) : def;
	
	if (try < bottom)
	    mprintf("Must be at least %ld\r", bottom);
	else if (try > top)
	    mprintf("Must be no more than %ld\r", top);
    } while ((try < bottom || try > top) && onLine());
    return try;
}

/*
 * getNumber() - get a # w/o default
 */
long
getNumber(char *prompt, long bottom, long top)
{
    return asknumber(prompt, bottom, top, (int)(bottom-1));
}

/*
 * whereis() - looks for a pattern between `low' and `high'.
 */
int
whereis(char *src, char *pattern, int low, int high)
{
    register at, patlen;
    register char *p;

    patlen = strlen(pattern);
    at = high - patlen;

    while (at >= low)
	if (strnicmp(&src[at], pattern, patlen) == 0)
	    return at;
	else
	    --at;
    return -1;
}

/*
 * setclock() -- gets the date from the aide and remembers it
 */
void
setclock(void)
{
    int tmp;
    struct tm tts;

    timeis(&tts);	/* ANSIfied by AA 90Nov05 */
    mprintf("set date (current date is %s %s)\r", formDate(), tod(NO));
    if (getNo("Change the date")) {
	while (onLine()) {
	    tmp = asknumber("Year",  88L, 1999L, tts.tm_year + 1900);
	    if (tmp > 99)
		tmp -= 1900;
	    if (tmp >= 90 && tmp < 199) {
		tts.tm_year = tmp;
		break;
	    }
	    else
		mprintf("Year must be 88..99 -or- 1988..1999\r");
	}
	tts.tm_mon = asknumber("Month", 1L, 12L, tts.tm_mon + 1) - 1;
	tts.tm_mday = asknumber("Day", 1L, 31L, tts.tm_mday);
	tts.tm_hour = asknumber("Hour", 0L, 23L, tts.tm_hour);
	tts.tm_min = asknumber("Minute", 0L, 59L, tts.tm_min);
	if (onLine()) {
	    set_time(&tts);
	    setUpEvent();	/* date changed so regrab the event stuff */
	}
    }
}

void
showcfg(void)
{
    mprintf("Your current setup:\r\r");
    mprintf("%sxpert, ", readbit(logBuf,uEXPERT) ? "E" : "Non-e");
    mprintf("Default file transfer protocol: ");
    switch ((logBuf.flags & (uPROTO1|uPROTO2|uPROTO3)) >> 10) {
	case 0: mprintf("Xmodem.\r");	break;
	case 1: mprintf("Ymodem.\r");	break;
	case 2: mprintf("WXmodem.\r");	break;
	default: mprintf("Who knows?\r");	break;
    }
    mprintf("%slinefeeds, %d nulls,",
	readbit(logBuf,uLINEFEEDS) ? "" : "no ", logBuf.lbnulls);
    mprintf(" screen width is %d.\r", logBuf.lbwidth);
    mprintf("%srint time messages created.\r",
	readbit(logBuf,uSHOWTIME) ? "P" : "Do not p");
    mprintf("%srint last old message on [N]ew message command.\r",
	readbit(logBuf,uLASTOLD) ? "P" : "Do not p");
    mprintf("%ssing floor mode.\r",
	readbit(logBuf,uFLOORMODE) ? "U" : "Not u");
    mprintf("%sause between messages.\r",
	readbit(logBuf,uREADMORE) ? "P" : "Do not p");
    mprintf("%suto-show new messages in %s after login.\r",
	readbit(logBuf,uAUTONEW) ? "A" : "Do not a", roomTab[0].rtname);
    doCR();
}

static void
setflag(char *msg, int flag)
{
    int previous;

    previous = readbit(logBuf,flag);
    if (coreGetYesNo(msg, previous ? 'Y' : 'N') != previous)
	flip(logBuf, flag);
}

static void
getproto(void)
{
    int proto, foobar;
    char mode;

    mprintf("Default transfer protocol (now ");
    switch ((logBuf.flags & (uPROTO1|uPROTO2|uPROTO3)) >> 10) {
	case 0: mprintf("Xmodem");	break;
	case 1: mprintf("Ymodem");	break;
	case 2: mprintf("WXmodem");	break;
	default: mprintf("Who knows?");	break;
    }
    mprintf(")%s? ", readbit(logBuf,uEXPERT) ? "" :
	" ([X]modem, [Y]modem, CR=no change)");
    if ((mode = toupper(getnoecho())) == '\n') {
	doCR();
	return;
    }
    switch (mode) {
	case 'Y': proto = YMODEM; foobar = 1;	break;
#if 0
	case 'W': proto = WXMODEM; foobar = 2;	break;
#endif
	case 'X': proto = XMODEM; foobar = 0;	break;
	default : mprintf("?\r");	return;
    }
    logBuf.flags = (logBuf.flags & ~(uPROTO1|uPROTO2|uPROTO3)) |
	(long)(foobar << 10);
    mprintf("%s\r", protocol[proto]);
}

void
config(char what)
{
    switch (what) {
    case 'E': setflag("Are you an experienced Citadel user", uEXPERT);	break;
    case 'L': setflag("Do you need linefeeds", uLINEFEEDS);		break;
    case 'N': logBuf.lbnulls = (char)asknumber("Number of nulls", 0L, 127L,
		(int)logBuf.lbnulls);					break;
    case 'W': logBuf.lbwidth = asknumber("Screen width", 10L, 255L,
		logBuf.lbwidth);					break;
    case 'T': setflag("Print time messages created", uSHOWTIME); break;
    case 'O': setflag("Show last old message when reading [N]ew", uLASTOLD);
									break;
    case 'F': setflag("Floor mode", uFLOORMODE);			break;
    case 'P': setflag("Pause after each message", uREADMORE);		break;
    case 'A': setflag("Auto-show new messages after login", uAUTONEW);
									break;
    case 'R': setflag("Show running count of messages left while reading",
		uNUMLEFT);						break;
    case 'V': showcfg();						break;
    case 'Y': getproto();						break;
    case '?': menu("config"); doCR();					break;
    default:  whazzit();
    }
}

/*
 * ingestFile() - copy a file into the held mesg buffer
 */
int
ingestFile(name)
char *name;
{
    FILE *fd;
    register c;

    if (fd = safeopen(name, "r")) {
	sendCinit();
	while ((c = getc(fd)) != EOF && sendCchar(c & 0x7f))
	    ;
	sendCend();
	fclose(fd);
	return 1;
    }
    return 0;
}

/*
 * _getstring() - edits an already-existing string
 */
int
_getstring(char *string, int i, int size, int escape, int visible)
{
    char c;
    extern char justLostCarrier;

    --size;	/* for null termination */
    outFlag = IMPERVIOUS;
    while (onLine() && !justLostCarrier) {
	if (c = modIn()) {
	    if (i == 0 && c == escape) {
		string[i++] = c;
		break;
	    }
	    if (c = cfg.filter[0x7f & c]) {
		if (c == '\n')
		    break;
		else if (c == BACKSPACE) {
		    if (i>0) {
			oChar(BACKSPACE);
			oChar(' ');
			oChar(BACKSPACE);
			--i;
		    }
		    else oChar(BELL);
		}
		else if (i < size) {
		    oChar(visible ? c : '.');
		    string[i++] = c;
		}
		else oChar(BELL);
	    }
	}
    }
    doCR();
    string[i] = 0;
    return i;
}

/*
 * getString() - reads a string
 */
int
getString(char *prompt, char *string, int size, char escape, int visible)
{
    if (strlen(prompt) > 0)
	iprintf("%s: ", prompt);

    return _getstring(string, 0, size, escape, visible);
}

/*
 * typeWC() - Send a file via WC
 */
int
typeWC(FILE *fd)
{
    register int data;

    if (beginWC()) {
	while ((data = fgetc(fd)) != EOF && (*sendPFchar)(data))
	    ;
	endWC();
	return YES;
    }
    return NO;
}

/*
 * WCHeader() Give the 'ready for WC download' message.
 */
static int
WCHeader(struct dirList *fn)
{
    long time;
#if 0
    long sectors;
#else
    long kludgefactor;
#endif
    int Protocol = usingWCprotocol;
    int tooLong = NO;
    char msg[80];

    if (batchWC) {
	switch (usingWCprotocol) {
	case XMODEM:
	case YMODEM:
	case WXMODEM:
	    if (sendYhdr(fn->fd_name, fn->fd_size))
		break;
	    /* otherwise fall into the default case.... */
	default:
	    return NO;
	}
    }
    else {
	usingWCprotocol = ASCII;
	if (byteRate) {
#if 0
	    sectors = (fn->fd_size + (long)(SECTSIZE - 1)) / (long)(SECTSIZE);
	    time = (sectors*133L)/(long)(byteRate);
#else
	    switch (Protocol) {
		case XMODEM:	kludgefactor = 13L;	break;
		case YMODEM:	kludgefactor = 11L;	break;
		case WXMODEM:	kludgefactor = 13L;	break;
		default:	kludgefactor = 0L;	break;
	    }
	    time = kludgefactor * fn->fd_size / (long) (byteRate * 10);
#endif

	    if (dl_not_ok(time, fn->fd_size))
		return NO;
	    dlstat(fn->fd_name, time, fn->fd_size);
	}
	sprintf(msg, "ready for %s download", protocol[Protocol]);
	if (!getYesNo(msg))
	    return NO;
	usingWCprotocol = Protocol;
    }
    if (!inNet)
	logMessage(READ_FILE, fn->fd_name, NO);

    return YES;
}

/*
 * download() - dumps a host file with no formatting
 */
int
download(struct dirList *fn)
{
    FILE *fp;
    int status = YES;

    if (fp = safeopen(fn->fd_name, "rb")) {
	if (status = (WCHeader(fn) && typeWC(fp))) {
	    if (loggedIn && cfg.download && !onConsole)
		logBuf.lbdownloadlimit += fn->fd_size;
	    if (!batchWC)
		oChar(BELL);
	}
	fclose(fp);
    }
    return status;
}

/*
 * writeformatted() - display a file
 */
static void
writeformatted(FILE *fd, int helpline)
{
    char line[MAXWORD];

    outFlag = OUTOK;
    if (usingWCprotocol == ASCII && helpline && !readbit(logBuf,uEXPERT))
	mformat("\n [J]ump [P]ause [S]top");

    doCR();
    while (fgets(line, MAXWORD, fd) && outFlag != OUTSKIP)
	mformat(line);
    if (outFlag == OUTSKIP)
	outFlag = OUTOK;
    doCR();
}

/*
 * typefile() - dump out an ascii file
 */
int
typefile(struct dirList *p)
{
    register c;
    register gc;
    FILE *fp;

    outFlag = OUTOK;
    if (fp=safeopen(p->fd_name, dFormatted ? "r" : "rb")) {
	if (dFormatted)
	    writeformatted(fp, YES);
	else {
	    doCR();
	    while ((c=getc(fp)) != EOF) {
		conout(c);
		if (gc=gotcarrier())
		    modout(c);
		if (mAbort() || !(gc || onConsole))
		    break;
	    }
	}
	fclose(fp);
    }
    if (outFlag == OUTSKIP) {
	outFlag = OUTOK;
	mprintf("\r\r");
	outFlag = OUTSKIP;
    }
    return (outFlag != OUTSKIP);
}

static int
alphasort(const struct dirList *s1, const struct dirList *s2)
{
    return strcmp(s1->fd_name, s2->fd_name);
}

/*
 * wildcard() - do something with a pattern
 */
int
wildcard(int (*fn)(struct dirList *), char *pattern, int (*preamble)(int, 
    struct dirList *))
{
    int i, count;
    struct dirList *list;
    extern char batchWC;

    if (count=scandir(pattern, &list)) {
	if (preamble && !(*preamble)(count, list))
	    return ERROR;
	qsort((void *)list, (size_t)count, sizeof list[0],
	    (int (*)(const void *, const void *))alphasort);
#if 0
	for (i=0; i<count && (*fn)(&list[i]); i++)
	    ;
#else
	for (i = 0; i < count && (*fn)(&list[i]); ) {
	    /* Handle browser [A]gain and [B]ackup */
	    if (outFlag == OUTAGAIN || outFlag == OUTBACKUP) {
		if (outFlag == OUTBACKUP && i > 0)
		    i--;
		rewindtag();		/* Reset tag file ptr to beginning */
		outFlag = OUTOK;
	    }
	    else			/* Go to next entry */
		i++;
	}
#endif
	freedir(list, count);
	/*
	 * If we're batching, shut it down.
	 */
	if (batchWC && (usingWCprotocol == YMODEM || usingWCprotocol == XMODEM))
	    sendYhdr(NULL, 0L);
    }
    batchWC = NO;
    return count;
}

/*
 * upload() - enters a file into current directory
 */
void
upload(char WCmode)
{
    LABEL file;
    char *strchr();
    char successful;
    char msg[80];

    if (!readbit(logBuf,uEXPERT))
	iprintf("\rEnter file name: ");
    getNormStr("", file, NAMESIZE, YES);

    if (strpbrk(file," :\\/")) {
	mprintf("Illegal filename.\r");
	return;
    }
    if (strlen(file) == 0 || !xchdir(roomBuf.rbdirname))
	return;

    if (upfd = safeopen(file, "r")) {		/* File already exists */
	mprintf("A %s already exists.\r", file);
	fclose(upfd);
    }
    else if (upfd = safeopen(file, "wb")) {
	getNormStr("Enter a brief description of the file\n ",
		    msgBuf.mbtext, 500, YES);
	if (WCmode == ASCII)
	    switch ((logBuf.flags & (uPROTO1 | uPROTO2 | uPROTO3)) >> 10) {
		case 0: WCmode = XMODEM;	break;
		case 1: WCmode = YMODEM;	break;
		case 2: WCmode = WXMODEM;	break;
		default: WCmode = XMODEM;	break;
	    }
	sprintf(msg, "Ready for %s upload", protocol[WCmode]);
	successful = NO;
	if (getYesNo(msg)) {
	    if (WCmode != CAPTURE && WCmode != TODISK)
		iprintf("Hit ^X once or twice to cancel...\n");
	    successful = enterfile(sendARchar, WCmode);
	}
	fclose(upfd);

	if (successful) {
	    if (msgBuf.mbtext[0])
		putTag(file, msgBuf.mbtext);	/* write out the tag */
	    zero_struct(msgBuf);
	    sprintf(msgBuf.mbtext, "File \"%s\" uploaded into %s by %s.",
				      file, roomBuf.rbname, uname());
	    aideMessage(NO);
	    storeMessage(NULL, ERROR);
	}
	else
	    dunlink(file);
    }
    else
	mprintf("Can't create %s!\r", file);
    homeSpace();
}

/*
 * plural() - pluralise a message
 */
char *
plural(char *msg, long number)
{
    static char scratch[40];

    sprintf(scratch, "%ld %s%s", number, msg, (number!=1L)?"s":"");
    return scratch;
}

/*
 * showdays() - print a day_of_week mask
 *
 * The `oldstyle' kludge is necessary because the days bitmap used to look
 * like `xSSFRWTM'.  This has been changed (for simplicity elsewhere in the
 * code) to `xSFRWTMS'.  But to avoid having to convert netBuf.poll_day, we
 * kludge it.
 */
void
showdays(char mask, int oldstyle)
{
    int j;
    
    for (j=0; j<7; j++)
	if (mask & (1<<j))
	    mprintf(" %s", (oldstyle ? _alt_day[j] : _day[j]));
}

/*
 * dateok() -- is this item okay to print?
 *
 * Takes a time_t which represents midnight on the given date.
 */

int
dateok(time_t time)
{
    if ((dPass & dAFTER) && (DAY(time) < DAY(dAfterDate)))
	return NO;
    if ((dPass & dBEFORE) && (DAY(time) > DAY(dBeforeDate)))
	return NO;
    return YES;
}

/*
 * dl_not_ok() Check that this download can be done..
 */
int
dl_not_ok(long time, long size)
{
    long allowed;

    if (!onConsole) {
	if (evtRunning && isPreemptive(nextEvt) && timeLeft(evtClock) < time) {
	    mprintf("Not now.\r");
	    return YES;
	}
	allowed = cfg.download - logBuf.lbdownloadlimit;
	if (cfg.download && size > allowed) {
	    mprintf( (allowed>0) ? "Your download limit is %s\r"
				 : "You have exceeded your download limit\r",
		    plural("byte", allowed));
	    return YES;
	}
    }
    return NO;
}

/*
 * dlstat() - print a download statistics message
 */
void
dlstat(char *fname, long time, long size)
{
    mprintf("[ %s - ", fname);
    mprintf("%s", plural("byte", size));
    if (time) {
	mprintf(" - ");
	if (time > 59L)
	    mprintf("%s, ", plural("minute", time/60L));
	mprintf("%s", plural("second", time%60L));
    }
    mprintf(" ]\r");
}

/*
 * whazzit() - print a `huh' message on bad input
 */
void
whazzit(void)
{
    mprintf("?%s\r\r", readbit(logBuf,uEXPERT) ? "" : " (Type `?' for menu)");
    if (!onConsole)
	mflush();
}

/*
 * uname() - return user name or <anonymous>
 */
char *
uname(void)
{
    return loggedIn ? logBuf.lbname : "<anonymous>";
}

/*
 * initCitadel()
 */

static int lockfile;		/* multitasking lock semaphore	*/

void
initCitadel(void)
{
    PATHBUF sysfile;
    char temp[20];

    if (!(readSysTab(YES) && makelock(&lockfile)))	/* set up the system */
	exit(SYSOP_EXIT);				/* or bomb           */
#ifdef ATARIST
    sprintf(temp,"%lx\n", &active);		/* set up semaphore....	*/
    dwrite(lockfile, temp, strlen(temp));
    active = !multiTask;			/* run in background?	*/
#endif
    if (cfg.flags.FZAP)	checkloops = YES;
    if (cfg.flags.FNETLOG)	logNetResults = YES;
    if (cfg.flags.FNETDEB)	netDebug = YES;
    if (cfg.flags.DEBUG)	Debug = YES;

    if (statbar && !makebar())
	statbar = NO;

    /* Following are to allocate space for variable-sized parts of structures;
	added by AA 90Jan31 */
    initlogBuf(&logBuf);
    initlogBuf(&origlogBuf);
    initroomBuf(&roomBuf);
    initnetBuf(&netBuf);
    msgsentered = (int *)xmalloc(MAXROOMS * sizeof(int));
    indices = (struct Index *)xmalloc(MAXROOMS * sizeof(struct Index));

    systemInit();
    strcpy(oldTarget, "Aide");

    /* open message files: */
    ctdlfile(sysfile, cfg.msgdir, "ctdlmsg.sys");	msgfl = xopen(sysfile);
    ctdlfile(sysfile, cfg.sysdir, "ctdllog.sys");	logfl = xopen(sysfile);
    ctdlfile(sysfile, cfg.netdir, "ctdlnet.sys");	netfl = xopen(sysfile);

    /* set up network aliases */
    ctdlfile(sysfile, cfg.netdir, "alias.sys");
    net_alias = load_alias(sysfile);

    initArchiveList();		/* archived rooms, anyone? */
    loadfloor();		/* set up the floor table  */
    getRoom(LOBBY);		/* load Lobby>             */
    hangup();			/* Hang up the modem if necessary	*/
    haveCarrier = modStat = gotcarrier();
    onConsole = NO;		/* point input at the modem*/
}

/*
 * exitCitadel()
 */
void
exitCitadel(int status)
{
    hangup();				/* punt the current user	*/
    if (dropDTR)			/* enable the phone?		*/
	modemClose();
#ifdef ATARIST
    if (multiTask) {			/* detach the process		*/
	active = NO;
	pause(200);
    }
#endif
#ifdef BROWSER
    if (browse.list)			/* AA 91Jan24 */
	free(browse.list);
#endif
    systemShutdown();			/* reset the system		*/
    writeSysTab(); 			/* preserve citadel tables	*/
    if (statbar)
	killbar();			/* kill the status bar		*/
    wipelock(&lockfile);		/* clear the lockfile		*/
    killlogBuf(&logBuf);		/* kill variable sized buffers	*/
    killlogBuf(&origlogBuf);
    killroomBuf(&roomBuf);
    killnetBuf(&netBuf);
    exit(status);			/* and return			*/
}

