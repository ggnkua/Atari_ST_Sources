/*
 *  Code Generation, Fixups and Section Management
 *
 *	isect()			initialize sections
 *	mksect(sno,attr)	make a section
 *	savsect()		save current section
 *	switchsect(sno)		switch to another section
 *	chcheck(amt)		ensure space in current code chunk
 *	fixup(attr,loc,expr)	arrange fixup for later
 *
 */
#include "as.h"
#include "sect.h"


/*
 *  Imports
 */
extern int debug;		/* 1, enable debugging messages */
extern WORD cfileno;		/* = current file# */
extern int curlineno;		/* = current line# */
extern int sbra_flag;		/* 1, checking for short branches */
extern int obj_format;		/* object file format */
extern int m6502;		/* 1, assembler in .6502 mode */
extern char *undef_error;	/* -> error message */


/*
 *  Tunable (storage) definitions
 */
#define CH_THRESHOLD	16	/* minimum amount of space in code chunk */
#define	CH_CODE_SIZE	2048	/* code chunk normal allocation */
#define	CH_FIXUP_SIZE	1024	/* fixup chunk normal allocation */


/*
 *  Section descriptors
 *
 */
SECT sect[NSECTS];		/* all sections... */
int cursect;			/* current section number */

/*
 *  These are copied from the section descriptor,
 *  the current code chunk descriptor and the current
 *  fixup chunk descriptor when a switch is made
 *  into a section.
 *
 *  They are copied back to the descriptors when the
 *  section is left.
 *
 */
WORD scattr;			/* section attributes */
LONG sloc;			/* current loc in section */

CHUNK *scode;			/* -> current (last) code chunk */
LONG challoc;			/* = #bytes alloc'd to code chunk */
LONG chsize;			/* = #bytes used in code chunk */
char *chptr;			/* -> deposit point in code chunk buffer */

CHUNK *sfix;			/* -> current (last) fixup chunk */
LONG fchalloc;			/* = #bytes alloc'd to fixup chunk */
LONG fchsize;			/* = #bytes used in fixup chunk */
PTR fchptr;			/* -> deposit point in fixup chunk buffer */



/*
 *  Initialize sections;
 *  setup initial abs, text, data and bss sections.
 *
 */
isect()
{
	register int i;
	SECT *p;

	/*
	 *  Cleanup all sections
	 */
	for (i = 0; i < NSECTS; ++i)
		mksect(i, 0);

	/*
	 *  Construct default sections,
	 *  make TEXT the current section.
	 */
	mksect(ABS, SUSED|SABS|SBSS);	/* ABS */
	mksect(TEXT, SUSED|TEXT);	/* TEXT */
	mksect(DATA, SUSED|DATA);	/* DATA */
	mksect(BSS, SUSED|BSS|SBSS);	/* BSS */
	mksect(M6502, SUSED|TEXT);	/* 6502 code section */

	switchsect(TEXT);		/* switch to TEXT for starters */
}


/*
 *  Make a new (clean) section
 *
 */
mksect(sno, attr)
int sno;			/* section# */
WORD attr;			/* attributes for it */
{
	register SECT *p;

	p = &sect[sno];
	p->scattr = attr;
	p->sloc = 0;
	p->scode = p->sfcode = NULL;
	p->sfix = p->sffix = NULL;
}


/*
 *  Switch to another section
 *  (copy section and chunk descriptors to global
 *   vars for fast access)
 *
 */
switchsect(sno)
int sno;
{
	register SECT *p;
	register CHUNK *cp;

	m6502 = (sno == M6502);	/* set 6502-mode */

	cursect = sno;
	p = &sect[sno];

	scattr = p->scattr;		/* copy section vars */
	sloc = p->sloc;
	scode = p->scode;
	sfix = p->sfix;

	if ((cp = scode) != NULL)	/* copy code chunk vars */
	{
		challoc = cp->challoc;
		chsize = cp->chsize;
		chptr = cp->chptr + chsize;
	}
	else challoc = chsize = 0;

	if ((cp = sfix) != NULL)	/* copy fixup chunk vars */
	{
		fchalloc = cp->challoc;
		fchsize = cp->chsize;
		fchptr.cp = cp->chptr + fchsize;
	}
	else fchalloc = fchsize = 0;
}


/*
 *  Save current section
 *  (copy global vars to section and chunk descriptors
 *   for safe-keeping)
 *
 */
savsect()
{
	register SECT *p;
	register CHUNK *cp;

	p = &sect[cursect];

	p->scattr = scattr;		/* bailout section vars */
	p->sloc = sloc;

	if (scode != NULL)		/* bailout code chunk */
		scode->chsize = chsize;

	if (sfix != NULL)		/* bailout fixup chunk */
		sfix->chsize = fchsize;
}


