/*
 * Filename:     gs_mem.c
 * Project:      GlueSTiK
 * 
 * Note:         Please send suggestions, patches or bug reports to me
 *               or the MiNT mailing list <mint@fishpool.com>.
 * 
 * Copying:      Copyright 1999 Frank Naumann <fnaumann@cs.uni-magdeburg.de>
 * 
 * Portions copyright 1997, 1998, 1999 Scott Bigham <dsb@cs.duke.edu>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <string.h>
#include <osbind.h>
#include "config.h"
#include "gs_mem.h"

#define POOLSIZE_DEFAULT	200000L
#define MIN_CHUNK		(sizeof (chunk_header) + 8)
#define ALLOCED		0xAB000000UL
#define FREED			0xFB000000UL

#define round(n)		(((n) + 7) & ~7)
#define is_alloced(H)		(((H)->size & 0xFF000000L) == ALLOCED)
#define is_freed(H)		(((H)->size & 0xFF000000L) == FREED)
#define chunksize(H)		((H)->size & 0x00FFFFFFL)

#ifdef NETWORK
#ifdef LWIP

typedef struct chunk_header chunk_header;
struct chunk_header
{
	chunk_header *next;
	unsigned long size;
};

static uchar *pool;
static unsigned long poolsize;
static chunk_header *arena;


int
gs_init_mem (void)
{
	poolsize = POOLSIZE_DEFAULT;

# define BOUNDARY	(8192 - 1)
	poolsize += BOUNDARY;
	poolsize &= ~BOUNDARY;
	poolsize -= 512;
	
	pool = (uchar *)Malloc (poolsize);
	if (!pool)
	{
		Cconws ("Unable to allocate alloc pool\r\n");
		return 0;
	}
	
	arena = (chunk_header *) pool;
	arena->next = 0;
	arena->size = (poolsize - sizeof (chunk_header)) | FREED;
	
	return 1;
}

void
gs_cleanup_mem (void)
{
	if (pool)
		Mfree(pool);
}


/* join_next() -- Joins chunk |H| with the next block and sets its state to
 * |state|.
 * WARNING:  Assumes |H->next| is not NULL.
 */
static void
join_next (register chunk_header *H, unsigned long state)
{
	register chunk_header *H2 = H->next;
	H->next = H2->next;
	H->size = (chunksize (H) + chunksize (H2) + sizeof (chunk_header)) | state;
}

/* try_split() -- split chunk |block| into two chunks, the first of size
 * |newsize|, if there's room for a second chunk.  The new chunk (if
 * any) is marked FREED; the (possibly smaller) original block is marked
 * ALLOCED.
 * WARNING:  assumes |newsize| is already round()'ed.
 */
static void
try_split (chunk_header *block, unsigned long newsize)
{
	register chunk_header *H;
	
	if (chunksize (block) - newsize >= MIN_CHUNK)
	{
		H = (chunk_header *) ((uchar *) (block + 1) + newsize);
		H->next = block->next;
		H->size = (chunksize (block) - newsize - sizeof (chunk_header)) | FREED;
		block->next = H;
		block->size = newsize | ALLOCED;
		
		/* if the next block is free, merge the new block into it
		 */
		if (H->next && is_freed (H->next))
			join_next (H, FREED);
	}
	else
	{
		block->size = chunksize (block) | ALLOCED;
	}
}


void *
gs_mem_alloc (unsigned long size)
{
	register chunk_header *H;
	
	PRINT_DEBUG (("gs_mem_alloc(%lu)", size));
	
	size = round (size);
	if (size >= 0x01000000L || size == 0)
	{
		PRINT_DEBUG (("gs_mem_alloc: returns NULL"));
		return NULL;
	}
	
	for (H = arena; H; H = H->next)
	{
		if (is_alloced (H) || chunksize (H) < size)
			continue;
		
		if (!is_freed (H))
		{
			PRINT_DEBUG (("gs_mem_alloc: possible arena corruption at %p", H));
		}
		
		try_split (H, size);
		
		PRINT_DEBUG (("gs_mem_alloc: returns %p", (void *) (H + 1)));
		return (char *) (H + 1);
	}
	
	PRINT_DEBUG (("gs_mem_alloc: returns NULL"));
	return NULL;
}

