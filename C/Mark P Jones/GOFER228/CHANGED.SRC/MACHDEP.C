/* --------------------------------------------------------------------------
 * machdep.c:   Copyright (c) Mark P Jones 1991-1993.   All rights reserved.
 *              See goferite.h for details and conditions of use etc...
 *              Gofer version 2.28 January 1993
 *
 * Machine dependent code
 * RISCOS specific code provided by Bryan Scatergood, JBS
 * ------------------------------------------------------------------------*/
#if UNIX
#include <signal.h>

#if !(ATARI | LATTICE)			/* LP 9.5.93 */
#include <sys/ioctl.h>
#endif

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

#if (TURBOC | BCC)
#include <dos.h>
#include <conio.h>
#include <io.h>
#include <stdlib.h>
#include <mem.h>
#include <sys\stat.h>
#include <time.h>
extern unsigned _stklen = 8000;		/* Allocate an 8k stack segment	   */
#endif

#if ZTC
#include <stdlib.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

#if DJGPP
#include <dos.h>
#include <stdlib.h>
#include <std.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

#if RISCOS
#include <assert.h>
#include <signal.h>
#include "swis.h"
#include "os.h"
#endif

/* --------------------------------------------------------------------------
 * Machine dependent code is used in each of:
 *	- The gofer interpreter		MACHDEP_GOFER
 *	- The gofer compiler		MACHDEP_GOFC
 *	- The compiler runtime system	MACHDEP_RUNTIME
 * In many cases, the the same code is used in each part.  The following
 * sections of code are enclosed in suitable #if ... #endif directives to
 * indicate which sections require particular parts of the code.  Each of
 * the three systems above defines one of the three symbols on the right
 * above as 1 and then #includes this file.  The following directives make
 * sure that the other macros are set to the correct defaults.
 * ------------------------------------------------------------------------*/

#ifndef MACHDEP_GOFER
#define MACHDEP_GOFER   0
#endif
#ifndef MACHDEP_GOFC
#define MACHDEP_GOFC    0
#endif
#ifndef MACHDEP_RUNTIME
#define MACHDEP_RUNTIME 0
#endif

/* --------------------------------------------------------------------------
 * Find information about a file:
 * ------------------------------------------------------------------------*/

#if (MACHDEP_GOFER | MACHDEP_GOFC)
#if RISCOS
typedef struct { unsigned hi, lo; } Time;
#define timeChanged(now,thn)	(now.hi!=thn.hi || now.lo!=thn.lo)
#define timeSet(var,tm)		var.hi = tm.hi; var.lo = tm.lo
#else
typedef time_t Time;
#define timeChanged(now,thn)	(now!=thn)
#define timeSet(var,tm)		var = tm
#endif

static Void local getFileInfo	Args((String, Time *, Long *));

static Void local getFileInfo(s,tm,sz)	/* find time stamp and size of file*/
String s;
Time   *tm;
Long   *sz; {
#if RISCOS				/* get file info for RISCOS -- JBS */
    os_regset r;			/* RISCOS PRM p.850 and p.837	   */
    r.r[0] = 17;			/* Read catalogue, no path	   */
    r.r[1] = (int)s;
    os_swi(OS_File, &r);
    if(r.r[0] == 1 && (r.r[2] & 0xFFF00000) == 0xFFF00000) {
	tm->hi = r.r[2] & 0xFF;		/* Load address (high byte)	   */
	tm->lo = r.r[3];		/* Execution address (low 4 bytes) */
    }
    else				/* Not found, or not time-stamped  */
	tm->hi = tm->lo = 0;
    *sz = (Long)(r.r[0] == 1 ? r.r[4] : 0);
#else					/* normally just use stat()	   */
    static struct stat scbuf;
    stat(s,&scbuf);
    *tm = scbuf.st_mtime;
    *sz = (Long)(scbuf.st_size);
#endif
}
#endif

