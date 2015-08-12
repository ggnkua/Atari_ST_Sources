/*
 *  Mark Williams object file generation
 *
 */
#include "as.h"
#include "sect.h"

#define	MWHDRSIZ	0x0030	/* size of MW header */
#define	MWMAGIC		0407	/* object file magic header */
#define	M68000		10	/* machine ID for 68000 */
#define	MWSYMSIZ	16	/* #chars in a symbol name */
#define MWGLOBAL	0x0010	/* symbol is global */
#define	MWEXTERN	0x000a	/* symbol is an external reference */
#define	MWEXT_MASK	0x000f	/* (mask for symbol space) */

#define	MWSYMSPACE	7	/* symbol space */
#define	MWPCREL		0x10	/* PC-relative fixup */
#define	MWREL_WORD	0x20	/* fixup word */
#define	MWREL_LONG      0x40	/* fixup longword */


/*
 *  MW sections we map assembler sections to:
 */
#define	MWABS		9
#define	MWTEXT		0
#define	MWDATA		3
#define	MWBSS		5


/*
 *  vars for sorting fixup records
 */
int nitems;			/* number of fixup records */
char **ptrbuf;			/* -> vector of ptrs to fixup records */
char *altreloc;			/* -> alternate relocation info buffer */


/*
 *  Generate Mark Williams object file
 *
 */
mwobj(fd, tsize, dsize, bsize, nsyms)
int fd;
LONG tsize;
LONG dsize;
LONG bsize;
int nsyms;
{
	LONG ssize;			/* = size of symbols */
	LONG rsize;			/* = size of relocation information */
	LONG tds;			/* = size of text+data */
	register LONG t;
	register char *buf;		/* -> buffer for writing output */
	register char *p;
	register int i;
	register CHUNK *cp;

	LONG mwreloc();
	char *mwconstr();


	/*
	 *  Compute sizes of text+data image, symbol information and
	 *   relocation information.  Allocate storage for the text+data
	 *   and so on, and allocate storage for a pointer to every
	 *   relocation record (for sorting, later on).
	 *
	 */
	rsize = mwreloc(NULL, 0);
	ssize = nsyms * (MWSYMSIZ + 6);
	t = tds = tsize + dsize;

	if (t < ssize)		/* t = max(tds, ssize, rsize*2) */
		t = ssize;
	if (t < rsize*2)
		t = rsize*2;

	ptrbuf = (char **)amem(((LONG)nitems) * sizeof(char *));
	buf = amem(t + MWHDRSIZ) + MWHDRSIZ;
	altreloc = buf + rsize;

#ifdef DO_DEBUG
	DEBUG printf("mwobj(): rsize=$%lx ssize=$%lx tds=$%lx t=$%lx\n",
				 rsize, ssize, tds, t);
#endif

	/*
	 *  Construct header
	 */
	chptr = buf - MWHDRSIZ;
	D_rword(MWMAGIC);		/* MWobj magic number */
	D_rword(020);		/* 32-bit header */
	D_rword(M68000);		/* processor = 68000 */
	D_rword(0x0030);		/* offset of text = 0x30 (always) */

	D_rlong(tsize);		/* 0: shared instr. space */
	D_rlong(0);			/* 1: (unused) private instr. space */
	D_rlong(0);			/* 2: (unused) uninitialized instr. space */
	D_rlong(dsize);		/* 3: shared data space */
	D_rlong(0);			/* 4: (unused) private data space */
	D_rlong(bsize);		/* 5: uninitialized data space */
	D_rlong(0);			/* 6: (unused) debug information */
	D_rlong(ssize);		/* 7: symbols */
	D_rlong(rsize);		/* 8: relocation information */


	/*
	 *  Copy text and data segments to buffer,
	 *  fix-up stuff that still needs it,
	 *  and write the header+text+data to the file.
	 */
	p = buf;
	for (i = TEXT; i <= DATA; ++i)
		for (cp = sect[i].sfcode; cp != NULL; cp = cp->chnext)
		{
			copy(p, cp->chptr, cp->chsize);
			p += cp->chsize;
		}
	rsize = mwreloc(buf, 1);
	write(fd, buf-MWHDRSIZ, tds+MWHDRSIZ);

	/*
	 *  Construct symbol-table and write it
	 */
	sy_assign(buf, mwconstr);
	write(fd, buf, ssize);

	/*
	 *  Construct relocation information, sort it, and write it
	 */
	mwreloc(buf, 0);
	mwsort();
	write(fd, altreloc, rsize);
}



/*
 *  translate mark "to" space to MWC fixup space
 */
static char mwrelsp[] = {
	MWABS,			/* absolute */
	MWTEXT,			/* text */
	MWDATA, 0,			/* data (plus filler) */
	MWBSS			/* BSS */
};

/*
 *  Deposit / compute size of MW relocation information
 *   return size of relocation information
 *   if (buf != NULL) then deposit relocation information
 *
 *  If 'fix_flag' != 0, then fixup text+data image at 'buf'.
 */
