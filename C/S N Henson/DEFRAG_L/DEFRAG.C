/*
 * defrag.c - the Linux file system degragmenter.
 * defrag.c,v 1.7 1993/01/07 14:48:48 linux Exp
 *
 * Copyright (C) 1992, 1993 Stephen Tweedie (sct@dcs.ed.ac.uk)
 *
 * Copyright (C) 1992 Remy Card (card@masi.ibp.fr) 
 *
 * Copyright (C) 1991 Linus Torvalds (torvalds@kruuna.helsinki.fi)
 * 
 * This file may be redistributed under the terms of the GNU General
 * Public License.
 *
 * Based on efsck 0.9 alpha by Remy Card and Linus Torvalds.
 * 
 */

/* Modified for Minixfs/MiNT by S N Henson. 1993. */


#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <termios.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/stat.h>

#include "defrag.h"
#include "version.h"

#ifndef NODEBUG
int debug = 0;
#endif

char * device_name = NULL;
int IN;
int verbose = 0; 
int show = 0;
int show_version = 0;
int test_disk = 0;
int salvage = 0;
int no_bad_inode = 0;
int badblocks = 0;
int readonly = 0;
int changed = 0;
int blocks_until_sync = 0;

Block next_block_to_fill = 0, first_zone = 0;
unsigned int zones = 0, block_size = 0;

/* Global buffer variables */
char * inode_buffer = NULL;
char super_block_buffer[BLOCK_SIZE];
char * inode_map = NULL;
Block *inode_average_map = NULL;
int *inode_order_map = NULL;
#ifdef EXTFS
char * bad_map = NULL;
#endif
Block *n2d_map = NULL, *d2n_map = NULL;

/* Local variables */
static float sum_inode_zones;
static int count_inode_blocks;
static int used_inodes = 0;

/* optimise_zone : find the next destination block for the optimised data,
   and swap the zone with the old contents of that block if necessary.
   Only modify the relocation maps and (if necessary) the zone
   pointer; don't move any data just yet. */
void optimise_zone (Block *znr)
{
	Block ox, oy, nx, ny;

	if (debug)
		printf ("DEBUG: optimise_zone (&%d)\n", *znr);
	changed = 1;

	ox = *znr;
	check_zone_nr(ox);

#ifdef EXTFS
	/* Don't attempt to relocate a bad block! */
	if (zone_is_bad(*znr))
		return;
	while (zone_is_bad(next_block_to_fill))
		next_block_to_fill++;
#endif

	ny = next_block_to_fill++;
	check_zone_nr(ny);

	nx = d2n(ox);
	oy = n2d(ny);

	/* Update the zone maps. */
	d2n(ox) = ny;
	if (oy)
		d2n(oy) = nx;
	n2d(nx) = oy;
	n2d(ny) = ox;
	if (!readonly)
		*znr = ny;
}

#ifndef NODEBUG
void validate_relocation_maps()
{
	int i;
	
	for (i=first_zone; i < zones; i++)
	{
		if (n2d(i))
			assert (d2n(n2d(i)) == i);
		if (d2n(i))
			assert (n2d(d2n(i)) == i);
	}
}
#endif

/* walk_[ind_/dind_/tind_]zone - perform a tree walk over inode data zones.
   return true iff the block is relocated.
   Depending on the mode:
   mode == WZ_BAD_BLOCKS: scan bad block inode to create bad zone map.
   mode == WZ_SCAN:	  scan inode to determine average occupied block.
   mode == WZ_REMAP_IND:  optimise inode indirection zones
   mode == WZ_REMAP_DATA: optimise inode data zones - by this time the inode
			  indirection zones will have been modified to
			  point to the new zone locations, although
			  the zones will not have moved; hence,
			  lookups through the indirection blocks will
			  have to be passed through the n2d
			  translation.

   Note - there is NEVER any need to perform that n2d lookup if we are
   in readonly mode, since in that case the zone number changes never
   get written to disk.
*/

static inline void update_inode_average (Block n)
{
	sum_inode_zones += n;
	count_inode_blocks++;
}

