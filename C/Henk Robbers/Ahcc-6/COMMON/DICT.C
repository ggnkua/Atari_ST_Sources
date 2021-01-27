/* Copyright (c) 2006 - present by H. Robbers.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	dict.c
 *
 *	dictionary.
 */

#include <stdio.h>
#include <string.h>

#include "qmem.h"
#include "dict.h"

global
MEMBASE dictionary_mem;
global
short numhash = NHASHD;
global
long dictionary_names = 0, heap_names = 0;
global
void *dictionary[NHASHD];

global
short dichash(Cstr key)
{
	Cstr s = key;
	short k = 0;

	while (*s)
		k = (((k << 1) + (k >> 14)) ^ (*s++)) & 0x3fff;

	return k % numhash;
}

/* Get the dictionary entry for the identifier named key.
   Create one if there is none.  */

void
send_msg(char *text, ...);

global
Cstr to_dictionary(Cstr key)	/* for ID's only */
{
	short hashval;
	DIC *bp;

	/* Determine the proper bucket.  */

	hashval = dichash(key);

	/* Search the bucket.  */

	bp = dictionary[hashval];
	while (bp)
	{
		if (SCMP(50, key, bp->name) eq 0)
			return bp->name;
		bp = bp->link;
	}


	/* Nothing was found; create a new dictionary entry.  */

	bp = qalloc(&dictionary_mem, sizeof(DIC) + strlen(key) + 1);

	if (bp)
	{
		strcpy ((char *)bp->name, key);

		/* Add the entry to the bucket.  */

		bp->link = dictionary[hashval];
		dictionary[hashval] = bp;
		dictionary_names++;
		return bp->name;
	}
	else
		return "~~5";
}

global
Cstr to_name_heap(short l, Cstr n)	/* may contain \0 */
{
	char *s, *to;

	if (l eq 1)
	{
		/* very common (about 30 %) */
		if (*n eq ' ')
			return " ";
		if (*n eq '0')
			return "0";
		if (*n eq '1')
			return "1";
	}

	to = qalloc(&dictionary_mem, l + 1);
	if (to)
	{
		s = to;
		while(l--) *s++ = *n++;
		*s = 0;
		heap_names++;
		return to;
	}
	else
		return "~~6";
}

global
void print_dictionary(FILE *fp)
{
	DIC *bp;
	short i = 0;

	while (i < NHASHD)
	{
		bool have = false;
		bp = dictionary[i];
		while (bp)
		{
			fprintf(fp, "'%s'\n", bp->name);
			have = true;
			bp = bp->link;
		}
		if (have)
			fprintf(fp, "[%d]\n", i);
		i++;
	}
	fprintf(fp, "\nunique names: %ld\n", dictionary_names);
}

global
void init_dictionary(void)
{
	dictionary_names = 0;
	heap_names = 0;
	memset(dictionary, 0, sizeof(dictionary));
/*	dictionary = calloc(1, sizeof(void *) * numhash); */
	init_membase(&dictionary_mem, 8192, 0, "dictionary_memory", nil);
}

global
void free_dictionary(void)
{
	free_membase(&dictionary_mem);
	memset(dictionary, 0, sizeof(dictionary));
}

