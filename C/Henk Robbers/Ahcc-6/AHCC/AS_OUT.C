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

/*
 * assembler:  ouput the bit patterns of the instructions
 *
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "param.h"

#include "common/amem.h"
#include "opt.h"
#include "out.h"
#include "reg.h"
#include "po.h"
#include "plib.h"
#include "as.h"

char *pclass(short);

#pragma warn -aus

w_A W_end {}

static
AREA *find_code_area(short class)
{
	if (class <= 0 or class >= high_class)
		class = TEXT_class;
	return P.code_std_areas[class];
}

w_A W_text { o_AREA(TEXT_class); P.area_now = find_code_area(class_now); }
w_A W_data { o_AREA(DATA_class); P.area_now = find_code_area(class_now); }
w_A W_bss  { o_AREA(BSS_class);  P.area_now = find_code_area(class_now); }

w_A W_offset
{
	o_AREA(OFFS_class);
	P.area_now = find_code_area(class_now);
	o_area_setup(class_now, ++area_id, "anonymous offset");
}

w_A W_org
{
	long org = ip->arg->disp;
	P.area_now = find_code_area(class_now);
	if (org < P.area_now->limage)
		error("org pointing backward");
	else
		P.area_now->limage = org;
}

w_A W_even
{
	AREA *ar = P.area_now;
	if (ar)
		if (ar->limage & 1)
			if (no_image(ar->target))
				ar->limage += 1;
			else
				advance_b(0);
}

w_A W_align
{
	AREA *ar = P.area_now;
	if (ar)
	{
		long al = ar->limage, tal = ip->arg->disp;
		al /= tal;
		al += 1;
		al *= tal;

		if (no_image(ar->target))
			ar->limage = al;
		else
		{
			long fill = al - ar->limage;
			while (fill)
				advance_b(0), --fill;
		}
	}
}

void o_area(IP ip)
{
	o_area_setup(class_now, ++area_id, ip->arg->astr);
	o_fixup(ip->arg->astr, area_id, ip->arg->gl ? FIX_glmod : FIX_lcmod, 0);
	P.in_module = true;
}

w_A W_module { o_area(ip); }
w_A W_area   { o_area(ip); }
w_A W_endmod
{
	P.area_now = find_code_area(class_now);
	P.in_module = false;
}

w_A W_incbin
{
	VP nf = (VP)ip->arg->astr;

	advance_m(nf->vval, nf->codep);
	CC_ffree(nf->codep);
	freeVn(nf);
}

static
w_A o_align
{
	if (ip->sz > 1)
		if (P.area_now->limage & 1)
			if (no_image(P.area_now->target))
				P.area_now->limage++;
			else
				advance_b(0);
}

w_A W_ds
{
	o_align(ip);
	o_DS(ip);
}

#if BIP_ASM
static
void check_minus(NP np, NP lp, NP rp)
{
	if (	np->token eq MINUS
	    and lp->token eq ID
	    and rp->token eq ID
	   )
	{
		short lsc = lp->sc, rsc = rp->sc;
		if (   lsc eq K_AHEAD
		    or rsc eq K_AHEAD
		   )
		{
			G.need_second_pass = true;
		   	warnn(rsc eq K_AHEAD ? rp : lp, "can not diff with advance ref");
		   	/* 2 fixups, 1 for high label, 1 for low label, produce ICON high-low in second phase */
/*		   	message(0, 0, "Assembler needs second phase\n");
*/		}
		/* preliminary */
		np->token = ICON;
		advance_l(np->val.i);
	}
}
#endif

static
void write_dc(NP np, short sz)
{
	NP lp = np->left,
	   rp = np->right;

#if BIP_ASM
	if (np->token eq MINUS)
		check_minus(np,lp,rp);
	else
#endif
	if (np->token eq COMMA)
	{
		write_dc(lp, sz);
		write_dc(rp, sz);
	othw
		switch (sz)
		{
		case DOT_B:
			if (np->token eq SCON)
			{
				short i;
				for (i = 0; i < np->size; i++)
					advance_b(np->name[i]);
			}
			else
				advance_b(np->val.i);
		break;
		case DOT_W:
			if (np->token eq PLUS)
			{
				o_fixup(np->left->name, np->left->area_info.id, FIX_wabs, np->left->lbl);
				advance(np->right->val.i);			/* 05'12 v4.12 right, was left */
			}
			elif (np->token eq ID)
			{
				o_fixup(np->name, np->area_info.id, FIX_wabs, np->lbl);
				advance(0);
			}
			elif (np->token eq ICON)
			{
				advance(np->val.i);
			}
		break;
		case DOT_L:
			if (np->token eq PLUS)
			{
				o_fixup(np->left->name, np->left->area_info.id, FIX_labs, np->left->lbl);
				advance_l(np->right->val.i);			/* 05'12 v4.12 right, was left */
			}
			elif (np->token eq ID)
			{
				o_fixup(np->name, np->area_info.id, FIX_labs, np->lbl);
				advance_l(0);
			}
			elif (np->token eq ICON)
			{
				advance_l(np->val.i);
			}
		break;
#if FLOAT
		case DOT_D:
		{
			R64 d64;
			d80tod64(&d64, getrcon(np));
			advance_m(DOT_D, &d64);
		}
		break;
		case DOT_X:
		{
			double d = getrcon(np);
			advance_m(DOT_X, &d);
		}
		break;
#endif
		}
	}
}

w_A W_dc
{
	NP np = (NP)ip->arg;

	write_dc(np, ip->sz);
	freenode(np);
}

