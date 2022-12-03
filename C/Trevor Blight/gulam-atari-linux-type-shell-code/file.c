/*
	file.c of uE/Gulam

The routines in this file handle the reading and writing
of disk files.  All of details about the reading and writing of the
disk are in "fileio.c".  */

#include        "ue.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local makename P_((uchar bname[], uchar name[]));
local getfilename P_((uchar *ps, uchar *fnm));
local lineinsert P_((char *q, int nnb));
local readin P_((uchar name[], LINE *lp));
local writeout P_((BUFFER *bp, uchar *fn));
#undef P_


/* Take a file name, and from it fabricate a buffer name.  This
routine knows about the syntax of file names on the target system.
--pm */
	local
makename(bname, name)
uchar    bname[];
uchar    name[];
{
        register uchar   *p;
	register int	n;

	p = rindex(name, DSC);
	if (p == NULL) p = rindex(name, ':');
	if (p == NULL) p = name-1;
	n = strlen(++p); if (n > NBUFN-1) n = NBUFN-1;
	cpymem(bname, p, n);
	bname[n] = '\000';
}

/* Prompt for a filename using the given promt string and the parent
dir of fnm. --pm */
	local
getfilename(ps, fnm)
register uchar *ps, *fnm;
{	register uchar	*p, *q, c;
	uchar		*pp;
   extern	void	showcompletions();

	p = rindex(curbp->b_fname, DSC);
	if (p)
	{	c = *++p; *p = '\000';
		strcpy(fnm, curbp->b_fname);
		*p = c;
	}
	else
	{	p = gfgetcwd();  *fnm = '\000';
		if (p)
		{	strcpy(fnm, p);
			q = fnm + strlen(fnm) - 1;
			if (*q != DSC) {*++q = DSC; *++q = '\000';}
			gfree(p);
	}	}

	pp = gmalloc(NFILEN);	/* TENEX style file name expansion */
	if (pp) strcpy(pp, fnm); else return ABORT;
	mlmesg(ps);	/* 1 below => give full path on expansion */
	c = userfnminput(&pp, NFILEN, showcompletions, 1);
	mlmesg(ES);
	strcpy(fnm, pp); gfree(pp);
	killcompletions();
	if (c == '\007') return ABORT;
	return (c == '\r' || c == '\n'); 
}

/* Visit file named f; called from ue.c, misc.c also */

flvisit(f)
uchar            f[];
{
	uchar	 fname[NFILEN], bname[NBUFN];
        register BUFFER *bp;
        register WINDOW *wp;
        register LINE   *lp;
        register int    i, s;

	strcpy(fname, f);
	fullname(fname);
        for (bp=bheadp; bp!=NULL; bp=bp->b_bufp)
	{	if (strcmp(bp->b_fname, fname)==0)
 		{	if (--curbp->b_nwnd == 0) bwdotmark(curbp, curwp);
                        curbp = bp;
                        curwp->w_bufp  = bp;
                        if (bp->b_nwnd++ == 0) wbdotmark(curwp, bp);
			else
				for (wp = wheadp; wp; wp = wp->w_wndp)
				{	if (wp!=curwp && wp->w_bufp==bp)
					{	wwdotmark(curwp, wp);
                                                break;
				}	}
                        lp = curwp->w_dotp;
                        i = curwp->w_ntrows/2;
                        while (i-- && lback(lp)!=curbp->b_linep)
                                lp = lback(lp);
                        curwp->w_linep = lp;
                        curwp->w_flag |= WFMODE|WFHARD;
                        userfeedback("(Old buffer)", 2);
                        return TRUE;
	}	}
        makename(bname, fname);                 /* New buffer name.     */
        while (bp = bfind(bname, FALSE, 0, REGKB, 0))
	{	s = bp->b_flag;
		if ((s&BFTEMP) || ((s&BFRDO) && (s&BFCHG) == 0)) break; /*pm*/
                s = mlreply("A namesake buffer exists; give another name: ",
			 bname, NBUFN);
                if (s == '\007') return (ABORT);
                if (bname[0] == '\000')		/* clobber it     */
		{	makename(bname, fname);
                        break;
	}	}
        if (bp==NULL && (bp=bfind(bname, TRUE, 0, REGKB, BMCREG))==NULL)
	{	mlwrite("Cannot create buffer");
                return FALSE;
        }
        if (--curbp->b_nwnd == 0) bwdotmark(curbp, curwp);
        curbp = bp;                             /* Switch to it.        */
        curwp->w_bufp = bp;
        curbp->b_nwnd++;
	s = readin(fname, NULL);
	isetmark();
        return s;
}

extern	int	lnn, evalu;
extern	long	ntotal;
local	LINE	*lineinp;	/* used only in lineinsert()	*/

	local
lineinsert(q, nnb)		/* gets called via frdapply()	*/
register char	*q;
register int	nnb;
{
	if (evalu) return;
	if (lnlink(lineinp, q, nnb))
	{	ntotal += nnb + 2;
		lnn ++;
	} else evalu = -39;
	if (valu) evalu = valu;
}

/* Read file "name" into the current buffer.  If flag != 0, blow away
any text found there.  Return the final status of the read.  */
	local
