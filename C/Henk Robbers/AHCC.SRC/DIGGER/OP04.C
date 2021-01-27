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
 * OP04.C
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

short oc1l(DW *dw, char *mnem, short l, short mr)
{
	z l = l;
	tab(dw, z t1);
	print(mnem);
	if (!(l eq 2 and !z cg->wordop))
		*pos++ = '.',
		*pos++ = "bw l"[l-1];
	tab(dw, z t2);
	return ea(dw, mr);
}

static
void ccrr(uint c, short mach)		/* only called if mach ne 0 */
{
	char *s = nil;
	switch (c)
	{
	case 0: s = "sfc"; break;
	case 1: s = "dfc"; break;
	case 2: if (mach < MC060) s = "cacr"; break;
	case 0x800: s = "usp"; break;
	case 0x801: s = "vbr"; break;
	case 0x802: if (mach < MC060) s = "caar"; break;
	case 0x803:	if (mach < MC060) s = "msp"; break;
	case 0x804: if (mach < MC060) s = "isp"; break;
	default:
	if (mach >= MC040)
		switch(c)
		{
			case 3: s = "tc"; break;
			case 4: s = "itt0"; break;
			case 5: s = "itt1"; break;
			case 6: s = "dtt0"; break;
			case 7: s = "dtt1"; break;
			case 0x805: s = "mmusr"; break;
			case 0x806: s = "urp"; break;
			case 0x807: s = "srp"; break;
			default:
			if ((mach&MC060) ne 0 )
				if (c eq 0x808)
					s = "pcr";
				elif (c eq 8)
					s = "buscr";
		}
	}

	if (s eq nil)
 		s = "??ccr??",
 		eafail = 990;
	print(s);
}

static
char *cfccr[] = {"cacr","asid","acr0","acr1","acr2","acr3","mmubar"};

static
void ccrrcf(uint c)
{
	char *s = nil;

	if (c >= 2 and c <= 8)
		s = cfccr[c-2];
	elif (c >= 0xC00 and c <= 0xC0F)
	{
		switch (c)
		{
			case 0xc00: s = "rombar0";   break;
			case 0xc01: s = "rombar1";   break;
			case 0xc04: s = "rambar0";   break;
			case 0xc05: s = "rambar1";   break;
			case 0xc0c: s = "mpcr";      break;
			case 0xc0d: s = "edrambar";  break;
			case 0xc0e: s = "secrambar"; break;
			case 0xc0f: s = "nbar";      break;
		}
	}
	elif (c >= 0xD00 and c <= 0xD0F)
	{
		switch (c)
		{
			case 0xd02: s = "pcr1u0"; break;
			case 0xd03: s = "pcr1l0"; break;
			case 0xd04: s = "pcr2u0"; break;
			case 0xd05: s = "pcr2l0"; break;
			case 0xd06: s = "pcr3u0"; break;
			case 0xd07: s = "pcr3l0"; break;
			case 0xd0a: s = "pcr1u1"; break;
			case 0xd0b: s = "pcr1l1"; break;
			case 0xd0c: s = "pcr2u1"; break;
			case 0xd0d: s = "pcr2l1"; break;
			case 0xd0e: s = "pcr3u1"; break;
			case 0xd0f: s = "pcr3l1"; break;
		}
	}
	elif (c eq 0x801)
		s = "vbr";
	elif (c eq 0x80f)
		s = "pc";

	if (s eq nil)
 		s = "??ccr??",
 		eafail = 990;
	print(s);
}

