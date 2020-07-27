/*
	gioatari.c of Gulam/uE -- screen display and key board interface

	copyright (c) 1987 pm@cwru.edu
*/

#include "gu.h"

#if	!TOS
%%	this is Atari ST/TOS version
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


nrow2550()		/* called from tv.c via a set var	*/
{	register int	n;

	if (varnum(OwnFonts) == 0)
	{	if(Getrez() != 2)  return;	/* Not in high rez */
		n = varnum(Nrows);
		if (n == 50)	hi50(); else
		if (n == 25)	hi25();
	}
	vtinit();
	onlywind(1, 1);
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
} rp[3] =	{	{0xFFFF, 0xFFFF, 0, 8,  319, 199, 0, 1},
			{0xFFFF, 0xFFFF, 0, 8,  639, 199, 0, 1},
			{0xAAAA, 0x5555, 0, 16, 639, 399, 1, 1}
		};

/* This thing draws the gray-shaded rectangle that GEM-oriented programs
assume as their background. */

#include	<linea.h>

drawshadedrect()
{
	register int rez;
	unsigned int pattern[2];

	linea0(); 	rez = Getrez();

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
*/

#include "keynames.h"

static
char	unsh[128*3] = {
	/* -------scan codes: 0x00-0x0f ---------------------------- */
	'\000' /*nul*/, '\033' /*esc*/, 	
	'\061' /*1*/, '\062' /*2*/, '\063' /*3*/,
	'\064' /*4*/, '\065' /*5*/, '\066' /*6*/, '\067' /*7*/,
	'\070' /*8*/, '\071' /*9*/, '\060' /*0*/, 
	'\055' /*-*/, '\075' /*=*/,
	'\010' /* bs*/, '\011' /* ht*/, 

	/* ------------------ 0x10-0x1f ---------------------------- */
	'\161' /*q*/, '\167' /*w*/, '\145' /*e*/, '\162' /*r*/,
	'\164' /*t*/, '\171' /*y*/, '\165' /*u*/, '\151' /*i*/,
	'\157' /*o*/, '\160' /*p*/,
	'\133' /*[*/, '\135' /*]*/, 
	'\015' /* cr*/, '\000' /*ctrl*/,
	'\141' /*a*/, '\163' /*s*/, 

	/* ------------------ 0x20-0x2f ---------------------------- */
	'\144' /*d*/, '\146' /*f*/, '\147' /*g*/, '\150' /*h*/,
	'\152' /*j*/, '\153' /*k*/, '\154' /*l*/,
	'\073' /*;*/, '\047' /*'*/, '\140' /*`*/,
	'\000' /*lshift*/,
	'\134' /*\*/,
	'\172' /*z*/, '\170' /*x*/, '\143' /*c*/,  '\166' /*v*/,

	/* ------------------ 0x30-0x3f ---------------------------- */
	'\142' /*b*/, '\156' /*n*/, '\155' /*m*/,
	'\054' /*,*/, '\056' /*.*/, '\057' /* / */,
	'\000' /*rshift*/, '\000' /*unused*/, '\000' /*alt*/,
	'\040' /*space*/,
	'\000' /*caps lock*/,
	F1, F2, F3, F4, F5,


	/* ------------------ 0x40-0x4f ---------------------------- */
	F6, F7, F8, F9, F10,
	'\000' /*unused*/, '\000' /*unused*/,
	HOME,	UPARRO,	'\000' /*unused*/,
	KMINUS,	LTARRO,	'\000' /*unused*/,
	RTARRO,	KPLUS,	'\000' /*unused*/,

	/* ------------------ 0x50-0x5f ---------------------------- */
	DNARRO,	'\000' /*unused*/,	INSERT,	'\177' /*del*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,

	/* ------------------ 0x60-0x6f ---------------------------- */
	'\000' /*ISO key*/,
	UNDO,	HELP,	KLP,	KRP,	KSLASH,	KSTAR,
	K7,	K8,	K9,	K4,	K5,	K6,
	K1,	K2,	K3,

	/* ------------------ 0x70-0x72 ---------------------------- */
	K0,	KDOT,	KENTER,

	/* ------------------ 0x73-0x7f  undefined ----------------- */
	'\000','\000','\000','\000','\000','\000','\000','\000',
	'\000','\000','\000','\000','\000',
/**
 };


static
char	shif[128] = {
**/
	/* ------------------ 0x00-0x0f ---------------------------- */
	'\000' /*nul*/, '\033' /*esc*/, 	
	'\041' /*!*/, '\100' /*@*/,  '\043' /*#*/, '\044' /*$*/,
	'\045' /*%*/, '\136' /*^*/, '\046' /*&*/, '\052' /***/,
	'\050' /*(*/, '\051' /*)*/, '\137' /*_*/, '\053' /*+*/,
	'\010' /* bs*/, '\011' /* ht*/, 

	/* ------------------ 0x10-0x1f ---------------------------- */
	'\121' /*Q*/, '\127' /*W*/, '\105' /*E*/, '\122' /*R*/,
	'\124' /*T*/, '\131' /*Y*/, '\125' /*U*/, '\111' /*I*/,
	'\117' /*O*/, '\120' /*P*/,
	'\173' /*{*/, '\175' /*}*/, 
	'\015' /* cr*/, '\000' /*ctrl*/,
	'\101' /*A*/, '\123' /*S*/, 

	/* ------------------ 0x20-0x2f ---------------------------- */
	'\104' /*D*/, '\106' /*F*/, '\107' /*G*/, '\110' /*H*/,
	'\112' /*J*/, '\113' /*K*/, '\114' /*L*/,
	'\072' /*:*/, '\042' /*"*/, '\176' /*~*/,
	'\000' /*lshift*/,
	'\174' /*|*/,
	'\132' /*Z*/, '\130' /*X*/, '\103' /*C*/,  '\126' /*V*/,

	/* ------------------ 0x30-0x3f ---------------------------- */
	'\102' /*B*/, '\116' /*N*/, '\115' /*M*/,
	'\074' /*<*/, '\076' /*.*/, '\077' /* ? */,
	'\000' /*rshift*/, '\000' /*unused*/, '\000' /*alt*/,
	'\040' /*space*/,
	'\000' /*caps lock*/,
	F1+SHIFTED, F2+SHIFTED, F3+SHIFTED, F4+SHIFTED, F5+SHIFTED,


	/* ------------------ 0x40-0x4f ---------------------------- */
	F6+SHIFTED, F7+SHIFTED, F8+SHIFTED, F9+SHIFTED, F10+SHIFTED,
	'\000' /*unused*/, '\000' /*unused*/,
	HOME+SHIFTED,	UPARRO+SHIFTED,	'\000' /*unused*/,
	KMINUS+SHIFTED,LTARRO+SHIFTED,	'\000' /*unused*/,
	RTARRO+SHIFTED,KPLUS+SHIFTED,	'\000' /*unused*/,

	/* ------------------ 0x50-0x5f ---------------------------- */
	DNARRO+SHIFTED,	'\000' /*unused*/,
	INSERT+SHIFTED,	'\177' /*del*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,

	/* ------------------ 0x60-0x6f ---------------------------- */
	'\000' /*ISO key*/,
	UNDO+SHIFTED,	HELP+SHIFTED,	KLP+SHIFTED,
	KRP+SHIFTED,	KSLASH+SHIFTED,KSTAR+SHIFTED,
	K7+SHIFTED,	K8+SHIFTED,	K9+SHIFTED,
	K4+SHIFTED,	K5+SHIFTED,	K6+SHIFTED,
	K1+SHIFTED,	K2+SHIFTED,	K3+SHIFTED,

	/* ------------------ 0x70-0x72 ---------------------------- */
	K0+SHIFTED,	KDOT+SHIFTED,	KENTER+SHIFTED,

	/* ------------------ 0x73-0x7f  undefined ----------------- */
	'\000','\000','\000','\000','\000','\000','\000','\000',
	'\000','\000','\000','\000','\000',
/**
};

static
char	caps[128] = {
**/
	/* ------------------ 0x00-0x0f ---------------------------- */
	'\000' /*nul*/, '\033' /*esc*/, 	
	'\061' /*1*/, '\062' /*2*/, '\063' /*3*/,
	'\064' /*4*/, '\065' /*5*/, '\066' /*6*/, '\067' /*7*/,
	'\070' /*8*/, '\071' /*9*/, '\060' /*0*/, 
	'\055' /*-*/, '\075' /*=*/,
	'\010' /* bs*/, '\011' /* ht*/, 

	/* ------------------ 0x10-0x1f ---------------------------- */
	'\121' /*Q*/, '\127' /*W*/, '\105' /*E*/, '\122' /*R*/,
	'\124' /*T*/, '\131' /*Y*/, '\125' /*U*/, '\111' /*I*/,
	'\117' /*O*/, '\120' /*P*/,
	'\133' /*[*/, '\135' /*]*/, 
	'\015' /* cr*/, '\000' /*ctrl*/,
	'\101' /*A*/, '\123' /*S*/, 

	/* ------------------ 0x20-0x2f ---------------------------- */
	'\104' /*D*/, '\106' /*F*/, '\107' /*G*/, '\110' /*H*/,
	'\112' /*J*/, '\113' /*K*/, '\114' /*L*/,
	'\073' /*;*/, '\047' /*'*/, '\140' /*`*/,
	'\000' /*lshift*/,
	'\134' /*\*/,
	'\132' /*Z*/, '\130' /*X*/, '\103' /*C*/,  '\126' /*V*/,

	/* ------------------ 0x30-0x3f ---------------------------- */
	'\102' /*B*/, '\116' /*N*/, '\115' /*M*/,
	'\054' /*,*/, '\056' /*.*/, '\057' /* / */,
	'\000' /*rshift*/, '\000' /*unused*/, '\000' /*alt*/,
	'\040' /*space*/,
	'\000' /*caps lock*/,
	F1, F2, F3, F4, F5,


	/* ------------------ 0x40-0x4f ---------------------------- */
	F6, F7, F8, F9, F10,
	'\000' /*unused*/, '\000' /*unused*/,
	HOME,	UPARRO,	'\000' /*unused*/,
	KMINUS,	LTARRO,	'\000' /*unused*/,
	RTARRO,	KPLUS,	'\000' /*unused*/,

	/* ------------------ 0x50-0x5f ---------------------------- */
	DNARRO,	'\000' /*unused*/,	INSERT,	'\177' /*del*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,
	'\000' /*unused*/,'\000' /*unused*/,'\000' /*unused*/,

	/* ------------------ 0x60-0x6f ---------------------------- */
	'\000' /*ISO key*/,
	UNDO,	HELP,	KLP,	KRP,	KSLASH,	KSTAR,
	K7,	K8,	K9,	K4,	K5,	K6,
	K1,	K2,	K3,

	/* ------------------ 0x70-0x72 ---------------------------- */
	K0,	KDOT,	KENTER,

	/* ------------------ 0x73-0x7f  undefined ----------------- */
	'\000','\000','\000','\000','\000','\000','\000','\000',
	'\000','\000','\000','\000','\000'

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
