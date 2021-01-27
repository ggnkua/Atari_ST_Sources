/* Copyright (c) 2001 - 2009 by Henk Robbers @ Amsterdam
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


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "ahcm.h"

#define USEM1M1 1			/* If 0, XA_match can be tested */
#define LARGE 1
#define IFIRST 0
#define TEST_OUT_OF_MEMORY 0	/* If 1, left shift simulates out of memory condition */
#define MDEBUG 0

typedef struct record
{
	long size;
	char data[0];
} REC;

#define ptrok(x) ((long)x >= 0x1000000L && (long)x < 0x2000000L)
long Fdump(char *fn, short *rfl, long l, void *map);

XA_memory
	XA_heap_base   = {nil, nil, nil, 16384, 13, 0,        0, 0, nil, nil, "default"      },	/* mode 3 is pref TT-ram */
	XA_local_base  = {nil, nil, nil,  8192, 13, 0,        0, 0, nil, nil, "local base"   },
	XA_file_base   = {nil, nil, nil, 16384, 13, 0,        0, 0, nil, nil, "file base"    },
	XA_global_base = {nil, nil, nil,  4096, 12, 0,MX_GLOBAL, 0, nil, nil, "global base"  };
/*                                   ^^^^^
 * If you've made a type error       here,
 *   AHCM will nicely round it up for you :-)
 */

size_t XA_total = 0;

XA_report chk;

/*
static
char ran_out[] = "************* OUT OF MALLOC *************";
*/

static
void *new_block(XA_memory *base, long size, bool svcur, XA_key key, XA_key type)
{
	XA_block *new;

#if TEST_OUT_OF_MEMORY
	long Kbshift(short);
	#define break_in (Kbshift(-1)==1)

	new = nil;
	if (!break_in)
#endif

	if (base->mode)
		new = Mxalloc(size, base->mode);
	else
		new = Malloc(size);

	if (new)
	{
		XA_unit *fr;
#if IFIRST
		XA_block *first  = base->first;
		if (first)
		{
			first->prior = new;
			base->first = new;
			new->prior = nil;
			new->next = first;
		}
#else
		XA_block *last = base->last;
		if (last)
		{
			last->next = new;
			base->last = new;
			new->next = nil;
			new->prior = last;
		}
#endif
		else
		{
			base->last = base->first = new;
			new->next = new->prior = nil;
		}
#ifdef XA_MAGIC
		new->magic = XA_MAGIC;
#endif
		new->used.first = new->used.last = new->used.cur = nil;
		fr = new->area;

		new->free.first = new->free.last = new->free.cur = fr;
		fr->next = fr->prior = nil;
		fr->size = size - blockprefix;
		new->size = size;
		if (svcur)
			base->cur = new;
		XA_total += size;
		base->allocated += size;
	othw
		XA_run_out *rout = base->ranout ? base->ranout : base->runout;
		if (rout)
		{
			if (rout(base, key, type) eq 0)
				return new_block(base, size, svcur, key, type);
		}
	}

	return new;
}

#if MDEBUG
static
void XA_Mfree(XA_memory *base, XA_block *blk)
{
	short done;
	long size = blk->size;

	done = Mfree(blk);

	if (done eq 0)
	{
		XA_total -= size;
		base->allocated -= size;
		if (base->allocated < 0)
		{
			printf("****** Mfree inconsistent %s\n", base->name);
			Cconin();
		}
	othw
		printf("****** Mfree failed %s\n", base->name);
		Cconin();
	}
}
#else
#define XA_Mfree(a,b) Mfree(b)
#endif

static
void free_block(XA_memory *base, XA_block *blk)
{
	XA_block *next = blk->next, *prior = blk->prior;

	if (next)
		next->prior = prior;
	else
		base->last = prior;
	if (prior)
		prior->next = next;
	else
		base->first = next;

	base->cur = prior ? prior : next;

	XA_Mfree(base, blk);
}

static
void extract(XA_list *list, XA_unit *this)
{
	XA_unit *next = this->next, *prior = this->prior;
	if (next)
		next->prior = prior;
	else
		list->last = prior;
	if (prior)
		prior->next = next;
	else
		list->first = next;
	list->cur = prior ? prior : next;
}

