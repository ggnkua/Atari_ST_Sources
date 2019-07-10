/* #define DOORDEBUG 1 */

/*
 * sysdep.c -- System-dependent stuff used inside Citadel.
 */

/*
 * 90Dec09 AA	Oops -- use spawnv() instead.
 * 90Aug20 AA	changed dosexec() to use execve() instead of Pexec()
 * 89Mar23 AA   defines put in for Mark Williams C
 * 88Aug05 orc	moved conout() to libdep.c
 * 88Jul17 orc	moved scandir()/freedir() to scandir.c
 *		moved receiptfree() to netmisc.c
 * 88Apr10 orc	moved receive() to libmodem.c
 * 88Jan29 orc	moved rawmodeminit() to libmisc.c
 * 87Dec17 orc	Clear line noise even if modem codes are used.
 * 87Dec14 orc	Prometheus modem init-at-high-speed code added.
 * 87Jul25 orc	9600 baud support (I hope....)
 * 87May24 orc	Use gemdos() instead of bios() calls for console i/o
 * 87Mar28 orc  add delay in for autobauding, change file area code
 *		around some more, fix up modemSetup string glitch.
 * 87Mar08 orc	redo timer stuff & shorten modem input buffer size.
 * 87Feb07 orc	have modeminit dump modemSetup string...
 * 87Jan30 orc	safeopen() moved from libarch.
 * 87Jan22 orc	More changes to area manager.
 * 87Jan21 orc	Finally got around commenting ST changes...
 * 86Dec14 HAW	Reorganized into areas.
 * 86Nov25 HAW	Created.
 */

#include <setjmp.h>
#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "msg.h"
#include "room.h"
#include "calllog.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

#include <stdarg.h>

/*
 * getArea()		get an area from the sysop.
 * homeSpace()		takes us to our home space.
 * xchdir()		chdir or print an error message
 * * check_CR()		scan input for carriage returns.
 * scanbaud()		does flip flop search for baud.
 * crashout()		Print error message, log error, then go belly-up & die
 * xprintf()		multitasking printf()
 * iprintf()		writes an impervious line to modem & console.
 * wcprintf()		printf() for the networker.
 * splitF()		debug formatter.
 * set_time()		set date (system dependent code).
 * dosexec()		execute an external program
 * systemInit()		system dependent init.
 * systemShutdown()	system dependent shutdown.
 */

#define NEEDED	0

#define ENOERR	0			/* the anti-error	*/
#define ENODSK	-1			/* no disk		*/
#define ENODIR	-2			/* no directory		*/

static PATHBUF homeDir;		/* directory where we live	*/

/*
 * getArea() - get area to assign to a directory room from sysop
 */
void
getArea(struct aRoom *roomData)
{
    char finished = NO;
    PATHBUF nm;
    char message[100];

    if (roomData->rbdirname[0] == 0)	/* default to current directory */
	getcd(roomData->rbdirname);

    while (onLine()) {
	mprintf("Directory (C/R == `%s'): ",roomData->rbdirname);
	getNormStr("", nm, PATHSIZE-3, YES);
	if (strlen(nm) == 0)
	    return;

	else if (cd(nm) == 0) {
	    sprintf(message, "Use existing %s", nm);
	    if (getYes(message))
		break;
	}
	else {
	    sprintf(message, "create new %s", nm);
	    if (getYes(message))
		if (mkdir(nm) != 0 || cd(nm) != ENOERR)
		    mprintf("Can't create directory\r");
		else
		    break;
	}
	homeSpace();
    }
    getcd(roomData->rbdirname);
}

/*
 * homeSpace() takes us home!
 */
void
homeSpace(void)
{
    cd(homeDir);
}

/*
 * xchdir() - cd or error message
 */
int
xchdir(char *path)
{
    if (cd(path) != ENOERR) {
	mprintf("No directory <%s>\r", path);
	homeSpace();
	return NO;
    }
    return YES;
}

static int
OKBaud(int speed, int prompt)
{
    register c;
    register clock_t ff;
    register clock_t countdown;

#ifdef debugme
    printf("Okbaud(%d)-", speed);
#endif
    setBaud(speed);
    mflush();
    countdown = CLK_TCK/2;
    if (prompt) {
	modputs("\007\r\nType return:");
	countdown *= 4;
    }
    /*
     * wait a little while for some appropriate input
     * (5 seconds for prompt, .5 seconds for autobauding)
     */
    for (ff = clock(); ticksSince(ff) < countdown;)
	if (MIReady())
	    if ((c = getMod()) == '\r' || c == N0_KEY)
		return YES;
    return NO;
}

static int
scanmmesg(char *id)
{
    register idx;

#ifdef debugme
    xprintf("scanmmesg(");
    for (idx=0; id[idx]; idx++)
	if (isprint(id[idx]))
	    xputc(id[idx]);
	else
	    xprintf("<%02x>", 0xff & id[idx]);
    xprintf(")-");
#endif
    for (idx=0; idx <= cfg.sysBaud; ++idx)
	if (strcmp(&cfg.codeBuf[cfg.mCCs[idx]], id) == 0) {
	    setBaud(idx);
	    return idx;
	}
    return ERROR;
}

