/*
 *  Directive handling
 */
#include "as.h"
#include "sect.h"
#define DEF_KW
#include "kwtab.h"


/*
 *  External strings for common error messages
 */
extern char *fwd_error;
extern char *rel_error;
extern char *abs_error;
extern char *range_error;
extern char *undef_error;
extern char *locgl_error;
extern char *comma_error;
extern char in_6502mode[];

/*
 *  Imports
 */
extern int debug;		/* 1, debugging messages */
extern TOKEN *tok;		/* -> current token */
extern TOKEN a0expr[];		/* postfix expression for addr mode 0 */
extern int as68_flag;		/* 1, AS68 kludge mode for Alcyon back-end */
extern int list_flag;
extern int listing;
extern int just_bss;		/* 1, just BSS kludge */
extern int m6502;		/* 1, assembler in 6502 mode */
extern SYM *lab_sym;		/* -> label symbol on current line (or NULL) */

extern SYM *lookup(), *newsym(); /* symbol lookup and creation */
extern int fpop();		/* pop an input level */


/*
 *  Exports
 */
TOKEN exprbuf[128];		/* expression buffer */


/*
 *  Forward function definitions
 */

int	d_unimpl(), d_even(), d_6502(), d_68000(), d_bss(), d_data(),
	d_text(), d_abs(), d_comm(), d_dc(), d_ds(), d_dcb(), d_reg(),
	d_disable(), d_enable(), d_globl(), d_xdef(),
	d_assert(), d_if(), d_endif(), d_iif(), d_include(), d_end(),
	d_macro(), exitmac(), d_endm(), d_list(), d_nlist(), d_rept(),
	d_endr(), d_struct(), d_ends(), d_title(), d_subttl(), eject(),
	d_error(), d_warn(), d_org(), d_init(), d_cargs(), d_undmac();

/*
 *  External function definitions
 *
 *	function		file it's in
 *	---------		-------------
 */
extern int
	d_goto();		/* token.c */


/*
 *  Directive handler table
 */
int (*dirtab[])() = {
	d_org,			/* 0 org */
	d_even,			/* 1 even */
	d_6502,			/* 2 .6502 */
	d_68000,		/* 3 .68000 */
	d_bss,			/* 4 bss */
	d_data,			/* 5 data */
	d_text,			/* 6 text */
	d_abs,			/* 7 abs */
	d_comm,			/* 8 comm */
	d_init,			/* 9 init */
	d_cargs,		/* 10 cargs */
	d_goto,			/* 11 goto */
	d_dc,			/* 12 dc */
	d_ds,			/* 13 ds */
	d_undmac,		/* 14 undefmac */
	d_unimpl,		/* 15 */
	d_unimpl,		/* 16 */
	d_dcb,			/* 17 dcb */
	d_unimpl,		/* 18* set */
	d_unimpl,		/* 19* reg */
	d_unimpl,		/* 20 dump */
	d_unimpl,		/* 21 load */
	d_unimpl,		/* 22 disable */
	d_unimpl,		/* 23 enable */
	d_globl,		/* 24 globl */
	d_unimpl,		/* 25 extern */
	d_unimpl,		/* 26 xref */
	d_unimpl,		/* 27 xdef */
	d_assert,		/* 28 assert */
	d_unimpl,		/* 29* if */
	d_unimpl,		/* 30* endif */
	d_unimpl,		/* 31* endc */
	d_unimpl,		/* 32* iif */
	d_include,		/* 33 include */
	fpop,			/* 34 end */
	d_unimpl,		/* 35* macro */
	exitmac,		/* 36* exitm */
	d_unimpl,		/* 37* endm */
	d_list,			/* 38 list */
	d_nlist,		/* 39 nlist */
	d_unimpl,		/* 40* rept */
	d_unimpl,		/* 41* endr */
	d_unimpl,		/* 42 struct */
	d_unimpl,		/* 43 ends */
	d_title,		/* 44 title */
	d_subttl,		/* 45 subttl */
	eject,			/* 46 eject */
	d_unimpl,		/* 47 error */
	d_unimpl,		/* 48 warn */
};


d_unimpl()
{
  return error("unimplemented directive");
}


/*
 *  Return absolute (not TDB) and defined expression
 *  or return an error.
 *
 */