static int walk_zone (Block * znr, enum walk_zone_mode mode)
{
	if (!*znr)
		return 0;
	if (debug)
		printf ("DEBUG: walk_zone(&%d, %d)\n", *znr, mode);
	check_zone_nr(*znr);

	if (mode == WZ_SCAN)
		update_inode_average(*znr);
	
	switch (mode)
	{
#ifdef EXTFS
	case WZ_BAD_BLOCKS:
		mark_bad(*znr);
#endif
	case WZ_SCAN:
	case WZ_REMAP_IND:
		break;
	case WZ_REMAP_DATA:
		optimise_zone(znr);
		return 1;
	}
	return 0;
}

static int walk_zone_ind (Block * znr, enum walk_zone_mode mode)
{
	static char blk[BLOCK_SIZE];
	int i, result = 0, blk_chg = 0;

	if (!*znr)
		return 0;
	if (debug)
		printf ("DEBUG: walk_zone_ind (&%d, %d)\n", *znr, mode);
	check_zone_nr (*znr);

	if (mode == WZ_SCAN)
		update_inode_average(*znr);
	
	if (mode == WZ_REMAP_DATA && !readonly)
		read_current_block(n2d(*znr), blk);
	else
		read_current_block(*znr, blk);

	if (mode == WZ_REMAP_IND)
	{
		optimise_zone(znr);
		result = 1;
	}
	
	for (i = 0; i < INODES_PER_BLOCK; i++)
		blk_chg |= walk_zone (i + (Block *) blk,
				      mode);
	/* The nodes beneath the single indirection block are data 
	   blocks, so the block will only be changed when mode == 
	   WZ_REMAP_DATA; in this case we need to pass the current 
	   "virtual" zone number through n2d_map to find the real zone 
	   number */
	if (blk_chg && !readonly)
		write_current_block (n2d(*znr), blk);
	if (mode != WZ_REMAP_IND)
		assert (!result);
	if (mode != WZ_REMAP_DATA)
		assert (!blk_chg);
	return result;
}

static int walk_zone_dind (Block * znr, enum walk_zone_mode mode)
{
	static char blk[BLOCK_SIZE];
	int i, result = 0, blk_chg = 0;

	if (!*znr)
		return 0;
	if (debug)
		printf ("DEBUG: walk_zone_dind (&%d, %d)\n", *znr, mode);
	check_zone_nr (*znr);

	if (mode == WZ_SCAN)
		update_inode_average(*znr);
	
	if (mode == WZ_REMAP_DATA && !readonly)
		read_current_block(n2d(*znr), blk);
	else
		read_current_block(*znr, blk);
	
	if (mode == WZ_REMAP_IND)
	{
		optimise_zone(znr);
		result = 1;
	}

	for (i = 0; i < INODES_PER_BLOCK; i++)
		blk_chg |= walk_zone_ind (i + (Block *) blk,
					  mode);
	/* By the time (during the WZ_REMAP_IND pass) that we come to 
	   rewrite this block after reallocating children indblocks, 
	   this current zone will have been optimised - so convert 
	   back to real disk blocks using the n2d map.  This also
	   applies to optimising triple indirection blocks below. */
	if (blk_chg && !readonly)
		write_current_block (n2d(*znr), blk);
	if (mode != WZ_REMAP_IND)
		assert ((!blk_chg) && (!result));
	return result;
}

#ifdef EXTFS
static int walk_zone_tind (Block * znr, enum walk_zone_mode mode)
{
	static char blk[BLOCK_SIZE];
	int i, result = 0, blk_chg = 0;

	if (!*znr)
		return 0;
	if (debug)
		printf ("DEBUG: walk_zone_tind (&%d, %d)\n", *znr, mode);
	check_zone_nr (*znr);

	if (mode == WZ_SCAN)
		update_inode_average(*znr);
	
	if (mode == WZ_REMAP_DATA && !readonly)
		read_current_block(n2d(*znr), blk);
	else
		read_current_block(*znr, blk);

	if (mode == WZ_REMAP_IND)
	{
		optimise_zone(znr);
		result = 1;
	}

	for (i = 0; i < INODES_PER_BLOCK; i++)
		blk_chg |= walk_zone_dind (i + (Block *) blk, mode);
	if (blk_chg && !readonly)
		write_current_block (n2d(*znr), blk);
	if (mode != WZ_REMAP_IND)
		assert ((!blk_chg) && (!result));
	return result;
}
#endif /* EXTFS */

