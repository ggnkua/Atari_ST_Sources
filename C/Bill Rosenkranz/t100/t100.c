/*
 *	t100 - simple term emulator. vt52 and ANSI (much of vt100)
 *
 *	by Bill Rosenkranz (rosenkra@convex.com).
 *
 *	based on st52 program by Nick Castellano (entropy@ai.mit.edu) but
 *	greatly changed so it bears little resemblence. i added the vt100
 *	support, including font changes. also lifted rs232init from Howard
 *	Chu's tip and rs232cd (carrier detect) from Steve Yelvington.
 *
 *	this was written with gcc 1.40 (and MiNT 10 libraries).
 *
 *	currently it is hardwired to vt100 (vt100_mode==1 always). i am
 *	not sure why you'd want vt52 anyway. you can toggle this by adding
 *	code to set vt100_mode to 0 (the host better know you changed!).
 *	my reference for the ANSI/vt100 escape codes was an old Falco
 *	terminal manual. it may not be accurate/modern/complete but does
 *	seem accurate for all the escapes i find in standard vt100 termcap.
 *
 *	it should be easy to hack in an escape to execute shell commands.
 *	i just have not done it. that way you could start up a kermit
 *	or xmodem or whatever. i have not tested this under MiNT or mgr.
 *
 *	restrictions: to (re)set the fonts, i do a line A init ($A000)
 *	to get the fonthdr pointer and from there get the address of the
 *	font data. i poke in a new address to my own data, being careful
 *	to set it back on exit (i hope :-). this means if your big-screen
 *	monitor can't support this, you are SOL. it also won't run on a
 *	TT since line A went bye-bye. note that you can always recompile
 *	with -UUSE_FONTS and it should work fine on any system. you just
 *	won't have bold and underline.
 *
 *	also, if you define SET_RS232_INIT at compile time, this relies
 *	on Rsconf returning a value. my understanding is that this does
 *	not work on TOS 1.0. the safe bet would be to check the TOS
 *	version. i have not tested this part of the code. currently,
 *	the rs232 paramaters are hardwired. i would set it from the
 *	control panel.
 *
 *	major problem: i can't figure out how to tell the host we are an
 *	80x25 term without changing /etc/termcap (difficult to do without
 *	the root passwd). setting TERMCAP did not help, at least with
 *	GNU emacs and less. maybe there is a termcap for 80x25 but i never
 *	checked. standard vt100 and vt100n has li set to 24. emacs manual
 *	sez stuff about this (maybe set TERM to vt100-25?). i have no idea
 *	about VMS and other non-unix systems with user library routines whose
 *	names contain "$". why bother? :-)
 */

#ifndef lint
static char *rcsid_t100_c = "$Id: t100.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: t100.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <osbind.h>
#include <mintbind.h>
#include <signal.h>
#include "t100.h"



#define MINTID		"MiNT"		/* MiNT's cookie string */
#define MAXWAIT		1000		/* see note in main loop */
#define PROMPT_STRING	"\n\rt100> "	/* MUST contain a newline */

#define NEWLINE		10		/* common chars */
#define ESC		27
#define RETURN		13


/*
 *	globals
 */
char		iobuf[8192];		/* new iorec for rs232 (first half */
					/* is in, second half out) */
_IOREC	       *recsav;			/* ptr to iorec struct */
_IOREC		oldirec;		/* old input iorec */
_IOREC		oldorec;		/* old output iorec */

int		par  = 0;		/* none, odd, even - 0, 1, 2 */
int		baud = 4;		/* see baud table 4=2400 */
int		echo = 0;		/* 0=off, 1=on */
int		flow = 0;		/* none, xon/xoff, rts/cts */

int		ucr, rsr, tsr, scr;	/* for resetting rs232 regs */

char	       *bauds[] = {"19200","9600","4800","3600","2400","2000",
			   "1800","1200","600","300","200","150","134",
			   "110","75","50"};		/* unused */

int		vt100_mode = 1;		/* 0 means revert to vt52 */
long		mintcookie = 0L;	/* if MiNT this will be non-NULL */

/*
 *	vt100 modes, etc...
 */