abs_expr(a_eval)
     VALUE *a_eval;
{
  WORD eattr;

  if (expr(exprbuf, a_eval, &eattr, NULL) < 0)
    return ERROR;
  if (!(eattr & DEFINED))
    return error(undef_error);
  if (eattr & TDB)
    return error(rel_error);

  return OK;
}


/*
 *  Do auto-even.  This must be called ONLY if 'sloc' is odd.
 *
 *  This is made hairy because, if there was a label
 *  on the line, we also have to adjust its value.
 *
 *  This won't work with more than one label on the line, which
 *  is OK since multiple labels are only allowed in AS68 kludge
 *  mode, and the C compiler is VERY paranoid and uses ".even"
 *  whenever it can.
 *
 */
auto_even()
{
  if (cursect != M6502)
    {
      if (scattr & SBSS)
	++sloc;			/* bump BSS section */
      else
	{
	  D_byte(0)		/* deposit 0.b in non-BSS */
	}

      if (lab_sym != NULL)	/* bump label if we have to */
	++lab_sym->svalue;
    }
}
 

/*
 *  Hand symbols in a symbol-list to a function
 *  (kind of like mapcar...)
 *
 */
symlist(func)
     int (*func)();
{
    register char *em = "symbol list syntax";

    for (;;) {
	if (*tok != SYMBOL) return error(em);
	if ((*func)(tok[1]) != OK) break;
	tok += 2;
	if (*tok == EOL) break;
	if (*tok != ',') return error(em);
	++tok;
    }
}


/*
 *  .include "filename"
 */
d_include()
{
  register int j;
  register int i;
  register char *fn;
  register char *s;
  char buf[128];
  char buf1[128];

  if (*tok == STRING)		/* leave strings ALONE */
    fn = (char *)*++tok;
  else if (*tok == SYMBOL)
    {				/* try to append ".s" to symbols */
      strcpy(buf, (char *)*++tok);
      fext(buf, ".s", 0);
      fn = &buf[0];
    }				/* punt if no STRING or SYMBOL */
  else return error("missing filename");

  /*
   *  Make sure the user didn't try anything like:
   *
   *		.include equates.s
   *
   *  ... which won't work.
   */
  if (*++tok != EOL) return error("extra stuff after filename -- enclose it in quotes");

  /*
   *  Attempt to open the include file in the current directory,
   *  then (if that failed) try list of include files passed in the
   *  enviroment string or by the "-d" option.
   */
  if ((j = open(fn, 0)) < 0)
    {
      for (i = 0; nthpath("MACPATH", i, buf1) != 0; ++i)
	{
	  j = strlen(buf1);
	  if (j > 0 &&		/* append path char if necessary */
	      buf1[j-1] != SLASHCHAR)
	    strcat(buf1, SLASHSTRING);
	  strcat(buf1, fn);
	  if ((j = open(buf1, 0)) >= 0)
	    goto allright;
	}

      return errors("cannot open: \"%s\"", fn);
    }

 allright:
  include(j, fn);
}




/*
 *  .assert expression [, expression...]
 */
d_assert(siz)
     WORD siz;			/* (unused) */
{
  WORD eattr;
  VALUE eval;

  for (; expr(exprbuf, &eval, &eattr, NULL) == OK; ++tok)
    {
      if (!(eattr & DEFINED))
	return error("forward or undefined .assert");
      if (!eval)
	return error("assert failure");
      if (*tok != ',')
	break;
    }
  at_eol();
}


/*
 *  .globl symbol [, symbol]
 *  <<<cannot make local symbols global>>>
 */
d_globl(siz)
     WORD siz;
{
  int globl1();

  if (m6502)
    return error(in_6502mode);
  symlist(globl1);
}


globl1(p)
  char *p;
{
  register SYM *sy;

  if (*p == '.')
    return error("cannot .globl local symbol");
  if ((sy = lookup(p, LABEL, 0)) == NULL)
    {
      sy = newsym(p, LABEL, 0);
      sy->svalue = 0;
      sy->sattr = GLOBAL;
    }
  else sy->sattr |= GLOBAL;

  return OK;
}


/*
 *   .abs [expression]
 */
d_abs()
{
  VALUE eval;

  if (m6502)
    return error(in_6502mode);

  savsect();
  if (*tok == EOL)
    eval = 0;
  else
    if (abs_expr(&eval) != OK)
      return;

  switchsect(ABS);
  sloc = eval;
}


d_text()
{
  if (m6502)
    return error(in_6502mode);

  if (cursect != TEXT)
    {
      savsect();
      switchsect(TEXT);
    }
}


