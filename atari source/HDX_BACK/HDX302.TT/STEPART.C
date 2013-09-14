/* stepart.c */

/*
 * Partition editing and picking.
 *
 * 09-Dec-87	ml.	Added pheader() to take care of placing partition
 *			headers at good sectors.
 * 14-Jan-88	ml.	Added chkpart() to make sure partition scheme does
 *			not map pass end of device.
 * 02-Dec-88 	jye. change and add codes so that can be used for MS-DOS
 * 22-Dec-89	jye. Fix a bug in stuffamt() so that partitioning dialog
 *				     box correctly handle the partition size over 100 Mb.
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
#include "ipart.h"

#define ROLL1 1			/* move the bar one step */
#define ROLL4 4			/* move the bar four steps */
#define NULL 0L			/* the nill pointer */

extern int wdesk;
extern int hdesk;
extern long gbslsiz();
extern long getdsiz();
extern long bslsiz;
extern SECTOR badbuf[];		/* bad sectors buffer */
extern long ostack;
extern long sptrk;				/* sector per track */
extern long disksiz;			/* size of disk in blocks */
extern int yesscan;			/* the flag for the func. IBMGPART use */
extern int npart;			/* number of partitions */
extern int ext;			/* the index that point to the extended partition */
extern int extend;		/* the index that point to the end of extended */


/*
 * Global variables these routines communicate with
 *
 */
static PART *pinfo;		/* -> partition block */
static int totcyl;		/* total # of cylinder */
static long sizleft;	/* size of unused disk in blocks */
static long extleft;	/* size of unused extended partition in blocks */
static int formw, formh;
static int lx, ly, sx, sy;
static int ok2draw;		/* 0: don't draw PARTPNL boxes */
static char partnames[NAMSIZ];	/* partition name buffer */
static int menuflg;		/* negative: never called partmenu */
static int pnlflg;		/* 1: partition scheme comes from panel */
static int along;		/* 1: will not redraw and clean the box */
static int first;		/* flag for add bad and good sectors only one time */
long sumsiz;			/* the sum of bytes of root sectors */
int tolpart;			/* the total of number partitions */
int epty;				/* the y-coordinate of the moving bar */
int uplim;				/* index of dialog box */
int lowlim;				/* index of dialog box */
int restept;			/* 1: rest the moving bar to initial place */
DPART *headptr;			/* the head pointer of structure */
long ratio, bps;
long nill = (long)NULL;
int prevnpart;			/* former number of partitions */


/*
 * Figure out partition information;
 *    return OK if xpinfo[] is filled-in,
 *	     ERROR on [CANCEL] or something.
 */
sfigpart(bs, dev, rpinfo)

char *bs;
int dev;
PART **rpinfo;

{
    int ret;

	lowlim = 0;
	uplim = 4;
	first = 0;
	along = 0;		/* will redraw and clean the box */
	restept = 0;

    /*  Get partition information from disk's root block. */
    if ((ret = getroot(dev, bs, (SECTOR)0)) != 0) {
    	if (tsterr(ret) != OK)
	    	err(rootread);
		return ERROR;
	}
	yesscan = 0;
    
	/* get bad sectors list size */
    if ((bslsiz = gbslsiz(dev)) == 0L) {	/* no bsl */
        return err(oldfmt);
    } else if (bslsiz < 0L) {			/* error occurred */
    	if (bslsiz == ERROR)			/* read error */
    	    err(rootread);
		return ERROR;				/* medium changed error */
    }

  	if ((ret = chkroot(dev, bs)) == -3)	{ /* don't have to show the alert box */
		return ERROR;
	} else if (ret != OK)	{
   		return err(cruptfmt);
	}

	disksiz = ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz;
	if (stgpart(dev, bs, (PART *)&pinfo) == ERROR)	{
		if (pinfo > 0) Mfree(pinfo);
		return ERROR;
	}
	if (ext != NO_EXT)	sortpart(pinfo, USER_ED);

	/* put partition infomations into the dynamic structure */
	if (part2dpart(npart) == ERROR)		{
		return ERROR;
	}
	menuflg = -1;	/* first time through */
	restept = 1;
	prevnpart = npart;
    for (;;)
    {
	switch (sdoscrbar())
	{
	    case SPMENU:			/* chose from menu */
			switch (spartmenu())
			{
			    case PPOK:		*rpinfo = pinfo;
								return OK;	/* [OK] */
			    default:
			    case PPCN:		if (pinfo > 0) Mfree(pinfo);
								if (headptr > 0) free(headptr);
								return BAILOUT;	/* [CANCEL] */
			    case PPEDIT:	restept = 1; 
								lowlim = 0;
								uplim = 4;
								break;		/* continue and edit */
			}
			break;

		case EXPERT:	along = 0;
						lowlim = 0;
						uplim = 4;
						restept = 1;
						ext = 1;		/* set default to 1 */
						extend = npart-2;
						switch (doexpert())	{
							case NOSEL:		if (pinfo > 0)	{
												inipart(pinfo, prevnpart);
												Mfree(pinfo);
											}
											if (headptr > 0) free(headptr);
											return BAILOUT;	/* [CANCEL] */
							case SELOK:	pnlflg = 1;	
										if (pinfo > 0)	{
											inipart(pinfo, prevnpart);
											Mfree(pinfo);
										}
										if (dpart2part(ext) == ERROR) {
											if (headptr > 0) free(headptr);
											if (pinfo > 0) Mfree(pinfo);
												return ERROR;
										}
			    						*rpinfo = pinfo;
										return OK;
							default:
							case TOEDIT: break;
						}

		case SCRUP:  	break;
		case SCRDN:  	break;
		case SCRBAR:  	break;
		case SCREPT:  	break;
		case SUNDO:  	break;

	    default:
		case SEPOK:	*rpinfo = pinfo;
					return OK;
		case SEPCN: if (pinfo > 0) Mfree(pinfo);
					if (headptr > 0) free(headptr);
					return BAILOUT;
	}
    }
}

