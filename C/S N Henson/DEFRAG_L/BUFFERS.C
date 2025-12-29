/*
 * buffers.c - buffer management for the Linux file system degragmenter.
 * buffers.c,v 1.5 1993/01/07 14:48:47 linux Exp
 *
 * Copyright (C) 1992, 1993 Stephen Tweedie (sct@dcs.ed.ac.uk)
 * 
 * This file may be redistributed under the terms of the GNU General
 * Public License.
 *
 */

/* Modified for Minixfs/MiNT by S N Henson 1992 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "defrag.h"

#define sizeof_buffer (sizeof(*pool) + block_size)
#define buffer(i) ((Buffer *) \
		     (((char *) pool) + (i) * sizeof_buffer))

/* The buffer pool is a unified buffer space containing both the
   pending pool and the rescue pool.  The pending pool holds buffers
   waiting to be written to disk as part of the sequential write of 
   optimised zones; the rescue pool holds the contents of zones about
   to be overwritten by blocks from the write pool.

   The select set is an arbitrary subset of the whole buffer pool.
   This feature is used in various places to select a group of buffers
   for reading or writing. 

   The buffer pool and hash table will not necessarily be totally in
   synch with the relocation maps d2n_map and n2d_map.  It is possible
   for a buffer to exist for a block which, according to the
   relocation maps, is still on disc.  This is because the relocation
   maps are NOT modified by the creation or deletion of pool buffers,
   but only by the actual reading or writing of those pool buffers.
   (The basis of the defragmenter's optimisation is the deferring as
   long as possible of reads and writes, and the sorting of bulk
   reads/writes to improve performance.)
*/

int pool_size = 512;
Buffer *pool;
Buffer *first_free_buffer;
Buffer **select_set;
int select_set_size;
int free_buffers, count_output_buffers, count_rescue_buffers;

int count_buffer_writes = 0, count_buffer_reads = 0;
int count_write_groups = 0, count_read_groups = 0;
int count_buffer_migrates = 0, count_buffer_forces = 0;
int count_buffer_read_aheads = 0;

/* We will hash buffered blocks on the least significant bits of the
   block's dest_zone */
#define HASH_SIZE 1024
static Buffer * (hash[HASH_SIZE]) = {0};
#define hash_list(zone) (hash[(zone) % (HASH_SIZE)])

/* First of all, the primitive buffer management functions: allocation
   and freeing of buffer blocks. */

/* Set up the buffer tables and clear the hash table.  This must be
   called after the fs-dependent code has been initialised (typically
   in read_tables() ) so that the block size variables have been
   correctly initialised. */
void init_buffer_tables()
{
	int i;
	if (debug)
		printf ("DEBUG: init_buffer_tables()\n");
	
	for (i=0; i<HASH_SIZE; i++)
		hash[i] = 0;
	pool = (Buffer *) malloc (pool_size * sizeof_buffer);
	if (!pool)
		die ("Unable to allocate buffer pool.");
	memset (pool, 0, pool_size * sizeof_buffer);
	select_set = (Buffer **) malloc (pool_size *
					 sizeof(*select_set));
	if (!select_set)
		die ("Unable to allocate pool select set");
	select_set_size = 0;
	/* Set up the free buffer list */
	for (i=0; i<pool_size-1; i++)
	{
		buffer(i)->next = buffer(i+1);
	}
	buffer(pool_size-1)->next = 0;
	first_free_buffer = buffer(0);
	free_buffers = pool_size;
	count_output_buffers = count_rescue_buffers = 0;
}

/* Lookup a block in the hash table.  Returns a pointer to the entry
   in the hash list (ie. doubly indirected), or zero. */
static Buffer ** hash_lookup (Block zone)
{
	Buffer ** b;
	b = &(hash_list(zone));
	while (*b)
	{
		if ((*b)->dest_zone == zone)
			return b;
		b = &((*b)->next);
	}
	return 0;
}

