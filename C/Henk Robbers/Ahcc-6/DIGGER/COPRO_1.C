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
 * COPRO_1.C
 * =========
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
char *ccf[] =
{
	"f",    "eq",  "ogt", "oge", "olt", "ole", "ogl", "or",
	"un",   "ueq", "ugt", "uge", "ult", "ule", "ne",  "t",
	"sf",   "seq", "gt",  "ge",  "lt",  "le",  "gl",  "gle",
	"ngle", "ngl", "nle", "nlt", "nge", "ngt", "sne", "st"
};

static char *fpcr[] =
{
	"?none?", "FPIAR",      "FPSR",      "FPSR/FPIAR",
	"FPCR",   "FPCR/FPIAR", "FPCR/FPSR", "FPCR/FPSR/FPIAR"
};

static
short fszs[] =
{ 4, 4, 12, 12, 2, 8, 1 ,0 };

/* B6 - b0 of lineF 2nd word */
static char fpops  [][8] =
{
	"fmove",	"fint",		"fsinh",	"fintrz",
	"fsqrt",	"F05",		"flognp1",	"F07",
	"fetoxm1",	"fatanh",	"fatan",	"F0b",
	"fasin",	"fatanh",	"fsin",		"ftan",
	"fetox",	"ftwotox",	"ftentox",	"F13",
	"flogn",	"flog10",	"flog2",	"F17",
	"fabs", 	"fcosh",	"fneg",		"F1b",
	"facos",	"fcos",		"fgetexp",	"fgetman",
	"fdiv", 	"fmod",		"fadd",		"fmul",
	"fsgldiv",	"frem",		"fscale",	"fsglmul",
	"fsub", 	"F29",		"F2a",		"F2b",
	"F2c",		"F2d",		"F2e",		"F2f",
	"fsincos",	"fsincos",	"fsincos",	"fsincos",
	"fsincos",	"fsincos",	"fsincos",	"fsincos",
	"fcmp", 	"F39",		"ftst",		"F3b",
	"F3c",		"F3d",		"F3e",		"F3f",
	"fsmove",	"fssqrt",   "F42",      "",
	"fdmove",   "fdsqrt",   "",         "",
	"F48", "", "","",
	"","","","",
	"F50","","","",
	"","","","",
	"fsabs",	"F59","fsneg","",
	"fdabs",	"","fdneg","",
	"fsdiv",	"F61","fsadd","fsmul",
	"fddiv",	"","fdadd","fdmul",
	"fssub",	"F69","","",
	"fdsub",	"","","",
	"F70","","","",
	"","","","",
	"F78","","","",
	"","","",""
};

static char cfpops  [][12] =
{
	"fmove",	"fint",		"*fsinh",	"fintrz",
	"fsqrt",	"F05",		"*flognp1",	"F07",
	"*fetoxm1",	"*fatanh",	"*fatan",	"F0b",
	"*fasin",	"*fatanh",	"*fsin",	"*ftan",
	"*fetox",	"*ftwotox",	"*ftentox",	"F13",
	"*flogn",	"*flog10",	"*flog2",	"F17",
	"fabs", 	"*fcosh",	"fneg",		"F1b",
	"*facos",	"*fcos",	"*fgetexp",	"*fgetman",
	"fdiv", 	"*fmod",	"fadd",		"fmul",
	"*fsgldiv",	"*frem",	"*fscale",	"*fsglmul",
	"fsub", 	"F29",		"F2a",		"F2b",
	"F2c",		"F2d",		"F2e",		"F2f",
	"*fsincos",	"*fsincos",	"*fsincos",	"*fsincos",
	"*fsincos",	"*fsincos",	"*fsincos",	"*fsincos",
	"fcmp", 	"F39",		"ftst",		"F3b",
	"F3c",		"F3d",		"F3e",		"F3f",
	"fsmove",	"fssqrt",   "F42",      "",
	"fdmove",   "fdsqrt",   "",         "",
	"F48", "", "","",
	"","","","",
	"F50","","","",
	"","","","",
	"*fsabs",	"F59",	"fsneg",	"",
	"*fdabs",	"",		"fdneg",	"",
	"fsdiv",	"F61",	"fsadd",	"fsmul",
	"fddiv",	"",		"fdadd",	"fdmul",
	"fssub",	"F69","","",
	"fdsub",	"","","",
	"F70","","","",
	"","","","",
	"F78","","","",
	"","","",""
};

static
void freglist(DW *dw, uint rl, short m)
{
	short mr, h = 0, m1, m0; bool rev;
	if (m eq 4)				/* -(An) */
		m1 = BTST(rl, 0),		/* The bloody bit order is quite opposite that of the movem */
		rev = false;
	else
		m1 = BTST(rl, 7),
		rev = true;
	for (mr = 0; mr <8; mr++)
	{
		m0 = m1;
		if (rev)
			m1 = BTST(rl, 6-mr);
		else
			m1 = BTST(rl, mr+1);

		if (m0)
			if (mr ne 7 and m1)
			{
				if (h ne '-')
				{
					if (h)
						*pos++ = '/';
					print("fp0");
					*(pos-1) += mr;
					h = '-';
				}
			othw
				if (h)
					*pos++ = h;
				print("fp0");
				*(pos-1) += mr;
				h = '/';
			}
	}
	*pos = 0;
}

