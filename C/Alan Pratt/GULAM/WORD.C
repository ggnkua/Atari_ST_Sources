/* word.c of ue/Gulam -- from microEmacs and microGNU-Emacs

The routines in this file implement commands that work word at a time.
Code for dealing with paragraphs and filling.  Adapted from MicroEMACS
3.6.  GNU-ified by mwm@ucbvax.  Several bug fixes by
blarson@usc-oberon.  Gulam-ified by pm@Case.  fillpara() is new by
pm@Case */


#include "gu.h"
#include "ue.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local lowerc P_((uchar *p));
local upperc P_((uchar *p));
local int bgnofword P_((void));
local int casechange P_((int n, int (*f1)(), int (*f2)()));
local WS *makeparastr P_((void));
#undef P_

	local
lowerc(p)
register uchar *	p;
{	register uchar	c;

	c = *p;
	if ('A' <= c && c <= 'Z')
	{	*p -= 'A' - 'a';
		lchange(WFHARD);
}	}

	local
upperc(p)
register uchar *	p;
{	register uchar	c;

	c = *p;
	if ('a' <= c && c <= 'z')
	{	*p -= 'a' - 'A';
		lchange(WFHARD);
}	}

	local int
bgnofword()
{	register int	n;

	for (n = 0; (inword() == FALSE); n++)
	{	if (forwchar(FALSE, 1) == FALSE) {n = -1; break;}
	}
	return n;
}

/* Move the cursor forward by the specified number of words.  As you
move convert the first character of the word by applying f1, and
subsequent characters by f2.  Error if you try and move past the end
of the buffer.  */

	local int
casechange(n, f1, f2)
register int	n;
register int	(*f1)(), (*f2)();
{
        register int    c;

        if (n < 0) return FALSE;
        while (n--)
	{	if (bgnofword() == -1) return FALSE;
                if (inword() != FALSE)
		{	(*f1)(&(curwp->w_dotp->l_text[curwp->w_doto]));
                        if (forwchar(FALSE, 1) == FALSE) return FALSE;
                        while (inword() != FALSE)
			{	(*f2)(&(curwp->w_dotp->l_text[curwp->w_doto]));
                                if (forwchar(FALSE, 1) == FALSE) return FALSE;
        }	}	}
        return TRUE;
}

/* Move the cursor forward by the specified number of words.  As you
move, convert any characters to upper case.  Error if you try and move
beyond the end of the buffer.  Bound to "M-U".  */

upperword(f, n)
{	casechange(n, upperc, upperc);
}

/* Move the cursor forward by the specified number of words.  As you
move convert characters to lower case.  Error if you try and move over
the end of the buffer.  Bound to "M-L".  */

lowerword(f, n)
{	casechange(n, lowerc, lowerc);
}

/* Move the cursor forward by the specified number of words.  As you
move convert the first character of the word to upper case, and
subsequent characters to lower case.  Error if you try and move past
the end of the buffer.  Bound to "M-C".  */

capword(f, n)
{	casechange(n, upperc, lowerc);
}

/* Move the cursor backward by "n" words.  All of the details of
motion are performed by the "backchar" and "forwchar" routines.  Error
if you try to move beyond the buffers.  */

backword(f, n)
register int	n;
{
        if (n < 0) return (forwword(f, -n));
        if (backchar(FALSE, 1) == FALSE) return FALSE;
        while (n--)
	{ while (inword()==FALSE) if (backchar(FALSE, 1)==FALSE) return FALSE;
	  while (inword()!=FALSE) if (backchar(FALSE, 1)==FALSE) return FALSE;
        }
        return (forwchar(FALSE, 1));
}

/* Move the cursor forward by the specified number of words.  All of
the motion is done by "forwchar".  Error if you try and move beyond
the buffer's end.  */

forwword(f, n)
register int	n;
{
        if (n < 0) return (backword(f, -n));
        while (n--)
	{	if (bgnofword() == -1) return FALSE;
                while (inword() != FALSE)
			if (forwchar(FALSE, 1) == FALSE) return FALSE;
        }
        return TRUE;
}


/* Kill forward by "n" words.  Remember the location of dot.  Move
forward by the right number of words.  Put dot back where it was and
issue the kill command for the right number of characters.  Bound to
"M-D".  */

delfword(f, n)
{	register RSIZE	size;
	register LINE	*dotp;
	register int	doto;

	if (n < 0) return FALSE;
	if ((lastflag&CFKILL) == 0)		/* Purge kill buffer.	*/
		kdelete();
	thisflag |= CFKILL;
	dotp = curwp->w_dotp;
	doto = curwp->w_doto;
	size = 0;
	while (n--)
	{	while (inword() == FALSE)
		{	if (forwchar(FALSE, 1) == FALSE)
				goto out;	/* Hit end of buffer.	*/
			++size;
		}
		while (inword() != FALSE)
		{	if (forwchar(FALSE, 1) == FALSE)
				goto out;	/* Hit end of buffer.	*/
			++size;
		}
	}
out:
	curwp->w_dotp = dotp;
	curwp->w_doto = doto;
	return (ldelete(size, KFORW));
}

/* Kill backwards by "n" words.  Move backwards by the desired number
of words, counting the characters.  When dot is finally moved to its
resting place, fire off the kill command.  The rules for success and
failure are now different, to prevent strange behavior at the start of
the buffer.  The command only fails if something goes wrong with the
actual delete of the characters.  It is successful even if no
characters are deleted, or if you say delete 5 words, and there are
only 4 words left.  I (who?) considered making the first call to
"backchar" special, but decided that that would just be wierd.
Normally this is bound to "M-Rubout" and to "M-Backspace".  */

