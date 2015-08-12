/* token.c */

/*
 *  Tokenizer (include files and macros)
 *
 *    itoken()			initialization
 *    tokln()			tokenize a line
 *    include(handle, filename)	include a file
 *    fpop()			pop and include file or macro
 *    d_goto()			handle ".GOTO" directive
 *
 *    getln()			*fast* buffered fgets()
 *    getmln()			get next line from a macro
 *    getrln()			get next line from a repeat block
 *    a_inobj(typ)		alloc and push include-object
 *    setfnum(fnum)		set 'curfname', for error message reporting
 *    mexpand(src,dst,dstsiz)	perform macro expansion
 *
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "as.h"
#include "token.h"

#define DECL_KW			/* declare keyword arrays */
#define DEF_KW			/* declare keyword values */
#include "kwtab.h"		/* include generated keyword tables and defs */


/*
 *  Imports
 */
extern int as68_flag;		/* 1, as68 "compatibility" crock */
extern int verb_flag;		/* 1, verbose mode */
extern IFENT *ifent;		/* top ifent */


/*
 *  Character Attributes
 *
 */
#define	ILLEG	0		/* illegal character (unused) */
#define	DIGIT	1		/* 0-9 */
#define	HDIGIT	2		/* A-F, a-f */
#define	STSYM	4		/* A-Z, a-z, _~. */
#define	CTSYM	8		/* A-Z, a-z, 0-9, _~$? */
#define	SELF	16		/* single-character tokens: ( ) [ ] etc. */
#define	WHITE	32		/* whitespace (space, tab, etc.) */
#define	MULT	64		/* multiple-character tokens */
#define DOT	128		/* [bwlsBWSL] for what follows a `.' */


char chrtab[] =
{
	ILLEG,ILLEG,ILLEG,ILLEG,			/* NUL SOH STX ETX */
	ILLEG,ILLEG,ILLEG,ILLEG,			/* EOT ENQ ACK BEL */
	ILLEG,WHITE,ILLEG,ILLEG,			/* BS HT LF VT */
	WHITE,ILLEG,ILLEG,ILLEG,			/* FF CR SO SI */

	ILLEG,ILLEG,ILLEG,ILLEG,			/* DLE DC1 DC2 DC3 */
	ILLEG,ILLEG,ILLEG,ILLEG,			/* DC4 NAK SYN ETB */
	ILLEG,ILLEG,ILLEG,ILLEG,			/* CAN EM SUB ESC */
	ILLEG,ILLEG,ILLEG,ILLEG,			/* FS GS RS US */

	WHITE,MULT,MULT,SELF,				/* SP ! " # */
	MULT+CTSYM,MULT,SELF,MULT,			/* $ % & ' */
	SELF,SELF,SELF,SELF,				/* ( ) * + */
	SELF,SELF,STSYM,SELF,				/* , - . / */

	DIGIT+HDIGIT+CTSYM,DIGIT+HDIGIT+CTSYM,		/* 0 1 */
	DIGIT+HDIGIT+CTSYM,DIGIT+HDIGIT+CTSYM,		/* 2 3 */
	DIGIT+HDIGIT+CTSYM,DIGIT+HDIGIT+CTSYM,		/* 4 5 */
	DIGIT+HDIGIT+CTSYM,DIGIT+HDIGIT+CTSYM,		/* 6 7 */
	DIGIT+HDIGIT+CTSYM,DIGIT+HDIGIT+CTSYM, 	/* 8 9 */
	MULT,MULT,					/* : ; */
	MULT,MULT,MULT,STSYM+CTSYM,			/* < = > ? */

	MULT,STSYM+CTSYM+HDIGIT,			/* @ A */
	DOT+STSYM+CTSYM+HDIGIT,STSYM+CTSYM+HDIGIT,	/* B C */
	STSYM+CTSYM+HDIGIT,STSYM+CTSYM+HDIGIT,		/* D E */
	STSYM+CTSYM+HDIGIT,STSYM+CTSYM,		/* F G */
	STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,	/* H I J K */
	DOT+STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,	/* L M N O */

	STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,DOT+STSYM+CTSYM,	/* P Q R S */
	STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,DOT+STSYM+CTSYM,	/* T U V W */
	STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,SELF,		/* X Y Z [ */
	SELF,SELF,MULT,STSYM+CTSYM,				/* \ ] ^ _ */

	ILLEG,STSYM+CTSYM+HDIGIT,				/* ` a */
	DOT+STSYM+CTSYM+HDIGIT,STSYM+CTSYM+HDIGIT,		/* b c */
	STSYM+CTSYM+HDIGIT,STSYM+CTSYM+HDIGIT,			/* d e */
	STSYM+CTSYM+HDIGIT,STSYM+CTSYM,			/* f g */
	STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,	/* h i j k */
	DOT+STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,	/* l m n o */

	STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,DOT+STSYM+CTSYM,	/* p q r s */
	STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,DOT+STSYM+CTSYM,	/* t u v w */
	STSYM+CTSYM,STSYM+CTSYM,STSYM+CTSYM,SELF,		/* x y z { */
	SELF,SELF,SELF,ILLEG					/* | } ~ DEL */
};

