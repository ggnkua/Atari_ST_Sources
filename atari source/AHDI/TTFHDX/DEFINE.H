/* defs.h */

#define	DEFUNIT		0		/* default physical unit */
#define	DEFDMDL		"CON3042"	/* default disk model */
#define	DEFID		"st"		/* default id for disk model */
#define	DEFDTYPE	"ACSI"		/* default disk type */
#define	DEFPATTERN	0xc623d5ab	/* default test pattern */

#define	RESOURCEFILE	"FHDX.RSC"	/* Resource file for main */
#define	WCAPFILE	"WINCAP"	/* name of winnie-cap file */

#define	MEGABYTE	2048L			/* 1Mb worth of blocks */
#define	MAXPSIZ		((16*MEGABYTE)-1)	/* 16Mb partition limit */
#define	NAMSIZ		1024			/* max length of a name */

#define WI_KIND		0		/* window to be opened on screen */

#define MAXPHYSDEVS	2		/* at most 2 units are hooked up */
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

/* Ascii values for some control codes */
#define	NOKEY		0x00	/* No key input or Not key we're looking for */
#define	CTRLQ		0x11	/* Ctrl-Q */
#define	CTRLR		0x12	/* Ctrl-R */
#define	CTRLS		0x13	/* Ctrl-S */
#define	ESC		0x1b	/* Escape */

/* Rwflag for Lrwabs() */
#define	PHYSREAD	0x8	/* physical read */
#define	PHYSWRT		0x9	/* physical write */

extern long gemdos();
extern char *mymalloc();
 
