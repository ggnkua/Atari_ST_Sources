/*
 * $Header: f:/src/gulam\RCS\gioatari.c,v 1.1 1991/09/10 01:02:04 apratt Exp $
 * ======================================================================
 * $Log: gioatari.c,v $
 * Revision 1.1  1991/09/10  01:02:04  apratt
 * First CI of AKP
 *
 * Revision: 1.5 90.10.11.10.40.14 apratt 
 * Added 'extern' declarations for Font[] and Mdmport[].
 * 
 * Revision: 1.4 90.02.13.15.09.42 apratt 
 * Added setmdmport(), in response to "set mdmport X" -- calls
 * Bconmap().  This is far from bulletproof, esp. if TE has already
 * been initialized - the larger buffer was allocated for the original
 * mapping, and the new mapping is stuck with the ROM bugfer & baud rate.
 * Gulam needs to know about this in more detail.
 * 
 * Revision: 1.3 90.02.05.15.18.36 apratt 
 * Added printing Scrninit before changing fonts because changing
 * fonts with cursor visible is dangerous.  Assumes somebody
 * downstream (vtinit?) will enable the cursor again.
 * 
 * Added handler font() for variable Font ("font") -- sets
 * 8x8, 8x10, or 8x16 font in any rez, sets nrows accordingly,
 * and calls vtinit like nrows does.
 * 
 * Revision: 1.2 89.09.15.15.03.18 apratt 
 * Added TT resolutions to "drawshadedrect" which "gem" prefix calls.
 * 
 */

/*
	gioatari.c of Gulam/uE -- screen display and key board interface

	copyright (c) 1987 pm@cwru.edu
*/

#include "gu.h"
#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local charinc P_((uint c));
#undef P_

#if	!TOS
/* %%	this is Atari ST/TOS version */
#endif

#ifdef	H			/* thse are included in sysdpend.h */

#define	ggetchar()		Bconin(2)
#define	gputchar(c)		Bconout(2, c)
#define	onreversevideo()	gputs("\033p")
#define	offreversevideo()	gputs("\033q")
#define	toeolerase()		gputs("\033K")
#define	screenerase()		gputs("\033Y  \033J")
#define	invisiblecursor()	gputs("\033f")
#define	visiblecursor()		gputs("\033e")
#endif


#ifndef	H
uchar	Scrninit[] = "\033E\033f\033v"; /* clr scrn, cursr off, wordwrap on */

/* initialize the screen display and key board	*/

tioinit()	{mouseoff(); gputs(Scrninit); mouseon();}



/* N.B.  \033q is sent more often than should be necessary because the
ST remains in reverse video, in some situations, even after receiving
a \033q.  */

#define	SZinc	4*256		
static	uchar	inc[SZinc];	/* storage for typeahead keys	*/
static	int	inx = 0;	/* circular buffer is overkill	*/

	static
charinc(c)
register uint	c;
{	if (inx < SZinc-1) inc[inx++] = (uchar) c;
}

/* Store the string p as if the chars are typed ahead */

storekeys(p)
register uchar *p;
{	if (p) while (*p) charinc(*p++);
}

/* Return the next key pressed by the user; it is in inc if inx > 0 */

inkey()
{	register uint	i;


	if (inx > 0)
	{	i = (uint)(inc[0]);
		cpymem(inc, inc+1, --inx);	/* inx is very small */
	} else
#ifndef	TEB
	i = (uint) ggetchar();
#else
	{ checkagain:
		if (inkbdrdy()) i = (uint) ggetchar();
		else
		{	teupdate();
			goto checkagain;
	}	}
#endif
	return i;
}

#ifdef DEBUG

showinc()
{
	inc[inx] = '\000';
	mlwrite("inx %d :%s:\r\n", inx, inc);
}
#endif

/* Give the latest key pressed by the user.  Used for job control such
as ^C, ^G, ^S and ^Q.  So always do constat and conin.  Save the key
if this is a typeahead.  */

usertyped()
{	register int	c;

	c = -1;
	if (inkbdrdy())
	{	c = (uint) ggetchar();
		if (c != CTRLC && c != CTRLG
		&&  c != CTRLS && c != CTRLQ) charinc(c);
	}
	return c;
}

/* Return TRUE iff user typed a ^C or ^G */

useraborted()
{	register int c;

	c = usertyped();
	return (c == CTRLC || c == CTRLG);
}

/* Output string to screen; similar to Cconws, but should not treat ^C
as an exception.  */

