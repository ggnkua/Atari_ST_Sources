/*
 * ctdl.c -- Main user interface routines.
 *
 * 90Nov09 AA	Munged in some 3.4a stuff plus gcc hacks
 * 88Aug13 orc	add +ymodem flag for preferring ymodem networking
 * 88Jul13 orc	doSysop() extracted from ctdl.c
 * 88Jul08 orc	doEnter() and friends extracted from ctdl.c
 * 88Feb05 orc	`Z' command added for autodialing
 * 88Jan08 orc	`Y' display changed for day-selectable events
 *		local functions staticised
 * 87Oct07 orc	`+hup' option on command line for people who don't want
 *		the phone disabled when in console mode
 * 87Aug29 orc	doChat() rewritten.
 * 87Aug28 orc	doRead() and friends extracted from ctdl.c
 * 87Aug16 orc	Paranoid mode.
 * 87Aug12 orc	Floors.
 * 87Aug08 orc	drop DTR when in CONSOLE mode
 * 87Apr10 orc	total rewrite of file upload/download commands.
 * 87Apr01 orc	new file tag regime.
 * 87Mar29 orc	rewriting some of the read/enter code.
 * 87Mar28 orc  adding more enhancements.
 * 87Jan24 orc	reported after initial rewrite destroyed...
 * 86Aug16 HAW	Kill history for file because of space problems.
 * 84May18 JLS/HAW Greeting modified for coherency.
 * 84Apr04 HAW	Upgrade to BDS 1.50a begun.
 * 83Mar08 CrT	Aide-special functions installed & tested...
 * 83Feb24 CrT/SB Menus rearranged.
 * 82Dec06 CrT	2.00 release.
 * 82Nov05 CrT	removed main() from room2.c and split into sub-fn()s
 */

#include "ctdl.h"
#include "net.h"
#include "event.h"
#include "calllog.h"
#include "protocol.h"
#include "floor.h"
#include "msg.h"
#include "log.h"
#include "config.h"
#include "room.h"
#include "terminat.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

/*
 * doChat()		C(hat) command
 * doAide()		Aide-only commands
 * doForget()		Z(Forget room) command
 * doHelp()		H(elp) command
 * doKnown()		K(nown rooms) command
 * doLogout()		T(erminate) command
 * ungoto()		U(ngoto) command
 * inituserlist()	initialise a userlist for purging, restrict, etc
 * initfnord()		load the <fnord>s
 * doFnord()		confuse people
 * doRegular()		fanout for above commands
 * greeting()		System-entry blurb etc
 * getCommand()		prints prompt and gets command char
 * main()		has the central menu code
 */

long _stksize = 10240L;

char	Abandon = NO;		/* True when time to bring system down	*/
char	eventExit = NO;		/* true when an event goes off		*/
char	dropDTR = YES;		/* hang up phone when in console mode	*/
char	netymodem = NO;
#ifdef ATARIST
char	multiTask = NO;		/* run as a background multitasker?	*/
#endif
char	statbar = NO;		/* disable the status bar		*/
char	restrict = NO;		/* implement login restrictions?	*/
char	msgpurge = NO;		/* implement msg purge after logoff?	*/
static char	backup = NO;		/* use the 'backup' command?	*/
char	Debug;			/* normal debugging			*/
int	exitValue = CRASH_EXIT;
char	doormode = NO;		/* are we being run as a door?		*/
char	chatrequest = NO;	/* user wants to chat?			*/

FILE *debuglog = NULL;		/* general debugging stuff */

char	confirm[] = "confirm";

/* fnords added in a fit of silliness by AA 89Feb11 */
/* ...loading of fnords made dynamic by AA 91Jun03 */
char	**fnords;
int	numfnords = 0;

/* message purging added in a fit of pique by AA 89Dec11 */
struct user *purgelist;
int	numpurge = 0;

/* User login restrictions added in a fit of foresight by RH 89Dec21 */
struct user *restlist;
int	numrestrict = 0;

/*
 * doChat()
 */
static void
doChat(int nochat)
{
    mprintf("chat");

    if (onConsole) {
	chatrequest = NO;
	putchar('\n');
	connect(conGetYesNo("Echo to modem"),
		conGetYesNo("Echo keyboard"),
		conGetYesNo("Echo CR as CRLF"));
    }
    else if (nochat || !active) {
	chatrequest = YES;
	if (!blurb("nochat", NO))
	    mprintf("- The sysop's not around\r");
    }
    else
	ringSysop();
}

/*
 * doAide() handles the aide-only menu
 *
 * return NO to fall into default error msg
 */
