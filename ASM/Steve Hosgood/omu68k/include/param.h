/*******************************************************************************
 *	Param.h		System parameters for MICROBOX OMU
 *******************************************************************************
 *
 * Notes:
 * NFPERU can be > NFILES because usually several files are 'DUP'-ed
 *		together in a process. Also for concurancy
 */

#ifndef VERSION
# define	VERSION		4	/* Omus version number */
#endif
# define	NFILES		20	/* total no. distinct files */
# define	NFPERU		20	/* no. files per user process */

# define	NPROC		10	/* total no. processes */
# define	NINODES		15	/* no. in core inode copies */
# define	NBUF		30	/* no. in core block buffers */
# define	NMOUNT		4	/* Max number of mounted file-stores */

# define	NSWAPS		16	/* No of items in swap space */
# define	PATHLEN		64	/* Maxinum path name for prog */

/* DEVICES */

# define	NBDEVS		4	/* Number of block devs in blk switch */
# define	NCDEVS		8	/* Number of char devs in char switch */

# define	RDEV_MAJ	0	/* Root device major (hard disk) */
# define	RDEV_MIN	0	/* Root device minor */
# define	PDEV_MAJ	2	/* Pipe major device no (HARDDISK) */
# define	PDEV_MIN	0	/* Pipe minor device no (HARDDISK) */

/* Major device definitions for event handling */
# define	DEVFDMAJ	&bdevsw[0]
# define	DEVRDMAJ	&bdevsw[1]
# define	DEVTTYMAJ	&cdevsw[0]
# define	DEVNULLMAJ	&cdevsw[1]
# define	DEVRFDMAJ	&cdevsw[2]

		/* OMU extra bits */

# define	EVENTSON	1	/* Allows events processing, NOTE might
					 * slow down TTY handler if Enabled.
					 * Events are file events.
					 */

		/* SUPER BLOCK */

# define	BSIZE		512	/* Block size */
# define	BMASK		0777	/* Masks block size */
# define	BSHIFT		9	/* Shift for block */
# define	SUPERB		1	/* Super block */
# define	NICFREE		50	/* No blocks in freelist */
# define	NICINOD		100 	/* No inodes in inode list */
# define	NINDIR		(BSIZE/sizeof(daddr_t))	/* Number of directy's*/


/*
 * priorities
 * probably should not be
 * altered too much
 */

# define PSWP		0
# define PSIGNAL	5		/* Signal priority */
# define PINOD		10
# define PRIBIO		20
# define PPIPE		26
# define PTTY		28		/* TTY wait */
# define PWAIT		30		/* Process sleeping wait() */

# define PUSERMIN	30		/* Mininum user priority */
# define PUSER		50		/* Normal user priority */
# define PZERO		25
# define NZERO		20		/* Nice offset */

/*
 * Some macros for units conversion
 */
/* Core clicks (2K bytes) to segments (32K bytes) and vice versa */
#define ctos(x) (((long)(x)+15)>>4)
#define stoc(x) ((long)(x)<<4)

/* Bytes to disk blocks */
#define btod(x) (((x)+511)>>9)

/* Disk blocks to bytes */
#define dtob(x) ((x)<<9)

/* Core clicks (2K bytes) to disk blocks */
#define ctod(x) ((x)<<2)

/* inumber to disk address */
#define itod(x) (daddr_t)((((unsigned)(x)+15)>>3))

/* inumber to disk offset */
#define itoo(x) (int)(((x)+15)&07)

/* core clicks to bytes */
#define ctob(x) ((x)<<11)

/* core bytes to clicks */
#define btoc(x) ((((x)+2047)>>11)&0x1FFFFF)

/* Varible types */

typedef	long		daddr_t;
typedef char *		caddr_t;
typedef	long		mem_t;
typedef	unsigned short	ino_t;
typedef	long		time_t;
typedef	long		label_t[13];	/* regs d2-d7, a2-a7, pc */
typedef	short		dev_t;
typedef	long		off_t;

	/* selectors and constructor for device code */
/* #define	major(x)  	(int)(((unsigned)(x)>>8)) */
#define	major(x)	(int)((((x)>>8)) & 0xFF)
#define	minor(x)  	(int)((x)&0377)
#define	makedev(x,y)	(dev_t)((x)<<8|(y))
