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
 *	help.c
 */
/*
 *  Modifications:
 *    - this file compiled conditionally only if HELP defined
 *    - tie up a number of lines displayed to a window size
 *    - all 'display help' functions consolidated in this file.
 *    - function help does not save an image of a current line
 *      but it contents and a positioning information
 *    Michal Jaegermann, July 1991
 */
char	 *svline;		/* define always, since start.s refers to it */
#ifdef HELP

#include <setjmp.h>
#include "adb.h"

#define IN_HELP
#define H_WIDTH 40		/* witdh of a help line */
#include "lang.h"

extern char    *linbuf;
extern int      l_restart, w_restart;

char          **helplist[] = {
			      help4,
			      help3,
			      help2,
			      help1,
			      0
};

extern struct window w;

extern char *screen;
extern w_curc(), w_putc(), lcopy();
extern unsigned long   wcurl_max;


void
help ()
{
    char         ***p;
    char          **q;
    register char *cp;
    int		svcol, width = w.cols;
    int         svlr, svwr;
    int             i;

    w_curs (0);				/* cursor off */
    svcol = w.curc;			/* cursor was here */
    svlr = l_restart;			/* keep backspacing info */
    svwr = w_restart;
    w.curc = width - H_WIDTH;		/* last H_WIDTH columns used by help */
    bcopy (linbuf, svline, width);	/* keep the current line */
    width -= 1;
    svline[width] = '\0';

    for (p = helplist; *p;) {		/* show help screens */
	q = *p++;
	helpscr (q, *p != 0);
	if (*p) {
	    i = gemdos (7) & 0xff;
	    if (i == 'q' || i == 'Q')
		break;
	}
    }

    w.curl = wcurl_max;			/* go to the last line */
    
    w.curc = 0;
    cp = svline;
    while (*cp)				/* restore saved lined at the bottom */
	w_put (*cp++);
    bcopy(svline, linbuf, width);
    l_restart = svlr;			/* restore backspacing info */
    w_restart = svwr;
    w.curc = svcol;			/* and our line position */
    w_curs (1);				/* cursor on */
}

helpscr (p, more)
    char          **p;
{
    int             nlines = 0;

    for (nlines = 0; nlines < w.lines - 1; nlines++) {
	if (*p)
	    helpline (*p++, nlines, H_WIDTH);
	else
	    helpline ("", nlines, H_WIDTH);
    }
/*	helpline(more ? "   q - quit  <space> - more" : "", nlines, 39); */
    helpline (more ? M1 : "", nlines, H_WIDTH - 1);
}

#define W_HLINE(line) \
    (w.curl=(unsigned long)(line) * w.lsz, w.curc=w.cols - H_WIDTH)

#define W_HCHR(c)     w_put((c))

helpline (p, line, n)
    char           *p;
{
    int             i;

    W_HLINE (line);
    for (i = 0; i < n; i++)
	if (*p)
	    W_HCHR (*p++);
	else
	    W_HCHR (' ');
}
#endif
