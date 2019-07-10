#define DEBUG

/*
 *	vt100.c - emulates a vt100 using vt52 codes when possible
 *
 *	this code handles an escape sequence only. on entry, the ESC has
 *	already been read from AUX:. it writes all output to CON: via bios.
 *
 *	this compiles (and runs :-) with gcc 1.40 and mint libraries, PL 10.
 *	it should also work with "normal" gcc libraries.
 */


#ifndef lint
static char *rcsid_vt100_c = "$Id: vt100.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: vt100.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <osbind.h>
#include "t100.h"



/*
 *	macro to get a char from AUX. we check status some number of times.
 *	if no char available, we may have a hosed connection or host screwed
 *	up. otherwise, if char available, get it. use BIOS...
 */
#define GET_NEXT_CHAR \
{ \
    long counter; \
    for (counter = 1000; counter; counter--) {\
	if (Bconstat (AUX)) break; \
    } \
    if (counter == 0) goto no_char_avail; \
    c = (int) Bconin (AUX); \
}


/*
 *	default value if none specified. if not 0, be careful!
 */
#define VAL_DEFAULT	0


/*
 *	modes, etc...
 */
extern int	bold;			/* OFF 1m */
extern int	underline;		/* OFF 4m */
extern int	blinking;		/* OFF 5m */
extern int	reverse;		/* OFF 7m */
extern int	wrap;			/* ON (set) */
extern int	video;			/* 0=normal (reset) */
extern int	repeat;			/* ON (set) */
extern int	curskey;		/* OFF (reset) */
extern int	keypad;			/* 0=normal (reset) */
extern int	colwidth;		/* 0=80 (reset), 1=132 */
extern int	smooth;			/* OFF (reset) */
extern int	origmode;		/* 0=normal (reset) */



