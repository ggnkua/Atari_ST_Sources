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
#define LOOPCOUNT 0
static
void if_stmt(VP back)
{
	short l1, l2;
	bool lex;
	VP flow;
	NP e1;

	D_(S, "IF");

	flow = new_unit(back, cur, K_IF);
	fadvnode();
	lex = is_ty_start();
	if (lex)
	{
		new_scope(K_IF, "if{");
		loc_decls();
	}
	l1 = new_albl(4);
	e1 = need_expr();
	new_gp(e1, EX1);
	gen_boolean(e1, l1, for_FALSE);
	out_gp();
	eat(K_THEN);
	flow->inner = new_in(flow, "true", -1, -1);
	phrase(flow->inner, K_THEN);
	G.fltab = flow->inner;
	if (cur->token eq K_ELIF)
	{
		D_(S, "ELIF");

		l2 = new_albl(5);
		flow->F.out = new_out(flow, "elif");
		out_br(l2);
		def_albl(l1, 2);
		if_stmt(flow);
		def_albl(l2, 3);
	}
	elif (cur->token eq K_ELSE)
	{
		D_(S, "ELSE");

		fadvnode();
		l2 = new_albl(6);
		flow->F.out = new_out(flow, "else");
		out_br(l2);
		def_albl(l1, 4);
		phrase(flow->F.out, K_ELSE);
		def_albl(l2, 5);
		eat(K_FI);		/* only eat fi when no elif */
	othw
		def_albl(l1, 6);
		eat(K_FI);		/* only eat fi when no elif */
	}

	if (lex)
		end_scope();
	G.fltab = flow;
}

static
void warn_for(LOOP_CONTROL *lc)
{
	if (lc->xfrom)
	{
		warn("'%s' ignored", graphic[K_FROM]);
		freenode(lc->xfrom);
		lc->xfrom = nil;
	}
	if (lc->xby)
	{
		warn("'%s' ignored", graphic[K_BY]);
		freenode(lc->xby);
		lc->xby = nil;
	}
}

global Cstr lc_name;

static
bool do_stmt(VP back, LOOP_CONTROL *lc)
{
	VP flow;
	TP rp = nil, lv = nil;
	short llbl = 0;
	Cstr to_dictionary(Cstr key);
#if LOOPCOUNT
	bool use_c;
#endif
	lc_name = to_dictionary("__c");
	D_(S, "DO");

	flow = new_unit(back, cur, K_DO);
	flow->inner = new_in(flow, "block", lc->loop_break, lc->loop_continue);
	flow->inner->FF.root = flow;
#if LOOPCOUNT
	if (lc->returns or lc->xfor or lc->xto)
		lv = loc_var(T_LONG, lc_name);		/* make the default loop counter */
#endif

	if (lc->xfor)
	{
		NP np = lc->xfor;

		if (!G.nmerrors)
		{
#if 1
			bool s = false;
			if (np->token eq ID)
				if (all_syms((TP)np, 0) ne nil)
					s = true;
			if (s or (lc->id and lc->here))				/* cardinal, classic loop on counter */
#else
			TP sp = all_syms((TP)np, 0);

			if (!sp or (lc->id and lc->here))			/* cardinal, classic loop on counter */
#endif
			{
				lv = loc_var(T_LONG, np->name);		/* make the loop var */
				if (lc->xfrom eq nil)
					out_loop_clear(lv->name);
			othw
				form_types(np, FORSIDE, 0);

				if (    np->token       eq TAKE
				    and np->type->token eq REFTO)
				{
					lc->id = false;
					lc->for_row = true;
					rp = for_row_expr(np);		/* assign local pointer for array */
					if (rp and !G.nmerrors)
						out_arr_end(rp);		/* assign ptr to end */
					warn_for(lc);
				}
				elif (    np->token eq ID
				      and np->type->token eq REFTO
				     )
				{
					lc->id = false;
					lc->for_ref = true;
					rp = for_ref_expr(np);
					warn_for(lc);
				}
				elif (    lc->id
				      and np->token eq ID
				      and is_cardinal(np->type->ty)
				     )
					lv = (TP)np;
				else
				{
					error("'%s' on no row or cardinal", graphic[K_FOR]);
					freenode(lc->xfor);
					lc->xfor = nil;
				}
			}
		}
	}

#if LOOPCOUNT
	use_c = lc->returns or lc->xto or ((!lc->xfrom or !lc->xfor) and !(lc->for_row or lc->for_ref));
	if (use_c)
		out_loop_clear(lc_name);
#else
	if (!lv)
		lv = loc_var(T_LONG, lc_name);		/* make the default loop counter */
#endif

	if (lc->xto and !lc->xfrom)
		lc->xfrom = make_node(ICON, E_LEAF, 0, "from 0");

	if (lc->xfrom)
		from_expr(lc->xfrom, lv);

	/* the symbol table of loop vars must have been setup */
	if (cur->token eq K_AFTER)
	{
		fadvnode();
		lc->after = true;
		new_scope(K_AFTER, graphic[K_AFTER]);
		loc_decls();		/* The after unit must be executed in the right place */
		unit(flow, K_AFTER);
		if (cur->token ne K_DO)
			error("expects '%s'", graphic[K_DO]);
	}

	if (!G.nmerrors)
	{
		if (lc->xfor and rp)
			if (lc->for_row)
			{
				llbl = loop_lbl(lc->loop_back);
				out_arr_cmp(rp->name, lc->loop_break);
			}

		if (lc->xto)
		{
			if (!llbl)
				llbl = loop_lbl(lc->loop_back);
			to_expr(lc->xto, lv, lc->loop_break);
		}

		if (lc->xwhile)
		{
			if (!llbl)
				llbl = loop_lbl(lc->loop_back);
			new_gp(lc->xwhile, WHILE);
			gen_boolean(lc->xwhile, lc->loop_break, for_FALSE);
			out_gp();
		}
	}

	if (!llbl)
		loop_lbl(lc->loop_back);

	if (cur->token eq K_DO)
	{
		lc->done = true;
		fadvnode();
		new_scope(K_DO, graphic[K_DO]);
		if (cur->token eq LABEL)
		{
			fadvnode();
			if (cur->token eq ID)
			{
				SCP sc = G.scope;
				sc->do_lbl = cur->name;
				sc->brk = lc->loop_break;
				sc->cnt = lc->loop_continue;
				fadvnode();
			}
			else
				error("'%s' label needs ID", graphic[K_DO]);
		}
		loc_decls();
		unit(flow->inner, K_DO);
		end_scope();
		eat(K_OD);
	}

	def_albl(lc->loop_continue, 7);

	if (!G.nmerrors)
	{
		if (rp and lc->xfor)
			if (lc->for_row or lc->for_ref)
				out_arr_add(rp);

		if (     lv
		    and !(   lc->for_row
		          or lc->for_ref
		         )
		    and  (   lc->xfor
		          or lc->xfrom
		          or lc->xto
		          or lc->xby
		         )
		   )
		{
			if (!lc->xby)
				lc->xby = make_node(ICON, E_LEAF, 1, "by 1");

			by_expr(lc->xby, lv);
		}

#if LOOPCOUNT
		if (lv and use_c and lv->name ne lc_name)
			out_loop_inc(lc_name);
#endif
		out_br (lc->loop_back);
		def_albl(lc->loop_break, 8);

#if LOOPCOUNT
		if (lc->returns)
			out_loop_rtn();
#endif
	}

	G.fltab = flow;
	return true;
}