w_A W_dcb
{
	NP np = (NP)ip->arg;

	if (np->token eq COMMA)
	{
		long i = np->left->val.i;

	  	while (i--)
			write_dc(np->right, ip->sz);
	}
	else
		write_dc(np, ip->sz);

	freenode(np);
}

static
void write_scons(NP np, short ty)
{
	if (np->token eq COMMA)
	{
		write_scons(np->left , ty);
		write_scons(np->right, ty);
	othw
		if (ty eq 1)		/* asciil */
		{
			if (np->size > 256)
				error("string size %ld doesnt fit a byte", np->size);
			advance_b(np->size);
		}
		advance_m(np->size, np->name);

		if (ty eq 2)		/* asciiz */
			advance_b(0);
	}
	freenode(np);			/* 09'10 HR forgotten */
}

w_A W_ascii  { write_scons((NP)ip->arg, 0); }
w_A W_asciil { write_scons((NP)ip->arg, 1); }
w_A W_asciiz { write_scons((NP)ip->arg, 2); }

static
bool xbcd(IP ip, ushort w1)
{
	w1 |= ip->arg->areg & 7;

	if (ip->arg->next)
		w1 |= (ip->arg->next->areg & 7) << 9;
	else
		return false;

	if (MO(ip->arg->am) ne REG)			/* -(Ay), -(Ax) */
		w1 |= 010;
	advance(w1);
	return true;
}
w_A W_abcd { xbcd(ip, 0140400); }
w_A W_sbcd { xbcd(ip, 0100400); }
w_A W_nbcd
{
	ushort w1 = 0044000;
	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, 0);
}

w_A W_pack
{
	if (xbcd(ip, 0100500))
		if (ip->arg->next->next)
			advance(ip->arg->next->next->disp);
		else
			advance(0);
}

w_A W_unpk
{
	if (xbcd(ip, 0100600))
		if (ip->arg->next->next)
			advance(ip->arg->next->next->disp);
		else
			advance(0);
}

w_A W_add
{
	if (ip->reg >= 0)			/* ea,dn */
		o_Qarith(ip, 0150000, 042, IN_X, 0050000);
	else
	{
		ip->reg = ip->arg->areg;	/* dn,ea */
		ip->arg = ip->arg->next;
		o_Qarith(ip, 0150400, 042, TO_S, true);
	}
}

w_A W_adda { o_Qarith(ip, 0150000, 042, IN_X, 0050000); }

w_A W_addi
{
	if (ISAA(ip->arg->next))
		o_imma(ip, 0150000);
	else
		o_Qimm(ip, 0003000, 0050000);
}

w_A W_addq
{
	OPND *dst = ip->arg->next;
	if (    MO(dst->am) eq REG
		and ISA(dst->areg)
	   )
	   ip->sz = DOT_L;			/* 05'12 HR: v4.11 */
	o_Qimm(ip, 0003000, 0050000);
}

w_A W_addx
{
	ushort w1 = 0150400;
	w1 |= o_size(ip);
	xbcd(ip, w1);
}

w_A W_sub
{
	if (ip->reg >= 0)			/* ea,dn */
		o_Qarith(ip, 0110000, 050, IN_X, 0050400);
	else
	{
		ip->reg = ip->arg->areg;	/* dn,ea */
		ip->arg = ip->arg->next;
		o_Qarith(ip, 0110400, 050, TO_S, true );
	}
}

w_A W_suba { o_Qarith(ip, 0110000, 050, IN_X, 0050400); }

w_A W_subi
{
	if (ISAA(ip->arg->next))
		o_imma(ip, 0110000);
	else
		o_Qimm(ip, 0002000, 0050400);
}

w_A W_subq
{
	o_Qimm(ip, 0002000, 0050400);
}
w_A W_subx
{
	ushort w1 = 0110400;
	w1 |= o_size(ip);
	xbcd(ip, w1);
}

w_A W_and
{
	if (ip->reg >= 0)			/* ea,dn */
		o_arith (ip, 0140000, -1,  -1,   true );
	else
	{
		ip->reg = ip->arg->areg;	/* dn,ea */
		ip->arg = ip->arg->next;
		o_arith (ip, 0140400, -1,  -1,   true );
	}
}

w_A W_or
{
	if (ip->reg >= 0)			/* ea,dn */
		o_arith (ip, 0100000, -1,  -1,   true );
	else
	{
		ip->reg = ip->arg->areg;	/* dn,ea */
		ip->arg = ip->arg->next;
		o_arith (ip, 0100400, -1,  -1,   true );
	}
}

w_A W_eor { o_arith (ip, 0130400, -1,  -1,   true ); }

w_A W_andi
{
	if (MO(ip->arg->next->am) eq CONDREG)
		o_cond(ip, 0001074);
	else
		o_imm (ip, 0001000);
}
w_A W_ori
{
	if (MO(ip->arg->next->am) eq CONDREG)
		o_cond(ip, 0000074);
	else
		o_imm (ip, 0000000);
}
w_A W_eori
{
	if (MO(ip->arg->next->am) eq CONDREG)
		o_cond(ip, 0005074);
	else
		o_imm (ip, 0005000);
}

w_A W_callm{ o_imm(ip, 0003300); }

w_A W_cmp		/* ea,dn only (dn,ea is eor !!!) */
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

w_A W_cmpa
{
	ushort w1 = 0130000;
	w1 |= ip->sz eq DOT_W ? 0300 : 0700;
	o_arith(ip, w1, 0, -1, false);
}

w_A W_cmpi
{
	if (ISAA(ip->arg->next))
		o_imma(ip, 0130000);
	elif (ip->arg->disp eq 0)
	{
		ushort w1 = 0045000;			/* tst */
		w1 |= o_ea(ip->arg->next);
		w1 |= o_size(ip);
		advance(w1);
		o_ext(ip, ip->arg->next, ip->sz);
	}
	else
		o_imm (ip, 0006000);
}

