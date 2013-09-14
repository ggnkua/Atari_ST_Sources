
/* epart.c */

/*
 * Partition edit and pick for MS-DOS
 *
 * 08-Oct-1988	jye.  change and add this codes to do the partition 
 * 					  editing and picking for MS-DOS
 * 18-NOV-1988  jye.  change and add codes in the partition editing and
 *					  picking for the user interface.
 */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "ipart.h"
#include "bsl.h"
#include "hdx.h"
#include "addr.h"
#include "myerror.h"

#define SCR 1			/* use for extended partition box */
#define PRM 0			/* use for primary partition box */
#define ROLL1 1			/* move the bar one step */
#define ROLL4 4			/* move the bar four steps */

extern long ostack;
extern int wdesk;
extern int hdesk;
extern int ibm2st;
extern int toibm;
extern long bslsiz;
extern SECTOR badbuf[];		/* bad sectors buffer */
extern long gbslsiz();
extern int npart;				/* number of partitions */
extern int ext;				/* the index of extended partition */
extern int uplim;				/* index of dialog box */
extern int typedev;
extern int typedrv;
extern int firstmsg;			/* 1: 1st time to show the max partition */
								/* alert box */

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
static int lowlim;		/* index of dialog box */
static int first;		/* flag for add bad and good sectors only one time */
long disksiz;			/* size of disk in blocks */
long sumsiz;			/* the sum of bytes of root sectors */
long spcyl;				/* sector per cylinder */
long sptrk;				/* sector per track */
int ibmpart;			/* IBM or ST partition flag. 0 ST partition else IBM */
int yesscan;			/* the flag for the func. IBMGPART use */
int tolpart;			/* the total of number partitions */
int epty;				/* the y-coordinate of the moving bar */
int restept;			/* 1: rest the moving bar to initial place */



#define MFM 17			/* sectors per track of MFM */
#define RLL 26			/* sectors per track of RLL */

/* 
 * 	get IBM disk size.
 */

ibmgdsiz(dev, bs)

int dev;
char *bs;

{
	char *num;
	BYTE spt,numhead;
	int i, ret, numtrack;
    extern long get3bytes();
    SETMODE *mb;
    SECTOR size, msiz;	/* size of media */
    char buf[512], sendata[32];
    long dmaptr, tmpptr;
    char *dmahigh=0xffff8609,
         *dmamid=0xffff860b,
         *dmalow=0xffff860d;

	ostack = Super(NULL);
	/* get format parameters/ disk size from emdia */
	ret = mdsense(dev, 0, 0, 16, sendata);
	delay();
	Super(ostack);
	if (ret != 0) 	{
		return ERROR;
	}

    /* check what kind of sense data it returned  */
    /* If full SCSI, will return number of blocks */
    /* on disk at byte 5, 6 and 7.  If Adaptec,   */
    /* will return 0 for number of blocks on disk */
    /* on SCSI. */
   
   	if (!(msiz = get3bytes(sendata+5))) {	/* no disk size returned??? */
   		/* it's adaptec's.  Interpret as SETMODE structure */
   		mb = (SETMODE *)sendata;
		/* get number of cylinders */
		totcyl = mb->smd_cc[0];
		totcyl <<= 8;
		totcyl |= mb->smd_cc[1];

		/* get number of heads */
		numhead = mb->smd_dhc;
   
		sptrk = (long)MFM;
		msiz = (SECTOR)numhead * (SECTOR)totcyl * sptrk;
		spcyl = (SECTOR)numhead * sptrk;
   
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
			return err(cruptfmt);

		/* Determine if media is MFM or RLL */
		if (i < 20)		{
			sptrk = (long)RLL;
		    msiz = (SECTOR)numhead * (SECTOR)totcyl * sptrk;
			spcyl = (SECTOR)numhead * sptrk;
		}
   	}
	if ((ibmpart) || (!ibm2st))		{
		numhead = IBMHEAD;
		sptrk = IBMSPT;
 		totcyl = (int)(msiz / (sptrk * numhead));
		if (totcyl > IBMMCYL)	{
			numhead = (BYTE)(((msiz -1) / (sptrk * 1024)) + 2);
		}
		/* the number of sector in one cylinder.*/ 
		/*	'spcyl' is a global value */
		spcyl = sptrk * (long)numhead;
	}
	/* assign the size of disk */
	disksiz = msiz;
}


/* 
 * get disk size for ST
 */

