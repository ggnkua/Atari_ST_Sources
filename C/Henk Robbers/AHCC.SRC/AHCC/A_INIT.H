/* Copyright (c) 1990 - 2009 by H. Robbers Amsterdam.
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

	short ast = cur->token;
	long save_dat;

	if (   ast eq ASS
		or ast eq IS)
	{
		xp->type->tflgs.f.formal = 0;			/* 04'09 */
		class = xp->sc eq K_GLOBAL ? GDATA_class : DATA_class;
		save_dat = std_areas->ar[class].size;
		permanent_var(4, xp, class);

/* code is put in (global) code generation nodes and
	is written out at the end of the ride by 'outcode_list()'.
	gpbase is the first of the list and contains the permanent_var code
	gp     is the last
	each gp->next (left) is the next in the list.
	each gp->right contains the initialization code.
*/
		fadvnode();
		g_init(tp, class);
		std_area_end(xp, class);
		if (ast eq IS)
			xp->cflgs.f.qc = 1;		/* make ID constant*/
	othw
		class = xp->sc eq K_GLOBAL ? GBSS_class : BSS_class;
		save_dat = std_areas->ar[class].size;
		if (xp->type->tflgs.f.formal)		/* 04'09 row unsized, unitinialized :: formal/forward decl */
			return false;
		warn_const(xp);
		permanent_var(5, xp, class);
		std_area_end(xp, class);
	}

	if (gpbase->left and !G.nmerrors)		/* const to ?CON */
	{
		NP xg = gpbase->left;
		if ( xg->token eq SCALAR and tp->size <= DOT_L)
		{
			if (   xp->cflgs.f.qc
				or tp->cflgs.f.qc
				)
			{		/* make a ?CON */
				xg =xg->right;		/* can only be a ?CON */
				xp->token = xg->token;
				xp->offset = xg->val.i;
				xp->area_info.id = 0;			/* HR 04'15 */
				/* type already ok */
				std_areas->ar[class].size = save_dat;	/* correction */
				return false;  			/* Dont output */
			}
		}
	}
