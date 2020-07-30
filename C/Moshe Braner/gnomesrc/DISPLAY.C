/*
 * The functions in this file
 * handle redisplay. There are two halves,
 * the ones that update the virtual display
 * screen, and the ones that make the physical
 * display screen the same as the virtual
 * display screen. These functions use hints
 * that are left in the windows by the
 * commands.
 */
#include	<stdio.h>
#include	"ed.h"

#define WFDEBUG 0			/* Window flag debug.		*/

extern int getkey();
extern int escseq();

typedef struct  VIDEO {
	int	v_col;			/* mb: line len / scrn offset	*/
	int	v_flag;			/* Flags			*/
	char	v_text[NLINE];		/* Screen data.			*/
}	VIDEO;

#define VIDEOSIZE (sizeof(VIDEO)-NLINE)

#define VFCHG	0x0001			/* Changed.			*/
#define VFMOD	0x0002			/* Mode line. (dal/mb:)		*/

int	sgarbf  = TRUE;			/* TRUE if screen is garbage	*/
int	mpresf  = FALSE;		/* TRUE if message in last line */
int	visible = FALSE;		/* mb: show white-space chars	*/
int	vtrow	= 0;			/* Row location of SW cursor	*/
int	vtcol	= 0;			/* Column location of SW cursor */
int	ttrow	= HUGE;			/* Row location of HW cursor	*/
int	ttcol	= HUGE;			/* Column location of HW cursor */

VIDEO	**vscreen;			/* Virtual screen.		*/
VIDEO	**pscreen;			/* Physical screen.		*/

/*
 * Initialize the data structures used
 * by the display code. The edge vectors used
 * to access the screens are set up. The operating
 * system's terminal I/O channel is set up. All the
 * other things get initialized at compile time.
 * The original window has "WFCHG" set, so that it
 * will get completely redrawn on the first
 * call to "update".
 * mb: added initialization of v_flag fields since we want VFMOD right.
 */
vtinit()
{
	register int	i;
	register VIDEO  *vp;

	(*term.t_open)();
	vscreen = (VIDEO **) malloc(term.t_nrow*sizeof(VIDEO *));
	if (vscreen == NULL)
#if BFILES
		_exit(1);
#else
		exit(1);
#endif
	pscreen = (VIDEO **) malloc(term.t_nrow*sizeof(VIDEO *));
	if (pscreen == NULL)
#if BFILES
		_exit(1);
#else
		exit(1);
#endif
	for (i=0; i<term.t_nrow; ++i) {
		vp = (VIDEO *) malloc(VIDEOSIZE+NLINE);
		if (vp == NULL)
#if BFILES
			_exit(1);
#else
			exit(1);
#endif
		vscreen[i] = vp;
		vp->v_flag = 0;
		vp->v_col = 0;		/* mb: line length */
		vp = (VIDEO *) malloc(VIDEOSIZE+term.t_ncol);
		if (vp == NULL)
#if BFILES
			_exit(1);
#else
			exit(1);
#endif
		pscreen[i] = vp;
		vp->v_flag = 0;
		vp->v_col = 0;		/* mb: screen offset */
	}
}

/*
 * Clean up the virtual terminal
 * system, in anticipation for a return to the
 * operating system. Move down to the last line and
 * clear it out (the next system prompt will be
 * written in the line). Shut down the channel
 * to the terminal.
 */
vttidy()
{
	movecursor(term.t_nrow, 0);
	(*term.t_putchar)('\n');	/* mb: scroll! */
	(*term.t_close)();
}

/*
 * mb: toggle visibility of tabs, spaces and newlines
 */
int
visitog(f,n)
{
	visible = !visible;
	if (visible)
		mlwrite("[white-space characters visible]");
	else
		mlwrite("[white-space white]");
	sgarbf = TRUE;
	update(FALSE);
	return (TRUE);
}

/*
 * Set the virtual cursor to
 * the specified row and column on the
 * virtual screen. There is no checking for
 * nonsense values; this might be a good
 * idea during the early stages.
 */
vtmove(row, col)
{
	vtrow = row;
	vtcol = col;
}