static
bool fexist(DW *dw, uint x)
{
	x &= 0177;
	if (z mach >= MC040 or x < (z coldfire ? 128 : 64))	/* 040 | 060 */
	{
		char c;
		if (z coldfire)
			c = cfpops[x][0];
		else
			c = fpops[x][0];

		if (islower(c) /*or c eq '*'*/)		/* 'Fxx only for avoiding miscounting in the table ;-) */
			return true;
	}

	return false;
}

static
bool coldok(DW *dw, uint m, uint r)		/* CFPRM 7-8 table 7-6 */
{
	if (z coldfire)
	{
		if (m eq 6) return false;
		if (m eq 7 and r ne 2) return false;
	}
	return true;
}

group copro_1
{
	if (z cg->mc81 /* and i.r1 eq 1*/) 		/* coprocessor id 1 = mc68881/2 */
	{
		short spec;

		if (i.m1)
			return general_coprocessor(dw, i.opcode, i.pc, 31, ccf, "f");
		else
		{
			uint ttx = *i.pc.u, opc = ttx & 0177;
			z pc.u = ++i.pc.u;
			spec = (ttx>>10)&7;

			if (BTST(ttx, 15))			/* fmovem */
			{
				if (!BTST(ttx, 14))		/* r/m */
				{
					if (spec ne 1 and spec ne 2 and spec ne 4) /* must be single system reg */
						eafail = 889;
					else
					{
						oc(dw, "fmove.l", 0);
						z lf = 4;			/* 01'10 HR */
						if (BTST(ttx, 13))	/* direction */
							print(fpcr[spec]), ea2(dw, i.mr);  /* fmove 1 ccr */
						else
							ea(dw, i.mr), *pos++ = ',', print(fpcr[spec]);
					}
				othw
					if ((ttx&0xff) eq 0)
					{
						ocl(dw, "fmovem", 4);
						if (BTST(ttx, 13))
							print(fpcr[spec]), ea2(dw, i.mr);	/* fmovem multiple ccr */
						else
							ea(dw, i.mr), *pos++ = ',', print(fpcr[spec]);
					othw		/* fmovem registers */
						if (z coldfire and (ttx&0017400) ne 0010000) return 810;	/* B12-8 :: 0b10000 */
						oc(dw, "fmovem", 0);
						if (BTST(ttx, 13))
						{
							if (!(c_alt(i.mr) or i.m eq 4))	return 810;
							freglist(dw, ttx, i.m);
							ea2(dw, i.mr);
						othw
							if (!(c_add(i.mr) or i.m eq 3)) return 809;
							ea(dw, i.mr);
							*pos++ = ',';
							freglist(dw, ttx, i.m);
						}
					}
				}	/* r/m */
			othw
				uint dfp = (ttx>>7)&7;	/* destination fp reg */
				if (BTST(ttx, 13))
				{
					if (i.m eq 1) return 800;				/* HR 11'15 v8.3 */
					z lf = fszs[spec];
					if (z coldfire and z lf eq 12)
						return 805;
					z spec = spec;
					if (!coldok(dw, i.m, i.r)) return 804;
					ocl(dw, "fmove", 0);	/* fmove register to memory */
					print("fp0");
					*(pos-1) += dfp;
					ea2(dw, i.mr);
				othw
/*					if (opc eq 0x3a and (ttx&01600) ne 0) return 807;	/* ftst dest reg must be zero */
					but should NOT cause a error exception. (not even on Coldfire)
*/
					if (BTST(ttx, 14))
					{
						if (i.mr eq 0 and spec eq 7)
						{
							oc(dw, "fmovecr", 0), *pos++ = '#', pdhex(opc, 2, z cg);
						othw
							if (!fexist(dw, opc)) return 808;
							if (!coldok(dw, i.m, i.r)) return 804;
							z lf = fszs[spec];
							if (z coldfire and z lf eq 12)
								return 804;
							z spec = spec;
							ocl(dw, z coldfire ? cfpops[opc] : fpops[opc], z lf);   /* fp op memory to register 11'15 v8.3: z lf */
							ea(dw, i.mr);
						}
						print(",fp0");
						*(pos-1) += dfp;
					othw						/* fp op register to register */
						if (i.r or i.m)	return 800;
						if (!fexist(dw, opc))	return 807;
						oc(dw, z coldfire ? cfpops[opc] : fpops[opc], 0);
						print("fp0");
						*(pos-1) += spec;
						if (spec ne dfp or z cg->dblf)
						{
							print(",fp0");
							*(pos-1) += dfp;
						}
					}
				}
				z lf = 0;			/* must be clean after use !! */
			} /* if fmovem */
		}
	}

	return eafail;
}