#define NSIZE	10	/* Size of big inode cache in blocks */


/* Inode status structure */

typedef struct
{
	unsigned short flag;
			/* Flags or'ed together */
#define I_FREE	0x01	/* Inode free */
#define I_DIR	0x02	/* Is a directory */
#define I_FDD	0x04	/* Fix '..' inode silently */
#define I_D	0x08	/* '.' present */
#define I_DD	0x10	/* '..' present */
#define I_FOUND 0x20	/* Has a parent */
#define I_LINK	0x40	/* Dir has a dir hard link in it */
#define I_FIXDD	0x80	/* Prompt for fixing '..' */
#define I_EMP	0x100	/* Dir contains free slots */
	long 	links;	/* Number of links to this inode */
	unsigned short parent;  /* Inode of parent (from '..')*/
} inode_stat;

/* Structure for multiply allocated blocks */

typedef struct zlst
{
	zone_nr zone;			/* zones */
	unsigned inum;			/* inode zone found on */
        unsigned flag; /* Status flag */
#define FOUND   0x1
#define REMOVE  0x2
#define IGNORE  0x4
	long	mod;			/* Modified time of zone */
	struct zlst *next;		/* Pointer to next entry */
} zlist;

static zlist *fzlist,*lzlist;		/* Pointer to first and last entry */


