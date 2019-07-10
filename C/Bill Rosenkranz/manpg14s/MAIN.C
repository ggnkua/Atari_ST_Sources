/*
 *	manpager - a pager for man which changes fonts
 *
 *	reads a file all at once, not on the fly like less. it is somewhat
 *	slower than less, not much. it can also be used like cat to copy the
 *      file, stripping out all escape sequences which would normally cause
 *	font changes. stdout must be redirected, however, for that to occur.
 *
 *	reads only a single file at this point, which is good enuf for man.
 *
 *	history:
 *
 *	1.0 91/1/14 rosenkra	pre-release, first version
 *
 *	1.1 91/1/15 rosenkra	posted version, more or less working
 *
 *	1.2 91/1/23 rosenkra	changed to MGR fonts (nserif8x16). fixed
 *				fwd_line bug. add -s (system font) for normal
 *				less-like operation. print funky chars with
 *				octal \xxx if non-printable (-s only).
 */

#include <stdio.h>
#include <zlib.h>
#include <ctype.h>
#include <osbind.h>

static char *sccsid  = "@(#) main.c 1.4 91/1/27 rosenkra\0\0\0           ";
static char *version = "manpager 1.4 91/1/27 rosenkra\0\0\0              ";
static char *myname  = "manpager\0\0\0\0";

#ifndef lastchar
#define lastchar(s)	((s)[strlen(s)-1])	/* last char in a string */
#define plastchar(s)	&((s)[strlen(s)-1])	/* ptr to it */
#endif

#define PADTIME		20		/* padding time in ms */
#define PADNUM		1		/* number of pads */

#define ESC		0x1B		/* some chars we need... */
#define LF		0x0A
#define CR		0x0D
#define BS		0x08
#define DEL		0x7F
#define COLON		0x3A
#define SLASH		0x2F
#define QMARK		0x3F
#define SPACE		0x20
#define BEL		0x07

#define COMPMAG		"\37\235"	/* 0x1f9d is compress magic */


/*
 *	line structure. this forms a doubly linked list. i_prev for first
 *	is NULL; i_next for last is NULL.
 *
 *		first     second    third             last
 *	      (plfirst)                         (pllast, anchor)
 *	         ____      ____      ____             ____     
 *	NULL<---|prev|<---|prev|<---|prev|<---...<---|prev|
 *	        |    |    |    |    |    |           |    |
 *	        |next|--->|next|--->|next|--->...--->|next|--->NULL
 *	        |____|    |____|    |____|           |____|    
 *	          |         |         |                |
 *	        __v___    __v___    __v___             v
 *	       |line 1|  |line 2|  |line 3|           NULL
 *	       |______|  |______|  |______|
 *	            actual text buffers
 */
struct iline
{
	struct iline   *i_next;		/* ptr to next line */
	struct iline   *i_prev;		/* ptr to previous line */
	char	       *i_line;		/* actual line */
	long		i_cumlen;	/* cummulative length */
	int		i_linum;	/* line number, starts with 1 */
	int		i_len;		/* length of line */
};



/*
 *	globals
 */
long		_STKSIZ = 350000L;/* sufficient for most "reasonable" docs */

struct iline	list;		/* first line (anchor of list) */
struct iline   *plfirst;	/* ptr to first line (constant) */
struct iline   *pllast;		/* ptr to last line (constant after read) */
struct iline   *plcur;		/* ptr to current line (variable) */
long		totlen;		/* chars in file (includes LF and CR) */
int		totlines;	/* lines in file */
char	       *curfname;	/* name of current file */
FILE	       *curfile;	/* handle of current file */
ZFILE	       *curzfile;	/* handle of current file (compressed) */
int		scrlines;	/* num of lines on screen, account for wrap */
int		otty;		/* is stdout a tty? */
int		debugging = 0;	/* debug mode */
int		sysfont = 0;	/* force system font (no font changes) */
int		decomp = 0;	/* use zlib(3x) to read compressed file */
#ifdef USE_FUNNY_FONT
int		funfont = 0;	/* use fun font :-) */
#endif


/*
 *	functions
 */
extern char    *malloc ();
extern char    *stolower ();

