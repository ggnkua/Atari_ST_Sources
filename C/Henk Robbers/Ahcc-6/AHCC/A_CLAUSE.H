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

static
void double_error(NP *np, short token)
{
	error("double '%s'", graphic[cur->token]);
	if (*np)
		freenode(*np);
	*np = nil;
}

static
void clean_loop_control(LOOP_CONTROL *lc)
{
	freenode(lc->xfor);
	lc->xfor = nil;
	freenode(lc->xfrom);
	lc->xfrom = nil;
	freenode(lc->xby);
	lc->xby = nil;
	freenode(lc->xto);
	lc->xto = nil;
	freenode(lc->xwhile);
	lc->xwhile = nil;
}

/*  process a single statement or block */
global
bool closed_clause(VP flow)
{
	LOOP_CONTROL lc = {0};

	if (cur->cat0 & LP_ST)
	{
		lc.any = true;
		lc.loop_back     = new_lbl();
		lc.loop_break    = new_lbl();
		lc.loop_continue = new_lbl();
		new_scope(K_FOR, "loop");
		lc.have_scope = true;

		while (cur->cat0 & LP_ST)
		{
			if (cur->token eq K_DO or cur->token eq K_AFTER)
			{
				do_stmt(flow, &lc);
				break;		/* loop, not switch!! */
			}
			else
			switch(cur->token)
			{
				case K_FOR:
					if (lc.xfor)
						double_error(&lc.xfor, cur->token);
					fadvnode();
					if (cur->token eq K_INT)
					{
						fadvnode();
						lc.here = true;		/* loop var is local */
					}
					if (lc.here)
					{
						if (cur->token ne ID)
						{
							error("'%s' needs ID", graphic[K_FOR]);
							break;
						}
						lc.xfor = npcur();
						lc.id = true;
						advnode();
					othw
						lc.xfor = need_expr();
						if (lc.xfor)
							if (lc.xfor->token eq ID)
								lc.id = true;
					}
				break;
				case K_FROM:
					if (lc.xfrom)
						double_error(&lc.xfrom, cur->token);
					fadvnode();
					lc.xfrom = need_expr();
				break;
				case K_BY:
					if (lc.xby)
						double_error(&lc.xby, cur->token);
					fadvnode();
					lc.xby = need_expr();
				break;
				case K_TO:
					if (lc.xto)
						double_error(&lc.xto, cur->token);
					fadvnode();
					lc.xto = need_expr();
				break;
				case K_WHILE:
					if (lc.xwhile)
						double_error(&lc.xwhile, cur->token);
					fadvnode();
					lc.xwhile = need_expr();
				break;
 				/* There should be NO other LP_ST's than those handled above */
 			}
 		}

		if (!lc.done)
		{
			error("[1]expect '%s'", graphic[K_DO]);
			clean_loop_control(&lc);
		}
		if (lc.after)
			end_scope();
		if (lc.have_scope)
			end_scope();
	othw
		switch(cur->token)
		{
			case BLOCK:
				return block(flow),	true;
			case K_IF:
				return if_stmt(flow), true;
			case K_CASE:
				return case_stmt(flow), true;
			default:
				if (is_brast(cur) and cur->token ne K_GOTO)
					return bra_stmt(flow), true;
		}
	}

	return false;
}

static
bool is_val(short tok)
{
	switch (tok)
	{
		case K_ELSE:		/* choices that can yield a value */
		case K_THEN:
		case BLOCK:
		return true;
	}
	return false;
}

static void warn_open(void)
{
	warn("open unit: '%s' assumed", graphic[ENDS]);
}

/*  for A: process a unit */
static
void unit(VP flow, short tok)		/* tok is stmt beginner k/w */
{
	/* in A all statements are closed */
	do{
		if (closed_clause(flow))			/* a single A statement or block */
		{
			if (cur->token eq ENDS)			/* go on token */
			{
				fadvnode();
				if (G.prtab->token eq STMT and G.prtab->type)
				{
					if (!is_basic(G.prtab->type) /* G.prtab->type->nflgs.f.bas*/)
						freeTn(G.prtab->type);	/* throw away result */
					G.prtab->type = nil;
#if FLOW_SHOW
					if (G.vflag > 3)
						bpr("throw away");
#endif
					G.fltab->F.escape &= ~RETV;
				}
#if FLOW_SHOW
				if (G.vflag > 3)
				{
					bpr("{};");
					list_flow(G.fltab, 0);
				}
#endif
			}
			elif (is_end(cur) or cur->token eq COMMA)
				break;						/* is closed */
			else
			{
				warn_open();
				/* Dont leave the clause too fast (avoids a lot af error messages) */
				/* But it loops sometimes */
				break;
			}
		othw
			NP np = get_expr();
			if (np)
			{
				new_gp(np, EXPR);
				if ((is_end(cur) or cur->token eq COMMA) and is_val(tok))
				{
					if (G.prtab->type)		/* apriori type */
					{
						if (G.prtab->type->token ne T_VOID)
						{
							aprioty_expr(np);
							out_gp();
							return;
						}
					othw					/* not yet a type; get aposteriori type */
						aposty_expr(np);
						out_gp();
						return;
					}
				}

				D_(S, "X_STMT");		/* if get to here: general xpr */
				do_expr(np, FORSIDE);
				out_gp();
			}
			if (cur->token eq ENDS)
				fadvnode();					/* go on token */
#if 0
			else
				break;
#else
			elif (is_end(cur) or cur->token eq COMMA or tok eq K_AFTER)
				break;						/* is closed */
			else
			{
				warn_open();
				break;
			}
#endif
		}
	}od
}
