/*
	temul.c of Gulam -- builtin Terminal Emulator

	Copyright (c) 1987 pm@cwru.edu
*/

#include "ue.h"
#include "keynames.h"
#define	Fnoop		0

#ifndef	TEB
KB  tekeybind[] = {{KEOTBL,		Fnoop}};

totebuf()	{}
tenewline()	{}
tesendtext()	{}
#else			/* includes the rest of this file */

uchar	Terminal[]	= "\257terminal\256";

#define	TESUNDEF	0
#define	TESCOOKED	1
#define	TESRAW		2

local int	testate	= TESUNDEF;	

BUFFER	*tebp;

KB  tekeybind[] = {
	{F1,			Fdelbword},
	{F2,			Fdelfword},
	{F3,			Fkill},
	{F4,			Fcopyregion},
	{F5,			Fkillbuffer},
	{F6,     		Flistbuffers},
	{F7,			Fusebuffer},
	{F8,			Ffilewrite},
	{F9,			Ffilevisit},
	{F10,    		Ffilesave},

	{HELP,			Fhelp},
	{UNDO,   		Fquickexit},
	{INSERT,		Fbackpage},
	{HOME,			Fforwpage},
	{UPARRO, 		Fbackline},
	{DNARRO,		Fgforwline},
	{LTARRO,		Fbackchar},
	{RTARRO,		Fforwchar},

	{CTRL|'[',		Fmetanext},
	{CTRL|'X',		Fctlxnext},
        {CTRL|'@',		Fsetmark},
        {CTRL|'A',		Fgotobol},
        {CTRL|'B',		Fbackchar},
	{CTRL|'C',		Ftogulambuf},
        {CTRL|'D',		Fforwdel},
        {CTRL|'E',		Fgotoeol},
        {CTRL|'F',		Fforwchar},
        {CTRL|'G',		Fctrlg},
        {CTRL|'H',		Fbackdel},
        {CTRL|'I',		Ftab},
        {CTRL|'J',		Findent},
        {CTRL|'K',		Fkill},
        {CTRL|'L',		Frefresh},
        {CTRL|'M',		Ftenewline},
        {CTRL|'N',		Fgforwline},
        {CTRL|'O',		Fopenline},
        {CTRL|'P',		Fbackline},
        {CTRL|'Q',		Fquote},
        {CTRL|'R',		Fbacksearch},
        {CTRL|'S',		Fforwsearch},
        {CTRL|'T',		Ftwiddle},
        {CTRL|'U',		Fgetarg},
        {CTRL|'V',		Fforwpage},
        {CTRL|'W',		Fkillregion},
        {CTRL|'Y',		Fyank},
        {CTRL|'Z',		Ftempexit},
	{CTRL|'_',		Fhelp},

	{')',			Fshowmatch},
	{'}',			Fshowmatch},
	{']',			Fshowmatch},

/*
keypad keys
-----------		*/
	{KLP,			Fmvdnwind},
	{KRP,			Fmvupwind},
	{KSLASH,		Fsplitwind},
	{KSTAR,			Fonlywind},
	{KMINUS,		Fprevwind},
	{KPLUS,			Fnextwind},
	{KENTER,		Ftesendtext},
	{KDOT,			Fgotoline},
	{K0,			Ftemul},


	{K7,			Fgotobob},
	{K8,			Freposition},
	{K9,			Fgotoeob},
	{K4,			Fbackword},
	{K5,			Fbackline},
	{K6,			Fforwword},
	{K1,			Fgotobol},
	{K2,			Fgforwline},
	{K3,			Fgotoeol},
	{CTLX|CTRL|'A',		Fshowkbdmacro},
        {CTLX|CTRL|'B',		Flistbuffers},
        {CTLX|CTRL|'C',		Fquit},
        {CTLX|CTRL|'F',		Ffilevisit},
        {CTLX|CTRL|'I',		Fbufferinsert},
        {CTLX|CTRL|'O',		Fdeblank},
        {CTLX|CTRL|'N',		Fmvdnwind},
        {CTLX|CTRL|'P',		Fmvupwind},
        {CTLX|CTRL|'R',		Ffileread},
        {CTLX|CTRL|'S',		Ffilesave},
        {CTLX|CTRL|'V',		Ffilevisit},
        {CTLX|CTRL|'W',		Ffilewrite},
        {CTLX|CTRL|'X',		Fswapmark},
        {CTLX|CTRL|'Z',		Fshrinkwind},
	{CTLX|'!',		Fspawn},
        {CTLX|'!',		Fexecbuf},
        {CTLX|'=',		Fshowcpos},
        {CTLX|'(',		Fctlxlp},
        {CTLX|')',		Fctlxrp},
        {CTLX|'1',		Fonlywind},
        {CTLX|'2',		Fsplitwind},
        {CTLX|'B',		Fusebuffer},
	{CTLX|'E',		Fctlxe},
        {CTLX|'F',		Fsetfillcol},
        {CTLX|'I',		Ffileinsert},
        {CTLX|'K',		Fkillbuffer},
        {CTLX|'N',		Fnextwind},
        {CTLX|'O',		Fnextwind},
        {CTLX|'P',		Fprevwind},
	{CTLX|'S',		Fsavebuffers},
        {CTLX|'Z',		Fenlargewind},
        {META|CTRL|'H',		Fdelbword},
        {META|'!',		Fexecbuf},
	{META|'.',		Fsetmark},
        {META|'>',		Fgotoeob},
        {META|'<',		Fgotobob},
	{META|'[',		Fgotobop},
	{META|']',		Fgotoeop},
	{META|'%',		Fqueryrepl},
	{META|' ',		Fdelwhite},
        {META|'B',		Fbackword},
        {META|'C',		Fcapword},
        {META|'D',		Fdelfword},
        {META|'F',		Fforwword},
        {META|'G',		Ftogulambuf},
        {META|'L',		Flowerword},
	{META|'Q',		Ffillpara},
	{META|'R',		Fbacksearch},
	{META|'S',		Fforwsearch},
        {META|'U',		Fupperword},
        {META|'V',		Fbackpage},
        {META|'W',		Fcopyregion},
 	{META|0x7F,		Fdelbword},
        {META|CTRL|'[',		Fgxpand},
        {META|CTRL|'D',		Fgxpshow},
        {META|CTRL|'F',		Ffilename},
        {0x7F,			Fbackdel},
	{HELP+SHIFTED,		Fkbreset},
				/* room for new key bindings */
	{0,			Fnoop},
	{0,			Fnoop},
	{0,			Fnoop},
	{0,			Fnoop},
	{0,			Fnoop},
	{0,			Fnoop},
	{0,			Fnoop},
	{0,			Fnoop},
	{0,			Fnoop},
	{0,			Fnoop},
	{KEOTBL,		Fnoop}
};

