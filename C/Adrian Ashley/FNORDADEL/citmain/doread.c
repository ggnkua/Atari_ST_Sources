/*
 * doread.c -- menu .r(ead) command & support functions
 *
 * 91Jan23 AA	File browsing (.RM[ED]) and configurable archive header reader
 * 90Nov06 AA	Plugged in some stadel 3.4a stuff; also munged things for gcc
 * 88Jul11 orc	[D]ownload command hooked in
 * 87Nov03 orc	Extended protocol stuff put into rwProtocol()
 * 87Sep29 orc	permission checking for file access put into fileok()
 * 87Sep19 orc	.r(ead archive) h(eader) added.
 * 87Aug28 orc	Extracted from ctdl.c
 */

#include "ctdl.h"
#include "dirlist.h"
#include "protocol.h"
#include "dateread.h"
#include "browser.h"
#include "archiver.h"
#include "config.h"
#include "room.h"
#include "log.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

char WC;			/* WC mode rwProtocol returns	*/
char dPass = dEVERY;		/* for reading from a date	*/
time_t dAfterDate, dBeforeDate;	/* the date in stanard form	*/
char dFormatted = 0;		/* display formatted files	*/
static long FDSectCount;	/* size of files in directory	*/
static char FDextended;		/* list extended directory?	*/
int wantuser = NO;		/* for (.r)ead (u)ser		*/

#ifdef BROWSER
struct _browse browse = { NULL, 0, 0, 0, ERROR };
#endif

/*
 * readglobal() - core for read global-new
 */
static void
readglobal(void)
{
    do {
	mformat("\r\r");
	givePrompt();
	mprintf("Read new\r");
	showMessages(NEWoNLY, NO);
    } while (outFlag != OUTSKIP && nextroom('G') != ERROR && onLine());
}

/*
 * systat() - prints out current system status
 */
static void
systat(void)
{
    long size, allowed;
    int i, roomCount;
    char *mydate;

    for (roomCount = i = 0; i < MAXROOMS; i++)
	if readbit(roomTab[i],INUSE)
	    roomCount++;

    mprintf("\rThis is %s\r", &cfg.codeBuf[cfg.nodeTitle]);
    mydate = formDate();
    mprintf("%s, %s %s.\r", day_of_week(&now), mydate, tod(YES));
    mprintf("Running Fnordadel v%s-%d.\r", VERSION, PATCHNUM);
    mprintf("%s, last is %lu.\r",
	    plural("message", cfg.newest-cfg.oldest+1L), cfg.newest);
    size = ((long)(cfg.maxMSector) * (long)BLKSIZE) / 1024L;
    mprintf("%ldK message space, ", size);
    if (cfg.oldest > 1)
	size = ((long)cfg.maxMSector * (long)BLKSIZE)/(long)(cfg.newest-cfg.oldest+1L);
    else
	size = (((long)cfg.catSector * (long)BLKSIZE) + (long)cfg.catChar) / cfg.newest;
    mprintf("average message length is %ld characters.\r",  size);
    mprintf("%d-entry log.\r", cfg.logsize);
    mprintf("%d room slots, %d in use.\r", MAXROOMS, roomCount);
    mprintf("Chat is %sabled.\r", (cfg.flags.NOCHAT) ? "dis" : "en");

    if (loggedIn) {
	short privs = 0;

	mprintf("\rLogged in as %s.\r", logBuf.lbname);
	if (readbit(logBuf,uFLOORMODE))
	    mprintf("Using floor mode.\r");
	if (readbit(logBuf,uNETPRIVS) || readbit(logBuf,uMAILPRIV) ||
		readbit(logBuf,uDOORPRIV) ||
		readbit(logBuf,uAIDE) || readbit(logBuf,uSYSOP)) {
	    mprintf("You have the following privileges: ");
	    if readbit(logBuf,uNETPRIVS)
		mprintf("%snet (%s)", (privs++) ? ", " : "",
		    plural("net credit", (long)(logBuf.credit)) );
	    if readbit(logBuf,uMAILPRIV)
		mprintf("%smail", (privs++) ? ", " : "");
	    if readbit(logBuf,uDOORPRIV)
		mprintf("%sdoor", (privs++) ? ", " : "");
	    if readbit(logBuf,uSYSOP)
		mprintf("%sSysop", (privs++) ? ", " : "");
	    else if readbit(logBuf,uAIDE)
		mprintf("%sAide", (privs++) ? ", " : "");
	    mprintf(".\r");
	}
	if (cfg.download) {
	    allowed = (cfg.download - logBuf.lbdownloadlimit) / 1024L;
	    if (allowed > 0)
		mprintf("Your download limit is %ldK.\r", allowed);
	    else
		mprintf("You may not download anymore today.\r");
	}
	if (cfg.maxcalls) {
	    allowed = MAX(0L, (long)(cfg.maxcalls - logBuf.lbcalls));
	    mprintf("You have made %s today, ",
		plural("call", (long)logBuf.lbcalls));
	    mprintf("%s left.\r", readbit(logBuf,uAIDE) ? "unlimited" :
		plural("call", allowed));
	}
	if (cfg.maxtime) {
	    allowed = MAX(0L, (long)(cfg.maxtime - logBuf.lbtime -
		(MINUTE(time(NULL)) - MINUTE(logBuf.lblast))));
	    mprintf("You have used %s of connect time today, ",
		plural("minute", (long)(logBuf.lbtime + (MINUTE(time(NULL)) -
			MINUTE(logBuf.lblast)))));
	    mprintf("%s left.\r", readbit(logBuf,uAIDE) ? "unlimited" :
		plural("minute", allowed));
	}
	if (cfg.maxclosecalls && cfg.closetime) {
	    allowed = MAX(0L, (long)(cfg.maxclosecalls - logBuf.lbclosecalls));
	    mprintf("You have made %s today, ",
		plural("close call", (long)logBuf.lbclosecalls));
	    mprintf("%s left.\r", readbit(logBuf,uAIDE) ? "unlimited" :
		plural("close call", allowed));
	}
    }
}

