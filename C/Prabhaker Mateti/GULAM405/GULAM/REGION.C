/*

region.c -- The routines in this file deal with the region, that
magic space between dot and mark.  */

#include        "ue.h"

/* Determine the bounds of the region in the current window, and fill
in the fields of the REGION structure pointed to by rp.  Because the
dot and mark are usually very close together, we scan outward from dot
looking for mark.  This should save time.  Return a standard code.  */

	int
getregion(rp)
REGION *rp;
{
        register LINE   *flp, *blp, *lastp;
        register int    fsize, bsize;

	if (curwp->w_markp == NULL)
	{	mlwrite("No mark set in this window");
		return FALSE;
	}
	if (curwp->w_dotp == curwp->w_markp)
	{	rp->r_linep = curwp->w_dotp;
		if (curwp->w_doto < curwp->w_marko) {
			rp->r_offset = curwp->w_doto;
			rp->r_size = curwp->w_marko-curwp->w_doto;
                } else {
			rp->r_offset = curwp->w_marko;
			rp->r_size = curwp->w_doto-curwp->w_marko;
		}
		return (TRUE);
	}
	flp = blp = curwp->w_dotp;  lastp = curbp->b_linep;
	bsize = curwp->w_doto;  fsize = llength(flp) - bsize + 1;
	while (flp != lastp || lback(blp) != lastp)
	{	if (flp != lastp)
		{	flp = lforw(flp);
			if (flp == curwp->w_markp)
			{	rp->r_linep = curwp->w_dotp;
				rp->r_offset = curwp->w_doto;
				rp->r_size = fsize+curwp->w_marko;
				return TRUE;
			}
			fsize += llength(flp) + 1;
		}
		if (lback(blp) != lastp)
		{	blp = lback(blp);
			bsize += llength(blp)+1;
			if (blp == curwp->w_markp)
			{	rp->r_linep = blp;
				rp->r_offset = curwp->w_marko;
				rp->r_size = bsize - curwp->w_marko;
				return TRUE;
	}	}	}
	mlwrite("Bug: lost mark");
	return FALSE;
}

/* Kill the region.  Ask getregion() to figure out the bounds of the
region.  Move dot to the start, and kill the characters.  Bound to
"C-W".  */

killregion(f, n, kk)
{
        register int    s;
        REGION          region;

	s = getregion(&region); if (s != TRUE)  return s;
        if ((lastflag&CFKILL) == 0) kdelete();
        thisflag |= CFKILL;
        curwp->w_dotp = region.r_linep;
        curwp->w_doto = region.r_offset;
        return ldelete(region.r_size, KFORW);
}

/* Copy all of the characters in the region to the kill buffer.  Don't
move dot at all.  This is a bit like a kill region followed by a yank.
Bound to "M-W".  */

copyregion()
{
        register LINE   *linep;
        register int    loffs, s;
        REGION          region;

	s = getregion(&region); if (s != TRUE)  return s;
        if ((lastflag&CFKILL) == 0) kdelete();
        thisflag |= CFKILL;
        linep = region.r_linep;                 /* Current line.        */
        loffs = region.r_offset;                /* Current offset.      */
        while (region.r_size--)
	{	if (loffs == llength(linep))	/* End of line.         */
		{	s = kinsert('\n', KFORW); if (s != TRUE) return s;
                        linep = lforw(linep);
                        loffs = 0;
                } else				/* Middle of line.      */
		{	s = kinsert(lgetc(linep, loffs), KFORW);
			if (s != TRUE) return s;
                        ++loffs;
                }
        }
        return TRUE;
}

/* -eof- */
