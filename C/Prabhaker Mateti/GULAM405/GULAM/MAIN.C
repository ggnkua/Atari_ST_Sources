/*
	main.c -- main file of a new shell, called gulam	10/11/86

	copyright (c) 1987 pm@cwru.edu
*/

#include "gu.h"

extern	int	exitue;		/* see ue.c	*/
extern	uchar	Shell[], 	OS[],
		Gulam[],	GulamLogo[],
		Copyright[],	defaultprompt[],
		Scrninit[]; 	/* clr scrn, cursr off, wordwrap on */

extern	long	_stksize;
extern	long	getticks(), starttick;

uchar	cnmcomplete	= ESC;
uchar	cnmshow		= CTRLD;

local	uchar	ID[] =			/* id of this program		*/
"\r\n\
beta-test version 1.03.04.03 121387 of\r\n\
yet another shell for %s\r\n\r\n\
(non-profit redistribution is permitted)\r\n\r\n\
%s  Copyright %s 1987 pm@cwru.edu\r\n\
\r\n";


/**	last alpha	0.09.09.15 090687 of\r\n\ **/

showid()	{outstr(sprintp(ID, OS, GulamLogo, Copyright));}
outstrg()	{outstr(strg); gfree(strg); strg = NULL;}
outemsg()	{outstr(emsg); emsg = NULL;}

/* Make a gmalloc'd copy of the prompt; when freeing, must be gfreed
*/
	uchar *
getprompt()
{
	register uchar	*p, *q;
	register WS	*ws;

	p = varstr("prompt");
	if (*p == '\000') p = strdup(defaultprompt);
	else
	{	ws = expand(strdup(p), 0);
		p = catall(ws, 0);	/* p now == ws->ps */
		gfree(ws);
	}
	q = str3cat(p, varstr("prompt_tail"), ES); gfree(p);
	return q;
}

gulamhelp()
{
	showid(); showbuiltins();
	outstr("\r\nprograms accessible through hash table:");
	which(0);
	if (strg == NULL || *strg == '\000')
		outstr("none! (your hash table is empty)");
	outstrg();	/* at least gfree(strg)	*/
	keysetup();	/* may have been clobbered by the Pexec'd progs */
	state = TRUE;
}

	unsigned int
userfnminput(p, sz, fn, pexp)
register uchar	**p;
register int	sz, pexp, (*fn)();
{	uchar	*q;
	register uchar	*r, c;
	register int	n;

	for (;;)
	{	c = getuserinput(*p, sz);
		if (c != cnmcomplete && c != cnmshow) break;
		n = fnmexpand(p, &q, pexp, 1); /* 1 ==> TENEX */
		if (c == cnmshow && n > 1 && fn != NULL)
		{	r = pscolumnize(q, -1, -1);
			if (r) {(*fn)(r); gfree(r);}
			mlmesg(NULL);
		}
		gfree(q);
	}
	return	c;
}
	static
showcompletes(r)
register uchar	*r;
{
	gputs(CRLF); gputs(r);
}

/* Get one (cmd) line from user.  Include esc-name
completion. */

	uchar	*
getoneline()
{	char	*p;
	register unsigned int	u;

	tominibuf();
	if (p = gmalloc(SZcmd))
	{	*p = '\000';
		u =  userfnminput(&p, SZcmd, showcompletes);
		if (u == '\007') *p = '\000';
	}
	return p;
}

/* Get one cmd, and do it.  Called from (1) within this file, (2) from
misc.c via spawn(), and (3) via _shell_p */

getcmdanddoit()
{	register char	*p;

	p = getoneline(); gputs(CRLF);
	processcmd(p, 1);	/* processcmd() frees p */
}

time()				/* called from docmd(); see do.c */
{	register WS	*ws;

	starttick = getticks();
	ws = useuplexws();	shiftws(ws, 1);
	gfree(execcmd(ws));
}

	uchar *
execcmd(ws)
register WS	*ws;
{	register char	*qq;

	qq = NULL; if (stackoverflown(256)) goto ret;
	ws = aliasexp(ws);  
	if (ws && ws->ps)
	{	lexaccept(ws);
		if (ws->ps[0])
		{	qq = strdup(lexsemicol());
			docmd();
		}
	} else  ret: freews(ws);
	/* do not freews(ws) ow because lex() will later on */
	return qq;
}


/* Process the given line as a shell cmd: store it in history (if
savehist != 0), expand it, and finally run it.  The globals strg,
emsg, valu are initialized in docmd(), and contain the results at the
end.  The semicolon counting is there to break possible recursion in
aliassed cmds containing semicolons.  */

processcmd(qq, savehist)
register char	*qq;
register int	savehist;
{	register char	*p;
	register WS	*ws;
	register int	nsemi, maxsemi;

	if ((qq == NULL) || (*qq == '\000')) {gfree(qq); return;}
	emsg = NULL;
	if (index(qq, '!'))
	{	p = substhist(qq);	/* p != qq => qq got freed there */
		if (p != qq) userfeedback(p, 0);
		outemsg();
	} else	p = qq;
	if (savehist) remember(p);
	ws = expand(p, 0);	/* expand frees p */
	if (emsg) {outemsg(); freews(ws); return; }
	maxsemi = varnum("semicolon_max");  if (maxsemi <= 0) maxsemi = 20;
	for (nsemi=0;;)
	{	if (varnum("time")) starttick = getticks();
		if ((++nsemi > maxsemi) || useraborted())
			{freews(ws); valu = -nsemi; qq = NULL;}
		else
		{	qq = execcmd(ws);
			outstrg();
			undoredirections();
			outemsg();
		}
		if (valu) outstr(sprintp("cmd exit code %d", (int) valu));
		valu = 0L;
		computetime();
		if (qq == NULL)  break;		/* <== */
		lex(qq, DELIMS, TKN2); gfree(qq);
		ws = useuplexws();
}	}

/* main() of Gulam.  If argc > 1, the shell is being invoked for
non-interactive work.  */

main(argc, argv, envp)
register int	argc;
register char	**argv, **envp;
{
	register uchar	*p;
	register WS	*ws;
	register int	m, nco;
	extern	uchar	Verbosity[], Ncmd[], Cwd[], Home[];

	ueinit();  if (exitue == 3) exit(-1);
	setgulam();

	readinenv(*envp);	/* read in the supplied environment	*/
	if (p = gfgetcwd())
	{	insertvar(Home, p);
		insertvar(Cwd,  p);
		gfree(p);
	}
	insertvar(Ncmd, itoa((long) 1L));
	insertvar(Verbosity, "2");

	if (argc == 1) goto interactive;
	processcmd(strdup("gulam.g"), 0);
	processcmd(strdup("rehash"), 0);
	for (nco = 1;  argc-- > 1;)
	{	p = *++argv;
		if (nco && strcmp(p, "-c")) processcmd(strdup(p), 0);
		else
			if (nco) {nco = 0; ws = initws();}
			else strwcat(ws, p, 1);
	}
	if ((nco == 0) && ws)
	{	p = catall(ws, 0);
		processcmd(p, 0); /* ws->ps is freed here */
		gfree(ws);
	}
	exit ((int)valu);

	interactive: tioinit();
	exitue = -1; update(); mlerase(); showid();
	processcmd(strdup("date"),    0);
	processcmd(strdup("gulam.g"), 0);
	readhistory();
	m = varnum("show_mem");

	for (;;)
	{
		getcmdanddoit();	/* see bexit() in do.c */
		if (m) processcmd(strdup("mem"), 0);
	}
}


/* -eof- */
