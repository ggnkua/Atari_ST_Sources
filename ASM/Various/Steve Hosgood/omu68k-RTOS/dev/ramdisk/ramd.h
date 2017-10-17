/******************************************************************************
 *	Ramdisk settings	(Memory area defined in memory.h)
 ******************************************************************************
 */


/* Number of inode blocks */
# define	RD_NINODBK	6	/* 48 inodes */

/* Ramdisk definition structure */
struct ramdisk {
	short	nblocks;		/* Number of blocks in device */
	short	seg;			/* Memory segment it is in */
	unsigned long start;		/* Start of RAM area */
	short	nopen;			/* Number of opens */
};
