/*
 * minix.h - minix-specific include file for the Linux file system 
 * degragmenter. 
 * minix.h,v 1.1 1992/12/23 03:43:23 linux Exp
 *
 * Copyright (C) 1992 Stephen Tweedie (sct@dcs.ed.ac.uk)
 *
 * Copyright (C) 1992 Remy Card (card@masi.ibp.fr)
 *
 * Copyright (C) 1991 Linus Torvalds (torvalds@kruuna.helsinki.fi)
 * 
 * This file may be redistributed under the terms of the GNU General
 * Public License.
 *
 */

#include <minix_fs.h>

#define NAME_LEN MINIX_NAME_LEN

#define ROOT_INO 1
#define FIRST_USER_INODE 2
#define DIRECT_ZONES 7

#ifdef MINIX_V2
typedef long Block;
#define d_inode new_minix_inode
#else

typedef unsigned short Block;

#define d_inode minix_inode

#endif 

#define UPPER(size,n)		((size + ((n) - 1)) / (n))
#define INODE_SIZE		(sizeof (struct d_inode))
#define INODE_BLOCKS		UPPER(INODES, MINIX_INODES_PER_BLOCK)
#define INODE_BUFFER_SIZE	(INODE_BLOCKS * BLOCK_SIZE)

#define BITS_PER_BLOCK		(BLOCK_SIZE<<3)

#define Super		(* (struct minix_super_block *) super_block_buffer)
#define INODES ((unsigned long)Super.s_ninodes)
#ifdef MINIX_V2
#define ZONES Super.s_zones
#else
#define ZONES ((unsigned long)Super.s_nzones)
#endif
#define IMAPS ((unsigned long)Super.s_imap_blocks)
#define ZMAPS ((unsigned long)Super.s_zmap_blocks)
#define FIRSTZONE ((unsigned long)Super.s_firstdatazone)
#define ZONESIZE ((unsigned long)Super.s_log_zone_size)
#define MAXSIZE ((unsigned long)Super.s_max_size)
#define MAGIC (Super.s_magic)
#define NORM_FIRSTZONE (2+IMAPS+ZMAPS+INODE_BLOCKS)
#ifdef MINIX_V2
#define INODES_PER_BLOCK (BLOCK_SIZE >> 2)
#undef MINIX_SUPER_MAGIC
#undef MINIX_INODES_PER_BLOCK
#define MINIX_SUPER_MAGIC NEW_MINIX_SUPER_MAGIC
#define MINIX_INODES_PER_BLOCK NEW_MINIX_INODES_PER_BLOCK
#else
#define INODES_PER_BLOCK (BLOCK_SIZE >> 1)
#endif
