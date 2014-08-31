;----------------------------------------------------------------------------
; File name:	RA_MINIX.I			Revision date:	2000.07.20
; Created by:	Ulf Ronald Andersson		Creation date:	2000.07.20
;----------------------------------------------------------------------------
; Purpose:
;	define structs and constants for access on MINIX filesystems
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_MINIX_defined
RA_MINIX_defined	set	1
;----------------------------------------------------------------------------
DOM_TOS		= 0
DOM_MINT	= 1
NUM_DRIVES	= 32
;----------------------------------------------------------------------------
;---	Useful C macro, is non zero only if 'x' is not a power of two
;-------------------------------------
;---# define NPOW2(x)	(((x) & (x - 1)) != 0)
;----------------------------------------------------------------------------
;	Filename translation modes
;-------------------------------------
SRCH_TOS	= $01	;search with tosify, tos domain
SRCH_MNT	= $02	;search with tosify, mint domain
DIR_TOS		= $04	;dir compat tosify, tos domain
DIR_MNT		= $08	;dir compat tosify, mint domain
LWR_TOS		= $10	;lower case creat, tos domain
LWR_MNT		= $20	;lower case creat, mint domain
AEXEC_TOS	= $40	;auto 'x', tos domain.
AEXEC_MNT	= $80	;auto 'x', mint domain.
;----------------------------------------------------------------------------
;---	C Macro to determine maximum filename length for a given increment
;-------------------------------------
;---# define MMAX_FNAME(x)	(((x) << 4) - 2)
;----------------------------------------------------------------------------
BLOCK_SIZE	= 1024		;# bytes in a disk block
L_BS		= 10		;log 2 bytes/block
;----------------------------------------------------------------------------
;	Flag bits for i_mode in the inode
;-------------------------------------
I_OLDLINK	= @160000	;old symbolic link mode
;-------
I_SYMLINK	= @120000	;symbolic link (Linux compatible)
I_TYPE		= @170000	;this field gives inode type
I_REGULAR	= @100000	;regular file, not dir or special
I_BLOCK_SPECIAL	= @060000	;block special file
I_DIRECTORY	= @040000	;file is a directory
I_CHAR_SPECIAL	= @020000	;character special file
I_NAMED_PIPE	= @010000	;named pipe (FIFO)
I_SET_UID_BIT	= @004000	;set effective uid on exec
I_SET_GID_BIT	= @002000	;set effective gid on exec
I_STICKY	= @001000	;sticky bit
ALL_MODES	= @007777	;all bits for user, group and others
RWX_MODES	= @000777	;mode bits for RWX only
R_BIT		= @000004	;Rwx protection bit
W_BIT		= @000002	;rWx protection bit
X_BIT		= @000001	;rwX protection bit
I_NOT_ALLOC	= @000000	;this inode is free
;----------------------------------------------------------------------------
;---	Useful C macros
;-------------------------------------
;---# define IS_DIR(m)		((m.i_mode & I_TYPE) == I_DIRECTORY)
;---# define IS_REG(m)		((m.i_mode & I_TYPE) == I_REGULAR)
;---# define IS_SYM(m)		((m.i_mode & I_TYPE) == I_SYMLINK)
;---# define IM_SPEC(m)		(((m & I_TYPE) == I_CHAR_SPECIAL) || ((m & I_TYPE) == I_BLOCK_SPECIAL))
;----------------------------------------------------------------------------
;	Flag bits for cookie 'aux' field
;-------------------------------------
AUX_DEV		= $1f	;Mask for bios device
AUX_DRV		= $20	;First 5 bits are bios dev mask
AUX_DEL		= $40	;file marked for deletion
AUX_SYNC	= $80	;l_sync() on next write
;----------------------------------------------------------------------------
;Miscellaneous constants
;-------------------------------------
SUPER_MAGIC	= $137F	;magic number contained in super-block
SUPER_V1_30	= $138f	;magic number for Linux+V1+30chars
SUPER_V2	= $2468	;v2 magic number
;-------
MINIX_VALID_FS	= $0001	;Clean fs
MINIX_ERROR_FS	= $0002	;fs has errors
;-------
MINIX_LINK_MAX	= 65530
;----------------------------------------------------------------------------
FIND		= 0	;tells search_dir to search for file
ADD		= 1	;tells search_dir to add a dir entry
KILL		= 2	;tells search_dir to kill entry	
POS		= 3	;tells search_dir to find position
;----------------------------------------------------------------------------
BOOT_BLOCK  	= 0	;block number of boot block
SUPER_BLOCK 	= 1	;block number of super block
ROOT_INODE	= 1	;inode number for root directory
;----------------------------------------------------------------------------
;Derived sizes
;-------------------------------------
NR_ZONE_NUMS	=	9				;# zone numbers in an inode
NR_DZONE_NUM	=	(NR_ZONE_NUMS - 2)		;# zones in inode
ZONE_NUM_SIZE	=	(sizeof (uint16))		;# bytes in zone nr
DIR_ENTRY_SIZE	=	(sizeof (dir_struct))		;# bytes/dir entry
L_DIR_SIZE	=	4				;log2 bytes/dir entry	
INODES_PER_BLOCK =	(BLOCK_SIZE / INODE_SIZE)	;# inodes/disk blk
L_IPB		=	5				;log2 inodes/blk
INODE_SIZE	=	(sizeof (d_inode1))		;bytes in disk inode
NR_DIR_ENTRIES	=	(BLOCK_SIZE / DIR_ENTRY_SIZE)	;# dir entries/block
NR_INDIRECTS	=	(BLOCK_SIZE / ZONE_NUM_SIZE)	;# zones/indir block
LNR_IND		=	9				;log 2 NR_INDIRECTS
NR_DBL		=	(NR_DZONE_NUM + NR_INDIRECTS)	;1st zone in dbl ind
INTS_PER_BLOCK	=	(BLOCK_SIZE / sizeof (int))	;# integers/block
SUPER_SIZE	=	(sizeof (struct super_block))	;super_block size
PIPE_SIZE	=	(NR_DZONE_NUM * BLOCK_SIZE)	;pipe size in bytes
MAX_ZONES	=	(NR_DZONE_NUM + (NR_INDIRECTS + 1l) * NR_INDIRECTS)
;-------
NR_ZONE_NUMS2	=	10
NR_DZONE_NUM2	=	(NR_ZONE_NUMS2 - 3)
ZONE_NUM_SIZE2	=	(sizeof (int32))
INODES_PER_BLOCK2 =	(BLOCK_SIZE / INODE_SIZE2)
L_IPB2		=	4
INODE_SIZE2	=	(sizeof (d_inode))
NR_INDIRECTS2	=	(BLOCK_SIZE / ZONE_NUM_SIZE2)
LNR_IND2	=	8
NR_DBL2		=	(NR_DZONE_NUM2 + NR_INDIRECTS2)
MAX_ZONES2	=	(NR_DZONE_NUMS2 + ((NR_INDIRECTS2 + 1l) * NR_INDIRECTS2 + 1l) * NR_INDIRECTS2)
;----------------------------------------------------------------------------
typedef struct super_block SB;
struct super_block
{
	uint16	s_ninodes;	;# usable inodes on the minor device
	uint16	s_nzones;	;total device size, including bit maps etc
	uint16	s_imap_blks;	;# of blocks used by inode bit map
	uint16	s_zmap_blks;	;# of blocks used by zone bit map
	uint16	s_firstdatazn;	;number of first data zone
	uint16	s_log_zsize;	;log2 of blocks/zone
	uint32	s_max_size;	;maximum file size on this device
	uint16	s_magic;	;magic number to recognize super-blocks
	uint16	s_state;	;filesystem state
	uint32	s_zones;	;long version of s_nzones for v2
};
;----------------------------------------------------------------------------
;	super_info contains information about each Minix filesystem
;-------------------------------------
typedef struct super_info SI;
struct super_info
{
	DI	*di;	;device identifikator for this device
	SB	*sblk;	;ptr to our super block
	uint32	s_flags;
	
