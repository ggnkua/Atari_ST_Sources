/* defs.h */


#define	RESOURCEFILE	"HDX.RSC"	/* Resource file for main */
#define	WCAPFILE	"WINCAP"	/* name of winnie-cap file */

#define	MEGABYTE	2048L			/* 1Mb worth of blocks */
#define MAXSECT		32760			/* max sector */
#define	IBMMAXSECT	1114112			/* maxsect = spt x head x #cyl          */
#define CLUSIZ		1024			/* size of a cluster in bytes */
								    /*         = 17  x 64   x 1024 = 1114112 */
#define IBMSPT		17				/* sector per track of IBM is 17 */
#define IBMMCYL   	1024			/* max cylinder of IBM is 1024 */
#define IBMMHEAD    64				/* max head of IBM hard disk driver */
#define IBMHEAD  	8				/* the head of IBM hard disk driver */
#define	MAXPSIZ		((32*MEGABYTE)-1)	/* 32Mb partition limit */
#define	NAMSIZ		1024			/* max length of a name */
#define DOS12		0x01			/* primary DOS 12 bit FAT */
#define DOS16		0x04			/* primary DOS 16 bit FAT */
#define SPC			2				/* sector per cluster */
#define BPS         512L            /* bytes per sector */
#define BPEN        2				/* bytes per entry */
#define NUMEN       256		        /* number of entries */
#define BPDIR       32              /* byte per dirtory */
#define ENPS        (BPS/BPDIR)     /* entries per sector */
#define FAT12       341             /* BPS/1.5 = 341 */
#define FAT16       256             /* BPS/2 = 256 */
#define MB16        0x8000L         /* 16 mega bytes */
#define MB32        0x10000L        /* 32 mega bytes */
#define ROOTSECT	1L				/* the root sector is on sector */
#define SCAN_BS     0				/* the flag for sortpart() use */
#define USER_ED     1				/* the flag for sortpart() use */
#define NO_EXT		-1				/* no extended partition */
#define MAXBUFSECT	254				/* max # of sector for memory check */

#define WI_KIND		0		/* window to be opened on screen */

#define MAXPHYSDEVS	16		/* max #devs on DMA bus */
#define	MAXLOGDEVS	14		/* max # logical devices */
#define MAXPART	    30		/* assume max # of IBM partitions are 30 */
#define	NPARTS		4		/* #partitions in root block */
#define	EXTRALOGD 	100		/* define some more logical device for logmap */

#define	NULL	0L
#define	LONG	long
#define	WORD	int
#define UWORD	unsigned int
#define	BYTE	char

#define	SECTOR	LONG

#define	OFF		0
#define ON		1

#define	NO		0
#define YES		1
#define NOMAX   2

#define	FALSE		0
#define TRUE		1

#define	OK		0
#define	ERROR		(-1)
#define BAILOUT		(-2)
#define MDMERR		(-3)	/* medium changed error */

#define ARROW_MOUSE	graf_mouse(ARROW, 0x0L)
#define BEE_MOUSE	graf_mouse(HOURGLASS, 0x0L)

extern long gemdos();
extern char *mymalloc();
