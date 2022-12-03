/*
 * $Header: f:/src/gulam\RCS\tv.c,v 1.1 1991/09/10 01:02:04 apratt Exp $ $Locker:  $
 * ======================================================================
 * $Log: tv.c,v $
 * Revision 1.1  1991/09/10  01:02:04  apratt
 * First CI of AKP
 *
 * Revision: 1.5 90.02.13.14.33.14 apratt 
 * Added Mdmport[] and setmdmport() in variable table - see gioatari.c.
 * 
 * Revision: 1.4 90.02.05.14.24.10 apratt 
 * Added variable Font[] = "font" with handler font().
 * 
 * Revision: 1.3 89.06.16.17.24.06 apratt 
 * Header style change.
 * 
 * Revision: 1.2 89.06.02.13.42.00 Author: apratt
 * Compiler generated incorrect code for tbldelete when it
 * had register variables.  Don't ask my why; I just ripped them out.
 * 
 * Revision: 1.1 88.06.03.15.38.46 Author: apratt
 * Initial Revision
 * 
 */

/*sep 9, 86

	tbl.c 	of gulam -- a simple table mechanism
	alias.c	of gulam -- alias module
	env.c 	of gulam -- environment maintainer
	var.c	of gulam -- shell var maintainer
	hlp.c   of gulam -- help, what little there is

	copyright (c) 1986 pm@Case

	These modules are together here for no good reason;
	they were just too short!
*/

#include "gu.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local putenv P_((uchar *p, uchar *q));
local rdhelpln P_((uchar *q, int nb));
#undef P_

/* Notes: This table module can create and maintain simple tables of two
columns; the first column has to be a string, the second column is whatever.
The first node in the TBLE list is used as a header.  The key-, and elm-fields
(except those of hdr) point to malloc'd areas; key pts to a string, elm can
be arbitrary.
*/


/**				see "gu.h"
typedef	struct TBLE {
	uchar *		key;	ascii uchar string to search for
	uchar *		elm;	ptr to arbitrary data
	struct TBLE *	next;	next element in the table
}	TBLE;
**/

	TBLE *
tblfind(t, k)
TBLE	*t;
register uchar		*k;
{
	register TBLE *p;

	p = NULL;
	if (k && (p = t))
	do {
		p = p->next;
	} while (p && (strcmp(p->key, k)) != 0);
	return p;
}

tbldelete(t, k)
TBLE	*t;
uchar		*k;
{
	TBLE *p;
	TBLE *q;

	if ((k==NULL) || ((p = t)==NULL)) return;
	do {
		q = p;
		p = p->next;
	} while (p && (strcmp(p->key, k)) != 0);
	if (p) {
		q->next = p->next;
		gfree(p->key);
		gfree(p->elm);
		gfree(p);
}	}


tblinsert(t, k, e)
TBLE	*t;
uchar		*k, *e;
{
	register TBLE *p;

	if ((t==NULL) || (k==NULL) || (e==NULL)) return;
	tbldelete(t, k);
	if (p = (TBLE *) gmalloc(((uint)sizeof(TBLE))))
	{	p->key = k;
		p->elm = e;
		p->next = t->next;
		t->next = p;
}	}

/* Create a new table. */

	TBLE *
tblcreate()
{
	register TBLE *p;

	if (p = (TBLE *) gmalloc(((uint)sizeof(TBLE))))
	{	p->key	=
		p->elm	=
		p->next = NULL;
	}
	return p;
}

tblfree(t)
TBLE *t;
{
	register  TBLE *p, *q;

	for (p = t; p; p = q)
	{	q = p->next;
		gfree(p->key);
		gfree(p->elm);
		gfree(p);
}	}

/* Make a WS out of table's contents, in the requested style.
 0 => columnar format (a->key's only)	1 => key \t elm \r\n
 2 => key = elm \r\n			3 => key = elm \0
 4 => key =\0 elm \0
*/
	WS *