int		bold      = 0;		/* OFF 1m */
int		underline = 0;		/* OFF 4m */
int		blinking  = 0;		/* OFF 5m */
int		reverse   = 0;		/* OFF 7m */
int		wrap      = 1;		/* ON (set) */
int		video     = 0;		/* 0=normal (reset) */
int		repeat    = 1;		/* ON (set) */
int		curskey   = 0;		/* OFF (reset) */
int		keypad    = 0;		/* 0=normal (reset) */
int		colwidth  = 0;		/* 0=80 (reset), 1=132 */
int		smooth    = 0;		/* OFF (reset) */
int		origmode  = 0;		/* 0=normal (reset) */

short		kbinit, kbrpt;		/* saved key repeat stuff */

int		outtran[256];		/* char xlation table */



/*------------------------------*/
/*	main			*/
/*------------------------------*/
int main (int argc, char *argv[], char *envp[])
{
	short		kbret;
	int		x;
	register long	key;			/* raw Bconin value */
	register int	gnsrgh = MAXWAIT;
	register int	c;
#ifdef JUNK
	/* this was in st52 code. i don't use it...(it was #ifdef'd already) */
	char	       *terminal;
	char	       *etmp;
	char	       *newenv;


	etmp = (char *) envp;

	terminal = getenv ("TERM");
#ifdef DEBUG
	Cconws ("Terminal type:  ");
	puts (terminal);
#endif

	if (strcmp (terminal, "mgr") == 0)
	{

#ifdef DEBUG
		puts ("yep");
		printf ("value: %d\n",
		Pexec (200, "e:\\mint\\mgr\\bin\\vt52.prg",
			"e:\\mint\\mgr\\bin\\vt52.prg t100", envp));
#else
		Pexec (200, "e:\\mint\\mgr\\bin\\vt52.prg",
			"e:\\mint\\mgr\\bin\\vt52.prg t100", envp);
#endif
	}

#endif /*JUNK*/



	/*
	 *   some initializations: key repeat (save old) and wrap ON
	 */
	kbret  = (short) Kbrate (15, 2);/* repeat ESC [ ? 8 h */
	kbinit = (kbret >> 8) & 0x00ff;
	kbrpt  = kbret & 0x00ff;

	Bconout (CON, (int) 27);	/* wrap ESC [ ? 7 h */
	Bconout (CON, (int) 'v');



	/*
	 *   set up output char translation array (normally output==input,
	 *   but you can remap if you want here)
	 */
	for (x = 0; x < 256; x++)
		outtran[x] = x;
#ifdef SWAP_DEL_AND_BS
	/*
	 *   this swaps DEL and BS
	 */
	outtran[127] = 8;
	outtran[8]   = 127;
#endif


	/*
	 *   check for MiNT cookie
	 */
	mintcookie = getcookie (MINTID);
#ifdef DEBUG
	printf ("MiNT cookie %lx detected\n", mintcookie);
#endif



#ifdef USE_FONTS
	/*
	 *   set fonts
	 */
#ifdef DEBUG
	Cconws ("\n\rset fonts...\n\r\n\r");
#endif
	if (vt100_mode)
		fnt_roman ();

#if 0
/* test fonts */
			Cconws ("Roman font (normal)\n\r");
	fnt_bold ();	Cconws ("BOLD font\n\r");
	fnt_uline ();	Cconws ("uline font\n\r");
	fnt_reverse ();	Cconws ("reverse font\n\r");
	fnt_roman ();	Cconws ("back to Roman\n\r\n\r\n\r");

			Cconws ("roman ");
	fnt_bold ();	Cconws ("bold ");
	fnt_uline ();	Cconws ("uline ");
	fnt_reverse ();	Cconws ("reverse ");
	fnt_roman ();	Cconws ("roman\n\r\n\r");
#endif
#else /*! USE_FONTS*/
	vt100_mode = 0;
#endif /*USE_FONTS*/

#if 0
/* test Setcolor */
	Setcolor (0,0);
	Setcolor (1,0x777);
	Cconws ("any key\n\r");
	Crawcin ();
	Setcolor (0,0x777);
	Setcolor (1,0);
#endif


	/*
	 *   introductions...
	 */
	blurb ();


	/*
	 *   initialize rs232 (buffers and baud)
	 */
	Cconws ("\n\rinitialize rs232...\n\r");
	rs232init ();
	Cconws ("baud set to 2400.\n\r");


	/*
	 *   prompt
	 */
	Cconws (PROMPT_STRING);


	/*
	 *   main loop...
	 */
	for (;;)
	{
		/*
		 *   if there are characters at the AUX port, and we are
		 *   not going to interrupt, print them. without the
		 *   gnsrgh value, we can't interrupt and send a char.
		 *   MAXWAIT controls how many chars we let in before
		 *   checking the keyboard. 1000 seems reasonable.
		 */
		if (Bconstat (AUX) && gnsrgh--)
		{
			/*
			 *   get char
			 */
			c = (int) Bconin (AUX);

			/*
			 *   check for newline. if we are connected do nothing
			 *   special. otherwise print PROMPT_STRING (which
			 *   must have the newline we ignore in it)
			 */
			if (c == NEWLINE)
			{
				/*
				 *   if carrier detected...
				 */
				if (rs232cd ())
				{
					/*
					 *   ...output the newline...
					 */
					Bconout (CON, (int) c);
				}
				else
				{
					/*
					 *   ...otherwise do our prompt
					 */
					Cconws (PROMPT_STRING);
				}
			}
#ifdef EMUL_VT100
			else if ((c == ESC) && vt100_mode)
			{
				/*
				 *   assume if we get ESC that this will be
				 *   an ANSI/vt100 escape seqence and handle
				 *   it. vt100 also reads AUX for the rest
				 *   of the sequence. maybe it should return
				 *   an error code.
				 */
				vt100 ();
			}
			else
			{
				/*
				 *   just echo the char
				 */
				Bconout (CON, (int) c);
			}
#else
			else
			{
				/*
				 *   just echo the char. let the vt52 emulator
				 *   handle the rest...
				 */
				Bconout (CON, (int) c);
			}
#endif
		}
		else
		{
			/*
			 *   reset gnsrgh. see note above.
			 *
			 *   then check for keyboard input...
			 */
			gnsrgh = MAXWAIT;
			if (Bconstat (CON))
			{
				/*
				 *   get it...
				 */
				key = Bconin (CON);
#ifdef DEBUG
				printf ("-%08lx-\n", key);
#endif

				/*
				 *   what was it? check for possible internal
				 *   commands. here we can get fancy and look
				 *   for something to do shell escapes, file
				 *   xfers, etc. so far it is basic.
				 *
				 *   also look for arrow and keypad keys and
				 *   send the right thing depending on mode.
				 */
				handle_key (key);
			}
			else
			{
				/*
				 *   nothing to do so give up a quantum to
				 *   others if under MiNT...
				 */
				if (mintcookie)
					(void) Syield ();
			}
		}
	}

	/*NOTREACHED*/
}