/*
 * getpdate() -- get a date for reading from
 */
static int
getpdate(void)
{
    LABEL adate;

    if (dPass & dAFTER) {
	getNormStr("After what date", adate, NAMESIZE, YES);
	if (adate[0]) {
	    if ((dAfterDate = msgtime(adate, "12:00 am")) == ERROR) {
		mprintf("bad date\r");
		return NO;
	    }
	}
	else
	    dAfterDate = origlogBuf.lblast;   /* default: date of last call */
    }
    if (dPass & dBEFORE) {
	getNormStr("Before what date", adate, NAMESIZE, YES);
	if (adate[0]) {
	    if ((dBeforeDate = msgtime(adate, "12:00 am")) == ERROR) {
		mprintf("bad date\r");
		return NO;
	    }
	}
	else
	    dBeforeDate = origlogBuf.lblast;   /* default: date of last call */
    }
    return YES;	
}

/*
 * fileok() -- check download permissions
 */
static int
fileok(void)
{
    if readbit(roomBuf,ISDIR) {
	if ((readbit(roomBuf,DOWNLOAD) || SomeSysop()) && 
	    !(readbit(logBuf,uTWIT)))
	    return YES;
	else
	    mprintf("- You may not access the files in this room\r");
    }
    else
	mprintf("- This is not a directory room\r");
    return NO;
}

/* 
 * okbatch() - Confirm a batch transfer
 */
static int
okbatch(int count, struct dirList *list)
{
    int oldproto = usingWCprotocol;
    long sectors, time, bytes;
    char msg[80];
    int i;
    
    usingWCprotocol = ASCII;
    if (byteRate) {
	sectors = time = bytes = 0L;
	for (i=0;i<count;i++) {
	    bytes += list[i].fd_size;
	    sectors += (list[i].fd_size + (SECTSIZE-1))/(long)(SECTSIZE);
	}
	time = ((sectors+count) * 133L) / (long)(byteRate);
	if (dl_not_ok(time, bytes))
	    return NO;
	dlstat(plural("file", (long)count), time, bytes);
    }
    sprintf(msg, "Ready for %s batch download", protocol[oldproto]);
    if (getYesNo(msg)) {
	usingWCprotocol = oldproto;
	return YES;
    }
}

