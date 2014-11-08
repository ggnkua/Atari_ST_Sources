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

#define BLOCKSIZE	8192L
#define MINSIZE		(2 * sizeof(BLOCK))
#define MAGIC		0x32143344L

typedef struct block
{
	struct block *prev;			/* Pointer to previous block. */
	struct block *next;			/* Pointer to next block. */
	unsigned size_t size;		/* Length of block. */
	struct heap *heapblock;		/* Pointer to heap. */
} BLOCK;

typedef struct heap
{
	unsigned long magic;		/* Magic. */
	struct heap *prev;			/* Pointer to previous heap block. */
	struct heap *next;			/* Pointer to next heap block. */
	struct block *freelist;		/* List with free memory blocks. */
	struct block *usedlist;		/* List with used memory blocks. */
} HEAP;
