#ifndef minixfs_h
#define minixfs_h

#include <sys/types.h>
#include <string.h>
#include <ctype.h>

#include "atarierr.h"
#include "filesys.h"

#include "kernel.h"

#include "config.h"

#define DOM_TOS 0
#define DOM_MINT 1
#define NUM_DRIVES 32

#ifndef NULL
#define NULL 0L
#endif

/* Useful macro , is non zero only if 'x' is not a power of two */

#define NPOW2(x) ( ( (x) & (x-1) )!=0)

/* Dates smaller than 1st Jan 1980 confuse dostime _corr avoids them */

#define _corr(t) ( (t > 315532800L) ? t : 315532800L)

#define SIZEOF sizeof

/* General types we will use */
typedef unsigned short unshort;
typedef unsigned short ushort;
typedef unsigned char unchar;

/* Constants for fscntl */

#define MFS_BASE	0x100
#define MFS_VERIFY	(MFS_BASE)	/* Return minixfs magic number */
#define MFS_SYNC	(MFS_BASE|0x01)	/* Sync the filesystem */
#define MFS_CINVALID	(MFS_BASE|0x02)	/* Invalidate cache entries */
#define MFS_FINVALID	(MFS_BASE|0x03)	/* Invalidate Fileptrs */
#define MFS_INFO	(MFS_BASE|0x04)	/* Get info about filesystem */
#define MFS_USAGE	(MFS_BASE|0x05)	/* Get block allocation of a file */
#define MFS_IMODE	(MFS_BASE|0x06)	/* Change all bits in an inode mode */
#define MFS_GTRANS	(MFS_BASE|0x07) /* Get filename translation mode */ 
#define MFS_STRANS	(MFS_BASE|0x08) /* Set filename translation mode */
#define MFS_PHYS	(MFS_BASE|0x09) /* Get physical partition info */
#define MFS_IADDR	(MFS_BASE|0x0a) /* Get start address of minixfs */
#define MFS_UPDATE	(MFS_BASE|0x0b) /* Update daemon controls */

#define MFS_MAGIC	0x18970431	/* Magic number from MFS_VERIFY */

/* Filename translation modes */

#define SRCH_TOS	0x01		/* search with tosify , tos domain  */
#define SRCH_MNT	0x02		/* search with tosify , mint domain */
#define DIR_TOS		0x04		/* dir compat tosify  , tos domain  */
#define DIR_MNT		0x08		/* dir compat tosify  , mint domain */
#define LWR_TOS		0x10		/* lower case creat   , tos domain  */
#define LWR_MNT		0x20		/* lower case creat   , mint domain */
#define AEXEC_TOS	0x40		/* auto 'x' ,   tos domain.   */
#define AEXEC_MNT	0x80		/* auto 'x' ,	mint domain. */


typedef struct {
long total_inodes,total_zones;
long free_inodes,free_zones;
int version;			/* Filesystem version 1=V1 2=V2 */
int increment;			/* Directory increment */
long res1,res2,res3,res4;	/* Reserved for future use */
} mfs_info;

