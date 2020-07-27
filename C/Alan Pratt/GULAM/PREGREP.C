/*
	pregrep.c of gulam -- print, lpr, and grep functions	aug 24, 86

	copyright (c) 1986 pm@Case
*/

/* 890111 kbad	fixed bug in "prout" which would cause an extra header to
*		print(without formfeed) after the last page of a document.
*/

#include "gu.h"
#include "regexp.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local prout P_((char *p, int n));
local prvar P_((char *p, char *q));
local prinit P_(());
local header P_(());
local prline P_((char *q, int n));
local lprint P_((char *pnm));
local fgmatch P_((char *q, int n));
local legrep P_((char *pnm));
local igrep P_((int flag));
#undef P_

static	regexp	*re;
static	int	lnn;		/* line number			*/
static	char	*fnm;		/* name of current file		*/
static	int	lfnm;

#if	LPRINT

#define	LPPG	55		/* default lines per page	*/

static	int	nerr;		/* #errors			*/
static	int	lppg;		/* lines per page		*/

static	char	*hdr;		/* top of page hdr		*/
static	char	*pgp;		/* pos of pageno in hdr		*/
static	long	page;		/* # current page 		*/
static	int	lprf;		/* 1 iff lpr; 0 iff print 	*/

			/* printer initialization strings	*/
			/* the one below is for epson mx80		*/
/* "\033\D\010\020\030\040\050\060\070\100\200\"	set tabs	*/
/* "\033\C\102"					form length = 66	*/

	local
prout(p, n)		/* ouput to PRN:	*/
register char	*p;
register int	n;
{
	register char	c;
	static		header();

	if (n < 0) return;	/* jstncs	*/
	while (n--)
	{	c = *p++;
		do {
		  if (useraborted())  {	valu = -1; nerr++; return; }
		} while (printstatus()==0);
		printout(c);
		if (c == '\014' && n ) header();
}	}

	local
prvar(p, q)
register char	*p, *q;
{
	p = varstr(p);
	if (p == NULL || *p == '\000') p = q;
	prout(p, ((int)strlen(p)));
}
	local
prinit()		/* init before beginning to print/lpr */
{
	register char *p;

	nerr = 0;  page = 0; hdr = NULL;
	lppg = varnum("pr_lpp"); if (lppg <= 0) lppg = LPPG;
	prvar("pr_bof", ES);

	if( !lprf ) {
		gsdatetime(ES);		/* strg has date-time string */
		p = str3cat(strg, "  ", fnm);
		hdr = str3cat(p, "  Page ", "0123456789\r\n\n\n"); gfree(p);
		if (hdr) pgp = rindex(hdr, '0');
		gfree(strg); strg = NULL;
	}
	header();
}

	local
header()
{
	lnn = 1;
	page++;
	if (hdr)
	{
		strcpy(pgp, itoa(page));
		strcat(pgp, "\r\n\n\n");
		prout(hdr, ((int)strlen(hdr)));
		/* 1st page doesn't have the FF\n, so
		 * we must generate the \n.
		 */
		if( page == 1 ) prvar("pr_eol",CRLF);
	}
}

	local
prline(q, n)
register char	*q;
int		n;
{
	if (nerr)  return;

	/* FF followed by other chars signals end of page.
	 * Header is sent by prout(), because we want an embedded FF
	 * in a document to generate a header.
	 */
	if( (lnn++ % lppg) == 0 ) prvar("pr_eop","\014\n");
	prout(q, n);
	prvar("pr_eol", CRLF);
}

	local
lprint(pnm)		/* "print" one file	*/
register char *pnm;
{
	register int	fd;

	fd = gfopen(pnm, 0);	if (fd < 0) return;

 	fnm = pnm;  lfnm = strlen(fnm);  prinit();
	eachline(fd, prline);

	/* FF alone signals end of file, and will not generate
	 * a header in prout() after the last page.
	 */
	prvar("pr_eof", "\014");

	if (hdr) gfree(hdr);
}

print()
{
	lprf = 0;
	doforeach("print", lprint);
}

lpr()
{
	lprf = 1;
	doforeach("lpr", lprint);
}
#endif	LPRINT

	local
fgmatch(q, n)
register char	*q;
int		n;
{	register char	*s;

	lnn ++;
	if (regexec(re, q) == 1)
	{	s = gmalloc(((uint)(lfnm + strlen(q) + 20))); if (s == NULL) return;
		strcpy(s, fnm); s[lfnm] = ' ';
		strcpy(s+lfnm+1, itoa((long)lnn));
		strcat(s, ": ");
		strcat(s, q);
		outstr(s);
		gfree(s);
}	}

	local
legrep(pnm)
register char * pnm;
{
	register int	fd;

	fd = gfopen(pnm, 0);
	if (fd < 0) {emsg = "file not found"; return;}

	fnm = pnm;  lfnm = strlen(fnm); lnn = 0;
	eachline(fd, fgmatch);
}

	local
igrep(flag)			/* flag => fgrep; else egrep	*/
{
	char		meta[256];
	register char	*p, *q, *r, *s, c;

	p = strdup(lexgetword());	/* p has pattern */
	if (flag && (r = q = gmalloc(((uint)(1 + 2*strlen(p))))))
	{	charset(meta, "[()|?+*.$", 1); s = p;
		while (c = *p++){ if (meta[c]) *q++ = '\\'; *q++ = c;}
		*q = '\000';
		gfree(s); p = r;
	}
	if (p)
	{	re = regcomp(p);  gfree(p);
		if (re == NULL) valu = -1;
		else  	{doforeach("egrep", legrep); gfree(re);}
	}
}

egrep()		{igrep(0);}
fgrep()		{igrep(1);}

regerror(s)		/* called from within regexp.c	*/
register char *s;
{
	userfeedback(sprintp("ill formed regexp: %s", s), 0);
}

/* -eof- */
