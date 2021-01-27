/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Tony Andrews
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
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
 * Jan 1991: Modified by Han Driesen, Stichting ST, The Netherlands
 * Optimizer integrated in the compiler.
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "common/mallocs.h"
#include "param.h"

#include "opt.h"
#include "po.h"
#include "plib.h"
#include "out.h"
#include "inst.h"
#include "reg.h"
#include "peep.h"

#define error send_msg

#define debug_o (G.yflags['o'-'a'])
#define debugR (G.xflags['r'-'a'])
#define debugJ (G.xflags['j'-'a'])	/* display IXC in console */

global
PO_COMMON P;

short cur_proc, class_now;
void	bopt	(BP bp);

#if OPTBUG
PEEPC peepcnt = {0};
#endif

global
void do_pcnts(void)
{
#if OPTBUG
#if ! PCNT_SAMPLE
	if (G.v_Cverbosity > 2)
#endif
	{
		console("Peep counts:\n");
		send_msg("loops:%d\n", peep_loops);
		prcnt(p0_0);
		prcnt(p0_1 );prcnt(p0_2 );prcnt(p0_3 );prcnt(p0_4 );prcnt(p0_5 );
		prcnt(p0_11);prcnt(p0_12);prcnt(p0_13);prcnt(p0_14);prcnt(p0_15);
		prcnt(p0_lea);prcnt(p0_imm);prcnt(p0_tsf);
		prcnt(p0_tst);prcnt(p0_tsx);prcnt(s_fasn);prcnt(d_fasn);prcnt(p_fpsh);prcnt(tst_areg);
		prcnt(p1_0);prcnt(p1_reg);prcnt(p1_1);prcnt(p1_2);
		prcnt(p1_3);prcnt(p1_4);prcnt(p1_5);
		prcnt(p1_split);prcnt(p1_shift);prcnt(p1_ldx);

		prcnt(p2_0);prcnt(p2_1);prcnt(p2_2);prcnt(p2_3);prcnt(p2_4a);
		prcnt(p2_4b);prcnt(p2_4c);prcnt(p2_4d);prcnt(p2_5);
		prcnt(p2_6);prcnt(p2_7);prcnt(p2_8);prcnt(p2_9);
		prcnt(p2_alea);prcnt(p2_dlea);prcnt(p2_lmx);
		prcnt(p2_10);prcnt(p2_11);prcnt(p2_12);prcnt(p2_13);prcnt(p2_14);
		prcnt(p2_15);prcnt(p2_16);prcnt(p2_17);prcnt(p2_18);prcnt(p2_19);
		prcnt(p2_20);prcnt(p2_21);prcnt(p2_22);prcnt(p2_23);prcnt(p2_24);
		prcnt(p2_25);prcnt(p2_26);prcnt(p2_27);prcnt(p2_28);prcnt(p2_29);
		prcnt(p2_30);prcnt(p2_31);prcnt(p2_32);prcnt(p2_33);prcnt(p2_34);
		prcnt(p2_35);
		prcnt(p2_combine);
		prcnt(p2_40);prcnt(p2_45);prcnt(p2_46);prcnt(p2_47);
		prcnt(p2_91);prcnt(p2_92);prcnt(p2_93);
		prcnt(p2_100);prcnt(p2_101);

		prcnt(p3_0);prcnt(p3_1);prcnt(p3_2);
		prcnt(p3_3);prcnt(p3_4);prcnt(p3_5);
	}
#endif
}

/*
 * Options
 */

long inst_nr;

#if OPTBUG
void add_debug(IP ip, Cstr s)
{
	if (ip)
	{
		Cstr y = ip->bugstr;
		Wstr x;

		if (y)
		{
			x = CC_xmalloc(strlen(y) + strlen(s) + 3, AH_ADD_DEBUG2, CC_ranout);
			if (x)
			{
				strcpy(x, y);
				strcat(x, ", ");
				strcat(x, s);
				CC_xfree(y);
			}
		othw
			x = CC_xmalloc(strlen(s)+1, AH_ADD_DEBUG1, nil);
			if (x)
				strcpy(x, s);
	 	}

		ip->bugstr = x ? x : (Wstr) y;
	}
}
#endif

/*
 * Optimization statistics (use -v to print)
 */
