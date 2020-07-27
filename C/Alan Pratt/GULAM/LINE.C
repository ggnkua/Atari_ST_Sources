/* line.c of ue in gulam -- part of original microEmacs

The functions in this file are a general set of line management
utilities.  They also touch the buffer and window structures, to make
sure that the necessary updating gets done.  There are routines in
this file that handle the kill buffer too.  These are here for no good
reason.

Note that this code only updates the dot and mark values in the window
list.  Since all the code acts on the current window, the buffer that
we are editing must be being displayed, which means that "b_nwnd" is
non zero, which means that the dot and mark values in the buffer
headers are nonsense.

A line may 'belong' to more than one window, but never to more than one buffer.
*/


#include        "ue.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local kgrow P_((int back));
#undef P_

#define KBLOCK  256                     /* Kill buffer block size       */

local		kgrow();
local char	*kbufp	= NULL;		/* Kill buffer data.		*/
local RSIZE	kused	= 0;		/* # of bytes used in KB.	*/
local RSIZE	ksize	= 0;		/* # of bytes allocated in KB.	*/
local RSIZE	kstart  = 0;		/* # of first used byte in KB.	*/

/* This routine allocates a block of memory large enough to hold a
LINE containing "used" characters.  The block is always rounded up a
bit.  Return a pointer to the new block, or NULL if there isn't any
memory left.  Print a message in the message line if no space.  (pm:
We allocate one more byte for the \0; see makelnstr() of misc.c.) */

	LINE    *
lalloc(used)
register int	used;
{
        register LINE   *lp;
        register int	size;

	size = used;
	if (size < 4) size = 4; /* Assume that an empty line is for type-in. */
	if (lp = (LINE *) malloc(1+((uint)sizeof(LINE))+size))
		{ /* lp->l_zsize = size; **/ lp->l_used = used;}
	else	mlwrite("Could not allocate %d bytes for a line", size);
	return lp;
}

/* Link a line at lx.  The content is given by nb bytes beginning at q.
*/
	LINE *
lnlink(lx, q, nb)
register LINE	*lx;
	uchar	*q;
register int	nb;
{	register LINE	*ly, *lz;
	
	if (ly = lalloc(nb))
	{	cpymem(ly->l_text, q, nb);
		lz       = lx->l_bp;
		lz->l_fp = ly;
		ly->l_bp = lz;
		lx->l_bp = ly;
		ly->l_fp = lx;
	}
	return ly;
}

/* Delete line "lp".  Fix all of the links that might point at it
(they are moved to offset 0 of the next line.  Unlink the line from
whatever buffer it might be in.  Release the memory.  The buffers are
updated too.  */

lfree(lp)
register LINE   *lp;
{
        register BUFFER *bp;
        register WINDOW *wp;

	for (wp = wheadp;  wp; wp = wp->w_wndp)
	{  if (wp->w_linep == lp) {wp->w_linep = lp->l_fp;}
	   if (wp->w_dotp  == lp) {wp->w_dotp  = lp->l_fp; wp->w_doto  = 0;}
 	   if (wp->w_markp == lp) {wp->w_markp = lp->l_fp; wp->w_marko = 0;}
        }
	for (bp = bheadp; bp; bp = bp->b_bufp)
	{  if (bp->b_nwnd == 0)
	   {	if (bp->b_dotp  == lp) {bp->b_dotp = lp->l_fp; bp->b_doto = 0;}
		if (bp->b_markp == lp) {bp->b_markp= lp->l_fp; bp->b_marko= 0;}
	}  }
        lp->l_bp->l_fp = lp->l_fp;
        lp->l_fp->l_bp = lp->l_bp;
        free((char *) lp);
}

/* This routine gets called when a character is changed in place in
the buffer bp.  It updates all of the required flags in the buffer and
window system.  The flag used is passed as an argument; if the buffer
is being displayed in more than 1 window we change EDIT t HARD.  Set
MODE if the mode line needs to be updated (the "*" has to be set).  */

