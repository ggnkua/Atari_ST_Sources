/*
	cs.c of gulam -- control structures

	copyright (c) 1987 pm@Case
*/

#define	WS1	1

#include "gu.h"
#include "ue.h"

uchar	*csexp();		/* exported from here		*/

#define	BOT	0
#define	NEW	1
#define	BGNIF	2
#define	SKIPIF	3
#define	WHILE	4
#define	FOREACH	5

local	uchar	ZERO[]	= "0";
local	uchar	ONE[]	= "1";
local	uchar	*dummy;

typedef struct	STE
{	int		op;
	int		tf;
	int		nn;
	LINE		*lp;
	WS		*wp;
	uchar		*varp;	/* nn, wp, varp used only for FOREACH	*/
	struct STE 	*next;
}	STE;

#define	MXsnl		25		/* dflt depth of batch file nesting */

local	LINE	*curcmdlp;
local	STE	stbot	= {BOT, TRUE, 0, NULL, NULL, NULL, NULL};
local	STE	*stp	= &stbot;
local	int	snl	= 0;
local	int	lpagain	= 0;	/* 0, 1, or 2			*/

	local
stpush(op, f)
register int	op;
register uchar	*f;
{	register STE	*s;

	state = (f? atoi(f) : 0) != 0;
	s = (STE *) gmalloc(sizeof(STE));
	if (s)
	{	s->op	= op;
		s->tf	= state;
		s->nn	= 0;
		s->lp	= curcmdlp;
		s->varp	= NULL;
		s->wp	= NULL;
		s->next = stp;
		stp = s;
}	}

/* pop one element (or give back the top).  stp is never == NULL. */

	local	STE	*
stpop()
{	register STE	*s;

	s   = stp;
	if (s != &stbot)
	{	stp = s->next;
		if (s->wp) freews(s->wp);
		if (s->varp) gfree(s->varp);
		gfree(s);
	}
	state = stp->tf;
	return s;
}

	local
stfree()
{	register STE	*s;
	register int	op;

	for (;;)
	{	op = stpop()->op;
		if (op == NEW || op == BOT) break;
}	}

inbatchfile()
{	return (snl > 0);
}

csexit(n)
register int	n;
{
	lpagain = 2;	valu = n;
}

csexecbuf(bp)
register BUFFER	*bp;
{
	register uchar	*q, c, i;
	LINE		*lp, *slp;
	int		sfda[4];
	extern	int	fda[];

	for (i = 0; i < 4; i++) {sfda[i] = fda[i]; fda[i] = MINFH-1;}
	slp = curcmdlp;
	snl ++; stpush(NEW, (stp->tf? ONE : ZERO));
	for (lp = lforw(bp->b_linep); lp != bp->b_linep;)
	{	if (useraborted()) {valu = -3; goto ret;}
		q = strdup(makelnstr(lp));
		if (varnum("batch_echo"))  userfeedback(q, 0);
		curcmdlp = lp; lpagain = 0;
		processcmd(q, 0);	/* 0 ==> don't put cmd in history */
		if (lpagain == 2) goto ret;
		lp = (lpagain? curcmdlp : lforw(curcmdlp));
	}
	valu = 0;

	ret:
	snl --; 		/* stfree pops to the (NEW, NULL);	*/
	stfree();		/* user's ^C may have brought us here */
	curcmdlp = slp;
	for (i = 0; i < 4; i++)	fda[i] = sfda[i];
}

batch(p, cmdln, envp)		/* take commands from file given by p	*/
uchar *p, *cmdln, *envp;
{
	extern   BUFFER	*opentempbuf();	/* see misc.c		*/

	register uchar	*q;
	register int	n;
	register BUFFER	*bp;
	int		dummy;
	extern	long	_stksize;

	valu	= -1;
	if (p == NULL || *p == '\000' || flnotexists(p))
		{ emsg = "shell file not found"; return -33;}
	if (stackoverflown(512)) return -1;
	if ((bp = opentempbuf(p))==NULL)
		{emsg = "is shell file nesting too deep?"; return -1;}
	/* do puts(CRLF) because of the (Read bb bytes in nn lines) mesg */
	userfeedback(ES, 1);
	/* cmdln[0] == length */
	q = (cmdln? str3cat(p, " ", cmdln+1) : NULL);
	pushws(lex(q, DELIMS, TKN2));  gfree(q);

	csexecbuf(bp);

	closebuf(bp);
	popargws();
	return valu;
}

/* Predicate on file name: c is in {e, f, d, h, v, m, r} */

	uchar *
fnmpred(c, p)
register uchar c, *p;
{	register int	a;
	register DTA	*dta;

	if ((p == NULL) || flnotexists(p)) a = 0;
	else if (c == 'e') a = 1;
	else
	{ dta = (DTA *) gfgetdta(); a = dta->attr;
	  if (c == 'd') a &= 0x10;		/* dir		*/
	  else if (c == 'f') a  = !(a & 0x10);	/* ord file	*/
	  else if (c == 'h') a &= 0x06;		/* hidden file	*/
	  else if (c == 'v') a &= 0x08;		/* volume	*/
	  else if (c == 'm') a &= 0x20;		/* archived	*/
	  else a = 0;
	}
	return (a? ONE : ZERO);
}

/* atom ::= number | filename  | filepred | { exp } | ! atom */

	local uchar *