d_data()
{
  if (m6502)
    return error(in_6502mode);

  if (cursect != DATA)
    {
      savsect();
      switchsect(DATA);
    }
}


d_bss()
{
  if (m6502)
    return error(in_6502mode);

  if (cursect != BSS)
    {
      savsect();
      switchsect(BSS);
    }
}


/*
 *  .ds[.size] expression
 *
 */
d_ds(siz)
     register WORD siz;
{
  VALUE eval;

  /*
   *  This gets kind of stupid.  This directive is disallowed
   *  in normal 68000 mode ("for your own good!"), but is permitted
   *  for 6502 and Alcyon-compatibility modes.
   *
   *  For obvious reasons, no auto-even is done in 8-bit processor modes.
   *
   */
  if (cursect != M6502)
    {
	if (as68_flag == 0 && (scattr & SBSS) == 0)
	  return error(".ds permitted only in BSS");

	if (siz != SIZB && (sloc & 1)) /* automatic .even */
	  auto_even();
    }

  if (abs_expr(&eval) != OK) return;

  /*
   *  In non-TDB section (BSS, ABS and M6502) just advance the
   *  location counter appropriately.  In TDB sections, deposit
   *  (possibly large) chunks of zeroed memory....
   *
   */
  if ((scattr & SBSS) || cursect == M6502)
    {
	listvalue(eval);
	eval *= siz;
	sloc += eval;
	if (cursect == M6502) chptr += eval;
	just_bss = 1;		/* no data deposited (eight-bit CPU mode) */
    }
  else
    {
	dep_block(eval, siz, (VALUE)0, (WORD)(DEFINED|ABS), NULL);
    }

  at_eol();
}



/*
 *  dc.b
 *  dc.w / dc
 *  dc.l
 *
 */
d_dc(siz)
     register WORD siz;
{
  WORD eattr;
  VALUE eval;
  register WORD tdb;
  register WORD defined;
  register LONG i;
  register char *p;

  if ((scattr & SBSS) != 0)
    return error("illegal initialization of section");

  if (cursect != M6502 &&	/* not in microprocessor section */
      siz != SIZB &&		/* automatic .even */
      sloc & 1)
    auto_even();

  for (;; ++tok)
    {
      /*
       *  dc.b 'string' [,] ...
       */
      if (siz == SIZB &&
	  *tok == STRING &&
	  (tok[2] == ',' || tok[2] == EOL))
	{
	  i = strlen((const char*)tok[1]);
	  if ((challoc - chsize) < i)
	    chcheck(i);
	  for (p = (char *)tok[1]; *p != EOS; ++p)
	    D_byte(*p);
	  tok += 2;
	  goto comma;
	}

      /*
       * dc.x <expression>
       */
      if (expr(exprbuf, &eval, &eattr, NULL) != OK)
	return;
      tdb = eattr & TDB;
      defined = eattr & DEFINED;
      if ((challoc - chsize) < 4)
	chcheck(4L);

      switch (siz)
	{
	case SIZB:
	  if (!defined)
	    {
	      fixup(FU_BYTE|FU_SEXT, sloc, exprbuf);
	      D_byte(0);
	    }
	  else
	    {
	      if (tdb)
		return error("non-absolute byte value");
	      if (eval + 0x100 >= 0x200)
		return error(range_error);
	      D_byte(eval);
	    }
	  break;
	  
	case SIZW:
	case SIZN:
	  if (!defined)
	    {
	      fixup(FU_WORD|FU_SEXT, sloc, exprbuf);
	      D_word(0);
	    }
	  else
	    {
	      if (tdb)
		rmark(cursect, sloc, tdb, MWORD, NULL);
	      if (eval + 0x10000 >= 0x20000)
		return error(range_error);

	      /* deposit 68000 or 6502 (byte-reversed) word */
	      if (cursect != M6502)
		{
		  D_word(eval);
		}
	      else
		{
		  D_rword(eval);
		}
	    }
	  break;
	  
	case SIZL:
	  if (m6502)
	    return error(in_6502mode);

	  if (!defined)
	    {
	      fixup(FU_LONG, sloc, exprbuf);
	      D_long(0);
	    }
	  else
	    {
	      if (tdb)
		rmark(cursect, sloc, tdb, MLONG, NULL);
	      D_long(eval);
	    }	
	  break;
	}
      
    comma:
      if (*tok != ',')
	break;
    }
  at_eol();
}


