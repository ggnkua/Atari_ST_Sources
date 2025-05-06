/* Copyright (c) 1990 by Sozobon, Limited.  Author: Michal Jaegermann
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	fkeydefs.c  30 April 1990
 */

#define IN_FKEY

#include <fcntl.h>
#include "adb.h"
#include "lang.h"

#define MSIZE	0x800
#define SLACK	0x80
#define NUMFK   20		/* a number of used function keys */

extern char   **ftable;
extern int      ibase;
extern int      lastc;

void
kdefs (name)
    char           *name;
/*
 * Read file with strings to be attached to function keys and
 * create corresponding ftable entries
 */
{
    char           *rbuf;
    char           *target, *source, *stop;
    int             fh, rcount = 0;
    int             c, keynum = 0;
    extern char    *malloc ();
    extern int      atonum ();
    static int      accept (), attach ();

    if (-3 > (fh = open (name, O_RDONLY))) {
	/* prtf ("cannot open %s\n", name); */
	prtf (M1, name);
	return;
    }

    if ((char *) 0 == (rbuf = malloc (MSIZE + SLACK))) {
	/* prt ("kdefs: out of memory\n"); */
	prt (M6);
	return;
    }
    if ((char **) 0 == (ftable = (char **) malloc (NUMFK * sizeof (char *)))) {
	/* prt ("no memory for a table of function keys\n"); */
	prt (M2);
	goto out;
    }
    /* initialize ftable */
    keynum = NUMFK - 1;
    do {
	ftable[keynum] = (char *) 0;
	keynum -= 1;
    } while (keynum >= 0);

    target = rbuf;
    for (;;) {
	rcount = target - rbuf;	/* already this amount in a buffer */
	rcount = (rcount < SLACK ? MSIZE : MSIZE + SLACK - rcount);
	rcount = read (fh, target, rcount);
	if (rcount <= 0)	/* EOF or error */
	    break;
	source = target;
	stop = source + rcount;

	while (source < stop) {
	    if (target > rbuf) {/* previous string not finished */
		if (accept (&target, &source, stop)) {
		    if (0 > attach (keynum, rbuf, target))
			goto out;	/* out of memory */
		}
		else {

		    /*
		     * prtf ("definition of F%i too long - aborted\n",
		     * keynum);
		     */
		    prtf (M3, keynum);
		}
		target = rbuf;
	    }
	    else {
		if ('F' == *source++) {
		    keynum = atonum (source, 10, &c);
		    if ((' ' == c || '\t' == c) &&
			(0 < keynum && keynum <= NUMFK)) {
			/* skip digits and following white space */
			do {
			    source++;
			} while (c != *source);
			do {
			    source++;
			} while (' ' == *source || '\t' == *source);
			if ('\r' == *source && '\n' == *(source + 1)) {
			    /* reached end of line - skip this definition */
			    source += 2;
			    continue;
			}
			if (accept (&target, &source, stop)) {	/* full def */
			    if (0 > attach (keynum, rbuf, target))
				goto out;	/* out of memory */
			    target = rbuf;
			}
			continue;
		    }		/* if ((' ' == c || '\t' == c) && ... */
		}		/* if ('F' == *source++) */
		/* skip a remainder of a line */
		while (source < stop && '\n' != *source++);
	    }
	}			/* while ( source < step) */
    }				/* for (;;) */

    if (target > rbuf) {	/* some leftovers in rbuf */
	(void) attach (keynum, rbuf, target);
	if (rcount < 0) {
	    /* prtf ("read error: file %s\n", name); */
	    prtf (M4, name);
	}
    }

out:
    free (rbuf);
    return;
}				/* kdefs */


static int
accept (p_target, p_source, stop)
    char          **p_target;
    char          **p_source;
    char           *stop;
/*
 *  Copy characters from *source to *target, skipping escaped newlines,
 *  until newline found (returns 1) or, it this fails,  until 'stop'
 *  (returns 0). Updates values at p_target and at p_source.
 */
{
    register char  *target, *source;
    register char   c = 0;

    target = *p_target;
    source = *p_source;

    while (c != '\n' && source < stop) {
	if ('\\' == (c = *source++) && source < stop) {
	    if ('\r' == (c = *source++) && source < stop) {
		if ('\n' == *source) {
		    source++;
		    continue;
		}
	    }
	    *target++ = '\\';
	}
	*target++ = c;
    }

    *p_target = target;
    *p_source = source;
    return ('\n' == c);
}				/* accept */

static int
attach (keynum, from, to)
    int             keynum;
    char           *from;
    char           *to;
/*
 * If keynum in range, keynum slot is not taken yet, and memory
 * is available then put into ftable a string starting in
 * an address 'from' and ending in 'to'.
 * This string is modified by a removal of all trainling white
 * space and appending a sequence "\n\0" to it.
 *
 * Returns 0 on success, -1 if out of memory, and 1 if keynum
 * out of range or slot already taken
 */
{
    register char  *pos, *table, c;
    extern char    *malloc ();

    keynum -= 1;
    if ((unsigned) keynum >= NUMFK || ftable[keynum])
	/* to big or too small or already defined */
	return 1;

    to -= 1;
    while ('\n' == (c = *to) || ('\r' == c) || (' ' == c) || ('\t' == c)) {
	to -= 1;
    }
    to += 1;
    *to++ = '\n';
    *to++ = '\0';

    pos = from;
    if ((char *) 0 == (ftable[keynum] = malloc ((int) (to - pos)))) {
	/* prtf ("out of memory while defining F%i\n", keynum); */
	prtf (M5, keynum);
	return (-1);
    }

    table = ftable[keynum];
    while (pos < to)
	*table++ = *pos++;

    return 0;
}				/* attach */

void
hndlfkey ()
/*
 *  If what follows on a command line converts, in base 10,
 *  to 0 - print all definition of function keys.
 *  If in range 1 -- NUMFK, then execute definition - if exists.
 *  Otherwise ignore.  Only up to 11 non-blank characters get
 *  converted.
 */
{
    char           *cp, *cs, buf[12];
    int             i, base, c;
    long            n;
    long            atonum ();
    void            src_line ();

    if ((char **) 0 == ftable)
	return;

    cp = buf;
    cs = buf + 11;

    PEEKC;
    do {
	c = getchr (0);
	*cp++ = c;
    } while ('\n' != c && cp < cs);
    PUSHC (c);
    n = atonum (buf, 10, &c);

    if (0 == n) {		/* list */
	base = ibase;
	ibase = 10;
	for (i = 0; i < NUMFK; i++) {
	    if ((char *) 0 != ftable[i])
		prtf ("F%i %s", i + 1, ftable[i]);
	}
	ibase = base;
    }
    else if (n <= NUMFK) {
	src_line (ftable[n - 1]);
    }
    return;
}				/* hndlfkey */

#undef IN_FKEY