/*
 *  Check that there are at least `amt' bytes left in
 *  the current chunk.  If there are not, allocate another
 *  chunk of at least `amt' bytes (and probably more).
 *
 *  If `amt' is zero, ensure there are at least CH_THRESHOLD
 *  bytes, likewise.
 *
 */
chcheck(amt)
register LONG amt;
{
	register CHUNK *cp;
	register SECT *p;

	if (scattr & SBSS) return;	/* if in BSS section, forget it */

	if (!amt) amt = CH_THRESHOLD;

	if (challoc - chsize >= amt) return;

	if (amt < CH_CODE_SIZE) amt = CH_CODE_SIZE;
	p = &sect[cursect];
	cp = (CHUNK *)amem((long)(sizeof(CHUNK) + amt));

	if (scode == NULL)
	{				/* first chunk in section */
		cp->chprev = NULL;
		p->sfcode = cp;
	}
	else
	{				/* add chunk to other chunks */
		cp->chprev = scode;
		scode->chnext = cp;
		scode->chsize = chsize;	/* save old chunk's globals */
	}

	/*
	 *  Setup chunk and global vars
	 */
	cp->chloc = sloc;
	cp->chnext = NULL;
	challoc = cp->challoc = amt;
	chsize = cp->chsize = 0;
	chptr = cp->chptr = ((char *)cp) + sizeof(CHUNK);
	scode = p->scode = cp;
}


/*
 *  Arrange for a fixup on a location
 *
 */
fixup(attr, loc, fexpr)
WORD attr;
LONG loc;
TOKEN *fexpr;
{
	register LONG i;
	register LONG len;
	register CHUNK *cp;
	register SECT *p;

	/*
	 *  Compute length of expression (could be faster);
	 *  determine if it's the single-symbol case;
	 *  no expression if it's just a mark.
	 *
	 *  This code assumes 16 bit WORDs and 32 bit LONGs
	 */
	if (*fexpr == SYMBOL &&
		  fexpr[2] == ENDEXPR)
		i = 14;			/* just a single symbol */
	else
	{
		attr |= FU_EXPR;
		for (len = 0; fexpr[len] != ENDEXPR; ++len)
			if (fexpr[len] == CONST ||
				  fexpr[len] == SYMBOL)
				++len;
		++len;			/* add 1 for ENDEXPR */
		i = (len << 2) + 12;
	}

	/*
	 *  Maybe alloc another fixup chunk
	 *  for this one to fit in
	 */
	if (fchalloc - fchsize < i)
	{
		p = &sect[cursect];
		cp = (CHUNK *)amem((long)(sizeof(CHUNK) + CH_FIXUP_SIZE));

		if (sfix == NULL)
		{			/* first fixup chunk in section */
			cp->chprev = NULL;
			p->sffix = cp;
		}
		else
		{			/* add to other chunks */
			cp->chprev = sfix;
			sfix->chnext = cp;
			sfix->chsize = fchsize;
		}

		/*
		 *  Setup fixup chunk and its global vars
		 */
		cp->chnext = NULL;
		fchalloc = cp->challoc = CH_FIXUP_SIZE;
		fchsize = cp->chsize = 0;
		fchptr.cp = cp->chptr = ((char *)cp) + sizeof(CHUNK);
		sfix = p->sfix = cp;
	}

	/*
	 *  Record fixup type, fixup location, and the
	 *  file number and line number the fixup is
	 *  located at.
	 */
	*fchptr.wp++ = attr;
	*fchptr.lp++ = loc;
	*fchptr.wp++ = cfileno;
	*fchptr.wp++ = (WORD)curlineno;

	/*
	 *  Store postfix expression or
	 *  pointer to a single symbol,
	 *  or nothing for a mark.
	 */
	if (attr & FU_EXPR)
	{
		*fchptr.wp++ = len;
		while (len--)
			*fchptr.lp++ = (LONG)*fexpr++;
	}
	else *fchptr.lp++ = (LONG)fexpr[1];

	fchsize += i;
}


/*
 *  Resolve all fixups
 *
 */
fixups()
{
	register int i;
	extern int glob_flag;

	if (glob_flag)		/* make undefined symbols GLOBL */
		syg_fix();

	resfix(TEXT);
	resfix(DATA);
	resfix(M6502);		/* fixup 6502 section (if any) */
}


/*
 *  Resolve fixups in a section
 *
 */