int		usage ();
int		quit ();
int		init ();
int		cat ();
int		command ();
int		prompt ();
int		cprompt ();
int		fwd_line ();
int		bkwd_line ();
int		fwd_full ();
int		cursor ();
int		insert ();
int		home ();
int		wrap ();
int		rvideo ();
int		mv_cursor ();
int		clr_screen ();
int		c_print ();
int		s_print ();
int		bell ();
int		bells ();
int		getcmd ();
int		gotoline ();
int		isatty ();
int		search ();
int		status_msg ();
int		clr_status ();
int		pad ();
int		wait_ms ();
int		show_fname ();
int		show_version ();
int		help ();
int		clr_char ();
int		cerase ();



/*------------------------------*/
/*	main			*/
/*------------------------------*/
main (argc, argv)
int	argc;
char   *argv[];
{
	FILE   *infile;
	ZFILE  *zinfile;
	char	lbuf[1024];
	int	linelen;
	char	fnbuf[256];
	int	no_z_suffix = 0;


	/*
	 *   we use this later, but do it now...
	 */
	otty = isatty (1);


	/*
	 *   check command line
	 */
	argc--, argv++;
	while (argc && **argv == '-')
	{
		switch (*(*argv+1))
		{
#ifdef USE_FUNNY_FONT
		case 'f':		/* funny font only */
			if (!strncmp (*argv, "-fun", 4))
				funfont = 1;
			break;
#endif
		case 's':		/* system font only */
			sysfont = 1;
			break;

		case 'z':		/* decompress file */
			decomp = 1;
			break;

		case 'h':		/* help */
			usage (0);
			break;

		case 'v':		/* version */
			printf ("%s\n", version);
			exit (0);
			break;

		case 'd':		/* debug */
			debugging++;
			break;

		default:
			fprintf (stderr, "%s: unknown switch %s\n",
				myname, *argv);
			usage (1);
			break;
		}
		argc--, argv++;
	}


	/*
	 *   we MUST have a file name...
	 */
	if (argc < 1)
	{
		fprintf (stderr, "%s: a file name is required\n", myname);
		usage (1);
	}


	/*
	 *   check for bad args...
	 */
#ifdef USE_FUNNY_FONT
	if (funfont && sysfont)
	{
		fprintf (stderr, "%s: -fun and -s are mutually exclusive\n",
				myname);
		usage (1);
	}
#endif


	/*
	 *   open input file
	 */
openfile:
	if (decomp)
	{
		/*
		 *   either -z (for compressed files) or file not found
		 *   (assumed compressed file)
		 */
		char   *pdot;

		/*
		 *   try file as is (it may not be compressed, but zlib
		 *   handles this case anyway)...
		 */
		strcpy (fnbuf, *argv);
		if ((zinfile = zfopen (fnbuf, "r")) == (ZFILE *) NULL)
		{
			/*
			 *   try adding "Z" suffix, a la ST compress 4.3:
			 *
			 *	compress file		-> file.z
			 *	compress file.		-> file.z
			 *	compress file.e		-> file.ez
			 *	compress file.ee	-> file.eez
			 *	compress file.eee	-> file.eez
			 */
			pdot = plastchar(fnbuf);
			if (pdot[0] == '.')		strcat (fnbuf, "z");
			else if (pdot[-1] == '.')	strcat (fnbuf, "z");
			else if (pdot[-2] == '.')	strcat (fnbuf, "z");
			else if (pdot[-3] == '.')	*pdot = 'z';
			else				strcat (fnbuf, ".z");

			fprintf (stderr,
				"%s: could not open %s (compressed), try %s...\n",
				myname, *argv, fnbuf);
			if ((zinfile = zfopen (fnbuf, "r")) == (ZFILE *) NULL)
			{
				fprintf (stderr,
					"%s: could not open %s either. sorry...\n",
					myname, fnbuf);
				exit (1);
			}
		}
		curfname = fnbuf;
		curzfile = zinfile;
	}
	else
	{
		/*
		 *   no -z (normal file)
		 */
		char	cmag[5];

		/*
		 *   try it as is...
		 */
		if ((infile = fopen (*argv, "r")) == (FILE *) NULL)
		{
#if 0
			fprintf (stderr, "%s: could not open %s.\n",
				myname, *argv);
			exit (1);
#else
			/*
			 *   if not, assume it was compressed and retry,
			 *   setting -z
			 */
			fprintf (stderr,
			  "%s: could not open %s. try compressed version...\n",
			  myname, *argv);
			decomp      = 1;
			no_z_suffix = 1;	/* flag it is compr, but no .z*/
			goto openfile;
#endif
		}

		/*
		 *   check if compressed anyway...
		 */
		cmag[0] = (char) fgetc (infile);
		cmag[1] = (char) fgetc (infile);
		if (!strncmp (cmag, COMPMAG, 2))
		{
			if (otty)
				fprintf (stderr,
					"Warning: file %s seems to be compressed! Reopening...\n",
					*argv);
			fclose (infile);
			decomp = 1;
			goto openfile;
		}
		rewind (infile);
		curfname = *argv;
		curfile  = infile;
	}


	/*
	 *   set pointers
	 */
	plfirst = &list;
	pllast  = &list;
	plcur   = &list;


	/*
	 *   initialize list
	 */
	list.i_next = (struct iline *) NULL;
	list.i_prev = (struct iline *) NULL;
	totlen      = 0L;
	totlines    = 0;


	/*
	 *   read the file. each line read is allocated a buf for i_line.
	 *   at the bottom of the loop, we allocate a new plcur struct
	 *   and reset pointers. on feof, we are left with a "tail anchor"
	 *   with no allocated string which should point forward (i_next)
	 *   to NULL and backward to the last line (the one we just read).
	 *
	 *   note: plcur should NEVER end up at the tail anchor. it should
	 *   go only as far as the tail's i_prev.
	 */
	if (otty)
		printf ("Reading file...\n");
	while (1)
	{
		/*
		 *   read a line
		 */
		if (decomp)
		{
			zfgets (lbuf, 1023, zinfile);
			if (zfeof (zinfile))
			{
				zfclose (zinfile);
				break;
			}
		}
		else
		{
			fgets (lbuf, 1023, infile);
			if (feof (infile))
			{
				fclose (infile);
				break;
			}
		}


		/*
		 *   set line len, number (starts at 1) and totlines
		 */
		totlines++;
		linelen        = strlen (lbuf) + 1;	/* account for CR */
		plcur->i_len   = linelen;
		plcur->i_linum = totlines;


		/*
		 *   allocate space for it in list
		 */
		plcur->i_line  = (char *) malloc (linelen + 2);
		if (plcur->i_line == (char *) NULL)
		{
			fprintf (stderr, "%s: char malloc (i_line) failed\n",
				myname);
			exit (1);
		}


		/*
		 *   copy line to buffer
		 */
		strcpy (plcur->i_line, lbuf);


		/*
		 *   accumulate length, in bytes. i_cumlen is total bytes,
		 *   including this one
		 */
		totlen += linelen;
		if (plcur->i_prev)
			plcur->i_cumlen = (plcur->i_prev)->i_cumlen + linelen;
		else
			plcur->i_cumlen = linelen;


		/*
		 *   allocate next line...
		 */
		plcur = (struct iline *) malloc (sizeof (struct iline));
		if (plcur == (struct iline *) NULL)
		{
			fprintf (stderr, "%s: struct malloc (iline) failed\n",
				myname);
			exit (1);
		}

		/*
		 *   reset pointers:
		 *
		 *	1) set next in prev line
		 *	2) set prev in this line
		 *	3) terminate this line (next is NULL)
		 *	4) set new ptr to last line
		 */
		pllast->i_next = plcur;
		plcur->i_prev  = pllast;
		plcur->i_next  = (struct iline *) NULL;
		pllast         = plcur;
	}


	/*
	 *   set current line to the first
	 */
	plcur = plfirst;




	/*
	 *   cat file only
	 */
	if (!otty)
		cat ();


	/*
	 *   other initializations...
	 */
	init ();


	/*
	 *   draw screen. plcur always points to top line displayed...
	 */
	home ();
	fwd_full ();


	/*
	 *   do commands...
	 */
	command ();

				/*NOT REACHED*/
}




