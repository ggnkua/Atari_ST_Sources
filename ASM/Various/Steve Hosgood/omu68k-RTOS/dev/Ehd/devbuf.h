/******************************************************************************
 *	Devbuf.h	Device disk buffering system data
 ******************************************************************************
 */

# define	NODEVBUFS	1	/* Number of buffers */
/* # define	FULLBUFFERING	1 */	/* Buffered write as well as read */

/*
 *	defines for the buffering system for omu floppies
 */

#define	MAXSECTS	2		/* Maximum number of sectors in buf */
#define	SECTSIZE	512

struct Dbuf{
	char 	flags;		/* used in flushing */
	short	mindev;		/* which drive is it for */
	short	bstart;		/* first block */
	short	bend;		/* last block */
	struct	Dbuf *prev;	/* Previous buffer */
	struct	Dbuf *next;	/* Next buffer */
	char	data[SECTSIZE * MAXSECTS];		/* track */
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

#define	INBUF(a,b)	((a->flags) && (b->b_bno >= a->bstart) \
				&& (b->b_bno < a->bend) \
				&& (b->b_dev == a->mindev))

extern struct	Dbuf *getdevbuf(), *checkdevbuf();
