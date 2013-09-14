/* sect.c */

/* 
 * Aug-12-89 jye. Change and add codes so that can be used for MS-DOS
 * Dec-22-89 jye. Fixed a bug that HDX return a error message in the
 *				  partitioning dialog box when the CD-ROM is busy.
 *				  The correction is in rescan().
 */

#include "obdefs.h"
#include "osbind.h"
#include "defs.h"
#include "part.h"
#include "hdx.h"
#include "addr.h"
#include "error.h"

#define	ZBUFSIZ	0x4000		/* about 16k == 32 sectors */
#define	ZCOUNT	(ZBUFSIZ/0x200)	/* ZCOUNT = 32 */
#define MAXUNITS 16			/* max number of logical units */

#define PUNINFO struct _punifno
PUNINFO {
		WORD puns;	/* number of physical units */
		BYTE pun[MAXUNITS];
		LONG partition_start[MAXUNITS]; /* offset to partition on */
										/* physical unit */
};
extern long ostack;		/* old stack pointer */
extern UWORD errcode();		/* function to return error code */
extern int yesscan;		/* the flag for the func. IBMGPART use */
extern long sptrk;		/* the sector per track */
extern int npart;		/* the number of partitions */
extern int ext;			/* the index of extended partition */
extern int extend;		/* the index of end extended partition */
extern int showmany;	/* the flag for show the too many device alert box */


/*
 * Logical-to-dev+partition mapping table.
 */
int nlogdevs;			/* # logical devices */
LOGMAP logmap[EXTRALOGD];	/* logical dev map */
int livedevs[MAXPHYSDEVS];	/* live devs flags; 1: device is alive */
char typedev = 0x00;		/* if the bit set, that bit is mean that */
							/* driver is a removable driver */


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
    int dev, scan=0;
    char buf[512];
	char sendata[16];
    int partno, ret, inqret, i;
    PART *partinfo;
	char mask = 0x80;	/* 7th bit is set on */
	char setmask;

    /* disable all logical and physical devs */
    for (dev = 0; dev < EXTRALOGD; ++dev)
	logmap[dev].lm_physdev = -1;

    for (dev = 0; dev < MAXPHYSDEVS; ++dev)
	livedevs[dev] = 0;

    /*
     * Scan all physical devs
     * and pick up partition structures.
     */
    nlogdevs = 0;
	showmany = 0;
    for (dev = 0; dev < MAXPHYSDEVS; ++dev)
    {
		/* initialize the buffer */
		for (i = 0; i < 16; i++)		{
			sendata[i] = 0;
		}

		/* check see the drive is a what kind of drive */
   		ostack = Super(NULL);
		inqret = inquiry(dev, sendata);
   		delay();
   		Super(ostack);
		if (inqret & 0x08)	{	/* the device is busy */
			continue;
		}
		/* ret not = ok, it may be a regular hard drive */
		if (inqret == OK)	{ /* it is not a regular hard drive */
			if (sendata[0])	{ 	/* it is not a hard drive */
				continue;
			}
		}
		setmask = 0x01;
    	if ((ret = getroot(dev, buf, (SECTOR)0)) < 0) {
			if (znm)  rangelog(dev);
	    	continue;
		} else {		/* ret >= 0 */
		    if (ret > 0) {
	    	    if (flag) {	/* if non-0, report error if medium changed */
	    	        if (tsterr(ret) == OK)
	    	            return ERROR;
	    	    }
	    	    if ((ret = getroot(dev, buf, (SECTOR)0))) {	/* try again */
			    	if (ret > 0 && flag && tsterr(ret) == OK)	{
						return ERROR;
					} else if ((ret > 0) && (!flag))	{
						if ((inqret == OK) && (sendata[1] & mask))	{ 
							/* it is a removable drive */
							/* but forget insert the cartridge */
							err(instdrv);
							return ERROR;
						}
					}
					if (znm)	{
						rangelog(dev);
					}
					continue;
				}
	    	}

			if ((inqret == OK) && (sendata[1] & mask))	{ 
				/* it is a removable drive */
				/* set the relative bit, */ 
				/* 1 is a removable, other is not */
				typedev |= setmask << dev;
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
				if (nlogdevs == MAXLOGDEVS)		 {
					showmany = 1;
				}
	        }
	    }
	}
	inipart(partinfo, npart);
	if (partinfo > 0)	Mfree(partinfo);
    }
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
	/* move the extened partition to the frant */
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
 * check to find out the exist of device
 */

rangelog(dev)

int dev;