/* 
 * rwildcard() - for user-level file diddling
 */
static void
rwildcard(int (*fn)(struct dirList *), char *pattern, int protocol)
{
    int count;
    int oldproto = usingWCprotocol;

    if (xchdir(roomBuf.rbdirname)) {
	usingWCprotocol = protocol;
	count = wildcard(fn, pattern, batchWC ? okbatch : 0L);
	usingWCprotocol = oldproto;
	if (count == 0)
	    mprintf("No %s\r", pattern);
    }
}

/*
 * readfiles() read files.
 */
static void
readfiles(int protocol, char *fname)
{
    if (protocol != TODISK)
	rwildcard((protocol == ASCII) ? typefile : download, fname, protocol);
    else
	mprintf("Can't journal files!\r");
}

static int
readhdr(int arc, struct arcH *p)
{
    char tmp[28];
    register i;
    char c[1], version;

    c[0] = 0xff;
    if (dread(arc, c, 1) == 0L)
	return 0;
    if (c[0] != ARCMAGIC) {
abort:	mprintf("\rcorrupted archive!");
	return -1;
    }

    if (dread(arc, c, 1L) == 0L || c[0] == 0)
	return 0;
    if ((version = c[0]) < 0 || version > ARCVERSION)
	goto abort;

    if (version == 1) {
	dread(arc, p, (long)(sizeof(struct arcH)-sizeof(long)));
	p->a_length = p->a_size;
    }
    else {
	dread(arc, tmp, 27);

	for(i=0;i<AFLEN; (p->a_name[i] = tmp[i]),i++)
	    ;
	p->a_size = ((long)(0xff & tmp[16])<<24L)
		  + ((long)(0xff & tmp[15])<<16L)
		  + ((long)(0xff & tmp[14])<< 8L)
		  + ((long)(0xff & tmp[13])     );
	
	p->a_length = ((long)(0xff & tmp[26])<<24L)
		    + ((long)(0xff & tmp[25])<<16L)
		    + ((long)(0xff & tmp[24])<< 8L)
		    + ((long)(0xff & tmp[23])     );
    }
    return 1;
}

/*
 * arctoc() - print the toc of an .ARC file.
 */
static int
arctoc(struct dirList *fn)
{
    int f, i;
    struct arcH file;
    char *ext;
    LABEL filename;

    outFlag = OUTOK;

    strcpy(filename, fn->fd_name);
    ext = strrchr(filename, '.');
    ext++;

    if (Debug)
	xprintf("in arctoc(): ext == `%s'\n", ext);

    for (i=0; i<cfg.arch_count; i++) {
	if (Debug)
	    xprintf("in arctoc(): comparing with `%s'\n", archTab[i].extension);
	if ((stricmp(ext, archTab[i].extension) == 0) && archTab[i].doorptr) {
	    rundoor(archTab[i].doorptr, fn->fd_name);
	    mAbort();
	    return (outFlag != OUTSKIP);
	}
    }
    if (stricmp(ext, "arc") == 0) {
	if ((f = dopen(fn->fd_name, O_RDONLY)) >= 0) {
	    mprintf("\r%s:", fn->fd_name);
	    doCR();
	    while (readhdr(f, &file) > 0 && outFlag == OUTOK) {
		mprintf("%-14s%7ld ", file.a_name, file.a_length);
		dseek(f, file.a_size, 1);
	    }
	    doCR();
	    dclose(f);
	}
	else
	    mprintf("Cannot open %s.\r", fn->fd_name);
    }
    else
	mprintf("I don't recognise that file as an archive.\r");
    return (outFlag != OUTSKIP);
}