/*	case expression
	then
		c1 [[c2]...): {unit} [[, cn: {unit}]...]  /* where cn: is optional.
													 if empty, enumaration takes place
													 (just like enum) */
	else
		unit
	esac
*/
static
bool case_stmt(VP back)
{
	NP e1, cp;
	VP swit, flow;
	short l1, l2, lb, sty;
	long ssz, staffel = 0;

	D_(S, "CASE");
	fadvnode();
	l1 = new_albl(7);		/* esac lable */
	l2 = new_albl(8);		/* branch over code for choices */
	swit = new_unit(back, cur, K_SWITCH);
	swit->inner = new_in(swit, "case", -1, -1);	/* no break's for this kind of statement */
	swit->inner->FF.root = swit;
	e1 = need_expr();
	if (e1)
	{
		new_gp (e1, SWIT);
		do_expr(e1, SWITCH);
		ssz = e1->size;
		sty = e1->ty;
		if (    !G.nmerrors			/* ty not defined than */
			and !is_cardinal(sty)
		   )
			error("%s needs integral", graphic[K_CASE]);
		out_gp();
	}
	out_br(l2);
	swit->F.deflbl = -1;
	swit->F.size = ssz;
	flow = swit->inner;
	G.fltab = flow;
	if (cur->token eq K_WHEN)
	{
		fadvnode();
		do{				/* process choices separated by COMMA */
			lb = new_albl(9);
			do{			/* process constant expressions followed by 1 LABEL */
				VP new = new_case(flow, l1);
				cp = assignx();		/* no COMMA's */
				if (cp)
					new->vval = confold_value(cp, FORSIDE);
				add_case(swit, new->vval, lb);
				G.fltab = new;
				if (cur->token ne COMMA)
					break;
				fadvnode();
			} while (cur_ne(LABEL));
			eat(LABEL);
			def_albl(lb, 9);
			unit(flow, K_THEN);
			out_br(l1);			/* no fall thru: always break */
			if (cur->token ne COMMA)
				break;
			fadvnode();
		}od
	othw
		eat(K_THEN);
		do{				/* process choices seperated by COMMA */
			VP new = new_case(flow, l1);
			lb = new_albl(10);
			new->vval = staffel++;		/* enumerate */
			add_case(swit, new->vval, lb);
			G.fltab = new;
			def_albl(lb, 10);
			unit(flow, K_THEN);
			out_br(l1);			/* no fall thru: always break */
			if (cur->token ne COMMA)
				break;
			fadvnode();
		}od
	}

	if (cur->token eq K_ELSE)
	{
		fadvnode();
		lb = new_albl(11);
		new_default(flow, lb, K_CASE, K_ELSE);
		def_albl(lb, 11);
		phrase(flow->F.out, K_ELSE);
	}
	add_br_1_2(l1);
	gen_switch(swit->F.caselist, swit->F.size, swit->F.deflbl);
	def_albl(l1, 12);
	G.fltab = swit;
	eat(K_ESAC);
	return true;
}
