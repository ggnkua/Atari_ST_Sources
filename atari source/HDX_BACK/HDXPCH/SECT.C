/* sect.c */

/* 
 * Aug-23-88 jye. Change and add codes so that can be used for MS-DOS
 * Dec-20-89 jye. Free a bug that HDX gives a error message when CD-ROM 
 *				  is busy. 
 * Feb-11-93 jye. changed the size of the 'sentdate' buff to 56 bytes 
 *				  for the 'inquiry', this will fit some hard drives. (Ex.
 *				  IBM OME 0663E15)
 * May-10-93 jye. Fix a bug that can't format or partition any externally
 *				  connected SCSI drive if the Falcon has no internal hard-
 *				  disk. Added codes in rescan()
 */

#include "obdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "hdxpch.h"
#include "addr.h"
#include "myerror.h"

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
extern char ttscsi;		/* the flag for SCSI if set */
extern char spscsixst;	/* set for the sparrow scsi exist */
extern int needscan;	/* TRUE: if it is the first time to scan the units */
extern int athead;		/* the # of data heads on the AT drive */
extern int atcyl;		/* the # of cylinders on the AT drive */
extern int atspt;		/* the # of sectors per track on the AT drive */
extern int noacsi;		/* set for no ACSI drive in the system */
extern char slwacsi;	/* 1: set for slow acsi device */
extern char *drvid[];	/* for the id of the devices */
/*
 * Logical-to-dev+partition mapping table.
 */
int nlogdevs;				/* # logical devices */
LOGMAP logmap[EXTRALOGD];	/* logical dev map */
int livedevs[MAXPHYSDEVS];	/* live devs flags; 1: device is alive */
int idevs[16];				/* the devs have id flags; 1: device has id */
int typedev = 0x0000;		/* if set, driver is a removable driver */
int typedrv = 0x0000;		/* if set, driver is a SCSI driver */
int atexst;					/* AT drive exists */
int slvexst;				/* AT slave drive exists */
char useblit;				/* set for it is not the stbook drive */
int floptical=0;			/* set if it a floptical drive */


/*
 * Rebuild logical-to-physical mapping
 * by reading and interpreting the root
 * blocks for all physical devs.
 *
 */

rescan(flag, fnp)

int flag;	/* 0: don't report medium change error; */
			/* non-0: report medium change error; */
int fnp;    /* 0: do zero & markbad; 1: do format & ship; 2: do part */

