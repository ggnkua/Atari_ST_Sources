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
 *	dict.h
 *
 *	dictionary defines.
 */

#include "common/mallocs.h"
#include "common/qmem.h"

#define NHASHD 1009

/*  hashing method from very old gnu ld, but still good */

typedef struct hashdic
{
	struct hashdic *link;
	char name[0];
} DIC;

void	free_dictionary(void),
		init_dictionary(void);
Cstr to_dictionary(Cstr n);
Cstr to_name_heap(short l, Cstr n);

extern short numhash;
extern long dictionary_names, heap_names;
extern void * dictionary[];
extern MEMBASE dictionary_mem;

