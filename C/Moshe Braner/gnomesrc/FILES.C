/*
 * file file.c:
 *
 * The routines in this file
 * handle the reading and writing of
 * disk files. All of details about the
 * reading and writing of the disk are
 * in "fileio.c".
 */

#include <stdio.h>
#include "ed.h"

#if MSDOS
#include <fcntl.h>
#include <sys/stat.h>
#endif

extern int ctrlg();

/*
 *  mb: code to add a filename to the list of defaults.
 */
int
addfile (fname)
	char *fname;
{
	char *fnp;

	if (nfiles < maxnfiles
	 && (fnp=malloc(NFILEN)) != NULL) {
		strcpy (fnp, fname);		/* save the file name	*/
		clfn[nfiles++] = fnp;		/* and add to the list	*/
		return (TRUE);
	}
	return (FALSE);
}

/*
 * mb: common code for fileread(), filewrite(), and filevisit().
 */
choosefile(prompt, fname, flag)
	char	*prompt, *fname;
	int	flag;
{
	char	*fnp, *dflt;
	int	s;
	int	old = TRUE;
start:
	if (old) {
		old = FALSE;
		if (flag) {
			if (curbp->b_fname[0] != '\0')
				dflt = curbp->b_fname;
			else
				dflt = curbp->b_bname;
		} else {
			if (oldbp != NULL)
				dflt = oldbp->b_fname;
			else
				goto start;
		}
	} else {
		if (nfiles == 0)
			dflt = NULL;
		else if (fileindex < nfiles)
			dflt = clfn[fileindex++];
		else {
			dflt = clfn[0];
			fileindex = 1;
		}
	}
	s = mlreply(prompt, dflt, fname, NFILEN, FALSE);
	if (s==UP) {
		if (fileindex > 1)
			fileindex -= 2;    /* one before last default */
		else if (fileindex == 1)
			fileindex = nfiles-1;
	}
	if (s==UP || s==DOWN)
		goto start;
	if (s!=TRUE && s!=FALSE)
		return (ABORT);
	if (s == TRUE)
		addfile (fname);
	return (TRUE);
}

/*
 * Read a file into the current
 * buffer. This is really easy; all you do it
 * find the name of the file, and call the standard
 * "read a file into the current buffer" code.
 * Bound to "C-X C-R".   mb: added keep&insert stuff.
 */
fileread(f, n)
{
	register BUFFER	*bp;
	register int	s, ins;
	char	fname[NFILEN];

	bp = curbp;
	if (lforw(bp->b_linep) != bp->b_linep) {	/* buf not empty */
		ins = mlyesno("Keep current text", fname, NFILEN);
		if (ins == ABORT)
			return (ctrlg());
		if (ins != TRUE) {
			if ((s=bclear(bp)) != TRUE)
				return (s);
		}
	} else
		ins = FALSE;

	if (choosefile("File to read", fname, TRUE) != TRUE) {
		bp->b_fname[0] = '\0';	  /* mb: not that file anymore! */
		curwp->w_flag |= WFMODE;
		return (ctrlg());
	}
	if ((s=readin(fname)) != FIOEOF)
		return (FALSE);
	bp->b_flag &= ~BFTEMP;
	if (ins)
		bp->b_flag |= BFCHG;
	else {
		strcpy(bp->b_fname, fname);
		bp->b_flag &= ~BFCHG;
	}
	bp->b_flag |= BFEDIT;			/* read for editing */
	return (TRUE);  
}

/*
 * Select a file for editing.
 * Look around to see if you can find the
 * file in another buffer; if you can find it
 * just switch to the buffer.
 * Else, create a new buffer, read in the
 * text, and switch to the new buffer.
 * Bound to C-X C-V.
 * mb: combined "out" portion of new & old cases,
 *	added "fileindex" stuff.
 */
filevisit(f, n)
{
	register BUFFER *bp;
	register WINDOW *wp;
	register LINE   *lp;
	char		fname[NFILEN];
	char		bname[NBUFN];
	char		tname[NBUFN];
	int		s, old;
	char		*msg;
	LINE		*flp, *fdp;

	if (choosefile("File to visit", fname, FALSE) != TRUE)
		return (ctrlg());

	old = FALSE;
	for (bp=bheadp; bp!=NULL; bp=bp->b_bufp) {
		if ((bp->b_flag&BFTEMP)==0 && strcmp(bp->b_fname, fname)==0) {
			old = TRUE;
			break;
		}
	}
	if (old) goto out;

	makename(bname, fname);			/* New buffer name.     */

	while ((bp=bfind(bname, FALSE, 0)) != NULL) {
		msg = "Buffer name (default: existing buffer!)";
		strcpy (tname, bname);
		s = mlreply(msg, tname, bname, NBUFN, FALSE);
		if (s!=TRUE && s!=FALSE)
			return (ctrlg());
		if (strcmp(bname,tname)==0) {
			if (bclear(bp) != TRUE)
				return(FALSE);
			break;
		}
	}
	if (bp==NULL && (bp=bfind(bname, TRUE, 0))==NULL) {
		mlwrite("Cannot create buffer");
		return (FALSE);
	}
out:
	flp = curwp->w_linep;
	fdp = curwp->w_dotp;
	gotobuf(bp);			/* mb: in buffer.c */
	if (old)
		mlwrite("[Old buffer]");
	else {
		if ((s=readin(fname)) != FIOEOF) {
			gotobuf(oldbp);		/* back where we started */
			freebuf(oldbp);		/* now oldbp = abandoned */
						/*  (empty) visited buf  */
			curwp->w_linep = flp;	/* mb: needed,		*/
			curwp->w_dotp  = fdp;	/*   don't know why	*/
			return (FALSE);
		}
		strcpy(bp->b_fname, fname);
		bp->b_flag &= ~(BFTEMP|BFCHG|BFEDIT);
	}
/*	curwp->w_linep = bp->b_linep;		mb: now done in gotobuf() */
	curwp->w_flag |= WFMODE|WFFORCE|WFHARD;
	return (TRUE);
}

