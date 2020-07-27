/*
 * $Header: f:/src/gulam\RCS\gcoatari.c,v 1.1 1991/09/10 01:02:04 apratt Exp $ $Locker:  $
 * ======================================================================
 * $Log: gcoatari.c,v $
 * Revision 1.1  1991/09/10  01:02:04  apratt
 * First CI of AKP
 *
 * Revision: 1.7 90.10.11.12.00.28 apratt 
 * Fixed so the state machine matches what sz really sends: now
 * when you 'sz' on the remote, you automatically execute the value
 * of the variable rz_command.
 * 
 * Revision: 1.6 90.10.10.23.37.06 apratt 
 * Added, but #if'ed out, code to use Rsconf to set the "send break"
 * bit rather than writing to the TSR directly.  The code is untested,
 * but there.  Sends 1/4 second of break...
 * 
 * Added code to respond to "[CR|LF]CAN**B00" by executing the command
 * named in the string variable rz_command, which should just be "rz"
 * so you can start receiving files electrically.
 * This is untested, too, but in the works.
 * 
 * Revision: 1.5 90.02.13.15.22.42 apratt 
 * Changed gmalloc to Malloc for terminal screens: on TT they're >32K.
 * Also changed gfree to Mfree when exiting TE (via teexit).
 * 
 * Revision: 1.4 89.12.04.14.15.16 apratt 
 * Changed terminit so it allocates a screen, no matter how big that is.
 * (Still uses Setscreen to move it; will lose on Mega w/moniterm monitor.)
 * 
 * Revision: 1.3 89.06.16.17.23.32 apratt 
 * Header style change.
 * 
 * Revision: 1.2 89.06.02.12.48.26 Author: apratt
 * Added code to make switching to a special terminal screen dependent
 * on no_te_scr being FALSE (or missing).  If it's present and nonzero,
 * you don't switch screens.  (First cut; hope it works.)
 * 
 * Revision: 1.1 88.06.03.23.24.54 Author: apratt
 * Initial Revision
 * 
 */

/*
	gcoatari.c of gulam -- Communications port interface

	Copyright (c) 1986 pm@cwru.edu		11/24/86

Everything in here is very AtariST specific.  Read the comments and
rewrite the routines with equiv functionality for other systems.

*/

#include "gu.h"
#include <setjmp.h>
#include <linea.h>

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
static setspeed P_((char *p));
static switchscreens P_((void));
static tehelp P_((void));
static terminit P_((void));
#undef _P

uchar	Szrsbuf[]  = "sz_rs232_buffer";

#if 0
struct linea_init la_init;
#endif

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
	rsbuf = (char *) gmalloc((uint)szrsbuf);  if (rsbuf == NULL) return;

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
		buf, ((uint)sizeof(buf)));
	if (r != '\007') setspeed(buf);
}

	local
switchscreens()
{
	static int	n = 0;		/* index into scrn[]	*/

	register char * p;

	if (!varnum("no_te_scr")) {	/* conditional added AKP */
	    scrn[n].x = lineAvars[-14];	/* save cursor position	*/
	    scrn[n].y = lineAvars[-13];

	    n ++; n &= 1;	/* n = (n == 0? 1 : 0); */
	    if (p = scrn[n].logbasep) Setscreen(p, p, -1);
	    /* p should never be NULL here, but ... */

/*	    Vsync(); Vsync();	/* don't know if these are really nec */
				/* they're not... AKP */
	    mvcursor(scrn[n].y, scrn[n].x);
	}
}

/* Send a break:  Modifies Bit 3 in the TSR (reg 23) of the Mfp
by bammi@cwru.edu  */

/* 
 * Fixed by AKP: use Rsconf to modify that bit! Rsconf returns the
 * four register values in the bytes of a long, so you can read them,
 * set the right bit, then clear it to end the break.  This is compatible
 * with all Bconmappable devices.
 *
 * This code is as yet untested, and I don't want to include it
 * until I test it.
 */