group op4
{
	if (i.m1 < 4)			/* bit 8!! */
	{
/*	140401; It seems that tst d(pc) is allowed on the whole 68000 family. */
 		if (    (z mach or z coldfire)
 		    and i.r1 eq 5 and i.m1 < 3 and i.mr <= Imm)
		{
			short l = BSETW(i.m1);
			if (l eq 1 and i.m eq 1)
				return 998;
			/* TT all adressing modes allowed except An direct and size = byte */
			oc1l(dw, "tst", l, i.mr);
			return eafail;
		}
		switch (i.r1)
		{
		case 0:
		case 1:
		case 2:
		case 3:
		case 5:
			if (i.m ne 1)
			{
				if (i.m1 < 3)
					/* 01000oo0ssxxxxxx negx,clr,neg,not,tst xx */
					if (i.mr <= labs)
					{
						short l = BSETW(i.m1);
						if (i.r1 eq 0)
							if (z coldfire and (i.m ne 0 or l < 4))
								return -1;
							else
								oc1l(dw, "negx", l, i.mr);
						elif (i.r1 eq 1)
						{
							oc1l(dw, "clr", l, i.mr);
							if (l >= 2)
								if (i.mr eq 027 or i.mr eq 037 or i.mr eq 47)
									trap_id(dw, z pc.u, 0);
						}
						elif (i.r1 eq 2)
							if (z coldfire and (i.m ne 0 or l < 4))
								return -1;
							else
								oc1l(dw, "neg", l, i.mr);
						elif (i.r1 eq 3)
							if (z coldfire and (i.m ne 0 or l < 4))
								return -1;
							else
								oc1l(dw, "not", l, i.mr);
						else
							oc1l(dw, "tst", l, i.mr);
						return eafail;
					}
					else ;
				elif (i.r1 eq 0)  /* and m1 eq 3 */
				{
					/* 0100 000 011 xxx xxx move sr,xx */
					if (z coldfire and i.m eq 4 and i.r eq 7)
					{
						if (*i.pc.u eq 043374)
						{
							z pc.u = ++i.pc.u;
							return oc1(dw, "stldsr", 2, Imm);
						}
						else
							return -1;
					}
					elif (i.mr <= labs)
						return oc(dw, "move", 2), print("sr,"), ea(dw, i.mr);
				}
				elif (i.r1 eq 1 and (z mach or z coldfire))   /* and m1 eq 3 */
					/* 0100 001 01 1xxx xxx move ccr,xx */
					if (d_alt(i.mr) and !(z coldfire and i.m))
						return oc(dw, "move", 2), print("ccr,"), ea(dw, i.mr);
					else ;
				elif (i.r1 eq 5)	  /* and m1 eq 3 */
					/* 0100101011xxxxxx tas xx */
					if (i.mr <= labs)
						if (!(z coldfire and i.m eq 0))
							return oc1(dw, "tas", 1, i.mr);
						else ;
					elif (i.mr eq 074)
						/* 0100101011111100 illegal */
						if (*z cg->illegal)
							return oc0(dw, z cg->illegal, 1), eafail;
						else ;
					else ;
				elif (i.r1 >= 2)    /* and m1 eq 3 */
					/* 0100010011xxxxxx move xx,ccr	*/
					/* 0100011011xxxxxx move xx,sr	*/
					if (z coldfire and i.m ne ddir and i.mr ne Imm)
						return -1;
					elif (i.mr <= Imm)
						return	oc1(dw, "move", 2, i.mr),
								print((i.r1 eq 2) ? ",ccr" : ",sr"),
								eafail;
			}
			elif (z coldfire and i.m eq 1)
				if (i.r eq 0)
					return oc0(dw, "halt",  1), 0;
				elif (i.r eq 4)
					return oc0(dw, "pulse",  1), 0;
				else
					return -1;
		esac
		case 4:
			if (i.m1 eq 0)
				/* 0100100000xxxxxx nbcd xx */
				if (d_alt(i.mr))
					if (!z coldfire)
						return oc1(dw, "nbcd", 1, i.mr);
					else ;
				elif (z mach and i.m eq 1)
					return oc2l(dw, "link", 4, i.mr, Imm);
				else ;
			elif (i.m1 eq 1)
				if (c_add(i.mr))
				{	/* 0100100001xxxxxx pea xx */
					oc1(dw, "pea", 1, i.mr);
					if (i.mr eq labs)
						if (rel(dw, z pc.b-4) eq rel(dw, z pc.b-3))
							trap_id(dw, z pc.u, *(z pc.u-2));
					return eafail;
				}
				elif (i.m eq 0)	/* 0100100001000xxx swap dx */
					return oc1(dw, "swap", 1, i.r);
				elif (i.m eq 1 and z mach)
					return oc(dw, "bkpt", 1), *pos++ = '#', prdec(i.r), eafail;
				else ;
			elif (i.m1 < 4)
				if (i.m eq 0)		/* 0100 1000 1s00 0xxx ext dx */
					return oc1l(dw, "ext", (i.m1-1)*2, i.r);
				elif (i.m > 1 and i.m ne 3 and i.mr <= labs)
								/* 0100 100 01s xxx xxx movem regs,xx */
					if (btst(z dt, i.pc.b-z org.b))
						return 997;
					elif (     z coldfire
					    and (   (    i.m  ne 2
					             and i.m  ne 5
					            )
					         or i.m1 eq 2
					        )
					   )
						return 997;
					else
					{
						ocl(dw, "movem", (i.m1-1)*2);
						reglist(dw, *i.pc.u, i.m);
						z pc.u = ++i.pc.u;
						return ea2(dw, i.mr);
					}
		esac
		case 6:
			if (i.m1 eq 0)			/* TT muls.l mulu.l */
			{
				uint ttx;
				if (!(    (z mach or z coldfire)
				      and d_add(i.mr)
				      and (*i.pc.w&0101770) eq 0 ) )		return 996;
				if (z coldfire and i.mr >= DindX)
					return -1;
				ttx = *i.pc.u;
				z pc.u = ++i.pc.u;
				oc1l(dw, BTST(ttx, 11) ? "muls" : "mulu", 4, i.mr);
				if (BTST(ttx, 10))
					if (z coldfire)
						return -1;
					else
						return ea2(dw, ttx&7), ea2d(dw, ttx>>12);	/* Dh, Di */
				else
					return ea2(dw, ttx>>12);			/* Di only */
			}
			elif (i.m1 eq 1)			/* TT divs.l divsl.l, divu.l divul.l */
			{
				uint ttx, ttq, ttr;
				if (!(    (z mach or z coldfire)
				      and d_add(i.mr)
				      and (*i.pc.w&0101770) eq 0) )	  return 995;
				if (z coldfire and BTST(*i.pc.u, 10)) return 995;
				ttx = *i.pc.u;
				z pc.u = ++i.pc.u;
				ttq = (ttx>>12)&7;
				ttr = ttx&7;
				if (BTST(ttx, 11))
					if (BTST(ttx, 10))
						oc2l(dw, "divs", 4, i.mr, ttr), ea2d(dw, ttq);
					else
						if (ttr ne ttq)
							oc2l(dw, z coldfire ? "rems" : "divsl",  4, i.mr, ttr), ea2d(dw, ttq);
						elif (z coldfire and i.mr >= DindX)
							return -1;
						else
							oc2l(dw, "divs", 4, i.mr, ttr);
				else
					if (BTST(ttx, 10))
						oc2l(dw, "divu", 4, i.mr, ttr), ea2d(dw, ttq);
					else
						if (ttr ne ttq)
							oc2l(dw, z coldfire ? "remu" : "divul",  4, i.mr, ttr), ea2d(dw, ttq);
						elif (z coldfire and i.mr >= DindX)
							return -1;
						else
							oc2l(dw, "divu", 4, i.mr, ttr);
				return eafail;
			}
			elif (i.m1 < 4)	/* 010011001sxxxxxx movem xx,regs */
			{
				if (z coldfire and i.m eq 0 and i.m1 eq 2)
					return oc1l(dw, "sats", 4, i.mr);

				if (c_add(i.mr) or i.m eq 3)
				{
					uint rl;
					if (btst(z dt, i.pc.b-z org.b))
						return 994;
					if (     z coldfire
					    and (   (    i.m  ne 2
					             and i.m  ne 5
					            )
					         or i.m1 eq 2
					        )
					   )
						return 997;

					rl = *i.pc.u;
					z pc.u = ++i.pc.u;
					oc1l(dw, "movem", (i.m1-1)*2, i.mr);
					*pos++ = ',';
					reglist(dw, rl, i.m);
					return eafail;
				}
			}
		esac
		case 7:
			if (i.m1 eq 1)
				if (i.mr < 020)	/* 010011100100xxxx trap #x */
				{
					oc(dw, "trap", 1);
					*pos++ = '#';
					prdec(i.mr);
					if (i.mr eq 1)
						tab(dw, z t4), print("; Gemdos");
					elif (i.mr eq 2)
						tab(dw, z t4), print("; VDI/AES");
					elif (i.mr eq 13)
						tab(dw, z t4), print("; Bios");
					elif (i.mr eq 14)
						tab(dw, z t4), print("; Xbios");
					return eafail;
				}
				elif (i.mr < 030)	/* 0100111001010xxx link ax,#n */
				{
					if ((-*i.pc.u&0x8001) ne 0 and relo(dw, i.pc) ne 4)
						return 993;
					return oc2(dw, "link", 2, i.r+adir, Imm);
				}
				elif (i.mr < 040)		/* 0100111001011xxx unlk ax */
					return oc1(dw, "unlk", 0, i.r+adir);
				elif (i.mr < 050)		/* 0100111001100xxx move ax,usp */
					return oc1(dw, "move", 0, i.r+adir), print(",usp"), eafail;
				elif (i.mr < 060)		/* 0100111001101xxx move usp,ax */
					return oc (dw, "move", 0), print("usp,"), ea(dw, i.r+adir);
				elif (i.mr eq 060)	/* 0100111001110000 reset */
					return oc0(dw, "reset", 0), eafail;
				elif (i.mr eq 061)	/* 0100111001110001 nop */
					return oc0(dw, "nop", 0), eafail;
				elif (i.mr eq 062)	/* 0100111001110010 stop #n */
					return oc1(dw, "stop", 2, Imm);
				elif (i.mr eq 063)	/* 0100111001110011 rte */
					return oc0(dw, "rte", 0), z openline = 1, eafail;
				elif (i.mr eq 064 and z mach)	/* 0100111001110100 rtd */
					return z openline = 1, oc1(dw, "rtd", 2, Imm);
				elif (i.mr eq 065)	/* 0100111001110101 rts */
					return oc0(dw, "rts", 0), z openline = 1, eafail;
				elif (i.mr eq 066)	/* 0100111001110110 trapv */
					if (!z coldfire)
						return oc0(dw, "trapv", 0), eafail;
					else;
				elif (i.mr eq 067)	/* 0100111001110111 rtr */
					return oc0(dw, "rtr", 0), z openline = 1, eafail;
				elif (i.mr eq 072 and z mach)
				{
					uint ttx = *i.pc.u;
					z pc.u = ++i.pc.u;
					oc(dw, "movec", 0);
					ccrr(ttx&0xfff, z mach);
					ea2(dw, ttx>>12);
					return eafail;
				}
				elif (i.mr eq 073)
				{
					if (z mach)
					{
						uint ttx = *i.pc.u;
						z pc.u = ++i.pc.u;
						oc1(dw, "movec", 0, ttx>>12);
						*pos++ = ',';
						ccrr(ttx&0xfff, z mach);
						return eafail;
					}
					if (z coldfire)
					{
						uint ttx = *i.pc.u;
						z pc.u = ++i.pc.u;
						oc1(dw, "movec", 0, ttx>>12);
						*pos++ = ',';
						ccrrcf(ttx&0xfff);
						return eafail;
					}
				}
				elif (z mach&MC020)		/*  020 */
					return z openline = 1, oc1(dw, "rtm", 0, i.r+adir);
				else ;
			elif (c_add(i.mr))
				if (i.m1 eq 2)
					return oc1(dw, "jsr", 2, i.mr);
				elif (i.m1 eq 3)
					return z openline = 1, oc1(dw, "jmp", 2, i.mr);
		esac
		} /* end switch i.r1 */
	}
	elif(z mach and i.m1 eq 4 and d_add(i.mr))	/* 0100yyy100xxxxxx chk.l xx,dy */
		return oc2l(dw, "chk", 4, i.mr, i.r1);
	elif (i.m1 eq 6 and d_add(i.mr))				/* 0100yyy110xxxxxx chk xx,dy */
		return oc2l(dw, "chk", 2, i.mr, i.r1);
	elif (i.m1 eq 7)
		if (i.m eq 0 and i.r1 eq 4 and (z mach or z coldfire))
			return oc1l(dw, "extb", 4, i.r);
		elif (c_add(i.mr))
			return oc2(dw, "lea ", 1, i.mr, i.r1+adir);
	return -1;
}