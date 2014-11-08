/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <errno.h>
#include <stddef.h>
#include <string.h>
#include <tos.h>

#include "malloc.h"

/* Macro for adding an element on the start of a linked list. */

#define add_list(list,elem)		elem->prev = NULL;			\
								elem->next = (list);		\
								if ((list) != NULL)			\
									(list)->prev = elem;	\
								(list) = elem

/* Macro for removing an element from a linked list. */

#define rem_list(list,elem)		if (elem->next != NULL)				\
									elem->next->prev = elem->prev;	\
								if (elem->prev != NULL)				\
									elem->prev->next = elem->next;	\
								else								\
									(list) = elem->next

HEAP *__heap = NULL;

/*
 * Find a free memory block in the heap.
 *
 * Parameters:
 *
 * heap			- pointer to the heap, which should be used.
 * size			- size of block, including the size of the BLOCK
 *				  structure.
 *
 * Result: a NULL pointer if the is not free block, else a pointer
 *         to the free memory block is returned.
 */

static BLOCK *find_block(HEAP *heap, size_t size)
{
	HEAP *heapblock = heap;

	while (heapblock != NULL)
	{
		BLOCK *h = heap->freelist;

		while (h != NULL)
		{
			if (h->size >= size)		/* Check if block is large enough. */
				return h;				/* Return block. */
			h = h->next;				/* Next block. */
		}

		heapblock = heapblock->next;	/* Next heapblock. */
	}

	return NULL;						/* No block found. */
}

/*
 * Check if a block is a member of usedlist of the heap.
 *
 * heap			- pointer to the heap.
 * block		- pointer to the block, which should be checked.
 *
 * Result: TRUE if block is a member, FALSE if not.
 */

int check_block(HEAP *heap, BLOCK *block)
{
	HEAP *heapblock = heap;

	while (heapblock != NULL)
	{
		BLOCK *h = heapblock->usedlist;

		while (h != NULL)
		{
			if (h == block)				/* Check if block is a member. */
				return TRUE;
			h = h->next;				/* Next block. */
		}

		heapblock = heapblock->next;	/* Next heapblock. */
	}

	return FALSE;						/* Block not found. */
}

/*
 * Get more memory from the core memory.
 *
 * Parameters:
 *
 * heap			- pointer to the heap, which should be used.
 * size			- size of the heap block, including the size of the
 *				  HEAP structure.
 *
 * Result: a NULL pointer if the is not enough memoey, else a pointer
 *         to the new heap block is returned.
 */

static HEAP *add_core(HEAP **heap, size_t size)
{
	HEAP *new;
	BLOCK *block;

	if ((new = (HEAP *) Malloc(size)) == NULL)
		return NULL;					/* Out of memory. */

	new->magic = MAGIC;
	new->freelist = (BLOCK *) ((unsigned long) new + sizeof(HEAP));
	new->usedlist = NULL;

	add_list(*heap, new);				/* Add to list of heapblocks. */

	block = new->freelist;

	block->prev = NULL;
	block->next = NULL;
	block->size = size - sizeof(HEAP);
	block->heapblock = new;

	return new;
}

/*
 * Return a heapblock to the core memory.
 *
 * Parameters:
 *
 * heap			- pointer to the heap, which should be used.
 * heapblock	- pointer to heapblock.
 */

static void free_core(HEAP **heap, HEAP *heapblock)
{
	rem_list(*heap, heapblock);		/* Remove the block from the heap. */
	Mfree(heapblock);				/* Return the block to the core memory. */
}

/*
 * Move a block from the freelist to the used list.
 *
 * Parameters:
 *
 * block		- pointer to the memory block.
 */

static void claim_block(BLOCK *block)
{
	HEAP *heapblock = block->heapblock;

	rem_list(heapblock->freelist, block);	/* Remove from freelist. */
	add_list(heapblock->usedlist, block);	/* Add to usedlist. */
}

/*
 * Add a block to the freelist. Join, if possible, the block
 * with other blocks in the freelist. The block should not be
 * a member of the usedlist or the freelist.
 *
 * Parameters:
 *
 * block		- pointer to the memory block.
 */

static void free_block(BLOCK *block)
{
	BLOCK *h, *next;
	HEAP *heapblock = block->heapblock;

	add_list(heapblock->freelist, block);	/* Add block to freelist. */

	/* Merge blocks. */

	h = block->next;

	while (h != NULL)
	{
		next = h->next;

		if ((BLOCK *) ((unsigned long) h + h->size) == block)
		{
			/* Check if the block can be added to the end of another
			   block. */

			rem_list(heapblock->freelist, block);	/* Remove block from freelist. */
			h->size += block->size;					/* Merge blocks. */
			block = h;								/* Continue with new block. */
		}
		else if ((BLOCK *) ((unsigned long) block + block->size) == h)
		{
			/* Check if another block can be added to the end of the
			   block. */

			rem_list(heapblock->freelist, h);		/* Remove block from freelist. */
			block->size += h->size;					/* Merge blocks. */
		}

		h = next;
	}
}

/*
 * Shrink a block to the desired size. Free not used memory.
 *
 * Parameters:
 *
 * block		- pointer to the memory block.
 * size			- the desired size.
 */

static void shrink_block(BLOCK *block, size_t size)
{
	BLOCK *new;
	size_t newsize;

	if (size & 3)				/* align on 32 bit boundary. */
		size = (size + 3L) & 0xFFFFFFFCL;

	/* Check if the size of the not used part of the block is larger
	   than the minimum size of the block. */

	if ((newsize = block->size - size) > MINSIZE)
	{
		new = (BLOCK *) ((unsigned long) block + size);

		block->size = size;

		new->size = newsize;
		new->heapblock = block->heapblock;

		free_block(new);
	}
}