/*------------------------------*/
/*	handle_key		*/
/*------------------------------*/
void handle_key (long key)
{

/*
 *	handle key from console...
 */

	char	buf[512];
	int	len;


	switch (key)
	{

/* cursor keys... */

	case 0x00480000:	/* up arrow */
		if (curskey)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'A');
		}
		else
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'[');
			Bconout (AUX, (int)'A');
		}
		break;
	case 0x00500000:	/* down arrow */
		if (curskey)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'B');
		}
		else
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'[');
			Bconout (AUX, (int)'B');
		}
		break;
	case 0x004d0000:	/* right arrow */
		if (curskey)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'C');
		}
		else
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'[');
			Bconout (AUX, (int)'C');
		}
		break;
	case 0x004b0000:	/* left arrow */
		if (curskey)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'D');
		}
		else
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'[');
			Bconout (AUX, (int)'D');
		}
		break;

/* keypad keys... */

	case 0x00700030:	/* 0 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'p');
		}
		else
		{
			Bconout (AUX, (int)'0');
		}
		break;
	case 0x006d0031:	/* 1 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'q');
		}
		else
		{
			Bconout (AUX, (int)'1');
		}
		break;
	case 0x006e0032:	/* 2 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'r');
		}
		else
		{
			Bconout (AUX, (int)'2');
		}
		break;
	case 0x006f0033:	/* 3 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'s');
		}
		else
		{
			Bconout (AUX, (int)'3');
		}
		break;
	case 0x006a0034:	/* 4 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'t');
		}
		else
		{
			Bconout (AUX, (int)'4');
		}
		break;
	case 0x006b0035:	/* 5 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'u');
		}
		else
		{
			Bconout (AUX, (int)'5');
		}
		break;
	case 0x006c0036:	/* 6 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'v');
		}
		else
		{
			Bconout (AUX, (int)'6');
		}
		break;
	case 0x00670037:	/* 7 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'w');
		}
		else
		{
			Bconout (AUX, (int)'7');
		}
		break;
	case 0x00680038:	/* 8 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'x');
		}
		else
		{
			Bconout (AUX, (int)'8');
		}
		break;
	case 0x00690039:	/* 9 */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'y');
		}
		else
		{
			Bconout (AUX, (int)'9');
		}
		break;
	case 0x004a002d:	/* - */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'m');
		}
		else
		{
			Bconout (AUX, (int)'-');
		}
		break;
	case 0x0072000d:	/* enter */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'M');
		}
		else
		{
			Bconout (AUX, (int)RETURN);
		}
		break;
	case 0x0071002e:	/* . */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'n');
		}
		else
		{
			Bconout (AUX, (int)'.');
		}
		break;
