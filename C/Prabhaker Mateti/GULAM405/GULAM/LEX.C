/*
	lex.c of gulam					10/10/86

	copyright (c) 1986 pm@Case
*/

/* Given a string (may be multi-line long), this module produces a
 WS-style sequence of stringlets, each stringlet being a lexeme.
*/

#include "gu.h"

uchar	DELIMS		[256];	/* these are inited in lex()	*/
uchar	SUBDELIMS	[256];
uchar	COMMA		[256];
uchar	BTRNQD		[256];
uchar	TKN2		[256];
uchar	EMPTY2		[256];
uchar	WHITE		[256];	/* white chars		*/
uchar	WHITEDELIMS	[256];
/*
Note 1: WHITE[0] must be 0, or else the first loop in nextlexeme()
	won't terminate.
Note 2:	DELIMS[0] = SUBDELIMS[0] = COMMA[0] = BTRNQD[0] must be set to 1,
	or else the second loop of nextlexeme() won't terminate.
*/

local	WS	*ws	= NULL;
local	int	nlxm;		/* # stringlets in ws		*/
local	int	clxm;		/* # current lxm		*/

local	uchar	*lxnextp; /* ptr to next word in the line being parsed	*/
local	uchar	*bgnp;
local	uchar	prevc;

local	uchar	*delim;
local	uchar	*lxm2b;
local	uchar	*lxm2s;
local	uchar	tkn2s[] = ">>>=<===!=/==~/~";

/* Return p + (0, 1 or 2)==length of the delim-based lexeme.
*/
	local	uchar *
stdlxm(p)
register uchar *p;
{
	register uchar *q, c, c1;

	if (lxm2b[c = *p])
		for (c1=p[1], q=lxm2s; q = index(q, c); q += 2)
			if (q[1] == c1) return p+2;
	return ++p;
}

	local uchar *	/* *p is either ' or "; find a matching quote	*/
quotedword(p)		/* and terminate it with \0			*/
register uchar *p;
{
	register uchar	c, sdq;

	sdq = *p;	/* single or double qoute	*/
	matchsdq:
	while ((c = *++p) && (c != sdq));
	if (c != sdq) emsg = "unmatched quote";
	else
	{	if (p[-1] == '\021') goto matchsdq; /* ^Q */
		++p;
	}
	return p;
}

/* Determine the extent of the next lexeme, and null-terminate it,
 return ptr to the 1st non-space uchar of the lexeme. [bgnp .. lxnextp-1]
 is the lexeme.  If bgnp >= lxnextp implies that there are no more lexemes
 on this line.
*/
	local uchar *
nextlexeme()
{
	register uchar	*p, *q;
	register int	tlx;		/* length of token	*/
	
	p = lxnextp; q = delim;
	*p = prevc;  if (*p == '\000') {bgnp = p;  return NULL;}
	while (WHITE[*p]) p++;	/* Note 1 */
	bgnp = p;
	while (!q[*p]) p++;	/* Note 2 */
	tlx = p - bgnp;
	if (!tlx)	/* lexeme length == 0; so, that was a delimiter */
	{	if ((*p == '\'') || (*p == '"')) p = quotedword(p);
		else if (*p) p = stdlxm(p);
	}
	lxnextp = p;  prevc = *p;  *p = '\000';
	return bgnp;
}

/* Tokenize the given string p, and return a ws-format string.  Each stringlet
 in ws will be a lexeme. dlm is the string of delimiters; t2 is a string 2-char
 long special lexemes that begin with a non-white delimiter.  dlm may or
 may not include white chars.
*/
	WS *
lex(p, dlm, t2)
register uchar *p, *dlm, *t2;
{
	static	int	lxnotinited = 1;

	if (lxnotinited)
	{	lxnotinited = 0;
		charset(WHITE, " \t\r\n", 1);
		charset(WHITEDELIMS, " \t\r\n", 1);
		charset(DELIMS,"; \t\r\n`'\"" , 1);
		charset(SUBDELIMS, "!@#$%^&-=+`{}:;'\"\\|,.<>/", 1);
		charset(COMMA, ",", 1);
		charset(BTRNQD, " \t\r\n'\"", 1);
		/* Note 2 */
		WHITEDELIMS[0] =
		DELIMS[0] = SUBDELIMS[0] = COMMA[0] = BTRNQD[0]= (uchar) 1;
		charset(TKN2,">=<!/~" , 1);
		charset(EMPTY2, ES, 1);
	}
	delim = dlm;
	lxm2b = t2;
	lxm2s = (t2 == TKN2? tkn2s : ES);
	if (p == NULL) p = ES;
	prevc = *p;  lxnextp = p;
	freews(ws);   ws = initws();
	for (nlxm = clxm = 0; p = nextlexeme(); nlxm++)
		strwcat(ws, p, 1);
	return ws;
}

/* Use up lex ws: used in doing args for $n substitutions
*/
	WS *
useuplexws()
{	register WS	*w;

	w = ws; ws = NULL;
	nlxm = clxm = 0;
	return w;
}
	uchar *
lexgetword()	{return (ws && clxm < nlxm? nthstr(ws->ps, clxm++) : ES);}

	uchar *
lexlastword()	{return (ws && clxm < nlxm? nthstr(ws->ps, --nlxm) : ES);}

	uchar *
lextail()	{return catall(ws, clxm);}

appendlextail(w)
register WS	*w;
{	
	appendws(w, ws, clxm);
}

	uchar *	/* cat all stringlets numbered 0..nlxm-1, return result	*/
lexhead()
{
	if (ws) ws->ns --;
	return catall(ws, 0);
}

/* If there is a ';' stringlet among those in ws, null it, and return
 the remainder as a regular (ie., one \0, non-WSPS) string.
*/
	uchar *
lexsemicol()
{	register int	i, n;
	register uchar	*p, *q;

	p = (ws? p = ws->ps : NULL);
	n = (p?  n = ws->ns : 0);
	for (i = 0; (i < n); i++)
	{	if (*p == ';' && p[1] == '\000')
		{	q = catall(ws, i+1);
			nlxm = ws->ns = i; *p = '\000';
			return q;	/* <=== */
		}
		p += strlen(p) + 1;
	}
	return NULL;
}

lexaccept(w)
register WS	*w;
{
	freews(ws);
	ws	= w;
	clxm	= 0;
	nlxm	= (w? w->ns : 0);
}

typedef	struct	SE
{	int		cx;
	int		nx;
	WS		*ws;
	struct	SE	*next;

} SE;

local	SE	*sp	= NULL;

lexpush()
{	register SE	*tp;

	tp = (SE *) gmalloc(sizeof(SE)); if (tp == NULL) return;
	tp->cx	= clxm;
	tp->nx	= nlxm;
	tp->ws	= ws;
	tp->next = sp;
	sp = tp;
	(void) useuplexws();
}

lexpop()
{	register SE	*tp;

	tp	= sp;	if (tp == NULL) return;
	freews(ws);
	clxm	= tp->cx;
	nlxm	= tp->nx;
	ws	= tp->ws;
	sp	= tp->next;
	gfree(tp);
}

/* -eof- */
