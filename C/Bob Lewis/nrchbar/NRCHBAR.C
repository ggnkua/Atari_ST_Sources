#undef NO_PIPE		/* def to eliminate diff (read from stdin instead) */
#undef USE_MALLOC	/* def to malloc space for diff command line */
#ifndef ALCYON
# define ALCYON		/* for popen(3) simulation and other stuff */
#endif

/*
 *	nrchbar - insert nroff change bar commands into a file
 *
 *	note: original unix version uses popen ("diff file1 file2", "r")
 *	to get diff output. i wrote an ST version of popen(3) to get the
 *	job done. uses system(3) and stdio.
 *
 *	note: to make this, you need getopt(3), diff(1), system(3), popen(3)
 *	and pclose(3) (simulated here for ST), and ungetc(3S). if you use the
 *	popen provided, DON'T #define USE_MALLOC!
 */

#include <stdio.h>

#ifdef ALCYON
# define DIFFPROG	"c:\\bin\\diff.ttp"
#else
# define DIFFPROG	"/bin/diff"
#endif

typedef	int bool;

#ifdef TRUE
# undef TRUE
#endif
#ifdef FALSE
# undef FALSE
#endif
#define	TRUE		1
#define	FALSE		0

#define	ADD		'a'
#define	CHANGE		'c'
#define	DELETE		'd'

typedef	struct
{
	int	lnOldFrom;
	int	lnOldTo;
	int	cmd;
	int	lnNewFrom;
	int	lnNewTo;
}		diffdescr;

char	       *progname;
#ifdef ALCYON
char	       *_progname = "nrchbar";
#endif
bool		flagAll	= FALSE;
bool		flagBreakAfter = TRUE;
bool		flagDelete = FALSE;
bool		debugging = FALSE;
char	       *version = "nrchbar 1.4 (TOS) 90/07/25 04:51:58 rosenkra";

/*
 *	forward	declarations
 */
FILE	       *fopenOrElse ();
void		nrchbar	();
void		skipLinesOrElse	();
void		userErr	();
void		beginChbar ();
bool		cpLin ();
void		cpLinOrElse ();
void		endChbar ();
int		getDiff ();
bool		isRoffCmd ();
void		markDiff ();
#ifndef NO_PIPE
FILE	       *pipeDiffs ();
#endif


#ifndef	lint
# ifdef ALCYON
char   *rcsid = "$Header: nrchbar.c,v 1.4(TOS) 90/07/25 04:51:58 rosenkra Exp $";
# else
char   *rcsid = "$Header: nrchbar.c,v 1.3 87/03/31 16:33:16 bobl Exp $";
# endif
#endif



/*------------------------------*/
/*	main			*/
/*------------------------------*/
main (argc, argv)
int	argc;
char   *argv[];
{
	extern int	optind;
	extern int	getopt ();

	int		c;
	FILE	       *fpDiff,
		       *fpNew;
	char	       *fnOld,
		       *fnNew;

#ifdef ALCYON
	progname = _progname;
#else
	progname = argv[0];
#endif

	while ((c = getopt (argc, argv, "abdv")) != EOF)
	{
		switch (c)
		{
		case 'a':			/* all changes */
			flagAll	= TRUE;
			break;

		case 'b':			/* no breaks after changes */
			flagBreakAfter = FALSE;
			break;

		case 'd':			/* show deleted sections */
			flagDelete = TRUE;
			break;

		case 'v':
			printf ("%s\n", version);
			exit (0);

		case '?':
		default:
			fprintf	(stderr, "%s: unknown flag \"-%c\"\n",
				progname, (int) c);
			fprintf	(stderr,
				"Usage: %s [-a] [-b] [-d] [oldfile] newfile\n",
				progname);
			exit (1);
			break;
		}
	}


	/* 
	 *   Depending on the number of files on the command line.
	 */
	switch (argc - optind)
	{
	case 1:	
		fpDiff = stdin;
		fnNew  = argv[optind++];
		fpNew  = fopenOrElse (fnNew, "r");
		break;

	case 2:	
#ifdef NO_PIPE
		fprintf	(stderr,
			"%s: sorry, no pipes. use stdin.\n", progname);
		exit (1);
#else
		fnOld  = argv[optind++];
		fnNew  = argv[optind++];
		fpDiff = pipeDiffs (fnOld, fnNew);
		fpNew  = fopenOrElse (fnNew, "r");
#endif
		break;

	default: 
		fprintf	(stderr,
			"Usage: %s [-a] [-b ] [-d] [oldfile] newfile\n",
			progname);
		exit (1);
	}

	/* 
	 *   Now the real work begins.
	 */
	nrchbar	(fpDiff, fpNew);

	/*
	 *   clean up and exit...
	 */
	if (fpDiff != stdin)
		pclose (fpDiff);

	exit (0);
}



