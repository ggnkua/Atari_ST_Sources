#ifndef _LINUX_MINIX_FS_H
#define _LINUX_MINIX_FS_H

/*
 * The minix filesystem constants/structures
 */

/*
 * Thanks to Kees J Bot for sending me the definitions of the new
 * minix filesystem (aka V2) with bigger inodes and 32-bit block
 * pointers. It's not actually implemented yet, but I'll look into
 * it.
 */

#ifndef BLOCK_SIZE
#define BLOCK_SIZE	1024l
#endif

#define MINIX_NAME_LEN 14
#define MINIX_ROOT_INO 1

#define MINIX_I_MAP_SLOTS	8
#define MINIX_Z_MAP_SLOTS	8
#define MINIX_SUPER_MAGIC	0x137F
#define NEW_MINIX_SUPER_MAGIC	0x2468

#define MINIX_INODES_PER_BLOCK ((BLOCK_SIZE)/(sizeof (struct minix_inode)))
#define NEW_MINIX_INODES_PER_BLOCK ((BLOCK_SIZE)/(sizeof(struct new_minix_inode)))
#define MINIX_DIR_ENTRIES_PER_BLOCK ((BLOCK_SIZE)/(sizeof (struct minix_dir_entry)))

struct minix_inode {
	unsigned short i_mode;
	unsigned short i_uid;
	unsigned long i_size;
	unsigned long i_time;
	unsigned char i_gid;
	unsigned char i_nlinks;
	unsigned short i_zone[9];
};

/*
 * The new minix inode has all the time entries, as well as
 * long block numbers and a third indirect block (7+1+1+1
 * instead of 7+1+1). Also, some previously 8-bit values are
 * now 16-bit. The inode is now 64 bytes instead of 32.
 */
struct new_minix_inode {
	unsigned short i_mode;
	unsigned short i_nlinks;
	unsigned short i_uid;
	unsigned short i_gid;
	unsigned long i_size;
	unsigned long i_atime;
	unsigned long i_mtime;
	unsigned long i_ctime;
	unsigned long i_zone[10];
};

/*
 * minix super-block data on disk
 */
struct minix_super_block {
	unsigned short s_ninodes;
	unsigned short s_nzones;
	unsigned short s_imap_blocks;
	unsigned short s_zmap_blocks;
	unsigned short s_firstdatazone;
	unsigned short s_log_zone_size;
	unsigned long s_max_size;
	unsigned short s_magic;
	unsigned short s_pad;	/* Padding */
	unsigned long s_zones;	/* Number of zones for V2 */
};

#endif