/* Allocate an unused buffer from the pool. */
Buffer * allocate_buffer (Block zone, BufferType btype)
{
	Buffer * b;
	if (!first_free_buffer)
		die ("No free buffers");
	assert (free_buffers);
	assert (!(hash_lookup(zone)));

	/* Remove a buffer from the free list */
	b = first_free_buffer;
	first_free_buffer = first_free_buffer->next;
	assert (!b->in_use);
	b->in_use = 1;
	
	/* Set up the buffer fields */
	b->dest_zone = zone;
	b->btype = btype;
	b->full = 0;

	/* Update buffer counts */
	free_buffers--;
	switch (btype)
	{
	case OUTPUT:
		count_output_buffers++;
		break;
	case RESCUE:
		count_rescue_buffers++;
		break;
	}
		
	/* Link the buffer into the hash table */
	b->next = hash_list(zone);
	hash_list(zone) = b;

	assert ((count_rescue_buffers + count_output_buffers +
		 free_buffers) == pool_size);
	return b;
}

/* Free up a buffer from the buffer pool.  Manage the free buffer list
   and hash table appropriately. */
void free_buffer (Buffer *b)
{
	Buffer **p;
	if (debug)
		printf ("DEBUG: free_buffer (%lu)\n", b->dest_zone);
	assert (b->in_use);
	assert (first_free_buffer ? free_buffers : !free_buffers);
	/* Assert : throwing away a buffer's data is illegal unless 
	   the zone is on disk somewhere. */ 
	assert (n2d(b->dest_zone));
	b->in_use = 0;

	/* Unlink this buffer from the hash table */
	p = hash_lookup (b->dest_zone);
	assert (p);
	assert ((*p) == b);
	*p = b->next;
	
	/* Link the buffer into the free list */
	b->next = first_free_buffer;
	first_free_buffer = b;

	/* Update buffer counts */
	free_buffers++;
	switch (b->btype)
	{
	case OUTPUT:
		count_output_buffers--;
		break;
	case RESCUE:
		count_rescue_buffers--;
		break;
	}
}

/* Set a buffer's type - used to migrate blocks from the RESCUE to the 
   OUTPUT pool. */
void set_buffer_type (Buffer *b, BufferType btype)
{
	if (debug)
		printf ("DEBUG: set_buffer_type (%lu:%d, %d)\n",
			b->dest_zone, b->btype, btype);
	if (b->btype == btype)
		return;
	switch (b->btype)
	{
	case OUTPUT:
		count_output_buffers--;
		break;
	case RESCUE:
		count_rescue_buffers--;
		break;
	}
	b->btype = btype;
	switch (btype)
	{
	case OUTPUT:
		count_output_buffers++;
		break;
	case RESCUE:
		count_rescue_buffers++;
		break;
	}
	assert ((count_rescue_buffers + count_output_buffers +
		 free_buffers) == pool_size);
}

		
/* Select a group of buffers based on an arbitrary selection predicate */
void select_buffers (int (*fn) (const Buffer *))
{
	int i;
	if (debug)
		printf ("DEBUG: select_buffers()\n");
	
	select_set_size = 0;
	for (i=0; i<pool_size; i++)
	{
		if (buffer(i)->in_use && fn(buffer(i)))
			select_set[select_set_size++] = buffer(i);
	}
	if (debug)
		printf ("DEBUG: selected %d buffers\n", select_set_size);
}

/* Compare two buffers based on their dest_zone fields, for use by
   the stdlib qsort() function */
static int compare_buffer_zones(const void *a, const void *b)
{
	Block azone, bzone;
	azone = (*((Buffer **) a))->dest_zone;
	bzone = (*((Buffer **) b))->dest_zone;
	
	if (azone < bzone)
		return -1;
	if (azone == bzone)
		return 0;
	return 1;
}

/* Compare two buffers again, this time based on their source zone */
static int compare_buffer_zones_for_read (const void *a, const void *b)
{
	Block azone, bzone;
	azone = n2d((*((Buffer **) a))->dest_zone);
	bzone = n2d((*((Buffer **) b))->dest_zone);
	
	if (azone < bzone)
		return -1;
	if (azone == bzone)
		return 0;
	return 1;
}