	uint16	dev;	;device this belongs to
	uint16	res;	;alignment
	
	int32	serial;	;Serial number of disk (ignored for now)
	int32	ioff;	;Offset to inode 1
	
	uint16	*ibitmap;
	uint16	*zbitmap;
	
	uint16	idirty;	;ibitmap dirty flag
	uint16	zdirty;	;zbitmap dirty flag
	
	int32	ilast;	;search start for free inodes
	int32	zlast;	;search start for free zones
	
	UNIT	*sunit;	;actual super block
	
	;This lot is filled in as appropriate for each FS type
	uint16	ipb;	;Inodes per block
	uint16	zpind;	;zones per indirection block
	uint16	dzpi;	;direct zones per inode
	uint16	ndbl;	;first zone number in double indirect block
	short	incr;	;num of dir_structs per dir entry
	short	mfname;	;max file name
};
;----------------------------------------------------------------------------
;	These are the fs-independent mount-flags: up to 16 flags are supported
;-------------------------------------
MS_RDONLY	=	   1	;Mount read-only
MS_NOSUID	=	   2	;Ignore suid and sgid bits
MS_NODEV	=	   4	;Disallow access to device special files
MS_NOEXEC	=	   8	;Disallow program execution
MS_SYNCHRONOUS	=	  16	;Writes are synced at once
MS_REMOUNT	=	  32	;Alter flags of a mounted FS
MS_MANDLOCK	=	  64	;Allow mandatory locks on an FS
S_QUOTA		=	 128	;Quota initialized for file/directory/symlink
S_APPEND	=	 256	;Append-only file
S_IMMUTABLE	=	 512	;Immutable file
MS_NOATIME	=	1024	;Do not update access times.
MS_NODIRATIME	=	2048    ;Do not update directory access times
S_NOT_CLEAN_MOUNTED =	4096	;not cleanly mounted
;----------------------------------------------------------------------------
;This is what a directory entry on the disk looks like. Note: we can use
;a dirty trick to use this same structure for large filenames > 14 chars
;the idea is to use only a fraction of the total entries , so that if
;say the filename size is 30 we just use entries 0,2,4,6,8 etc. d_name
;then occupies all of the next entry. This forces the max filename size
;to be 2 less than a power of two (and certainly less than 1022), normally
;30 should be more than adequate to cover every filename you'll ever see.
;62 is for paranoids, but remember the path name limit of 128 characters.
;-------------------------------------
;	directory entry:
;-------------------------------------
typedef struct dir_struct dir_struct;
struct dir_struct
{
	uint16	d_inum;			;inode number
	char	d_name[MMAX_FNAME(1)];	;character string
};
;----------------------------------------------------------------------------
;	V2.x disk inode
;-------------------------------------
typedef struct d_inode d_inode;
struct d_inode
{
	uint16	i_mode;			;file type, protection, etc.
	uint16	i_nlinks;		;how many links to this file. HACK!
	uint16	i_uid;			;user id of the file's owner.
	uint16	i_gid;			;group number HACK!
	uint32	i_size;			;current file size in bytes
	uint32	i_atime;		;when was file data last accessed
	uint32	i_mtime;		;when was file data last changed
	uint32	i_ctime;		;when was inode data last changed
	uint32	i_zone[NR_ZONE_NUMS2];	;block nums for direct, ind, and dbl ind
};
;----------------------------------------------------------------------------
typedef union bufr bufr;
union bufr
{
	char		bdata[BLOCK_SIZE];		;ordinary user data
	dir_struct	bdir[NR_DIR_ENTRIES];		;directory block
	int32		bind[NR_INDIRECTS2];		;indirect block
	d_inode		binode[INODES_PER_BLOCK2];	;inode block
};
;----------------------------------------------------------------------------
;This is a special FILEPTR structure, it is pointed to by the devinfo field,
;this speeds up read and write. 
;	For write, 'zones' contains only the current writing block, which
;is used if lots of small writes take place. For reading it contains a list
;of the next few zones to read. Care is needed as an O_TRUNC (or a truncate
;which  nothing uses at  present) can invalidate all  of this.  lckfirst
;contains a pointer to where a pointer to the first lock is contained. This
;means that if the first lock is deleted then only *lckfirst need be altered.
;-------------------------------------
typedef struct f_cache f_cache;
struct f_cache
{
	int32	zones[PRE_READ];	;Zonecache for pre-read,write
	int32 	fzone;			;chunk number in zone[0]
	int32	lzone;			;Last valid chunk number
	LOCK 	**lfirst;		;pointer to pointer with first lock
};
;----------------------------------------------------------------------------
;	C Macros for indirection blocks
;-------------------------------------
;---# define PIND(tmp, index)	(tmp->bind[index])
;---# define IND(temp, index)	(temp.bind[index])
;----------------------------------------------------------------------------
	endc	;RA_MINIX_defined
;----------------------------------------------------------------------------
;End of file:	RA_MINIX.I
;----------------------------------------------------------------------------
