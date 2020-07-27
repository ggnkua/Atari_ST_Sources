/*  Window management of microEmacs.

pm: Windows are singly-linked.  Wheadp pts to the first window, mlwp to the
last window, the message-line-window.  Curwp pts to one of the windows on this
list.  Wheadp and mlwp are never NULL, and
wheadp never == mlwp.  The sum of the heights (incl mode lines) of all
windows == terminal.nrows
*/

#include        "ue.h"

WINDOW  *curwp;                         /* Current window               */
WINDOW	*mlwp;				/* message line window		*/
WINDOW  *wheadp; 			/* WINDOW listhead              */

wupdatemodeline(bp)			/* Update mode lines		*/
register BUFFER	*bp;
{	register WINDOW *wp;

	for (wp = wheadp; wp; wp = wp->w_wndp)
		if (bp == NULL || wp->w_bufp == bp) wp->w_flag |= WFMODE;
}

/*
 * Reposition dot in the current window to line "n". If the argument is
 * positive, it is that line. If it is negative it is that line from the
 * bottom. If it is 0 the window is centered (this is what the standard
 * redisplay code does). With no argument it defaults to 1. Bound to M-!.
 * Because of the default, it works like in Gosling.
 */
reposition(f, n)
    {
    curwp->w_force = n;
    curwp->w_flag |= WFFORCE;
    return (TRUE);
    }

switchwindow(wp)			/* pm */
register WINDOW *wp;
{
    if (wp == NULL) wp = wheadp;	/* wheadp is never == NULL */
    curwp = wp;
    curbp = wp->w_bufp;
    return TRUE;
}
/*
 * The command make the next window (next => down the screen) the current
 * window. There are no real errors, although the command does nothing if
 * there is only 1 window on the screen. Bound to "C-X C-N".
 */
nextwind()
{
	if (curwp->w_wndp == mlwp) curwp = mlwp;
	return (switchwindow(curwp->w_wndp));
}

	local WINDOW *
predwp(wp)
register WINDOW *wp;
{ 	register WINDOW *wp1;

	if (wheadp == mlwp) return NULL;
 	if (wheadp == wp)  wp = mlwp;
	for (wp1 = wheadp; wp1->w_wndp != wp;) wp1 = wp1->w_wndp;
 	return wp1;
}

/*
 * This command makes the previous window (previous => up the screen) the
 * current window. There arn't any errors, although the command does not do a
 * lot if there is 1 window.
 */
prevwind()
{
    return (switchwindow(predwp(curwp)));
}

/*
 * This command moves the current window down by "arg" lines. Recompute the
 * top line in the window. The move up and move down code is almost completely
 * the same; most of the work has to do with reframing the window, and picking
 * a new dot. We share the code by having "move down" just be an interface to
 * "move up". Magic. Bound to "C-X C-N".
 */
mvdnwind(f, n)
register int n;
{
    return (mvupwind(f, -n));
}

/*
 * Move the current window up by "arg" lines. Recompute the new top line of
 * the window. Look to see if "." is still on the screen. If it is, you win.
 * If it isn't, then move "." to center it in the new framing of the window
 * (this command does not really move "."; it moves the frame). Bound to
 * "C-X C-P".
 */
mvupwind(f, n, kk)
register int n;
{
    register LINE *lp;
    register int i;

    lp = curwp->w_linep;

    if (n < 0)
        {
        while (n++ && lp!=curbp->b_linep)
            lp = lforw(lp);
        }
    else
        {
        while (n-- && lback(lp)!=curbp->b_linep)
            lp = lback(lp);
        }

    curwp->w_linep = lp;
    curwp->w_flag |= WFHARD;            /* Mode line is OK. */

    for (i = 0; i < curwp->w_ntrows; ++i)
        {
        if (lp == curwp->w_dotp)
            return (TRUE);
        if (lp == curbp->b_linep)
            break;
        lp = lforw(lp);
        }

    lp = curwp->w_linep;
    i  = curwp->w_ntrows/2;

    while (i-- && lp != curbp->b_linep)
        lp = lforw(lp);

    curwp->w_dotp  = lp;
    curwp->w_doto  = 0;
    return (TRUE);
}

/* Delete a window.  wp != curwp && wp != mlwp.
*/
killwindow(wp)
register WINDOW *wp;
{	register WINDOW *wp1;


	wp1 = (wp? predwp(wp) : NULL);
	if (wp1)
	{	if (wp1 == mlwp)
		{	if (curwp == wheadp) curwp = wp->w_wndp;
			wheadp = wp->w_wndp;
		}
		else wp1->w_wndp = wp->w_wndp;
		wp1->w_flag  |= WFMODE|WFHARD;
		wp1->w_ntrows += 1 + wp->w_ntrows;
                if (--wp->w_bufp->b_nwnd == 0)	bwdotmark(wp->w_bufp, wp);
                free((char *) wp);
	}
}

