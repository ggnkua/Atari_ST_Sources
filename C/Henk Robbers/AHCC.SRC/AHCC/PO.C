/* Copyright (c) 2004 - present by H. Robbers.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*  output Pure C object file in stead of 68K assembler text
*/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "param.h"

#include "opt.h"
#include "out.h"
#include "reg.h"
#include "po.h"
#include "plib.h"

char *pclass(short area);

#pragma warn -aus

o_A o_MOV { o_move_eaea(ip); }
o_A o_LDX { o_move_eadn(ip, false); }
o_A o_M3Q
{
	if (ip->arg) if (ip->arg->next)
	{
		OPND *dst = ip->arg->next;
		if (op_dreg(dst))
		{
#if OPTBUG
			console("[%ld] m3q --> Dn\n", ip->snr);
#endif
			ip->reg = dst->areg;
			ip->opcode = LDX;
			ip->arg->next = nil;
			o_LDX(ip);
			return;
		}
	}
	o_move_eaea(ip);
}

void o_bf(IP ip, ushort w1)
{
	OPND *arg = ip->arg;
	ushort w2;
	w1 |= o_ea(arg);
	advance(w1);
	w2  =  arg->fldw & 037;
	w2 |= (arg->fldo & 037) << 6;
	w2 |= (ip->reg &7 ) << 12;
	advance(w2);
	o_ext(ip, arg, 0);
}

o_A o_LDBS { o_bf(ip, 0165700); }
o_A o_LDBU { o_bf(ip, 0164700); }
o_A o_STB  { o_bf(ip, 0167700); }

void o_bit(IP ip, ushort w1)
{
	OPND *arg = ip->arg;
	w1 |= o_ea(arg);
	w1 |= (ip->reg&7)<<9;
	advance(w1);
	o_ext(ip, arg, 0);
}

o_A o_BSET { o_bit(ip, 000700); }
o_A o_BCLR { o_bit(ip, 000600); }

static
void o_mvq(IP ip)
{
	ushort w1 = 0070000;

	w1 |= (ip->reg & 7) << 9;			/* moveq #0,Dn */
	advance(w1);
	o_move_eadn(ip, false);
}

o_A o_EXX
{
	ushort w1 = 0044000;

	w1 |= o_X(ip);
	w1 |=    ip->sz eq DOT_W
	       ? 0200
	       : (  ip->sz eq DOT_L
	          ? 0300
	          : 0700			/* DOT_B = extb.l */
	         );
	advance(w1);
}

static
void o_mvsz(IP ip, ushort w1)
{
	if (ip->sz eq DOT_W)
		w1 |= 0100;
	w1 |= (ip->reg & 7) << 9;
	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}

o_A o_MVZ		/* unsigned extend byte or word to long */
{
#if COLDFIRE
	if (G.Coldfire and !G.i2_68020)
		o_mvsz(ip, 0070600);
	else
#endif
	if (ip->rref & RM(ip->reg))		/* if the mvz references target reg */
	{								/* we cannot zeroize the reg beforehand */
		ushort w1 = 0140274;		/* and Dn, #mask */

		o_move_eadn(ip, false);

		w1 |= (ip->reg & 7) << 9;
		advance(w1);
		if (ip->sz eq DOT_B)
			advance_l(0x00ff);
		else
			advance_l(0xffff);
	}
	else
		o_mvq(ip);
}

o_A o_WMVZ		/* unsigned extend byte to word */
{
	if (ip->rref & RM(ip->reg))		/* if the wmvz references target reg */
	{								/* we cannot zeroize the reg beforehand */
		ushort w1 = 0140074;		/* and.S Dn, #mask */

		o_move_eadn(ip, false);

		w1 |= (ip->reg &7) << 9;
#if COLDFIRE
		if (G.Coldfire)
		{
			w1 |= 0200;
			advance(w1);
			advance_l(0xff);
		}
		else
#endif
		{
			w1 |= 0100;
			advance(w1);
			advance(0xff);
		}
	}
	else
		o_mvq(ip);
}

o_A o_WMVS			/* move.b <ea>,Dn  ext.w Dn */
{
	ushort w1 = 0044200;

	w1 |= ip->reg & 7;

	if (!(    MO(ip->arg->am) eq REG
	      and ip->arg->areg eq ip->reg)
	   )
		o_move_eadn(ip, false);

	advance(w1);
}

