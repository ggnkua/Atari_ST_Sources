/* epart.c */

/*
 * Partition editing and picking.
 *
 * 09-Dec-87	ml.	Added pheader() to take care of placing partition
 *			headers at good sectors.
 * 14-Jan-88	ml.	Added chkpart() to make sure partition scheme does
 *			not map pass end of device.
 */
#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "defs.h"
#include "part.h"
#include "bsl.h"
#include "hdx.h"
#include "addr.h"
#include "error.h"

extern long maxpsiz;
extern int wdesk;
extern int hdesk;

extern long gbslsiz();
extern long bslsiz;
extern SECTOR badbuf[];		/* bad sectors buffer */

/*
 * Global variables these routines communicate with
 *
 */
static PART *pinfo;		/* -> partition block */
static long disksiz;		/* size of disk in blocks */
static long sizleft;		/* size of unused disk in blocks */
static int formw, formh;
static int lx, ly, sx, sy;
static int ok2draw;		/* 0: don't draw PARTPNL boxes */
static char partnames[NAMSIZ];	/* partition name buffer */
static int menuflg;		/* negative: never called partmenu */
static int pnlflg;		/* 1: partition scheme comes from panel */


/*
 * Figure out partition information;
 *    return OK if xpinfo[] is filled-in,
 *	     ERROR on [CANCEL] or something.
 */
figpart(dev, xpinfo)
int dev;
PART *xpinfo;
{
    char bs[512];
    int ret;

    pinfo = xpinfo;

    /*
     * Get partition information from disk's root block.
     */
    if ((ret = getroot(dev, bs)) != 0) {
    	if (tsterr(ret) != OK)
	    err(rootread);
	return ERROR;
    }

    if (chkroot(dev, bs) != OK)
        return err(cruptfmt);
    
    gpart(bs, pinfo);
    disksiz = ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz;
    
    if ((bslsiz = gbslsiz(dev)) == 0L) {	/* no bsl */
        return err(oldfmt);
    } else if (bslsiz < 0L) {			/* error occurred */
    	if (bslsiz == ERROR)			/* read error */
    	    err(rootread);
	return ERROR;				/* medium changed error */
    }

    menuflg = -1;	/* first time through */
    for (;;)
    {
	switch (partpnl())
	{
	    case EPMENU:			/* chose from menu */
		switch (partmenu())
		{
		    case PPOK:	return OK;	/* [OK] */
		    default:
		    case PPCN:	return BAILOUT;	/* [CANCEL] */
		    case PPEDIT: break;		/* continue and edit */
		}
		break;

	    default:
	    case EPCN:		return BAILOUT;	/* [CANCEL] */
	    case EPOK:		return OK;	/* [OK] */
	}
    }
}


int objup[] = {EP0UP, EP1UP, EP2UP, EP3UP};
int objdn[] = {EP0DN, EP1DN, EP2DN, EP3DN};
int objsiz[] = {EP0SIZ, EP1SIZ, EP2SIZ, EP3SIZ};
char *sizstr[5] = {"999.9Mb", "999.9Mb", "999.9Mb", "999.9Mb", "999.9Mb"};


/*
 * Handle PARTPNL partition edit panel;
 *   Return EPMENU if the luser wants the menu again;
 *	    EPCN if the luser CANCEL'ed
 *	    EPOK if the luser wants to use the partition
 */
