/******************************************************************************
 *	Swap.h		Swap data
 ******************************************************************************
 */


# define	SWAPCREATE	-2	/* Table entry being created */
# define	SWAPSTICK	-1	/* Sticky proccess in here */

# define	SWAPDISK	-2	/* Segment is on disk */

# define	SPROC	1		/* Process swap out */
# define	SSTICK	2		/* Sticky process swap out */
# define	STEXT	4		/* Text area */
# define	SDATA	8		/* Data area */

/* Swap space management structure */
struct	Swapspace{

	short	pid;			/* Proccess id or SWAPSTICK */
	char	name[PATHLEN];		/* Process name */
	struct	Object object;		/* Proccess or file ID */
	short	textseg;		/* Text segment number */
	short	dataseg;		/* Data segment number */
	struct	Psize	psize;		/* Process sizes */
};

struct	Segarea {
	short	lock;
	long	start;
	long	end;
};

extern struct Swapspace swapspace[];
extern struct Segarea segarea[];