static
XA_block *find_free(XA_memory *base, long s)
{
	XA_block *blk;

	blk = base->cur;
	if (blk)
		if (blk->free.cur)
			if (blk->free.cur->size >= s)
				return blk;

	blk = base->first;
	while (blk)
	{
		XA_unit *fr = blk->free.first;
		while (fr)
		{
			if (fr->size >= s)
			{
				base->cur = blk;
				blk->free.cur = fr;
				return blk;
			}
			fr = fr->next;
		}
		blk = blk->next;
	}
	return nil;
}

/* Option LARGE:
   Remember that blocks are always a whole multiple of roundup size !!
   If a block is larger then chunk size, we put a free area
   at the front of the large block. No space is wasted and when
   the allocated large unit is freed, the large block can be
   shrunken to the chunk size.
*/
static
XA_unit *split(XA_list *list, long s, bool large)
{
	XA_unit *cur = list->cur;
	long l = cur->size - s;

	if (l > 2*unitprefix)
	{
		XA_unit *new  = cur,
		        *next = cur->next;
#if LARGE
		if (large)
		{
			(long)cur += l;
			cur->next = next;
			cur->prior = new;
			if (next)
				next->prior = cur;
			else
				list->last = cur;
			new->next = cur;
		}
		else
#endif
		{
			(long)new += s;
			new->next = next;
			new->prior = cur;
			if (next)
				next->prior = new;
			else
				list->last = new;
			cur->next = new;
		}
		new->size = l;
		cur->size = s;
		new->key = -1;
		new->type  = -1;

		list->cur = new;		/* last split off becomes cur. */
	}

	return cur;
}

static
void insfirst(XA_list *list, XA_unit *this)
{
	list->cur = this;
	this->prior = nil;
	this->next = list->first;
	if (list->first)
		list->first->prior = this;
	else							/* if last is nil, first also nil */
		list->last = this;
	list->first = this;
}

static
void insbefore(XA_list *list, XA_unit *this, XA_unit *before)
{
	this->next = before;
	if (before->prior)
		before->prior->next = this;
	else
		list->first = this;
	this->prior = before->prior;
	before->prior = this;
}

static
void inslast(XA_list *list, XA_unit *this)
{
	list->cur = this;
	this->next = nil;
	this->prior = list->last;
	if (list->last)
		list->last->next = this;
	else							/* if first is nil, last also nil */
		list->first = this;
	list->last = this;
}

static
void insafter(XA_list *list, XA_unit *this, XA_unit *after)
{
	this->prior = after;
	if (after->next)
		after->next->prior = this;
	else
		list->last = this;
	this->next = after->next;
	after->next = this;
}

static
void amalgam(XA_list *list, XA_unit *this)
{
	if (this->next)
	{
		XA_unit *next = this->next;
		if ((long) this + this->size eq (long) next)
		{
			this->size += next->size;
			next = next->next;
			if (next)
				next->prior = this;
			else
				list->last = this;
			this->next = next;
		}
	}
	list->cur = this;
}

static
void sortins(XA_list *list, XA_unit *this)
{
	XA_unit *have;

	have = list->cur;
	if (!have)
		have = list->first;
	if (!have)
		insfirst(list, this);
	else
	if (have->area < this->area)
	{
		while (have and have->area < this->area)
			have = have->next;
		if (!have)
			inslast(list, this);
		else
			insbefore(list, this, have);
	othw
		while (have and have->area > this->area)
			have = have->prior;
		if (!have)
			insfirst(list, this);
		else
			insafter(list, this, have);
	}
}

static
void combine(XA_list *list, XA_unit *this)
{
	amalgam(list, this);
	if (this->prior)
		amalgam(list, this->prior);
}

static
size_t XA_round(XA_memory *base, size_t size)
{
	long y;
	short x = base->round;

	if (x < 12) x = 12;
	if (x > 16) x = 16;

	y = (1L << x) - 1;		/* build a mask */

	if (size & y)
	{
		y = ((size >> x) + 1) << x;		/* must roundup */
		return y;
	}
	else
		return size;					/* already round */
}

static
bool in_list(XA_list *list, void *area)
{
	XA_unit *at;

	if (list->cur)
		if (list->cur->area eq area)
			return true;

	at = list->first;
	while (at)
	{
		if (at->area eq area)
			return true;

		at = at->next;
	}

	return false;
}

