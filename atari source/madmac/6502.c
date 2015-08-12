/*
 *  6502 Assembler
 *
 *    i6502	initialization
 *    d_6502    handle ".6502" directive
 *    m6502cg	generate code for a 6502 mnemonic
 *    d_org	handle 6502 section's ".org" directive
 *    m6502obj	generate 6502 object file
 *
 */
#include "as.h"
#include "sect.h"

#define	UPSEG_SIZE	0x10010L /* size of 6502 code buffer, 64K+16bytes */


/*
 *  Imports
 */
extern TOKEN *tok;		/* -> current token */
extern int debug;		/* >0, in debug mode (-x) */
extern int m6502;		/* 1, in 6502 mode */
extern TOKEN exprbuf[];		/* "universal" postfix expression buffer */
extern LONG lsloc;		/* `sloc' at start of line */

extern char extra_stuff[];	/* needed-eol error message */
extern char *range_error;	/* value-out-of-range error message */


/*
 *  Exports
 */
char in_6502mode[] = "directive illegal in .6502 section";


/*
 *  6502 addressing modes;
 *  do not change these values.
 *
 */
#define	A65_ABS		0
#define	A65_ABSX	1
#define	A65_ABSY	2
#define	A65_IMPL	3
#define	A65_IMMED	4
#define	A65_INDX	5
#define	A65_INDY	6
#define	A65_IND		7
#define	A65_REL		8
#define	A65_ZP		9
#define	A65_ZPX		10
#define	A65_ZPY		11


#define	NMACHOPS 56		/* number of machine ops */
#define	NMODES	12		/* number of addressing modes */
#define	NOP	0xea		/* 6502 NOP instruction */
#define	ILLEGAL	0xff		/* 'illegal instr' marker */
#define END65	0xff		/* end-of-an-instr-list */

