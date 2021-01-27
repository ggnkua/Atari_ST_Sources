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
 * OP15.C
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

group copro_0,copro_1,copro_2,copro_3,copro_4,copro_5,copro_6,copro_7;

global
short general_coprocessor(DW *dw, uint opcode, PC pc, short n, char *ccn[], char *prf)
{
	short	m1 = (opcode>>6)&7,
		mr = opcode&077,
		r = opcode&7,
		m = mr>>3;

	char c[12]; short fcc; uint ttx;

	c[0] = 0; c[1] = 0;
	switch (m1)
	{
	case 1:
		ttx = *pc.u;
		z pc.u = ++pc.u;
		fcc = ttx&077;
		if (fcc > n) return 799;
		if (d_alt(mr))
		{
			if (z coldfire and *prf eq 'f')
				c[0] = '*';
			return oc1(dw, strcat(strcat(strcat(c, prf), "s"), ccn[fcc]), 0, mr);
		}
		elif (m eq 1)
		{
			if (z coldfire and *prf eq 'f')
				return 798;
			oc1(dw, strcat(strcat(strcpy(c, prf), "db"), ccn[fcc]), 0, r);
			*pos++ = ',';
			if (chk_pcrel(dw, 2, z pc, pc_w))
				return 8;
			else
				z pc = pcrel(dw, z pc, pc_w);
		}
		elif (m eq 7)
		{
			char *trap = "trap";
			if (z coldfire and *prf eq 'f')
				return 798;
			if   (r eq 4)				/* no operand */
				return oc(dw, strcat(strcat(strcpy(c, prf), trap), ccn[fcc]), 0), eafail;
			elif (r eq 3)
				return oc1(dw, strcat(strcat(strcat(strcpy(c, prf), trap), ccn[fcc]), ".l"), 4, Imm);
			else
				return oc1(dw, strcat(strcat(strcat(strcpy(c, prf), trap), ccn[fcc]), ".w"), 2, Imm);
		}
	esac
	case 2:
	case 3:
		if (m1 eq 2 and *pc.w eq 0 and mr eq 0)
			return z pc.w = ++pc.w, oc(dw, "fnop", 0), eafail;
		if (mr > 31) return 798;
		fcc = opcode&n;
		if (fcc eq 0)
			z openline = 1;
		if (m1 eq 3)
			if (chk_pcrel(dw, 4, pc, pc_l))
				eafail = 9;
			else
				return oc0(dw, strcat(strcat(strcpy(c, prf), "b"), ccn[fcc]), 4),
					print(z cg->lbr), tab(dw, z t2),
					z pc = pcrel(dw, pc, pc_l),
					eafail;
		else
			if (chk_pcrel(dw, 2, pc, pc_w))
				eafail = 10;
			else
				return oc0(dw, strcat(strcat(strcpy(c, prf), "b"), ccn[fcc]), 4),
					print(z cg->wbr), tab(dw, z t2),
					z pc = pcrel(dw, pc, pc_w),
					eafail;
	esac
	case 4:
		if (z coldfire and !(m eq 2 or m eq 5))
			return 797;
		if (!(c_alt(mr) or m eq 4))
			return 797;
		return oc1(dw, strcat(strcpy(c, prf), "save"), 2, mr);
	case 5:
		if (z coldfire and !(m eq 2 or m eq 5 or m eq 7))
			return 797;
		if (!(c_add(mr) or m eq 3))
			return 796;
		return oc1(dw, strcat(strcpy(c, prf), "restore"), 2, mr);
	default:
		eafail = 790;
	} /* switch m1 */

	return eafail;
}

global
short ea_t(DW *dw, short mr)
{
	tab(dw, z t2);
	return ea(dw, mr);
}

group *copro[8] =
{
	copro_0, copro_1, copro_2, copro_3, copro_4, copro_5, copro_6, copro_7
};

bool mop15 = false;
group op15
{
	mop15 = true;
/*	if (i.r1 eq 1 and !z cg->mc81)	/* very old TOS 1.00 line_f used by AES */
*/	if (!z cg->mc81)	/* very old TOS 1.00 line_f used by AES -- 08'16 v8.3+: courtesy R. Burrows */
	{
		ocl(dw, "dc", 3);
		prconv(i.opcode, 16, 4, z cg->r16);
		if (z linef.w)
		{
			long a;
			if ((i.opcode&3) eq 0 and (i.opcode&0xfff) < z linef_max )
			{
				PC get;
				tab(dw, z t3);
				print("; jsr  ");
				get.i = z linef.i+(i.opcode&0xfff);
				a = *(get.l);
				if (    z tosimg
				    or ( !  z tosimg
				        and z org.b eq (char *)z os_base
				       )
				   )
					address(dw, z shift.b+a);
				else
					pdhex(a, 6, z cg);
			}
			elif (i.opcode&1)
			{
				tab(dw, z t3), print("; rtx  ");
				reglist(dw, (i.opcode&0xffe)*4, 0);
				z openline = 1;
			}
		}
	}
	elif (copro[i.r1])
		return copro[i.r1](dw, i);

	return eafail;
}