#ifdef BROWSER
static void
browser(struct dirList *fn)
{
    brList *p, *q;
    char c;
    char fname[14];
    char *totmarkmsg = "Total marked file size = %d bytes.\r";
    register int i;
    long allowed;
    size_t size;

prompt:
    iprintf("\rBrowse cmd%s: ", readbit(logBuf,uEXPERT) ? "" :
			" ([N]ext, [M]ark for transfer, e[X]it, [?]=menu)");
    while (onLine()) {
	switch (c = toupper(getnoecho())) {
	case 'A': iprintf("Again\r");	outFlag = OUTAGAIN;	return;
	case 'B': iprintf("Backup\r");	outFlag = OUTBACKUP;	return;
	case 'C':
		iprintf("Batch list cleared.\r");
		free(browse.list);
		browse.list = NULL;
		browse.count = browse.numalloc = browse.limit = 0;
		browse.user = ERROR;
		goto prompt;
	case 'H':
		iprintf("Archive header:\r");
		arctoc(fn);
		goto prompt;
	case 'M':
		p = browse.list;
		i = 0;
		while (i < browse.count) {
		    if (stricmp(fn->fd_name, p->br_name) == 0)
			break;
		    p++; i++;
		}
		if (i < browse.count) {		/* found it */
		    iprintf("Already marked %s.\r", fn->fd_name);
		    goto prompt;
		}

		allowed = cfg.download - (browse.limit + logBuf.lbdownloadlimit);
		if (cfg.download && fn->fd_size > allowed) {
		    mprintf("Adding this file would exceed your download limit.\r");
		    mprintf("Your remaining download limit is %s.\r",
			plural("byte", allowed));
		    goto prompt;
		}

		i = browse.count;
		if (i == browse.numalloc) {
		    size = (10 + i) * sizeof(brList);
		    browse.list = (browse.list
				   ? (brList *)realloc(browse.list, size)
				   : (brList *)xmalloc(size));
		    if (!browse.list) {
			iprintf("out of memory!\r");
			browse.count = browse.numalloc = browse.limit = 0;
			browse.user = ERROR;
			return;
		    }
		    browse.numalloc += 10;
		}

		browse.list[i].br_size = fn->fd_size;
		strcpy(browse.list[i].br_name, fn->fd_name);
		browse.list[i].br_room = thisRoom;
		browse.limit += fn->fd_size;
		browse.count++;
		browse.user = logindex;
		iprintf("%s marked for batch transfer.\r", fn->fd_name);
		mprintf(totmarkmsg, browse.limit);
		goto prompt;
	case ' ':
	case '\n':
	case 'N': iprintf("Next\r");				return;
	case 'U':
		iprintf("Unmark file\rEnter file name: ");
		getNormStr("", fname, 14, YES);
		p = browse.list;
		i = 0;
		while (i < browse.count) {
		    if (stricmp(fname, p->br_name) == 0)
			break;
		    p++; i++;
		}
		if (i < browse.count) {			/* Found it */
		    if (browse.count == 1) {		/* Only 1 item */
			free(browse.list);
			browse.list = NULL;
			browse.count = browse.numalloc = browse.limit = 0;
			browse.user = ERROR;
		    }
		    else if (i == browse.count - 1) {	/* Last item */
			browse.limit -= p->br_size;
			browse.count--;
		    }
		    else {
			i++;		/* Point to item after unmarked one */
			/* q = p + 1; */

			browse.limit -= p->br_size;
			while (i < browse.count) {	/* Shuffle items down */
			    /* copy_array(q, p); */	/* src, dest */
			    memcpy(&browse.list[i-1], &browse.list[i],
				sizeof(brList));	/* dest, src, size */
			    /* q++; p++; i++; */
			    i++;
			}
			browse.count--;
		    }
		    iprintf("%s unmarked.\r", fname);
		}
		else
		    iprintf("%s not found.\r", fname);

		goto prompt;
	case 'V':
		iprintf("View batch list:\r");
		if (browse.count == 0)
		    mprintf("No files marked.\r");
		else {
		    for (i = 0; i < browse.count; i++)
			mprintf("%-24s%-16s%8ld\r",
			    roomTab[browse.list[i].br_room].rtname,
			    browse.list[i].br_name, browse.list[i].br_size);
		    mprintf(totmarkmsg, browse.limit);
		}
		goto prompt;
	case 'Q':
	case 'S':
	case 'X': iprintf("Exit\r"); outFlag = OUTSKIP;		return;
	case '?':
		menu("browser");
		goto prompt;
	}
	oChar(BELL);
    }
}

