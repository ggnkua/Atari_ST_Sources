/* defs.h */


#define	RESOURCEFILE	"HDX.RSC"	/* Resource file for main */
#define	WCAPFILE	"WINCAP"	/* name of winnie-cap file */

#define	MEGABYTE	2048L			/* 1Mb worth of blocks */
#define	MAXPSIZ		((32*MEGABYTE)-1)	/* 32Mb partition limit */
#define	NAMSIZ		1024			/* max length of a name */

#define WI_KIND		0		/* window to be opened on screen */

#define MAXPHYSDEVS	8		/* max #devs on DMA bus */
#define	MAXLOGDEVS	14		/* max # logical devices */
#define	NPARTS		4		/* #partitions in root block */

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
