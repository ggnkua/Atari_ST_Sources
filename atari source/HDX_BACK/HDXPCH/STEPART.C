/*
 * Partition editing and picking.
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
#include "hdxpch.h"
#include "addr.h"
#include "myerror.h"
#include "ipart.h"

#define NULL 0L			/* the nill pointer */

extern long gbslsiz();
extern long bslsiz;
extern long disksiz;			/* size of disk in blocks */
extern int yesscan;			/* the flag for the func. IBMGPART use */
extern int npart;			/* number of partitions */
extern int ext;			/* the index that point to the extended partition */


/*
 * Global variables these routines communicate with
 *
 */
static PART *pinfo;		/* -> partition block */
static int formw, formh;
static int lx, ly, sx, sy;
long ratio, bps;
long nill = (long)NULL;


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

	disksiz = ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz;
	if (stgpart(dev, bs, (PART *)&pinfo) == ERROR)	{
		if (pinfo > 0) Mfree(pinfo);
		return ERROR;
	}
	*rpinfo = pinfo;
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

spheader(pdev, part)

int pdev;	/* physical device number */
PART *part;	/* partition info */

{
    /* Maximum sizes for FAT, root directory and header <in sectors> */
    long  maxdent;		/* max num entries in root dir */
    long  start;		/* starting sector number of a partition */
	long  psiz;
    UWORD maxfsiz, maxdsiz, hdrsiz;
	int  pno;			/* partition being dealt with */
	int  ret;			/* return code from testing header sectors */
	int	 spc;			/* sectors per cluster */
	long bigsect(), nsect;
	long temsect, remain;
	long cell();
    
    
    /* Determine actual sizes and starting sectors for all partitions */
    for (pno = 0; pno < npart; pno++) {
    	
    	/* Partition 0 starts right after root sect.  The rest starts right
    	   after its previous partition ???*/
		if (pno == 0)
		    start = 1 + bslsiz; 
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

	/* Where current partition should start */
	part[pno].p_st = start;

  }
  return OK;	/* everything is fine */
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


