/*
 * C version of my dynamic memory allocator. Hopefully no bugs this time.
 * 
 *                    Copyright 1993 Andrew L. Younger.
 *
 * Amended 10/6/1993 - M.Watson. 
 *
 */

#include <tos.h>
#include "dynamic.h"

static long startmem;
static long endofmem;

struct mem_struct
{
	long start;
	long size;
} memblock[NUMBLOCKS];

/*
 * Game front end to the memory handler.
 */
void InitDynamic(void)
{
	startmem = (long)Malloc((1000L * 1024L));
	InitMemMan((unsigned short *)startmem);
}

/*
 * Close down the dynamic memory manager.
 */
void ExitDynamic(void)
{
	Mfree((void *)startmem);
}

/*
 * Initialize memory manager.
 */
void InitMemMan(unsigned short *mem)
{
unsigned short loop = 0;
struct mem_struct *p;

	endofmem = (long )mem;
	p = (struct mem_struct *)&memblock[0];
	for (; loop < NUMBLOCKS; loop++, p++)
	{
	p->start = (long )mem;
	p->size = 0L;
	}
}

/*
 * Allocate block of memory..
 */
short AllocMem(unsigned long sizemem)
{
unsigned short loop = 1;
	while (memblock[loop].size && loop < NUMBLOCKS)
			loop++;
	if (loop == NUMBLOCKS)
		return 0;   /* Out of blocks man.. */
	ResizeMem(loop, sizemem);
	ClearMem(loop);
	return(loop);
}

/*
 * Return start memory address.
 */
short *WhereMem(unsigned short handle)
{
	return ((short *)memblock[handle].start);
}

/*
 * Free block of memory.
 */
void FreeMem(unsigned short handle)
{
	ResizeMem(handle,0L);
}

/*
 * Return Size of block..
 */
long SizeMem(unsigned short handle)
{
	return ((long)memblock[handle].size);
}

/*
 * Resize block of memory.
 */
void ResizeMem(unsigned short handle, unsigned long newsize)
{
short loop;
long modifier, src, dst, size;

	newsize = ((newsize+1) & 0xfffffffeL);	/* Word boundary it */
	modifier = newsize - memblock[handle].size;
	src = memblock[handle+1].start;
	dst = src+modifier;
	size=endofmem-src;
	MoveMem((void *)dst,(const void *)src,size>>1);
	memblock[handle].size = newsize;
	endofmem += modifier;
	for (loop = handle+1; loop < NUMBLOCKS; loop++)
		memblock[loop].start += modifier;	/* Update pointers */
}

void	MoveMem(short *dst,short *src,long size)
{
	for	(;--size>0;)
		*dst++=*src++;
}

void	ClearMem(unsigned short handle)
{
long size=(SizeMem(handle))>>1;
short *start=WhereMem(handle);
	for (;--size>0;)
		*start++=0;
}
		