short
	tnum,
	BC,
	s_bdel,			/* branches deleted */
	s_badd,			/* branches added */
	s_brev,			/* branch reversals */
	s_peep1,		/* 1 instruction peephole changes */
	s_peep2,		/* 2 instruction peephole changes */
	s_peep3,		/* 3 instruction peephole changes */
	s_idel,			/* instructions deleted */
	s_reg,			/* variables "registerized" */
	s_movem,		/* movem pairs added */
	s_lnk,			/* link pairs removed */
	s_regref,		/* refs to register variables */
	s_memref,		/* refs to lea'd memory locations */
	flows,
	peep_loops;

BP  fhead;			/* head of the current function */

global
Wstr mifp, ifp;

/*
 * idata
 *
 * For each instruction, we have some global information, as well
 * as flags indicating what the instruction does with its operands.
 * We need to know if each operand is set and/or referenced. If the
 * instruction has side-effects not directly related to its operands,
 * we need to know that as well, so "special case" code can deal with
 * that as well.
 */

#define DEF_PO_PROTO 1
#include "po_defs.h"

#define DEF_PO_OP 1

global
IDATA idata[] =
{
	{"invalid"},
#include "po_defs.h"
	{0L}
};

static	bool	saw_eof = false;

/*
 * Tokens from the current line...
 */

static
char
	*t_line,
	*t_lab,			/* label, if any */
	*t_op,			/* opcode */
	*t_reg,			/* register */
	*t_arg,			/* argument 1 */
	*t_dst;			/* destination if arg and NO reg */


#if PCNT_SAMPLE
global
void clr_pcnts(void)
{
	zero(peepcnt);
}
#endif

global
void init_po(void)		/* 11'09 HR: fix serious regression */
{
	zero(P);
}

static
void init_opt(void)
{
	tnum    = 0;
	BC      = 0;
	s_bdel  = 0;		/* branches deleted */
	s_badd  = 0;		/* branches added */
	s_brev  = 0;		/* branch reversals */
	s_peep1 = 0;		/* 1 instruction peephole changes */
	s_peep2 = 0;		/* 2 instruction peephole changes */
	s_peep3 = 0;		/* 3 instruction peephole changes */
	s_idel  = 0;		/* instructions deleted */
	s_reg   = 0;		/* variables "registerized" */
	s_movem = 0;		/* movem pairs added */
	s_lnk   = 0;		/* link/unlk pairs removed */
	s_regref = 0;		/* refs to register variables */
	s_memref = 0;		/* refs to lea'd memory locations */
	peep_loops = 0;
	flows = 0;

#if PCNT_SAMPLE
	clr_pcnts();
#endif
	phase = OPTIMIZING;
}

#if AMFIELDS
global
bool is_areg(OPMODE mo, short r)
{
	return mo.f.m eq REG and ISA(r);
}

#if FLOAT
global
bool is_freg(OPMODE mo, short r)
{
	return mo.f.m eq REG and ISF(r);
}
#endif

global
bool is_dreg(OPMODE mo, short r)
{
	return mo.f.m eq REG and ISD(r);
}

#else

global
bool is_areg(short m, short r)
{
	return m eq REG and ISA(r);
}

#if FLOAT
global
bool is_freg(short m, short r)
{
	return m eq REG and ISF(r);
}
#endif

global
bool is_dreg(short m, short r)
{
	return m eq REG and ISD(r);
}
#endif

global
bool op_dreg(OPND *op)
{
	return is_dreg(op->am, op->areg);
}

static
void end_opt(void)
{
#if OPTBUG
#if ! PCNT_SAMPLE
	if (G.v_Cverbosity > 2)
#endif
	{
		console("\nPeephole changes (1): %4d\t", s_peep1);
		console("Instructions deleted: %4d\n", s_idel);
		console("Peephole changes (2): %4d\t", s_peep2);
		if (!G.ab_no_branch_reversals)
			console("Branch reversals    : %4d\n", s_brev);
		console("\nPeephole changes (3): %4d\t", s_peep3);
		console("Branches removed    : %4d\n", s_bdel - s_badd);
		if (s_reg or s_movem)
		{
			console("Variables registered: %4d\t", s_reg);
			console("Movem pairs added   : %4d\n", s_movem);
		}
		if (s_regref or s_memref)
		{
			console("Refs to regvars:      %4d\t", s_regref);
			console("Refs to lea'd memory: %4d\n", s_memref);
		}

		if (s_lnk)
			console("Link pairs removed  : %4d\n", s_lnk/2);
	#if ! PCNT_SAMPLE
		do_pcnts();
	#endif
	}
#endif
}

