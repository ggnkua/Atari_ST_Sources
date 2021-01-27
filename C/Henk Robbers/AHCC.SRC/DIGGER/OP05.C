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
 * OP05.C
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

group op5		/* char cct[][] = condition mnemonics */
{
	short l = BSETW(i.m1&3);
	if (l <= 4)
	{
		if (!(z coldfire and l < 4))
			if ( i.mr <= labs and (l ne 1 or i.m ne 1) )
			{
				ocl(dw, BTST(i.opcode, 8) ? "subq" : "addq", l);
				*pos++ = '#';
				*pos++ = ((i.r1-1)&7)+'1';
				return ea2(dw, i.mr);
			}
	othw
		char *c = "              ",
			 *cc = cct[(i.opcode>>8)&15];
		if (d_alt(i.mr))		/* dit eerst */
			if (!(z coldfire and i.m ne 0))
				return oc1(dw, strcat(strcpy(c, "s"), cc), 1, i.mr);
			else ;
		elif (i.m eq 1 and !z coldfire)			/* dan wat overblijft */
		{
			oc1(dw, strcat(strcpy(c, "db"), cc), 2, i.r);
			if (chk_pcrel(dw, 2, z pc, pc_w))
				return 4;
			else
				return *pos++ = ',', z pc = pcrel(dw, z pc, pc_w), eafail;
		}
		elif (i.mr >= 072 and i.mr <= 074)
		{
			if (z mach)
			{
				char *trap = strcat(strcpy(c, "trap"), cc);
				if (i.mr eq 074)		/* no operand */
					return oc(dw, trap, 2), eafail;
				elif (i.mr eq 072)
					return oc1(dw, strcat(trap, ".w"), 2, Imm);
				else
					return oc1(dw, strcat(trap, ".l"), 4, Imm);
			}
			elif (z coldfire and i.r1 eq 0 and i.m1 eq 7)
				return oc0(dw, i.r eq 4
				              ? "tpf"
				              : i.r eq 2
				                ? "tpf.w"
				                : "tpf.l",
				              0), 0;
		}
	}

	return -1;
}
group op6
{
	short bt = (i.opcode>>8)&15;
	char opc = i.opcode;

	if ((i.opcode&0xf00) eq 0)
		z openline = 1;
	oc0(dw, "b", 0);			/* branch */
	print(bt eq 0 ? "ra" : (bt eq 1 ? "sr" : cct[bt]));
	if (opc ne 0)
		if (opc eq -1 and (z mach or z coldfire))
			if (chk_pcrel(dw, 4, z pc, pc_l))
				return 5;
			else
				return print(z cg->lbr), tab(dw, z t2), z pc = pcrel(dw, z pc, pc_l), eafail;
		elif (opc&1)
			return 6;
		else
			return print(z cg->sbr), tab(dw, z t2), address(dw, i.pc.b+opc), eafail;
	elif (chk_pcrel(dw, 2, z pc, pc_w))
		return 7;
	else
		return print(z cg->wbr), tab(dw, z t2), z pc = pcrel(dw, z pc, pc_w), eafail;
}

group op7
{
	if (z coldfire and BTST(i.opcode, 8) ne 0)	/* 0111yyy1xsmmmrrr mvx.s <ea>,dy */
		return oc2l(dw, BTST(i.opcode, 7) ? "mvz" : "mvs",
		                BTST(i.opcode, 6) ? 2     : 1    , i.mr, i.r1);
	elif (BTST(i.opcode,8) eq 0)				/* 0111yyy0xxxxxxxx moveq #x,dy */
	{
		oc(dw, "moveq", 4);
		*pos++ = '#';
		psdhex((char)i.opcode, 2, z cg);
		ea2(dw, i.r1);
		if (*z pc.w-i.r1 eq 0x3f00 or *z pc.w-i.r1 eq 0x3e80)
			trap_id(dw, z pc.u+1, i.opcode&0xff);
		return eafail;
	}
	return -1;
}
