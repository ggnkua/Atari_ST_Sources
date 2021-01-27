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
 *  M68K instruction generator library for Pure C objects
 *       common between po.c and as_out.c
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "common/mallocs.h"
#include "common/qmem.h"
#include "common/amem.h"
#include "param.h"

#include "opt.h"
#include "out.h"
#include "reg.h"
#include "peep.h"
#include "po.h"
#include "plib.h"


char *pclass(short);

#pragma warn -aus

#define debugA (G.xflags['a'-'a'])
#define debugJ (G.xflags['j'-'a'])	/* display IXC in console */

global
short std_area_to_fix[] =	/* standard area class to standard segment */
{
	0,
	FIX_text,		/*	TEXT_class	*/
	FIX_data,		/*	DATA_class	*/
	FIX_data,		/*	GDATA_class	*/
	FIX_data,		/*	STR_class	*/
	FIX_data,		/*	CON_class	*/
	FIX_bss,		/*	BSS_class	*/
	FIX_bss,		/*	GBSS_class	*/
	FIX_offs,		/*  OFFS_class	*/
	0
};

global
PO_NAME * get_po_name(NAMEBASE *nmb, short n)
{
	if (n < nmb->high)
	{
		PO_NAME *nm = nmb->base;
		return &nm[n];
	}
	return nil;
}

global
PO_NAME * new_po_name(NAMEBASE *nmb, Cstr name, short area, short tlab, bool chklbl)
{
	PO_TAB *tp = nil;
	short hashval = ldhash(name);
	PO_NAME *pn, *nm = nmb->base;
	short n = nmb->high, l;

	if (*name)
	{
		tp = P.po_tab[hashval];
		while (tp)
		{
			if (    strcmp(name, tp->n->s) eq 0
			    and tlab eq tp->n->tlab)
			{
				/* is one of the names a forward reference ? */
				/* it is in the same file, so the found name is the nearest */
				if (area eq 0)
				{
					area = tp->n->area_number;
					break;
				}
				if (tp->n->area_number eq 0)
				{
					tp->n->area_number = area;
					break;
				}

			    if (area eq tp->n->area_number)
					break;
			}

			tp = tp->link;
		}

		if (tp)
			return tp->n;
	}

	pn = &nm[n];			/* make new */

	l = strlen(name);
	tp = CC_qalloc(&defmem, sizeof(PO_TAB) + l + 1, CC_ranout, AH_CC_OBNAME);
	if (tp)
	{
		tp->n = pn;
		pn->s = tp->name;
		pn->tlab = tlab;
		pn->l = l;
		pn->nr = n;
		pn->hash = hashval;
		pn->area_number = area;

		strcpy(pn->s, name);

		if (chklbl and is_lbl(name) > 0)
			pn->ty = TLAB;
		else
			pn->ty = 0;

		if (n eq nmb->size)
			error("More than %ld names!!!!", nmb->size);
		else
			nmb->high = n + 1;

		tp->link = P.po_tab[hashval];
		P.po_tab[hashval] = tp;
		P.po_names++;
	}

	return pn;
}

global
bool o_setup(void)
{
	FLIST *fl;

	if (P.setup_done)
		return true;

	zero(P);

	P.setup_done = true;
	init_membase(&defmem, 16384, 0, "global base", nil);
	init_membase(&refmem, 16384, 0, "reference base", nil);
	init_membase(&opndmem, 8192, 0, "operands base", nil);

	P.fbase.name = o_name.s;

	fl = ins_flist(o_name.s, AH_CC_OFILE, nil, nil);

	if (fl)
	{
		long size;
		fl->names.size = (G.lblnum > 1 ? G.lblnum : ACHUNK) + ACHUNK;
		size = fl->names.size * sizeof(PO_NAME);
		fl->names.high = 0;
		fl->names.base = CC_xmalloc(size, AH_O_SETUP, nil);
		if (fl->names.base)
		{
			P.po_tab = init_symtab(AH_NEW_POTAB);
			memset(fl->names.base, 0, size);
#if O_VERBOSE
			send_msg("(lblnum: %d + %ld) * %ld = %ld\n", G.lblnum, ACHUNK, sizeof(PO_NAME), size);
			send_msg("highest area: %d\n", area_id);
#endif
			return true;
		}
	}

	return false;
}

global
char *iname(IP ip)
{
	return idata[ip->opcode].text;
}

#define START_ALLO 500
#define NEW_ALLO(x) ((x*3)/2)

global
void advance_b(uchar w)
{
	AREA *ar = P.area_now;
	if (ar)
	{
		long l = ar->allo;
		char *now = ar->image,
		     *cur = now + ar->limage,
		     *new;

		if (cur + sizeof(w) > now + l)
		{
			l = NEW_ALLO(l);
			new = CC_frealloc(now, l, AH_ADVANCE_B, CC_ranout);
			if (new)
			{
				ar->allo  = l;
				ar->image = new;
				cur = ar->image + ar->limage;
			}
		}

		*(uchar *)cur = w;
		ar->limage += sizeof(w);
	}
}

global
void advance(ushort w)
{
	AREA *ar = P.area_now;

	if (ar)
	{
		long l = ar->allo;
		char *now = ar->image,
		     *cur = now + ar->limage,
		     *new;

		if (cur + sizeof(w) > now + l)
		{
			l = NEW_ALLO(l);
			new = CC_frealloc(now, l, AH_ADVANCE_W, CC_ranout);
			if (new)
			{
				ar->allo  = l;
				ar->image = new;
				cur = ar->image + ar->limage;
			}
		}

		*(ushort *)cur = w;
		ar->limage += sizeof(w);
	}
}

global
void advance_l(long w)
{
	AREA *ar = P.area_now;
	if (ar)
	{
		long l = ar->allo;
		char *now = ar->image,
		     *cur = now + ar->limage,
		     *new;

		if (cur + sizeof(w) > now + l)
		{
			l = NEW_ALLO(l);
			new = CC_frealloc(now, l, AH_ADVANCE_L, CC_ranout);
			if (new)
			{
				ar->allo  = l;
				ar->image = new;
				cur = ar->image + ar->limage;
			}
		}

		*(long *)cur = w;
		ar->limage += sizeof(w);
	}
}

global
void advance_m(long size, void *m)
{
	AREA *ar = P.area_now;
	if (ar)
	{
		long l = ar->allo;
		char *now = ar->image,
		     *cur = now + ar->limage,
		     *new;

		if (cur + size > now + l)
		{
			l = NEW_ALLO(l);
			l += size;
			new = CC_frealloc(now, l, AH_ADVANCE_L, CC_ranout);
			if (new)
			{
				ar->allo  = l;
				ar->image = new;
				cur = ar->image + ar->limage;
			}
		}

		memmove(cur, m, size);
		ar->limage += size;
	}
}