char tolowertab[128];		/* uppercase ==> lowercase */
char hextab[128];		/* table of hex values */
char dotxtab[128];		/* table for ".b", ".s", etc. */
TOKEN tokeol[1] = {EOL};	/* bailout end-of-line token */


/* -------------------------------- */


TOKEN *tok;			/* -> current token */
TOKEN *etok;			/* -> past last token in tokbuf[] */
char *curfname;			/* -> current filename */
WORD filecount;			/* = unique file number counter */
WORD cfileno;			/* = current file number */
int curlineno;			/* = current line number */
int maclevel;			/* current macro nesting level */
int lnsave;			/* 1: strcpy() text of current line */
int totlines;			/* total # of lines */
char lnbuf[LNSIZ];		/* text of current line */
char lntag;			/* line tag */
char irbuf[LNSIZ];		/* text for .rept block line */

INOBJ *cur_inobj;		/* -> current input object (IFILE or IMACRO) */
static INOBJ *f_inobj;		/* -> list of free INOBJs */
static IFILE *f_ifile;		/* -> list of free IFILEs */
static IMACRO *f_imacro;	/* -> list of free IMACROs */

static TOKEN tokbuf[TOKBUFSIZE]; /* token buffer (stack-like, for all files) */


/*
 *  File record
 *  (used to maintain a list of every
 *  include file ever visited).
 */
#define FILEREC struct _filerec
FILEREC {
	FILEREC *frec_next;
	char *frec_name;
};

FILEREC *filerec;
FILEREC *last_fr;


/* -------------------------------- */


/*
 *  Initialize tokenizer
 */
itoken()
{
	register int i;
	char *htab = "0123456789abcdefABCDEF";

	lnsave = 0;			/* don't save lines */
	curfname = "";		/* no file, empty filename */
	filecount = -1;
	cfileno = -1;			/* cfileno gets bumped to 0 */
	curlineno = 0;
	totlines = 0;
	etok = tokbuf;
	f_inobj = NULL;
	f_ifile = NULL;
	f_imacro = NULL;
	cur_inobj = NULL;
	filerec = NULL;
	last_fr = NULL;
	lntag = SPACE;


	/*
	 * Initialize hex, "dot" and tolower tables
	 */
	for (i = 0; i < 128; ++i)
	{
		hextab[i] = -1;
		dotxtab[i] = 0;
		tolowertab[i] = i;
	}
	for (i = 0; htab[i] != EOS; ++i)
		hextab[htab[i]] = (i < 16) ? i : i - 6;

	for (i = 'A'; i <= 'Z'; ++i)
		tolowertab[i] |= 0x20;

	/*
	 *  These characters are legal
	 *  immediately after a period.
	 */
	dotxtab['b'] = DOTB;		/* .b .B .s .S */
	dotxtab['B'] = DOTB;
	dotxtab['s'] = DOTB;
	dotxtab['S'] = DOTB;
	dotxtab['w'] = DOTW;		/* .w .W */
	dotxtab['W'] = DOTW;
	dotxtab['l'] = DOTL;		/* .l .L */
	dotxtab['L'] = DOTL;
}


/*
 *  Allocate an IFILE or IMACRO
 *
 */
INOBJ *a_inobj(typ)
int typ;
{
	register INOBJ *inobj;
	register IFILE *ifile;
	register IMACRO *imacro;

	/*
	 *  Allocate and initialize INOBJ first
	 */
	if (f_inobj == NULL)
		inobj = (INOBJ *)amem((LONG)sizeof(INOBJ));
	else
	{
		inobj = f_inobj;
		f_inobj = f_inobj->in_link;
	}

	switch (typ)
	{
		case SRC_IFILE:		/* alloc and init an IFILE */
			if (f_ifile == NULL)
				ifile = (IFILE *)amem((LONG)sizeof(IFILE));
			else
			{
				ifile = f_ifile;
				f_ifile = f_ifile->if_link;
			}
			inobj->inobj.ifile = ifile;
			break;

		case SRC_IMACRO:		/* alloc and init an IMACRO */
			if (f_imacro == NULL)
				imacro = (IMACRO *)amem((LONG)sizeof(IMACRO));
			else
			{
				imacro = f_imacro;
				f_imacro = f_imacro->im_link;
			}
			inobj->inobj.imacro = imacro;
			break;

		case SRC_IREPT:		/* alloc and init an IREPT */
			inobj->inobj.irept = (IREPT *)malloc((LONG)sizeof(IREPT));
#ifdef DO_DEBUG
			DEBUG printf("alloc IREPT\n");
#endif
			break;
	}

	/*
	 *  Install INOBJ on top of input stack
	 */
	inobj->in_ifent = ifent;	/* record .if context on entry */
	inobj->in_type = typ;
	inobj->in_otok = tok;
	inobj->in_etok = etok;
	inobj->in_link = cur_inobj;
	cur_inobj = inobj;

	return inobj;
}


