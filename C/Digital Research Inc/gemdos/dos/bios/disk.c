/*****************************************************************************
**
** disk.c - Disk I/O (and other initialization code) for VME/10 GEM DOS BIOS
**
** MODIFICATIONS
** 17 sep 85 scc	Redefined references to b_mdx to be MD.
**
**			Removed dph, dpb, csv, and alv data structures.
**
**			Removed references to NOTUNDERCPM and HDISKDIV.
**
** 30 sep 85 scc	Moved structure definitions of clk and vmecr to
**			BIOSC.C.
**
**  14 Oct 85	KTB	accomodate split of fs.h into fs.h and bios.h
**
**
** NAMES
**	scc	Steven C. Cavender
**	KTB	Karl T. Braun (kral)
**
******************************************************************************
*/

#include "portab.h"
#include "bios.h"
#include "abbrev.h"
#include "gemerror.h"
#include "ibmdisk.h"

			/* MEMDSK: 0 -> no memory disk			    */
			/*	   4 -> memory disk(sized at boot, drive E:)*/
			/* DISKB:  0 -> no disk B: (second floppy)	    */
			/*	   1 -> disk B: present			    */
			/* DISKC:  5 -> 5 megachar hard disk for disk C:    */
			/*	  15 -> 15 megachar hard disk for disk C:   */
			/*        40 -> 40 megachar hard disk for disk C:   */
			/* DISKD:  0 -> no disk D: (second hard disk)	    */
			/*	   5 -> 5 megachar hard disk for disk D:    */
			/*	  15 -> 15 megachar hard disk for disk D:   */

#if 0
***********************************************************************

GEMDOS disk parameter block structure

vme_dpb[0] = physical sector size in chars
vme_dpb[1] = cluster size in sectors
vme_dpb[2] = cluster size in chars
vme_dpb[3] = root directory length in sectors
vme_dpb[4] = FAT size in sectors (1 FAT)
vme_dpb[5] = 1st sector # of 2nd FAT
vme_dpb[6] = 1st sector # allocatable (where data begins)
vme_dpb[7] = total # of allocatable clusters
vme_dpb[8] = 0:12 bit FAT  1:16 bit FAT

For the 15 Mbyte VME drive we are given:
*	306 cylinders
*	32 sectors/track
*	256 bytes/sector
*	6 heads
Therefore we have 306 X 32 X 256 X 6 = 15,040,512 bytes on the 15 Mbyte disk.
Half of that = 7,520,256 or 7344 1024-char clusters for the partitioned disk.

With 12-bit FAT we have 1.5 bytes for every FAT entry per cluster.
With 16-bit FAT we have 2   bytes for every FAT entry per cluster.
Consequently, with a 16-bit FAT we have 256 words/sector.
As a result, a FAT entry for the whole 15 MByte H.D. is 14688 clusters/256=58.
And for a divided Hard disk it is half of that = 29 sectors/FAT.

The Hfudge factor is computed by adding a base so that all disk accesses begin
half way through the disk.
So when GEMDOS asks for sector we add 153 cylinders to point at start of
GEMDOS partition (153 X 32 X 6 = 29376 sectors) IFF the hard disk is divided.

For the 40 Mbyte drive:
*	829 cylinders
*	32 sectors/track
*	256 bytes/sector
*	6 heads

40 meg VME drive = 829 X 32 X 256 X 6 = 40,747,008
less the 15 meg CP/M portion = 25,706,496
so GEMDOS partition starts 58,752 sectors into the disk
so fudge is 58752
25,706,496 / 1024 = 25,104 clusters total
using 16-bit FAT that requires 99 sectors each for the FATS

*************************************************************************
#endif

extern MD b_mdx;

BPB vme_dpb[] = {  {  512, 2, 1024, 15,  3,  19, 37,  609, 0 },
		{     512, 2, 1024, 15,  3,  4,  22,  634, 0 },

#if (DISKC == 15)
		{     256, 4, 1024, 128, 116, 134, 378, 14593, 3 },
#endif
#if (DISKC == 40)
		{     256, 4, 1024, 128, 198, 200, 528, 25038, 3 },
#endif
 		{     512, 4, 2048, 32, 11, 12, 56, 3657, 0 } };

