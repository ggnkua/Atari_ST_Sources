/*
 * Partition editing and picking.
 *
 * 09-Dec-87	ml.	Added pheader() to take care of placing partition
 *			headers at good sectors.
 * 14-Jan-88	ml.	Added chkpart() to make sure partition scheme does
 *			not map pass end of device.
 * 02-Dec-88 	jye. Change and add codes so that can be used for MS-DOS
 *
 * 12-Dec-89	jye. Fixed a bug in stuffamt() so that correctly show three
 *				digits or more in the partitioning deialog box.
 */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "bsl.h"
#include "hdx.h"
#include "addr.h"
#include "myerror.h"

#define ROLL1 1			/* move the bar one step */
#define ROLL4 4			/* move the bar four steps */
#define NULL 0L			/* the nill pointer */

extern int wdesk;
extern int hdesk;
extern long gbslsiz();
extern long bslsiz;
extern SECTOR badbuf[];		/* bad sectors buffer */
extern long ostack;
extern long sptrk;				/* sector per track */
extern long disksiz;			/* size of disk in blocks */
extern int yesscan;			/* the flag for the func. IBMGPART use */
extern int npart;			/* number of partitions */
extern int ext;			/* the index that point to the extended partition */
extern int extend;		/* the index that point to the end of extended */
extern char ttscsi;		/* 1: SCSI bus drive */


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
    extern int tformat;		/* flag */
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
    	            if (tformat == TRUE)
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
            if (tformat == TRUE)
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
            	    if (tformat == TRUE)
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
            if (tformat == TRUE)
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