void
gs_mem_free (void *mem)
{
	register chunk_header *H = (chunk_header *) mem;
	
	PRINT_DEBUG (("gs_mem_free(%p)", mem));
	
	if (!mem)
		return;
	
	H--; /* step back to the header */
	if (!is_alloced (H))
	{
		PRINT_DEBUG (("gs_mem_free: block not allocated by this modul"));
		return;
	}
	
	H->size = chunksize (H) | FREED;
	
	if (H->next && is_freed (H->next))
	{
		/* next block is free; merge with it */
		join_next (H, FREED);
	}
	
	if (H != arena)
	{
		/* there is a previous chunk;
		 * merge with it if it's freed
		 */
		register chunk_header *H2;
		
		for (H2 = arena; H2 && H2->next != H; H2 = H2->next)
		{
			if (!is_freed(H2) && !is_alloced(H2))
				PRINT_DEBUG (("gs_mem_free: possible arena corruption at %p", H2));
			continue;
		}
		
		if (!H2)
		{
			/* this shouldn't happen */
			PRINT_DEBUG (("gs_mem_free: cannot find block in arena"));
		}
		else if (is_freed (H2))
		{
			join_next (H2, FREED);
			H = H2;
		}
		else if (!is_alloced (H2))
		{
			PRINT_DEBUG (("gs_mem_free: possible arena corruption at %p", H2));
		}
	}
	
	PRINT_DEBUG (("gs_mem_free: ok"));
}

int32
gs_mem_getfree (int16 flag)
{
	register chunk_header *H;
	register unsigned long size = 0;
	
	PRINT_DEBUG (("gs_mem_getfree(%i)", flag));
	
	if (flag)
	{
		for (H = arena; H; H = H->next)
		{
			if (is_freed (H) && chunksize (H) > size)
			{
				size = chunksize (H);
			}
			else if (!is_alloced (H))
			{
				PRINT_DEBUG (("gs_mem_getfree: possible arena corruption at %p", H));
			}
		}
	}
	else
	{
		for (H = arena; H; H = H->next)
		{
			if (is_freed (H))
			{
				size += chunksize (H);
			}
			else if (!is_alloced (H))
			{
				PRINT_DEBUG (("gs_mem_getfree: possible arena corruption at %p", H));
			}
		}
	}
	
	PRINT_DEBUG (("gs_mem_getfree: returns %li", size));
	return size;
}

void *
gs_mem_realloc (void *mem, unsigned long newsize)
{
	register chunk_header *H = (chunk_header *) mem;
	
	PRINT_DEBUG (("gs_mem_realloc(%p, %lu)", mem, newsize));
	if (!mem)
	{
		void *newmem = gs_mem_alloc (newsize);
		if (newmem)
			memset (newmem, 0, newsize);
		
		PRINT_DEBUG (("gs_mem_realloc: returns %p", newmem));
		return newmem;
	}

	if (newsize == 0)
	{
		gs_mem_free (mem);
		
		PRINT_DEBUG (("gs_mem_realloc: returns NULL"));
		return NULL;
	}
	
	H--; /* step back to the header */
	if (!is_alloced (H))
	{
		PRINT_DEBUG (("gs_mem_realloc: block not allocated by this modul"));
		return NULL;
	}
	
	newsize = round (newsize);
	if (newsize <= chunksize (H))
	{
		/* if we're downsizing, we may have room to split the chunk
		 */
		try_split (H, newsize);
		
		PRINT_DEBUG (("gs_mem_realloc: returns %p", mem));
		return mem;
	}
	else if (H->next
		&& is_freed(H->next)
		&& (chunksize (H) + chunksize (H->next) + sizeof (chunk_header)) >= newsize)
	{
		/* Next chunk is free and big enough to accommodate the new size;
		 * join it with the current chunk
		  */
		join_next (H, ALLOCED);
		
		/* We may even have room to split off part of the newly joined chunk
		 */
		try_split (H, newsize);
		
		PRINT_DEBUG (("gs_mem_realloc: returns %p", mem));
		return mem;
	}
	else
	{
		register char *newmem = gs_mem_alloc (newsize);
		
		if (!newmem)
		{
			PRINT_DEBUG (("gs_mem_realloc: returns NULL"));
			return NULL;
		}
		
		memcpy (newmem, mem, chunksize (H));
		gs_mem_free (mem);
		
		PRINT_DEBUG (("gs_mem_realloc: returns %p", newmem));
		return newmem;
	}
}

#endif /* LWIP */
#endif /* NETWORK */