#if RISCOS				/* RISCOS needs access()	   */
int access(char *s, int dummy) {	/* Give 1 iff cannot access file s */
    os_regset r;			/* RISCOS PRM p.850	-- JBS	   */
    assert(dummy == 0);
    r.r[0] = 17; /* Read catalogue, no path */
    r.r[1] = (int)s;
    os_swi(OS_File, &r);
    return r.r[0] != 1;
}

int namecmp(char *filename, char *spec){/* For filename extension hacks	   */
    while(*spec)
        if  (tolower(*filename) != *spec++)
	    return 0;
	else
	    ++filename;
    return *filename == '.';
}
#endif

/* --------------------------------------------------------------------------
 * Get time/date stamp for inclusion in compiled files:
 * ------------------------------------------------------------------------*/

#if MACHDEP_GOFC
#include <time.h>
String timeString() {			/* return time&date string	   */
    time_t clock;			/* must end with '\n' character	   */
    time(&clock);
    return(ctime(&clock));
}
#endif

/* --------------------------------------------------------------------------
 * Garbage collection notification:
 * ------------------------------------------------------------------------*/

#if  (MACHDEP_GOFER | MACHDEP_GOFC)
Bool gcMessages = FALSE;		/* TRUE => print GC messages	   */

Void gcStarted() {			/* notify garbage collector start  */
    if (gcMessages) {
	printf("{{Gc");
	fflush(stdout);
    }
}

Void gcScanning() {			/* notify garbage collector scans  */
    if (gcMessages) {
	putchar(':');
	fflush(stdout);
    }
}

Void gcRecovered(recovered)		/* notify garbage collection done  */
Int recovered; {
    if (gcMessages) {
	printf("%d}}",recovered);
	fflush(stdout);
    }
}

Cell *CStackBase;			/* Retain start of C control stack */

#if RISCOS				/* Stack traversal for RISCOS	   */

/* Warning: The following code is specific to the Acorn ARM under RISCOS
   (and C4).  We must explicitly walk back through the stack frames, since
   the stack is extended from the heap. (see PRM pp. 1757).  gcCStack must
   not be modified, since the offset '5' assumes that only v1 is used inside
   this function. Hence we do all the real work in gcARM.
*/
		  
#define spreg 13 /* C3 has SP=R13 */

#define previousFrame(fp)	((int *)((fp)[-3]))
#define programCounter(fp)	((int *)((*(fp)-12) & ~0xFC000003))
#define isSubSPSP(w)		(((w)&dontCare) == doCare)
#define doCare			(0xE24DD000)  /* SUB r13,r13,#0 */
#define dontCare		(~0x00100FFF) /* S and # bits   */
#define immediateArg(x)		( ((x)&0xFF) << (((x)&0xF00)>>7) )

static void gcARM(int *fp) {
    int si = *programCounter(fp);	/* Save instruction indicates how */
					/* many registers in this frame   */
    int *regs = fp - 4;
    if (si & (1<<0)) markWithoutMove(*regs--);
    if (si & (1<<1)) markWithoutMove(*regs--);
    if (si & (1<<2)) markWithoutMove(*regs--);
    if (si & (1<<3)) markWithoutMove(*regs--);
    if (si & (1<<4)) markWithoutMove(*regs--);
    if (si & (1<<5)) markWithoutMove(*regs--);
    if (si & (1<<6)) markWithoutMove(*regs--);
    if (si & (1<<7)) markWithoutMove(*regs--);
    if (si & (1<<8)) markWithoutMove(*regs--);
    if (si & (1<<9)) markWithoutMove(*regs--);
    if (previousFrame(fp)) {
	/* The non-register stack space is for the previous frame is above
	   this fp, and not below the previous fp, because of the way stack
	   extension works. It seems the only way of discovering its size is
	   finding the SUB sp, sp, #? instruction by walking through the code
	   following the entry point.
	*/
	int *oldpc = programCounter(previousFrame(fp));
	int fsize = 0, i;
	for(i = 1; i < 6; ++i)
	    if(isSubSPSP(oldpc[i])) fsize += immediateArg(oldpc[i]) / 4;
	for(i=1; i<=fsize; ++i)
	    markWithoutMove(fp[i]);
    }
}

