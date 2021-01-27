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
 * COPRO_0.C
 * ========
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

static char *ccp[] =
{
	"bs", "bc", "ls", "lc", "ss", "sc", "as", "ac",
	"ws", "wc", "is", "ic", "gs", "gc", "cs", "cc"
};

static char *eqne[] = {"eq", "ne" };

static
void pmask(short x, short m)
{
	print(",#");
	prdec((x>>5)&m);
}

static
void pmove(DW *dw, short mr, uint x, char *yyy)
{
	char xxx[12];

	strcpy(xxx, yyy);
	if (*(yyy+3) eq '%')		/* BAD, BAC only */
		*(xxx + 3) = '0' + ((x>>2)&7);
	if (BTST(x, 9))			/* r/w */
		if (BTST(x, 8))
			eafail = 43;
		else
			oc(dw, "pmove", 2), print(xxx), ea2(dw, mr);
	else
	{
		if (BTST(x, 8))
			oc(dw, "pmovefd", 2);
		else
			oc(dw, "pmove", 2);
		ea(dw, mr);
		*pos++ = ',';
		print(xxx);
	}
}

static
void fcode(DW *dw, short x, short m, char *opc)
{
	x &= 037;
	oc(dw, opc, 2);
	if (x eq 0)
		print("SFC");
	elif (x eq 1)
		print("DFC");
	elif (x >= 020)
		if ((x&017) > m)
			eafail = 40;
		else
			*pos++ = '#', prdec(x&m);
	elif (x >= 010)
		ea(dw, x&7);
	else
		eafail = 40;
}

static
short pmmu_3_5(DW *dw, short which, PC pc, short mr)
{
	uint ttx = *pc.u;
	short spec = (ttx>>10)&7;
	short fm = which eq 3 ? 7 : 15;

	z pc.u = ++pc.u;
	z spec = spec;

	switch ((ttx>>13)&7)
	{
	case 0:
		if (which eq 3 and (char)ttx eq 0 and m_alt(mr))
			if (spec eq 2)
				pmove(dw, mr, ttx, "TT0");
			elif (spec eq 3)
				pmove(dw, mr, ttx, "TT1");
			else
				eafail = 883;
		else
			eafail = 887;
	esac
	case 1:
		if (spec eq 0)
			if (c_alt(mr) and (ttx&0740) eq 0)
			{
				if (BTST(ttx, 9))
					fcode(dw, ttx, fm, "ploadr");
				else
					fcode(dw, ttx, fm, "ploadw");
				ea2(dw, mr);
			}
			else
				eafail = 886;
		else
		if (which eq 3)				/* mc68030 */
		{
			if ((ttx&01400) eq 0)
				if (spec eq 1 and (ttx&0340) eq 0 and mr eq 0)
					oc(dw, "pflusha", 2);
				elif (spec eq 4 and mr eq 0)
					fcode(dw, ttx, fm, "pflush"), pmask(ttx, 7);
				elif (spec eq 6 and c_alt(mr))
					fcode(dw, ttx, fm, "pflush"), pmask(ttx, 7), ea2(dw, mr);
				else
					eafail = 883;
			else
				eafail = 884;
		othw						/* mc68851 */
			if ((ttx&01000) eq 0)
				if (spec eq 1 and (ttx&0740) eq 0 and mr eq 0)
					oc(dw, "pflusha", 2);
				elif (spec eq 2 and c_alt(mr) and (ttx&0777) eq 0)
					oc0(dw, "pvalid", 0), tab(dw, z t2), print("VAL"), ea2(dw, mr);
				elif (spec eq 3 and c_alt(mr) and (ttx&0770) eq 0)
					oc0(dw, "pvalid", 0), ea_t(dw, adir|(ttx&7)), ea2(dw, mr);
				elif (spec eq 4 and mr eq 0)
					fcode(dw, ttx, fm, "pflush"),  pmask(ttx, 15);
				elif (spec eq 5 and mr eq 0)
					fcode(dw, ttx, fm, "pflushs"), pmask(ttx, 15);
				elif (spec eq 6 and c_alt(mr))
					fcode(dw, ttx, fm, "pflush"),  pmask(ttx, 15), ea2(dw, mr);
				elif (spec eq 7 and c_alt(mr))
					fcode(dw, ttx, fm, "pflushs"), pmask(ttx, 15), ea2(dw, mr);
				else
					eafail = 883;
		}
	esac
	case 2:
		if ((char)ttx)
			eafail = 883;
		elif (which eq 3)
			if (c_alt(mr))
				if (spec eq 0)
					pmove(dw, mr, ttx, "TC");
				elif (spec eq 2)
					pmove(dw, mr, ttx, "SRP");
				elif (spec eq 3)
					pmove(dw, mr, ttx, "CRP");
				else
					eafail = 881;
			else
				eafail = 882;
		elif (BTST(ttx, 9) ne 0 and !alterable(mr))		/* r/w */
			eafail = 883;
		elif (spec eq 0)
			pmove(dw, mr, ttx, "TC");
		elif (spec eq 1 and m_add(mr))
			pmove(dw, mr, ttx, "DRP");
		elif (spec eq 2 and m_add(mr))
			pmove(dw, mr, ttx, "SRP");
		elif (spec eq 3 and m_add(mr))
			pmove(dw, mr, ttx, "CRP");
		elif (spec eq 4)
			pmove(dw, mr, ttx, "CAL");
		elif (spec eq 5)
			pmove(dw, mr, ttx, "VAL");
		elif (spec eq 6)
			pmove(dw, mr, ttx, "SCC");
		elif (spec eq 7)
			pmove(dw, mr, ttx, "AC");
		else
			eafail = 881;
	esac
	case 3:
		if (which eq 3)
			if ((char)ttx or BTST(ttx, 8) or spec)
				eafail = 880;
			else
				pmove(dw, mr, ttx, "MMUSR");
		elif (spec eq 0)
			pmove(dw, mr, ttx, "PSR");
		elif (spec eq 1 and BTST(ttx, 9) ne 0)
			pmove(dw, mr, ttx, "PCSR");
		elif (spec eq 4)
			pmove(dw, mr, ttx, "BAD%");
		elif (spec eq 5)
			pmove(dw, mr, ttx, "BAC%");
		else
			eafail = 881;		/* 851 */
	esac
	case 4:
		if (c_alt(mr))
		{
			if (BTST(ttx, 9))
				fcode(dw, ttx, fm, "ptestr");
			else
				fcode(dw, ttx, fm, "ptestw");
			ea2(dw, mr);
			print(",#");
			prdec((ttx>>10)&7);
			if (BTST(ttx, 8))
				ea2(dw, ((ttx>>5)&7)+010);
			elif ((ttx&0340) ne 0)
				eafail = 880;
		}
		else
			eafail = 880;
	esac
	case 5:
		if (which eq 5 and m_add(mr) and (ttx&017777) eq 0)
			oc1(dw, "pflushr", 0, mr);
		else
			eafail = 887;
	esac
	default:
		return 888;
	}
	return eafail;
}

