/* sect.c */

/* 
 * Aug-23-88 jye. Change and add codes so that can be used for MS-DOS
 * Dec-20-89 jye. Free a bug that HDX gives a error message when CD-ROM 
 *				  is busy. 
 */

#include "obdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "hdx.h"
#include "addr.h"
#include "myerror.h"

#define	ZBUFSIZ	0x4000		/* about 16k == 32 sectors */
#define	ZCOUNT	(ZBUFSIZ/0x200)	/* ZCOUNT = 32 */
#define MAXUNITS 16			/* max number of logical units */

extern long ostack;		/* old stack pointer */
extern UWORD errcode();		/* function to return error code */
extern int yesscan;		/* the flag for the func. IBMGPART use */
extern int npart;		/* the number of partitions */
extern int ext;			/* the index of extended partition */
extern int needscan;	/* TRUE: if it is the first time to scan the units */
extern int athead;		/* the # of data heads on the AT drive */
extern int atcyl;		/* the # of cylinders on the AT drive */
extern int atspt;		/* the # of sectors per track on the AT drive */
/*
 * Logical-to-dev+partition mapping table.
 */
int nlogdevs;				/* # logical devices */
LOGMAP logmap[EXTRALOGD];	/* logical dev map */
int livedevs[1];	/* live devs flags; 1: device is alive */
int atexst;					/* AT drive exists */
int typedev = 0x0000;
int typedrv = 0x0000;


/*
 * Rebuild logical-to-physical mapping
 * by reading and interpreting the root
 * blocks for all physical devs.
 *
 */

rescan(flag, znm)

int flag;	/* 0: don't report medium change error; */
			/* non-0: report medium change error; */
int znm;    /* 1: do zero & markbad; 0: do partition & format */

{
    int dev=0;
    char buf[512];
    int partno, ret, i;
    PART *partinfo;

	ostack = Super(NULL);	/* set supervice mode */
	delay();
	if ((atexst = chkat()))	{ /* AT drive exist */
		if ((ret = identify(dev, buf)) == OK)	{
			atcyl = getword(buf+2);
			athead = getword(buf+6);
			atspt = getword(buf+12);
		} else { 
    		delay();
    		Super(ostack);
	        return ERROR;
    	}
	}
	delay();
	Super(ostack);
    /* disable all logical and physical devs */
    for (dev = 0; dev < EXTRALOGD; ++dev)
		logmap[dev].lm_physdev = -1;

    /*
     * Scan all physical devs
     * and pick up partition structures.
     */
    nlogdevs = 0;
	dev = 0;

		if (getroot(dev, buf, (SECTOR)0) != 0)	{
			return(ERROR);
		}

	   	livedevs[dev] = 1;
		yesscan = 1;
		if (stgpart(dev, buf, (PART *)&partinfo) == ERROR)	{
			return ERROR;
		}
		if (ext != NO_EXT)	{
			sortpart(partinfo,SCAN_BS); 
		}
	    for (partno = 0; partno < npart; ++partno) {
	        if ((partinfo[partno].p_flg & P_EXISTS) &&
		    	(partinfo[partno].p_siz != (SECTOR)0) &&
		    	(((partinfo[partno].p_id[0] == 'G') &&
		    	 (partinfo[partno].p_id[1] == 'E') &&
		    	 (partinfo[partno].p_id[2] == 'M'))   ||
		 		((partinfo[partno].p_id[0] == 'B') &&
		    	 (partinfo[partno].p_id[1] == 'G') &&
		    	 (partinfo[partno].p_id[2] == 'M'))))   
	        {
				if (nlogdevs > EXTRALOGD)	{
					continue;
				}
				logmap[nlogdevs].lm_physdev = dev;
				logmap[nlogdevs].lm_partno = partno;
				logmap[nlogdevs].lm_start =  partinfo[partno].p_st;
				logmap[nlogdevs].lm_siz = 	 partinfo[partno].p_siz;
		    	++nlogdevs;
	        }
	    }
	if (partinfo > 0)	Mfree(partinfo);

    return OK;
}