void gcCStack() {
    int dummy;
    int *fp = 5 + &dummy;
    while (fp) {
	gcARM(fp);
	fp = previousFrame(fp);
    }
}

#else			/* Garbage collection for standard stack machines  */

Void gcCStack() {			/* Garbage collect elements off    */
    Cell stackTop = NIL;		/* C stack			   */
    Cell *ptr = &stackTop;
#if SMALL_GOFER
    if (((long)(ptr) - (long)(CStackBase))&1)
	fatal("gcCStack");
#else 
    if (((long)(ptr) - (long)(CStackBase))&3)
	fatal("gcCStack");
#endif

#define StackGrowsDown	while (ptr<=CStackBase) markWithoutMove(*ptr++)
#define StackGrowsUp	while (ptr>=CStackBase) markWithoutMove(*ptr--)
#define GuessDirection	if (ptr>CStackBase) StackGrowsUp; else StackGrowsDown
#if HPUX
    GuessDirection;
#else
    StackGrowsDown;
#endif
#undef  StackGrowsDown
#undef  StackGrowsUp
#undef  GuessDirection
}
#endif
#endif

/* --------------------------------------------------------------------------
 * Terminal dependent stuff:
 * ------------------------------------------------------------------------*/

#if   (TERMIO_IO | SGTTY_IO)

#if TERMIO_IO
#include <termio.h>
typedef  struct termio   TermParams;
#define  getTerminal(tp) ioctl(fileno(stdin),TCGETA,&tp)
#define  setTerminal(tp) ioctl(fileno(stdin),TCSETAF,&tp)
#define  noEcho(tp)      tp.c_lflag    &= ~(ICANON | ECHO); \
			 tp.c_cc[VMIN]  = 1;		    \
			 tp.c_cc[VTIME] = 0;
#endif

#if SGTTY_IO
#include <sgtty.h>
typedef  struct sgttyb   TermParams;
#define  getTerminal(tp) ioctl(fileno(stdin),TIOCGETP,&tp)
#define  setTerminal(tp) ioctl(fileno(stdin),TIOCSETP,&tp)
#if HPUX
#define  noEcho(tp)      tp.sg_flags |= RAW; tp.sg_flags &= (~ECHO);
#else
#define  noEcho(tp)      tp.sg_flags |= CBREAK; tp.sg_flags &= (~ECHO);
#endif
#endif

static Bool messedWithTerminal = FALSE;
static TermParams originalSettings;

Void normalTerminal() {			/* restore terminal initial state  */
    if (messedWithTerminal)
	setTerminal(originalSettings);
}

Void noechoTerminal() {			/* set terminal into noecho mode   */
    TermParams settings;

    if (!messedWithTerminal) {
	getTerminal(originalSettings);
	messedWithTerminal = TRUE;
    }
    getTerminal(settings);
    noEcho(settings);
    setTerminal(settings);
}

#if (MACHDEP_GOFER | MACHDEP_GOFC)
Int getTerminalWidth() {		/* determine width of terminal	   */
#ifdef TIOCGWINSZ
#ifdef _M_UNIX				/* SCO Unix 3.2.4 defines TIOCGWINSZ*/
#include <sys/stream.h>			/* Required by sys/ptem.h	   */
#include <sys/ptem.h>			/* Required to declare winsize	   */
#endif
    static struct winsize terminalSize;
    ioctl(fileno(stdout),TIOCGWINSZ,&terminalSize);
    return (terminalSize.ws_col==0)? 80 : terminalSize.ws_col;
#else
    return 80;
#endif
}
#endif

Int readTerminalChar() {		/* read character from terminal	   */
    return getchar();			/* without echo, assuming that	   */
}					/* noechoTerminal() is active...   */
#endif

