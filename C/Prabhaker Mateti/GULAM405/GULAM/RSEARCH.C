/*
Search commands of uE.

pm: It now uses only regular expression search, and search/replace.
*/

#include	"ue.h"
#include	"regexp.h"

uchar    pat[NPAT]; 			/* Pattern                      */

local	regexp	*repat	= NULL;		/* compiled reg exp of pat[] */

	local
failed()
{	mlwrite("Search failed: \"%s\"", pat);
}

casesensitize(tpat)
uchar	*tpat;
{	register uchar	*p, *q, *r, c;

	if (varnum("case_insensitive"))
	{	/* replace each lower letter x by [xX]	*/
		r = malloc(4*strlen(tpat)+1);
		if (r)
		{	for (p = r, q = tpat; c = *q++;)
			{  if ('a' <= c && c <= 'z')
			   {*p++ = '['; *p++ = c; *p++ = c-'a'+'A';*p++ = ']';}
			   else *p++ = c;
			}
			*p = '\000';
			if (strlen(r) < 2*NPAT) strcpy(tpat, r);
			free(r);
}	}	}


/* pm: Read a pattern.  Stash it in the external variable "pat".  The
"pat" is not updated if the user types in an empty line.  If the user
typed an empty line, and there is no old pattern, it is an error.  To
escape metachars, you precede them by ^Q; the escape char in regex(3)
is '\\' */

	local
readpattern(prompt)
register uchar *prompt;
{	register int	s;
	register uchar	*p, *q, c;
	uchar		tpat[2*NPAT];

	tpat[0] = '\000';
	if (pat[0] == '\0') s = mlreply(sprintp("%s: ", prompt), tpat, NPAT);
	else  s = mlreply(sprintp("%s: (default %s) ",prompt,pat),tpat, NPAT);
	if (s == '\007') return ABORT;
	if (tpat[0])
	{	(void) strcpy(pat, tpat);
		for (q = pat, p = tpat; c = *q++; *p++ = c)
			if (c == '\\') *p++ = CTRLQ;
		*p = '\000';
		(void) strcpy(pat, tpat);
	}
	gfree(repat); repat = NULL;
	if (pat[0])
	{	for (q = pat, p = tpat; c = *q++; *p++ = c)
			if (c == CTRLQ) c = '\\';
		*p = '\000';
		casesensitize(tpat);
		repat = regcomp(tpat);
	}
	return (repat != NULL);
}

/* Replace plen characters before dot with argument string st.
Control-J characters in st are interpreted as newlines.  There is a
casehack enable flag (normally it likes to match case of replacement
to what was there).  */

	local
lreplace(plen, st) 			/* by Rich Ellison.		*/
register int	plen;			/* length to remove		*/
register uchar	*st;			/* replacement string		*/
{
	register int	dflen;		/* replacement/src length diff	*/
	register uint	c;		/* used for random characters	*/
	register int	doto;		/* offset into line		*/

	backchar(TRUE, plen, KRANDOM);

	/*
	 * make the string lengths match (either pad the line
	 * so that it will fit, or scrunch out the excess).
	 * be careful with dot's offset.
	 */
	if (dflen = plen - strlen(st))
	{	doto = curwp->w_doto;
		if (dflen > 0) ldelete(dflen, KNONE);
		else if (linsert(-dflen, ' ') == FALSE) return FALSE;
		curwp->w_doto = doto;
	}

	/* do the replacement */
	while (c = *st++)
	{	if (c == '\n')
		{	if (curwp->w_doto == llength(curwp->w_dotp))
				forwchar(FALSE, 1, KRANDOM);
			else
			{	if (ldelete(1, KNONE) != FALSE)
					lnewline();
			}
		} else
		if (curwp->w_dotp == curbp->b_linep)
		{	linsert((RSIZE) 1, c);
		} else
		if (curwp->w_doto == llength(curwp->w_dotp))
		{	if (ldelete(1, KNONE) != FALSE)
				linsert(1, c);
		} else	lputc(curwp->w_dotp, curwp->w_doto++, c);
	}
	lchange(WFHARD);
	return TRUE;
}

/* Perform substitutions after a regexp match.  Written by Henry
Spencer.  Copyright (c) 1986 by University of Toronto.  Not derived
from licensed software.  modified by pm@Case: return a ptr to the new
string; must be *g*free()'d */

	local char *
regsubst(prog, source)
regexp *prog;
char *source;
{
#ifndef CHARBITS
#define	UCHARAT(p)	((int)*(unsigned char *)(p))
#else
#define	UCHARAT(p)	((int)*(p)&CHARBITS)
#endif

	register char	*src, *p;
	register char	c;
	register int	no;
	register WS	*ws;		/* type really is WS * */
	extern	 WS	*initws();
	char		ord[2];

	if (prog == NULL || source == NULL
	|| (UCHARAT(prog->program) != MAGIC))	 return;

	src = source; ws = initws(); ord[1] = '\000';
	while ((c = *src++) != '\0')
	{	if (c == '&') no = 0; else
		if (c == '\\' && '0' <= *src && *src <= '9') no = *src++ - '0';
		else no = -1;
		if (no < 0) {ord[0] = c; strwcat(ws, ord, 0);}
		else if (prog->startp[no] != NULL && prog->endp[no] != NULL)
		{	p = prog->endp[no];
			c = *p; *p = '\000';
			strwcat(ws, prog->startp[no], 0);
			*p = c;
	}	}
	p = ws->ps; gfree(ws);
	return p;
}

