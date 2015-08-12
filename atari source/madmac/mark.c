/*
 *  Marks
 *   A record of things that are defined relative to
 *   any of the sections....
 *
 */
#include "as.h"
#include "sect.h"


#define	MARK_ALLOC_INCR	1024	/* #bytes to alloc for more mark space */
#define	MIN_MARK_MEM	(3*sizeof(WORD)+2*sizeof(LONG))


/*
 *  Imports
 */
extern int prg_flag;		/* 1, write ".PRG" relocatable executable */


MCHUNK *firstmch;		/* -> first mark chunk */
MCHUNK *curmch;			/* -> current mark chunk */
PTR markptr;			/* -> deposit point in current mark chunk */
LONG mcalloc;			/* = #bytes alloc'd to current mark chunk */
LONG mcused;			/* = #bytes used in current mark chunk */
WORD curfrom;			/* = current "from" section */


/*
 *  Initialize marker
 *
 */
imark()
{
	firstmch = curmch = NULL;
	mcalloc = mcused = 0;
	curfrom = 0;
}


/*
 *  Wrap up marker
 *  (called after final mark is made)
 *
 */
stopmark()
{
	if (curmch)
	{
		*markptr.wp = MCHEND;	/* mark end of block */
		curmch->mcused = mcused;	/* update #used in mark block */
	}
}


/*
 *  Mark a word or longword relocatable.
 *
 */
rmark(from, loc, to, size, symbol)
int from;
LONG loc;
int to;
int size;
SYM *symbol;		/* NULL, or ->symbol */
{
	register WORD w;

	if ((mcalloc - mcused) < MIN_MARK_MEM)
		amark();

	w = size | to;
	if (from != curfrom)
		w |= MCHFROM;
	if (symbol != NULL)
		w |= MSYMBOL;

	/*
	 *  Complain about some things are not allowed in `-p' mode:
	 *    o marks that aren't to LONGs;
	 *    o external references.
	 */
	if (prg_flag)
	{
		if ((w & MLONG) == 0)
			error("illegal word relocatable (in .PRG mode)");
		if (symbol != NULL)
			errors("illegal external reference (in .PRG mode) to '%s'",
				   symbol->sname);
	}

	mcused += sizeof(WORD) + sizeof(LONG);
	*markptr.wp++ = w;
	*markptr.lp++ = loc;

	if (w & MCHFROM)
	{
		*markptr.wp++ = from;
		curfrom = from;
		mcused += sizeof(WORD);
	}

	if (w & MSYMBOL)
	{
		*markptr.sy++ = symbol;
		mcused += sizeof(LONG);
	}
}


/*
 *  Allocate another chunk of mark space
 *
 */
amark()
{
	register MCHUNK *p;

	/*
	 *  Alloc mark block header (and data) and set it up.
	 */
	p = (MCHUNK *)amem((long)(sizeof(MCHUNK)) + MARK_ALLOC_INCR);
	p->mcnext = NULL;
	p->mcalloc = MARK_ALLOC_INCR;
	p->mcptr.cp = (char *)(((char *)p) + sizeof(MCHUNK));

	if (curmch)
	{				/* link onto previous chunk */
		*markptr.wp++ = MCHEND; /* mark end of block */
		curmch->mcused = mcused;
		curmch->mcnext = p;
	}
	if (!firstmch)
		firstmch = p;

	curmch = p;			/* setup global vars */
	markptr = p->mcptr;
	mcalloc = MARK_ALLOC_INCR;
	mcused = 0;
}


/*
 *  Table to convert from TDB to fixup triad
 *
 */
static char mark_tr[] = {
	0,				/* (n/a) */
	2,				/* TEXT relocatable */
	1, 0,				/* DATA relocatable */
	3				/* BSS relocatable */
};


/*
 *  Make mark image for Alcyon .o file
 *
 */