/*!!! not sure of this one */
	case 0x004e002b:	/* + */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'T');
		}
		else
		{
			Bconout (AUX, (int)'+');
		}
		break;
	case 0x00630028:	/* ( */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'P');
		}
		else
		{
			Bconout (AUX, (int)'(');
		}
		break;
	case 0x00640029:	/* ) */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'Q');
		}
		else
		{
			Bconout (AUX, (int)')');
		}
		break;
	case 0x0065002f:	/* / */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'R');
		}
		else
		{
			Bconout (AUX, (int)'/');
		}
		break;
	case 0x0066002a:	/* * */
		if (keypad)
		{
			Bconout (AUX, (int)ESC);
			Bconout (AUX, (int)'O');
			Bconout (AUX, (int)'S');
		}
		else
		{
			Bconout (AUX, (int)'*');
		}
		break;

/* keys we track for control... */

	case 0x00620000:	/* HELP */
		help ();
		if (!rs232cd ())
			Cconws (PROMPT_STRING);
		break;

	case 0x002E0000: 	/* alt-c (config) */ 
	case 0x000000E3:
		config ();
		if (!rs232cd ())
			Cconws (PROMPT_STRING);
		break;

	case 0x00260000:	/* alt-l (long break) */
		long_break ();
		if (!rs232cd ())
			Cconws (PROMPT_STRING);
		break;

	case 0x001f0000:	/* alt-s (shell) */
		buf[0] = 127;
		Cconws ("\n\r\n\rEnter shell command (eg ls):\n\r");
		Cconrs (buf);
		Cconws ("\n\r");
		len          = buf[1];
		buf[2+len+1] = '\0';
		if (system (&buf[2]))
		{
			Cconws ("\n\r\n\rCommand failed!\n\r\n\r");
		}
		if (!rs232cd ())
			Cconws (PROMPT_STRING);
		break;

	case 0x00250000:	/* alt-k (kermit) */
		buf[0] = 127;
		Cconws ("\n\r\n\rEnter kermit command (eg kermit -c):\n\r");
		Cconrs (buf);
		len = buf[1];
		buf[2+len+1] = '\0';
		Cconws ("\n\r\n\rAttempting to start Kermit....\n\r\n\r");
		if (system (&buf[2]))
		{
			Cconws ("\n\r\n\rKermit failed!\n\r\n\r");
		}
		if (!rs232cd ())
			Cconws (PROMPT_STRING);
		break;

	case 0x00100000: 	/* alt-q (quit) */ 
	case 0x000000F1:
		Cconws ("\n\r");
		bye (0);
		break;

	case 0x002C0000: 	/* alt-z */ 
	case 0x000000FA:
		/*
		 *   if mint, put ourselves in the
		 *   background
		 */
		if (mintcookie)
		{
			Cconws ("\n\r");
			(void) Pkill (Pgetpid (), SIGTSTP);
		}
		break;

/* anything else... */

	default:
		/* note the character translation */
		Bconout (AUX, outtran[(int) (key & KEYMASK)]);
	}
}




/*------------------------------*/
/*	blurb			*/
/*------------------------------*/
void blurb ()
{
	/* remain humble and don't plaster yer name all over the screen,
	   asking for money :-) */
	Cconws ("\n\r");
	if (vt100_mode)
	{
		fnt_reverse ();
		Cconws ("                              \n\r");
		Cconws ("   ");
		fnt_bold ();
		Cconws (" t100: ");
		fnt_uline ();
		Cconws ("Terminal Program ");
		fnt_reverse ();
		Cconws ("   \n\r");
		Cconws ("                              \n\r");
		fnt_roman ();
	}
	else
	{
		Cconws ("==============================\n\r");
		Cconws ("=== t100: Terminal Program ===\n\r");
		Cconws ("==============================\n\r");
	}
	Cconws ("\n\r");
	Cconws ("use HELP key for help...\n\r");
	Cconws ("\n\r");
}