/*
 * This command makes the current window the only window on the screen. Bound
 * to "C-X 1". Try to set the framing so that "." does not have to move on the
 * display. Some care has to be taken to keep the values of dot and mark in
 * the buffer structures right if the destruction of a window makes a buffer
 * become undisplayed.
 */
onlywind()					/* rewritten by pm */
{
        register WINDOW *wp, *wp2;
        register LINE   *lp;
        register int    i;

	for (wp = wheadp; wp; wp = wp2)
	{	wp2 = wp->w_wndp;
		if (wp == curwp || wp == mlwp) continue;
                if (--wp->w_bufp->b_nwnd == 0)
			bwdotmark(wp->w_bufp, wp);
                free((char *) wp);
        }
        lp = curwp->w_linep;
        i  = curwp->w_toprow;
        while (i!=0 && lback(lp)!=curbp->b_linep) {--i; lp = lback(lp);}
	if (curwp == mlwp)
	{	wp = makewind(0, 0);
		if (wp) curwp = wp;
	}
	wheadp = curwp;
	curwp->w_wndp   = mlwp;		mlwp ->w_wndp   = NULL;
        mlwp ->w_toprow = term.t_nrow;	mlwp ->w_ntrows = 1;
        curwp->w_toprow = 0;		curwp->w_ntrows = term.t_nrow-1;
        curwp->w_linep  = lp;
        curwp->w_flag  |= WFMODE|WFHARD;
        return (TRUE);
}

/* Make a new window, and initialize it.  One of curwp and curbp must be
 non-NULL. pm
*/
	WINDOW *
makewind(top, ntr)
register int    top;
register int    ntr;
{
        register WINDOW *wp;

        if ((wp = (WINDOW *) malloc(sizeof(WINDOW))) == NULL) {
                mlwrite("Cannot allocate WINDOW block");
                return (wp);
        }
	curbp->b_nwnd++;	/* current buffer will be displayed */

        wp->w_flag  = WFMODE|WFHARD;
        wp->w_bufp  = curbp;
        wp->w_force = 0;
	wp->w_toprow = top;
	wp->w_ntrows = ntr;
	if (curwp)
	{	wwdotmark(wp, curwp);
	        wp->w_linep = curwp->w_linep;
	} else
	{	wbdotmark(wp, curbp);
	        wp->w_linep = curbp->b_linep;                    
	}
        return wp;
}

/*
 * Split the given window. A window smaller than 3 lines cannot be split.
 * The only other error that is possible is a "malloc" failure allocating the
 * structure for the new window. Bound to "C-X 2".
 */
	local int
lsplitwind(gwp)
	register WINDOW *gwp;
{
        register LINE   *lp;
 	register int    ntru, ntrl, ntrd;
 	register WINDOW *wp, *wp1, *wp2;

        if (gwp->w_ntrows < 3)
        { 	mlwrite("Cannot split a %d line window", gwp->w_ntrows);
 		return (FALSE);
        }
        if ((wp = makewind(0, 0)) == NULL) return (FALSE);

        ntru = (gwp->w_ntrows-1) / 2;         /* Upper size           */
        ntrl = (gwp->w_ntrows-1) - ntru;      /* Lower size           */
        for (lp = gwp->w_linep, ntrd = 0; lp != gwp->w_dotp;)
		{ ++ntrd; lp = lforw(lp); }
        lp = gwp->w_linep;
        if (ntrd <= ntru) 			/* Old is upper window. */
 	{	if (ntrd == ntru) 		/* Hit mode line.       */
                        lp = lforw(lp);
                gwp->w_ntrows = ntru;
                wp->w_wndp = gwp->w_wndp;
                gwp->w_wndp = wp;
                wp->w_toprow = gwp->w_toprow+ntru+1;
                wp->w_ntrows = ntrl;
        } else {                                /* Old is lower window  */
                for (wp1 = NULL, wp2 = wheadp; wp2 != gwp;)
			{ wp1 = wp2; wp2 = wp2->w_wndp; }
                if (wp1 == NULL) wheadp = wp; else wp1->w_wndp = wp;
                wp->w_wndp   = gwp;
                wp->w_toprow = gwp->w_toprow;
                wp->w_ntrows = ntru;
                ++ntru;                         /* Mode line.           */
                gwp->w_toprow += ntru;
                gwp->w_ntrows  = ntrl;
                while (ntru--) lp = lforw(lp);
        }
        gwp->w_linep = lp; 			/* Adjust the top lines */
        wp->w_linep = lp; 			/* if necessary.        */
        gwp->w_flag |= WFMODE|WFHARD;
        wp->w_flag |= WFMODE|WFHARD;
        return (TRUE);
}

