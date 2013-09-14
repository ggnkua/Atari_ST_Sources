/* fmt.c */


#include "obdefs.h"
#include "defs.h"
#include "part.h"
#include "hdx.h"
#include "addr.h"


extern char sbuf[];
extern int rebootp;


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
 * If we change drives, this might have to be changed.
 *
 */
HINFO deffmt = {
	0x264,		/* 612 cylinders */
	4,		/* 4 heads */
	0x264,		/* no reduced write-current cylinder */
	0x264,		/* no write precomp cylinder */
	10,		/* landing zone position = 10 */
	2,		/* use buffered seeks */
	1,		/* interleave = 1 */
	17		/* 17 sectors per track */
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
    extern long mode_set();

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

    return (int)mode_set(dev, 22, &mb);
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
gfparm(modesel, hinfop, fpnam, id)
int *modesel;
HINFO *hinfop;
char *fpnam, *id;
{
    long num;
    char name[128];

    strcpy(name, fpnam);
    if (wgetent(fpnam, id) == ERROR) {
    	nofmt[NOSCHFOK].ob_state = NORMAL;
    	(nofmt[NOSCHFMT].ob_spec)->te_ptext = name;
    	execform(nofmt);
		return ERROR;
    }

    fdefault(hinfop);
    if (wgetnum("cy", &num) == OK) hinfop->hi_cc = (UWORD)num;
    if (wgetnum("hd", &num) == OK) hinfop->hi_dhc = (BYTE)num;
    if (wgetnum("rw", &num) == OK) hinfop->hi_rwcc = (UWORD)num;
    if (wgetnum("wp", &num) == OK) hinfop->hi_wpc = (UWORD)num;
    if (wgetnum("lz", &num) == OK) hinfop->hi_lz = (BYTE)num;
    if (wgetnum("rt", &num) == OK) hinfop->hi_rt = (BYTE)num;
    if (wgetnum("in", &num) == OK) hinfop->hi_in = (BYTE)num;
    if (wgetnum("sp", &num) == OK) hinfop->hi_spt = (BYTE)num;
    if (wgetnum("md", &num) == OK) *modesel = (UWORD)num;
    return OK;
}


/*
 *	Set mode information on a SYQUEST drive.
 *
 */

sqms(dev, sendata)
int dev;			/* physical device number */
char sendata[];
{
	extern long mode_set();

	sendata[0] = sendata[2] = 0;	/* reserved */
	sendata[3] = 0x08;				/* block descriptor length */
	sendata[12] = 0;				/* Reserved = 0; Page Code = 0 */
	sendata[13] = 0x02;				
	sendata[14] = 0x10;				/* set inhst bit in page 00 */
	sendata[15] = 0;				/* Device type qualifier  */
	return (int)mode_set(dev, 16, sendata);
}