static char imodes[] =
{
	A65_IMMED, 0x69, A65_ABS, 0x6d, A65_ZP, 0x65, A65_INDX, 0x61, A65_INDY, 0x71,
	A65_ZPX, 0x75, A65_ABSX, 0x7d, A65_ABSY, 0x79, END65,
	A65_IMMED, 0x29, A65_ABS, 0x2d, A65_ZP, 0x25, A65_INDX, 0x21, A65_INDY, 0x31,
	A65_ZPX, 0x35, A65_ABSX, 0x3d, A65_ABSY, 0x39, END65,
	A65_ABS, 0x0e, A65_ZP, 0x06, A65_IMPL, 0x0a, A65_ZPX, 0x16, A65_ABSX,
	0x1e, END65,
	A65_REL, 0x90, END65,
	A65_REL, 0xb0, END65,
	A65_REL, 0xf0, END65,
	A65_REL, 0xd0, END65,
	A65_REL, 0x30, END65,
	A65_REL, 0x10, END65,
	A65_REL, 0x50, END65,
	A65_REL, 0x70, END65,
	A65_ABS, 0x2c, A65_ZP, 0x24, END65,
	A65_IMPL, 0x00, END65,
	A65_IMPL, 0x18, END65,
	A65_IMPL, 0xd8, END65,
	A65_IMPL, 0x58, END65,
	A65_IMPL, 0xb8, END65,
	A65_IMMED, 0xc9, A65_ABS, 0xcd, A65_ZP, 0xc5, A65_INDX, 0xc1, A65_INDY, 0xd1,
	A65_ZPX, 0xd5, A65_ABSX, 0xdd, A65_ABSY, 0xd9, END65,
	A65_IMMED, 0xe0, A65_ABS, 0xec, A65_ZP, 0xe4, END65,
	A65_IMMED, 0xc0, A65_ABS, 0xcc, A65_ZP, 0xc4, END65,
	A65_ABS, 0xce, A65_ZP, 0xc6, A65_ZPX, 0xd6, A65_ABSX, 0xde, END65,
	A65_IMPL, 0xca, END65,
	A65_IMPL, 0x88, END65,
	A65_IMMED, 0x49, A65_ABS, 0x4d, A65_ZP, 0x45, A65_INDX, 0x41, A65_INDY, 0x51,
	A65_ZPX, 0x55, A65_ABSX, 0x5d, A65_ABSY, 0x59, END65,
	A65_ABS, 0xee, A65_ZP, 0xe6, A65_ZPX, 0xf6, A65_ABSX, 0xfe, END65,
	A65_IMPL, 0xe8, END65,
	A65_IMPL, 0xc8, END65,
	A65_ABS, 0x4c, A65_IND, 0x6c, END65,
	A65_ABS, 0x20, END65,
	A65_IMMED, 0xa9, A65_ABS, 0xad, A65_ZP, 0xa5, A65_INDX, 0xa1, A65_INDY, 0xb1,
	A65_ZPX, 0xb5, A65_ABSX, 0xbd, A65_ABSY, 0xb9, END65,
	A65_IMMED, 0xa2, A65_ABS, 0xae, A65_ZP, 0xa6, A65_ABSY, 0xbe,
	A65_ZPY, 0xb6, END65,
	A65_IMMED, 0xa0, A65_ABS, 0xac, A65_ZP, 0xa4, A65_ZPX, 0xb4,
	A65_ABSX, 0xbc, END65,
	A65_ABS, 0x4e, A65_ZP, 0x46, A65_IMPL, 0x4a, A65_ZPX, 0x56,
	A65_ABSX, 0x5e, END65,
	A65_IMPL, 0xea, END65,
	A65_IMMED, 0x09, A65_ABS, 0x0d, A65_ZP, 0x05, A65_INDX, 0x01, A65_INDY, 0x11,
	A65_ZPX, 0x15, A65_ABSX, 0x1d, A65_ABSY, 0x19, END65,
	A65_IMPL, 0x48, END65,
	A65_IMPL, 0x08, END65,
	A65_IMPL, 0x68, END65,
	A65_IMPL, 0x28, END65,
	A65_ABS, 0x2e, A65_ZP, 0x26, A65_IMPL, 0x2a, A65_ZPX, 0x36,
	A65_ABSX, 0x3e, END65,
	A65_ABS, 0x6e, A65_ZP, 0x66, A65_IMPL, 0x6a, A65_ZPX, 0x76,
	A65_ABSX, 0x7e, END65,
	A65_IMPL, 0x40, END65,
	A65_IMPL, 0x60, END65,
	A65_IMMED, 0xe9, A65_ABS, 0xed, A65_ZP, 0xe5, A65_INDX, 0xe1, A65_INDY, 0xf1,
	A65_ZPX, 0xf5, A65_ABSX, 0xfd, A65_ABSY, 0xf9, END65,
	A65_IMPL, 0x38, END65,
	A65_IMPL, 0xf8, END65,
	A65_IMPL, 0x78, END65,
	A65_ABS, 0x8d, A65_ZP, 0x85, A65_INDX, 0x81, A65_INDY, 0x91, A65_ZPX, 0x95,
	A65_ABSX, 0x9d, A65_ABSY, 0x99, END65,
	A65_ABS, 0x8e, A65_ZP, 0x86, A65_ZPY, 0x96, END65,
	A65_ABS, 0x8c, A65_ZP, 0x84, A65_ZPX, 0x94, END65,
	A65_IMPL, 0xaa, END65,
	A65_IMPL, 0xa8, END65,
	A65_IMPL, 0xba, END65,
	A65_IMPL, 0x8a, END65,
	A65_IMPL, 0x9a, END65,
	A65_IMPL, 0x98, END65
};


static char ops[NMACHOPS][NMODES]; /* opcodes */
static unsigned char inf[NMACHOPS][NMODES]; /* construction info */

static int abs2zp[] =
{				/* absolute-to-zeropage trans table */
	A65_ZP,			/* ABS */
	A65_ZPX,			/* ABSX */
	A65_ZPY,			/* ABSY */
	-1,				/* IMPL */
	-1,				/* IMMED */
	-1,				/* INDX */
	-1,				/* INDY */
	-1,				/* IND */
	-1,				/* REL */
	-1,				/* ZP */
	-1,				/* ZPX */
	-1				/* ZPY */
};


/*
 *  initialize 6502 assembler
 *
 */
i6502()
{
	register int i;
	register int j;
	register char *s;

	s = imodes;

	/* set all instruction slots to illegal */
	for (i = 0; i < NMACHOPS; ++i)
		for (j = 0; j < NMODES; ++j)
			inf[i][j] = ILLEGAL;

	/* uncompress legal instructions into their slots */
	for (i = 0; i < NMACHOPS; ++i)
	{
		do {
			j = *s & 0xff;
			inf[i][j] = *s;
			ops[i][j] = s[1];

			/* hack A65_REL mode */
			if (*s == A65_REL)
			{
				inf[i][A65_ABS] = A65_REL;
				ops[i][A65_ABS] = s[1];
				inf[i][A65_ZP] = A65_REL;
				ops[i][A65_ZP] = s[1];
			}
		} while(*(s += 2) != (char)END65);
		++s;
	}
}


/*
 *  .6502 --- enter 6502 mode
 *
 */
