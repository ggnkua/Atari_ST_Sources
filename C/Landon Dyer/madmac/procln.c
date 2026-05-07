/*
 *  Line processing
 *
 */
#include "as.h"
#include "amode.h"
#include "sect.h"
#include "token.h"

#define DEF_MN			/* include 68k keyword definitions */
#define DECL_MN			/* include 68k keyword state machine tables */
#include "mntab.h"

#define DEF_MP			/* include 6502 keyword definitions */
#define DECL_MP			/* include 6502 keyword state machine tables */
#include "6502.h"


/*
 *  Imports
 */
extern int as68_flag;		/* 1, assembler in Alcyon stupidity mode */
extern int list_flag;		/* 1, assembler in listing mode */
extern int listing;		/* listing level */
extern char lntag;		/* current tag for listing ('-', etc.) */
extern TOKEN *tok;		/* -> current token */
extern int curenv;		/* current local symbol enviroment */
extern TOKEN exprbuf[];		/* scratch expression-postfix buffer */
extern SYM *lookup();		/* lookup-a-symbol */
extern SYM *newsym();		/* make-a-new-symbol */
extern MNTAB machtab[];		/* 68000 code generation table */
extern int (*dirtab[])();	/* assembler directive handlers */
extern char tolowertab[];	/* convert uppercase ==> lowercase */
extern char *undef_error;	/* "undefined expression" (string) */
extern int m6502;		/* 1, assembler in .6502 mode */
extern VOID m6502cg();		/* 6502 code generator */


/*
 *  Exports and locals
 */
int just_bss;			/* 1, ds.b in microprocessor mode */
VALUE pcloc;			/* value of "PC" at beginning of line */
static int disabled;		/* 1, assembly conditionally disabled */
IFENT *ifent;			/* -> current ifent */
SYM *lab_sym;			/* -> label on line (or NULL) */
static IFENT ifent0;		/* root ifent */
static IFENT *f_ifent;		/* freelist of ifents */

char extra_stuff[] = "extra (unexpected) text found after addressing mode";
char *comma_error = "missing comma";
char *syntax_error = "syntax error";
char *locgl_error = "cannot GLOBL local symbol";
char *lab_ignored = "label ignored";



/*
 *  Table to convert an addressing-mode
 *  number to a bitmask.
 *
 */
LONG amsktab[0112] =
{
	M_DREG, M_DREG, M_DREG, M_DREG,
	M_DREG, M_DREG, M_DREG, M_DREG,

	M_AREG, M_AREG, M_AREG, M_AREG,
	M_AREG, M_AREG, M_AREG, M_AREG,

	M_AIND, M_AIND, M_AIND, M_AIND,
	M_AIND, M_AIND, M_AIND, M_AIND,

	M_APOSTINC, M_APOSTINC, M_APOSTINC, M_APOSTINC,
	M_APOSTINC, M_APOSTINC, M_APOSTINC, M_APOSTINC,

	M_APREDEC, M_APREDEC, M_APREDEC, M_APREDEC,
	M_APREDEC, M_APREDEC, M_APREDEC, M_APREDEC,

	M_ADISP, M_ADISP, M_ADISP, M_ADISP,
	M_ADISP, M_ADISP, M_ADISP, M_ADISP,

	M_AINDEXED, M_AINDEXED, M_AINDEXED, M_AINDEXED,
	M_AINDEXED, M_AINDEXED, M_AINDEXED, M_AINDEXED,

	M_ABSW,			/* 070 */
	M_ABSL,			/* 071 */
	M_PCDISP,			/* 072 */
	M_PCINDEXED,			/* 073 */
	M_IMMED,			/* 074 */
	0L,				/* 075 */
	0L,				/* 076 */
	0L,				/* 077 */
	M_ABASE,			/* 0100 */
	M_MEMPOST,			/* 0101 */
	M_MEMPRE,			/* 0102 */
	M_PCBASE,			/* 0103 */
	M_PCMPOST,			/* 0104 */
	M_PCMPRE,			/* 0105 */
	M_AM_USP,			/* 0106 */
	M_AM_SR,			/* 0107 */
	M_AM_CCR,			/* 0110 */
	M_AM_NONE			/* 0111 */
};				/* 0112 length */


/*
 *  Initialize line processor
 *
 */
iprocln()
{
	disabled = 0;
	ifent = &ifent0;
	f_ifent = ifent0.if_prev = NULL;
	ifent0.if_state = 0;
}


/*
 *  Line processor
 *
 */