/*
 * Read file "fname" into the current buffer.
 * Called by both the read and visit commands.
 * Return the final status of the read.
 * Also called by the mainline, to read in a file
 * specified on the command line as an argument.
 */
readin(fname)
char    fname[];
{
	register LINE   *lp1;
	register char	*cp;
	register int    i;
	register int    nbytes;
	register int    nline;
	register int    s;
	register WINDOW	*wp;
	register BUFFER	*bp;
	register LINE	*lp2;
	LINE		*flp;
	char		line[NLINE];
	int		longline = FALSE;

	s = ffropen(fname);
	if (s == FIOERR)
		mlwrite("Error opening file");
	if (s == FIOFNF)
		mlwrite("File not found");
	if (s != FIOSUC)
		return (s);
	mlwrite("[Reading file...]");
	wp = curwp;
	bp = curbp;
	flp = lforw(bp->b_linep);
	nline = 0;
	while ((s=ffgetline(line, NLINE))==FIOSUC) {
		nbytes = strlen(line);
		if (nbytes == NLINE-1)		/* "long line"	*/
			longline = TRUE;	/* Keep message */
		if ((lp1=lalloc(nbytes)) == NULL) {
			s = FIOERR;		/* Keep message displayed */
			/* mb: if not enough memory to read the whole file,
				protect the original from overwriting: */
			bp->b_flag &= (~BFEDIT);
			break;
		}

/* mb: original version:

		lp2 = lback(curbp->b_linep);
		lp2->l_fp = lp1;
		lp1->l_fp = curbp->b_linep;
		lp1->l_bp = lp2;
		curbp->b_linep->l_bp = lp1;
		for (i=0; i<nbytes; i++)
			lputc(lp1, i, line[i]);

- instead, enable insertion into existing text: */

		if (nline == 0)
			flp = lp1;
		lp2 = lback(wp->w_dotp);
		lp2->l_fp = lp1;
		lp1->l_fp = wp->w_dotp;
		lp1->l_bp = lp2;
		wp->w_dotp->l_bp = lp1;
		cp = line;
		for (i=0; i<nbytes; i++)
			lputc(lp1, i, *cp++);

		nline++;
	}
	frclose();				/* Ignore errors.       */

	if (s == FIOEOF && (! longline))	/* Don't zap message	*/
		mlwrite("[Read %d line(s)]", nline);
	if (s == FIOFUNNY)			/* passed to flag message */
		s = FIOEOF;			/* but is not an error	*/

	for (wp=wheadp; wp!=NULL; wp=wp->w_wndp) {
		if (wp->w_bufp == bp) {
/* original:		wp->w_linep = lforw(bp->b_linep);
			wp->w_dotp  = lforw(bp->b_linep);
			wp->w_doto  = 0;

  - mb: */		wp->w_linep = flp;
			wp->w_dotp  = flp;
			wp->w_doto  = 0;
			wp->w_force = 0;
			wp->w_flag |= WFMODE|WFHARD|WFFORCE;
			wp->w_markp = NULL;
			wp->w_marko = 0;
		}
	}
	return (s);
}

/*
 * Take a file name, and from it
 * fabricate a buffer name. This routine knows
 * about the syntax of file names on the target system.
 * I suppose that this information could be put in
 * a better place than a line of code.
 */
makename(bname, fname)
char    bname[];
char    fname[];
{
	register char   *cp1;
	register char   *cp2;
	register char	c;

	cp1 = &fname[0];
	while (*cp1 != 0)
		++cp1;
#if     VMS
	while (cp1!=&fname[0] && cp1[-1]!=':' && cp1[-1]!=']')
		--cp1;
#endif
#if     CPM
	while (cp1!=&fname[0] && cp1[-1]!=':')
		--cp1;
#endif
#if     MSDOS
	while (cp1!=&fname[0] && cp1[-1]!=':' && cp1[-1]!='\\')
		--cp1;
#endif
#if     AtST
	while (cp1!=&fname[0] && cp1[-1]!=':' && cp1[-1]!='\\')
		--cp1;
#endif
#if     V7
	while (cp1!=&fname[0] && cp1[-1]!='/')
		--cp1;
#endif
	cp2 = &bname[0];
	while (cp2!=&bname[NBUFN-1] && *cp1!=0 && *cp1!=';') {
		c = *cp1++;
#if (V7==0)
		if (c >= 'A' && c <= 'Z')
			c += 'a' - 'A';
#endif
		*cp2++ = c;
	}
	*cp2 = 0;
}

/*
 * Ask for a file name, and write the
 * contents of the current buffer to that file.
 * Update the remembered file name and clear the
 * buffer changed flag. This handling of file names
 * is different from the earlier versions, and
 * is more compatible with Gosling EMACS than
 * with ITS EMACS. Bound to "C-X C-W".
 * mb: added default filename.
 */