LONG markimg(mp, siz, tsize, okflag)
register char *mp;
LONG siz;
LONG tsize;
int okflag;		/* 1, ok to deposit reloc information */
{
	MCHUNK *mch;			/* -> mark chunk */
	register PTR p;		/* source point from within mark chunk */
	WORD from;			/* section fixups are currently FROM */
	register WORD w;		/* a word (temp) */
	LONG loc;			/* location (temp) */
	LONG lastloc;			/* last location fixed up (RELMOD) */
	SYM *symbol;			/* -> symbols (temp) */
	char *wp;			/* pointer into raw relocation information */
	register char *dp;		/* deposit point for RELMOD information */
	int firstp;			/* 1, first relocation (RELMOD) */
	LONG diff;			/* difference to relocate (RELMOD) */

	if (okflag)
		clear(mp, siz);		/* zero relocation buffer */

	from = 0;
	for (mch = firstmch; mch != NULL; mch = mch->mcnext)
		for (p = mch->mcptr;;)
		{
			w = *p.wp++;		/* w = next mark entry */
			if (w & MCHEND)		/* (end of mark chunk) */
				break;

			/*
			 *  Get mark record
			 */
			symbol = NULL;
			loc = *p.lp++;		/* mark location */
			if (w & MCHFROM)	/* maybe change "from" section */
				from = *p.wp++;
			if (w & MSYMBOL)	/* maybe includes a symbol */
				symbol = *p.sy++;

			/*
			 *  Compute mark position in relocation information;
			 *  in RELMOD mode, get address of data to fix up.
			 */
			if (from == DATA)
				loc += tsize;
			wp = (char *)(mp + loc);

			if (okflag && (w & MLONG)) /* indicate first word of long */
			{
				wp[1] = 5;
				wp += 2;
			}

			if (symbol)
			{
				/*
				 *  Deposit external reference
				 */
				if (okflag)
				{
					if (w & MPCREL)
						w = 6;		/* pc-relative fixup */
					else w = 4;		/* absolute fixup */
					w |= symbol->senv << 3;
					*wp++ = w >> 8;
					*wp = w;
				}
			}
			else
			{
				/*
				 *  Deposit section-relative mark;
				 *  in RELMOD mode, fix it up in the chunk,
				 *  kind of like a sleazoid linker.
				 *
				 *  In RELMOD mode, marks to words (MWORDs) "cannot happen,"
				 *  checks are made when mark() is called, so we don't have
				 *  to check again here.
				 */
				w &= TDB;
				if (okflag)
					wp[1] = mark_tr[w];
				else if (prg_flag && (w & (DATA|BSS)))
				{
					dp = wp;
					diff = ((LONG)(*dp++ & 0xff)) << 24;
					diff |= ((LONG)(*dp++ & 0xff)) << 16;
					diff |= ((LONG)(*dp++ & 0xff)) << 8;
					diff |= (LONG)(*dp & 0xff);

#ifdef DO_DEBUG
					DEBUG printf("diff=%lx ==> ", diff);
#endif
					diff += sect[TEXT].sloc;
					if (w == BSS)
						diff += sect[DATA].sloc;

					dp = wp;
					*dp++ = (char)(diff >> 24);
					*dp++ = (char)(diff >> 16);
					*dp++ = (char)(diff >> 8);
					*dp = (char)diff;
#ifdef DO_DEBUG
					DEBUG printf("%lx\n", diff);
#endif
				}
			}
		}

	/*
	 *  Generate ".PRG" relocation information in place in
	 *  the relocation words (the ``RELMOD'' operation).
	 */
	if (okflag && prg_flag)
	{
		firstp = 1;
		wp = mp;
		dp = mp;
		for (loc = 0; loc < siz;)
			if ((wp[1] & 7) == 5)
			{
				if (firstp)
				{
					*dp++ = (char)(loc >> 24);
					*dp++ = (char)(loc >> 16);
					*dp++ = (char)(loc >> 8);
					*dp++ = (char)loc;
					firstp = 0;
				}
				else
				{
					for (diff = loc - lastloc; diff > 254; diff -= 254)
						*dp++ = 1;
					*dp++ = (char)diff;
				}
				wp += 4;
				lastloc = loc;
				loc += 4;
			}
			else 
			{
				loc += 2;
				wp += 2;
			}

		/*
		 *  Terminate relocation list with 0L (if there was no
		 *  relocation) or 0.B (if relocation information was
		 *  written).
		 */
		if (!firstp)
			*dp++ = 0;
		else for (firstp = 0; firstp < 4; ++firstp)
			*dp++ = 0;

		/*
		 *  Return size of relocation information
		 */
		loc = dp - mp;
		return loc;
	}

	return siz;
}