w_A W_asl { o_shiftx(ip, 0160400); }
w_A W_asr { o_shiftx(ip, 0160000); }
w_A W_lsl { o_shiftx(ip, 0160410); }
w_A W_lsr { o_shiftx(ip, 0160010); }
w_A W_roxl{ o_shiftx(ip, 0160420); }
w_A W_roxr{ o_shiftx(ip, 0160020); }
w_A W_rol { o_shiftx(ip, 0160430); }
w_A W_ror { o_shiftx(ip, 0160030); }
w_A W_negx{ o_gens(ip, 0040000,  -1); }
w_A W_clr { o_gens(ip, 0041000,  -1); }
w_A W_neg { o_gens(ip, 0042000, 032); }
w_A W_not { o_gens(ip, 0043000,  -1); }
w_A W_tst { o_gens(ip, 0045000, 072); }

static
void o_bits(IP ip, ushort w1)
{
	OPND *arg = ip->arg, *dst = arg->next;
	w1 |= o_ea(dst);
	if (MO(arg->am) eq REG)
	{
		w1 |= 00400;
		w1 |= (arg->areg & 7) << 9;
		advance(w1);
	othw
		w1 |= 04000;
		advance(w1);
		advance(arg->disp & 0xff);
	}

	o_ext(ip, dst, DOT_B);
}

w_A W_btst { o_bits(ip, 0000000); }
w_A W_bchg { o_bits(ip, 0000100); }
w_A W_bclr { o_bits(ip, 0000200); }
w_A W_bset { o_bits(ip, 0000300); }

static
ushort o_bfow(OPND *op)
{
	if (MO(op->am) eq REG)
		return o_x(op->areg) | 040;
/*	elif (op->amode eq ABS) */
	else
		return op->disp eq 32 ? 0 : (op->disp & 31);
}

static
void o_bf(OPND *args, ushort w1, short reg)
{
	OPND *ea = args;
	ushort w2 = 0;

	w1 |= o_ea(args);
	advance(w1);
	args = args->next;
	w2 |= o_x(reg) << 12;
	w2 |= o_bfow(args) << 6;
	w2 |= o_bfow(args->next);
	advance(w2);
	o_ext(nil, ea, 0);
}

w_A W_bftst  { o_bf(ip->arg, 0164300,       0); }		/* <ea>{o:w} */
w_A W_bfchg  { o_bf(ip->arg, 0165300,       0); }
w_A W_bfclr  { o_bf(ip->arg, 0166300,       0); }
w_A W_bfset  { o_bf(ip->arg, 0167300,       0); }
w_A W_bfextu { o_bf(ip->arg, 0164700, ip->reg); }	/* <ea>{o:w}, Dn */
w_A W_bfexts { o_bf(ip->arg, 0165700, ip->reg); }
w_A W_bfffo  { o_bf(ip->arg, 0166700, ip->reg); }
w_A W_bfins  { o_bf(ip->arg, 0167700, ip->reg); }

w_A W_bsr { o_brdisp(ip->arg, DOT_W, 0060400, 0, ip->arg->areg); }

static
ushort cas_size(IP ip)
{
	switch (ip->sz)
	{
	case DOT_B:
		return 01000;
	case DOT_W:
		return 02000;
	}
	return 03000;
}

w_A W_cas
{
	OPND *arg = ip->arg;
	ushort Dc, Du;
	ushort w1 = 0004300;

 	Dc = arg->areg, arg = arg->next;
	Du = arg->areg, arg = arg->next;

 	w1 |= o_ea(arg);
	w1 |= cas_size(ip);
	advance(w1);
	w1  = Dc;
	w1 |= Du << 6;
	advance(w1);
	o_ext(ip, arg, ip->sz);
}

w_A W_cas2
{
	OPND *arg = ip->arg;
	ushort Dc1, Dc2, Du1, Du2, Rn1, Rn2;
	ushort w1 = 0004374;

	Dc1 = arg->areg, arg = arg->next;
	Dc2 = arg->areg, arg = arg->next;
	Du1 = arg->areg, arg = arg->next;
	Du2 = arg->areg, arg = arg->next;
	Rn1 = arg->areg, arg = arg->next;
	Rn2 = arg->areg, arg = arg->next;

	w1 |= cas_size(ip);
	advance(w1);
	w1  = ISA(Rn1) ? 0100000 : 0;
	w1 |=  Dc1;
	w1 |=  Du1<<6;
	w1 |= (Rn1&7)<<12;
	advance(w1);

	w1  = ISA(Rn2) ? 0100000 : 0;
	w1 |=  Dc2;
	w1 |=  Du2<<6;
	w1 |= (Rn2&7)<<12;
	advance(w1);
}

w_A W_chk
{
	ushort w1 = 0040000;

	w1 |= o_ea(ip->arg);
	w1 |= o_X(ip) << 9;
	w1 |= ip->sz eq DOT_W ? 0600 : 0400;
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}

static
void cmpchk(IP ip, ushort w2)
{
	ushort w1 = 0000300;
	w1 |= o_ea(ip->arg);
	w1 |= o_size(ip)<<3;
	advance(w1);
	if (ISA(ip->reg))
		w2 |= 0100000;
	w2 |= o_X(ip) << 12;
	advance(w2);
	o_ext(ip, ip->arg, ip->sz);
}

w_A W_chk2 { cmpchk(ip, 0004000); }
w_A W_cmp2 { cmpchk(ip, 0000000); }