int
mmesgbaud(void)		/* for modems that return connection strings... */
{
#define MMESGSIZ 50
    char buffer[MMESGSIZ];
    register c, i;
    clock_t x;

#ifdef debugme
    xprintf("mmesgbaud()-");
#endif
    for (i=0, x = clock(); ticksSince(x) < CLK_TCK; ) {
        if (MIReady())
            if ((c = getMod()) == '\r') {
                buffer[i] = 0;
		if ((i=scanmmesg(buffer)) != ERROR)
		    return i;
		i = 0;
            }
            else if (i < MMESGSIZ-1)	/* truncate long messages. */
		buffer[i++] = 0x7f & c;	/* and only accept 7 bits. */
	    else
		i = 0;
    }
    buffer[i] = 0;
    return scanmmesg(buffer);
}

int
scanbaud(void)
{
    int  bps;
    clock_t time;

    pause(100*cfg.connectDelay);
    if (!(cfg.flags.MODEMCC) || mmesgbaud() == ERROR) {
	if ((cfg.flags.SEARCH_BAUD) && (cfg.sysBaud != ONLY_300)) {
	    for (bps=0, time=clock(); gotcarrier() && timeSince(time) < 60L; )
		if (OKBaud(bps, (cfg.flags.CONNECTPROMPT)
						|| timeSince(time) > 30L))
		    goto stab;
		else
		    bps = (1+bps) % (1+cfg.sysBaud);
	}
	setBaud(cfg.sysBaud);
    }
stab:
    mflush();
    pause(50);
    return gotcarrier();
}

void
crashout(char *msg, ...)
{
    FILE *fd, *safeopen();
    va_list arg;

    fd = safeopen("crash", "a");

    iprintf("\rWhoops! Think I'll die now...\r");

    va_start(arg, msg);
    vsprintf(msgBuf.mbtext, msg, arg);
    va_end(arg);

    printf("%s\n", msgBuf.mbtext);

    if (fd) {
	fputs(msgBuf.mbtext, fd);
	fprintf(fd," (%s @ %s)\n", formDate(), tod(NO));
	fclose(fd);
    }
    exitCitadel(CRASH_EXIT);
}

void
xputs(char *s)
{
    if (active)
	fputs(s, stdout);
}

/************************************************************************
 * SYSTEM FORMATTING:							*
 *    These functions take care of formatting to strange places not	*
 * handled by normal C library functions.				*
 *   xprintf() print to the console if citadel is attached.		*
 *   iprintf() print unstoppably to the modem port via a mformat() call *
 *   wcprintf() print out modem port via WC, append a 0 byte.		*
 *   splitF() debug function, prints to both screen and disk.		*
 ************************************************************************/

int
xputc(int c)
{
    if (active) {
	putchar(c);
	return c;
    }
    return EOF;
}

void
xprintf(char *format, ...)
{
    va_list arg;

    if (active) {
	va_start(arg, format);
	vprintf(format, arg);
	va_end(arg);
    }
}

void
iprintf(char *format, ...)
{
    va_list arg;
    char string[MAXWORD];

    va_start(arg, format);
    vsprintf(string, format, arg);
    va_end(arg);
    outFlag = IMPERVIOUS;
    mformat(string);
    outFlag = OUTOK;
}

void
splitF(FILE *diskfile, char *format, ...)
{
    va_list arg;
    char string[MAXWORD];

    va_start(arg, format);
    vsprintf(string, format, arg);
    va_end(arg);
    fputs(string, stdout);
    if (diskfile) {
	fputs(string,diskfile);
	fflush(diskfile);
    }
}

void
wcprintf(char *format, ...)
{
    va_list arg;
    char string[MAXWORD];
    register char *p;

    va_start(arg, format);
    vsprintf(string, format, arg);
    va_end(arg);
    for (p=string; *p;)
	(*sendPFchar)(*p++);
    (*sendPFchar)(0);
}

/*
 * set_time() -- set system time & date
 */
int
set_time(struct tm *clk)
{
    unsigned short date, time;

    if (clk->tm_year < 90 || clk->tm_year > 199 || clk->tm_mon > 11
		     || clk->tm_mon < 0 || clk->tm_hour > 23 || clk->tm_hour <0
		     || clk->tm_min > 59 || clk->tm_min < 0 
		     || clk->tm_mday <= 0 || clk->tm_mday > 31)
	return NO;

    date = ((unsigned short)(clk->tm_year - 80) << 9)
	   | ((unsigned short)(clk->tm_mon + 1) << 5)
	   | ((unsigned short)(clk->tm_mday));
    time = ((unsigned short) clk->tm_hour << 11)
	   | ((unsigned short) clk->tm_min << 5)
	   | ((unsigned short)(clk->tm_sec / 2));

    Tsettime(time);
    Tsetdate(date);
    return YES;
}