static BYTE hexch[] = { '0','1','2','3','4','5','6','7',
		'8','9','A','B','C','D','E','F' } ;


/************************************************************************/
/*	Disk I/O Procedures and Definitions				*/
/************************************************************************/

#define	DSKCNTL	((struct dio *) 0xf1c0d1)	/* controller address */

#define	LSCTSZ	128		/* logical sector size - 128 chars */
#define	DCXFER	128		/* chars per dsk controller transfer request */

#define	FDRM	127		/* floppy disk directory maximum */
#define	FDSM96	313		/* floppy disk storage maximum - 96 tpi */
#define	FDSM48	153		/* floppy disk storage maximum - 48 tpi */

#if !TEST
#define	FCSVSIZE	((FDRM / 4) + 1)	/* floppy csv size */
#define	FALVSIZE	((FDSM96 / 8) + 1)	/* floppy alv size */
#define	HCSVSIZC	((HDRMC / 4) + 1)	/* hard C: csv size */
#define	HALVSIZC	((HDSMC / 8) + 1)	/* hard C: alv size */
#define	HCSVSIZD	((HDRMD / 4) + 1)	/* hard D: csv size */
#define	HALVSIZD	((HDSMD / 8) + 1)	/* hard D: alv size */
#endif /* !TEST */

#define	TKBUFSZ	(32 * 128)	/* number of chars in track buffer */
				/* at least as large as a floppy track */

#define	DSKSTAT		0x00	/* commands */
#define	DSKRECAL	0x01
#define	DSKDFRMT	0x04	/* format disk */
#define	DSKTFRMT	0x06	/* format track */
#define	DSKREAD		0x08
#define	DSKSCAN		0x09
#define DSKWRITE	0x0a
#define	DSKCONFG	0xc0

#define	CTL512DD	0x34	/* default command control char: 48 tpi */
				/* IBM sn, DD, 512 bps, DS, no ci, blk drq */
#define	CTL128SD	0x04	/* command control char: 48 tpi */
				/* IBM sn, SD, 128 bps, DS, no ci, blk drq */

#define	BUSY		0x80	/* status bits */
#define	DRQ		0x08	/* data request - can xfer DCXFER chars */
#define	RST		0x80	/* sense status bit - reset */
#define	RDY		0x08	/* sense status bit - drive ready */
#define	NOERR		0x00	/* sense error code - no error */
#define	IDNTFND		0x06	/* sense error code - ID header not found */
#define	CORRDER		0x13	/* sense error code - correctable read error */

#define	TPI96	0x80
#define	TPI48	0

#if ! MEMDSK
#define NUMDSKS 4		/* number of disks defined */
#else
#define NUMDSKS 5
#endif

/************************************************************************/
/*	Currently Selected Disk Stuff					*/
/************************************************************************/

BYTE cnvdsk[NUMDSKS]  = { 2, 3, 0, 1 };  /* convert CP/M dsk# to Motorola */
BYTE rcnvdsk[NUMDSKS] = { 2, 3, 0, 1 };	 /* and vice versa */

/************************************************************************/
/*	Define the number of disks supported and other disk stuff	*/
/************************************************************************/

#define MAXDSK  (NUMDSKS-1)	/* maximum disk number 	   */

/*
 *	These are the physical disk I/O routines for the cross
 *	PC-DOS utility running under CP/M originally received from Motorola
 *	and only slightly altered here.
 *
 *	They drive RWIN disk controller on the VME/10.
 *
 *	ASSUMPTIONS:
 *
 *	- Floppy disks are 96 tpi, 512 char DD sectors, 8 per track.
 *
 */


/************************************************************************/
/* Define Disk I/O Addresses and Related Constants			*/
/************************************************************************/

#define	DISKCNTL	((DIO *) 0xf1c0d1)	/* controller address */

#define	DCXFER	128		/* chars per dsk controller transfer request */
				/*		for writes (not need for rd) */
#define	DISKREAD		0x08	/* commands */
#define DISKWRITE		0x0a
#define DISKCONFG		0xc0