/*------------------------------*/
/*	beginChbar		*/
/*------------------------------*/
void beginChbar	(chMark)
int	chMark;			/* in: use this	character */
{

/*
 *	beginChbar -- put out a	*roff command to begin a change	bar
 */

/*!!!	if (flagBreakAfter)
		printf (".br\n");
*/
	printf (".mc %c\n", chMark);
	return;
}



/*------------------------------*/
/*	cpLin			*/
/*------------------------------*/
bool cpLin (nLn, nSkip, fpFrom)
int	nLn;			/* in: copy this many lines ...	*/
int	nSkip;			/* in: ... skipping this many characters
					   at the start	of each	one ...	*/
FILE   *fpFrom;			/* in: ... from	this file to stdout */
{

/*
 *	cpLin -- copy a given number of lines from one file to standard
 *	output
 */

	int	ch;
	int	iSkip;

	while (nLn-- > 0)
	{
		for (iSkip = 0;	iSkip <	nSkip; iSkip++)
		{
			if (getc (fpFrom) == EOF)
				return (FALSE);
		}
		do
		{
			ch = getc (fpFrom);
			if (ch == EOF)
				return (FALSE);
			putchar	(ch);

		} while	(ch != '\n');
	}

	return (TRUE);
}



/*------------------------------*/
/*	cpLinOrElse		*/
/*------------------------------*/
void cpLinOrElse (nLn, nSkip, fpFrom)
int	nLn;			/* in: copy this many lines ...	*/
int	nSkip;			/* in: ... skipping this many characters
					   at the start	of each	one ...	*/
FILE   *fpFrom;			/* in: ... from	this file to stdout */
{

/*
 *	cpLinOrElse -- copy a given number of lines from one file to
 *	standard output; exit if unable
 */

	if (!cpLin (nLn, nSkip, fpFrom))
		userErr	("unexpected EOF");	/* exits! */
	return;
}



/*------------------------------*/
/*	endChbar		*/
/*------------------------------*/
void endChbar ()
{

/*
 *	endChbar -- put	out a *roff command to end a change bar	section
 */

	/*
	 *   make sure the previous change bar is visible
	 */
	if (flagBreakAfter)
		printf (".br\n");

	printf (".mc\n");

	return;
}



/*------------------------------*/
/*	fopenOrElse		*/
/*------------------------------*/
FILE *fopenOrElse (fname, type)
char   *fname;			/* in: file name to open */
char   *type;			/* in: way in which to open fname */
{

/*
 *	fopenOrElse -- open a file or else exit	with an	error message
 */

	FILE   *fp;


	fp = fopen (fname, type);

	if (fp == (FILE *) NULL)
	{
		fprintf	(stderr, "%s: can't open \"%s\" for mode \"%s\"\n",
			progname, fname, type);
		exit (1);
	}
	return (fp);
}



/*------------------------------*/
/*	getDiff			*/
/*------------------------------*/

#define	EOA		0
#define	START_ACCUM	1
#define	ACCUM		2
#define	SETOLDFROM	3
#define	SETOLDTO	4
#define	SETCMD		5
#define	SETNEWFROM	6
#define	SETNEWTO	7
#define	MXN_ACTION	8

struct FSM
{
	int	state;
	char   *trig;
	int	stateNext;
	int	action[MXN_ACTION];
};

