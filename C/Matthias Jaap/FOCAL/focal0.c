/*
 * Focal, 1981.
 * Dedicated to the old times,
 * when an 8k PDP-8 was considered
 * a BIG machine.
 * Driver and command handler.
 */

/*)BUILD
	$(PROGRAM)	= focal
	$(INCLUDE)	= focal.h proto.h
	$(FILES)	= { focal0.c focal1.c focal2.c focal3.c }
	$(ATOD)		= 1
	$(DTOA)		= 1
*/
#ifdef	DOCUMENTATION

title	focal		Ancient Interpretive Language
index			Ancient Interpretive Language

synopsis

	focal

description

	Focal is a block-structured interpretive language.
	It is described in the PDP-8 "Introduction to
	Programming."  There is also a PDP-11 Focal manual.

	This version of focal runs on Vax/VMS and Unix.

author

	Dave Conroy

#endif

#include	"focal.h"
#ifdef	vms
#include	<stsdef.h>
#include	<ssdef.h>
#define	IO_SUCCESS	SS$_NORMAL
#define	IO_ERROR	(STS$M_INHIB_MSG | SS$_ABORT)
#else
#ifndef	IO_SUCCESS
#define	IO_SUCCESS	0
#endif
#ifndef	IO_ERROR
#define	IO_ERROR	1
#endif
#endif

char	cbuf[128];			/* Command buffer */
char	abuf[128];			/* Ask buffer */
char	*ctp;				/* Current text pointer */
struct	line	*line;			/* Line list header */
struct	line	*clp;			/* Current line pointer */
int	mode;				/* Current processing mode */
struct	sym	*forsp;			/* Symbol pointer (for) */
double	forlimit;			/* Loop limit (for) */
double	forstep;			/* Loop step (for) */
struct	control	*control;		/* Control stack */
jmp_buf	env;				/* Saved state for errors */
int	intflag;			/* Interrupt flag */

struct	sym	*sym[N_HASH + 1];	/* Symbol table */

int main()
{
	register int	c;

#ifdef FUNCTIONS
	builtin("fsin", fsin);
	builtin("fcos", fcos);
	builtin("fexp", fexp);
	builtin("flog", flog);
	builtin("fatn", fatn);
	builtin("fsqt", fsqt);
	builtin("fabs", fabt);
	builtin("fsgn", fsgn);
	builtin("fitr", fitr);
	builtin("fran", fran);
#endif
	setjmp(env);
	catchcc();
	for (;;) {
		putchar('*');
		if (gets(cbuf) == NULL) {
			putchar('\n');
			break;
		}
		mode = C_TOP;
		clp  = NULL;
		ctp  = cbuf;
		if ((c=getnb()) != 0) {
			if (isdigit(c))
				inject(c);
			else {
				--ctp;
				process();
			}
		}
	}
	return EXIT_SUCCESS;
}

/*
 * Handcraft the symbol table
 * entry for a builtin function. Used
 * at initialization time, to jam
 * the functions into the table, and
 * never used again!
 */
void builtin(cp, fp)
char	*cp;
double	(*fp)();
{
	register struct sym *sp = NULL;
	int	ix;
	
	sp = (struct sym *)malloc(sizeof(*sp)+strlen(cp)+1);
	if (sp == NULL) {
		fprintf(stderr, "No memory for %s\n", cp);
		exit(IO_ERROR);
	}
	ix = hashname(cp);
	sp->s_fp = sym[ix];
	sym[ix] = sp;
	sp->s_type = S_FUNC;
	sp->s_subs = 0;
	sp->s_un.s_fp = fp;
	strcpy(sp->s_id, cp);
}




#ifdef	DEBUG
void dumpsyms()
{
	register struct sym *sp;
	int	i;
	
	for (i = 0; i < N_HASH; ++i) {
		printf("%3d:", i);
		for (sp = sym[i]; sp != NULL; sp = sp->s_fp) {
			if (sp->s_type == S_ARRAY)
				printf(" %s(%d)", sp->s_id, sp->s_subs);
			else
				printf(" %s", sp->s_id);
		}
		printf(" $\n");
	}
}
#endif


/*
 * This is the line evaluator. It runs
 * the do/for/return stack, checks for interrupts
 * and calls the required subfunctions to get
 * the focal commands executed.
 */