gputs(s)
register char *s;
{	register int c;

	while (c = *s++) gputchar(c);
}

/* Clean up the virtual terminal system, in anticipation for a return
to the operating system.  Move down to the last line and clear it out
(the next system prompt will be written in the line).  Shut down the
channel to the terminal.  */

vttidy()
{
 	mvcursor(getnrow() - 1, 0);
 	gputs("\033K");
}

mvcursor(row, col)
register int	row, col;
{	static char es[5] = "\033Yrc";

	es[2] = (char) row + 32;
	es[3] = (char) col + 32;
	gputs(es);
}


/* 
 * added "gputs(Scrninit)" here because changing fonts when the cursor
 * is visible is dangerous.  Scrninit makes it invisible; 
 * vtinit makes it visible again.
 */

nrow2550()		/* called from tv.c via a set var	*/
{	register int	n;

	if (varnum(OwnFonts) == 0)
	{	if(Getrez() != 2)  return;	/* Not in high rez */
		n = varnum(Nrows);
		switch (n) {
		 case 50: gputs(Scrninit);hi50(); break;
		 case 40: gputs(Scrninit);hi40(); break;
		 case 25: gputs(Scrninit);hi25(); break;
		}
	}
	vtinit();
	onlywind(1, 1);
}

/*
 * extension by AKP... This sets nrows to the return from the
 * appropriate font-setting routine, then calls vtinit etc. as above.
 */

font()
{	register int n;
	extern uchar Font[];

	if (varnum(OwnFonts) == 0)
	{
		n = varnum(Font);
		switch(n) {
		 case 8: gputs(Scrninit); setvarnum(Nrows,font8()); break;
		 case 10: gputs(Scrninit); setvarnum(Nrows,font10()); break;
		 case 16: gputs(Scrninit); setvarnum(Nrows,font16()); break;
		}
	}
	vtinit();
	onlywind(1, 1);
}

/*
 * extension by AKP... This uses Bconmap to set the port to be used
 * by Bcon calls on device 1 ("AUX"), Rsconf, and Iorec calls.
 * By default (in ROM) it's the ST MFP port.
 */

setmdmport()
{
	extern uchar Mdmport[];
#ifdef __GNUC__
	Bconmap((int)varnum(Mdmport));	/* 43 is Bconmap() */
#else
	xbios(43,(int)varnum(Mdmport));	/* 43 is Bconmap() */
#endif
}

#ifdef DEBUG

	local char *
showpallete()
{	register int	i, j, n;
	register char *p;

	char		bf[5];
	WS		*ws;
	extern char	hex[];

	bf[3] = '-'; bf[4] = '\000';
	ws = initws(); strwcat(ws, "palette was ", 0);
	for (i=0; i < 16; i++)
	{	n = Setcolor(i, -1);
		for (j=3; j;) {bf[--j] = hex[n & 0xF]; n >>= 4;}
		strwcat(ws, bf, 0);
	}
	if (ws) p = ws->ps; gfree(ws);
	return p;
}
#endif

#ifdef __GNUC__
#define Setpallete Setpalette
#endif

pallete()
{	register char	*p, *q, *r;
	register int	i;
	static   int	pal[16];
	/* pal has to be static, not auto; Setpallete does not work
	othwerwise, because it takes effect at next Vsync()
	*/

	p = r = varstr("rgb");
	if (strlen(p) < 3) p = r = "006-770-707-070-";	/* default colors */
	q = p + strlen(p) - 3;
	for (i=0; i < 16; p += 4)
	{	pal[i] = (p < q?
		  (p[0] - '0')*256 + (p[1] - '0')*16 + (p[2] - '0') :0);
		i++;
	}
	Setpallete(pal);
}

local	struct r
{	int	p0, p1;
	int	x1, y1, x2, y2;
	int	c0, c1;
} rp[8] =	{	{0xFFFF, 0xFFFF, 0, 8,  319, 199, 0, 1},
			{0xFFFF, 0xFFFF, 0, 8,  639, 199, 0, 1},
			{0xAAAA, 0x5555, 0, 16, 639, 399, 1, 1},
			{0},
			{0xAAAA, 0x5555, 0, 16, 639, 479, 0, 1},
			{0},
			{0xAAAA, 0xFFFF, 0, 32, 1279,959, 1, 1},
			{0xFFFF, 0xFFFF, 0, 8,  319, 479, 0, 1}
		};

/* This thing draws the gray-shaded rectangle that GEM-oriented programs
assume as their background. */

#include	<linea.h>