/* 
 * ok_browse_batch() - Confirm a batch transfer
 */
static int
ok_browse_batch(int count, brList *list)
{
    int oldproto = usingWCprotocol;
    long sectors, time, bytes;
    char msg[80];
    int i;
    
    usingWCprotocol = ASCII;
    if (byteRate) {
	sectors = time = bytes = 0L;
	for (i=0;i<count;i++) {
	    bytes += list[i].br_size;
	    sectors += (list[i].br_size + (SECTSIZE - 1)) / (long)(SECTSIZE);
	}
	time = ((sectors + count) * 133L) / (long)(byteRate);
	dlstat(plural("file", (long)count), time, bytes);
    }
    sprintf(msg, "Ready for %s batch download", protocol[oldproto]);
    if (getYesNo(msg)) {
	usingWCprotocol = oldproto;
	return YES;
    }
}

void
browse_batch_dl(int protocol)
{
    register int i;
    register brList *p = browse.list;
    struct dirList fn;
    int oldproto = usingWCprotocol;
    int oldroom = thisRoom;
    int status = YES;

    usingWCprotocol = protocol;
    if (!ok_browse_batch(browse.count, browse.list)) {
	usingWCprotocol = oldproto;
	return;
    }    

    for (i=0; status && i < browse.count; i++) {
	strcpy(fn.fd_name, p->br_name);
	fn.fd_size = p->br_size;
	fn.fd_date = p->br_date;
	if (p->br_room != thisRoom) {
	    getRoom(p->br_room);
	    xchdir(roomBuf.rbdirname);
	}
	status = download(&fn);
	p++;
    }
    if (batchWC && (usingWCprotocol == YMODEM || usingWCprotocol == XMODEM))
	sendYhdr(NULL, 0L);
    batchWC = NO;
    usingWCprotocol = oldproto;

    free(browse.list);
    browse.list = NULL;
    browse.limit = browse.count = browse.numalloc = 0;
    browse.user = ERROR;
    getRoom(oldroom);
    return;
}

#endif BROWSER

/*
 * printdir() -- prints out one filename and size, for a dir listing
 */
static dirxp, dircols;

static int
printdir(struct dirList *fn)
{
    char *desc;

    if (fn->fd_name[0] != '.'){	/* don't print things that start with a . */
	strlwr(fn->fd_name);
	outFlag = OUTOK;

	if (FDextended)
	    desc = getTag(fn->fd_name);

	if (FDextended) {
	    CRftn = retfmt;
	    CRfill = "%31c: ";
	    mprintf("%-13s%7ld : ", fn->fd_name,fn->fd_size);
	    mprintf("%02d%s%02d : ", fn->fd_date.year,
			monthTab[fn->fd_date.mon + 1], fn->fd_date.mday);
	    if (desc)
		mformat(desc);
	    CRftn = NULL;
	    doCR();
	}
	else
	    mprintf("%-14s%7ld%c", fn->fd_name, fn->fd_size,
				(((++dirxp)%dircols) == 0) ? '\r' : ' ');
	FDSectCount += fn->fd_size;
#ifdef BROWSER
	if (singleMsg)
	    browser(fn);	/* handle .RM[ED] */
	else {
#endif
	    mAbort();		/* chance to next(!)/pause/skip */
	    /* This routine is called only by wildcard(), which ignores	*/
	    /* all outFlag modes except OUTBACKUP.  OUTBACKUP makes	*/
	    /* sense only in singleMsg mode, so clear it if set here.	*/
	    if (outFlag == OUTBACKUP)
		outFlag = OUTOK;
	}
    }
    return (outFlag != OUTSKIP);
}

/*
 * readdir() -- read the directory.
 */