atom(p)
register uchar	*p;
{	register uchar	c, *r;
	uchar		*nextword;

	c = *p;
	if (c == '{')
	{	r = csexp(lexgetword(), &nextword);
		if (*nextword != '}')	emsg = "missing }";
	}
	else
	{	if (('0' <= c) && (c <= '9')) r = p;
		else if (c == '-') r = fnmpred(p[1], lexgetword());
		else if (c == '!')
		{	r = atom(lexgetword());
			r = (r && atoi(r)? ZERO: ONE) ;
		}
		else r = p;
		r = strdup(r);
	}
	return r;
}

/* Compute the arithmetic expression [arithexp ::= exp using +-/%*]
Exp with no operators, ie an atom, is a special case because we want
the string form of the atom (eg as for "blah" in "set s blah").  */

	local uchar *
arithexp(p, nextword)
register uchar	*p, **nextword;
{	register uchar	*q, *r;
	register long	i, nr;
	register int	niter;
	register uchar	op;

	niter = 0; i = 0L; op = '+'; *nextword = ES;
	while (p && *p)
	{ r = atom(p);	  if (niter++ == 0) q = strdup(r);
	  if (r) {nr = atoi(r);  gfree(r);} else nr = 0L;
	  switch (op) {
	  case '+'	: i += nr; break;
	  case '-'	: i -= nr; break;
	  case '*'	: i *= nr; break;
	  case '/'	: i = (nr != 0? i/nr : 0x7FFF); break;
	  case '%'	: i = (nr != 0? i%nr : 0x7FFF); break;
	  }
	  *nextword = lexgetword();  op = **nextword;
	  if (rindex("+-/*%", op) == NULL) break;		/* <=== */
	  p = lexgetword();
	}
	return (niter == 1? q : strdup(itoa((long) i)));
}

	local uchar *
relaexp(p, op,  nextword)
register uchar	*p, *op, **nextword;
{	register uchar	a, b;
	register int	np, nr;

	a  = op[0]; b = op[1];
	np = atoi(p);
	nr = atoi(arithexp(lexgetword(), nextword));
	if ((a == '<') && (b == '='))  nr = (np <= nr); else
	if ((a == '<') && (b == '\0')) nr = (np <  nr); else
	if ((a == '>') && (b == '='))  nr = (np >= nr); else
	if ((a == '>') && (b == '\0')) nr = (np >  nr); else
	if ((a == '=') && (b == '='))  nr = (np == nr); else
	if ((a == '!') && (b == '='))  nr = (np != nr); else
	nr = 0;
	return strdup((nr? ONE : ZERO));
}
	local uchar *		/** no short-circuit eval yet	**/
andor(p, op, nextword)
register uchar	*p, *op, **nextword;
{	register uchar	a, b;
	register int	np, nr;

	a  = op[0]; b = op[1];
	np = atoi(p);
	nr = atoi(csexp(lexgetword(), nextword)); 
	if ((a == '&') && (b == '&'))  nr = (np && nr); else
	if ((a == '|') && (b == '|'))  nr = (np || nr); else
	nr = 0;
	return strdup((nr? ONE : ZERO));
}

/* exp	::= aexp | aexp '||' exp | aexp && exp | aexp relop aexp */

	uchar *
csexp(p, nextword)
register uchar	*p, **nextword;
{	register uchar	*r;
	uchar		*q;

	r = arithexp(p, &q);
	switch (*q) {
	case '<':case '>':case '=':	return relaexp(r, q, nextword);
	case '|':case '&':		return andor(r, q, nextword);
	default	:			*nextword = q; break;
	}
	return r;
}

csif()
{	register int	g;
	uchar		*q;

	if (stp->tf)	stpush(BGNIF, csexp(lexgetword(), &q));
	else	stpush(SKIPIF, ZERO);
}

cselse()
{	register STE	*s;
	register int	f;
	register uchar	*p;
	uchar		*q;

	s = stp;
	if (s->op == BGNIF)
	{	f = s->tf; stpop();
		if (f) stpush(SKIPIF, ZERO);
		else
		{	p = lexgetword();
			p = (*p? csexp(p, &q) : ONE);
			stpush(BGNIF, p);
		}
	} else
 	if (s->op != SKIPIF) emsg = "unexpected else";
}

csendif()
{
	if (stp->op==BGNIF || stp->op==SKIPIF) stpop();
	else	emsg = "extraneous endif";
}

cswhile()
{
	stpush(WHILE, (stp->tf? csexp(lexgetword(), &dummy) : ZERO));
}

csendwhile()
{
	if (stp->op == WHILE)
	{	if (stp->tf) {curcmdlp = stp->lp; lpagain = 1;}
		stpop();
	}
	else	emsg = "extraneous endwhile";
}

csforeach()
{	register WS	*ws;
	register uchar	*p;
	uchar		*loopvar, *q;

	loopvar	= lexgetword();
	p	= lexgetword();	if (*p != '{') emsg = "missing {";
	ws = initws();
	if (stp->tf)
	{ p = lexgetword();	/* make a ws list of loop var values	*/
	  while (p)		/* p must never be NULL, but ...	*/
	  {	if (*p == '}') break;
		if (*p == '\000') {emsg = "missing }"; break;}
		strwcat(ws, csexp(p, &q), 1);
		p = q;
	  }
	  insertvar(loopvar, nthstr(ws->ps, 0));
	}
	stpush(FOREACH, (stp->tf? ONE : ZERO));
	stp->varp = strdup(loopvar); stp->wp = ws; stp->nn = 1;
}

csendfor()
{	register uchar	*p;
	register STE	*s;

	s = stp;
	if (s->op == FOREACH)
	{	if (s->tf && (p = nthstr(s->wp->ps, s->nn++)) && *p)
		{	insertvar(s->varp, p);
			curcmdlp = s->lp;
		} else stpop();
	}else	emsg = "extraneous endfor";
}

/* -eof- */