static
bool is_okarg(char c)
{
	if (   c eq '\t'
		or c eq ','
		or c eq ';'
		or c eq '\r'
		or c eq 0
		) return false;
	return true;
}

static
bool is_ok(char c)
{
	if (   c eq '\t'
		or c eq '\r'
		or c eq ';'
		or c eq 0
		) return false;
	return true;
}

static
bool is_okdc(char c)
{
	if (   c eq '\t'
		or c eq '\r'
		or c eq 0
		) return false;
	return true;
}

static
bool is_line(char c)
{
	if (   c eq 0x10
		or c eq ';'
		or c eq '\r'
		or c eq '\n'
	   ) return false;
	return true;
}

/*
 * Symbol table:
 *
 * For each symbol, contains a pointer to the block starting at the
 * given symbol, and a pointer to the next symbol in the symbol table.
 */

BP sfirst = nil;
BP slast  = nil;

/*
 * mksym(symbol) - make a new symbol table entry
 *
 * mksym creates new symbol table entries, and allocates space for the
 * 'block' structure that will be used for the symbol. This can happen
 * when a reference to a block is detected, but before the block has
 * been encountered. Since we allocate the block structure here, other
 * blocks can reference it before we actually read it in.
 */
global
BP mksym(Cstr symbol)
{
	BP new = allocBn();
	BP bp  = allocBn();

	bp->name = symbol;
	new->symbol = bp;
	new->name = bp->name;
	new->next = nil;

/*  if sfirst eq nil then sfirst else slast->next fi := new */
	if (sfirst eq nil)
		sfirst = new;
	else
		slast->next = new;

	slast = new;
	return bp;
}

/*
 * getsym(symbol) - return a pointer to the block for 'symbol'
 *
 * Scans the symbol table for the given symbol and returns a pointer
 * to its block when found, or nil if not present.
 */
global
BP getsym(Cstr symbol)
{
	BP sp = sfirst;

	while (sp)
	{
		if (strcmp(sp->name, symbol) eq 0)
			return sp->symbol;
		sp = sp->next;
	}
	return nil;
}


/*
 * freesym() - free all symbol table space
 */
global
VpV freesym
{
	BP sp = sfirst;

	while (sp)
	{
		BP nexts = sp->next;
		freeIn(sp->symbol->first);
		freeBunit(sp->symbol);
		freeBunit(sp);
		sp = nexts;
	}
	sfirst = slast = nil;
}

static
void tokenize(char *s)
{
	char c = *s;

	t_line = s;

	t_lab = "";
	t_op  = t_lab;
	t_reg = t_lab;
	t_arg = t_lab;
	t_dst = t_lab;

	if (c ne '\t' and c ne '{')
	{
		t_lab = s;
		while (is_ok(*s)) ++s;
		c = *s;
		if (*(s-1) eq ':')
			*(s-1) = 0;
		*s = 0;
	}


	if (c eq '{')
		c = *++s;

	if (c eq '\t')
	{
		t_op = ++s;
		if (c eq '.') ++s;
		while (is_ok(*s)) ++s;
		c = *s;
		*s = 0;
	}

	if (c eq '\t')
	{
		t_reg = ++s;
		while (is_ok(*s)) ++s;
		c = *s;
		*s = 0;
	}

	if (c eq '\t')
	{
		t_arg = ++s;
		if (t_op[0] eq 'd' and t_op[1] eq 'c')
			while (is_okdc(*s)) ++s;
		else
			while (is_okarg(*s)) ++s;
		c = *s;
		*s = 0;
	}

	if (c eq ',')
	{
		t_dst = ++s;
		while (is_ok(*s)) ++s;
		c = *s;
		*s++ = 0;
	}
}

static
void write_line(void)
{
	if (*t_lab)
		send_out("%s:", t_lab);
	send_out("\t%s\t%s\t%s", t_op, t_reg, t_arg);
	if (*t_dst)
		send_out(",%s", t_dst);
	send_out("\n");
}

