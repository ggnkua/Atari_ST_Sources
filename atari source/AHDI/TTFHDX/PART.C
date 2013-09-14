/* part.c */

/* 
 * 09-20-89	ml.	Modified to handle "big" partitions (i.e.
 *			partitions >= 16Mb.
 */
 
#include <obdefs.h>
#include "fhdx.h"
#include "define.h"
#include "part.h"
#include "bsl.h"
#include "addr.h"


extern char sbuf[];
extern int rebootp;
extern long bslsiz, maxpsiz;


/*
 * Fill in partition entry with default information
 * and configuration values from the current "pr" wincap entry.
 *
 */
fillpart(n, part)
int n;		/* partition number */
PART *part;	/* entry to hold info of partition n */
{
    long num;
    char *partid;
    char *idstr = "XX";
    char *wgetstr();

    part->p_flg = 0;		/* set defaults */
    part->p_id[0] = 'G';
    part->p_id[1] = 'E';
    part->p_id[2] = 'M';
    part->p_st = 0L;
    part->p_siz = 0L;

    /* see if `pX' is mentioned */
    *idstr = 'p';
    *(idstr+1) = n + '0';
    
    if (wgetnum(idstr, &num) == OK) {
	part->p_siz = (LONG)(num / 512);
	*idstr = 'f';
	if (wgetnum(idstr, &num) == OK)
	    part->p_flg = (BYTE)num;
	    else part->p_flg = P_EXISTS;
	*idstr = 'i';
	if ((partid = wgetstr(idstr)) != NULL) {
	    for (num = 0; num < 3; ++num)
		part->p_id[num] = partid[num];
	} else if (part->p_siz > maxpsiz) {	/* id for big partitions */
		part->p_id[0] = 'B';
		part->p_id[1] = 'G';
		part->p_id[2] = 'M';
	}
	
    }
}


/*
 * Extract partition structures from root sector.
 *
 */
gpart(image, pinfo)
char *image;
PART *pinfo;
{
    register PART *rpart;
    int i, j;

    rpart = &((RSECT *)(image + 0x200 - sizeof(RSECT)))->hd_p[0];

    for (i = 0; i < 4; ++i) {
	pinfo->p_flg = rpart->p_flg;
	for (j = 0; j < 3; ++j)
	    pinfo->p_id[j] = rpart->p_id[j];
	pinfo->p_st = rpart->p_st;
	pinfo->p_siz = rpart->p_siz;

	++pinfo;
	++rpart;
    }
}


/*
 * Install partition structures in root sector.
 *
 */
spart(image, pinfo)
char *image;
PART *pinfo;
{
    register PART *rpart;
    int i, j;

    rpart = &((RSECT *)(image + 0x200 - sizeof(RSECT)))->hd_p[0];

    for (i = 0; i < 4; ++i) {
	rpart->p_flg = pinfo->p_flg;	/* copy part struct */
	for (j = 0; j < 3; ++j)
	    rpart->p_id[j] = pinfo->p_id[j];
	rpart->p_st = pinfo->p_st;
	rpart->p_siz = pinfo->p_siz;

	++rpart;
	++pinfo;
    }
}


/*
 * Setup partitions on the disk;
 * write boot sectors and zero FATs and root directories.
 *
 */