/*
 *  Arrange to include a source file
 *  (used at the root, and for ".include" files)
 */
include(handle, fname)
int handle;
char *fname;
{
	register IFILE *ifile;
	register INOBJ *inobj;
	register FILEREC *fr;
	char *nstring();

	/*
	 *  Say hello to daddy
	 */
	if (verb_flag)
		printf("[Including: %s]\n", fname);

	/*
	 *  Alloc and initialize include-descriptors
	 */
	inobj = a_inobj(SRC_IFILE);
	ifile = inobj->inobj.ifile;

	ifile->ifhandle = handle;	/* setup file handle */
	ifile->ifind = ifile->ifcnt = 0; /* setup buffer indices */
	ifile->ifoldlineno = curlineno; /* save old line number*/
	ifile->ifoldfname = curfname; /* save old filename */
	ifile->ifno = cfileno;	/* save old file number */
	cfileno = ++filecount;	/* compute new file number */
	curfname = nstring(fname);	/* set current filename (alloc storage) */
	curlineno = 0;		/* start on line zero */

	/*
	 *  Add another file to the file-record
	 */
	fr = (FILEREC *)amem((LONG)sizeof(FILEREC));
	fr->frec_next = NULL;
	fr->frec_name = curfname;
	if (last_fr == NULL)
		filerec = fr;		/* add first filerec */
	else
		last_fr->frec_next = fr;	/* append to list of filerecs */
	last_fr = fr;

	return OK;
}


/*
 *  Pop the current input level
 *
 */
fpop()
{
	register INOBJ *inobj;
	register IFILE *ifile;
	register IMACRO *imacro;
	register LONG *p, *p1;

	inobj = cur_inobj;
	if (inobj != NULL)
	{
		/*
		 *  Pop IFENT levels until we reach the conditional
		 *  assembly context we were at when the input object
		 *  was entered.
		 */
		while (ifent != inobj->in_ifent)
			d_endif();

		tok = inobj->in_otok;	/* restore tok and otok */
		etok = inobj->in_etok;

		switch (inobj->in_type)
		{
			case SRC_IFILE:		/* pop and release an IFILE */
				if (verb_flag)
					printf("[Leaving: %s]\n", curfname);
				ifile = inobj->inobj.ifile;
				ifile->if_link = f_ifile;
				f_ifile = ifile;
				close(ifile->ifhandle); /* close source file */
				curfname = ifile->ifoldfname;	/* set current filename */
				curlineno = ifile->ifoldlineno; /* set current line# */
#ifdef DO_DEBUG
				DEBUG printf("cfileno=%d ifile->ifno=%d\n",
							 (int)cfileno, (int)ifile->ifno);
#endif
				cfileno = ifile->ifno; /* restore current file number */
				break;

			case SRC_IMACRO:	/* pop and release an IMACRO */
				imacro = inobj->inobj.imacro;
				imacro->im_link = f_imacro;
				f_imacro = imacro;
				break;

			case SRC_IREPT:		/* pop and release an IREPT */
#ifdef DO_DEBUG
				DEBUG printf("dealloc IREPT\n");
#endif
				p = inobj->inobj.irept->ir_firstln;
				while (p != NULL)
				{
					p1 = (LONG *)*p;
					free(p);
					p = p1;
				}
				free(inobj->inobj.irept);
				break;
		}

		cur_inobj = inobj->in_link;
		inobj->in_link = f_inobj;
		f_inobj = inobj;
	}
}


/*
 *  Make `fnum' the current `curfname'.  This
 *  is a linear search (which doesn't matter,
 *  since only error messages use it).
 *
 */
setfnum(fnum)
WORD fnum;
{
	register FILEREC *fr;

	for (fr = filerec; fr != NULL && fnum--; fr = fr->frec_next)
		;

	if (fr == NULL)
		curfname = "(*top*)";
	else
		curfname = fr->frec_name;
}


/* -------------------------------- */


/*
 *  Get line from file into buffer, return NULL on end of file
 *  or a pointer to the beginning of a null-terminated line.
 *
 */