global
REFS * get_label(AREA *ar, Cstr name, short tlab)
{
	REFS *rf = ar->lbls.first;
	while (rf)
	{
		PO_NAME *np = rf->fx->name;
		if (strcmp(np->s, name) eq 0)
			if (tlab eq 0 or tlab eq np->tlab)
				return rf;

		rf = rf->next;
	}

	return rf;
}

global
FIXUP * o_fixup(Cstr name, short area, short ty, short tlab)
{
	FIXUP *f = nil;

	if (name and *name)
	{
		FLIST *fl;
		PO_NAME *pn;
		short target;
		AREA *ar = P.area_now;

		fl     = ar->in;
		target = std_area_to_fix[class_now];
		pn     = new_po_name(&fl->names, name, area, tlab, true);
#if O_VERBOSE
		send_msg("o_fixup: %s area, %s  id %d @ %ld\t[%d] %s[%d]%d\n",
		           pclass(class_now), fixup_name(ty), area, ar->limage,
		           pn->area_number, pn->s, pn->tlab, pn->nr);
#endif

		if (ty eq FIX_labs)			/* prevent removing of fixup */
			pn->ty = 0;

		f = new_fixup(&ar->fixups, pn, target, ty,
		           ar->image + ar->limage, ar->limage,
		           CC_ranout);
	}

	return f;
}

global
void o_func(BP head, short class, short area)
{
	o_fixup(head->name, area,
							head->bflg.is_global ? FIX_glmod : FIX_lcmod,
			0);
}

global
void branch_aheads(AREA *ar, FIXUP *ef)
{
	long progress; 		/* cumulative size reduction of area */

	/* reduce branch ahead operands (Bcc.w --> Bcc.s) where possible
	   and change fixup type */

	do
	{
		FIXUP *f = ar->fixups.first;
		progress = 0;

		while (f)
		{
			f->disp -= progress;		/* update ALL fixups positions !!! */

			if (    f->fix.ty eq FIX_wbra
			    and strcmp(f->name->s, ef->name->s) eq 0)
			{
				if (f->name->tlab eq ef->name->tlab)
				{
					long d = ef->disp - f->disp;
					if (d <= 128)		/* remember! its branch aheads :-) */
					{
						char *to = ar->image + f->disp;
						long size = ar->limage - f->disp - DOT_W;

						if (size)
							memmove(to, to + DOT_W, size);

						progress   += DOT_W;
						ar->limage -= DOT_W;
						f->disp    -= DOT_W;
						f->fix.ty = FIX_sbra;
	#if F_VERBOSE
						send_msg("reduced %s @ %ld, progress %ld, moved %ld\n",
						          f->name->s, f->disp, progress, size);
	#endif
					}
				}
			}

			f = f->next;
		}
	}
	while (progress);
}

global
AREA *try_bsr(FLIST *fl, AREA *this, Cstr name)
{
	AREA *ar = fl->areas.first, *here;

	/* find out if a bsr suffices */

	while (ar)
	{
		if (strcmp(ar->name, name) eq 0)
		{
			long tally = 0;				/* compute distance */

			here = ar;
			while (ar ne this)
			{
				if (ar->target eq this->target)
					tally += ar->limage;
				ar = ar->next;
			}

			tally += this->limage;		/* current area size */

			if (D16OK(tally))
			{
#if O_VERBOSE
				console("can bsr %s in %s  @ %ld\n", name, this->name, tally);
#endif
				return here;
			}
			else
				return nil;
		}

		ar = ar->next;
	}

	return nil;
}

global
void o_block(BP cb)
{
#if 0
	send_msg("block(%d) ", cb->bn);
	send_msg("name  %s  ", cb->name);
	send_msg("fall '%s' ", cb->fall ? cb->fall->name : "");
	send_msg("cond '%s' ", cb->cond ? cb->cond->name : "");
	send_msg("ref(%s),",mask_to_s(cb->live));
	send_msg("set(%s) ",mask_to_s(cb->rset));
	send_msg("\n");
#endif
	if (cb->bflg.label)
	{
		REFS *rf;
		AREA *ar = P.area_now;
		FIXUP *f = o_fixup(cb->name, 0, FIX_lcent, 0);

		if (f)
		{
#if OPTBUG
	#if DEBUG
			if (debugJ)
	#endif
				console("%s:\n", cb->name);
#endif
			rf = get_label(ar, cb->name, 0);

			if (!rf)
			{
				ins_ref(&refmem, &ar->lbls, ar, f, CC_ranout);
				branch_aheads(ar, f); 	 /* branch operand reduction */
			}
			/* else internal error */
		}
	}
}

global
void o_lab(char *name)
{
	o_fixup(name, area_id,
			class_now eq GBSS_class
	     or class_now eq GDATA_class
			   ? FIX_glent
			   : FIX_lcent,
			0);
#if OPTBUG
	#if DEBUG
			if (debugJ)
	#endif
				if (*name)
					console("%s:\n", name);
#endif
}

global
void o_brdisp(OPND *arg, short sz, ushort w1, short cc, short area)
{
	long a = arg->disp;

	if (arg->astr)
	{
		short tlab = arg->tlab;
		Cstr name = arg->astr;
		AREA *ar = P.area_now;
		REFS *rf = get_label(ar, name, tlab);

		w1 |= cc << 8;

		if (rf)
		{
			long d = a + rf->fx->disp - (ar->limage + DOT_W);

			if (d >= -128 and d < 128)
			{
				w1 |= a & 0xff;
				o_fixup(name, area, FIX_sbra, tlab);
				advance(w1);
				return;
			}
			/* back branch.W is same as branch ahead */
		}

		if (sz eq DOT_B)
		{
			/* make branch.S */
			w1 |= a & 0xff;
			o_fixup(name, area, FIX_sbra, tlab);
			advance(w1);
		}
		elif (sz eq DOT_L)
		{
			/* make branch.L */			/* 11'09 HR: completely forgotten */
			w1 |= 0xff;
			advance(w1);
			o_fixup(name, area, FIX_lpcrel, tlab);
			advance_l(a);
		othw
			/* make branch.W */
			advance(w1);
			o_fixup(name, area, FIX_wbra, tlab);
			advance(a);
		}
	}
	elif (MO(arg->am) eq ABS)
	{
		w1 |= cc << 8;
		if (sz eq DOT_B or (a >= -128 and a < 128))
		{
			w1 |= a & 0xff;
			advance(w1);
		}
		elif (sz eq DOT_W)
		{
			a += 2;				/* Pasm compatible */
			if (a < -32768 or a > 32767)
				error("displacement out of range");
			advance(w1);
			advance(a);
		othw			/* DOT_L */				/* 11'09 HR: completely forgotten */
			w1 |= 0xff;
			advance(w1);
			advance_l(a);
		}
	}
	elif (MO(arg->am) eq INSTD)		/* 05'11 HR: '*' operand */
	{
		a -= 2;
		w1 |= cc << 8;
		if (sz eq DOT_B)
		{
			w1 |= a & 0xff;
			advance(w1);
		}
		elif (sz eq DOT_W)
		{
			if (a < -32768 or a > 32767)
				error("displacement out of range");
			advance(w1);
			advance(a);
		othw
			w1 |= 0xff;
			advance(w1);
			advance_l(a);
		}
	}
	else
		console("Bcc mode: 0x%04x disp: %ld\n", MO(arg->am), a);
}

