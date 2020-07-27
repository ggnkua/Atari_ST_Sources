/*
 * $Header: f:/src/gulam\RCS\do.c,v 1.1 1991/09/10 01:02:04 apratt Exp $ $Locker:  $
 * ======================================================================
 * $Log: do.c,v $
 * Revision 1.1  1991/09/10  01:02:04  apratt
 * First CI of AKP
 *
 * Revision: 1.9 89.06.16.17.23.18 apratt 
 * Header style change.
 * 
 * Revision: 1.8 89.04.14.23.11.50 Author: apratt
 * Added use of rindex to find .g in file name to see if it is
 * a batch file... Previously, used index(), so ..\foo.g wouldn't be
 * executed right.
 * 
 * Added command-line length byte = 0x7f if env_style == mw.
 * 
 * Revision: 1.7 89.03.10.17.13.16 Author: apratt
 * Fixed a REALLY STUPID bug: args were processed according to b->type
 * for the built-in command lexically after the command name,
 * if the command wasn't a built-in.  Now it's processed as a '1'
 * meaning it might change dir stuff, but no other strange handling.
 * 
 * Revision: 1.6 89.03.10.14.23.52 Author: apratt
 * Fixed range checking for command tail.  Maxes out at 7e as it should.
 * 
 * Revision: 1.5 89.03.10.13.56.06 Author: apratt
 * Stomped cmdline tail length to max 0x7e so it's not a lie.
 * 
 * Revision: 1.4 89.02.07.13.31.34 Author: apratt
 * Reinstated mem, but made it more innocuous
 * 
 * Revision: 1.3 89.02.01.15.06.26 Author: apratt
 * oops
 * 
 * Revision: 1.2 89.02.01.14.45.34 Author: apratt
 * Removed "mem" command -- doesn't work for TOS 1.4.
 * 
 * Revision: 1.1 88.06.03.15.39.00 Author: apratt
 * Initial Revision
 * 
 */

/*
	docmd.c of gulam --  builtin commands			7/20/86

	copyright (c) 1986 pm@Case
*/

#include "gu.h"
#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local run P_((uchar *g, uchar *cmdln, uchar *envp));
local mkcmdenv P_((int flag, char *pgm, char **cmdp, char **envp));
local lexec P_((uchar *p, int flag));
local int noteredfnm P_((int r, char *fnm));
#undef P_

extern	uchar	ext[];

int	state = TRUE;		/* == T => do the cmd; == F => skip it	*/
long	valu;			/* result of calling the function	*/
uchar *	strg;			/* result string, if any		*/
uchar *	emsg;			/* error msg string, if any errors	*/
uchar	negopts[256];		/* -ve options				*/
uchar	posopts[256];		/* +ve options				*/
int	fda[4]			= {MINFH-1, MINFH-1,MINFH-1, MINFH-1};
uchar	*rednm[2] = { NULL, NULL};	/* names of redirections	*/
int	outappend = 0;


static	uchar	Sgulamend[]	= "gulamend.g";

/* Collect options from the users command.  This is invoked only
if the cmd is a builtin. All non-option words are given back to the
lex module. */

addoptions(p)
register uchar	*p;
{	register uchar	*q;
	register int	i;

	q = (*p == '+' ? posopts : negopts);
	while (i = (int) *++p) q[i] = (uchar) 1;
}

setdate()
{
	gsdatetime(lexgetword());
}

	local
run(g, cmdln, envp)		/* "run" the file given by the pathname g */
uchar *g, *cmdln, *envp;
{
	register uchar *p;
	uchar *rindex();		/* used to call index() (AKP) */

	emsg = NULL;
	p = rindex(g, '.'); if (p == NULL) goto pexecute;
	if (isgulamfile(p)) {valu = batch(g, cmdln, envp); return;}

	pexecute:
	keyreset();
	valu = execfile(g, cmdln, envp);
	keysetup();
	setgulam();	/* set _shell_p ptrs again	*/
}

/* Prepare command tail, and environment for Pexec() */
	local
mkcmdenv(flag, pgm, cmdp, envp)
int	flag;
char	*pgm, **cmdp, **envp;
{
#if	TOS
	static	 uchar	ARGVVAL[] = "ARGV=CCCP????????????????????????????";
#endif
	register uchar	*p, *q;
	register WS	*ws;
	int mwcflag = 0;

	ws = dupenvws(0);
#if	TOS
	p = varstr("env_style"); if (p == NULL || *p == '\000') p = "gu";
	if (flag == 0 && p[0] == 'm' && p[1] == 'w') /* Mark Williams style */
	{	strwcat(ws, ARGVVAL, 1);
		strwcat(ws, pgm, 1);
		appendlextail(ws);	/* all the args appended */
		mwcflag = 1;
	}
#endif
	*envp = ws->ps;	gfree(ws);

	ws = initws(); strwcat(ws, ES, 1); /* 1 byte for length */
	strwcat(ws, lextail(), 0);
	if (ws == NULL) *cmdp = NULL;
	else
	{	p = *cmdp = ws->ps;
		*p = (uchar) (ws->nc - 1); /* 'cmdln' of Pexec needs length */
#if	TOS
		/* A little range checking might lighten things up... (AKP) */
		if ((ws->nc-1) > 0x7e) *p = 0x7e;
		if (mwcflag) *p=0x7f;	/* validate ARGV in env (AKP) */
#endif
	}
	gfree(ws);
}