readin(name, lp)
uchar    name[];
LINE	*lp;
{	register WINDOW *wp;
        register BUFFER *bp;
        register int    s;

	bp = curbp;
 	if (lp == NULL)
	{	lp = bp->b_linep;
		if ((s=bclear(bp)) != TRUE) return (s);	/* Might be old. */
		strcpy(bp->b_fname, name);
		bp->b_flag &= ~(BFTEMP|BFCHG);
	} else	bp->b_flag |= BFCHG;

	lineinp = lp;
 	s = frdapply(name, lineinsert);
 	if (s == FIOFNF) mlwrite("(New file)");
	for (wp=wheadp; wp!=NULL; wp=wp->w_wndp)
	{	if (wp->w_bufp == curbp)
 		{	wp->w_linep = 
                        wp->w_dotp  = lforw(curbp->b_linep);
                        wp->w_doto  = 0;
                        wp->w_markp = NULL;
                        wp->w_marko = 0;
                        wp->w_flag |= WFMODE|WFHARD;
	}	}
	return (s != FIOERR);
}

/* Insert the given named buffer (flag != 0), or file (flag == 0) into
the current buffer after the current line (after dotp).  */

insertborf(name, flag)
register uchar	*name;
register int	flag;
{	register int    s, odoto;
	register LINE	*odotp;

	odoto = curwp->w_doto; odotp = curwp->w_dotp;
	gotoeol(); forwchar(TRUE, 1);
	s = (flag
		? bufinsert(name)
		: readin(name, curwp->w_dotp)	);
	if (lnn)
	   mlwrite("(Inserted %s, %D bytes in %d lines)",name, ntotal, lnn);
	curwp->w_doto = odoto;  curwp->w_dotp = odotp;
        return s;
}

/* Insert a file into the current buffer.  Bound to "C-X I".  */

fileinsert()
{	register int    s;

        uchar            name[NFILEN];

        if ((s=getfilename("Insert file: ", name)) != TRUE) return s;
	fullname(name);
	return insertborf(name, 0);
}

/* Read a file into the current buffer.  This is really easy; all you
do it find the name of the file, and call the standard "read a file
into the current buffer" code.  Bound to "C-X C-R".  */

fileread()
{
        register int    s;
        uchar            name[NFILEN];

        if ((s=getfilename("Read file: ", name)) != TRUE) return (s);
	fullname(name);
	isetmark();
        return (readin(name, NULL));
}

/* Select a file for editing.  Look around to see if you can find the
file in another buffer; if you can find it just switch to the buffer.
If you cannot find the file, create a new buffer, read in the text,
and switch to the new buffer.  Bound to C-X C-V.  */

filevisit()
{
        register int    s;
        uchar            name[NFILEN];

        s=getfilename("Visit file: ", name);
	return (s != TRUE? s : flvisit(name));
}

/* This function performs the details of file writing.  Uses the file
management routines in fio.c.  The number of lines written is
displayed.  Sadly, it looks inside a LINE; provide a macro for this.
Most of the grief is error checking of some sort.  */

	local
writeout(bp, fn)
register BUFFER	*bp;
register uchar    *fn;
{
        register LINE   *lp;
	register long	ntotal;
        register int    nline, nb, s;

	if (bp->b_flag & BFRDO)
	{	s = mlyesno("Buffer is marked read-Only; write anyway?");
		if (s != TRUE) return FALSE;
	}
        if ((s=ffwopen(fn)) != FIOSUC) return FALSE;
        ntotal = nline = 0;                     /* Number of lines.     */
	for (lp = lforw(bp->b_linep); lp != bp->b_linep; lp = lforw(lp))
	{	s = ffputline(&lp->l_text[0], nb = llength(lp));
		if (s != FIOSUC) break;
                ++nline;
		ntotal += nb + 2;
        }
	nb = ffclose();
        if (s == FIOSUC)			/* No write error.      */
	{	if (nb == FIOSUC)		/* No close error.      */
		{	userfeedback(sprintp(
				"(Wrote %s : %D bytes in %d lines)",
				fn, ntotal, nline), 1);
	                bp->b_flag &= ~BFCHG;
			wupdatemodeline(bp);
        }	}
	return (s == FIOSUC);
}

/* Ask for a file name, and write the contents of the current buffer
to that file.  Update the remembered file name and clear the buffer
changed flag.  This handling of file names is different from the
earlier versions, and is more compatible with Gosling EMACS than with
ITS EMACS.  Bound to "C-X C-W".  */

filewrite()
{	extern	 uchar	*ptometach();
        register int    s;
        uchar            name[NFILEN];

	getfnm:
        if ((s=getfilename("Write the buffer to file: ", name)) != TRUE)
                return (s);
	if (fullname(name) > 1 || ptometach(name)) goto getfnm;
        if ((s=writeout(curbp, name)) == TRUE) strcpy(curbp->b_fname, name);
        return (s);
}

flsave(bp)
register BUFFER *bp;
{	extern	 uchar	*ptometach();
	register uchar	*p;

	p = bp->b_fname;
        if ((bp->b_flag&BFCHG) == 0) return TRUE; /* No changes.  */
        if (*p == 0 || ptometach(p)) return filewrite();
        return writeout(bp, p);
}

/* Save the contents of the current buffer in its associatd file.  No
nothing if nothing has changed (this may be a bug, not a feature).
Error if there is no remembered file name for the buffer.  Bound to
"C-X C-S".  May get called by "C-Z".  */

filesave()	{flsave(curbp);}

/* The command allows the user to modify the file name associated with
the current buffer.  It is like the "f" command in UNIX "ed".  The
operation is simple; just zap the name in the BUFFER structure, and
mark the windows as needing an update.  You can type a blank line at
the prompt if you wish.  */

filename()
{
        register int    s;
        uchar            name[NFILEN];

        if ((s=getfilename("Change associated file name to: ", name)) == ABORT)
                return (s);
	strcpy(curbp->b_fname, s? name : ES);
	wupdatemodeline(curbp);
        return TRUE;
}

/* -eof- */
