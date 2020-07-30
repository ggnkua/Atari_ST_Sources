/*
 * The functions in this file
 * implement commands that search in the
 * forward and backward directions. There are
 * no special characters in the search strings.
 * Probably should have a regular expression
 * search, or something like that.
 */
#include	<stdio.h>
#include	"ed.h"

/* mb: added: */
#define  eq(c,d,s) ((d)==ANYCHAR || (s ? ((c)==(d)) : (FOLD(c)==(d))))
#define  FOLD(c)   (((c)>='a' && (c)<='z') ? ((c)-0x20) : (c))

/* mb: completely rewritten.
 * Search forward.
 * Get a search string from the
 * user, and search, beginning at ".",
 * for the string. If found, reset the
 * "." to be just after the match string,
 * and [perhaps] repaint the display.
 * Bound to "M-S".
 */
forwsearch(f, n)
{
	register LINE *clp;
	register int  *pp;
	register int  cbo;
	register int  c, d, s;
	register int  found;
	LINE *tlp;
	int  tbo, negmode, tmp;
	int  tpat[NPAT+1];

	if (readpattern("Forward search") == ABORT)
		return(ABORT);
	s = casesens;
	/* mb: do the following here to save time: FOLD the pat only once.
	       Also use an int[] rather than a char[] since each
	       char will be promoted to an int later anyway, and
	       we also want to do "&0xFF" only once.		*/
	for (c=0; pat[c]!='\0'; c++)
		tpat[c] = ((int) (s? pat[c] : FOLD(pat[c]))) & 0xFF;
	tpat[c] = tpat[c+1] = '\0';
	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	pp = tpat;
	found = FALSE;
	negmode = FALSE;
	for(;;) {
		if (cbo >= llength(clp)) {
			clp = lforw(clp);
			if (clp == curbp->b_linep) {
				found = FALSE;
				break;
			}
			cbo = 0;
			c = '\n';
		} else {
			c = lgetc(clp, cbo++);
		}
		d = (*pp);
		if (d == NEGCHAR) {
			negmode = TRUE;
			++pp;
		}
		if (d == WHITESPACE) {
			if (negmode) {
				if (c!=' ' && c!='\t' && c!='\n')
					continue;
			} else {
				if (c==' ' || c=='\t' || c=='\n')
					continue;
			}
			negmode = FALSE;
			++pp;
			if (*pp == '\0') {
				found = TRUE;
				if (cbo)
					--cbo;
				break;
			}
		}
		d = (*pp);
		if ((!negmode && !eq(c,d,s)) || (negmode && eq(c,d,s))) {
			if (found) {
				found = FALSE;
				clp = tlp;
				cbo = tbo;
			}
			pp = tpat;
			negmode = FALSE;
			continue;
		}
		if (! found) {
			found = TRUE;
			tlp = clp;
			tbo = cbo;
		}
		if (*(++pp) == '\0')
			break;
		negmode = FALSE;
	}					/* end of for(;;) */
	if (found) {
		curwp->w_dotp = clp;
		curwp->w_doto = cbo;
		curwp->w_flag |= WFMOVE;
		mlerase();
	} else {
		mlwrite("Not found");
	}
	return (found);
}

/* mb: completely rewritten.
 * Reverse search.
 * Get a search string from the
 * user, and search, starting at "."
 * and proceeding toward the front of
 * the buffer. If found "." is left
 * pointing at the first character of
 * the pattern [the last character that
 * was matched]. Bound to "M-R".
 */