char *getln()
{
	register IFILE *fl;
	register int i, j;
	register char *p, *d;
	int readamt;

	readamt = -1;			/* 0 if last read() yeilded 0 bytes */
	fl = cur_inobj->inobj.ifile;

	for (;;)
	{
		/*
		 * Scan for next end-of-line;
		 *  handle stupid text formats by treating \r\n the same as \n.
		 *  (lone '\r' at end of buffer means we have to check for '\n'.
		 */

		i = 0;
		j = fl->ifcnt;
		d = &fl->ifbuf[fl->ifind];

		for (p = d; i < j; ++i, ++p)
			if (*p == '\r' ||
				  *p == '\n')
			{
				++i;
				if (*p == '\r')
					if (i >= j)
						break;	/* look for '\n' to eat */
					else if (p[1] == '\n')
						++i;

				*p = '\0';

				fl->ifind += i;
				fl->ifcnt -= i;
				return d;
			}

		/*
		 * Handle hanging lines by ignoring them.
		 * (input file is exhausted, no \r or \n on last line)
		 */
		if (!readamt && fl->ifcnt)
		{
			fl->ifcnt = 0;
			*p = '\0';
			return NULL;
		}

		/*
		 * Truncate and return absurdly long lines.
		 */
		if (fl->ifcnt >= QUANTUM)
		{
			fl->ifbuf[fl->ifind + fl->ifcnt - 1] = '\0';
			fl->ifcnt = 0;
			return &fl->ifbuf[fl->ifind];
		}

		/*
		 * Relocate what's left of a line to the beginning
		 * of the buffer, and read some more of the file in;
		 * return NULL if the buffer's empty and on EOF.
		 */
		if (fl->ifind != 0)
		{
			p = &fl->ifbuf[fl->ifind];
			d = &fl->ifbuf[fl->ifcnt & 1];
			for (i = 0; i < fl->ifcnt; ++i)
				*d++ = *p++;
			fl->ifind = fl->ifcnt & 1;
		}

		if ((readamt = read(fl->ifhandle,
							&fl->ifbuf[fl->ifind + fl->ifcnt],
							QUANTUM)) < 0)
			return NULL;

		if ((fl->ifcnt += readamt) == 0)
			return NULL;
	}
}


/*
 *  Get next line of text from a macro
 *
 */
char *getmln()
{
	register IMACRO *imacro;
	register LONG *strp;

	imacro = cur_inobj->inobj.imacro;
	strp = imacro->im_nextln;

	if (strp == NULL)		/* end-of-macro */
		return NULL;

	imacro->im_nextln = (LONG *)*strp;
	mexpand((char *)(strp + 1), imacro->im_lnbuf, LNSIZ);

	return imacro->im_lnbuf;
}


/*
 *  Get next line of text from a repeat block
 *
 */
char *getrln()
{
	register IREPT *irept;
	register LONG *strp;

	irept = cur_inobj->inobj.irept;
	strp = irept->ir_nextln;

	/*
	 *  Do repeat at end of .rept block's string list
	 */
	if (strp == NULL)
	{
#ifdef DO_DEBUG
		DEBUG printf("back-to-top-of-repeat-block count=%d\n", irept->ir_count);
#endif
		irept->ir_nextln = irept->ir_firstln;
		if (irept->ir_count-- == 0)
		{
#ifdef DO_DEBUG
			DEBUG printf("end-repeat-block\n");
#endif
			return NULL;
		}
		strp = irept->ir_nextln;
	}
	strcpy(irbuf, (char*)irept->ir_nextln + 1);
#ifdef DO_DEBUG
	DEBUG printf("repeat line='%s'\n", irbuf);
#endif
	irept->ir_nextln = (LONG *)*strp;

	return irbuf;
}


/*
 *  Tokenize a line
 *   or return another line from a macro definition or repeat-block.
 *
 *  The register declaration order is important to performance
 *  on the VAX.  It's probably moot for a 68000 (this whole procedure
 *  needs to be written in native assembly anyway).
 *
 */