/* Sort the current select_set based on buffer dest_zone.  Sorting
   buffers in this manner before a read or write will significantly
   improve i/o performance, but is not essential for correct running
   of the program. */
void sort_select_set (void)
{
	if (debug)
		printf ("DEBUG: sort_select_set()\n");
	qsort (select_set, select_set_size, sizeof (*select_set), 
	       compare_buffer_zones);
}

/* Perform a similar sort, but sort on source zones for an order
   suitable for reading the select set. */
void sort_select_set_for_read (void)
{
	if (debug)
		printf ("DEBUG: sort_select_set_for_read()\n");
	qsort (select_set, select_set_size, sizeof (*select_set), 
	       compare_buffer_zones_for_read);
}

/*
 * check_zone_nr checks to see that *nr is a valid zone nr. It dies if
 * it isn't.
 */
void check_zone_nr (Block nr)
{
	if (debug)
		printf ("DEBUG: check_zone_nr (&%d)\n", nr);
	if (nr < first_zone)
		printf ("Zone nr %d < first_zone.\n", nr);
	else if (nr >= zones)
		printf ("Zone nr %d > zones.\n", nr);
	else
		return;
	die ("Invalid zone number");
}

/*
 * read_current_block reads block nnr into the buffer at addr.
 */
void read_current_block (Block nnr, char * addr)
{
	if (debug)
		printf ("DEBUG: read_block (&%d, %d)\n", nnr, (int) addr);
	if (!nnr)
		return;
	check_zone_nr(nnr);

	if (block_size * (nnr) != lseek (IN, block_size * (nnr), SEEK_SET))
		die ("seek failed in read_block");
	if (block_size != read (IN, addr, block_size))
		die ("Read error: bad block in read_block.");
}

/*
 * write_current_block writes block nr to disk.
 */
void write_current_block (Block nnr, char * addr)
{
	int r;
	
	if (debug)
		printf ("DEBUG: write_block(%d, %d)\n", nnr, (int) addr);
	check_zone_nr(nnr);
	if (block_size * nnr != lseek (IN, block_size * nnr, SEEK_SET))
		die ("seek failed in write_block");
	if (readonly)
		return;
	if (block_size != (r = write (IN, addr, block_size)))
		printf ("Write error: bad block (%d,%d) in write_block.\n", nnr, r);
	if (blocks_until_sync++ >= SYNC_PERIOD)
	{
		sync();
		blocks_until_sync = 0;
	}
}

/* read/write_old_block function as read_block and write_block, but using
   the zone map to follow blocks which may have been swapped to make room for
   optimised zones. */
void read_old_block (Block onr, char *addr)
{
	check_zone_nr(onr);
	read_current_block (d2n(onr), addr);
}

void write_old_block (Block onr, char *addr)
{
	check_zone_nr(onr);
	write_current_block (d2n(onr), addr);
}


/* Read/write _Buffer_s.  The read/write_old/new_block routines work
   on arbitrary blocks and arbitrary memory locations; the Buffer
   read/write routines, on the other hand, interact fully with the
   zone relocation maps and Buffer data structures from the buffer
   pool. */

void read_buffer_data (Buffer *b)
{
	Block source;
	if (debug)
		printf ("DEBUG: read_buffer_data (%lu)\n",
			b->dest_zone);
	assert (b->in_use);
	if (b->full)
		return;
	source = n2d(b->dest_zone);
	/* Don't bother reading here if we are in readonly mode; there
	   will be no need to write it back at any time. */
	if (!readonly)
		read_current_block (source, b->data);
	d2n(source) = 0;
	n2d(b->dest_zone) = 0;
	b->full = 1;
	count_buffer_reads++;
	return;
}