#define	CTL512DD	0x34	/* default command control char: 48 tpi */
				/* IBM sn, DD, 512 bps, DS, no ci, blk drq */
#define CTL128SD	0x04

#define	BUSY		0x80	/* status bits */
#define	DRQ		0x08	/* data request - can xfer DCXFER chars */

#define CORRDER		0x13	/* sense error code - correctable read error */

#define	TPI96	0x80	/* we must tell controller we have 96 tpi floppy */

#define RETRYCNT	10	/* number of retries on disk read if error */

/************************************************************************/
/*	Disk I/O Packets and Variables					*/
/************************************************************************/

typedef struct			/* disk controller registers */
{
	BYTE	cmdsns;		/* command/sense BYTE */
	BYTE	diofl1;		/* fill char */
	BYTE	intstt;		/* interrupt/status char */
	BYTE	diofl2;		/* fill char */
	BYTE	rst;		/* reset */
	BYTE	diofl3;		/* fill char */
	BYTE	ntusd;		/* not used */
	BYTE	diofl4;		/* fill char */
	BYTE	data;		/* data */
} DIO;

typedef struct			/* sense packet */
{
	BYTE	ercode;		/* error code */
	BYTE	lun;		/* CP/M logical unit number */
	BYTE	status;		/* status includes controller lun */
	WORD	pcylnm;		/* physical cylinder number */
	BYTE	headnm;		/* head number */
	BYTE	sectnm;		/* sector number */
	BYTE	n;		/* number sectors left to process */
	BYTE	snsbt6;		/* sense packet char 6 */
	BYTE	snsbt7;		/* sense packet char 7 */
	BYTE	snsbt8;		/* sense packet char 8 */
	BYTE	snsbt9;		/* sense packet char 9 */
} DSNS;

DSNS sns;			/* last sense packet read from disk */

/************************************************************************/
/*	Send command packet						*/
/*									*/
/*	NOTE: These assignments must not be reordered			*/
/*	or optimized away.  We are writing to a single memory		*/
/*	mapped register and the order of data sent is significant.	*/
/************************************************************************/

SndCmd(dsk,psn,n,cmd)
REG WORD n, dsk, cmd;
REG LONG psn;
{
	WORD	ctl;

	/* correction for reading or writing track 0 on the floppy (only)  */
	/* track 0 is special: single density, 128 byte/sector, 16 sectors */
	/* all other tracks are double density, 512 byte/sector, 8 sectors */
	/* correction assumes reads and writes are done on a track basis   */

	if ( (dsk == 0 || dsk == 1) &&		/* ie floppy only */
	    ((cmd == DISKREAD) || (cmd == DISKWRITE) || (cmd == DSKTFRMT)) &&
	    psn < 8L)
	{			/* for system info must access all of trk   */
		psn = 0;	/* starting at the beginning of track	    */
		ctl = CTL128SD;	/* it is a floppy and we do track 0 	    */
		n = 16;		/* 16 128 byte sectors on track 0           */
	}
	else
		ctl = CTL512DD;

	/* write the packet to the controller */

	DISKCNTL->cmdsns = cmd;			/* command - char 0 */

	/* following line assumes psn <= 21 bits long */
	DISKCNTL->cmdsns = (cnvdsk[dsk] << 5) | (psn >> 16);	/* char 1 */
	DISKCNTL->cmdsns = (psn >> 8);				/* char 2 */
	DISKCNTL->cmdsns = psn;					/* char 3 */
	DISKCNTL->cmdsns = n;					/* char 4 */

	/* char 5 configuration information is IGNORED FOR HARD DISK */
	/* and we don't enable interrupts */
	DISKCNTL->cmdsns = ctl | TPI96;				/* char 5 */
}


/************************************************************************/
/*	Send disk configuration packet					*/
/************************************************************************/