w_A W_bkpt
{
	ushort w1 = 0044110;

	w1 |= ip->arg->disp & 7;
	advance(w1);
}

w_A W_cmpm
{
	ushort w1 = 0130410;

	w1 |= o_size(ip);
	w1 |= o_x(ip->arg->areg);
	w1 |= o_x(ip->arg->next->areg) << 9;
	advance(w1);
}

w_A W_exg
{
	ushort w1 = 0140400, areg = ip->arg->areg;

	if (ISA(ip->reg) and ISA(areg))
		w1 |= 0110;
	elif (ISD(ip->reg) and ISD(areg))
		w1 |= 0100;
	else
		w1 |= 0210;

	w1 |= o_x(areg);
	w1 |= o_X(ip) << 9;
	advance(w1);
}

static
void ext(IP ip)
{
	ushort w1 = 0044000;

	w1 |= o_X(ip);
	switch(ip->sz)
	{
		case DOT_B: w1 |= 0200; break;
		case DOT_W: w1 |= 0300; break;
		default:    w1 |= 0700;
	}
	advance(w1);
}

w_A W_ext  { ext(ip); }
w_A W_extb { ext(ip); }

w_A W_illegal { advance(0045374); }
w_A W_jsr { o_jump(ip, 0047200); }
w_A W_jmp { o_jump(ip, 0047300); }

w_A W_lea
{
	ushort w1 = 0040700;

	w1 |= o_dst_X(ip);
	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}
w_A W_pea
{
	ushort w1 = 0044100;

	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}

w_A W_link
{
	if (ip->sz eq DOT_L)
	{
		ushort w1 = 0044010;

		w1 |= o_X(ip);
		advance(w1);
		advance_l(ip->arg->disp);
	othw
		ushort w1 = 0047120;

		w1 |= o_X(ip);
		advance(w1);
		advance(ip->arg->disp);
	}
}

w_A W_unlk
{
	ushort w1 = 0047130;

	w1 |= o_X(ip);
	advance(w1);
}

/*
S	move <- sr		0100 000 011 <d_alt>
*	move <- ccr		0100 001 011 <d_alt>
	move -> ccr		0100 010 011 <d_add>
S	move -> sr		0100 011 011 <d_add>

S	move -> usp		0100 111 001 100 aaa
S	move <- usp		0100 111 001 101 aaa
*/

static
void o_move_cond(IP ip)
{
	ushort w1, reg;
	OPND *arg = ip->arg,
	     *dst = ip->arg->next;

	if (MO(arg->am) eq CONDREG)
	{
		reg = arg->disp;
		if (reg eq USP)
		{
			advance(0047150 | (dst->areg & 7));
			return;
		}

		arg = dst;
		w1 = 0040300;
		if (reg eq CCR)
			w1 |= 01000;
	othw
		reg = dst->disp;
		if (reg eq USP)
		{
			advance(0047140 | (arg->areg & 7));
			return;
		}

		w1 = 0042300;
		if (reg eq SR)
			w1 |= 01000;
	}

	w1 |= o_ea(arg);
	advance(w1);
	o_ext(ip, arg, DOT_W);
}

w_A W_move
{
	if (ip->arg->next)		/* ea,ea */
		if (   MO(ip->arg->      am) eq CONDREG
		    or MO(ip->arg->next->am) eq CONDREG
		   )
			o_move_cond(ip);
		else
			o_move_eaea(ip);
	else					/* ea,dn */
		o_move_eadn(ip, true);
}

w_A W_strldsr
{
	advance_l(0x40e746fc);
	advance(ip->arg->disp);
}

w_A W_wdebug
{
	ushort w1 = 0175700;
	w1 |= o_ea(ip->arg);
	advance(w1);
	advance(3);
	o_ext(ip, ip->arg, 0);
}

w_A W_wddata
{
	ushort w1 = 0175400;
	w1 |= ((ip->sz/2) & 3) << 6;
	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, 0);
}

w_A W_movea { o_move_eadn(ip, true); }

w_A W_move16
{
	ushort w1 = 0173000;
	OPND *arg = ip->arg, *dst = ip->arg->next;
	bool ab = MO(arg->am) eq ABS or MO(arg->am) eq IMM,
	     db = MO(dst->am) eq ABS or MO(dst->am) eq IMM;

	short
		areg = arg->areg & 7,
	    dreg = dst->areg & 7;

	if (
#if AMFIELDS
	        arg->am.f.m eq REGI
	    and arg->am.f.inc
	    and dst->am.f.m eq REGI
	    and dst->am.f.inc
#else
	        arg->am eq (REGI|INC)
	    and dst->am eq (REGI|INC)
#endif
	   )
	{
		w1 |= 040;
		w1 |= areg;
		advance(w1);
		advance(0100000 | (dreg << 12));
	}
	elif (ab and MO(dst->am) eq REGI)
	{
		w1 |= 030;
		w1 |= dreg;
		advance(w1);
		o_ext(ip, arg, DOT_L);
	}
	elif (    ab
	      and MM(dst->am) eq REGI
#if AMFIELDS
	  	  and dst->am.f.inc
#else
	      and (dst->am & INC) ne 0
#endif
	     )
	{
		w1 |= 010;
		w1 |= dreg;
		advance(w1);
		o_ext(ip, arg, DOT_L);
	}
	elif (db and MO(arg->am) eq REGI)
	{
		w1 |= 020;
		w1 |= areg;
		advance(w1);
		o_ext(ip, dst, DOT_L);
	}
	elif (
	          db
	      and MM(arg->am) eq REGI
#if AMFIELDS
	  	  and arg->am.f.inc
#else
	      and (arg->am & INC) ne 0
#endif
	     )
	{
		w1 |= 000;
		w1 |= areg;
		advance(w1);
		o_ext(ip, dst, DOT_L);
	}
}

