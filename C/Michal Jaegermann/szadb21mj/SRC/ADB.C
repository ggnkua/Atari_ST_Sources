/* Copyright (c) 1990 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	adb.c
 */
/* 
 * Modified to allow adb execute strings of commands stored in memory.
 * Added buffered transcript output to named files.
 * Changes in accepted request syntax.
 * More elaborate command line.
 *
 *    Michal Jaegermann, May 1990
 *
 * Symbol table display is now paging - it was just too fast for TT.
 * ('q', 'Q' or CNTLC will get you out - any other key continues)
 *    Michal Jaegermann, July 1991
 *
 */

#include <setjmp.h>
#include <fcntl.h>
#include "adb.h"

#define IN_ADB
#include "lang.h"

#define CNTLC	3
#define CNTLS	0x13
#define CNTLW	0x17

#define CHUNK   0x4000L;
long _BLKSIZ = CHUNK;	     /* granularity of memory allocation */

struct file     binary;
int             swidth;      /* max width of symbol name - unknown so far */

long            dot;
int             dotoff;
long            olddot;

#define DOT	(dot+dotoff)

int             dotset;
long            maxoff = 0x400;
int             ibase = 10;

int             lastc = 0;
char            sign = 0;
long            bcount;

int             click = 0;	/* flag for cmdcol */
extern int      write (), bf_write ();
char            trname[LINESZ + 2];	/* transcript file name */
int             trid = NO_TRANS;/* its descriptor       */
w_buf          *trbuf = (w_buf *) 0;	/* pointer to its buffer */
int             (*trout) () = write;

unsigned long   regbuf[19];

struct regs     regs[] = {
			  "pc", &regbuf[16],
			  "sr", &regbuf[17],
			  "xsp", &regbuf[18],
			  "d0", &regbuf[0],
			  "d1", &regbuf[1],
			  "d2", &regbuf[2],
			  "d3", &regbuf[3],
			  "d4", &regbuf[4],
			  "d5", &regbuf[5],
			  "d6", &regbuf[6],
			  "d7", &regbuf[7],
			  "a0", &regbuf[8],
			  "a1", &regbuf[9],
			  "a2", &regbuf[10],
			  "a3", &regbuf[11],
			  "a4", &regbuf[12],
			  "a5", &regbuf[13],
			  "a6", &regbuf[14],
			  "sp", &regbuf[15],
			  "", 0,
};

#define NREGS	19

jmp_buf         jmpb, trp_buf;

static char	cnbuf[LINESZ + 2];
#define CONSOLE &cnbuf[0]

int             l_restart, w_restart, lb_cur, lb_fill;
char           *lbuf = CONSOLE;

int             getkchr (), getschr ();
static char    *csource;	/* location read by a function getschr() */
static int      (*getachr) () = getkchr;
extern int      print_regs;
extern struct window w;

char          **bpt_cmds;
char          **ftable;

_main ()
{
    extern int      _argc;
    extern char   **_argv;

    main (_argc, _argv);
    exit (0);
}