delbword(f, n)
{
	register RSIZE	size;

	if (n < 0) return FALSE;
	if ((lastflag & CFKILL) == 0) kdelete();/* Purge kill buffer.	*/
	thisflag |= CFKILL;
	if (backchar(FALSE, 1) == FALSE) return TRUE;
	size = 1;				/* One deleted.		*/
	while (n--)
	{	while (inword() == FALSE)
		{	if (backchar(FALSE, 1) == FALSE)
				goto out;	/* Hit buffer start.	*/
			++size;
		}
		while (inword() != FALSE)
		{	if (backchar(FALSE, 1) == FALSE)
				goto out;	/* Hit buffer start.	*/
			++size;
		}
	}
	if (forwchar(FALSE, 1) == FALSE) return FALSE;
	--size;					/* Undo assumed delete.	*/
out:
	return (ldelete(size, KBACK));
}

/* Return TRUE if the character at dot is a character that is
considered to be part of a word.  The word character list is hard
coded.  Should be setable.  */

inword()
{
        register int    c, n;
	register LINE	*lp;

	lp = curwp->w_dotp; n = curwp->w_doto;
        if (n == llength(lp)) return FALSE;
        c = lp->l_text[n];
	return
	           (c>='a' && c<='z')
        	|| (c>='A' && c<='Z')
	        || (c>='0' && c<='9')
        	|| (c=='$' || c=='_');		/* For identifiers      */

}

local int	fillcol = 70;

/* Go back to the begining of the current paragraph.  We look for a
<NL><NL> or <NL><TAB> or <NL><SPACE> combination to delimit the
begining of a paragraph.  */

gotobop(f, n)
register int	n;
{
	register LINE	*lp, *lastp;
	register int	suc, c;

	if (n < 0) return gotoeop(f, -n);
	while (n--)
	{	for (;;)  /* first scan back until we are in a word */
		{	suc = backchar(FALSE, 1);
			if (inword() || suc != TRUE) break;
		}
		curwp->w_doto = 0; lastp = curbp->b_linep;
		for (lp = curwp->w_dotp;
			lback(lp) != lastp; lp = lback(lp))
		{	if (0   == llength(lback(lp))
			|| ' '  == (c = lgetc(lp, 0))
			|| '\t' == c)			break;
		}
		curwp->w_dotp = lp;
	}
	curwp->w_flag |= WFMOVE;	/* force screen update */
	return TRUE;
}

/* Go forword to the end of the current paragraph.  We look for a
<NL><NL> or <NL><TAB> or <NL><SPACE> combination to delimit the
begining of a paragraph.  */

gotoeop(f, n)
register int	n;
{
	register LINE	*lp, *lastp;
	register int suc, c;

	if (n < 0) return gotobop(f, -n);
	while (n--)
	{	curwp->w_doto = 0;
		for (;;)  /* Find the first word on/after the current line */
		{	suc = forwchar(FALSE, 1);
			if (inword() || suc != TRUE) break;
		}
		curwp->w_doto = 0;
		lp = curwp->w_dotp;
		lastp = curbp->b_linep;
		if (lp == lastp) break;
		for (;;)
		{	lp = lforw(lp);  if (lp == lastp) break;
			if (0   == llength(lp)
			|| ' '  == (c = lgetc(lp, 0))
			|| '\t' == c)	{lp = lback(lp); break;}
		}
		curwp->w_dotp = lp;
	}
	curwp->w_flag |= WFMOVE;	/* force screen update */
	return TRUE;
}

local	uchar	*blanks[3] = {"", " ", "  "}; /* 0, 1, 2 blanks */

/* Make a string out of the lines belonging to the current para.
Delete these lines.  curwp->dotp pts to the line below the para.  */

	local WS *
makeparastr()
{	register LINE	*lp, *eopg;
	register WS	*ws;
	register int	n;

	gotoeop(TRUE, 1);  eopg = curwp->w_dotp;
	gotobop(TRUE, 1);
	if (ws = initws())
	{  for (n = 1, lp = curwp->w_dotp; lp != eopg; n++) lp = lforw(lp);
	   while (n--)
	   {	strwcat(ws, makelnstr(curwp->w_dotp), 0); strwcat(ws, " ", 0);
		kill(TRUE, 1);	/* kill changes the curwp->w_dotp */
		lastflag = thisflag;
	}  }
	return ws;
}

/* Fill the current paragraph according to the current fill column */

fillpara()
{
	register WS	*ln, *ws;
	register uchar	*p, *s;
	register int	nln, i, n;

	if ((ws = makeparastr()) == NULL) return FALSE;
	if ((ln = initws())  == NULL) {freews(ws); return FALSE;}

	for (nln = i = 0; WHITEDELIMS[n = ws->ps[i]]; i++)
		{if (n == '\t') nln |= 007; nln ++;}
	ws->ps[i] = '\000'; strwcat(ln, ws->ps, 0); ws->ps[i] = n;
	/* added the para delimiter as is */

	lex(&(ws->ps[i]), WHITEDELIMS, EMPTY2); freews(ws);
	for (i = 0;;)	/* i == #blanks between words	*/
	{	n = strlen(p = lexgetword());
		nln += i + n;
		if (nln > fillcol || n == 0)
		{	lnlink(curwp->w_dotp, ln->ps, ln->nc);
			if (n == 0) break;
			ln->nc = i = 0;
			nln = n;
		}
		strwcat(ln, blanks[i], 0);
		strwcat(ln, p, 0);
		n = p[n-1];
		i = (n == '.' || n == '!' || n == '?' ? 2 : 1);
	}
	freews(useuplexws());  freews(ln);
	return TRUE;
}

setfillcol(f, n)
{
	extern int	getccol() ;

	fillcol = (f? n : getccol(0));
	mlwrite("Fill column set to %d", fillcol);
        return TRUE;
}

/* -eof- */
