
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




countpart(dev)
int dev;
{
	char bs[512];
	PART *ipart;
	int ret, count, i; 
	long sect, start;

	if ((ret = getroot(dev, bs, (SECTOR)0)) != 0)	{
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
