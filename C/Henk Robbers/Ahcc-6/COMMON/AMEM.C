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
#include "common/ahcm.h"
#include "amem.h"

XA_memory
	XA_NS_base  = {nil, nil, nil,  16384, 13, 0, 0, 0, nil, nil, "compiler node space"},
	XA_CC_base  = {nil, nil, nil,  16384, 13, 0, 0, 0, nil, nil, "compiler base"},
	XA_CC_fbase = {nil, nil, nil,  16384, 13, 0, 0, 0, nil, nil, "compiler file base"};

global
void *NS_xmalloc(size_t size, XA_key key, XA_run_out *ranout)
{	return XA_alloc(&XA_NS_base, size, ranout, key, 0);	}
global
void *NS_xcalloc(size_t items, size_t chunk, XA_key key, XA_run_out *ranout)
{	return XA_calloc(&XA_NS_base, items, chunk, ranout, key, 0);}
global
void *NS_xrealloc(void *old, size_t size, XA_key key, XA_run_out *ranout)
{	return XA_realloc(&XA_NS_base, old, size, ranout, key, 0);	}
global
void NS_xfree(void *addr)
{	XA_free(&XA_NS_base, addr); }
global
void NS_xfree_all(XA_key key)
{	XA_free_all(&XA_NS_base, key, -1); }


global
void *CC_xmalloc(size_t size, XA_key key, XA_run_out *ranout)
{	return XA_alloc(&XA_CC_base, size, ranout, key, 0);	}
global
void *CC_xcalloc(size_t items, size_t chunk, XA_key key, XA_run_out *ranout)
{	return XA_calloc(&XA_CC_base, items, chunk, ranout, key, 0);}
global
void *CC_xrealloc(void *old, size_t size, XA_key key, XA_run_out *ranout)
{	return XA_realloc(&XA_CC_base, old, size, ranout, key, 0);	}
global
void CC_xfree(void *addr)
{	XA_free(&XA_CC_base, addr); }
global
void CC_xfree_all(XA_key key)
{	XA_free_all(&XA_CC_base, key, -1); }


global
void *CC_fmalloc(size_t size, XA_key key, XA_run_out *ranout)
{	return XA_alloc(&XA_CC_fbase, size, ranout, key, 0);	}
global
void *CC_fcalloc(size_t items, size_t chunk, XA_key key, XA_run_out *ranout)
{	return XA_calloc(&XA_CC_fbase, items, chunk, ranout, key, 0);}
global
void *CC_frealloc(void *old, size_t size, XA_key key, XA_run_out *ranout)
{	return XA_realloc(&XA_CC_fbase, old, size, ranout, key, 0);	}
global
void CC_ffree(void *addr)
{	XA_free(&XA_CC_fbase, addr); }
global
void CC_ffree_all(XA_key key)
{	XA_free_all(&XA_CC_fbase, key, -1); }