static void
readdir(char *fname)
{
    long sectors, bytes;

#ifdef BROWSER
    /* Nuke the browser list if this is a different user */
    if (browse.count && logindex != browse.user) {
	browse.limit = browse.count = browse.numalloc = 0;
	browse.user = ERROR;
	if (browse.list != NULL) {
	    free(browse.list);
	    browse.list = NULL;
	}
    }
#endif

    if (xchdir(roomBuf.rbdirname)) {
	dirxp = 0;
	dircols = (logBuf.lbwidth < 23) ? 1 : (logBuf.lbwidth/23);
	if (FDextended)
	    tagSetup();
	FDSectCount = 0L;
	wildcard(printdir, strlen(fname) ? fname : "*.*", 0L);
	if (FDextended)
	    tagClose();
	if (dirxp%dircols)
	    doCR();

	mprintf("%s total.\r", plural("byte", FDSectCount));
	if (onConsole || (cfg.flags.DISKUSAGE)) {
	    diskSpaceLeft(roomBuf.rbdirname, &sectors, &bytes);
	    mprintf("%s free in %s\r", plural("byte", bytes), roomBuf.rbdirname);
	}
	if (outFlag == OUTSKIP) {
	    outFlag = OUTOK;
	    doCR();
	}
    }
}

/*
 * rwProtocol() - Figure out what protocol to use for a r/w command.
 */
int
rwProtocol(char cp)
{
    switch (cp) {
    case 'V': WC = VANILLA;	break;
    case 'Y': WC = YMODEM;	break;
    case 'W': WC = WXMODEM;	break;
    case 'X': WC = XMODEM;	break;
    default : return NO;
    }
    mprintf("%s ", protocol[WC]);
    return YES;
}

/*
 * initWC() -- set up for a protocol download
 */
int
initWC(int mode)
{
    int started = 0;
    char msg[80];

    if (mode == ASCII)
	return 1;
    sprintf(msg, "Ready for %s download", protocol[mode]);
    if (mode == TODISK || getYesNo(msg)) {
	if (mode != TODISK && mode != CAPTURE)
	    iprintf("Hit ^X once or twice to cancel...\n");
	usingWCprotocol = mode;
	started = beginWC();
	if (!started)
	    usingWCprotocol = ASCII;
    }
    return started;
}

/*
 * doRead() - do the R(ead) command.
 *
 * The argument `hack' is for calling doread with special commands like `d',
 * `f', `o', `n', etc.
 */

#define	MESSAGE	0	/* .r[nora] */
#define	GLOBAL	1	/* .rg */
#define	STATUS	2	/* .rs */
#define	DIR	3	/* .rd, .re */
#define	HEADER	4	/* .rh */
#define	FILES	5	/* .rf, .rb */
#define	INVITED	6	/* .ri */
#define	SINGLE	7	/* .r<number>	*/
#define BROWSE_DL 8	/* .rb with browse list */

