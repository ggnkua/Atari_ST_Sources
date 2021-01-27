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

/* qmem.h
 *
 * local memory allocation
 *
 */

#ifdef QMEM_H
#pragma endof
#else
#define QMEM_H

#include "ahcm.h"

typedef struct membase
{
	XA_memory base;
	char *memory;
	long memorynow;
	long chunk;
	char *name;
} MEMBASE;

void	init_membase(MEMBASE *mb, long chunk, short flag, char *name, XA_run_out *ranout);
void	free_membase(MEMBASE *mb);
void *	qalloc		(MEMBASE *mb, long new);
void *  CC_qalloc	(MEMBASE *mb, long new, XA_run_out *ranout, XA_key key);

#endif