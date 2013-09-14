/* zero.c */

/* 16-Mar-88  ml.	split up assist.c into this and markbad.c	*/
/* 11-Dec-87  ml.	added BSL concept to zero().			*/
/* 01-Nov-88  jye.  change add codes so that can be used for MS-DOS */


#include "osbind.h"
#include "obdefs.h"
#include "defs.h"
#include "part.h"
#include "bsl.h"
#include "addr.h"


extern long gbslsiz();
extern long bslsiz;
extern BYTE *bsl;
extern long ratio;


/*           
 * Zero logical dev
 *
 */
zero(ldev)
int ldev;
{
    UWORD pdev,ndirs, fatsiz;
	UWORD bps;
    SECTOR fat0, data, size, dummy=0;
    char bs[512];
    char *newbs;
    BOOT *boot;
    int  bootsiz, i, ret;
    
    if ((ret = rdsects(ldev, 1, bs, (SECTOR)0)) != 0) {
    	if (tsterr(ret) != OK)
	    	err(bootread);
		return ERROR;
    }

    /*
     * Zero file system's boot sector, FAT and DIR sectors.
     */
    boot = (BOOT *)bs;
    gw((UWORD *)&boot->b_ndirs[0], &ndirs);
    gw((UWORD *)&boot->b_spf[0], &fatsiz);
    gw((UWORD *)&boot->b_bps[0], &bps);
	ratio = (long)(bps / BPS);
	size = (long)BPS * ratio;
	if ((newbs = (char *)Malloc(size)) <= 0)	{
		err(nomemory);
		if (newbs > 0) Mfree((long)newbs);
		return ERROR;
	}
    
    if ((ret = zerosect(ldev, (SECTOR)0, 
					(1 + fatsiz*2 + ndirs*BPDIR/bps)*((UWORD)ratio))) != 0) {
    	if (tsterr(ret) != OK)
            err(hdrwrite);
        return ERROR;
    }
	     

    /* Put boot information into new boot sector */
    if ((ret = rdsects(ldev, (UWORD)ratio, newbs, (SECTOR)0)) != 0) {
    	if (tsterr(ret) != OK)
            err(bootread);
        return ERROR;
    }
    bootsiz = sizeof(BOOT);        
    for (i = 0; i < bootsiz; i++)
        newbs[i] = bs[i];
    
	/* put the last long word data into the new boot sector */
	*(long *)&newbs[508] = *(long *)&bs[508];

    /* Write boot information back to disk */
    if ((ret = wrsects(ldev, (UWORD)ratio, newbs, (SECTOR)0)) != 0) {
    	if (tsterr(ret) != OK)
            err(bootwrit);
        return ERROR;
    }
        
    /*
     * Make first 2 entries in FATs more IBM-like.
     */
    if ((ret = rdsects(ldev,(UWORD)ratio,newbs,ratio)) != 0) {/* read FAT 0 */
		return ERROR;
    }
    *(UWORD *)&newbs[0] = 0xf8ff;
    *(UWORD *)&newbs[2] = 0xffff;
    
    /* write FAT 0 and FAT 1 */
    if ((ret = wrsects(ldev, (UWORD)ratio, newbs, ratio)) != 0
	|| (ret = wrsects(ldev, (UWORD)ratio, newbs, 
				(SECTOR)((1+fatsiz)*ratio))) != 0) {
	if (tsterr(ret) != OK)
	    err(fatwrite);
	return ERROR;
    }
	    
    pdev = ldev;
    log2phys(&pdev, &dummy);
    
    /* Get size of BSL */
    if ((bslsiz = gbslsiz(pdev)) > 0L) {
    	/* Allocate memory for existing BSL */
    	if ((bsl = (BYTE *)mymalloc((int)bslsiz << 9)) <= 0)
    	    return err(nomemory);
    	    
    	/* Read in BSL */
    	if ((dummy = rdbsl(pdev)) != OK) {
    	    free(bsl);
    	    if (dummy = INVALID)
    	        err(cruptbsl);
    	    return ERROR;
    	}
    	
	fat0 = ratio;
	data = (SECTOR)1 + (SECTOR)fatsiz*2 + (SECTOR)(ndirs*BPDIR/bps);
	
        /* Mark Vendor or User Bad Sectors into FAT */
	if (bsl2fat(ldev, fat0, fatsiz*((UWORD)ratio), data*ratio, MEDIA) != OK) {
            free(bsl);
            return ERROR;
        }
	free(bsl);
    }
	if (newbs > 0)	Mfree((long)newbs);
    return OK;
}

