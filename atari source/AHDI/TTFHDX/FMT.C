/* fmt.c */


#include <obdefs.h>
#include <gemdefs.h>
#include "fhdx.h"
#include "define.h"
#include "part.h"
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
	0x265,		/* no reduced write-current cylinder */
	0x265,		/* no write precomp cylinder */
	10,		/* landing zone position = 10 */
	2,		/* use buffered seeks */
	1,		/* interleave = 1 */
	17		/* 17 sectors per track */
};


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

    return mdselect(dev, 22, &mb);
}


/*
 * Set mode information on a SCSI drive.
 *
 * Comments:
 * (20-Jun-1990  ml.)
 *	Support for page code 3 is specific for the NEC D5862 drives
 * _ONLY_.  They have very weird mode select and mode sense commands.
 * A mode sense page code 3 returns with data of page code 1, 3 and 4!
 * This would explain some of the things done under case 3 of the switch
 * statement below.  Further details of the commands, refer to the D5862
 * Magnetic Disk Drive Product Description.
 */
char sendata[64];	/* data buffer */

scsims(dev, hinfo, pcode, hdsiz)
int  dev;		/* physical device number */
HINFO *hinfo;		/* parameters of dev */
int  pcode;		/* page code */
long *hdsiz;		/* -> hard disk size */
{
    int len;		/* transfer length */
    int ret;		/* return code */
    extern long get3bytes();

    if (pcode == 0)
	len = 16;
    else if (pcode == 3)
	len = 36;
	    
    if ((ret = mdsense(dev, pcode, 0, len, sendata)) != OK)
	return ret;
    	
    delay();
    sendata[0] = sendata[2] = 0;    /* reserved */
    
    switch(pcode) {		    /* set up buffer */
    	case 0:			    /* for page code 0 */
	    sendata[3] = 0x08;	    /* block descriptor length */
	    sendata[10] = 0x02;	    /* block length = 512 bytes */
	    sendata[12] = 0;	    /* page code 0 */
	    sendata[13] = 0x02;	    /* page is 2 bytes long */
	    sendata[14] = 0x10;	    /* set inhst bit -> no error on reset */
	    sendata[15] = 0;	    /* device type qualifier */
	    len = 16;
	    break;
	    
	case 3:			    /* for NEC-D5862 page code 3 ONLY */
	    for (ret = 0; ret <= 27; ret++)	/* init data */
	    	sendata[ret] = 0;
	    len = 28;
	    sendata[4] = 3;			/* page code 3 */
	    sendata[5] = 0x16;			/* page is 22 bytes long */
	    sendata[15] = (BYTE)hinfo->hi_spt;	/* set sectors per track */
	    sendata[24] = 0x40;
    }
    
    if ((ret = mdselect(dev, len, sendata)) != OK)
        return ret;

    delay();	
    if ((ret = mdsense(dev, pcode, 0, len, sendata)) == OK)
    	*hdsiz = get3bytes(sendata+5);
    return ret;
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
 * the format parameter name `fpnam' and kind of
 * entry.  (entry could be "ct" for controller 
 * test, or "mn" for regular format)
 *
 * return 0 on OK,
 * -1 on [CANCEL].
 *
 */
gfparm(modesel, hinfop, fpnam, entry)
int *modesel;
HINFO *hinfop;
char *fpnam;
char *entry;
{
    long num;
    char name[128];
    char eid[4];	/* entry id */
    int  ret;

    strcpy(name, fpnam);
    strcpy(eid, entry);

    if (wgetent(name, eid) == ERROR) {
    	nofmt[NOSCHFMT].ob_spec = name;
    	nofmt[NOSCHFOK].ob_state = NORMAL;
    	execform(nofmt, 0);
	ret = ERROR;
	goto gfend;
    }

    fdefault(hinfop);
    if (wgetnum("cy", &num) == OK) hinfop->hi_cc = (WORD)num;
    if (wgetnum("hd", &num) == OK) hinfop->hi_dhc = (BYTE)num;
    if (wgetnum("rw", &num) == OK) hinfop->hi_rwcc = (WORD)num;
    if (wgetnum("wp", &num) == OK) hinfop->hi_wpc = (WORD)num;
    if (wgetnum("lz", &num) == OK) hinfop->hi_lz = (BYTE)num;
    if (wgetnum("rt", &num) == OK) hinfop->hi_rt = (BYTE)num;
    if (wgetnum("in", &num) == OK) hinfop->hi_in = (BYTE)num;
    if (wgetnum("sp", &num) == OK) hinfop->hi_spt = (BYTE)num;
    if (wgetnum("md", &num) == OK) *modesel = (WORD)num;
    ret = OK;
    
gfend:
    /* Close the wincap file after accessing it */
    wclose();
        	
    return ret;
}