SndCnf(dsk, mxhd, mxcl, prcmp)
REG WORD dsk, mxhd, mxcl, prcmp;
{
	WORD zero;

	zero = 0;	/* so clr.b won't be generated for char 5 */

	/* write the configuration packet to the controller */
	/* the DISKCNTL references must NOT be reordered */

	DISKCNTL->cmdsns = DISKCONFG;			/* command - char 0 */
	DISKCNTL->cmdsns = (cnvdsk[dsk] << 5);		/* char 1 */
	/* following line assumes mxcl <= 13 bits long */
	DISKCNTL->cmdsns = (mxhd << 5) | (mxcl >> 8);	/* char 2 */
	DISKCNTL->cmdsns = mxcl;			/* char 3 */
	DISKCNTL->cmdsns = prcmp;			/* char 4 */
	DISKCNTL->cmdsns = zero;			/* char 5 */

	while ( DISKCNTL->intstt & BUSY )
		;				/* wait while controller busy */
}


/************************************************************************/
/*	Get disk sense							*/
/************************************************************************/

GetDiskSense()
{
	/* read the sense block from the controller */
	/* the DISKCNTL references must NOT be reordered */

	while ( DISKCNTL->intstt & BUSY )
		;	/* wait while controller busy */

	sns.ercode = DISKCNTL->cmdsns;
	sns.status = DISKCNTL->cmdsns;
	sns.lun = rcnvdsk[(sns.status >> 5) & 0x3];
	sns.pcylnm = DISKCNTL->cmdsns;
	sns.pcylnm = (sns.pcylnm << 8) + DISKCNTL->cmdsns;
	sns.headnm = DISKCNTL->cmdsns;
	sns.sectnm = sns.headnm & 0x1f;
	sns.headnm = sns.headnm >> 5;
	sns.n = DISKCNTL->cmdsns;
	sns.snsbt6 = DISKCNTL->cmdsns;
	sns.snsbt7 = DISKCNTL->cmdsns;
	sns.snsbt8 = DISKCNTL->cmdsns;
	sns.snsbt9 = DISKCNTL->cmdsns;
}


#if NO_ASM_SUPPORT

/************************************************************************/
/*	Disk read data transfer						*/
/************************************************************************/

rddat(bp)
REG BYTE *bp;
{
	/* This routine should be written in assembly language later. */

	REG WORD cnt;

	for ( cnt = DCXFER; cnt--; )
		*bp++ = DISKCNTL->data;
}

/************************************************************************/
/*	Disk write data transfer					*/
/************************************************************************/

wrdat(bp)
REG BYTE *bp;
{
	/* This routine should be written in assembly language later. */

	REG WORD cnt;

	for ( cnt = DCXFER; cnt; cnt-- )
		DISKCNTL->data = *bp++;
}

#endif	/* NO_ASM_SUPPORT	*/

/************************************************************************/
/*	Disk Read with error correction					*/
/************************************************************************/

RdDiskOnce(dsk, psn, pscnt, bufp)
REG WORD  dsk;
REG LONG  psn;
REG WORD  pscnt;
REG BYTE *bufp;
{
	LONG erofst;	/* offset from bp of location to correct */
	BYTE *bp;	/* address of last sector read - for correction */

	SndCmd(dsk, psn, pscnt, DISKREAD);
	while ( 1 )
	{
		while ( DISKCNTL->intstt & BUSY )
			if ( DISKCNTL->intstt & DRQ )
			{
				rddat(bufp);
				bufp += DCXFER;
			}
		GetDiskSense();	/* check for error */
		if ( sns.ercode != CORRDER )
			return (sns.ercode);
		else
		{		/* correct the data - winchester only */
			erofst = (sns.snsbt6 << 8) + sns.snsbt7;
			bp = (BYTE *)((LONG)bufp - 256);
			bp[erofst] ^= sns.snsbt8;
			bp[erofst+1] ^= sns.snsbt9;
			if ( sns.n )	/* more to read - reissue command */
				SndCmd(dsk, psn+pscnt-sns.n, sns.n, DISKREAD);
			else return (E_OK);	/* done - no error to report */
		}
	}
}

/************************************************************************/
/*	Disk Transfers							*/
/************************************************************************/

/************************************************************************/
/*	Disk Sector Write						*/
/************************************************************************/

