/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


/* Bridge to AHCM */


#include <ahcm\ahcm.h>

global
void *xmalloc(size_t size, int key)
{
	return XA_alloc(nil, size, key, 0);
}

global
void *xcalloc(size_t items, size_t size, int key)
{
	return XA_calloc(nil, items, size, key, 0);
}

global
void *malloc(size_t size)
{
	return XA_alloc(nil, size, 0, 0);
}

global
void *calloc(size_t items, size_t size)
{
	return XA_calloc(nil, items, size, 0, 0);
}

global
void free(void *addr)
{
	XA_free(nil,addr);
}

global
void _FreeAll(void)
{
	XA_free_all(nil, -1, -1);
}
