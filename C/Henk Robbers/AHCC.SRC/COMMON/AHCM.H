/* Copyright (c) 2001 - present by Henk Robbers @ Amsterdam
 *
 * This file is part of AHCM. A Home Cooked Memory allocator.
 *
 * AHCM is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCM is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCM; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Thread safe and debug friendly memory allocator
 */

#ifdef _XA_MEMORY_H
#pragma if_endfile			/* AHCC: perform #endif and abandon file immediately */
/* there is also if_endcomp and if_endmake, + the equivalents without if_ */
#else
#define _XA_MEMORY_H

#define XA_MAGIC 0xf1e2d3c4

#include <prelude.h>
#include <stdlib.h>		/* size_t */

#define XA_lib_replace 1

typedef short XA_key;

/* size must be multiple of 4 */
typedef struct xa_unit
{
	long size;				/* MUST be in front and include unitprefix !! */
	struct xa_unit *next,*prior;
	XA_key key,
	       type;
	char area[0];
} XA_unit;

typedef struct xa_list
{
	XA_unit *first, *cur, *last;
} XA_list;

/* size must be multiple of 4 */
typedef struct xa_block		/* These are the big ones, at least 8K */
{
	long size;				/* MUST be in front and include blockprefix!! */
#ifdef XA_MAGIC
	long magic;
#endif
	struct xa_block *next, *prior;
	XA_list used, free;
	short mode, filler;
	XA_unit area[0];
} XA_block;

#undef MX_STRAM
#undef MX_TTRAM
#undef MX_PREFSTRAM
#undef MX_PREFTTRAM
#undef MX_HEADER
#undef MX_PRIVATE
#undef MX_GLOBAL
#undef MX_SUPERVISOR
#undef MX_READABLE

enum
{
	MX_STRAM     =   0,
	MX_TTRAM     =   1,
	MX_PREFSTRAM =   2,
	MX_PREFTTRAM =   3,
	MX_HEADER    =  (1 << 3),
	MX_PRIVATE   = ((1 << 3) | (1 << 4)),
	MX_GLOBAL    = ((1 << 3) | (2 << 4)),
	MX_SUPERVISOR= ((1 << 3) | (3 << 4)),
	MX_READABLE  = ((1 << 3) | (4 << 4))
};

#define XA_LOCAL 1		/* base is defined in local memory */

typedef struct xa_memory XA_memory;
typedef void  XA_report(XA_memory *base, XA_block *blk, XA_unit *unit, char *txt, short nr);
typedef short XA_run_out(XA_memory *base, XA_key key, XA_key type);

struct xa_memory
{
	XA_block *first, *last, *cur;	/* No free pointer here, blocks that
									   become free are returned to GEMDOS */
	long chunk;
	short round,
	      flags,
	      mode,
	      stack;
	XA_run_out *runout,				/* default   out of memory function */
	           *ranout;				/* transient out of memory function */
	char *name;
	long allocated;
};

extern XA_memory XA_heap_base, XA_local_base, XA_file_base, XA_global_base;

void 	XA_set_base	(XA_memory *base, size_t chunk, short round, short flags, XA_run_out *runout, char *name);
void *	XA_alloc	(XA_memory *base, size_t amount, XA_run_out *ranout, XA_key key, XA_key type);
void *	XA_calloc	(XA_memory *base, size_t items, size_t chunk, XA_run_out *ranout, XA_key key, XA_key type);
void *	XA_realloc	(XA_memory *base, void *area, size_t size, XA_run_out *ranout, XA_key key, XA_key type);
bool 	XA_free		(XA_memory *base, void *area);
void 	XA_free_all	(XA_memory *base, XA_key key, XA_key type);
void	XA_up		(XA_memory *base);
void *	XA_new		(XA_memory *base, size_t size, XA_key key);
void	XA_down		(XA_memory *base);
bool	XA_leaked	(XA_memory *base, XA_key key, XA_key type, XA_report *report, short which);
void	XA_sanity	(XA_memory *base, XA_report *report, short which);
void    XA_list_free(XA_memory *base, XA_report *report);
void *	XA_find		(XA_memory *base, XA_key key, XA_key type);
bool	XA_present	(XA_memory *base, void *area);

#if XA_lib_replace
/* The below are wrapper functions and do the same
   as the macros further below.
   You can find them in ahcm.c
   By having these functions in ahcm.c
   existing library functions are completely replaced.
*/
	void *calloc(size_t n, size_t sz);
	void *malloc(size_t size);
	void *realloc(void *, size_t);
	void free(void *);
	void _FreeAll(void);
#else
/* In this case, only files that include ahcm.h
   invoke AHCM. Other objects are not affected.
   Calls to standard C malloc in libraries are not
   replaced.
*/
	#define calloc(n,l) XA_calloc(nil, (n), (l), nil, 0, 0)
	#define malloc(l)   XA_alloc (nil, (l), nil, 0, 0)
	#define realloc(p,l) XA_realloc(nil, (p), (l), nil, 0, 0)
	#define free(a)     XA_free  (nil, (a), 0)
	#define _freeAll()	XA_free_all(nil, -1, -1)
#endif

#define unitprefix sizeof(XA_unit)
#define blockprefix sizeof(XA_block)
#define XA_get_l(a) (*(long *)((a)-unitprefix))

void *xmalloc	(size_t, XA_key);
void *xcalloc	(size_t items, size_t chunk, XA_key key);
void *xrealloc	(void *old, size_t size, XA_key key);
void  xfree		(void *);
void *fmalloc	(size_t, XA_key);
void *fcalloc	(size_t items, size_t chunk, XA_key key);
void *frealloc	(void *old, size_t size, XA_key key);
void  ffree		(void *);
#endif