void write_buffer_data_at (Buffer *b, Block dest)
{
	if (debug)
		printf ("DEBUG: write_buffer_data_at (%lu, %lu)\n", 
			b->dest_zone, dest);
	assert (b->in_use & b->full);
	write_current_block (dest, b->data);
	assert (!n2d(b->dest_zone));
	assert (!d2n(dest));
	d2n(dest) = b->dest_zone;
	n2d(b->dest_zone) = dest;
	count_buffer_writes++;
}

void write_buffer_data (Buffer *b)
{
	write_buffer_data_at (b, b->dest_zone);
}


/***********************************************************************
   The disk relocation routines: the working core of the defragmenter.
   These routines are responsible for implementing the disk block
   relocation defined by the forward and reverse relocation maps
   d2n_map and n2d_map.
 ***********************************************************************/
	
void read_select_set ()
{
	int i;
	sort_select_set_for_read();
	if (!select_set_size)
		return;
	if (verbose>1)
		printf ("Reading %d blocks...\n", select_set_size);
	for (i=0; i < select_set_size; i++)
	{
		assert (!select_set[i]->full);
		read_buffer_data (select_set[i]);
	}
	count_read_groups++;
}

void write_select_set ()
{
	int i;
	sort_select_set();
	if (!select_set_size)
		return;
	if (verbose>1)
		printf ("Writing %d blocks...\n", select_set_size);
	for (i=0; i < select_set_size; i++)
	{
		assert (select_set[i]->in_use &&
			select_set[i]->full);
		write_buffer_data(select_set[i]);
	}
	count_write_groups++;
}

void free_select_set()
{
	int i;
	for (i=0; i < select_set_size; i++)
		free_buffer (select_set[i]);
	select_set_size = 0;
}

/* A few useful buffer selection predicates... */
int output_buffer_p (const Buffer *b)
{
	return (b->btype == OUTPUT);
}

int empty_buffer_p (const Buffer *b)
{
	return (!b->full);
}

int rescue_buffer_p (const Buffer *b)
{
	return (b->btype == RESCUE);
}

int true (const Buffer *b)
{
	return 1;
}


/* Routines for reading and flushing data */
void read_all_buffers()
{
	/* Select and sort all (non-empty) buffers for reading */
	select_buffers (empty_buffer_p);
	read_select_set();
}	

void flush_output_pool()
{
	read_all_buffers ();
	select_buffers (output_buffer_p);
	if (!select_set_size)
		return;
	if (verbose>1)
		printf ("Saving: ");
	write_select_set();
	free_select_set();
}

/* Here we employ various methods for getting rid of some of the
   buffers in the buffer pool.  There are three methods used, in
   order of preference:
   flush output buffers: Buffers waiting to be sequentially written to
		disk are written now.
   If that fails to free more than 25% of buffers:
   flush rescue buffers: Rescue buffers whose destination zones are
   		empty (ie. already moved into the output pool and
		hence to disk) are flushed, by migrating them
		immediately to the output pool.
   If that fails to free more than 20% of the buffers, drastic action
   is necessary:
   force rescue buffers: Rescue buffers are sorted, and a number of
		rescue buffers destined for later disk zones are
		written to free space at the end of the disk (NOT to
		their ultimate destinations, though).  We choose later
		rescue buffers to flush in preference to earlier
		buffers, in anticipation of soon being able to migrate
		early rescued blocks to the output pool. */