/* This routine does the real work of a forward search.  The pattern
is sitting in the external variable "pat".  If found, dot is updated,
the window system is notified of the change, and TRUE is returned.  */

fsearch()
{	register LINE	*clp;
	register int	cbo;
	register char	*s;

	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	while (clp != curbp->b_linep)
	{	s = makelnstr(clp);
		if (regexec(repat, s+cbo)==1) goto found;
		clp = lforw(clp);
		cbo = 0;
	}
	return FALSE;

	found:
	curwp->w_dotp  = clp;
	curwp->w_doto  = repat->endp[0] - s;
	curwp->w_flag |= WFMOVE;
	return TRUE;
}

/* This routine does the real work of a backward search.  The pattern
is sitting in the external variable "pat".  If found, dot is updated,
the window system is notified of the change, and TRUE is returned.  If
the string isn't found, FALSE is returned.  */

bsearch()
{	register LINE	*clp;
	register int	cbo;
	register int	i;
	register char	*s, c;

	clp = curwp->w_dotp;	if (clp == curbp->b_linep) clp = lback(clp);
	cbo = curwp->w_doto;
	while (clp != curbp->b_linep)
	{	s = makelnstr(clp); if (cbo >= 0) {c = s[cbo]; s[cbo] = '\000';}
		i = regexec(repat, s);
		if (i == 1) goto found;
		if (cbo >= 0) {s[cbo] = c; cbo = -1;}
		clp = lback(clp);
	}
	return (FALSE);

	found:
	for (i = strlen(s); i; i--)
		if (regexec(repat, s+i)==1) break;
	if (cbo >= 0) s[cbo] = c;
	curwp->w_dotp  = clp;
	curwp->w_doto  = i;
	curwp->w_flag |= WFMOVE;
	return TRUE;
}

/* Search forward.  Get a search string from the user, and search for
it, starting at ".".  If found, "." gets moved to just after the
matched characters, and display does all the hard stuff.  If not
found, it just prints a message.  */

forwsearch()
{	register int	s;

	s = readpattern("re Search Forward");
	if ((s == ABORT) || (s == FALSE))  return (s);
	s = (s == 0x12? bsearch() : fsearch());
	if (s == FALSE) failed();
	return s;
}

/* Reverse search.  Get a search string from the user, and search,
starting at "." and proceeding toward the front of the buffer.  If
found "." is left pointing at the first character of the pattern [the
last character that was matched].  */

backsearch()
{	register int	s;

	s = readpattern("re Search Backward");
	if ((s == ABORT) || (s == FALSE))  return (s);
	s = (s == 0x13? fsearch() : bsearch());
	if (s == FALSE) failed();
	return s;
}

/* Query Replace.  Replace strings selectively.  Does a search
and replace operation.
*/

queryrepl()
{
	register int	s, c, all;
	register int	rcnt;		/* Replacements made so far	*/
	register int	plen;		/* length of found string	*/
	char		news[NPAT];	/* replacement string		*/
	register char	*p;

	news[0] = '\000';
	if ((s=readpattern("re Query replace")) != TRUE)	return (s);
	s = mlreply(sprintp("re Query replace %s with: ", pat),news, NPAT);
	if (s == CCHR('G')) return ABORT;
	mlwrite("re Query replacing %s with %s:", pat, news);
	rcnt = all = 0;
	while (fsearch() == TRUE)
	{ loopbgn:
		if (all) 
		{	c = usertyped(); if (c == -1) c = ' ';
			if ((rcnt & 0x003f) == 0) update();
		} else	{update(); c = inkey();}
		switch (c) {
		case 0x7F:	break;
		case '!':	all = 1;	/* fall through */
		case ' ':
		case '.':
			p = regsubst(repat, news);
			plen = repat->endp[0] - repat->startp[0];
			s = lreplace(plen, p); gfree(p);
			if (s == FALSE) goto stopsearch;
			rcnt++;
			if (c != '.') break;
			/* else fall through to stopsearch */

		case '\007':
		case '\003':
		case '\033':	goto stopsearch;
		default:
mlwrite("<SP> replace, [.] rep-end, <DEL> don't, [!] repl rest <ESC> quit");
			goto loopbgn;
		}
	}
stopsearch:
	curwp->w_flag |= WFHARD;
	update();
	mlwrite("(%d replacements done)", rcnt);
	return TRUE;
}

/* -eof- */