o_A o_MVS		/* extend byte or word to long */
{
#if COLDFIRE
	if (G.Coldfire and !G.i2_68020)
		o_mvsz(ip, 0070400);
	else
#endif
	{
		ushort w1 = 0044000;

		w1 |= ip->reg & 7;

		if (!(    MO(ip->arg->am) eq REG
		      and ip->arg->areg eq ip->reg)
		   )
			o_move_eadn(ip, false);

		if (ip->sz eq DOT_B)
		{
#if FLOAT || COLDFIRE
			if (G.i2_68020 or G.Coldfire)
			{
				advance(w1|0700);		/* extb.l */
				return;
			}

#endif
			advance(w1|0200);		/* ext.w */
		}

		advance(w1|0300);		/* ext.l */
	}
}

global
void change_disp(OPND *op, long adjust)
{
	op->disp += adjust;
	if (op->disp and MO(op->am) eq REGI)
		MO(op->am) = REGID;
	elif (op->disp eq 0 and MO(op->am) eq REGID)
		MO(op->am) = REGI;
}

o_A o_FASN			/* assign double mem to mem; 2 or 3 move.l +0, +4, +8 */
{
	short sz = ip->sz;
	ip->sz = DOT_L;
	o_MOV(ip);
	if (sz > DOT_L)		/* 06'11 HR also for fasn.s */
	{
		change_disp(ip->arg,       DOT_L);
		change_disp(ip->arg->next, DOT_L);
		o_MOV(ip);
		if (sz eq DOT_X)
		{
			change_disp(ip->arg,       DOT_L);
			change_disp(ip->arg->next, DOT_L);
			o_MOV(ip);
		}
	}
}

o_A o_STO
{
	ushort w1;
	short sz = ip->sz;

#if FLOAT
	if (is_f(ip))
		o_cpgens(ip, 0);
	else
#endif
	{
		w1  = o_move(sz);
		w1 |= o_src_X(ip);
		w1 |= o_dst_ea(ip->arg);
		advance(w1);
		o_ext(ip, ip->arg, sz);
	}
}

o_A o_ORS { o_arith (ip, 0100400, -1,  -1,   true ); }
o_A o_SBX { o_Qarith(ip, 0110000, 050, IN_X, 0050400); }
o_A o_SBS { o_Qarith(ip, 0110400, 050, TO_S, true ); }
o_A o_ANS { o_arith (ip, 0140400, -1,  -1,   true ); }
o_A o_ERS { o_arith (ip, 0130400, -1,  -1,   true ); }
o_A o_ADX { o_Qarith(ip, 0150000, 042, IN_X, 0050000); }
o_A o_ADS { o_Qarith(ip, 0150400, 042, TO_S, true ); }

o_A o_ADJ { o_ADX(ip); }
o_A o_SDJ { o_SBX(ip); }

static
void bitsand(IP ip)
{
	if (G.Coldfire and ip->sz < DOT_L)
	{
		if (MM(ip->arg->am) eq IMM)
			(ulong)ip->arg->disp &= ip->sz eq DOT_B ? 0xffL : 0xffffL;

		ip->sz = DOT_L;
	}
}

o_A o_ORX
{
#if COLDFIRE
	bitsand(ip);
#endif
	o_arith (ip, 0100000, -1,  -1,   true );
}
o_A o_ANX
{
#if COLDFIRE
	bitsand(ip);
#endif
	o_arith (ip, 0140000, -1,  -1,   true );
}

o_A o_ERX
{
#if COLDFIRE
	bitsand(ip);
#endif
	if (MO(ip->arg->am) eq IMM)
	{
		ushort w1 = 0005000;

		w1 |= ip->reg & 7;
		w1 |= o_size(ip);
		advance(w1);
		o_ext(ip, ip->arg, ip->sz);
	othw
		ushort w1 = 0130400;

		w1 |= (ip->arg->areg & 7) <<9;
		w1 |=  ip->reg & 7;
		w1 |= o_size(ip);
		advance(w1);
	}
}

o_A o_MPX
{
#if COLDFIRE || FLOAT
	if (    ip->sz eq DOT_L
	#if FLOAT
	    and !is_f(ip)
	#endif
	   )
		o_Lmd(ip, 0046000, 2, 1);
	else
#endif
		o_arith (ip, 0140700, 043, IN_X, false);
}

o_A o_UMPX
{
#if COLDFIRE || FLOAT
	if (    ip->sz eq DOT_L
	#if FLOAT
	    and !is_f(ip)
	#endif
	   )
		o_Lmd(ip, 0046000, 0, 1);
	else
#endif
		o_arith (ip, 0140300, 043, IN_X, false);
}

o_A o_SCX		/* special int*int=long */
{
	o_arith (ip, 0140700, 043, IN_X, false);
}

o_A o_USCX		/* special int*int=long */
{
	o_arith (ip, 0140300, 043, IN_X, false);
}