global
void o_branch(OPND *op, short sz, short opc, short cc, short area)
{
	o_brdisp(op, sz, 0060000, cc, area);
}

global
void o_cpbranch(OPND *op, short opc, short cp, short cc, short size, short area, bool a)
{
	ushort w1 = 0170200 | cc;

	w1 |= cp << 9;			/* coprocessor id */

	if (size eq DOT_W)
	{
		advance(w1);
		o_fixup(op->astr, area, FIX_wpcrel, op->tlab);
		advance(0);
	othw
		w1 |= 0100;
		advance(w1);
		o_fixup(op->astr, area, FIX_lpcrel, op->tlab);
		advance_l(0);
	}
}

/* 01'11 HR: remove local entry fixups if not referenced */
static
bool no_refs(FIXUP *fx, AREA *ar)
{
#if 0
	FIXUP *f;

	if (fx->name eq nil or is_gl_entry(fx->fix.ty))
		return false;

	f = ar->fixups.first;

	while (f)
	{
		if (f->name and is_ref(f->fix.ty))
			if (f->name->nr eq fx->name->nr)
				return false;		/* Not no refs */

		f = f->next;
	}

	return true;
#else
	return false;
#endif
}

global
void o_endproc(void)
{
	AREA *ar = P.area_now;
	FIXUP *f;
	REFS *ef;

	/* fixup all anonymous entries */
	f = ar->fixups.first;
	while (f)
	{
		short sbra_adjust = 0;
		switch (f->fix.ty)
		{
			case FIX_wbra:
				f->fix.ty = FIX_wpcrel;			/* and fall thru */
			case FIX_wpcrel:
				if (is_tmplab(f))
				{
					ef = get_label(ar, f->name->s, f->name->tlab);		/* find entry */
					if (ef)
					{
						long d = ef->fx->disp - f->disp;
						short *to = (short *)(ar->image + f->disp);
						long nd = *to + d;
						if (nd < -32768 or nd > 32767)
							error("word pc relative overflow for %s", f->name->s);
						*to = nd;
#if F_VERBOSE
						send_msg("fixed %s.W 0x%04x%04x @ %ld --> %ld, dist %ld\n",
								f->name->s, *(to-1), *to, f->disp, ef->fx->disp, d);
#endif
					}
				}
			break;
			case FIX_sbra:
				sbra_adjust = DOT_W;			/* and fall thru */
			case FIX_bpcrel:
			if (*f->name->s)
			{
				ef = get_label(ar, f->name->s, f->name->tlab);		/* find entry */

				if (ef)
				{
					long d = ef->fx->disp - f->disp;
					d -= sbra_adjust;
					if (d)
					{
						char *to = ar->image + f->disp + 1;
						short nd = *to + d;
						if (nd < -128 or nd >= 128)
							error("byte pc relative overflow for %s", f->name->s);
						*to = nd;
#if F_VERBOSE
						send_msg("fixed %s.B 0x%04x @ %ld --> %ld, dist %ld\n",
								f->name->s, *to, f->disp, ef->fx->disp, d);
#endif
					}
					elif (f->fix.ty eq FIX_sbra)
					{
						short *to = (short *)(ar->image + f->disp);
						*to = 047161;			/* Bcc.s 0  would be wrong; change to nop */
#if F_VERBOSE
						send_msg("noppens %s\n", f->name->s);
#endif
					}
				}
				else
					error("byte pc relative label '%s' must be in same area", f->name->s);
			}
			break;
			case FIX_lpcrel:
				if (is_tmplab(f))
				{
					ef = get_label(ar, f->name->s, f->name->tlab);		/* find entry */
					if (ef)
					{
						long d = ef->fx->disp - f->disp;
						long *to = (long *)(ar->image + f->disp);
						*to = d;
#if F_VERBOSE
						send_msg("fixed %s.L 0x%08lx%08lx @ %ld --> %ld, dist %ld\n",
								f->name->s, *(to-1), *to, f->disp, ef->fx->disp, d);
#endif
					}
				}
			break;
		}

		f = f->next;
	}


	/* remove all anonymous fixups */
	/* !!! Only called for TEXT areas !!! */
	f = ar->fixups.first;
	while (f)
	{
		FIXUP *fx = f->next;
		short ty = f->fix.ty;

		switch (ty)
		{
			case FIX_sbra:
			case FIX_bpcrel:
				rem_list(&ar->fixups, f);
#if F_VERBOSE
				send_msg("removed fixup for %s\n", f->name->s);
#endif
			break;
			case FIX_wpcrel:
			case FIX_lpcrel:
				if (is_tmplab(f) or no_refs(f, ar))
				{
#if F_VERBOSE
					send_msg("[1]removed fixup for %s\n", f->name->s);
#endif
					f->name->nr = -1;		/* remove fixup if TLAB */
					rem_list(&ar->fixups, f);
				}
			break;
			case FIX_lcent:
				if (is_tmplab(f) or no_refs(f, ar))
				{
#if F_VERBOSE
					send_msg("[2]removed entry for %s\n", f->name->s);
#endif
					f->name->nr = -1;		/* remove fixup if  TLAB */
					rem_list(&ar->fixups, f);
				}
			break;
		}

		f = fx;
	}
}

#if C_DEBUG || OPTBUG
Cstr pascode   (short tok);
Cstr regnm(short x);

