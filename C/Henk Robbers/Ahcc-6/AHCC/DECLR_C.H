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

/* declr_c.h */

static
TP decl_su(short isstruct)
{
	TP rv = nil, tagp;
	TP *attab;

	fadvnode();		/* skip 'struct' or 'union' */

	attab = G.prtab->level ? &G.scope->b_tags : &G.tagtab;
	tagp = nil;
	if (cur->token eq ID)
		tagp = tpcur(), advnode();	/* hold on to ID node */

	if (cur->token eq BLOCK)
	{							/* new declaration */
		if (tagp eq nil)
		{
			tagp = make_type(ID,-1,nil,nil);
	/* Using line nr in dummy names is not a good idee,
	 * U can have any number of structs without tagname in 1 line.
	 */		/* tagp->token = ID; */
			new_name(tagp, "__%d", new_lbl());
		}
		fadvnode();				/* skip left delimiter */
		if ((rv = tlook(*attab, tagp)) ne nil )
		{
			freeTn(tagp);
			if (rv->list)
			{
				errorn(rv, "redefinition of %s", graphic[rv->token]);
				freeTn(rv->list);
				rv->list = nil;
			}
		othw					/* new defn */
			rv = tagp;
			to_type(rv, isstruct);
			putt_lifo(attab, rv);
		}
		su_decls(&rv->list, isstruct, &rv->size, &rv->aln);
		while (rv->size & ALN_A) rv->size++;		/* 01'14 HR v5.1 */
		eat(KCOLB);
	othw						/* reference to allready defined */
		if ( tagp eq nil )
			error("nonsense %s", graphic[isstruct]);
		else
		{
			/* ANSI special decl
				struct <tag> ;
			   for hiding old tag within block */
			if (cur->token eq ENDS and G.prtab->level)
				rv = tlook(*attab, tagp);
			else
				rv = alltags(tagp);
			if (rv eq nil)
			{						/* delayed tag */
				rv = tagp;
				to_type(rv, isstruct);
				putt_lifo(attab, rv);
			} else
				freeTn(tagp);
		}
	}
	return rv;
}