main (argc, argv)
    int             argc;
    char           *argv[];
{
    char           *cp, c;
    extern long     ossp;
    int             i, no_cmds, no_buf;
    void            adb (), copyargs (), kdefs (), free (), usage ();
    char           *malloc ();

    winopen ();
    *argv++;			/* skip starting argument */

    no_cmds = no_buf = 0;
    while ('-' == **argv) {
	(*argv)++;		/* skip dash */
	while ('\0' != (c = ~' ' & **argv)) {
	    (*argv)++;		/* skip leading letter */
	    if ('N' == c) {
		while ('\0' != (c = ~' ' & **argv)) {
		    if ('C' == c)
			no_cmds = 1;
		    else if ('B' == c)
			no_buf = 1;
		    else
			usage ();
		    (*argv)++;	/* to next character */
		}
		break;		/* done with option */
	    }
	    else if ('K' == c) {
		if ('\0' == **argv) {
		    if (0 == --argc)	/* out of arguments? */
			usage ();
		    *argv++;
		}
		kdefs (*argv);	/* load definitions of fuction keys */
		break;
	    }
	    else if ('O' == c) { /* tell which object format */
		if ('\0' == **argv) {
		    if (0 == --argc)	/* out of arguments? */
			usage ();
		    *argv++;
		}
		if ('M' == (~' ' & **argv))
		    swidth = 16;	/* this is MWC symbol table */
		else
		    swidth = 8;		/* we'll take anything else for DRI */
		break;
	    }
	    else
		usage ();
	}			/* while ('\0' != (c = ~' ' & **argv)) */
	if (0 == --argc)
	    usage ();
	*argv++;		/* to next argument */
    }				/* while ('-' == **argv) */
    ibase = 16;

    if (0 == no_cmds) {
	i = 0;
	if ((char **) 0 != (bpt_cmds =
			    (char **) malloc (MAXBPTS * sizeof(char *)))) {
	    while (i < MAXBPTS) {
		if ((char *) 0 == (bpt_cmds[i] = malloc (LINESZ + 3)))
		    break;
		i++;
	    }
	}
	if (i < MAXBPTS) {
	    prt ("not enough memory for breakpoint requests\n");
	    while (i > 0) {
		--i;
		free (bpt_cmds[i]);
	    }
	    if ((char **) 0 != bpt_cmds)
		free (bpt_cmds);
	}
    }

    if (0 == no_buf) {		/* set write-to-file function to unbuffered
				 * write */
	if ((w_buf *) 0 ==
	    (trbuf = (w_buf *) malloc (sizeof (w_buf)))) {
	    prt (M7);		/* warning - transcript unbuffered */
	}
	else {
	    trbuf->buf_len = TRBUFSZ;
	    trbuf->buffered = 0;
	    trout = bf_write;
	}
    }

    binary.symptr = 0;
/*    binary.flags = 0; */
    if (0 == --argc) {
	usage ();
    }
    binary.name = *argv++;

    if ((binary.fid = open (binary.name, 0)) < 0) {
/*		prtf("%s:cannot open\n", binary.name);	*/
	prtf (M1, binary.name);
	seeerr ();
	exit (2);
    }
    if (setobj () != 0) {
/*		prtf("%s:bad format\n", binary.name);	*/
	prtf (M2, binary.name);
	seeerr ();
	exit (3);
    }
    if (loadpcs () != 0) {
/*		prtf("%s:bad pexec\n", binary.name);	*/
	prtf (M3, binary.name);
	seeerr ();
	exit (4);
    }
    close (binary.fid);
    copyargs (--argc, argv);	/* if any left - copy for a process to debug */

    relsym ();
    vects ();
/*	prt("Szadb version 1.2 (english)\n");	*/
    prt (M4);
    if (setjmp (trp_buf)) {
	seeerr ();
	exit (0);
    }
    adb (1);
}

void
usage ()
{
/*    prtf ("Usage: adb [-nb] [-nc] [-k kdefs] [-o(s|m)] binary [args]\n"); */
    prtf (M_USE);
    seeerr ();
    exit (1);
}

exit (n)
{
    void            trclose ();

    oldvects ();
    winclose ();
    trclose ();
    _exit (n);
}

seeerr ()
{
/*	prt("(hit any key)");	*/
    prt (M5);
    gemdos (7);
}

#define MWC_START   0x2a6f0004

setobj ()
{
    struct fheader  hdr;
    long            guess;
    int             fid = binary.fid;

    if ((read (fid, &hdr, sizeof (hdr)) != sizeof (hdr)) &&
						(MAGIC != hdr.magic))
	return -1;
    /* an empty MWC symbol table may use 0x30 bytes for something (?) */
    if ((hdr.ssize) && (0x30L != hdr.ssize)) {
        if (sizeof(long) != read(fid, &guess, sizeof(long)))
	    return -1;
	if (0 == swidth) { /* nobody told what is the format */
	    swidth = (MWC_START == guess ? 16 : 8);
	}
	lseek (fid, hdr.tsize + hdr.dsize - (long)(sizeof(long)), 1);
	if (16 == swidth)
	    return mwsetsym (fid, hdr.ssize);
	else {
	    if (extndsymb(fid, hdr.ssize))
		swidth = 22;
	    return setsym (fid, hdr.ssize);
	}
    }
    return 0;
}