/* switch to >terminal< buffer */

totebuf()
{
	if (tebp = bfind(Terminal, TRUE, BFTEMP, TEKB, BMCTEM))
	{	switchwindow(popbuf(tebp));
		if (exitue != 0) refresh(FALSE, 1);
		exitue = 0;
		if (testate == TESUNDEF)
		{	testate = TESCOOKED; update();
			setrs232speed(); setrs232buf();
			flushinput();
}	}	}

/* Send the current line to remote */

tenewline()
{
	register uchar	*p, *q, *r, c;
	register LINE	*lp;
	register int	m, n;

	lp = curwp->w_dotp;
	q = lp->l_text; n = llength(lp); q[n] = '\r';
	m = (curwp->w_markp == lp? curwp->w_marko : 0);
	writemodem(q+m, n-m+1);
	q[n] = '\000'; userfeedback(q+m);
	llength(lp) = curwp->w_doto = m;
	lchange(WFEDIT); update();
}

tesendtext()
{
	register LINE	*linep;
	register int	loffs, s;
	uchar		c;

        REGION          region;

	s = getregion(&region); if (s != TRUE)  return;
        linep = region.r_linep;
        loffs = region.r_offset;
        while (region.r_size--)
	{	if (loffs == llength(linep))
		{	c = '\r';
                        linep = lforw(linep);
                        loffs = 0;
                } else
		{	c = lgetc(linep, loffs);
                        ++loffs;
                }
		writemodem(&c, 1);
        }
}

/* Keep the Terminal buffer up to date.  But don't hog the system
in doing so, because we will get another chance. In particular, quit
when kbd input is detected. */

#include <setjmp.h>

teupdate()
{	uchar		buf[100];
	extern  jmp_buf	abort_env;
	register uchar	*p;
	register int	n;
	register WINDOW	*wp;

	if (inmdmrdy() == 0)	return;

	wp = curwp;
	totebuf(); igotoeob(); backchar(TRUE, 1);

	more:
	for (n = 0, p = buf; (n++ < 99) && inmdmrdy();)
		*p++ = (uchar) (readmodem() & 0x7f);
	*p = '\000'; addcurbuf(buf);
	isetmark();
	if ((n >= 99) && (inkbdrdy() == 0)) goto more;
	switchwindow(wp);
	update();
}
#endif	TEB

/* -eof- */