/*
 * unexpected crash handlers
 */

#define	TERMVEC	0x102				/* terminate vector	*/
#define	BUSERR	2				/* bus vector		*/
#define	ADDRERR	3				/* address vector	*/

static void (*oldodd)();	/* holders for old terminate vec,	*/
static void (*oldbus)();	/* bus error trap			*/
static void (*oldaddr)();	/* and address error trap		*/

static jmp_buf termjump;
static jmp_buf busjump;
static jmp_buf addrjump;

static
oddcrash(void)
{
    longjmp(termjump,1);
}

static
buscrash(void)
{
    longjmp(busjump,1);
}

static
addrcrash(void)
{
    longjmp(addrjump,1);
}

static
fixexc(void)
{
    Setexc(TERMVEC, oldodd);
    Setexc(BUSERR,  oldbus);
    Setexc(ADDRERR,oldaddr);
}

static
setexc(void)
{
    Setexc(TERMVEC, oddcrash);
    Setexc(BUSERR,  buscrash);
    Setexc(ADDRERR,addrcrash);
}

static void
panic(void)
{			/* ooopsie! */
    xprintf("\n\007\007DOUBLE TERMINATE! - ");
    systemShutdown();
    exit(255);
}

static void
setupSys(void)
{
    Cursconf(1,0);	/* set up the cursor			*/
    Cursconf(3,0);
    xputs("\033v");	/* put emulator into line wrap mode	*/
}

/*
 * dosexec() -- execute a subprocess with the `normal' environment
 */
long
dosexec(char *cmd, char *tail)
{
    long status;

#define MAXARGS 20
    extern char *strrchr();
    char *av[MAXARGS];		/* initialisation taken out by AA 90Oct22 */
    int ac = 0;
    char *s, *q;

#ifdef DOORDEBUG
    xprintf("dosexec input: %s %s\n", cmd, tail);
#endif
    writeSysTab();

    /* NOTE: we don't kill the statbar for remote users - if the door goes */
    /* boom there will at least be some evidence of who was on at the time. */
    if (onConsole && statbar)
	killbar();
    fixmodem();		 		/* restore the old input queue	*/
    fixexc();				/* and trap handlers		*/

    /* fill in argv[0] with the command name, stripped of leading path stuff */
    if ((q = strrchr(cmd, '\\')) != NULL)
	av[ac++] = (++q);
    else
	av[ac++] = cmd;
#ifdef DOORDEBUG
    xprintf("argv[0]: %s\n", av[0]);
#endif

    /* Parse the supplied tail into args, inserting ptrs into av[] */
    if (tail && *tail) {	/* Is there a tail of any kind? */
	q = strdup(tail);	/* don't bus' the original, just in case */
	if ((s = strtok(q, "\t ")) != NULL) {	/* there is at least one arg */
	    av[ac++] = s;			/* add it to argv[] */
#ifdef DOORDEBUG
	    xprintf("argv[%d]: %s\n", ac-1, av[ac-1]);
#endif
	    while ((s = strtok(NULL, "\t ")) != NULL) {
		if (ac == MAXARGS) {
		    mprintf("Too many command line arguments in dosexec()\r");
		    return ERROR;
		}
		av[ac++] = s;
#ifdef DOORDEBUG
		xprintf("argv[%d]: %s\n", ac-1, av[ac-1]);
#endif
	    }
	}
    }
    av[ac] = (char *)0;		/* make sure the arg list is terminated */

    status = spawnv(0, cmd, av);
    setexc();				/* reload our processes		*/
    setmodem(1);			/* input queue size		*/
    setupSys();				/* and whatever else...		*/
    if (onConsole && statbar) {
	if (!makebar())
	    statbar = NO;
	else
	    stat_upd();
    }
    dunlink(indextable);		/* zot CTDLTABL.SYS		*/
    return status;			/* and tell the caller what's up*/
}

/*
 * systemInit() - system dependent initialization
 */
void
systemInit(void)
{
    static int crashing = 0;

    oldodd = Setexc(TERMVEC, -1L);		/* get addresses of old */
    oldbus = Setexc(BUSERR,  -1L);		/* trap handlers */
    oldaddr= Setexc(ADDRERR, -1L);

    setexc();					/* load ours */

    if (setjmp(termjump) != 0) {		/* and set up jumps */
	if (crashing++ > 0)			/* for evil errors */
	    panic();
	crashout("unexpected terminate");
    }
    else if (setjmp(busjump) != 0) {
	if (crashing++ > 0)
	    panic();
	crashout("bus error");
    }
    else if (setjmp(addrjump) != 0) {
	if (crashing++ > 0)
	    panic();
	crashout("Address error");
    }
    setupSys();
    getcd(homeDir);		/* get our home directory.		*/
    setmodem(1);		/* get the appropriate modem handler...	*/
}

/*
 * systemShutdown() - system dependent shutdown code
 */
void
systemShutdown(void)
{
    homeSpace();
    fixmodem();
    fixexc();
    xprintf("Bye\n");
}