o_A o_DVX
{
#if COLDFIRE || FLOAT
	if (    ip->sz eq DOT_L
	#if FLOAT
	    and !is_f(ip)
	#endif
	   )
		o_Lmd(ip, 0046100, 2, 1);
	else
#endif
		o_arith (ip, 0100700, 040, IN_X, false);
}

o_A o_UDVX
{
#if COLDFIRE || FLOAT
	if (    ip->sz eq DOT_L
	#if FLOAT
	    and !is_f(ip)
	#endif
	   )
		o_Lmd(ip, 0046100, 0, 1);
	else
#endif
		o_arith (ip, 0100300, 040, IN_X, false);
}

o_A o_MDX  { o_DVX (ip); }
o_A o_UMDX { o_UDVX(ip); }

#if COLDFIRE || FLOAT
o_A o_RMX { o_Lmd(ip, 0046100, 2, 0); }
o_A o_URMX{ o_Lmd(ip, 0046100, 0, 0); }
#endif

o_A o_CPX
{
	ushort w1 = 0130000;
	if (ISA(ip->reg))
	{
		w1 |= ip->sz eq DOT_W ? 0300 : 0700;
		o_arith(ip, w1, 0, -1, false);
	}
	else
		o_arith(ip, w1, 070, -1, true);
}

o_A o_ORI { o_imm (ip, 0000000); }
o_A o_ANI { o_imm (ip, 0001000); }
o_A o_ERI { o_imm (ip, 0005000); }

o_A o_CPI
{
	if (ISAA(ip->arg->next))
		o_imma(ip, 0130000);
	else
		o_imm (ip, 0006000);
}
o_A o_SBI
{
	if (ISAA(ip->arg->next))
		o_imma(ip, 0110000);
	else
		o_Qimm(ip, 0002000, 0050400);
}
o_A o_ADI
{
	if (ISAA(ip->arg->next))
		o_imma(ip, 0150000);
	else
		o_Qimm(ip, 0003000, 0050000);
}

o_A o_LAX
{
	ushort w1 = 0040700;

	w1 |= o_dst_X(ip);
	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}
o_A o_LAA { o_LAX(ip); }

o_A o_LMX
{
	short am = MM(ip->arg->am);
	if (am eq IMM)
		console("Internal error: lmx IMM");
	if (am eq REG)
		console("Internal error: lmx REG");
	o_LAX(ip);
}

o_A o_NGX { o_genx(ip, 0042000, 032); }
o_A o_NGS { o_gens(ip, 0042000, 032); }
o_A o_NOX { o_genx(ip, 0043000, -1 ); }
o_A o_NOS { o_gens(ip, 0043000, -1 ); }
o_A o_TSX { o_genx(ip, 0045000, 072); }
o_A o_TST
{
	if (ip->arg and MO(ip->arg->am) eq REG)
	{
		ip->reg = ip->arg->areg;
		ip->arg = nil;
		o_genx(ip, 0045000, 072);
	}
	else
		o_gens(ip, 0045000, 072);
}

static
void o_CLA(IP ip)
{
	ushort w1 = 0110710;
	w1 |= o_X(ip);
	w1 |= o_X(ip) << 9;			/* suba.l An,An */
	advance(w1);
}

o_A o_CLX
{
	if (ISA(ip->reg))
		o_CLA(ip);
	else
		o_genx(ip, 0041000, -1);
}

o_A o_CLS
{
	OPND *arg = ip->arg;
	if (arg and MO(arg->am) eq REG)
	{
		ip->reg = arg->areg;
#if OPTBUG
		ip->arg = nil;
		ip->opcode++;
#endif
		if (ISA(ip->reg))
			o_CLA(ip);
		else
			o_genx(ip, 0041000, -1);
	}
	else
		o_gens(ip, 0041000, -1);
}

o_A o_PEA
{
	ushort w1 = 0044100;					/* <c_add> */

	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}

static
bool is_0_psh(OPND *op)
{
	return  op ne nil
		and MM(op->am) eq IMM
#if AMFIELDS
		and op->am.f.symb eq 0
#else
		and (op->am & SYMB) eq 0
#endif
		and op->disp eq 0;
}

static
o_A o_push
{
	ushort w1;

	if (is_0_psh(ip->arg))
	{
		w1 = 0041047;
		w1 |= o_size(ip);
		advance(w1);
	othw
		w1 = o_move(ip->sz);
		w1 |= 07400;
		w1 |= o_ea(ip->arg);
		advance(w1);
		o_ext(ip, ip->arg, ip->sz);
	}
}

