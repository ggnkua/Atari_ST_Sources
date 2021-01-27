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
 * OP10.C
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
char *LineA[] =
{
	"LineA Init", "Put Pixel", "Get Pixel", "Line", "Hor. Line",
	"Filled Rect.", "Filled Poly.", "Bitblt", "Textblt", "Show Mouse",
	"Hide Mouse", "Transfrm Mouse", "Undraw Sprite", "Draw Sprite", "Cpy RastrFrm",
	"Seedfill",
};

group op10
{
	if (z coldfire and i.m1 eq 5)
	{
		oc(dw, "mov3q", 0);
		*pos++ = '#';
		if (i.r1 eq 0)
		{
			*pos++ = '-';
			*pos++ = '1';
		}
		else
			*pos++ = (i.r1 & 7) + '0';
		return ea2(dw, i.mr);
	}
	ocl(dw, "dc", 3);
	pdhex(i.opcode, 4, z cg);
	if (i.opcode < 0xa010)
		tab(dw, z t4), print("; "), print(LineA[i.opcode&15]);
	return eafail;
}

group op11
{
	switch (i.m1)
	{
	case 0:
	case 1:
	case 2:
		/* 1011yyy0ssxxxxxx cmp xx,dy */
		if ( (i.m ne 1 or i.m1 ne 0) and d_all(i.mr))
			return oc2l(dw, "cmp", BSETW(i.m1), i.mr, i.r1);
	esac
	case 3:
	case 7:
		/* 1011yyys11xxxxxx cmpa xx,ay */
		if (d_all(i.mr))
			return z movea = true, oc2l(dw, "cmpa", (i.m1+1)>>1, i.mr, i.r1+010);
	esac
	case 4:
	case 5:
	case 6:
		if (i.m eq 1)				/* 1011yyy1ss001xxx cmpm (ax)+,(ay)+ */
			if (!z coldfire)
				return oc2l(dw, "cmpm", BSETW(i.m1&3), i.r+postincrement, i.r1+postincrement);
			else ;
		elif (i.mr <= 071)		/* 1101yyy1ssxxxxxx eor dy,xx */
			if (!(z coldfire and BSETW(i.m1&3) < 4))
				return oc2l(dw, "eor", BSETW(i.m1&3), i.r1, i.mr);
	}

	return -1;
}

group op12
{
	switch (i.m1)
	{
	case 0:
	case 1:
	case 2:
		/* 1100yyy0ssxxxxxx and xx,dy */
		if ( d_add(i.mr))
			if (!(z coldfire and BSETW(i.m1) < 4))
				return oc2l(dw, "and", BSETW(i.m1), i.mr, i.r1);
	esac
	case 3:
		/* 1100yyy011xxxxxx mulu xx,dy */
		if (d_add(i.mr))
			return oc2l(dw, "mulu", 2, i.mr, i.r1);
	esac
	case 4:
	case 5:
	case 6:
		if (m_alt(i.mr))			/* 1100yyy1ssxxxxxx and dy,xx */
			if (!(z coldfire and BSETW(i.m1&3) < 4))
				return oc2l(dw, "and", BSETW(i.m1&3), i.r1, i.mr);
			else ;
		elif (i.m eq 0)
			if (i.m1 eq 4)		/* 1100yyy100000xxx abcd dx,dy */
				if (!z coldfire)
					return oc2(dw, "abcd", 1, i.r, i.r1);
				else ;
			elif (i.m1 eq 5 and !z coldfire)	/* 1100yyy101000xxx exg dy,dx */
				return oc2(dw, "exg", 4, i.mr-i.r+i.r1, i.mr);
			else ;
		elif (i.m eq 1)
			if (i.m1 eq 4)		/* 1100yyy100001xxx abcd -(ax),-(ay) */
				if (!z coldfire)
					return oc2(dw, "abcd", 1, i.r+predecrement, i.r1+predecrement);
				else ;
			elif (!z coldfire)
				if (i.m1 eq 5)		/* 1100yyy101001xxx exg ay,ax */
					return oc2(dw, "exg", 4, i.mr-i.r+i.r1, i.mr);
				else	/* i.m1 eq 6	   1100yyy110001xxx exg dy,ax */
					return oc2(dw, "exg", 4, i.r1, i.mr);
	esac
	case 7:
		/* 1100yyy111xxxxxx muls xx,dy */
		if (d_add(i.mr))
			return oc2(dw, "muls", 2, i.mr, i.r1);
	}

	return -1;
}

group op13
{
	switch (i.m1)
	{
	case 0:
	case 1:
	case 2:
		/* 1101yyy0ssxxxxxx add xx,dy */
		if ( (i.m ne 1 or i.m1 ne 0) and d_all(i.mr))
			if (!(z coldfire and BSETW(i.m1) < 4))
				return oc2l(dw, "add", BSETW(i.m1), i.mr, i.r1);
	esac
	case 3:
	case 7:
		/* 1101yyys11xxxxxx adda xx,ay */
		if (d_all(i.mr))
			if (!(z coldfire and ((i.m1+1)>>1) < 4))
				return oc2l(dw, "adda", (i.m1+1)>>1, i.mr, i.r1+adir);
	esac
	case 4:
	case 5:
	case 6:
		if (!(z coldfire and BSETW(i.m1&3) < 4))
			if (m_alt(i.mr))			/* 1101yyy1ssxxxxxx add dy,xx */
				return oc2l(dw, "add", BSETW(i.m1&3), i.r1, i.mr);
			elif (i.m eq 0)			/* 1101yyy1ss000xxx addx dx,dy */
				return oc2l(dw, "addx", BSETW(i.m1&3), i.r, i.r1);
			elif (i.m eq 1)			/* 1101yyy1ss001xxx addx -(ax),-(ay) */
				if (!z coldfire)
					return oc2l(dw, "addx", BSETW(i.m1&3), i.r+predecrement, i.r1+predecrement);
	}

	return -1;
}
