/*
	gcoatari.c of gulam -- Communications port interface

	Copyright (c) 1986 pm@cwru.edu		11/24/86

Everything in here is very AtariST specific.  Read the comments and
rewrite the routines with equiv functionality for other systems.

*/

#include "gu.h"
#include <setjmp.h>
#include <linea.h>

uchar	Szrsbuf[]  = "sz_rs232_buffer";
				/* align the screen on a 256-byte bndry	*/
#define	SZscreen	(32*1024 + 256)	/* sz of screen ram	*/


struct linea_init la_init;

extern				/* in xmdm.c	*/
jmp_buf abort_env, 		/* Long jump when transfers are aborted */
        time_env; 		/* Long jump on timeout	*/

typedef struct			/* Iorec() returns a ptr to this type */
{	char *ibuf;
	int ibufsiz;
	int ibufhd;
	int ibuftl;
	int ibuflow;
	int ibufhi;
}	rs232REC;

typedef	struct			/* screen record	*/
{	char *	logbasep;
	int	x;
	int	y;	
}	SCR;

local	int		firstentry = 1;
local	SCR		scrn[2];	/* see switchscreens()		*/
local	rs232REC	savedrs232rec;
local	rs232REC	*newrs232recp;
local	char		*rsbuf;		/* ptr to large rs232 rcv buf	*/
local	int		szrsbuf;
#define	SZrsbuf		16*1024

local	char *	tesmallocp;	/* ptr to mem occ by te screen 		*/
local	int  *	lineAvars;	/* address of line A interface vars	*/

local int	speed = -1;		/* baud rate of rs232 */
local int 	flowctl = 1,
		ucr = -1,
		rsr = -1,
		tsr = -1,
		scr = -1;

/* Reset the rs232 buffer to the savedrs232recd, if no one is using it;
i.e., neither teemulator, nor xmdm() is using. */

resetrs232buf()
{
	if (rsbuf == NULL || firstentry == 0) return;

	gfree(rsbuf); rsbuf = NULL;
	*newrs232recp = savedrs232rec;
}

/* Save the systems rs232buffer and install large one, if not already done. */

setrs232buf()
{
	if (rsbuf) return;
	szrsbuf = varnum(Szrsbuf);
	if (szrsbuf == 0)
	{	szrsbuf = 1024;
		insertvar(Szrsbuf, "1024");
	}
	gfree(rsbuf);
	rsbuf = (char *) gmalloc(szrsbuf);  if (rsbuf == NULL) return;

	newrs232recp = (rs232REC *) Iorec(0);
	savedrs232rec	= *newrs232recp;

	newrs232recp->ibuf	= rsbuf;
	newrs232recp->ibufsiz	= szrsbuf;
	newrs232recp->ibuflow	= szrsbuf/4;
	newrs232recp->ibufhi	= szrsbuf / 4 * 3;
	newrs232recp->ibufhd	= newrs232recp->ibuftl = 0;
}

	local
setspeed(p)
register char	*p;
{	static   int	tbl[10] = {0, 7, 4, 9, 2, 1, 1, 1, 1, 1};
	register int	i;

	i = *p - '0';
	if ((0 > i) || (i > 9)) {speed = -1; return;}
	speed = tbl[i];
	Rsconf(speed, flowctl, ucr, rsr, tsr, scr);
}

setrs232speed()
{
	char		buf[4];
	register int	r;

	if (speed >= 0) return;
	setspeed(varstr("baud_rate"));	if (speed >= 0) return;
	speed = -1; buf[0] = '\000'; 
	r = mlreply(
"press left most digit to set baud rate 019200 9600 4800 2400 1200 300:",
		buf, sizeof(buf));
	if (r != '\007') setspeed(buf);
}

	local
switchscreens()
{
	static int	n = 0;		/* index into scrn[]	*/

	register char * p;

	scrn[n].x = lineAvars[-14];	/* save cursor position	*/
	scrn[n].y = lineAvars[-13];
	n ++; n &= 1;	/* n = (n == 0? 1 : 0); */
	if (p = scrn[n].logbasep) Setscreen(p, p, -1);
	/* p should never be NULL here, but ... */

	Vsync(); Vsync();	/* don't know if these are really nec */
	mvcursor(scrn[n].y, scrn[n].x);
}

/* Send a break:  Modifies Bit 3 in the TSR (reg 23) of the Mfp
by bammi@cwru.edu  */

