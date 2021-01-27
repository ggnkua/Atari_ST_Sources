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
 *
 * lmem.c
 *
 * local and/or quick memory allocation
 *
 */

#include <prelude.h>
#include <stdio.h>
#include "ahcm.h"
#include "qmem.h"

global
void * qalloc(MEMBASE *mb, long new)
{
	char *ret;

	if (new < 1)
		return nil;

	new = (new + 3) & -4;

	if (mb->memorynow + new > mb->chunk)
	{
		mb->memory = XA_alloc(&mb->base, mb->chunk, nil, -1, -1);

		if (mb->memory eq nil)
			return nil;

		mb->memorynow = 0;
	}

	ret = mb->memory;
	mb->memory += new;
	mb->memorynow += new;
	return ret;
}

global
void * CC_qalloc(MEMBASE *mb, long new, XA_run_out *ranout, XA_key key)
{
	char *ret;

	if (new < 1)
		return nil;

	new = (new + 3) & -4;

	if (mb->memorynow + new > mb->chunk)
	{
		mb->memory = XA_alloc(&mb->base, mb->chunk, ranout, key, -1);
		mb->memorynow = 0;
	}

	ret = mb->memory;
	mb->memory += new;
	mb->memorynow += new;
	return ret;
}

global
void init_membase(MEMBASE *mb, long chunk, short flag, char *name, XA_run_out *runout)
{
	mb->chunk = chunk - blockprefix - 2*unitprefix;
	mb->memorynow = 2*mb->chunk;
	mb->memory = nil;
	mb->name = name;
	XA_set_base(&mb->base, chunk, 0, 0, runout, name);
	mb->base.flags = flag;
}

global
void free_membase(MEMBASE *mb)
{
	XA_free_all(&mb->base, -1, -1);
	mb->memorynow = 2*mb->chunk;
	mb->memory = nil;
}