drawshadedrect()
{
	register int rez;
	unsigned int pattern[2];

	/* linea0(); */
 	rez = Getrez();

	WMODE = 0; 	/* replace */
	COLBIT2		= COLBIT3 = 0;
	CLIP = 0;	PATMSK = 1;
	MFILL		= 0;
	PATPTR		= &pattern[0];
	pattern[0]	= rp[rez].p0;
	pattern[1] 	= rp[rez].p1;
	X1		= rp[rez].x1;
	Y1		= rp[rez].y1;
	X2		= rp[rez].x2;
	Y2		= rp[rez].y2;
	COLBIT0		= rp[rez].c0;
	COLBIT1		= rp[rez].c1;

	linea5();
}

/* Turn mouse movements into cursor keys */

mousecursor()
{	static char defikbdcmd[3] = {0x0a, 0x07, 0x07}; /* fast enough */
	static char usrikbdcmd[3] = {0x0a};
	register char	*p;
	extern	uchar	Mscursor[];

	if ((p = varstr(Mscursor)) && *p)
	{	usrikbdcmd[1] = (p[0] - '0')*16 + p[1] - '0';
		usrikbdcmd[2] = (p[2] - '0')*16 + p[3] - '0';
		p = usrikbdcmd;
	} else	p = defikbdcmd;
	if (p[1] && p[2]) Ikbdws(2, p);
}

/* Turn mouse back to its normal operation (relative coords) */

mouseregular()
{
	Ikbdws(0, "\010"); /* Ikbdws(0, put mouse back to relative) */
}
/*	mapping of keys follows			1/13/86
	scan code to ascii keymap for use in microEmacs on ST520
================
changed shifted keypad keys, changed to char constants
kbad 880601
================
*/

#include "keynames.h"