/*
 * Write a character to the
 * virtual screen. The virtual row and
 * column are updated.
 * This routine only puts printing characters
 * into the virtual terminal buffers.
 * Only column overflow is checked.
 * mb: added general tab size & "visible" option.
 */
vtputc(c)				/* mb: split */
{
	vvtputc(c, 0);
}

vvtputc(c, wvsbl)
	register int	c;
	register int	wvsbl;		/* mb: white-space visibility */
{
	register VIDEO	*vp;

	c &= 0x00FF;
	if (c == '\t') {
		if (wvsbl)
			c = '-';
		else
			c = ' ';
		while (((vtcol+1)%tabsize) != 0)
			vtputc(c);
		if (wvsbl)
			c = '>';
	} else if (c == '\n') {
		if (wvsbl) {
			c = '<';
			vtputc(c);
		} else
			return;
	} else if (c == ' ') {
		if (wvsbl)
			c = '_';
	} else if (c<0x20 || c==0x7F) {
		vtputc('^');
		c ^= 0x40;
	}
	vp = vscreen[vtrow];
	if (vtcol < NLINE)
		vp->v_text[vtcol++] = c;
	vp->v_col = vtcol;
}

/*
 * Erase from the end of the
 * software cursor to the end of the
 * line on which the software cursor is
 * located.
 */
vteeol()
{
	register VIDEO  *vp;

	vp = vscreen[vtrow];
	while (vtcol < NLINE)
		vp->v_text[vtcol++] = ' ';
}

/*
 * mb: heavily altered.
 * Make sure that the display is
 * right. This is a three part process.
 * First, make sure that "currow" and "curcol" are
 * correct for the current window, and get the screen
 * offset into the v_col fields of each line.
 * Second, scan through all of the windows looking for
 * dirty ones. Check the framing, and refresh the screen.
 * Third, make the virtual and physical screens the same.
 */
