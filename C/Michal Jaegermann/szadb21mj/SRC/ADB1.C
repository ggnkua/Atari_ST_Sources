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
 *	adb1.c
 */
/*
 * Modifications:
 *   Michal Jaegermann, May 1990
 *
 *   - added functions to handle MWC format symbol table and hooks to
 *     possibly add other formats
 *   - added functions for buffered output to external files
 *
 *   Michal Jaegermann, January 1991
 *
 *   - function setsym() modified to handle also extended format in
 *     which function name can be continued in the next symbol slot
 *     (known as "GST format")
 *   - added function extndsymb() which checks if symbols are using
 *     extended GST format
 *
 *   Michal Jaegermann, January 1992
 *
 *   - added function xsoz_setsym() to handle "Sozobon eXtended"
 *     format introduced with version 2.0 of Sozobon C compiler.
 *   - modified setsym() to switch to xsoz_setsym if such format
 *     encountered.
 */

#include <setjmp.h>
#include "adb.h"

#define IN_ADB1
#include "lang.h"

extern struct file binary;

extern long     dot;
extern int      dotoff;
extern long     maxoff;
extern int      ibase;

extern int      lastc;
extern char     sign;

extern int      swidth;
extern jmp_buf  jmpb;
extern int      trid;
extern w_buf   *trbuf;
extern char    *trname;

getfmt (fmt)
    register char  *fmt;
{
    int             in_string = 0;

    while ((*fmt = getchr (in_string)) != '\n') {
	if ('"' == *fmt)
	    in_string = !in_string;
	fmt++;
    }
    *fmt = '\0';
    PUSHC ('\n');
    return;
}

long
getdot (d, n)
    long            d;
    int             n;
{
    long            l;

    l = dot;
    if (n == 2)
	l &= 0xffff;
    else if (n == 1)
	l &= 0xff;
    return (l);
}

#ifdef GONER
unsigned char
getb (fp)
    struct file    *fp;
{
    long            getn ();

    return (getn (dot + dotoff, 1));
}
#endif

unsigned int
getwd ()
{
    long            getn ();

    return (getn (dot + dotoff, 2));
}

putn (v, d, n)
    long            v, d;
    int             n;
{
    union {
	int             i;
	long            l;
    }               no, val;
    long            b;
    register int    o;
    char           *p, *s;

    b = d >> LOGBS;
    o = d & (BSIZE - 1);
    switch (n) {

    case 2:
	p = (char *) (&no.i);
	val.i = v;
	s = (char *) (&val.i);
	break;
    case 4:
	p = (char *) (&no.l);
	val.l = v;
	s = (char *) (&val.l);
	break;

    }
    rdsub (d, p, n, 0);
    dotoff += n;
    switch (n) {

    case 2:
	bcopy (s, p, n);
	break;
    case 4:
	bcopy (s, p, n);
	break;

    }
    wrsub (p, d, n, 0);
    return;
}

long
getn (d, n)
    unsigned long   d;
    int             n;
{
    unsigned long   b, no;
    register unsigned int o;
    char           *p;

    b = d >> LOGBS;
    o = d & (BSIZE - 1);
    rdsub (d, &b, n, 0);
    p = (char *) &b;
    dotoff += n;
    switch (n) {

    case 1:
	no = *p;
	break;
    case 2:
	no = *(int *) p;
	break;
    case 4:
	no = *(long *) p;
	break;

    }
    return (no);
}

puto (n, s)
    unsigned long   n;
    int             s;
{

    if (n > 0)
	puto ((n >> 3) & 0x1fffffff, --s);
    else
	while (s-- > 0)
	    putchr (' ');
    putchr ((char) ((n & 7) + '0'));
    return;
}

putd (n, s)
    long            n;
    int             s;
{

    if (n < 0) {
	s--;
	n = -n;
	if (n < 0) {
	    while (s-- > 0)
		putchr (' ');
	    putchr ('?');
	    return;
	}
	else
	    sign = '-';
    }
    if (n > 9)
	putd (n / 10, --s);
    else
	while (s-- > 0)
	    putchr (' ');
    if (sign) {
	putchr (sign);
	sign = 0;
    }
    putchr ((char) ((n % 10) + '0'));
    return;
}

