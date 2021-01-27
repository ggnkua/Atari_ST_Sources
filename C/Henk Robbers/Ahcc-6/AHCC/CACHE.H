/* Copyright (c) 1990 - present by H. Robbers.
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

/* cache.h   defines for the header file caching subsystem
*/

#ifndef CACHE_H
#define CACHE_H

#include "c_lex.h"

typedef struct cache
{
	struct cache *next;
	Cstr name;
	short fileno;
	short heap;			/* heap or no copy */
	uint fl;
	short busy;
	long size;
	long bytes;
	long lines;
	LEX_RECORD *text;
} CACHE, *CP;

extern CP cache;

void	init_cache		(void);
void	free_cache		(void);
void	delete_from_cache(Cstr name, short caching);
CP		free_cache_unit	(CP);
CP		new_cache		(void);
CP		cache_look		(CP pt, CP *pr, Cstr name, bool new);
CP		cache_fits		(long size);
CP		cache_high		(long size);

#endif