void process()
{
	double		limit, step = 1.0;
	double		value;
	register int	c;
	register struct sym *sp;
	register struct line *lp;
	struct lno	lno;
	struct line	*lp1, *lp2, *lp3;
	int		grp = 0;

loop:
	if (intflag) {
		intflag = 0;
		diag("^C");
	}
	while ((c=getnb()) == ';')
		;
	if (c == 0) {
		if (mode == C_FOR) {
			forsp->s_un.s_value += forstep;
			if ((forstep>0.0 && forsp->s_un.s_value<=forlimit)
			||  (forstep<0.0 && forsp->s_un.s_value>=forlimit)) {
				clp = control->c_lp;
				ctp = control->c_tp;
				goto loop;
			}
			popfor();
		}
		if (clp != NULL) {
			grp = clp->l_gno;
			clp = clp->l_fp;
			ctp = clp->l_text;
		}
		if (clp == NULL) {
			if (mode == C_TOP)
				return;
			popdo();
		} else if (mode == C_DLINE
		|| (mode==C_DGRP && grp!=clp->l_gno))
			popdo();
		goto loop;
	}
	while (isalpha(*ctp))
		++ctp;
	if (isupper(c))
		c = tolower(c);
	switch (c) {

	case 'a':
		ask();
		break;

	case 'c':
		while (*ctp != 0)
			++ctp;
		break;

	case 'd':
		getlno(&lno, -1);
		pushcntl();
		if (lno.ln_type==LN_NONE || lno.ln_type==LN_ALL) {
			if ((clp=line) == NULL)
				diag("No program");
			ctp = clp->l_text;
			mode = C_DALL;
			goto loop;
		}
		if (lno.ln_type == LN_GRP) {
			lp = line;
			while (lp!=NULL && lp->l_gno<lno.ln_gno)
				lp = lp->l_fp;
			if (lp!=NULL && lp->l_gno==lno.ln_gno) {
				clp = lp;
				ctp = clp->l_text;
				mode = C_DGRP;
				goto loop;
			}
			badline();
		}
		lp = line;
		while (lp != NULL
		&& (lp->l_gno != lno.ln_gno
		||  lp->l_lno != lno.ln_lno))
			lp = lp->l_fp;
		if (lp != NULL) {
			clp = lp;
			ctp = clp->l_text;
			mode = C_DLINE;
			goto loop;
		}
		badline();

	case 'e':
		getlno(&lno, -1);
		if (lno.ln_type == LN_NONE) {
			erasesyms();
			break;
		}
		lp1 = NULL;
		lp2 = line;
		while (lp2 != NULL) {
			if (lno.ln_type == LN_ALL
			|| (lp2->l_gno  == lno.ln_gno
			&& (lno.ln_type==LN_GRP || lp2->l_lno==lno.ln_lno))) {
				if (lp2 == clp)
					diag("Erasing current line");
				lp3 = lp2;
				lp2 = lp2->l_fp;
				if (lp1 == NULL)
					line = lp2; else
					lp1->l_fp = lp2;
				free((char *) lp3);
			} else {
				lp1 = lp2;
				lp2 = lp2->l_fp;
			}
		}
		break;

	case 'f':
		sp = getsym();
		clearfors(sp);
		if (getnb() != '=')
			diag("Missing = sign");
		sp->s_un.s_value = eval();
		if (getnb() != ',')
			diag("Missing comma");
		limit = eval();
		if ((c=getnb()) == ';')
			step = 1.0;
		else if (c == ',') {
			step = eval();
			if (getnb() != ';')
				diag("Missing semi");
		} else
			diag("Bad for");
		pushcntl();
		forsp = sp;
		forlimit = limit;
		forstep = step;
		mode = C_FOR;
		break;

	case 'g':
		getlno(&lno, -1);
		if (lno.ln_type == LN_NONE) {
			if ((clp=line) == NULL)
				diag("No program");
			ctp = clp->l_text;
			goto loop;
		} else if (lno.ln_type == LN_LINE) {
			lp = line;
			while (lp != NULL
			&& (lp->l_gno != lno.ln_gno
			||  lp->l_lno != lno.ln_lno))
				lp = lp->l_fp;
			if (lp != NULL) {
				clp = lp;
				ctp = clp->l_text;
				goto loop;
			}
		}
		badline();

	case 'i':
		value = eval();
		if (value >= 0.0) {
			while ((c = *ctp)!=0 && c!=',' && c!=';')
				++ctp;
			if (c != ',')
				goto loop;
			++ctp;
			if (value != 0.0) {
				while ((c = *ctp)!=0 && c!=',' && c!=';')
					++ctp;
				if (c != ',')
					goto loop;
				++ctp;
			}
		}
		getlno(&lno, -1);
		if (lno.ln_type == LN_LINE) {
			lp = line;
			while (lp != NULL
			&& (lp->l_gno != lno.ln_gno
			||  lp->l_lno != lno.ln_lno))
				lp = lp->l_fp;
			if (lp != NULL) {
				clp = lp;
				ctp = clp->l_text;
				goto loop;
			}
		}
		badline();

	case 'l':
		library();
		break;

	case 'q':
		if (clp == NULL)
			exit(IO_SUCCESS);
		return;

	case 't':
		type();
		break;

	case 'r':
		while (mode == C_FOR)
			popfor();
		popdo();
		break;

	case 's':
		sp = getsym();
		if (getnb() != '=')
			diag("Missing = sign");
		sp->s_un.s_value = eval();
		break;

	case 'w':
		getlno(&lno, -1);
		save(&lno, stdout);
		break;

#ifdef	DEBUG
	case 'x':
		dumpsyms();
		break;
#endif

	default:
		diag("Illegal command");
	}
	goto loop;
}