/*------------------------------*/
/*	usage			*/
/*------------------------------*/
usage (excode)
int	excode;
{
#ifdef USE_FUNNY_FONT
	fprintf (stderr, "usage: %s [-s | -fun] [-z] file\n", myname);
#else
	fprintf (stderr, "usage: %s [-s] [-z] file\n", myname);
#endif
	exit (excode);
}




/*------------------------------*/
/*	quit			*/
/*------------------------------*/
quit ()
{

/*
 *	do what we have to before we exit (also done here)
 */

	cursor (1);
	exit (0);
}




/*------------------------------*/
/*	init			*/
/*------------------------------*/
init ()
{

/*
 *	anything needing initialization
 */

	scrlines = 24;
	cursor (0);
	wrap (1);
}




/*------------------------------*/
/*	cat			*/
/*------------------------------*/
cat ()
{

/*
 *	cat file only
 */

	for ( ; plcur->i_next; plcur = plcur->i_next)
	{
#ifdef DEBUGGING
		if (plcur->i_line)
		{
			printf ("%6d %6d %6ld",
				plcur->i_linum, plcur->i_len, plcur->i_cumlen);
			putline (plcur->i_line, stdout);
		}
		else
			printf ("no line allocated\n");
#else
		if (plcur->i_line)
		{
			putline (plcur->i_line, stdout);
		}
#endif
	}
#ifdef DEBUGGING
	printf ("totlines = %d, totlen = %ld\n", totlines, totlen);
#endif
	exit (0);
}