static
XA_block *find_unit(XA_memory *base, void *area)
{
	XA_block *blk = base->cur;

	if (blk)
		if (blk->used.cur)
			if (blk->used.cur->area eq area)
				return blk;

	blk = base->first;

	while (blk)
	{
		long x = (long)area,
		     b = (long)blk->area + unitprefix;

		/* Is the area in this block ? */
		if ( x >= b and x <  b + blk->size - (blockprefix + unitprefix) )
		    if (in_list(&blk->used, area))
				return blk;

		blk = blk->next;
	}

	return nil;
}

static
XA_report chk
{
	printf("%s INSANE!!!!! %s\n", base->name, txt);
	Cconin();
	Fdump("xa_block", nil, 32768L, blk);
}

/* The smaller the requested area, the less likely it is
   allocated & freed only once in a while. */
void *XA_alloc(XA_memory *base, size_t size, XA_run_out *ranout, XA_key key, XA_key ty)
{
	XA_block *blk = nil;
	bool large = false;
	long s;

	s = ((size+3)&-4) + unitprefix;
	if (!base)
		base = &XA_heap_base;

	if (ranout)
		base->ranout = ranout;

	if (s > base->chunk - blockprefix)
	{
		long ns = XA_round(base, s + blockprefix);
		blk = new_block(base, ns, false, key, ty);
		if (!blk)
			return nil;
		large = true;
	}
	else
		blk = find_free(base, s);

	if (!blk)
	{
		base->chunk = XA_round(base, base->chunk);
		blk = new_block(base, base->chunk, true, key, ty);
	}

	if (blk)
	{
		XA_unit *this;

		this = split(&blk->free, s, large);
		extract(&blk->free, this);
#if IFIRST
		insfirst(&blk->used, this);
#else
		inslast(&blk->used, this);
#endif
		this->key  = key;
		this->type = ty;

#if TESTSHRINK
		if (large)
		{
			XA_unit *test = blk->free.first;
			if (test)
			{
				/* By putting the excess unit in the used list I can easily
				   test the shrink process. */
				extract(&blk->free, test);
				insfirst(&blk->used, test);
			}
		}
#endif
		return this->area;
	}
	return nil;
}

void *XA_calloc(XA_memory *base, size_t items, size_t chunk, XA_run_out *ranout, XA_key key, XA_key type)
{
	void *new = nil;
	long l = items*chunk;
	if (l)
	{
		new = XA_alloc(base, l, ranout, key, type);
		if (new)
			memset(new,0,l);
	}
	return new;
}


static
void free_unit(XA_memory *base, XA_block *this, XA_unit *at)
{
	extract(&this->used, at);
	sortins(&this->free, at),
	combine(&this->free, at);

	if (this->used.first eq nil)
		free_block(base, this);
#if LARGE
	else
	if (this->size > base->chunk)		/* 'large' block ? */
	{
		/* shrink a large block if it now has a large free unit at the end of the block */

		at = this->free.last;		/* free list is sorted on address */
		if (at)
		{
			if (    at->size > base->chunk - blockprefix	/* 'large' free unit ? */
			    and (long)at + at->size eq (long)this + this->size		/* at end of block ? */
			   )
			{
				long s = 0, t = blockprefix;

				/* self repair the multiple chunksize prerogative */
				while ((long)this + s < (long)at + unitprefix)
					s += base->chunk;

				if (s < this->size)
				{
					t = this->size - s;
					XA_total -= t;
					this->size -= t;
					at->size -= t;
					Mshrink(0, this, this->size);
				}
			}
		}
	}
#endif
}