putx (n, s)
    unsigned long   n;
    int             s;
{

    if (n > 0xf)
	putx ((n >> 4) & 0xfffffff, --s);
    else {
	while (s-- > 0)
	    putchr (' ');
    }
    putchr ("0123456789abcdef"[n & 0xf]);
    return;
}

prtn (n, s)
    long            n;
    int             s;
{

    switch (ibase) {

    case 8:
	puto (n, s);
	break;
    case 10:
	putd (n, s);
	break;
    default:
    case 16:
	putx (n, s);
	break;

    }
    return;
}

prt (s)
    register char  *s;
{

    while (*s)
	putchr (*s++);
    return;
}


relsym ()
{
    register struct symbol *sp;
    extern struct basepg *bpage;

    sp = binary.symptr;
    while (sp) {
	sp->value += (long) bpage->p_tbase;
	sp = sp->next;
    }
}

mwsetsym (fid, ssize)
/* read symbol table in MWC format */
    int             fid;
    long            ssize;
{
    struct mwfilsym sym;
    char            ct;
    
    if (0 != (ssize % sizeof(sym))) {
	if (ssize <= 0x30L)
	    return 0;
	lseek (fid, 0x30L, 1);  /* skip some really not-symbol stuff */
	ssize -= 0x30L;
    }
    do {
	if (read (fid, &sym, sizeof (sym)) != sizeof (sym))
	    return -1;
	if (sym.flag & 0x1000) {  /* global data */
	    ct = sym.sval.got[0];
	    sym.sval.got[0] = sym.sval.got[1];
	    sym.sval.got[1] = ct;
	    ct = sym.sval.got[2];
	    sym.sval.got[2] = sym.sval.got[3];
	    sym.sval.got[3] = ct;
	    if (0 == addsym (&binary.symptr, sym.name, sym.sval.value))
		break;
	}
    } while (0 < (ssize -= sizeof (sym)));
    return 0;
} /* mwsetsym */

#define XNAME	"SozobonX"
#define XVALUE	0x87654321
#define NAMEMAX 80

/* Read symbol table in "Sozobon extended" format introduced with */
/* version 2.0 of this compiler.				  */
/* Maximum name length is rather high.  We will ensure that all   */
/* symbol table entries are NULL terminated.                      */
xsoz_setsym (fid, ssize)
    int             fid;
    long            ssize;
{
    register char *ptr, *npos = 0;
    register int count;
    struct filsym sym;
    char name[NAMEMAX + 2];
    long value;

    swidth = NAMEMAX + 2;

    do {
	if (read (fid, &sym, sizeof(sym)) != sizeof(sym))
	    return -1;
	ssize -= sizeof(sym);
	/*
	 * not an extension - add to symbol table what we collected
	 * so far and start reading a new symbol
	 */
	if (XVALUE != sym.value || S_EXTEND != sym.flag) {
	    if (npos != 0)
		addsym (&binary.symptr, name, value);
	    npos = name;
	    value = sym.value;
	}
	ptr = &(sym.name[0]);
	/* copy what we got to a name buffer */
	count = sizeof(sym.name);
	do {
	    if ('\0' == (*npos = *ptr++))
		break;
	    npos++;
	} while (--count > 0);
    } while (ssize > 0);
    /* write out the last symbol */
    if (npos != 0)
	addsym (&binary.symptr, name, value);
    return 0;
} /* xsoz_setsym */

