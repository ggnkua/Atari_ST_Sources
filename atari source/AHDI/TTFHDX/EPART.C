/* epart.c */

/*
 * 14-Sep-89	ml.	Modified to use Rwabs() instead of hread()
 *			and hwrite().  Will handle both SCSI and ACSI
 *			drives.
 * 21-Sep-89	ml.	Modified to handle big partitions (>=16Mb).
 */
 
#include <obdefs.h>
#include <osbind.h>
#include "fhdx.h"
#include "define.h"
#include "part.h"
#include "bsl.h"
#include "addr.h"
#include "lrwabs.h"

extern SECTOR *badbuf;
extern long bslsiz;

extern long maxpsiz;
static PART *pinfo;		/* -> partition block */

/*
 *  Place partition headers at the appropiate sectors.
 *	Input:
 *		pdev - physical device partitions belong to.
 *		part - partition structure containing the partitions'
 *		       information.
 *		spc - sectors per cylinder.
 *	Return:
 *		OK - if everything is fine.
 *		ERROR - error occurs when testing header sectors.
 *	Comments:
 *		Making sure that the headers occupy consecutive good 
 *	sectors.  If necessary, sizes of partitions are adjusted to 
 *	achieve this purpose.
 *		If any size adjustment make a partition bigger than
 *	the maximum size, the partition will be adjusted to the maximum
 *	size leaving the excessive sectors wasted.
 */