/*------------------------------*/
/*	command			*/
/*------------------------------*/
command ()
{

/*
 *	interactive command processor. handles movement within the file,
 *	basically.
 */

	int	done = 0;
	char	cmd;			/* input char */
	int	ncmd;			/* result of numeric input */
	int	srchdir = 1;		/* 1=forward, 0=backward */
	char	srchstr[100];		/* last search string */
	char   *ps;


	/*
	 *   loop until "quit" entered...
	 */
	while (!done)
	{
		/*
		 *   initialize loop. default for everything is do it once so
		 *   ncmd is set to 1
		 */
		scrlines = 24;
		prompt ();
		ncmd = 1;


		/*
		 *   get a command char
		 */
		cmd  = (char) getcmd ();


		/*
		 *   all commands are non-digits. if it is a digit, it is
		 *   specifying a number to override the default (e.g. 5g
		 *   goes to line 5 rather than 1). the special commands
		 *   / and ? are also handled here...
		 */
		if (isdigit (cmd))
		{
			int	nch;
			
			/*
			 *   we can allow for backspacing by keeping track
			 *   of the number of chars read (only for mv_cursor)
			 */
			nch = 1;


			/*
			 *   do a colon prompt and echo the first number
			 */
			cprompt ((int) COLON);
			c_print ((int) cmd);


			/*
			 *   loop until a command. set number read to first
			 *   digit
			 */
			for (ncmd = (int) cmd - '0'; ; )
			{
				/*
				 *   get next char
				 */
				cmd = (char) getcmd ();

				/*
				 *   if backspace, undo last digit
				 */
				if ((cmd == BS) || (cmd == DEL))
				{
					if (nch >= 1)
					{
						ncmd /= 10;
						cerase ();
						nch--;
					}
					if (nch == 0)
					{
						nch  = 1;
					}
				}
				else if (!isdigit (cmd))
				{
					/*
					 *   no more digits, it must be command
					 */
					break;
				}
				else
				{
					/*
					 *   it is a number, so update ncmd
					 *   and echo it
					 */
					nch++;
					c_print ((int) cmd);
					ncmd = (10 * ncmd) + ((int) cmd - '0');
				}
			}
		}
		else if ((cmd == SLASH) || (cmd == QMARK))
		{
			/*
			 *   search
			 */
			int	nch;
			

			/*
			 *   we can allow for backspacing by keeping track
			 *   of the number of chars read (only for mv_cursor)
			 */
			nch = 0;


			/*
			 *   echo the command as a prompt
			 */
			cprompt ((int) cmd);


			/*
			 *   set search direction
			 */
			if (cmd == SLASH)
				srchdir = 1;		/* forward */
			else
				srchdir = 0;


			/*
			 *   get the string
			 */
			for (ps = srchstr; ; )
			{
				/*
				 *   get a char
				 */
				*ps = (char) getcmd ();
				nch++;

				/*
				 *   if backspace, undo last char. do not
				 *   advance ps, tho make sure we never go
				 *   past srchstr[0].
				 */
				if ((*ps == BS) || (*ps == DEL))
				{
					*ps-- = '\0';
					if (nch >= 1)
					{
						cerase ();
						nch--;
					}
					if (nch < 0)
					{
						nch = 0;
					}
					if ((long) ps < (long) srchstr)
						ps  = srchstr;

					continue;
				}

				/*
				 *   we finish if we get a CR
				 */
				if (*ps == CR || *ps == LF)
				{
					*ps = '\0';
					break;
				}

				/*
				 *   otherwise, print char and advance ps
				 */
				c_print ((int) *ps);
				ps++;
			}

			/*
			 *   do the search and paint the screen if we found
			 *   something
			 */
			if (search (srchdir, srchstr))
				fwd_full ();

			continue;
		}


		/*
		 *   go to beginning of status line and clear it
		 */
		clr_status ();


		/*
		 *   what command did we get?
		 */
		switch (cmd)
		{
		case 'g':		/* goto line (def 1) */
			if (ncmd == 1 && plcur->i_linum == 1)
			{
				/*
				 *   already at beginning
				 */
				bell ();
				break;
			}
			gotoline (ncmd);
			fwd_full ();
			break;

		case 'G':		/* goto last line */
			if (plcur->i_linum >= totlines - 24 + 1)
			{
				/*
				 *   already at end
				 */
				bells (2);
				break;
			}
			gotoline (totlines - 23);
			fwd_full ();
			break;

		case ' ':		/* forward screen */
		case 'f':
			if (plcur->i_linum >= totlines - 24 + 1)
			{
				/*
				 *   already at end
				 */
				bells (2);
				break;
			}
			gotoline (plcur->i_linum + (24 * ncmd) - 1);
			fwd_full ();
			break;

		case 'b':		/* backward screen */
			if (plcur->i_linum == 1)
			{
				/*
				 *   already at beginning
				 */
				bell ();
				break;
			}
			gotoline (plcur->i_linum - (24 *ncmd));
			fwd_full ();
			break;

		case 'd':		/* forward 1/2 screen */
			fwd_line (12);
			break;

		case 'u':		/* backward 1/2 screen */
			bkwd_line (12);
			break;

		case CR:		/* forward line */
		case 'e':
		case 'j':
			fwd_line (ncmd);
			break;

		case 'y':		/* backward line */
		case 'k':
			bkwd_line (ncmd);
			break;

		case 'r':		/* repaint screen */
			fwd_full ();
			break;

		case 'n':		/* repeat last search */
			if (search (srchdir, srchstr))
				fwd_full ();
			break;

		case '=':		/* show file name */
			show_fname ();
			break;

		case 'V':		/* show version */
			show_version ();
			break;

		case 'h':		/* help */
		case 'H':
			help ();
			fwd_full ();
			break;

		case 'Q':		/* quit */
		case 'q':
			quit ();
			break;

		default:
			bells (3);
			break;
		}
	}
}