setsym (fid, ssize)
/* Read symbol table in Alcyon format - used by Sozobon as well.    */
/* This function modified to handle also symbol tables where symbol */
/* name possibly extends into the next symbol slot; only when       */
/* signalled by S_LNAM flag, otherwise backward compatible.	    */
    int             fid;
    long            ssize;
{
    register int extsymbs;
    struct filsym sym; /* dummy for #defines - Sozobon doesn't know what
    			   to do with sizeof(struct filsym) */
#define SYMSPAN sizeof(sym)
#define NAMSIZE sizeof(sym.name)

    struct  {
	char	xname[NAMSIZE + SYMSPAN];
	short	xflag;
	long	xvalue;
    } xsym;

    static int first_symbol = 1;

    extsymbs = (22 == swidth);
    do {
	if ((read (fid, &xsym, NAMSIZE) != NAMSIZE) ||
	    (read (fid, (char *)(&xsym) + NAMSIZE + SYMSPAN, SYMSPAN - NAMSIZE)
	    		!= SYMSPAN - NAMSIZE))
	    return -1;
	ssize -= SYMSPAN;
	if (first_symbol) { /* check if this is an "extended Sozobon" format */
	    if (XVALUE == xsym.xvalue && S_EXTEND == xsym.xflag &&
 				strncmp(xsym.xname, XNAME, 8) == 0) {
		return (xsoz_setsym(fid, ssize));
	    }
	    first_symbol = 0;
	}

	if (0 >= ssize) {
	    xsym.xflag &= ~S_LNAM;
	}
	if (extsymbs && (S_LNAM == (xsym.xflag & S_LNAM))) {
	    if (read (fid, (char *)(&xsym) + NAMSIZE, SYMSPAN) != SYMSPAN)
		return -1;
	    ssize -= SYMSPAN;
	}
	else {
	    xsym.xname[NAMSIZE] = '\0';
	}
	if ((xsym.xflag & S_EXT) &&
	    (xsym.xflag & (S_DATA | S_TEXT | S_BSS))) {
	    if (0 == addsym (&binary.symptr, xsym.xname, xsym.xvalue))
		break;
	}
    } while (ssize > 0);
    return 0;
} /* setsym */

#undef SYMSPAN
#undef NAMSIZE

addsym (spp, name, value)
    struct symbol **spp;
    char           *name;
    long            value;
{
    register char  *cp, *cps, *cptr;
    long            v;
    struct symbol  *sp;
    char           *malloc ();
    struct symbol  *p;
    int             msize;

    v = value;
    sp = *spp;
    while (sp && (sp->value <= v)) {
	spp = &sp->next;
	sp = *spp;
    }
    
    cps = name;
    cp = cps + swidth;	/* max symbol size */
    while ( *cps && (cps < cp))
	cps++;
    cp = name;

    msize =  sizeof (*p) + (int)(cps - cp) + 1; /* need a space for '\0' */
    if ((p = (struct symbol *) malloc (msize)) == 0) {
/*		prtf("can't allocate %i bytes for symbol\n", sizeof(*p)); */
	prtf (M1, msize);
	return 0;
    }
    *spp = p;
    p->next = sp;
    p->value = v;
    cptr = p->name;
    while (cp < cps)
	*cptr++ = *cp++;
    *cptr = '\0';
    return 1;
}

int
extndsymb(fid, ssize)
/* check if any symbol in a file is in an extended format */
    int             fid;
    long            ssize;
{
    register int extended;
    struct filsym sym;
    long position;
    extern long tell();
    
    position = tell(fid);
    do {
	if (read (fid, &sym, sizeof (sym)) != sizeof (sym))
	    break;
	if (extended = (S_LNAM == (sym.flag & S_LNAM)))
	    break;      
    } while (0 < (ssize -= sizeof(sym)));
    /* restore an original position in a file */
    lseek (fid, position, 0);
    return extended;
}

struct symbol  *
findnam (cp, sp)
    char           *cp;
    struct symbol  *sp;
{
    while (sp) {
	if (strncmp (cp, sp->name, swidth) == 0)
	    return (sp);
	else
	    sp = sp->next;
    }
    return (0);
}

struct symbol  *
findsym (v, sp)
    unsigned long   v;
    struct symbol  *sp;
{
    struct symbol  *lp;
    unsigned long   val;

    lp = sp;
    while (sp) {
	val = sp->value;
	if (val > v)
	    break;
	else {
	    lp = sp;
	    sp = sp->next;
	}
    }
    if (lp && v >= lp->value && v < lp->value + maxoff)
	return (lp);
    return (0);
}

long
atonum (s, inbase, nond_p)
    register char  *s;
    int             inbase;
    int            *nond_p;