/* rerange the partition informations. */

 sortpart(pinfo, type)
 PART *pinfo;
 int type;				/* USER_ED = 1: for user interface use */
 						/* SCAN_BS = 0: for rescan() and laybs() use */
 {
 	int i, j, k;
	PART rpart[2];

	if (ext == NO_EXT) return OK;	/* don't need sort */
	for (i = 0; i < 2; i++)	{ /* initialize the temple space */
		rpart[i].p_flg = 0L;
		rpart[i].p_st = 0L;
		rpart[i].p_siz = 0L;
		for (k = 0; k < 3; k++)
			rpart[i].p_id[k] = '0';
	}
	/* save the partitions that after the extened partitions */
	for (i = ext+1, j=0; i < 4; i++, j++)		{
		if (pinfo[i].p_flg & P_EXISTS)	{
			rpart[j].p_flg = P_EXISTS;
			rpart[j].p_st = pinfo[i].p_st;
			rpart[j].p_siz = pinfo[i].p_siz;
			for (k = 0; k < 3; k++)
				rpart[j].p_id[k] = pinfo[i].p_id[k];
		} 
	}
	/* move the extened partition to the front */
 	for (i=4, j = ext; i < npart; i++, j++)	{
		if (pinfo[i].p_flg & P_EXISTS)	{
			pinfo[j].p_flg = P_EXISTS;
			pinfo[j].p_st = (type)?(pinfo[i].p_st):(pinfo[i].p_st + ROOTSECT);
			pinfo[j].p_siz = (type)?(pinfo[i].p_siz):(pinfo[i].p_siz-ROOTSECT);
			for (k = 0; k < 3; k++)
				pinfo[j].p_id[k] = pinfo[i].p_id[k];
		} else { j--;}	/* stay with that space */
	}
	/* copy the not extended partitions back after the extended partitions */
 	for (i=0; i < 2; i++, j++)	{
		if (rpart[i].p_flg & P_EXISTS)	{
			pinfo[j].p_flg = P_EXISTS;
			pinfo[j].p_st = rpart[i].p_st;
			pinfo[j].p_siz = rpart[i].p_siz;
			for (k = 0; k < 3; k++)
				pinfo[j].p_id[k] = rpart[i].p_id[k];
		} else {j--;}
	}
	for (i = j; i < npart; i++)	{ /* set the rest to 0 */
		pinfo[i].p_flg = 0L;
		pinfo[i].p_st = 0L;
		pinfo[i].p_siz = 0L;
		for (k = 0; k < 3; k++)
			pinfo[i].p_id[k] = '0';
	}
}



/*
 * From a PHYSICAL device unit (0->7)
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

    for (logdev = 0; logdev < EXTRALOGD; logdev++) {
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
    if (dev >= 0 && dev <= 17)
	return OK;

    dev = toupper(dev);
    if (dev >= 'C' && dev <= 
				('C'+EXTRALOGD)) /* from C to 't' are 50 logic device */
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
    if (ldev >= 'C' && ldev <= 
				('C'+EXTRALOGD)){/*from C to 't' are 50 logic device */
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
    if (ldev >= 'C' && ldev <= 
				('C'+EXTRALOGD)){/*from C to 't' are 50 logic device */
    	ldev -= 'C';
    	return (logmap[ldev].lm_start+logmap[ldev].lm_siz-1);
    }
    return ERROR;
}


#define	MFM 17		/* sectors per track for MFM */
#define	RLL 26		/* sectors per track for RLL */



/*
 * Chkparm()
 *	Check if given logical device has the asssumed parameters.
 * Assumptions are:
 *	- 512 bytes/sector
 *	- 2 sectors/cluster
 *	- 1 reserved sector
 *	- 2 FATs
 *
 * Input:
 *	ldev - logical device number ('C' -> 'P').
 *
 * Return:
 *	OK - parameters of partition match the assumptions
 *	ERROR - something went wrong.
 *
 * Comment:
 *	Number of FATs is assumed to be 2.  Cannot check this 
 * because previous version of HDX did not put that in the boot
 * sector.
 */