w_A W_movem
{
	ushort w1 = 0044200;

	if (ip->sz eq DOT_L)
		w1 |= 00100;
										/* arg   arg->next */
	if (MM(ip->arg->am) eq IMM)			/* list, <ea> */
	{
		w1 |= o_ea(ip->arg->next);
		advance(w1);
		advance(ip->arg->disp);
		o_ext(ip, ip->arg->next, ip->sz);
	othw								/* <ea>, list */
		w1 |= 02000;
		w1 |= o_ea(ip->arg);
		advance(w1);
		advance(ip->arg->next->disp);
		o_ext(ip, ip->arg, ip->sz);
	}
}

static
short listcount(ushort list)
{
	short i = 0;
	while (list)
	{
		if (list&1)
			i++;
		list >>= 1;
	}
	return i;
}

/* xsave & xrest are Coldfire compatible */
w_A W_xsave
{
	short mask = ip->arg->disp;
#if COLDFIRE
	if (G.Coldfire)
	{
		ushort w1 = 047757;
		advance(w1);
		advance(-(listcount(mask)*DOT_L));	/* lea -cnt(sp),sp */
		w1 = 0044327;
		advance(w1);
		advance(mask);						/* movem.l reglist,(sp) */
	}
	else
#endif
	{
		ushort w1 = 0044347;
		advance(w1);
		advance(mask);						/* movem.l reglist,-(sp) */
	}
}

w_A W_xrest
{
	short mask = ip->arg->disp;
#if COLDFIRE
	if (G.Coldfire)
	{
		ushort w1 = 0046327;
		advance(w1);
		advance(mask);						/* movem.l (sp),reglist */
		w1 = 047757;
		advance(w1);
		advance((listcount(mask)*DOT_L));	/* lea cnt(sp),sp */
	}
	else
#endif
	{
		ushort w1 = 0046337;
		advance(w1);
		advance(mask);						/* movem.l (sp)+,reglist */
	}
}

w_A W_movep
{
	ushort w1 = 010;
	if (ip->reg >= 0)						/* Dn,d(An) */
	{
		w1 |= o_x(ip->reg) << 9;
		w1 |= o_x(ip->arg->areg);
		w1 |= ip->sz eq DOT_W ? 0600 : 0700;
	othw									/* d(An),Dn */
		w1 |= o_x(ip->arg->areg);
		w1 |= o_x(ip->arg->next->areg) << 9;
		w1 |= ip->sz eq DOT_W ? 0400 : 0500;
	}
	advance(w1);
	advance(ip->arg->disp);
}

w_A W_moveq
{
	ushort w1  = 070000;
	w1 |= ip->reg<<9;
	w1 |= ip->arg->disp&0xff;
	advance(w1);
}

#if COLDFIRE
static
void o_mvsz(IP ip, ushort w1)
{
	w1 |= ip->reg<<9;
	w1 |= o_ea(ip->arg);
	if (ip->sz eq DOT_W)
		w1 |= 0100;
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}

w_A W_mvs { o_mvsz(ip, 070400); }
w_A W_mvz { o_mvsz(ip, 070600); }

static
void o_brv(IP ip, ushort w1)
{
	w1 |= ip->arg->areg;
	advance(w1);
}

w_A W_bitrev  { o_brv(ip, 000300); }
w_A W_byterev { o_brv(ip, 001300); }
w_A W_ff1     { o_brv(ip, 002300); }
w_A W_mov3q   { }
#endif

w_A W_mulu
{
	if (ip->sz eq DOT_W)
		o_arith (ip, 0140300, 043, IN_X, false);
#if FLOAT			/* !FLOAT implies 68000 */
	else
		o_Lmd(ip, 0046000, 0, 1);
#endif
}

w_A W_muls
{
	if (ip->sz eq DOT_W)
		o_arith(ip, 0140700, 043, IN_X, false);
#if FLOAT
	else
		o_Lmd(ip, 0046000, 2, 1);
#endif
}

w_A W_divu
{
	if (ip->sz eq DOT_W)
		o_arith (ip, 0100300, 040, IN_X, false);
#if FLOAT
	else
		o_Lmd(ip, 0046100, 0, 1);
#endif
}

w_A W_divs
{
	if (ip->sz eq DOT_W)
		o_arith (ip, 0100700, 040, IN_X, false);
#if FLOAT
	else
		o_Lmd(ip, 046100, 2, 1);
#endif
}

w_A W_divul { o_Lmd(ip, 0046100, 0, 0); }
w_A W_divsl { o_Lmd(ip, 0046100, 2, 0); }
w_A W_remu  { o_Lmd(ip, 0046100, 0, 0); }
w_A W_rems	{ o_Lmd(ip, 0046100, 2, 0); }

w_A W_rtm
{
	ushort w1 = 0047160;
	w1 |= o_X(ip);
	if (ISA(ip->reg))
		w1 |= 010;
	advance(w1);
}

w_A W_reset { advance(0047160); }
w_A W_nop   { advance(0047161); }
w_A W_halt  { advance(0045310); }
w_A W_pulse { advance(0045314); }
w_A W_stop  { advance(0047162); advance(ip->arg->disp); }
w_A W_rte   { advance(0047163); }
w_A W_rtd   { advance(0047164); advance(ip->arg->disp); }
w_A W_rts   { advance(0047165); }
w_A W_trapv { advance(0047166); }
w_A W_rtr   { advance(0047167); }

w_A W_swap
{
	ushort w1 = 0044100;

	w1 |= o_X(ip);
	advance(w1);
}