void *XA_realloc(XA_memory *base, void *area, size_t size, XA_run_out *ranout, XA_key key, XA_key ty)
{
	XA_block *blk;

	if (area eq nil)
		return XA_alloc(base, size, ranout, key, ty);

	if (!base)
		base = &XA_heap_base;

	if (ranout)
		base->ranout = ranout;

	blk = find_unit(base, area);

	if (blk)
	{
		XA_unit *this = area;
		long old_size, new_size;
		(long)this -= unitprefix;
		new_size = ((size+3)&-4) + unitprefix;
		old_size = this->size;

		if (new_size < old_size)
		{
#if LARGE
			XA_unit *frf;
#endif
			XA_unit *splat;

			if (old_size - new_size < 2*unitprefix)
				return area;

			blk->used.cur = this;
			/* split off excess and integrate in free list */
			splat = split(&blk->used, new_size, false);
			if (splat->next)
				free_unit(base, blk, splat->next);
			else
				Cconout(7), Cconin();

#if LARGE
		/* reasonable optinization when realloc was used in environment having
		   extreme differences between allocation sizes (large blocks involved)
		*/
			frf = blk->free.first;
			if (frf and frf < this)
			{
				if (    blk->size >  base->chunk
				    and new_size  <  base->chunk - (unitprefix + blockprefix)
				    and frf->size >= new_size
				    and frf->size - new_size > 2*unitprefix
				   )
				{
					blk->free.cur = frf;
					split(&blk->free, new_size, false);
					extract(&blk->free, frf);
					inslast(&blk->used, frf);
					memmove(frf->area, area, size);
					free_unit(base, blk, this);
					this = frf;
				}
			}
#endif
			this->key = key;
			this->type = ty;
			return this->area;
		}
		else
		if (new_size > old_size)
		{
			void *new;
#if LARGE
			XA_unit *follow = this;
			long diff = new_size - old_size, fs;

			if ((long)this + this->size < (long)blk + blk->size)
			{
				(long)follow += old_size;
				fs = follow->size;
				/* is the following physical unit free and large enough to hold the extension */

				if (    old_size + fs > new_size
					and fs - diff > 2*unitprefix
				    and in_list(&blk->free, follow->area)
				   )
				{
					XA_unit *followup = follow;

					/* just move up the boundery between this and the following free area */

					(long)followup += diff;
					memmove(followup, follow, unitprefix);
					followup->size -= diff;
					this->size += diff;

					if (followup->prior)
						followup->prior->next = followup;
					else
						blk->free.first = followup;

					if (followup->next)
						followup->next->prior = followup;
					else
						blk->free.last = followup;

					blk->free.cur = followup;
					this->key = key;
					this->type = ty;
					return this->area;
				}
			}
#endif

			new = XA_alloc(base, size, ranout, key, ty);
			if (new)
			{
				memmove(new, area, old_size - unitprefix);
				free_unit(base, blk, this);
			}

			return new;
		}
		else
			return area;				/* same size, do nothing */
	}

	return nil;
}

bool XA_free(XA_memory *base, void *area)
{
	XA_block *blk;
	if (!area)
		return false;

	if (!base)
		base = &XA_heap_base;

	blk = find_unit(base, area);
	if (blk)
	{
		XA_unit *this = area;
		(long)this -= unitprefix;
		free_unit(base, blk, this);
		return true;
	}
	return false;
}

bool XA_match(XA_unit *at, XA_key key, XA_key ty)
{
	bool m =(   key  eq -1
	         or key  eq at->key )
	    and (   ty eq -1
	         or ty eq at->type )
		;
	return m;
}

void XA_free_all(XA_memory *base, XA_key key, XA_key type)
{
	XA_block *blk;

	if (!base)
		base = &XA_heap_base;
	blk = base->first;

#if USEM1M1					/* This is only for being able to test XA_match */
	if (key eq -1 and type eq -1)
	{
		while(blk)
		{
			XA_block *next = blk->next;
			XA_Mfree(base, blk);
			blk = next;
		}
		base->first = base->last = base->cur = nil;
	}
	else
#endif
	{
/* So I can detect leaking */
		while (blk)
		{
			XA_block *bx = blk->next;
			XA_unit *at = blk->used.first;
			while (at)
			{
				XA_unit *ax = at->next;
				if (XA_match(at, key, type))
					free_unit(base, blk, at);
				at = ax;
			}

			blk = bx;
		}
	}
}

void XA_up(XA_memory *base)
{
	if (!base)
		base = &XA_local_base;
	++base->stack;
}

void *XA_new(XA_memory *base, size_t size, XA_key key)
{
	if (!base)
		base = &XA_local_base;
	return XA_alloc(base, size, nil, key, base->stack);
}