int objnums[] = { SPARTNM0, SPARTNM1, SPARTNM2, SPARTNM3};
int objups[] = {SEP0UP, SEP1UP, SEP2UP, SEP3UP};
int objdns[] = {SEP0DN, SEP1DN, SEP2DN, SEP3DN};
int objsizs[] = {SEP0SIZ, SEP1SIZ, SEP2SIZ, SEP3SIZ};
char *sizstr[6] = {"1000.0Mb0", "1000.0Mb0", "1000.0Mb0", "1000.0Mb0", 
				   "1000.0Mb0", " 999 partition(s)"};
char *numstr[4] = {"#999", "#999", "#999", "#999"};


int objnum[] = { PART1, PART2, PART3, PART4, PARTX, PARTY, PARTZ};
char *xsizstr[7] = {"1000.0Mb0", "1000.0Mb0", "1000.0Mb0", "1000.0Mb0", 
				   "1000.0Mb0", "1000.0Mb0", "1000.0Mb0"};
int objsiz[] = {PART1MB, PART2MB, PART3MB, PART4MB, PARTXMB, PARTYMB, PARTZMB};
char *xnumstr[7] = {"#999", "#999", "#999", "#999", "#999", "#999", "#999"};
int objsel[] = { SELECT1, SELECT2, SELECT3, SELECT4, SELECT5, SELECT6};
char *selstr[6] = {"from #2 to #99", "from #2 to #99", "from #2 to #99", 
					"from #3 to #99", "from #3 to #99", "from #4 to #99" };
doexpert()
{

	int i, lastpno, pno;
	int run = 1;
	int erase = 0;
	int but;

	ok2draw = 0;


	exppnl[TOEDIT].ob_state = NORMAL;
	exppnl[NOSEL].ob_state = NORMAL;
	exppnl[SELOK].ob_state = NORMAL;

	drawsel(2, npart-2, 0, exppnl);
	drawsel(2, npart-1, 1, exppnl);
	drawsel(2, npart, 2, exppnl);
	drawsel(3, npart-1, 3, exppnl);
	drawsel(3, npart, 4, exppnl);
	drawsel(4, npart, 5, exppnl);


	for (i = 0; i < 7; i++)		{
		if (npart > 7)	{
			if (i > 3)	{
				if (i == 4)
					lastpno = npart - i + 1;
				drawpart(i, lastpno++, exppnl);
			} else {
				drawpart(i, i, exppnl);
			}
		} else if (npart == 5)	{
			if (i > 4)	{
				pno = -1;
				drawpart(i, pno, exppnl);
			} else {
				drawpart(i, i, exppnl);
			}
		} else if (npart == 6)	{
			if (i > 5)	{
				pno = -1;
				drawpart(i, pno, exppnl);
			} else {
				drawpart(i, i, exppnl);
			}
		} else {
			drawpart(i, i, exppnl);
		}
	}

	/* set the default selected */
	exppnl[SELECT1].ob_state = NORMAL | SELECTED;
	exppnl[SELECT2].ob_state = NORMAL;
	exppnl[SELECT3].ob_state = NORMAL;
	exppnl[SELECT4].ob_state = NORMAL;
	exppnl[SELECT5].ob_state = NORMAL;
	exppnl[SELECT6].ob_state = NORMAL;
	turnexton(1, npart-2);

	ARROW_MOUSE;
	dsplymsg(exppnl);

	++ok2draw;
	while (run)		{
		switch((but = form_do(exppnl, -1)))		{
			case TOEDIT:	run = 0; 
							break;
			case NOSEL:		run = 0;
							erase = 1;
							break;
			case SELOK:		run = 0;
							erase = 1;
							break;
			case SELECT1:	ext = 1;
							extend = npart - 2;
							turnexton(1, npart-2);
							break;
			case SELECT2:	ext = 1;
							extend = npart - 1;
							turnexton(1, npart-1);
							break;
			case SELECT3:	ext = 1;
							extend = npart;
							turnexton(1, npart);
							break;
			case SELECT4:	ext = 2;
							extend = npart - 1;
							turnexton(2, npart-1);
							break;
			case SELECT5:	ext = 2;
							extend = npart;
							turnexton(2, npart);
							break;
			case SELECT6:	ext = 3;
							extend = npart;
							turnexton(3, npart);
							break;
		}
	}
	if (erase)	{
		erasemsg();
		BEE_MOUSE;
	}
	return but;
}