o_A o_PSH
{
#if FLOAT
	if (is_f(ip))
	{
		ip->reg = ip->arg->areg;		/* we know it can only be fp register */
		MO(ip->arg->am) = REGI;
#if AMFIELDS
		ip->arg->am.f.dec = 1;
#else
		ip->arg->am |= DEC;
#endif
		ip->arg->areg = SP;
		o_cpgens(ip, 0);
	}
	else
#endif
		o_push(ip);
}

#if FLOAT
o_A o_FPSH					/* push fp memory */
{
	if (ip->sz eq DOT_X)
	{
		ip->sz = DOT_L;
		change_disp(ip->arg, 2*DOT_L);
		o_push(ip);
		change_disp(ip->arg, -DOT_L);
		o_push(ip);
		change_disp(ip->arg, -DOT_L);
		o_push(ip);
	othw
		ip->sz = DOT_L;
		change_disp(ip->arg, DOT_L);
		o_push(ip);
		change_disp(ip->arg, -DOT_L);
		o_push(ip);
	}
}
#endif

o_A o_PLL
{
	ushort w1;

#if FLOAT
	if (is_f(ip))
		o_cpgenx(ip, 0);
	else
#endif
	{
		w1 = o_move(ip->sz);
		w1 |= 037;
		w1 |= o_dst_ea(ip->arg);
		advance(w1);
	}
	o_ext(ip, ip->arg, ip->sz);
}

o_A o_PLA
{
	ushort w1;
	short sz = ip->sz;

#if FLOAT
	if (is_f(ip))
	{
		advance(0171037);		/* fmove (sp)+ .... */
#if COLDFIRE
		if (G.Coldfire)			/* 02'12 HR */
			w1  =   0052000;		/* .d				*/
		else
#endif
			w1  =   0044000;		/* .x				*/
		w1 |= o_X(ip) << 7;		/* ....         FPn */
	}
	else
#endif
	{
		w1  = o_move(sz);
		w1 |= 037;				/* (sp)+ */
		w1 |= o_dst_X(ip);
		if (ISA(ip->reg))
			w1 |= 0100;
	}
	advance(w1);
}

o_A o_SVA { o_STO(ip); }

o_A o_SWX
{
	ushort w1 = 0044100;

	w1 |= o_X(ip);
	advance(w1);
}

static
short bit_count(RMASK r)
{
	short c = 0;
	do
		if (r&1)
			c++;
	while ( (r >>= 1) ne 0);
	return c;
}

static
short bit_to_reg(RMASK r)
{
	short x = 0;
	do
	{
		if (r&1)
			break;
		x++;
	}
	while ( (r >>= 1) ne 0);

	return x;
}

static
ushort flip(ushort m)
{
	short i;
	ushort n = 0;
	for (i=0; i<8; i++)
	{
		n <<= 1;
		n |= m&1;
		m >>= 1;
	}
	return n;
}

o_A o_MMS
{
	OPND *arg = ip->arg;
	ushort w1 = 0, w2 = 0, nd, nf;
	RMASK m, f, d;

	if (MO(arg->am) eq ABS)
		m = loclist;			/* ex reg instruction */
	else
		m =  MO(arg->am) eq RLST
		   ? s_to_mask(arg->astr)
		   : arg->disp;

	f = m & 0x00ff00;
	nf = bit_count(f);

	if (nf)
	{
		if (nf eq 1)
		{
			short x = bit_to_reg(f);
			advance(0171047);
			w2  =
#if COLDFIRE
				G.Coldfire ? 0072000 :
#endif
				0064000;

			w2 |= (x - FREG) << 7;
		othw
#if COLDFIRE
			if (G.Coldfire)
			{
				advance(047757);		/* lea -d(sp), sp */
				advance(-nf*DOT_X);		/* DOT_X is large enough and comapatible */
				advance(0171027);		/* fmovem.d #m, (sp) */
				w2  = 0170000;			/* 11'10 HR */
				w2 |= flip(f >> 8);
			}
			else
#endif
			{
				advance(0171047);
				w2  = 0160000;
				w2 |= f >> 8;
			}
		}

		advance(w2);
	}

	d = m & 0xff00ff;
	nd = bit_count(d);

	if (nd)
	{
		if (nd eq 1)
		{
			short x = bit_to_reg(d);
			w1 = 0027400;
			w1 |= ISA(x) ? 010|(x-AREG) : 000|x;
			advance(w1);
		othw
#if COLDFIRE
			if (G.Coldfire)
			{
				advance(0047757);		/* lea -d(sp), sp */
				advance(-nd*DOT_L);
				advance(0044327);		/* movem.l	#m, (sp) */
				w2 = (d&0xff)|(d>>8);	/* squeeze out fregs (no flip :-) */
			}
			else
#endif
			{
				advance(0044347);
				w2 = (flip(d & 0xff) << 8) | flip(d >> 16);	/* flip & squeeze out fregs */
			}

			advance(w2);
		}
	}
}