void walk_inode (struct d_inode *inode, enum walk_zone_mode mode)
{
	int i;
	
	for (i = 0; i < DIRECT_ZONES ; i++)
		walk_zone (i + inode->i_zone, mode);
	walk_zone_ind (DIRECT_ZONES + inode->i_zone, mode);
	walk_zone_dind ((DIRECT_ZONES+1) + inode->i_zone, mode);
#ifdef EXTFS
	walk_zone_tind ((DIRECT_ZONES+2) + inode->i_zone, mode);
#endif
}

#ifdef EXTFS
void read_bad_zones (void)
{
	struct d_inode * inode = Inode + BAD_INO;

	if (debug)
		printf ("DEBUG: read_bad_zones()\n");
	if (inode->i_mode || inode->i_nlinks)
		die ("disk does not have a badblock inode.");
	if (!inode_in_use (BAD_INO))
		die ("The badblock inode is on the free list.");

	walk_inode(inode, WZ_BAD_BLOCKS);
}
#endif /* EXTFS */

void optimise_inode (unsigned int i, int scan)
{
	struct d_inode * inode;

	if (debug)
		printf ("DEBUG: optimise_inode(%d, %d)\n", i, scan);
	inode = Inode + i;
	if (!S_ISDIR (inode->i_mode) && !S_ISREG (inode->i_mode) &&
	    !S_ISLNK (inode->i_mode)
#ifdef EXTFS
	    && (i != BAD_INO)
#endif
	    )
	{
		inode_average_map[i] = 0;
		return;
	}
	if (verbose > 1)
	{
		if (scan)
			printf ("Scanning inode %d...", i);
		else
			printf ("Relocating inode %d...", i);
	}
	if (scan)
	{
		sum_inode_zones = 0.0;
		count_inode_blocks = 0;
		walk_inode(inode, WZ_SCAN);
		if (count_inode_blocks)
			inode_average_map[i] = 
				(Block) (sum_inode_zones / 
					 (float) count_inode_blocks);
		else
			inode_average_map[i] = 0;
	}
	else
	{
		walk_inode(inode, WZ_REMAP_IND);
		walk_inode(inode, WZ_REMAP_DATA);
	}
	if (verbose > 1)
	{
		if (scan)
			printf (" %d block%s.", 
				count_inode_blocks,
				count_inode_blocks==1 ? "" : "s");
		printf ("\n");
	}
}


/* Scan the disk map.  For each inode, calculate the average of all
   zone numbers occupied by that inode. */
void scan_used_inodes()
{
	int i;

	if (debug)
		printf ("DEBUG: scan_used_inodes()\n");
	if (verbose)
		printf ("Scanning inode zones...\n");
	optimise_inode (ROOT_INO, 1);
	for (i=FIRST_USER_INODE; i<=INODES; i++)
	  	if (inode_in_use(i))
			optimise_inode(i, 1);
}

/* Optimise the disk map.  This involves passing twice over the
   zone tree for each inode; once to allocate the new block to each
   indirection block, once to allocate data blocks (and at the same
   time modifying the indirection blocks to reflect the new map - but
   we don't actually MOVE any data yet). */
void optimise_used_inodes()
{
	int i;

	if (debug)
		printf ("DEBUG: optimise_used_inodes()\n");
	if (verbose)
		printf ("Creating data relocation maps...\n");
	for (i=0; i<used_inodes; i++)
		optimise_inode(inode_order_map[i], 0);
}

/* Sort the inodes in ascending order of average occupied block.  
   Optimising inodes in this order should lead to blocks having to be
   moved, on average, shorter distances on the disk.  This reduces the
   typical time between rescuing a block and writing it to its final
   destination, reducing the average size of the rescue pool. */
static int compare_inodes (const void *a, const void *b)
{
	Block ave_a = inode_average_map[*((int*) a)];
	Block ave_b = inode_average_map[*((int*) b)];
	if (ave_a < ave_b)
		return -1;
	if (ave_a == ave_b)
		return 0;
	return 1;
}