static
char *IXC_op(OPND *op)
{
	static char buf[4096], *b = buf, reg[8];
	OPMODE amd = op->am, am = amd;

	MO(am) &= MO_FF;
	*b = 0;
	switch (MO(am))
	{
	case REG:
		strcat(buf, regnm(op->areg));
	break;
	case REGI:
		strcat(buf, regnm(op->areg));
#if AMFIELDS
		if (amd.f.dec)
#else
		if (amd & DEC)
#endif
			strcat(buf, "-");
#if AMFIELDS
		elif (amd.f.inc)
#else
		elif (amd & INC)
#endif
			strcat(buf, "+");
		else
			strcat(buf, ".");
	break;
	case REGID:
		sprintf(buf, "%s.%ld", regnm(op->areg), op->disp);
	break;
	case PCD:
		if (op->disp)
			sprintf(buf, "pc.%ld", op->disp);
		else
			strcpy(buf, "pc");
	break;
	case REGIDX:
	{
#if AMFIELDS
		char *sz = (op->am.f.absw) ? ".w" : ".l";
#else
		char *sz = (op->am & ABSW) ? ".w" : ".l";
#endif
		char sc[4];

		strcpy(reg, regnm(op->ireg));
		if (op->scale)
			sc[0] = '*', sc[1] = '0' + (1 << op->scale), sc[2] = 0;
		else
			sc[0] = 0;

		sprintf(buf, "%ld(%s,%s%s%s)", op->disp, regnm(op->areg), reg, sz, sc);
	}
	break;
	case IMM:
#if AMFIELDS
		if (amd.f.symb)
#else
		if (amd & SYMB)
#endif
		{
			if (op->disp)
				sprintf(buf, "#%s+%ld", op->astr, op->disp);
			else
				sprintf(buf, "#%s", op->astr);
		}
		else
			sprintf(buf,"#%ld", op->disp);
	break;
	case CONDREG:
		sprintf(buf,"#0x%04lx", op->disp);
	break;
	case ABS:
		if (op->astr and op->disp)
			sprintf(buf, "%s+%ld", op->astr, op->disp);
		elif (op->astr)
			sprintf(buf, "%s", op->astr);
		else
			sprintf(buf, "%ld", op->disp);
	break;
	case SPPLUS:
		strcpy(buf, "sp+");
	break;
	case RLST:
		strcpy(buf, op->astr);
	break;
	}

	return buf;
}

static
char *opsz(IP ip)
{
	char c;
	static char s[4];
	s[0] = 0;
	if (ip->iflg.f.flt and ip->sz eq DOT_S)
		c = 's';
	else
	switch (ip->sz)
	{
	case DOT_B:
		c = 'b';
	break;
	case DOT_W:
		c = 'w';
	break;
	case DOT_L:
		c = 'l';
	break;
	case DOT_X:
		c = 'x';
	break;
	default:
		c = 0;
	break;
	}
	if (c)
	{
		s[0] = '.';
		s[1] = c;
		s[2] = 0;
	}
	return s;
}

global
void go_to(short to, char *s)
{
	char *t;
	short l = strlen(s);
	t = s + l;
	if (l < to)
		while (l < to)
			*t++ = ' ', l++;
	else
		*t++ = ' ';
	*t = 0;
}

global
void IXC_inst(IP ip)
{
	static char buf[4096];
#define start 5
	buf[0] = 0;

#if start
	go_to(start,buf);
#elif OPTBUG
	sprintf(buf, "%ld", ip->snr);
	go_to(start+5, buf);
#endif
	strcat(buf, pascode(ip->opcode));
	strcat(buf, opsz(ip));
	strlwr(buf);
	go_to(start+8, buf);
	if (ip->reg >= 0)
		strcat(buf, regnm(ip->reg));
	if (ip->arg)
	{
		go_to(start+12, buf);
		strcat(buf, IXC_op(ip->arg));
		if (ip->arg->next)
		{
			strcat(buf, ", ");
			strcat(buf, IXC_op(ip->arg->next));
		}
	}
	if (ip->bugstr)
	{
		go_to(start+24, buf);
		sprintf(buf+strlen(buf), "[%s]", ip->bugstr);
	}

	console("%s\n", buf);
}
#endif

global
void o_inst(IP ip)
{
	idata[ip->opcode].opr(ip);
#if OPTBUG
	#if DEBUG
		if (debugJ)
	#endif
			IXC_inst(ip);
#endif
}

static
void remove_dummy_areas(void)
{
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		AREA *ar = fl->areas.first;
		while (ar)
		{
			AREA *nx = ar->next;

			if (ar->limage eq 0)
			{
				bool have_entries = false;
				FIXUP *f = ar->fixups.first;

				if (f)
				{
					f = f->next;
					if (f)
					{
						if (    (   f->fix.ty eq FIX_lcmod
						         or f->fix.ty eq FIX_glmod
						        )
						    and f->name eq nil
						    or (     f->name
						        and *f->name->s eq WARN_AREA
						       )
						   )
						{
							while (f)
							{

								if (   f->fix.ty eq FIX_lcent
								    or f->fix.ty eq FIX_glent
								   )
								{
									have_entries = true;
									break;
								}

								f = f->next;
							}
						}
					}
				}
#if O_VERBOSE
				else
					console("area %s without fixups\n", ar->name ? ar->name : "");
#endif
				if (!have_entries)
				{
					FIXUP *f = ar->fixups.first;
					while (f)
					{
#if O_VERBOSE
						if (f->name)
							console("remove_dummy_areas: -1 --> %s\n", f->name->s);
						else
							console("remove_dummy_areas: target %d ty %d\n", f->target, f->fix.ty);
#endif
						if (f->name)
							f->name->nr = -1;

						f = f->next;
					}

					rem_list(&fl->areas, ar);
				}
			}
			ar = nx;
		}

		fl = fl->next;
	}
}

global
void setup_end(void)
{
	CC_xfree(P.po_tab);
	P.po_tab = nil;
	free_membase(&defmem);
	free_membase(&refmem);
	free_membase(&opndmem);
	XA_free_all(nil, AH_LD, -1);
	CC_ffree_all(AH_ASM);
	CC_xfree_all(AH_ASM);
	CC_ffree_all(AH_O_SETUP);
	CC_xfree_all(AH_O_SETUP);
	CC_ffree_all(AH_AREA_SETUP);
	CC_xfree_all(AH_AREA_SETUP);
	P.setup_done = false;
}

global
void o_end(short verbose)
{
	if (P.result eq 0 and !G.nmerrors)
	{
#if O_VERBOSE
		FLIST *fl = P.fbase.first;
		NAMEBASE *nmb = &fl->names;
		send_msg("number of PO names %d\n", nmb->high);
#endif
		remove_dummy_areas();
		write_object(P.fbase.first->name, verbose, true, CC_ranout);
	}
	setup_end();
}

global
bool ISAA(OPND *op)
{
	if (op)
		return MO(op->am) eq REG and ISA(op->areg);
	return false;
}

global
bool ISDD(OPND *op)
{
	if (op)
		return MO(op->am) eq REG and ISD(op->areg);
	return false;
}

global
bool ISFF(OPND *op)
{
	if (op)
		return MO(op->am) eq REG and ISF(op->areg);
	return false;
}

global
ushort o_size(IP ip)
{
	switch (ip->sz)
	{
	case DOT_B:
		return 0000;
	case DOT_W:
		return 0100;
	}
	return 0200;
}

