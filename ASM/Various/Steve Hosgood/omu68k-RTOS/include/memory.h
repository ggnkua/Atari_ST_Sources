/******************************************************************************
 *	Memory.h	Information on system memory allocation
 ******************************************************************************
 */

/*	System memory is broken up into Major memory segments.
 *	These major segments are further split into Minor segments.
 *	The number of minor segments is different depending on the use
 *	of the particular segment.
 */

/* Memory allocation Major Segments */

#define NMSEGS		7		/* Number of major memory segments */

#define	TOTALSEG	0		/* All of memory */
#define KERNELSEG	1		/* Kernal segment number */
#define PROCSEG		2		/* Process segment */
#define PROCSEG2	3		/* Process segment 2 */
#define SWAPSEG		4		/* Swap segment */
#define	RAMDISKSEG	5		/* Ramdisk segment number */
#define	MODULESEG	6		/* Module segment for device drivers */

/* Number of minor segments */
#define	NMINSEG0	1		/* All of memory */
#define NMINSEG1	1		/* Kernal segment number */
#define NMINSEG2	1		/* Process segment */
#define NMINSEG3	1		/* Process segment 2 */
#define NMINSEG4	20		/* Swap segment */
#define	NMINSEG5	1		/* Ramdisk segment number */
#define	NMINSEG6	10		/* Module segment for device drivers */

#define	MMUBOUND	0x008000L	/* MMU page boundary ( for data seg ) */
#define	MMUMASK		0xFFFF8000L	/* MMU page boundary mask */

/* Memory segment usage structures */

/* Minor segments */
struct	Minseg {
	short	inuse;			/* Number of things in segment */
	short	pid;			/* Process using segment */
	caddr_t	start;			/* Memory start */
	caddr_t	end;			/* Memory end */
};

/* Major segments */
struct	Majseg {
	short	inuse;			/* Number of things in segment */
	short	nsegs;			/* Number of minor segments */
	struct	Minseg *segs;		/* Pointer to minor segments */
	caddr_t	start;			/* Memory start */
	caddr_t	end;			/* Memory end */
};

extern	struct Majseg mem_maj[NMSEGS];	/* Major segments */