filewrite(f, n)
{
	register int    c;
	int	s;
	char	fname[NFILEN];
	WINDOW 	*wp;

	if (choosefile("File to write", fname, TRUE) != TRUE)
		return (ctrlg());

	if ((s=writeout(fname)) == TRUE) {
		strcpy(curbp->b_fname, fname);
		curbp->b_flag &= ~BFCHG;
		wp = wheadp;		/* Update mode lines. */
		while (wp != NULL) {
			if (wp->w_bufp == curbp)
				wp->w_flag |= WFMODE;
			wp = wp->w_wndp;
		}
	}
	return (s);
}

/*
 * Save the contents of the current
 * buffer in its associatd file. No nothing
 * if nothing has changed (this may be a bug, not a
 * feature). Error if there is no remembered file
 * name for the buffer. Bound to "C-X C-S". May
 * get called by "C-Z".
 */
filesave(f, n)
{
	register WINDOW *wp;
	register int    s;

	if ((curbp->b_flag&BFCHG) == 0)		/* Return, no changes.  */
		return (TRUE);
	if (curbp->b_fname[0] == 0) {		/* Must have a name.    */
		mlwrite("Need a file name");
		return (FALSE);
	}
	if ((s=writeout(curbp->b_fname)) == TRUE) {
		curbp->b_flag &= ~BFCHG;
		wp = wheadp;			/* Update mode lines.   */
		while (wp != NULL) {
			if (wp->w_bufp == curbp)
				wp->w_flag |= WFMODE;
			wp = wp->w_wndp;
		}
	}
	return (s);
}

/*
 * This function performs the details of file
 * writing. Uses the file management routines in the
 * "fileio.c" package. The number of lines written is
 * displayed. Sadly, it looks inside a LINE; provide
 * a macro for this. Most of the grief is error
 * checking of some sort.
 */
writeout(fn)
char    *fn;
{
	register int    s;
	register LINE   *lp;
	register int    nline;

	if (playback == TRUE)	/* mb: no file output from playback */
		return(TRUE);

	s = ffwopen(fn);
	if (s != FIOSUC) {
		mlwrite("Cannot open file for writing");
		return (FALSE);
	}

	mlwrite("[writing file...]");
	lp = lforw(curbp->b_linep);		/* First line.		*/
	nline = 0;				/* Number of lines.	*/
	while (lp != curbp->b_linep) {
		if ((s=ffputline(&lp->l_text[0], llength(lp))) != FIOSUC)
			break;
		++nline;
		lp = lforw(lp);
	}
	if (s == FIOSUC) {			/* No write error.      */
		s = fwclose();
		if (s == FIOSUC) {		/* No close error.      */
			mlwrite("[Wrote %d line(s)]", nline);
		}
	} else					/* Ignore close error   */
		fwclose();			/* if a write error.    */
	if (s != FIOSUC)			/* Some sort of error.  */
		return (FALSE);
	return (TRUE);
}

/*
 * The command allows the user
 * to modify the file name associated with
 * the current buffer. It is like the "f" command
 * in UNIX "ed". The operation is simple; just zap
 * the name in the BUFFER structure, and mark the windows
 * as needing an update.
 */
filename(f, n)
{
	register WINDOW *wp;
	register int    s;
	char		fname[NFILEN], *dflt, *fnp;

	if (curbp->b_fname[0] != '\0')
		dflt = curbp->b_fname;
	else
		dflt = curbp->b_bname;
	s = mlreply("New filename", dflt, fname, NFILEN, FALSE);
	if (s!=TRUE && s!=FALSE)
		return (ctrlg());
	if (s == TRUE)
		addfile (fname);
	strcpy(curbp->b_fname, fname);
	curbp->b_flag |= BFEDIT;
	wp = wheadp;				/* Update mode lines.   */
	while (wp != NULL) {
		if (wp->w_bufp == curbp)
			wp->w_flag |= WFMODE;
		wp = wp->w_wndp;
	}
	return (TRUE);
}


/*
 * file fileio.c:
 *
 * mb: Atari ST stuff & BFILES added.
 *
 * The routines in this file
 * read and write ASCII files from the
 * disk. All of the knowledge about files
 * are here. A better message writing
 * scheme should be used.
 */

#if BFILES
static	char	fbufp[FBLOCK];	/* File text buffer			*/
static	char	*fbpos;		/* Current position in file text buffer	*/
static	char	*ftail;		/* End of file text buffer		*/
static	int	oldbfc = EOF;	/* for bungetc				*/
#if (AtST | MSDOS)
static	int	handle = (-1);
static	long	fsize;
#endif
#else
static	FILE	*ffp;		/* File pointer, all functions. */
#endif BFILES

#if AtST
long
getfsize(fn)
	char *fn;
{
	int  dtabuf[22];
	Fsetdta(dtabuf);		/* tell GEMDOS where to put data */
	if (Fsfirst(fn, 0) != 0)	/* get the data */
		return (-1L);		/* file not found */
	return(*(long *)(&dtabuf[13]));	/* isolate the file size data */
}
#endif

/*
 * Open a file for reading.
 */