#if DOS_IO
static Bool terminalEchoReqd = TRUE;

#if (MACHDEP_GOFER | MACHDEP_GOFC)
Int getTerminalWidth() {		/* PC screen is fixed 80 chars	   */
    return 80;
}
#endif

Void normalTerminal() {			/* restore terminal initial state  */
    terminalEchoReqd = TRUE;
}

Void noechoTerminal() {			/* turn terminal echo on/off	   */
    terminalEchoReqd = FALSE;
}

Int readTerminalChar() {		/* read character from terminal	   */
    if (terminalEchoReqd)
	return getchar();
    else {
	Int c = getch();
	return c=='\r' ? '\n' : c;
    }
}
#endif

#if RISCOS
#if (MACHDEP_GOFER | MACHDEP_GOFC)
Int getTerminalWidth() {
    int dummy, width;
    (void) os_swi3r(OS_ReadModeVariable, -1, 1, 0, &dummy, &dummy, &width);
    return width+1;
}
#endif

Void normalTerminal() {			/* restore terminal initial state  */
}					/* (not yet implemented)	   */

Void noechoTerminal() {			/* turn terminal echo on/off	   */
}					/* (not yet implemented)	   */

Int readTerminalChar() {		/* read character from terminal	   */
    return getchar();
}
#endif

/* --------------------------------------------------------------------------
 * Interrupt handling:
 * ------------------------------------------------------------------------*/

#if (MACHDEP_GOFER | MACHDEP_GOFC)	/* runtime.c provides own version  */
static  Bool broken    = FALSE;
static  Bool breakReqd = FALSE;
static  sigProto(ignoreBreak);

Bool breakOn(reqd)			/* set break trapping on if reqd,  */
Bool reqd; {				/* or off otherwise, returning old */
    Bool old  = breakReqd;

    breakReqd = reqd;
    if (reqd) {
	if (broken) {			/* repond to break signal received */
	    broken = FALSE;		/* whilst break trap disabled	   */
	    sigRaise(breakHandler);
	}
	ctrlbrk(breakHandler);
    }
    else
	ctrlbrk(ignoreBreak);

    return old;
}

static sigHandler(ignoreBreak) {	/* record but don't respond to break*/
    ctrlbrk(ignoreBreak);
    broken = TRUE;
    sigResume;
}
#endif

/* --------------------------------------------------------------------------
 * Shell escapes:
 * ------------------------------------------------------------------------*/

#if MACHDEP_GOFER
Int shellEsc(s)				/* run a shell command (or shell)  */
String s; {
#if UNIX
    if (s[0]=='\0')
	s = fromEnv("SHELL","/bin/sh");
#endif
    return system(s);
}

#if RISCOS				/* RISCOS also needs a chdir()	   */
int chdir(char *s) {			/* RISCOS PRM p. 885	-- JBS	   */
    return os_swi2(OS_FSControl + XOS_Bit, 0, (int)s) != NULL;
}
#endif
#endif

/* --------------------------------------------------------------------------
 * Floating point support:
 * ------------------------------------------------------------------------*/

#if HAS_FLOATS
#if BREAK_FLOATS
static union {
    Float  flVal;
    struct {
	Cell flPart1,flPart2;
    }	   clVal;
} fudgeCoerce;

Cell part1Float(fl)
FloatPro fl; {
    fudgeCoerce.flVal = fl;
    return fudgeCoerce.clVal.flPart1;
}

Cell part2Float(fl)
FloatPro fl; {
    fudgeCoerce.flVal = fl;
    return fudgeCoerce.clVal.flPart2;
}

FloatPro floatFromParts(c1,c2)
Cell c1, c2; {
    fudgeCoerce.clVal.flPart1 = c1;
    fudgeCoerce.clVal.flPart2 = c2;
    return fudgeCoerce.flVal;
}