global
ushort o_fsize(IP ip)
{
	switch (ip->sz)
	{
	case DOT_B:
		return 6<<10;
	case DOT_W:
		return 4<<10;
	case DOT_L:
#if DOT_L == DOT_S			/* avoid duplicate case */
		if (ip->iflg.f.flt)
			return 1<<10;
#endif
		return 0;
	case DOT_D:
		return 5<<10;
	case DOT_P:
		return 3<<10;
#if DOT_L != DOT_S			/* avoid duplicate case */
	case DOT_S:
		return 1<<10;
#endif
	case DOT_S+1:			/* avoid .l confusion */
		return 1<<10;
	case DOT_X:
		return 2<<10;
	}
	return 0;
}

global
ushort o_move(short sz)
{
	switch(sz)
	{
		case DOT_B:
			return 010000;
		case DOT_L:
			return 020000;
	}
	return 030000;
}

global
ushort o_ea(OPND *op)
{
	short reg;

	if (op eq nil)
		return 0;

	reg  = op->areg;
	reg -= ISA(op->areg) ? AREG : DREG;

	switch (MM(op->am))
	{
	case NONE:
		return 0;
	case REG:
		return ISA(op->areg) ? 010|reg : 000|reg;
	case IMM:
		return 074;
	case ABS:
		if (is_number(op))
		{
			if (op->astr)		/* 12'09 HR: already in op->disp ? */
				op->disp = atol(op->astr);
			op->astr = nil;
#if AMFIELDS
			if (op->am.f.absw)
				return 070;
			if (!op->am.f.absl)				/* 5'15 v5.2 */
				if (op->disp > -32768 and op->disp < 32768)
					return op->absw = 1, 070;
#else
			if (op->am & ABSW)
				return 070;
			if ((op->am & ABSL) eq 0)		/* 10'14 v5.2 */
				if (op->disp > -32768 and op->disp < 32768)
					return op->am |= ABSW, 070;
#endif

		}

		return 071;
	case REGI:
#if AMFIELDS
		if (op->am.f.dec)
#else
		if (op->am & DEC)
#endif
			return 040|reg;
#if AMFIELDS
		if (op->am.f.inc)
#else
		if (op->am & INC)
#endif
			return 030|reg;
		return 020|reg;
	case REGID:
		return 050|reg;
	case REGIDXX:
		if (op->areg eq -1)
			return 060;
	case REGIDX:				/* fall thru OK */
		return 060|reg;
	case PCD:
	case INSTD:					/* 05'11 HR: '*' operand */
		return 072;
	case PCDX:
	case PCDXX:
		return 073;
	case SPPLUS:
		return 037;
	default:
		error("OE: bad addr. mode in o_ea: %d\n", op->am);
		return 0;
	}
}

global
ushort o_dst_ea(OPND *op)
{
	short reg;

	if (op eq nil)
		return 0;

	reg  = op->areg;
	if (reg ne -1)
	{
		reg -= ISA(op->areg) ? AREG : DREG;
		reg <<= 9;
	}

	switch (MM(op->am))
	{
	case NONE:
		return 0;
	case REG:
		return ISA(op->areg) ? reg|0100 : reg|0000;
	case IMM:
		return 04700;
	case ABS:
		if (is_number(op))
		{
			if (op->astr)		/* 12'09 HR: already in op->disp ? */
				op->disp = atol(op->astr);
			op->astr = nil;
#if AMFIELDS
			if (op->am.f.absw)
				return 0700;
			if (!op->am.f.absl)			/* 5'15 v5.2 */
				if (op->disp > -32768 and op->disp < 32768)
					return op->am.f.absw = 1, 0700;
#else
			if (op->am & ABSW)
				return 0700;
			if ((op->am & ABSL) eq 0)		/* 10'14 v5.2 */
				if (op->disp > -32768 and op->disp < 32768)
					return op->am |= ABSW, 0700;
#endif

/*
console("o_dst_ea ABS 0x%04x = %s return 01700\n", op->amode, pr_amode(op->amode));
*/
		}
		return 01700;
	case REGI:
#if AMFIELDS
		if (op->am.f.dec)
#else
		if (op->am & DEC)
#endif
			return reg|0400;
#if AMFIELDS
		if (op->am.f.inc)
#else
		if (op->am & INC)
#endif
			return reg|00300;
		return reg|00200;
	case REGID:
		return reg|00500;
	case REGIDXX:
		if (op->areg eq -1)
			return 00600;
	case REGIDX:				/* fall thru OK */
		return reg|00600;
	case PCD:
	case INSTD:					/* 05'11 HR: '*' operand */
		return 02700;
	case PCDX:
	case PCDXX:
		return 03700;
	default:
		error("OE: bad addr. mode in o_dst_ea: %d\n", op->am);
		return 0;
	}
}

#if FLOAT
global
bool is_f(IP ip)
{
	if (ISF(ip->reg))
		return true;
	if (ip->arg)
		if (    MO(ip->arg->am) eq REG
		    and ISF(ip->arg->areg)
		   )
			return true;
	if (ip->sz eq DOT_D)
		return true;
	if (ip->sz eq DOT_X)
		return true;
	if (ip->iflg.f.flt)
		return true;
	return false;
}
#endif

#if 0
global
bool no_cf(IP ip)
{
	if (     ip->arg
	    and (ip->arg->amode&0xff) eq IMM
	   )
	{
		/* Not suitable for Coldfire */
		return true;
	}
	return false;
}
#endif

global
ushort o_x(short reg)
{
	if (reg >= 0)
		return reg - (ISA(reg) ? AREG : (ISF(reg) ? FREG : DREG));
	return 0;
}

global
ushort o_X(IP ip)
{
	return o_x(ip->reg);
}

global
ushort o_argX(IP ip)
{
	return o_x(ip->arg->areg);
}

global
ushort o_dst_X(IP ip)
{
	short reg = ip->reg;

	if (reg >= 0)
	{
		if (ISA(reg))
			return ((reg - AREG) << 9) | 0100;
		else
			return  (reg - DREG) << 9;
	}
	return 0;
}

global
ushort o_src_X(IP ip)
{
	short reg = ip->reg;

	if (reg >= 0)
	{
		if (ISA(reg))
			return (reg - AREG) | 0010;
		else
			return  reg - DREG;
	}
	return 0;
}

static
short fixup_type(OPMODE mode)
{
#if AMFIELDS
	bool w = mode.f.absw;
#else
	bool w = (mode & ABSW) ne 0;
#endif

	switch(MM(mode))
	{
		case PCD:		return FIX_wpcrel;
		case REGID:		return FIX_wabs;
		case PCDX:		return FIX_bpcrel;
		case PCDXX:
			if (w)
				return FIX_wpcrel;
			return FIX_lpcrel;
		default:
		if (w)
			return FIX_wabs;
		return FIX_labs;
	}
}