assemble()
{
	register int state;		/* keyword machine state (output) */
	register int j;		/* random int, must be fast */
	register char *p;		/* random char ptr, must be fast */
	TOKEN *tk;			/* -> first token in line */
	char *label;			/* -> symbol (or NULL) */
	char *equate;			/* -> symbol (or NULL) */
	int labtyp;			/* label type (':', DCOLON) */
	int equtyp;			/* equ type ('=', DEQUALS) */
	VALUE eval;			/* expression value */
	WORD eattr;			/* expression attributes */
	SYM *esym;			/* -> external symbol involved in expr. */
	WORD siz;			/* size suffix to mnemonic/directive/macro */
	LONG amsk0, amsk1;		/* address-type masks for ea0, ea1 */
	MNTAB *m;			/* code generation table pointer */
	SYM *sy;			/* -> symbol (temp usage) */
	char *opname;			/* -> name of directive/mnemonic/macro... */
	int listflag;			/* 0, don't call listeol() */
	int as68mode;			/* 1, handle multiple labels */
	WORD rmask;			/* register list, for REG */

	listflag = 0;

loop:
	if (tokln() == TKEOF)		/* get another line of tokens */
	{
		if (list_flag && listflag) /* flush last line of source */
			listeol();

		if (ifent->if_prev != NULL)
			error("hit EOF without finding matching .endif");
		return;
	}

	if (list_flag) {
		/* tell listing generator about end-of-line */
		if (listflag && listing > 0) listeol();

		lstout((disabled ? '-' : lntag));	/* prepare new line for listing */
		listflag = 1;		/* OK to call `listeol' now */
		just_bss = 0;		/* reset just_bss mode */
	}

	state = -3;			/* no keyword (just EOL) */
	label = NULL;			/* no label */
	lab_sym = NULL;		/* no (exported) label */
	equate = NULL;		/* no equate */
	tk = tok;			/* save first token in line */
	pcloc = (VALUE)sloc;		/* set beginning-of-line PC */

loop1:
	if (*tok == EOL)
		goto loop;

	if (*tok != SYMBOL)		/* first token MUST be a symbol */
	{
		error(syntax_error);
		goto loop;
	}

	/*
	 *  Skip equates (normal statements)
	 */
	j = (int)tok[2];
	if (j == '=' ||		/* handle equates */
		  j == DEQUALS ||
		  j == SET ||
		  j == REG)
	{
		equate = (char *)tok[1];
		equtyp = j;
		tok += 3;
		goto normal;
	}

	/*
	 *  Skip past label (but record it for later)
	 *
	 */
	if (j == ':' ||
		  j == DCOLON)
	{
as68label:
		label = (char *)tok[1];
		labtyp = tok[2];
		tok += 3;

		/*
		 *  Handle multiple labels;
		 *  if there's another label, go
		 *  process it, and come back at `as68label' above.
		 */
		if (as68_flag)
		{
			as68mode = 0;
			if (*tok == SYMBOL &&
				  tok[2] == ':')
			{
				as68mode = 1;
				goto do_label;
			}
		}
	}

	if (*tok == EOL)		/* EOL is legal here... */
		goto normal;

	if (*tok++ != SYMBOL)
	{				/* next token MUST be a symbol */
		error(syntax_error);
		goto loop;
	}
	opname = p = (char *)*tok++;

	/*
	 *  Check to see if the SYMBOL is a keyword
	 *  (a mnemonic or directive).
	 *
	 *  On output, `state' will have one of the values:
	 *
	 *        -3	  there was no symbol (EOL)
	 *   -2.. -1    the symbol didn't match any keyword
	 *	0..499    vanilla directives (dc, ds, etc.)
	 *  500..999    electric directives (macro, rept, etc.)
	 * 1000.. +     mnemonics (move, lsr, etc.)
	 *
	 */
#ifdef ST
	state = kmatch(p, mnbase, mncheck, mntab, mnaccept);
#else
	for (state = 0; state >= 0;)
	{
		j = mnbase[state] + tolowertab[*p];
		if (mncheck[j] != state)	/* reject, character doesn't match */
		{
			state = -1;		/* no match */
			break;
		}

		if (!*++p)
		{			/* must accept or reject at EOS */
			state = mnaccept[j];	/* (-1 on no terminal match) */
			break;
		}
		state = mntab[j];
	}
#endif

	/*
	 *  Check for ".b" ".w" ".l"
	 *  after directive, macro or mnemonic.
	 */
	siz = SIZN;
	if (*tok == DOTW)
		siz = SIZW, ++tok;
	else if (*tok == DOTL)
		siz = SIZL, ++tok;
	else if (*tok == DOTB)
		siz = SIZB, ++tok;

	/*
	 *  Do special directives (500..999)
	 *  (These must be handled in "real time")
	 */
	if (state >= 500 && state < 1000)
		switch (state)
		{
			case MN_IF:
				d_if();
				goto loop;

			case MN_ELSE:
				d_else();
				goto loop;

			case MN_ENDIF:
				d_endif();
				goto loop;

			case MN_IIF:		/* .iif --- immediate if */
				if (disabled ||
					  expr(exprbuf, &eval, &eattr, &esym) != OK)
					goto loop;

				if (!(eattr & DEFINED))
				{
					error(undef_error);
					goto loop;
				}
				if (*tok++ != ',')
				{
					error(comma_error);
					goto loop;
				}
				if (eval == 0)
					goto loop;
				goto loop1;

			case MN_MACRO:		/* .macro --- macro definition */
				if (!disabled)
				{
					if (label != NULL)
						warn(lab_ignored);
					defmac();
				}
				goto loop;

			case MN_EXITM:		/* .exitm --- exit macro */
			case MN_ENDM:		/* .endm --- same as .exitm */
				if (!disabled)
				{
					if (label != NULL)
						warn(lab_ignored);
					exitmac();
				}
				goto loop;

			case MN_REPT:
				if (!disabled)
				{
					if (label != NULL)
						warn(lab_ignored);
					defrept();
				}
				goto loop;

			case MN_ENDR:
				if (!disabled)
					error("mis-nested .endr");
				goto loop;
		}


normal:
	if (disabled)			/* conditionally disabled code */
		goto loop;

	/*
	 *  Do equates
	 */
	if (equate != NULL)
	{
		j = 0;			/* pick global or local symbol enviroment */
		if (*equate == '.')
			j = curenv;

		sy = lookup(equate, LABEL, j);
		if (sy == NULL)
		{
			sy = newsym(equate, LABEL, j);
			sy->sattr = 0;
			if (equtyp == DEQUALS)
			{
				if (j)
				{		/* can't GLOBAL a local symbol */
					error(locgl_error);
					goto loop;
				}
				sy->sattr = GLOBAL;
			}
		}
		else if ((sy->sattr & DEFINED) &&
				 equtyp != SET)
		{
			errors("multiple equate to '%s'", sy->sname);
			goto loop;
		}

		/*
		 *  Put symbol in "order of definition" list
		 */
		if (!(sy->sattr & SDECLLIST)) sym_decl(sy);


		/*
		 *  Parse value to equate symbol to
		 *    o  .reg
		 *    o  everything else
		 */
		if (equtyp == REG)
		{
			if (reglist(&rmask) < 0)
				goto loop;
			eval = (VALUE)rmask;
			eattr = ABS | DEFINED;
		}
		else if (expr(exprbuf, &eval, &eattr, &esym) != OK)
			goto loop;

		if (!(eattr & DEFINED))
		{
			error(undef_error);
			goto loop;
		}

		/*  symbol inherits value and attributes */
		sy->sattr |= eattr | EQUATED;
		sy->svalue = eval;
		if (list_flag)		/* put value in listing */
			listvalue(eval);

		at_eol();			/* must be at EOL now */
		goto loop;
	}


	/*
	 *  Do labels
	 */
	if (label != NULL)
	{
do_label:
		j = 0;
		if (*label == '.')
			j = curenv;
		sy = lookup(label, LABEL, j);

		if (sy == NULL)
		{
			sy = newsym(label, LABEL, j);
			sy->sattr = 0;
		}
		else
			if (sy->sattr & DEFINED)
			{
				errors("multiply-defined label '%s'", label);
				goto loop;
			}

		/*
		 *  Put symbol in "order of definition" list
		 */
		if (!(sy->sattr & SDECLLIST)) sym_decl(sy);

		sy->svalue = sloc;
		sy->sattr |= DEFINED | cursect;
		lab_sym = sy;
		if (!j)
			++curenv;

		if (labtyp == DCOLON)
		{			/* make label global */
			if (j)
			{
				error(locgl_error);
				goto loop;
			}
			sy->sattr |= GLOBAL;
		}

		/*
		 *  If we're in as68 mode, and there's another
		 *  label, go back and handle it
		 */
		if (as68_flag && as68mode)
			goto as68label;
	}


	/*
	 *  Punt on EOL
	 */
	if (state == -3)
		goto loop;


	/*
	 *  If we're in 6502 mode and are still in need
	 *  of a mnemonic, then search for valid 6502 mnemonic.
	 */
	if (m6502 &&
		  (state < 0 || state >= 1000))
	{
#ifdef ST
		state = kmatch(opname, mpbase, mpcheck, mptab, mpaccept);
#else
		for (state = 0, p = opname; state >= 0;)
		{
			j = mpbase[state] + tolowertab[*p];
			if (mpcheck[j] != state)	/* reject, character doesn't match */
			{
				state = -1;		/* no match */
				break;
			}

			if (!*++p)
			{			/* must accept or reject at EOS */
				state = mpaccept[j];	/* (-1 on no terminal match) */
				break;
			}
			state = mptab[j];
		}
#endif

		/*
		 *  Call 6502 code generator if we found a mnemonic
		 */
		if (state >= 2000)
		{
			m6502cg(state - 2000);
			goto loop;
		}
	}


	/*
	 *  Invoke macro or complain about bad mnemonic
	 */
	if (state < 0)
	{
		if ((sy = lookup(opname, MACRO, 0)) != NULL) invokemac(sy, siz);
		else errors("unknown op '%s'", opname);
		goto loop;
	}


	/*
	 *  Call directive handlers
	 */
	if (state < 500)
	{
		(*dirtab[state])(siz);
		goto loop;
	}


	/*
	 *  Do mnemonics
	 *    o  can't deposit instrs in BSS or ABS
	 *    o  do automatic .EVEN for instrs
	 *    o  allocate space for largest possible instr
	 *    o  can't do ".b" operations with an address register
	 */
	if (scattr & SBSS)
	{
		error("cannot initialize non-storage (BSS) section");
		goto loop;
	}

	if (sloc & 1)			/* automatic .even */
		auto_even();

	if (challoc - chsize < 18)	/* make sure we have space in current chunk */
		chcheck(0L);

	m = &machtab[state - 1000];
	if (m->mnattr & CGSPECIAL)
	{				/* call special-mode handler */
		(*m->mnfunc)(m->mninst, siz);
		goto loop;
	}

	if (amode(1) < 0)		/* parse 0, 1 or 2 addr modes */
		goto loop;

	if (*tok != EOL)
		error(extra_stuff);

	amsk0 = amsktab[am0];
	amsk1 = amsktab[am1];

	/*
	 *  Catch attempts to use ".B" with an address register
	 *  (yes, this check does work at this level).
	 */
	if (siz == SIZB &&
		  (am0 == AREG || am1 == AREG))
	{
		error("cannot use '.b' with an address register");
		goto loop;
	}

	for (;;)
	{
		if ((m->mnattr & siz) &&
			  (amsk0 & m->mn0) != 0 &&
			  (amsk1 & m->mn1) != 0)
		{
			(*m->mnfunc)(m->mninst, siz);
			goto loop;
		}
		m = &machtab[m->mncont];
	}
}


