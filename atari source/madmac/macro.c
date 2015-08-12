/*
 *  Macro definition and invocation
 *
 *    imacro()		initialize macro processor
 *    defmac()		define macro
 *    invokemac()	invoke macro
 *    exitmac()		exit macro
 *
 */
#include <ctype.h>
#include "as.h"
#include "sect.h"
#include "token.h"


INOBJ *a_inobj();

/*
 *  Imports
 */
extern TOKEN *tok;
extern int lnsave;
extern char lnbuf[];
extern TOKEN exprbuf[];
extern int list_flag;		/* 1, listings enabled */
SYM *lookup();
SYM *newsym();


/*
 *  Exports
 */
TOKEN **argp;			/* -> free spot in argptrs[] */
LONG curuniq;			/* current macro's unique number */
IMACRO *root_imacro;		/* -> macro in effect (if any) */
int macnum;			/* = unique number for macro definition */


/*
 *  Locals
 */
static LONG macuniq;		/* unique-per-macro number */



/*
 *  Initialize macro processor
 *
 */
imacro()
{
	macuniq = 0;
	macnum = 1;
	argp = NULL;
}


/*
 *  Global variables used by defmac() / defmac1() / defmac2()
 *  for communication.
 */
static SYM *curmac;		/* -> macro currently being defined */
static char **curmln;		/* -> previous macro line (or NULL) */
static VALUE argno;		/* formal argument count */


/*
 *  Define macro
 *
 *    macro foo arg1,arg2,...
 *     :
 *     :
 *    endm
 *
 *  Helper functions:
 *  -----------------
 *    `defmac1' adds lines of text to the macro definition
 *
 *    `defmac2' processes the formal arguments (and sticks them into
 *    the symbol table.
 *
 */
defmac()
{
	char *p;
	SYM *mac;
	SYM *arg;
	int defmac1();
	int defmac2();
	extern int mnbase[], mncheck[], mntab[], mnaccept[];

	/*
	 *  Setup entry in symbol table,
	 *   make sure the macro isn't a duplicate entry, and that
	 *   it doesn't override any processor mnemonic or assembler directive.
	 */
	if (*tok++ != SYMBOL) return error("missing symbol");
	p = (char *)*tok++;
	if (lookup(p, MACRO, 0) != NULL)
		return error("multiple macro definition");
	if (kmatch(p, mnbase, mncheck, mntab, mnaccept) >= 0)
		return error("macro definition cannot override directive or mnemonic");

	curmac = mac = newsym(p, MACRO, 0);
	mac->svalue = 0;
	mac->sattr = macnum++;

	/*
	 *  Parse and define formal arguments in symbol table
	 */
	if (*tok != EOL)
	{
		argno = 0;
		symlist(defmac2);
		at_eol();
	}

	/*
	 *  Suck in the macro definition;
	 *  we're looking for an ENDM symbol on a line
	 *  by itself to terminate the definition.
	 */
	curmln = NULL;
	lncatch(defmac1, "endm ");
}


/*
 *  Add a formal argument to a macro definition
 *
 */
defmac2(argname)
register char *argname;
{
	register SYM *arg;

	if (lookup(argname, MACARG, (int)curmac->sattr) != NULL)
		return error("multiple formal argument definition");
	arg = newsym(argname, MACARG, (int)curmac->sattr);
	arg->svalue = argno++;

	return OK;
}


/*
 *  Add a line to a macro definition;
 *  also print lines to listing file (if enabled).
 *
 *  The last line of the macro (containing .endm) is
 *  not included in the macro.  A label on that line
 *  will be lost.
 *
 *  `endflg' is misleading here.  It is -1 for all lines
 *  but the last one (.endm), when it is 0.
 *
 */
defmac1(ln, endflg)
char *ln;
int endflg;
{
	register PTR p;
	LONG len;

	if (list_flag)
	{
		listeol();		/* flush previous source line */
		lstout('.');		/* mark macro definition with period */
	}

	if (endflg)
	{
		len = strlen(ln) + 1 + sizeof(LONG);
		p.cp = amem(len);
		*p.lp = 0;
		strcpy(p.cp + sizeof(LONG), ln);

		/*
		 *  Link line of text onto end of list
		 */
		if (curmln == NULL)
			curmac->svalue = (VALUE)p.cp;
		else
			*curmln = p.cp;
		curmln = (char **)p.cp;
		return 1;			/* keep looking */
	}
	else return 0;		/* stop looking at the end */
}