static
void send_line(void)
{
	send_msg("L");
	if (*t_lab)
		send_msg("%s:", t_lab);
	send_msg("\t%s\t%s\t%s", t_op, t_reg, t_arg);
	if (*t_dst)
		send_msg(",%s", t_dst);
	send_msg("\n");
}

/*
 * readline() - read the next line of class from the file
 *
 */

static
bool readline(short class)
{
	/* Keep looping until we get a line of class */

	while (!(*ifp eq 1 and *(ifp+1) eq 0))
	{
		Wstr buf = ifp;

		while (*buf ne '\n') buf++;
		if (!is_line(*ifp))
			ifp = buf+1;
		else
		{
			ASMOP op;

			t_line = ifp;
			tokenize(t_line);
			ifp = buf+1;

			/* is it a area-op? */
			if (*t_lab ne WARN_AREA)
				return true;		/* process line of requested class */

			/* compare class */
			op = get_opcode(t_lab + 1);
			if (op > 0)
			{
				/* Find out if the area is changing. */
				idata[op].opr(nil);

				if (class_now ne class)			/* have change */
				{
					console("class changed %s to %s\n", class_names[class], class_names[class_now]);
					return false;
				}

				if (op eq GPROC or op eq SPROC or op eq PEND)
					return true;

				*t_line = 0x10;		  /* same class: skip */
			}
		}
	}

	return false;	/* file ends with \1\0 */
}

global
short is_lbl(Cstr l)
{
	if (l)
	{
		short lbl = 0;
		if (*l   eq  0 ) return  0;			/* no label */
		if (*l++ ne '_') return -1;
		if (*l++ ne '_') return -1;
		if (*l   eq  0 ) return -1;
		while(*l)
			if (*l < '0' or *l > '9' )
				return -1;  /* no compiler generated label */
			else
				lbl = (lbl*10)+(*l++-'0');
		return lbl+1;			/* '__' followed by digits only */
	}
	return -1;
}

static
AREA *find_area(short id)
{
	FLIST *fl = P.fbase.first;

	while(fl)
	{
		AREA *ar = fl->areas.first;

		while (ar)
		{
			if (ar->id eq id)
				return ar;
			ar = ar->next;
		}

		fl = fl->next;
	}

	return nil;
}

/*
 * get_func() - get a function and return a pointer to its starting block
 *
 * Returns nil on end of file.
 */

static
bool noregs;
global
bool new_peep;

static
BP get_func(short class, short area)
{
	BP head,	/* starting block for this function */
	   cb,		/* the block we're currently reading */
	   ob;		/* the last block we read */

	loclist = 0;
	regi = nil;
	loci = nil;
	noregs = false;
	new_peep = false;

	if (saw_eof)
		return nil;

	cur_proc = 0;

	do
	{
		saw_eof = !readline(class);
		if (saw_eof)
			return nil;
	}
	while (cur_proc eq 0);

	head = mksym(t_arg);		/* Enter the symbol and mark it global. */

#if BIP_ASM
	if (isdigit(*t_dst))
	{
		AREA *ar;

		area_id = atoi(t_dst);		/* area id of a assembler function */
		ar = find_area(area_id);

		if (ar eq nil)
			console("CE: invalid asm area number %d\n", area_id);
		else
		{
			rem_list(&P.fbase.first->areas, ar);
			ins_last(&P.fbase.first->areas, ar);
#if C_DEBUG
			console("asm area TEXT %d size %ld\n", area_id, ar->limage);
#endif
			return head;
		}
	}
	else
#endif
	{
		char *s = t_dst;
		while (*s)
		{
			if (*s eq 'R') noregs = true;
			if (*s eq 'r') noregs = false;
			if (*s eq 'N') new_peep = true;
			if (*s eq 'n') new_peep = false;
			s++;
		}
	}

	area_id = area;
	o_area_setup(TEXT_class, area_id, t_arg);

#if OPTBUG
	if (G.v_Cverbosity > 2 or G.ad_new_peep or new_peep)
		send_msg("optimizing '%s'\n", t_arg);
#endif
 	if (cur_proc eq 2)
		head->bflg.is_global = 1;

	cb = ob = head;

	do{		/* read blocks until end of proc */
		do{		/* read lines until we hit a new block or end of proc. */
			saw_eof = !readline(class);

			if (saw_eof or cur_proc eq 0)		/* end of file or end of proc */
			{
				o_area_end();
				return head;
			}

			if (*t_lab)		/* If we see a label, we're done with the block. */
			{
				cb = getsym(t_lab);

				if (cb eq nil)
					cb = mksym(t_lab);

				ob->chain = cb;
				ob->next = cb;
				ob->fall = cb;
				break;
			}

			addinst(cb, t_op, t_reg, t_arg, t_dst);
		}od

		ob = cb;
	}od
}