w_A W_sats
{
	ushort w1 = 0046200;

	w1 |= o_X(ip);
	advance(w1);
}

w_A W_tas
{
	ushort w1 = 0045300;

	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, 0);
}

w_A W_trap  { advance(0047100 | (ip->arg->disp & 15)); }
w_A W_aline { advance(0xa000  |  ip->arg->disp); }

static
void inv_push(IP ip, ushort scope)
{
	ushort w1 = 0172000;
	w1 |= scope << 3;
	w1 |= (ip->reg & 3) << 6;
	if (ip->arg)
		w1 |= o_x(ip->arg->areg);
	advance(w1);
}

w_A W_cinvl  { inv_push(ip, 1); }
w_A W_cinvp  { inv_push(ip, 2); }
w_A W_cinva  { inv_push(ip, 3); }
w_A W_cpushl { inv_push(ip, 5); }
w_A W_cpushp { inv_push(ip, 6); }
w_A W_cpusha { inv_push(ip, 7); }

w_A W_intouch
{
	ushort w1 = 0172050;
	w1 |= o_x(ip->arg->areg);
	advance(w1);
}

static
void o_cpsaverestore(IP ip, ushort w1)
{
	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, 0);
}

w_A W_movec
{
	short reg;
	ushort w1 = 0047172;

	if (ip->reg >= 0)
		w1 |= 1,						/* Rn,Rc */
		reg = ip->reg;
	else
		reg = ip->arg->next->areg;		/* Rc,Rn */

	advance(w1);
	w1 = ip->arg->disp;
	w1 |= o_x(reg) << 12;

	if (ISA(reg))
		w1 |= 0100000;

	advance(w1);
}

w_A W_moves
{
	short reg;
	ushort w1 = 0007000;

	w1 |= o_ea(ip->arg);
	w1 |= o_size(ip);
	advance(w1);

	if (ip->reg >= 0)
		reg = ip->reg,
		w1 = 004000;
	else
		reg = ip->arg->next->areg,
		w1 = 0;

	w1 |= o_x(reg) << 12;

	if (ISA(reg))
		w1 |= 0100000;

	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}

static
void o_scc(IP ip, ushort cc)
{
	ushort w1 = 0050300;

	w1 |= cc<<8;
	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, 0);
}

w_A W_bra { o_brdisp(ip->arg, ip->sz, 0060000, asdata[ip->opcode].cc, ip->arg->areg); }
w_A W_st  { o_scc(ip, asdata[ip->opcode].cc); }
w_A W_dbra
{
	ushort w1 = 0050310;

	w1 |= asdata[ip->opcode].cc << 8;
	w1 |= o_X(ip);
	advance(w1);
	if (ip->arg->astr)
		o_fixup(ip->arg->astr, ip->arg->areg, FIX_wbra, ip->arg->tlab);
	advance(ip->arg->disp);
}

w_A W_trapt
{
	ushort w1 = 050370;
	short s = ip->sz eq DOT_W ? 2 : ip->sz eq DOT_L ? 3 : 4;

	w1 |= asdata[ip->opcode].cc << 8;
	w1 |= s;
	advance(w1);

	if (s < 4)
		o_ext(ip, ip->arg, ip->sz);
}

w_A W_fmovecr
{
	ushort w2 = 0056000;

	advance(0171000);
	w2 |= o_X(ip) << 7;
	w2 |= ip->arg->disp & 0177;
	advance(w2);
}

w_A W_fmovem
{
	ushort w1 = 0171000;
	OPND *arg = ip->arg, *dst = ip->arg->next;

	if (ip->sz eq DOT_X)				/* data registers */
	{
		bool dn = MO(arg->am) eq REG and ISD(arg->areg),
		     im = MO(arg->am) eq IMM;

		if (dn or im)
		{											/* regs to memory */
			w1 |= o_ea(dst);
			advance(w1);
			w1 = 0160000;

			if (dn)
			{
				w1 |= 04000;
				w1 |= o_x(arg->areg) << 4;
			}
			else
				w1 |= arg->disp;

#if AMFIELDS
			if (    dst->am.f.m eq REGID
			    and dst->am.f.dec
			   )
#else
			if (dst->am eq (REGID|DEC))
#endif
				w1 |= 010000;
			advance(w1);
			o_ext(ip, dst, 0);
		othw										/* memory to regs */
			dn = MO(dst->am) eq REG and ISD(dst->areg);
			w1 |= o_ea(arg);
			advance(w1);
			w1 = 0140000;
			if (dn)
			{
				w1 |= 04000;
				w1 |= o_x(dst->areg) << 4;
			}
			else
				w1 |= dst->disp;

#if AMFIELDS
			if (    arg->am.f.m eq REGID
			    and arg->am.f.inc
			   )
#else
			if (arg->am eq (REGID|DEC))
#endif
				w1 |= 010000;
			advance(w1);
			o_ext(ip, arg, 0);
		}
	othw								/* control registers */
		if (MO(arg->am) eq FCREG)
		{											/* regs to memory */
			w1 |= o_ea(dst);
			advance(w1);
			w1 = 0160000;
			w1 |= ip->reg<<10;
			advance(w1);
			o_ext(ip, dst, DOT_L);
		othw										/* memory to regs */
			w1 |= o_ea(arg);
			advance(w1);
			w1 = 0140000;
			w1 |= ip->reg<<10;
			advance(w1);
			o_ext(ip, arg, DOT_L);
		}
	}
}


#if FLOAT
w_A W_fnop     { advance(0171200); advance(0); }
w_A W_fsave    { o_cpsaverestore(ip, 0171400); }
w_A W_frestore { o_cpsaverestore(ip, 0171500); }