d_6502()
{
	savsect();			/* save curent section */
	switchsect(M6502);		/* switch to 6502 section */
	if (challoc == 0) {
		/*
		 *  Allocate and clear 64K of space for the 6502 section
		 */
		chcheck(UPSEG_SIZE);
		clear(sect[M6502].scode->chptr, UPSEG_SIZE);
	}
}


/*
 *  Do 6502 code generation
 *
 */
m6502cg(op)
int op;
{
	register int amode;		/* (parsed) addressing mode */
	register int i;
	VALUE eval;			/* expression value */
	WORD eattr;			/* expression attributes */
	int zpreq;			/* 1, optimize instr to zero-page form */
	register char *p;		/* (temp) string usage */


	chsize = 0;			/* reset chunk size on every instruction */

	/*
	 *  Parse 6502 addressing mode
	 *
	 */
	zpreq = 0;
	switch ((int)*tok)
	{
		case EOL:
			amode = A65_IMPL;
			break;

		case '#':
			++tok;
			if (expr(exprbuf, &eval, &eattr, NULL) < 0) return;
			amode = A65_IMMED;
			break;

		case '(':
			++tok;
			if (expr(exprbuf, &eval, &eattr, NULL) < 0) return;

			if (*tok == ')')
			{			/* (foo) or (foo),y */
				if (*++tok == ',')
				{			/* (foo),y */
					++tok;
					p = (char *)tok[1];
					if (*tok != SYMBOL ||
						  p[1] != EOS ||
						  (*p | 0x20) != 'y') /* sleazo tolower() */
						goto badmode;
					tok += 2;
					amode = A65_INDY;
				}
				else amode = A65_IND;
			}
			else if (*tok == ',')
			{			/* (foo,x) */
				++tok;
				p = (char *)tok[1];
				if (*tok != SYMBOL ||
					  p[1] != EOS ||
					  (*p | 0x20) != 'x') /* sleazo tolower() */
					goto badmode;
				tok += 2;
				if (*tok++ != ')')
					goto badmode;
				amode = A65_INDX;
			}
			else goto badmode;
			break;

		case '@':
			++tok;
			if (expr(exprbuf, &eval, &eattr, NULL) < 0) return;

			if (*tok == '(')
			{
				++tok;
				p = (char *)tok[1];
				if (*tok != SYMBOL ||
					  p[1] != EOS ||
					  tok[2] != ')' ||
					  tok[3] != EOL)
					goto badmode;

				i = (*p | 0x20);	/* sleazo tolower */
				if (i == 'x')
					amode = A65_INDX;
				else if (i == 'y')
					amode = A65_INDY;
				else goto badmode;
				tok += 3;		/* past SYMBOL <string> ')' EOL */
				zpreq = 1;		/* request zeropage optimization */
			}
			else if (*tok == EOL)
				amode = A65_IND;
			else goto badmode;
			break;

		default:
			/*
			 *  Short-circuit
			 *    x,foo
			 *    y,foo
			 *
			 */
			p = (char *)tok[1];
			if (*tok == SYMBOL &&
				  p[1] == EOS &&
				  tok[2] == ',')
			{
				tok += 3;		/* past: SYMBOL <string> ',' */
				i = (*p | 0x20);

				if (i == 'x')
					amode = A65_ABSX;
				else if (i == 'y')
					amode = A65_ABSY;
				else goto not_coinop;

				if (expr(exprbuf, &eval, &eattr, NULL) < 0)
					return;
				if (*tok != EOL)
					goto badmode;

				zpreq = 1;
				break;
			}

not_coinop:
			if (expr(exprbuf, &eval, &eattr, NULL) < 0) return;
			zpreq = 1;

			if (*tok == EOL)
				amode = A65_ABS;
			else if (*tok == ',')
			{
				++tok;
				p = (char *)tok[1];
				if (*tok != SYMBOL ||
					  p[1] != EOS)
					goto badmode;
				tok += 2;

				/*
				 *  Check for X or Y index register;
				 *  the OR with 0x20 is a sleazo conversion
				 *  to lower-case that actually works.
				 */
				i = *p | 0x20;	/* oooh, this is slimey (but fast!) */
				if (i == 'x')
					amode = A65_ABSX;
				else if (i == 'y')
					amode = A65_ABSY;
				else goto badmode;
			}
			else goto badmode;
			break;

badmode:
			return error("bad 6502 addressing mode");
	}

	/*
	 *  Optimize ABS modes to zero-page when possible
	 *    o  ZPX or ZPY is illegal, or
	 *    o  expr is zeropage && zeropageRequest && expression is defined
	 */
	if (inf[op][amode] == ILLEGAL || /* if current op is illegal, or */
		  (eval < 0x100 &&		/* expr must be zero-page */
		   zpreq != 0 &&		/* amode must request zero-page opt. */
		   (eattr & DEFINED)))	/* and the expression must be defined */
	{
		i = abs2zp[amode];	/* i = zero-page translation of amode */
#ifdef DO_DEBUG
		DEBUG printf(" OPT: op=%d amode=%d i=%d inf[op][i]=%d\n",
					 op, amode, i, inf[op][i]);
#endif
		if (i >= 0 &&
			  (inf[op][i] & 0xff) != ILLEGAL) /* use it if it's legal */
			amode = i;
	}

#ifdef DO_DEBUG
	DEBUG printf("6502: op=%d amode=%d ", op, amode);
	DEBUG printf("inf[op][amode]=%d\n", (int)inf[op][amode]);
#endif

	switch (inf[op][amode])
	{
		case A65_IMPL:		/* just leave the instruction */
			D_byte(ops[op][amode]);
			break;

		case A65_IMMED:
		case A65_INDX:
		case A65_INDY:
		case A65_ZP:
		case A65_ZPX:
		case A65_ZPY:
			D_byte(ops[op][amode]);
			if (!(eattr & DEFINED))
			{
				fixup(FU_BYTE, sloc, exprbuf);
				eval = 0;
			}
			else if (eval + 0x100 >= 0x200)
			{
				error(range_error);
				eval = 0;
			}
			D_byte(eval);		/* deposit byte following instr */
			break;

		case A65_REL:
			D_byte(ops[op][amode]);
			if (eattr & DEFINED)
			{
				eval -= (sloc + 1);
				if (eval + 0x80 >= 0x100)
				{
					error(range_error);
					eval = 0;
				}
				D_byte(eval);
			}
			else
			{
				fixup(FU_6BRA, sloc, exprbuf);
				D_byte(0);
			}
			break;

		case A65_ABS:
		case A65_ABSX:
		case A65_ABSY:
		case A65_IND:
			D_byte(ops[op][amode]);
			if (!(eattr & DEFINED))
			{
				fixup(FU_WORD, sloc, exprbuf);
				eval = 0;
			}
			D_rword(eval);
			break;

			/*
			 *  Deposit 3 NOPs for illegal things
			 */
		default:
		case ILLEGAL:
			for (i = 0; i < 3; ++i) {
				D_byte(NOP);
			}
			error("illegal 6502 addressing mode");
	}

	/*
	 *  Check for overflow of code region
	 */
	if (sloc > 0x10000L) fatal("6502 code pointer > 64K");
	if (*tok != EOL) error(extra_stuff);
}