backsearch(f, n)
{
	register LINE *clp;
	register int  *pp;
	register int  cbo;
	register char c, d, s;
	register int  found;
	LINE *tlp;
	int  tbo, negmode;
	int  *epp, *tpatp;
	int  tpat[NPAT+1];

	if ((s=readpattern("Reverse search")) == ABORT)
		return(ABORT);
	s = casesens;
	for (c=0; pat[c]!='\0'; c++)
		tpat[c+1] = (s? pat[c] : FOLD(pat[c])) & 0xFF;
	tpat[0] = tpat[c+1] = '\0';
	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	tpatp = tpat+1;
	epp = tpat;
	while (epp[1] != '\0')
		++epp;
	pp = epp;
	found = FALSE;
	negmode = FALSE;
	for(;;) {
		if (--cbo < 0) {
			clp = lback(clp);
			if (clp == curbp->b_linep) {
				found = FALSE;
				break;
			}
			cbo = llength(clp);
			c = '\n';
		} else {
			c = lgetc(clp, cbo);
		}
		if (pp[-1] == NEGCHAR)
			negmode = TRUE;
		if (*pp == WHITESPACE) {
			if (negmode) {
				if (c!=' ' && c!='\t' && c!='\n')
					continue;
			} else {
				if (c==' ' || c=='\t' || c=='\n')
					continue;
			}
			if (negmode) {
				--pp;
				negmode = FALSE;
			}
			if (--pp < tpatp) {
				found = TRUE;
				if (c != '\n')
					++cbo;
				break;
			}
		}
		if ((!negmode && !eq(c,*pp,s)) || (negmode && eq(c,*pp,s))) {
			if (found) {
				found = FALSE;
				clp = tlp;
				cbo = tbo;
			}
			pp = epp;
			negmode = FALSE;
			continue;
		}
		if (! found) {
			found = TRUE;
			tlp = clp;
			tbo = cbo;
		}
		if (negmode) {
			--pp;
			negmode = FALSE;
		}
		if (--pp < tpatp)
			break;
	}					/* end of for(;;) */
	if (found) {
		curwp->w_dotp = clp;
		curwp->w_doto = cbo;
		curwp->w_flag |= WFMOVE;
		mlerase();
	} else {
		mlwrite("Not found");
	}
	return (found);
}

/* mb: eq() unnecessary now, deleted */

/*
 * Read a pattern.
 * Stash it in the external
 * variable "pat". The "pat" is
 * not updated if the user types in
 * an empty line. If the user typed
 * an empty line, and there is no
 * old pattern, it is an error.
 * mb: much simpler now that mlreply() does all the work.
 * mb: remember old patterns.
 */
readpattern(prompt)
char	*prompt;
{
	register int	c, i, s;
	register char	*dflt1, *dflt2;
	static	 int	oldpati = (-1);
	static	 int	maxpati = (-1);
	static	 char	pat0[NPAT], pat1[NPAT], pat2[NPAT], pat3[NPAT];
	static	 char	*oldpat[4] = {pat0, pat1, pat2, pat3};
	char		dbuf[NPAT], buf[NPAT];

	if (pat[0] != '\0') {			/* Old pattern		*/
		dflt1 = pat;
		goto start;
	}
altpat:
	if (oldpati >= 0)
		dflt1 = oldpat[oldpati];
	else
		dflt1 = NULL;
start:
	if (dflt1 != NULL) {
		i = 0;
		do {
			c = dflt1[i];
			if (casesens)
				dbuf[i] = c;
			else
				dbuf[i] = FOLD(c);  /* hint: case blind */
			++i;
		} while (c);
		dflt2 = dbuf;
	} else
		dflt2 = NULL;
	s = mlreply(prompt, dflt2, buf, NPAT, TRUE);
	if (s == UP) {
		if (oldpati > 0)
			--oldpati;
		else if (oldpati==0 && maxpati>0)
			oldpati = maxpati;
		goto altpat;
	}
	if (s == DOWN) {
		if (oldpati < maxpati)
			++oldpati;
		else if (oldpati > 0)
			oldpati = 0;
		goto altpat;
	}
	if (s!=TRUE && s!=FALSE)
		return (ctrlg());
	if (buf[0] != '\0') {			/* specified		*/
		strcpy (pat, buf);
		if (s == TRUE) {
			++oldpati;
			if (oldpati > 3)
				oldpati = 0;
			if (oldpati > maxpati)
				maxpati = oldpati;
			strcpy (oldpat[oldpati], buf);
		}
	}
	else if (dflt2 == NULL)
		return (ctrlg());
	return (s);
}

#if CMODE