tokln()
{
	register char *ln;		/* ptr to current position in line */
	register char *p;		/* random character ptr */
	register TOKEN *tk;		/* token-deposit ptr */
	register int state;		/* state for keyword detector */
	register int j;		/* var for keyword detector */
	register char c;		/* random char */
	register VALUE v;		/* random value */
	char *nullspot;		/* spot to clobber for SYMBOL termination */
	int stuffnull;		/* 1, terminate SYMBOL '\0' at *nullspot */
	char c1;

retry:
	if (cur_inobj == NULL)	/* return EOF if input stack is empty */
		return TKEOF;

	/*
	 *  Get another line of input from the
	 *   current input source: a file, a macro,
	 *   or a repeat-block.
	 */
	switch (cur_inobj->in_type)
	{
		/*
		 *  Include-file:
		 *    o  handle EOF;
		 *    o  bump source line number;
		 *    o  tag the listing-line with a space;
		 *    o  kludge lines generated by Alcyon C.
		 */
		case SRC_IFILE:
			if ((ln = getln()) == NULL)
			{
				fpop();		/* pop input level*/
				goto retry;	/* try for more lines */
			}
			++curlineno;		/* bump line number */
			lntag = SPACE;
			if (as68_flag)
				/*
				 *  AS68 compatibility,
				 *   throw away all lines starting with back-quotes,
				 *   tildes, or asterisks.
				 *
				 *  On other lines, turn the first '*' into a semi-colon.
				 */
				if (*ln == '`' ||
					  *ln == '~' ||
					  *ln == '*') *ln = ';';
				else for (p = ln; *p != EOS; ++p)
					if (*p == '*') {
						*p = ';';
						break;
					}
			break;

			/*
			 *  Macro-block:
			 *    o  Handle end-of-macro;
			 *    o  tag the listing-line with an at (@) sign.
			 */
		case SRC_IMACRO:
			if ((ln = getmln()) == NULL)
			{
				exitmac();	/* exit macro (pop args, do fpop(), etc.) */
				goto retry;	/* try for more lines... */
			}
			lntag = '@';
			break;

			/*
			 *  Repeat-block:
			 *    o  Handle end-of-repeat-block;
			 *    o  tag the listing-line with a pound (#) sign.
			 */
		case SRC_IREPT:
			if ((ln = getrln()) == NULL)
			{
				fpop();
				goto retry;
			}
			lntag = '#';
			break;
	}

	/*
	 *  Save text of the line.  We only do this during listings
	 *   and within macro-type blocks, since it is expensive to
	 *   unconditionally copy every line.
	 */
	if (lnsave) strcpy(lnbuf, ln);

	/*
	 *  General house-keeping
	 */
	tok = tokeol;		/* set "tok" to EOL in case of error */
	tk = etok;			/* reset token ptr */
	stuffnull = 0;		/* don't stuff nulls */
	++totlines;			/* bump total #lines assembled */

	/*
	 *  See if the entire line is a comment.  This is a
	 *   win if the programmer puts in lots of comments.
	 */
	if (*ln == '*' || *ln == ';') goto goteol;


	/*
	 *  Main tokenization loop;
	 *    o  skip whitespace;
	 *    o  handle end-of-line;
	 *    o  handle symbols;
	 *    o  handle single-character tokens (operators, etc.);
	 *    o  handle multiple-character tokens (constants, strings, etc.).
	 */
	for (; *ln != EOS;)
	{
		/*
		 * Skip whitespace, handle EOL
		 */
		while (chrtab[*ln] & WHITE)
			++ln;

		if (*ln == EOS ||	/* handle EOL, comment with ';' */
			  *ln == ';')
			break;

		/*
		 *  Handle start of symbol.
		 *
		 *  Symbols are null-terminated in place.  The termination is
		 *   always one symbol behind, since there may be no place for
		 *   a null in the case that an operator immediately follows
		 *   the name.
		 *
		 */
		c = chrtab[*ln];
		if (c & STSYM)
		{
			if (stuffnull)	/* terminate old symbol */
				*nullspot = EOS;
			v = 0;		/* assume no DOT attribute follows symbol */
			stuffnull = 1;
			p = nullspot = ln++; /* nullspot -> start of this symbol */


			/*
			 *  Find end of symbol
			 *  (and compute its length)
			 */
			for (j = 1; chrtab[*ln] & CTSYM; ++j)
				++ln;

			/*
			 *  Handle "DOT" special forms (like ".b")
			 *  that follow a normal symbol or keyword:
			 */
			if (*ln == '.')
			{
				*ln++ = EOS;	/* terminate symbol*/
				stuffnull = 0;	/* and never try it again */

				/*
				 * Character following the `.' must have a DOT attribute,
				 * and the chararacter after THAT one must not have a
				 * start-symbol attribute (to prevent symbols that look
				 * like, for example, "zingo.barf", which might be a
				 * good idea anyway....)
				 *
				 */
				if (chrtab[*ln] & DOT == 0 ||
					  dotxtab[*ln] <= 0)
					return error("[bwsl] must follow `.' in symbol");
				v = (VALUE)dotxtab[*ln++];
				if (chrtab[*ln] & CTSYM)
					return error("misuse of `.', not allowed in symbols");
			}

			/*
			 *  If the symbol is small, check to see if
			 *  it's really the name of a register.
			 *
			 */
			if (j <= KWSIZE)
				for (state = 0; state >= 0;)
				{
					j = tolowertab[*p++];
					j += kwbase[state];
					if (kwcheck[j] != state)
					{
						j = -1;
						break;
					}

					if (*p == EOS || p == ln)
					{
						j = kwaccept[j];
						break;
					}

					state = kwtab[j];
				}
			else
				j = -1;

			if (j < 0 || state < 0)
			{
				*tk++ = SYMBOL;
				*tk++ = (TOKEN)nullspot;
			}
			else
			{
				*tk++ = (TOKEN)j;
				stuffnull = 0;
			}

			if (v)		/* record attribute token (if any) */	
				*tk++ = (TOKEN)v;

			if (stuffnull)	/* arrange for string termination */
				nullspot = ln;
			continue;
		}

		/*
		 * Handle identity tokens
		 */
		if (c & SELF)
		{
			*tk++ = *ln++;
			continue;
		}

		/*
		 * Handle multiple-character tokens
		 */
		if (c & MULT)
			switch (*ln++)
			{
				case '!':		/* ! or != */
					if (*ln == '=')
					{
						*tk++ = NE;
						++ln;
					} else *tk++ = '!';
					continue;

				case '\'':		/* 'string' */
				case '\"':		/* "string" */
					c1 = ln[-1];
					*tk++ = STRING;
					*tk++ = (TOKEN)ln;

					for (p = ln; *ln != EOS && *ln != c1;)
					{
						c = *ln++;
						if (c == '\\')
							switch (*ln++)
							{
								case EOS:
									return error("unterminated string");

								case 'e':
									c = '\033';
									break;

								case 'n':
									c = '\n';
									break;

								case 'b':
									c = '\b';
									break;

								case 't':
									c = '\t';
									break;

								case 'r':
									c = '\r';
									break;

								case 'f':
									c = '\f';
									break;

								case '\"':
									c = '\"';
									break;

								case '\'':
									c = '\'';
									break;

								case '\\':
									c = '\\';
									break;

								default:
									warn("bad backslash code in string");
									--ln;
									break;
							}
						*p++ = c;
					}

					if (*ln++ != c1)
						return error("unterminated string");
					*p++ = EOS;
					continue;

				case '$':		/* $, hex constant */
					if (chrtab[*ln] & HDIGIT)
					{
						v = 0;
						while (hextab[*ln] >= 0)
							v = (v << 4) + hextab[*ln++];
						*tk++ = CONST;
						*tk++ = v;
					}
					else *tk++ = '$';
					continue;

				case '<':		/* < or << or <> or <= */
					switch (*ln)
					{
						case '<':
							*tk++ = SHL;
							++ln;
							continue;

						case '>':
							*tk++ = NE;
							++ln;
							continue;

						case '=':
							*tk++ = LE;
							++ln;
							continue;

						default:
							*tk++ = '<';
							continue;
					}

				case ':':		/* : or :: */
					if (*ln == ':')
										   {
											   *tk++ = DCOLON;
											   ++ln;
										   } else *tk++ = ':';
					continue;

				case '=':		/* = or == */
					if (*ln == '=')
					{
						*tk++ = DEQUALS;
						++ln;
					} else *tk++ = '=';
					continue;

				case '>':		/* > or >> or >= */
					switch (*ln)
					{
						case '>':
							*tk++ = SHR;
							++ln;
							continue;

						case '=':
							*tk++ = GE;
							++ln;
							continue;

						default:
							*tk++ = '>';
							continue;
					}

				case '%':		/* % or binary constant */
					if (*ln < '0' ||
						  *ln > '1')
					{
						*tk++ = '%';
						continue;
					}
					v = 0;
					while (*ln >= '0' &&
						   *ln <= '1')
						v = (v << 1) + *ln++ - '0';
					*tk++ = CONST;
					*tk++ = v;
					continue;

				case '@':		/* @ or octal constant */
					if (*ln < '0' ||
						  *ln > '7')
					{
						*tk++ = '@';
						continue;
					}
					v = 0;
					while (*ln >= '0' &&
						   *ln <= '7')
						v = (v << 3) + *ln++ - '0';
					*tk++ = CONST;
					*tk++ = v;
					continue;

				case '^':		/* ^ or ^^ <operator-name> */
					if (*ln != '^')
					{
						*tk++ = '^';
						continue;
					}

					if ((chrtab[*++ln] & STSYM) == 0)
					{
						error("invalid symbol following ^^");
						continue;
					}

					p = ln++;
					while (chrtab[*ln] & CTSYM)
						++ln;

					for (state = 0; state >= 0;)
					{
						/* get char, convert to lowercase */
						j = *p++;
						if (j >= 'A' && j <= 'Z')
							j += 0x20;

						j += kwbase[state];
						if (kwcheck[j] != state)
						{
							j = -1;
							break;
						}

						if (*p == EOS || p == ln)
						{
							j = kwaccept[j];
							break;
						}
						state = kwtab[j];
					}

					if (j < 0 || state < 0)
					{
						error("unknown symbol following ^^");
						continue;
					}

					*tk++ = (TOKEN)j;
					continue;

				default:
					interror(2);	/* bad MULT entry in chrtab */
					continue;
			}

		/*
		 * Handle decimal constant
		 */
		if (c & DIGIT)
		{
			v = 0;
			while (chrtab[*ln] & DIGIT)
				v = (v * 10) + *ln++ - '0';
			*tk++ = CONST;
			*tk++ = v;
			continue;
		}

		/*
		 * Handle illegal character
		 */
		return error("illegal character");
	}

	/*
	 * Terminate line of tokens
	 * and return "success."
	 */
goteol:
	tok = etok;			/* set tok to beginning of line */
	if (stuffnull)		/* terminate last SYMBOL */
		*nullspot = EOS;
	*tk++ = EOL;

	return OK;
}