tblws(t, style)
register  TBLE	*t;
{	register  TBLE	*a;
	register int		i;
	register WS		*ws;
	uchar			seps[2];

	if (t == NULL) return NULL;
	ws = initws(); if (ws == NULL) return NULL;
	seps[0] = (style < 2? '\t' : '=');	/* separator uchar */
	seps[1] = '\000';
	i = (style == 0? 1: 0);
	for (a = t->next; a; a = a->next)
	{	strwcat(ws, a->key, i);
		if (style)
		{	strwcat(ws, seps, 0);
			if (style == 4) strwcat(ws, ES, 1);
			strwcat(ws, a->elm, 0);
			if (style < 3) strwcat(ws, CRLF, 0);
			else strwcat(ws, ES, 1);
		}
	}
	return ws;
}

	uchar *
tblstr(t, style)
register  TBLE	*t;
{	register WS	*ws;
	register uchar	*p;

	ws = tblws(t, style); if (ws == NULL) return NULL;
	p  = ws->ps;
	if (style == 0) {p = pscolumnize(p, -1, 0); gfree(ws->ps);}
	gfree(ws);
	return p;
}

/* -eof tbl.c- */

local  TBLE	*alip = NULL;

alias()			/* show/set alias(es)	*/
{	register uchar	*p, *q;

	p = lexgetword();
	if (*p)
	{  q = lextail();
	   if (*q)
	   {	if (alip == NULL) alip = tblcreate();
		tblinsert(alip, strdup(p), strdup(q));
	   }else strg = strdup(getalias(p));
	}
	else	strg = tblstr(alip, 1);
}

unalias()	{tbldelete(alip, lexgetword());}

	uchar *
getalias(p)		/* return the alias'd string, if any, or itself */
register uchar *p;
{
	register  TBLE	*a;

	a = tblfind(alip, p);	
	return (a? a->elm : p);
}

/* eof alias.c	*/
/* env.c of shell -- environment maintainer			*/

local  TBLE	*envp = NULL;

	uchar *
ggetenv(p)			/* get string value of env var whose	*/
register uchar *	p;		/* name appears in *p...		*/
{	register  TBLE	*a;

	a = tblfind(envp, p);	
	return (a? a->elm : NULL);
}

	local
putenv(p, q)			/* insert name p with string value q	*/
register uchar *p, *q;
{
	if (envp == NULL) envp = tblcreate();
	tblinsert(envp, strdup(p), strdup(q));
}

	WS *		/* duplicate the env string; if flag, put in \r\n */
dupenvws(flag)
register int flag;
{
	flag = (flag? 2 : 3);
	if (flag == 3 && strcmp(varstr("env_style"), "bm") == 0) flag = 4;
	return tblws(envp, flag);
}

printenv()
{	register WS	*ws;
	
	ws = dupenvws(1);
	strg = ws->ps;
	gfree(ws);
}

setenv()
{
	register uchar *p, *q;

	p = lexgetword();
	q = lexgetword();
	if (*p) putenv(p, q);
	else  printenv();
}

unsetenv()	{tbldelete(envp, lexgetword());}

readinenv(p)
register uchar	*p;
{
	register uchar	*q, *r;

	if (p == NULL) return;
	for (; *p; p = r + strlen(r) + 1)
	{	q  = p;	p = index(p, '=');  if (p == NULL) break;
		*p = '\000';  r = p+1;  if (*r == '\000') r++;
		putenv(q, r);
		*p = '='; 
}	}

/* var.c == shell variables and their operations	*/

uchar	Gulam[]		= "Gulam";
uchar	Shell[]		= "shell";
uchar	GulamHelp[]	= "gulam_help_file";
uchar	Nrows[]		= "nrows";
uchar	OwnFonts[]	= "own_fonts";
uchar	History[]	= "history";
uchar	Cwd[]		= "cwd";
uchar	Home[]		= "home";
uchar	Rgb[]		= "rgb";
uchar	Path[]		= "path";
uchar	Status[]	= "status";
uchar	Verbosity[]	= "verbosity";
uchar	Mscursor[]	= "mscursor";
uchar	Ncmd[]		= "ncmd";
#if	AtariST
uchar	Font[]		= "font";	/* extension by AKP */
uchar	Mdmport[]	= "mdmport";	/* extension by AKP */
#endif

extern	rehash();
extern	histinit();
extern	rdhelpfile();

#if	AtariST
extern	nrow2550();
extern	font();				/* extension by AKP */
extern	setmdmport();			/* extension by AKP */
extern	pallete();
extern	mousecursor();
#endif

