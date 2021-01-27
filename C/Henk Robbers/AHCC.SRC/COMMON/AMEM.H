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

/* lemem.h
 *
 * local memory allocation
 *
 */

#ifdef LMEM_H
#pragma endof
#else
#define LMEM_H

#include "ahcm.h"

void *	NS_xmalloc	(size_t size,                XA_key key, XA_run_out *ranout);
void *	NS_xcalloc	(size_t items, size_t chunk, XA_key key, XA_run_out *ranout);
void *	NS_xrealloc	(void *old,    size_t size,  XA_key key, XA_run_out *ranout);
void  	NS_xfree	(void *addr);
void  	NS_xfree_all(XA_key key);

void *	CC_xmalloc	(size_t size,                XA_key key, XA_run_out *ranout);
void *	CC_xcalloc	(size_t items, size_t chunk, XA_key key, XA_run_out *ranout);
void *	CC_xrealloc	(void *old,    size_t size,  XA_key key, XA_run_out *ranout);
void  	CC_xfree	(void *addr);
void  	CC_xfree_all(XA_key key);

void *	CC_fmalloc	(size_t size,                XA_key key, XA_run_out *ranout);
void *	CC_fcalloc	(size_t items, size_t chunk, XA_key key, XA_run_out *ranout);
void *	CC_frealloc	(void *old,    size_t size,  XA_key key, XA_run_out *ranout);
void  	CC_ffree	(void *addr);
void  	CC_ffree_all(XA_key key);

XA_run_out CC_ranout, LD_ranout;
extern XA_memory XA_NS_base, XA_CC_base, XA_CC_fbase;
#endif