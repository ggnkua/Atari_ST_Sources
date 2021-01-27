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

/*
 * loc_proc.h
 * if for A defines a local procedure
 */

global void loc_proc(TP xp, short tok)
{
	FP	new;
	TP	bp, tp = xp->type;
	short l1 = new_lbl();

	/* local procedure body definition (ANS_ARGS only) */
	D_(D, "LPROC");

	out_br(l1);		/* jump over body */
	new=calloc(1, sizeof(FNODE));
#if NODESTATS
	G.ncnt[PRNODE]++;
#endif

	tp->token = L_PROC;
	new->outer=G.prtab;
	G.prtab=new;
	G.prtab->token = tok;
/*	name_to_str((NP)G.prtab, tok eq L_PROC ? "local proc" : "primary stmt");
*/
	xp->sc = K_STATIC;
	xp->lbl = new_lbl();	/* name expression node */
#if GEN_PO
	xp->area_info.class = TEXT_class;
#endif
	G.prtab->fretl = new_lbl(); /* MUST directly after above (L1 & L2) */

	new_gp(nil, PROC);		/* make first gnode for code output */
	gp->name  = xp->name;
/*	gp->nflgs.f.nheap = NCOPY;
*/	gp->sc = xp->sc;
#if GEN_PO
	gp->area_info = xp->area_info;
#endif
	gp->lbl = xp->lbl;

/*	addcode(gp, "\n^S\t\t^N" C( local_proc) "\n");	*/
	addcode(gp, "\n^N" C( local_proc) "\n");

	if (tok ne STMT)
	{
		G.prtab->type  = functy(xp->type);	/* apriori type */
		type_is_not_a_copy(G.prtab);
		loc_sym(xp, 0);
	}
	G.prtab->name = xp->name;	/* funcname globally accessible */
/*	G.prtab->nflgs.f.nheap = 0;
*/	G.prtab->maxregs=G.prtab->outer->maxregs;
	G.prtab->maxlocs=G.prtab->outer->maxlocs;

	next_gp(nil);
	out_pbegin(G.prtab);

	/* L_PROC makes parameters permanent part of local name space */
	G.prtab->level=1;
	new_scope(L_PROC, "lproc arg block");

	if (tok ne STMT)
	{
		G.scope->b_size += tp->size;

		/* generate advice for TOP  etc */
		G.scope->b_syms=copyTnode(tp->list);
		add_argbase(G.scope->b_syms, tp->type, -G.scope->b_size);
		for (bp=G.scope->b_syms; bp ne nil; bp=bp->next)
		{
			next_gp(nil);	 /* no 'register' and '...' */
			loc_advice(bp, gp);
		}
	}

	out_gp();

	{
		VP svfl = G.fltab, svflow = G.flow_chart;
		FP bp;

		G.fltab = allocVn(FLNODE);
		G.flow_chart = G.fltab;
		G.fltab->FF.brk    = -1;
		G.fltab->FF.cont   = -1;
		G.fltab->FF.base = G.fltab;		/* points to itself; is copied in all next's at this level 0 */
		flno = 0;
		G.fltab->F.nr = 0;
		G.fltab->token = L_PROC;
		G.fltab->name = G.prtab->name;

		if (G.lang eq 'a')
		{
			closed_clause(G.fltab);
			if (tok eq STMT)
			{
				tp->type = G.prtab->type;		/* local proc returning ... */
				if (is_nct(G.prtab))
					type_is_not_a_copy(tp);		/* needed, because this type is freed by the normal procedure in e_to_g() */
			}
		othw
			eat(BLOCK);
			do_block(G.fltab, KCOLB, true);
			eat(KCOLB);
		}
		end_scope();

		out_pret(G.prtab, tp);

		freeVn(G.flow_chart);
		G.flow_chart = nil;
		G.fltab = nil;

		bp = G.prtab;				/* step down G.prtab */
		G.prtab = bp->outer;
		G.prtab->maxlocs = bp->maxlocs;	/* keep locals of local proc permanent */
		G.scope->b_size  = bp->maxlocs;
		bp->outer = nil;
		free(bp);
		def_lbl(l1);
		G.flow_chart = svflow, G.fltab = svfl;
	}
}