update(visiplay)
	int visiplay;
{
	register LINE	*lp;
	register WINDOW *wp;
	register int	j;
	register int	c;
	register int	v;
	register int	i;
	int	vflag, *pvflag;
	int	wshift, wsflag, offset;
	VIDEO	*vp, *pp;
	BUFFER	*bp;

	if (playback == TRUE) {
		if (visiplay)
			mlwrite("[Playback in progress...]");
		else
			return;   /* mb: invisible playback */
	}

	/* Always recompute the row and column number of the hardware	*/
	/* cursor. This is the only update for simple moves.		*/
	/* mb: do it here to find out if w_offset needs to be changed	*/
	wp = curwp;
	lp = wp->w_linep;
	while (lp != wp->w_dotp)
		lp = lforw(lp);
	curcol = 0;
	i = 0;
	while (i < wp->w_doto) {
		c = lgetc(lp, i++);
		if (c == '\t')
			curcol += tabsize-(curcol%tabsize)-1;  /* mb: */
		else if (c<0x20 || c==0x7F)
			++curcol;
		++curcol;
	}
	wsflag = 0;
	offset = wp->w_offset;
	curcol -= offset;
	wshift = term.t_ncol / WSHIFT;
	while (curcol >= term.t_ncol - (offset? 2 : 1)) {
		offset += wshift;		/* mb: shift window right */
		curcol -= wshift;
		wsflag = 1;
	}
	while (curcol < 0) {
		offset -= wshift;		/* mb: shift window left */
		curcol += wshift;
		wsflag = 1;
	}
	if (wsflag) {
		wp->w_offset = offset;
		wp->w_flag |= WFHARD;	/* mb: must redraw window */
	}
	if (offset)
		++curcol;		/* mb: for the '$' at the left */

	wp = wheadp;
	while (wp != NULL) {
		v = visible;
		bp = wp->w_bufp;
		if (bp==blistp || bp==bhelpp)
			v = FALSE;
		if (sgarbf != FALSE)			/* mb: added */
			wp->w_flag |= WFHARD;
		/* Look at any window with update flags set on.		*/
		if (wp->w_flag != 0) {
			/* If not force reframe, check the framing.	*/
			if ((wp->w_flag&WFFORCE) == 0) {
				lp = wp->w_linep;
				for (i=0; i<wp->w_ntrows; ++i) {
					if (lp == wp->w_dotp)
						goto out;
					if (lp == wp->w_bufp->b_linep)
						break;
					lp = lforw(lp);
				}
			}
			/* Not acceptable, better compute a new value	*/
			/* for the line at the top of the window. Then  */
			/* set the "WFHARD" flag to force full redraw.  */
			i = wp->w_force;
			if (i > 0) {
				if (i > wp->w_ntrows)
					i = wp->w_ntrows;
				--i;
			} else if (i < 0) {
				i += wp->w_ntrows;
				if (i < 0)
					i = 0;
			} else
				i = wp->w_ntrows/2;
			lp = wp->w_dotp;
			while (i!=0 && lback(lp)!=wp->w_bufp->b_linep) {
				--i;
				lp = lback(lp);
			}
			wp->w_linep = lp;
			wp->w_flag |= WFHARD;	/* Force full.		*/
		out:
			/* mb: put the window offsets in the pscreen[]
				v_col fields for aid in later display.	*/
			lp = wp->w_linep;
			i  = wp->w_toprow;
			while (i < wp->w_toprow+wp->w_ntrows) {
				pscreen[i]->v_col = wp->w_offset;
				lp = lforw(lp);
				++i;
			}

			/* Try to use reduced update. Mode line update  */
			/* has its own special flag. The fast update is */
			/* used if the only thing to do is within the	*/
			/* line editing.				*/
			lp = wp->w_linep;
			i  = wp->w_toprow;
			if ((wp->w_flag&~WFMODE) == WFEDIT) {
				while (lp != wp->w_dotp) {
					++i;
					lp = lforw(lp);
				}
				vtmove(i, 0);
				vp = vscreen[i];
				vp->v_col = 0;
				pvflag = &vp->v_flag;
				*pvflag |= VFCHG;
				*pvflag &= ~VFMOD;
				for (j=0; j<llength(lp); ++j)
					vvtputc(lgetc(lp, j), v);
				vvtputc('\n', v);
				vteeol();
			} else if ((wp->w_flag&(WFEDIT|WFHARD)) != 0) {
				while (i < wp->w_toprow+wp->w_ntrows) {
					vtmove(i, 0);
					vp = vscreen[i];
					vp->v_col = 0;
					pvflag = &vp->v_flag;
					*pvflag |= VFCHG;
					*pvflag &= ~VFMOD;
					if (lp != bp->b_linep) {
					    for (j=0; j<llength(lp); ++j)
					        vvtputc(lgetc(lp, j), v);
					    vvtputc('\n', v);
					    lp = lforw(lp);
					}
					vteeol();
					++i;
				}
			}
#if	WFDEBUG
			/* nothing */
#else
			if ((wp->w_flag&WFMODE) != 0)
				modeline(wp);
			wp->w_flag  = 0;
			wp->w_force = 0;
#endif
		}		
#if	WFDEBUG
		modeline(wp);
		wp->w_flag =  0;
		wp->w_force = 0;
#endif
		wp = wp->w_wndp;
	}

	/* Special hacking if the screen is garbage. Clear the hardware */
	/* screen, and update your copy to agree with it. Set all the	*/
	/* virtual screen change bits, to force a full update.		*/
	if (sgarbf != FALSE) {
		for (i=0; i<term.t_nrow; ++i) {
			vscreen[i]->v_flag |= VFCHG;
			vp = pscreen[i];
			for (j=0; j<term.t_ncol; ++j)
				vp->v_text[j] = ' ';
		}
		movecursor(0, 0);		/* Erase the screen.	*/
		(*term.t_eeop)();
		sgarbf = FALSE;			/* Erase-page clears	*/
		mpresf = FALSE;			/* the message area.	*/
	}

	/* Make sure that the physical and virtual displays agree.	*/
	/* Unlike before, the "updateline" code is only called with a	*/
	/* line that has been updated for sure.				*/
	for (i=0; i<term.t_nrow; ++i) {
		vp = vscreen[i];
		pvflag = &vp->v_flag;
		if ((*pvflag & VFCHG) || wsflag) {
			if ((*term.t_pend)())	/* mb: key pressed?	*/
				break;		/* skip rest of repaint	*/
			*pvflag &= ~VFCHG;
			updateline(i, vp, pscreen[i]);
		}
	}

	/* Need to recompute the cursor row in case of reframe.	*/
	wp = curwp;
	lp = wp->w_linep;
	currow = wp->w_toprow;
	while (lp != wp->w_dotp) {
		++currow;
		lp = lforw(lp);
	}
	/* Finally, update the hardware cursor and flush out buffers.	*/
	movecursor(currow, curcol);
	(*term.t_flush)();
}

