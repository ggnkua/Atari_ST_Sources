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
 *	pcs.c
 */
/*
 * Modifications:
 *   - cmdcol() changed for a cooperation with stepping commands
 *   - added function getrequs() which handles turning on/off
 *     execution on breakpoints and stepping commands
 *   - added function findval() which returns values of read-only
 *     internal variables
 *
 *     Anthony Howe, Michal Jaegermann, April 1990
 *
 *   - prnstack now uses Unwind function from stepping.c to find
 *     a chain of return addresses.  (MJ - November 1990)
 */
#include <setjmp.h>
#include <ctype.h>
#include "adb.h"

#define IN_PCS
#include "lang.h"

#ifndef NULL
#define NULL	0L
#endif

unsigned long   esp;
struct basepg  *bpage;
jmp_buf         cont_buf;
static int      got_args = 0;

extern long     dot;
extern long     olddot;
extern int      dotset;
extern int      dotoff;
extern int      lastc;
extern int      print_regs;
extern int      click;
extern struct regs regs[];
extern next_step next_list[];
extern next_step jump_list[];

prstack (argsflg)
{
    int             first, at_sp;
    long            pc, fp, sp, ap;
    long            npc, nfp;
    long            getn ();
    short          *Unwind();
    struct basepg  *bp = bpage;

    pc = *(regs[PC].value);
    fp = *(regs[FP].value);
    sp = *(regs[SP].value);
    at_sp = first = 1;

    while (pc) {
	prtf ("%A", pc);
	npc = (long) Unwind (&at_sp, pc, sp, fp);
				 /* this may modify value of at_sp */
	if (first && at_sp) {
	    nfp = fp;
	    ap = sp + 4;
	    at_sp = 0;		    /* get the next return address from fp */
	}
	else {
	    nfp = getn (fp, 4);
	    ap = fp + 8;
	}
	if (argsflg && npc)
	    funargs (npc, ap, nfp);
	putchr ('\n');

	if (nfp < (long) bp->p_bbase + bp->p_blen ||
	    nfp > (long) bp->p_hitpa ||
	    nfp <= sp || nfp < fp ||
	    (nfp == fp && !first))
	    break;
	pc = npc;
	fp = nfp;
	first = 0;
    }
}

funargs (retpc, argp, limit)
    long            retpc, argp, limit;
{
    int             i, n;
    unsigned        w;

    n = numargs (retpc);

    if (n == 0) {		/* optimized out maybe */
/*		prtf("(? at %I)", argp); */
	prtf (M1, argp);
	return;
    }

    putchr ('(');
    for (i = 0; i < n; i++, argp += 2) {
	w = getn (argp, 2);
	prt4x (w);
	if (argp + 2 >= limit)
	    break;
	if ((i + 1) < n)
	    putchr (',');
    }
    putchr (')');
}

prt4x (w)
    unsigned        w;
{
    int             i, j, k;

    k = 12;
    for (k = 12; k >= 0; k -= 4) {
	j = w >> k;
	j &= 0xf;
	putchr ("0123456789abcdef"[j]);
    }
}

numargs (retpc)
    long            retpc;
{
    int             ins, n;
    long            getn ();

    ins = getn (retpc, 2);
    if ((ins & 0xf1ff) == 0x504f ||
	(ins & 0xf1ff) == 0x508f) {	/* addq.[wl] #n,A7 */
	n = (ins >> 9) & 7;
	if (n == 0)
	    n = 8;
    }
    else if (ins == 0xdefc) {	/* adda.w #n,A7 */
	n = getn (retpc + 2, 2);
    }
    else if (ins == 0xdffc) {	/* adda.l #n,A7 */
	n = getn (retpc + 2, 4);
    }
    else
	n = 0;

    if (n < 0)
	n = 0;
    return n / 2;
}

long
atbranch (loc)
    long            loc;
{
    int             ins, i;

    ins = getn (loc, 2);
    if ((ins & 0xff00) == 0x6000) {
	i = ins & 0xff;
	if (i == 0)
	    i = getn (loc + 2, 2);
	return loc + 2 + i;
    }
    return 0;
}