WriteSector(dsk,psn,nsecs,bufp)
WORD  dsk;
LONG  psn;
WORD  nsecs;
BYTE *bufp;
{
	WORD  rcnt;	/* retry count */
	BYTE *bp;	/* buffer pointer for retries */
	WORD  error;	/* error flag */
	WORD  blkcnt;	/* blkcnt determines how many blocks to transfer */	

		/* An idiosyncracy of the RWIN driver is that disk writes    */
		/* are in terms of 128 bytes for the floppy and 256 bytes    */
		/* for the hard disk.  Therefore, to write a normal sector   */
		/* will need 4 writes for the floppy and 2 for the hard disk.*/

	bp = bufp;			/* save buffer addr */
	rcnt = RETRYCNT;		/* retry count */

				/* determine number of blocks to transfer */
	if( psn == 0L && dsk == 0)	/* 1st track of floppy is special */
		blkcnt = 16;
	else
		blkcnt = (dsk == 0) ? (nsecs * 4) : (nsecs * 2);

	do				/* error retry loop */
	{
		SndCmd(dsk, psn, nsecs, DISKWRITE);
		while ( DISKCNTL->intstt & BUSY )
			if ( (DISKCNTL->intstt & DRQ) && blkcnt )
			{
				wrdat(bufp);
				bufp += DCXFER;
				blkcnt--;
			}
		GetDiskSense();
		error = sns.ercode;
		bufp = bp;		/* restore buffer addr */
	} while (error && --rcnt);

	if( error )
		return (EWRITF);
	else
		return (E_OK);
}

/************************************************************************/
/*	Disk Sector Read						*/
/************************************************************************/

ReadSector(dsk,psn,nsecs,bufp)
WORD  dsk;		/* disk drive number */
LONG  psn;		/* first physical sector to access */
WORD  nsecs;		/* number of sectors to access */
BYTE *bufp;		/* buffer to write data onto */
{
	WORD  rcnt;	/* retry count */
	WORD  error;	/* error flag */

	rcnt = RETRYCNT;		/* retry count */

	do			/* error retry loop */
	{
		error = RdDiskOnce(dsk, psn, nsecs, bufp);
	} while (error && --rcnt);

	if (error)
	{
		return (EREADF);
	}
	else
	{
		return (E_OK);
	}
}


/************************************************************************/
/*	Disk Initialization						*/
/************************************************************************/

initdsks()
{
	REG WORD i;

	/* turn off controller interrupts */
	DSKCNTL->intstt = 0;

	/* configure controller for disks */
	SndCnf(0, 1, 79, 40);			/* a: fd, 96 tpi, ds */
	while ( DSKCNTL->intstt & BUSY ) 	/* wait while controller busy */
		;				/* assume no errors */
#if DISKB
	SndCnf(1, 1, 79, 40);			/* b: fd, 96 tpi, ds */
	while ( DSKCNTL->intstt & BUSY ) 	/* wait while controller busy */
		;				/* assume no errors */
#endif
#if DISKC	/* only initialize if present */
	SndCnf(2, CMHD, CMCYL, 255);		/* c: wd */
	while ( DSKCNTL->intstt & BUSY ) 	/* wait while controller busy */
		;				/* assume no errors */
#endif
#if DISKD
	SndCnf(3, DMHD, DMCYL, 255);		/* d: wd */
	while ( DSKCNTL->intstt & BUSY ) 	/* wait while controller busy */
		;				/* assume no errors */
#endif
}


LONG
format(dsk)
REG WORD dsk;
{
#if	MEMDSK
	if (dsk == MEMDSK)
		return(E_OK);
#endif

	SndCmd(dsk, 0L, 0, DSKDFRMT);
	GetDiskSense();

	if ( sns.ercode )
		return(ERROR);

	SndCmd(dsk, 0L, 0, DSKTFRMT);
	GetDiskSense();

	if ( sns.ercode )
		return(ERROR);

	return(E_OK);
}

prthex(h)
LONG h;
{
	LONG h2;
	if (h2 = (h >> 4) & 0xfffffff) prthex(h2);
	else cons_out('0');
	cons_out(hexch[h & 0x0f]);
}