void
adb (top)
    int             top;
{
    int             cmddol (), cmdcol (), cmdprt ();
    int             cmdwrt (), cmdsreg (), null ();
    long            getn (), getdot ();
    long            expr ();
    int             intr ();
    register int    c, lc;
    register long   count;
    int             (*f) ();
    long            (*g) ();
    char            fmt[LINESZ];

    if (top) {
	f = cmdprt;
	g = getdot;
	lc = '=';
	fmt[0] = 'a';
	fmt[1] = '\n';
	fmt[2] = '\0';
	setjmp (jmpb);
    }

    for (;;) {
	dotoff = 0;
	if (type (c = PEEKC) & (ALPHANUM | SPECX)) {
	    dot = expr ();
	    olddot = dot;
	    dotset = 1;
	}
	else
	    dotset = 0;
	if (PEEKC == ',') {
	    nb ();		/* consume pushed comma */
	    count = expr ();
	}
	else
	    count = 1L;

	switch (c = nb ()) {
	case '>':
	    f = cmdsreg;
	    break;
	case '$':
	    c = nb ();
	    f = cmddol;
	    break;
	case ':':
	    c = nb ();
	    f = cmdcol;
	    if (':' == c) {
		c = nb ();
		click = 1;	/* turned off by cmdcol */
	    }
	    if ('b' == c) {
		bcount = count;
		count = 1L;
	    }
	    break;
	case '?':
	case '/':
	    g = getn;
	    switch (PEEKC) {

	    case 'w':
	    case 'W':
		f = cmdwrt;
		break;
	    default:
		getfmt (fmt);
	    case '\n':		/* FALLTHROUGH */
		f = cmdprt;
		break;

	    }
	    break;
	case '=':
	    f = cmdprt;
	    g = getdot;
	    if (PEEKC != '\n')
		getfmt (fmt);
	    break;
	case '\r':
	case '\n':
	    c = lc;
	    break;
	default:
	    f = null;
	    count = 1;
	    break;
	}

	dotoff = 0;
	if (f == cmdprt && g != getdot && 'a' != *fmt) {
	    prtad (DOT);
	    putchr (':');
	    putchr ('\n');
	}
	while (count--) {
	    (*f) (c, fmt, g);
	    if (chkbrk ())
		break;
	}
	if (f == cmdprt && g != getdot)
	    dot += dotoff;
	lc = c;
	if (f == cmdcol) {	/* change 'jumps' to 'nexts' */
	    if ('j' == lc || 'J' == lc)
		lc += ('n' - 'j');
	}
	while (getchr (0) != '\n');

	if ((!top) && (lb_cur >= lb_fill)) {
	    optnl ();
	    break;
	}
    }				/* for (;;) */
    return;
}

getchr (in_string)
    int             in_string;
{
    char            c;

    if (lastc) {
	c = lastc;
	lastc = 0;
    }
    else {
	if (lb_cur >= lb_fill) {
	    getline ();
	}
	c = lbuf[lb_cur++];
	if (!in_string) {
	    if (';' == c)
		c = '\n';
	}
    }
    return c;
}

getline ()
/*
 * Get keyboard input if we run out of  characters from a console buffer
 * - echo received characters
 */
{
    char            c;

    optnl ();
    prt ("> ");			/* print prompt character */
    l_restart = lb_fill = lb_cur = 0;
    w_restart = 2;		/* printing starts after prompt */
    while (lb_fill <= LINESZ) {
	if (lb_fill > (LINESZ - 2)) {
	    getachr = getkchr;
	}
	if (0 == (c = (*getachr) ()))
	    continue;
	if (c == '\b') {
	    if (lb_fill > l_restart) {
		--lb_fill;
	    }
	    lbuf[lb_fill] = '\0';
	}
	else {
	    if (LINESZ == lb_fill)
		c = '\n';
	    lbuf[lb_fill++] = c;
	}
	putchr (c);		/* putchr handles '\b' in a special way */
	if (c == '\n')
	    break;
    }
    return;
}

void
src_line (buf)
    char           *buf;
/*
 * Source adb commands from a buffer buf - buf has to be terminated
 * by a newline character.  Bad things will happen if this is not true.
 */
{

    register char  *loc;
    void            adb ();
    char           *sv_lbuf;
    int             sv_cur;
    int             sv_fill;
    int             sv_lc;

    if ((char *) 0 == buf)
	return;

    sv_lbuf = lbuf;
    sv_cur = lb_cur;
    sv_fill = lb_fill;
    sv_lc = lastc;
    /* count characters in a new input buffer - newline inclusive */
    loc = buf;
    while ('\n' != *loc)
	loc++;
    loc++;

    lastc = 0;
    lbuf = buf;
    lb_cur = 0;
    lb_fill = loc - buf;
    /* execute comands - if not at the top adb will return at EOBuf */
    adb (0);
    /* restore previous input stream */
    lastc = sv_lc;
    lbuf = sv_lbuf;
    lb_cur = sv_cur;
    lb_fill = sv_fill;
    return;
}