static
bool need_inst(IP ci)
{
	if (ci->opcode eq REGL and loclist eq 0)
		return false;		/* dont count as a inst */

	if (	(	ci->opcode eq MMS
			 or ci->opcode eq MMX
			)
		and MO(ci->arg->am) ne RLST			/* 03'09 must be ABS */
		and loclist eq 0
	   )
		return false;

	return true;
}

/* Check if a block has nothing but a return instruction. */
static
IP rtn_only(BP bp)
{
	if (bp->bflg.ret)
	{
		IP ip = bp->first;
		while (ip)
			if (need_inst(ip))
				break;
			else
				ip = ip->next;

		if (ip)
			if (is_return(ip->opcode))
				return ip;
	}
	return nil;
}

/*
 * put_func(sb) - print out the function starting at block 'sb'
 *
 * The 'next' pointers determine the order in which things are placed
 * in the file. Branch instructions have been removed so they need to
 * be replaced here on output. Conditional branches are generated if
 * indicated (by non-null 'cond'). Unconditional branches are generated
 * at the end of a block if it's "fall through" block isn't going to
 * be the next thing in the file.
 */
static
void put_func(BP cb, short class, short area)
{
	IP ci;
	OPND branch_arg = {0}, *arg = &branch_arg;

	MO(arg->am) = ABS;
#if AMFIELDS
	arg->am.f.symb = 1;
#else
	arg->am |= SYMB;
#endif

	o_func(cb, class, area);

	while (cb)
	{
		if (cb ne fhead)
			o_block(cb);

		ci = cb->first;
		while (ci)
		{
			if (need_inst(ci))
				o_inst(ci);
			else
				s_idel++;
#if DBGA2
			if (    fhead->bflg.has_trap
			    and ci->opcode ne TRAP
/*			    and ci->opcode ne MMX
			    and ci->opcode ne MMS
*/			   )
			{
				Cstr pascode(short tok);
				if (((ci->rref|ci->rset) & RM(A2)) ne 0)
					console("A2 by %s\n", pascode(ci->opcode));
			}
#endif
			ci = ci->next;
		}

/*
 * If there's a conditional branch, put out the
 * appropriate instruction for it.
 */
		if (cb->cond ne nil and cb->opcode >= 0)
		{
			arg->astr = cb->cond->name;
#if FLOAT
			if (cb->opcode >= FBNE)
				o_cpbranch(arg,        cb->opcode, 1, idata[cb->opcode].cc, DOT_W, 0, false);
			else
#endif
				o_branch  (arg, DOT_W, cb->opcode,    idata[cb->opcode].cc, 0);
#if OPTBUG
	#if DEBUG
			if (debugJ)
	#endif
			{
				INODE inst = {0}, *ip = &inst;
				ip->arg = arg;
				ip->opcode = cb->opcode;
				ip->reg = -1;
				IXC_inst(ip);
			}
#endif
		}
/*
 * If there's a "fall through" label, and the destination
 * block doesn't come next, put out a branch,
 * unless the fall block only contains a single return instruction.
 */

		if (cb->fall ne nil and cb->fall ne cb->next)
		{
			IP rt = rtn_only(cb->fall);
			if (rt)
			{
				s_idel--;
				o_inst(rt);		/* output return inst in stead of branch. */
			othw
				s_badd++;
				arg->astr = cb->fall->name;
				o_branch(arg, DOT_W, BRA, 0, 0);
#if OPTBUG
	#if DEBUG
				if (debugJ)
	#endif
				{
					INODE inst = {0}, *ip = &inst;
					ip->arg = arg;
					ip->opcode = BRA;
					ip->reg = -1;
					IXC_inst(ip);
					console("\n");
				}
#endif
			}
		}

		cb = cb->next;
	}

	o_endproc();
}