/*
 *  Hand off lines of text to the function `lnfunc' until a line
 *  containing one of the directives in `dirlist' is encountered.
 *  Return the number of the keyword encountered (0..n)
 *
 *  `dirlist' contains null-seperated terminated keywords.  A final
 *  null terminates the list.  Directives are compared to the keywords
 *  without regard to case.
 *
 *  If `lnfunc' is NULL, then lines are simply skipped.
 *  If `lnfunc' returns an error, processing is stopped.
 *
 *  `lnfunc' is called with an argument of -1 for every line but the
 *  last one, when it is called with an argument of the keyword number
 *  that caused the match.
 *
 */
lncatch(lnfunc, dirlist)
int (*lnfunc)();		/* handoff function */
char *dirlist;		/* list of directives to look for */
{
	register char *p;
	register int k;

	if (lnfunc != NULL)
		++lnsave;			/* tell tokenizer to keep lines */

	for (;;)
	{
		if (tokln() == TKEOF)
		{
			errors("encountered end-of-file looking for '%s'", dirlist);
			fatal("cannot continue");
		}

		/*
		 *  Test for end condition.  Two cases to handle:
		 *
		 *            <directive>
		 *    symbol: <directive>
		 *
		 */
		p = NULL;
		k = -1;

		if (*tok == SYMBOL)
			if ((tok[2] == ':' || tok[2] == DCOLON))
			{
				if (tok[3] == SYMBOL) /* label: symbol */
					p = (char *)tok[4];
			}
			else p = (char *)tok[1]; /* symbol */

		if (p != NULL)
		{
			if (*p == '.')	/* ignore leading '.'s */
				++p;
			k = kwmatch(p, dirlist);
		}

		/*
		 *  Hand-off line to function
		 *  if it returns 0, and we found a keyword, stop looking.
		 *  if it returns 1, hand off the line and keep looking.
		 */
		if (lnfunc != NULL)
			k = (*lnfunc)(lnbuf, k);

		if (!k)
			break;
	}

	if (lnfunc != NULL)
		--lnsave;			/* tell tokenizer to stop keeping lines */
}


/*
 *  See if the string `kw' matches one of the keywords
 *  in `kwlist'.  If so, return the number of the keyword
 *  matched.  Return -1 if there was no match.
 *
 *  Strings are compared without regard for case.
 *
 *  This should be re-coded in native code for speed.
 *
 */
/*$SPEEDY$*/
kwmatch(kw, kwlist)
char *kw;
register char *kwlist;
{
	register char *p;
	register char c1;
	register char c2;
	int k;

	for (k = 0; *kwlist; ++k)
	{
		for (p = kw;;)
		{
			c1 = *kwlist++;
			c2 = *p++;

			if (c2 >= 'A' &&
				  c2 <= 'Z')
				c2 += 32;

			if (c1 == ' ' && c2 == EOS)
				return k;

			if (c1 != c2)
				break;
		}

		/*
		 *  Skip to beginning of next keyword in `kwlist'
		 */
		while (*kwlist &&
			   *kwlist != ' ')
			++kwlist;
		if (*kwlist== ' ')
			++kwlist;
	}

	return -1;
}


/*
 *  Invoke a macro
 *    o  parse, count and copy arguments
 *    o  push macro's string-stream
 *
 */