global
void operand_fixup(OPND *op)
{
	short ty = fixup_type(op->am);

	if (op->aname and P.area_po_names[op->areg])
	{
		short target;
		PO_NAME *pn = P.area_po_names[op->areg];

		AREA *ar = P.area_now;

#if O_VERBOSE
		if (op->disp)
			send_msg(" -- ANAME %s.%ld + %ld '%s'\n",
				pn->s, op->namedisp, op->disp, op->astr ? op->astr : "~");
#endif
		op->disp += op->namedisp;
		op->namedisp = 0;

		target = std_area_to_fix[class_now];

#if O_VERBOSE
		send_msg("operand_fixup: in area %s; %s @ %ld\t%s, op->areg %d\n",
		           pclass(class_now), fixup_name(ty), ar->limage, pn ? pn->s ? pn->s : "???" : "~~~", op->areg);
#endif
		new_fixup(&ar->fixups, pn, target, ty,
		           ar->image + ar->limage, ar->limage,
		           CC_ranout);
	}
	elif (op->astr)
		o_fixup(op->astr, op->areg, ty, op->tlab);
}

static
ushort o_ireg(OPND *op, ushort w2)
{
	if (ISA(op->ireg))
		w2 |= 0100000;
	w2 |= (op->ireg&7)<<12;
#if AMFIELDS
	if (op->am.f.xl)
#else
	if (op->am & XLONG)
#endif
		w2 |= 0004000;
	w2 |= (op->scale&3)<<9;

	return w2;
}

static
void o_ea_exx(OPND *op)
{
	ushort w2 = 0000400;		/* bit 8: extended modes ( NO 8 bit disp in extension word!!) */

	OPND *op_o = op->outd;

	if (op->areg eq -1)
		if (MM(op->am) ne PCDXX)
			w2 |= 0000200;			/* BS suppress base register */

	if (op->ireg eq -1)
		w2 |= 0000100;				/* IS suppress index register */
	else
		w2 = o_ireg(op, w2);
#if AMFIELDS
	if (op->am.f.bdisp)				/* implies x */
#else
	if (op->am & BDISP)				/* implies x */
#endif
	{
#if AMFIELDS
		if (op->am.f.absw)
#else
		if (op->am & ABSW)		/* base displacement size */
#endif
			w2 |= 2<<4;
		else
			w2 |= 3<<4;
	}
	else
		w2 |= 1<<4;				/* null base displacement */

#if AMFIELDS
	if (op->am.f.mind)
#else
	if (op->am & MIND)
#endif
	{
#if AMFIELDS
		if (op->am.f.inc)		/* postindexed */
			w2 |= 4;
		if (op->am.f.odisp)
#else
		if (op->am & POSTI)		/* postindexed */
			w2 |= 4;
		if (op->am & ODISP)
#endif
		{
			w2 |= 2;
#if AMFIELDS
			if (op_o->am.f.absw)
#else
			if ((op_o->am & ABSW) eq 0)
#endif
				w2 |= 1;
		}
		else						/* memory indirect with null outer displacement */
			w2 |= 1;
	}

	advance(w2);

#if AMFIELDS
	if (op->am.f.bdisp)
#else
	if (op->am & BDISP)
#endif
	{
		short m = MM(op->am);

/* PASM has error.
   See "MC68030 Enhanced 32 bit microprocessor user's manual"
        ISBN 0-13-566423-3 page 2-17,2-18,2-19:
        "The value of the PC is the address of the first extension word"

   Note that the fixup record MUST point to the address to be fixed up.
   So thats is why this value is adjusted (NOT the fixup procedure :-)
 */

		if (m eq PCDX or m eq PCDXX)
			if (op->astr)
				op->disp += DOT_W;

		operand_fixup(op);			/* base displacement fixup */
#if AMFIELDS
		if (op->am.f.absw)
#else
		if (op->am & ABSW)
#endif
			advance(op->disp);
		else
			advance_l(op->disp);
	}

#if AMFIELDS
	if (op->am.f.odisp)			/* with outer displacement */
#else
	if (op->am & ODISP)			/* with outer displacement */
#endif
	{
		operand_fixup(op_o);			/* outer displacement fixup */
#if AMFIELDS
		if (op_o->am.f.absw)
#else
		if (op_o->am & ABSW)
#endif
			advance(op_o->disp);
		else
			advance_l(op_o->disp);
	}
}

global
void o_ext(IP ip, OPND *op, short size)
{
	if (op eq nil)
#if OPTBUG
		send_msg("**** o_ext nil %s %d snr %ld bugstr %s arg %lx dst %lx ****\n",
				idata[ip->opcode].text,
				ip->sz,
				ip->snr,
				ip->bugstr ? ip->bugstr : "~~~",
				ip->arg,
				ip->arg ? ip->arg->next : 0L);
#else
		send_msg("**** o_ext nil ****\n");
#endif
	else
	switch (MM(op->am))
	{
	case IMM:
		if (size eq DOT_L)
		{
#if AMFIELDS
			if (op->am.f.symb)
#else
			if (op->am & SYMB)
#endif
				operand_fixup(op);
			advance_l(op->disp);
		}
		elif (size eq DOT_B)
			advance(op->disp & 0xff);
		else
			advance(op->disp);		/* a zero size has always been the default */
	break;
	case ABS:
		operand_fixup(op);

#if AMFIELDS
			if (op->am.f.absw)
#else
			if (op->am & ABSW)
#endif
			advance  (op->disp);
		else
			advance_l(op->disp);
	break;
	case REGID:
		operand_fixup(op);
		advance(op->disp);
	break;
	case REGIDXX:
		o_ea_exx(op);		/* + bit 8 */
	break;
	case REGIDX:
	{
		ushort w2 = op->disp & 0xff;
		w2 = o_ireg(op, w2);
		advance(w2);
	}
	break;
	case PCD:
		operand_fixup(op);
		advance(op->disp);
	break;
	case INSTD:						/* 05'11 HR: '*' operand */
		advance(op->disp-2);		/* preliminary; probably only works with 1st operand. */
	break;
	case PCDX:
	{
		ushort w2 = op->disp & 0xff;
		w2 = o_ireg(op, w2);
		operand_fixup(op);
		advance(w2);
	}
	break;
	case PCDXX:
		o_ea_exx(op);		/*  + bit 8 */
	break;
	}
}

global
void o_even(void)
{
	if (P.area_now)
	{
		AREA *ar = P.area_now;
		if (ar->limage & 1)
		{
			if (ar->target eq FIX_bss)
				ar->limage++;
			else
				advance_b(0);
		}
	}
}

global
void o_area_end(void)
{
	o_even();
}