int
getkchr ()
/*
 * Read one character from a console - no echo.
 */
{
    long            gemdos ();
    union {
	long            full;
	struct {
	    short           high;
	    short           low;
	}               part;
    }               kcode;
    register int    c;
    void            fkey ();
#ifdef HELP
    void            help ();
#endif

    for (;;) {
	kcode.full = gemdos (7);

	if (0 == (c = (short) kcode.full & 0xff)) {	/* hack attack!! */
	    c = kcode.part.high;

	    if (c >= 0x3b && c <= 0x44) {	/* unshifted function key */
		fkey (c - 0x3b);
		return (0);
	    }
	    else if (c >= 0x54 && c <= 0x5d) {	/* shifted function key */
		fkey (c - (0x54 - 0x0a));
		return (0);
	    }
#ifdef HELP
	    else if (c == 0x62) {	/* help key */
		help ();
	    }
#endif
	    continue;		/* ignore other */
	}
	else {			/* low part code non-zero */
	    if (c == CNTLW) {
		winswtch ();
		c = gemdos (7);
		winswtch ();
		continue;
	    }
	    else if (c == CNTLC || c == CNTLS)
		continue;
	}
	break;			/* any other key not matched so far */
    }				/* for (;;) */

    if (c == '\r')
	c = '\n';

    return (c);
}

int
getschr ()
/*
 * Return one character from a location 'csource' and advance.
 * Revert input to console when found '\n' or '\0'.
 * Used to insert stored strings into a CONSOLE buffer.
 */
{
    int             c;

    if ('\n' == (c = *csource++))
	c = 0;
    if (0 == c)
	getachr = getkchr;
    return (c);
}

void
fkey (num)
    int             num;
/*
 * If buffer number num non-empty set input reader to use it.
 */
{
    if (ftable && 0 != (csource = ftable[num])) {
	getachr = getschr;
    }
}

chkbrk ()
{
    char            c;

    if (gemdos (11) == 0)	/* any chars pending ? */
	return 0;
    c = gemdos (7) & 0xff;
    if (c == CNTLC)
	return 1;
    else if (c == CNTLS) {
	c = gemdos (7) & 0xff;
	if (c == CNTLC)
	    return 1;
    }
    return 0;
}

#ifdef GONER
int
pushc (c)
    int             c;
{
    lastc = c;
}

peekc ()
{

    return (pushc (nb ()));
}

#endif				/* GONER */

nb ()
{
    register int    c;

    while ((c = getchr (0)) == ' ' || c == '\t');
    if (c == '\n')
	PUSHC (c);
    return (c);
}

type (c)
    char            c;
{

    if (c >= '0' && c <= '9')
	return (NUMERIC);
    if (c >= 'a' && c <= 'f')
	return (HEX);
    if (c >= 'A' && c <= 'F')
	return (HEX);
    if (c >= 'g' && c <= 'z')
	return (ALPHA);
    if (c >= 'G' && c <= 'Z')
	return (ALPHA);
    if (c == '_')
	return (ALPHA);
    switch (c) {
    case '$':
    case ':':
    case '?':
    case '/':
    case '=':
    case ',':
    case '>':
    case '\r':
    case '\n':
	return (SPECCMD);
    }
    return (SPECX);
}

long
expr ()
{
    long            term ();
    long            r;
    int             c;

    r = term ();
    for (;;)
	switch (c = nb ()) {
	case '+':
	    r += term ();
	    break;
	case '-':
	    r -= term ();
	    break;
	case '*':
	    r *= term ();
	    break;
	case '%':
	    r /= term ();
	    break;
	case '&':
	    r &= term ();
	    break;
	case '|':
	    r |= term ();
	    break;
	case ')':
	default:
	    PUSHC (c);
	    return (r);
	}
}

