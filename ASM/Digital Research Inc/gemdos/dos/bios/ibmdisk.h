/*	@(#)ibmdisk.h	2.9		*/
/*  External functions */

EXTERN WORD swapw();
EXTERN LONG swapl();
EXTERN WORD getword();
EXTERN putword();

#define FORMATCMD	FALSE

/*  Equates for PC-DOS 1.1 disk format */

/*
 *	These values are used to allocate buffers and are
 *	"expected worst values".
 *
 *	The numbers allow mapping up to ~39Mb with 8K clusters
 *	and 1.5 byte FAT entries and so can make use of a 40Mb
 *	drive.
 *
 *	We have not implemented 16 bit (2 byte) FAT entries
 *	in this cross utility, though I don't think it would
 *	be hard....
 */

#define MAXSECTSIZE 512		/* max expected size of one sector in bytes */
#define MAXFATSIZE  28		/* max expected number of sectors in a FAT */
#define MAXCLSIZE   8192	/* max expected number of bytes in a cluster */

#define MAXRTDIRENTRIES	512	/* max exp. number of root directory entries */

/*
 *	Some constants
 */

#define DIRENTRYSZBYTES	32	/* size of directory entry in bytes */
#define BTSZBYTES	4096
#define NFATS		2	/* We always have two copies of FAT */

#define TENBUGSECTORS	2	/* two 256 byte sectors for TENbug */

/*
 *	General Hard Disk Definitions for VME/10.
 *
 *	BTCYLS is the number of cylinders we need to reserve
 *	for hardware badtrack mapping at the end of the disk
 *	to use this feature of RWIN controller on the VME/10.
 *	If you port this util, and you use software bad track handling
 *	in your environment, it would go to 0.
 */

#define HBPS		256	/* hard disk bytes per sector */
#define HSPT		32	/* sectors per track */
#define HATTR		0x10	/* Configuration attribute for hard disk */
#define HPRECOMP	255
#define HBTSTARTSEC	2	/* Boot Start Sector */
#define HNUMDIRENTRIES	512

/*
 *	NOTE: 5, 10 and 15 Mb hard disks supported here
 *	are VERY similar, and differ only in the number of HEADS
 *	physically.  We do use larger FAT tables to span the disk.
 *
 *	If you wanted to add new disks, you would have to
 *	define the parameters below, and make an entry to initialize
 *	with those numbers in "dkconf.c".
 */

/*
 *	5 Megabyte Hard Disk Defines
 */

#define H5SPCLUSTER		(2048/HBPS)
#define H5SPFAT			15
#define H5HEADS			2
#define H5CYL			306
#define H5BTCYLS		12
#define H5PRECOMP		255

/*
 *	10 Megabyte Hard Disk Defines
 */

#define H10SPCLUSTER		(2048/HBPS)
#define H10SPFAT		30
#define H10HEADS		4
#define H10CYL			306
#define H10BTCYLS		12
#define H10PRECOMP		255

/*
 *	15 Megabyte Hard Disk Defines
 */

#define H15SPCLUSTER		(4096/HBPS)
#define H15SPFAT		22
#define H15HEADS		6
#define H15CYL			306
#define H15BTCYLS		12
#define H15PRECOMP		255

/*
 *	40 Megabyte Micropolis-Type Hard Disk Defines
 */

#define H40SPCLUSTER		(8192/HBPS)
#define H40SPFAT		28
#define H40HEADS		6
#define H40CYL			830
#define H40BTCYLS		12
#define H40PRECOMP		255

/*
 *	Floppy Disk Definitions for VME/10.
 */

#define FBPS		512	/* floppy disk bytes per sector */
#define FHIDDEN		16	/* hidden sectors - two tracks */
#define FSPT		8	/* sectors per track */
#define FATTR		0xf	/* Configuration attribute for floppy disk */
#define FBTSTARTSEC	8
#define FSPCLUSTER	4
#define FSPFAT		1
#define FNUMDIRENTRIES	224
#define FHEADS		2
#define FCYL		80
#define FPRECOMP	40

/* doesn't include two hidden tracks.
 */

#define FNSECTORS	1248

/*
 *	The FS structure is our global catch all for media
 *	dependent information.
 *
 *	I think we got our bases covered.
 */

typedef struct
{
	WORD	disknum;
	WORD	bps;		/* bytes per sector - TENbug Config also */

	WORD	bpc;		/* bytes per cluster */

	WORD	clszinsecs;	/* these sizes are in PHYSICAL SECTORS */
	WORD	rtdirszinsecs;
	WORD	fatszinsecs;

	WORD	numrtdirentries;/* used to set up boot record */
	LONG	hiddensectors;
	WORD	reservedsectors;

	WORD	nfats;
	LONG	nsects;

	LONG	fatstartsec;	/* Starting sector values */
	LONG	rtdirstartsec;
	LONG	datastartsec;

	WORD	numbootsecs;	/* Boot loader information */
	LONG	bootstartsec;	/* Starting sector */

	WORD	attr;		/* TENbug Configuration Block Information */
	BYTE	spt;
	BYTE	heads;
	WORD	cylinders;
	WORD	precomp;

	BYTE	mediatype;	/* MS-DOS tag if hard or floppy disk? */
} FS;

/* return flags */

#define ERROR (-1)
#define OK	0

/*
 *	mediatype id - the first word of the FAT.
 */

#define FMEDIA	0xFF	/* ibm number - check value for PC/AT */
#define HMEDIA	0xF8	/* hard disk media */