getdsiz(dev)
int dev;
{
	char *num;
	BYTE sptrk,numhead;
	int i, ret, totcyl, numtrack, set, scsidrv, mask=0x0001;
    extern long get3bytes();
    SETMODE *mb;
    SECTOR size, msiz;	/* size of media */
    char buf[512], sendata[32];
    long dmaptr, tmpptr, spcyl;
    char *dmahigh=0xffff8609,
         *dmamid=0xffff860b,
         *dmalow=0xffff860d;

	ostack = Super(NULL);
	/* get format parameters/ disk size from emdia */
	set = typedev & (mask << dev);
	scsidrv = typedrv & (mask << dev);
	if ((set) || (scsidrv))		{
		ret = mdsense(dev, 4, 0, 16, sendata);
	} else	{
		ret = mdsense(dev, 0, 0, 22, sendata);
	}
	delay();
	Super(ostack);
	if (ret != 0) 	{
		return ERROR;
	}

    /* check what kind of sense data it returned  */
    /* If full SCSI, will return number of blocks */
    /* on disk at byte 5, 6 and 7.  If Adaptec,   */
    /* will return 0 for number of blocks on disk */
    /* on SCSI. */
   
   	if (!(msiz = get3bytes(sendata+5))) {	/* no disk size returned??? */
   		/* it's adaptec's.  Interpret as SETMODE structure */
   		mb = (SETMODE *)sendata;
		/* get number of cylinders */
		totcyl = mb->smd_cc[0];
		totcyl <<= 8;
		totcyl |= mb->smd_cc[1];

		/* get number of heads */
		numhead = mb->smd_dhc;
   
		sptrk = (long)MFM;
		msiz = (SECTOR)numhead * (SECTOR)totcyl * sptrk;
   
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
			return err(cruptfmt);

		/* Determine if media is MFM or RLL */
		if (i < 20)		{
		    msiz = (SECTOR)numhead * (SECTOR)totcyl * (long)RLL;
		}
   	}
	return(msiz);
}



/* 
 * get ST partition information for ST structure
 */

stgpart(xdev, bs, rpinfo)

int xdev;
char *bs;
PART **rpinfo;