long
term ()
{
    long            n;
    long            getn (), findval (), atonum ();
    register int    c;
    char           *cp, buf[80];
    struct symbol  *sp, *findnam ();
    struct regs    *rp, *findreg ();
    int             erridx;

    if ((c = nb ()) == '(') {
	n = expr ();
	if (nb () != ')')
	    error (UNBAL);
	return (n);
    }
    else if (c == '\'') {
	n = 0;
	while ((c = getchr (1)) != '\'')
	    if (c == '\n') {
		PUSHC (c);
		break;
	    }
	    else
		n = (n << 8) | c;
	return (n);
    }
    else if (c == '-') {
	n = term ();
	return -n;
    }
    else if (c == '~') {
	n = term ();
	return ~n;
    }
    else if (c == '<') {
	cp = buf;
	while (type (c = getchr (0)) & ALPHANUM)
	    *cp++ = c;
	*cp = '\0';
	PUSHC (c);
	if (rp = findreg (buf))
	    return *rp->value;
	n = findval (buf, &erridx);	/* no register? - try read-only
					 * variable */
	if (0 != erridx) {
	    error (BADRNAME);
	}
	return n;
    }
    else if (c == '*') {
	n = term ();
	n = getn (n, 4);
	return n;
    }
    else if (c == '@') {
	n = term ();
	n = getn (n, 2);
	return n;
    }
    else if (c == '.') {
	return dot;
    }
    else if (c == '&') {
	return olddot;
    }
    else {			/* get the whole term into a buffer */
	cp = buf;
	if (16 != swidth && '_' != c) {	/* standard symbol name - not MWC */
	    *cp++ = '_';
	}
	*cp++ = c;
	while (type (c = getchr (0)) & ALPHANUM)
	    *cp++ = c;
	*cp = '\0';
	PUSHC (c);
	if (type (*(buf + 1)) & ALPHAONLY) {
	    /* don't search if number for sure */
	    if (sp = findnam (buf, binary.symptr))
		return (sp->value);
	    if (16 != swidth) { /* if not MWC */
		if (sp = findnam (buf + 1, binary.symptr))
		    return (sp->value);
	    }
	    else { /* not found so far and MWC */
		*cp++ = '_';
		*cp = '\0';
		if (sp = findnam (buf, binary.symptr))
		    return (sp->value);
		*(cp - 1) = '\0'; /* we will try a number */
	    }
	}
	/* if not symbol or not found - try convert to a number */
	n = atonum (buf + (16 != swidth ? 1 : 0), ibase, &erridx);
	if (0 != erridx) {
	    error (BADNAME);
	}
	return (n);
    }
}

null (c, fmt, get)
    int             c;
    char           *fmt;
    long            (*get) ();
{
/*	prtf("unknown command\n");	*/
    prtf (M6);
    return (0);
}

cmddol (c, fmt, get)
    int             c;
    char           *fmt;
    long            (*get) ();
{
    extern struct regs regs[];
    int             i;
    void            tofile (), hndlfkey ();

    switch (c) {
    case 'q':
	exit (0);
    case 'd':
	ibase = 10;
	break;
    case 'o':
	ibase = 8;
	break;
    case 'x':
	ibase = 16;
	break;
    case 's':
	maxoff = dot;
	break;
    case 'e':
	prtstbl (binary.symptr);
	break;
    case 'b':
	PrBptList ();
	break;
    case 'r':
	prregs ();
	prbpt (*(regs[PC].value));
	putchr ('\n');
	break;
    case 'p':
	prbasepg ();
	break;
    case 'c':
    case 'C':
	prstack (c == 'C');
	break;
    case 'k':
	hndlfkey ();
	break;
    case '>':
	tofile ();
	break;
    default:
	error (UNKNOWN);
	break;
    }
    return (0);
}

prregs ()
{
    struct regs    *rp;

    prtreg (&regs[PC]);
    prtreg (&regs[XSP]);
    prt_sr ();
    optnl ();

    rp = &regs[D0];
    while (rp < &regs[NREGS])
	prtreg (rp++);
    optnl ();
}

prtreg (rp)
    struct regs    *rp;
{
    int             i;

    i = strlen (rp->name);
    prt (rp->name);
    prtn (*(rp->value), 15 - i);
    prt ("    ");
    return;
}

prtstbl (sp)
struct symbol  *sp;
{
    register int lcount, wsz;
    int key;

    if (sp) {
	wsz = w.lines - 1;
	lcount = wsz--;
	for(;;) {
	    prt (sp->name);
	    prt (": ");
	    prtn (sp->value, 0);
	    putchr ('\n');
	    if (!(sp = sp->next))
		break;
	    if (0 == --lcount) {
		key = gemdos(7) & 0xff;
		if ('q' == key || CNTLC == key || 'Q' == key)
		    break;
		lcount = wsz;
	    }
	    if (chkbrk ())
		break;
	}
    }
    return;
}

cmdwrt (c, fmt, get)
    char            c;
    char           *fmt;
    long            (*get) ();
{
    long            l;

    c = nb ();
    l = expr ();
    putn (l, DOT, c == 'w' ? 2 : 4, 1);
    return;
}