chkparm(ldev)
int ldev;
{
    char bs[512];	    /* boot sector */
    BOOT *boot;		    /* boot structure */
    UWORD bps, res, siz;    /* bytes/sector, num reserved sectors, ldev size */
    int ret;

    if ((ret = rdsects(ldev, 1, bs, (SECTOR)0)) != 0) {
    	goto parmend;
    }    

    boot = (BOOT *)bs;
    gw((UWORD *)&boot->b_bps, &bps);	/* what is number bytes/sector? */
    gw((UWORD *)&boot->b_res, &res);	/* what is num of reserved sectors? */
    gw((UWORD *)&boot->b_nsects, &siz);	/* what is size of partition */
    if (bps % BPS			/* bytes per sector == ratio of 512 ? */
	|| res != 1) {			/* num sectors reserved == 1 ? */
	ret = ERROR;			/* Nope, different from assumptions */
	goto parmend;
    }
    
    /* Check if sectors per cluster make sense */
    if (boot->b_spc != 2) {
    	ret = ERROR;
    	goto parmend;
    }
    
    ret = OK;				/* If yes, return OK */

parmend:
    return ret;
}


/*
 * Get dev's root block.
 *
 */
getroot(dev, buf, sect)
int dev;
char *buf;
SECTOR sect;
{
    return rdsects(dev, 1, buf, sect);
}


/*
 * Put dev's root block.
 *
 */
putroot(dev, buf, sect)
int dev;
char *buf;
SECTOR sect;
{
    return wrsects(dev, 1, buf, sect);
}


/*
 *  Read sector(s) from dev.
 *
 *  Input:
 *	dev - device number (logical or physical).
 *	num - number of sectors to read.
 *	buf - buffer to write data read.
 *	sect - starting sector number to read from.
 *
 *  Return:
 *	errnum - 0: if read is successful.
 *		 an error code: if read is unsuccessful.
 */
rdsects(dev, num, buf, sect)
int dev;			/* device number (logical or physical) */
UWORD num;			/* number of sectors to read */
char *buf;
SECTOR sect;			/* starting sector to read from */
{
    int errnum;

    if (log2phys(&dev, &sect) < 0)
	return ERROR;

    ostack = Super(NULL);
		errnum = ideread(athead, atspt, sect, num, buf, (UWORD)dev);
    delay();
    Super(ostack);

    if (errnum > 0) {
    	return ERROR;
    }
        
    return errnum;		/* return the error code */
}


/*
 *  Write sector(s) to dev.
 *
 *  Input:
 *	dev - device number (logical or physical).
 *	num - number of sectors to write.
 *	buf - buffer with data to be written.
 *	sect - starting sector number to write to.
 *
 *  Return:
 *	errnum - 0: if write is successful.
 *		 an error code: if write is unsuccessful.
 */
wrsects(dev, num, buf, sect)
int dev;			/* device number (logical or physical */
UWORD num;			/* number of sectors to write */
char *buf;			/* buffer with data to be written */
SECTOR sect;			/* starting sector to write to */
{
    int errnum;

    if (log2phys(&dev, &sect) < 0)
	return ERROR;

    ostack = Super(NULL);
		errnum = idewrite(athead, atspt, sect, num, buf, (UWORD)dev);
    delay();
    Super(ostack);

    if (errnum > 0) {
        return ERROR;
    }

    return errnum;
}


/*
 * Zero range of sectors on dev.
 *
 */
zerosect(dev, start, count)
int dev;
SECTOR start;
UWORD count;
{
    char *zbuf;
    int  v;
    UWORD i;

    if ((zbuf = (char *)mymalloc(ZBUFSIZ)) <= 0)
        return ERROR;
        
    if (log2phys(&dev, &start) < 0) {
    	free(zbuf);
	return ERROR;
    }

    fillbuf(zbuf, (long)ZBUFSIZ, 0L);

    while (count)
    {
    	if (count > ZCOUNT)
    	    i = ZCOUNT;
    	else i = count;

	if ((v = wrsects(dev, i, zbuf, start)) != 0)
	    break;
	start += i;
	count -= i;
    }
    free(zbuf);
    
    return v;
}