/*
 *  Convert a string of characters to a number in a base not bigger
 *  than 16. Returns accumulated number and stores first not
 *  converted character in a location pointed by nond_p.
 *
 *  To override an original base use 0x, 0t or 0o prefix.
 */
{
    int             type ();
    register int    c, base;
    register long   n = 0;

    c = *s++;
    base = inbase;
    if (c == '0') {
	base = 8;
	switch (c = *s++) {
	case 'x':
	    base += 6;		/* FALLTHROUGH */
	case 't':
	    base += 2;		/* FALLTHROUGH */
	case 'o':
	    c = *s++;
	    break;
	default:
	    base = inbase;
	    break;
	}
    }
    while (c && (type (c) & HEXDIG)) {
	if (c >= 'A') {
	    c &= ~' ';		/* ensure that we are in an upper case */
	    c -= 'A' - '0' - 10;
	}
	c -= '0';
	if (c >= base)
	    break;
	n = (n * base) + c;
	c = *s++;
    }
    *nond_p = c;
    return (n);
}

prtsym (v, sp)
    unsigned long   v;
    struct symbol  *sp;
{

    prt (sp->name);
    if (v != sp->value) {
	putchr ('+');
	prtn (v - sp->value, 0);
    }
    return;
}

rdsub (from, to, n, pid)
    char           *from, *to;
    int             n, pid;
{
    long            l[2];
    register int    off;

    off = (int) from & (sizeof (l[0]) - 1);
    from -= off;
    l[0] = ptrace (RD_DATA, pid, from, 0);
    if ((off + n) > sizeof (l[0]))
	l[1] = ptrace (RD_DATA, pid, from + sizeof (l[0]), 0);
    bcopy ((char *) l + off, to, n);
    return;
}

wrsub (from, to, n, pid)
    char           *from, *to;
    int             n, pid;
{
    long            l[2];
    register int    off;

    off = (int) to & (sizeof (l[0]) - 1);
    to -= off;
    if (off || n != sizeof (l[0]))
	l[0] = ptrace (RD_DATA, pid, to, 0);
    if ((off + n) > sizeof (l[0]))
	l[1] = ptrace (RD_DATA, pid, to + sizeof (l[0]), 0);
    bcopy (from, (char *) l + off, n);
    ptrace (WR_DATA, pid, to, l[0]);
    if ((off + n) > sizeof (l[0]))
	ptrace (WR_DATA, pid, to + sizeof (l[0]), l[1]);
    return;
}

cmdsreg (c, fmt, get)
    int             c;
    char           *fmt;
    long            (*get) ();
{
    char            buf[10], *cp, c;
    int             i;
    struct regs    *rp, *findreg ();

    cp = buf;
    i = 0;
    while (i < 5 && (c = getchr (0)) != '\n') {
	i++;
	*cp++ = c;
    }
    *cp = '\0';
    if (c == '\n')
	PUSHC ('\n');

    if (rp = findreg (buf)) {
	*rp->value = dot;
	return;
    }
    error (BADRNAME);
}

int
bf_write (fd, data, size)
    int             fd;
    char           *data;
    int             size;
/*
 * Write to a file with a descriptor fd when no more space in a buffer
 * - otherwise keep adding to a storage.
 * Returns 0 on success or a negative error code.
 */
{
    int             grab = 0;
    int             rc;

    do {
	data += grab;
	if (size > (trbuf->buf_len - trbuf->buffered)) {
	    if (0 > (rc = write (fd, trbuf->storage, trbuf->buffered))) {
		return (rc);
	    }
	    trbuf->buffered = 0;
	}

	grab = (size > trbuf->buf_len ? trbuf->buf_len : size);
	/* bcopy defined in assist.s */
	bcopy (data, trbuf->storage + trbuf->buffered, grab);
	trbuf->buffered += grab;
	size -= grab;
    } while (0 < size);

    return (grab);
}				/* bf_write */

void
trflush ()
{
    if ((w_buf *) 0 != trbuf && 0 < trbuf->buffered) {
	for (;;) {		/* if error on write give a chance of a
				 * recovery */
	    if (0 <= write (trid, trbuf->storage, trbuf->buffered))
		break;
	    prtf (MW, trname);	/* error happened  */
	    prt (M2);		/* "Retry? (y/n) " */
	    if ('N' == (~' ' & getkchr ())) {
		putchr ('\n');
		break;		/* buffered output lost */
	    }
	}			/* retry loop */
	trbuf->buffered = 0;
    }
}				/* trflush */
