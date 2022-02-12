/* Tables sizes */
#define NR_ZONE_NUMS       9	/* # zone numbers in an inode */

#define NR_FILPS          64	/* # slots in filp table */
#define I_MAP_SLOTS        8	/* max # of blocks in the inode bit map */
#define ZMAP_SLOTS         8	/* max # of blocks in the zone bit map */
#define NR_INODES         32	/* # slots in "in core" inode table */
#define NR_SUPERS          5	/* # slots in super block table */

#define FS_STACK_BYTES  (272 * sizeof (char *)) /* size of file system stack */

/* Miscellaneous constants */
#define SUPER_MAGIC   0x137F	/* magic number contained in super-block */
#define SU_UID 	   (uid_t) 0	/* super_user's uid_t */
#define SYS_UID    (uid_t) 0	/* uid_t for processes MM and INIT */
#define SYS_GID    (gid_t) 0	/* gid_t for processes MM and INIT */
#define NORMAL	           0	/* forces get_block to do disk read */
#define NO_READ            1	/* prevents get_block from doing disk read */
#define PREFETCH           2	/* tells get_block not to read or mark dev */

#define XPIPE  -(NR_TASKS+1)	/* used in fp_task when suspended on pipe */
#define XOPEN  -(NR_TASKS+2)	/* used in fp_task when suspended in open */

#define NO_BIT    (bit_nr) 0	/* returned by alloc_bit() to signal failure */
#define DUP_MASK        0100	/* mask to distinguish dup2 from dup */

#define LOOK_UP            0	/* tells search_dir to lookup string */
#define ENTER              1	/* tells search_dir to make dir entry */
#define DELETE             2	/* tells search_dir to delete entry */

#define CLEAN              0	/* disk and memory copies identical */
#define DIRTY              1	/* disk and memory copies differ */
#define ATIME            002	/* set if atime field needs updating */
#define CTIME            004	/* set if ctime field needs updating */
#define MTIME            010	/* set if mtime field needs updating */

#define BOOT_BLOCK  (block_nr)0	/* block number of boot block */
#define SUPER_BLOCK (block_nr)1	/* block number of super block */
#define ROOT_INODE  (ino_t)1	/* inode number for root directory */

#define INFO               2	/* where in data_org is info from build */
#define END_OF_FILE     -104	/* eof detected */

/* Derived sizes */
#define ZONE_NUM_SIZE    sizeof(zone_nr)	     /* # bytes in zone nr  */
#define NR_DZONE_NUM     (NR_ZONE_NUMS-2)	     /* # zones in inode    */
#define DIR_ENTRY_SIZE   sizeof(dir_struct)	     /* # bytes/dir entry   */
#define INODES_PER_BLOCK (BLOCK_SIZE/INODE_SIZE)     /* # inodes/disk blk   */
#define INODE_SIZE       (sizeof (d_inode))	     /* bytes in disk inode */
#define NR_DIR_ENTRIES   (BLOCK_SIZE/DIR_ENTRY_SIZE) /* # dir entries/block */
#define NR_INDIRECTS     (BLOCK_SIZE/ZONE_NUM_SIZE)  /* # zones/indir block */
#define INTS_PER_BLOCK   (BLOCK_SIZE/sizeof(int))    /* # integers/block    */
#define SUPER_SIZE       sizeof(struct super_block)  /* super_block size    */
#define PIPE_SIZE        (NR_DZONE_NUM*BLOCK_SIZE)   /* pipe size in bytes  */
#define MAX_ZONES (NR_DZONE_NUM+NR_INDIRECTS+(long)NR_INDIRECTS*NR_INDIRECTS)
						     /* max zones in a file */
#define printf printk