resfix(sno)
int sno;			/* = section# */
{
	SECT *sc;			/* -> section */
	CHUNK *ch;
	register PTR fup;		/* -> current fixup */
	register WORD *fuend;	/* -> end of last fixup (in this chunk) */
	CHUNK *cch;			/* cached chunk for target */
	register WORD w;		/* fixup word (type+modes+flags) */
	register char *locp;	/* -> location to fix (in cached chunk) */
	LONG loc;			/* location to fixup */
	VALUE eval;			/* expression value */
	WORD eattr;			/* expression attrib */
	SYM *esym;			/* external symbol involved in expression */
	SYM *sy;			/* (temp) pointer to a symbol */
	WORD i;			/* (temp) word */
	WORD tdb;			/* eattr & TDB */


	sc = &sect[sno];
	ch = sc->sffix;

	if (ch == NULL)
		return;

	cch = sc->sfcode;		/* "cache" first chunk */
	if (cch == NULL)		/* can't fixup a section with nothing in it */
		return;

	/*
	 *  Wire the 6502 segment's size to its allocated size (64K)
	 */
	if (sno == M6502)
		cch->chsize = cch->challoc;

	do
	{
		fup.cp = ch->chptr;	/* fup -> start of chunk */
		fuend = (WORD *)(fup.cp + ch->chsize); /* fuend -> end of chunk */

		while (fup.wp < fuend)
		{
			w = *fup.wp++;
			loc = *fup.lp++;
			cfileno = *fup.wp++;
			curlineno = (int)*fup.wp++;
			esym = NULL;

			/*
			 *  Search for chunk containing location to fix up;
			 *  compute a pointer to the location (in the chunk).
			 *
			 *  Often we will find the fixup is in the "cached" chunk,
			 *  so the linear-search is seldom executed.
			 *
			 */
			if (loc < cch->chloc ||
				  loc >= (cch->chloc + cch->chsize))
			{
				for (cch = sc->sfcode; cch != NULL; cch = cch->chnext)
					if (loc >= cch->chloc &&
						  loc < (cch->chloc + cch->chsize))
						break;
				if (cch == NULL)
				{
					interror(7); /* fixup (loc) out of range */
					/*NOTREACHED*/
				}
			}
			locp = cch->chptr + (loc - cch->chloc);


			/*
			 *  Compute expression/symbol value and attribs
			 */
			if (w & FU_EXPR)
			{			/* complex expression */
				i = *fup.wp++;
				if (evexpr(fup.tk, &eval, &eattr, &esym) != OK)
				{
					fup.lp += i;
					continue;
				}
				fup.lp += i;
			}
			else
			{			/* simple symbol */
				sy = *fup.sy++;
				eattr = sy->sattr;
				if (eattr & DEFINED)
					eval = sy->svalue;
				else eval = 0;

				if ((eattr & (GLOBAL|DEFINED)) == GLOBAL)
					esym = sy;
			}
			tdb = eattr & TDB;


			/*
			 *  If the expression is undefined and
			 *  no external symbol is involved, then
			 *  it's an error.
			 */
			if (!(eattr & DEFINED) &&
				  esym == NULL)
			{
				error(undef_error);
				continue;
			}


			/*
			 *  Do the fixup
			 *
			 *  If a PC-relative fixup is undefined, its
			 *  value is *not* subtracted from the location
			 *  (that will happen in the linker when the
			 *  external reference is resolved).
			 *
			 *  MWC expects PC-relative things to have the LOC
			 *  subtracted from the value, if the value is external
			 *  (that is, undefined at this point).
			 *
			 *  PC-relative fixups must be DEFINED and either
			 *  in the same section (whereupon the subtraction
			 *  takes place) or ABS (with no subtract).
			 *
			 */
			if (w & FU_PCREL) {
				if (eattr & DEFINED) {
					if (tdb == sno) eval -= (VALUE)loc;
					else if (tdb) {
						error("PC-relative expr across sections");
						continue;
					}

					if (sbra_flag &&
						  (w & FU_LBRA) &&
						  (eval + 0x80 < 0x100))
						warn("unoptimized short branch");
				} else if (obj_format == MWC) eval -= (VALUE)loc;

				tdb = 0;
				eattr &= ~TDB;
			}

			/*
			 *  Do fixup classes
			 */
			switch ((int)(w & FUMASK))
			{
				/*
				 *  FU_BBRA fixes up a one-byte branch offset.
				 */
				case FU_BBRA:
					if (!(eattr & DEFINED))
					{
						error("external short branch");
						continue;
					}

					eval -= 2;
					if (eval + 0x80 >= 0x100)
						goto range;
					if (eval == 0)
					{
						error("illegal bra.s with zero offset");
						continue;
					}
					*++locp = (char)eval;
					break;

					/*
					 *  Fixup one-byte value at locp + 1.
					 */
				case FU_WBYTE:
					++locp;
					/*FALLTHROUGH*/

					/*
					 *  Fixup one-byte forward references
					 */
				case FU_BYTE:
					if (!(eattr & DEFINED)) {
						error("external byte reference");
						continue;
					}

					if (tdb) {
						error("non-absolute byte reference");
						continue;
					}

					if ((w & FU_PCREL) && eval + 0x80 >= 0x100) goto range;

					if (w & FU_SEXT) {
						if (eval + 0x100 >= 0x200) goto range;
					} else if (eval >= 0x100) goto range;

					*locp = (char)eval;
					break;


					/*
					 *  Fixup WORD forward references;
					 *  the word could be unaligned in the section
					 *  buffer, so we have to be careful.
					 */
				case FU_WORD:
					if (!(eattr & DEFINED))
					{
						if (w & FU_PCREL)
							w = MPCREL | MWORD;
						else w = MWORD;
						rmark(sno, loc, 0, w, esym);
					}
					else
					{
						if (tdb)
							rmark(sno, loc, tdb, MWORD, NULL);
						if (w & FU_SEXT)
						{
							if (eval + 0x10000 >= 0x20000)
								goto range;
						}
						else if (w & FU_ISBRA)	/* range-check BRA and DBRA */
						{
							if (eval + 0x8000 >= 0x10000)
								goto range;
						}
						else if (eval >= 0x10000)
							goto range;
					}

					if (sno != M6502)
					{
						*locp++ = (char)(eval >> 8);
						*locp = (char)eval;
					}
					else
					{
						*locp++ = (char)eval;
						*locp = (char)(eval >> 8);
					}
					break;


					/*
					 *  Fixup LONG forward references;
					 *  the long could be unaligned in the section
					 *  buffer, so be careful (again).
					 */
				case FU_LONG:
					if (!(eattr & DEFINED))
						rmark(sno, loc, 0, MLONG, esym);
					else if (tdb)
						rmark(sno, loc, tdb, MLONG, NULL);
					*locp++ = (char)(eval >> 24);
					*locp++ = (char)(eval >> 16);
					*locp++ = (char)(eval >> 8);
					*locp = (char)eval;
					break;


					/*
					 *  Fixup a 3-bit "QUICK" reference in bits 9..1
					 *  (range of 1..8) in a word.  Really bits 1..3
					 *  in a byte.
					 */
				case FU_QUICK:
					if (!(eattr & DEFINED))
					{
						error("External quick reference");
						continue;
					}

					if (eval < 1 || eval > 8)
						goto range;
					*locp |= (eval & 7) << 1;
					break;

					/*
					 *  Fix up 6502 funny branch
					 */
				case FU_6BRA:
					eval -= (loc + 1);
					if (eval + 0x80 >= 0x100)
						goto range;
					*locp = (char)eval;
					break;

				default:
					interror(4); /* bad fixup type */
					/*NOTREACHED*/
			}
			continue;
range:
			error("expression out of range");
		}

		ch = ch->chnext;
	} while (ch != NULL);
}


