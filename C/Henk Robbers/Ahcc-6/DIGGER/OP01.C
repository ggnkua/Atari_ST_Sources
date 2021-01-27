/*  (c) 1987 - 1991 by Han  Driesen Leiden.
 *  (c) 1996 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of Atari Digger.
 *
 * Digger is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Digger is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Digger; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * OP01.C
 * ======
 */


#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "common/aaaa_lib.h"
#include "../aaaa_ini.h"
#include "common/config.h"
#include "ttd_kit.h"
#include "ttd_cfg.h"
#include "ttdisass.h"

void send_msg_n(char *text, ...);

#include "group.h"

static
bool cf(short sm, short sr, short dm, short dr)
{
	if (sm <= 4)						return true;
	if (sm eq 5 and dm < 6)				return true;
	if (sm eq 7 and sr eq 2 and dm < 6)	return true;
	if (sm eq 6 and dm < 5)				return true;
	if (sm eq 7)
		switch (sr)
		{
			case 0:
			case 1:
			case 3:
			case 4:
			if (dm < 5)					return true;
		}

	return false;
}

group opmove
{
	if (d_all(i.mr))		/* source */
	{
		short mr1 = (i.m1<<3)+i.r1;
		if (mr1 <= labs)	/* destination */
		{
			short l = i.grp eq 3 ? 2 : (i.grp eq 1 ? 1 : 4);
			if (l>1 or (i.m ne 1 and i.m1 ne 1))
			{
				if (i.m1 eq 1)
				{
					z movea = true;
					oc2l(dw, "movea", l, i.mr, mr1);
				}
				else
					oc2l(dw, "move", l, i.mr, mr1);

				if (z coldfire and !cf(i.m, i.r, i.m1, i.r1))
					eafail = 1000;
				if (eafail eq 0)
					if (i.mr eq Imm)
						if (l >= 2 and (mr1 eq 027 or mr1 eq 047) )
							if ( rel(dw, z pc.b-l) eq rel(dw, z pc.b-l+1) )
								trap_id(dw, z pc.u, *(z pc.u-l/2));
				return eafail;
			}
		}
	}
	return eafail;
}