/*------------------------------*/
/*	rs232init		*/
/*------------------------------*/
void rs232init ()
{

/*
 *	Set up a large I/O buffer for the RS232 port, and set initial
 *	speed, flow control, and parity.
 *
 *	(lifted from howard chu's tip)
 */

#ifdef SET_RS232_INIT
	register long	m68901reg;
#endif

	/*
	 *   get current buffer ptr (0 is rs232)
	 */
	recsav           = (_IOREC *) Iorec (0);

	oldirec          = *recsav;	/* save input record (struct) */
					/* this copies a structure, BTW */
	recsav->ibuf     = (char *) iobuf;
	recsav->ibufsiz  = (short) 4096;
	recsav->ibufhd   = (short) 0;
	recsav->ibuftl   = (short) 0;
	recsav->ibuflow  = (short) 100;
	recsav->ibufhi   = (short) 4000;

	recsav++;

	oldorec          = *recsav;	/* save output record (struct) */

	recsav->ibuf     = (char *) &iobuf[4096];
	recsav->ibufsiz  = (short) 4096;
	recsav->ibufhd   = (short) 0;
	recsav->ibuftl   = (short) 0;
	recsav->ibuflow  = (short) 100;
	recsav->ibufhi   = (short) 4000;


#ifdef SET_RS232_INIT

	/* this ONLY works with TOS 1.2 or later!!! */
	m68901reg   = Rsconf (baud, 0, -1, -1, -1, -1);

	scr         = m68901reg & 0xff;

	m68901reg >>= 8;
	tsr         = m68901reg & 0xff;

	m68901reg >>= 8;
	rsr         = m68901reg & 0xff;

	m68901reg >>= 8;
	ucr         = m68901reg & 0xf8;

	Rsconf(-1, -1, ucr, -1, -1, -1);	/* turn off parity */

#endif
}



/*------------------------------*/
/*	bye			*/
/*------------------------------*/
void bye (int excode)
{
	/*
	 *   reset to old I/O rec stuff, then exit
	 */
	*recsav = oldorec;
	recsav--;
	*recsav = oldirec;

#ifdef USE_FONTS
	fnt_normal ();
#endif
	Cconws ("\n\rExit t100...\n\r\n\r");


	/*
	 *   reset kbrate!!!
	 */
	Kbrate (kbinit, kbrpt);


	exit (excode);

	/*NOTREACHED*/
}

 

/*------------------------------*/
/*	rs232cd			*/
/*------------------------------*/
short rs232cd ()
{

/*
 * function: rs232cd
 *   author: Steve Yelvington
 *  purpose: checks for RS-232 carrier detect signal
 *   return: 
 *   values: 0 for no Carrier Detect
 *           1 for Carried Detect
 */

	register long	ssp;
	register short *mfp;
	register short	status;

	mfp    = ((short *) 0xfffffa00L);	/* base address of MFP */
	ssp    = Super (0L);			/* enter supervisor mode */
	status = *mfp;				/* get MFP status */
	Super (ssp);				/* return to user mode */

	return (!(status & 0x0002));		/* check for carrier */
}



/*------------------------------*/
/*	dobreak			*/
/*------------------------------*/
void dobreak ()
{

/*
 *	sends a break. currently unused...
 */

#define _MSLP			386		/* tune this for delay */
#define WAIT_MS(ms) \
{ \
    register short _I,_MS=ms; \
    for(;_MS>0;_MS--) \
	for(_I=_MSLP;_I>0;_I--) \
	    ; \
}

#ifdef SET_RS232_INIT
	tsr |= 0x08;
	Rsconf (-1, -1, -1, -1, tsr, -1);

	if (mintcookie)
		Fselect (300, 0L, 0L, 0L);	/* sleep 300 milliseconds :-) */
	else
		WAIT_MS(300);			/* wait 300 ms :-( */

	tsr &= 0xf7;
	Rsconf (-1, -1, -1, -1, tsr, -1);
#endif
}

