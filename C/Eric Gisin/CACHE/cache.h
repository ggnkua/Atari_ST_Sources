/*
 * Floppy Disk Cache (Atari ST)
 */

#ifndef NULL			/* belong in <stddef.h> */
#define	NULL	0L
typedef	long	size_t;
#endif

/* magic functions to return internal tables to cstat */
#define	CSTAT	-1			/* return address of cache tables */
#define	CINIT	-2			/* clear cache */

/* cache parameters */
#define	NSECT	(82*2*10)		/* maximum sectors cached */
#define	CYCLE	100			/* update interval */

#define	A_INC	16			/* increment for each reference */

/* indices for stats array */
#define	TOTAL	0
#define	HITS	1
#define	READS	2
#define	WRITES	3
#define	RECLMS	4
#define	STATS	5			/* elements in stats */

#define	NOBUF	(-1)			/* no cached sector */

/* per sector cache information */
typedef struct {
	short	avg;		/* average usage */
	short	buf;		/* index of cached sector in cbufs [] */
} Cache;

typedef struct {
	char	data [512];
} Sector;

