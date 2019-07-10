static char *sccsid = "@(#) putline.c 1.3 91/1/25 rosenkra\0         ";

/*
 *	putline.c - output a line of text with font changes keyed by
 *	            escape sequences imbedded in the text. works a char
 *	            at a time, parsing as it goes. uses BIOS to output chars
 *	            (c_print).
 */
#include <stdio.h>

/*
 *	some std char defs
 */
#define ESC		(char)0x1b
#define SP		0x20
#define TAB		0x09
#define CR		0x0d
#define LF		0x0a
#define CARET		0x5e
#define LBRACKET	0x5b
#define SPACE		0x20
#define TILDE		0x7e
#define BSLASH		0x5c


/*
 *	mode we were in when we last left. we always reset to normal before
 *	we leave, then set back on entry to last font (note that "normal"
 *	is NOT roman; there is a seperate font for MODE0).
 */
#define MODE9		9		/* alt set */
#define MODE8		8		/* small */
#define MODE7		7		/* standout */
#define MODE4		4		/* underline (italic) */
#define MODE1		1		/* bold */
#define MODE0		0		/* roman */


/*------------------------------*/
/*	putline			*/
/*------------------------------*/
int putline (s, stream)
char   *s;				/* string with newline */
FILE   *stream;				/* stream to write to */
{

/*
 *	output a line, changing fonts if necessary. ANSI escape sequences
 *	cause the changes as follows:
 *
 *		\E[9m		begin using alternate char set
 *		\E[8m		begin using small char set
 *		\E[7m		enter standout mode (reverse video)
 *		\E[4m		enter undeline mode
 *		\E[1m		enter bold mode
 *		\E[m or \E[0m	cancel all modes (normal)
 *
 *	all these modes fiddle with system fonts.
 *
 *	the effect of modes is not cummulative. you cannot have 2 modes "on"
 *	at the same time. each escape loads a new font. there are no bold
 *	underline fonts, for example.
 *
 *	returns actual number of chars put to output.
 */

	extern int	sysfont;
	extern int	otty;
#ifdef USE_FUNNY_FONT
	extern int	funfont;
#endif

	static int	lastmode = MODE0;	/* starts with normal */

	register char  *ps;
	int		ret = 0;



	/*
	 *   check for valid string. return now if not...
	 */
	if (s == (char *) NULL)
		return (0);


	/*
	 *   reset mode...
	 */
	if (!sysfont)
	{
#ifdef USE_FUNNY_FONT
		if (!funfont)
		{
			switch (lastmode)
			{
			case MODE0:	fnt_roman ();		break;
			case MODE1:	fnt_bold ();		break;
			case MODE4:	fnt_uline ();		break;
			case MODE7:	fnt_standout ();	break;
			case MODE8:	fnt_small ();		break;
			case MODE9:	fnt_special ();		break;
			}
		}
		else
		{
			switch (lastmode)
			{
			case MODE0:	fnt_fun ();		break;
			case MODE1:	fnt_bfun ();		break;
			case MODE4:	fnt_bfun ();		break;
			case MODE7:	fnt_bfun ();		break;
			case MODE8:	fnt_small ();		break;
			case MODE9:	fnt_special ();		break;
			}
		}
#else
		switch (lastmode)
		{
		case MODE0:	fnt_roman ();		break;
		case MODE1:	fnt_bold ();		break;
		case MODE4:	fnt_uline ();		break;
		case MODE7:	fnt_standout ();	break;
		case MODE8:	fnt_small ();		break;
		case MODE9:	fnt_special ();		break;
		}
#endif
	}


	/*
	 *   initialize things...
	 */
	ret = 0;
	ps  = s;


	/*
	 *   for some reason, things are hosed if first char on line is a
	 *   tab. do 8 spaces instead...
	 */
	if (*ps == TAB)
	{
		c_print ((int) SP);
		c_print ((int) SP);
		c_print ((int) SP);
		c_print ((int) SP);
		c_print ((int) SP);
		c_print ((int) SP);
		c_print ((int) SP);
		c_print ((int) SP);
		ps++;
	}


	/*
	 *   for all chars on line...
	 */
	for ( ; *ps; ps++)
	{
		/*
		 *   look for escape sequence. it will start "\E[...". if
		 *   there is one, parse it, set the proper font, and skip
		 *   past it. otherwise, just output the character. if using
		 *   system font (sysfont != 0), we do something else below.
		 */
		if ((*ps == ESC) && !sysfont)
		{
			/*
			 *   is it a valid escape? hard to tell, but if not
			 *   at least \E[, the just print it (sans the ESC).
			 */
			if (*++ps != '[')
			{
				if (otty)
				{
					c_print ((int) BSLASH);
					ret++;
					c_print ((int) *ps);
					if (*ps == LF)
						c_print ((int) CR);
				}
				else
				{
					fputc ((char) BSLASH, stream);
					ret++;
					fputc (*ps, stream);
				}
				if (*ps != LF)
					ret++;

				continue;
			}

			/*
			 *   ok, we assume it is valid. what sort of escape is
			 *   it?
			 */
			switch (*++ps)
			{
			case '9':		/* alt char set */
				ps++;
				if (!sysfont)
					fnt_special ();
				lastmode = MODE9;
				break;

			case '8':		/* small char set */
				ps++;
				if (!sysfont)
					fnt_small ();
				lastmode = MODE8;
				break;

			case '7':		/* standout (rev video) */
				ps++;
				if (!sysfont)
				{
#ifdef USE_FUNNY_FONT
					if (funfont)
						fnt_bfun ();
					else
						fnt_standout ();
#else
					fnt_standout ();
#endif
				}
				lastmode = MODE7;
				break;

			case '4':		/* underline */
				ps++;
				if (!sysfont)
				{
#ifdef USE_FUNNY_FONT
					if (funfont)
						fnt_bfun ();
					else
						fnt_uline ();
#else
					fnt_uline ();
#endif
				}
				lastmode = MODE4;
				break;

			case '1':		/* bold */
				ps++;
				if (!sysfont)
				{
#ifdef USE_FUNNY_FONT
					if (funfont)
						fnt_bfun ();
					else
						fnt_bold ();
#else
					fnt_bold ();
#endif
				}
				lastmode = MODE1;
				break;

			case '0':		/* normal */
				ps++;		/* FALL THRU */
			case 'm':
				if (!sysfont)
				{
#ifdef USE_FUNNY_FONT
					if (funfont)
						fnt_fun ();
					else
						fnt_roman ();
#else
					fnt_roman ();
#endif
				}
				lastmode = MODE0;
				break;
			default:		/* unknown */
				if (otty)
				{
					c_print ((int) CARET);
					c_print ((int) LBRACKET);
					c_print ((int) *ps);
					if (*ps == LF)
						c_print ((int) CR);
				}
				else
				{
					fputc ((char) CARET, stream);
					fputc ((char) LBRACKET, stream);
					fputc (*ps, stream);
				}
				break;
			}
		}
		else if (sysfont && ((*ps < SPACE) || (*ps > TILDE)))
		{
			char	oct[5];

			if (otty)
			{
				if (*ps == LF)
				{
					c_print ((int) *ps);
					c_print ((int) CR);
				}
				else
				{
					c_print ((int) BSLASH);
					sprintf (oct, "%03o\0", (unsigned int) *ps);
					c_print ((int) oct[0]);
					c_print ((int) oct[1]);
					c_print ((int) oct[2]);
					ret += 4;
				}
			}
			else
			{
				if (*ps == LF)
				{
					fputc (*ps, stream);
				}
				else
				{
					fprintf (stream, "\\%03o\0", (unsigned int) *ps);
					ret += 4;
				}
			}
		}
		else
		{
			/*
			 *   not escape, so just output it...
			 */
			if (otty)
			{
				/*
				 *   use bios
				 */
				c_print ((int) *ps);
				if (*ps == LF)
					c_print ((int) CR);
			}
			else
			{
				/*
				 *   use stdio
				 */
				fputc (*ps, stream);
			}
			if (*ps != LF)
				ret++;
		}
	}

#if 0
	/* GEMLIB is really hosed. this seemingly innocent command causes
	   the function to break with fputc (stdio). */
	fflush (stream);
#endif


	/*
	 *   reset to normal mode before we return. here "normal" is the
	 *   orig screen font. lastmode keeps track of what the last mode
	 *   wuz, so that multi-line escaped sections will work correctly.
	 */
	if (!sysfont)
		fnt_normal ();


	/*
	 *   return actual number of chars written to screen
	 */
	return (ret);
}
	
