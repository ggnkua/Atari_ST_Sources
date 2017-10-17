/*
 * Block I/O buffer structure.
 */

struct buf {
	int		b_bno;
	int		b_dev;
	int		b_flags;
	char		b_buf[512];
	int		(*b_strat)();
	struct	buf	*b_next;
	struct	buf	*b_prev;
};

/*
 * Values of 'flags' field
 */

# define	ABORT		0x01
# define	WRITE		0x02
# define	B_BUSY		0x08
# define	B_INUSE		0x10	/* Buffer is being used */

/*
 * Mode flags for getbuf
 */

# define	ALLBUF		0	/* Uses least used buffer */
# define	ONEBUF		1	/* Uses last used buffer */

/*
 * Some functions don't return integers
 */

struct buf *getbuf();
struct buf *getibuf();
struct buf *gfreebuf();