{
    int dev, scan=0;
    char buf[512];
	char sendata[56];
    int partno, ret, inqret, i;
    PART *partinfo;
	char mask = 0x80;	/* 7th bit is set on */
	int setmask;
	int maxloop;

	noacsi = 1;				/* assume there is no ACSI in the system */
	ostack = Super(NULL);	/* set supervice mode */

	ttscsi = chkscsi();		/* check if SCSI exists */
	spscsixst = chksp();	/* check if sparrow scsi exists */
	delay();
	if ((atexst = chkide()))	{ /* AT drive exist */
		if (stbook())	{
			useblit = 0;
		} else {
			useblit = chkblit();
		}
		if ((ret = identify(16, buf)) == OK)	{
			delay();
			/* in byte 54 of the buf having the drive's id */
			gdrvid(16, &buf[54], drvid[16]);
			/* return the number of cylinder, head, spt */
			gparmfc(&atcyl, &athead, &atspt, buf);
		} else { 
			if (ret == -1)	{ /* May-10-93: fix a bug by adding these codes */
				/* The bug is when Falcon without a ide drive, it will return
				   a timeout, so now I will continue the process instead of 
				   tread it as a error */
				drvid[16] = drvid[18];
				goto jjj;
			}
    		delay();
    		Super(ostack);
			ret = errcode(16);
			if (tsterr(ret) != OK) 
	    	    return ERROR;
			return (-3);	/* don't have to show the alert box */
    	}
	}
jjj:
	delay();
	Super(ostack);
	/* set the scent message box */
	if ((needscan) && ((ttscsi)||(spscsixst)))
		dsplymsg(scanmsg);

    /* disable all logical and physical devs */
    for (dev = 0; dev < EXTRALOGD; ++dev)
		logmap[dev].lm_physdev = -1;

    for (dev = 0; dev < MAXPHYSDEVS; ++dev)
		livedevs[dev] = 0;

	/* set all devices have no id */
	for(i=0; i < 16; i++)	{
		idevs[i] = 0;
	}

    /*
     * Scan all physical devs
     * and pick up partition structures.
     */
    nlogdevs = 0;
	showmany = 0;
	slwacsi = 0;
	if (atexst)	{
		maxloop = 18;
		dev = 16;
	} else if ((ttscsi)||(spscsixst))	{
		if (spscsixst)	{
			slwacsi = 1;
		} 
		maxloop = 16;
		dev = 8;
	} else {
		maxloop = 8;
		slwacsi = 1;
		dev = 0;
	}
rerescan:
    for (; dev < maxloop; ++dev)
    {

		if (((dev == 16) && atexst) || ((dev == 17) && slvexst))	{
			if ((ret = getroot(dev, buf, (SECTOR)0)) != 0)	{
				if (ret == -1)	{ /* May-10-93: to fix a bug that can't format
									 in the Falcon without a ide drive */
					/* it is timeout or without a ide drive in Falcon */
					goto noidedr;
				}
				if (tsterr(ret) != OK)	
					err(rootread);
				slwacsi = 0;
				return(ERROR);
			}
			goto atst;	/* skip and do the at stuff only */
		}
		/* initialize the buffer */
		for (i = 0; i < 56; i++)		{
			sendata[i] = 0;
		}

		/* check see the drive is a what kind of drive */
   		ostack = Super(NULL);
   		delay();
		if ((inqret = inquiry(dev, (WORD)56, sendata)) != ERROR)	{
			for (i=8; i < 56; i++)	{
				if (sendata[i])	{
					break;
				}
			}
			if (i < 56)	{	/* there are some date return */
				/* May-14-93 jye: Set the flag if it is a floptical drive */
				if ((sendata[8] == 'I') &&	(sendata[9] == 'N') &&
					(sendata[10] == 'S') &&	(sendata[11] == 'I') &&
					(sendata[12] == 'T') &&	(sendata[13] == 'E') &&
					(sendata[16] == 'I') &&	(sendata[17] == '3') &&
					(sendata[18] == '2') &&	(sendata[19] == '5'))	{
					/* it is a floptical INSITE I325 drive */
					floptical = 1;
				}
				gdrvid(dev, &sendata[8], drvid[dev]);
				idevs[dev] = 1;
			}
		}
   		delay();
   		Super(ostack);
		setmask = 0x0001;
		if (inqret & 0x08)	{ /* the device is busy */
			continue;
		}
		/* ret not equal OK, it may be a regular hard drive */
		if ((inqret == OK)||(inqret == 7)) { /*it is not a regular hard drive*/
			if (sendata[0])  	{	/* it is not a hard drive */
				continue;
			} else if (sendata[1] & mask)	{ /* it is a removable drive */
				if (spscsixst)	{
		  			/* it is a SCSI drive */
					/* set the relative bit, 1 is a SCSI, other is not */
					typedrv |= setmask << dev;
					/* set the relative bit, 1 is a removable */
					typedev |= setmask << dev;
				} else {
					;			/* don't set the SCSI bit */
				}
			} else if (dev > 7)	{
		  		/* it is a SCSI drive */
				/* set the relative bit, 1 is a SCSI, other is not */
				typedrv |= setmask << dev;
			}
		}
    	if ((ret = getroot(dev, buf, (SECTOR)0)) < 0) {
			if (!fnp)  rangelog(dev);
	    	continue;
		} else {		/* ret >= 0 */
		    if (ret > 0) {
	    	    if ((flag) && (tsterr(ret) == OK))	{	
				/* if non-0, report error if medium changed */
						erasemsg();
						slwacsi = 0;
	    	         	return ERROR;
	    	    }
	    	    if ((ret = getroot(dev, buf, (SECTOR)0))) {	/* try again */
			    	if (ret > 0 && flag && tsterr(ret) == OK)	{
						erasemsg();
						slwacsi = 0;
						return ERROR;
					} else if ((ret > 0) && (!flag))	{
						if (((inqret == OK)||(inqret == 7)) && 
											 (sendata[1] & mask))	{ 
							/* it is a removable drive */
							/* but forget insert the cartridge */
							err(instdrv);
							/*
							erasemsg();
							*/
							/* set the relative bit, 1 is a removable */
							typedev |= setmask << dev;
						}
						/*
						if (fnp == 1)	{  do format 
							livedevs[dev] = 1;
							if (dev < 8)  there is a ACSI in the system 
								noacsi = 0;
							yesscan = 1;
						}
						*/
					}
					if (!fnp)	{
						rangelog(dev);
					}
					continue;
				}
	    	}
			if ((inqret == OK)||(inqret == 7)) 	{  /* it is a SCSI drive */
				if (sendata[1] & mask)	{ /* it is a removable drive */
					/* set the relative bit, 1 is a removable, other is not */
					typedev |= setmask << dev;
				}
			}
	atst:
			if (dev < 8)	{	/* there is a ACSI drive in the system */
				noacsi = 0;
			}
	    	livedevs[dev] = 1;
			yesscan = 1;
			if (stgpart(dev, buf, (PART *)&partinfo) == ERROR)	{
				erasemsg();
				slwacsi = 0;
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

noidedr:
	if ((maxloop > 16) && ((ttscsi)||(spscsixst)))	{
		maxloop = 16;
		dev = 8;
		slwacsi = 0;
		if (spscsixst)	{
			slwacsi = 1;
		}
		goto rerescan;
	} else if (((maxloop > 16) && ((!ttscsi)&&(!spscsixst))) 
							   || ((ttscsi)&&(maxloop>8)))	{
		maxloop = 8;
		dev = 0;
		slwacsi = 1;
		goto rerescan;
	}
	erasemsg();
	slwacsi = 0;
    return OK;
}



/* get the identification of drive */

gdrvid(indx, sptr, dptr)
int indx;
char *sptr;
char *dptr;
{

	int i, j=0;

	/* string in ptr is sperated by space */
	for (i=0; i < 24; i++)	{
		if ((*dptr++ = *sptr++) == 0x20)	{
			j++;
			if (j > 1)	{
				dptr--;
			}
		} else {
			j = 0;
		}
	}
	*(dptr-1) = 0;
	/*
	while ((*sptr != 0x20) && (*sptr))	{
		*dptr++ = *sptr++;
	}
	*dptr++ = 0x20;
	sptr = ptr+8;
	while ((*sptr != 0x20) && (*sptr))	{
		*dptr++ = *sptr++;
	}
	*dptr = 0;
	*/
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
	if (dev == 16)	{ /* it is a AT drive */
		errnum = ideread(athead, atspt, sect, num, buf, (UWORD)dev);
	} else {
    	errnum = hread(sect, num, buf, (UWORD)dev);
	}
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
	if (dev == 16)	{ /* it is a AT drive */
		errnum = idewrite(athead, atspt, sect, num, buf, (UWORD)dev);
	} else {
    	errnum = hwrite(sect, num, buf, (UWORD)dev);
	}
    delay();
    Super(ostack);

    if (errnum > 0) {
        errnum = errcode(dev);
    }
    return errnum;
}


/*
 * Return uppercase of `c'
 *
 */
toupper(c)
char c;
{
    if(c >= 'a' && c <= 'z')
	c -= 0x20;
    return c;
}