turnexton(stnum, endnum)
int stnum;		/* the number that start to turn on the extended partition */
int endnum;		/* the number that end to turn on the extended partition */
{
	int i;

	if (npart > 7)	{
		endnum = 7 - (npart - endnum);
	}
	for (i = 0; i < 7; i++)	{
		exppnl[objsiz[i]].ob_state = NORMAL;
		if ((i >= stnum) && (i < endnum))	{
			exppnl[objsiz[i]].ob_state |= SELECTED;
		}
		if (ok2draw)	{
			objc_draw(exppnl, objsiz[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
		}

	}
	ok2draw++;
}




drawsel(stnum, tonum, num, pnl)
int stnum;		/* the first extended partition number */
int tonum;		/* the last extended partition number */
int num;		/* the number of selected extended partition scheme */
OBJECT *pnl;
{

	/* set the select range in the dialog box */
	calextnum(stnum, tonum, selstr[num]);
	(pnl[objsel[num]].ob_spec)->te_ptext = selstr[num];
	if (ok2draw)	{
		objc_draw(pnl, objsel[num], MAX_DEPTH, 0, 0, wdesk, hdesk);
	}
}


drawpart(num, pno, pnl)
int num;		/* the number of selected extended partition scheme */
int pno;		/* the partition number */
OBJECT *pnl;
{
	DPART *pinfo, *addr();

	if (pno == NO_EXT)	{ /* not exists */
		pnl[objsiz[num]].ob_spec = "Unused";
		pnl[objsiz[num]].ob_state = NORMAL;
		pnl[objsiz[num]].ob_flags = TOUCHEXIT;
		(pnl[objnum[num]].ob_spec)->te_ptext = "     ";
	} else {
		pinfo = addr(pno);
		stuffamt(pinfo->siz, xsizstr[num]);
		pnl[objsiz[num]].ob_spec = xsizstr[num];
		pnl[objsiz[num]].ob_state = NORMAL;
		pnl[objsiz[num]].ob_flags = TOUCHEXIT;

		stpartnum(pno+1, xnumstr[num]);
		(pnl[objnum[num]].ob_spec)->te_ptext = xnumstr[num];
	}
	if (ok2draw)	{
		objc_draw(pnl, objsiz[num], MAX_DEPTH, 0, 0, wdesk, hdesk);
		objc_draw(pnl, objnum[num], MAX_DEPTH, 0, 0, wdesk, hdesk);
	}

}

sdoscrbar()

{

    int i, j, but, step;
    int xrun = 1;
    long usesiz;
	DPART *temptr, *addr();

    ok2draw = (along) ? 1 : 0;

	/* set form for first display */
	scrpnl[SEPOK].ob_state = NORMAL;
	scrpnl[SEPCN].ob_state = NORMAL;
	scrpnl[SPMENU].ob_state = NORMAL;
	scrpnl[SUNDO].ob_state = NORMAL;

	if (!first++)	{	/* initially ST partition */
		temptr = headptr;
		for (i = 0; i < npart; i++)	{
			if ((temptr->flg & P_EXISTS) && 
				(!((temptr->next)->flg & P_EXISTS)))	{
				temptr->siz += bslsiz + 1; /* add sacrificed space back */
			}
			temptr = temptr->next;
		}
	}

    for (i = -1; i < 4; ++i)
	 	sepadj(0L, i, scrpnl);
	if (restept)	{
		scrpnl[SCREPT].ob_y = 0;
		restept = 0;
	}
	if (!along)		{
	    ARROW_MOUSE;
	    dsplymsg(scrpnl);
	}

    /*
     * Edit the thing;
     * canonical event-driven switch().
     */
    ++ok2draw;
    while (xrun) 	{
	along = 0;
	if (npart > 4)	{
		scrpnl[EXPERT].ob_state = NORMAL;
		scrpnl[EXPERT].ob_flags = TOUCHEXIT;
	} else {
		scrpnl[EXPERT].ob_state = DISABLED;
		scrpnl[EXPERT].ob_flags = NONE;
	}
	objc_draw(scrpnl, EXPERT, MAX_DEPTH, 0, 0, wdesk, hdesk);

	switch ((but = form_do(scrpnl, -1)))
    {
	case SEPOK:	pnlflg = 1;
				if (pinfo > 0L)	{
					inipart(pinfo,prevnpart);
					Mfree(pinfo);
				}
				ext = 1;		/* set the default extended partition */
				extend = npart - 2;
				if (dpart2part(ext) == ERROR) return ERROR;
				xrun = 0;
				break;
	case SEPCN:	xrun = 0;			/* return */
					break;
	case EXPERT: if (npart > 4)		{
					xrun = 0;
					break;
				 } else {
				 	xrun = 1;
					break;
				 }
	case SCRBAR: if (sdoscrupdn(ROLL4) == ERROR) return ERROR;
					xrun = 0;
					break;
	case SCRUP:  if (sdoscrupdn(ROLL1) == ERROR) return ERROR;
				xrun = 0;
				break;
	case SCRDN:  if (sdoscrupdn(ROLL1) == ERROR) return ERROR;
				xrun = 0;
				break;
	case SCREPT: if (sdoslidebox(scrpnl) == ERROR) return ERROR;
				xrun = 0;
				break;
	case SPMENU:	xrun = 0;
					break;

	case SUNDO:	 /* restore the starting parameters */
				lowlim = 0;
				uplim = 4;
				if (part2dpart(prevnpart) == ERROR)	return ERROR;
				for (i = -1; i < NPARTS; ++i)
				    sepadj(0L, i, scrpnl);
				npart = prevnpart;
				scrpnl[SCREPT].ob_y = 0;
				objc_draw(scrpnl, SCRBAR, MAX_DEPTH, 0, 0, wdesk, hdesk);
				break;

	case SEP0SIZ:xrun = septoggle(0, scrpnl);	break;
	case SEP0UP:	sepadj(MEGABYTE, 0, scrpnl);	break;
	case SEP0DN:	sepadj(-MEGABYTE, 0, scrpnl);	break;

	case SEP1SIZ:xrun = septoggle(1, scrpnl);	break;
	case SEP1UP:	sepadj(MEGABYTE, 1, scrpnl);	break;
	case SEP1DN:	sepadj(-MEGABYTE, 1, scrpnl);	break;

	case SEP2SIZ:xrun = septoggle(2, scrpnl);	break;
	case SEP2UP:	sepadj(MEGABYTE, 2, scrpnl);	break;
	case SEP2DN:	sepadj(-MEGABYTE, 2, scrpnl);	break;

	case SEP3SIZ:xrun = septoggle(3, scrpnl);	break;
	case SEP3UP:	sepadj(MEGABYTE, 3, scrpnl);	break;
	case SEP3DN:	sepadj(-MEGABYTE, 3, scrpnl);	break;
  	}
  }


    /*
     * Draw shrinking box and cleanup the screen;
     * return thing that caused our exit.
     */
	if (!along)	{
    	erasemsg();
    	BEE_MOUSE;
	}
    return but;
}




/* 
 * conver the partition number for the dialog box to the string .
 *
 */

calextnum(stnum, tonum, str)

int stnum,tonum;
char *str;

{
	int  i = 0;
	int addspace = 0;
	char tem[10];

	/* set the partition number header */
	*str++ = 'f';
	*str++ = 'r';
	*str++ = 'o';
	*str++ = 'm';
	*str++ = ' ';
	*str++ = '#';
	*str++ = stnum % 10 + '0';
	*str++ = ' ';
	*str++ = 't';
	*str++ = 'o';
	*str++ = ' ';
	*str++ = '#';
	/* conver the integer to ASCII */
	do	{	/* generate digits in reverse order */
		tem[i++] = tonum % 10 + '0';	/* get next digits */
	} while ((tonum /= 10) > 0);		/* delete it */

	if (i == 1)	{
		addspace = 1;
	}
	for (; i > 0; )	{ /* reverse string 'str' in place */
		*str++ = tem[--i];
	}
	if (addspace)	*str++ = ' ';
   	*str = '\0';
}


sdoscrupdn(roll)
int roll;

{
 	int gr_mkmx, gr_mkmy;
	int gr_mkmstate, gr_mkkstate;
	int barht, barx, bary;
	int eptx, eptht;

	along = 1;
	barht = scrpnl[SCRBAR].ob_height;
	eptht = scrpnl[SCREPT].ob_height;
	graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
	objc_offset(scrpnl, SCREPT, &eptx, &epty);
	objc_offset(scrpnl, SCRBAR, &barx, &bary);
	/* check which part of bar was clicked */
	if (gr_mkmy > (epty+eptht))	{	/* low part of bar was clicked */
		if (roll == ROLL4)	{
			if ((eptht > (bary+barht-epty-eptht)) || (lowlim == 20))	{
				scrpnl[SCREPT].ob_y = barht - eptht;
			} else {
				scrpnl[SCREPT].ob_y += eptht;
			}
			lowlim += 4;
			if ((lowlim + 4) > uplim) uplim += 4;
			if (uplim > npart)	{
				if (creatmem(ROLL4) == ERROR)	{
					return ERROR;
				}
			}
		} else {
			if ((eptht > ((bary+barht-epty-eptht) * 4)) || (lowlim == 23))	{
				scrpnl[SCREPT].ob_y = barht - eptht;
			} else {
				scrpnl[SCREPT].ob_y += eptht / 4;
			}
			lowlim++;
			if ((lowlim + 4) > uplim) 	 uplim++;
			if (uplim > npart)	{
				if (creatmem(ROLL4) == ERROR)	{
					return ERROR;
				}
			}
		}
	} else if (gr_mkmy < epty)	{	/* upper part of bar was clicked */
		if (roll == ROLL4)	{
			if ((eptht > (epty - bary)) || (lowlim <= 4))	{
				scrpnl[SCREPT].ob_y = 0;
				lowlim = 0;
			} else {
				scrpnl[SCREPT].ob_y -= eptht;
				lowlim -= 4;
			}
		} else {
			if ((eptht > ((epty - bary) * 4)) || (lowlim == 1))	{
				scrpnl[SCREPT].ob_y = 0;
			} else {
				scrpnl[SCREPT].ob_y -= eptht / 4;
			}
			if (lowlim)	 {
				lowlim--;
			}
		}
	}
	objc_draw(scrpnl,SCRBAR, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


#define WHITEBAR 24		/* when the white bar on the bottom, the */
						/* 'lowlim' will equal to 24 */
sdoslidebox(tree)

OBJECT *tree;

{
	int gr_wreturn, eptatmax;
	int numofmem;			/*   # of memories to be allocated */

	along = 1;
	eptatmax = tree[SCRBAR].ob_height - tree[SCREPT].ob_height;
	gr_wreturn = graf_slidebox(tree, SCRBAR, SCREPT, 1);
	lowlim = (WHITEBAR * gr_wreturn) / 1000;
	if ((lowlim >= uplim) || ((lowlim + 4) > uplim)) 	{
		uplim = lowlim + 4;
		if (uplim > npart)	{
			numofmem = uplim - npart;
			if (creatmem(numofmem) == ERROR)	{
				return ERROR;
			}
		}
	}
	/*
	tree[SCREPT].ob_y = (eptatmax * gr_wreturn) / 1000;
	*/
	tree[SCREPT].ob_y = (eptatmax * lowlim ) / 24;
	objc_draw(tree, SCRBAR, MAX_DEPTH, 0, 0, wdesk, hdesk);
}



/*
 * Toggle partition in/out of existence.
 */
septoggle(n, pnl)
int n;
OBJECT *pnl;
{
	int i; 
	DPART *pinfo, *ppinfo, *npinfo, *addr();
    /*
     * Toggle existance flag,
     * enforce minimum partition size.
     */
	i = n + lowlim;
	pinfo = addr(i);	/* return the structure pointer */
	ppinfo = addr(i-1);	/* return the previous structure pointer */
	npinfo = addr(i+1);	/* return the next structure pointer */
	if ((!(pinfo->flg & P_EXISTS)) && (pinfo->siz) && (ppinfo)
							&& (ppinfo->flg & P_EXISTS)){
		if (maxmsg(pnl,i,tolpart) == NOMAX) return ON;
		pinfo->flg = P_EXISTS;
		sepadj(0L, n, pnl);
	} else if (((pinfo->flg ^= P_EXISTS) & P_EXISTS) 
		  && !pinfo->siz) {
		/* make extended partition continue */
		if (!i || ((ppinfo) && (ppinfo->flg & P_EXISTS)))		{
			if (maxmsg(pnl,i,tolpart) == NOMAX) return ON;
			sepadj(MEGABYTE, n, pnl);
		} else {
			sepadj(0L, n, pnl);
		}
	} else if ((!lowlim) && (!i)&&(!(npinfo->flg & P_EXISTS)))	{
		sepadj(0L, n, pnl);
	} else if ((!lowlim) && (!i)&&(pinfo->flg & P_EXISTS))	{
		sepadj(0L, n, pnl);
	} else {             /* do nothing, turn it back to the initial state */
		pinfo->flg ^= P_EXISTS;
		if ((pinfo->flg & P_EXISTS) && (!(npinfo->flg & P_EXISTS))) {
      		pinfo->flg ^= P_EXISTS;
			sepadj(0L, n, pnl);
		}
	}
    sepadj(0L, -1, pnl);			/* update #left field */
	return YES;
}
	

/*
 * Adjust partition `pno' size by `amt';
 * if `pno' is -1, just recompute and update disk space left indicator.
 *
 * A partition of size zero is disabled.
 */

#define HALFMEGA 1024L

sepadj(amt, pno, pnl)
long amt;
int pno;
OBJECT *pnl;
{
	int i;
    long siz;
	long sizhas; 	/* disk size left in sectors */
    long totsiz = 0;
	DPART *pinfo, *npinfo, *addr();

    if (pno < 0) 
		goto fixleft;
	pno += lowlim;

	pinfo = headptr;
    /* compute total used */
	while (pinfo->flg & P_EXISTS)	{
	    	totsiz += pinfo->siz;
			pinfo = pinfo->next;
	}
	pinfo = addr(pno);
	npinfo = addr(pno+1);
	sizhas = disksiz;

    /*
     * If total partition size exceeds the disk's
     * capacity, reduce `amt' accordingly.
     */
    if (amt >= 0 && totsiz + amt > sizhas)
	amt = sizhas - totsiz;

    if (amt > 0) {
	/*
	 * Enforce maximum partition size.
	 */
	siz = sizhas - totsiz;			/* siz = #free */
	if (amt > siz) amt = siz;		/* ensure amt <= siz */
	if (pinfo->siz + amt > sizhas)	/* ensure partition not */
	    amt = sizhas - pinfo->siz;	/* too big */

	pinfo->siz += amt;		/* bump partition size */
	pinfo->flg = P_EXISTS;
    } else if (amt < 0) {
	amt = -amt;
	if (pinfo->siz > amt) {		/* reduce partition size */
	    pinfo->siz -= amt;
    	if ((pinfo->siz < HALFMEGA) && (npinfo->flg & P_EXISTS))
			pinfo->siz = amt;
	} else if ((pinfo->siz <= amt) &&
				(!(npinfo->flg & P_EXISTS)))	{
		/* reduce partition size */
	    pinfo->siz = 0L;
    } 
  }

    /*
     * Enforce minimum partition size of half mega byte 
     */
    if (pinfo->siz < HALFMEGA)
	pinfo->siz = 0L;

    /*
     * Disable partitions of zero size
     */
    if (!pinfo->siz)	{
		pinfo->flg &= ~P_EXISTS;
	}

    /*
     * Redraw the thing;
     * if partition is disabled, shadow it and disable UP/DOWN buttons;
     * otherwise setup the buttons, setup size string, and so on...
     */
	pno -= lowlim;
    if (!(pinfo->flg & P_EXISTS)) {
		pnl[objsizs[pno]].ob_spec = "Unused";
		pnl[objsizs[pno]].ob_state = NORMAL;
		pnl[objsizs[pno]].ob_flags = TOUCHEXIT;

		pnl[objups[pno]].ob_state = DISABLED;
		pnl[objups[pno]].ob_flags = NONE;

		pnl[objdns[pno]].ob_state = DISABLED;
		pnl[objdns[pno]].ob_flags = NONE;
    } else {
		stuffamt(pinfo->siz, sizstr[pno]);
		pnl[objsizs[pno]].ob_spec = sizstr[pno];
		pnl[objsizs[pno]].ob_state = NORMAL;
		pnl[objsizs[pno]].ob_flags = TOUCHEXIT;

		pnl[objups[pno]].ob_state = NORMAL;
		pnl[objups[pno]].ob_flags = TOUCHEXIT;

		pnl[objdns[pno]].ob_state = NORMAL;
		pnl[objdns[pno]].ob_flags = TOUCHEXIT;
    }

	/* set the partition numbers in the dialog box */
	stpartnum(lowlim+pno+1, numstr[pno]);
	(pnl[objnums[pno]].ob_spec)->te_ptext = numstr[pno];

    if (ok2draw) {
		objc_draw(pnl, objsizs[pno], MAX_DEPTH, 0, 0, wdesk, hdesk);
		objc_draw(pnl, objups[pno], MAX_DEPTH, 0, 0, wdesk, hdesk);
		objc_draw(pnl, objdns[pno], MAX_DEPTH, 0, 0, wdesk, hdesk);
		objc_draw(pnl, objnums[pno], MAX_DEPTH, 0, 0, wdesk, hdesk);
    }


fixleft:

    /*
     * Compute and redraw 'space left' indicator and
	 * calculat the total partitions number */

   	sizleft = disksiz;
	pinfo = headptr;
	tolpart = 0;
	while ((pinfo->flg & P_EXISTS) && (pinfo->siz > 0)) 	{
		    sizleft -= pinfo->siz;
			tolpart++;  
			pinfo = pinfo->next;
	}
	npart = tolpart;
   	stuffamt(sizleft, sizstr[4]);
   	(pnl[SEPLEFT].ob_spec)->te_ptext = sizstr[4];

    totalpart(tolpart, sizstr[5]);
   	(pnl[STOLPART].ob_spec)->te_ptext = sizstr[5];

    if (ok2draw)	{
		objc_draw(pnl, SEPLEFT, MAX_DEPTH, 0, 0, wdesk, hdesk);
		objc_draw(pnl, STOLPART, MAX_DEPTH, 0, 0, wdesk, hdesk);
	}
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
	if (mb < 0) mb = frac = 0;

    if (mb > 999)	{ 
		*str++ = (mb / 1000) + '0';
		mb -= 100 * (amt / 1000);
		if ((!mb) || (mb < 10))	{ /* take care the mb=1000 or 1001 case */
			*str++ = '0';
			*str++ = '0';
		} else if (mb < 100)	{ /* take care the mb=1099 case */
			*str++ = '0';
		}
    }
    if (mb > 99) {
		*str++ = (mb / 100) + '0';
		mb -= 100 * (amt / 100);
		if ((!mb) || (mb <10))	{ /* take care the mb=100 or 101 case */
			*str++ = '0';
		}
    }
    if (mb > 9) {
		*str++ = (mb / 10) + '0';
		mb -= 10 * (mb / 10);
    } 
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
 * Partitin button number-to-object translation table.
 */

int ppart[] = {
	PPART0, PPART1, PPART2, PPART3,
	PPART4, PPART5, PPART6, PPART7,
	PPART8, PPART9, PPART10, PPART11,
	PPART12, PPART13, PPART14
};

/*
 * Throw up menu of canned partitions;
 *    Return PPOK on [OK],
 *	     PPCN on [CANCEL],
 *	     PPEDIT on [EDIT==>],
 *	     ERROR on some error.
 *    if `flag' < 0, this is the first time 
 *	putting up the menu.
 */

spartmenu()
{
    int i, but, tem;
    char *s, *pnam, pr_id[5];

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
	npart = 4;
	ext = NO_EXT;		/* set no extended partition */
	if (headptr > 0)	free(headptr);
	if ((pinfo = (PART *)Malloc((long)sizeof(PART)*npart)) <= 0)		{
		err(nomemory);
		if (pinfo > 0)	Mfree(pinfo);
		return ERROR;
	}
	inipart(&pinfo[0], npart);		/* initialized the 'pinfo' */
	npart = 0;
    for (i = 0; i < 4; ++i)
		fillpart(i, &pinfo[i]);

    return but;
}


/* 
 * conver the partition number for the dialog box to the string .
 *
 */

stpartnum(num, str)

int num;
char *str;

{
	int  i = 0;
	char tem[100];

	/* set the partition number header */
	*str++ = '#';
	/* conver the integer to ASCII */
	do	{	/* generate digits in reverse order */
		tem[i++] = num % 10 + '0';	/* get next digits */
	} while ((num /= 10) > 0);		/* delete it */

	for (; i > 0; )	{ /* reverse string 'str' in place */
		*str++ = tem[--i];
	}
   	*str = '\0';
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

spheader(pdev, part)

int pdev;	/* physical device number */
PART *part;	/* partition info */

{
    /* Maximum sizes for FAT, root directory and header <in sectors> */
    long  maxdent;		/* max num entries in root dir */
    long  start;		/* starting sector number of a partition */
	long  entries, nument();
	long  movehdr, temstart, moved, psiz;
    UWORD maxfsiz, maxdsiz, hdrsiz;
	long currbsiz;		/* size of BSL b4 pheader is executed */
	int  pno;			/* partition being dealt with */
	int  done;			/* tell if location of header is found */
	int  curr;			/* current sector of header being checked */
	int  ret;			/* return code from testing header sectors */
	int	 spc;			/* sectors per cluster */
	int  kindfat;       /* 12 bits fat or 16 bits fat */
	int  step;			/* the index for check the partitions */
	long bigsect(), nsect;
	long stbigsect();
	long temsect, remain;
	long cell();
    
    
	/* get the BSL ready ofr later */
	entries = nument(MEDIA);
	sortbsl(entries);
	currbsiz = bslsiz;

    /* Determine actual sizes and starting sectors for all partitions */
    for (pno = 0; pno < npart; pno++) {
    	
    	/* Partition 0 starts right after root sect.  The rest starts right
    	   after its previous partition ???*/
		if (pno == 0)
		    start = 1 + currbsiz; 
		else if (pno == 4)
			start = part[ext].p_st;	/* start in extened partition */
		else
		    start = part[pno-1].p_st + part[pno-1].p_siz;
	    
    	/* Check if partition exists.  If it doesn't, move on to next one */
    	if ((!(part[pno].p_flg & P_EXISTS)) || (pno == ext)) {
			part[pno].p_st = start;
    	    continue;
    	}
		if (pno > 3) 	{
			psiz = part[pno].p_siz - ROOTSECT;
		} else	{
			psiz = part[pno].p_siz;
		}

		/* estimate the bps */
		/* MAXSECT = 16MB - 8 */
		bps = cell((psiz-7)*BPS, (long)MAXSECT);
		/* the real pbs */
		bps = BPS * n2power((UWORD)cell(bps, (long)BPS));
		ratio = bps / BPS;
		nsect = psiz / ratio;

        /* Detail of calculations in part.c dopart() */
        /* find max FAT size. FAT16: 16 bits fat; FAT12: 12bits fat */
        maxfsiz = ((((nsect / SPC) + 2)*2) / bps) + 1;
        /* find max root dir entries */
		if (nsect < 0x5000L)	maxdent = NUMEN;
		else maxdent = nsect / 80;
        maxdent = (maxdent + (bps/BPDIR -1)) & ~(bps/BPDIR -1);
        /* find max root dir size */
        maxdsiz = (maxdent * BPDIR) / bps + 1;

   		if (pno > 3)	{  /* they are extended partitions */
        /*-------------------------------------------------------*
         * Biggest possible header for a extended partition <in sectors> 
         *	=  Root sector + Boot Sector + 2 FATs + Root Dir	
         *-------------------------------------------------------*/
		 /* convert it back to 512 bps size */
        	hdrsiz = 1 + ratio + ((maxfsiz * 2) + maxdsiz) * ratio;
		} else
        /*-------------------------------------------------------*
         * Biggest possible header for a partition <in sectors>  *
         *	=  Boot Sector + 2 FATs + Root Dir		 *
         *-------------------------------------------------------*/
		 /* convert it back to 512 bps size */
        	hdrsiz = (1 + (maxfsiz * 2) + maxdsiz) * ratio;
    
	/*-----------------------------------------------------------------*
	 * Look for a chunk of sectors starting at "start" (or after, but  *
	 * as close as possible) which is big enough to hold the biggest   *
	 * possible header.						   *
	 *-----------------------------------------------------------------*/
	done = 0;   	/* assume correct location not found yet */
	moved = 0;
	while (!done) {
	    /*----------------------------------------------------------*
	     * Find out if header contains any bad sectors by checking	*
	     * range of sectors to be occupied by the header against	*
	     * the BSL.													*
	     *----------------------------------------------------------*/
		for (curr = 0; curr < hdrsiz; curr++)	{
			if (srchbsl(start+curr, entries) == YES)
				break;
		}
		if (curr < hdrsiz)	{	/* bad sector found in header */
			/* move header to start after the bad sector */
			moved += curr + 1;
			start += curr + 1;
		} else {
   			if ((ret = testhdr(pdev, start, hdrsiz)) < 0)
     			return ERROR;
			if (ret)	{	/* some bad sectors found in header */
				entries = nument(MEDIA);
				sortbsl(entries);
			} else {		/* all sectors belong ot header are good */
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
		if (ratio > 1)	{	/* big sector */
			start -= moved;
			moved = stbigsect(moved);
			start += moved;
		}
	    if (pno > 0) {
	        if (part[pno-1].p_siz + moved > disksiz)
		    	part[pno-1].p_siz = disksiz;
			else
			    part[pno-1].p_siz += moved;
		}
	        
	    /* Shrink size of current partition */
	    part[pno].p_siz -= moved;
	} 

	/* Where current partition should start */
	part[pno].p_st = start;

	/* add the waist sectors of big partition to the next partition */
	/* partition #3 in the pinfo is the last partition */
	/* partition # npart-1 in the pinfo is the last partition in 
		the extended partition */
	if ((pno != 3) && (pno != npart - 1) && 
					(part[pno].p_siz >= MB16))		{ /* big partition */
		temsect = part[pno].p_siz;
		if (pno > 3)	{ /* extended big partition */
   		part[pno].p_siz = ROOTSECT + bigsect(part[pno].p_siz-ROOTSECT);
		} else {	/* prime big partition */
   		part[pno].p_siz = bigsect(part[pno].p_siz);
		}
		remain = temsect - part[pno].p_siz;
		if (remain)	{
			part[pno+1].p_siz += remain;
			part[pno+1].p_st -= remain;
		}
	}

  }
    /* last existing partition has to sacrifice some space for the BSL	*/
    /* and the root sector of device.					*/
	if ((ext == 3) || ((!(part[2].p_flg & P_EXISTS)) &&
						(!(part[3].p_flg & P_EXISTS))))	{ 
		/* the last partition is inside the extended partitions */
		step = npart;
		/* the total extended partition should not inculde the bad sector */
		/* list and root sector */
		part[ext].p_siz -= (currbsiz + 1);
	} else {	/* the last partition is in the prime partitions */
		step = NPARTS;
	}
    for (pno = step-1; pno >= 0; pno--) {
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
                    part[pno].p_siz -= (bslsiz - currbsiz);
            }
        }
    }
  return OK;	/* everything is fine */
}


long stbigsect(amt)
long amt;

{
	long numsect;
	if (ratio > 1)	{
		numsect = (amt % ratio) ? (amt / ratio + 1) : (amt /ratio);
		return(numsect * ratio);
	} else {
		return(amt);
	}
}


long bigsect(amt)
long amt;

{
	if (ratio > 1)	{
		return((amt / ratio) * ratio);
	} else {
		return(amt);
	}
}

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
	/*
    over = mega % 10;
    if (over >= 5)
       mega += (10 - over);
    else
       mega -= over;
	*/
    itoa(mega, numbuf);
    strcpy(pr_id, numbuf);
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
    
    
    /* Get partition information from disk's root block.*/
    if ((ret = getroot(pdev, bs, (SECTOR)0)) != 0) {
    	if (tsterr(ret) != OK)
		    err(rootread);
		return (1);		/* return error but it is not a size too big */
    }

    disksiz = ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz;
    totsiz = 0;
    for (i = 0; i < NPARTS; i++) {
		if (xpinfo[i].p_flg & P_EXISTS)	{
        	totsiz += xpinfo[i].p_siz;
		}
    	if (totsiz > disksiz)
    	    return ERROR; 	/* size too big */
    }
    return OK;
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
    long size, pattern;
    extern long longrandom();
    extern int format;		/* flag */
    UWORD sectcnt, list;
    int ret, nbad, clean=1;
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
        return ret;
        
    if (!clean) {
    	/* write new bsl back to disk */
    	if (wrbsl(pdev) != OK) {
    	    return ERROR;
    	}
        return 1;
    }
        
    return OK;
}

long
cell(top, bottom)
long top;
long bottom;
{
	return ((top % bottom) ? (top / bottom + 1) :
			(top / bottom));
}


n2power(num)
UWORD num;
{
	UWORD power = 1;

	for (;;)	{
		if (num <= power )	{
			return (power);
		}
		power <<= 1;
	} 
}


DPART
*addr(index)
int index;
{
	DPART *temptr;
	int i;

	if (index < 0)	return nill;
	if (!index) return (headptr);
	temptr = headptr->next;
	for (i = 1; i < index; i++)	{
		temptr = temptr->next;
	}
	return (temptr);
}

DPART
*last()
{
	DPART *temptr;
	int i;

	if (!headptr) return (headptr);
	temptr = headptr;
	while (temptr->next)
		temptr = temptr->next;
	return (temptr);
}



creatmem(num)
int num;		/* number of block to malloc */
{
	DPART *temptr;
	DPART *last();
	int i;

	if (headptr == nill)	{
		if ((headptr = (DPART *)mymalloc((int)sizeof(DPART))) <= 0)	{;
			err(nomemory);
			if (headptr > 0) free(headptr);
			return ERROR;
		}
		headptr->next = nill;
		headptr->siz = 0L;
		headptr->flg = 0;
	}
	temptr = last();
	for (i = 0; i < num; i++)	{
		if ((temptr->next = (DPART *)mymalloc((int)sizeof(DPART))) <= 0)	{
			err(nomemory);
			if (headptr > 0) free(headptr);
			return ERROR;

		}
		temptr = temptr->next;
		temptr->next = nill;
		temptr->siz = 0L;
		temptr->flg = 0;
	}
}


dpart2part(extpart)
int extpart ;	/* set the extended pointer in the 4th place */
{
	int i;
	DPART *temptr;

	/* if npart > 4; need 1 more space for the extended partition */
	if (npart > 4)	{
		i = npart - extend;	/* the index that extended form the end of part. */
		npart += NPARTS-extpart;	/* add 1 extra space for the extended */
									/* partition and 0 or 1 or 2 space for */
									/* the prime partition in the root */
		extend = npart - i;	/* move 2 space for 2 prime partition in the root */
	} else {				/* set the extpart to -1 */
		npart = 4;
		extpart = -1;
		ext = NO_EXT;
	}
	if ((pinfo = (PART *)Malloc((long)sizeof(PART)*npart)) <= 0)	{
		err(nomemory);
		if (pinfo > 0) Mfree(pinfo);
		free(headptr);
		return ERROR;
	}
	inipart(pinfo, npart);  
	temptr = headptr;
	for (i = 0; i < npart; i++)		{
		if (!(temptr->flg & P_EXISTS)) {
			if (sizleft > 0) {
	            if (temptr->siz > sizleft) {
	            	pinfo[i].p_siz = sizleft;
	            }
	            sizleft -= temptr->siz;
	        }
	    } else {
			pinfo[i].p_siz = temptr->siz;
			pinfo[i].p_flg = P_EXISTS;
			if (i == extpart)	{
				pinfo[i].p_id[0] = 'X';
				pinfo[i].p_id[1] = 'G';
				pinfo[i].p_id[2] = 'M';
				pinfo[i].p_siz = 0L;
			} else if ((extpart == 1) && ((i == 2) || (i==3)))	{
				pinfo[i].p_flg = 0;
				pinfo[i].p_siz = 0L;
			} else if ((extpart == 2) && (i==3))	{
				pinfo[i].p_flg = 0;
				pinfo[i].p_siz = 0L;
			} else if (temptr->siz < MB16)	{
				pinfo[i].p_id[0] = 'G';
				pinfo[i].p_id[1] = 'E';
				pinfo[i].p_id[2] = 'M';
				temptr = temptr->next;
			} else {
				pinfo[i].p_id[0] = 'B';
				pinfo[i].p_id[1] = 'G';
				pinfo[i].p_id[2] = 'M';
				temptr = temptr->next;
			}
		}
	}
	free(headptr);
	if (extpart != NO_EXT)	{
		asmpart(extpart);
	}
	return OK;
}


asmpart(extpart)
int extpart ;	/* the extended partition pointer */
{
	int i;

	/* # of extened partition to add up */
	for (i = 4; i < extend; i++)		{
		pinfo[extpart].p_siz += pinfo[i].p_siz;
	}
	if (extpart == 3)	{
		return OK;		/* done */
	} else 	{
		/* put the last (npart-extend-1) partitions to */
		/* the 3rd or 4th place as prime partitions */
		i = extend;
		if (i < npart)	{
			pinfo[extpart+1].p_siz = pinfo[i].p_siz;
			pinfo[extpart+1].p_flg = P_EXISTS;
			if (pinfo[extpart+1].p_siz < MB16)	{
				pinfo[extpart+1].p_id[0] = 'G';
				pinfo[extpart+1].p_id[1] = 'E';
				pinfo[extpart+1].p_id[2] = 'M';
			} else {
				pinfo[extpart+1].p_id[0] = 'B';
				pinfo[extpart+1].p_id[1] = 'G';
				pinfo[extpart+1].p_id[2] = 'M';
			}
			pinfo[i].p_flg = 0;
			pinfo[i].p_siz = 0L;
			pinfo[i].p_id[0] = '0';
			pinfo[i].p_id[1] = '0';
			pinfo[i].p_id[2] = '0';
			npart--;
		} 
		if (i++ < npart)	{
			pinfo[extpart+2].p_siz = pinfo[i].p_siz;
			pinfo[extpart+2].p_flg = P_EXISTS;
			if (pinfo[extpart+2].p_siz < MB16)	{
				pinfo[extpart+2].p_id[0] = 'G';
				pinfo[extpart+2].p_id[1] = 'E';
				pinfo[extpart+2].p_id[2] = 'M';
			} else {
				pinfo[extpart+2].p_id[0] = 'B';
				pinfo[extpart+2].p_id[1] = 'G';
				pinfo[extpart+2].p_id[2] = 'M';
			}
			pinfo[i].p_flg = 0;
			pinfo[i].p_siz = 0L;
			pinfo[i].p_id[0] = '0';
			pinfo[i].p_id[1] = '0';
			pinfo[i].p_id[2] = '0';
			npart--;
		}
	}
}


part2dpart(numpart)
int numpart;
{

	int i;
	DPART *temptr;

	headptr = nill;
	if (creatmem(numpart) == ERROR) {
		return ERROR;
	}
	temptr = headptr;
	for (i = 0; i < numpart; i++) {
		if (pinfo[i].p_flg & P_EXISTS)	{
			temptr->siz = pinfo[i].p_siz;
			temptr->flg = P_EXISTS;
		} 
		temptr = temptr->next;
	}
}