struct FSM     *fsmCur;
struct FSM	fsm[16] = 
{
/*	state	trig	      stateNext action */

	{0,	"0123456789",	1,	{START_ACCUM, EOA} },
	{1,	"0123456789",	1,	{ACCUM, EOA} },
	{1,	",",		2,	{SETOLDFROM, EOA} },
	{1,	"acd",		4,	{SETOLDFROM, SETOLDTO, SETCMD, EOA} },
	{2,	"123456789",	3,	{START_ACCUM, EOA} },
	{3,	"0123456789",	3,	{ACCUM, EOA} },
	{3,	"acd",		4,	{SETOLDTO, SETCMD, EOA} },
	{4,	"0123456789",	5,	{START_ACCUM, EOA} },
	{5,	"0123456789",	5,	{ACCUM, EOA} },
	{5,	",",		6,	{SETNEWFROM, EOA} },
	{5,	"\n",		-1,	{SETNEWFROM, SETNEWTO, EOA} },
	{6,	"123456789",	7,	{START_ACCUM, EOA} },
	{7,	"0123456789",	7,	{ACCUM, EOA} },
	{7,	"\n",		-1,	{SETNEWTO, EOA} },
	{-1,	0L,		-1,	{EOA} }		/* sentinal */
};

int getDiff (fp, ddscr)
FILE	       *fp;		/* in: file containing "diff" output */
diffdescr      *ddscr;		/* in: a diff section descriptor */
{

/*
 *	getDiff	-- get a "diff"	description line
 *
 *	diff output looks like this:
 *
 *		12 c 12				range
 *		< (hereafter, "*roff")		first file
 *		---				seperator
 *		> (hereafter, "_roff")		second file
 *
 *	range can be like these:
 *
 *		n l n
 *		n,n l n
 *		n l n,n
 *
 *	where n is a number, l is a letter (a, d, c)
 */


	extern char    *index ();

	int		stateCur = 0;
	int		ch,
			accum =	0;
	int	       *action;
	int		len = 0;

	do
	{
		/*
		 *   get a char, skip spaces
		 */
GET_A_CHAR:
		ch = getc (fp);
		if (ch == EOF)
			return (EOF);
		if (ch == ' ' || ch == '\t')
			goto GET_A_CHAR;


		/*
		 *   set current fsm to first one
		 */
		len++;
		fsmCur = (struct FSM *) &fsm[0];

		/*
		 *   find a state where ch is in trig. don't go past the end
		 */
		while (fsmCur->state != -1
		&& (fsmCur->state != stateCur
		|| index (fsmCur->trig, (char) ch) == (char *) NULL))
		{
			if (debugging == TRUE)
				fprintf (stderr,
				"state loop: fsmCur->state = %d, stateCur = %d, index (|%s|, |%c|)\n",
				fsmCur->state, stateCur, fsmCur->trig, (int) ch);

			fsmCur++;
		}

		/*
		 *   if we reached the end, there was no match (error)
		 */
		if (fsmCur->state == -1)
			userErr	("illegal syntax in 'diff' output");

		/*
		 *   do the work for each action in this state
		 */
		for (action = fsmCur->action; *action != EOA; action++)
		{
			if (debugging == TRUE)
				fprintf (stderr,
					"action loop: action = %d\n", action);

			switch (*action)
			{
			case START_ACCUM:	/* get a number */
				accum =	ch - '0';
				break;

			case ACCUM:		/* continue on number */
				accum =	10 * accum + (ch - '0');
				break;

			case SETCMD:		/* a command (a,c,d) */
				ddscr->cmd = ch;
				break;

			case SETNEWFROM:	/* new, range start */
				ddscr->lnNewFrom = accum;
				break;

			case SETNEWTO:		/* new, range end */
				ddscr->lnNewTo = accum;
				break;

			case SETOLDFROM:	/* old, range start */
				ddscr->lnOldFrom = accum;
				break;

			case SETOLDTO: 		/* old, range end */
				ddscr->lnOldTo = accum;
				break;
			}
		}

		/*
		 *   set current state to next state and continue reading
		 *   the diff "command"
		 */
		stateCur = fsmCur->stateNext;

	} while	(stateCur != -1);

	return (len);
}