/*
 * Update a single line. This
 * does not know how to use insert
 * or delete character sequences; we are
 * using VT52 functionality. Update the physical
 * row and column variables. It does try to
 * exploit erase to end of line.
 * mb: changed calling syntax, added the "offset" business,
 *	and added special treatment for modeline.
 */
updateline(row, vline, pline)
int	row;
VIDEO	*vline, *pline;
{
	register char	*cp1;
	register char	*cp2;
	register char	*cp3;
	register char	*cp5;
	int	 nbflag, modflag, eovlflag;
	char	*vtext, *ptext;
	int	 vmod,   pmod;
	int	 offset, lastcol, ncol;

	vtext = vline->v_text;
	ptext = pline->v_text;
	ncol = term.t_ncol;
	vmod = vline->v_flag & VFMOD;
	pmod = pline->v_flag & VFMOD;
	modflag = (vmod != pmod);
	if (modflag)
		pline->v_flag = vmod;

	if (vmod)
		offset = 0;
	else
		offset = pline->v_col;

	if (offset) {			/* mb: do screen edges */
		if (ptext[0] != '$') {
			movecursor(row, 0);
			(*term.t_putchar)('$');
		}
		ptext[0] = '$';
		cp1 = &vtext[offset];
		cp2 = &ptext[1];
		lastcol = offset + ncol - 1;
	} else {
		cp1 = &vtext[0];
		cp2 = &ptext[0];
		lastcol = ncol;
	}
	if (lastcol > NLINE) {		/* mb: beyond physical end of vline */
		lastcol = NLINE;
		eovlflag = TRUE;
	} else {
		eovlflag = FALSE;
	}

	if (! modflag) {			/* Compute left match.  */

		while (cp1!=&vtext[lastcol] && cp1[0]==cp2[0]) {
			++cp1;
			++cp2;
		}
		if (cp1 == &vtext[lastcol])	/* All equal.	*/
			return;

	/* - can still happen, even though we only call this routine	*/
	/* on changed lines. A hard update is always done when a line	*/
	/* splits, a massive change is done, or a buffer is displayed	*/
	/* twice. This optimizes out most of the excess updating. A lot */
	/* of computes are used, but these tend to be hard operations	*/
	/* that do a lot of update, so I don't really care.		*/

	}

	nbflag = FALSE;
	cp3 = &vtext[lastcol];		/* Compute right match. */
	cp5 = &ptext[ncol];
	if (! modflag) {
		while (cp3[-1] == cp5[-1]) {
			--cp3;
			--cp5;
			if (cp3[0] != ' ')	/* Note if any nonblank */
				nbflag = TRUE;
		}
	}
	cp5 = cp3;
	if (nbflag == FALSE) {			/* Erase to EOL ?	*/
		while (cp5>cp1 && cp5[-1]==' ')
			--cp5;
		if ((int)(cp3-cp5) <= 3)	/* Use only if erase is */
			cp5 = cp3;		/* fewer characters.	*/
	}

	if (vmod)
		(*term.t_hglt)();
	movecursor(row, (int)(cp2-&ptext[0]));  /* Go to first change	*/
	while (cp1 < cp5) {			/* Ordinary.		*/
		(*term.t_putchar)(*cp1);
		++ttcol;
		*cp2++ = *cp1++;
	}
	if (cp5 != cp3 || eovlflag) {		/* Erase.		*/
		(*term.t_eeol)();
		while (cp1 < cp3)
			*cp2++ = *cp1++;
	}
	if (vline->v_col > lastcol) {
		movecursor(row, ncol-1);
		(*term.t_putchar)('$');
		ptext[ncol-1] = '$';
	}
	if (vmod)
		(*term.t_nrml)();
}