sbreak()
{	static char	*tsr_ptr = (char *)0x00fffa2dL;
	static long	*hz_200  = (long *)0x000004baL;

	register sint32 save_ssp;
	register sint32 time;

	save_ssp = Super(0L);	/* Super Mode */
	*tsr_ptr |= (char)8; 	/* set bit 3 of the TSR */
	time = *hz_200 + 50; 	/* wait for 250 ms */
	while(*hz_200 < time);	/* wait */
	*tsr_ptr &= (char)~8;	/* reset bit 3 of the tsr */
	Super(save_ssp);	/* Back to user Mode */
}

/* Set the alarm time.  This rtn is here because it is used primarily
by xmdm.c before doing readmodem(). */

static	long    alrm_time = 0L;	  /* Time of next timeout (200 Hz) */
extern	long	getticks();

alarm(n)
uint n;
{	register long ticks;

	if (n)
	{	ticks = getticks();
		/* We really need n * 200 but n * 256 if close enough */
		alrm_time = ticks + ( n << 8 );
	}
	else    alrm_time = 0L;
}


/* Read a character from the modem port.  Check for user abort (^C)
and timeout at the same time */

	int
readmodem()
{	register long	ticks;

	for (;;)
	{	if (useraborted()) longjmp(abort_env,-1);
		if(Bconstat(1))    return (int) Bconin(1);

		if(alrm_time != 0)	/* Check for time out if required */
		{	ticks = getticks();
			if(ticks >= alrm_time)
			    /* timeout */
			    longjmp(time_env, -1);
}	}	}

/* Send buffer to the modem port */

writemodem(buf,len)
register char *buf;
register int len;
{
	register int i;

	for(i = 0; i < len; i++)  Bconout(1, *buf++);
}

	local
tehelp()			/* help for the term emulator only	*/
{	register int	s;

	switchscreens();	/* to local screen	*/
	s = speed; speed = -1; setrs232speed();
	if (speed == -1) speed = s;
	if (speed != -1) switchscreens();	/* to remote screen	*/
}

	local
terminit()
{
	register char *p;
	int	*lineA();

	if (scrn[1].logbasep == NULL)
	{	scrn[0].logbasep = (char *) Logbase();
		tesmallocp = p = gmalloc(SZscreen);
		scrn[1].logbasep = (p == NULL
			? scrn[0].logbasep	/* align the screen mem */
			: (char *)(256L + (0xFFFFFF00L & (long) p)));
		lineAvars = lineA();
		scrn[1].x = 0;
		scrn[1].y = 24;
	}
	switchscreens();
	if (firstentry)
	{	firstentry = 0;
		gputs("\033E");  tehelp(); 
		setrs232buf();
		flushinput();
}	}


/* Flush any characters in the modem port */

flushinput()
{
	while (Bconstat(1)) Bconin(1);
}


/* exit term emulator */

teexit()
{
	firstentry = 1;
	/* should we set speed = -1; ? let's use old speed... */
	if (tesmallocp) gfree(tesmallocp);
	scrn[1].logbasep = tesmallocp = NULL;
	resetrs232buf();
}

/* Terminal emulator of Gulam.  Uses BIOS built-in vt52/vt100
emulation.  The statoc stoprecursion is there because we will be in
>mini< while receiving input for baud-rate setting and it is possible
the user invokes temul via Keypad-0 again.  */

temul()
{	static	 int	stoprecursion = 0;
	register long	i;

	if (stoprecursion) return; stoprecursion = 1; 
	terminit();		/* expected to set speed */
	if (speed == -1) {teexit(); goto ret;}
	mouseregular();
	for (;;)
	{	for (i = 0; Bconstat(1);)
		{	Bconout(2, (int) Bconin(1) & 0x7F);
			/* check the console once in a while */
			/* important at high speeds */
			if ((++i) == 32)  break;
		}
		{ register long	conin;	/*- usrin(): check user's kbd	-*/
		  if (conin = Crawio(0xff))	/* coupled to ggetchar() */
		  {	i = conin & 0x00FF0000L;
			if (i == UNDOKEY) break;
			else
			if (i == HELPKEY) tehelp();
			else
			{ Bconout(1, (int) (conin & 0xFF));
			  switch ((int) conin)
			  { default	: break;
			    case CTRLO	: flushinput(); break;
			    case CTRLS	:
				/* If there is more stuff in the rs232 port,
				stop display right now! Resume when ^Q is hit
				*/
				if (Bconstat(1))
				{ while ((ggetchar() & 0x7f) != CTRLQ);
				  Bconout(1, (int) CTRLQ);
				}
				break;
		
		} }	} }
	}
	switchscreens();
	ret:
	mousecursor();
	stoprecursion = 0;
}

/* -eof- */