lbpchange(bp, flag)
register BUFFER	*bp;
register int    flag;
{
        register WINDOW *wp;

        if (bp->b_nwnd != 1) 			/* Ensure hard.         */
                flag = WFHARD;
        if ((bp->b_flag&BFCHG) == 0) 		/* First change, so     */
 	{	flag |= WFMODE;                 /* update mode lines.   */
 		bp->b_flag |= BFCHG;
        }
 	for (wp = wheadp; wp; wp = wp->w_wndp)
		if (wp->w_bufp == bp)  wp->w_flag |= flag;
}


lchange(flag)	{lbpchange(curbp, flag);}

/* Insert "n" copies of the character "c" at the current location of
dot.  In the easy case all that happens is the text is stored in the
line.  In the hard case, the line has to be reallocated.  When the
window list is updated, take special care; I screwed it up once.  You
always update dot in the current window.  You update mark, and a dot
in another window, if it is greater than the place where you did the
insert.  Return TRUE if all is well, and FALSE on errors.  */

linsert(n, c)
{
	register LINE   *lp1, *lp2;
	register char   *cp1;
	register LINE   *lp3;
	register char   *cp2;
        register int    doto, i;
        register WINDOW *wp;

        lchange(WFEDIT);
        lp1 = curwp->w_dotp;                    /* Current line         */
        if (lp1 == curbp->b_linep)		/* At the end: special  */
	{	if (curwp->w_doto != 0)
			{mlwrite("bug: linsert"); return FALSE;}
                if ((lp2=lalloc(n)) == NULL) return FALSE;
                lp3 = lp1->l_bp;
		lp3->l_fp = lp2; 	lp2->l_fp = lp1;
		lp1->l_bp = lp2; 	lp2->l_bp = lp3;
		curwp->w_dotp = lp2;	curwp->w_doto = n;
		for (cp1 = lp2->l_text; n--;) *cp1++ = c;
                return TRUE;
        }
        doto = curwp->w_doto;                   /* Save for later.      */
        if (lp1->l_used + n > lsize(lp1))	/* Hard: reallocate     */
	{	if ((lp2=lalloc(lp1->l_used+n)) == NULL) return FALSE;
		cpymem(lp2->l_text, lp1->l_text, lp1->l_used);
                lp1->l_bp->l_fp = lp2; lp2->l_fp = lp1->l_fp;
                lp1->l_fp->l_bp = lp2; lp2->l_bp = lp1->l_bp;
                free((char *) lp1);
        } else	{lp1->l_used += n; lp2 = lp1;}
	for (cp2 = &lp2->l_text[lp2->l_used],
		cp1 = cp2-n; cp1 != &lp2->l_text[doto];) *--cp2 = *--cp1;
        for (i=0; i<n; ++i) *cp1++ = c;
	for (wp = wheadp; wp; wp = wp->w_wndp)
	{	if (wp->w_linep == lp1) wp->w_linep = lp2;
                if (wp->w_dotp == lp1)
		{	wp->w_dotp = lp2;
 			if (wp == curwp || wp->w_doto > doto) wp->w_doto += n;
                }
                if (wp->w_markp == lp1)
		{	wp->w_markp = lp2;
			if (wp->w_marko > doto) wp->w_marko += n;
	}	}
        return TRUE;
}

/* Insert a newline into the buffer at the current location of dot in
the current window.  The funny ass-backwards way it does things is not
a botch; it just makes the last line in the file not a special case.
Return TRUE if everything works out and FALSE on error (memory
allocation failure).  The update of dot and mark is a bit easier then
in the above case, because the split forces more updating.  */

lnewline()
{
        register char   *cp1;
        register char   *cp2;
        register LINE   *lp1;
        register LINE   *lp2;
        register int    doto;
        register WINDOW *wp;

        lchange(WFHARD);
        lp1  = curwp->w_dotp;                   /* Get the address and  */
        doto = curwp->w_doto;                   /* offset of "."        */
        if ((lp2=lalloc(doto)) == NULL)         /* New first half line  */
                return FALSE;
        cp1 = &lp1->l_text[0];                  /* Shuffle text around  */
        cp2 = &lp2->l_text[0];
        while (cp1 != &lp1->l_text[doto])
                *cp2++ = *cp1++;
        cp2 = &lp1->l_text[0];
        while (cp1 != &lp1->l_text[lp1->l_used])
                *cp2++ = *cp1++;
        lp1->l_used -= doto;
        lp2->l_bp = lp1->l_bp;
        lp1->l_bp = lp2;
        lp2->l_bp->l_fp = lp2;
        lp2->l_fp = lp1;
        wp = wheadp;                            /* Windows              */
        while (wp != NULL) {
                if (wp->w_linep == lp1)
                        wp->w_linep = lp2;
                if (wp->w_dotp == lp1) {
                        if (wp->w_doto < doto)
                                wp->w_dotp = lp2;
                        else
                                wp->w_doto -= doto;
                }
                if (wp->w_markp == lp1) {
                        if (wp->w_marko < doto)
                                wp->w_markp = lp2;
                        else
                                wp->w_marko -= doto;
                }
                wp = wp->w_wndp;
        }       
        return TRUE;
}