o_A o_MMX
{
	OPND *arg = ip->arg;
	ushort w1 = 0, w2 = 0, nd, nf;
	RMASK m, f, d;

	if (MO(arg->am) eq ABS)
		m = loclist;			/* ex reg instruction */
	else
		m =   MO(arg->am) eq RLST
		    ? s_to_mask(arg->astr)
		    : arg->disp;

	d = m & 0xff00ff;
	nd = bit_count(d);

	if (nd)
	{
		if (nd eq 1)
		{
			short x = bit_to_reg(d);
			w1 = 0020037;
			w1 |= ISA(x) ? ((x-AREG)<<9)|0100 : (x<<9)|0000;
			advance(w1);
		othw
#if COLDFIRE
			if (G.Coldfire)
			{
				advance(0046327);		/* movem.l	(sp), #m */
				advance((d&0xff)|(d>>8));	/* squeeze out fregs */
				advance(0047757);		/* lea d(sp), sp */
				advance(nd*DOT_L);
			}
			else
#endif
			{
				advance(0046337);
				advance((d&0xff)|(d>>8));	/* squeeze out fregs */
			}
		}
	}

	f = m & 0x00ff00;
	nf = bit_count(f);

	if (nf)
	{
		if (nf eq 1)
		{
			short x = bit_to_reg(f);
			advance(0171037);
			w2  =
#if COLDFIRE
				G.Coldfire ? 0052000 :
#endif
				0044000;

			w2 |= (x - FREG) << 7;
			advance(w2);
		othw
#if COLDFIRE
			if (G.Coldfire)
			{
				advance(0171027);		/* fmovem.d (sp), #m */
				w2  = 0150000;
				w2 |= flip(f >> 8);
				advance(w2);
				advance(047757);		/* lea d(sp), sp */
				advance(nf*DOT_X);		/* DOT_X is large enough and comapatible */
			}
			else
#endif
			{
				advance(0171037);
				w2  = 0150000;
				w2 |= flip(f >> 8);
				advance(w2);
			}
		}
	}
}

o_A o_TSP
{
	if (ISAA(ip->arg))
	{
		ushort w1 = 0130374;		/* cmpa #0, an */
		w1 |= (ip->arg->areg - AREG)<<9;
		advance(w1);
		advance(0);
	}
	else
		o_TST(ip);
}

o_A o_LKX
{
	ushort w1 = 0047120;

	w1 |= o_X(ip);
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}


o_A o_ULX
{
	ushort w1 = 0047130;

	w1 |= o_X(ip);
	advance(w1);
}

o_A o_RTS
{
	advance(047165);
}

o_A o_RTAD		/* cdecl or G.h_cdecl_calling */
{
	advance(0020010);		/* move.l a0,d0 */
	o_RTS(ip);
}

o_A o_RTA { o_RTS(ip); }
o_A o_RTF { o_RTS(ip); }
o_A o_RTV { o_RTS(ip); }

o_A o_BSR
{
	advance(0060400);
	o_fixup(ip->arg->astr, ip->arg->areg, FIX_wbra, ip->arg->tlab);
	advance(0);
}

o_A o_JSL { o_jump(ip, 0047200); }

void o_call(IP ip)
{
	OPND *dst = ip->arg->next;
	short i = 0;
	ushort w1;

	if (dst)
		if (  MO(dst->am) eq IMM)
			i = dst->disp;
		elif (MO(dst->am) eq ABS)
			i = atoi(dst->astr);

	if (i)
	{
		if (i <= 8)
		{
			w1 = 0050217;		/* addq.l #i,sp */	/* 01'10 HR .l */
			w1 |= (i&7)<<9;
			advance(w1);
		}
		else
		{
			w1 = 0047757;		/* lea i(sp),sp */
			advance(w1);
			advance(i);
		}
	}
}

o_A o_INLV { advance(ip->arg->disp); }

o_A o_JSR
{
	AREA *ar;
	if (    MO(ip->arg->am) eq ABS
		and (ar = try_bsr(P.fbase.first, P.area_now, ip->arg->astr)) ne nil
	   )
	{
		ip->arg->areg = ar->id;
	   	o_BSR(ip);
	}
	else
		o_jump(ip, 0047200);
	o_call(ip);
}

o_A o_TRAP
{
	ushort w1 = 0047100;

	w1 |= ip->arg->disp & 15;
	advance(w1);
	o_call(ip);
}

o_A o_JMP { o_jump(ip, 0047300); }

