/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 * (c) 2000 by Henk Robbers @ Amsterdam
 */
 
#ifndef _XA_MEMORY_H
#define _XA_MEMORY_H

#include "prelude.h"

typedef long size_t;

#define XA_lib_replace 1

typedef struct xa_unit
{
	long size;
	struct xa_unit *next,*prior;
	short key, type;
	char area[0];
} XA_unit;

typedef struct xa_list
{
	XA_unit *first, *cur, *last;
} XA_list;

typedef struct xa_block		/* These are the big ones, at least 8K */
{
	long size;
	struct xa_block *next, *prior;
	XA_list used, free;
	short mode;
	XA_unit area[0];
} XA_block;

typedef struct xa_memory
{
	XA_block *first, *last, *cur;		/* No free pointer here, bkocks that
									   become free are returned to GEMDOS */
	long chunk;
	short mode;
} XA_memory;

extern XA_memory XA_global_base;

typedef void XA_report(XA_memory *base, XA_block *blk, XA_unit *unit, char *txt);

void 	XA_set_base	(XA_memory *base, size_t chunk, short flags);
void *	XA_alloc	(XA_memory *base, size_t amount, short key, short type);
void *	XA_calloc	(XA_memory *base, size_t items, size_t chunk, short key, short type);
void 	XA_free		(XA_memory *base, void *area);
void 	XA_free_all	(XA_memory *base, short key, short type);
bool	XA_leaked	(XA_memory *base, short key, short type, XA_report *report);
void	XA_sanity	(XA_memory *base, XA_report *report);


#if XAAES		/* The whole lot is written for XaAES */
void *xcalloc(size_t n, size_t sz, short key);
void *xmalloc(size_t size, short key);
void free(void *);
void _FreeAll(void);
#elif XA_lib_replace
void *calloc(size_t n, size_t sz);
void *malloc(size_t size);
void free(void *);
void _FreeAll(void);
#else
#define calloc(n,l) XA_calloc(&XA_global_base, (n), (l), 0, 0)
#define malloc(l)   XA_alloc (&XA_global_base, (l), 0, 0)
#define free(a)     XA_free  (&XA_global_base, (a))
#define _freeAll()	XA_free_all(&XA_global_base, -1, -1)
#endif

#define unitprefix sizeof(XA_unit)
#define blockprefix sizeof(XA_block)


#endif
