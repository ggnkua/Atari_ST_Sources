/*
 * free.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <stdlib.h>
#include <mint/osbind.h>
#include "mallint.h"

/* linked list of free blocks struct defined in lib.h */
struct mem_chunk _mchunk_free_list = { VAL_FREE, &_mchunk_free_list, &_mchunk_free_list, 0 };


void free(void *param)
{
	struct mem_chunk *head, *next, *prev;
	struct mem_chunk *r = (struct mem_chunk *) param;

#if MALLOC_DEBUG
	nf_debugprintf("free 0x%08lx\n", (unsigned long)r);
#endif
	/* free(NULL) should do nothing */
	if (r == NULL)
		return;

	/* move back to uncover the mem_chunk */
	r = (struct mem_chunk *)(((char *) r) - ALLOC_EXTRA);

	if (r->valid != VAL_ALLOC)
		return;

	r->valid = VAL_FREE;

	/* stick it into free list, preserving ascending address order */
	head = &_mchunk_free_list;
	next = head->next;
	while (next != head && next < r) 
		next = next->next;

	r->next = next;
	r->prev = next->prev;
	r->prev->next = r;
	r->next->prev = r;
	/* merge after if possible */
	if ((struct mem_chunk *)(((char *) r) + r->size) == next && next->valid == VAL_FREE)
	{
		r->size += next->size;
		r->next = next->next;
		next->next->prev = r;
	}

	/* merge before if possible, otherwise link it in */
	prev = r->prev;
	if (prev != head && prev->valid == VAL_FREE && (struct mem_chunk *)(((char *) (prev) + (prev)->size)) == r)
	{
		prev->size += r->size;
		prev->next = r->next;
		r->next->prev = prev;
		r = prev;
	}
	
	prev = r->prev;
	if (prev != head && prev->valid == VAL_SBRK && SBRK_SIZE(prev) == r->size)
	{
		prev->prev->next = r->next;
		r->next->prev = prev->prev;
		Mfree(prev);
	}
}
