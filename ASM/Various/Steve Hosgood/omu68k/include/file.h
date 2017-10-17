/*
 * Structure of an element of the file table.
 */

struct file {
	short		f_mode;
	short		f_ndup;        /* no. fd's pointing here */
	short		f_type;
	short		f_dev;
	struct inode	*f_inode;
	long		f_curblk;	/* Current block number */
	short		f_curchar;
	struct dev	*f_handler;
	struct file	*f_pipelink;	/* Other end of pipe file entry */
};

/*
 * Values of 'f_mode'.
 */

# define        READABLE        1
# define        WRITEABLE       2
# define	PIPE		4

/*
 * Values of 'f_type' field.
 */

# define        STD     0
# define        B_SPECL 1
# define        C_SPECL 2