sbreak()
{
#if 1
	static char	*tsr_ptr = (char *)0x00fffa2dL;
	static long	*hz_200  = (long *)0x000004baL;

	register long save_ssp;
	register long time;

	*tsr_ptr |= (char)8; 	/* set bit 3 of the TSR */
	time = *hz_200 + 50; 	/* wait for 250 ms */
	while(*hz_200 < time);	/* wait */
	*tsr_ptr &= (char)~8;	/* reset bit 3 of the tsr */
	Super(save_ssp);	/* Back to user Mode */
#else
	register long	*hz_200	= (long *)0x000004baL;
	register int otsr;
	register long save_ssp;
	register long time;


	save_ssp = Super(0L);	/* Super Mode */

	otsr = ((int)Rsconf(-1,-1,-1,-1,-1,-1) & 0x0000ff00L) >> 8;
	otsr |= 8;
	Rsconf(-1,-1,-1,-1,otsr,-1);
	time = *hz_200 + 50;
	while (*hz_200 < time) ;
	otsr &= ~8;
	Rsconf(-1,-1,-1,-1,otsr,-1);
	Super(save_ssp);
#endif
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
	long SZscreen;

    if (!varnum("no_te_scr")) {
	if (scrn[1].logbasep == NULL)
	{
		lineAvars = lineA();

		/* (AKP) compute size of screen rather than assuming it */
		/* Add 256 for alignment.  Alignment is one of the things */
		/* which varies most among ST/STE/TT, but 256 is the */
		/* common denominator. */
		/* Screen size in bytes is (nplanes * xres * yres) / 8 */

		SZscreen = (((long)lineAvars[0] *
			    (long)lineAvars[-6] *
			     (long)lineAvars[-2]) >> 3) + 256;


		scrn[0].logbasep = (char *) Logbase();

		/* this was gmalloc, but screens can be >32K! */
		tesmallocp = p = (char *)Malloc(SZscreen);

		scrn[1].logbasep = (p == NULL
			? scrn[0].logbasep	/* align the screen mem */
			: (char *) ((((long)p)+255L) & ~255L));
		scrn[1].x = 0;
		scrn[1].y = 0;
	}
	switchscreens();
    }
    if (firstentry)
    {	firstentry = 0;
	gputs("\033E");  tehelp(); 
	setrs232buf();
	flushinput();
    }
}


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

	/* this was gfree() but screens are allocated with Malloc now */
	if (tesmallocp) Mfree(tesmallocp);

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
	int rzstate = 0;
	uchar *rzcmd;

	if (stoprecursion) return; stoprecursion = 1; 
	terminit();		/* expected to set speed */
	if (speed == -1) {teexit(); goto ret;}
	mouseregular();
	for (;;)
	{	for (i = 0; Bconstat(1);)
		{
		    register char c = (Bconin(1) & 0x7f);
		    switch (rzstate) {
			case 0: if (c == 13 || c == 10) rzstate++;
				break;
			case 1:
			case 2: if (c == '*') rzstate++;
				else if (c == 13 || c == 10) rzstate = 1;
				else rzstate = 0;
				break;
			case 3: if (c == ('X'-'@')) rzstate++;
				else rzstate = 0;
				break;
			case 4: if (c == 'B') rzstate++;
				else rzstate = 0;
				break;
			case 5: if (c == '0') rzstate++;
				else rzstate = 0;
				break;
			case 6: if (c == '0' &&
				    (rzcmd = varstr("rz_command")) != ES) {
				    /* execute the command in 'rz_command' */
				    Bconout(2,'\r');
				    processcmd(strdup(rzcmd),0);
				}
				rzstate = 0;
				break;
		    }
		    Bconout(2, (int) c);
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
			  { /* default	: break; */
#ifdef STUPID_CTLO_HANDLING_IN_TE
			    case CTRLO	: flushinput(); break;
#endif

#ifdef STUPID_CTLS_HANDLING_IN_TE
			    case CTRLS	:
				/* If there is more stuff in the rs232 port,
				stop display right now! Resume when ^Q is hit
				*/
				if (Bconstat(1))
				{ while ((ggetchar() & 0x7f) != CTRLQ);
				  Bconout(1, (int) CTRLQ);
				}
				break;
#endif
		
		} }	} }
	}
	switchscreens();
	ret:
	mousecursor();
	stoprecursion = 0;
}

/* -eof- */