partpnl()
{
    int i, but;
    int xrun = 1;
    PART savpart[4];
    char *s, *d;

    ok2draw = 0;

    /* save starting parameters */
    s = (char *)pinfo;
    d = (char *)savpart;
    for (i = sizeof(PART) * 4; i--;)
	*d++ = *s++;

    /*
     * Set form for first display, then throw it up.
     */
    ppnl[EPOK].ob_state = NORMAL;
    ppnl[EPCN].ob_state = NORMAL;
    ppnl[EPMENU].ob_state = NORMAL;
    for (i = NPARTS-1; i >= 0; --i) {
        if (pinfo[i].p_flg & P_EXISTS) {
            pinfo[i].p_siz += (bslsiz + 1);  /* add sacrificed space back */
            break;
        }
    }
    for (i = -1; i < 4; ++i)
	epadj(0L, i, ppnl);
    ARROW_MOUSE;
    dsplymsg(ppnl);

    /*
     * Edit the thing;
     * canonical event-driven switch().
     */
    ++ok2draw;
    while (xrun) switch ((but = form_do(ppnl, -1)))
    {
	case EPOK:	pnlflg = 1;
			for (i = 0; i < NPARTS; i++) {
			    if (!(pinfo[i].p_flg & P_EXISTS)) {
			        if (sizleft <= 0) {
			            pinfo[i].p_siz = 0L;
			        } else {
			            if (pinfo[i].p_siz > sizleft) {
			            	pinfo[i].p_siz = sizleft;
			            }
			            sizleft -= pinfo[i].p_siz;
			        }
			    } else {
			    	pinfo[i].p_id[0] = 'G';
			    	pinfo[i].p_id[1] = 'E';
			    	pinfo[i].p_id[2] = 'M';
			    }
			}
	case EPCN:
	case EPMENU:	xrun = 0;			/* return */
			break;

	case EPRESET:	d = (char *)pinfo;
			s = (char *)savpart;
			for (i = sizeof(PART) * 4; i--;)
			    *d++ = *s++;
			for (i = -1; i < 4; ++i)
			    epadj(0L, i, ppnl);
			objc_change(ppnl, EPRESET, MAX_DEPTH,
				    0, 0, wdesk, hdesk,
				    NORMAL, 1);
			break;

	case EP0SIZ:	eptoggle(0, ppnl);		break;
	case EP0UP:	epadj(MEGABYTE, 0, ppnl);	break;
	case EP0DN:	epadj(-MEGABYTE, 0, ppnl);	break;

	case EP1SIZ:	eptoggle(1, ppnl);		break;
	case EP1UP:	epadj(MEGABYTE, 1, ppnl);	break;
	case EP1DN:	epadj(-MEGABYTE, 1, ppnl);	break;

	case EP2SIZ:	eptoggle(2, ppnl);		break;
	case EP2UP:	epadj(MEGABYTE, 2, ppnl);	break;
	case EP2DN:	epadj(-MEGABYTE, 2, ppnl);	break;

	case EP3SIZ:	eptoggle(3, ppnl);		break;
	case EP3UP:	epadj(MEGABYTE, 3, ppnl);	break;
	case EP3DN:	epadj(-MEGABYTE, 3, ppnl);	break;
    }


    /*
     * Draw shrinking box and cleanup the screen;
     * return thing that caused our exit.
     */
    erasemsg();
    BEE_MOUSE;

    return but;
}


/*
 * Toggle partition in/out of existence.
 */
eptoggle(n, pnl)
int n;
OBJECT *pnl;
{
    /*
     * Toggle existance flag,
     * enforce minimum partition size.
     */
    if (((pinfo[n].p_flg ^= P_EXISTS) & P_EXISTS) && !pinfo[n].p_siz)
	epadj(MEGABYTE, n, pnl);
        else epadj(0L, n, pnl);

    epadj(0L, -1, pnl);			/* update #left field */
}


/*
 * Adjust partition `pno' size by `amt';
 * if `pno' is -1, just recompute and update disk space left indicator.
 *
 * A partition of size zero is disabled.
 */