LONG mwreloc(buf, fix_flag)
register char *buf;
int fix_flag;
{
	register char byte;
	register WORD w;		/* fixup flags */
	register WORD from;		/* section fixup is from (TEXT or DATA) */
	register LONG loc;		/* location temp */
	LONG rsize;			/* computed size of relocation info */
	LONG lw;			/* longword temp */
	register PTR p;		/* -> mark records in mark chunk */
	register SYM *sym;		/* -> symbol for fixup */
	register char *fp;		/* temp ptr to fixup */
	char **ptrdep;		/* deposit ptr for saddrs of fixup records */
	MCHUNK *mch;		/* -> chunk of marks */

	extern MCHUNK *firstmch;	/* -> first mark chunk */


	rsize = 0;
	from = 0;
	ptrdep = ptrbuf;
	nitems = 0;

	for (mch = firstmch; mch != NULL; mch = mch->mcnext)
		for (p = mch->mcptr;;)
		{
			w = *p.wp++;	/* w = next mark entry */
			if (w & MCHEND)	/* (end of mark chunk) */
				break;

			sym = NULL;		/* assume no symbol */
			++nitems;		/* bump relocation item count */

			/*
			 *  get mark record
			 */
			loc = *p.lp++;	/* get offset into section */
			if (w & MCHFROM)	/* get change-of-from if necessary */
				from = *p.wp++;
			byte = mwrelsp[(w & TDB)];

			if (w & MSYMBOL)	/* get symbol pointer if necessary */
			{
				sym = *p.sy++;
				byte = MWSYMSPACE;
				rsize += 2;	/* adjust relocation info size for symbol */
			}
			rsize += 5;		/* bump size of relocation information */

			/*
			 *  compute fixup size (word or long)
			 */
			if (w & MLONG)
				byte |= MWREL_LONG;
			else byte |= MWREL_WORD;

			/*
			 *  set pc-relative flag
			 */
			if (w & MPCREL)
				byte |= MWPCREL;

			/*
			 *  compute offset into image part of file
			 */
			if (from & DATA)
				loc += sect[TEXT].sloc;

			if (fix_flag)
			{
				/*
				 *  offsets in MWC files are to the base of
				 *   the text segment, so adjust offset in image:
				 */
				if (w & (DATA|BSS))
					if (w & MLONG)
					{
						fp = &buf[loc];
						lw = ((LONG)(*fp++ & 0xff)) << 24;
						lw |= ((LONG)(*fp++ & 0xff)) << 16;
						lw |= ((LONG)(*fp++ & 0xff)) << 8;
						lw |= (LONG)(*fp & 0xff);

						lw += sect[TEXT].sloc;
						if (w & BSS)
							lw += sect[DATA].sloc;

#ifdef DO_DEBUG
						DEBUG
								printf("mwreloc: long fix at $%08lx ==> $%08lx\n",
									   loc, lw);
#endif

						fp = &buf[loc];
						*fp++ = (char)(lw >> 24);
						*fp++ = (char)(lw >> 16);
						*fp++ = (char)(lw >> 8);
						*fp = (char)lw;
					}
					else
					{
						fp = &buf[loc];
						lw = ((LONG)(*fp++ & 0xff)) << 8;
						lw |= (LONG)(*fp & 0xff);

						lw += sect[TEXT].sloc;
						if (w & BSS)
							lw += sect[DATA].sloc;

#ifdef DO_DEBUG
						DEBUG
								printf("mwreloc: word fix at $%08lx ==> $%08lx\n",
									   loc, lw);
#endif

						fp = &buf[loc];
						*fp++ = (char)(lw >> 8);
						*fp = (char)lw;
					}
			}
			else if (buf != NULL)
			{
				*ptrdep++ = buf;
				*buf++ = byte;
				*buf++ = (char)(loc >> 16);
				*buf++ = (char)(loc >> 24);
				*buf++ = (char)loc;
				*buf++ = (char)(loc >> 8);

				if (sym != NULL)
				{
					*buf++ = (char)sym->senv;
					*buf++ = (char)(sym->senv >> 8);
				}
			}
		}

	return rsize;
}


/*
 *  Sort MWC relocation information from
 *   buf[] into altreloc[].
 *
 */