static int
doAide(int prefix, int cmd)
{
    LABEL oldName;
    PATHBUF fn;
    int rm, oldrm;
    int i;

    if (!readbit(logBuf,uAIDE))
	return NO;

    mprintf("aide ");

    switch (cmd=toupper(prefix ? getnoecho() : cmd)) {
    case 'C':
	doChat(NO);
	break;
    case 'D':
	sprintf(msgBuf.mbtext, "The following empty rooms deleted by %s: ",
						uname());
	i = strlen(msgBuf.mbtext);
	mprintf("delete empty rooms\r");
	oldrm = thisRoom;
	indexRooms();
	getRoom(readbit(roomTab[oldrm],INUSE) ? oldrm : LOBBY);

	if (strlen(msgBuf.mbtext) > i)	/* don't create message in aide */
	    aideMessage(NO);		/* unless something died        */
	break;
    case 'E':
	mprintf("edit room");
	editroom();
	break;
#if 0
    case 'I':
	mprintf("insert message- ");
/* MAILROOM disallowed by AA 90Jul20 */
	if (thisRoom == MAILROOM || thisRoom == AIDEROOM || pullMId == 0L) {
	    mprintf("nope!\r");
	    break;
	}
	if (!getNo(confirm))
	    break;
	note2Message(pullMId, pullMLoc);
	noteRoom();
	putRoom(thisRoom);
	sprintf(msgBuf.mbtext, "Following message inserted in %s> by %s",
				roomBuf.rbname, uname());
	aideMessage(YES);
	break;
#endif
    case 'K':
	mprintf("kill room - ");
	if (!(cfg.flags.AIDEKILLROOM) && !SomeSysop()) {
	    mprintf("sorry, the Sysop has disabled this Aide command.\r");
	    break;
	}
	if (thisRoom==LOBBY || thisRoom==MAILROOM || thisRoom==AIDEROOM) {
	    mprintf("not %s!\r", formRoom(thisRoom, NO));
	    break;
	}
	if (!getNo(confirm))
	    break;

	sprintf(msgBuf.mbtext, "%s killed by %s", formRoom(thisRoom, YES),
	    uname());
	aideMessage(NO);

	clear(roomBuf,INUSE);

	clear(roomBuf,DESCRIPTION);
	ctdlfile(fn, cfg.roomdir, "room%04d.inf", thisRoom);
	dunlink(fn);

	noteRoom();
	putRoom(thisRoom);
	updtfloor();			/* Wipe out floor if now empty */
	thisFloor = LOBBYFLOOR;
	getRoom(LOBBY);
	break;
    case 'S':
	setclock();
	break;
    case '?':
	menu("aide");
	break;
    default:
	whazzit();
	break;
    }
    return YES;
}

/*
 * doForget() -- Forget a room
 */
static void
doForget(int prefix)
{
    int floorsave;

    if (prefix) {
	floorsave = readbit(logBuf,uFLOORMODE);
	clear(logBuf,uFLOORMODE);

	if (floorsave) {

/* TODO:    lFloor(l_FGT|l_LONG); */

	    listRooms(l_FGT);
	    set(logBuf,uFLOORMODE);
	}
	else
	    listRooms(l_FGT);
    }
    else {
	mprintf("forget");
	if (thisRoom==LOBBY || thisRoom==MAILROOM || thisRoom==AIDEROOM) {
	    mprintf("- not %s\r", formRoom(thisRoom,NO));
	    return;
	}
	mprintf(" %s - ", roomBuf.rbname);
	if (getNo(confirm)) {
	    logBuf.lbgen[thisRoom] = 
			((roomBuf.rbgen + FORGET_OFFSET) % MAXGEN) << GENSHIFT;
	    getRoom(LOBBY);
	}
    }
}

/*
 * doHelp() -- Ask for help
 */
static void
doHelp(int prefix)
{
    LABEL topic;

    mprintf("help ");
    if (prefix) {
	getNormStr("", topic, 9, YES);
	if (strlen(topic) == 0)
	    hothelp("dohelp");
	else if (topic[0] == '?')
	    hothelp("topics");
	else
	    hothelp(topic);
    }
    else
	hothelp("dohelp");
}

/*
 * doinfo() -- handle the room Information command
 */