/*------------------------------*/
/*	isRoffCmd		*/
/*------------------------------*/
bool isRoffCmd (fp)
FILE   *fp;			/* in: file to examine for *roff command */
{

/*
 *	isRoffCmd -- return TRUE iff the next line begins with a *roff
 *	command
 */

	int	ch;

	if ((ch	= getc (fp)) ==	EOF)
		userErr	("unexpected EOF");

	ungetc (ch, fp);

	return (ch == '.');		/* don't know about ".cc" command */
}



/*------------------------------*/
/*	markDiff		*/
/*------------------------------*/
void markDiff (ddscr, fpDiff, fpNew)
diffdescr      *ddscr;		/* in: descriptor of the differing sections */
FILE	       *fpDiff;		/* in: the diff	file */
FILE	       *fpNew;		/* in: the new file */
{

/*
 *	markDiff -- note a changed section of a	file; return # of lines
 *	copied from fpNew
 */

	int	nLnNew;
	int	nLnOld;
	int	nLnNewCopy;

	nLnNew     = ddscr->lnNewTo - ddscr->lnNewFrom + 1;
	nLnOld     = ddscr->lnOldTo - ddscr->lnOldFrom + 1;
	nLnNewCopy = nLnNew;

	switch (ddscr->cmd)
	{
	case ADD: 
		if (!flagAll)
		{
			while (nLnNewCopy > 0 && isRoffCmd (fpNew))
			{
				cpLinOrElse (1, 0, fpNew);
				nLnNewCopy--;
			}
		}
		if (nLnNewCopy > 0)
		{
			beginChbar ('+');
			cpLinOrElse (nLnNewCopy, 0, fpNew);
			endChbar ();
		}
		skipLinesOrElse	(nLnNew, fpDiff);
		return;

	case CHANGE: 
		if (!flagAll)
		{
			while (nLnNewCopy > 0 && isRoffCmd (fpNew))
			{
				cpLinOrElse (1, 0, fpNew);
				nLnNewCopy--;
			}
		}
		if (nLnNewCopy > 0)
		{
			beginChbar ('|');
			cpLinOrElse (nLnNewCopy, 0, fpNew);
			endChbar ();
		}
		skipLinesOrElse	(nLnNew	+ 1 + nLnOld, fpDiff);
					/* allow for "---" in diff */
		return;

	case DELETE: 
		beginChbar ('-');
		if (flagDelete)
		{
			putchar	('[');
			putchar	('[');
			putchar	('\n');
			cpLinOrElse (nLnOld, 2, fpDiff);
					/* strip off the "< " */
			putchar	(']');
			putchar	(']');
			putchar	('\n');
		}
		else
			skipLinesOrElse	(nLnOld, fpDiff);
		endChbar ();
		return;
	}
}



/*------------------------------*/
/*	nrchbar			*/
/*------------------------------*/
void nrchbar (fpDiff, fpNew)
FILE   *fpDiff;			/* in: diff file */
FILE   *fpNew;			/* in: original	file */
{

/*
 *	nrchbar	-- produce *roff change	bar file
 */

	int		lnNew =	1;
	int		nLines;
	diffdescr	ddscr;

	/*
	 *   read diff "commands"
	 */
	while (getDiff (fpDiff,	&ddscr)	!= EOF)
	{
		/*
		 *   line count from command
		 */
		nLines = ddscr.lnNewFrom - lnNew;
		if (ddscr.cmd == DELETE)
			nLines++;

		/*
		 *   copy the lines from new file
		 */
		cpLinOrElse (nLines, 0, fpNew);

		/*
		 *   add any change bars...
		 */
		markDiff (&ddscr, fpDiff, fpNew);
		lnNew =	ddscr.lnNewTo +	1;
	}

	/*
	 *   last line...
	 */
	while (cpLin (1, 0, fpNew))
		;

	return;
}



#ifndef NO_PIPE