epadj(amt, pno, pnl)
long amt;
int pno;
OBJECT *pnl;
{
    int i;
    long siz;
    long totsiz = 0;

    if (pno < 0) goto fixleft;

    for (i = 0; i < 4; ++i)			/* compute total used */
	if (pinfo[i].p_flg & P_EXISTS)
	    totsiz += pinfo[i].p_siz;

    /*
     * If total partition size exceeds the disk's
     * capacity, reduce `amt' accordingly.
     */
    if (amt >= 0 && totsiz + amt > disksiz)
	amt = disksiz - totsiz;

    if (amt > 0) {
	/*
	 * Enforce maximum partition size.
	 */
	siz = disksiz - totsiz;			/* siz = #free */
	if (amt > siz) amt = siz;		/* ensure amt <= siz */
	if (pinfo[pno].p_siz + amt > maxpsiz)	/* ensure partition not */
	    amt = maxpsiz - pinfo[pno].p_siz;	/* too big */

	pinfo[pno].p_siz += amt;		/* bump partition size */
	pinfo[pno].p_flg |= P_EXISTS;
    } else if (amt < 0) {
	amt = -amt;
	if (pinfo[pno].p_siz >= amt)		/* reduce partition size */
	    pinfo[pno].p_siz -= amt;
	else pinfo[pno].p_siz = 0L;
    }

    /*
     * Enforce minimum partition size of .5Mb
     */
    if (pinfo[pno].p_siz < 1024L)
	pinfo[pno].p_siz = 0L;

    /*
     * Disable partitions of zero size
     */
    if (!pinfo[pno].p_siz)
	pinfo[pno].p_flg &= ~P_EXISTS;

    /*
     * Redraw the thing;
     * if partition is disabled, shadow it and disable UP/DOWN buttons;
     * otherwise setup the buttons, setup size string, and so on...
     */
    if (!(pinfo[pno].p_flg & P_EXISTS)) {
	pnl[objsiz[pno]].ob_spec = "Unused";
	pnl[objsiz[pno]].ob_state = NORMAL;
	pnl[objsiz[pno]].ob_flags = SELECTABLE | TOUCHEXIT;

	pnl[objup[pno]].ob_state = DISABLED;
	pnl[objup[pno]].ob_flags = NONE;

	pnl[objdn[pno]].ob_state = DISABLED;
	pnl[objdn[pno]].ob_flags = NONE;
    } else {
	stuffamt(pinfo[pno].p_siz, sizstr[pno]);
	pnl[objsiz[pno]].ob_spec = sizstr[pno];
	pnl[objsiz[pno]].ob_state = NORMAL;
	pnl[objsiz[pno]].ob_flags = SELECTABLE | TOUCHEXIT;

	pnl[objup[pno]].ob_state = NORMAL;
	pnl[objup[pno]].ob_flags = TOUCHEXIT;

	pnl[objdn[pno]].ob_state = NORMAL;
	pnl[objdn[pno]].ob_flags = TOUCHEXIT;
    }

    if (ok2draw) {
	objc_draw(pnl, objsiz[pno], MAX_DEPTH, 0, 0, wdesk, hdesk);
	objc_draw(pnl, objup[pno], MAX_DEPTH, 0, 0, wdesk, hdesk);
	objc_draw(pnl, objdn[pno], 0, MAX_DEPTH, 0, 0, wdesk, hdesk);
    }


fixleft:

    /*
     * Compute and redraw 'space left' indicator.
     */
    sizleft = disksiz;
    for (i = 0; i < 4; ++i)
	if (pinfo[i].p_flg & P_EXISTS)
	    sizleft -= pinfo[i].p_siz;
    stuffamt(sizleft, sizstr[4]);
    (pnl[EPLEFT].ob_spec)->te_ptext = sizstr[4];
    if (ok2draw)
	objc_draw(pnl, EPLEFT, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


/*
 * Atoi `amt', #blocks, into 999.9Mb (or something like that);
 * assumes enough space in `str'.
 */
stuffamt(amt, str)
long amt;
char *str;
{
    long mb, frac;

    mb = amt / 2048;
    frac = amt - (2048 * mb);
    if (frac / 16)
	frac /= 205;				/* that's MEGABYTE / 10 */
	else frac = 0;
    if (frac < 0) frac = -frac;

    if (mb > 999) mb = 999;
    else if (mb < 0) mb = frac = 0;

    if (mb > 99) {
	*str++ = (mb / 100) + '0';
	mb -= 100 * (amt / 100);
    }

    if (mb > 9) {
	*str++ = (mb / 10) + '0';
	mb -= 10 * (mb / 10);
    } else *str++ = ' ';

    *str++ = mb + '0';

    if (frac) {
	*str++ = '.';
	*str++ = frac + '0';
    }
    *str++ = 'M';
    *str++ = 'b';
    *str++ = '\0';
}


/*
 * Partition button number-to-object translation table.
 */
int ppart[] = {
    PPART0, PPART1, PPART2, PPART3,
    PPART4, PPART5, PPART6, PPART7,
    PPART8, PPART9, PPART10, PPART11,
    PPART12, PPART13, PPART14
};


/* 
 * Given size of a hard disk, figure out
 * the partition scheme ID to look for.
 * ID is always 2 characters long.
 */
figprid(hdsiz, pr_id)
long hdsiz;
char pr_id[];
{
    UWORD mega, over;
    char numbuf[10];
    
    /* Round off disk size in megabytes */    
    mega = hdsiz / MEGABYTE;
    
    /* Round off disk size to nearest 10Mb */
    over = mega % 10;
    if (over >= 5)
       mega += (10 - over);
    else
       mega -= over;
    itoa(mega, numbuf);
    strcpy(pr_id, numbuf);
}


/*
 * Throw up menu of canned partitions;
 *    Return PPOK on [OK],
 *	     PPCN on [CANCEL],
 *	     PPEDIT on [EDIT==>],
 *	     ERROR on some error.
 *    if `flag' < 0, this is the first time 
 *	putting up the menu.
 */
partmenu()
{
    int i, but;
    char *s, *pnam, pr_id[2];

    /* Figure out partition scheme id */
    figprid(disksiz, pr_id);
    
    if (menuflg < 0) {
    	menuflg = 1;
       
        /* Get all available partition schemes from wincap 'ID' entries */
        wallents(partnames, pr_id);
    }

    for (i = 0, s = partnames; i < 15 && *s; ++i) {
    	p[ppart[i]].ob_type = G_BUTTON;
	p[ppart[i]].ob_spec = (long)s;
	p[ppart[i]].ob_state = NORMAL;
	p[ppart[i]].ob_flags = SELECTABLE | RBUTTON;
	while (*s++)
	    ;
    }

    /* rest of buttons are invisible and untouchable */
    for (; i < 15; ++i) {
    	p[ppart[i]].ob_type = G_IBOX;
	p[ppart[i]].ob_spec = 0L;			/* no thickness */
	p[ppart[i]].ob_state = DISABLED;		/* nobody home */
	p[ppart[i]].ob_flags = NONE;			/* disabled */
    }

    /* clean up rest of the form and throw it up */
    p[PPOK].ob_state = NORMAL;
    p[PPCN].ob_state = NORMAL;
    p[PPEDIT].ob_state = NORMAL;
    
    if((but = execform(p)) == PPCN || but == PPEDIT)
	return;

    /* search for partition they picked */
    pnlflg = 0;				/* partition scheme from menu */
    for (i = 0; i < 15; ++i)
	if (p[ppart[i]].ob_state & SELECTED)
	    break;
    if (i >= 15) return but;		/* nothing changed */
    pnam = p[ppart[i]].ob_spec;

    i = wgetent(pnam, pr_id);				/* (floppy access) */
    if (i != OK) {
    	nopart[NOSCHPOK].ob_state = NORMAL;
        (nopart[NOSCHPR].ob_spec)->te_ptext = p[ppart[i]].ob_spec;
        execform(nopart);
        return ERROR;
    }

    for (i = 0; i < 4; ++i)
	fillpart(i, &pinfo[i]);

    return but;
}


/*
 * Check if partition scheme selected is _legal_.
 * _Legal_ means the scheme does not map to non-existing memory.
 * If it is not, prompt user to pick partition again.
 *	Input:
 *		pdev - physical unit we're trying to partition.
 *		xpinfo - partition block user selected.
 *	Return:
 *		OK - if partition scheme is _legal_.
 *		ERROR - if partition scheme is illegal.
 */
chkpart(pdev, xpinfo)
int pdev;
PART *xpinfo;
{
    char bs[512];
    SECTOR totsiz;
    int	 i, ret;
    
    /*
     * Get partition information from disk's root block.
     */
    if ((ret = getroot(pdev, bs)) != 0) {
    	if (tsterr(ret) != OK)
	    err(rootread);
	return ERROR;
    }

    disksiz = ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz;
    totsiz = 0;
    for (i = 0; i < NPARTS; i++) {
        totsiz += xpinfo[i].p_siz;
    	if (totsiz > disksiz)
    	    return ERROR;
    }
    return OK;
}
	

/*
 *  Place partition headers at the appropiate sectors.
 *	Input:
 *		pdev - physical device partitions belong to.
 *		part - partition structure containing the partitions'
 *		       information.
 *	Return:
 *		OK - if everything is fine.
 *		ERROR - error occurs when testing header sectors.
 *	Comments:
 *		Making sure that the headers occupy consecutive good 
 *	sectors.  If necessary, sizes of partitions are adjusted to 
 *	achieve the above.
 *		If any size adjustment make a partition bigger than
 *	the maximum size, the partition will be adjusted to the maximum
 *	size leaving the excessive sectors wasted.
 */
pheader(pdev, part)
int pdev;	/* physical device number */
PART *part;	/* partition info */
{
    /* Maximum sizes for FAT, root directory and header <in sectors> */
    long  maxdent;		/* max num entries in root dir */
    long  start;		/* starting sector number of a partition */
    long  entries, nument();	/* num entries in BSL */
    long  newsiz;		/* size of modified partition */
    UWORD maxfsiz, maxdsiz, hdrsiz;
    int  pno;			/* partition being dealt with */
    int  done;			/* tell if location of header is found */
    int  moved;			/* num sectors header has been moved */
    int  curr;			/* current sector of header being checked */
    int  ret;			/* return code from testing header sectors */
    long currbsiz;		/* size of BSL b4 pheader is executed */
    int	 spc;			/* sectors per cluster */
    
    /* Get the BSL ready for later */
    entries = nument(MEDIA);
    sortbsl(entries);
    currbsiz = bslsiz;
    
    /* Determine actual sizes and starting sectors for all partitions */
    for (pno = 0; pno < NPARTS; pno++) {
    	
    	/* Partition 0 starts right after the BSL.  The rest starts right
    	   after its previous partition */
	if (pno == 0)
	    start = 1 + currbsiz;
	else
	    start = part[pno-1].p_st + part[pno-1].p_siz;
	    
    	/* Check if partition exists.  If it doesn't, move on to next one */
    	if (!(part[pno].p_flg & P_EXISTS)) {
    	    part[pno].p_st = start;
    	    continue;
    	}

        /* Detail of calculations in part.c dopart() */
        /* find number of sectors per cluster */
        if (part[pno].p_siz >= 0x8000L)	/* partition >= 16Mb? */
            spc = 4;			/* Yes, 4 spc */
        else
            spc = 2;			/* No, so, the good old 2 spc */
        /* find max FAT size */
        maxfsiz = ((part[pno].p_siz / spc) + 2) / 256 + 1;
        /* find max root dir entries */
        maxdent = ((part[pno].p_siz/ 80) + 15) & ~15;
        /* find max root dir size */
        maxdsiz = (maxdent * 32) / 512 + 1;
    
        /*-------------------------------------------------------*
         * Biggest possible header for a partition <in sectors>  *
         *	=  Boot Sector + 2 FATs + Root Dir		 *
         *-------------------------------------------------------*/
        hdrsiz = 1 + (maxfsiz * 2) + maxdsiz;
    
	/*-----------------------------------------------------------------*
	 * Look for a chunk of sectors starting at "start" (or after, but  *
	 * as close as possible) which is big enough to hold the biggest   *
	 * possible header.						   *
	 *-----------------------------------------------------------------*/
	done = 0;   	/* assume correct location not found yet */
	moved = 0;	/* assume header has not been moved */
	while (!done) {
	    /*----------------------------------------------------------*
	     * Find out if header contains any bad sectors by checking	*
	     * range of sectors to be occupied by the header against	*
	     * the BSL.							*
	     *----------------------------------------------------------*/
	    for (curr = 0; curr < hdrsiz; curr++) {
	    	if (srchbsl(start+curr, entries) == YES)
	    	    break;
	    }
	    
	    if (curr < hdrsiz) {	/* bad sector found in header */
	        /* move header to start after the bad sector */
	        moved += curr + 1;
	        start += curr + 1;
	    } else {			/* header is fine as it is */
	        if ((ret = testhdr(pdev, start, hdrsiz)) < 0)
	            return ERROR;
	        if (ret) {	/* Some bad sectors found in header */
	            entries = nument(MEDIA);
	            sortbsl(entries);
	        } else {	/* all sectors belong to header are good */
	    	    done = 1;
	    	}
	    }
	}
	
	if (moved) {	/* header has been moved */
	    /*-------------------------------------------------------*
	     * Expand previous partition (except if the current one  *
	     * is partition 0, then there is no previous partition), *
	     * and enforce maximum partition size on it.	     *
	     *-------------------------------------------------------*/
	    if (pno > 0) {
	        if (part[pno-1].p_siz + moved > maxpsiz)
		    part[pno-1].p_siz = maxpsiz;
		else
		    part[pno-1].p_siz += moved;
	    }
	        
	    /* Shrink size of current partition */
	    part[pno].p_siz -= moved;
	}
	
	/* Where current partition should start */
	part[pno].p_st = start;
    }
    
    /* last existing partition has to sacrifice some space for the BSL	*/
    /* and the root sector of device.					*/
    for (pno = NPARTS-1; pno >= 0; pno--) {
        if (part[pno].p_flg & P_EXISTS) {
	    part[pno].p_siz -= (currbsiz + 1);
	    break;
	}
    }

    /* have to move partitions (existing or not) which start
       right after the BSL if BSL has been expanded  */
    if (bslsiz > currbsiz) {		/* BSL becomes bigger? */
        for (pno = 0; pno < NPARTS; pno++) {
            if (part[pno].p_st == currbsiz + 1) {
                part[pno].p_st = bslsiz + 1;
                if (part[pno].p_siz > 0)
                    part[pno].p_siz -= (bslsiz = currbsiz);
            }
        }
    }
    
    return OK;	/* everything is fine */
}



/*
 *  Make sure that sectors assigned to a partition header are GOOD.
 *	Input:
 *		pdev - physical device number partition belongs to.
 *		start - starting (physical) sector number header starts.
 *		hdrsiz - number of sectors header occupies.
 *	Return:
 *		OK - if all sectors in header are good.
 *		positive number - if entries are added to BSL in testing
 *					the header.
 *		ERROR - if somewhere the process went wrong.
 *	Comments:
 *		Bad Sectors found are added as USER bad sectors.  
 *	First, because we can't expand the VENDOR list while preserving
 *	the USER list.  Second, this is ok, because even if the USER list
 *	is full, the user should reformat the disk anyway, and if the
 *	sector is REALLY bad, it would be discovered again then.
 */
testhdr(pdev, start, hdrsiz)
int pdev;
SECTOR start;
UWORD hdrsiz;
{
    long ret, size, pattern;
    extern long longrandom();
    extern int format;		/* flag */
    UWORD sectcnt, list;
    int nbad, clean=1;
    SECTOR sect;
    char *buf;		/* buffer with test data */
    
    
    size = (long)hdrsiz << 9;
    if ((buf = (char *)Malloc(size)) <= 0) {
    	err(nomemory);
    	ret = NOMEM;
    	goto wrapup;
    }
        
    /*
     * Try to write to header's sectors.
     */
    pattern = longrandom();
    fillbuf(buf, size, pattern);
    sectcnt = hdrsiz;
    sect = start;
    nbad = 0;

    if ((ret = wrsects(pdev, sectcnt, buf, sect)) != 0) {
    	if (tsterr(ret) == OK) {
    	    ret = ERROR;
    	    goto wrapup;
    	}
    	clean = 0;
        
    	while (sectcnt) {	/* find out which sector is indeed bad */
	    if ((ret = wrsects(pdev, 1, 0L, sect)) != 0) {
		if (tsterr(ret) == OK) {
		    ret = ERROR;
		    goto wrapup;
		}
    	        if (sect < 3) {
		    ret = err(rsrvbad);
		    goto wrapup;
		}
    	    	    
     	        badbuf[nbad++] = sect;	/* store bad sector num */
    	    	    
    	        /* buffer is filled up, have to add bad sectors
    	           found so far to the BSL before continuing.   */
    	        if (nbad == WARNBADSECTS) {
    	            /* Decide which list to add to */
    	            if (format == TRUE)
    	                list = VENDOR;
    	            else list = USER;
    	       	    if ((ret=addbsl(pdev, list, nbad)) < 0) {
    	       	        ret = err(rsrvbad);
    	       	        goto wrapup;
    	       	    }
    	       	    nbad = 0;	/* start counting again */
    	        }
    	    }
    	    sect++;
    	    sectcnt--;
    	}
        if (nbad) {	/* there are bad sectors found not added to BSL yet */
            /* Decide which list to add to */
            if (format == TRUE)
                list = VENDOR;
            else list = USER;
            if ((ret = addbsl(pdev, list, nbad)) < 0) {
                ret = ERROR;
                goto wrapup; 
            }
            nbad = 0;
        }
    }
    
    /* Try to read header's sectors */
    sectcnt = hdrsiz;
    sect = start;
    nbad = 0;
    if ((ret = rdsects(pdev, sectcnt, buf, sect)) != 0) {
    	if (tsterr(ret) == OK) {
    	    ret = ERROR;
    	    goto wrapup;
    	}
    	clean = 0;
        
    	while (sectcnt) {	/* find out which sector is indeed bad */
	    if ((ret = rdsects(pdev, 1, buf, sect)) != 0) {
	    	if (tsterr(ret) == OK) {
	    	    ret = ERROR;
	    	    goto wrapup;
	    	}
    	        if (sect < 3) {
		    ret = err(rsrvbad);
		    goto wrapup;
		}
    	    	    
     	        badbuf[nbad++] = sect;	/* store bad sector num */
    	    	    
    	        /* buffer is filled up, have to add bad sectors
    	           found so far to the BSL before continuing.   */
    	        if (nbad == WARNBADSECTS) {
            	    /* Decide which list to add to */
            	    if (format == TRUE)
                	list = VENDOR;
            	    else list = USER;
    	       	    if ((ret = addbsl(pdev, list, nbad)) < 0) {
    	       	        ret = ERROR;
    	       	        goto wrapup;
    	       	    }
    	       	    nbad = 0;	/* start counting again */
    	        }
    	    }
    	    sect++;
    	    sectcnt--;
    	}
        if (nbad) {	/* there are bad sectors found not added to BSL yet */
            /* Decide which list to add to */
            if (format == TRUE)
                list = VENDOR;
            else list = USER;
            if ((ret = addbsl(pdev, list, nbad)) < 0) {
                ret = ERROR;
                goto wrapup; 
            }
            nbad = 0;
        }
    }
wrapup:
    if (buf > 0)  Mfree((long)buf);
    
    if (ret < 0)
        return (int)ret;
        
    if (!clean) {
    	/* write new bsl back to disk */
    	if (wrbsl(pdev) != OK) {
    	    return ERROR;
    	}
        return 1;
    }
        
    return OK;
}