global
AREA * o_area_setup(short class, short area, Cstr start_txt)
{
	AREA *new;
	short st = std_area_to_fix[class];

#if O_VERBOSE
	send_msg("making area %d %s\n", area, start_txt);
#endif

	new = new_area(P.fbase.first, st, start_txt, CC_ranout);
	if (new)
	{
		P.area_now = new;
		new->id   = area;
		new->class = class;
		class_now = class;
		if (!no_image(st))
		{
			new->image = CC_fmalloc(START_ALLO, AH_AREA_SETUP, CC_ranout);
			if (new->image)
				new->allo = START_ALLO;
		}

		/* a area is its own target */
		/* This fixup intruduce the major segments known as -1 (no name) */
		new_fixup(&new->fixups, nil, st, st, new->image, 0, CC_ranout);
	}

	return new;
}

global
bool o_AREA(short class)
{
	if (P.in_module and !P.in_func and class_now ne class)
		error("change of segment within module not allowed");
	else
	{
		if (class_now ne class)
		{
#if O_VERBOSE
			console("o_AREA %d\n", class);
#endif
			class_now = class;
			return true;
		}
	}
	return false;
}

global
bool can_quick(IP ip)
{
	OPND *op = ip->arg;

	return
#if FLOAT
	           ! is_f(ip)
	       and
#endif
	           MO(op->am) eq IMM
	       and op->disp   > 0
	       and op->disp  <= 8
	       ;
}

global
void o_cond(IP ip, ushort w1)
{
	w1 |= ip->arg->next->disp << 6;
	advance(w1);
	o_ext(ip, ip->arg, DOT_W);
}

global
void o_imm(IP ip, ushort w1)
{
	w1 |= o_ea(ip->arg->next);
	w1 |= o_size(ip);
	advance(w1);
	o_ext(ip, ip->arg,       ip->sz);
	o_ext(ip, ip->arg->next, ip->sz);
}

global
void o_imma(IP ip, ushort w1)
{
	w1 |= ip->sz eq DOT_W ? 0300 : 0700;
	ip->reg = ip->arg->next->areg;
	ip->arg->next = nil;
	o_arith(ip, w1 , -1, -1, false);
}

global
void o_Iquick(IP ip, ushort w1)
{
	w1 |= (ip->arg->disp&7)<<9;	/* 0=8 */
	w1 |= o_size(ip);
	w1 |= o_ea(ip->arg->next);
	advance(w1);
	o_ext(ip, ip->arg->next, ip->sz);
}

global
void o_Qimm(IP ip, ushort w1, ushort wq)
{
	if (can_quick(ip))
		o_Iquick(ip, wq);
	else
		o_imm(ip, w1);
}

#if FLOAT
global
void o_cpgenx(IP ip, short op)
{
	OPND *arg = ip->arg;
	ushort w1 = 0171000, w2;

	if (arg eq nil)
	{
		advance(w1);
		w2  = o_X(ip)<<10;						/* fpm */
		w2 |= o_X(ip)<<7;						/* = fpn */
		w2 |= op;
		advance(w2);
	}
	elif (    MO(arg->am) eq REG
	      and ISF(arg->areg)
	      and ISF(ip->reg)
	   )
	{								/* fpm,fpn */
		advance(w1);
		w2  = (arg->areg - FREG) << 10;			/* fpm */
		w2 |= o_X(ip)<<7;						/* fpn */
		w2 |= op;
		advance(w2);
	}
	elif (ip->reg >= F0)							/* <ea>,fpn */
	{
		w1 |= o_ea(ip->arg);		/* ea */
		advance(w1);
		w2  = o_X(ip)<<7;			/* fpn */
		w2 |= o_fsize(ip);
		w2 |= 040000;				/* r/m */
		w2 |= op;
		advance(w2);
		o_ext(ip, arg, ip->sz);
	}
	elif (op eq 0)				/* fmove fpm,<ea> */
	{
		OPND *dst = ip->arg->next;
		if (dst)
		{
			w1 |= o_ea(dst);		/* ea */
			advance(w1);
			w2  = o_argX(ip)<<7;		/* fpm */
			w2 |= o_fsize(ip);
			w2 |= 060000;				/* r/m + B13 */
			advance(w2);
			o_ext(ip, dst, ip->sz);
		}
		else
			console("OE: fmove fpn, <ea>, NO DST\n");
	}
	elif (ip->reg < 0 and arg)	/* ftst  <ea> */
	{
		w1 |= o_ea(arg);		/* ea */
		advance(w1);
		w2  = o_fsize(ip);
		w2 |= 040000;				/* r/m */
		w2 |= op;
		advance(w2);
		o_ext(ip, arg, ip->sz);
	}
#if DEBUG
	else
		console("-= o_cpgenx: nop =-\n");
#endif
}

global
void o_cpgens(IP ip, short op)
{
	OPND *arg = ip->arg;
	ushort w1 = 0171000, w2;

	if (ip->arg eq nil)
	{
		advance(w1);
		w2  = o_X(ip)<<10;						/* fpm */
		w2 |= o_X(ip)<<7;						/* fpn */
		w2 |= op;
		advance(w2);
	}
	elif (    MO(ip->arg->am) eq REG
	      and ISF(ip->arg->areg)
	      and ISF(ip->reg)
	   )
	{
		advance(w1);
		w2  = (arg->areg - FREG) << 7;		/* fpn */
		w2 |= o_X(ip)<<10;						/* fpm */
		w2 |= op;
		advance(w2);
	othw
		w1 |= o_ea(arg);			/* ea */
		advance(w1);
		w2  = o_X(ip)<<7;			/* fpn */
		w2 |= o_fsize(ip);
		w2 |= 040000;				/* r/m */
		if (op eq 0)
			w2 |= 020000;			/* ea->fp, fp->ea */
		w2 |= op;
		advance(w2);
		o_ext(ip, arg, ip->sz);
	}
}
#endif

global
void o_Lmd(IP ip, ushort w1, ushort w2, ushort size)
{
	OPND *ea = ip->arg;
	short Dh = o_X(ip);
	w2 <<= 10;
	w1 |= o_ea(ea);
	advance(w1);
	if (ea->next)			/* if dst, reg is remainder, dst quotient */
	{
		short Dl = o_x(ea->next->areg);
		if (Dh eq Dl)
		{
			error("Internal: long mul/div same Dn:Dm %d", Dh);
		}
		w2 |= Dh;
		w2 |= Dl << 12;
		w2 |= size << 10;
	othw
		w2 |= Dh << 12;
		if ((w1 & 0100) ne 0)	/* for div.l: */
			w2 |= Dh;			/* Dr = Dq, AHCC doesnt use this for long quotient yet. */

	}
	advance(w2);
	o_ext(ip, ea, DOT_L);
}