#ifdef NDEBUG
#define assert(expression)
#else
# ifdef __STDC__
#define assert(expression) \
	((expression) ? 0 : FATAL("assert(`%s') failed at line %ld of %s.", \
	    #expression, (long)__LINE__, __FILE__))
# else
#define assert(expression) if(expression) FATAL("assert(%s) failed", \
	    "expression")
# endif
#endif



/* Macro to determine maximum filename length for a given increment */

#define MMAX_FNAME(x) ( ( (x)<<4 ) -2)

/* Absolute maximum filename length */

#define MNAME_MAX MMAX_FNAME(MAX_INCREMENT)

#define BLOCK_SIZE	1024	/* # bytes in a disk block */
#define L_BS		10	/* log 2 bytes/block */

#define MAJOR			 8	/* major device = (dev>>MAJOR) & 0377 */
#define MINOR			 0	/* minor device = (dev>>MINOR) & 0377 */
#define NOLAST	(unshort *) 0	/* We dont want parent directory of a file */

/* Flag bits for i_mode in the inode. */

#define I_SYMLINK	0160000 /* symbolic link (not standard minix) */

#define I_TYPE		0170000	/* this field gives inode type */
#define I_REGULAR	0100000	/* regular file, not dir or special */
#define I_BLOCK_SPECIAL 0060000	/* block special file */
#define I_DIRECTORY	0040000	/* file is a directory */
#define I_CHAR_SPECIAL	0020000	/* character special file */
#define I_NAMED_PIPE	0010000 /* named pipe (FIFO) */
#define I_SET_UID_BIT	0004000	/* set effective uid on exec */
#define I_SET_GID_BIT	0002000	/* set effective gid on exec */
#define I_STICKY	0001000 /* sticky bit */
#define ALL_MODES	0007777	/* all bits for user, group and others */
#define RWX_MODES	0000777	/* mode bits for RWX only */
#define R_BIT		0000004	/* Rwx protection bit */
#define W_BIT		0000002	/* rWx protection bit */
#define X_BIT		0000001	/* rwX protection bit */
#define I_NOT_ALLOC	0000000	/* this inode is free */

/* Useful macros */
#define IS_DIR(m)	((m.i_mode & I_TYPE)==I_DIRECTORY)
#define IS_REG(m)	((m.i_mode & I_TYPE)==I_REGULAR)

/* Flag bits for cookie 'aux' field */
#define AUX_DEL	 1	/* file marked for deletion */
#define AUX_SYNC 2	/* l_sync() on next write */

/* Tables sizes */
#define NR_ZONE_NUMS	   9	/* # zone numbers in an inode */
#define NR_ZONE_NUMS2	  10	/* #zone numbers in v2 inode */

/* Miscellaneous constants */
#define SUPER_MAGIC   0x137F	/* magic number contained in super-block */
#define SUPER_V2      0x2468	/* v2 magic number */

#define FIND		0	/* tells search_dir to search for file */
#define ADD		1	/* tells search_dir to add a dir entry */
#define KILL		2	/* tells search_dir to kill entry	 */
#define POS		3	/* tells search_dir to find position   */

#define INVALID 	   0	/* Cache entry is garbage */
#define CLEAN		   1	/* Cache entry same as disk */
#define DIRTY		   2	/* Cache entry is more recent than disk */
#define LOCKED		   4	/* do not overwrite entry */

#define NOLOCK		   3	/* Bits not connected with locks */

#define BOOT_BLOCK  0		/* block number of boot block */
#define SUPER_BLOCK 1		/* block number of super block */
#define ROOT_INODE  (unshort)1	/* inode number for root directory */


/* Derived sizes */
#define ZONE_NUM_SIZE	 (SIZEOF(unshort))	     /* # bytes in zone nr  */
#define NR_DZONE_NUM	 (NR_ZONE_NUMS-2)	     /* # zones in inode    */
#define DIR_ENTRY_SIZE	 (SIZEOF(dir_struct))	     /* # bytes/dir entry   */
#define L_DIR_SIZE	 4			     /* log2 bytes/dir entry */	
#define INODES_PER_BLOCK (BLOCK_SIZE/INODE_SIZE)     /* # inodes/disk blk   */
#define L_IPB		 5			     /* log2 inodes/blk */
#define INODE_SIZE	 (SIZEOF(d_inode1))		 /* bytes in disk inode */
#define NR_DIR_ENTRIES	 (BLOCK_SIZE/DIR_ENTRY_SIZE) /* # dir entries/block */
#define NR_INDIRECTS	 (BLOCK_SIZE/ZONE_NUM_SIZE)  /* # zones/indir block */
#define LNR_IND		 9			     /* log 2 NR_INDIRECTS */
#define NR_DBL		 (NR_DZONE_NUM+NR_INDIRECTS) /* 1st zone in dbl ind */
#define INTS_PER_BLOCK	 (BLOCK_SIZE/SIZEOF(int))    /* # integers/block    */
#define SUPER_SIZE	 (SIZEOF(struct super_block)) /* super_block size    */
#define PIPE_SIZE	 (NR_DZONE_NUM*BLOCK_SIZE)   /* pipe size in bytes  */
#define MAX_ZONES (NR_DZONE_NUM+(NR_INDIRECTS+1l)*NR_INDIRECTS)

#define NR_ZONE_NUMS2	10
#define NR_DZONE_NUM2	(NR_ZONE_NUMS2-3)
#define ZONE_NUM_SIZE2	(SIZEOF(long))
#define INODES_PER_BLOCK2 (BLOCK_SIZE/INODE_SIZE2)
#define L_IPB2		4
#define INODE_SIZE2	(SIZEOF(d_inode))
#define NR_INDIRECTS2	(BLOCK_SIZE/ZONE_NUM_SIZE2)
#define LNR_IND2	8
#define NR_DBL2		(NR_DZONE_NUM2+NR_INDIRECTS2)
#define MAX_ZONES2 (NR_DZONE_NUMS2+(NR_INDIRECTS2+1l)*NR_INDIRECTS2)

#ifndef SEEK_SET
/* lseek() origins */
#define	SEEK_SET	0		/* from beginning of file */
#define	SEEK_CUR	1		/* from current location */
#define	SEEK_END	2		/* from end of file */
#endif


#ifndef min
#define min(a,b) ((a)>(b) ? (b) : (a))
#endif

typedef struct	{
  unshort s_ninodes;		/* # usable inodes on the minor device */
  unshort s_nzones;		/* total device size, including bit maps etc */
  unshort s_imap_blks;		/* # of blocks used by inode bit map */
  unshort s_zmap_blks;		/* # of blocks used by zone bit map */
  unshort s_firstdatazn;	/* number of first data zone */
  short int s_log_zsize;	/* log2 of blocks/zone */
  long s_max_size;		/* maximum file size on this device */
  short s_magic;		/* magic number to recognize super-blocks */
  short pad;			/* padding */
  long s_zones;			/* long version of s_nzones for v2 */
} super_block;

/* super_info contains information about each Minix filesystem */

typedef struct  {
	super_block sblk;	/* Actual super block */
	int dev;		/* Device this belongs to */
	long serialno;		/* Serial number of disk (ignored for now)*/
	long ioff;		/* Offset to inode 1 */
	ushort *ibitmap;
	ushort idirty;		/* Set if ibitmap changed after last write */
	long ilast;		/* search start for free inodes */
	ushort *zbitmap;
	ushort zdirty;		/* zbitmap dirty flag */
	long zlast;		/* search start for free zones */

/* This lot is filled in as appropriate for each FS type */

	char version;		/* 0 for V1, 1 for V2 : -1 for 'dummy' */
	unsigned ipb;		/* Inodes per block */
	unsigned zpind;		/* zones per indirection block */
	unsigned dzpi;		/* direct zones per inode */
	unsigned ndbl;		/* first zone number in double indirect block */
	int increment;		/* num of dir_structs per dir entry */
} super_info;

#define DFS ((super_info *) -1)

/* This is what a directory entry on the disk looks like. Note: we can use
 * a dirty trick to use this same structure for large filenames > 14 chars
 * the idea is to use only a fraction of the total entries , so that if
 * say the filename size is 30 we just use entries 0,2,4,6,8 etc. d_name
 * then occupies all of the next entry. This forces the max filename size
 * to be 2 less than a power of two (and certainly less than 1022), normally
 * 30 should be more than adequate to cover every filename you'll ever see.
 * 62 is for paranoids, but remember the path name limit of 128 characters.
 */

typedef struct {		/* directory entry */
  unshort d_inum;		/* inode number */
  char d_name[MMAX_FNAME(1)];	/* character string */
} dir_struct;

typedef struct {		/* disk inode. */
  unshort i_mode;		/* file type, protection, etc. */
  unshort i_uid;		/* user id of the file's owner */
  long i_size;			/* current file size in bytes */
  long i_mtime;			/* when was file data last changed */
  unchar i_gid;			/* group number */
  unchar i_nlinks;		/* how many links to this file */
  unshort i_zone[NR_ZONE_NUMS];	/* block nums for direct, ind, and dbl ind */
} d_inode1;

typedef struct {		/* V2.x disk inode */
  ushort i_mode;		/* file type, protection, etc. */
  ushort i_nlinks;		/* how many links to this file. HACK! */
  ushort i_uid;			/* user id of the file's owner. */
  ushort i_gid;			/* group number HACK! */
  long i_size;			/* current file size in bytes */
  long i_atime;			/* when was file data last accessed */
  long i_mtime;			/* when was file data last changed */
  long i_ctime;			/* when was inode data last changed */
  long i_zone[NR_ZONE_NUMS2];	/* block nums for direct, ind, and dbl ind */
} d_inode;

typedef
  union {
    char bdata[BLOCK_SIZE];		/* ordinary user data */
    dir_struct bdir[NR_DIR_ENTRIES];	/* directory block */
    unshort bind1[NR_INDIRECTS];		/* indirect block */
    long    bind[NR_INDIRECTS2];		/* v2 indirect block */
    d_inode1 binode1[INODES_PER_BLOCK];	/* inode block */
    d_inode binode[INODES_PER_BLOCK2]; /* v2 inode block */
  } bufr;

typedef struct {
	bufr	*buffer;
	long 	block;		/* Block number bufr contains */
	short	drive;		/* Drive of bufr */
	int	status;		
/* Valid status values:
 * 0=invalid
 * 1=valid&clean 
 * 2=dirty
 * 3=dirty but not essential (i.e. don't complain if not written out)
 */

} cache;

typedef struct {
	cache *pos,*start,*end;
} cache_control;

/* This is a special FILEPTR structure, it is pointed to by the devinfo field,
 * this speeds up read and write. 
 *	For write, 'zones' contains only the current writing block, which
 * is used if lots of small writes take place. For reading it contains a list
 * of the next few zones to read. Care is needed as an O_TRUNC (or a truncate
 * which  nothing uses at  present) can invalidate all  of this.  lckfirst
 * contains a pointer to where a pointer to the first lock is contained. This
 * means that if the first lock is deleted then only *lckfirst need be altered.
 * Following this is a series of 'guesses' as to where relevant info for a file
 * may be contained. This means that most of the time functions can find the
 * cache entry almost immediately, instead of searching. Since the cache is
 * dynamic and entries can be overwritten, the guess is not perfect and is
 * checked before use. If it is invalid then the guess is updated after a
 * successful load or search.
 */

typedef struct {
	long	zones[PRE_READ];	/* Zonecache for pre-read,write */
	long 	fzone;			/* chunk number in zone[0] */
	long	lzone;			/* Last valid chunk number */
	LOCK 	**lfirst;		/* pointer to pointer with first lock */
	#define NOGUESS ( (cache **) 0) /* Don't guess cache entry */
	cache 	*iguess;		/* Guess at inode cache position */
	cache	*zguess;		/* Guess at zone cache position */ 
	cache	*izguess;		/* Ind zone guess */
	cache	*dizguess;		/* Dbl ind zone guess */
} f_cache;

/* Physical partition structure */
struct phys_part {
long start;		/* Physical partition start sector number */
long finish;		/* End sector number */
char shadow;		/* Rwabs dev number to access this drive at */
char scsiz;		/* sector size 1=512 bytes 0=1K */
};

/* Macros for indirection blocks */

#define PIND(vers,tmp,index) \
	( (vers) ? (tmp->bind[index]) : (tmp->bind1[index]) )
#define IND(vers,temp,index) \
	( (vers) ? (temp.bind[index]) : (temp.bind1[index]) )

#endif