void XA_down(XA_memory *base)
{
	XA_block *blk;

	if (!base)
		base = &XA_local_base;

	blk = base->first;

	while (blk)
	{
		XA_block *bx = blk->next;
		XA_unit *at = blk->used.first;
		while (at)
		{
			XA_unit *ax = at->next;

			if (at->type >= base->stack)
				free_unit(base, blk, at);
			at = ax;
		}
		blk = bx;
	}

	if (base->stack > 0)
		--base->stack;
}

bool XA_leaked(XA_memory *base, XA_key key, XA_key ty, XA_report *report, short nr)
{
	XA_block *blk; bool reported = false;
	if (!base)
		base = &XA_heap_base;
	blk = base->first;

	while (blk)
	{
		XA_unit *at = blk->used.first;
		while (at)
		{
			if (XA_match(at, key, ty))
			{
				report(base, blk, at, "leak", nr);
				reported = true;
			}
			at = at->next;
		}
		blk = blk->next;
	}
	return reported;
}

void XA_follow(XA_memory *base, XA_block *blk, XA_list *list, XA_report *report, short which)
{
	/* Go up and down the list, finish at the same address. */
	XA_unit *un = list->first, *n = un;
	while (un)
	{
		n = un;

		if (!ptrok(n))
		{
			report(base, blk, n, "invalid next ptr", which);
			return;
		}

		if ((long)n < (long)blk + blockprefix)
		{
			report(base, blk, n, "next ptr below block", which);
			return;
		}

		if ((long)n > (long)blk + blk->size - unitprefix)
		{
			report(base, blk, n, "next ptr beyond block", which);
			return;
		}

		un = un->next;
	}

	if (n ne list->last)
	{
		report(base, blk, n, "incistent next list", which);
		return;
	}

	un = list->last;
	n = un;

	while (un)
	{
		n = un;

		if (!ptrok(n))
		{
			report(base, blk, n, "invalid prior ptr", which);
			return;
		}

		if ((long)n < (long)blk + blockprefix)
		{
			report(base, blk, n, "prior ptr below block", which);
			return;
		}

		if ((long)n > (long)blk + blk->size - unitprefix)
		{
			report(base, blk, n, "prior ptr beyond block", which);
			return;
		}

		un = un->prior;
	}

	if (n ne list->first)
	{
		report(base, blk, n, "inconsistent prior list", which);
		return;
	}
}

void XA_sanity(XA_memory *base, XA_report *report, short which)
{
	XA_block *blk;

	if (!base)
		base = &XA_heap_base;
	/* follow sizes and see if they fit. */
	blk = base->first;
	while (blk)
	{
		REC *at = (REC *)blk,
		    *to = at,
		    *pr;

		if (!ptrok(blk))
		{
			report(base, blk, nil, "invalid block pointer", 1);
			return;
		}

#ifdef XA_MAGIC
		if (blk->magic ne XA_MAGIC)
		{
			printf("block magic 0x%08lx 0x%08lx\n", blk->magic, blk);
			report(base, blk, nil, "not a block", 2);
			return;
		}
#endif
		if (blk->size < 0)
		{
			printf("block size %ld 0x%08lx blk 0x%08lx\n", blk->size, blk->size, blk);
			report(base, blk, nil, "negative block size", 3);
			return;
		}

		if (blk->size < blockprefix + unitprefix)
		{
			printf("block size %ld 0x%08lx 0x%08lx\n", blk->size, blk->size, blk);
			report(base, blk, nil, "block size too small", 4);
			return;
		}

		(long)at += blockprefix;
		(long)to += blk->size;

		while (at < to)
		{
			if (!ptrok(at))
			{
				report(base, blk, (XA_unit *)at, "invalid unit ptr", 5);
				return;
			}

			if (at->size < 0)
			{
				printf("unit size %ld 0x%08lx at %ld blk 0x%08lx\n", at->size, at->size, (long)at - (long)blk, blk);
				report(base, blk, (XA_unit *)at, "negative unit size", 6);
				return;
			}

			if (at->size < unitprefix)
			{
				printf("unit size %ld 0x%08lx at %ld blk 0x%08lx\n", at->size, at->size, (long)at - (long)blk, blk);
				report(base, blk, (XA_unit *)at, "unit size too small", 7);
				return;
			}

			if ((long)at + at->size > (long)blk + blk->size)
			{
				printf("at %ld, at->size %ld, blk->size %ld\n", at, at->size, blk->size);
				report(base, blk, (XA_unit *)at, "unit size too large", 8);
				return;
			}

			pr = at;
			(long)at += at->size;
		}

		if (at != to)
		{
			printf("blksize %ld, at %lx to %lx diff %ld\n", blk->size, at, to, to - at);
			report(base, blk, (XA_unit *)pr, "unit sizes dont fit block", which);
			return;
		}

		XA_follow(base, blk, &blk->free, report, which);
		XA_follow(base, blk, &blk->used, report, which);

		blk = blk->next;
	}
}