/* Execute file p: We search the hash table first; then try as is;
then try appending .tos|.ttp|.ttp|.g.  If flag != 0, just see if p is
batch-able as is.  */

	local
lexec(p, flag)
register uchar *p;
{
	extern	uchar	Status[];	/* in tv.c	*/

	register uchar	*q, *lst;
	register int	i, n;
	uchar	*cmdln, *envp, *g;

	mkcmdenv(flag, p, &cmdln, &envp);
	if (flag)     {valu = batch(p, cmdln, envp); goto freecmdln;}
	if (q = hashlookup(0, p)) {run(q, cmdln, envp); goto freecmdln;}

	q = fnmsinparent(p); lst = strg; strg = NULL;
	n = matchednms(lst, q, 0); /* first try as-is in current dir	*/
	if (n == 1) {run(p, cmdln, envp); if (valu != EFILNF) goto freelst;}

	valu = EFILNF; g = NULL; n = 0;

#if	TOS
	if (q = str3cat(q, ".(g|tos|ttp|prg)", ES))
		{n = matchednms(lst, q, 1); gfree(q);}
	if (g = str3cat(p, ".xxx", ES))
	{  if (n > 0)
	   {	for (q = g + strlen(p) + 1, i=0; i < SZext-1; i += 4)
		{	strcpy(q, &ext[i]);
			run(g, cmdln, envp);
			if (valu != EFILNF) break;
	   }	}
	} else valu = ENSMEM;
#endif
	if (valu == EFILNF && (q = hashlookup(1, p)))
		{run(q, cmdln, envp); goto freelst;}
	if (valu == ENSMEM) emsg = "not enough memory";
	if (valu == EFILNF) emsg = (char *) sprintp("%s: not found", p);

	freeg:		gfree(g);
	freelst:	gfree(lst);
	freecmdln:	gfree(cmdln);	gfree(envp);
	insertvar(Status, itoa(valu));
}


source()
{
	lexec(lexgetword(), 1);
}

echo()
{
	strg = strdup(lextail());
}

bexit()
{	register char	*p;
	register int	n;

	n = atoi(lexgetword());
	if (inbatchfile()) {csexit(n); return;}

	if (quickexit(0, 1) !=  1) return 0;
	invisiblecursor();
	mouseon();
	cd (varstr("home"));
	p = fnmpred ('e', Sgulamend);
	if (*p == '1') processcmd(strdup(Sgulamend), 0);
	savehistory();
	keyreset();
	exit(n);
}

/* Ask, if the -i option is present, if "op p?".  Return 1 if okayed,
0 if nayed, and ABORT (==2), if aborted.  */

asktodoop(op, p)
register uchar	*op, *p;
{
	return	(negopts['i']
		? mlyesno(sprintp( "%s %s?", op, p))
		: 1);
}

doforeach(op, f)		/* do f() for each word in current cmd */
register uchar	*op;
register int	(*f)();
{
	register uchar	*p;
	register int	flag;

	for (;;)
	{	p = lexgetword(); if (*p == '\000') break;
		flag = asktodoop(op, p);
		if (flag == ABORT) break;
		if (flag) (*f)(p);
		if (useraborted()) break;
	}
	mlmesg(ES);
}

setuekey()
{	register uchar	*p, c;
	register int	n;

/*
	p = lexgetword();
	if (*p != '-') n = 0;
	else	
		{ c = p[1]; n = (c == 'm'? 2 : (c == 'g'? 1 : 0)); }
*/
	/* REGKB = 0, MINIKB == 2, GUKB == 1		*/
	n = (negopts['m']? 2 : (negopts['g']? 1 : 0)); 
	p = lexgetword();
 	bindkey(n, p, lexgetword()); 	/* see ue's kb.c */
}

	local	int
noteredfnm(r, fnm)
register int	r;
register char	*fnm;
{
	register char	c;

	c = *fnm;
	if (c == '>')
	{	r = 1; outappend = 0;
		if (fnm[1] == '>') {fnm++; outappend = 1;}
	} else
	{	if (c == '<') r = 0;
		else  if (r <= 1) fnm--; else return 3;
	}

	if (fnm[1])
	{	gfree(rednm[r]);
		unquote(fnm+1, fnm+1);
		rednm[r] = strdup(fnm+1);
		r = 2;
	}
	return r;
}