/*------------------------------*/
/*	pipeDiffs		*/
/*------------------------------*/
FILE *pipeDiffs	(fnOld,	fnNew)
char   *fnOld;			/* in: old file	name */
char   *fnNew;			/* in: new file	name */
{

/*
 *	pipeDiffs -- return a pipe with	a diff run on the other	end
 */

	FILE   *popen ();
	char   *malloc ();

	char   *cmd;
	FILE   *fpPipe;
#ifndef USE_MALLOC
	char	cmdbuf[1000];		/* need more space to append ">file" */
#endif

	/*
	 *   make up the diff command...
	 */
#ifdef USE_MALLOC
	cmd = (char *) malloc ((unsigned int) (strlen (DIFFPROG) + 1 + strlen (fnOld) +	1 + strlen (fnNew) + 1));
#else
	cmd = &cmdbuf[0];
#endif
	sprintf	(cmd, "%s %s %s", DIFFPROG, fnOld, fnNew);

	/*
	 *   do it with a pipe
	 */
	fpPipe = popen (cmd, "r");
	if (fpPipe == (FILE *) NULL)
	{
		fprintf	(stderr, "%s: can't open pipe for \"%s\"\n",
				progname, cmd);
		exit (1);
	}

	/*
	 *   clean up...
	 */
#ifdef USE_MALLOC
	free (cmd);
#endif

	/*
	 *   return descriptor of pipe
	 */
	return (fpPipe);
}



#ifdef ALCYON

/*------------------------------*/
/*	popen			*/
/*------------------------------*/

#define PIPE_FILE	"__NRCH__.PIP"

FILE *popen (cmd, mode)
char   *cmd;
char   *mode;
{

/*
 *	simulate pipes on the ST (alcyon). pipe output of cmd to file.
 *	return file descriptor of fopen'd file as the pipe descriptor.
 *
 *	pclose should close the descriptor, then delete the pipe file...
 *	note: abnormal exits to nrchbar may cause the pipe file to linger.
 */

	FILE   *fp;

	/*
	 *   only read pipes needed here...
	 */
	if (*mode == 'r')
	{
		/*
		 *   delete the "pipe"
		 */
		unlink (PIPE_FILE);

		/*
		 *   cat an output redirect to the command
		 */
		strcat (cmd, " >");
		strcat (cmd, PIPE_FILE);

		/*
		 *   do it! we could be more selective here: if diff returns
		 *   0, there were no diffs so there should be no need to
		 *   do this.
		 */
		system (cmd);

		/*
		 *   now open the "pipe" as a file and return its descriptor
		 *   don't need to check as NULL is a valid return...
		 */
		fp = fopen (PIPE_FILE, "r");

		return (fp);
	}
	else
	{
		fprintf (stderr, "%s: sorry, no support for write pipes!\n", progname);
		return ((FILE *) 0);
	}
}



/*------------------------------*/
/*	pclose			*/
/*------------------------------*/
pclose (fp)
FILE   *fp;
{
	/*
	 *   close the pipe (open file). delete the pipe file
	 */
	close (fp);
	unlink (PIPE_FILE);
}

#endif /*ALCYON*/

#endif /*!NO_PIPE*/



/*------------------------------*/
/*	skipLinesOrElse		*/
/*------------------------------*/
void skipLinesOrElse (nLn, fp)
int	nLn;			/* in: skip this many lines ...	*/
FILE   *fp;			/* in: ... in this file	*/
{

/*
 *	skipLinesOrElse	-- skip	a given	number of lines	in a file; exit	if
 *	errors
 */

	int	ch;

	while (nLn-- > 0)
	{
		do
		{
			if ((ch	= getc (fp)) ==	EOF)
				userErr	("unexpected EOF");

		} while	(ch != '\n' && ch != '\r');
	}
	return;
}



/*------------------------------*/
/*	userErr			*/
/*------------------------------*/
void userErr (msg)
char   *msg;
{

/*
 *	userErr	-- note	an error and politely exude
 */

	fprintf	(stderr, "%s: %s\n", progname, msg);
	exit (1);
}