/*
 *  Names of registers
 */
static char *regname[] =
{
	"d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7",
	"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7",
	"pc", "ssp", "usp", "sr", "ccr"
};


/*
 *  Perform macro substitution from 'orig' to 'dest'.
 *  Return OK or some error.
 *
 *  A macro reference is in one of two forms:
 *	\name <non-name-character>
 *	\{name}
 *
 *  A doubled backslash (\\) is compressed to a single backslash (\).
 *
 *  Argument definitions have been pre-tokenized, so we have
 *  to turn them back into text.  This means that numbers, in
 *  particular, become hex, regardless of their representation
 *  when the macro was invoked.  This is a hack.
 *
 *  A label may appear at the beginning of the line:
 *
 *	:<name><whitespace>
 *
 *  (the colon must be in the first column).  These labels are stripped
 *  before macro expansion takes place.
 *
 */
mexpand(src, dest, destsiz)
char *src;
char *dest;
int destsiz;
{
	register char *s;
	register char *d;
	register char *dst;		/* -> next dest slot */
	char *edst;			/* -> end+1 of dest buffer */
	int i;
	int questmark;		/* \? for testing argument existence */
	TOKEN *tk;
	char mname[128];		/* assume maximum size of a formal arg name */
	int macnum;
	SYM *arg;
	IMACRO *imacro;
	char numbuf[20];		/* buffer for text of CONSTs */
	extern TOKEN **argp;		/* -> argument frame */
	extern LONG curuniq;		/* unique-per-macro-call number */
	SYM *lookup();

	imacro = cur_inobj->inobj.imacro;
	macnum = (int)(imacro->im_macro->sattr);

	--destsiz;
	dst = dest;
	edst = dest + destsiz;


	/*
	 *  Check for (and skip over) any "label" on the line
	 */
	s = src;
	if (*s == ':') {
		while (*s != EOS &&
			   !(chrtab[*s] & WHITE)) ++s;
		if (*s != EOS) ++s;	/* skip first whitespace */
	}

	/*
	 *  Expand the rest of the line
	 */
	while (*s != EOS)
		if (*s != '\\')
		{				/* copy single character */
			if (dst >= edst)
				goto overflow;
			*dst++ = *s++;
		}
		else
		{				/* do macro expansion */
			questmark = 0;

			/*
			 *  Do special cases
			 */
			switch (*++s)
			{
				case '\\':	/* \\, \ (collapse to single backslash) */
					if (dst >= edst)
						goto overflow;
					*dst++ = *s++;
					continue;

				case '?':	/* \? <macro>  set `questmark' flag */
					++s;
					questmark = 1;
					break;

				case '#':	/* \#, number of arguments */
					sprintf(numbuf, "%d", (int)imacro->im_nargs);
					goto copystr;

				case '!':	/* \!, size suffix supplied on invocation */
					switch ((int)imacro->im_siz)
					{
						case SIZN:
							d = "";
							break;

						case SIZB:
							d = ".b";
							break;

						case SIZW:
							d = ".w";
							break;

						case SIZL:
							d = ".l";
							break;
					}
					goto copy_d;

				case '~':		/* ==> unique label string Mnnnn... */
					sprintf(numbuf, "M%ld", curuniq);

copystr:
					d = numbuf;
copy_d:
					++s;
					while (*d != EOS)
						if (dst >= edst) goto overflow;
						else *dst++ = *d++;
					continue;

				case EOS:
					return error("missing argument name");
			}

			/*
			 * \n ==> argument number 'n', 0..9
			 *
			 */
			if (chrtab[*s] & DIGIT)
			{
				i = *s++ - '1';
				if (i < 0)
					i = 9;
				goto arg_num;
			}

			/*
			 *  Get argument name:
			 *	  \name
			 *    \{name}
			 *
			 */
			d = mname;
			if (*s != '{') {				/* \foo */
				do 
					*d++ = *s++;
				while (chrtab[*s] & CTSYM);
			} else {					/* \\{foo} */
				for (++s; *s != EOS && *s != '}';)
					*d++ = *s++;

				if (*s != '}') return error("missing '}'");
				else ++s;
			}
			*d = EOS;


			/*
			 *  Lookup the argument and copy its (string) value
			 *  into the destination string
			 */
#ifdef DO_DEBUG
			DEBUG printf("mname='%s'\n", mname);
#endif
			if ((arg = lookup(mname, MACARG, macnum)) == NULL)
				return errors("undefined argument: '%s'", mname);
			else
			{
				/*
				 *  Convert a string of tokens (terminated with EOL)
				 *  back into text.
				 *
				 *  If an argument is out of range (not specified in the
				 *  macro invocation) then it is ignored.
				 *
				 */
				i = (int)arg->svalue;
arg_num:
#ifdef DO_DEBUG
				DEBUG printf("~argnumber=%d\n", i);
#endif

				tk = NULL;
				if (i < imacro->im_nargs)
					tk = argp[i];

				/*
				 *  \?arg yields:
				 *    0  if the argument is empty or non-existant,
				 *    1  if the argument is not empty
				 */
				if (questmark)
				{
					if (tk == NULL ||
						  *tk == EOL)
						questmark = 0;
					if (dst >= edst)
						goto overflow;
					*dst++ = questmark + '0';
					continue;
				}

				if (tk != NULL)	/* arg# is in range, so expand it */
					while (*tk != EOL)
					{
						/*
						 *  Reverse-translation from a token number to
						 *  a string.  This is a hack.
						 *
						 *  It might be better table-driven.
						 */
						d = NULL;
						if (*tk >= KW_D0)
						{
							d = regname[(int)*tk++ - KW_D0];
							goto strcopy;
						}
						else switch ((int)*tk++)
						{
							case SYMBOL:
								d = (char *)*tk++;
								break;

							case STRING:
								d = (char *)*tk++;

								if (dst >= edst)
									goto overflow;
								*dst++ = '"';

								while (*d != EOS)
									if (dst >= edst)
										goto overflow;
									else *dst++ = *d++;

								if (dst >= edst)
									goto overflow;
								*dst++ = '"';
								continue;
								break;

							case CONST:
								sprintf(numbuf, "$%lx", (LONG)*tk++);
								d = numbuf;
								break;

							case DEQUALS:
								d = "==";
								break;

							case SET:
								d = "set";
								break;

							case COLON:
								d = ":";
								break;

							case DCOLON:
								d = "::";
								break;

							case GE:
								d = ">=";
								break;

							case LE:
								d = "<=";
								break;

							case NE:
								d = "<>";
								break;

							case SHR:
								d = ">>";
								break;

							case SHL:
								d = "<<";
								break;

							case DOTB:
								d = ".b";
								break;

							case DOTW:
								d = ".w";
								break;

							case DOTL:
								d = ".l";
								break;

							case CR_DATE:
								d = "^^date";
								break;

							case CR_TIME:
								d = "^^time";
								break;

							case CR_DEFINED:
								d = "^^defined ";
								break;

							case CR_REFERENCED:
								d = "^^referenced ";
								break;

							case CR_STREQ:
								d = "^^streq ";
								break;

							case CR_MACDEF:
								d = "^^macdef ";
								break;

							default:
								if (dst >= edst)
									goto overflow;
								*dst++ = (char)*(tk-1);
								break;
						}

						/*
						 *  If 'd' != NULL, copy string to destination
						 */
						if (d != NULL)
						{
strcopy:
#ifdef DO_DEBUG
							DEBUG printf("d='%s'\n", d);
#endif
							while (*d != EOS)
								if (dst >= edst)
									goto overflow;
								else *dst++ = *d++;
						}
					}
			}
		}

	*dst = EOS;
	return OK;

overflow:
	*dst = EOS;
	return fatal("line too long as a result of macro expansion");
}