/* Unquote the arguments to cmd (ie., the ws->ps stringlets) in place.
Also, note redirections and options (if builtin cmd).  As we handle
the redirs, p will lag behind q; if there are no redirs, p will == q
all the time.  */

processargs(builtin, unqflag)
int	builtin, unqflag;
{
	register WS	*ws;
	register uchar	*p, *q;
	register int	i, k, n, redi, brl;

	ws = useuplexws(); redi = 3;
	if (ws && (q = p = ws->ps))
	{ for (brl = 0, i = ws->ns; i-- > 0; q += n + 1)
	  {	n = strlen(q); k = *q;
		if (k == '{') brl++; else if (k == '}') brl--;
		redi = (brl == 0? noteredfnm(redi, q) : 3);
		if (redi < 3)  ws->ns --;
		else
		{ if (builtin && (k == '-' || k == '+'))
			{addoptions(q); ws->ns--;}
		  else
		  if (unqflag) p = unquote(p, q)+1;
		  else
		  {if (p < q) cpymem(p, q, n);  p += n+1;}
	  }	}
	  *p++ = '\000';
	  ws->nc = (int)(p - ws->ps);
	}
	lexaccept(ws);
	doredirections();
}

#if	TOS
extern	Gem(); 					/* gmc.c	*/
extern	mouseon(),	mouseoff();		/* gmc.c	*/
extern	format(),	dm(),
	lpeekw(),	lpokew(),
 	mem();
#endif
extern	ue(),	fg(),	moreue();		/* ue.c		*/
extern	gulamhelp();				/* main.c	*/
extern	alias(),	unalias();		/* exp.c	*/
extern	history();				/* history.c	*/
extern	ls(),		fnmtbl();		/* ls.c		*/
extern	settime(),	time(),
	setdate();				/* gmc.c	*/	
extern	rehash(),	cmdwhich();		/* rehash.c	*/
extern	setvar(),	unsetvar(),
	unsetenv(),	setenv(),
	printenv();				/* env.c	*/
extern	cp(),		copy(),
	mv(),		touch(),
	cat(),		df(),
	chmod(),	rename(),
	rm(),		dirs(),
	pushd(),	popd(),
	mkdir(),	rmdir(),
	pwd(),		cdcmd();		/* fop.c	*/
#if	LPRINT
extern	print(),	lpr();			/* pregrep.c	*/
#endif
extern	egrep(),	fgrep();
extern	source(),	batch(),		/* cs.c		*/
	csif(),		cselse(),
	csendif(),
	cswhile(),	csendwhile(),
	csforeach(),	csendfor();
#ifdef	XMDM
extern	temul(),	teexit();		/* gmc.c	*/
extern	rxmdm(), sxmdm();			/* xmdm.c	*/
#endif
			/* b->type values */
#define	OWNWAY		2	/* cmd handles args own way	*/
#define	ARGREQ		4	/* 1=>0/1 arg reqd		*/
#define	PREFIX		6	/* cmd is a prefix to others	*/
#define	NOUNQU		8	/* don't do unquote for this	*/
#define	DOEACH		10	/* do the cmd for each arg	*/
#define	BATCHS		12	/* ok in batch files only	*/
/* +1 	added 		if 	cmd may change dir contents	*/

	local			/*   built-in commands  	*/