/* This function deletes n bytes, starting at dot; n >= 0.  It understands
how do deal with end of lines, etc.  It returns TRUE if all of the
characters were deleted, and FALSE if they were not (because dot ran
into the end of the buffer.  The "kflag" indicates either no
insertion, or direction of insertion into the kill buffer.  */

ldelete(n, kflag)
RSIZE n;
{
	register char	*cp1, *cp2;
	register LINE	*dotp;
	register RSIZE	doto, chunk;
	register WINDOW	*wp;

	/*
	 * HACK - doesn't matter, and fixes back-over-nl bug for empty
	 *	kill buffers.
	 */
	if (kused == kstart) kflag = KFORW;

	while (n > 0)
	{	dotp = curwp->w_dotp; doto = curwp->w_doto;
		if (dotp == curbp->b_linep) return FALSE;
		chunk = dotp->l_used - doto;	/* Size of chunk.	*/
		if (chunk > n) chunk = n;
		if (chunk == 0)			/* End of line, merge.	*/
		{	lchange(WFHARD);
			if (ldelnewline() == FALSE
			|| (kflag!=KNONE && kinsert('\n', kflag)==FALSE))
				return FALSE;
			--n;
			continue;
		}
		lchange(WFEDIT);
		cp1 = &dotp->l_text[doto]; cp2 = cp1 + chunk;
		if (kflag == KFORW)
		{	while (ksize - kused < chunk)
				if (kgrow(FALSE) == FALSE) return FALSE;
			cpymem(&(kbufp[kused]), cp1, (int) chunk);
			kused += chunk;
		} else if (kflag == KBACK) {
			while (kstart < chunk)
				if (kgrow(TRUE) == FALSE) return FALSE;
			cpymem(&(kbufp[kstart-chunk]), cp1, (int) chunk);
			kstart -= chunk;
		}
		while (cp2 != &dotp->l_text[dotp->l_used])
			*cp1++ = *cp2++;
		dotp->l_used -= chunk;
		for (wp = wheadp; wp; wp = wp->w_wndp)
		{	if (wp->w_dotp==dotp && wp->w_doto>=doto)
			{	wp->w_doto -= chunk;
				if (wp->w_doto < doto) wp->w_doto = doto;
			}	
			if (wp->w_markp==dotp && wp->w_marko>=doto)
			{	wp->w_marko -= chunk;
				if (wp->w_marko < doto) wp->w_marko = doto;
		}	}
		n -= chunk;
	}
	return TRUE;
}

/* Delete a newline.  Join the current line with the next line.  If
the next line is the magic header line always return TRUE; merging the
last line with the header line can be thought of as always being a
successful operation, even if nothing is done, and this makes the kill
buffer work "right".  Easy cases can be done by shuffling data around.
Hard cases require that lines be moved about in memory.  Return FALSE
on error and TRUE if all looks ok.  Called by "ldelete" only.  */

