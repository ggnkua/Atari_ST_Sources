/*
	hist.c of shell -- history substitutions etc	 3/27/86

	copyright (c) 1987 pm@Case
*/

#include "gu.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local uchar *strhist P_((uchar *p, uchar *q));
local uchar *wnumhist P_((int n, uchar *p, uchar *r));
local uchar *numhist P_((uchar *p, uchar *q));
local histstr P_((int flag));
#undef P_

#define	SZH	20		/* default size of hist[]	*/
local	uchar	HF[] = "histfile";
local	int	szh;		/* # cmds to be remembered	*/
local	uchar	**histp;	/* ptr to the remembered history */
local	int	nh;		/* # actual commands in h[]; == # \n's in h[]*/
local	int	hcount = 0;	/* # of cmds processed; >= 0	*/
local	uchar	NSH[] = 	"no such history";
local	int	nprevcmd;

histinit()		/* called from remember(), or after changing szh */
{
	register uchar **p;
	register int  x, i, j, n;

	szh = n = varnum("history");
	if (n <= 0) szh = n = SZH;
	p = histp;
	histp = (uchar **) gmalloc(n * ((uint)sizeof(uchar *)));
	if (histp == NULL) {histp = p; return;} /* histp could still be NULL */

	if (p)		/* copy old history into new area	*/
	{	if (n >= nh) {i = nh; j = 0;}
		else         {i = n;  j = nh - n;}
		for (x = i;  x < n;) histp[x++] = NULL;
		for (x = nh; x > j;) histp[--i] = p[--x];
		for (x = j;  x > 0;) gfree(p[--x]);
		gfree(p);
		if (n < nh) nh = n;
	}
	else	nh = 0;
	nprevcmd = 0;
}

/***
 Find the most recent cmd that matches the str starting at q
*/
	local	uchar *
strhist(p, q)
register uchar *p, *q;
{
   register uchar	*b;
   register int	n, i;

   i = strlen(q);
   for (n=nh-1; n >= 0; n-- ) {
       b = histp[n];
       if (strncmp(q, b, ((size_t)i)) == 0) goto subst;
   }
   emsg = NSH;
   b =  ES;
   subst:
   return str3cat(p, b, ES);
}

   local	uchar *
wnumhist(n, p, r)	/* Find the n-th command			*/
register int n;
register uchar *p, *r;
{
   register uchar	*b;
   register int	i;

   i = n + nh - hcount - 1;
   if ((0 <= i) && (i < nh)) b = histp[i];
   else	{emsg = NSH;	b =  ES;}
   return str3cat(p, b, r);
}

   local	uchar *
numhist(p, q)		/* Find the n-th command, where n is given in 	*/
register uchar *p, *q;	/* ascii digits starting at q			*/
{
   register uchar	*r;
   register int	c, n, minus;

   if  (*q == '-') {minus = 1; q++;} else minus = 0;
   for (r = q, n = 0;;)
   {	c = (int) *r++;
      if (('0' <= c) && (c <= '9')) n = 10*n + c - '0';
      else break;
   }
   r--;
   if (minus) n = hcount - n;
   return(wnumhist(n, p, r));
}

/* Get a previous command from history.  The prev cmd is one older than what
 was obtained through this routine last time, since the last call to
 remember().
*/
   uchar *
prevhist()
{	register int	n;

   n = nprevcmd ++;
   if (n == nh) nprevcmd = 0;
   return wnumhist(hcount - n, ES, ES);
}

/*************
 Substitute every substring of the form !xx with matched hist string.
 Unless substitutions do occur, return s as is.
 Otherwise, free s which does point to malloc'd area.
 `!!', `!number', `!string' => history
*/

   uchar *
substhist(s)
char *s;
{
   register char	*p, *q;
   register WS	*ws;
   register int	icq, nsubst;

   if (histp == NULL) return s;
  /* BTRNQD is " \t\r\n'\"" - ie whitespace or quotes */
   lex(s, BTRNQD, EMPTY2);  ws = initws();  nsubst = 0;
   while ((p = lexgetword()) && *p && (p = strdup(p))) {
       if (*p != '\'' && *p != '"')
           while (p && (q = index(p, '!')) && q[1]) {  /* lonely '!' doesn't count */
               nsubst++;
               *q = '\000';
               icq = (int) *++q;
               if (icq == '!') q = wnumhist(hcount, p, ++q);
               else if(('0'<=icq && icq<='9') || (icq == '-'))
                   q = numhist(p, q);
               else  q = strhist(p, q);
               gfree(p);
               p = q;
           } /* while */
       strwcat(ws, p, 1); gfree(p);
   } /* while */
   if (nsubst == 0) freews(ws);
   else  {gfree(s); s = catall(ws, 0); gfree(ws);} /* not freews(ws) */
   return s;
} /* substhist() */

remember(p, n)	/*  Insert a fresh copy of p into hist[]	*/
register char *p;
{
	register int	i;
	register uchar **hp;
	extern	uchar	Ncmd[];

	if (histp == NULL) histinit();
	hp = histp;	if (hp == NULL) return;
	if (nh < szh) nh ++;
	else
	{	gfree(*hp);
		for (i=0; i < nh-1; i++) hp[i] = hp[i+1];
	}
	hp[nh-1] = strdup(p);
	hcount++;
	nprevcmd = 0;
	insertvar(Ncmd, itoa((long) (1+hcount)));
}

/* List history into strg; if flag != 0, include line numbers	*/
	local
histstr(flag)
register int	flag;
{
	register int	i, n;
	register uchar **hp;
	register uchar *p, *q;

	hp   = histp;	if (hp == NULL) return;
	for (i=0, n=0; n < nh; n++) i += strlen(hp[n]);
	p = strg = gmalloc(i + nh*(8) + 1); /* 8 == #\r\n + 5digits + 1space */
	if (p == NULL) return;

	i = hcount - nh;
	for (n=0; n < nh; n++)
	{	if (flag)
		{  q = itoa((long) (++i));
		   strcpy(p, "     ");  p += 5;
		   strcpy(p - strlen(q), q); *p++ = ' ';
		}
		strcpy(p, hp[n]);  p += strlen(hp[n]);
		strcpy(p, CRLF);
		p += 2;
	}
}

history()
{	register uchar	*p;
	histstr(((p = lexgetword()) && (p[0] == '-') && (p[1] == 'h')? 0 : 1));
}

#define	FIOSUC	0		/* see ue:  "..\\ue\\ed.h"	*/

/* Read the history saved from a previous session into the history
data structure */

readhistory()
{	register uchar	*p;
	int		fd;

	p = varstr(HF);
	if (*p == '\000' || (fd = gfopen(p, 0)) < 0) return;
	eachline(fd, remember);	/* remember does not need a 2nd arg */
}

savehistory()
{	register uchar	*p;

	p = varstr(HF);
	if (*p == '\000' || ffwopen(p) != FIOSUC) return;
	histstr(0);
	ffputline(strg, ((int)strlen(strg)));
	gfree(strg); strg = NULL;
	ffclose();
}

/* -eof- */