struct bi
{	uchar	*name;		/* name of builtin cmd		*/
	uchar	len;		/* strlen of the cmd name	*/
	uchar	type;		/* cmd type; see below		*/
	int	(* rtnp)();
} builtins[]			/* must list in alpha order	*/
= {						/* type=> ...	*/
	"alias",	5, OWNWAY,	alias,
	"cat",		3, DOEACH,	cat,
	"cd",		2, ARGREQ,	cdcmd,
	"chmod",	5, DOEACH+1,	chmod,
	"copy",		4, OWNWAY+1,	cp,
	"cp",		2, OWNWAY+1,	cp,
	"date",		4, ARGREQ,	setdate,
	"df",		2, DOEACH,	df,
#if	TOS
	"dm",		2, OWNWAY,	dm,
#endif
	"dirc",		4, OWNWAY,	fnmtbl,
	"dirs", 	4, OWNWAY,	dirs,
	"echo", 	4, OWNWAY,	echo,
	"egrep",	5, OWNWAY,	egrep,
	"ef",		2, BATCHS,	cselse, /* invoke even if state==F */
	"endfor",	6, BATCHS,	csendfor,
	"endif",	5, BATCHS,	csendif, /* invoke even if state==F */
	"endwhile",	8, BATCHS,	csendwhile,
	"exit", 	4, OWNWAY,	bexit,
	"fg",		2, OWNWAY,	fg,
	"fgrep",	5, OWNWAY,	fgrep,
	"foreach",	7, BATCHS,	csforeach,
#if	TOS
	"format",	6, DOEACH+1,	format,
	"gem",		3, PREFIX,	Gem,
#endif
	"grep",		4, OWNWAY,	egrep,
	"help",		4, OWNWAY,	gulamhelp,
	"history", 	7, OWNWAY,	history,
	"if",		2, BATCHS,	csif, /* invoke even if state==F */
	"kb",		2, OWNWAY,	setuekey,
#if	LPRINT
	"lpr",		3, OWNWAY,	lpr,
#endif
	"ls",		2, OWNWAY,	ls,
#if	TOS
	"mem",		3, OWNWAY,	mem,
#endif
	"mkdir",	5, DOEACH+1,	mkdir,
	"more",		4, OWNWAY,	moreue,
#if	TOS
	"mson",		4, OWNWAY,	mouseon,
	"msoff",	5, OWNWAY,	mouseoff,
#endif
	"mv",		2, OWNWAY+1,	mv,
#if	TOS
	"peekw",	5, OWNWAY,	lpeekw,
	"pokew",	5, OWNWAY,	lpokew,
#endif
	"popd", 	4, OWNWAY,	popd,
#if	LPRINT
	"print",	5, OWNWAY,	print,
#endif
	"printenv",	8, OWNWAY,	printenv,
	"pushd",	5, ARGREQ,	pushd,
	"pwd", 		3, OWNWAY,	pwd,
	"rehash", 	6, OWNWAY,	rehash,
	"ren",		3, OWNWAY+1,	rename,
	"rm", 		2, DOEACH+1,	rm,
	"rmdir",	5, DOEACH+1,	rmdir,
#if	XMDM
	"rx",		2, DOEACH+1,	rxmdm,
#endif
	"set",		3, NOUNQU,	setvar,
	"setenv",	6, OWNWAY,	setenv,
	"source", 	6, OWNWAY,	source,
#if	XMDM
	"sx",		2, DOEACH,	sxmdm,
	"te",		2, OWNWAY,	temul,
	"teexit",	6, OWNWAY,	teexit,
#endif
	"time",		4, PREFIX,	time,
	"touch",	5, DOEACH,	touch,
	"ue",		2, OWNWAY+1,	ue,
	"unalias",	7, OWNWAY,	unalias,
	"unset",	5, OWNWAY,	unsetvar,
	"unsetenv",	8, OWNWAY,	unsetenv,
	"which",	5, OWNWAY,	cmdwhich,
	"while",	5, BATCHS,	cswhile,
	NULL, 		0, OWNWAY,	NULL
};

#define NBC	((int)(sizeof(builtins) / sizeof(struct bi)))
#define	MXL	8	/* length of longest built-in cmd	*/
#define	MXC	8	/* #columns in the showbuiltin list	*/

showbuiltins()
{	register struct bi *	b;
	register uchar	*s;
	register WS	*ws;

	outstr(sprintp("%d built-in commands:", NBC-1));

	ws = initws();  if (ws == NULL) return;
	for (b = builtins; b->name != NULL; b++)
		strwcat(ws, b->name, 1);
	s = pscolumnize(ws->ps, -1, 0);
	outstr(s); gfree(s); freews(ws);
}

docmd()
{
	register struct bi *	b;
	register uchar		*p;
	register int		lw, i, btype;

	valu = 0; strg = emsg = NULL;
	charset(negopts, ES, 1); charset(posopts, ES, 1);

	p = lexgetword(); lw = strlen(p); i = 1;
	if (lw <= MXL)
	   for (b = builtins; b->name; b++)
	   {	if ((int) b->len != lw) continue;
		i = strcmp(p, b->name);
		if (i <= 0) break;
	   }

	/*
	 * STOOPID! btype used to be set to b's type whether or not
	 * b was actually the command you typed in! Now btype for
	 * non-builtins is one, meaning the command may change dir stuff
	 * Also, btype is compared against values, not bits, so you'd
	 * better not try to set more than one bit (except the +1 bit).
	 */

	if (i != 0) btype = 1;
	else btype = (int) b->type;

	lw = btype & 0x0001;
	btype &= 0x00FE;	/* i==0 => built-in command	*/
	if (i == 0 && btype == BATCHS)
	{	if (! inbatchfile()) goto skipit;
	} else  if (state != TRUE)   goto skipit;

	if (btype != PREFIX)
	{	processargs(i == 0, btype != NOUNQU);
		p = lexgetword();	/* see above rtn ... */
	}
	if (i == 0)
	{	if (btype == DOEACH) doforeach(p, b->rtnp);
		else (*(b->rtnp))(p);
	}
	else	{lexec(p, 0); lw = 1;}

	skipit:
	if (lw || varnum("dir_cache") == 0) freewtbl();
}

/* -eof- */