/*
 *  .org --- Set origin
 *
 *  We also kludge `lsloc' so the listing generator doesn't
 *  try to spew out megabytes.
 *
 */
d_org()
{
	VALUE eval;

	if (m6502 == 0) return error(".org permitted only in .6502 section");
	if (abs_expr(&eval) < 0) return;
	if (eval >= 0x10000L) return error(range_error);

	chsize = 0;
	lsloc = sloc = eval;
	chptr = scode->chptr + eval;
	at_eol();
}


#define	NPAGES		256L
#define	PAGESIZE	256L


/*
 *  Generate 6502 object output file.
 *
 */
m6502obj(ofd)
int ofd;
{
	register CHUNK *ch;
	register long i;
	register long j;
	register long k;
	register char *p;
	char pageflag[NPAGES];

	/*
	 *  If no 6502 code was generated, forget it
	 */
	if ((ch = sect[M6502].scode) == NULL ||
		  ch->challoc == 0)
		return;


	/*
	 *  Scan through 64K image and mark pages to write
	 */
	k = 0;
	for (i = 0; i < NPAGES; ++i)
	{
		pageflag[i] = 0;
		p = ch->chptr + (i * PAGESIZE);
		for (j = PAGESIZE; j--;)
			if (*p++)
			{
#ifdef DO_DEBUG
				DEBUG printf("6502: page %d\n", i);
#endif
				pageflag[i] = 1;
				k = 1;
				break;
			}
	}

	/*
	 *  If nothing's dirty, don't write any pages
	 */
	if (!k)
		return;

	/*
	 *  Write map of page images we're about to write
	 */
	write(ofd, &pageflag[0], NPAGES);

	/*
	 *  Write images;
	 *  write adjacent flagged pages with one write() call.
	 */
	p = ch->chptr;
	for (j = 0; j < NPAGES; ++j)
		if (pageflag[j])
		{
			for (k = j + 1; k < NPAGES && pageflag[k] != 0;)
				++k;
#ifdef DO_DEBUG
			DEBUG printf("6502: write %d..%d-1\n", j, k);
#endif
			write(ofd, p + (j << 8), (k - j) << 8);
			j = k;
		}
}
