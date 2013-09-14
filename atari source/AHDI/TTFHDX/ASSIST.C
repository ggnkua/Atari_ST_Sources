/* assist.c */
/* 
 * 14-Sep-1989	ml.	Use Rwabs() instead of hread() and hwrite().
 *			Will handle both SCSI and ACSI drives.
 */

#include <osbind.h>
#include <obdefs.h>
#include "fhdx.h"
#include "define.h"
#include "part.h"
#include "bsl.h"
#include "addr.h"
#include "lrwabs.h"


#define	MBUFSIZ		32		/* #blocks in read buffer */

extern SECTOR *badbuf;


/* 
 * Critical Error Handler:
 *	Always return -1L
 *
 */
long
crerr()
{
    return -1L;
}


/*
 * Fixup bad sector entries in the FATs;
 */
fixbadcls(ldev, fat0, fatsiz, data, nbad, sratio)
int ldev;		/* logical device */
SECTOR fat0, data;	/* log starting sector of FAT0 and data */
WORD fatsiz;		/* FAT size in # log sectors */
int nbad;		/* # bad sectors */
WORD sratio;		/* log sector size : phys sector size */
{
    long clno, numcl;
    int i, pdev;
    WORD *buf;
    SECTOR fat1;	/* physical starting sector# of 2nd FAT */
    SECTOR pstart;	/* physical starting sector# of partition */
    SECTOR pdata;	/* physical starting sector# of data */
    extern SECTOR logstart();
    extern LOGMAP logmap[];
    int ret;
    
    if((buf = (WORD *)Malloc((long)(fatsiz*sratio) << 9)) <= 0)
        return err(nomemory);
        
    pdev = ldev;
    fat0 *= sratio;	/* FAT0 starting sector # (in # phys sector) */
    fatsiz *= sratio;	/* FAT size in # phys sector */
    
    /* find phys dev # and FAT0 phys starting sector # */
    log2phys(&pdev, &fat0);
    pstart = logstart(ldev);
    pdata = (data * sratio) + pstart;
    numcl = ((logmap[ldev-'C'].lm_siz / sratio) - data) >> 1;
            
    ret = OK;	/* Assume everything is going to be OK */
    
    if (Lrwabs(PHYSREAD, buf, fatsiz, fat0, pdev+2) != 0) {
        ret = err(fatread);
        goto fixend;
    }

    for (i = 0; i < nbad; ++i) {
    	if ((clno = ((*(badbuf+i)-pdata)/sratio)>>1) >= numcl)
    	    continue;
	*(buf+clno+2) = 0xf7ff;		/* 0xfff0 in 8086-land */
    }

    /* find phys starting sector # of FAT1 */
    fat1 = fat0 + fatsiz;
    
    if (Lrwabs(PHYSWRT, buf, fatsiz, fat0, pdev+2) != 0 ||
    	Lrwabs(PHYSWRT, buf, fatsiz, fat1, pdev+2) != 0) {
    	ret = err(fatwrite);
    }
    
fixend:
    Mfree((long)buf);
    return ret;
}