/*
 *  .GOTO <label>	goto directive
 *
 *  The label is searched for starting from the first line of
 *  the current, enclosing macro definition.  If no enclosing
 *  macro exists, an error is generated.
 *
 *  A label is of the form:
 *
 *	:<name><whitespace>
 *
 *  The colon must appear in column 1.  The label is stripped prior
 *  to macro expansion, and is NOT subject to macro expansion.  The
 *  whitespace may also be EOL.
 *
 */
d_goto(siz)
WORD siz;
{
	char *sym;			/* -> label to search for */
	register LONG *defln;	/* -> macro definition strings */
	register char *s1;		/* temps for string comparison */
	register char *s2;
	IMACRO *imacro;		/* -> macro invocation block */

	/*
	 *  Setup for the search
	 */
	if (*tok != SYMBOL) return error("missing label");
	sym = (char *)tok[1];
	tok += 2;

	if (cur_inobj->in_type != SRC_IMACRO) return error("goto not in macro");
	imacro = cur_inobj->inobj.imacro;
	defln = (LONG *)imacro->im_macro->svalue;

	/*
	 *  Find the label, starting with the first line.
	 */
	for (; defln != NULL; defln = (LONG *)*defln)
		if (*(char *)(defln + 1) == ':') {
			/*
			 *  Compare names (sleazo string compare)
			 */
			s1 = sym;
			s2 = (char *)(defln + 1) + 1;
			while (*s1 == *s2)
				if (*s1 == EOS) break;
				else {
					++s1;
					++s2;
				}

			/*
			 *  Found the label,
			 *   set new macro next-line and return.
			 */
			if (*s2 == EOS || chrtab[*s2] & WHITE) {
				imacro->im_nextln = defln;
				return;
			}
		}

	return error("goto label not found");
}
