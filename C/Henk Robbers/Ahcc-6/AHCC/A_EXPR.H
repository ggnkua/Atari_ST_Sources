/* Copyright (c) 1990 - 2009 by H. Robbers.
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

/* expressions that needs checking of apostiori type against apriori type */
global void aprioty_expr(NP np)
{
	G.prtab->tmps = 0;
	if (np and !G.nmerrors)
	{
		form_types(np, FORSIDE, 0);
		if (!G.nmerrors)
		{
			if (   np->type->token eq T_VOID
				or !coercable(G.prtab->type, np->type)
				)
				/* if void or not coercable or same type: dont regard as an escape */
				gen_expr(np, FORSIDE);
			else
			{
				D_(_s, "R_STMT");
				Cast(np, G.prtab->type, IMPCNV, "Aprio_cast");
				gen_expr(np, ret_context(G.prtab->type));
				G.fltab->F.escape |= RETV;
			}
		}
	}
}

global void aposty_expr(NP np)
{
	G.prtab->tmps = 0;
	if (np and !G.nmerrors)
	{
		form_types(np, FORSIDE, 0);
		if (G.nmerrors)
			G.prtab->type = basic_type(T_VOID,0);		/* avoid crashing */
		else
		{
			if (np->type->token eq T_VOID)
				gen_expr(np, FORSIDE);
			else
			{
				D_(_s, "RV_STMT");
				if (np->token eq ICON)
				{
					G.prtab->type = basic_type(
						   np->ty eq ET_U
						 ? T_ULONG
						 : T_LONG,0);		/* always okay */
					to_nct(G.prtab);
				othw
					G.prtab->type = np->type;	/* ?????????????? copy type */
					to_nct(np);
				}
				Cast(np, G.prtab->type, IMPCNV, "Apost_cast");
				gen_expr(np, ret_context(G.prtab->type));
				G.fltab->F.escape |= RETV;
			}
		}
	}
}

global
void t_to_gp(TP vp)
{
	gp->token = vp->token;
	gp->name = vp->name;
	gp->nflgs.f.nheap = 0;
	gp->sc = vp->sc;
	gp->size = vp->type->size;
	gp->val.i = vp->offset;
	gp->rno = vp->rno;
	gp->lbl = vp->lbl;
}

global
TP loc_var(short token, Cstr name)
{
	TP t1, tp;

	D_(_s, "loc_var");

	t1 = allocTn(1);
	t1->token = OREG;
	t1->rno = FRAMEP;
	t1->sc = K_AUTO;
	tp = allocTn(1);
	t1->type = tp;
	to_type(tp, token);
	G.scope->b_size += tp->size;
	t1->offset = -G.scope->b_size;
	name_to_str(t1, to_dictionary(name));
	putt_lifo(&G.scope->b_syms, t1);
	if (!G.nmerrors)
	{
		new_gp(nil, FOR);
		t_to_gp(t1);
		set_vreg(t1);			/* 07'13 HR: v4.15 */
		loc_advice(t1, gp);
		out_gp();
	}

	return t1;
}

global
TP for_ref_expr(NP np)
{
	if (np)
	{
		NP ap;
		TP vp;
		long size;
		Cstr name;

		G.prtab->tmps = 0;
		size = np->type->type->size; 	/* unit size */

		if (!size)
			errorn(np, "size of #A object not known or zero");

		name = to_dictionary(np->name);

		vp = loc_var(REFTO, name);			/* step pointer */
		vp->type->type = np->type->type;	/* make a type & (deref) */
		to_nct(vp->type);
		vp->size = size;					/* unit size */
		vp->nflgs.f.nheap       = 0;
		vp->type->aflgs.f.deref = 1;   /* used by see_id */

		ap = copyone(np);
		np->token = ASS;
		np->tt = E_BIN;
		name_to_str(np, "asn_start_ref");

		np->right = ap;
		np->left = t_copyone_e(vp);
		np->left->token = ID;

		new_gp(np, FOR);
		gen_expr(np, FORSIDE);
		out_gp();

		return vp;		/* is a little symbol table for the loop control variable */
	}

	return nil;
}

global
TP for_row_expr(NP np) /* create 2 temp ptr's to arr in local name space
						for start array & end array */
				  /* create assignment to start pointer */
				  /* return symbols for later use */
				  /* Generate assignment to local pointer */
{
	if (np)
	{
		NP lp = np->left, ap;
		TP vp;
		long s1, s2;
		Cstr name;

		G.prtab->tmps = 0;
		s1 = lp->type->size; 	/* unit size */
		s2 = np->size;			/* total array size & SAW_ARRAY passed by see_array() */

		if (!s1)
			errorn(np, "size of #A object not known or zero");
		if (!s2)
			messagen(0, 0, np, "'%s' on formally declared row", graphic[K_FOR]);

/* Find the appropriate name.
	I think this is right (and simple).
	The only things you can do with arrays is
	take their address or dereference pointers to it,
	all unary operations. If there is any pointer arithmatic
	it can only be + or - and then the pointer is put to the left.
*/
		ap = np;
		while (ap)
		{
			if (ap->token eq ID or ap->token eq SELECT)
			{
				name = to_dictionary(ap->name);;
				break;
			}
			ap = ap->left;
		}

		if (s2)
		{
			vp = loc_var(REFTO, "__e");		/* make the pointer to the end of the array */
			vp->type->type = lp->type;
			to_nct(vp->type);
			vp->size = s2;
		}

		vp = loc_var(REFTO, name);		/* step pointer */
		vp->type->type = lp->type;		/* make a type & (deref) */
		to_nct(vp->type);
		vp->size = s1;					/* unit size */
		vp->nflgs.f.nheap       = 0;
		vp->type->aflgs.f.deref = 1;   /* used by see_id */
		ap = copyone(np);
		ap->left = lp;

		np->token = ASS;
		np->tt = E_BIN;
		name_to_str(np, "asn_start_row");

		np->right = ap;
		np->left = t_copyone_e(vp);
		np->left->token = ID;

		new_gp(np, FOR);
		gen_expr(np, FORSIDE);
		out_gp();

		return vp;		/* is a little symbol table for the loop control variables */
	}

	return nil;
}

global void from_expr(NP np, TP lv)
{
	NP ap = copyone(np);

	ap->left = np->left;
	np->token = ASS;
	np->tt = E_BIN;
	name_to_str(np, "from");

	np->right = ap;
	np->left = t_copyone_e(lv);
	np->left->token = ID;
	form_types(np, FORSIDE, 0);
	G.prtab->tmps = 0;
	new_gp(np, FROM);
	gen_expr(np, FORSIDE);
	out_gp();
}

global void to_expr(NP np, TP lv, short l)
{
	NP ap;

	ap = copyone(np);
	ap->left = allocnode(EXNODE);
	name_to_str(ap->left, to_dictionary(lv->name));
	ap->left->token = ID;
	ap->right = np;
	ap->token = LESS;
	ap->tt = E_BIN;
	name_to_str(ap, "<");
	new_gp(ap, TO);
	gen_boolean(ap, l, for_FALSE);
	out_gp();
}


global void by_expr(NP np, TP lv)
{
	NP ap = copyone(np);

	ap->left = allocnode(EXNODE);
	name_to_str(ap->left, to_dictionary(lv->name));
	ap->left->token = ID;
	ap->right = np;
	ap->token = ASSIGN PLUS;
	ap->tt = E_BIN;
	name_to_str(ap, "+=");

	form_types(ap, FORSIDE, 0);
	G.prtab->tmps = 0;
	new_gp(ap, BY);
	gen_expr(ap, FORSIDE);
	out_gp();
}