/*
 *  Report error if not at EOL
 */
at_eol()
{
	if (*tok != EOL)
		error("syntax error");
}


/*
 *  .if --- start conditional assembly
 *
 */
d_if()
{
	register IFENT *rif;
	WORD eattr;
	VALUE eval;
	SYM *esym;

	/*
	 *  Alloc an IFENTRY
	 */
	if ((rif = f_ifent) == NULL) rif = (IFENT *)amem((LONG)sizeof(IFENT));
	else f_ifent = rif->if_prev;

	rif->if_prev = ifent;
	ifent = rif;

	if (!disabled)
	{
		if (expr(exprbuf, &eval, &eattr, &esym) != OK) return;
		if ((eattr & DEFINED) == 0) return error(undef_error);
		disabled = !eval;
	}
	rif->if_state = disabled;
}


/*
 *  .else --- do alternate case for .if
 *
 */
d_else()
{
	register IFENT *rif;

	rif = ifent;

	if (rif->if_prev == NULL) return error("mismatched .else");

	if (disabled) disabled = rif->if_prev->if_state;
	else disabled = 1;

	rif->if_state = disabled;
}


/*
 *  .endif --- end of conditional assembly block
 *
 *  This is also called by fpop() to pop levels of IFENTs
 *  in case a macro or include file exits early with `exitm'
 *  or `end'.
 *
 */
d_endif()
{
	register IFENT *rif;

	rif = ifent;
	if (rif->if_prev == NULL) return error("mismatched .endif");

	ifent = rif->if_prev;
	disabled = rif->if_prev->if_state;
	rif->if_prev = f_ifent;
	f_ifent = rif;
}