{
	PUNINFO *divinfo;
	int devnum;

	ostack = Super(NULL);
	divinfo = ((PUNINFO *) *((long *)(0x516)));
	for (devnum = 0; devnum < MAXUNITS; ++devnum)	{
		if ((int)(divinfo->pun[devnum] & 0x07) == dev)	{
			delay();
			nlogdevs++;
		}
	}
	Super(ostack);
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
    if (dev >= 0 && dev <= 7)
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
 * Check if dev's root block is intact.
 * Return number of sectors per track on disk.
 *
 */
chkroot(dev, bs)
int dev;
char *bs;
{
    extern long get3bytes();
    SETMODE *mb;
    int i, ret;
    int cyl, head;
    SECTOR size, msiz;	/* size of media */
    char buf[512], sendata[16];
    long dmaptr, tmpptr;
    char *dmahigh=0xffff8609,
         *dmamid=0xffff860b,
         *dmalow=0xffff860d;
    
    size = ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz;
    
    ostack = Super(NULL);
    
    /* Get format parameters/ disk size from media */
    ret = md_sense(dev, sendata);
    delay();
    Super(ostack);
    
    if (ret != 0) {
		ret = errcode(dev);
		if (tsterr(ret) != OK) 
	        return ERROR;
		return (-3);	/* don't have to show the alert box */
    }
    
    /* check what kind of sense data it returned  */
    /* If full SCSI, will return number of blocks */
    /* on disk at byte 5, 6 and 7.  If Adaptec,   */
    /* will return 0 for number of blocks on disk */
    /* on SCSI. */
    
    if (!(msiz = get3bytes(sendata+5))) {	/* no disk size returned? */
    	/* Yup, ie., it's adaptec's.  Interpret as SETMODE structure */
    	mb = (SETMODE *)sendata;
	/* get number of cylinders */
	cyl = mb->smd_cc[0];
	cyl <<= 8;
	cyl |= mb->smd_cc[1];
    
	/* get number of heads */
	head = mb->smd_dhc;
    
	msiz = (SECTOR)head * (SECTOR)cyl * MFM;
    
	for (i = 0; i < 20; i++) {
	    if ((ret = rdsects(dev, 1, buf, msiz+i)) == OK) {
	    
		/* find out whether data has been transferred, by
	   	   checking if dma pointer has been moved.	  */

	   	ostack = Super(NULL);	/* get into Supervisor mode */
	   	
		dmaptr = *dmahigh;
		dmaptr &= 0x0000003f;
		dmaptr <<= 16;
		tmpptr = *dmamid;
		tmpptr &= 0x000000ff;
		tmpptr <<= 8;
		dmaptr |= tmpptr;
		tmpptr = *dmalow;
		tmpptr &= 0x000000ff;
		dmaptr |= tmpptr;
		
	        delay();
	        Super(ostack);		/* back to user mode */
	        
		if (dmaptr != buf)
		    break;
	    } else {			/* rdsects return an error */
		if (tsterr(ret) == OK) {
	            break;
		}
    	    }
        }
    
	if (ret == MDMCHGD)		/* check if error occurred */
	    return (ret);
       
	/* Determine if media is MFM or RLL */
	if (i < 20)
	    msiz = (SECTOR)head * (SECTOR)cyl * RLL;
    }
        
    if (size != msiz)
        ret = ERROR;
    else 
        ret = OK;
        
    return (ret);
}


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
    	if (tsterr(ret) != OK)
    	    err(bootread);
    	ret = ERROR;
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


ichkparm(ldev)
int ldev;
{
    char bs[512];	    /* boot sector */
    BOOT *boot;		    /* boot structure */
    UWORD bps, res, siz;    /* bytes/sector, num reserved sectors, ldev size */
    int ret;

    if ((ret = rdsects(ldev, 1, bs, (SECTOR)0)) != 0) {
    	if (tsterr(ret) != OK)
    	    err(bootread);
    	ret = ERROR;
    	goto parmend;
    }    

    boot = (BOOT *)bs;
    gw((UWORD *)&boot->b_bps, &bps);	/* what is number bytes/sector? */
    gw((UWORD *)&boot->b_res, &res);	/* what is num of reserved sectors? */
    gw((UWORD *)&boot->b_nsects, &siz);	/* what is size of partition */
    if (bps != 512			/* bytes per sector == 512 ? */
	|| res != 1) {			/* num sectors reserved == 1 ? */
	ret = ERROR;			/* Nope, different from assumptions */
	goto parmend;
    }
    
    /* Check if sectors per cluster make sense */
    if ((siz >= 0x8000L && boot->b_spc != 4) ||
    	(siz < 0x8000L && boot->b_spc != 2)) {
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
    errnum = hread(sect, num, buf, (UWORD)dev);
    delay();
    Super(ostack);

    if (errnum > 0) {
    	errnum = errcode(dev);
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
    errnum = hwrite(sect, num, buf, (UWORD)dev);
    delay();
    Super(ostack);

    if (errnum > 0) {
        errnum = errcode(dev);
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
        return err(nomemory);
        
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