cmdprt (c, fmt, get)
    int             c;
    char           *fmt;
    long            (*get) ();
{
    register int    c1;
    long           *ip;
    struct symbol  *sp;
    long            getdot ();
    int             rep, incr, oldoff;

    incr = 0;
    while (c = *fmt++) {
	if (c >= '0' && c <= '9') {
	    rep = c - '0';
	    while ((c = *fmt++) >= '0' && c <= '9')
		rep = 10 * rep + (c - '0');
	}
	else
	    rep = 1;

	if (c == 't')
	    tab (rep);
	else if (c == '^')
	    dotoff -= rep * incr;
	else
	    while (rep--) {

		oldoff = dotoff;

		switch (c) {
		case 'a':
		case 'p':
		    prtad (DOT);
		    if (c == 'a')
			putchr (':');
		    tab (ALIGN_A);
		    break;
		case 'i':
		    if (get == getdot)
			error (BADCMD);
		    puti ();
		    putchr ('\n');
		    break;
		case 'o':
		    puto ((*get) (DOT, 2) & 0xffff, 9);
		    break;
		case 'O':
		    puto ((*get) (DOT, 4), 19);
		    break;
		case 'd':
		    putd ((*get) (DOT, 2), 9);
		    break;
		case 'D':
		    putd ((*get) (DOT, 4), 19);
		    break;
		case 'x':
		    putx ((*get) (DOT, 2) & 0xffff, 9);
		    break;
		case 'X':
		    putx ((*get) (DOT, 4), 19);
		    break;
		case 'b':
		    puto ((*get) (DOT, 1) & 0xff, 4);
		    break;
		case 'c':
		    w_curs (0);
		    w_put  ((char) (*get) (DOT, 1));
		    w_curs (1);
		    break;
		case 'S':
		case 's':
		    if (get == getdot)
			error (BADCMD);
		    while (c1 = (char) (*get) (DOT, 1)) {
			if ((c == 'S') && (c1 < ' ' || c1 > 127))
			    c1 = '.';
			putchr (c1);
		    }
		    break;
		case '"':
		    while ((c = *fmt++) != '"' && c)
			putchr (c);
		    if (c != '"')
			fmt--;
		    break;
		case 'r':
		    putchr (' ');
		    break;
		case 'n':
		    putchr ('\n');
		    break;
		case '+':
		    dotoff++;
		    break;
		case '-':
		    dotoff--;
		    break;
		default:
		    putchr (c);
		    break;
		}
		incr = dotoff - oldoff;
	    }
    }
    return;
}

error (why)
{
    lb_cur = lb_fill;		/* skip the rest of an input buffer */
    prt (errwhy[why]);
    lbuf = CONSOLE;
    lastc = 0;
    longjmp (jmpb, 1);
}

prtad (where)
    long            where;
{
    struct symbol  *sp, *findsym ();

    if ((sp = findsym (where, binary.symptr)))
	prtsym (where, sp);
    else
	prtn (where, 0);
    return;
}

prt_sr ()
{
    long            sr;
    int             i;

    sr = *regs[SR].value;
    prtf ("sr %I -> ", sr);
    if (sr & 0x2000)
	prt ("Supv");
    else
	prt ("User");

    prtf (" pri%I ", (sr >> 8) & 7);

    for (i = 4; i >= 0; i--)
	if (sr & (1 << i))
	    putchr ("CVZNX"[i]);
    putchr ('\n');
}

struct regs    *
findreg (s)
    char           *s;
{
    struct regs    *rp;

    if (strcmp (s, "a7") == 0)
	s = "sp";
    for (rp = regs; rp->value; rp++)
	if (strcmp (s, rp->name) == 0)
	    return rp;

    return 0;
}

void
tofile ()
{
    void            trclose ();

    trclose ();
    if (PEEKC != '\n') {
	getfmt (trname);
	if ((trid = (access (trname, 0x00) ?
		     open (trname, O_WRONLY | O_CREAT, 0) :
		     open (trname, O_WRONLY | O_APPEND))) < -3) {
	    /* prtf("%s:cannot open\n", trname);	 */
	    prtf (M1, trname);
#ifdef DEBUG
	    prtf ("error number = ");
	    putd ((long) trid, 0);
	    prtf ("\n");
#endif
	    trid = NO_TRANS;
	}
#ifdef DEBUG
	else {
	    prtf ("opened file %s with id = ", trname);
	    prtn ((long) trid, 0);
	    prtf ("\n");
	}
#endif
    }
    return;
}

void
trclose ()
{
    extern void     trflush ();

    if (trid != NO_TRANS) {
	trflush ();
	close (trid);
	trid = NO_TRANS;
    }
    return;
}