/*
 * mb: Search forward for complementing brace, fancy CMODE version.
 * If not on an opening brace, search forwards for one,
 * then for corresponding closing brace.
 * Braces are {}, () and [].  Braces inside quotes
 * (single or double) or comments are ignored.
 * Also knows about backslashes.
 * Bound to "M-]", "M-)" and "M-}".
 */
forw_brace(f, n)
{
	register char	ch;
	register char	oldch;
	register int	doto;
	register LINE	*dotp;
	register int	quoted;
	register int	comment;
	int	depth, status;
	char	older, quote;
	char	stack[128];

	status = TRUE;
	quoted = FALSE;
	comment = FALSE;
	depth = 0;
	dotp = curwp->w_dotp;
	doto = curwp->w_doto;
	ch = '\n';
	while (depth < 127) {
		if ( doto >= llength(dotp) ) {
			dotp = lforw(dotp);
			if (dotp == curbp->b_linep) {
				status = ABORT;
				break;
			}
			doto = 0;
			continue;
		}
		older = oldch;
		oldch = ch;	
		ch = lgetc(dotp, doto++);
		if (quoted) {
			if (ch == quote)
				if ( oldch!='\\'
				||  (oldch=='\\' && older=='\\'))
					quoted = FALSE;
			continue;
		}
		if (comment) {
			if (ch == '/' && oldch == '*')
				comment = FALSE;
			continue;
		}
		if ((ch=='"' || ch=='\'') && oldch != '\\') {
			quoted = TRUE;
			quote = ch;
			continue;
		}
		if (ch == '*' && oldch == '/') {
			comment = TRUE;
			continue;
		}
		if (ch == '{')
			stack[depth++] = '}';
		else if (ch == '(')
			stack[depth++] = ')';
		else if (ch == '[')
			stack[depth++] = ']';
		else if ((ch=='}' || ch==')' || ch==']') && depth>0 ) {
			if (stack[--depth] != ch) {
				status = FALSE;
				break;
			}
			if (depth == 0)
				break;    /* found it! */
		}
	} 				/* end of while() */
	if (status == TRUE) {
		curwp->w_dotp  = dotp;
		curwp->w_doto  = doto - 1;
		curwp->w_flag |= WFMOVE;
		return (TRUE);
	}
	if (status == FALSE || depth > 0)
		mlwrite("Braces not balanced!");
	return (status);
}

/*
 * mb: Search backwards for complementing brace, fancy CMODE version.
 * If not on a closing brace, search backwards for one,
 * then for corresponding opening brace.
 * Bound to "M-[", "M-(" and "M-{".
 */
back_brace(f, n)
{
	register char	ch;
	register char	oldch;
	register int	doto;
	register LINE	*dotp;
	register int	quoted;
	register int	comment;
	int	depth, status;
	char	older, quote;
	char	stack[128];

	status = TRUE;
	quoted = FALSE;
	comment = FALSE;
	depth = 0;
	dotp = curwp->w_dotp;
	doto = curwp->w_doto + 1;	/* read THIS char, but: */
	if (doto > llength(dotp))	/* if at far eol...	*/
		--doto;			/* don't read garbage	*/
	ch = '\n';
	while (depth < 127) {
		if ( doto <= 0 ) {
			dotp = lback(dotp);
			if (dotp == curbp->b_linep) {
				status = ABORT;
				break;
			}
			doto = llength(dotp);
			continue;
		}
		older = oldch;
		oldch = ch;	
		ch = lgetc(dotp, --doto);
		if (quoted) {
			if (ch != '\\' && oldch == quote) {
				oldch = '\n';
				quoted = FALSE;
			} else
				continue;
		}
		if (comment) {
			if (ch == '/' && oldch == '*')
				comment = FALSE;
			continue;
		}
		if ((oldch=='"' || oldch=='\'') && ch!='\\') {
			quoted = TRUE;
			quote = oldch;
			continue;
		} 			
		if ((older=='"' || older=='\'')
		    && ch=='\\' && oldch=='\\') {
			quoted = TRUE;
			quote = older;
			continue;
 		}
		if (ch == '*' && oldch == '/') {
			comment = TRUE;
			continue;
		}
		if (ch == '}')
			stack[depth++] = '{';
		else if (ch == ')')
			stack[depth++] = '(';
		else if (ch == ']')
			stack[depth++] = '[';
		else if ((ch=='{' || ch=='(' || ch=='[') && depth>0 ) {
			if (stack[--depth] != ch) {
				status = FALSE;
				break;
			}
			if (depth == 0)
				break;    /* found it! */
		}
	} 				/* end of while() */
	if (status == TRUE) {
		curwp->w_dotp  = dotp;
		curwp->w_doto  = doto;
		curwp->w_flag |= WFMOVE;
		return (TRUE);
	}
	if (status == FALSE || depth > 0)
		mlwrite("Braces not balanced!");
	return (status);
}