o_A o_ASRX { o_shiftx(ip, 0160000); }
o_A o_ASRS { o_shifts(ip, 0160000); }
o_A o_ASLX { o_shiftx(ip, 0160400); }
o_A o_ASLS { o_shifts(ip, 0160400); }

o_A o_LSRX { o_shiftx(ip, 0160010); }
o_A o_LSRS { o_shifts(ip, 0160010); }
o_A o_LSLX { o_shiftx(ip, 0160410); }
o_A o_LSLS { o_shifts(ip, 0160410); }

/* rox, just for completeness (not generated yet) */
o_A o_RXRX { o_shiftx(ip, 0160020); }
o_A o_RXRS { o_shifts(ip, 0160020); }
o_A o_RXLX { o_shiftx(ip, 0160420); }
o_A o_RXLS { o_shifts(ip, 0160420); }

/* 03'09 rotate (for __SWPL__ & __SWPW__) */
o_A o_RORX { o_shiftx(ip, 0160030); }
o_A o_RORS { o_shifts(ip, 0160030); }
o_A o_ROLX { o_shiftx(ip, 0160430); }
o_A o_ROLS { o_shifts(ip, 0160430); }

void o_shiftcount(IP ip)
{
	OPND *dst = ip->arg->next;
	if (dst->disp <= 8)
	{
		ip->arg = dst;				/* direct shift */
	othw
		ushort w1 = 0070000;		/* moveq */
		w1 |= ip->arg->areg << 9;
		w1 |= dst->disp;
		advance(w1);				/* shift indirect */
	}
}
/* 11'10 field shift instructions.
   because no bits are shifted into or out of scope, these shifts
   can be omitted or deleted before BEQ or BNE */
o_A o_FLX
{
	o_shiftcount(ip);
	o_LSRX(ip);
}

o_A o_FLD			/* undisposable FLX */
{
	o_FLX(ip);
}

o_A o_LFLX
{
	o_shiftcount(ip);
	o_LSLX(ip);
}

o_A o_LFLD			/* shift signed bitfield left for sign extension */
{
	o_LFLX(ip);
}

o_A o_AFLD 			/* sign extend signed bitfield and shift into position */
{
	o_shiftcount(ip);
	o_ASRX(ip);
}

static
void o_scc(IP ip, ushort cc)
{
	ushort w1 = 0050300;

	w1 |= cc<<8;
	w1 |= o_X(ip);			/* Only Scc Dn is generated by compiler */
	advance(w1);
}

o_A o_SHI { o_scc(ip, 002); }
o_A o_SLS { o_scc(ip, 003); }
o_A o_TSCC { o_scc(ip, 004); }
o_A o_SCS { o_scc(ip, 005); }
o_A o_SNE { o_scc(ip, 006); }
o_A o_SEQ { o_scc(ip, 007); }
o_A o_SGE { o_scc(ip, 014); }
o_A o_SLT { o_scc(ip, 015); }
o_A o_SGT { o_scc(ip, 016); }
o_A o_SLE { o_scc(ip, 017); }
o_A o_DBF			/* only dbf generated is 'dbf dn,*-2' for struct assign */
{
	ushort w1 = 0050710;

	w1 |= o_X(ip);
	advance(w1);
	advance(-4);
}

o_A o_LDCT			/* load count; only #imm operand, generated for struct assign */
{
#if COLDFIRE
	if (G.Coldfire)
		ip->sz = DOT_L;
	else
#endif
		ip->arg->disp -= 1;		/* Uses dbf */

	o_LDX(ip);
}

o_A o_BCT			/* only bct generated is 'bct dn,*-2' for struct assign */
{
#if COLDFIRE
	if (G.Coldfire)
	{
		ushort w1 = 0051600;	/* subq.l	#1, Dn */

		w1 |= o_X(ip);
		advance(w1);
		advance(0063372);		/* bne		*-6  */
	}
	else
#endif
		o_DBF(ip);			/* dbf is more efficient also due to 68K loop mode */
}

static
void o_cpscc(IP ip, short cp, short cc)
{
	ushort w1 = 0170100;

	w1 |= o_X(ip);		/* compiler only generates Dn */
	w1 |= cp << 9;
	advance(w1);
	advance(cc);
}

o_A o_FSEQ { o_cpscc(ip, 1, 001); }
o_A o_FSNE { o_cpscc(ip, 1, 016); }
o_A o_FSGT { o_cpscc(ip, 1, 022); }
o_A o_FSGE { o_cpscc(ip, 1, 023); }
o_A o_FSLT { o_cpscc(ip, 1, 024); }
o_A o_FSLE { o_cpscc(ip, 1, 025); }