void *malloc(size_t size)
{
	size_t tsize = size + sizeof(BLOCK);	/* Total size of requested block. */
	HEAP *heapblock;
	BLOCK *block;

	if (tsize < MINSIZE)		/* Check on minimum length. */
		tsize = MINSIZE;

	if (tsize & 3)				/* align on 32 bit boundary. */
		tsize = (tsize + 3L) & 0xFFFFFFFCL;

	if (tsize > (BLOCKSIZE - sizeof(HEAP)))
	{
		/* If the size of the requested block is larger than the
		   block size, give the block it's own heap block. */

		if ((heapblock = add_core(&__heap, tsize + sizeof(HEAP))) == NULL)
		{
			/* Out of memory. */

			errno = ENOMEM;
			return NULL;
		}

		block = heapblock->freelist;
	}
	else
	{
		if ((block = find_block(__heap, tsize)) == NULL)
		{
			/* No block found, get more memory from the core. */

			if ((heapblock = add_core(&__heap, BLOCKSIZE)) == NULL)
			{
				/* Out of memory. */

				errno = ENOMEM;
				return NULL;
			}

			block = heapblock->freelist;
		}
	}

	/* Now block points to a block which is large enough. Put the
	   block in the usedlist and shrink it's size to the desired
	   size. */

	claim_block(block);			/* Remove from freelist and add to usedlist. */
	shrink_block(block, tsize);	/* Shrink block to the desired size. */

	return (void *) ((unsigned long) block + sizeof(BLOCK));
}

void *calloc(size_t nitems, size_t size)
{
	void *block;
	size_t tsize = nitems * size;			/* Total number of bytes. */

	if ((block = malloc(tsize)) != NULL)	/* Get memory. */
		memset(block, 0, tsize);			/* Clear memory. */

	return block;
}

void free(void *ptr)
{
	BLOCK *block = (BLOCK *) ((unsigned long) ptr - sizeof(BLOCK));

	if (check_block(__heap, block))
	{
		HEAP *heapblock = block->heapblock;

		rem_list(heapblock->usedlist, block);	/* Remove from usedlist. */
		free_block(block);						/* Add to freelist. */

		if (heapblock->usedlist == NULL)		/* Check if the heapblock is in use. */
			free_core(&__heap, heapblock);		/* Return to core memory. */
	}
}

void *realloc(void *ptr, size_t newsize)
{
	BLOCK *block = (BLOCK *) ((unsigned long) ptr - sizeof(BLOCK));
	size_t tnsize = newsize + sizeof(BLOCK);

	if (ptr == NULL)
		return malloc(newsize);

	if (check_block(__heap, block))
	{
		HEAP *heapblock = block->heapblock;
		BLOCK *h, *nblk;

		if (tnsize < MINSIZE)	/* Check on minimum length. */
			tnsize = MINSIZE;

		if (tnsize & 3L)		/* align on 32 bit boundary. */
			tnsize = (tnsize + 3L) & 0xFFFFFFFCL;

		if (block->size == tnsize)		/* Same size. */
			return ptr;
		else if (block->size > tnsize)	/* Shrink block. */
		{
			/* Check if the block is located in it's own heapblock.
			   (i.e. the block is larger than BLOCKSIZE). */

			if (block->size > (BLOCKSIZE - sizeof(HEAP)))
			{
				/* Check if the new block is still larger than
				   BLOCKSIZE. */

				if (tnsize <= (BLOCKSIZE - sizeof(HEAP)))
				{
					/* Shrink block and free remaining memory. */

					Mshrink(0, heapblock, BLOCKSIZE);
					block->size = BLOCKSIZE - sizeof(HEAP);
					shrink_block(block, tnsize);

					return ptr;	/* Address has not changed, return old pointer. */
				}
				else
				{
					/* Shrink block. */

					Mshrink(0, heapblock, tnsize + sizeof(HEAP));
					block->size = tnsize;

					return ptr;	/* Address has not changed, return old pointer. */
				}
			}
			else
			{
				/* Shrink block and free the remaining memory. */

				shrink_block(block, tnsize);	/* Shrink block to the desired size. */
				return ptr;						/* Address has not changed, return old pointer. */
			}
		}
		else							/* Enlarge block. */
		{
			/* First check if there is a free block, which can be
			   merged with the block. */

			nblk = (BLOCK *) ((unsigned long) block + block->size);
			h = heapblock->freelist;

			while ((h != NULL) && (h != nblk))
				h = h->next;

			if ((h != NULL) && ((h->size + block->size) >= tnsize))
			{
				/* There is a free block, which is sufficiently
				   large. Merge it. */

				rem_list(heapblock->freelist, h);	/* Get block. */
				block->size += h->size;				/* Merge blocks. */
				shrink_block(block, tnsize);		/* Shrink to the desired size. */

				return ptr;							/* Address has not changed, return old pointer. */
			}
			else
			{
				void *new;

				/* There is not a free block, which is large enough.
				   Allocate a new block and copy the contents of
				   the old block to the new block. */

				if ((new = malloc(newsize)) != NULL)
				{
					memcpy(new, ptr, block->size - sizeof(BLOCK));
					free(ptr);
				}

				return new;							/* Return pointer to new block. */
			}
		}
	}
	else
	{
		errno = EINVMEM;
		return NULL;
	}
}

/*
 * Return all allocated memory to the system.
 */

void _FreeAll(void)
{
	HEAP *h = __heap, *next;

	while (h != NULL)
	{
		next = h->next;
		Mfree(h);									/* Return the block to the core memory. */
		h = next;
	}
}