/* fpu ops */
w_A W_ftst
{
	ushort w1 = 0171000, w2 = 072;

	if (ip->reg > 0)
	{
		advance(w1);
		w2 |= (ip->reg - FREG) << 10;
		advance(w2);
	othw
		w1 |= o_ea(ip->arg);
		advance(w1);
		w2 |= o_fsize(ip);
		w2 |= 040000;				/* r/m */
		advance(w2);
		o_ext(ip, ip->arg, ip->sz);
	}
}

w_A W_fmovesr
{
	ushort w1 = 0171000, w2 = 0100000;

	if (ip->reg > 0)
		w2 |= (ip->reg << 10) | 0020000;
	else
		w2 |= ip->arg->next->areg << 10;

	w1 |= o_ea(ip->arg);
	advance(w1);
	advance(w2);
	o_ext(ip, ip->arg, ip->sz);
}

w_A W_fmove		{ o_cpgenx(ip, 000); }
w_A W_fint		{ o_cpgenx(ip, 001); }
w_A W_fsinh		{ o_cpgenx(ip, 002); }
w_A W_fintrz	{ o_cpgenx(ip, 003); }
w_A W_fsqrt		{ o_cpgenx(ip, 004); }
w_A W_flognp1	{ o_cpgenx(ip, 006); }

w_A W_fetoxm1	{ o_cpgenx(ip, 010); }
w_A W_ftanh		{ o_cpgenx(ip, 011); }
w_A W_fatan		{ o_cpgenx(ip, 012); }
w_A W_fasin		{ o_cpgenx(ip, 014); }
w_A W_fatanh	{ o_cpgenx(ip, 015); }
w_A W_fsin		{ o_cpgenx(ip, 016); }
w_A W_ftan		{ o_cpgenx(ip, 017); }

w_A W_fetox		{ o_cpgenx(ip, 020); }
w_A W_ftwotox	{ o_cpgenx(ip, 021); }
w_A W_ftentox	{ o_cpgenx(ip, 022); }
w_A W_flogn		{ o_cpgenx(ip, 024); }
w_A W_flog10	{ o_cpgenx(ip, 025); }
w_A W_flog2		{ o_cpgenx(ip, 026); }

w_A W_fabs		{ o_cpgenx(ip, 030); }
w_A W_fcosh		{ o_cpgenx(ip, 031); }
w_A W_fneg		{ o_cpgenx(ip, 032); }
w_A W_facos		{ o_cpgenx(ip, 034); }
w_A W_fcos		{ o_cpgenx(ip, 035); }
w_A W_fgetexp	{ o_cpgenx(ip, 036); }
w_A W_fgetman	{ o_cpgenx(ip, 037); }

w_A W_fdiv		{ o_cpgenx(ip, 040); }
w_A W_fmod		{ o_cpgenx(ip, 041); }
w_A W_fadd		{ o_cpgenx(ip, 042); }
w_A W_fmul		{ o_cpgenx(ip, 043); }
w_A W_fsgldiv	{ o_cpgenx(ip, 044); }
w_A W_frem		{ o_cpgenx(ip, 045); }
w_A W_fscale	{ o_cpgenx(ip, 046); }
w_A W_fsglmul	{ o_cpgenx(ip, 047); }

w_A W_fsub		{ o_cpgenx(ip, 050); }

w_A W_fsincos	{ o_cpgenx(ip, 060 | o_x(ip->arg->next->areg)); }

w_A W_fcmp		{ o_cpgenx(ip, 070); }

w_A W_fsmove	{ o_cpgenx(ip, 0100); }
w_A W_fssqrt	{ o_cpgenx(ip, 0101); }
w_A W_fdmove	{ o_cpgenx(ip, 0104); }
w_A W_fdsqrt	{ o_cpgenx(ip, 0105); }
w_A W_fsabs 	{ o_cpgenx(ip, 0130); }
w_A W_fsneg 	{ o_cpgenx(ip, 0132); }
w_A W_fdabs 	{ o_cpgenx(ip, 0134); }
w_A W_fdneg 	{ o_cpgenx(ip, 0136); }
w_A W_fsdiv 	{ o_cpgenx(ip, 0140); }
w_A W_fsadd 	{ o_cpgenx(ip, 0142); }
w_A W_fsmul 	{ o_cpgenx(ip, 0143); }
w_A W_fddiv 	{ o_cpgenx(ip, 0144); }
w_A W_fdadd 	{ o_cpgenx(ip, 0146); }
w_A W_fdmul 	{ o_cpgenx(ip, 0147); }
w_A W_fssub 	{ o_cpgenx(ip, 0150); }
w_A W_fdsub 	{ o_cpgenx(ip, 0154); }
#endif

static
void o_cpscc(IP ip, short cp, short cc)
{
	ushort w1 = 0170100;

	w1 |= o_ea(ip->arg);
	w1 |= cp << 9;
	advance(w1);
	advance(cc);
	o_ext(ip, ip->arg, 0);
}

w_A W_fbf     { o_cpbranch(ip->arg, 0,1, asdata[ip->opcode].cc, ip->sz, ip->arg->areg, true); }
w_A W_fsf     { o_cpscc   (ip,        1, asdata[ip->opcode].cc); }
w_A W_fdbf    { o_cpdbcc  (ip,        1, asdata[ip->opcode].cc); }
w_A W_ftrapf  { o_cptrapcc(ip,        1, asdata[ip->opcode].cc); }