/*
 *  Adjust location to an EVEN value
 */
d_even(siz)
     WORD siz;
{
  if (m6502)
    return error(in_6502mode);

  if (sloc & 1)
    if ((scattr & SBSS) == 0)
      {
	D_byte(0);
      }
    else ++sloc;
}


/*
 *  dcb[.siz] expr1,expr2
 *
 *  Make 'expr1' copies of 'expr2'
 */
d_dcb(siz)
     WORD siz;
{
  VALUE evalc, eval;
  WORD eattr;

  if ((scattr & SBSS) != 0)
    return error("illegal initialization of section");

  if (abs_expr(&evalc) != OK)
    return;

  if (*tok++ != ',')
    return error("missing comma");

  if (expr(exprbuf, &eval, &eattr, NULL) < 0)
    return;

  if (cursect != M6502 &&	/* not in microprocessor section */
      siz != SIZB &&		/* automatic .even */
      sloc & 1)
    auto_even();

  dep_block(evalc, siz, eval, eattr, exprbuf);
}


/*
 *  Generalized initialization directive
 *
 *    .init[.siz] [#count,] expression [.size] , ...
 *
 *  The size suffix on the ".init" directive becomes the default
 *  size of the objects to deposit.  If an item is preceeded with
 *  a sharp (immediate) sign and an expression, it specifies a
 *  repeat count.  The value to be deposited may be followed by
 *  a size suffix, which overrides the default size.
 *
 */
d_init(def_siz)
     register WORD def_siz;
{
  NOREG VALUE count;
  NOREG VALUE eval;
  NOREG WORD eattr;
  register WORD siz;

  if ((scattr & SBSS) != 0)
    return error(".init not permitted in BSS or ABS");

  for (;;)
    {
      /*
       *  Get repeat count (defaults to 1)
       */
      if (*tok == '#')
	{
	  ++tok;
	  if (abs_expr(&count) != OK)
	    return;
	  if (*tok++ != ',')
	    return error(comma_error);
	}
      else count = 1;

      /*
       *  Evaluate expression to deposit
       */
      if (expr(exprbuf, &eval, &eattr, NULL) < 0)
	return;

	  switch ((int)*tok++)		/* determine size of object to deposit */
	  {
		  case DOTB:
			  siz = SIZB;
			  break;

		  case DOTW:
			  siz = SIZB;
			  break;

		  case DOTL:
			  siz = SIZL;
			  break;

		  default:
			  siz = def_siz;
			  --tok;
			  break;
	  }

	  dep_block(count, siz, eval, eattr, exprbuf);

	  switch ((int)*tok)
	  {
		  case EOL:
			  return;

		  case ',':
			  ++tok;
			  continue;

		  default:
			  return error(comma_error);
	  }
	}
}


/*
 *  Deposit 'count' values of size 'siz'
 *  in the current (non-BSS) segment.
 *
 */
dep_block(count, siz, eval, eattr, exprbuf)
VALUE count;		/* #times to repeat value */
WORD siz;			/* size of value */
register VALUE eval;	/* value to deposit */
WORD eattr;		/* value's attributes */
TOKEN *exprbuf;		/* expression buffer (for forward values) */
{
	register WORD tdb;
	register WORD defined;

	tdb = eattr & TDB;
	defined = eattr & DEFINED;

	while (count--)
	{
		if ((challoc - chsize) < 4)
			chcheck(4L);

		switch (siz)
		{
			case SIZB:
				if (!defined)
				{
					fixup(FU_BYTE|FU_SEXT, sloc, exprbuf);
					D_byte(0);
				}
				else
				{
					if (tdb)
						return error("non-absolute byte value");
					if (eval + 0x100 >= 0x200)
						return error(range_error);
					D_byte(eval);
				}
				break;

			case SIZW:
			case SIZN:
				if (!defined)
				{
					fixup(FU_WORD|FU_SEXT, sloc, exprbuf);
					D_word(0);
				}
				else
				{
					if (tdb)
						rmark(cursect, sloc, tdb, MWORD, NULL);
					if (eval + 0x10000 >= 0x20000)
						return error(range_error);

					/* deposit 68000 or 6502 (byte-reversed) word */
					if (cursect != M6502)
					{
						D_word(eval);
					}
					else
					{
						D_rword(eval);
					}
				}
				break;

			case SIZL:
				if (m6502)
					return error(in_6502mode);

				if (!defined)
				{
					fixup(FU_LONG, sloc, exprbuf);
					D_long(0);
				}
				else
				{
					if (tdb)
						rmark(cursect, sloc, tdb, MLONG, NULL);
					D_long(eval);
				}	
				break;
		}
	}
}