/*------------------------------*/
/*	prompt			*/
/*------------------------------*/
prompt ()
{

/*
 *	normal prompt
 */

	static int	firsttime = 1;
	char		prstr[128];
	long		percent;
	int		linleft;


	/*
	 *   calculate % into file and number lines left from current
	 */
	percent = (100 * plcur->i_cumlen) / totlen;
	linleft = totlines - plcur->i_linum;


	/*
	 *   clear status line
	 */
	clr_status ();


	/*
	 *   put cursor on status line, enter rev video mode
	 */
	mv_cursor (0, 24);
	rvideo (1);


	/*
	 *   first time we display the prompt, we print file name
	 */
	if (firsttime)
	{
		firsttime = 0;
		s_print (stolower (curfname));
		s_print (" (press h for help)");
	}


	/*
	 *   if near the end of the file, say so
	 */
	if (linleft < 24)
		sprintf (prstr, " (END) \0");
	else
		sprintf (prstr, " %ld%% \0", percent);


	/*
	 *   the prompt is % into the file. do it, then back to normal video
	 */
	s_print (prstr);
	rvideo (0);
}




/*------------------------------*/
/*	cprompt			*/
/*------------------------------*/
cprompt (c)
int	c;
{

/*
 *	prompt with character
 */

	/*
	 *   clear status line
	 */
	clr_status ();


	mv_cursor (0, 24);
	c_print ((int) c);
}




/*------------------------------*/
/*	fwd_line		*/
/*------------------------------*/
fwd_line (n)
int	n;
{

/*
 *	print next n lines, scrolling. all tests done here. we write on the
 *	status line. on entry, we are at old top line. we advance here.
 */

	register struct iline  *pc;
	register struct iline  *pc24;
	register int		i;
	register int		ln;
	register int		ln24;


	/*
	 *   if already near bottom, ring bell and don't do any more
	 */
	if (plcur->i_linum >= totlines - 24 + 1)
	{
		bells (2);
		return;
	}


	/*
	 *   find next line to print, 25 lines down.
	 */
	ln   = plcur->i_linum;
	ln24 = ln + 24 - 1;
	if (ln24 > totlines)
	{
		bells (4);		/* should never get here... */
		return;
	}
	for (pc24 = plcur;  ; )
	{
		if ((pc24 = pc24->i_next) == (struct iline *) NULL)
		{
			bells (6);	/* should never get here... */
			return;
		}
		if (pc24->i_linum == ln24)
			break;
	}


	/*
	 *   for each line to move down...
	 */
	while (n--)
	{
		/*
		 *   if already near/at bottom, ring bell and don't do any more
		 */
		if ((plcur->i_linum >= totlines - 24 + 1))
		{
			bells (8);	/* should never get here... */
			return;
		}


		/*
		 *   reset pointer
		 */
		gotoline (plcur->i_linum + 1);
		pc24 = pc24->i_next;


		/*
		 *   we can never go past here, so stop now
		 */
		if ((pc24 == (struct iline *) NULL))
		{
			gotoline (plcur->i_linum - 1);
			bells (10);	/* should never get here... */
			return;
		}


		/*
		 *   too paranoid, all these checks! print the damn line
		 */
		clr_status ();
/*!!!		mv_cursor (0, 24);*/
		putline (pc24->i_line, stdout);
	}
}
			



