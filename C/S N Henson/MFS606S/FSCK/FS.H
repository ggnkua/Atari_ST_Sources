/* This is a barebones file that defines the structures of the fs
 * along with a few constants
 */

#ifndef NULL
#define NULL 0L
#endif


#ifdef V1
#define d_inode d_inode1
#define NINDIR 512      		/* Zones per indirection block */
#define NDIR   7        		/* Direct zones in inode */
#define MAGIC SUPER_V1  		/* Super block magic number */
#define MAGIC_ALT SUPER_V2
#define NR_ZONE	NR_ZONE1
typedef unsigned short zone_nr;
#define do_fsck do_fsck1
#define FS_TYPE "V1"
#else

#ifdef V2
#define d_inode d_inode2
#define NINDIR 256
#define NDIR	7
#define MAGIC SUPER_V2
#define MAGIC_ALT SUPER_V1
#define NR_ZONE NR_ZONE2
typedef long zone_nr;
#define do_fsck do_fsck2
#define FS_TYPE "V2"

#endif
#endif

#define IPB	(BLOCKSIZE/sizeof(d_inode))	/* Inodes per block */
#define DSIZE (sizeof(dir_struct))		/* Directory entry size */
#define DPB (BLOCKSIZE/DSIZE)			/* Entries per block */


/* Useful macro , is non zero only if 'x' is not a power of two */

#define NPOW2(x) ( ( (x) & (x-1) )!=0)

/* Macro to determine maximum filename length for a given increment */

#define MMAX_FNAME(x) ( ( (x)<<4 ) -2)

/* Absolute maximum filename length */

#define MNAME_MAX MMAX_FNAME(MAX_INCREMENT)

#define BLOCKSIZE	1024l	/* # bytes in a disk block */

/* Flag bits for i_mode in the inode. */

#define I_SYMLINK	0160000 /* symbolic link (not standard minix) */

#define I_TYPE		0170000	/* this field gives inode type */
#define I_REGULAR	0100000	/* regular file, not dir or special */
#define I_BLOCK_SPECIAL 0060000	/* block special file */
#define I_DIRECTORY	0040000	/* file is a directory */
#define I_CHAR_SPECIAL	0020000	/* character special file */
#define I_NAMED_PIPE	0010000 /* named pipe (FIFO) */
#define I_SET_UID_BIT	0004000	/* set effective uid_t on exec */
#define I_SET_GID_BIT	0002000	/* set effective gid_t on exec */
#define I_STICKY	0001000 /* sticky bit */
#define ALL_MODES	0007777	/* all bits for user, group and others */
#define RWX_MODES	0000777	/* mode bits for RWX only */
#define R_BIT		0000004	/* Rwx protection bit */
#define W_BIT		0000002	/* rWx protection bit */
#define X_BIT		0000001	/* rwX protection bit */
#define I_NOT_ALLOC	0000000	/* this inode is free */

/* Miscellaneous constants */
#define SUPER_V1   0x137F	/* magic number contained in super-block */
#define SUPER_V2   0x2468	/* v2 magic number */

#define NR_ZONE1 9
#define NR_ZONE2 10

/* Macros for zone counts */

#define	NO_IND(x)	(((x)-NDIR+NINDIR-1)/NINDIR)
#define NO_DBL(x)	( (x > NDIR + NINDIR) ? 1 : 0)

#define ROOT_INODE  1	/* inode number for root directory */


typedef struct	{
  unsigned short s_ninodes;		/* # usable inodes on the minor device */
  unsigned short s_nzones;		/* total device size, including bit maps etc */
  unsigned short s_imap_blks;		/* # of blocks used by inode bit map */
  unsigned short s_zmap_blks;		/* # of blocks used by zone bit map */
  unsigned short s_firstdatazn;	/* number of first data zone */
  short int s_log_zsize;	/* log2 of blocks/zone */
  long  s_max_size;		/* maximum file size on this device */
  short s_magic;		/* magic number to recognize super-blocks */
  short pad;			/* padding */
  long s_zones;			/* long version of s_nzones for v2 */
} super_block;

/* This is what a directory entry on the disk looks like. Note: we can use
 * a dirty trick to use this same structure for large filenames > 14 chars
 * the idea is to use only a fraction of the total entries , so that if
 * say the filename size is 30 we just use entries 0,2,4,6,8 etc. d_name
 * then occupies all of the next entry. This forces the max filename size
 * to be 2 less than a power of two (and certainly less than 1022), normally
 * 30 should be more than adequate to cover every filename you'll ever see.
 * 62 is for paranoids , but remember the path name limit of 128 characters.
 */

typedef struct {		/* directory entry */
  unsigned short d_inum;	/* inode number */
  char d_name[14];		/* character string */
} dir_struct;

typedef struct {		/* disk inode. */
  unsigned short i_mode;		/* file type, protection, etc. */
  unsigned short i_uid;			/* user id of the file's owner */
  long i_size;			/* current file size in bytes */
  long i_mtime;		/* when was file data last changed */
  unsigned char i_gid;			/* group number */
  unsigned char i_nlinks;		/* how many links to this file */
  unsigned short i_zone[NR_ZONE1];	/* block nums for direct, ind, and dbl ind */
} d_inode1;

typedef struct {		/* V2.x disk inode */
  unsigned short i_mode;		/* file type, protection, etc. */
  unsigned short i_nlinks;		/* how many links to this file. HACK! */
  unsigned short i_uid;			/* user id of the file's owner. */
  unsigned short i_gid;			/* group number HACK! */
  long i_size;		/* current file size in bytes */
  long i_atime;		/* when was file data last accessed */
  long i_mtime;		/* when was file data last changed */
  long i_ctime;		/* when was inode data last changed */
  long i_zone[NR_ZONE2];	/* block nums for direct, ind, and dbl ind */
} d_inode2;