struct	SETVAR
{	int	(*fun)();	/* execute after updating the setvar	*/
	int	coupled;	/* ==1 iff coupled to  env var		*/
	uchar	*varname;	/* name of the set variable		*/
};

local	struct	SETVAR	stv[] =
{
	{NULL,		1,	Cwd},
	{rehash,	1,	Path},
	{histinit,	0,	History},
	{NULL,		1,	Home},
	{NULL,		1,	Shell},
	{rdhelpfile,	0,	GulamHelp},
#if AtariST
	{pallete,	1,	Rgb},
	{nrow2550,	1,	Nrows},
	{font,		0,	Font},		/* extension by AKP */
	{setmdmport,	0,	Mdmport},	/* extension by AKP */
	{mousecursor,	0,	Mscursor}
#endif
};

#define	Nstv	((uint)(sizeof(stv)/sizeof(struct SETVAR)))


local  TBLE	*varp = NULL;


	uchar *
varstr(p)		/* return the string value of a var */
register uchar *p;
{	register  TBLE	*a;

	a = tblfind(varp, p);	
	return (a? a->elm : ES);
}

varnum(p)
register uchar *p;
{
	register uchar *q;

	q = varstr(p);
	return (atoi(q));
}

showvars()
{	register TBLE	*p;

	if (varp == NULL) return;
	for (p = varp->next; p; p = p->next)
	{	gputs(sprintp("var %D %s=%s %D\r\n", 
			p->key,p->key, p->elm, p->elm));
	}	
	gputs("--\r\n");
}


insertvar(p, q)
register uchar *p, *q;
{	register int	i;
	register int	(*f)();

	if (varp == NULL) varp = tblcreate();
	q = strdup(q); 	unquote(q, q);
	tblinsert(varp, p = strdup(p), q);
	for (i=0; i < Nstv; i++)
	{	if (strcmp(p, stv[i].varname) == 0)
		{	if (stv[i].coupled)
			{	p = strdup(p);
				putenv(uppercase(p), q);
				gfree(p);
			}
			if (f = stv[i].fun) (*f)();
			break;
	}	}
}

setvarnum(p, n)
register uchar	*p;
register int	n;
{
	insertvar(p, itoa((long) n));
}

setvar()
{
	register uchar	*p;
	uchar		*dummy;

	p = lexgetword();
	if (*p)	insertvar(p, csexp(lexgetword(), &dummy));
	else  strg = tblstr(varp, 1);
} /* setvar() */

unsetvar()	{tbldelete(varp, lexgetword());}

/* -eof var.c-	*/
/* hlp.c	*/
local	int	nstate		= -1;
local	TBLE	*atbl[3]	= {NULL,NULL,NULL};

#define	XKCDNM	0	/* key code to key name		*/
#define XFCDNM	1	/* fn code to fn name		*/
#define	XGCMDD	2	/* Gulam cmd descriptive name	*/
#define	XUNSHI	3	/* key codes for unshifted keys	*/
extern	int	lnn, evalu;
extern	long	ntotal;

	local
rdhelpln(q, nb)
register uchar	*q;
register int	nb;
{	register uchar	*p;

	lnn++; ntotal += nb;
	if (q[0] == '#') {nstate = q[1] - '1'; return;}
	if (XKCDNM > nstate || nstate > XGCMDD) return;
	p = index(q, ' '); if (p == NULL || p == q) return;
	*p = '\000';
	tblinsert(atbl[nstate], strdup(q), strdup(p+1));
	*p = ' ';
}

/* Read the Gulam help file.  Called from setvar(). */

rdhelpfile()
{	register uchar	*p;
	register int	i;

	nstate = -1; p = varstr(GulamHelp); if (*p == '\000') return;
	for (i = XKCDNM; i <= XGCMDD; i++)
	{	tblfree(atbl[i]);
		atbl[i] = tblcreate();
	}
	frdapply(p, rdhelpln); gputs(CRLF);
}

/* Transform a key code into a name, using the above table.
*/
	uchar *
findname(x, k)
register int x, k;
{
	register uchar	*kp;
	register TBLE	*t;

	kp = itoar(0x1000L + (long) k, 16) + 1; /* skip the leading '1' */
	t  = tblfind(atbl[x], kp);
	return (t? t->elm : ES);
}

/* -eof- */