ffropen(fn)
char    *fn;
{
#if BFILES

#if AtST
	if ((fsize = getfsize(fn)) <= 0L)
		return (FIOFNF);
	if ((handle = (int) Fopen(fn, 0)) < 0)
		return (FIOERR);
	fbpos = fbufp;
	ftail = fbufp;			/* nothing read yet */
	return (FIOSUC);
#endif
#if MSDOS
	struct stat filestat;

	if ((handle = _open (fn, O_RDONLY)) < 0)
		return (FIOFNF);
	if (fstat (handle, &filestat))
		return (FIOERR);
	fsize = filestat.st_size;
	fbpos = fbufp;
	ftail = fbufp;			/* nothing read yet */
	return (FIOSUC);
#endif
#if (V7 | VMS | CPM)
	return (FIOERR);
#endif

#else	/* if not BFILES */

#if AtST
	if ((ffp=fopen(fn, "br")) == NULL)  /* we handle crlf ourselves */
#else
	if ((ffp=fopen(fn, "r")) == NULL)
#endif AtST
		return (FIOFNF);
	return (FIOSUC);
#endif BFILES
}

/*
 * Open a file for writing.
 * Return TRUE if all is well, and
 * FALSE on error (cannot create).
 */
ffwopen(fn)
char    *fn;
{
#if BFILES
#if AtST
	if ((handle = Fcreate(fn, 0)) < 0L)
		return (FIOERR);
	fbpos = fbufp;
	ftail = fbufp + FBLOCK;
	return (FIOSUC);
#endif
#if MSDOS
	if ((handle = _creat (fn, 0)) < 0)
		return (FIOERR);
	fbpos = fbufp;
	ftail = fbufp + FBLOCK;
	return (FIOSUC);
#endif
#if (V7 | VMS | CPM)
	return (FIOERR);
#endif
#else
#if	VMS
	register int    fd;

	if ((fd=creat(fn, 0666, "rfm=var", "rat=cr")) < 0
	|| (ffp=fdopen(fd, "w")) == NULL)
		return (FIOERR);
#else
	if ((ffp=fopen(fn, "w")) == NULL)
		return (FIOERR);
#endif	VMS
	return (FIOSUC);
#endif BFILES
}

/*
 * Close an input file.
 */
frclose()
{
#if BFILES
#if AtST
	if (handle >= 0) {
		Fclose(handle);
		handle = (-1);
	}
#endif
#if MSDOS
	if (handle >= 0) {
		_close (handle);
		handle = (-1);
	}
#endif
#else
	fclose(ffp);
#endif
}

/*
 * Close an output file.
 * Should look at the status in all systems.
 */
fwclose()
{
#if BFILES
	long size;
	int  isize;

	if (handle < 0)
		return (FIOERR);

#if AtST
	size = (fbpos - fbufp);
	if (size > 0L) {	/* something to write out */
		if (Fwrite(handle, size, fbufp) != size) {
			mlwrite("Write error");
			return (FIOERR);
		}
	}
	if (Fclose(handle) < 0L) {
		mlwrite("Error closing file");
		return(FIOERR);
	}
#endif
#if MSDOS
	isize = (int)(fbpos - fbufp);
	if (isize > 0) {	/* something to write out */
		if (_write (handle, fbufp, isize) != isize) {
			mlwrite("Write error");
			return (FIOERR);
		}
	}
	if (_close (handle) != 0) {
		mlwrite("Error closing file");
		return(FIOERR);
	}
#endif
	handle = (-1);
#else
#if     V7
	if (fclose(ffp) != FALSE) {
		mlwrite("Error closing file");
		return(FIOERR);
	}
#else
#if     AtST
	if (ffp != NULL && fclose(ffp) != FALSE) {
		mlwrite("Error closing file");
		return (FIOERR);
	}
#else
	fclose(ffp);
#endif	AtST
#endif	V7
#endif	BFILES
	return (FIOSUC);
}

#if BFILES
bputc(c)
	register int c;
{
	if (fbpos >= ftail) {	/* RAM full, write it out */
#if AtST
		if (Fwrite(handle, (long)FBLOCK, fbufp) != FBLOCK)
			return (EOF);
#endif
#if MSDOS
		if (_write (handle, fbufp, (int)FBLOCK) != FBLOCK)
			return (EOF);
#endif
		fbpos = fbufp;
	}
	*fbpos++ = (char) c;
	return (c);
}
#endif BFILES

/*
 * Write a line to the already
 * opened file. The "buf" points to the
 * buffer, and the "nbuf" is its length, less
 * the free newline. Return the status.
 * Check only at the newline.
 */