global
void o_arith(IP ip, ushort w1, ushort fop, FLO_DIRECTION to, bool havesz)
{
#if FLOAT
	if (is_f(ip))
		(to > 0 ? o_cpgens(ip, fop) : o_cpgenx(ip, fop));
	else
#endif
	{
		if (havesz)
			w1 |= o_size(ip);
		w1 |= o_X(ip)<<9;
		w1 |= o_ea(ip->arg);
		advance(w1);
		o_ext(ip, ip->arg, ip->sz);
	}
}

global
void o_Aquick(IP ip, ushort w1)
{
	w1 |= (ip->arg->disp&7)<<9;	/* 0=8 */
	w1 |= o_X(ip);
	if (ISA(ip->reg))
	{
		ip->sz = DOT_L;		/* 01'10 HR: .l for An */
		w1 |= 010;
	}
	w1 |= o_size(ip);
	advance(w1);
}

global
void o_Qarith(IP ip, ushort w1, ushort fop, FLO_DIRECTION to, ushort wq)
{
	if (can_quick(ip))
		o_Aquick(ip, wq);
	else
	{
		if ((w1&0400) ne 0 and MO(ip->arg->am) eq REG)
		{
			short x = ip->reg;
			ip->reg = ip->arg->areg;
			ip->arg->areg = x;
			w1 &= ~0400;
		}
		if (ISA(ip->reg))
		{
			w1 |= ip->sz eq DOT_W ? 0300 : 0700;
			o_arith(ip, w1, 0, 0, false);
		}
		else
		{
			o_arith(ip, w1, fop, to, true);
		}
	}
}

global
void o_shiftx(IP ip, ushort w1)
{
	OPND *arg = ip->arg;
	if (ip->reg eq -1)			/* memory shift */
	{
		w1 |= (w1 & 030) << 6;		/* holy shit! have to move the shift type somewhere else */
		w1 &= 0177700;

		w1 |= 0300;
		w1 |= o_ea(arg);
		advance(w1);
		o_ext(ip, arg, 0);
	othw
		w1 |= o_size(ip);
		w1 |= o_X(ip);
		if (MO(arg->am) eq IMM)
		{
			if (arg->disp > 8)
			{
				advance(w1);		/* 11'10 HR: 0 = 8 */
				arg->disp -= 8;
			}
			w1 |= (arg->disp&7)<<9;
		}
		elif (MO(arg->am) eq REG)
		{
			w1 |= 040;
			w1 |= (arg->areg&7)<<9;
		}
		advance(w1);
	}
}

global
void o_shifts(IP ip, ushort w1)
{
	OPND *arg = ip->arg;
	w1 |= o_size(ip);
	w1 |= o_X(ip)<<9;
	w1 |= 040;
	w1 |= (arg->areg&7);
	advance(w1);
}

global
void o_genx(IP ip, ushort w1, short fop)
{
#if FLOAT
	if (fop > 0 and is_f(ip))
		o_cpgenx(ip, fop);
	else
#endif
	{
		w1 |= o_size(ip);
		w1 |= o_X(ip);
		advance(w1);
	}
}

global
void o_gens(IP ip, ushort w1, short fop)
{
#if FLOAT
	if (fop > 0 and is_f(ip))
		o_cpgenx(ip, fop);			/* !!! genx OK !!! */
	else
#endif
	{
		w1 |= o_size(ip);
		w1 |= o_ea(ip->arg);
		advance(w1);
		o_ext(ip, ip->arg, ip->sz);
	}
}

global
void o_jump(IP ip, ushort w1)
{
	w1 |= o_ea(ip->arg);
	advance(w1);
	o_ext(ip, ip->arg, ip->sz);
}

static
void canmoveq(IP ip, bool s)
{
	OPND *arg = ip->arg;
	ushort w1;
	short sz = ip->sz;
	/* in assem only moveq when size is DOT_L */
	/* C doesnt preserve parts of a register */
	if (!ISA(ip->reg) and !(s and sz ne DOT_L)
	    and MO(arg->am) eq IMM
	    and arg->disp >= -128
	    and arg->disp <   128
	   )
	{
		w1  = 070000;				/* moveq */
		w1 |= ip->reg<<9;
		w1 |= arg->disp&0xff;
		advance(w1);
	othw
		w1  = o_move(sz);
		w1 |= o_ea(arg);
		w1 |= o_dst_X(ip);
		advance(w1);
		o_ext(ip, arg, sz);
	}
}

global
void o_move_eaea(IP ip)
{
	ushort w1;
	short sz = ip->sz;

	if (!ip->arg)
	{
#if OPTBUG
		console("[1]arg nil %ld\n", ip->snr);
#else
		console("[1]arg nil\n");
#endif
		return;
	}

#if FLOAT
	if (is_f(ip))
		if (sz eq DOT_S)
			ip->iflg.f.flt = 0;		/* float move ea,ea done by move.l */
#endif
#if COLDFIRE
	if (G.Coldfire and !G.i2_68020)
	{
		OPND *dst = ip->arg->next;
		if (    ip->sz eq DOT_L
			and MO(ip->arg->am) eq IMM
			and can_3q(ip->arg->disp)
			and !op_dreg(dst)
		   )
		{
			if (ip->arg->disp eq -1)
				ip->arg->disp = 0;		/* VERY special */
			w1 = 0120500;				/* mov3q */
			w1 |= ip->arg->disp << 9;
			w1 |= o_ea(ip->arg->next);
			advance(w1);
			o_ext(ip, ip->arg->next, sz);
			return;
		}
	}
#endif
	w1  = o_move(sz);
	w1 |= o_dst_ea(ip->arg->next);
	w1 |= o_ea    (ip->arg);
	advance(w1);
	o_ext(ip, ip->arg,       sz);
	o_ext(ip, ip->arg->next, sz);
}

global
void o_move_eadn(IP ip, bool s)
{

	if (!ip->arg)
	{
#if OPTBUG
		console("[2]arg nil %ld\n", ip->snr);
#else
		console("[2]arg nil\n");
#endif
		return;
	}

#if FLOAT
	if (is_f(ip))
		o_cpgenx(ip, 0);
	else
#endif
		canmoveq(ip, s);
}

global
void o_cpdbcc(IP ip, short cp, short cc)
{
	ushort w1 = 0170110;

	w1 |= o_X(ip);
	w1 |= cp << 9;
	advance(w1);
	advance(cc);
	o_fixup(ip->arg->astr, ip->arg->areg, FIX_wpcrel, ip->arg->tlab);	/* make non reducable branch.W */
	advance(0);
}

global
void o_cptrapcc(IP ip, short cp, short cc)
{
	ushort w1 = 0170170;
	short s = ip->sz eq DOT_W ? 2 : ip->sz eq DOT_L ? 3 : 4;

	w1 |= s;
	w1 |= cp << 9;
	advance(w1);
	advance(cc);

	if (s < 4)
		o_ext(ip, ip->arg, ip->sz);
}