o_A o_SWT			/* 03'11 HR: use size */
{
	if (ip->sz eq DOT_L)
	{
		advance(0162600);		/* asl.l  #2,d0          */
		advance(0020173);		/* move.l 4(pc, d0.l),a0 */
		advance(0004004);
	othw
		advance(0162500);		/* asl.w  #2,d0          */
		advance(0020173);		/* move.l 4(pc, d0.w),a0 */
		advance(0000004);
	}

	advance(0047320);		/* jmp    (a0)           */
}

o_A o_NOP  { advance(0047161); }
o_A o_DISCARD {}				/* 06'16 v5.5 */
o_A o_STOP { advance(0047162); advance(ip->arg->disp); }

void o_statreg(IP ip, ushort w, ushort wx)
{
	w |= o_ea(ip->arg);
	advance(w);
	if (wx)
		advance(wx);
	o_ext(ip, ip->arg, ip->sz);
}

o_A o_LDSR { o_statreg(ip, 0040300, 0); }			/* move SR,<ea> */
o_A o_STSR { o_statreg(ip, 0043300, 0); }			/* move <ea>,SR */
o_A o_LDCR { o_statreg(ip, 0041300, 0); }			/* move CCR,<ea> */
o_A o_STCR { o_statreg(ip, 0042300, 0); }			/* move <ea>,CCR */

#if FLOAT
/* 11'11 HR */
o_A o_LDFCR { o_statreg(ip, 0171000, 0130000); }	/* fmove FPCR,<ea> */
o_A o_STFCR { o_statreg(ip, 0171000, 0110000); }	/* fmove <ea>,FPCR */
o_A o_LDFSR { o_statreg(ip, 0171000, 0124000); }	/* fmove FPSR,<ea> */
o_A o_STFSR { o_statreg(ip, 0171000, 0104000); }	/* fmove <ea>,FPSR */

o_A o_OACOS  { o_cpgenx(ip, 034); }
o_A o_OASIN  { o_cpgenx(ip, 014); }
o_A o_OATAN  { o_cpgenx(ip, 012); }
o_A o_OATANH { o_cpgenx(ip, 015); }
o_A o_OCOS   { o_cpgenx(ip, 035); }
o_A o_OCOSH  { o_cpgenx(ip, 031); }
o_A o_OETOX  { o_cpgenx(ip, 020); }
o_A o_OETOXM1{ o_cpgenx(ip, 010); }
o_A o_OABS   { o_cpgenx(ip, 030); }
o_A o_OINTRZ { o_cpgenx(ip, 003); }
o_A o_OINT   { o_cpgenx(ip, 001); }		/* 11'11 HR */
o_A o_OGEXP  { o_cpgenx(ip, 036); }
o_A o_OGMAN  { o_cpgenx(ip, 037); }
o_A o_OLOGNP1{ o_cpgenx(ip, 006); }
o_A o_OLOGN  { o_cpgenx(ip, 024); }
o_A o_OLOG10 { o_cpgenx(ip, 025); }
o_A o_OLOG2  { o_cpgenx(ip, 026); }
o_A o_OSIN   { o_cpgenx(ip, 016); }
o_A o_OSINH  { o_cpgenx(ip, 002); }
o_A o_OSQRT  { o_cpgenx(ip, 004); }
o_A o_OTAN   { o_cpgenx(ip, 017); }
o_A o_OTANH  { o_cpgenx(ip, 011); }
o_A o_OTENTOX{ o_cpgenx(ip, 022); }
o_A o_OTWOTOX{ o_cpgenx(ip, 021); }
o_A o_ONEG   { o_cpgenx(ip, 032); }		/* 11'11 HR */
#endif

/* Currently this method of switching uses quite a lot of memory.
   however, it is quite efficient. So I leave it this way for now.
   (It helped that it was a easy implementation ;-)
*/
o_A o_DCS		/* dc.S in switch statements */
{
	FIXUP *f = o_fixup(ip->arg->astr, ip->arg->areg, FIX_labs, 0);
	if (f)
		f->name->ty = 0;	/* turn into permanent label */

	advance_l(0);
}

o_A o_GLOB {}
o_A o_LOCAL {}

o_A o_EVEN
{
	o_even();
}

static
Cstr s_xtol(Cstr ln, long *v)
{
	long n = 0; short c; bool t = false;
	short digits = 0;

	if ( *ln eq '-')
		ln++,
		t = true;

	while ( (c=*ln) ne 0 and digits < 8)
	{
		if   ( c >= '0' and c <= '9')
			n=16*n+(c-'0');
		elif ( c >= 'A' and c <= 'F')
			n=16*n+(c-'A'+10);
		elif ( c >= 'a' and c <= 'f')
			n=16*n+(c-'a'+10);
		else
			break;
		ln++;
		digits++;
	}
	if (t) *v = -n;
	else   *v = n;
	return ln;
}

