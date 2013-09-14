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
sfmtparm(image, size)
char *image;
long size;
{
    ((RSECT *)(image + 0x200 - sizeof(RSECT)))->hd_siz = size;
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

    return (int)mode_set(dev, &mb);
}


/*
 * Move `w' to unaligned location.
 *
 */
cpw(d, w)
char *d;
UWORD w;
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
gfparm(modesel, hinfop, fpnam)
int *modesel;
HINFO *hinfop;
char *fpnam;
{
    long num;
    char name[128];

    strcpy(name, fpnam);
    if (wgetent(fpnam, NULL) == ERROR) {
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