/*------------------------------*/
/*	bkwd_line		*/
/*------------------------------*/
bkwd_line (n)
int	n;
{

/*
 *	print previous n lines, scrolling. all tests done here. we open a line
 *	at the top to do it.
 */

	while (n--)
	{
		if (plcur->i_linum == 1)
		{
			bell ();
			return;
		}
		gotoline (plcur->i_linum - 1);

		insert ();
		putline (plcur->i_line, stdout);
	}
}


			

/*------------------------------*/
/*	fwd_full		*/
/*------------------------------*/
fwd_full ()
{
	register struct iline  *pc;
	register int		i;
	int			actlen;

	clr_screen ();
	home ();

	for (pc = plcur, i = 0; i < scrlines; i++)
	{
		if (pc->i_next && pc->i_line)
		{
			/*
			 *   the line itself may have escape sequences. we
			 *   need the actual line length as it appears on the
			 *   screen. putline returns this.
			 */
			actlen = putline (pc->i_line, stdout);


			/*
			 *   check for wrap...
			 */
			if (actlen > 80)
			{
				scrlines -= (actlen % 80);
			}

			pc = pc->i_next;
		}
		else
			printf ("~\n");
	}
}




/*------------------------------*/
/*	cursor			*/
/*------------------------------*/
cursor (on)
int	on;
{

/*
 *	turn cursor on/off
 */

	if (on)		Cconws ("\33e\0");
	else		Cconws ("\33f\0");
}




/*------------------------------*/
/*	insert			*/
/*------------------------------*/
insert ()
{

/*
 *	insert line at top
 */

/*!!!	Cconws ("\33H\33L\0");*/	/* home, insert line */
	Cconws ("\33H\33I\0");		/* home, move up (insert) */
	pad (PADNUM);
}




/*------------------------------*/
/*	home			*/
/*------------------------------*/
home ()
{

/*
 *	move cursor to upper left corner
 */

	Cconws ("\33H\0");
	pad (PADNUM);
}




/*------------------------------*/
/*	wrap			*/
/*------------------------------*/
wrap (on)
int	on;
{

/*
 *	turn line wrap on/off
 */

	if (on)		Cconws ("\33v\0");
	else		Cconws ("\33w\0");
}




/*------------------------------*/
/*	rvideo			*/
/*------------------------------*/
rvideo (on)
int	on;
{

/*
 *	turn reverse video on/off (for prompt)
 */

	if (on)		Cconws ("\33p\0");
	else		Cconws ("\33q\0");
}




/*------------------------------*/
/*	mv_cursor		*/
/*------------------------------*/
mv_cursor (col, row)
int	col;
int	row;
{

/*
 *	move cursor to row,col (0,0 is UL corner). for printing
 */

	char	msg[10];

	sprintf (msg, "\33Y%c%c\0", (char) (' ' + row), (char) (' ' + col));
	Cconws (msg);
	pad (PADNUM);
}




/*------------------------------*/
/*	clr_screen		*/
/*------------------------------*/
clr_screen ()
{

/*
 *	clear screen, home cursor. we must pad here to make sure we get the
 *	first char if we print immediately after the clear...
 */

	Cconws ("\33E\0");
	pad (PADNUM);
}




/*------------------------------*/
/*	c_print			*/
/*------------------------------*/
c_print (c)
int	c;
{

/*
 *	output a char. works better with BIOS (Bconout) vs GEMDOS (Cconout)
 */

	c &= 0x00FF;
	Bconout (2, c);
	if (c == LF)
		Bconout (2, (int) CR);
}