invokemac(mac, siz)
SYM *mac;
WORD siz;
{
	register TOKEN *p;
	register IMACRO *imacro;
	register INOBJ *inobj;
	register dry_run;
	WORD nargs;
	WORD arg_siz;
	TOKEN **argptr;
	TOKEN *beg_tok;

	inobj = a_inobj(SRC_IMACRO);	/* alloc and init IMACRO */
	imacro = inobj->inobj.imacro;
	imacro->im_siz = siz;
	nargs = 0;
	beg_tok = tok;

	for (dry_run = 1;; --dry_run)
	{
		for (tok = beg_tok; *tok != EOL;)
		{
			if (dry_run) ++nargs;
			else *argptr++ = p;

			while (*tok != ',' && *tok != EOL)
			{
				if (*tok == '\\' && tok[1] != EOL) ++tok;
				switch ((int)*tok)
				{
					case CONST:
					case SYMBOL:
					case ACONST:
						if (dry_run) arg_siz += sizeof(TOKEN), ++tok;
						else *p++ = *tok++;
						/*FALLTHROUGH*/

					default:
						if (dry_run) arg_siz += sizeof(TOKEN), ++tok;
						else *p++ = *tok++;
						break;
				}
			}

			if (dry_run) arg_siz += sizeof(TOKEN);
			else *p++ = EOL;

			if (*tok == ',') ++tok;
		}

		/*
		 *  Allocate space for argument ptrs and so on
		 *   and then go back and construct the arg frame.
		 */
		if (dry_run) {
			if (nargs != 0) p = (TOKEN *)malloc((LONG)arg_siz);
			argptr = (TOKEN **)malloc((LONG)((nargs + 1) * sizeof(LONG)));
			*argptr++ = (TOKEN *)argp;
			argp = argptr;
		} else break;
	}


	/*
	 *  Setup imacro:
	 *    o  #arguments;
	 *    o  -> macro symbol;
	 *    o  -> macro definition string list;
	 *    o  save 'curuniq', to be restored when the macro pops;
	 *    o  bump `macuniq' counter and set 'curuniq' to it;
	 */
	imacro->im_nargs = nargs;
	imacro->im_macro = mac;
	imacro->im_nextln = (LONG *)mac->svalue;
	imacro->im_olduniq = curuniq;
	curuniq = ++macuniq;

#ifdef DO_DEBUG
	DEBUG
	{
		printf("nargs=%d\n", nargs);
		for (nargs = 0; nargs < imacro->im_nargs; ++nargs)
		{
			printf("arg%d=", nargs);
			dumptok(argp[imacro->im_nargs - nargs - 1]);
		}
	}
#endif
	return OK;

	/*
	 *  Complain about macro overflow
	 */
overflow:
	fatal("macro stack overflow");
	/*NOTREACHED*/
}


/*
 *  Exit from a macro
 *    o  pop any intervening include files and repeat blocks;
 *    o  restore argument stack;
 *    o  pop the macro.
 *
 */
exitmac()
{
	register IMACRO *imacro;
	register TOKEN **p;
	extern INOBJ *cur_inobj;

	/*
	 *  Pop intervening include files and .rept blocks
	 */
	while (cur_inobj != NULL &&
		   cur_inobj->in_type != SRC_IMACRO)
		fpop();

	if (cur_inobj == NULL)
		fatal("too many ENDMs");

	/*
	 *  Restore
	 *    o  old arg context
	 *    o  old unique number
	 *  ...and then pop the macro.
	 */
	imacro = cur_inobj->inobj.imacro;
	curuniq = imacro->im_olduniq;

	if (imacro->im_nargs) free(*argp);
	p = --argp;
	argp = (TOKEN **)*argp;
	free(p);

	fpop();
}


/* ---------------- .rept/.endr ---------------- */


static LONG *firstrpt;		/* first .rept line */
static LONG *nextrpt;		/* last .rept line */
static int rptlevel;		/* .rept nesting level */


/*
 *  Define a .rept block,
 *  this gets hairy because they can be nested.
 *
 */
defrept()
{
	register INOBJ *inobj;
	register IREPT *irept;
	VALUE eval;
	int defr1();
	extern abs_expr();

	/* evaluate repeat expression */
	if (abs_expr(&eval) != OK)
		return ERROR;

	/* suck in lines for .rept block */
	firstrpt = NULL;
	nextrpt = NULL;
	rptlevel = 1;
	lncatch(defr1, "endr rept ");

	/* alloc and init input object */
	if (firstrpt)
	{
		inobj = a_inobj(SRC_IREPT);
		irept = inobj->inobj.irept;
		irept->ir_firstln = firstrpt;
		irept->ir_nextln = NULL;
		irept->ir_count = eval;
	}
}


/*
 *  Add lines to a .rept definition
 *
 */
defr1(ln, kwno)
char *ln;
int kwno;
{
	register LONG len;
	register LONG *p;

	if (list_flag)
	{
		listeol();		/* flush previous source line */
		lstout('#');		/* mark this a 'rept' block */
	}

	switch (kwno)
	{
		case 0:			/* .endr */
			if (--rptlevel == 0)
				return 0;
			goto addln;

		case 1:			/* .rept */
			++rptlevel;

		default:
addln:
			len = strlen(ln) + 1 + sizeof(LONG);
			p = (LONG *)malloc(len);
			*p = 0;
			strcpy((char*)(p+1), ln);
			if (nextrpt == NULL)
				firstrpt = p;
			else *nextrpt = (LONG)p;
			nextrpt = p;
			return rptlevel;
	}
}
