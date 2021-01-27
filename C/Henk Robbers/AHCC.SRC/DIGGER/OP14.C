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
 * OP14.C
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

static char shifts[][8] =
{
	"asr",  "asl",  "lsr", "lsl",
    "roxr", "roxl", "ror", "rol"
};

static char fields[][8] =
{
	"bftst", "bfextu", "bfchg", "bfexts",
    "bfclr", "bfffo",  "bfset", "bfins"
};

static
void fieldop(DW *dw, uint x)
{
	uint o = (x>>6)&0x1f,
	     w = x&0x1f;
	*pos++ = '{';
	if (BTST(x, 11))
		if (o > 7)
			eafail = 47;
		else
			ea(dw, o&7);
	else
		pdhex(o, 2, z cg);

	*pos++ = ':';
	if (BTST(x, 5))
		if (w > 7)
			eafail = 42;
		else
			ea(dw, w&7);
	else
	{
		if (w eq 0)
			w = 32;
		pdhex(w, 2, z cg);
	}
	print("}");
}

group op14
{
	if ((i.m1&3) eq 3)
	{
		short fn = (i.opcode>>8)&7;
		/* 11100ood11xxxxxx asd,lsd,roxd,rod xx (memory) */
		if (i.r1 < 4)
			if (m_alt(i.mr) and !(z coldfire))
				return oc1(dw, shifts[fn], 2, i.mr);
			else ;
		elif (z mach)		/* bit field instructions */
		{
			uint ttx;

			if (i.m ne 0)
				switch (fn)
				{
				case 0:
				case 1:
				case 3:
				case 5:
					if (!c_add(i.mr)) return 980;
				esac
				default:
					if (!c_alt(i.mr)) return 981;
				}

			ttx = *i.pc.u;

			oc(dw, fields[fn], 2);
			if (BTST(ttx, 15) eq 0)
			{
				z pc.u = ++i.pc.u;
				if (fn eq 7)				/* bfins */
					ea(dw, ttx>>12), ea2(dw, i.mr);
				else
					ea(dw, i.mr);
				fieldop(dw, ttx&07777);
				if (i.m1 ne 3)
					if (fn ne 7)
						return ea2(dw, ttx>>12);
					else ;
				elif (ttx&0170000)
					return 899;
			}
			return eafail;
		}
	}
	elif (!(z coldfire and BSETW(i.m1&3) < 4))
	{
		short fn = (i.m&3)*2+(i.m1>>2);
		if (!(z coldfire and fn > 3))		/* rod, roxd */
		{
			/* 1110yyydss0ooxxx asd,lsd,roxd,rod #y,dx
			   1110yyydss1ooxxx asd,lsd,roxd,rod dy,dx  */
			ocl(dw, shifts[fn], BSETW(i.m1&3));
			if (BTST(i.opcode, 5))
				ea(dw, i.r1);
			else
				*pos++ = '#', *pos++ = '1'+((i.r1-1)&7);
			return ea2(dw, i.r);
		}
	}

	return -1;
}
