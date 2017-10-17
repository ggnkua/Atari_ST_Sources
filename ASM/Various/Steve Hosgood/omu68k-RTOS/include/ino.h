/*
 * Inode structure as it appears on
 * a disk block.
 * Hacked to work on 68000, 28-4-85
 */

struct dinode
{
	unsigned short di_mode;        /* mode and type of file */
	short	di_nlink;       /* number of links to file */
	short	di_uid;         /* owner's user id */
	short	di_gid;         /* owner's group id */
	off_t	di_size;        /* number of bytes in file */
	char	di_addr[40];
	long    di_atime;       /* last access */
	long    di_mtime;       /* last mod */
	long    di_ctime;       /* create date */
};

#define INOPB   8       /* 8 inodes per block */

/* Works out data in di_addr[] */

#define	ADDR(x)		(((di_addr[(x)*3]<<16) & 0xFF0000) +\
			((di_addr[((x)*3)+1]<<8) & 0xFF00) +\
			((di_addr[((x)*3)+2])) & 0xFF)

/*
 * the 40 address bytes:
 *      39 used; 13 addresses
 *      of 3 bytes each.
 */

/*
 * Some routines don't return integers.
 */
struct dinode *getdiptr();
