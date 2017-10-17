
/*******************************************************************************
 *	Inode.h		-	Include file OMU
 *******************************************************************************
 */

/*
 * The I node is the focus of all
 * file activity in unix. There is a unique
 * inode allocated for each active file,
 * each current directory, each mounted-on
 * file, text file, and the root. An inode is 'named'
 * by its dev/inumber pair. (iget/iget.c)
 * Data, from mode on, is read in
 * from permanent inode on volume.
 */

# define	NADDR	13		/* Number of addresses per block */

/*
 * Structure of an in-core copy of an inode.
 */
struct inode {
	struct dev      *i_mdev;
	short           i_minor;
	short           i_ino;
	short		i_flag;		/* Inode accessed flag */
	short           i_mode;         /* encoded file mode */
	short           i_nlink;
	unsigned        i_size;
	short           i_nlocks;
	unsigned        i_addr[13];
	short           i_uid;
	short           i_gid;
	long            i_atime;        /* last access */
	long            i_mtime;        /* last modification */
	long            i_ctime;        /* create date */
};

# define        NULLIPTR        (( struct inode * ) 0)
# define	ROOTINO		2

/*
 * Structure of an indirect block entry.
 */
struct indir {
	unsigned long	ind_addr;
};

/*
 * Encoding of flags. NOTE: only used for access type checking for file time.
 *	and One buffer operation of bcache.
 */
#define	ILOCK	01		/* inode is locked */
#define	IUPD	02		/* file has been modified */
#define	IACC	04		/* inode access time to be updated */
#define	IMOUNT	010		/* inode is mounted on */
#define	IWANT	020		/* some process waiting on lock */
#define	ITEXT	040		/* inode is pure text prototype */
#define	ICHG	0100		/* inode has been changed */

#define	IONEBUF	0200		/* Single buffer operation (EXEC) */

/*
 * Encoding of 'i_mode' as per stat.h.
 *
 */

/* modes */
#define	IFMT	0170000		/* type of file */
#define		IFDIR	0040000	/* directory */
#define		IFCHR	0020000	/* character special */
#define		IFBLK	0060000	/* block special */
#define		IFREG	0100000	/* regular */
#define		IFMPC	0030000	/* multiplexed char special */
#define		IFMPB	0070000	/* multiplexed block special */
#define		IFBMD	0110000	/* OMU block module special (Linkload device) */
#define		IFCMD	0120000	/* OMU char module special (Linkload device) */

#define	ISUID	04000		/* set user id on execution */
#define	ISGID	02000		/* set group id on execution */
#define ISVTX	01000		/* save swapped text even after use */
#define	IREAD	0400		/* read, write, execute permissions */
#define	IWRITE	0200
#define	IEXEC	0100

#define	IACCESS	0777		/* Access bits */
#define	IACCSS	0007		/* Access bits for check */
#define	IAREAD	0004		/* Inode access check read */
#define	IAWRITE	0002		/* Inode access check write */
#define	IAEXEC	0001		/* Inode access check exec */


/*
 * Modes for 'namlock' and 'srchdir':
 */

# define	CREATE	1
# define	SEARCH  2
# define	DELETE  3
# define	MKLINK  4
# define	EOPEN	5	/* Exec open, one buffer operation */

/*
 * Global variables..
 */

extern struct inode *user_curdir;

/*
 * Some functions don't return integers.
 */

extern struct inode *getiptr();
extern struct inode *namlock();
extern struct inode *relock();
extern struct inode *srchdir();
extern struct inode *lockfree();
extern struct inode *i_find();