static bool in_list(short code, short *list)
{
	if (*list < 0)
		return true;		/* neg = all */
	while(*list)
		if (*list++ eq code)
			return true;
	return false;

}

global
void All_inst(BP cp, bool c, Cstr s, ...)
{
	IP ip;	/* current instruction */
	va_list codes;
	va_start(codes, s);
	send_msg(">>>> All_inst -= %s =-\n", s);

	while (cp)
	{
		ip = cp->first;
		while (ip)
		{
			if (in_list(ip->opcode, (short *)codes) )
				IXC_inst(ip);

			ip = ip->next;
		}
		cp = c? cp->chain : cp->next;
	}
	send_msg("<<<< All_inst end\n\n");
}

global
void All_blocks(BP bp, bool c, Cstr s)
{
/*	BP head = bp;
*/	send_msg(">>>> All_blocks -= %s =-\n", s);
	while (bp)
	{
		send_msg("%s(%d)\n", bp->name, bp->bn);
		bp = c ? bp->chain : bp->next;
	}
	send_msg("<<<< All_blocks end\n\n");
}

global IP regi, loci;

static
bool do_func(short class, short area)
{
	IP ci;
#if DBGA2
	bool trap = false;
#endif
	saw_eof = false;

	clrvar();

	if ((fhead = get_func(class, area)) eq nil)
	{
		freesym();
		return false;					/* end of (virtual) file */
	}

	ci = fhead->first;

	if (ci eq nil)
	{
		freesym();
		return true;
	}

	if (loci)
	{
		if (ci->opcode eq LKX)
		{
			MO(ci->arg->am) = IMM;
			ci->arg->disp  = loci->arg->disp;
			freeIn(loci);
		othw
			loci->next = ci;
			ci->prior = loci;
			fhead->first = loci;
		}
	}

	ci = fhead->first;
	if (regi)
	{
		regi->next = ci;
		ci->prior = regi;
		fhead->first = regi;
	}

	/*
	 * Process the function we just read.
	 * Via the chain pointers you can do anything in the original order.
	 */
	bopt(fhead);		/* perform branch optimization always (essential) */
						/* everything next relies heavily on bopt() */
	if (!(G.ar_no_registerization or noregs))
		setreg(fhead);	/* try to assign locals to registers */

	peep (fhead);	/* peephole optimizations */
	G.asm_clo = clock();
#if DBGA2
	{
		BP bp = fhead;
		while (bp)
		{
			trap |= bp->bflg.has_trap;
			bp = bp->chain;
		}
	}
	fhead->bflg.has_trap = trap;
	if (trap)
		console("traps in %s\n", fhead->name);
#endif
	put_func(fhead, class, area);	/* Now dump out the modified tree */
	G.asm_clock += clock() - G.asm_clo;
	freesym();			/* free the symbol table */
	freevar(locals);
	return true;
}

static
void assem(BpII *part, short op, short class, char *start, char *startmod)
{
	AREA_STACK *as = start_areas;
	while (as)
	{
		AREAS *a = &as->ar[class];
		long l = a->out - a->start;
		short area = a->id;

		std_areas = as;

		if (l)
		{
			mifp = ifp = a->start;
			*(ifp+l)   = 1;
			*(ifp+l+1) = 0;		/*  \1\0 for readline */

			if (class ne TEXT_class)		/* TEXT in do_func */
			{
				AREA *new = o_area_setup(class, area, "");
				if (new)
					new_fixup(&new->fixups,
				              P.area_po_names[area],
				              std_area_to_fix[class],
				              FIX_lcmod,
				              new->image,
				              0,
				              CC_ranout);
			}

			idata[op].opr(nil);
			while((*part)(class, area));

			if (class ne TEXT_class)
				o_area_end();				/* TEXT in do_func */
		}

		as = as->next;
	}
}

static
bool do_data(short class, short area)
{
	area_id = area;

	while (readline(class))
	{
		IP ip;
		
		ip = addinst(nil, t_op, t_reg, t_arg, t_dst);
		o_lab(t_lab);
		if (ip)
		{
			o_inst(ip);
			freeIn(ip);
		}
		*t_line = 0x10;
	}
	return false;
}

