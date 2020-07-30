/*
 * The routines in this file
 * implement commands that work word at
 * a time. Sentence and/or paragraph
 * mode commands are also in this file.
 */
#include	<stdio.h>
#include	"ed.h"

extern LINE	*lalloc();
extern int 	lchange();
extern int 	linsert();
extern int 	kdelete();
extern char	*malloc();
extern char	*kbufp;
extern int	kused;
extern int	ksize;

/*
 * Word wrap.  mb: rewritten.
 */
wrapword(c)
	int c;
{
	register int  doto;
	register int  count;
	register int  temp;

	doto = curwp->w_doto;
	count = 0;
	if (c != ' ') do {
		if (backchar(FALSE, 1) == FALSE)  return;
		++count;
	} while (--doto>0 && inword(TRUE));
	while (doto>0 && !inword(TRUE)) {
		if (backchar(FALSE, 1) == FALSE)  return;
		--doto;
		++count;
	}
	if (forwchar(FALSE, 1) == FALSE)  return;
	if (++doto > 0) {
		temp = count;
		while (--temp>0 && lgetc(curwp->w_dotp,doto)==' ') {
			if (forwdel(FALSE, 1) != TRUE)  return;
			--count;
		}
		if (newline(FALSE, 1) != TRUE)  return;
		if (do_margin() != TRUE)  return;
	}
	while (--count > 0)
		if (forwchar(FALSE, 1) == FALSE)  return;
	return;
}

#if EXTRA
/*
 * mb: added.
 */
forwparag(f, n)
{
	register LINE	*dlp;

	dlp = curwp->w_dotp;
	while (dlp!=curbp->b_linep && istext(dlp))
		dlp = lforw(dlp);
	while (dlp!=curbp->b_linep && (! istext(dlp)))
		dlp = lforw(dlp);
	curwp->w_dotp  = dlp;
	curwp->w_doto  = 0;
	curwp->w_flag |= WFMOVE;
	return (TRUE);
}

backparag(f, n)
{
	register LINE	*tlp;
	register LINE	*dlp;

	tlp = lback(curwp->w_dotp);
	dlp = tlp;
	while (tlp!=curbp->b_linep && (! istext(tlp))) {
		dlp = tlp;
		tlp = lback(tlp);
	}
	while (tlp!=curbp->b_linep && istext(tlp)) {
		dlp = tlp;
		tlp = lback(tlp);
	}
	curwp->w_dotp  = dlp;
	curwp->w_doto  = 0;
	curwp->w_flag |= WFMOVE;
	return (TRUE);
}
#endif

/* mb: added. A subsidary of reformat(). If size==0
 * open a line long enough to fit current margins
 * and enter left margin. If size>0 simply lalloc()
 * that size. In any case link new line into the text.
 */
LINE *falloc(lp, size)
	LINE *lp;
	int  size;
{
	register LINE *nlp;
	register char *cp;
	register int  i;
	int  nt, ns;

	if (size == 0) {
		nt = lmargin / tabsize;
		ns = lmargin % tabsize;
		nlp = lalloc(fillcol - lmargin + nt + ns);
	} else
		nlp = lalloc(size);
	if (nlp == NULL)
		return (NULL);
	if (size == 0) {
		cp = nlp->l_text;
		for (i=0; i<nt; ++i)  *(cp++) = '\t';
		for (i=0; i<ns; ++i)  *(cp++) = ' ';
		nlp->l_used = nt + ns;
	} else
		nlp->l_used = 0;
	lforw(nlp) = lforw(lp);
	lback(nlp) = lp;
	lforw(lp) = nlp;
	lback(lforw(nlp)) = nlp;
	return (nlp);
}

/* mb: added. Count chars to be reformatted,
 * create new kill buffer, and copy paragraph
 * into it. Called by reformat().
 */
int ppkill(blp,elp)
	LINE *blp;
	LINE *elp;
{	register LINE *clp;
	register char *ccp;
	register int   i;

	for (i=1, clp=blp; clp!=elp; clp=lforw(clp))
		i += llength(clp) + 1;
	kdelete();
	if ((kbufp = malloc(i)) == NULL) {
		mlwrite("not enough memory");
		return (FALSE);
	}
	kused = i;
	ksize = i;
	ccp = kbufp;
	*ccp++ = '\n';
	for (clp=blp; clp!=elp; clp=lforw(clp)) {
		for (i=0; i<llength(clp); ++i)
			*ccp++ = clp->l_text[i];
		*ccp++ = '\n';
	}
	return (TRUE);
}

/* mb: added. Backward till right after empty line, then:
 * Redo line-splits to fit current margins. (Don't touch
 * left margin of first line, though.)  Keep going till
 * first empty line.  Double space if argument.
 * Paragraph is saved in kill buffer before it's
 * reformatted.  Bound to C-X F.
 */