/*
 * Redisplay the mode line for
 * the window pointed to by the "wp".
 * This is the only routine that has any idea
 * of how the modeline is formatted.
 * (mb: changed the modeline format.)
 * Called by "update" any time a window is dirty.
 */
modeline(wp)
register WINDOW *wp;
{
	register char	*cp;
	register int	c;
	register int	n;
	register BUFFER *bp;
	int verbose = TRUE;
start:
	n = wp->w_toprow+wp->w_ntrows;		/* Location.		*/
	vscreen[n]->v_flag |= VFCHG | VFMOD;	/* Redraw next time.	*/
	vtmove(n, 0);				/* Seek to right line.  */
	bp = wp->w_bufp;
	if (bp->b_flag & BFEDIT)
		vtputc('+');		/* mb: '+' if in edit mode */
	else
		vtputc('-');
	if (bp->b_flag & BFCHG)		/* '*' if buffer changed. */
		vtputc('*');
	else
		vtputc('-');
	vtputc(' ');
	n = 3;
	if (verbose) {
#if AtST
		cp = "GNOME -- Buffer: ";	/* mb: AtST has 'Help' key */
#endif
#if MSDOS
#if HELP
		cp = "GNOME -- F1 for help -- ";
#else
		cp = "GNOME -- Buffer: ";
#endif
#endif
#if (V7 | VMS | CPM)
#if HELP
		cp = "GNOME -- ESC-? for help -- ";
#else
		cp = "GNOME -- Buffer: ";
#endif
#endif
		n = modeput (cp, n);
	}
	n = modeput (bp->b_bname, n);		/* Buffer name */
	n = modeput (" -- ", n);
	if (bp->b_fname[0] != 0) {		/* File name */
		n = modeput ("File: ", n);
		n = modeput (bp->b_fname, n);
	}
#if  WFDEBUG
	vtputc('-');
	vtputc((wp->w_flag&WFMODE)!=0  ? 'M' : '-');
	vtputc((wp->w_flag&WFHARD)!=0  ? 'H' : '-');
	vtputc((wp->w_flag&WFEDIT)!=0  ? 'E' : '-');
	vtputc((wp->w_flag&WFMOVE)!=0  ? 'V' : '-');
	vtputc((wp->w_flag&WFFORCE)!=0 ? 'F' : '-');
	n += 6;
#endif
	vtputc(' ');
	++n;
	if (n > term.t_ncol) {			/* long pathname */
		verbose = FALSE;
		goto start;
	}
	while (n < term.t_ncol) {		/* Pad to full width.	*/
		vtputc('-');
		++n;
	}
}

int
modeput (cp, n)
	register char *cp;
	int n;
{
	register int c, m;
	m = n;
	while ((c = *cp++) != 0) {
		vtputc(c);
		++m;
	}
	return (m);
}


/*
 * Send a command to the terminal
 * to move the hardware cursor to row "row"
 * and column "col". The row and column arguments
 * are origin 0. Optimize out random calls.
 * Update "ttrow" and "ttcol".
 */
movecursor(row, col)
{
	if (row!=ttrow || col!=ttcol) {
		ttrow = row;
		ttcol = col;
		(*term.t_move)(row, col);
	}
}

/*
 * Erase the message line.
 * This is a special routine because
 * the message line is not considered to be
 * part of the virtual screen. It always works
 * immediately; the terminal buffer is flushed
 * via a call to the flusher.
 */
mlerase()
{
	movecursor(term.t_nrow, 0);
	(*term.t_eeol)();
	(*term.t_flush)();
	mpresf = FALSE;
}

/*
 * Ask a yes or no question in
 * the message line. Return either TRUE,
 * FALSE, or ABORT. The ABORT status is returned
 * if the user bumps out of the question with
 * a ^G. Used any time a confirmation is
 * required. mb: modified so cr unneeded.
 */
mlyesno(prompt)
char	*prompt;
{
	register int	c;
	register int	s;
	char		buf[64];

	for (;;) {
		strcpy(buf, prompt);
		strcat(buf, " [y/n]? ");
		mlwrite(buf);
		c = getkey();
		if (c=='y' || c=='Y')
			return (TRUE);
		if (c=='n' || c=='N')
			return (FALSE);
		if (c==(CNTL|'G'))
			return (ABORT);
		if (c == METACH)
			return (ABORT);
#if AtST
		if (c==(FUNC|0x61))
			return (ABORT);
#endif
#if MSDOS
		if (c==(FUNC|0x3C))
			return (ABORT);
#endif
		/* else repeat */
	}
}

