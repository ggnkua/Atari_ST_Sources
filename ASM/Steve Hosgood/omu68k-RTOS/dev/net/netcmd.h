/*******************************************************************************
 *	Netcmd.h
 *******************************************************************************
 */


/*	Net header */
struct	Netcmd {
	short	nc_cmd;		/* Command */
	long	nc_blk;		/* Block number */
};

struct	Netdata {
	struct	Netcmd nd_h;	/* Net header */
	char	nd_data[BSIZE];	/* Data in block */
};

/*	Net commands */
# define	CGETBLK		1
# define	CCHKBLK		2

/*	Net data return */
# define	DGETBLK		0x41
# define	DCHKBLK		0x42

# define	DERROR		0x40