/*
 *  .comm symbol, size
 *
 */
d_comm()
{
	register SYM *sym;
	register char *p;
	WORD eattr;
	VALUE eval;

	if (m6502)
		return error(in_6502mode);

	if (*tok != SYMBOL)
		return error("missing symbol");
	p = (char *)tok[1];
	tok += 2;

	if (*p == '.')		/* cannot .comm a local symbol */
		return error(locgl_error);

	if ((sym = lookup(p, LABEL, 0)) == NULL)
		sym = newsym(p, LABEL, 0);
	else
	{
		if (sym->sattr & DEFINED)
			return error(".comm symbol already defined");
	}

	sym->sattr = GLOBAL|COMMON|BSS;
	if (*tok++ != ',')
		return error(comma_error);

	if (abs_expr(&eval) != OK)	/* parse size of common region */
		return;
	sym->svalue = eval;		/* install common symbol's size */
	at_eol();
}


/*
 *  .list --- turn listing on
 *
 */
d_list()
{
	if (list_flag)
		++listing;
}


/*
 *  .nlist --- turn listing off
 *
 */

d_nlist()
{
	if (list_flag)
		--listing;
}


/*
 *  .68000 --- back to 68000 TEXT segment
 *
 */
d_68000()
{
	savsect();
	switchsect(TEXT);
}


/*
 *  .cargs [#offset], symbol[.size], ...
 *
 *  Lists of registers may also be mentioned; they just
 *  take up space.  Good for "documentation" purposes.
 *
 *    .cargs a6,.arg1, .arg2, .arg3...
 *
 *  The symbols are ABS and EQUATED.
 *
 */
d_cargs(siz)
WORD siz;
{
	NOREG VALUE eval;
	NOREG WORD rlist;
	register SYM *sy;
	register char *p;
	register int env;
	register int i;
	extern int curenv;
	SYM *lookup();
	SYM *newsym();

	if (*tok == '#')
	{
		++tok;
		if (abs_expr(&eval) != OK)
			return;
		if (*tok == ',')		/* eat comma if it's there */
			++tok;
	}
	else eval = 4;

	for (;;)
	{
		if (*tok == SYMBOL)
		{
			p = (char *)tok[1];
			if (*p == '.')
				env = curenv;
			else env = 0;

			sy = lookup(p, LABEL, env);
			if (sy == NULL)
			{
				sy = newsym(p, LABEL, env);
				sy->sattr = 0;
			}
			else if (sy->sattr & DEFINED)
				return errors("multiply-defined label '%s'", p);

			/*
			 *  Put symbol in "order of definition" list
			 */
			if (!(sy->sattr & SDECLLIST)) sym_decl(sy);

			sy->sattr |= ABS|DEFINED|EQUATED;
			sy->svalue = eval;
			tok += 2;

			switch ((int)*tok)
			{
				case DOTL:
					eval += 2;

				case DOTB:
				case DOTW:
					++tok;
			}
			eval += 2;
		}
		else if (*tok >= KW_D0 && *tok <= KW_A7)
		{
			if (reglist(&rlist) < 0)
				return;
			for (i = 0; i++ < 16; rlist >>= 1)
				if (rlist & 1)
					eval += 4;
		}
		else switch ((int)*tok)
		{
			case KW_USP:
			case KW_SSP:
			case KW_PC:
				eval += 2;
				/*FALLTHROUGH*/

			case KW_SR:
			case KW_CCR:
				eval += 2;
				++tok;
				break;

			case EOL:
				return;

			default:
				return error(".cargs syntax");
		}

		if (*tok == ',')
			++tok;
	}
}


/*
 *  Undefine a macro
 *    .undefmac macname [, macname...]
 */
d_undmac()
{
	int undmac1();

	symlist(undmac1);
}

undmac1(p)
char *p;
{
	register SYM *sy;

	/*
	 *  If the macro symbol exists, cause it to dissappear
	 */
	if ((sy = lookup(p, MACRO, 0)) != NULL) sy->stype = SY_UNDEF;
	return OK;
}