atlink (loc)
    long            loc;
{
    int             ins;

    ins = getn (loc, 2);
    return (ins == 0x4e56);	/* link a6,#N */
}

atrts (loc)
    long            loc;
{
    int             ins;

    ins = getn (loc, 2);
    return (ins == 0x4e75);
}

prbasepg ()
{
    int             n, i;
    unsigned char   c;
    struct basepg  *bp;

    if (dotset)
	bp = (struct basepg *) dot;
    else
	bp = bpage;

/*	prtf("base page at %I", bp); */
    prtf (M2, bp);
/*	prt("low tpa ");	*/
    prt (M3);
    prtn (bp->p_lowtpa, 10);
/*	prt("  hi tpa  ");	*/
    prt (M4);
    prtn (bp->p_hitpa, 10);
/*	prt("\ntext at ");	*/
    prt (M5);
    prtn (bp->p_tbase, 10);
/*	prt("  size    ");	*/
    prt (M6);
    prtn (bp->p_tlen, 10);
/*	prt("\ndata at ");	*/
    prt (M7);
    prtn (bp->p_dbase, 10);
/*	prt("  size    ");	*/
    prt (M6);
    prtn (bp->p_dlen, 10);
/*	prt("\nbss at  ");	*/
    prt (M8);
    prtn (bp->p_bbase, 10);
/*	prt("  size    ");	*/
    prt (M6);
    prtn (bp->p_blen, 10);
/*	prt("\nenv ptr ");	*/
    prt (M9);
    prtn (bp->p_env, 10);
/*	prt("  parent  ");	*/
    prt (M10);
    prtn (bp->p_parent, 10);

    prtf ("\nargs: ");
    n = bp->p_cmdlin[0];
    for (i = 0; i < n;) {
	c = bp->p_cmdlin[++i];
	if (c < ' ') {
	    putchr ('^');
	    c += 'A';
	}
	putchr (c);
    }
    putchr ('\n');
}

loadpcs ()
{
    int           **ip;
    char            parms[80], *envp;
    extern struct basepg *gemdos ();
    extern struct file binary;
    extern struct basepg *_base;
    extern unsigned long ossp;

    parms[0] = '\0';
    envp = _base->p_env;
    if ((bpage = gemdos (0x4b, 3, binary.name, parms, envp)) < 0) {
/*		prtf("can't load %s\n", binary.name);	*/
	prtf (M11, binary.name);
	return -1;
    }
    ip = (int **) (bpage->p_hitpa);
    *--ip = (int *) bpage;
    --ip;
    *(regs[SP].value) = (unsigned long) ip;
    *(regs[PC].value) = dot = olddot = (unsigned long) bpage->p_tbase;
    *(regs[XSP].value) = ossp;
#ifdef OLD
    bpage->p_parent = _base;
#else
    bpage->p_parent = 0;
#endif
    return 0;
}

void
cmdcol (c, fmt, get)
    int             c;
    char           *fmt;
    long            (*get) ();
{
    extern int      MakeReq ();
    int             kind, tmp;

    if ('b' == c) {		/* set breakpoint */
	SetBpt (dot);
    }
    else if ('d' == c) {	/* clear breakpoint */
	ClrBpt (dot);
    }
    else {			/* tracing */
	if (dotset)
	    *regs[PC].value = dot;
	else
	    dot = *regs[PC].value;

	c = ((print_regs = isupper (c)) ? tolower (c) : c);
	if ('s' == c)
	    kind = CM_STEP;
	else if ('n' == c || 'j' == c)
	    kind = CM_NEXT;
	else if ('f' == c)
	    kind = CM_FINISH;
	else {
	    kind = CM_CONT;	/* we hope */
	    if (click)		/* command line started with :: */
		c = 0;		/* force error */
	}

	if (CM_CONT == kind || 0 == MakeReq (kind)) {
	    switch (c) {
	    case 's':
		SingleStep (dot, CM_STEP);
		break;
	    case 'c':
		getargs ();
		if (setjmp (cont_buf)) {
		    dot = *regs[PC].value;
		}
		FullStep (dot, (short *) NULL, CM_CONT);
		break;
	    case 'n':
		NextStep (dot, next_list);
		break;
	    case 'j':
		NextStep (dot, jump_list);
		break;
	    case 'f':
		FuncStep (dot);
		break;
	    default:
		prt (UNKNOWN_CMD);
	    }			/* switch */
	}			/* if (click) */
    }				/* if ('b' == c) */
    click = 0;			/* next time around execute */
    return;
}				/* cmdcol */