/*------------------------------*/
/*	vt100			*/
/*------------------------------*/
void vt100 ()
{

/*
 *	emulate vt100. upon entry, we got a ESC char from AUX. only the
 *	ESC was read so far.
 *
 *	note: in order to report things back to the host, we must know
 *	things like baud rate, parity, etc. these are not in the termcap,
 *	however, so don't sweat it for now. we also can't report postion.
 *
 *	we do not do character generators (g0 and g1).
 *
 *	we do not do LEDs.
 *
 *	here is the basic logic:
 *
 *		we got an ESC already from AUX.
 *
 *		get_next_char.
 *		if (current_char == >,=,8,7,or M)
 *		    handle.
 *		    done.
 *		else if (current_char == [)
 *		    get_next_char.
 *		    if (current_char == ?)
 *		        get_next_char. it should be 1-8. save val.
 *		        get_next_char. it should be h or l.
 *		        handle.
 *		        done.
 *		    else if (current_char == number)
 *		        read all of number. convert and save.
 *		        get_next_char.
 *		    else
 *		        val1 = 0 (or 1)
 *		    if (current_char == ;)
 *		        get_next_char.
 *		        if (current_char == number)
 *		            read all of number. convert and save.
 *		            get_next_char.
 *		        else
 *		            val2 = 0 (or 1)
 *		        switch (current_char)
 *		          H or f
 *		          r
 *		          R
 *		    else
 *		        switch (current_char)
 *		          A
 *		          B
 *		          C
 *		          D
 *			  H
 *		          J
 *		          K
 *		          L
 *		          M
 *		          P
 *		          g
 *		          h
 *		          l
 *		          m
 *		          n
 *		          x
 *		          @
 *		else
 *		    error?
 *
 */

/*

here are likely codes to be seen. xxx is optional, 0, 1, or 2 chars:

\E	[	xxx	J
\E	[	xxx	K
\E	[	xxx	;	xxx	H	position cursor
\E	[	xxx	H			special case of position cursor
\E	[	xxx	;	xxx	r
\E	[	xxx	C			cursor right
\E	[	xxx	D			cursor left
\E	[	xxx	B			cursor down
\E	[	xxx	A			cursor up
\E	8
\E	7
\E	M
\E	[	?	1	l		cursor key mode reset
\E	[	?	1	h				set
\E	[	?	3	l		col width reset (to 80)
\E	[	?	4	l
\E	[	?	5	l
\E	[	?	7	h
\E	[	?	8	h		auto repeat mode set
\E	>
\E	=
\E	[	1	m
\E	[	4	m
\E	[	5	m
\E	[	7	m
\E	[	0	m
\E	[	m


this is a real vt100 termcap with equiv vt52 codes:

vt100			vt52		desc

:cd=\E[J:		:\EJ:		clear display after cursor
:ce=\E[K:		:\EK:		clear to end of line
:cl=\E[;H\E[2J:		:\EH\EJ:	home cursor, clear screen
:cm=\E[%i%d;%dH:	:\EY%+ %+ :	move to row #1 and col #2
:cs=\E[%i%d;%dr:	---		change scrolling region to rows #1 to #2
:ho=\E[H:		:\EH:		move cursor home
:is=\E[1;24r\E[24;1H:	:\Ev\Ee:	initialization string (wrapon, curs vis)
:nd=\E[C:		:\EC:		non-destructive space (move right)
:rc=\E8:		:\Ek:		restore cursor to position saved by sc
:sc=\E7:		:\Ej:		save absolute cursor position
:sr=\EM:		:\EI:		scroll reverse one line
:up=\E[A:		:\EA:		move cursor up

:rs=\E>\E[?3l\E[?4l\E[?5l\E[?7h\E[?8h:	reset to sane modes

:ke=\E[?1l\E>:		---		turn keypad off, if possible
:ks=\E[?1h\E=:		---		turn keypad on, if possible

:mb=\E[5m:		---		turn on blinking attribute
:md=\E[1m:		---		turn on bold
:me=\E[m:		:\Eq:		turn off all attributes
:mr=\E[7m:		:\Ep:		turn on reverse video

:se=\E[m:		:\Eq:		end standout (reverse) mode
:so=\E[7m:		:\Ep:		begin standout (reverse) mode
:ue=\E[m:		---		end underline mode
:us=\E[4m:		---		begin underline mode

 */


	register int	c;
	register int	val1;
	register int	val2;
	int		row;
	int		col;
	int		i;




	/*
	 *   this is first char after an ESC.
	 */
	GET_NEXT_CHAR;


	/*
	 *   what is it?
	 */
	switch (c)
	{
	case 'Z':			/* terminal ID */
		/* this is obsolete. use ESC [ c */
		return;
		break;	/*NOTREACHED*/

	case 'c':			/* reset to initial state */
		vt100_reset ();
		return;
		break;	/*NOTREACHED*/

	case 'H':			/* set tab at current position */
		return;
		break;	/*NOTREACHED*/

	case 'D':			/* index */
		Bconout (CON, (int) 27);
		Bconout (CON, (int) 'B');
		return;
		break;	/*NOTREACHED*/

	case 'M':			/* scroll reverse one line */
		Bconout (CON, (int) 27);
		Bconout (CON, (int) 'I');
		return;
		break;	/*NOTREACHED*/

	case 'E':			/* next line */
		Bconout (CON, (int) 13);
		Bconout (CON, (int) 27);
		Bconout (CON, (int) 'B');
		return;
		break;	/*NOTREACHED*/

	case '>':			/* reset keypad (normal) */
		keypad = 0;
		return;
		break;	/*NOTREACHED*/

	case '=':			/* set keypad (application) */
		keypad = 1;
		return;
		break;	/*NOTREACHED*/

	case '8':			/* restore cursor to saved loc */
		Bconout (CON, (int) 27);
		Bconout (CON, (int) 'k');
		return;
		break;	/*NOTREACHED*/

	case '7':			/* save cursor location */
		Bconout (CON, (int) 27);
		Bconout (CON, (int) 'j');
		return;
		break;	/*NOTREACHED*/

	case '[':
		/*
		 *   get next one...
		 */
		GET_NEXT_CHAR;

		if (c == '?')
		{
			/*
			 *   next char SHOULD be a number...
			 */
			GET_NEXT_CHAR;

			if ((c >= '0') && (c <= '9'))
			{
				/*
				 *   get all of number. store as int val1.
				 */
				val1 = 0;
				do
				{
					val1 = (10 * val1) + (c - '0');

					GET_NEXT_CHAR;
	
				} while ((c >= '0') && (c <= '9'));


				/*
				 *   what was last char? (one causing do/while
				 *   to stop)
				 */
				if (c == 'l')
				{
					switch (val1)
					{
					case 1:		/* reset cursor key */
						curskey = 0;
						return;
						break;	/*NOTREACHED*/

					case 2:		/* change mode */
						/*
						 *   this may not be portable
						 */
						return;
						break;	/*NOTREACHED*/

					case 3:		/* reset col width */
						colwidth = 0;
						return;
						break;	/*NOTREACHED*/

					case 4:		/* reset smooth scroll*/
						smooth = 0;
						return;
						break;	/*NOTREACHED*/

					case 5:		/* reset screen mode */
						/*
						 *   normal video. bg is color
						 *   0. fg depends on rez.
						 *   black is low intens (0),
						 *   white is high (777).
						 */
						switch (Getrez ())
						{
						case 0:
							Setcolor (0,  0x777);
							Setcolor (15, 0);
							break;
						case 1:
							Setcolor (0, 0x777);
							Setcolor (3, 0);
							break;
						case 2:
							Setcolor (0, 0x777);
							Setcolor (1, 0);
							break;
						}
						video = 0;
						return;	/*NOTREACHED*/
						break;

					case 6:		/* reset origin mode */
						origmode = 0;
						return;
						break;	/*NOTREACHED*/

					case 7:		/* reset wrap */
						Bconout (CON, (int) 27);
						Bconout (CON, (int) 'w');
						wrap = 0;
						return;
						break;	/*NOTREACHED*/

					case 8:		/* reset auto repeat*/
						Kbrate (0, 0);
						repeat = 0;
						return;
						break;	/*NOTREACHED*/

					default:
						/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC ? xxx l code\r\n\n");
goto error_in_code;
#endif
						break;
					}
				}
				else if (c == 'h')
				{
					switch (val1)
					{
					case 1:		/* set cursor key */
						curskey = 1;
						return;
						break;	/*NOTREACHED*/

					case 3:		/* set col width */
						colwidth = 1;
						return;
						break;	/*NOTREACHED*/

					case 4:		/* set smooth scroll*/
						smooth = 1;
						return;
						break;	/*NOTREACHED*/

					case 5:		/* set screen mode */
						/*
						 *   reverse video. bg is color
						 *   0. fg depends on rez.
						 *   black is low intens (0),
						 *   white is high (777).
						 */
						switch (Getrez ())
						{
						case 0:
							Setcolor (0, 0);
							Setcolor (15, 0x777);
							break;
						case 1:
							Setcolor (0, 0);
							Setcolor (3, 0x777);
							break;
						case 2:
							Setcolor (0, 0);
							Setcolor (1, 0x777);
							break;
						}
						video = 1;
						return;
						break;	/*NOTREACHED*/

					case 6:		/* set origin mode */
						origmode = 1;
						return;
						break;	/*NOTREACHED*/

					case 7:		/* set wrap */
						Bconout (CON, (int) 27);
						Bconout (CON, (int) 'v');
						wrap = 1;
						return;
						break;	/*NOTREACHED*/

					case 8:		/* set auto repeat*/
						Kbrate (50, 2);
						repeat = 1;
						return;
						break;	/*NOTREACHED*/

					default:	/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC ? xxx h code\r\n\n");
goto error_in_code;
#endif
						break;
					}
				}
				else if (c == 'i')
				{
					switch (val1)
					{
					case 1:		/* print line */
						return;
						break;	/*NOTREACHED*/

					default:	/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC ? xxx i code\r\n\n");
goto error_in_code;
#endif
						break;
					}
				}
				else
				{
					/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC ? code (unknown param)\r\n\n");
goto error_in_code;
#endif
				}
			}
			else
			{
				/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC ? code (no param)\r\n\n");
goto error_in_code;
#endif
			}

			return;
		}
		else if ((c >= '0') && (c <= '9'))
		{
			/*
			 *   read all of number. could be 1,2, or 3 digits.
			 */
			val1 = 0;
			do
			{
				val1 = (10 * val1) + (c - '0');

				GET_NEXT_CHAR;

			} while ((c >= '0') && (c <= '9'));
		}
		else
			val1 = VAL_DEFAULT;

		/*
		 *   this char should not be a number...
		 */
		if (c == ';')
		{
			GET_NEXT_CHAR;

			if ((c >= '0') && (c <= '9'))
			{
				val2 = 0;
				do
				{
					val2 = (10 * val2) + (c - '0');

					GET_NEXT_CHAR;

				} while ((c >= '0') && (c <= '9'));
			}
			else
				val2 = VAL_DEFAULT;


			/*
			 *   ok. we have a 2 parameter command. there are
			 *   not too many of these...
			 */
			switch (c)
			{
			case 'H':		/* absolute cursor position */
			case 'f':
				if (val1 == 0)
					val1 = 1;
				if (val2 == 0)
					val2 = 1;
				row = val1 - 1 + ' ';
				col = val2 - 1 + ' ';
				Bconout (CON, (int) 27);
				Bconout (CON, (int) 'Y');
				Bconout (CON, (int) row);
				Bconout (CON, (int) col);
				return;
				break;	/*NOTREACHED*/

			case 'r':		/* set scroll region */
				return;
				break;	/*NOTREACHED*/

			case 'R':		/* cursor position report */
				return;
				break;	/*NOTREACHED*/

			case 'y':		/* initiate self test, reset*/
				if ((val1 != 2) && (val2 != 1))
				{
					/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC [ xxx ; yyy y code\r\n\n");
goto error_in_code;
#endif
				}
				vt100_reset ();
				return;
				break;	/*NOTREACHED*/

			default:		/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC [ xxx ; yyy * code (unknown cmd)\r\n\n");
goto error_in_code;
#endif
				break;
			}

			return;
		}

		/*
		 *   single parameter command.
		 */
		switch (c)
		{
		case 'A':			/* cursor up */
			if (val1 == 0)
				val1 = 1;
			for ( ; val1; val1--)
			{
				Bconout (CON, (int) 27);
				Bconout (CON, (int) c);
			}
			return;
			break;	/*NOTREACHED*/

		case 'B':			/* cursor down */
			if (val1 == 0)
				val1 = 1;
			for ( ; val1; val1--)
			{
				Bconout (CON, (int) 27);
				Bconout (CON, (int) c);
			}
			return;
			break;	/*NOTREACHED*/

		case 'C':			/* cursor right */
			if (val1 == 0)
				val1 = 1;
			for ( ; val1; val1--)
			{
				Bconout (CON, (int) 27);
				Bconout (CON, (int) c);
			}
			return;
			break;	/*NOTREACHED*/

		case 'D':			/* cursor left */
			if (val1 == 0)
				val1 = 1;
			for ( ; val1; val1--)
			{
				Bconout (CON, (int) 27);
				Bconout (CON, (int) c);
			}
			return;
			break;	/*NOTREACHED*/

		case 'H':			/* home (special case) */
		case 'f':
			Bconout (CON, (int) 27);
			Bconout (CON, (int) c);
			return;
			break;	/*NOTREACHED*/

		case 'J':			/* erase in display */
			if (val1 == 0)
			{
				/* from cursor to end of page */
				Bconout (CON, (int) 27);
				Bconout (CON, (int) 'J');
			}
			else if (val1 == 1)
			{
				/* from cursor to begin of page */
				Bconout (CON, (int) 27);
				Bconout (CON, (int) 'd');
			}
			else if (val1 == 2)
			{
				/* clear entire screen */
				Bconout (CON, (int) 27);
				Bconout (CON, (int) 'E');
			}
			else
			{
				/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC [ xxx J code\r\n\n");
goto error_in_code;
#endif
			}
			return;
			break;	/*NOTREACHED*/

		case 'K':			/* erase in line */
			if (val1 == 0)
			{
				/* from cursor to end of line */
				Bconout (CON, (int) 27);
				Bconout (CON, (int) 'K');
			}
			else if (val1 == 1)
			{
				/* from cursor to begin of line */
				Bconout (CON, (int) 27);
				Bconout (CON, (int) 'o');
			}
			else if (val1 == 2)
			{
				/* clear entire line */
				Bconout (CON, (int) 27);
				Bconout (CON, (int) 'l');
			}
			else
			{
				/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC [ xxx K code\r\n\n");
goto error_in_code;
#endif
			}
			return;
			break;	/*NOTREACHED*/

		case 'L':			/* insert line */
			if (val1 == 0)
				val1 = 1;
			for ( ; val1; val1--)
			{
				Bconout (CON, (int) 27);
				Bconout (CON, (int) c);
			}
			return;
			break;	/*NOTREACHED*/

		case 'M':			/* delete line */
			if (val1 == 0)
				val1 = 1;
			for ( ; val1; val1--)
			{
				Bconout (CON, (int) 27);
				Bconout (CON, (int) c);
			}
			return;
			break;	/*NOTREACHED*/

		case 'P':			/* delete char */
			return;
			break;	/*NOTREACHED*/

		case 'c':			/* device attributes */
			return;
			break;	/*NOTREACHED*/

		case 'g':			/* clear tabs */
			return;
			break;	/*NOTREACHED*/

		case 'i':
			if (val1 == 7)		/* enable ext port */
			{
			}
			else if (val1 == 6)	/* disable ext port */
			{
			}
			else if (val1 == 0)	/* print screen */
			{
			}
			else if (val1 == 4)	/* reset transp print mode */
			{
			}
			else if (val1 == 5)	/* set transp print mode */
			{
			}
			return;
			break;	/*NOTREACHED*/

		case 'h':
			if (val1 == 4)		/* set insert mode */
			{
			}
			else if (val1 == 2)	/* set keybd action mode */
			{
			}
			else if (val1 == 20)	/* set newline mode */
			{
			}
			else
			{
				/* ERROR... */
			}
			return;
			break;	/*NOTREACHED*/

		case 'l':
			if (val1 == 4)		/* reset insert mode */
			{
			}
			else if (val1 == 2)	/* reset keybd action mode */
			{
			}
			else if (val1 == 20)	/* reset newline mode */
			{
			}
			else
			{
				/* ERROR... */
			}
			return;
			break;	/*NOTREACHED*/

		case 'm':			/* select graphics mode */
			if (val1 == 0)
			{
				blinking  = 0;
				bold      = 0;
				reverse   = 0;
				underline = 0;
#ifdef USE_FONTS
				fnt_roman ();
#else
				Bconout (CON, (int) 27);
				Bconout (CON, (int) 'q');
#endif

				return;
			}
			else
			{
				blinking  = 0;
				bold      = 0;
				reverse   = 0;
				underline = 0;

				switch (val1)
				{
				case 1:
					bold = 1;
#ifdef USE_FONTS
					fnt_bold ();
#else
					Bconout (CON, (int) 27);
					Bconout (CON, (int) 'p');
#endif
					return;
					break;	/*NOTREACHED*/

				case 4:
					underline = 1;
#ifdef USE_FONTS
					fnt_uline ();
#else
					Bconout (CON, (int) 27);
					Bconout (CON, (int) 'p');
#endif
					return;
					break;	/*NOTREACHED*/

				case 5:
					blinking = 1;
					return;
					break;	/*NOTREACHED*/

				case 7:
					reverse = 1;
#ifdef USE_FONTS
					fnt_reverse ();
#else
					Bconout (CON, (int) 27);
					Bconout (CON, (int) 'p');
#endif
					return;
					break;	/*NOTREACHED*/

				default:	/* ERROR... */
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC [ xxx m code (unknown param)\r\n\n");
goto error_in_code;
#endif
					break;
				}
			}
			return;
			break;	/*NOTREACHED*/

		case 'n':			/* status report/req */
			return;
			break;	/*NOTREACHED*/

		case 'x':			/* req term params */
			return;
			break;	/*NOTREACHED*/

		case '@':			/* insert char */
			return;
			break;	/*NOTREACHED*/
		}

		return;
		break;	/*NOTREACHED*/


	default:				/* ERROR or unrecognized... */
/*		Bconout (CON, (int) c);*/
#ifdef DEBUG
Cconws ("\r\n\nvt100: error in ESC code (unknown cmd)\r\n\n");
goto error_in_code;
#endif
		goto error_in_code;
		break;

	} /* end main switch */




	/*
	 *   phew...THAT was fun...
	 */
	return;




no_char_avail: ;

	Cconws ("\r\n\nvt100: error, no_char_avail from AUX\r\n\n");

	return;



error_in_code: ;

	return;
}





/*------------------------------*/
/*	vt100_reset		*/
/*------------------------------*/
void vt100_reset ()
{

#ifdef USE_FONTS
	fnt_roman ();			/* normal ESC [ 0 m */
#endif
	blinking  = 0;
	bold      = 0;
	reverse   = 0;
	underline = 0;

	repeat = 1;
	Kbrate (50, 2);			/* repeat ESC [ ? 8 h */

	wrap = 1;
	Bconout (CON, (int) 27);	/* wrap ESC [ ? 7 h */
	Bconout (CON, (int) 'v');

	video = 0;
	switch (Getrez ())		/* normal ESC [ ? 5 l */
	{
	case 0:
		Setcolor (0,  0x777);
		Setcolor (15, 0);
		break;
	case 1:
		Setcolor (0, 0x777);
		Setcolor (3, 0);
		break;
	case 2:
		Setcolor (0, 0x777);
		Setcolor (1, 0);
		break;
	}

	curskey = 0;

	keypad = 0;

	colwidth = 0;

	smooth = 0;

	origmode = 0;

	return;
}