static
void o_35flush(IP ip, ushort s)
{
	OPND *ea = ip->arg->next->next;
	ushort w1 = 0170000;
	ushort w2 = 0020000;
	if (ea)					/* <fc>,#<mask>,<ea> */
	{
		w1 |= o_ea(ea);
		w2 |= 6 << 10;		/* mode */
	}
	else
		w2 |= 4 << 10;		/* mode */

	if (s)
		w2 |= s << 10;		/* mode 5 & 7 */

	advance(w1);
	w2 |=  ip->arg      ->disp;			/* fc */
	w2 |= (ip->arg->next->disp) << 5;	/* mask */
	advance(w2);
	if (ea)
		o_ext(ip, ea, 0);
}

w_A W_pflush
{
	if (G.CPU & (_3|_5))
		o_35flush(ip, 0);
	elif (G.CPU & _4)
	{
		ushort w1 = 0172410;
		w1 |= o_x(ip->arg->areg);
		advance(w1);
	}
}

w_A W_pflusha
{
	if (G.CPU & (_3|_5))
	{
		advance(0170000);
		advance(0022000);
	}
	elif (G.CPU & _4)
		advance(0172430);
}

w_A W_pflushn
{
	ushort w1 = 0172400;
	w1 |= o_x(ip->arg->areg);
	advance(w1);
}

w_A W_pflushan
{
	advance(0172420);
}

w_A W_pflushs
{
	if (G.CPU & _5)
		o_35flush(ip, 1);
}

w_A W_pflushr
{
	ushort w1 = 0170000;
	w1 |= o_ea(ip->arg);
	advance(w1);
	advance(0120000);
	o_ext(ip, ip->arg, DOT_L);
}

static
void o_pload(IP ip, ushort rw)
{
	ushort w1 = 0170000;
	w1 |= o_ea(ip->arg);
	advance(w1);
	w1 = 0020000;
	w1 |= rw << 9;
	w1 |= ip->arg->next->disp;
	advance(w1);
	o_ext(ip, ip->arg, 0);
}

w_A W_ploadr { o_pload(ip, 1); }
w_A W_ploadw { o_pload(ip, 0); }

static
void o_pmove(IP ip, ushort fd)
{
	ushort w1 = 0170000, w2, size = DOT_L;
	ushort tomem = ip->reg < 0 ? 0 : 1;
	OPND *ea = ip->arg;
	short reg = ip->arg->next->disp;

	w2 = tomem << 9;		/* r/w */
	w1 |= o_ea(ea);
	advance(w1);

	w2 |= (reg>>3) << 10;

	if (G.CPU & _3)
	{
		if (!tomem and reg ne MMUSR)
			w2 |= fd << 8;
		switch (reg)
		{
			case SRP:
			case CRP:
				size = DOT_LL;
			break;
			case MMUSR:
				size = DOT_W;		/* same as PSR on _5 */
			break;
		}
	}

	if (G.CPU & _5)
	{
		if (reg >= BAD0 and reg <= BAC7)
			w2 |= (reg & 7) << 2;
		else
		switch (reg)
		{
			case DRP:
			case SRP:
			case CRP:
				size = DOT_LL;
			break;
			case CAL:
			case VAL:
			case SCC:
				size = DOT_B;
			break;
			case AC:
			case PSR:
			case PCSR:
				size = DOT_W;
			break;
		}
	}
	advance(w2);
	o_ext(ip, ea, size);
}

w_A W_pmove   { o_pmove(ip, 0); }
w_A W_pmovefd { o_pmove(ip, 1); }

static
void o_ptest(IP ip, ushort rw)
{
	if (G.CPU & (_3|_5))
	{
		ushort w1 = 0170000, w2 = 0100000 | (rw << 9);
		OPND *ea = ip->arg;
		short fc = ip->arg->next->disp,
		    lvl = ip->arg->next->next->disp;

		w1 |= o_ea(ea);
		w2 |= fc & 037;

		if (ip->reg >= 0)
			w2 |= 0400 | (o_X(ip) << 5);

		w2 |= (lvl & 7) << 10;
		advance(w1);
		advance(w2);
		o_ext(ip, ea, 0);
	}
	elif (G.CPU & _4)
	{
		ushort w1 = 0172510;
		w1 |= rw << 5;
		w1 |= o_x(ip->arg->areg);
		advance(w1);
	}
}

w_A W_ptestr  { o_ptest(ip, 0); }
w_A W_ptestw  { o_ptest(ip, 1); }

w_A W_pvalid
{
	ushort w1 = 0170000, w2 = 0024000;

	w1 |= o_ea(ip->arg);

	if (ip->reg ne VVAL)
		w2 |= 02000 | o_X(ip);

	advance(w1);
	advance(w2);
	o_ext(ip, ip->arg, 0);
}

w_A W_psave    { o_cpsaverestore(ip, 0170400); }
w_A W_prestore { o_cpsaverestore(ip, 0170500); }

w_A W_pbbs    { o_cpbranch(ip->arg, 0,0, asdata[ip->opcode].cc, ip->sz, ip->arg->areg, true); }
w_A W_psbs    { o_cpscc   (ip,        0, asdata[ip->opcode].cc); }
w_A W_pdbbs   { o_cpdbcc  (ip,        0, asdata[ip->opcode].cc); }
w_A W_ptrapbs { o_cptrapcc(ip,        0, asdata[ip->opcode].cc); }

static
void o_plpa(IP ip, short rw)
{
	ushort w1 = 0172610;

	w1 |= rw;
	w1 |= o_x(ip->arg->areg);
	advance(w1);
}
w_A W_plpar  { o_plpa(ip, 0100); }
w_A W_plpaw  { o_plpa(ip, 0000); }
w_A W_lpstop
{
	advance_l(0xf80001c0);
	advance(ip->arg->disp);
}