void get_some_buffer_space()
{
	int i, count = 0;
	Block dest;
	
	flush_output_pool();
	if ((free_buffers * 4) > pool_size)
		return;

	/* OK, try migrating rescue buffers to the output pool */
	for (i=0; i<pool_size; i++)
	{
		if (buffer(i)->in_use &&
		    buffer(i)->btype == RESCUE &&
		    d2n(buffer(i)->dest_zone) == 0)
		{
			set_buffer_type(buffer(i), OUTPUT);
			count++;
			count_buffer_migrates++;
		}
	}
	if (verbose>1)
		printf ("Migrated %d rescued blocks%s", count,
			count ? ": " : ".\n");
	flush_output_pool();
	if ((free_buffers * 5) > pool_size)
		return;
	
	/* Serious trouble - more than 80% of the pool is occupied by 
	   unsaveable rescue buffers.  We'll have to force some of 
	   them to disk.  (The algorithm I'm using tries hard to avoid
	   this, since it is the only occasion where a disk block may
	   have to be be moved more than once during relocation.) */
	select_buffers (true);
	sort_select_set ();
	assert (select_set_size + free_buffers == pool_size);
	/* Select the top 25% of rescue buffers for forcing (this is 
	   an entirely arbitrary number; in fact, most of the numbers 
	   in this function could probably be tweaked to tune 
	   performance, but these seem to work OK. */
	dest = zones-1; count = 0;
	if (verbose>1)
		printf ("Pool too full - forcing buffers...");
	for (i = select_set_size-1; i >= ((select_set_size*3)/4); i--)
	{
		while (d2n(dest))
			dest--;
		write_buffer_data_at (select_set[i], dest);
		free_buffer (select_set[i]);
		count_buffer_forces++;
		count++;
	}
	if (verbose>1)
		printf (" %d buffers recovered.\n", count);
	select_set_size = 0;
}

void remap_disk_blocks (void)
{
	Block source, dest = first_zone, dest2;
	Buffer **p;

	if (debug)
		printf ("DEBUG: remap_disk_blocks()\n");
	if (verbose)
		printf ("Relocating disk blocks - this could take a while.\n");
	
	/* Walk through each disk block sequentially, rescuing 
	   previous contents and reading the new contents into the 
	   output buffer. */
	do
	{
		if (verbose && !(dest & 1023))
		{
			printf ("Relocating : %d MB...\n",
				(dest / 1024));
		}
		
		/* Don't try to save stuff to disk until we are */
		/* running out of free buffers. */
		if (free_buffers < 4)
		{
			get_some_buffer_space ();
		}
		assert (free_buffers >= 4);
		
		/* Use the reverse relocation map to obtain the block 
		   which should go in this space */
		source = n2d(dest);
		/* Zero means this block cannot be found on disk.
		   Either it should remain empty (it may  be a bad
		   block), or it has already been read into the rescue
		   pool.  If source==dest, the block is already in
		   place. */
		if (source == dest)
			continue;
		/* We may have already read the source block into the 
		   rescue pool; look for the block (indexed by dest) 
		   in the hash table */
		p = hash_lookup (dest);
		if (p)
		{
			/* Yes, we already have the block so make it 
			   an OUTPUT buffer (it must currently be a 
			   RESCUE buffer). */
			assert ((*p)->btype == RESCUE);
			set_buffer_type (*p, OUTPUT);
			count_buffer_read_aheads++;
		}
		else
		{
			/* No, the block is not in the hash table:
			   if the block can be found on disk, read it;
			   otherwise, the block will remain empty and
			   can be skipped. */
			if (!source)
				continue;
			allocate_buffer (dest, OUTPUT);
		}
		
		/* Rescue the block about to be overwritten.  All 
		   buffers are referred to by their destination zone 
		   (according to the relocation map), NOT the zone 
		   that block is currently residing in.  So, work out 
		   the final destination of the block currently 
		   residing in the destination zone by looking up the 
		   forward relocation map. */
		dest2 = d2n(dest);
		/* Zero means that the dest block may be safely 
		   overwritten. */
		if (!dest2)
			continue;
		/* Check to see if we have already read this block */
		p = hash_lookup (dest2);
		if (p)
		{
			/* We have, so no need to read it again */
			continue;
		}
		/* Read the block into the rescue pool */
		allocate_buffer (dest2, RESCUE);
	} while (++dest < zones);
	/* We have got to the end, so flush any remaining buffers. */
	flush_output_pool ();
	assert (!count_output_buffers);
	assert (!count_rescue_buffers);
	assert (free_buffers == pool_size);
}

       