mwsort()
{
	int mwcomp();		/* qsort() comparison function */
	register int i;		/* number of records to copy */
	register char **ptrptr;	/* -> sorted pointers */
	register char *src;		/* -> source relocation record */
	register char *dst;		/* -> sorted destination area */

#ifdef DO_DEBUG
	DEBUG
	{
		for (i = 0; i < nitems; ++i)
			printf("%d: $%08lx ($%02x $%02x%02x%02x%02x)\n",
				   i, ptrbuf[i],
				   *(ptrbuf[i])&0xff,
				   *(ptrbuf[i]+2)&0xff,
				   *(ptrbuf[i]+1)&0xff,
				   *(ptrbuf[i]+4)&0xff,
				   *(ptrbuf[i]+3)&0xff);
	}
#endif

	qsort(ptrbuf, nitems, sizeof(char *), mwcomp);

#ifdef DO_DEBUG
	DEBUG
	{
		printf("------------\n");
		for (i = 0; i < nitems; ++i)
			printf("%d: $%08lx ($%02x $%02x%02x%02x%02x)\n",
				   i, ptrbuf[i],
				   *(ptrbuf[i])&0xff,
				   *(ptrbuf[i]+2)&0xff,
				   *(ptrbuf[i]+1)&0xff,
				   *(ptrbuf[i]+4)&0xff,
				   *(ptrbuf[i]+3)&0xff);
	}
#endif

	dst = altreloc;
	ptrptr = ptrbuf;
	for (i = nitems; i; --i)
	{
#ifdef DO_DEBUG
		DEBUG printf("~ mwsort  $%02x $%02x%02x%02x%02x",
					 *src, src[1+1], src[1], src[1+3], src[1+2]);
#endif
		src = *ptrptr++;
		if ((*src & 0x0f) == 7)
		{			/* account for symbol-based relocation */
#ifdef DO_DEBUG
			DEBUG printf(" sym=$%02x%02x", src[5], src[6]);
#endif
			*dst++ = *src++;
			*dst++ = *src++;
		}
#ifdef DO_DEBUG
		DEBUG putchar('\n');
#endif

		*dst++ = *src++;	/* copy 5-byte relocation record */
		*dst++ = *src++;
		*dst++ = *src++;
		*dst++ = *src++;
		*dst++ = *src++;
	}
}


/*
 *  Compare two relocation records
 *   and return -1, 0 or 1 (canonical qsort comparison routine).
 */
int mwcomp(ptra, ptrb)
char **ptra;
char **ptrb;
{
	register unsigned char *a;
	register unsigned char *b;
	register LONG lwa;
	register LONG lwb;

	a = (unsigned char *)*ptra;
	b = (unsigned char *)*ptrb;

	/*     DEBUG printf("~ mwcomp()\n");*/

	lwa = ((a[2]&0xff)<<24) |
		  ((a[1]&0xff)<<16) |
		  ((a[4]&0xff)<<8) |
		  (a[3]&0xff);

	lwb = ((b[2]&0xff)<<24) |
		  ((b[1]&0xff)<<16) |
		  ((b[4]&0xff)<<8) |
		  (b[3]&0xff);

	/*     DEBUG printf("\ta=$%08lx b=$%08lx\n", lwa, lwb);*/

	if (lwa > lwb) return 1;
	else if (lwa < lwb) return -1;
	else return 0;
}


/*
 *  Translate from TDB to MW segment number
 */
static WORD mwtdb[] = {
	MWABS,			/* absolute */
	MWTEXT,			/* TEXT */
	MWDATA, -1,			/* DATA */
	MWBSS			/* BSS */

};

/*
 *  Deposit MW symbol in symbol-table
 *
 */
char *mwconstr(buf, sym, globflag)
register char *buf;
SYM *sym;
int globflag;
{
	register int i;
	register char *s;
	register WORD w;
	register WORD w1;
	register LONG lw;
	int uflag;
	extern int mwc_uflag;

#ifdef DO_DEBUG
	DEBUG printf("mwconstr(): sym->sname='%s' globflag=%d\n",
				 sym->sname, globflag);
#endif

	/*
	 *  Deposit symbol name,
	 *   put '_' on end if "-fmu" is specified on the commandline.
	 */
	uflag = 0;
	s = sym->sname;

	if (*s == '_' && mwc_uflag)
	{				/* rip-off '_' on front */
		uflag = 1;
		++s;
	}

	for (i = 0; i < MWSYMSIZ && *s; ++i) /* copy name */
		*buf++ = *s++;

	if (i < MWSYMSIZ && uflag)
	{				/* append '_' */
		*buf++ = '_';
		++i;
	}

	while (i++ < MWSYMSIZ)	/* fill rest of name with nulls */
		*buf++ = '\0';


	/*
	 *  compute and deposit flags
	 */
	w1 = sym->sattr;
	if (w1 & COMMON)
		w = MWEXTERN|MWGLOBAL;
	else
	{
		w = mwtdb[w1 & TDB];
		if (globflag)
		{
			w |= MWGLOBAL;
			if ((w1 & DEFINED) == 0)
				w = (w & (~MWEXT_MASK)) | MWEXTERN;
		}
	}

	*buf++ = (char)w;
	*buf++ = (char)(w >> 8);

	/*
	 *  compute and deposit value
	 */
	lw = sym->svalue;
	if (w1 & (DATA|BSS))
	{
		lw += sect[TEXT].sloc; /* put in DATA segment */
		if (w1 & BSS)
			lw += sect[DATA].sloc; /* put  in BSS segment */
	}

	*buf++ = (char)(lw >> 16);
	*buf++ = (char)(lw >> 24);
	*buf++ = (char)lw;
	*buf++ = (char)(lw >> 8);

	return buf;
}