pheader(pdev, part, spc)
int pdev;	/* physical device number */
PART *part;	/* partition info */
int spc;
{
    /* Maximum sizes for FAT, root directory and header <in sectors> */
    long  maxdent;		/* max num entries in root dir */
    long  start;		/* starting sector number of a partition */
    long  entries, nument();	/* num entries in BSL */
    long  psiz, newsiz;		/* size of modified partition */
    unsigned int  maxfsiz, maxdsiz, hdrsiz, sratio;
    int  pno;			/* partition being dealt with */
    int  done;			/* tell if location of header is found */
    int  moved;			/* num sectors header has been moved */
    int  curr;			/* current sector of header being checked */
    int  ret;			/* return code from testing header sectors */
    long currbsiz;		/* BSL size b4 pheader is executed */
    
    /* Get the BSL ready for later */
    entries = nument(MEDIA);
    sortbsl(entries);
    currbsiz = bslsiz;		/* save current size of BSL */
    
    /* Determine actual sizes and starting sectors for all partitions */
    for (pno = 0; pno < NPARTS; pno++) {
    	
    	/* Check if partition exists.  If it doesn't, move on to next one */
    	if (!(part[pno].p_flg & P_EXISTS))
    	    continue;

    	/* Partition 0 starts right after the BSL.  The rest starts right
    	   after its previous partition */
	if (pno == 0)
	    start = 1 + currbsiz;
	else
	    start = part[pno-1].p_st + part[pno-1].p_siz;

	sratio = 1;		/* assume log sect size = phys sect size */
	psiz = part[pno].p_siz;	/* => partition size = # phys sector */
	
	/* 
	 * if partition is too big, double sector size until 
	 * number of log sectors <= maxpsiz 
	 */
	while ((psiz / sratio) > maxpsiz)
	    sratio <<= 1;
	    
	psiz /= sratio;		/* # log sectors in partition */
	
        /* Detail of calculations in part.c dopart() */
        /* find max FAT size */
        maxfsiz = ((psiz >> 1) + 2) / (256*sratio) + 1;
        /* find max root dir entries */
        maxdent = (part[pno].p_siz/ 80) + (sratio<<4 - 1) & ~(sratio<<4 - 1);
        /* find max root dir size */
        maxdsiz = maxdent / (16*sratio);
    
        /*--------------------------------------------------------------*
         * Biggest possible header for a partition <in # phys sectors> 	*
         *	=  Boot Sector + 2 FATs + Root Dir		 	*
         *--------------------------------------------------------------*/
        hdrsiz = sratio * (1 + (maxfsiz * 2) + maxdsiz);
    
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
	        if ((ret = testhdr(pdev, start, hdrsiz, spc)) < 0)
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
		part[pno-1].p_siz += moved;
	    }
	        
	    /* Shrink size of current partition */
	    part[pno].p_siz -= moved;
	}
	
	/* Where current partition should start */
	part[pno].p_st = start;
    }
    
    /* last existing partition has to sacrifice some 
       space for the BSL.				*/
    for (pno = NPARTS-1; pno >= 0; pno--) {
        if (part[pno].p_flg & P_EXISTS) {
	    part[pno].p_siz -= (currbsiz + 1);
	    break;
	}
    }

    /* have to move 1st GEM partition if BSL has been expanded,
       and shrink it's size too */
    if (bslsiz > currbsiz) {		/* BSL becomes bigger? */
        if (part[0].p_st == currbsiz + 1) {
	    part[0].p_st = bslsiz + 1;
	    part[0].p_siz -= (bslsiz - currbsiz);
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
 *		spc - sectors per cylinder.
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
testhdr(pdev, start, hdrsiz, spc)
int pdev;
SECTOR start;
unsigned int hdrsiz;
int spc;
{
    long olderr, crerr(), ret;
    long size, pattern;
    extern long longrandom();
    int sectcnt;
    int nbad, clean=1;
    SECTOR sect;
    char *buf;		/* buffer with test data */
    
    olderr = Setexc(0x101, crerr);	/* Handle critical error ourselves */
    
    size = (long)hdrsiz * 512;
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
    if (Lrwabs(PHYSWRT, buf, sectcnt, sect, pdev+2) != 0) {
    	clean = 0;
        
    	while (sectcnt) {
	    if (Lrwabs(PHYSWRT, 0L, 1, sect, pdev+2) != 0) {
    	        if (sect < spc) {
		    ret = err(cyl0bad);
		    goto wrapup;
		}
    	    	    
     	        *(badbuf+nbad) = sect;	/* store bad sector num */
     	        nbad++;
    	    	    
    	        /* buffer is filled up, have to add bad sectors
    	           found so far to the BSL before continuing.   */
    	        if (nbad == WARNBADSECTS) {
    	       	    if ((ret=addbsl(pdev, VENDOR, nbad)) < 0) {
			if (ret == INVALID)
			    err(cruptbsl);
    	       	        goto wrapup;
    	       	    }
    	       	    nbad = 0;	/* start counting again */
    	        }
    	    }
    	    sect++;
    	    sectcnt--;
    	}
        if (nbad) {	/* there are bad sectors found not added to BSL yet */
            if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
            	if (ret == INVALID)
            	    err(cruptbsl);
                goto wrapup; 
            }
        }
    }
    
    /* Try to read header's sectors */
    sectcnt = hdrsiz;
    sect = start;
    nbad = 0;
    if (Lrwabs(PHYSREAD, buf, sectcnt, sect, pdev+2) != 0) {
    	clean = 0;
        
    	while (sectcnt) {
	    if (Lrwabs(PHYSREAD, buf, 1, sect, pdev+2) != 0) {
    	        if (sect < spc) {
		    ret = err(cyl0bad);
		    goto wrapup;
		}
    	    	    
     	        *(badbuf+nbad) = sect;	/* store bad sector num */
     	        nbad++;
    	    	    
    	        /* buffer is filled up, have to add bad sectors
    	           found so far to the BSL before continuing.   */
    	        if (nbad == WARNBADSECTS) {
    	       	    if ((ret=addbsl(pdev, VENDOR, nbad)) < 0) {
			if (ret == INVALID)
			    err(cruptbsl);
    	       	        goto wrapup;
    	       	    }
    	       	    nbad = 0;	/* start counting again */
    	        }
    	    }
    	    sect++;
    	    sectcnt--;
    	}
        if (nbad) {	/* there are bad sectors found not added to BSL yet */
            if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
            	if (ret == INVALID)
            	    err(cruptbsl);
                goto wrapup; 
            }
        }
    }
wrapup:
    if (buf > 0L)  Mfree((long)buf);
    Setexc(0x101, olderr);
    
    if (ret < 0)
        return (int)ret;
        
    if (!clean) {
    	wrbsl(pdev);	/* write new bsl back to disk */
        return 1;
    }
        
    return OK;
}