static void
doinfo(int prefix)
{
    PATHBUF fn;
    FILE *spl;

    ctdlfile(fn, cfg.roomdir, "room%04d.inf", thisRoom);
    if (thisRoom == MAILROOM || !readbit(roomBuf,DESCRIPTION) ||
		((spl = safeopen(fn, "rb")) == NULL)) {
	mprintf("no info for this room\r");
    }
    else {
	getspool(spl);
	fclose(spl);
	mprintf("Room information:\r");
	printdraft();
	doCR();
    }
    doCR();
    if (readbit(logBuf, uAIDE)) {
	roomreport(msgBuf.mbtext);
	mprintf("This is %s.\r", msgBuf.mbtext);
	if (SomeSysop() && readbit(roomBuf, SHARED))
	    whosnetting();
	doCR();
    }
    statroom();
    return;
}

/*
 * doKnown() -- List Known rooms
 */
static void
doKnown(int prefix)
{
    short mode = l_NEW|l_OLD|l_LONG;
    register unsigned int c;
    int floorsave = 0;

    target[0] = 0;
    iprintf("known ");
    if (prefix) {
	while ((c=toupper(getnoecho())) != '\n' && onLine())
	    switch (c) {
	    case 'D': iprintf("directory "); mode |= x_DIR;	break;
	    case 'P': iprintf("public "); mode |= x_PUB;	break;
	    case 'H': iprintf("hidden "); mode |= x_PRIV;	break;
	    case 'N': iprintf("network "); mode |= x_NET;	break;
	    case 'R': getString("rooms", target, NAMESIZE, 0, YES); goto doit;
	    case '?': menu("known");				return;
	    default:  whazzit();				return;
	}
	floorsave = readbit(logBuf,uFLOORMODE);
	clear(logBuf,uFLOORMODE);
    }
    mprintf("rooms ");
    mprintf(!readbit(logBuf,uFLOORMODE) ? "\r" :
				"in [%s]\r",floorTab[thisFloor].flName);
doit:
    if (prefix && floorsave)
	lFloor(mode);
    else
	listRooms(mode);
    if (floorsave)
	set(logBuf,uFLOORMODE);
}

/*
 * doLogout()
 */
static void
doLogout(int prefix, int cmd)
{

    if (loggedIn && heldMessage && !(cfg.flags.KEEPHOLD))
	mprintf("WARNING: You have a held message!\r");

    mprintf("terminate ");

    switch (toupper(prefix ? getnoecho() : cmd)) {
    case '?':
	menu("logout");
	break;
    case 'Y':
	if (prefix)
	    mformat("yes\r");
	else {
	    mformat("- ");
	    if (!getNo(confirm))
		break;
	}
	terminate(YES, tNORMAL);
	break;
    case 'Q':
	mformat("quit\r");
	terminate(YES, tNORMAL);
	break;
    case 'P':
	mformat("punt\r");
	terminate(YES, tPUNT);
	break;
    case 'S':
	mformat("stay\r");
	terminate(NO, tSTAY);
	break;
    default:
	whazzit();
    }
}

/*
 * ungoto() - back up to a previous room.
 */
static void
ungoto(int prefix, char *message)
{
    LABEL target;
    register slot;

    mprintf("%s ", message);
    if (prefix) {
	getNormStr("", target, NAMESIZE, YES);
	if (target[0]) {
	    if ((slot = gotoname(target)) == ERROR) {
		mprintf("No %s room.\r", target);
		return;
	    }
	}
	else {
	    mprintf("No room specified.\r");
	    return;
	}
    }
    else {
	doCR();
	if (lastRoom == -1) {
	    mprintf("No room to %s to!\r", message);
	    return;
	}
	slot = lastStack[lastRoom--];
    }

    getRoom(slot);
    indices[slot].visited = iNEVER;
    logBuf.lbgen[slot] = indices[slot].lastgen;
    statroom();
}

/*
 * inituserlist() - load a list of usernames into a linked list.
 *
 * Returns the number of names entered into the list.
 */
static int
inituserlist(struct user **list, char *filename)
{
    PATHBUF line;
    FILE *f;
    struct user *i = NULL, *p;
    int count = 0;

    *list = (struct user *)NULL;
    ctdlfile(line, cfg.sysdir, filename);
    if (f=safeopen(line, "r")) {
	while (fgets(line, 20, f)) {
	    if (strlen(line) > 2) {
		count++;
		line[strlen(line) - 1] = 0;
		p = (struct user *)xmalloc(sizeof(struct user));
		strcpy(p->name, line);
		p->next = (struct user *)NULL;
		if (!(*list)) {
		    *list = p;
		    i = p;
	        }
		else {
		    i->next = p;
		    i = p;
		}
	    }
	}
	fclose(f);
    }
    return count;
}

/*
 * initfnord() -- Load in fnords
 */