/*
 * Write a prompt into the message
 * line, then read back a response. Keep
 * track of the physical position of the cursor.
 * If we are in a keyboard macro throw the prompt
 * away, and return the remembered response. This
 * lets macros run at full speed. The reply is
 * terminated by a newline (\n or \r) only.
 * mb: completely rewritten and calling syntax changed!
 */
int
mlreply(prompt, dflt, buf, width, doesc)
	char	*prompt, *dflt, *buf;
	int	width, doesc;
{
	register int  c, i, j;
	register char *p1, *p2;
	int cpos, col, row, fresh, escmode, tmp;
	int (*tputc)();
	extern int getkey();

	tputc = term.t_putchar;

	i = 0;
	if (kbdmop != NULL) {
		do {
			c = *kbdmop++;
			buf[i++] = c;
		} while (c != '\0');
		return (TRUE);
	}

	i = term.t_ncol - 1 - strlen(prompt);
	if (width > i)	width = i;
	width -= 3;
start:
	mlwrite (prompt);
	(*tputc)(':');
	(*tputc)(' ');
	ttcol += 2;
	col = ttcol;
	row = ttrow;
	fresh = TRUE;
	escmode = FALSE;
	p1 = buf;
	p2 = dflt;
	if (p2 != NULL) {
		i = 0;
		while ((c=(*p2++))!='\0' && (i++)<=width) {
			*p1++ = c;
			mlputc(c);
		}
	}
	(*term.t_eeol)();
	while (i++ <= width)
		*p1++ = '\0';
	i = 0;
loop:
	(*term.t_move)(row, col+i);
	(*term.t_flush)();
	c = getkey();
#if VT100
	if (c=='\\' && doesc && !escmode) {
			c = getkey();
			escmode = TRUE;
			goto verbatim;
	}
	if (c==METACH && !escmode) {
		c = getkey();
		if (c=='[' || c=='O') {
			c = escseq(c);
			if (c!=UP && c!=DOWN && c!=LEFT && c!=RIGHT)
				c = getkey();
		} else if (c == '?') {
			return (ABORT);
		} else if (doesc) {
			escmode = TRUE;
			goto verbatim;
		}
	}
#else
	if ((c=='\\' || c==METACH) && doesc && !escmode) {
		c = getkey();
		escmode = TRUE;
		goto verbatim;
	}
#endif
	if (c == METACH && ! doesc)
		return (ABORT);
#if	AtST
	if (c==(CNTL|'G') || c==(FUNC|0x61)	/* Undo, abort */
	    || c==(CNTL|'C') || c==(FUNC|0x62))	/* Help */
#endif
#if	MSDOS
	if (c==(CNTL|'G') || c==(FUNC|0x3C)	/* Undo (F2) */
	    || c==(CNTL|'C') || c==(FUNC|0x3B))	/* Help (F1) */
#endif
#if (V7 | VMS | CPM)
	if (c == (CNTL|'G') || c==(CNTL|'C'))	/* Bell, abort */
#endif
		return (ABORT);

	if (c == CANCEL)
		goto start;
#if AtST
	if (c == (FUNC|0x47))			/* Clr/Home */
		goto start;
#endif
#if MSDOS
	if (c == (FUNC|0x52))			/* Insert */
		goto start;
#endif

	if (c==(CNTL|'M') || c==(CNTL|'J')) {	/* <Return> */
		if (buf[0] == '\0')
			return (ABORT);
		if (kbdmip != NULL) {
			if (kbdmip+i > &kbdm[NKBDM-3])
				return(ctrlg());
			for (j=0; (c=buf[j])!='\0'; j++)
				*kbdmip++ = buf[j] & 0xFF;
			*kbdmip++ = '\0';
		}
		(*tputc)('\r');
		ttcol = 0;
		(*term.t_flush)();
		if (fresh)
			return (FALSE);
		else
			return (TRUE);
	}

	if (c==UP || c==DOWN)
		return (c);
#if (AtST | MSDOS)
	if (c==(FUNC|0x48))
		return (UP);
	if (c==(FUNC|0x50))
		return (DOWN);
#endif
#if (AtST | MSDOS)
	if (c==RIGHT || c==(FUNC|0x4D)) {
#else
	if (c == RIGHT) {
#endif
		fresh = FALSE;
		if (i<width && buf[i]!='\0') {
			c = buf[i] & 0xFF;
			if ((c<0x20 || c==0x7F) && c!=ANYCHAR && c!=NEGCHAR)
				++col;
			++i;
		}
		goto loop;
	}
#if (AtST | MSDOS)
	if (c==LEFT || c==(FUNC|0x4B)) {
#else
	if (c == LEFT) {
#endif
		fresh = FALSE;
		if (i > 0) {
			--i;
			c = buf[i] & 0xFF;
			if ((c<0x20 || c==0x7F) && c!=ANYCHAR && c!=NEGCHAR)
				--col;
		}
		goto loop;
	}
#if AtST
	if (c==(CNTL|'A') || c==(FUNC|SHFT|0x73)) {
#endif
#if MSDOS
	if (c==(CNTL|'A') || c==(FUNC|0x47)) {
#endif
#if (V7 | VMS | CPM)
	if (c==(CNTL|'A')) {
#endif
		i = 0;
		col = ttcol;
		goto loop;
	}
#if AtST
	if (c==(CNTL|'E') || c==(FUNC|SHFT|0x74)) {
#endif
#if MSDOS
	if (c==(CNTL|'E') || c==(FUNC|0x4F)) {
#endif
#if (V7 | VMS | CPM)
	if (c==(CNTL|'E')) {
#endif
		p1 = &buf[0];
		i = 0;
		col = ttcol;
		while (i < width && (c=(*p1)&0xFF) != '\0') {
			++p1;
			++i;
			if ((c<0x20 || c==0x7F) && c!=ANYCHAR && c!=NEGCHAR)
				++col;
		}
		goto loop;
	}
#if AtST
	if (c==(FUNC|0x0E) || (deldir && c==(FUNC|0x53))) {	/* BS */
#endif
#if MSDOS
	if (c==(CNTL|'H') || (deldir && c==(FUNC|0x53))) {	/* BS */
#endif
#if (V7 | VMS | CPM)
	if (c==(CNTL|'H') || (deldir && c==(CNTL|0x3F))) {	/* BS */
#endif
		if (i > 0) {
			--i;
			j = buf[i] & 0xFF;
			if ((j<0x20 || j==0x7F) && j!=ANYCHAR && j!=NEGCHAR)
				--col;
			/* DON'T goto loop yet! */
		} else
			goto start;
	}
#if AtST
	if (c==(FUNC|0x53) || c==(CNTL|'D') || c==(FUNC|0x0E)) {
#endif
#if MSDOS
	if (c==(FUNC|0x53) || c==(CNTL|'D') || c==(CNTL|'H')) {
#endif
#if (V7 | VMS | CPM)
	if (c==(CNTL|0x3F) || c==(CNTL|'D') || c==(CNTL|'H')) {
#endif
		fresh = FALSE;
		p1 = &buf[i];
		p2 = p1 + 1;
		(*term.t_move)(row, col+i);
		while (*p2 != '\0') {
			mlputc(*p2);
			*p1++ = *p2++;
		}
		(*term.t_eeol)();
		*p1 = '\0';
		goto loop;
	}
#if AtST
	if (c==(CNTL|'K') || c==(FUNC|0x3E) || c==(FUNC|SHFT|0x53)) {
#endif
#if MSDOS
	if (c==(CNTL|'K') || c==(FUNC|0x3F)) {
#endif
#if (V7 | VMS | CPM)
	if (c == (CNTL|'K')) {
#endif
		fresh = FALSE;
		j = i;
		while (j<=width && buf[j]!='\0')
			buf[j++] = '\0';
		(*term.t_eeol)();
		goto loop;
	}

verbatim:
	if (fresh && i==0) {
		j = i;
		while (j<=width && buf[j]!='\0')
			buf[j++] = '\0';
		(*term.t_eeol)();
	}
	fresh = FALSE;
	if (c & CNTL) {
		if (!doesc)
			goto loop;
		c &= 0xFF;
		c ^= 0x40;
		if (c == '\r')
			c = '\n';
	}
	if (doesc && !escmode) {
		if (c == 0x17)			/* CNTL|'W' */
			c = WHITESPACE;
		else if (c == '.')
			c = ANYCHAR;
		else if (c == '!')
			c = NEGCHAR;
	}
	escmode = FALSE;		
	if (i < width) {
		col += mlputc(c);
		p1 = &buf[i];
		p2 = p1;
		j = i;
		while (j++ < width && *p2++ != '\0')
			;
		while (p2 != p1) {
			p2[0] = p2[-1];
			--p2;
		}
		*p2++ = c;
		while (*p2 != '\0')
			mlputc(*p2++);
		++i;
		goto loop;
	}
	goto loop;
}

int
mlputc(c)
	register int c;
{
	register int t, i;
	int (*tputc)();
	tputc = term.t_putchar;
	c &= 0xFF;
	t = c;
	i = 0;
	if (c == '\n') {
		(*tputc)('<');
		t = '<';
		i = 1;
	} else if (c == '\t') {
		(*tputc)('>');
		t = '>';
		i = 1;
	} else if (c == WHITESPACE) {
		(*tputc)('_');
		t = '_';
		i = 1;
	} else if (c == ANYCHAR) {
		t = '.';
	} else if (c == NEGCHAR) {
		t = '!';
	} else if (c<0x20 || c==0x7F) {
		(*tputc)('^');
		t ^= 0x40;
		i = 1;
	}
	(*tputc)(t);
	return (i);
}

/*
 * Write a message into the message
 * line. Keep track of the physical cursor
 * position. A small class of printf like format
 * items is handled. Assumes the stack grows
 * down; this assumption is made by the "++"
 * in the argument scan loop. Set the "message
 * line" flag TRUE.
 */
mlwrite(fmt, arg)
	char	*fmt;
{
	register int	c;
	register char	*ap;

	if (playback == TRUE) {
		if (strcmp (fmt, "[Playback in progress...]") != 0)
			return;
	}

	movecursor(term.t_nrow, 0);
	ap = (char *) &arg;
	while ((c = *fmt++) != 0) {
		if (c != '%') {
			(*term.t_putchar)(c);
			++ttcol;
		} else {
			c = *fmt++;
			switch (c) {
			case 'd':
				mlputi(*(int *)ap, 10);
				ap += sizeof(int);
				break;

			case 'x':
				mlputi(*(int *)ap, 16);
				ap += sizeof(int);
				break;

			case 'D':
				mlputli(*(long *)ap, 10);
				ap += sizeof(long);
				break;

			case 's':
				mlputs(*(char **)ap);
				ap += sizeof(char *);
				break;

			default:
				(*term.t_putchar)(c);
				++ttcol;
			}
		}
	}
	(*term.t_eeol)();
	(*term.t_flush)();
	mpresf = TRUE;
}

/*
 * Write out a string.  Update the physical cursor position.
 * This assumes that the characters in the
 * string all have width "1"; if this is not
 * the case things will get messed up a little.
 */
mlputs(s)
register char	*s;
{
	register int	c;

	while ((c = *s++) != 0) {
		(*term.t_putchar)(c);
		++ttcol;
	}
}

/*
 * Write out an integer, in
 * the specified radix. Update the physical
 * cursor position. This will not handle any
 * negative numbers; maybe it should.
 */
mlputi(i, r)
{
	register int	q;
	static char hexdigits[] = "0123456789ABCDEF";

	if (i < 0) {
		i = -i;
		(*term.t_putchar)('-');
	}
	q = i/r;
	if (q != 0)
		mlputi(q, r);
	(*term.t_putchar)(hexdigits[i%r]);
	++ttcol;
}

/*
 * do the same except as a long integer.
 */
mlputli(l, r)
long l;
{
	register long q;

	if (l < 0) {
		l = -l;
		(*term.t_putchar)('-');
	}
	q = l/r;
	if (q != 0)
		mlputli(q, r);
	(*term.t_putchar)((int)(l%r)+'0');
	++ttcol;
}
