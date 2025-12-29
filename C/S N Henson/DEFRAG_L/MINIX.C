/*
 * minix.c - minix-specific functions and data for the Linux file system 
 * degragmenter. 
 * minix.c,v 1.1 1992/12/23 03:43:22 linux Exp
 *
 * This file is responsible for managing those data structures dependent
 * on the minix.  Specifically, it
 * + allocates space for the various disk maps stored in memory; 
 * + reads and writes superblock information; 
 * + reads the used-data-zones and used-inodes maps into memory
 *   (inode_map and d2n/n2d_map respectively); and, 
 * + once the defragmentation is complete, rewrites the new free-space
 *   map to disk.
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

/* Modified for Minixfs/MiNT by S N Henson 1993 */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#include "defrag.h"

char * program_name = "defrag";

/* A few static variables and functions, needed only within minix.c
   for handling minix-specific data structures (like the free zone
   map) */
static char *zone_map = NULL;

#define bm_zone_in_use(x) (bit(zone_map,(x)-FIRSTZONE+1))
#define bm_mark_zone(x) (setbit(zone_map,(x)-FIRSTZONE+1),changed=1)
#define bm_unmark_zone(x) (clrbit(zone_map,(x)-FIRSTZONE+1),changed=1)


/* Read the superblock and inode table and reserve space for the
   remaining disk map tables */
void read_tables (void)
{
	if (debug)
		printf ("DEBUG: read_tables()\n");
	if (BLOCK_SIZE != lseek (IN, BLOCK_SIZE, SEEK_SET))
		die ("seek failed");
	if (BLOCK_SIZE != read (IN, super_block_buffer, BLOCK_SIZE))
		die ("unable to read super-block");
	if (MAGIC != MINIX_SUPER_MAGIC)
		die ("bad magic number in super-block");
	if (ZONESIZE != 0 || BLOCK_SIZE != 1024)
		die("Only 1k blocks/zones supported");
	if (!IMAPS || IMAPS > MINIX_I_MAP_SLOTS)
		die("bad s_imap_blocks field in super-block");
	if (!ZMAPS || ZMAPS > MINIX_Z_MAP_SLOTS)
		die("bad s_zmap_blocks field in super-block");

	inode_map = malloc (IMAPS*BLOCK_SIZE);
	if (!inode_map)
		die ("Unable to allocate inodes bitmap\n");
	if (IMAPS*BLOCK_SIZE != read(IN,inode_map,IMAPS*BLOCK_SIZE))
		die("Unable to read inode map");
	if(set_size(ZONES))
		die("Can't access partition");


	d2n_map = malloc ((ZONES - FIRSTZONE) * sizeof (*d2n_map));
	n2d_map = malloc ((ZONES - FIRSTZONE) * sizeof (*n2d_map));
	if (!n2d_map || !d2n_map)
		die ("Unable to allocate zone maps\n");

	zone_map = malloc (ZMAPS*BLOCK_SIZE);
	if (!zone_map)
		die ("Unable to allocate zone bitmap\n");
	if (ZMAPS*BLOCK_SIZE != read(IN,zone_map,ZMAPS*BLOCK_SIZE))
		die("Unable to read zone map");

	inode_buffer = malloc (INODE_BUFFER_SIZE);
	if (!inode_buffer)
		die ("Unable to allocate buffer for inodes");
	if (INODE_BUFFER_SIZE != read (IN, inode_buffer, INODE_BUFFER_SIZE))
		die ("Unable to read inodes");

	inode_average_map = malloc (INODES * sizeof(*inode_average_map));
	if (!inode_average_map)
		die ("Unable to allocate buffer for inode averages");
	memset (inode_average_map, 0, (INODES * sizeof(*inode_average_map)));

	inode_order_map = malloc (INODES * sizeof(*inode_order_map));
	if (!inode_order_map)
		die ("Unable to allocate buffer for inode order");
	memset (inode_order_map, 0, (INODES * sizeof(*inode_order_map)));

	if (NORM_FIRSTZONE != FIRSTZONE)
		printf ("Warning: Firstzone != Norm_firstzone\n");
	first_zone = FIRSTZONE;
	zones = ZONES;
	block_size = BLOCK_SIZE;
	
	if (show)
	{
		printf ("%d inodes\n",INODES);
		printf ("%d blocks\n",ZONES);
		printf ("Firstdatazone=%d (%d)\n",FIRSTZONE,NORM_FIRSTZONE);
		printf ("Zonesize=%d\n",BLOCK_SIZE<<ZONESIZE);
		printf ("Maxsize=%d\n\n",MAXSIZE);
	}
}

/* Write the superblock, free zone/inode maps and inode table to disk */
void write_tables (void)
{
	if (debug)
		printf ("DEBUG: write_tables()\n");
	if (BLOCK_SIZE != lseek (IN, BLOCK_SIZE, SEEK_SET))
		die ("seek failed in write_tables");
	if (BLOCK_SIZE != write (IN, super_block_buffer, BLOCK_SIZE))
		die ("unable to write super-block");
	if (IMAPS*BLOCK_SIZE != write(IN,inode_map,IMAPS*BLOCK_SIZE))
		die("Unable to write inode map");
	if (ZMAPS*BLOCK_SIZE != write(IN,zone_map,ZMAPS*BLOCK_SIZE))
		die("Unable to write zone map");
	if (INODE_BUFFER_SIZE != write(IN,inode_buffer,INODE_BUFFER_SIZE))
		die("Unable to write inodes");
}

/* Recalculate the free zone map.  The defragmentation procedure will
   migrate all free blocks to the end of the disk partition, and so
   after defragmentation the free space map must be updated to reflect
   this. Free zones are determined by n2d_map, and the macro
   zone_in_use(n) is defined in defrag.h for this purpose. The minix
   fs stores the free zone map as a bitmap, so this bitmap must now be
   recreated from the n2d_map. */
void salvage_free_zones (void)
{
	Block i;
	if (debug)
		printf ("DEBUG: salvage_zone_freelist()\n");
	memset (zone_map, -1, ZMAPS*BLOCK_SIZE);
	for (i=FIRSTZONE; i<ZONES; i++)
	{
		if (!zone_in_use(i))
			bm_unmark_zone(i);
	}
}


/* Read the map of used/unused data zones on disk.  The extfs stores a
   linked list of unused blocks.
   The map is held jointly in d2n_map and n2d_map, described in
   defrag.h.  These are initialised to the identity map (d2n(i) = n2d(i)
   = i), and then the free zone bitmap is scanned, and all unused zones
   are marked as zero in both d2n_map and n2d_map. */
void init_zone_maps (void)
{
	Block i;

	if (debug)
		printf ("DEBUG: init_zone_maps()\n");
	for (i = FIRSTZONE; i < ZONES; i++)
	{
		if (bm_zone_in_use(i))
		{
			d2n(i) = i;
			n2d(i) = i;
		}
		else
		{
			d2n(i) = 0;
			n2d(i) = 0;
		}
	}
}

/* Read in the map of used/unused inodes.  For the minix-fs, we don't
   need to anything since the bitmap is read in by read_tables(). */
void init_inode_bitmap (void)
{
}