splitwind()	{return lsplitwind(curwp);}

/*
 * Enlarge the current window. Find the window that loses space. Make sure it
 * is big enough. If so, hack the window descriptions, and ask redisplay to do
 * all the hard work. You don't just set "force reframe" because dot would
 * move. Bound to "C-X Z".
 */
enlargewind(f, n, kk)
{
        register WINDOW *adjwp;
        register LINE   *lp;
        register int    i;

        if (n < 0)
                return (shrinkwind(f, -n));
        if (wheadp->w_wndp == NULL) {
                mlwrite("Only one window");
                return (FALSE);
        }
        if ((adjwp=curwp->w_wndp) == NULL) {
                adjwp = wheadp;
                while (adjwp->w_wndp != curwp)
                        adjwp = adjwp->w_wndp;
        }
        if (adjwp->w_ntrows <= n) {
                mlwrite("Impossible change");
                return (FALSE);
        }
        if (curwp->w_wndp == adjwp) {           /* Shrink below.        */
                lp = adjwp->w_linep;
                for (i=0; i<n && lp!=adjwp->w_bufp->b_linep; ++i)
                        lp = lforw(lp);
                adjwp->w_linep  = lp;
                adjwp->w_toprow += n;
        } else {                                /* Shrink above.        */
                lp = curwp->w_linep;
                for (i=0; i<n && lback(lp)!=curbp->b_linep; ++i)
                        lp = lback(lp);
                curwp->w_linep  = lp;
                curwp->w_toprow -= n;
        }
        curwp->w_ntrows += n;
        adjwp->w_ntrows -= n;
        curwp->w_flag |= WFMODE|WFHARD;
        adjwp->w_flag |= WFMODE|WFHARD;
        return (TRUE);
}

/*
 * Shrink the current window. Find the window that gains space. Hack at the
 * window descriptions. Ask the redisplay to do all the hard work. Bound to
 * "C-X C-Z".
 */
shrinkwind(f, n, kk)
{
        register WINDOW *adjwp;
        register LINE   *lp;
        register int    i;

        if (n < 0)
                return (enlargewind(f, -n));
        if (wheadp->w_wndp == NULL) {
                mlwrite("Only one window");
                return (FALSE);
        }
        if ((adjwp=curwp->w_wndp) == NULL) {
                adjwp = wheadp;
                while (adjwp->w_wndp != curwp)
                        adjwp = adjwp->w_wndp;
        }
        if (curwp->w_ntrows <= n) {
                mlwrite("Impossible change");
                return (FALSE);
        }
        if (curwp->w_wndp == adjwp) {           /* Grow below.          */
                lp = adjwp->w_linep;
                for (i=0; i<n && lback(lp)!=adjwp->w_bufp->b_linep; ++i)
                        lp = lback(lp);
                adjwp->w_linep  = lp;
                adjwp->w_toprow -= n;
        } else {                                /* Grow above.          */
                lp = curwp->w_linep;
                for (i=0; i<n && lp!=curbp->b_linep; ++i)
                        lp = lforw(lp);
                curwp->w_linep  = lp;
                curwp->w_toprow += n;
        }
        curwp->w_ntrows -= n;
        adjwp->w_ntrows += n;
        curwp->w_flag |= WFMODE|WFHARD;
        adjwp->w_flag |= WFMODE|WFHARD;
        return (TRUE);
}

/*
 * Pick the bootommost window that isn't the mesg window.  
 * Split the screen if that looks ok.  Used for
 * buflist, etc.  Return a pointer, or NULL on error.
 */
	WINDOW  *
wpopup()					/* rewritten by pm */
{	register WINDOW *wp;

	if (wheadp == mlwp) return NULL;
	wp = predwp(mlwp);
	if (wp->w_ntrows > term.t_nrow/4 && lsplitwind(wp)) wp = predwp(mlwp);
	return wp;
}

wininit()
{	register WINDOW *wp;

        wheadp	= curwp = NULL;			/* First window         */
	wp = makewind(0, term.t_nrow-1);	/* "-1" for mode line.  */
	mlwp = makewind(term.t_nrow, 1);	/* modeline window; pm	*/
        if (wp==NULL || mlwp == NULL) outofroom();

	wheadp = curwp = wp;
	wp->w_wndp  = mlwp;
	mlwp->w_wndp  = NULL;                   /* further initialize window */
}

/* -eof- */
