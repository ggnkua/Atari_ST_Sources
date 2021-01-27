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
 * OP08.C
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

group op8
{
	switch (i.m1)
	{
	case 0:
	case 1:
	case 2:
		/* 1000yyy0ssxxxxxx or xx,dy */
		if (d_add(i.mr))
			if (!(z coldfire and BSETW(i.m1) < 4))
				return oc2l(dw, "or", BSETW(i.m1), i.mr, i.r1);
	esac
	case 3:
		/* 1000yyy011xxxxxx divu xx,dy */
		if (d_add(i.mr))
			return oc2(dw, "divu", 2, i.mr, i.r1);
	esac
	case 4:
	case 5:
	case 6:
		if (m_alt(i.mr))		/* 1000yyy1ssxxxxxx or dy,xx */
			if (!(z coldfire and BSETW(i.m1&3) < 4))
				return oc2l(dw, "or", BSETW(i.m1&3), i.r1, i.mr);
			else ;
		elif (!z coldfire and i.m1 eq 4)		/* 1000yyy100000xxx sbcd dx,dy */
			if (i.m eq 0)
				return oc2(dw, "sbcd", 1, i.r, i.r1);
			elif (i.m eq 1)
				return oc2(dw, "sbcd", 1, i.r+predecrement, i.r1+predecrement);
			else ;
		elif (z mach)
			if (i.m1 eq 5)			/* 1000yyy101000xxx pack dx,dy */
				if (i.m eq 0)
					return oc2(dw, "pack", 2, i.r, i.r1), ea2(dw, Imm);
				elif (i.m eq 1)		/* 1000yyy101001xxx pack -(ax),-(ay) */
					return oc2(dw, "pack", 2, i.r+predecrement, i.r1+predecrement), ea2(dw, Imm);
				else ;
			elif (i.m1 eq 6)
				if (i.m eq 0)			/* 1000yyy110000xxx unpk dx,dy */
					return oc2(dw, "unpk", 2, i.r, i.r1), ea2(dw, Imm);
				elif (i.m eq 1)		/* 1000yyy110001xxx unpk -(ax),-(ay) */
					return oc2(dw, "unpk", 2, i.r+predecrement, i.r1+predecrement), ea2(dw, Imm);
	esac
	case 7:
		/* 1000yyy111xxxxxx divs xx,dy */
		if (d_add(i.mr))
			return oc2(dw, "divs", 2, i.mr, i.r1);
	}

	return -1;
}

group op9
{
	switch (i.m1)
	{
	case 0:
	case 1:
	case 2:
		/* 1001yyy0ssxxxxxx sub xx,dy */
		if ( (i.m ne 1 or i.m1 ne 0) and d_all(i.mr))
			if (!(z coldfire and BSETW(i.m1) < 4))
				return oc2l(dw, "sub", BSETW(i.m1), i.mr, i.r1);
	esac
	case 3:
	case 7:
		/* 1001yyys11xxxxxx suba xx,ay */
		if (d_all(i.mr))
			if (!(z coldfire and ((i.m1+1)>>1) < 4))
				return oc2l(dw, "suba", (i.m1+1)>>1, i.mr, i.r1+adir);
	esac
	case 4:
	case 5:
	case 6:
		if (!(z coldfire and BSETW(i.m1&3) < 4))
			if (m_alt(i.mr))			/* 1001yyy1ssxxxxxx sub dy,xx */
				return oc2l(dw, "sub", BSETW(i.m1&3), i.r1, i.mr);
			elif (i.m eq 0)			/* 1001yyy1ss000xxx subx dx,dy */
				return oc2l(dw, "subx", BSETW(i.m1&3), i.r, i.r1);
			elif (i.m eq 1)			/* 1001yyy1ss001xxx subx -(ax),-(ay) */
				if (!z coldfire)
					return oc2l(dw, "subx", BSETW(i.m1&3), i.r+predecrement, i.r1+predecrement);
	}

	return -1;
}
