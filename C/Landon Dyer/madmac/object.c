/*
 *  Writing object files
 *
 */
#include "as.h"
#include "sect.h"

#define HDRSIZE 0x1c		/* size of Alcyon header */


/*
 *  Imports
 */
extern int obj_format;		/* object file format to write */
extern int prg_flag;		/* generate Atari ST direct executable */


/*
 *  Generate Alcyon-format object file
 *
 */
object(fd)
WORD fd;			/* file to write to */
{
	register LONG t;
	register LONG tds;
	register int i;		/* (temp int) */
	register CHUNK *cp;		/* -> chunk (for gather) */
	register char *buf;		/* -> (huge) scratch area */
	register char *p;		/* (temp ptr) */
	LONG ssize;			/* size of symbols */

	char *constr_symtab();
	LONG markimg();


	/*
	 *  write 6502 object file (if one exists)
	 *   (God, this is a kludge)
	 */
	m6502obj(fd);

	/*
	 *  write 68000 object file
	 *   ALCYON or Mark Williams...
	 */
	switch (obj_format)
	{
		case MWC:
			i = sy_assign(NULL, NULL);
			mwobj(fd, sect[TEXT].sloc, sect[DATA].sloc, sect[BSS].sloc, i);
			break;

		case ALCYON:
			/*
			 *  Compute size of symbol table;
			 *   assign numbers to the symbols...
			 */
			ssize = 0;
			if (prg_flag != 1)
				ssize = ((LONG)sy_assign(NULL, NULL)) * 14;

			/*
			 *  Alloc memory for header+text+data, symbol and
			 *   relocation information construction.
			 */
			t = tds = sect[TEXT].sloc + sect[DATA].sloc;
			if (t < ssize)
				t = ssize;
			buf = amem(t + HDRSIZE) + HDRSIZE;

			/*
			 *  Build object file header
			 *   just before the text+data image
			 */
			chptr = buf - HDRSIZE;	/* -> base of header */
			D_word(0x601a);		/* magic number */
			t = sect[TEXT].sloc;		/* TEXT size */
			D_long(t);
			t = sect[DATA].sloc;		/* DATA size */
			D_long(t);
			t = sect[BSS].sloc;		/* BSS size */
			D_long(t);
			D_long(ssize);		/* symbol table size */
			D_long(0);			/* stack size (unused) */
			D_long(0);			/* entry point (unused) */
			D_word(0);			/* relocation information exists */

			/*
			 *  Construct text and data segments;
			 *  fixup relocatable longs in .PRG mode;
			 *  finally write the header+text+data
			 */
			p = buf;
			for (i = TEXT; i <= DATA; ++i)
				for (cp = sect[i].sfcode; cp != NULL; cp = cp->chnext)
				{
					copy(p, cp->chptr, cp->chsize);
					p += cp->chsize;
				}

			if (prg_flag)
				markimg(buf, tds, sect[TEXT].sloc, 0);

			write(fd, buf - HDRSIZE, tds + HDRSIZE);

			/*
			 *  Construct and write symbol table
			 */
			if (prg_flag != 1)
			{
				sy_assign(buf, constr_symtab);
				write(fd, buf, ssize);
			}

			/*
			 *  Construct and write relocation information;
			 *   the size of it changes if we're writing a RELMODed executable.
			 */
			tds = markimg(buf, tds, sect[TEXT].sloc, 1);
			write(fd, buf, tds);
			break;
	}
}


/*
 *  Alcyon symbol flags
 */
#define	AL_DEFINED	0x8000
#define	AL_EQUATED	0x4000
#define	AL_GLOBAL	0x2000
#define	AL_EQUREG	0x1000
#define	AL_EXTERN	0x0800
#define	AL_DATA		0x0400
#define	AL_TEXT		0x0200
#define	AL_BSS		0x0100
#define	AL_FILE		0x0080


static WORD tdb_tab[] = {
	0,				/* absolute */
	AL_TEXT,			/* TEXT segment based */
	AL_DATA, 0,			/* DATA segment based */
	AL_BSS			/* BSS segment based */
};


/*
 *  Add entry to symbol table;
 *  if `globflag' is 1, make the symbol global;
 *  if in .PRG mode, adjust symbol values for fake link.
 *
 */
char *constr_symtab(buf, sym, globflag)
register char *buf;
SYM *sym;
int globflag;
{
	register int i;
	register char *s;
	register WORD w;
	register LONG z;
	register WORD w1;

	/*
	 *  Copy symbol name
	 */
	s = sym->sname;
	for (i = 0; i < 8 && *s; ++i)
		*buf++ = *s++;
	while (i++ < 8)
		*buf++ = '\0';

	/*
	 *  Construct and deposit flag word
	 *
	 *	o  all symbols are AL_DEFINED
	 *	o  install T/D/B/A base
	 *    o  install 'equated'
	 *    o  commons (COMMON) are AL_EXTERN, but not BSS
	 *	o  exports (DEFINED) are AL_GLOBAL
	 *	o  imports (~DEFINED) are AL_EXTERN
	 *
	 */
	w1 = sym->sattr;
	w = AL_DEFINED | tdb_tab[w1 & TDB];
	if (w1 & EQUATED)		/* equated */
		w |= AL_EQUATED;

	if (w1 & COMMON)
	{
		w |= AL_EXTERN|AL_GLOBAL;	/* common symbol */
		w &= ~AL_BSS;		/* they're not BSS in Alcyon object files */
	}
	else if (w1 & DEFINED)
	{
		if (globflag)		/* export the symbol */
			w |= AL_GLOBAL;
	}
	else w |= AL_EXTERN;		/* imported symbol */

	*buf++ = w >> 8;
	*buf++ = w;

	z = sym->svalue;
	if (prg_flag)			/* relocate value in .PRG segment */
	{
		w1 &= DATA|BSS;
		if (w1)
			z += sect[TEXT].sloc;
		if (w1 & BSS)
			z += sect[DATA].sloc;
	}

	*buf++ = z >> 24;		/* deposit symbol value */
	*buf++ = z >> 16;
	*buf++ = z >> 8;
	*buf++ = z;

	return buf;
}