int
reformat(f,n)
{
	register char ch;
	register char *tcp;
	register char *scp;
	register char oldch;
	register char older;
	register int  skip;
	LINE *blp, *elp, *slp, *tlp;
	int  lm;
	char *eol, *limit, *wcp;

	if ((fillcol - lmargin) < tabsize) {
		mlwrite("Margins not set");
		return (FALSE);
	}

/* find extent of paragraph */

	blp = curwp->w_dotp;
	elp = blp;
	while (blp != curbp->b_linep && istext(blp)) {
		elp = blp;
		blp = lback(blp);
	}
	blp = elp;
	while (elp != curbp->b_linep && istext(elp))
		elp = lforw(elp);
	if (blp == elp)			/* nothing to reformat */
		return (FALSE);
	if (ppkill(blp,elp) != TRUE)	/* first save in kill buf */
		return (FALSE);

/* set up pointers for first line */

	slp = blp;
	scp = slp->l_text;
	eol = scp + llength(slp);
	tlp = falloc(lback(blp), fillcol);
	if (tlp == NULL) {
		kdelete();
		return (FALSE);
	}
	lm = 0;
	tcp = tlp->l_text;
	wcp = tcp;
	limit = tcp + fillcol + 1;
	skip = FALSE;
	oldch = ' ';
	ch = ' ';

/* copy into new lines, reformatting */

	for(;;) {
		older = oldch;
		oldch = ch;
		if (scp >= eol) {
			slp = lforw(slp);
			lfree(lback(slp));
			if (slp == elp)  /* end of paragraph */
				break;
			scp = slp->l_text;
			eol = scp + llength(slp);
			skip = TRUE;
			ch = ' ';
		} else {
			if (oldch != ' '
			 || (older!='.' && older!='?' && older!='!'))
				ch = *scp++;
		}
		if (ch == '\t') {
			if (skip)
				ch = ' ';
			else {
				limit -= (tabsize - 1);
				++lm;
			}
		}
		if (ch == ' ') {
			if (skip && oldch==' '
			 && (older!='.' && older!='?' && older!='!'))
				continue;
			if (tcp > tlp->l_text && tcp[-1]!=' ')
				wcp = tcp;
		}
		if (ch != ' ' && ch != '\t')
			skip = TRUE;
		*tcp++ = ch;
		if (tcp >= limit) {
			if (wcp > (tlp->l_text + lm)) {
				scp -= (tcp - wcp - 1);
				if (scp < slp->l_text)
					scp = slp->l_text;
				tlp->l_used = wcp - tlp->l_text;
			} else
				tlp->l_used = tcp - tlp->l_text;
			if (f) {
				tlp = falloc(tlp, 1);
				if (tlp == NULL)  break;
				tlp->l_text[0] = '\t';
				tlp->l_used = 1;
			}
			tlp = falloc(tlp, 0);
			if (tlp == NULL)  break;
			lm = llength(tlp);
			tcp = tlp->l_text + lm;
			wcp = tcp;
			limit = tcp + (fillcol + 1 - lmargin);
			ch = ' ';
			oldch = ' ';
			skip = TRUE;
		}
	}

/* exit, after setting appropriate flags */

	tlp->l_used = tcp - tlp->l_text;
	if (llength(tlp) == lm)
		tlp->l_used = 0;
        lchange(WFEDIT);
	curwp->w_dotp = elp;
	curwp->w_doto = 0;
	curwp->w_force = 0;
	curwp->w_flag |= WFMOVE|WFHARD|WFFORCE;
	return (TRUE);
}

/*
 * Move the cursor backward by
 * "n" words. All of the details of motion
 * are performed by the "backchar" and "forwchar"
 * routines. Error if you try to move beyond
 * the buffers.
 */
