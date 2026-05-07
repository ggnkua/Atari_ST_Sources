/*
 *  Do listing type stuff.  It's slow no matter what
 *  we do here, so we might as well do it right.
 *
 *    ilist()		initialize lister
 *    lstout(tag)	prepare line (prior to assembly)
 *    listeol()		finish line (after assembly) and print it
 *    eject()		page eject
 *    d_title()		set title (directive)
 *    d_subttl()	set subtitle (directive)
 *    taglist(chr)	tag listing line
 *

 0    0    1    1    2    2    3    3    4    4    5    5    6    6    7    7
 012345678901234567890123456789012345678901234567890123456789012345678901234567
 filename....                            Atari Macro Assembler N.NN (Atari ST)
 nnnnn  aaaaaaaa  dddddddddddddddddddd T source code
 nnnnn  aaaaaaaa  dddddddddddddddd
 nnnnn           =vvvvvvvv

*/
#include "as.h"
#include "sect.h"

#define	BOT_MAR		1	/* #blank lines on bottom of page */
#define	IMAGESIZ	200	/* max size of a line of text */
#define	TITLESIZ	200	/* max size of a title */
#define	LN_COL		0	/* column for line numbers */
#define	LOC_COL		7	/* location ptr */
#define	DATA_COL	17	/* data start (for 20 chars, usually 16) */
#define	DATA_END	(DATA_COL+20) /* end+1th data column */
#define	TAG_COL		38	/* tag character */
#define	SRC_COL		40	/* source start */


/*
 *  Imports
 */
extern char *list_fname;	/* -> listing filename */
extern char *firstfname;	/* first source name */
extern int listing;		/* listing level */
extern int list_fd;		/* listing file descriptor */
extern int curlineno;		/* line# in current file */
extern int just_bss;		/* 1, don't show data (ds.b in uProc mode) */
extern char *curfname;		/* -> current filename */
extern char lnbuf[];		/* image of current line */
extern int cursect;		/* current section */
extern LONG sloc;		/* current location in section */
extern TOKEN *tok;		/* -> token list */
extern char version[];		/* = text of assembler version# */

LONG lsloc;			/* `sloc' at start of line */
int pagelen = 61;		/* #lines on a page */
char subttl[TITLESIZ];		/* current subtitle */


/*
 *  Private
 */
static int lcursect;		/* `cursect' at start of line */
static int llineno;		/* `curlineno' at start of line */
static int nlines;		/* #lines on page so far */
static int pageno;		/* current page number */
static int pagewidth;		/* #columns on a page */
static int subflag;		/* 0, don't do .eject on subttl (set 1) */
static char lnimage[IMAGESIZ];	/* image of output line */
static char title[TITLESIZ];	/* current title */
static char datestr[20];	/* current date dd-mon-yyyy */
static char timestr[20];	/* current time hh:mm:ss [am|pm] */

static char buf[IMAGESIZ];	/* buffer for numbers */


/*
 *  Initialize listing generator
 *
 */
ilist()
{
	extern VALUE dos_date(), dos_time();

	subflag = 0;
	pageno = 0;
	nlines = 0;

	pagelen = 61;
	pagewidth = 132;
	strcpy(title, "");
	strcpy(subttl, "");
	date_string(datestr, dos_date());
	time_string(timestr, dos_time());
}


/*
 *  Copy current (saved) line to output buffer
 *  and tag it with a character.
 *
 */
lstout(tag)
char tag;
{
	register int i;
	register char *s;
	register char *d;

	lsloc = sloc;
	lcursect = cursect;
	llineno = curlineno;

	lnfill(lnimage, SRC_COL, SPACE); /* fill with spaces */
	lnimage[TAG_COL] = tag;

	/*
	 *  Copy line image and
	 *  handle control characters
	 */
	d = lnimage + SRC_COL;
	for (s = lnbuf; *s; ++s)
		if (*s >= 0x20 ||
			  *s == '\t')
			*d++ = *s;
		else
		{
			*d++ = '^';
			*d++ = *s + 0x40;
		}
	*d++ = EOS;
}


listvalue(v)
VALUE v;
{
	sprintf(buf, "=%08lx", v);
	scopy(lnimage+DATA_COL-1, buf, 9);
}


listeol()
{
	register CHUNK *ch;
	register char *p;
	int col;
	LONG count;
	int fixcount;
	extern int fixtest();

#ifdef DO_DEBUG
	DEBUG printf("~list: lsloc=$%lx sloc=$%lx\n", lsloc, sloc);
#endif

	if (lsloc != sloc)
	{
		sprintf(buf, "%08lx", lsloc);
		scopy(lnimage+LOC_COL, buf, 8);
	}

	if (llineno != curlineno)
	{
		sprintf(buf, "%5d", llineno);
		scopy(lnimage+LN_COL, buf, 5);
	}


	/*
	 *  List bytes only when section stayed the same
	 *  and the section is not a "no-data" (SBSS) section.
	 *
	 *  An extra annoyance is caused by "ds.b" in a microprocessor
	 *  mode, which prints out bytes of zero as if they had been
	 *  deposited with dcb.  The fix (kludge) is an extra variable
	 *  which records the fact that a 'ds.x' directive generated
	 *  all the data, and it shouldn't be listed
	 *
	 */
	savsect();		/* update section variables */
	if (lcursect == cursect &&
		  (sect[lcursect].scattr & SBSS) == 0 &&
		  lsloc != sloc &&
		  just_bss == 0)
	{
		ch = sect[lcursect].sfcode;
		if (lcursect != M6502)
			for (; ch != NULL; ch = ch->chnext)
				if (lsloc >= ch->chloc &&
					  lsloc < (ch->chloc + ch->chsize))
					break;

		if (ch == NULL)
		{			/* fatal: cannot find chunk holding the code */
nochunk:
			interror(6);		/* can't find generated code in section */
			/*notreached*/
		}

		p =  ch->chptr + (lsloc - ch->chloc);
		col = DATA_COL;
		fixcount = 0;
		for (count = sloc - lsloc; count--; col += 2, ++lsloc)
		{
			if (col >= DATA_END)
			{			/* ship the line */
				col = DATA_COL;
				uc_ln(lnimage);
				ship_ln(lnimage);
				lnfill(lnimage, SRC_COL, SPACE); /* fill with spaces */
				sprintf(buf, "%08lx", lsloc);
				scopy(lnimage+LOC_COL, buf, 8);
			}

			if (lcursect != M6502 &&
				  lsloc >= (ch->chloc + ch->chsize))
			{
				if ((ch = ch->chnext) == NULL)
					goto nochunk;
				p = ch->chptr;
			}

			if (!fixcount)
				fixcount = fixtest(lcursect, lsloc);

			if (fixcount)
			{
				--fixcount;
				strcpy(buf, "xx");
				++p;			/* 12-May-1988 lmd; advance anyway */
			}
			else sprintf(buf, "%02x", *p++ & 0xff);
			scopy(lnimage+col, buf, 2);
		}

		if (col > DATA_COL)	/* flush partial line */
		{
			uc_ln(lnimage);
			ship_ln(lnimage);
		}
	}
	else
	{
		uc_ln(lnimage);
		ship_ln(lnimage);
	}
}