void sort_inodes (void)
{
	int i;

	if (debug)
		printf ("DEBUG: sort_inodes()\n");
	if (verbose)
		printf ("Sorting inodes...\n");
	
	/* Initialise the inode order. */
	used_inodes = 0;
	inode_order_map[used_inodes++] = ROOT_INO;
#ifdef EXTFS
	inode_order_map[used_inodes++] = BAD_INO;
#endif
	for (i=FIRST_USER_INODE; i<=INODES; i++)
	{
		if (inode_in_use(i))
			inode_order_map[used_inodes++] = i;
	}
	/* Artificially give root inode high priority; it will be the
	   first thing on the disk */
	inode_average_map[ROOT_INO] = 0;
#ifdef EXTFS
	/* For extfs, we want the bad block inode's indirection blocks next */
	inode_average_map[BAD_INO] = 1;
#endif

	/* And sort... */
	qsort (inode_order_map, used_inodes,
	       sizeof(*inode_order_map),
	       compare_inodes);
}

int main (int argc, char ** argv)
{
	int i;
	char c;

	printf ("%s %s\n", program_name, version);
	if (argc && *argv)
		program_name = *argv;
	while ((c = getopt (argc, argv, 
			    "vVrsp:"
#ifndef NODEBUG
			    "d"
#endif
			    )) != EOF)
		switch (c)
		{
			case 'v': verbose++; break;
			case 'V': show_version=1; break;
			case 'r': readonly=1; show=1; break;
			case 's': show=1; break;
			case 'p': 
			{
				pool_size = strtoul(optarg,0,10); 
				if (pool_size < 20)
					pool_size = 20;
				break;
			}
#ifndef NODEBUG
			case 'd': debug=1; break;
#endif
			default: usage();
		}
	if (show_version)
	{
		printf ("CVS version %s\n", CVSID);
	}
	
	if (optind != argc - 1)
	{
		if (show_version)
			exit(0);
		usage ();
	}

	device_name = argv[optind];
	if (readonly)
		IN = open (device_name, O_RDONLY);
	else
		IN = open (device_name, O_RDWR);
	if (IN < 0)
		die("unable to open '%s'");
	for (i = 0 ; i < 3; i++)
		sync();
	read_tables ();
	init_buffer_tables ();
	init_zone_maps ();
	init_inode_bitmap ();
#ifdef EXTFS
	read_bad_zones ();
#endif
	next_block_to_fill = FIRSTZONE;
	scan_used_inodes ();
	sort_inodes ();
	optimise_used_inodes ();
#ifndef NODEBUG
	validate_relocation_maps ();
#endif
	remap_disk_blocks ();
	if (!readonly)
	{
		salvage_free_zones ();
		write_tables ();
		sync ();
	}
	if (show)
	{
		int free;

#ifdef MINIXFS
		for (i=1,free=0 ; i<INODES ; i++)
			if (!inode_in_use(i))
				free++;
#else
		free = FREEINODESCOUNT;
#endif
		printf ("\n%6d inode%s used (%d%%)\n", (INODES - free),
			((INODES - free) != 1) ? "s" : "",
			100 * (INODES - free) / INODES);

#ifdef MINIXFS
		for (i=FIRSTZONE,free=0 ; i<ZONES ; i++)
			if (!zone_in_use(i))
				free++;
#else
		free = FREEBLOCKSCOUNT;
#endif
		printf ("%6d zone%s used (%d%%)\n"
#ifdef EXTFS		       
			"%6d bad block%s\n"
#endif
			, (ZONES - free),
			((ZONES - free) != 1) ? "s" : "",
			100 * (ZONES - free) / ZONES
#ifdef EXTFS
			, badblocks,
			badblocks != 1 ? "s" : ""
#endif
			);

		printf ("\nRelocation statistics:\n");
		printf ("%d buffer reads in %d group%s, of which:\n",
			count_buffer_reads, count_read_groups,
			count_read_groups==1 ? "" : "s");
		printf ("  %d read-aheads.\n",
			count_buffer_read_aheads);
		printf ("%d buffer writes in %d group%s, of which:\n",
			count_buffer_writes, count_write_groups,
			count_write_groups==1 ? "" : "s");
		printf ("  %d migrations, %d forces.\n",
			count_buffer_migrates, count_buffer_forces);
	}
	return (0);
}