Cell mkFloat(fl)
FloatPro fl; {
    Cell p1,p2;
    fudgeCoerce.flVal = fl;
    p1 = mkInt(fudgeCoerce.clVal.flPart1);
    p2 = mkInt(fudgeCoerce.clVal.flPart2);
    return pair(FLOATCELL,pair(p1,p2));
}

FloatPro floatOf(c)
Cell c; {
    fudgeCoerce.clVal.flPart1 = intOf(fst(snd(c)));
    fudgeCoerce.clVal.flPart2 = intOf(snd(snd(c)));
    return fudgeCoerce.flVal;
}

#if MACHDEP_RUNTIME & BREAK_FLOATS
Cell safeMkFloat(fl)
FloatPro fl; {
    fudgeCoerce.flVal = fl;
    needStack(2);
    pushInt(fudgeCoerce.clVal.flPart2);
    pushInt(fudgeCoerce.clVal.flPart1);
    heap(2);
    mkap();
    topfun(FLOATCELL);
    return pop();
}
#endif

#else /* !BREAK_FLOATS */
static union {
    Float flVal;
    Cell  clVal;
} fudgeCoerce;

Cell mkFloat(fl)
FloatPro fl; {
    fudgeCoerce.flVal = fl;
    return pair(FLOATCELL,fudgeCoerce.clVal);
}

FloatPro floatOf(c)
Cell c; {
    fudgeCoerce.clVal = snd(c);
    return fudgeCoerce.flVal;
}
#endif

String floatToString(fl)			/* Make sure that floating   */
FloatPro fl; {					/* point values print out in */
    static char buffer1[32];			/* a form in which they could*/
    static char buffer2[32];			/* also be entered as floats */
    Int i=0, j=0;

    sprintf(buffer1,FloatFMT,fl);
    while (buffer1[i] && strchr("eE.",buffer1[i])==0)
	buffer2[j++] = buffer1[i++];
    if (buffer1[i]!='.') {
        buffer2[j++] = '.';
	buffer2[j++] = '0';
    }
    while (buffer2[j++]=buffer1[i++])
	;
    return buffer2;
}

FloatPro stringToFloat(s)
String s; {
    return atof(s);
}
#else
Cell mkFloat(fl)
FloatPro fl; {
    internal("mkFloat");
    return 0;/*NOTREACHED*/
}

FloatPro floatOf(c)
Cell c; {
    internal("floatOf");
    return 0;/*NOTREACHED*/
}

String floatToString(fl)
FloatPro fl; {
    internal("floatToString");
    return "";/*NOTREACHED*/
}

FloatPro stringToFloat(s)
String s; {
    internal("stringToFloat");
    return 0;
}
#endif

/* --------------------------------------------------------------------------
 * Machine dependent control:
 * ------------------------------------------------------------------------*/

#if (MACHDEP_GOFER | MACHDEP_GOFC)
#if UNIX
static sigHandler(panic) {		/* exit in a panic, on receipt of  */
    everybody(EXIT);			/* an unexpected signal		   */
    fprintf(stderr,"Unexpected signal\n");
    exit(1);
    sigResume;/*NOTREACHED*/
}
#endif

Void machdep(what)			/* Handle machine specific	   */
Int what; {				/* initialisation etc..		   */
    switch (what) {
        case MARK    : break;
#if UNIX
        case INSTALL :
#ifdef SIGHUP
		       signal(SIGHUP,panic);
#endif
#ifdef SIGQUIT
		       signal(SIGQUIT,panic);
#endif
#ifdef SIGTERM
		       signal(SIGTERM,panic);
#endif
#ifdef SIGSEGV
		       signal(SIGSEGV,panic);
#endif
#ifdef SIGBUS
		       signal(SIGBUS,panic);
#endif
		       break;
#endif
        case RESET   :
	case BREAK   :
	case EXIT    : normalTerminal();
		       break;
    }
}
#endif

/*-------------------------------------------------------------------------*/