void
doRead(int prefix, int hack, char cmd)
{
    char fname[80];
    int which, reversed;
    int i, count;
    struct logBuffer lbuf;
    int reading = MESSAGE;	/* what sort of thing we're reading	*/
    int explicitmore = NO;	/* did user enter [M]ore (vs. default)	*/
    int msgNo;			/* for read <number>			*/
    long atol();		/* ditto				*/
    int negated = NO;		/* next command to be negated?		*/
    char *negatables = "LMUI~";	/* commands which can be negated	*/

    switch (hack) {
	case 0:
	case 1: mprintf("read ");	break;
	case 2: mprintf("download ");	break;
	case 4: doCR();			break;
    }

    msguser[0] = dFormatted = justLocals = reversed = batchWC = wantuser = 0;
    dPass = dEVERY;
    which = (hack == 4) ? 0xf0 : 0;

#if 1	/* moved the MAILROOM part of this in from showMessages() [msg.c] */
    singleMsg = ((thisRoom == MAILROOM && which == NEWoNLY)
		 || readbit(logBuf,uREADMORE));
#else
    singleMsg = readbit(logBuf,uREADMORE);
#endif

    WC = ASCII;

    if (!(loggedIn || (cfg.flags.READOK) || onConsole) ) {
	if (thisRoom == MAILROOM)
	    showMessages(NEWoNLY, 0);
	else
	    mprintf("- [L]og in first!\r");
	return;
    }

    if (prefix) {
	while (prefix && onLine() && (cmd=toupper(getnoecho())) ) {
	    /*
	     * If we've already hit '~' but the next command isn't
	     * negatable, un-negate.
	     */
	    if (negated && (strchr(negatables, cmd) == NULL)) {
		mprintf("\b\b\b\b");
		negated = NO;
	    }
	    if (!rwProtocol(cmd)) {
		switch(cmd) {
		    case '~':
		    	mprintf(negated ? "\b\b\b\b" : "not-");
			negated = !negated;				break;
		    case 'T':
			mprintf("text ");	dFormatted = YES;	break;
		    case 'L':
			mprintf("local-only ");
			justLocals = (negated ? ERROR : YES);
			negated = NO;					break;
		    case 'M':
		    	mprintf("more ");
			singleMsg = (negated ? NO : YES);
			explicitmore = YES;
			negated = NO;					break;
		    case 'U':
			mprintf("user ");
			wantuser = (negated ? ERROR : YES);
			negated = NO;					break;
		    case '+':
			mprintf("after ");	dPass |= dAFTER;	break;
		    case '-':
			mprintf("before ");	dPass |= dBEFORE;	break;
		    case 'C':
			mprintf("%s ", protocol[WC=CAPTURE]);		break;
		    case '=':
			mprintf("headers ");	which = 0xf0;		break;
		    case 'J':
			if (SomeSysop()) {
			    mprintf("%s ", protocol[WC=TODISK]);
			}						break;
		    case '\n':
		    	whazzit();
			goto out;
		    default:
			prefix = NO;					break;
		}
	    }
	}
    }
    else
	cmd = toupper(cmd);

    /* KLUDGE! Arooooga! */
    if (negated && cmd != 'I') {
    	mprintf("\b\b\b\b");
	negated = NO;
    }

    switch (cmd) {
#if 0
    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
	    fname[0] = cmd;
	    oChar(cmd);
	    _getstring(fname, 1, NAMESIZE, 0, YES);
#else
    case '#':
	    mprintf("message ID #\r");
	    getNormStr("Enter message ID #", fname, NAMESIZE, YES);
#endif
	    if (fname[0])
		if ((msgNo=pick1mesg(atol(fname))) == ERROR)
		    mprintf("Can't find message!\r");
		else {
		    reading=SINGLE;
		    break;
		}
	    return;
    case 'A':
	    mprintf("all\r");
	    which |= OLDaNDnEW;
	    break;
    case 'R':
	    mprintf("reverse\r");
	    reversed = YES;
	    which |= OLDaNDnEW;
	    break;
    case 'N':
	    mprintf("new");
    case '\n':
	    mprintf("\r");
	    which |= NEWoNLY;
	    break;
    case 'O':
	    mprintf("old Reverse\r");
	    reversed = YES;
	    which |= OLDoNLY;
	    break;
    case 'G':
	    mprintf("global new-messages\r");
	    if (readbit(logBuf, uTWIT))		/* Don't let twits .RG */
		which |= NEWoNLY;
	    else
		reading = GLOBAL;
	    /* KLUDGE: cancel the implicit M(ore) that you get by doing a
	     * .Read command in the Mail room.  (Unless we ASKED for M(ore),
	     * of course.)
	     */
	    if (singleMsg && thisRoom == MAILROOM
			&& !readbit(logBuf,uREADMORE) && !explicitmore)
		singleMsg = NO;
	    break;
    case 'D':
    case 'E':
	    if (fileok()) {
		FDextended = (cmd == 'E');
		mprintf("%sdirectory ", FDextended?"extended ":"");
		if (!readbit(logBuf,uEXPERT))
		    iprintf("\rEnter file name (* and ? wildcards optional; CR=all files): ");
		getNormStr("", fname, 80, YES);
		wantuser = NO;
		reading = DIR;
		if (!explicitmore)
		    singleMsg = NO;	/* Never default to browser mode */
		break;
	    }
	    else return;
    case 'S':
	    mprintf("status\r");
	    reading = STATUS;
	    dPass = dEVERY;
	    wantuser = NO;
	    break;
    case 'F':					/* [F] and (.F) stay..	*/
	    if (hack == 1) {			/* but .ra takes the	*/
		mprintf("forward\r");		/* place of .rf		*/
		which |= OLDaNDnEW;
		break;
	    }
	    else if (fileok()) {
		if (hack == 2)		/* single-key entry */
		    switch ((logBuf.flags & (uPROTO1|uPROTO2|uPROTO3)) >> 10) {
			case 0: WC = XMODEM;	break;
			case 1: WC = YMODEM;	break;
			case 2: WC = WXMODEM;	break;
			default: WC = XMODEM;	break;
		    }
		mprintf("file ");
		if (!readbit(logBuf,uEXPERT))
		    iprintf("\rEnter file name (* and ? wildcards optional): ");
		getNormStr("", fname, 80, YES);
		if (strlen(fname) < 1) return;
		wantuser = NO;
		reading = FILES;
		break;
	    }
	    return;
    case 'B':
	    if (fileok()) {
		batchWC = (WC == YMODEM || WC == XMODEM);
		mprintf("b%s file ", batchWC?"atch":"inary");
		if (!readbit(logBuf,uEXPERT))
		    iprintf("\rEnter file name (* and ? wildcards optional): ");
		getNormStr("", fname, 80, YES);
		wantuser = NO;
		if (strlen(fname) < 1)
#ifdef BROWSER
		    if (batchWC && browse.count) {
			reading = BROWSE_DL;
			break;
		    }
		    else
#endif
			return;
		reading = FILES;
		break;
	    }
	    return;
    case 'H':
	    if (fileok()) {
		mprintf("archive header ");
		if (!readbit(logBuf,uEXPERT))
		    iprintf("\rEnter file name (* and ? wildcards optional): ");
		getNormStr("", fname, 80, YES);
		if (strlen(fname) < 1) return;
		wantuser = NO;
		reading = HEADER;
		break;
	    }
	    return;
    case 'I':
	    if (!readbit(roomBuf,PUBLIC)) {
		mprintf("invited users\r");
		wantuser= NO;
		dPass   = dEVERY;
		reading = INVITED;
		break;
	    }
    case '?': menu("readopt");		goto out;
    default:  whazzit();		goto out;
    }
    if (wantuser) {
	getNormStr("Which user", msguser, NAMESIZE, YES);
	if (msguser[0] == 0)
	    goto out;
    }

    if (!getpdate())
	return;

#ifdef BROWSER
    if (reading == DIR && singleMsg)	/* AA 91Jan23 */
	FDextended = YES;
#endif

    if (reading == FILES)
	readfiles(WC, fname);
#ifdef BROWSER
    else if (reading == BROWSE_DL)
	browse_batch_dl(WC);
#endif
    else {
	if (!initWC(WC))
	    return;
	switch (reading) {
	default:     showMessages(which, reversed);	break;
	case SINGLE: read1mesg(msgNo, ERROR);		break;
	case HEADER: rwildcard(arctoc, fname, WC);	break;
	case STATUS: systat();				break;
	case DIR:    readdir(fname);			break;
	case GLOBAL: readglobal();			break;
	case INVITED:
	    initlogBuf(&lbuf);
	    for (i=0; outFlag == OUTOK && i < cfg.logsize; i++) {
		getlog(&lbuf, i, logfl);
		if (readbit(lbuf,uINUSE)
		    && ((roomBuf.rbgen == LBGEN(lbuf,thisRoom) && !negated)
			|| (roomBuf.rbgen != LBGEN(lbuf,thisRoom) && negated))
		   )
		    mprintf("%s  ", lbuf.lbname);
	    }
	    killlogBuf(&lbuf);
	    doCR();
	    if (outFlag == OUTSKIP) {
		outFlag = OUTOK;
		mprintf("\r\r");
		outFlag = OUTSKIP;
	    }
	    break;
	}
	if (WC != ASCII)
	    endWC();
	usingWCprotocol = ASCII;
    }
out:dPass = dEVERY;
    singleMsg = 0;		/* be paranoid */
    msguser[0] = 0;
}