/*
 *  Ship line `ln' out;
 *  do page breaks and title stuff.
 *
 */
ship_ln(ln)
char *ln;
{
	register int i;
	register char j;

	/*
	 *  If listing level is <= 0, then don't print anything
	 */
	if (listing <= 0)
		return;

	/*
	 *  Notice bottom of page.
	 */
	if (nlines >= pagelen - BOT_MAR)
		eject();

	/*
	 *  Print title, boilerplate, and subtitle at top of page.
	 */
	if (nlines == 0)
	{
		++pageno;
		println("");
		sprintf(buf,
				"%-40s%-20s Page %-4d    %s %s     Madmac %s (%s)",
				title, curfname, pageno, timestr, datestr, version, SYSTEM);
		println(buf);
		sprintf(buf, "%s", subttl);
		println(buf);
		println("");
		nlines = 4;
	}

	println(ln);
	++nlines;
}


/*
 *  Transform letters a-f in the address and data columns of
 *  the listing to uppercase.  (People seem to like uppercase
 *  hex better in assembly-language listings....)
 *
 */
uc_ln(ln)
char *ln;
{
	register int i;
	register char j;

	for (i = LOC_COL; i < SRC_COL; ++i)
		if ((j = ln[i]) >= 'a' &&
			  j <= 'f')
			ln[i] = j - 0x20;
}


/*
 *  Tag listing with a character,
 *  typically for errors or warnings.
 */
taglist(chr)
char chr;
{
	lnimage[TAG_COL+1] = chr;
}


/*
 *  Print a line to the listing file.
 *
 */
println(ln)
register char *ln;
{
	if (list_fname != NULL)	/*  create listing file, if necessary */
		list_setup();

	write(list_fd, ln, (LONG)strlen(ln));
#ifdef ST
	write(list_fd, "\r\n", 2L);
#endif
#ifdef UNIX
	write(list_fd, "\n", 1L);
#endif
}


/*
 *  Create listing file
 *  (with the appropriate name)
 *
 */
list_setup()
{
	char fnbuf[FNSIZ];

	strcpy(fnbuf, list_fname);
	if (*fnbuf == EOS)
	{
		strcpy(fnbuf, firstfname);
		fext(fnbuf, ".prn", 1);
	}
	list_fname = NULL;

	if ((list_fd = creat(fnbuf, CREATMASK)) < 0)
		cantcreat(fnbuf);
}


/*
 *  Eject the page (print empty lines),
 *  reset the line count, and bump the page number.
 *
 */
eject()
{
	if (listing > 0)
	{
		println("\f");
		nlines = 0;
	}
}


/*
 *  Set title
 *  on titles not on the first page, do an eject
 *  and clobber the subtitle.
 *
 */
d_title()
{
	if (*tok != STRING)
		return error("missing string");
	strcpy(title, (char*)tok[1]);
	tok += 2;

	if (pageno > 1)
	{
		strcpy(subttl, "");
		eject();
	}
}


/*
 *  .subttl [-] "string"
 *
 *  Set subtitle;
 *    o  leading '-' supresses page eject
 *    o  don't .eject on first .subttl, but do so on all other ones,
 *    o  arrange not to print the .subttl directive
 *
 */
d_subttl()
{
	register int ejectok;

	ejectok = 1;
	if (*tok == '-')
	{
		ejectok = 0;
		++tok;
	}

	if (*tok != STRING)
		return error("missing string");
	strcpy(subttl, (char*)tok[1]);

	tok += 2;
	if (ejectok &&
		  (subflag || pageno > 1))	/* always eject on pages 2+ */
		eject();
	subflag = 1;
}


/*
 *  Copy `n' characters from `src' to `dest'
 *  (also stops on EOS in src).
 *  Does not null-terminate dest.
 *
 */
scopy(dest, src, len)
register char *src;
register char *dest;
register int len;
{
	if (len < 0)
		len = 1000;			/* some large number */
	while (len-- && *src)
		*dest++ = *src++;
}


/*
 *  Fill region `dest' with `len' characters `c'
 *  and null terminate the region.
 *
 */
lnfill(dest, len, chr)
register char *dest;
register int len;
register char chr;
{
	while (len--)
		*dest++ = chr;
	*dest = EOS;
}