{
	int i, j, linkst, ret;
	long sect;
	register PART *ipart;
	PART *xpinfo;

	if ((npart = countpart(xdev)) == ERROR)	{
		return ERROR;
	}
	if ((*rpinfo = (PART *)Malloc((long)sizeof(PART)*npart)) <= 0)	{
		err(nomemory);
		if (rpinfo > 0)		Mfree(rpinfo);
		return ERROR;
	}
	xpinfo = *rpinfo;
	inipart(xpinfo, npart);
   	ipart = &((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_p[0];
	for (i = 0; i < NPARTS; i++, ipart++)	{
		xpinfo[i].p_flg = ipart->p_flg;
		xpinfo[i].p_st = ipart->p_st;
		xpinfo[i].p_siz = ipart->p_siz;
		if (ipart->p_flg & P_EXISTS)	{
			if (i == ext)		{
				xpinfo[i].p_id[0] = 'X';
				xpinfo[i].p_id[1]  ='G';
				xpinfo[i].p_id[2] = 'M';
			} else if (xpinfo[i].p_siz < MB16)	{
				xpinfo[i].p_id[0] = 'G';
				xpinfo[i].p_id[1]  ='E';
				xpinfo[i].p_id[2] = 'M';
			} else {
				xpinfo[i].p_id[0] = 'B';
				xpinfo[i].p_id[1]  ='G';
				xpinfo[i].p_id[2] = 'M';
			}
		}
	}
	if (ext != NO_EXT)	{ /* there are extended partition */
		sect = xpinfo[ext].p_st;
		do	{
    		if ((ret = getroot(xdev, bs, sect)) != 0) {
  			  	if (tsterr(ret) != OK)
				    err(rootread);
				return ERROR;
    		}
   			ipart = &((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_p[0];
			xpinfo[i].p_flg = ipart->p_flg;
			xpinfo[i].p_st = sect;
			xpinfo[i].p_siz = ipart->p_siz + ROOTSECT;
			if (xpinfo[i].p_siz < MB16)	{
				xpinfo[i].p_id[0] = 'G';
				xpinfo[i].p_id[1]  ='E';
				xpinfo[i].p_id[2] = 'M';
			} else {
				xpinfo[i].p_id[0] = 'B';
				xpinfo[i].p_id[1]  ='G';
				xpinfo[i].p_id[2] = 'M';
			}
			ipart++;				
			i++;
			sect = ipart->p_st + xpinfo[ext].p_st;
		} while ((ipart->p_id[0] == 'X') && (ipart->p_id[1] == 'G') &&
				(ipart->p_id[2] == 'M'));  /* more partition */
	} 
	return OK;
}



maxmsg(pnl,num,tolpart)

OBJECT *pnl;
int num, tolpart;

{
		int ret; 	/* NOMAX: not to partition it. Else yes. */

		if ((num == MAXLOGDEVS) && (tolpart > MAXLOGDEVS - 1))	{
			ret = form_alert(2, maxlogms);
			return ((ret == NOMAX) ? (NOMAX) : (YES));
		}
}


/*
 * find out the total partitions
 */

totalpart(num, str)

int num;
char *str;

{
	int  i=0, j=0;
	char tem[10];

	/* conver the integer to ASCII */
	do	{	/* generate digits in reverse order */
		tem[i++] = num % 10 + '0';	/* get next digits */
	} while ((num /= 10) > 0);		/* delete it */

	for (; i > 0; )	{ /* reverse string 'str' in place */
		*str++ = tem[--i];
		j++;
	}
	for (; j < 5; j++)	
		*str++ = ' ';
   	*str = '\0';
}




/*
 * Partition button number-to-object translation table.
 */
 /*
int ppart[] = {
    PPART0, PPART1, PPART2, PPART3,
    PPART4, PPART5, PPART6, PPART7,
    PPART8, PPART9, PPART10, PPART11,
    PPART12, PPART13, PPART14
};
*/


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

ichkpart(pdev, xpinfo)
int pdev;
PART *xpinfo;
{
    char bs[512];
    SECTOR totsiz;
    int	 i, ret;
    
    /*
     * Get partition information from disk's root block.
     */
	if (!ibmpart)	{	/* initailly ST partition */
    	if ((ret = getroot(pdev, bs, (SECTOR)0)) != 0) {
  		  	if (tsterr(ret) != OK)
		    	err(rootread);
			return ERROR;
    	}
    	disksiz = ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz;
	} 
    totsiz = 0;
    for (i = 0; i < NPARTS; i++) {
        totsiz += xpinfo[i].p_siz;
    	if (totsiz > disksiz)
    	    return ERROR;
    }
    return OK;
}
	


inipart(xpart, npart)
PART *xpart;
int npart;
{
	int i;

	for (i = 0; i < npart; i++)	{
		xpart[i].p_siz = 0L;
		xpart[i].p_flg = 0;
		xpart[i].p_st = 0L;
		xpart[i].p_id[0] = 0;
		xpart[i].p_id[1] = 0;
		xpart[i].p_id[2] = 0;
	}
}




kindST(dev)
int dev;
{
	char bs[512];
	PART *ipart;
	int ret; 

	if ((ret = getroot(dev, bs, (SECTOR)0)) != 0)	{
		if (tsterr(ret) != OK)
			err(rootread);
		return ERROR;
	}
	ipart = &((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_p[0];
	if (((ipart+1)->p_flg & P_EXISTS) && 
		((ipart+1)->p_id[0] == 'X') && 
		((ipart+1)->p_id[1] == 'G') && 
		((ipart+1)->p_id[2] == 'M'))	{
		return (1);				/* link list ST partition */
	} else {	/* not link list ST partition */
		return (0);
	}
}

countpart(dev)
int dev;
{
	char bs[512];
	PART *ipart;
	int ret, count, i; 
	long sect, start;

	if ((ret = getroot(dev, bs, (SECTOR)0)) != 0)	{
		if (tsterr(ret) != OK)
			err(rootread);
		return ERROR;
	}
	ipart = &((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_p[0];
	ext = NO_EXT;
	for (i=0; i < NPARTS; i++, ipart++)	{
		if ((ipart->p_flg & P_EXISTS) && 
				(ipart->p_id[0] == 'X') && 
				(ipart->p_id[1] == 'G') && 
				(ipart->p_id[2] == 'M'))	{
			ext = i;
			start = ipart->p_st;
		}
	}
	count = 4;
	if (ext != NO_EXT)	{
		sect = start;
		do	{
			if ((ret = getroot(dev, bs, sect)) != 0)	{
				if (tsterr(ret) != OK)
					err(rootread);
				return ERROR;
			}
   			ipart = &((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_p[0];
			count++;
			ipart++;				
			sect = ipart->p_st + start;
		} while ((ipart->p_id[0] == 'X') && (ipart->p_id[1] == 'G') &&
				(ipart->p_id[2] == 'M'));  /* more partition */
	} 
	return (count);
}
