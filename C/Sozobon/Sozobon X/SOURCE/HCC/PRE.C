/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	pre.c
 *
 *	preprocessor for the compiler
 *
 *	Handles all preprocessor (#) commands and
 *	  looks up keywords
 *
 *	Interface:
 *		getnode()	returns next "token node"
 */

#include <stdio.h>
#include "param.h"
#include "tok.h"
#include "nodes.h"

#if CC68
FILE *fopenb();
#define fopen fopenb
#endif

extern struct tok curtok;
extern char curstr[];

#define TK_SEENL	1	/* want to see NL token */
#define TK_SEEWS	2	/* want to see WS token */
#define TK_ONLY1	4	/* only want 1st token on line */
#define TK_LTSTR	8	/* '<' starts a string */
#define TK_NOESC	16	/* dont do '\' escapes in string */

extern int tk_flags, sawnl;

#ifndef ACK_HOST
NODE *deflist[NHASH];
NODE *holdtok;
int iflevel, iftruth, ifnest, in_if_x, skip_id;
#else
#if PART_1
NODE *deflist[NHASH];
NODE *holdtok;
extern int iflevel, iftruth, ifnest, in_if_x, skip_id;
#else
extern NODE *deflist[NHASH];
extern NODE *holdtok;
int iflevel, iftruth, ifnest, in_if_x, skip_id;
#endif
#endif

extern lineno;
extern char *inname;
extern FILE *input;

NODE *hlook(), *llook();
NODEP tok_to_node();
NODE *copylist();

#ifdef DEBUG
extern int oflags[];
#define debugd	oflags['d'-'a']
#define debugt	oflags['t'-'a']
#endif

#ifndef ACK_HOST
#define PART_1	1
#define PART_2	1
#endif

#if PART_1

NODEP
hi_node()
{
	register NODEP rv;

	/* node from hold queue ? */
	if (holdtok) {
#ifdef DEBUG
		if (debugd > 2) {
			printf("Holdqueue");
			printnode(holdtok);
		}
#endif
		rv = holdtok;
		holdtok = rv->n_next;
		rv->n_next = NULL;
		return rv;
	}
	/* node from input */
again:
	while (iflevel && !iftruth)
		skiplines();
	if (nxttok()==0)
		return NULL;
	if (curtok.tnum == '#') {
		dopound(0);
		goto again;
	}
	rv = tok_to_node();
	return rv;
}

NODEP
getnode()
{
	register NODEP rv;
	NODEP dp;

again:
	rv = hi_node();
	if (rv == NULL) {
		rv = allocnode();
		rv->e_token = EOFTOK;
		strcpy(rv->n_name, "*EOF*");
	} else
	if (rv->e_token == ID) {
		if (in_if_x && strcmp(rv->n_name, "defined") == 0) {
			skip_id = 1;
			goto out;
		}
		if (skip_id) {
			skip_id = 0;
			goto out;
		}
		if ((dp = hlook(deflist, rv)) != NULL) {
			expand(dp);
			freenode(rv);
			goto again;
		} else if (rv->n_name[0] == '_' && builtin(rv))
			return rv;
		else
			kw_tok(rv);
	}
out:
#ifdef DEBUG
	if (debugt) {
		putchar('[');
		put_nnm(rv);
		printf("] ");
	}
#endif
	return rv;
}

builtin(np)
register NODEP np;
{
	int rv;

	if (strcmp(np->n_name, "__LINE__") == 0) {
		np->e_token = ICON;
		np->e_ival = lineno;
		return 1;
	}
	else if (strcmp(np->n_name, "__FILE__") == 0) {
		np->e_token = SCON;
		nscpy(np, inname);
		return 1;
	}
	return 0;
}

skiplines()
{
	for (;;) {
		if (nxttok()== 0)
			return;
		if (curtok.tnum == '#') {
			dopound(1);
			return;
		}
		tk_flags |= TK_ONLY1;
	}
}

static defnargs;

p_def()
{
	NODE *args;
	NODE *val;
	NODE *def;
	NODE *def_rgs(), *def_val();

	defnargs = -1;
	args = NULL;
	val = NULL;
	nxttok();
	if (curtok.tnum != ID) {
		error("bad #define");
		goto flush;
	}
	def = tok_to_node();

	tk_flags |= TK_SEEWS;
	nxttok();
	switch (curtok.tnum) {
	case '(':
		defnargs = 0;
		args = def_rgs();
	case WS:
		goto getval;
	case NL:
		goto dodef;
	default:
		error("bad #define");
		goto flush;
	}
getval:
	val = def_val();
dodef:
	def->e_ival = defnargs;
	define(def, val, args);
flush:
	;
}

optdef(s,as)
char *s, *as;
{
	NODEP val;
	NODEP def;
	NODEP id_tok(), def_val();

	defnargs = -1;
	val = NULL;

	def = id_tok(s);
	chr_push(as);

	tk_flags |= TK_SEENL;

	val = def_val();

	tk_flags = 0;

	def->e_ival = defnargs;
	define(def, val, NULL);
}

/*
optundef(s)
char *s;
{
	NODEP np, tp, id_tok();

	np = id_tok(s);
	tp = hlook(deflist, np);
	if (tp != NULL)
		tp->n_name[0] = '#';
	freenode(np);
}
*/

samedef(p1, p2)
NODEP p1, p2;
{
	if (p1->e_ival != p2->e_ival)
		return 0;
	return same_list(p1->n_right, p2->n_right);
}

same_list(p1, p2)
NODEP p1, p2;
{
	if (p1 == NULL)
		return p2 == NULL;
	if (p2 == NULL)
		return 0;
	if (l_cmp(p1, p2, sizeof(*p1)/sizeof(long)) != 0)
		return 0;
	return same_list(p1->n_left, p2->n_left);
}

l_cmp(p1, p2, n)
NODE *p1, *p2;
{
	if (xstrcmp(p1,p2) != 0)
		return 1;
	if (p1->e_token != p2->e_token ||
		p1->e_ival != p2->e_ival)
		return 1;
	return 0;
}

define(def, val, args)
NODEP def, val, args;
{
	NODEP oldp;

	if (args != NULL) {
		argsmod(val, args);
		freenode(args);
	}
	def->n_right = val;
	if ((oldp = hlook(deflist, def)) != NULL) {
		if (!samedef(oldp, def))
			warnn("redefined", def);
	}
#ifdef DEBUG
	if (debugd) {
		printf("define (%d args)", (int)def->e_ival);
		printnode(def);
	}
#endif
	puthlist(deflist, def);
}

argsmod(toks, args)
NODEP toks, args;
{
	register NODE *np, *vp;

	for (np=toks; np != NULL; np = np->n_next)
		if (np->e_token == ID) {
			vp = llook(args,np);
			if (vp != NULL) {
				np->e_token = DPARAM;
				np->e_ival = vp->e_ival;
				sprintf(np->n_name, "\\%d", (int)np->e_ival);
			}
		}
}

NODE *
def_rgs()
{
	NODE *rv;
	NODE *tail;
	NODE *np;

	rv = NULL;
	tail = NULL;
	nxttok();
	if (curtok.tnum == ')') {
		goto out;
	}
more:
	if (curtok.tnum != ID) {
		error("expect ID");
		goto bad;
	}
	np = tok_to_node();
	np->e_ival = defnargs;	/* hold sequence number */
	defnargs++;
	if (tail == NULL) {	/* first one */
		rv = np;
		tail = np;
	} else {			/* more */
		tail->n_next = np;
		tail = np;
	}
	nxttok();
	if (curtok.tnum == ',') {
		nxttok();
		goto more;
	}
	if (curtok.tnum == ')')
		goto out;
	error("define arg syntax");
bad:
	freenode(rv);
	rv = NULL;
	defnargs = 0;
out:
	return rv;
}

NODE *
def_val()
{
	NODE *rv;
	NODE *tail;
	NODE *np;

	rv = NULL;
	tail = NULL;
more:
	nxttok();
	if (curtok.tnum == NL) {
		goto out;
/*
	} else if (curtok.tnum == '\\') {
		nxttok();
		if (curtok.tnum != NL)
			goto bad;
		goto more;
*/
	}
	np = tok_to_node();
	if (tail == NULL) {	/* first one */
		rv = np;
		tail = np;
	} else {			/* more */
		tail->n_next = np;
		tail = np;
	}
	goto more;

bad:
	freenode(rv);
	rv = NULL;
out:
	return rv;
}

NODE *
gath1(sep)
int *sep;
{
	NODE *np, *rv, *tail;
	int inparen;

	inparen = 0;
	rv = NULL;
	tail = NULL;
more:
	np = hi_node();
	if (np == NULL) {
		goto bad;
	}
	switch (np->e_token) {
	case ')':
	case ',':
		if (inparen) {	/* dont end, part of subexpr */
			if (np->e_token == ')')
				inparen--;
			break;
		}
		*sep = np->e_token;
		freenode(np);
		goto out;
	case '(':
		inparen++;
		break;
	}
	if (tail == NULL) {	/* first one */
		rv = np;
		tail = np;
	} else {			/* more */
		tail->n_next = np;
		tail = np;
	}
	goto more;
bad:
	freenode(rv);
	rv = NULL;
	*sep = 0;
out:
	return rv;
}

NODE *
gath_args(n)
{
	NODE *rv;
	NODE *tail;
	NODE *np;
	int sep;
	int getn;

	getn = 0;
	rv = NULL;
	tail = NULL;
	np = hi_node();
	if (np->e_token != '(') {
		error("expect (");
		goto bad;
	}
	freenode(np);
	if (n == 0) {
		np = hi_node();
		if (np->e_token != ')') {
			error("expect )");
			goto bad;
		}
		freenode(np);
		return NULL;
	}
more:
	np = gath1(&sep);
	if (np == NULL) {
		error("expect arg");
		goto bad;
	}
	getn++;
	if (tail == NULL) {	/* first one */
		rv = np;
		tail = np;
	} else {			/* more */
		tail->n_right = np;
		tail = np;
	}
	if (sep) switch (sep) {
	case ',':
		goto more;
	case ')':
		if (getn != n) {
			error("arg num mismatch");
			goto bad;
		}
		goto out;
	}
	error("expand arg syntax");
bad:
	freenode(rv);
	rv = NULL;
out:
	return rv;
}

NODE *
argfix(val, args, rt)
NODE *val, *args;
NODE **rt;
{
	register NODE *scan, *sub;
	NODE *head;
	NODE *tail, *back;
	NODE *rthnode();
	NODE *copylist();

	head = val;
	back = NULL;
	for (scan = val; scan != NULL; back=scan, scan=scan->n_next)
		if (scan->e_token == DPARAM) {
			sub = rthnode(args, (int)scan->e_ival);
			sub = copylist(sub,&tail);
			if (back) {
				back->n_next = sub;
				tail->n_next = scan->n_next;
			} else {
				head = sub;
				tail->n_next = scan->n_next;
			}
			scan->n_next = NULL;
			freenode(scan);
			scan = tail;
		}
	*rt = back;
	return head;
}

expand(dp)
NODEP dp;
{
	int nargs;
	NODEP args;
	register NODEP val;
	NODEP tail;

	val = dp->n_right;
	if (val)
		val = copylist(val, &tail);
	nargs = dp->e_ival;
	if (nargs >= 0) {
		args = gath_args(nargs);
		if (args) {
			if (val)
				val = argfix(val,args,&tail);
			freenode(args);
		}
	}
	if (val == NULL)
		return;
#ifdef DEBUG
	if (debugd > 1) {
		printf("Expand");
		printnode(val);
	}
#endif
	tail->n_next = holdtok;
	holdtok = val;
}

p_undef()
{
	NODEP np, tp;

	nxttok();
	if (curtok.tnum != ID) {
		error("bad #undef");
		goto out;
	}
	tp = tok_to_node();
	if ((np = hlook(deflist, tp)) != NULL)
		/* quick and dirty */
		np->n_name[0] = '#';
	freenode(tp);
out:
	;
}

#endif
#if PART_2

p_inc()
{
	int chkhere;
	FILE *newf, *srch_open();
	char *scopy(), *newnm;

	tk_flags |= TK_NOESC|TK_LTSTR;
	nxttok();
	switch (curtok.tnum) {
	case SCON:
		chkhere = 1;
		break;
	case SCON2:
		chkhere = 0;
		break;
	case NL:
	case EOF:
		error("bad #include");
		return;
	}
	newf = srch_open(curstr, chkhere);
	if (newf == NULL) {
		fatals("Cant open ", curstr);
		return;
	}
	newnm = scopy(curstr);
	do 
		nxttok();
	while (curtok.tnum != NL);
	newfile(newf,newnm);
}

int inclvl;
struct svinc {
	int lineno;
	FILE *fd;
	char *filenm;
} svincs[MAXINCL];

#if NEEDBUF
char p_buf[MAXINCL][BUFSIZ];
#endif

static char obuf[MAXSTR];

newfile(fd,s)
FILE *fd;
char *s;
{
	register struct svinc *p;

	inclvl++;
	if (inclvl > MAXINCL) {
		inclvl--;
		fclose(fd);
		error("too many includes");
		return;
	}
	p = &svincs[inclvl-1];
	p->lineno = lineno;
	p->fd = input;
	p->filenm = inname;
	input = fd;
	lineno = 1;
	inname = s;
#if NEEDBUF
	setbuf(input, p_buf[inclvl-1]);
#endif
}

endfile()
{
	register struct svinc *p;

	if (inclvl == 0)
		return 0;
	fclose(input);
	inclvl--;
	p = &svincs[inclvl];
	sfree(inname);
	input = p->fd;
	lineno = p->lineno;
	inname = p->filenm;
	return 1;
}

#define MAXIDIR	10

#ifndef FOR_AMIGA
#ifndef MINIX
#ifndef UNIX
char *srchlist[MAXIDIR] = {
	"",
	"\\include\\",
	"\\sozobon\\include\\",
	"",
	0
};
static int idir_n = 4;		/* number of entries in above table */
#else
char *srchlist[MAXIDIR] = {
	"",
	"/home/hans/sozobon/include/",	/* change this to cross incl dir */
	0
};
static int idir_n = 2;
#endif
#else
char *srchlist[MAXIDIR] = {
	"",
	"/usr/include/",
	0
};
static int idir_n = 2;
#endif
#else
char *srchlist[MAXIDIR] = {
	"",
	"include:",
	0
};
static int idir_n = 2;		/* number of entries in above table */
#endif

static int idir_put = 1;	/* where to put -I dirs */

optincl(s)
char *s;
{
	register char **pp;

	if (idir_n >= MAXIDIR-1) {
		warn("too many -I dirs");
		return;
	}
	for (pp = &srchlist[idir_n]; pp > &srchlist[idir_put]; ) {
		pp--;
		pp[1] = pp[0];
	}
	*pp = s;
	idir_put++;
	idir_n++;
}

FILE *
srch_open(s, chkhere)
char *s;
{
	char **dir;
	FILE *fd;

	dir = srchlist;
	if (chkhere == 0) dir++;
	while (*dir) {
		strcpy(obuf, *dir);
		strcat(obuf, s);
		fd = fopen(obuf, ROPEN);
		if (fd != NULL) {
			return fd;
		}
		dir++;
	}
	return NULL;
}

p_if(kind,skipping)
{
	int truth;
	NODEP tp;

	if (skipping) {
		ifnest++;
		return;
	}
	switch (kind) {
	case 0:
		truth = if_expr();
		break;
	case 1:
	case 2:
		nxttok();
		if (curtok.tnum != ID) {
			error("bad #if(n)def");
			goto flush;
		}
		tp = tok_to_node();
		truth = (hlook(deflist, tp) != NULL);
		freenode(tp);
		if (kind == 2)
			truth = !truth;
	}
	iflevel++;
	iftruth = truth;
flush:
	;
}

if_expr()
{
	NODE *tp, *questx();
	extern NODE *cur;
	int rv;

	in_if_x = 1;
	skip_id = 0;
	advnode();
	tp = questx();
	in_if_x = 0;
	skip_id = 0;
	if (tp) {
		pnames(tp);
		rv = conxval(tp);
	} else
		rv = 0;
	if (cur->e_token != NL) {
		error("bad #if");
	} else
		freenode(cur);
	return rv;
}

pnames(np)
register NODEP np;
{
again:
	if (np->e_token == ID) {
		np->e_token = ICON;
		np->e_ival = 0;
	} else if (np->e_token == '(') {
		NODEP rp, lp;
		int truth;

		rp = np->n_right;
		lp = np->n_left;
		if (lp->e_token == ID && strcmp(lp->n_name, "defined") == 0
			&& rp && rp->e_token == ID) {
			truth = (hlook(deflist, rp) != NULL);
			freenode(rp);
			freenode(lp);
			np->n_left = NULL;
			np->n_right = NULL;
			np->e_token = ICON;
			np->e_ival = truth;
		}
	}
	if (np->n_right)
		pnames(np->n_right);
	np = np->n_left;
	if (np)
		goto again;
}

p_swit(kind,skipping)
{
	if (skipping && ifnest) {
		if (kind == 1)
			ifnest--;
		return;
	}
	if (iflevel == 0) {
		error("not in #if");
		goto out;
	}
	switch (kind) {
	case 0:		/* else */
		iftruth = !iftruth;
		break;
	case 1:		/* endif */
		iflevel--;
		iftruth = 1;
		break;
	}
out:
	;
}

p_line()
{
	char *scopy();

	nxttok();
	if (curtok.tnum != ICON) {
		error("bad #line");
		goto flush;
	}
	tk_flags |= TK_NOESC;
	nxttok();
	if (curtok.tnum == SCON) {
		sfree(inname);
		inname = scopy(curtok.name);
	}
	lineno = curtok.ival;
flush:
	;
}

struct cmds {
	char *name;
	int (*fun)();
	int arg;
	int skip;
} pcmds[] = {
	{"define", p_def, 0, 1},
	{"undef", p_undef, 0, 1},
	{"include", p_inc, 0, 1},
	{"if", p_if, 0, 0},
	{"ifdef", p_if, 1, 0},
	{"ifndef", p_if, 2, 0},
	{"else", p_swit, 0, 0},
	{"endif", p_swit, 1, 0},
	{"line", p_line, 0, 1},
	{0}
};

dopound(skipping)
{
	register struct cmds *p;
	register char *cname;

	tk_flags |= TK_SEENL;
	sawnl = 0;
	nxttok();
	if (curtok.tnum != ID) {
		error("expect name");
		return;
	}
	cname = curtok.name;
	for (p=pcmds; p->name; p++)
		if (strcmp(p->name, cname) == 0) {
			if (!skipping || !p->skip)
				(*p->fun)(p->arg, skipping);
			tk_flags = 0;
			if (sawnl == 0)
				tk_flags |= TK_ONLY1;
			return;
		}
	error("bad # command");
}

NODEP
tok_to_node()
{
	register struct tok *tp;
	register NODEP np;

	tp = &curtok;
	np = allocnode();
	np->e_token = tp->tnum;
	np->e_flags = tp->flags;
	if (tp->prec)	/* binary op */
		np->e_prec = tp->prec;
	else
	switch (np->e_token) {
	case ICON:
		np->e_ival = tp->ival;
		break;
	case FCON:
		np->e_fval = tp->fval;
		break;
	}
	nscpy(np, tp->name);
	return np;
}

NODEP
id_tok(s)
char *s;
{
	NODEP np;

	np = allocnode();
	np->e_token = ID;
	nscpy(np, s);
	return np;
}

#endif
