/******************************************************************************
 *	Buffer.h	Floppydisk buffering data
 ******************************************************************************
 */

# define	NO_BUFS		1	/* Number of buffers (5 k each) */
/* # define	FULLBUFFERING	1 */ 	/* Buffered write as well as read */

/*
 *	defines for the buffering system for omu floppies
 */

#define	MAXSECTS	10		/* maximum track size */
#define	SIZE		512
#define	CD_PERTRK	9		/* 9 sects p track for codata */
#define	RP_PERTRK	10		/* 10 for mine */

struct fd_buffer{
	char age;	/* used to get lru */
	char type;	/* used in flushing */
	short d_minor;	/* which drive is it for */
	short bstart;	/* first block */
	short bend;	/* last block */
	char fdata[SIZE * MAXSECTS];		/* track */
};

/*
 *	these are the values of the type flag in the fd_buffer:
 *
 *		AVAILABLE means that the buffer is not used
 *		READABLE means that it has freshly read data
 *		WRITTEN means that it has been written to
 */

#define	AVAILABLE	0
#define	READABLE	1
#define WRITTEN		(1<<1)
#define NOTFOUND	-1
#define ERROR		-1
#define NOERROR		0

/*
 *	returns TRUE if the buffer b (include/buf.h) is in the
 *	fd_buffer a
 */

#define	INBUF(a,b)	((b->b_bno >= a.bstart) \
				&& (b->b_bno <= a.bend) \
				&& (b->b_dev == a.d_minor))

/*
 *	max block nos for codata and my floppy
 */

#define        CD_B_MAX           1440
#define        RP_B_MAX           1600


struct drive_info {
	int     d_nopen;
	int     d_curtrk;
	short	d_type;
};

# define	DTYPE80		0		/* 80 track drive */
# define	DTYPE40		1		/* 40 track drive */
# define	DTYPESS		2		/* Single sided */
# define	DTYPEINTEL	4		/* Intel byte ordering */
