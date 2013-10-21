/*
 * Thread safe and debug friendly memory allocator
 *
 * (c) 2001 by Henk Robbers @ Amsterdam
 *
 */


#if XAAES
#include <osbind.h>
#include <sys/types.h>
void display(char *t, ...);
#define printf display
#else
#include <tos.h>
#include <stdio.h>
#endif


#include <string.h>

#include "ahcm.h"

#define DEBUG 0
#define IFIRST 0

#if DEBUG
#define DBG(x) printf x
#else
#define DBG(x)
#endif

XA_memory XA_default_base = {nil, nil, nil, 16384, 16, 3};		/* pref TT-ram */

static
void *new_block(XA_memory *base, long size, bool svcur)
{
	XA_block *new, *last, *first;

	if (base->mode)
		new = Mxalloc(size, base->mode);
	else
		new = Malloc(size);

 	if (new)
	{
		XA_unit *fr;
		DBG((" - new_block %ld :: %ld\n", new, size);)
#if IFIRST
		first = base->first;
		if (first)
		{
			first->prior = new;
			base->first = new;
			new->prior = nil;
			new->next = first;
#else
		last = base->last;
		if (last)
		{
			last->next = new;
			base->last = new;
			new->next = nil;
			new->prior = last;
#endif
		othw
			base->last = base->first = new;
			new->next = new->prior = nil;
		}
		new->used.first = new->used.last = new->used.cur = nil;
		fr = new->area;
		new->free.first = new->free.last = new->free.cur = fr;
		fr->next = fr->prior = nil;
		fr->size = size - blockprefix;
		new->size = size;
		if (svcur)
			base->cur = new;
		return new;
	}
	return nil;
}

static
void free_block(XA_memory *base, XA_block *blk)
{
	XA_block *next = blk->next, *prior = blk->prior;
#if DEBUG
	XA_list *free = &blk->free;
	XA_unit *this = free->first;
	if (!free->first or !free->last)
		printf("free_block; wrong free list f:%ld, l:%ld\n",free->first,free->last);
	else if (this->next or this->prior)
		printf("free_block; wrong free unit p:%ld, n:%ld\n",this->prior,this->next);
	else if (this->size ne blk->size - blockprefix)
		printf("free_block; wrong free size: %ld, b:%ld, diff:%ld\n",
			this->size, blk->size, blk->size - (this->size + blockprefix));
#endif
	if (next)
		next->prior = prior;
	else
		base->last = prior;
	if (prior)
		prior->next = next;
	else
		base->first = next;
	DBG((" - Free block %ld :: %ld\n", blk, blk->size);)
	base->cur = prior ? prior : next;
	Mfree(blk);
}

static
void free_unit(XA_list *list, XA_unit *this)
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
			{
				DBG((" - f0 %ld %ld:: %ld\n",blk, blk->free.cur, blk->free.cur->size);)
				return blk;
			}

	blk = base->first;
	while (blk)
	{
		XA_unit *fr = blk->free.first;
		while (fr)
		{
			DBG((" - f1 %ld :: %ld\n", fr, fr->size);)
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

static
XA_unit *split(XA_list *list, long s)
{
	XA_unit *cur = list->cur;
	long l = cur->size - s;
	if (l > 2*unitprefix)
	{
		XA_unit *new = cur,
	            *next = cur->next;
		(long)new += s;
		new->next = next;
		new->prior = cur;
		if (next)
			next->prior = new;
		else
			list->last = new;
		cur->next = new;
	
		new->size = l;
		cur->size = s;
		new->key = -1;
		new->type = -1;
		list->cur = new;		/* last split off becomes cur. */
	}
#if DEBUG
	else
		printf("Not split %ld :: %ld\n", cur, cur->size);
#endif
	return cur;
}

static
void insfirst(XA_list *list, XA_unit *this)
{
	DBG(("insfirst %ld :: %ld\n", this, this->size);)
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
	DBG(("insbefore %ld\n", before);)
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
	DBG(("inslast %ld :: %ld\n", this, this->size);)
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
	DBG(("insafter %ld\n", after);)
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
			DBG((" - combine %ld :: %ld + %ld :: %ld = %ld :: %ld\n",
				this, this->size, next, next->size, this, this->size + next->size);)
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
	DBG(("sortins %ld\n", this);)

	have = list->cur;
	if (!have)
		have = list->first;
	if (!have)
	{
		DBG((" - c0\n");)
		insfirst(list, this);
	}
	else
	if (have->area < this->area)
	{
		DBG((" - c1\n");)
		while (have and have->area < this->area)
			have = have->next;
		if (!have)
			inslast(list, this);
		else
			insbefore(list, this, have);
	othw
		DBG((" - c2\n");)
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
	DBG((" - a1\n");)
	amalgam(list, this);
	if (this->prior)
	{
		DBG((" - a2\n");)
		amalgam(list, this->prior);
	}
}

/* The smaller the requested area, the less likely it is
   allocated & freed only once in a while. */
void *XA_alloc(XA_memory *base, size_t size, XA_key key, XA_key type)
{
	XA_block *blk = nil;
	long s = ((size+3)&-4) + unitprefix;

	if (!base)
		base = &XA_default_base;

	if (s > (base->chunk - base->head - blockprefix))
	{
		long bls = s + blockprefix,
		      ns = 0;
		while (ns < bls) ns+= base->chunk;

		blk = new_block(base, ns - base->head, false);
		if (!blk)
			return nil;
	}
	else
		blk = find_free(base, s);

	if (!blk)
		blk = new_block(base, base->chunk - base->head, true);

	if (blk)
	{
		XA_unit *free= split(&blk->free, s);
		free_unit(&blk->free, free);
#if IFIRST
		insfirst(&blk->used, free);
#else
		inslast(&blk->used, free);
#endif
		free->key = key;
		free->type = type;
		return free->area;
	}
	return nil;
}

void *XA_calloc(XA_memory *base, size_t items, size_t chunk, XA_key key, XA_key type)
{
	void *new = nil;
	long l = items*chunk;
	if (l)
	{
		new = XA_alloc(base, l, key, type);
		if (new)
			memset(new,0,l);
	}
	return new;
}

extern XA_report punit;
static
void free_area(XA_memory *base, XA_block *this, XA_unit *at)
{
DBG((" - free_unit\n");)
	free_unit(&this->used, at);
#if DEBUG
	sortins(&this->free, at);
	combine(&this->free, at);
	if (this->used.first eq nil)
	{
		XA_sanity(base, punit);
		free_block(base, this);
	}
#else
	if (this->used.first eq nil)
		free_block(base, this);
	else
		sortins(&this->free, at),
		combine(&this->free, at);
#endif
}

void XA_free(XA_memory *base, void *area)
{
	XA_block *blk;
	if (!area)
		return;
	if (!base)
		base = &XA_default_base;

	blk = base->cur;
	if (blk)
	{
		if (blk->used.cur)
			if (blk->used.cur->area eq area)
			{
				DBG(("blk free cur %ld %ld:: %ld\n",blk, blk->used.cur, blk->used.cur->size);)
				free_area(base, blk, blk->used.cur);
				return;
			}
	}

	blk = base->first;
	DBG((" - bfirst %ld\n",blk);)
	while (blk)
	{
		long x = (long)area,
		     b = (long)blk->area + unitprefix;
		if (   x >= b
		    && x < b + blk->size - (blockprefix + unitprefix)
		    )
		{
			XA_unit *at;

			if (blk->used.cur)
				if (blk->used.cur->area eq area)
				{
					DBG(("free cur %ld %ld:: %ld\n",blk, blk->used.cur, blk->used.cur->size);)
					free_area(base, blk, blk->used.cur);
					return;
				}

			at = blk->used.first;
			while (at)
			{
				if (at->area eq area)
				{
					free_area(base, blk, at);
					return;
				}
				at = at->next;
			}
		}
		blk = blk->next;
	}
}

bool XA_match(XA_unit *at, XA_key key, XA_key type)
{
	bool m =(    key  eq -1
	         or (key  ne -1 and key  eq at->key)
	         )
	    and (    type eq -1
	         or (type ne -1 and type eq at->type)
	         )
		;
	return m;
}

void XA_free_all(XA_memory *base, XA_key key, XA_key type)
{
	XA_block *blk;
	if (!base)
		base = &XA_default_base;
	blk = base->first;
/* So I can detect leaking */
#if !GENERATE_DIAGS
	if (key eq -1 and type eq -1)
	{
		while(blk)
		{
			XA_block *next = blk->next;
			Mfree(blk);
			blk = next;
		}
		base->first = base->last = base->cur = nil;
	}
	else
#endif
	{
		while (blk)
		{
			XA_block *bx = blk->next;
			XA_unit *at = blk->used.first;
			while (at)
			{
				XA_unit *ax = at->next;
				if (XA_match(at, key, type))
					free_area(base, blk, at);
				at = ax;
			}
			blk = bx;
		}
	}
}

bool XA_leaked(XA_memory *base, XA_key key, XA_key type, XA_report *report)
{
	XA_block *blk; bool reported = false;
	if (!base)
		base = &XA_default_base;
	blk = base->first;
	while (blk)
	{
		XA_unit *at = blk->used.first;
		while (at)
		{
			if (XA_match(at, key, type))
			{
				report(base, blk, at, "leak");
				reported = true;
			}
			at = at->next;
		}
		blk = blk->next;
	}
	return reported;
}

typedef struct record
{
	long size;
	char d[0];
} REC;

void XA_follow(XA_memory *base, XA_block *blk, XA_list *list, XA_report *report)
{
	/* Go up and down the list, finish at the same address. */
	XA_unit *un = list->first, *n = un, *p;
	while (un)
	{
		n = un;
		un = un->next;
	}
	if (n ne list->last)
	{
		report(base, blk, n, "last found");
		report(base, blk, list->last, "list->last");
	}
	un = list->last;
	n = un;
	while (un)
	{
		n = un;
		un = un->prior;
	}
	if (n ne list->first)
	{
		report(base, blk, n, "first found");
		report(base, blk, list->first, "list->first");
	}
}

void XA_sanity(XA_memory *base, XA_report *report)
{
	XA_block *blk;
#if DEBUG
	printf("\nSanity check\n\n");
#endif
	if (!base)
		base = &XA_default_base;
	/* follow sizes and see if they fit. */
	blk = base->first;
	while (blk)
	{
		REC *at = (REC *)blk, *to = (REC *)blk, *pr;
		(long)at += blockprefix;
		(long)to += blk->size;

		while (at < to)
		{
			pr = at;
			(long)at += at->size;
		}

		if (at != to)
			report(base, blk, (XA_unit *)pr, "insane");
#if DEBUG
		printf("Follow free list\n");
#endif
		XA_follow(base, blk, &blk->free, punit);
#if DEBUG
		printf("Follow used list\n");
#endif
		XA_follow(base, blk, &blk->used, punit);
		blk = blk->next;
	}
}

void XA_set_base(XA_memory *base, size_t chunk, short head, short flags)
{
	if (!base)
		base = &XA_default_base;

	base->first = base->last = base->cur = nil;

	if (!chunk)
		base->chunk = XA_default_base.chunk;
	elif (chunk > 0)
		base->chunk = chunk;
	else
		base->chunk = 8192;

	if (!head)
		base->head = XA_default_base.head;
	elif (head > 0)
		base->head = head;
	else
		base->head = 16;

	base->mode = flags;
}

#if !XAAES
#if XA_lib_replace

void *malloc(size_t size)
{
	return XA_alloc(nil,size,0,0);
}

void *calloc(size_t items, size_t chunk)
{
	return XA_calloc(nil, items, chunk, 0, 0);
}

void free(void *addr)
{
	XA_free(nil,addr);
}
#endif

void _FreeAll(void) {/*XA_free_all(nil,-1,-1);*/}

#endif
