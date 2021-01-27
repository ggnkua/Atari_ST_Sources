/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
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

/* decl_a.h */

static
TP ok_decl_A(TP rv, TP head, short dty)
{
	if (!ok_revx(rv, dty))
	{
		freeTn(rv);
		return nil;
	}

	if (rv)
		d_to_dt(rv, head);
	elif (dty) 			/* 0 normal 1 cast 2 func */
		rv = head; 			/* cast or func */

	G.last_decl = rv;		/* For #pragma prln */

	return rv;
}

static
bool must_nct(TP tp)
{
	switch(tp->token)	/* type_maker types */
	{
		case REFTO:
		case ROW:
		case T_PROC:
		return false;
	}
	
	return tp->cflgs.f.q ne 0;
}

static
void decl_nct(bool last, TP e1, TP head)
{
	if (head)
	{
		if (last)
			while(head->type)	/* find last but one */
			{
				e1 = head;
				head = head->type;
			}

		if (e1)
			if (must_nct(head))
				type_is_not_a_copy(e1);
	}
}

static
TP target_type(TP tp)
{
	while (tp->type)
	{
		if (is_basic(tp->type) /* tp->type->nflgs.f.bas ne 0 */)
			return tp;
		tp = tp->type;
	}
	
	return nil;
}

static
void rep_tdef(TP head, TP e1, short tok, short newtok)
{
	TP new = basic_type(newtok, 1000);
	if (head->token eq T_DEF)
		e1->type = new;
	else
	{
		TP bas = target_type(head);
		if (bas and bas->type and bas->type->token eq T_DEF)
		{
			if (bas->token eq ROW)
			{
				size_t row = bas->size/bas->type->size;
				bas->size = row * new->size;
			}

			d_to_dt(bas, new);
		}
		elif (tok)
			errorn(e1, "incorrect use of '%s'", graphic[tok]);
	}
}


TP Declare_A(TP e1, TP head)
{
	if (e1 and head)
	{
		decl_nct(false, e1, head);		/* to e1 */
		decl_nct(true,  e1, head);		/* to last but 1 of head */
		if   (e1->aflgs.f.ns)
			rep_tdef(head, e1, STR, T_STRING);
/*		elif (e1->aflgs.f.np)
			rep_tdef(head, e1, CAR, T_INT);
*/		elif (e1->aflgs.f.nf)
			rep_tdef(head, e1, FLO, T_REAL);
		elif (head->token eq T_DEF)
			rep_tdef(head, e1, 0, T_INT);
	}

	G.last_decl = e1;		/* For #pragma prln */
	return e1;
}