backword(f, n)
{
	if (n < 0)
		return (forwword(f, -n));
	if (backchar(FALSE, 1) == FALSE)
		return (FALSE);
	while (n--) {
		while (inword(FALSE) == FALSE) {
			if (backchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
		while (inword(FALSE) != FALSE) {
			if (backchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
	}
	return (forwchar(FALSE, 1));
}

/*
 * Move the cursor forward by
 * the specified number of words. All of the
 * motion is done by "forwchar". Error if you
 * try and move beyond the buffer's end.
*/
forwword(f, n)
{
	if (n < 0)
		return (backword(f, -n));
	while (n--) {
		while (inword(FALSE) == FALSE) {
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
		while (inword(FALSE) != FALSE) {
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
	}
	return (TRUE);
}

#if EXTRA
/*
 * Move the cursor forward by
 * the specified number of words. As you move,
 * convert any characters to upper case. Error
 * if you try and move beyond the end of the
 * buffer. Bound to "M-U". mb: cut off from the meat.
 */
upperword(f, n)
{
	return( caseword(f, n, TRUE, FALSE) );
}

/*
 * mb: drastically simplified
 */
lowerword(f, n)
{
	return( caseword(f, n, FALSE, FALSE) );
}

/*
 * Move the cursor forward by
 * the specified number of words. As you move
 * convert the first character of the word to upper
 * case, and subsequent characters to lower case. Error
 * if you try and move past the end of the buffer.
 * Bound to "M-C".  mb: drastically simplified.
 */
capword(f, n)
{
	return( caseword(f, n, FALSE, TRUE) );
}

/*
 * mb: the common part of upperword() & lowerword():
 */
caseword(f, n, touc, cap)
	register int	touc;
	register int	cap;
{
	register int	c;
	register int	new;

	if (n < 0)
		return (FALSE);
	while (n--) {
		while (inword(FALSE))
			if (backchar(0, 1) != TRUE)
				break;
		while (! inword(FALSE)) {
			if (forwchar(0, 1) != TRUE)
				return (FALSE);
		}
		new = TRUE;
		while (inword(FALSE) != FALSE) {
			c = lgetc(curwp->w_dotp, curwp->w_doto);
			if((!touc || (cap&&!new)) && c>='A' && c<='Z') {
				c += 'a'-'A';
				lputc(curwp->w_dotp, curwp->w_doto, c);
				lchange(WFHARD);
			}
			if((touc || (cap&&new)) && c>='a' && c<='z') {
				c -= 'a'-'A';
				lputc(curwp->w_dotp, curwp->w_doto, c);
				lchange(WFHARD);
			}
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
			new = FALSE;
		}
	}
	return (TRUE);
}

/*
 * Kill forward by "n" words.
 * Remember the location of dot. Move forward
 * by the right number of words. Put dot back where
 * it was and issue the kill command for the
 * right number of characters. Bound to "M-D".
 */
delfword(f, n)
{
	register int	size;
	register LINE	*dotp;
	register int	doto;

	if (n < 0)
		return (FALSE);
	dotp = curwp->w_dotp;
	doto = curwp->w_doto;
	size = 0;
	while (n--) {
		while (inword(FALSE) == FALSE) {
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
			++size;
		}
		while (inword(FALSE) != FALSE) {
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
			++size;
		}
	}
	curwp->w_dotp = dotp;
	curwp->w_doto = doto;
	return (ldelete(size, TRUE));
}

/*
 * Kill backwards by "n" words.
 * Move backwards by the desired number of
 * words, counting the characters. When dot is
 * finally moved to its resting place, fire off
 * the kill command. Bound to "M-Rubout" and
 * to "M-Backspace".
 */
delbword(f, n)
{
	register int	size;

	if (n < 0)
		return (FALSE);
	if (backchar(FALSE, 1) == FALSE)
		return (FALSE);
	size = 0;
	while (n--) {
		while (inword(FALSE) == FALSE) {
			if (backchar(FALSE, 1) == FALSE)
				return (FALSE);
			++size;
		}
		while (inword(FALSE) != FALSE) {
			if (backchar(FALSE, 1) == FALSE)
				return (FALSE);
			++size;
		}
	}
	if (forwchar(FALSE, 1) == FALSE)
		return (FALSE);
	return (ldelete(size, TRUE));
}
#endif

/*
 * Return TRUE if the character at dot
 * is a character that is considered to be
 * part of a word. If 'wrap'==TRUE that includes
 * the chars *.,+-'"?!()[] (for wordwrap).
 */
int
inword(wrap)
	register int	wrap;
{
	register int	c;
	register char	*p;

	if (curwp->w_doto >= llength(curwp->w_dotp))
		return (FALSE);
	c = lgetc(curwp->w_dotp, curwp->w_doto);
	if ((c>='a' && c<='z')
	 || (c>='A' && c<='Z')
	 || (c>='0' && c<='9'))
		return (TRUE);
	for (p=INWORDM;	*p; p++) {
		if (*p == c)
			return (TRUE);
	}
#if AtST
	if (c & 0x80)		/* foreign characters */
		return (TRUE);
#endif
	if (wrap) {
		for (p=INWORDW;	*p; p++) {
			if (*p == c)
				return (TRUE);
		}
	}
	return (FALSE);
}

/*
 * mb: added.
 * Insert tabs and spaces to indent by lmargin.
 */
int
do_margin()
{
	int  i, s;

	s = TRUE;
	i = lmargin / tabsize;
	if (i)
		s = linsert(i, '\t', 0);
	i = lmargin % tabsize;
	if ((s==TRUE) && i)
		s = linsert(i,  ' ', 0);
	return (s);
}