static
short CF5(DW *dw, inst i)
{
	if (i.m1 eq 7)
	{
		if ((i.m eq 2 or i.m eq 5) and *z pc.u eq 3)
		{
			z pc.u++;
			return oc1(dw, "wdebug", 0, i.mr);
		}
	othw
		short l = BSETW(i.m1&3);
		if (m_alt(i.mr) and l <= 4)
			return oc1l(dw, "wddata", l, i.mr);
	}
	return 555;
}

group copro_0
{
	if ((z mach&MC020) ne 0 and z cg->mc51)	/* coprocessor id 0 and 020+851 = pmmu */
		if (i.m1)
			return general_coprocessor(dw, i.opcode, i.pc, 15, ccp, "p");
		else
			return pmmu_3_5(dw, 5, i.pc, i.mr);
	elif ((z mach&MC030) ne 0 and i.m1 eq 0)	/* coprocessor id 0 = mc68030 on chip pmmu */
		return pmmu_3_5(dw, 3, i.pc, i.mr);

	return -1;
}

group copro_3
{
	if (z mach >= MC040 and i.m1 eq 0 and i.m <= 4)	/* move16 */
	{
		uint ttx = *i.pc.u++;
		oc(dw, "move16", 4);
		if (i.m eq 4)
		{
			if ((ttx&0x8fff) eq 0x8000)
			{
				ea(dw, postincrement+i.r);
				z pc = i.pc;
				return ea2(dw, postincrement+((ttx>>12)&7));
			}
			eafail = 789;
		othw
			switch (i.m)
			{
			case 0:
				ea(dw, postincrement+i.r);
				return ea2(dw, labs);
			case 1:
				ea(dw, labs);
				return ea2(dw, postincrement+i.r);
			case 2:
				ea(dw, indir+i.r);
				return ea2(dw, labs);
			default:
				ea(dw, labs);
				return ea2(dw, indir+i.r);
			}
		}
	}

	return -1;
}

group copro_4
{
	if ((z mach&MC060) ne 0 and i.m1 eq 0 and i.m eq 0 and i.r eq 0
		    and *i.pc.u eq 0x01c0)
	{
		oc(dw, "lpstop", 0);
		z pc.u++;
		*pos++ = '#';
		pdhex(*z pc.u++, 4, z cg);
		return 0;
	}

	return -1;
}

group copro_5
{
	if (i.m1 ne 0)
		if (z coldfire)
			return CF5(dw, i);
		else
			return general_coprocessor(dw, i.opcode, i.pc, 1, eqne, "cp5");

	return -1;
}

group copro_6
{
	if (i.m1 ne 0)
		return general_coprocessor(dw, i.opcode, i.pc, 1, eqne, "cp6");

	return -1;
}

group copro_7
{
	if (i.m1 ne 0)
		return general_coprocessor(dw, i.opcode, i.pc, 1, eqne, "nf");

	return -1;
}
