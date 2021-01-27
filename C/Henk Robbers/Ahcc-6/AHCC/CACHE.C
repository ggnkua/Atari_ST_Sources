/* Copyright (c) 2004 - present by H. Robbers.
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

/* cache.c  caching subsystem for header files */

#include <string.h>

#include "common/mallocs.h"
#include "common/amem.h"
#include "cache.h"
#include "peepstat.h"

void send_msg(char *text, ...);

global
CP cache = nil;

global
CP free_cache_unit(CP cp)		/* only last */
{
	CP nx = nil;

	if (cp)
	{
		nx = cp->next;
		if (cp->text)
			CC_ffree(cp->text);
		if (cp->name and cp->heap)
			CC_xfree(cp->name);
		CC_xfree(cp);
	}

	return nx;
}

global
void delete_from_cache(Cstr name, short caching)
{
	CP pr, nx;
	CP cp = cache_look(cache, &pr, name, false);
	if (cp)
	{
		if (caching)
			if (cp->busy > 0)
				cp->busy -= 1;
			else ;
		elif (cp->busy > 0)
			cp->busy -= 1;
		else
		{
			nx = free_cache_unit(cp);
			if (pr eq nil)		/* deleted first */
				cache = nx;
			elif (nx)			/* deleted in the middle: pr and nx */
				pr->next = nx->next;
			else 				/* deleted last */
				pr->next = nil;
		}
	}
}

global
void free_cache(void)
{
	while (cache)
		cache = free_cache_unit(cache);

#if PCNT_SAMPLE
	do_pcnts();
#endif
}

global
void init_cache(void)
{
	free_cache();
	cache = nil;
}

global
CP cache_look(CP pt, CP *ppr, Cstr name, bool new)
{
	CP pr = nil;
	while (pt)
	{
		if (SCMP(80,pt->name, name) eq 0)
		{
			if (new)
				pt->busy += 1;
			if (ppr)
				*ppr = pr;
			return pt;
		}
		pr = pt;
		pt = pt->next;
	}

	if (ppr)
		*ppr = nil;
	return nil;
}

global
CP new_cache(void)
{
	CP new = CC_xcalloc(1, sizeof(*new), AH_NEW_CACHE, CC_ranout);
	if (new)
	{
		new->next = cache;
		cache = new;
	}

	return new;
}

/* if a cache entry is also in G.inctab, it is busy and cannot
   be freed. */

#if 0
static
bool not_busy(CP cp)
{
	VP np = G.inctab;

	while (np)
		if (SCMP(81,cp->name, G.inctab->name) eq 0)
			return false;
		else
			np = np->next;

	return true;
}
#else
	#define not_busy(a) ((a)->busy ne 0)
#endif

static
/* find smallest entry larger than size */
CP cache_fits(long size)
{
	long high = 0x7fffffff;
	CP cp = cache, have = nil;
	while (cp)
	{
		if (not_busy(cp))
			if (cp->size >= size)
				if (cp->size < high)
					high = cp->size, have = cp;

		cp = cp->next;
	}

	return have;
}

/* find largest entry smaller than size */
global
CP cache_high(long size)
{
	long high = 0;
	CP cp = cache, have = nil;
	while (cp)
	{
		if (not_busy(cp))
			if (cp->size < size)
				if (cp->size >= high)
					high = cp->size, have = cp;

		cp = cp->next;
	}

	return have;
}

/* try to obtain size bytes from the cache. Unfinished. */

global
bool clean(long size)
{
	/* first find the smallest unit larger than size */

	CP cp = cache_fits(size);
	if (cp)
		CC_ffree(cp);
	else
	{
		/* then accumulate largest sizes until size is met */
	}

	return cp ne nil;		/* success */
}

