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
 * list.h
 */

/* generic list */
typedef struct list
{
	struct list *next, *prior;
	void *data;			/* If data is malloc'd, put its pointer here */
} LIST;

typedef struct listbase
{
	LIST *first, *last;
} LISTBASE;


void *	rem_list	(void *base, void *u);
void	ins_last	(void *base, void *item);
void	ins_after	(void *base, void *after,  void *item);
void	ins_before	(void *base, void *before, void *item);
void	cut_list	(void *g_fro, void *g_beg, void *g_las);
void	append_list	(void *g_to, void *g_beg, void *g_las);
void	move_list	(void *to, void *fro, void *beg, void *las);
void	clr_listbase(void *rb);
void	slist_list	(void *base);
LISTBASE new_list	(Cstr name);