dopart(physdev, spt, pinfo, hdsiz)
int physdev;
int spt;
register PART *pinfo;
long hdsiz;
{
    SECTOR data;		/* starting sector of data */
    WORD ndirs;			/* # root directory entries */
    WORD fatsiz;		/* FAT size in # log sectors */
    SECTOR psiz;		/* partition size in # log sectors */
    WORD sratio;		/* log sect size : phys sect size */
    WORD ssiz;			/* log sector size in bytes */
    char image[512];		/* part of boot sector that holds info */
    BOOT *bs;			/* pointer to boot sector */
    char *devno="X";
    int i, j, ldev;

    for (i = 0; i < NPARTS; ++i, ++pinfo) {
	if (!(pinfo->p_flg & P_EXISTS)) {
	    continue;
	}

	/* Compute boot sector parameters. */
	if (pinfo->p_siz > hdsiz) {
	    *devno = i + '0';
	    part2big[BGPART].ob_spec = devno;
	    part2big[BGPARTOK].ob_state = NORMAL;
	    execform(part2big, 0);
	    return ERROR;
	}

	sratio = 1;		/* assume log sect size = phys sect size */
	psiz = pinfo->p_siz;	/* => partition size = # phys sector */
	
	/*
	 * if partition is too big, double sector size until 
	 * number of log sectors <= maxpsiz
	 */
	while ((psiz / sratio) > maxpsiz)
	    sratio <<= 1;

	ssiz = sratio << 9;	/* bytes per log sector */
	psiz /= sratio;		/* # log sectors in partition */
	
	/*
	 * Compute root directory size
	 * 256 entries if devs < 10Mb, 
	 * or 1 entry per 80 physical sectors.
	 */
	if (pinfo->p_siz < 20480L) 
	    ndirs = 256;
	else 
	    ndirs = pinfo->p_siz / 80;
	    
	/* 
	 * Round down ndirs to occupy the closest # of log sectors.
	 * Each physical sector holds 16 32-byte entries.
	 */
	ndirs = (ndirs + ((sratio<<4)-1)) & ~((sratio<<4)-1);

	/*--------------------------------------------------------------*
	 * Compute FAT size						*
	 *								*
	 * # entries to map the entire partition			*
	 *	= partition size in # of clusters			*
	 *	= partition size in # log sectors / 2			*
	 *								*
	 * # entries in FAT						*
	 *	= # entries to map partition + reserved entries		*
	 *	= (partition size in # log sectors / 2) + 2		*
	 *								*
	 * # log sectors FAT occupies					*
	 *	= # entries in FAT / # entries of FAT per log sector	*
	 *	= # entries in FAT / (log sect siz / 2)	<16-bit FAT>	*
	 *	= ((partition size in # log sectors/2) + 2) 		*
	 *	    / (log sect siz / 2) + 1	<+1 to round up>	*
	 *--------------------------------------------------------------*/
	fatsiz = (((psiz >> 1) + 2) / (ssiz >> 1)) + 1;

	/*
	 * Install entries in boot sector image;
	 * force sector checksum to zero (non-executable);
	 * write boot sector to media.
	 *
 	 *	... bytes/sector
	 *	2 sectors/cluster
	 *	1 reserved sector (for boot)
	 *	2 FATs
	 *	... dir slots
	 *	... # sectors
	 *	F9 means media is a hard disk (fixed disk)
	 *	... FAT size
	 *	... sectors per track
	 */
	 
	/* Zero the partition header */
	if (zerosect(physdev, (SECTOR)(pinfo->p_st+1),
	    (WORD)((sratio-1) + ((fatsiz*sratio)<<1) + (ndirs>>4))) != OK)
	    return ERROR;
		     
	/* Make a clean boot sector */
	fillbuf(image, 512L, 0L);
	bs = (BOOT *)image;
        
	iw((WORD *)&bs->b_bps[0], ssiz);
	bs->b_spc = 2;
	iw((WORD *)&bs->b_res[0], (WORD)1);
	bs->b_nfats = 2;
	iw((WORD *)&bs->b_ndirs[0], ndirs);
	iw((WORD *)&bs->b_nsects[0], (WORD)psiz);
	bs->b_media = 0xf8;
	iw((WORD *)&bs->b_spf[0], fatsiz);
	iw((WORD *)&bs->b_spt[0], (WORD)spt);

	/* Write partition's boot sector info */
	forcesum((WORD *)image, (WORD)0);	/* force image checksum */
	wrsect(physdev, image, (SECTOR)pinfo->p_st);

	/* Make first 2 entries in FATs more IBM-like. */
	if (rdsect(physdev, image, (SECTOR)(pinfo->p_st+sratio)) != 0)
	    return err(fatread);
	*(WORD *)&image[0] = 0xf8ff;
	*(WORD *)&image[2] = 0xffff;
	if (wrsect(physdev, image, (SECTOR)(pinfo->p_st+sratio)) != 0
	    || wrsect(physdev, image, 
		(SECTOR)(pinfo->p_st+(sratio*(1+fatsiz)))) != 0)
	    return err(fatwrite);
	
	/*
	 * Mark bad sectors recorded in the BSL into the FATs.
	 * Calculating parameters:
	 *	ldev - from physdev and i.
	 *	fat0 - always starts at logical sector 1
	 *	fatsiz - as calculated above.
	 *	data - starts after the boot sector, 2 FATs and rootdir.
	 */
	if (bslsiz > 0) {
	    ldev = phys2log(physdev, i);
	    data = (SECTOR)1 + (SECTOR)(fatsiz<<1) 
	    		+ (SECTOR)((ndirs>>4)/sratio);
	    bsl2fat(ldev, (SECTOR)1, fatsiz, data, MEDIA, sratio);
	}
    }
    return OK;
}


/*
 * Force checksum of sector image to a value
 */
forcesum(image, sum)
WORD *image;
WORD sum;
{
    register int i;
    register WORD w;

    w = 0;
    for (i = 0; i < 255; ++i)
	w += *image++;
    *image++ = sum - w;
}


/*
 * Put word in memory in 8086 byte-reversed format.
 *
 */
iw(wp, w)
WORD *wp;
WORD w;
{
    char *p;

    p = (char *)wp;
    p[0] = (w & 0xff);
    p[1] = ((w >> 8) & 0xff);
}


/*
 * Get word in memory, from 8086 byte-reversed format.
 *
 */
WORD gw(wp, aw)
WORD *wp;
WORD *aw;
{
    char *p, *q;

    p = (char *)wp;
    q = (char *)aw;
    q[0] = p[1];
    q[1] = p[0];
    return *aw;
}