ldelnewline()
{
        register char   *cp1;
        register char   *cp2;
        register LINE   *lp1;
        register LINE   *lp2;
        register LINE   *lp3;
        register WINDOW *wp;

        lp1 = curwp->w_dotp;
        lp2 = lp1->l_fp;
        if (lp2 == curbp->b_linep)		/* At the buffer end.   */
	{	if (lp1->l_used == 0)           /* Blank line.          */
                        lfree(lp1);
                return TRUE;
        }
        if (lp2->l_used <= lsize(lp1) - lp1->l_used)
	{	cpymem(&lp1->l_text[lp1->l_used], lp2->l_text, lp2->l_used);
                for (wp = wheadp; wp; wp = wp->w_wndp)
		{	if (wp->w_linep == lp2) wp->w_linep = lp1;
                        if (wp->w_dotp == lp2)
			{	wp->w_dotp  = lp1;
                                wp->w_doto += lp1->l_used;
                        }
                        if (wp->w_markp == lp2)
			{	wp->w_markp  = lp1;
                                wp->w_marko += lp1->l_used;
		}	}
                lp1->l_used += lp2->l_used;
                lp1->l_fp = lp2->l_fp;
                lp2->l_fp->l_bp = lp1;
                free((char *) lp2);
                return TRUE;
        }
        if ((lp3=lalloc(lp1->l_used+lp2->l_used)) == NULL)
                return FALSE;
        cp1 = &lp1->l_text[0];
        cp2 = &lp3->l_text[0];
        while (cp1 != &lp1->l_text[lp1->l_used])
                *cp2++ = *cp1++;
        cp1 = &lp2->l_text[0];
        while (cp1 != &lp2->l_text[lp2->l_used])
                *cp2++ = *cp1++;
        lp1->l_bp->l_fp = lp3;
        lp3->l_fp = lp2->l_fp;
        lp2->l_fp->l_bp = lp3;
        lp3->l_bp = lp1->l_bp;
	for (wp = wheadp; wp; wp = wp->w_wndp)
	{ if (wp->w_linep==lp1 || wp->w_linep==lp2) wp->w_linep = lp3;
	  if (wp->w_dotp == lp1) {wp->w_dotp = lp3; }   else
	  if (wp->w_dotp == lp2) {wp->w_dotp = lp3; wp->w_doto += lp1->l_used;}
	  if (wp->w_markp== lp1) {wp->w_markp= lp3; }   else
	  if (wp->w_markp== lp2) {wp->w_markp= lp3; wp->w_marko+= lp1->l_used;}
        }
        free((char *) lp1);
        free((char *) lp2);
        return TRUE;
}

/* Delete all of the text saved in the kill buffer.  Called by
commands when a new kill context is being created.  The kill buffer
array is released, just in case the buffer has grown to immense size.
No errors.  */

kdelete()
{
        if (kbufp)
	{	free((char *) kbufp);
		kbufp = NULL;
		kstart = kused = ksize = 0;
        }
}

/* Insert a character to the kill buffer, enlarging the buffer if
there isn't any room.  Always grow the buffer in chunks, on the
assumption that if you put something in the kill buffer you are going
to put more stuff there too later.  Return TRUE if all is well, and
FALSE on errors.  Dir says whether to put it at back or front.  */

kinsert(c, dir)
register int	c, dir;
{
	if (dir == KBACK)
	{	if (kstart == 0 && kgrow(TRUE)  == FALSE) return FALSE;
		kbufp[--kstart] = c;
	}
	else
	{	if (kused  == ksize && kgrow(FALSE) == FALSE) return FALSE;
		kbufp[kused++] = c;
	}
	return TRUE;
}

/* This function gets characters from the kill buffer.  If the
character index "n" is off the end, it returns "-1".  This lets the
caller just scan along until it gets a "-1" back.  */

kremove(n)
register int	n;
{	if (n < 0 || n + kstart >= kused) return (-1);
	return (kbufp[n + kstart] & 0xFF);
}

/* Get more kill buffer for the callee.  back is true if we are trying
to get space at the beginning of the kill buffer.  */
	local
kgrow(back)
register int	back;
{	register int	nstart;
	register char	*nbufp;

	nbufp = malloc(ksize + KBLOCK);
	if (nbufp == NULL)
	{	mlwrite("Can't get %d bytes for killbuf", ksize + KBLOCK);
		return FALSE;
	}
	nstart = (back == TRUE) ? (kstart + KBLOCK) : (KBLOCK / 4) ;
	if (kbufp)
	{  cpymem(&(nbufp[nstart]), &(kbufp[kstart]),  (int) (kused-kstart));
	   free((char *) kbufp);
	}
	kbufp  = nbufp;
	ksize += KBLOCK;
	kused = kused - kstart + nstart;
	kstart = nstart;
	return TRUE;
}


/* -eof- */
