/* sect.c */

/*
 * 14-Sep-89	ml.	Modified to use Rwabs() instead of hread()
 *			and hwrite().  Will handle both SCSI and
 *			ACSI drives.
 */

#include <obdefs.h>
#include <osbind.h>
#include "fhdx.h"
#include "define.h"
#include "part.h"
#include "bsl.h"
#include "addr.h"
#include "lrwabs.h"

#define	ZBUFSIZ	0x4000		/* about 16k == 32 sectors */
#define	ZCOUNT	(ZBUFSIZ/0x200)	/* ZCOUNT = 32 */


/*
 * Logical-to-dev+partition mapping table.
 */
int nlogdevs;			/* # logical devices */
LOGMAP logmap[MAXLOGDEVS];	/* logical dev map */


/*
 * Rebuild logical-to-physical mapping
 * by reading and interpreting the root
 * blocks for all physical devs.
 *
 */
rescan()
{
    int dev, pdev, ret;
    char buf[512];
    int partno;
    PART partinfo[NPARTS];
    extern int scsixst;

    /* disable all logical and physical devs */
    for (dev = 0; dev < MAXLOGDEVS; ++dev)
	logmap[dev].lm_physdev = -1;

    /*
     * Scan all physical devs
     * and pick up partition structures.
     */
    nlogdevs = 0;
    pdev = 0;
    for (dev = 0; dev < MAXPHYSDEVS; ++dev)
    {
scan:
    	pdev += dev;
	if ((ret = getroot(pdev, buf)) < 0)
	    continue;
	else {
	    if (ret > 0) {
		if (getroot(pdev, buf))		/* try again */
		    continue;
	    }
	    gpart(buf, &partinfo[0]);
	    for (partno = 0; partno < NPARTS; ++partno)
		if (partinfo[partno].p_flg & P_EXISTS &&
		    partinfo[partno].p_siz != (SECTOR)0)
		{
		    if (nlogdevs >= MAXLOGDEVS)
			return err(manyldev);

		    logmap[nlogdevs].lm_physdev = pdev;
		    logmap[nlogdevs].lm_partno = partno;
		    logmap[nlogdevs].lm_start = partinfo[partno].p_st;
		    logmap[nlogdevs].lm_siz = partinfo[partno].p_siz;
		    ++nlogdevs;
	    	}   
	}
    }
    
    if (scsixst && pdev <= MAXPHYSDEV) {
    	pdev = 8;
    	dev = 0;
    	goto scan;
    }

    return OK;
}


/*
 * From a PHYSICAL device unit (0->15)
 * and a partition number (0->3), figure
 * out the LOGICAL disk number ('C'->'P').
 *
 * return the LOGICAL disk number or
 * ERROR if the PHYSICAL device doesn't exist.
 *
 */
phys2log(pdev, pno)
int  pdev;	/* physical device unit */
int  pno;	/* partition number (0 -> 3) */
{
    int logdev;		/* index to step through partitions of a phys unit */

    for (logdev = 0; logdev < MAXLOGDEVS; logdev++) {
    	if (logmap[logdev].lm_physdev == pdev &&
    	    logmap[logdev].lm_partno == pno)
    	    return ('C'+logdev);
    }
    return ERROR;
}


/*
 * Map block on logical device to
 * block on physical device;
 * return ERROR if the logical device
 * doesn't exist.
 */
log2phys(adev, ablk)
int *adev;
SECTOR *ablk;
{
    int dev;
    char xbuf[256];
    
    dev = *adev;
    if ((dev >= 0 && dev < MAXPHYSDEV) 
        || (dev >= 8 && dev < MAXPHYSDEV + 8)
        || (dev >= 16 && dev < MAXPHYSDEV + 16))
	return OK;

    dev = toupper(dev);
    if (dev >= 'C' && dev <= 'P')
    {
	dev -= 'C';
	*adev = logmap[dev].lm_physdev;
	*ablk = logmap[dev].lm_start + *ablk;
	return OK;
    }

    return ERROR;
}



/*
 * Return physical starting block# of a partition
 *
 */
SECTOR 
logstart(ldev)
int ldev;	/* logical device */
{
    ldev = toupper(ldev);
    if (ldev >= 'C' && ldev <= 'P') {
    	ldev -= 'C';
    	return (logmap[ldev].lm_start);
    }
    return ERROR;
}



/*
 * Return physical starting block# of a partition's data block.
 *
 */
SECTOR 
logend(ldev)
int ldev;	/* logical device */
{
    ldev = toupper(ldev);
    if (ldev >= 'C' && ldev <= 'P') {
    	ldev -= 'C';
    	return (logmap[ldev].lm_start+logmap[ldev].lm_siz-1);
    }
    return ERROR;
}


/*
 * Get dev's root block.
 *
 */
getroot(dev, buf)
int dev;
char *buf;
{
    return rdsect(dev, buf, (SECTOR)0);
}


/*
 * Put dev's root block.
 *
 */
putroot(dev, buf)
int dev;
char *buf;
{
    return wrsect(dev, buf, (SECTOR)0);
}


/*
 * Read sector from dev.
 *
 */
rdsect(dev, buf, sect)
int dev;
char *buf;
SECTOR sect;
{
    if (log2phys(&dev, &sect) < 0)
	return ERROR;

    if (Lrwabs(PHYSREAD, buf, (WORD)1, sect, (WORD)dev+2) != 0)
    	return ERROR;
    	
    return OK;
}


/*
 * Write sector to dev.
 *
 */
wrsect(dev, buf, sect)
int dev;
char *buf;
SECTOR sect;
{
    if (log2phys(&dev, &sect) < 0)
	return ERROR;

    if (Lrwabs(PHYSWRT, buf, (WORD)1, sect, (WORD)dev+2) != 0)
    	return ERROR;
    	
    return OK;
}


/*
 * Zero range of sectors on dev.
 *
 */
zerosect(dev, start, count)
int dev;
SECTOR start;
WORD count;
{
    char *zbuf;
    int i, v;

    if ((zbuf = (char *)mymalloc(ZBUFSIZ)) <= 0) {
        err(nomemory);
        return NOMEM;
    }
        
    if (log2phys(&dev, &start) < 0) {
    	free(zbuf);
	return ERROR;
    }

    for (i = 0; i < ZBUFSIZ; i += 4)
	*((long *)&zbuf[i]) = 0L;

    while (count)
    {
    	if (count > ZCOUNT)
    	    i = ZCOUNT;
    	else i = count;

	if ((v = Lrwabs(PHYSWRT, zbuf, i, start, dev+2)) != 0)
	    break;
	    
	start += i;
	count -= i;
    }
    free(zbuf);
    
    if (v != 0) return ERROR;
    return OK;
}