/*
 * Process the ask command.
 * The "ask" has already been read in.
 * The funny altmode thing, where a variable
 * is left unchanged, is not implemented.
 * The input expression must be a legal floating
 * point number, although no checking is done.
 */
void ask()
{
	register struct	sym	*sp;
	register int	c;

	while ((c=getnb())!=0 && c!=';') {
		if (c == '"') {
			while ((c = *ctp++)!=0 && c!='"')
				putchar(c);
			if (c != 0)
				continue;
			diag("Missing `\"' in ask");
		}
		if (c == ',')
			continue;
		--ctp;
		sp = getsym();
		printf(": ");
		if (gets(abuf) == NULL) {
			putchar('\n');
			diag("EOF in ask");
		}
		sp->s_un.s_value = atof(abuf);
	}
	--ctp;
}

/*
 * Complain about bad line
 * numbers. Used all over the place.
 */
void badline()
{
	diag("Bad line number");
}



/*
 * Effectively use control stack
 */
static struct control *ccb_free = NULL;


/*
 * Obtain a control stack entry.
 * Check free list firstly, then call malloc
 * only when free list is empty.
 *  -- added by Akira Kida
 */
struct control *
newcontrol()
{
	struct control *cp;
	
	if (ccb_free != NULL) {
		cp = ccb_free;
		ccb_free = cp->c_fp;
	} else if ((cp = (struct control *)
		     malloc(sizeof(struct control))) == NULL) {
		diag("Out of space (control stack)");
	}
	return cp;
}

/*
 * Free control stack that is no longer needed.
 * Just return one to the free list.
 */
void
freecontrol(cp)
struct control *cp;
{
	cp->c_fp = ccb_free;
	ccb_free = cp;
}


/*
 * Push an entry onto the control stack
 *
 * There are two formats corresponding to
 * "for" and "do" statmenets.  "for" statiement
 * format differs from "do" statement format in 
 * that the loop variables are saved.
 *  -- added by Akira Kida
 */
void pushcntl()
{
	register struct control *cp;

	cp = newcontrol();
	cp->c_fp = control;
	control  = cp;
	cp->c_mode = mode;
	cp->c_tp = ctp;
	cp->c_lp = clp;
	if (mode == C_FOR) {
		cp->c_sp = forsp;
		cp->c_limit = forlimit;
		cp->c_step = forstep;
	}
}



/*
 * Pop an entry from the control stack
 */
void popcntl()
{
	register struct control *cp;

	cp = control;
	control = cp->c_fp;
	ctp = cp->c_tp;
	clp = cp->c_lp;
	mode = cp->c_mode;
	if (mode == C_FOR) {
		forsp = cp->c_sp;
		forlimit = cp->c_limit;
		forstep = cp->c_step;
	}
	freecontrol(cp);
}


/*
 * Pop a "do" format entry from
 * the control stack, restoring all of the
 * global variables.
 */
void popdo()
{
	if (control == NULL)
		diag("Return not in do");
	popcntl();
}


/*
 * Pop a "for" format item from the
 * control stack, restoring all the global
 * variables.
 */
void popfor()
{
	if (control == NULL)
		diag("For stack botch");
	popcntl();
}



/*
 * Dig in the control stack,
 * looking for "for" stack entries that
 * are controlling the variable whose symbol
 * table entry is pointed to by `sp'. Rip
 * them out. This makes everything work out
 * if you "go" out of a loop and then "for"
 * on the same variable.
 */
void clearfors(sp)
register struct	sym	*sp;
{
	register struct	control	*cp1;
	register struct	control	*cp2;

	if (mode==C_FOR && forsp==sp)
		popfor();
	else {
		cp1 = NULL;
		cp2 = control;
		while (cp2 != NULL) {
			if (cp2->c_mode==C_FOR && cp2->c_sp==sp) {
				if (cp1 == NULL)
					control = cp2->c_fp;
				else
					cp1->c_fp = cp2->c_fp;
				freecontrol(cp2);
				break;
			}
			cp1 = cp2;
			cp2 = cp2->c_fp;
		}
	}
}