static
char	unsh[128*3] = {
/* UNSHIFTED */
	/* -------scan codes: 0x00-0x0f ---------------------------- */
	'\0' /*NUL*/, '\033' /*ESC*/, '1', '2', '3', '4', '5', '6',
	'7', '8', '9', '0', '-', '=', '\010' /*BS*/, '\011' /*HT*/,

	/* ------------------ 0x10-0x1f ---------------------------- */
	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i',
	'o', 'p', '[', ']', '\015' /*CR*/, '\0' /*CTL*/, 'a', 's',

	/* ------------------ 0x20-0x2f ---------------------------- */
	'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',
	'\'', '`', '\0' /*LSH*/, '\\','z','x','c','v',

	/* ------------------ 0x30-0x3f ---------------------------- */
	'b', 'n', 'm', ',', '.', '/', '\0' /*RSH*/, '\0' /*NA*/,
	'\0' /*ALT*/, ' ', '\0' /*CAP*/, F1, F2, F3, F4, F5,


	/* ------------------ 0x40-0x4f ---------------------------- */
	F6, F7, F8, F9, F10, '\0' /*NA*/, '\0' /*NA*/, HOME,
	UPARRO,	'\0' /*NA*/, KMINUS, LTARRO,
	'\0' /*NA*/, RTARRO, KPLUS, '\0' /*NA*/,

	/* ------------------ 0x50-0x5f ---------------------------- */
	DNARRO, '\0' /*NA*/, INSERT, '\177' /*DEL*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,

	/* ------------------ 0x60-0x6f ---------------------------- */
	'\0' /*ISO*/, UNDO, HELP,
	KLP, KRP, KSLASH, KSTAR, K7,
	K8, K9, K4, K5, K6, K1, K2, K3,

	/* ------------------ 0x70-0x72 ---------------------------- */
	K0,	KDOT,	KENTER,

	/* ------------------ 0x73-0x7f  undefined ----------------- */
	'\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0',

/* SHIFTED */

	/* -------scan codes: 0x00-0x0f ---------------------------- */
	'\0' /*NUL*/, '\033' /*ESC*/, '!', '@', '#', '$', '%', '^',
	'&', '*', '(', ')', '_', '+', '\010' /*BS*/, '\011' /*HT*/,

	/* ------------------ 0x10-0x1f ---------------------------- */
	'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I',
	'O', 'P', '{', '}', '\015' /*CR*/, '\0' /*CTL*/, 'A', 'S',

	/* ------------------ 0x20-0x2f ---------------------------- */
	'D', 'F', 'G', 'H', 'J', 'K', 'L', ':',
	'\"', '~', '\0' /*LSH*/, '|','Z','X','C','V',

	/* ------------------ 0x30-0x3f ---------------------------- */
	'B', 'N', 'M', '<', '>', '?', '\0' /*RSH*/, '\0' /*NA*/,
	'\0' /*ALT*/, ' ', '\0' /*CAP*/, F1+SHIFTED,
	F2+SHIFTED, F3+SHIFTED, F4+SHIFTED, F5+SHIFTED,


	/* ------------------ 0x40-0x4f ---------------------------- */
	F6+SHIFTED, F7+SHIFTED, F8+SHIFTED, F9+SHIFTED,
	F10+SHIFTED, '\0' /*NA*/, '\0' /*NA*/, HOME+SHIFTED,
	UPARRO+SHIFTED, '\0' /*NA*/, '-'/*KMINUS+SHIFTED*/, LTARRO+SHIFTED,
	'\0' /*NA*/, RTARRO+SHIFTED, '+'/*KPLUS+SHIFTED*/, '\0' /*NA*/,

	/* ------------------ 0x50-0x5f ---------------------------- */
	DNARRO+SHIFTED, '\0' /*NA*/, INSERT+SHIFTED, '\177' /*DEL*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,

	/* ------------------ 0x60-0x6f ---------------------------- */
	'\0' /*ISO*/, UNDO+SHIFTED, HELP+SHIFTED, '('/*KLP+SHIFTED*/,
	')'/*KRP+SHIFTED*/, '/'/*KSLASH+SHIFTED*/, '*'/*KSTAR+SHIFTED*/,
	'7'/*K7+SHIFTED*/, '8'/*K8+SHIFTED*/, '9'/*K9+SHIFTED*/,
	'4'/*K4+SHIFTED*/, '5'/*K5+SHIFTED*/, '6'/*K6+SHIFTED*/,
	'1'/*K1+SHIFTED*/, '2'/*K2+SHIFTED*/, '3'/*K3+SHIFTED*/,

	/* ------------------ 0x70-0x72 ---------------------------- */
	'0'/*K0+SHIFTED*/, '.'/*KDOT+SHIFTED*/, '\015'/*KENTER+SHIFTED*/,

	/* ------------------ 0x73-0x7f  undefined ----------------- */
	'\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0',

/* CAPSLOCKED */

	/* -------scan codes: 0x00-0x0f ---------------------------- */
	'\0' /*NUL*/, '\033' /*ESC*/, '1', '2', '3', '4', '5', '6',
	'7', '8', '9', '0', '-', '=', '\010' /*BS*/, '\011' /*HT*/,

	/* ------------------ 0x10-0x1f ---------------------------- */
	'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I',
	'O', 'P', '[', ']', '\015' /*CR*/, '\0' /*CTL*/, 'A', 'S',

	/* ------------------ 0x20-0x2f ---------------------------- */
	'D', 'F', 'G', 'H', 'J', 'K', 'L', ';',
	'\'', '`', '\0' /*LSH*/, '\\','Z','X','C','V',

	/* ------------------ 0x30-0x3f ---------------------------- */
	'B', 'N', 'M', ',', '.', '/', '\0' /*RSH*/, '\0' /*NA*/,
	'\0' /*ALT*/, ' ', '\0' /*CAP*/, F1, F2, F3, F4, F5,


	/* ------------------ 0x40-0x4f ---------------------------- */
	F6, F7, F8, F9, F10, '\0' /*NA*/, '\0' /*NA*/, HOME,
	UPARRO,	'\0' /*NA*/, KMINUS, LTARRO,
	'\0' /*NA*/, RTARRO, KPLUS, '\0' /*NA*/,

	/* ------------------ 0x50-0x5f ---------------------------- */
	DNARRO, '\0' /*NA*/, INSERT, '\177' /*DEL*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,
	'\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/, '\0' /*NA*/,

	/* ------------------ 0x60-0x6f ---------------------------- */
	'\0' /*ISO*/, UNDO, HELP,
	KLP, KRP, KSLASH, KSTAR, K7,
	K8, K9, K4, K5, K6, K1, K2, K3,

	/* ------------------ 0x70-0x72 ---------------------------- */
	K0,	KDOT,	KENTER,

	/* ------------------ 0x73-0x7f  undefined ----------------- */
	'\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0'

};

#define	shif	unsh+128
#define	caps	unsh+256

keysetup()
{
	Keytbl(unsh, shif, caps);
	/* The ptr this returns appears to be useless	*/
	/* It should return the ptrs to old tables	*/
}


keyreset()			/* should reset to the table we had	*/
{				/* prior to entering uE			*/
	Bioskeys();
}

#endif H

/* -eof- */

