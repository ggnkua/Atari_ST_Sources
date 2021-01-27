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
 * OP00.C
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

group op0
{
	if (i.m eq 1)
		if (i.m1 >= 4 and !z coldfire)
			/* 0000yyy10s001xxx movep d(ax),dy
			   0000yyy11s001xxx movep dy,d(ax)	*/
			if (i.m1 >= 6)
				return oc2l(dw, "movep", ((i.m1&1)+1)*2, i.r1, i.r+Dind);
			else
				return oc2l(dw, "movep", ((i.m1&1)+1)*2, i.r+Dind, i.r1);
		else
			return -1;
	elif (i.m1 < 4)
	{
		if (i.r1 eq 4)
			/* 00001000ooxxxxxx btst,bchg,bclr,bset #n,xx */
			if (i.m1 eq 0)
				if (d_add(i.mr) and !(i.mr eq Imm))
					if (z coldfire and i.m >= 6)
						return -1;
					else
						return oc2(dw, "btst", 1, Imm, i.mr);
				else ;
			elif (d_alt(i.mr))
				if (z coldfire and i.m >= 6)
					return -1;
				elif (i.m1 eq 1)
					return oc2(dw, "bchg", 1, Imm, i.mr);
				elif (i.m1 eq 2)
					return oc2(dw, "bclr", 1, Imm, i.mr);
				else
					return oc2(dw, "bset", 1, Imm, i.mr);
			else ;
		elif (i.m1 < 3)		/* and i.r1 <> 4 */
		{
			/* 0000ooo0ssxxxxxx ori,andi,subi,addi,eori,cmpi #n,xx */
			if (i.mr ne Imm)
			{
				if (i.r1 eq 6)
					if (d_add(i.mr))
						return oc2l(dw, "cmpi", BSETW(i.m1), Imm, i.mr);
				if (!(z coldfire and (i.m or BSETW(i.m1) < 4)))
				{
					if (d_alt(i.mr))
						if (i.r1 eq 0)
							return oc2l(dw, "ori",  BSETW(i.m1), Imm, i.mr);
						elif (i.r1 eq 1)
							return oc2l(dw, "andi", BSETW(i.m1), Imm, i.mr);
						elif (i.r1 eq 2)
							return oc2l(dw, "subi", BSETW(i.m1), Imm, i.mr);
						elif (i.r1 eq 3)
							return oc2l(dw, "addi", BSETW(i.m1), Imm, i.mr);
						elif (i.r1 eq 5)
							return oc2l(dw, "eori", BSETW(i.m1), Imm, i.mr);
				}
			othw
				/* 0000o0o000111100 ori,andi,,,eori #n,ccr
				   0000o0o001111100 ori,andi,,,eori #n,sr   */
				char *ccc;
				if (z coldfire)
					return -1;
				ccc = (i.m1 ? ",sr" : ",ccr");
				switch(i.r1)
				{
				case 0:
					oc1(dw, "ori",  i.m1+1, Imm), print(ccc);
				esac
				case 1:
					oc1(dw, "andi", i.m1+1, Imm), print(ccc);
				esac
				case 5:
					oc1(dw, "eori", i.m1+1, Imm), print(ccc);
				esac
				default:
					return 998;
				}
				return eafail;
			}
			if (z mach and i.r1 eq 7 and m_alt(i.mr))
			{
				uint ttx = *i.pc.u;
				if ( (ttx&0x7ff) ne 0)
					return 998;
				z pc.w = ++i.pc.w;
				if (BTST(ttx, 11))
					return oc2l(dw, "moves", BSETW(i.m1), ttx>>12, i.mr);
				else
					return oc2l(dw, "moves", BSETW(i.m1), i.mr, ttx>>12);
			}
		}
		elif (z coldfire and i.m1 eq 3 and i.r1 < 3 and i.m eq 0)	/* bitrev, byterev, ff1 */
			if (i.r1 eq 0)
				return oc1(dw, "bitrev", 4, i.mr);
			elif (i.r1 eq 1)
				return oc1(dw, "byterev",  4, i.mr);
			else
				return oc1(dw, "ff1", 4, i.mr);
		elif (z mach and i.m1 eq 3)		/* cmp2, chk2, callm, cas, cas2 */
			if (i.r1 >= 5)				/* cas, cas2 */
			{
				uint ttx, tty;

				short l = BSETW((i.r1&3)-1);
				ttx = *i.pc.u;
				if (m_alt(i.mr))
				{
					if (ttx&0177070)
						return 998;
					i.pc.w = ++z pc.w;
					if (oc2l(dw, "cas", l, ttx&7, (ttx>>6)&7) eq 0)
						return ea2(dw, i.mr);
				}
				elif (i.mr eq Imm)	/* cas2 */
				{
					if (z l eq 1)
						return 998;
					tty = *(i.pc.u+1);
					if ( (ttx&07070) ne 0 or (tty&07070) ne 0)
						return 998;
					i.pc.l = ++z pc.l;
					ocl(dw, "cas2", l);
					ea(dw, ttx&7);
					ea2d(dw, tty&7);
					ea2(dw, (ttx>>6)&7);
					ea2d(dw, (tty>>6)&7);
					print(",(");
					ea(dw, ttx>>12);
					print("):(");
					ea(dw, tty>>12);
					print(")");
				}
				else
					return 998;
				return eafail;
			othw
				if (c_add(i.mr))
					if (i.r1 eq 3)
						if (z mach&MC020)		/*  020 */
							return oc2(dw, "callm", 1, Imm, i.mr);
						else
							return 998;		/* not on 030/040/060 */
					else
					{
						uint ttx = *i.pc.u;
						if (ttx&03777)
							return 998;
						z pc.w = ++i.pc.w;
						return oc2l(dw, BTST(ttx,11)
									    ? "chk2" : "cmp2",
									      BSETW(i.r1),
									      i.mr,
									      ttx>>12);
					}
			}
	othw
		/* 0000yyy1ooxxxxxx btst,bchg,bclr,bset dy,xx */
		if (i.m1 eq 4)
			if (d_add(i.mr))
				return oc2(dw, "btst", 1, i.r1, i.mr);
			else ;
		elif (d_alt(i.mr))
			if (i.m1 eq 5)
				return oc2(dw, "bchg", 1, i.r1, i.mr);
			elif (i.m1 eq 6)
				return oc2(dw, "bclr", 1, i.r1, i.mr);
			else
				return oc2(dw, "bset", 1, i.r1, i.mr);
	}
	return -1;
}