void XA_set_base(XA_memory *base, size_t chunk,
                short round, short mode,
                XA_run_out *runout, char *name)
{
	if (!base)
		base = &XA_heap_base;

	base->first = base->last = base->cur = nil;

/* 0: default, negative: dont change */
	if (!chunk)
		base->chunk = XA_heap_base.chunk;
	elif (chunk > 0)
		base->chunk = chunk;

	if (!round)
		base->round = XA_heap_base.round;
	elif (round > 0)
		base->round = round;

	if (base->round < 13) base->round = 13;
	if (base->round > 16) base->round = 16;

	base->mode  = mode;
	base->flags = 0;

	if (runout)
		base->runout = runout;

	if (name)
		base->name = name;
}

void XA_list_free(XA_memory *base, XA_report *report)
{
	XA_block *blk;
	if (!base)
		base = &XA_heap_base;

	blk = base->first;

	while (blk)
	{
		XA_unit *at = blk->free.first;
		while (at)
		{
			report(base, blk, at, "free", 99);
			at = at->next;
		}
		blk = blk->next;
	}

}

void XA_blocks(XA_memory *base, FILE *fp)
{
	XA_block *blk;
	long total = 0;
	fprintf(fp, "blocks for %s\n", base->name);
	blk = base->first;

	while (blk)
	{
		total += blk->size;
		fprintf(fp, "blk %lx size %ld\n", blk, blk->size);
		blk = blk->next;
	}
	fprintf(fp, "total %ld\n", total);
	fprintf(fp, "==============\n");
}

void pr_blocks(void)
{
	FILE *fp = stdout /* fopen("ahcm_dbg", "w") */;
	if (fp)
	{
		XA_blocks(&XA_heap_base, fp);
		XA_blocks(&XA_local_base, fp);
		XA_blocks(&XA_file_base, fp);
		XA_blocks(&XA_global_base, fp);
/*		fclose(fp); */
	}
	Cconin();
}

#if XA_lib_replace

void *malloc(size_t size)
{
	return XA_alloc(nil, size, nil, 0, 0);
}

void *calloc(size_t items, size_t chunk)
{
	return XA_calloc(nil, items, chunk, nil, 0, 0);
}

void *realloc(void *addr, size_t size)
{
	return XA_realloc(nil, addr, size, nil, 0, 0);
}

void free(void *addr)
{
	XA_free(nil, addr);
}
#endif

void _FreeAll(void)
{
	XA_free_all(nil, -1, -1);
}

global
void *xmalloc(size_t size, XA_key key)
{	return XA_alloc(nil, size, nil, key, 0);	}
global
void *xcalloc(size_t items, size_t chunk, XA_key key)
{	return XA_calloc(nil, items, chunk, nil, key, 0);}
global
void *xrealloc(void *old, size_t size, XA_key key)
{	return XA_realloc(nil, old, size, nil, key, 0);	}
void xfree(void *addr)
{	XA_free(nil, addr); }
void xfree_all(XA_key key)
{	XA_free_all(nil, key, -1);	}


global
void *fmalloc(size_t size, XA_key key)
{	return XA_alloc(&XA_file_base, size, nil, key, 0);	}
global
void *fcalloc(size_t items, size_t chunk, XA_key key)
{	return XA_calloc(&XA_file_base, items, chunk, nil, key, 0);	}
global
void *frealloc(void *old, size_t size, XA_key key)
{	return XA_realloc(&XA_file_base, old, size, nil, key, 0);	}
void ffree(void *area)
{	XA_free(&XA_file_base, area);	}
void ffree_all(XA_key key)
{	XA_free_all(&XA_file_base, key, -1);	}