/* Build a hashed table for finding operation codes */
static
ASM_TAB **IXC_tab = nil;

global
short ophash(Cstr key)
{
	Cstr s = key;
	short k = 0;

	while (*s)
		k = (((k << 1) + (k >> 10)) ^ (*s++)) & 0x3ff;

	return k % OPHASH;
}

static
bool opc_setup(void)
{
	short opc = 1;

	if (IXC_tab eq nil)
	{
		IDATA *id = idata + opc;

		IXC_tab = CC_xcalloc(1, sizeof(void *) * OPHASH, AH_OPC_SETUP, nil);

		if (IXC_tab eq nil)
			return false;

		while (id->text)
		{
			short hval;
			ASM_TAB *at = CC_xmalloc(sizeof(*at), AH_OPC_SETUP, nil);
			if (at eq nil)
				return false;

			hval = ophash(id->text);
			at->link = IXC_tab[hval];
			at->name = id->text;
			at->tok = opc;
			IXC_tab[hval] = at;
			++id;
			++opc;
		}

#if 0			/* check the spread */
		send_msg("%d opcodes\n", opc);
		{
			short i;
			for (i = 0; i < OPHASH; i++)
			{
				ASM_TAB *ab = IXC_tab[i];
				if (ab)
				{
					short k = 0;
					while (ab)
					{
						send_msg("%d>%s[%d]\n", k, ab->name, ab->tok);
						ab = ab->link;
						k++;
					}
				}
				else
					send_msg("~~~\n");
			}
		}
#endif
	}

	return true;
}

global
void opc_end(void)
{
	CC_xfree_all(AH_OPC_SETUP);
	IXC_tab = nil;
}

global
ASMOP find_op(char *o)
{
	short hval = ophash(o);
	ASM_TAB *ab = IXC_tab[hval];
	while (ab)
	{
		if (strcmp(ab->name, o) eq 0)
			return ab->tok;
		ab = ab->link;
	}

	return INVOP;
}

static
bool std_po_names(FLIST *fl)
{
	short i;

	if (area_id > MAXAREAS)
	{
		console("More than %d areas (%d)\n"
		        "please ring the author of AHCC\n", MAXAREAS, area_id);
		return false;
	}

	memset(P.area_po_names, 0, sizeof(P.area_po_names));

	for (i = start_class; i < high_class; i++)
	{
		AREA_STACK *as = start_areas;

		while (as)
		{
			AREAS *a = &as->ar[i];

			if (a->id > 0)
			{
				if (*a->name eq 0)
					sprintf(a->name, "__%d", new_lbl());
				P.area_po_names[a->id] = new_po_name(&fl->names, a->name, a->id, 0, false);
			}

			as = as->next;
		}
	}

	return true;
}

global
Wstr optimize(void)
{
	G.asm_clock = 0;		/* for internal IXC assembler 'assem' */
	init_opt();
	inst_nr = 0;

	if (!opc_setup() or !o_setup())
		error("insufficient memory for output phase\n");
	elif (std_po_names(P.fbase.first))
	{
		/* First: areas that by nature can not contain references. */
		assem(do_data, BSS,			BSS_class,  "BSS \t; static",    "BSS \n\tMODULE\tbss_static"   );
		assem(do_data, GBSS,		GBSS_class, "BSS \t; global",    "BSS \n\tMODULE\tbss_global"   );
		assem(do_data, CONSTANTS,	CON_class,  "DATA\t; consts" ,   "DATA\n\tMODULE\tconstants"    );
		assem(do_data, STRS,		STR_class,  "DATA\t; strings",   "DATA\n\tMODULE\tstrings"      );
		/* Second: data areas */
		assem(do_data, DATA,		DATA_class, "DATA\t; static",    "DATA\n\tMODULE\tdata_static"  );
		assem(do_data, GDATA,		GDATA_class,"DATA\t; global",    "DATA\n\tMODULE\tdata_global"  );
		/* Finally: the code areas */
		assem(do_func, TEXT,		TEXT_class, "TEXT","");
		o_end(G.v_Cverbosity);
	}
	end_opt();
	return out_goes;   			/* after last char written */
}