/*
 *  Return a size (SIZB, SIZW, SIZL) or 0,
 *  depending on what kind of fixup is associated
 *  with a location.
 *
 */
static char fusiztab[] =
{
	0,				/* FU_QUICK */
	1,				/* FU_BYTE */
	2,				/* FU_WORD */
	2,				/* FU_WBYTE */
	4,				/* FU_LONG */
	1,				/* FU_BBRA */
	0,				/* (unused) */
	1,				/* FU_6BRA */
};

/* offset to REAL fixup location */
static char fusizoffs[] =
{
	0,				/* FU_QUICK */
	0,				/* FU_BYTE */
	0,				/* FU_WORD */
	1,				/* FU_WBYTE */
	0,				/* FU_LONG */
	1,				/* FU_BBRA */
	0,				/* (unused) */
	0,				/* FU_6BRA */
};


/*
 *  Test to see if a location has a fixup
 *   sic'd on it.  This is used by the listing
 *   generator to print 'xx's instead of '00's
 *   for forward references
 */
int fixtest(sno, loc)
int sno;
LONG loc;
{
	register CHUNK *ch;
	register PTR fup;
	register char *fuend;
	register WORD w;
	register LONG xloc;

	stopmark();			/* force update to sect[] variables */

	/*
	 *  Hairy, ugly linear search for a mark on our location;
	 *  the speed doesn't matter, since this is only done when
	 *  generating a listing, which is SLOW....
	 */
	for (ch = sect[sno].sffix; ch != NULL; ch = ch->chnext)
	{
		fup.cp = (char *)ch->chptr;
		fuend = fup.cp + ch->chsize;

		while (fup.cp < fuend)
		{
			w = *fup.wp++;
			xloc = *fup.lp++ + (int)fusizoffs[w & FUMASK];
			fup.wp += 2;

			if (xloc == loc)
				return (int)fusiztab[w & FUMASK];

			if (w & FU_EXPR)
			{
				w = *fup.wp++;
				fup.lp += w;
			}
			else ++fup.lp;
		}
	}

	return 0;
}
