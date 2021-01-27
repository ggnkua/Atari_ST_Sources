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
 * list.c
 */

#include <prelude.h>
#include "list.h"

global
void *rem_list(void *base, void *u)
{
	LISTBASE *lb = base;
	LIST *l = u,
	     *nx = l->next,
	     *pr = l->prior;

	if (pr)
		pr->next = nx;
	else
		lb->first = nx;

	if (nx)
		nx->prior = pr;
	else
		lb->last = pr;

	return nx;
}

global
void cut_list(void *g_fro, void *g_beg, void *g_las)
{
	LISTBASE *fro = g_fro;
	LIST *beg = g_beg,
	     *las = g_las;

	/* remove from fro */
	if (beg->prior)
		beg->prior->next = las->next;
	else
		fro->first = las->next;

	if (las->next)
		las->next->prior = beg->prior;
	else
		fro->last = beg->prior;
}

global
void append_list(void *g_to, void *g_beg, void *g_las)
{
	LISTBASE *to  = g_to;
	LIST *beg = g_beg,
	     *las = g_las;

	/* insert at end of to */
	if (to->last)
		to->last->next = beg;
	beg->prior = to->last;
	las->next = nil;

	to->last = las;
	if (!to->first)
		to->first = beg;
}

global
void move_list(void *to, void *fro, void *beg, void *las)
{
	if (beg and las)
	{
		cut_list(fro, beg, las);
		append_list(to, beg, las);
	}
}

global
void ins_last(void *base, void *item)
{
	LISTBASE *lb = base;
	LIST *new = item;
	if (new)
	{
		if (lb->last)
			lb->last->next = new;
		else
			lb->first = new;
		new->next = nil;
		new->prior = lb->last;
		lb->last = new;
	}
}

global
void ins_first(void *base, void *item)
{
	LISTBASE *lb = base;
	LIST *new = item;
	if (new)
	{
		if (lb->first)
			lb->first->prior = new;
		else
			lb->first = new;
		new->next = lb->first;
		new->prior = nil;
		lb->first = new;
	}
}

global
void ins_before(void *base, void *before, void *item)
{
	LISTBASE *lb = base;
	LIST *bef  = before,
	     *this = item;
	if (this)
	{
		this->next = bef;

		if (bef eq nil)			/* empty list */
		{
			lb->first = lb->last = this;
			this->prior = nil;
		othw
			if (bef->prior)
				bef->prior->next = this;
			else
				lb->first = this;

			this->prior = bef->prior;
			bef->prior = this;
		}
	}
}

global
void ins_after(void *base, void *after, void *item)
{
	LISTBASE *lb = base;
	LIST *aft  = after,
	     *this = item;
	if (this)
	{
		this->prior = aft;

		if (aft eq nil)			/* empty list */
		{
			lb->first = lb->last = this;
			this->next = nil;
		othw
			if (aft->next)
				aft->next->prior = this;
			else
				lb->last = this;

			this->next = aft->next;
			aft->next = this;
		}
	}
}

global
void clr_listbase(void *rb)
{
	LISTBASE *lb = rb;
	lb->first = nil;
	lb->last  = nil;
}

global
LISTBASE new_list(Cstr name)
{
	LISTBASE new;
	new.first = nil;
	new.last  = nil;
	return new;
}