static void
initfnord(void)
{
    char line[180], *p;
    FILE *f;
    int len;

    numfnords = 0;
    fnords = (char **) NULL;

    ctdlfile(line, cfg.sysdir, "fnord.sys");

    if (f = safeopen(line, "r")) {
	while (fgets(line, 180, f)) {
	    len = strlen(line);
	    if (len < 1)
		continue;
	    line[len - 1] = 0;			/* nuke trailing newline */
	    if ((numfnords % 10) == 0) {
		fnords = (char **) realloc(fnords, ((numfnords / 10 + 1) * 10
							* sizeof(char *)));
		if (fnords == NULL) {
		    xprintf("out of memory loading <fnord>s!\n");
		    numfnords = 0;
		    return;
		}
	    }
	    p = (char *) xmalloc(len + 1);
	    if (p == NULL) {
		xprintf("out of memory loading <fnord>s!\n");
		return;
	    }
	    fnords[numfnords] = p;
	    strcpy(p, line);
	    numfnords++;
	}
	fclose(f);
    }
}

/*
 * doFnord -- Spit out random msg
 */
static void
doFnord(void)
{
	static int oldfnord = 0;
	int i;

	for (;;) {
	    i = (int)Random();
	    i = (ABS(i) % numfnords); 
	    if (i != oldfnord)
		break;
	}
	oldfnord = i;
	mprintf("<fnord><%s>\r", fnords[i]);
}

/*
 * doRegular()
 */
#define MAX_USER_ERRORS 25

static char
doRegular(int prefix, int c)
{
    static int errorCount = 0;
    LABEL target;

    if (readbit(logBuf,uTWIT) && (strchr("CD!", c) || (backup && c == 'U')))
	return YES;

    switch (c) {
#if 0
    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
#else
    case '#':
#endif
		doRead(NO, 0, c);
		break;
    case 'C': doChat((cfg.flags.NOCHAT));	break;
    case 'D': doRead(NO, 2, 'f');	break;
    case 'E': doEnter(prefix, 'm');	break;
    case 'F': doRead(NO, 1, 'f');	break;
    case 'S':   mprintf("skip %s> ", roomTab[thisRoom].rtname);
    case 'G':   mprintf("goto ");
		if (prefix) {
		    getNormStr("", target, NAMESIZE, YES);
		    if (target[0] == '?')
			listRooms(l_NEW|l_OLD);
		    else if (target[0])
			gotoroom(target, c);
		    else
			nextroom(c);
		}
		else
		    nextroom(c);
		break;

    case 'H': doHelp(prefix);		break;
    case 'I': doinfo(prefix);		break;
    case 'K': doKnown(prefix);		break;
    case 'L':
	    cfg.filter[N0_KEY] = 0;
	    mprintf("login ");
	    if (loggedIn)
		mprintf("- You're already logged in\r");
	    else
		login(prefix);
	    break;
    case 'M':   toroom(MAILROOM, 'S');
		mprintf("mail\r");
		statroom();
		break;
    case 'N': doRead(NO, 1, 'n');	break;
    case 'O': doRead(NO, 1, 'o');	break;
    case '=': doRead(NO, 4, '\n');	break;
    case 'R': doRead(prefix, 0, 'r');	break;
    case 'T': doLogout(prefix, 'y');	break;
    case '>':
    case '<':   doFloor(c);
		break;
    case '+':
    case '-':   steproom(prefix, c=='+');
		break;
    case 'B':   ungoto(prefix, "backup");
		break;
		/*
		 * Ungoto is either "upload" or "ungoto", depending on
		 * whether we are emulating k2ne or not.
		 */
    case 'U':   if (backup)
		    doEnter(prefix, 'F');
		else
		    ungoto(prefix, "ungoto");
		break;
    case 'P':
	    if (numfnords == 0) return YES;
		else doFnord();
	    break;
    case '?':
	    if (prefix)
		help("summary", NO);	/* not impervious and not hothelp */
	    else
		menu("mainopt");
	    break;
    case 'A': if (!doAide(prefix, 'e'))  return YES;    break;
    case 'Z': doForget(prefix);		break;
    case '!': dodoor();			break;
    case N0_KEY:if (receive(1) == N1_KEY && receive(1) == N2_KEY && netAck()) {
		    OutOfNet();		/* networking? */
		    break;
		}
    default:
	    if ((++errorCount > MAX_USER_ERRORS) && !onConsole)
		terminate(YES, tEVIL);
	    return YES;
	    break;
    }
    errorCount = 0;
    return NO;
}

/*
 * greeting() -- Say hello to a new caller
 */