#else

/*
 * mb: Search forward for complementing brace, plain version.
 * If not on an opening brace, search forwards for one,
 * then for corresponding closing brace.
 * Braces are {}, () and [].
 * Doesn't know about quotes and comments.
 * Bound to "M-]", "M-)" and "M-}".
 */
forw_brace(f, n)
{
	register char	ch;
	register int	doto;
	register LINE	*dotp;
	int	depth, status;
	char	stack[128];

	status = TRUE;
	depth = 0;
	dotp = curwp->w_dotp;
	doto = curwp->w_doto;
	ch = '\n';
	while (depth < 127) {
		if ( doto >= llength(dotp) ) {
			dotp = lforw(dotp);
			if (dotp == curbp->b_linep) {
				status = ABORT;
				break;
			}
			doto = 0;
			continue;
		}
		ch = lgetc(dotp, doto++);
		if (ch == '{')
			stack[depth++] = '}';
		else if (ch == '(')
			stack[depth++] = ')';
		else if (ch == '[')
			stack[depth++] = ']';
		else if ((ch=='}' || ch==')' || ch==']') && depth>0 ) {
			if (stack[--depth] != ch) {
				status = FALSE;
				break;
			}
			if (depth == 0)
				break;    /* found it! */
		}
	} 				/* end of while() */
	if (status == TRUE) {
		curwp->w_dotp  = dotp;
		curwp->w_doto  = doto - 1;
		curwp->w_flag |= WFMOVE;
		return (TRUE);
	}
	if (status == FALSE || depth > 0)
		mlwrite("Braces not balanced!");
	return (status);
}

/*
 * mb: Search backwards for complementing brace, plain version.
 * If not on a closing brace, search backwards
 * for one, then for corresponding opening brace.
 * Bound to "M-[", "M-(" and "M-{".
 */
back_brace(f, n)
{
	register char	ch;
	register int	doto;
	register LINE	*dotp;
	int	depth, status;
	char	stack[128];

	status = TRUE;
	depth = 0;
	dotp = curwp->w_dotp;
	doto = curwp->w_doto + 1;	/* read THIS char, but: */
	if (doto > llength(dotp))	/* if at far eol...	*/
		--doto;			/* don't read garbage	*/
	ch = '\n';
	while (depth < 127) {
		if ( doto <= 0 ) {
			dotp = lback(dotp);
			if (dotp == curbp->b_linep) {
				status = ABORT;
				break;
			}
			doto = llength(dotp);
			continue;
		}
		ch = lgetc(dotp, --doto);
		if (ch == '}')
			stack[depth++] = '{';
		else if (ch == ')')
			stack[depth++] = '(';
		else if (ch == ']')
			stack[depth++] = '[';
		else if ((ch=='{' || ch=='(' || ch=='[') && depth>0 ) {
			if (stack[--depth] != ch) {
				status = FALSE;
				break;
			}
			if (depth == 0)
				break;    /* found it! */
		}
	} 				/* end of while() */
	if (status == TRUE) {
		curwp->w_dotp  = dotp;
		curwp->w_doto  = doto;
		curwp->w_flag |= WFMOVE;
		return (TRUE);
	}
	if (status == FALSE || depth > 0)
		mlwrite("Braces not balanced!");
	return (status);
}

#endif