int
getrequs (buf)
    char           *buf;
/*
 *   If 'click' is off and if on a current position, and after all white space
 *   was skipped, there is a character other then '\n', then copy all remaining
 *   characters on a line into a supplied buffer buf. Terminate with '\n\0'.
 *   Return ON if something was copied and BLANK otherwise.
 *   If click is ON return one of the status comands depending on what follows.
 *   Skip to the next delimiter and push '\n'.
 */
{
    register int    c;
    register char  *pos = buf;
    int             status;
    extern int      getchr (), nb ();

    if (0 == click) {
	if ('\n' != PEEKC) {
	    do {
		*pos++ = c = getchr (1);
	    } while ('\n' != c);
	    *pos++ = '\0';
	    status = NEW;
	}
	else	/* '\n' is pushed */
	    return BLANK;
    }
    else {			/* we are changing status of attached
				 * commands - ignore buffer */
	switch (c = nb ()) {
	case '+':
	    status = ON;
	    break;
	case '-':
	    status = SILENT;
	    break;
	case '_':
	    status = DOWN;
	    break;
	case '`':
	    status = REVERT;
	    break;
	default:
	    status = IGNORE;
	}
	while (getchr (0) != '\n') /* skip to the next delimiter */
	    ;
    }
    PUSHC ('\n');
    return (status);
}				/* getrequs */

getargs ()
{
    char            c, *cp;
    int             n;

    c = nb ();
    if (c == '\n')
	return;

    if (got_args)
	return;
    got_args++;

    n = 1;
    cp = &bpage->p_cmdlin[n];
    *cp++ = c;
    while ((c = getchr (1)) != '\n') {
	*cp++ = c;
	n++;
	if (n >= 0x7f)
	    break;
    }
    bpage->p_cmdlin[0] = n;
    *cp = 0;
    PUSHC ('\n');
}

void
copyargs (argc, argv)
    int             argc;
    char          **argv;
/*
 * If argc > 0 copy command line arguments into a base page of
 * process to debug. Terminating zero not included in count.
 */
{
    char            c, *cp;
    int             n;

    if (0 == argc) {
	bpage->p_cmdlin[0] = 0;
	return;
    }
    got_args++;

    n = 0;
    cp = &bpage->p_cmdlin[1];
    for (;;) {
	if (n >= 0x7e)
	    break;
	while (0 != (c = *(*argv)++)) {
	    *cp++ = c;
	    n++;
	    if (n >= 0x7e)
		goto out;
	}
	if (--argc == 0)
	    break;
	*cp++ = ' ';
	n++;
    }
out:
    *cp = 0;
    bpage->p_cmdlin[0] = n;
}


#ifdef GONER
cleanup (fp)
    struct file    *fp;
{

    ptrace (KILL_PID, fp->pid, 0, 0);
    return;
}

#endif

prbpt (pc)
    long            pc;
{
    dot = pc;
    dotoff = 0;
    prtad (dot + dotoff);
    putchr (':');
    puti ();
    return;
}

long
findval (buf, err_p)
    char           *buf;
    int            *err_p;
/*
 * If a string in buf is "l", "b", "t" or "d" return value of
 * text segment base, data segment base, text size and data size
 * respectively.  Otherwise set error indicator and return 0.
 *
 * Names are chosen to avoid conflicts with a Un*x adb. Names
 * "b", "t", "d" and some other are already taken.
 */
{
    struct basepg  *bp = bpage;

    if (0 == (*err_p = buf[1])) {
	switch (buf[0]) {
	case 'l':
	    return (bp->p_tbase);
	case 'b':
	    return (bp->p_dbase);
	case 'd':
	    return (bp->p_dlen);
	case 't':
	    return (bp->p_tlen);
	}
    }
    *err_p = 1;
    return 0;
}