/* NB!! this code is extremely opportunistic.
        Please keep it that way.
        The compiler output is text because text is human readable,
        NOT because it must be 'human producable' :-)
*/
o_A o_DC
{
	OPND *op = ip->arg;

	if (op->aname)
	{
		operand_fixup(op);
		advance_l(op->disp);
	othw
		long v = 0; char t, tt;
		short sz = ip->sz;

		t  = * op->astr     ;
		tt = *(op->astr + 1);

		if (sz eq DOT_B)
		{
			Cstr s = op->astr;
			if (*s >='1' and *s <= '9')
				advance_b(atoi(s));
			else
				while (*s)
				{
					if (*s eq '\'')
					{
						s++;
						while (*s ne '\'')
							advance_b(*s++);
						s++;
					othw
						s += 2;		/* skip 0x */
						s = s_xtol(s, &v);
						advance_b(v);
					}
					if (*s ne ',')
						break;
					s++;
				}
		othw
			if (sz eq DOT_X)
			{
				Cstr s = op->astr + 1;
				s = s_xtol(s, &v);
				advance_l(v);
				s = s_xtol(s, &v);
				advance_l(v);
				s = s_xtol(s, &v);
				advance_l(v);
			}
			elif (sz eq DOT_LL)		/* also good for DOT_D */
			{
				Cstr s = op->astr + 1;
				s = s_xtol(s, &v);
				advance_l(v);
				s = s_xtol(s, &v);
				advance_l(v);
			othw
				if (t eq '0' and tt eq 'x')
					s_xtol(op->astr + 2, &v);
				elif (t eq '$')
					s_xtol(op->astr + 1, &v);
				elif (t >='0' and t <= '9')
					v = atol(op->astr);
				elif (t eq '-' and (tt >='0' and tt <= '9'))
					v = atol(op->astr);
				elif (sz eq DOT_L)
				{
					operand_fixup(op);
				}

				if   (sz eq DOT_L)
					advance_l(v + op->disp);
				else
					advance(v);
			}
		}
	}
}

o_A o_DS
{
	if (P.area_now)
	{
		long l;

		if (MM(ip->arg->am) eq ABS)
			l = atol(ip->arg->astr);
		else
			l = ip->arg->disp;

		if (no_image(P.area_now->target))
		{
			long pr = P.area_now->limage;
			P.area_now->limage += l * ip->sz;
		othw
			if (l > 0)
			{
				if   (ip->sz eq DOT_L)
					while (l--)
						advance_l(0);
				elif (ip->sz eq DOT_W)
					while (l--)
						advance(0);
				else
					while (l--)
						advance_b(0);
			}
		}
	}
}

o_A o_SLINE {}

o_A o_GPROC
{
	o_AREA(TEXT_class);
	cur_proc = 2;
}
o_A o_SPROC
{
	o_AREA(TEXT_class);
	cur_proc = 1;
}

o_A o_PEND
{
	cur_proc = 0;
}
o_A o_DATA		{	o_AREA(DATA_class);	}
o_A o_GDATA		{	o_AREA(GDATA_class);}
o_A o_BSS		{	o_AREA(BSS_class);	}
o_A o_GBSS		{	o_AREA(GBSS_class);	}
o_A o_CONSTANTS	{	o_AREA(CON_class);	}
o_A o_STRS		{	o_AREA(STR_class);	}
o_A o_TEXT		{	o_AREA(TEXT_class);	}

o_A o_VARD { }
o_A o_VARA { }
o_A o_VARF { }
o_A o_VARX { }

o_A o_BRA{ }
o_A o_BRB{ }
o_A o_BRF{ }
o_A o_BNE{ }
o_A o_BEQ{ }
o_A o_BGE{ }
o_A o_BLT{ }
o_A o_BGT{ }
o_A o_BLE{ }
o_A o_BHI{ }
o_A o_BLS{ }
o_A o_BCC{ }
o_A o_BCS{ }
o_A o_BVC{ }
o_A o_BVS{ }
o_A o_BPL{ }
o_A o_BMI{ }
o_A o_FBNE{ }
o_A o_FBEQ{ }
o_A o_FBGE{ }
o_A o_FBLT{ }
o_A o_FBGT{ }
o_A o_FBLE{ }
o_A o_BEGIN { }
o_A o_LIV{ }
o_A o_END{ }
o_A o_LOOP{ }
o_A o_REGL{ }
o_A o_LOC{ }
o_A o_RGD{ }
o_A o_RGA{ }
o_A o_RGF{ }
o_A o_UPS{ }
o_A o_DNS{ }