static void
greeting(void)
{
    int rotbanner;

    getRoom(thisRoom = LOBBY);
    thisFloor = LOBBYFLOOR;
    cfg.filter[N0_KEY] = N0_KEY;	/* enable net-watcher */
    setlog();

    if (loggedIn)
	terminate(NO, tGREETING);

    if (cfg.numbanners > 0)
	rotbanner = dobanner();
    if (cfg.numbanners == 0 || cfg.flags.BANNERBLB || !rotbanner)
	if (!blurb("banner", NO))
	    mprintf("Welcome to %s\r", &cfg.codeBuf[cfg.nodeTitle]);

    mprintf("Running: Fnordadel%s V%s-%d\r%s\r", MACHINE, VERSION, 
	PATCHNUM, formDate());

    xprintf("Chat mode %sabled\n", (cfg.flags.NOCHAT) ? "dis" : "en");
    xprintf("`MODEM' mode (<ESC> for CONSOLE mode.)\n");
}

/*
 * getCommand() -- prints menu prompt and does a command
 *
 * returns YES if something went wrong.
 */
static int
getCommand(void)
{
    int c, expand;

    givePrompt();

    c = toupper(getnoecho());

    if (c == HUP) {
	if (newCarrier) {
	    greeting();
	    newCarrier = NO;
	}
	return NO;
    }
    else if (c == CNTRLl)
	return doSysop();
    else {
	if (strchr(";'",c)) {
	    oChar(c);
	    return doFloor(getnoecho());
	}
	else if (expand = (int)strchr(" .,/", c)) {
	    oChar(c);
	    c = getnoecho();
	}
	return doRegular(expand, toupper(c));
    }
}

main(argc, argv)
int  argc;
char **argv;
{
    int recovered=0;

    setbuf(stdout, NULL);	/* stdout unbuffered -- AA 89Mar27 */

    fprintf(stderr, "\n\n\
Fnordadel%s %s-%d\n\
This is free software; see COPYING for more information.\n",
	    MACHINE, VERSION, PATCHNUM);

    while (argc-- > 1) {
	if (argv[argc][0] == '+' || argv[argc][0] == '-') {
	    char *p = &argv[argc][1];
	    if (stricmp(p, "netlog") == 0)
		logNetResults = YES;
	    else if (stricmp(p, "debug") == 0)
		Debug = YES;
	    else if (stricmp(p, "hup") == 0)
		dropDTR = NO;
	    else if (stricmp(p, "netdebug") == 0)
		netDebug = YES;
	    else if (stricmp(p, "zap") == 0)
		checkloops = YES;
	    else if (stricmp(p, "ymodem") == 0)
		netymodem = YES;
	    else if (stricmp(p, "line") == 0)
		statbar = YES;
	    else if (stricmp(p, "restrict") == 0)
		restrict = YES;
	    else if (stricmp(p, "purge") == 0)
		msgpurge = YES;
	    else if (stricmp(p, "backup") == 0)
		backup = YES;
	    else if (stricmp(p, "door") == 0)
		doormode = YES;
#ifdef ATARIST
	    else if (stricmp(p, "multi") == 0)
		multiTask = YES;
#endif
	}
	else
	    recovered = argc;
    }

    if (doormode)
	dropDTR = NO;

    initCitadel();
    initEvent();		/* set up for next event */
    initdoor();			/* load doorways here... */

    initfnord();

    /* new init function put in by AA 90Aug22 */
    /* fixed by AA 90Sep10 -- oops! (This is C: call by value, idiot...) */

    numrestrict = inituserlist(&restlist, "restrict.sys");
    numpurge = inituserlist(&purgelist, "purge.sys");

    zero_struct(prevuser);

    if (Debug) {		/* AA 90Dec08 */
	PATHBUF file;
	
	ctdlfile(file, cfg.auditdir, "debuglog.sys");
	debuglog = safeopen(file, "a");
	if (debuglog == NULL)
	    xprintf("Cannot open debug logfile (%s)\n", file);
    }

    greeting();

    if (recovered) {
	strcpy(msgBuf.mbtext, "System brought up from apparent crash.");
	aideMessage(NO);
    }

    logMessage(FIRST_IN, "", NO);

    while (!Abandon) {
	if (getCommand())
	    whazzit();
	else
	    doCR();
	if (justLostCarrier) {
	    justLostCarrier = NO;
	    if (loggedIn)
		terminate(YES, tDISCONNECT);
	}
	if (eventExit) {
	    if (loggedIn)
		terminate(YES, tEVENTPUNT);
	    doEvent();
	}
    }

    if (loggedIn)
	terminate(NO, tNORMAL);
    if (debuglog)
	fclose(debuglog);
    logMessage(LAST_OUT, "", NO);
    exitCitadel(exitValue);
}
