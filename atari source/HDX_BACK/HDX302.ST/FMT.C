/* fmt.c */

#include "obdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "hdx.h"
#include "addr.h"
#include "error.h"

#define MFM 17			/* sectors per track of MFM */
#define RLL 26			/* sectors per track of RLL */

extern long ostack;
extern int typedev;
extern int typedrv;
extern char sbuf[];
extern char ttscsi;		/* 1: SCSI bus drive */

/*
 * These constants are used in a heuristic that determines
 * if the format parameter information in the boot sector
 * is intact.  (See fmtpok()).
 */
#define	MAXCYLS		4096		/* max number of cylinders */
#define	MINCYLS		100		/* minimum number of cylinders */
#define	MAXHEADS	16		/* max number of heads */
#define	MINHEADS	2		/* minimum number of heads */
#define	MAXLZ		16		/* max landing zone value */
#define	MAXRT		2		/* max step-rate code */


/*
 * These are the default format parameters;
 * they are for a 20Mb Mutsubuishi drive.
 *
 * @ If we change drives, this might have to be changed.
 *
 */
HINFO deffmt = {
	0x264,		/* 612 cylinders */
	4,			/* 4 heads */
	0x264,		/* no reduced write-current cylinder */
	0x264,		/* no write precomp cylinder */
	10,			/* landing zone position = 10 */
	2,			/* 2 use buffered seeks */
	1,			/* 2 interleave = 1 */
	17			/* 17 sectors per track */
};


/*
 * Report format error.
 *
 */
formaterr(dev)
int dev;
{
    char *pdev="X";
    
    *pdev = dev + '0';
    (cantform[FMTDEV].ob_spec)->te_ptext = pdev;
    cantform[FMTERROK].ob_state = NORMAL;
    execform(cantform);
    return ERROR;
}


/*
 * Set format parameters in a
 * root sector image.
 * 6-13-88  only set size of hard disk.
 *
 */

sdisksiz(image, hdsiz)
char *image;
long hdsiz;
{
    ((RSECT *)(image + 0x200 - sizeof(RSECT)))->hd_siz = hdsiz;

}


/*
 * Set format parameters in a
 * root sector image.
 *
 */
sfmtparm(image, fmtparm)
char *image;
HINFO *fmtparm;
{
	register HINFO *rinfo;
	register long siz;

    rinfo = &((RSECT *)(image + 0x200 - sizeof(RSECT)))->hd_info;
	rinfo->hi_cc = fmtparm->hi_cc;
	rinfo->hi_dhc = fmtparm->hi_dhc;
	rinfo->hi_rwcc = fmtparm->hi_rwcc;
	rinfo->hi_wpc = fmtparm->hi_wpc;
	rinfo->hi_lz = fmtparm->hi_lz;
	rinfo->hi_rt = fmtparm->hi_rt;
	rinfo->hi_in = fmtparm->hi_in;
	rinfo->hi_spt = fmtparm->hi_spt;

	/* Compute total disk size
	 * = <#cyls> * <#heads> * <#sectors / track>
	 */
    ((RSECT *)(image + 0x200 - sizeof(RSECT)))->hd_siz = 
		(long)fmtparm->hi_cc *
		(long)fmtparm->hi_dhc *
		(long)fmtparm->hi_spt; 

}


/*
 * Determine if format parameters are good;
 * return OK if they appear to be,
 * ERROR if they don't appear to be.
 *
 */
fmtpok(fmtparm)
HINFO *fmtparm;
{
    if (fmtparm->hi_cc > MAXCYLS ||
	fmtparm->hi_cc < MINCYLS ||
	fmtparm->hi_dhc > MAXHEADS ||
	fmtparm->hi_dhc < MINHEADS ||
	fmtparm->hi_lz > MAXLZ ||
	fmtparm->hi_rt > MAXRT)
	    return ERROR;

    return OK;
}


/*
 * Setup default format parameters in hinfo;
 * (REAL C compilers do this with a structure assignment...)
 *
 */
fdefault(hinfop)
HINFO *hinfop;
{
    hinfop->hi_cc = deffmt.hi_cc;
    hinfop->hi_dhc = deffmt.hi_dhc;
    hinfop->hi_rwcc = deffmt.hi_rwcc;
    hinfop->hi_wpc = deffmt.hi_wpc;
    hinfop->hi_lz = deffmt.hi_lz;
    hinfop->hi_rt = deffmt.hi_rt;
    hinfop->hi_in = deffmt.hi_in;
    hinfop->hi_spt = deffmt.hi_spt;
}


/*
 * Set mode information on drive.
 *
 */
ms(dev, hinfo)
int dev;
HINFO *hinfo;
{
    int i;
    char *p;
    SETMODE mb;
    extern long mdselect();

    /* initialize parameter structure */
    p = (char *)&mb;
    for (i = sizeof(SETMODE); i--;)
	*p++ = 0;
    mb.smd_8 = 0x08;
    mb.smd_1 = 0x01;
    mb.smd_bs[1] = 0x02;	/* block size = 512 */

    cpw(&mb.smd_cc[0], hinfo->hi_cc);
    mb.smd_dhc = hinfo->hi_dhc;
    cpw(&mb.smd_rwc[0], hinfo->hi_rwcc);
    cpw(&mb.smd_wpc[0], hinfo->hi_wpc);
    mb.smd_lz = hinfo->hi_lz;
    mb.smd_rt = hinfo->hi_rt;

    return (int)mdselect(dev, 22, &mb);
}