/*
 * Inject a line of text, stored in
 * the normal command line buffer, into the
 * saved indirect program. The argument `c'
 * is the first character of the line
 * number, which is assumed to be valid.
 */
void inject(c)
register int	c;
{
	register struct	line	*lp1;
	register struct line	*lp2;
	register struct	line	*lp3;
	struct lno	lno;

	getlno(&lno, c);
	if (lno.ln_type != LN_LINE)
		diag("Illegal line number");
	lp1 = NULL;
	lp2 = line;
	while (lp2 != NULL
	&& (lp2->l_gno < lno.ln_gno
	|| (lp2->l_gno==lno.ln_gno&&lp2->l_lno<=lno.ln_lno))) {
		if (lp2->l_gno == lno.ln_gno
		&&  lp2->l_lno == lno.ln_lno) {
			lp3 = lp2;
			lp2 = lp2->l_fp;
			if (lp1 == NULL)
				line = lp2;
			else
				lp1->l_fp = lp2;
			free((char *) lp3);
			break;
		}
		lp1 = lp2;
		lp2 = lp2->l_fp;
	}
	if ((c=getnb()) != 0) {
		lp3 = alocline(--ctp);
		lp3->l_fp  = lp2;
		lp3->l_gno = lno.ln_gno;
		lp3->l_lno = lno.ln_lno;
		strcpy(lp3->l_text, ctp);
		if (lp1 == NULL)
			line = lp3;
		else
			lp1->l_fp = lp3;
	}
}


int getline(cp, fp)
register char *cp;
register FILE *fp;
{
	register c;

	while ((c=getc(fp))!=EOF && c!='\n')
		*cp++ = c;
	if (c == EOF)
		return (0);
	*cp = 0;
	return (1);
}


void type()
{
	register char *fmt;
	register c;
static	char fmtb[20];
static	int ifmtb = 1;
	int x, y;

	if (ifmtb) {
		strcpy(fmtb, "%9.4f");
		ifmtb--;
		}
	fmt = fmtb;
	while ((c=getnb())!=0 && c!=';') {
		if (c == '%') {
			if ((c=getnb())==0 || c==';' || c==',') {
				strcpy(fmtb, "%6e");
				fmt = fmtb;
				--ctp;
				continue;
			}
			x = getnum(c);
			if (getnb() != '.')
				diag("Missing . in format");
			y = getnum(getnb());
			sprintf(fmtb, "%%%d.%df", x, y);
			fmt = fmtb;
			continue;
		}
		if (c == ',')
			continue;
		if (c == '!') {
			putchar('\n');
			continue;
		}
		if (c == '#') {
			putchar('\r');
			continue;
		}
		if (c == '"') {
			while ((c = *ctp++)!='\0' && c!='"')
				putchar(c);
			if (c == '\0') {
				diag("Missing `\"' in type");
				break;
			}
			continue;
		}
		--ctp;
		printf(fmt, eval());
	}
	--ctp;
}

void save(lnop, fp)
register struct lno *lnop;
FILE *fp;
{
	struct lno lno;
	register struct line *lp;
	register tgroup, lgroup;

	if (lnop == NULL) {
		lno.ln_type = LN_ALL;
		lnop = &lno;
	}
	lp = line;
	if (lnop->ln_type!=LN_NONE && lnop->ln_type!=LN_ALL) {
		while (lp!=NULL && lp->l_gno<lnop->ln_gno)
			lp = lp->l_fp;
		if (lp==NULL || lp->l_gno!=lnop->ln_gno)
			diag("Line not found");
		if (lnop->ln_type == LN_LINE) {
			while (lp!=NULL && lp->l_lno!=lnop->ln_lno)
				lp = lp->l_fp;
			if (lp == NULL)
				diag("Line not found");
		}
	}
	while (lp != NULL) {
		putline(lp, fp);
		if (lnop->ln_type == LN_LINE)
			break;
		lgroup = lp->l_gno;
		if ((lp = lp->l_fp) != NULL) {
			tgroup = lp->l_gno;
			if (lnop->ln_type==LN_GRP && tgroup!=lnop->ln_gno)
				break;
			if (tgroup != lgroup)
				putc('\n', fp);
		}
	}
}

void erasesyms()
{
	register struct sym *sp1, *sp2;
	int	i;
	
	for (i = 0; i < N_HASH; ++i) {
		sp1 = sym[i];
		sym[i] = NULL;
		while (sp1 != NULL) {
			sp2 = sp1->s_fp;
			free((char *) sp1);
			sp1 = sp2;
		}
	}
}