/*------------------------------*/
/*	s_print			*/
/*------------------------------*/
s_print (s)
char   *s;
{

/*
 *	output a string
 */

	register char  *ps;

	for (ps = s; *ps; ps++)
	{
		if (*ps == LF)
			c_print ((int) CR);

		c_print ((int) *ps);
	}
}




/*------------------------------*/
/*	bell			*/
/*------------------------------*/
bell ()
{

/*
 *	ring bell once
 */

	Cconout ((int) BEL);
}




/*------------------------------*/
/*	bells			*/
/*------------------------------*/
bells (n)
int	n;
{

/*
 *	ring bell n times, 200 ms delay
 */

	while (n--)
	{
		Cconout ((int) BEL);
		wait_ms (200);
	}
}




/*------------------------------*/
/*	getcmd			*/
/*------------------------------*/
getcmd ()
{
	long	ret;

	ret = Cnecin ();

	return ((int)(ret & 0x000000FF));
}




/*------------------------------*/
/*	gotoline		*/
/*------------------------------*/
gotoline (n)
int	n;
{
	register struct iline  *pc;

	/*
	 *   trivial case is first or line
	 */
	if (n == 1 || n < 0)
	{
		plcur = plfirst;
		return;
	}
	if (n == totlines)
	{
		/*
		 *   remember: last "line" is tail anchor
		 */
		plcur = pllast->i_prev;
		return;
	}

	/*
	 *   check for n longer than file
	 */
	if (n > totlines)
		n = totlines;

	/*
	 *   if n ahead of where we are, search forward for correct line num.
	 *   else search backward from current point. it would be faster to
	 *   keep a table of line num vs plcur. for manpages, this probably
	 *   does not matter
	 */
	if (n > plcur->i_linum)
	{
		for (pc = plcur; pc; pc = pc->i_next)
		{
			if (pc->i_next == (struct iline *) NULL)
			{
				/*
				 *  n somehow larger than lenght of file.
				 *  set to last line
				 */
				plcur = pc->i_prev;
				break;
			}
			if (pc->i_linum == n)
			{
				plcur = pc;
				break;
			}
		}
	}
	else
	{
		for (pc = plcur; pc; pc = pc->i_prev)
		{
			if (pc->i_linum == n)
			{
				plcur = pc;
				break;
			}
			if (pc->i_prev == (struct iline *) NULL)
			{
				/*
				 *  n somehow smaller than 1.
				 *  set to first line
				 */
				plcur = pc;
				break;
			}
		}
	}
}




/*------------------------------*/
/*	isatty			*/
/*------------------------------*/
int isatty (handle)
register int	handle;
{

/*
 *	stolen from dlibs. this is the "approved" way of doing this...
 */

	register long	status;

	if ((status = Fseek (1L, handle, 1)) > 0)
	{
		Fseek (-1L, handle, 1);
		return (0);
	}
	return (status == 0);
}




/*------------------------------*/
/*	search			*/
/*------------------------------*/
int search (srchdir, srchstr)
int	srchdir;			/* 1=forward, 0=backward */
char   *srchstr;
{

/*
 *	search for string, both directions. returns 1 if string found, else 0.
 *	if string found, plcur is reset to that line.
 */

	register struct iline  *pc;
	register char	       *ps;
	register int		len;
	char			msg[128];


	/*
	 *   set length of search string
	 */
	len = strlen (srchstr);


	/*
	 *   what direction?
	 */
	if (srchdir)
	{
		/*
		 *   search forward from next line first see if there is a
		 *   next line...
		 */
		if (plcur->i_next == (struct iline *) NULL)
		{
			status_msg ("End of file. (press RETURN)");
			getcmd ();
			return (0);
		}
		for (pc = plcur->i_next; pc && pc->i_next; pc = pc->i_next)
		{
			for (ps = pc->i_line; *ps; ps++)
			{
				if (*ps != *srchstr)
					continue;
				if (!strncmp (ps, srchstr, len))
				{
					plcur = pc;
					return (1);
				}
			}
		}
		sprintf (msg, "Pattern /%s not found. (press RETURN)", srchstr);
	}
	else
	{
		/*
		 *   search backward from prev line. first see if there is a
		 *   previous line...
		 */
		if (plcur->i_prev == (struct iline *) NULL)
		{
			status_msg ("Beginning of file. (press RETURN)");
			getcmd ();
			return (0);
		}
		for (pc = plcur->i_prev; pc; pc = pc->i_prev)
		{
			for (ps = pc->i_line; *ps; ps++)
			{
				if (*ps != *srchstr)
					continue;
				if (!strncmp (ps, srchstr, len))
				{
					plcur = pc;
					return (1);
				}
			}
		}
		sprintf (msg, "Pattern ?%s not found. (press RETURN)", srchstr);
	}

	msg[79] = '\0';
	status_msg (msg);
	getcmd ();

	return (0);
}