/*
 * Move `w' to unaligned location.
 *
 */
cpw(d, w)
char *d;
WORD w;
{
    char *s;

    s = (char *)&w;
    d[0] = s[0];
    d[1] = s[1];
}


/*
 * Return format parameters in `hinfo', based on
 * the format parameter name `fpnam'.
 *
 * return 0 on OK,
 * -1 on [CANCEL].
 *
 */
gfparm(dev, noinfo, modesel, hinfop, fpnam, id)
int dev;
int noinfo;			/* 1: no information inside the wincap file */
int *modesel;
HINFO *hinfop;
char *fpnam, *id;
{
    long num;
    char name[128];
	int mask=0x0001;
	int scsidrv, set, ret = OK;
	UWORD cyl; 
	BYTE nhead, sptrk;

	set = typedev & (mask << dev);
	scsidrv = typedrv & (mask << dev);
    fdefault(hinfop);
	if ((set) || (scsidrv) || (ttscsi))		{
		*modesel = 0;
	} else if (noinfo)	{
		ret = cyhdsp(dev, &cyl, &nhead, &sptrk);
    	hinfop->hi_cc = cyl;
    	hinfop->hi_dhc = nhead;
    	hinfop->hi_rwcc = cyl;
    	hinfop->hi_wpc =  cyl;
    	hinfop->hi_spt =  sptrk;
	} else {

    	strcpy(name, fpnam);
    	if (wgetent(fpnam, id) == ERROR) {
    		nofmt[NOSCHFOK].ob_state = NORMAL;
    		(nofmt[NOSCHFMT].ob_spec)->te_ptext = name;
    		execform(nofmt);
			return ERROR;
    	}

    	if (wgetnum("cy", &num) == OK) hinfop->hi_cc = (UWORD)num;
    	if (wgetnum("hd", &num) == OK) hinfop->hi_dhc = (BYTE)num;
    	if (wgetnum("rw", &num) == OK) hinfop->hi_rwcc = (UWORD)num;
    	if (wgetnum("wp", &num) == OK) hinfop->hi_wpc = (UWORD)num;
    	if (wgetnum("lz", &num) == OK) hinfop->hi_lz = (BYTE)num;
    	if (wgetnum("rt", &num) == OK) hinfop->hi_rt = (BYTE)num;
    	if (wgetnum("in", &num) == OK) hinfop->hi_in = (BYTE)num;
    	if (wgetnum("sp", &num) == OK) hinfop->hi_spt = (BYTE)num;
    	if (wgetnum("md", &num) == OK) *modesel = (UWORD)num;
	}
    return(ret);
}


/*
 *	Set mode information on a SYQUEST drive.
 *
 */

sqms(dev, sendata)
int dev;			/* physical device number */
char sendata[];
{
	extern long mdselect();
	char buf[32];

	inquiry(dev, (WORD)16, buf);
	if (buf[8] == 'Q' & buf[9] == 'U' & buf[10] == 'A' & buf[11] == 'N') 
		/* It is a QUANTUM hard disk. So don't need to set the page one. */
		return OK;
	sendata[0] = sendata[2] = 0;	/* reserved */
	sendata[3] = 0x08;				/* block descriptor length */
	sendata[12] = 0;				/* Reserved = 0; Page Code = 0 */
	sendata[13] = 0x02;				
	sendata[14] = 0x10;				/* set inhst bit in page 00 */
	sendata[15] = 0;				/* Device type qualifier  */
	return (int)mdselect(dev, 16, sendata);
}




/* 
 * get cylinder, # of head, and sector per track for ST
 */

cyhdsp(dev, cyl, nhead, sptk)

int dev;
UWORD *cyl; 
BYTE *nhead, *sptk;

{
	char *num;
	BYTE sptrk,numhead;
	int i, ret, totcyl, numtrack;
    extern long get3bytes();
    SETMODE *mb;
    SECTOR size, msiz;	/* size of media */
    char buf[512], sendata[32];
    long dmaptr, tmpptr, spcyl;
    char *dmahigh=0xffff8609,
         *dmamid=0xffff860b,
         *dmalow=0xffff860d;

	for (i = 0; i < 22; i++)
		sendata[i] = 0;
	ostack = Super(NULL);
	/* get format parameters/ disk size from emdia */
	ret = mdsense(dev, 0, 0, 22, sendata);
	delay();
	Super(ostack);
	if (ret != 0) 	{
		return ERROR;
	}
	for (i=0; i<22; i++)	{
		if (sendata[i])
			break;
	}
	if (i == 22)	/* no info return in the buf 'sendata' */
		err(needinfo);

   	get3bytes(sendata+5);  /* it's adaptec's.  Interpret as SETMODE structure */
  	mb = (SETMODE *)sendata;
	/* get number of cylinders */
	totcyl = mb->smd_cc[0];
	totcyl <<= 8;
	totcyl |= mb->smd_cc[1];
	*cyl = (UWORD)totcyl;

	/* get number of heads */
	numhead = mb->smd_dhc;
	*nhead = numhead;
  
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
		*sptk = RLL;
	} else {
		*sptk = MFM;
	}
	return OK;
}



