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
 *	window.c
 */
/*
 * Modifications:
 *  - w_nl rewritten to allow recording of display lines in a transcript
 *    file
 *  - small mods to speedup scrolling
 *     Michal Jaegermann, May 1990
 *  - TT modifications - startup code computes now most of fields
 *    in 'window' structure, since it depends on a machine and resolution
 *    and we would like to avoid using calls to malloc() to reserve
 *    screen area (and linesv buffer if help is compiled in).
 *    Changes in types of window structure. Functions putting
 *    bits on a debugger screen more streamlined.
 *     Michal Jaegermann, July 1991
 */
#include "adb.h"
#include "lang.h"

/*
 * Size of a needed buffer for a screen and a value for 'screen'
 * are computed by a startup code, since we would not to hardwire
 * screen size into this program, but we also want to avoid
 * using malloc()
 */
char           *screen;  /* initialized and space reserved in a startup
			    code - depends on a monitor and resolution */
long            oscreen;
int             mywindow;
int             ucolor0, ucolor1;
int             opcode_pos = ALIGN_A;
char           *linbuf; /* initialized and space reserved in a startup
			   code - wider by two then a current screen width;
			   function cleanlb() from assist.s has to be
			   aware about this sizes */

extern int      trid;
extern char    *trname;
extern w_buf   *trbuf;
extern void     cleanlb ();
extern int      l_restart, w_restart, lb_fill;
extern char    *lbuf, *cnbuf;

winopen ()
{
    long            xbios ();


/***  this code moved to start.s

    screen = scrbuf;
    screen += 0xff;
    screen = (char *) ((long) screen & ~0xffL);

***/

    oscreen = xbios (2);
    xbios (5, -1L, screen, -1);
    ucolor0 = xbios (7, 0, 0);
    ucolor1 = xbios (7, 1, 0x777);
    w_init ();
    mywindow = 1;
}

winswtch ()
{
    long            xbios ();

    if (mywindow) {
	xbios (5, -1L, oscreen, -1);
	xbios (7, 0, ucolor0);
	xbios (7, 1, ucolor1);
    }
    else {
	oscreen = xbios (2);
	xbios (5, -1L, screen, -1);
	ucolor0 = xbios (7, 0, 0);
	ucolor1 = xbios (7, 1, 0x777);
    }
    mywindow = !mywindow;
}

winclose ()
{
    if (mywindow)
	winswtch ();
}


putchr (c)
    char            c;
{
    w_curs (0);
    /* c &= 0x7f;  */
    switch (c) {
    case '\b':
	w_bs ();
	break;
    case '\t':
	w_tab ();
	break;
    case '\n':
	w_nl ();
	break;
    default:
	w_put (c);
	break;
    }
    w_curs (1);
}

/*
 * This is the single instance of this structure and its fields
 * are initialized in a startup code
 */

struct window w;

unsigned long   wcurl_max;
static char    skips[8] = {  /* 2 to this power gives a number of
                                 words to skip to the next alpha cell */
		3,	/* 0 - ST low */			
		2,	/* 1 - ST medium */
		1,	/* 2 - ST high */
		0,	/* 3 - nobody */
		3,	/* 4 - TT medium */
		0,	/* 5 - nobody */
		1,	/* 6 - TT high */
		4 	/* 7 - TT low */
		};

w_init ()
{
    int             w_res;
    char           *fontsp;

/***
    fields of w, with an exception of w.csz, initialized already in start.s
***/
    fontsp = w.font;
    if ( 2 > (w_res = w.res)) 	/* ST low and medium */
	fontsp += 4;
    else
	fontsp += 8;		/* ST high and all TT resolutions */

    fontsp = *(char **) fontsp;
    fontsp += 0x4c;
    w.font = *(char **) fontsp;

    if (0 == w_res || 7 == w_res) /* low, 40 columns, ST or TT */ 
	opcode_pos = 4;		/* print in the next line with an indent */
    w.csz = skips[w_res];
    wcurl_max = (unsigned long)(w.lines - 1) * w.lsz;
    w_curs (1);
}

w_put (c)
    char            c;
{
    register int    i;
    register char  *fp;
    register char  *tp;
    register unsigned int    woff;
    register long  width;

    woff = w.curc;
    linbuf[woff] = c;
    tp = screen;
    tp += woff & 1;
    woff >>= 1;			/* loose the lowest bit */
    tp += (woff << w.csz);
    tp += w.curl;

    fp = &w.font[c];
    i = w.fontsz;
    width = w.fsz;
    do {
	*tp = *fp;
	tp += width;
	fp += 256;
    } while (--i > 0);
    w.curc++;
    if (w.curc >= w.cols)
	force_nl ();
}

w_curs (flg)
{
    register int    i;
    register char *tp;
    register unsigned int woff;
    register long   width;
    char            val;

    tp = screen;
    woff = w.curc;
    tp += (woff &1);
    woff >>= 1;			/* loose the lowest bit */
    tp += (woff << w.csz);
    tp += w.curl;

    val = flg ? 0xff : 0;

    i = w.fontsz;
    width = w.fsz;
    do {
	*tp = val;
	tp += width;
    } while (--i > 0);
}

w_bs ()
{
    if (w.curc > w_restart) {
	--w.curc;
	w_put (' ');
    }
    w.curc = w_restart;
    prt (&lbuf[l_restart]);
}

optnl ()
{
    if (w.curc) {
	w_curs (0);
	w_nl ();
	w_curs (1);
    }
}

align (n)
{
    w_curs (0);
    if (n >= w.cols) {
	n = (n % w.cols);
	force_nl ();
    }
    else if (w.curc > n) {
	force_nl ();
    }
    w.curc = n;
    w_curs (1);
}

tab (n)
{
    w_curs (0);
    w.curc += n;
    w.curc -= (w.curc % n);
    if (w.curc >= w.cols)
	force_nl ();
    w_curs (1);
}

w_tab ()
{
    w.curc += 10;
    w.curc -= (w.curc % 10);
    if (w.curc >= w.cols)
	force_nl ();
}

w_nl ()
{
    extern void     trclose ();
    extern int      (*trout) ();

    if (trid != NO_TRANS) {	/* send a current screen line to transcript */
	linbuf[w.curc] = '\r';
	linbuf[w.curc + 1] = '\n';
	if (0 > (*trout) (trid, linbuf, (w.curc + 2))) {
	    if ((w_buf *) 0 == trbuf)
		/* prtf("\nerror on write to %s\n", trname); */
		prtf (MW, trname);
	    trclose ();
	}
    }
    w.curc = 0;
    if (w.curl >= wcurl_max)
	w_scrup ();
    else
	w.curl += w.lsz;
    cleanlb ();
}

force_nl ()
{
    w_restart = 0;
    l_restart = lb_fill;
    w_nl ();
}

/*
 * Watch out - this function will work as long as (wcurl_max / 16)
 * fits into 16 bits!  For huge screens lcopy has to be modified.
 */
w_scrup ()
{
    register char		*clr;
    register int		 cnt;
    register unsigned long	 offset = wcurl_max;

    clr = screen;
    cnt = w.lsz;
    lcopy (clr + cnt, clr, (unsigned int) (offset / 16));
    clr += offset;
    do {
	*clr++ = 0;
    } while (--cnt);
}