/*------------------------------*/
/*	status_msg		*/
/*------------------------------*/
status_msg (s)
char   *s;
{

/*
 *	write string to status line, in reverse video. clear the line first.
 */

	clr_status ();

	rvideo (1);
	mv_cursor (0, 24);
	printf (" %s ", s);
	rvideo (0);
}




/*------------------------------*/
/*	clr_status		*/
/*------------------------------*/
clr_status ()
{

/*
 *	clear the status line, leave cursor at start of line
 */

	mv_cursor (0, 24);
	Cconws ("\33K\0");
}




/*------------------------------*/
/*	pad			*/
/*------------------------------*/
pad (n)
int	n;
{

/*
 *	give it time to clear screen. n is number of characters (for delay
 *	loop, this translates to the time to draw a character).
 */

	while (n--)
		wait_ms (PADTIME);
}




#define MSLOOP		192			/* generates a 1 ms loop */

/*------------------------------*/
/*	wait_ms			*/
/*------------------------------*/
wait_ms (ms)
int	ms;
{

/*
 *	wait the presribed number of milliseconds. nothing fancy, just
 *	kill time...
 */

	int	i;

	/*
	 *   trivial case (no neg wait)
	 */
	if (ms <= 0)
		return;

	for ( ; ms > 0; ms--)
		for (i = MSLOOP; i > 0; i--)
			;
	return;
}




/*------------------------------*/
/*	show_fname		*/
/*------------------------------*/
show_fname ()
{

/*
 *	show filename and current position statistics
 */

	char	msg[128];
	long	percent;
	int	linleft;

	percent = (100 * plcur->i_cumlen) / totlen;

	sprintf (msg, "%s line %d/%d byte %ld/%ld %ld%% (press RETURN)",
		stolower (curfname),
		plcur->i_linum, totlines,
		plcur->i_cumlen, totlen,
		percent);
	status_msg (msg);

	getcmd ();
}




/*------------------------------*/
/*	show_version		*/
/*------------------------------*/
show_version ()
{
	char	msg[128];

	sprintf (msg, "%s (press RETURN)", version);
	status_msg (msg);

	getcmd ();
}




/*------------------------------*/
/*	help			*/
/*------------------------------*/
help ()
{
	char	msg[128];

	clr_screen ();

printf (" Help for %s\n", myname);
printf ("\n");
printf ("motion:\tg          go to line (default 1)\n");
printf ("\tG          go to last line\n");
printf ("\tf, space   forward screen (default 1)\n");
printf ("\tb          backward screen (default 1)\n");
printf ("\td          forward 1/2 screen (default 1)\n");
printf ("\tu          backward 1/2 screen (default 1)\n");
printf ("\tj,e,CR     forward line (default 1)\n");
printf ("\tk,y        backward line (default 1)\n");

printf ("search:\t/string    search forward for string\n");
printf ("\t?string    search backward for string\n");
printf ("\tn          repeat last search (backward or forward)\n");

printf ("other:\tq,Q        quit\n");
printf ("\tr          repaint screen\n");
printf ("\th,H        help\n");
printf ("\t=          show file name and position\n");
printf ("\tV          show version\n");
printf ("\n");
printf (" The commands g,f,b,d,u,j, and k all accept optional numerical prefixes\n");
printf (" To change their defaults, enter a number, then the command. For example,\n");
printf (" enter \"22g\" to go to line 22 or \"2f\" to advance 2 screens.\n");

	sprintf (msg, "End of help. (press RETURN)");
	status_msg (msg);

	getcmd ();
}




/*------------------------------*/
/*	clr_char		*/
/*------------------------------*/
clr_char (col, row)
int	col;
int	row;
{

/*
 *	erase char at location specified, leaving cursor over that location
 */

	mv_cursor (col, row);
	c_print ((int) SPACE);
	mv_cursor (col, row);
}



/*------------------------------*/
/*	cerase			*/
/*------------------------------*/
cerase ()
{

/*
 *	erase last char, leaving cursor over that location
 */

	Cconws ("\33D\33K\0");	/* backspace, clear to eol */
}