int
ffputline(buf, nbuf)
register char   buf[];
register int    nbuf;
{
	register int    i, c;

	c = 0;				/* in case nbuf==0 */
	for (i=0; i<nbuf; ++i) {
#if BFILES
		c = bputc(buf[i]);
#else
		c = putc(buf[i], ffp);
#endif
		if (c == EOF)
			break;
	}
#if BFILES
	if (c != EOF)
		c = bputc('\r');
	if (c != EOF)
		c = bputc('\n');
	if (c==EOF) {
#else
	if (c != EOF)
		c = putc('\n', ffp);
	if (c==EOF || ferror(ffp) != FALSE) {
#endif
		mlwrite("Write error");
		return (FIOERR);
	}
	return (FIOSUC);
}

/*
 * Read a line from a file,
 * and store the bytes in the supplied
 * buffer. The "nbuf" is the length of the
 * buffer. Complain about long lines and lines
 * at the end of the file that don't have a
 * newline present. Check for I/O errors
 * too. Return status.
 */
#if BFILES
int
bgetc()
{
	long	size;
	int	c, isize;

	if (oldbfc != EOF) {
		c = oldbfc;
		oldbfc = EOF;
		return (c);
	}
#if AtST
	if (fbpos >= ftail) {
		if (fsize <= 0)
			return (EOF);	/* no error */
		size = (long) FBLOCK;
		if (fsize < (long) FBLOCK)
			size = fsize;
		if (Fread(handle, size, fbufp) == size) {
			fsize -= size;	/* what's left to read */
			fbpos = fbufp;
			ftail = fbufp + size;
		} else {
			return (EOF);	/* error */
		}
	}
#endif
#if MSDOS
	if (fbpos >= ftail) {
		if (fsize <= 0)
			return (EOF);	/* no error */
		isize = (int) FBLOCK;
		if (fsize < (long) FBLOCK)
			isize = (int) fsize;
		if (_read (handle, fbufp, isize) != isize)
			return (EOF);	/* error */
		fsize -= (long) isize;	/* what's left to read */
		fbpos = fbufp;
		ftail = fbufp + isize;
	}
#endif
#if (V7 | VMS | CPM)
		return (EOF);
#endif

	return (*fbpos++);
}
int
bungetc(c)
	int c;
{
	oldbfc = c;
}
#endif
int
ffgetline(buf, nbuf)
register char   buf[];
register int    nbuf;
{
	register int    c, i, t;

	i = 0;
	--nbuf;
#if BFILES
	while ((c=bgetc()) != EOF) {
		if (c == '\n') {
			if ((t=bgetc()) != '\r')
				bungetc(t);
			break;
		}
		if (c == '\r') {
			if ((t=bgetc()) != '\n')
				bungetc(t);
			c = '\n';
			break;
		}
#else
	while ((c=getc(ffp)) != EOF) {
		if (c == '\n') {
			if ((t=getc(ffp)) != '\r')
				ungetc(t, ffp);
			break;
		}
		if (c == '\r') {
			if ((t=getc(ffp)) != '\n')
				ungetc(t, ffp);
			c = '\n';
			break;
		}
#endif BFILES
		buf[i++] = c;
		if (i >= nbuf) {
			mlwrite("File has long line: splitted");
			break;
		}
	}
	buf[i] = 0;
	if (c == EOF) {
#if BFILES
		if (fsize != 0L) {
#else
		if (ferror(ffp) != FALSE) {
#endif
			mlwrite("File read error");
			return (FIOERR);
		}
		if (i != 0) {
			if (i==1 && buf[0]==0x1A)
				mlwrite("dropped ^Z at EOF");
			else
				mlwrite("Missing newline appended at EOF");
			return (FIOFUNNY);
		}
		return (FIOEOF);
	}
	return (FIOSUC);
}

#if CANLOG

/**
 **  mb: log file variables and functions:
 **/

#if (AtST | MSDOS)

static char *logfn = NULL;
static int  loghand = (-1);
static char logbuf[LOGFLUSH];
static int  logfc = 0;
static int  logtail = 0;
static long logsize;
#if MSDOS
extern char *getenv();		/* supported by Turbo C */
#endif

int
ropenlog()
{
#if MSDOS
	struct stat filestat;
#endif
	if (loghand >= 0)
		return (FALSE);		/* log file already open */
#if MSDOS
	/* try and get the log file pathname from the environment */
	if ((logfn=getenv("GNOMELOG")) == NULL)
		logfn = LOGFILE;
#else
	logfn = LOGFILE;
#endif
#if AtST
	logsize = getfsize(logfn);
	if (logsize <= 0L)
		return (ABORT);
	if ((loghand = (int) Fopen(logfn, 0)) < 0)
		return (FIOERR);
#endif
#if MSDOS
	if ((loghand = _open (logfn, O_RDONLY)) < 0)
		return (FIOERR);
	if (fstat (loghand, &filestat))
		return (FIOERR);
	logsize = filestat.st_size;
	if (logsize <= 0L)
		return (ABORT);
#endif
	logfc = 0;
	logtail = 0;		/* nothing read yet */
	return (TRUE);
}

int
wopenlog()
{
	if (loghand >= 0)
		return (FALSE);		/* log file already open */
#if MSDOS
	/* try and get the log file pathname from the environment */
	if ((logfn=getenv("GNOMELOG")) == NULL)
		logfn = LOGFILE;
#else
	logfn = LOGFILE;
#endif
#if AtST
	if ((loghand = Fcreate(logfn, 0)) < 0L)
		return (ABORT);
#endif
#if MSDOS
	if ((loghand = _creat (logfn, 0)) < 0)
		return (ABORT);
#endif
	logfc = 0;
	return (TRUE);
}

closelog()
{
	if (loghand >= 0)
#if AtST
		Fclose(loghand);
#endif
#if MSDOS
		_close (loghand);
#endif
	loghand = (-1);
}

int
putlog(c)
	int c;
{
	int tmp;
	logbuf[logfc++] = c;
	if (logfc >= LOGFLUSH) {
		tmp = logfc;
		if (flushlog(TRUE) != tmp)
			return (EOF);		/* error */
	}
	return (c);
}

int
flushlog(flag)
	int flag;
{
	int size = 0;

	if (flag) {
		if (loghand>=0 && logfc>0)
#if AtST
			size = (int) Fwrite(loghand, (long)logfc, logbuf);
#endif
#if MSDOS
			size = _write (loghand, logbuf, (int)logfc);
#endif
		logfc = 0;
	}
	return (size);
}

int
getlog()
{
	long size;

	if (logfc >= logtail) {
		if (logsize == 0)
			return (EOF);	/* end of file */
		if (logsize > LOGFLUSH)
			size = LOGFLUSH;
		else
			size = logsize;
#if AtST
		if (Fread(loghand, size, logbuf) != size)
			return (EOF);	/* error */
#endif
#if MSDOS
		if (_read (loghand, logbuf, (int)size) != (int)size)
			return (EOF);	/* error */
#endif
		logsize -= size; /* what's left to read */
		logfc = 0;
		logtail = (int) size;
	}
	return (logbuf[logfc++]);
}

#else	/* log file through standard I/O */

static FILE *logfp = NULL;
static int   logfc = 0;
static char *logfn = NULL;
#if V7
extern char *getenv();
#endif
#if VMS
static int   fd;
#endif

int
ropenlog()
{
	if (logfp != NULL)
		return (FALSE);		/* log file already open */
#if V7
	/* try and get the log file pathname from the environment */
	if ((logfn=getenv("GNOMELOG")) == NULL)
		logfn = LOGFILE;
#else
	logfn = LOGFILE;
#endif
	if ((logfp=fopen(logfn, "r")) == NULL)
		return (ABORT);
	return (TRUE);
}

int
wopenlog()
{
	if (logfp != NULL)
		return (FALSE);		/* log file already open */
#if V7
	/* try and get the log file pathname from the environment */
	if ((logfn=getenv("GNOMELOG")) == NULL)
		logfn = LOGFILE;
#else
	logfn = LOGFILE;
#endif
#if	VMS
	if ((fd=creat(logfn, 0666, "rfm=var", "rat=cr")) < 0
	|| (logfp=fdopen(fd, "w")) == NULL)
#else
	if ((logfp=fopen(logfn, "w")) == NULL)
#endif
		return (ABORT);
	return (TRUE);
}

closelog()
{
	if (logfc != NULL)
		fclose(logfp);
	logfc = NULL;
}

int
putlog(c)
	int c;
{
	int s;
	s = fputc (c, logfp);
	++logfc;
	return (s);
}

flushlog(flag)
	int flag;
{
	if ((flag && logfc > 0) || logfc >= LOGFLUSH)
		fflush(logfp);
	logfc = 0;
}

int
getlog()
{
	return (fgetc (logfp));
}

#endif	/* log file I/O for various systems */

#endif CANLOG

#if (AtST | MSDOS)

/*
 * mb: output the current buffer to a hardcopy device.
 */
int
hardcopy (f, n)
{
	register int    c, s;
	register LINE   *lp;
	register int    nline, npage;
	int		leftm, doskip, pagenums;
	char		buf[50];
	extern	int	hdev;

	if (playback == TRUE)	/* no hardcopy from playback */
		return(TRUE);

	s = mlreply("Parallel or Serial port? (p/s)", "P", buf, 50, FALSE);
	if (s!=TRUE && s!=FALSE)
		return (ctrlg());
	if (buf[0]=='s' || buf[0]=='S')
		hdev = SERPORT;
	else
		hdev = PARPORT;

	s = mlreply("Extra left margin", "0", buf, 50, FALSE);
	if (s!=TRUE && s!=FALSE)
		return (ctrlg());
	leftm = 0;
	s = 0;
	while ((c=buf[s++]) >= '0' && c <= '9')
		leftm = 10*leftm + c-'0';

	s = mlreply("Skip over perforation? (y/n) ", "Y", buf, 50, FALSE);
	if (s!=TRUE && s!=FALSE)
		return (ctrlg());
	if (buf[0]=='n' || buf[0]=='N')
		doskip = FALSE;
	else
		doskip = TRUE;

	if (! doskip)
		goto noskip;

	s = mlreply("Page numbers? (y/n) ", "Y", buf, 50, FALSE);
	if (s!=TRUE && s!=FALSE)
		return (ctrlg());
	if (buf[0]=='n' || buf[0]=='N')
		pagenums = FALSE;
	else
		pagenums = TRUE;
noskip:
	mlwrite("[printing buffer...]");
	lp = lforw(curbp->b_linep);		/* First line.		*/
	nline = 0;				/* Number of lines.	*/
	npage = 1;				/* Number of pages.	*/
	s = TRUE;
	while (lp != curbp->b_linep) {
		if (nline >= 60 && doskip) {
			if (pagenums) {
				++npage;
				for (s=0; s<41; s++)
					buf[s] = ' ';
				buf[41] = (npage%10) + '0';
				if (npage > 9)
					buf[40] = ((npage%100)/10) + '0';
				if (npage > 99)
					buf[39] = (npage/100) + '0';
			}
			for (nline=0; nline<6; nline++) {
				if (pagenums && nline == 4)
					s = hputline (buf, 42, 0);
				else
					s = hputline ((char *)0, 0, 0);
				if (s == FALSE)
					return (FALSE);
			}
			nline = 0;
		}
		s = hputline (&lp->l_text[0], llength(lp), leftm);
		if (s == FALSE)
			return (FALSE);
		++nline;
		lp = lforw(lp);
	}
	mlwrite("[done printing]");
	return (TRUE);
}

int
hputline (buf, nbuf, leftm)
	register char   buf[];
	int		nbuf, leftm;
{
	register int    i, c;

	c = TRUE;			/* in case nbuf==0 */

	if (leftm>0 && nbuf>0) {
		for (i=0; i<leftm; i++) {
			c = hardputc(' ');
			if (c == FALSE)
				goto jam;
		}
	}

	for (i=0; i<nbuf; ++i) {
		c = hardputc(buf[i]);
		if (c == FALSE)
			goto jam;
	}
	c = hardputc('\r');
	if (c != FALSE)
		c = hardputc('\n');
jam:
	if (c == FALSE)
		mlwrite("Unable to print");

	return (c);
}

#else
int hardcopy() {return (FALSE);}
#endif


/*
 * file: spawn.c
 *
 * The routines in this file
 * are called to create a subjob running
 * a command interpreter. This code is a big
 * fat nothing on CP/M-86. You lose.
 */

#if	VMS
#define	EFN	0				/* Event flag.		*/

#include	<ssdef.h>			/* Random headers.	*/
#include	<stsdef.h>
#include	<descrip.h>
#include	<iodef.h>

extern	int	oldmode[];			/* In "termio.c"	*/
extern	int	newmode[];			/* In "termio.c"	*/
extern	short	iochan;				/* In "termio.c"	*/
#endif

#if	MSDOS
#include	<dos.h>
#endif

#if	V7
#include	<signal.h>
#endif

/*
 * Create a subjob with a copy
 * of the command intrepreter in it. When the
 * command interpreter exits, mark the screen as
 * garbage so that you do a full repaint. Bound
 * to "C-X C-C". The message at
 * the start in VMS puts out a newline. Under
 * some (unknown) condition, you don't get one
 * free when DCL starts up.
 */
spawncli(f, n)
{
#if	VMS
	if (playback == TRUE)
		return (FALSE);
	movecursor(term.t_nrow, 0);		/* In last line.	*/
	mlputs("[Starting DCL]\r\n");
	(*term.t_flush)();			/* Ignore "ttcol".	*/
	sgarbf = TRUE;
	return (sys(NULL));			/* NULL => DCL.		*/
#endif
#if	AtST			/* give a disk directory listing	*/
	register long s;
	register int  j, c, nlen;
	int	dinfo[22];
	char	*prompt;
	char	path[90];
	char	buf[90];
	extern int ttcol;
	if (playback == TRUE)
		return (FALSE);
	path[0] = (char)(Dgetdrv() + 'A');	/* current prefix */
	path[1] = ':';
	if ((s=Dgetpath(&path[2], 0)) != 0)
		return (FALSE);
	strcat(path, "\\*.*");
	prompt = "Directory to list";
	c = mlreply(prompt, path, buf, 80, FALSE);
	if (c!=TRUE && c!=FALSE)
		return (ctrlg());
	strcpy(path, buf);
	j = 0;
	while (c=path[j++]) {
		if (c == '*')		/* user-specified wildcards */
			break;
	}
	if (c != '*')			/* just a directory name */
		strcat(path, "\\*.*");	/* GEMDOS wants this	 */
	Fsetdta(dinfo);
	mlputs("\r\n");
	j = 0;
	s = Fsfirst(path, 0x31);
	while (s == 0) {
		if (++j >= 22) {
			mlputs ("-- more -- ");
			c = (*term.t_getchar)();
			if (c=='q' || c=='Q' || c==0x1B) {
				sgarbf = TRUE;
				return (TRUE);
			}
			mlputs ("\r");
			j = 0;
		}
		ttcol = 0;
		c = dinfo[10];			/* attributes	*/
		if (c & 0x01)			/* read only	*/
			mlputs ("  > ");
		else
			mlputs ("    ");
		mlputs ((char *)(&dinfo[15]));	/* file name	*/
		if (c & 0x10) {			/* subdirectory	*/
			mlputs ("\\");
			goto next;
		}
		while (ttcol < 20)
			mlputs (" ");
		c = ((dinfo[12]>>9)&0x3F);	/* year		*/
		dirout (c+80, '-');
		c = ((dinfo[12]>>5)&0xF);	/* month	*/
		dirout (c, '-');
		c = ((dinfo[12])&0x1F);		/* day		*/
		dirout (c, ' ');
		mlputs ("    ");
		s = *(long *)(&dinfo[13]);	/* file length	*/
		mlputli (s, 10);
	next:
		mlputs ("\033K\n\r");
		ttcol = 0;
		s = Fsnext();
	}
	mlputs ("-- end of listing -- ");
	(*term.t_getchar)();
	sgarbf = TRUE;
	return (TRUE);
#endif
#if	CPM
	if (playback == TRUE)
		return (FALSE);
	mlwrite("Not in CP/M-86");
	return (FALSE);
#endif
#if	MSDOS
	if (playback == TRUE)
		return (FALSE);
	movecursor(term.t_nrow, 0);		/* Seek to last line.	*/
	(*term.t_flush)();
	system("command.com");			/* Run command.com and have
						   it run command.com...
						   (Turbo C lib fnc) */
	sgarbf = TRUE;
	return(TRUE);
#endif
#if	V7
	register char *cp;
	char	*getenv();
	if (playback == TRUE)
		return (FALSE);
	movecursor(term.t_nrow, 0);		/* Seek to last line.	*/
	(*term.t_flush)();
	ttclose();				/* stty to old settings	*/
	if ((cp = getenv("SHELL")) != NULL && *cp != '\0')
		system(cp);
	else
		system("exec /bin/sh");
	ttopen();
	sgarbf = TRUE;
	return(TRUE);
#endif
}

#if AtST
dirout(c, e)
	register int c;
	int e;
{
	register int	d;
	register char	*p;
	char str[4];

	d = '0';
	while (c > 9) {
		d += 1;
		c -= 10;
	}
	p = str;
	*p++ = d;
	*p++ = c + '0';
	*p++ = e;
	*p = '\0';
	mlputs(str);
}
#endif

/*
 * Run a one-liner in a subjob.
 * When the command returns, wait for a single
 * character to be typed, then mark the screen as
 * garbage so a full repaint is done.
 * Bound to "C-X !".
 */
spawn(f, n)
{
#if	VMS
	register int	s;
	char		line[NLINE];
	if (playback == TRUE)
		return (FALSE);
	s = mlreply("DCL command", (char*)0, line, NLINE, FALSE);
	if (s != TRUE && S != FALSE)
		return (ctrlg());
	(*term.t_putchar)('\n');		/* Already have '\r'	*/
	(*term.t_flush)();
	s = sys(line);				/* Run the command.	*/
	mlputs("\r\n\n[End]");			/* Pause.		*/
	(*term.t_flush)();
	while ((*term.t_getchar)() != '\r')
		;
	sgarbf = TRUE;
	return (s);
#endif
#if	AtST				/* set default path prefix	*/
	register int	c, s;
	register char	*cp;
	char	path[90], buf[90];
	char	*prompt;
	if (playback == TRUE)
		return (FALSE);
	path[0] = (char)(Dgetdrv() + 'A');
	path[1] = ':';
	if (Dgetpath(&path[2], 0) != 0)
		return (FALSE);
	prompt = "Default path prefix";
	s = mlreply(prompt, path, buf, 90, FALSE);
	if (s!=TRUE && s!=FALSE)
		return (ctrlg());
	cp = buf;
	if (cp[1] == ':') {
		c = *cp;
		if (c < 'a')
			c += ('a'-'A');
		Dsetdrv(c-'a');
		cp += 2;
	}
	Dsetpath(cp);
	return (TRUE);
#endif
#if	CPM
	if (playback == TRUE)
		return (FALSE);
	mlwrite("Not in CP/M-86");
	return (FALSE);
#endif
#if	MSDOS
	register int	i, s;
	register char	*cp;
	char		line[NLINE];
	static char	**history = NULL;
	static int	histindex = 0;
	static int	nhist = 0;

	if (playback == TRUE)
		return (FALSE);

	if (history == NULL) {
		history = (char **) malloc (HISTORY * sizeof(char *));
		if (history)
			cp = (char *) malloc (HISTORY * NFILEN);
		else
			cp = NULL;
		if (cp == NULL) {
			if (history)
				free (history);
			mlwrite ("not enough memory");
			return (ABORT);
		}
		for (i=0; i<HISTORY; i++, cp+=NFILEN) {
			history[i] = cp;
			cp[0] = '\0';
		}
	}

start:
	i = histindex;
loop:
	cp = history[i];
	if (! (*cp))
		cp = NULL;
	s = mlreply("MS-DOS command", cp, line, NFILEN, FALSE);
	if (s == UP) {
		if (i > 0)
			--i;
		else if (nhist)
			i = nhist-1;
		goto loop;
	}		
	if (s == DOWN) {
		if (i < nhist-1)
			++i;
		else
			i = 0;
		goto loop;
	}
	if (s != TRUE && s != FALSE)
		goto done;
	if (s == TRUE) {
		if (nhist) {
			if (++histindex >= HISTORY)
				histindex = 0;
		}
		if (nhist < HISTORY)
			++nhist;
		strcpy (history[histindex], line);
	} else
		histindex = i;
	(*term.t_putchar)('\n');
	system(line);
	(*term.t_putchar)('\n');
	goto start;
done:
	sgarbf = TRUE;
	return (ctrlg());
#endif
#if	V7
	register int	s;
	char		line[NLINE];
	if (playback == TRUE)
		return (FALSE);
	s = mlreply("Shell command", (char*)0, line, NLINE, FALSE);
	if (s != TRUE && s != FALSE)
		return (ctrlg());
	(*term.t_putchar)('\n');		/* Already have '\r'	*/
	(*term.t_flush)();
	ttclose();				/* stty to old modes	*/
	system(line);
	ttopen();
	mlputs("[End]");
	(*term.t_getchar)();			/* Pause.		*/
	sgarbf = TRUE;
	return (TRUE);
#endif
}

#if	VMS
/*
 * Run a command. The "cmd" is a pointer
 * to a command string, or NULL if you want to run
 * a copy of DCL in the subjob (this is how the standard
 * routine LIB$SPAWN works. You have to do wierd stuff
 * with the terminal on the way in and the way out,
 * because DCL does not want the channel to be
 * in raw mode.
 */
sys(cmd)
register char	*cmd;
{
	struct	dsc$descriptor	cdsc;
	struct	dsc$descriptor	*cdscp;
	long	status;
	long	substatus;
	long	iosb[2];

	status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
			  oldmode, sizeof(oldmode), 0, 0, 0, 0);
	if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
		return (FALSE);
	cdscp = NULL;				/* Assume DCL.		*/
	if (cmd != NULL) {			/* Build descriptor.	*/
		cdsc.dsc$a_pointer = cmd;
		cdsc.dsc$w_length  = strlen(cmd);
		cdsc.dsc$b_dtype   = DSC$K_DTYPE_T;
		cdsc.dsc$b_class   = DSC$K_CLASS_S;
		cdscp = &cdsc;
	}
	status = LIB$SPAWN(cdscp, 0, 0, 0, 0, 0, &substatus, 0, 0, 0);
	if (status != SS$_NORMAL)
		substatus = status;
	status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
			  newmode, sizeof(newmode), 0, 0, 0, 0);
	if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
		return (FALSE);
	if ((substatus&STS$M_SUCCESS) == 0)	/* Command failed.	*/
		return (FALSE);
	return (TRUE);
}
#endif
