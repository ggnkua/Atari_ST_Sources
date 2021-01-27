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

/*	DIGPAGE.C
 *	=========
 */

#include <string.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>

#include "common/mallocs.h"
#include "common/aaaa_lib.h"
#include "aaaa.h"
#include "common/cursor.h"
#include "text/text.h"
#include "common/config.h"
#include "common/journal.h"
#include "common/ahcm.h"
#include "ttd_kit.h"
#include "ttd_cfg.h"
#include "ttdisass.h"
#include "dig.h"
#include "digobj.h"
#include "dig_it.h"

#define SHOWMARKS 0

static
bool toolong;
static long ii;

bool is_ram(DW *dw)
{
	return z ty eq OBJ+MNRAM;
}

global
void nl(IT *w, short which)
{
	short tx, ty, lw = pos-regel, hl;
	DW *dw = w->dw;

	hl = w->hl;

	if (z fil)
		*pos = 0, fprintf(ofile, "%s\n", regel);
	elif (ii > 0)
	{
		if (cfg.hslider)
		{
			if (lw > w->view.sz.w)
				w->view.sz.w = lw;
			if (lw-w->norm.pos.x > w->norm.sz.w)
				pos = regel+w->norm.sz.w-w->norm.pos.x;
		}
		elif (lw > w->norm.sz.w)
		{
			toolong = true;
			*(regel+w->norm.sz.w-2) = 3;		/* pijl -> */
			*(regel+w->norm.sz.w-1) = 3;
			*(regel+w->norm.sz.w  ) = 0;
		}
		*pos = 0;
		lw = pos-regel-w->norm.pos.x;
		if (lw < 0)
			lw = 0;
		ty = w->ma.y+(w->unit.h*z lnr);
		tx = w->ma.x;
		f_txt(hl, tx, ty, regel+w->norm.pos.x);
		if (lw < w->norm.sz.w)
			pbox(hl, tx+(w->unit.w*lw), ty, tx+(w->norm.sz.w*w->unit.w)-1, ty+w->unit.h-1);

		if (w->dis.ssel.b)
		{
			if (w->dis.ssel.b eq w->dis.pc0.b and w->dis.ssel.b eq w->dis.esel.b)
			{
				vsf_color(hl, 1);		/* solid black */
				vswr_mode(hl, 3);
				pbox(hl, w->ma.x, ty, w->ma.x+(z lbl_len+1)*w->unit.w, ty+w->unit.h-1);
				vswr_mode(hl, 0);
				vsf_color(hl, 0);
			}
			elif (w->dis.ssel.b <= w->dis.pc0.b and w->dis.pc0.b < w->dis.esel.b)
			{
				vsf_color(hl, 1);
				vswr_mode(hl, 3);
				pbox(hl, w->ma.x, ty, w->ma.x+w->ma.w-1, ty+w->unit.h-1);
				vswr_mode(hl, 0);
				vsf_color(hl, 0);
			}
		}
		if (w->dis.ruler.b >= w->dis.pc0.b and w->dis.ruler.b < z pc.b)  /* ref found */
			box(hl, w->ma.x, ty, w->ma.x+w->ma.w-1, ty+w->unit.h-1);
	}

	vst_color(hl, 1);
	z prcol = 0;
	vst_effects(hl, 0);
	z lnr++;
	ii--;
}

static
void init_page(IT *w)
{
	DW *dw = w->dw;

	if (z fil)
		ii = 0x7ffffffe;	/* sufficiently high value only used for break_in chunking */
	else
	{
		if (w->cf.spg.b ne w->dis.history[w->dis.his_ptr].b)
		{
			w->dis.his_ptr += 1;
			w->dis.his_ptr &= HISTN-1;
			w->dis.history[w->dis.his_ptr] = w->cf.spg;
		}
		ii = w->norm.sz.h;		/* exact no lines that will fit !!! */
	}
	z pc = w->cf.spg;
}

static
void header(IT *w)
{
	DW *dw = w->dw;

	il(w);
	*pos++ = '*';
	oc(dw, "TEXT", 0);
	pdhex(w->dis.ltext, 6, &w->cg);
	print(bytes);
	if (w->dis.ltext > 0)
		print(frstr(SEG_STA)), address(dw, z org.b);
	nl(w,1);

	il(w);
	*pos++ = '*';
	oc(dw, "DATA", 0);
	pdhex(w->dis.ldat, 6, &w->cg);
	print(bytes);
	if (w->dis.ldat > 0)
		print(frstr(SEG_STA)), address(dw, z dat.b);
	nl(w,2);

	il(w);
	*pos++ = '*';
	oc(dw, "BSS", 0);
	pdhex(w->dis.lbss, 6, &w->cg);
	print(bytes);
	if (w->dis.lbss > 0)
		print(frstr(SEG_STA)), address(dw, z bss.b);
	nl(w,3);
	if is_PC
	{
		il(w);
		*pos++ = '*';
		oc(dw, "FIXUPS", 0);
		pdhex(w->dis.lfix, 6, &w->cg);
		print(bytes);
		nl(w,4);

		il(w);
		*pos++ = '*';
		oc(dw, "NAMES", 0);
		pdhex(w->dis.lnam, 6, &w->cg);
		print(bytes);
		nl(w,5);

		il(w);
		*pos++ = '*';
		oc(dw, "names", 0);
		pdhex(z L.no, 6, &w->cg);
		nl(w,6);
		if (w->dis.debug)
		{
			il(w);
			*pos++ = '*';
			oc(dw, w->dis.extra ? "EXTRA" : "DEBUG", 0);
			pdhex(w->dis.debug, 6, &w->cg);
			print(bytes);
			nl(w,7);
		}
	othw
		il(w);
		*pos++ = '*';
		oc(dw, "SYMBOLS", 0);
		pdhex(w->dis.lsym, 6, &w->cg);
		print(bytes);
		nl(w,8);
	}
	if (!is_PC)
	{
		il(w);
		*pos++ = '*';
		oc(dw, "FLAGS", 0);
		prhexl(*(z org.w-2), 4);			/* 10'12 HR prgflags */
		*pos++ = ' ';
		prhexl(*(z org.w-1), 4);			/* absflag */
		nl(w,9);
	}
	if (w->cg.sym and w->cg.xref[0] eq 0)
	{
		il(w);
		*pos++ = '*';
		oc(dw, frstr(EXTLIST), 0);
		nl(w,10);
	}
	if (w->cg.sym and w->cg.moduul[0] eq 0)
	{
		il(w);
		*pos++ = '*';
		oc(dw, frstr(MODSUP), 0);
		nl(w,11);
	}
	il(w), nl(w,12);
}

static
short after_oc(IT *w, char *str)
{
	short s;
	pos = regel;
	oc(w->dw, str, 0);
	s = pos-regel;
	pos = regel;
	return s;
}

static
void defines(IT *w)
{
	DW *dw = w->dw;
	long i, j;
	short s, t = w->wa.w/CHAR_BIT;

	if (is_PC and w->cg.sym)
	{
		if (w->cg.xref[0])
		{
			s = after_oc(w, w->cg.xref);
			j = t;
			for (i = 0;i<z L.no;i++)
				if (z PL[i].ty > FIX_f and z PL[i].n[0] > 0)
				{
					short l = z PL[i].n[0];
					if (j+l+1 < t and l < t-s)
						*pos++ = ',';
					else
					{
						j = s;
						nl(w,20), il(w), oc(dw, w->cg.xref, 0);
					}
					print(pure_name(z PL[i].n));
					j += l+1;
				}
			nl(w,201); il(w);
		}

		s = after_oc(w, w->cg.xdef);
		j = t;
		for (i = 0;i<z L.no;i++)
			if (z PL[i].ty eq FIX_glmod or z PL[i].ty eq FIX_glent)
			{
				short l = z PL[i].n[0];
				if (j+l+1 < t and l < t-s)	/* if very large name, at least the one */
					*pos++ = ',';
				else
				{
					j = s;
					nl(w,21), il(w), oc(dw, w->cg.xdef, 0);
				}
				keep_label(dw, z org.b+z PL[i].v, pos-regel);
				print(pure_name(z PL[i].n));
				keep_end_label(dw, 1);
				j += l+1;
			}
		nl(w,22);
	}
	elif (w->cg.sym and z reloff)
	{
		SYM *S = z S;
		if (w->cg.xref[0])
		{
			s = after_oc(w, w->cg.xref);
			j = t;
			for (i = 0; i<w->dis.syms; i++)
				if ( (S[i].ty&8) ne 0 and S[i].v eq 0)
				{
					short l;
					dri_name(S[i].n, S[i].d, z sozobon);	/* 5'99 RA: .d */
					l = strlen(pcn);
					if (j+l+1 < t and l < t-s)
						*pos++ = ',';
					else
					{
						j = s;
						nl(w,23), il(w), oc(dw, w->cg.xref, 0);
					}
					print(pcn);
					j += l+1;
				}
			nl(w,24); il(w);
		}

		s = after_oc(w, w->cg.xdef);
		j = t;
		for (i = 0; i<w->dis.syms; i++)
		{
			short ty = S[i].ty;
			if ( !  ( (ty&8)    ne 0 and S[i].v eq 0)
				and ( (ty&0x20) ne 0)   )
			{
				short l; long adj = 0;
				char *drn = dri_name(S[i].n, S[i].d, z sozobon);	/* 5'99 RA: .d */
				switch (ty&7)
				{
					case 4: adj = w->dis.ltext; break;
					case 1: adj = w->dis.ltext + w->dis.ldat; break;
				}

				l = strlen(drn);
				if (j+l+1 < t and l < t-s)
					*pos++ = ',';
				else
				{
					j = s;
					nl(w,25), il(w), oc(dw, w->cg.xdef, 0);
				}
				keep_label(dw, z org.b+S[i].v+adj, pos-regel);
				print(drn);
				keep_end_label(dw, 2);
				j += l+1;
			}
		}
		nl(w,26); il(w);

		for (i = 0; i<w->dis.syms; i++)
			if   ( (S[i].ty&0x48) eq 0x40 ) ;
			elif ( (S[i].ty&8   ) ne 0 )
			if   (  S[i].v        ne 0 )
			{
				il(w);
				oc(dw, w->cg.comm, 0);
				print(dri_name(S[i].n, S[i].d, z sozobon));	/* 5'99 RA: .d */
				*pos++ = ',';
				pdhex(S[i].v, 8, &w->cg);
				nl(w,27);
			}
	}
	il(w), nl(w,28);
}

static
bool new_section(IT *w, char *x)
{
	DW *dw = w->dw;

	if (ii < 2)
		return false;
	tab(dw, dw->t1);
	print(x);
	nl(w,29);
	il(w), nl(w,30);
	il(w);
	return true;
}

global
void check_mod(DW *dw)
{
	IT *w = dw->w;

	if (z modactive and w->cg.endmod[0])
	{
		print(w->cg.endmod);
		nl(w,31);
		il(w);
#if 0
		nl(w,32);
		il(w);
#endif
	}
	z modactive = false;
}

extern bool mop15;

static
bool standard(IT *w)
{
	DW *dw = w->dw;

	PC pc = z pc, pc0 = pc;
	phex(pc.b-z shift.b, w->cg.rdx, z lbl_len);
	print(w->cg.labelsep);

	if (pc.b < z bss.b-1 and (pc.i&1) eq 0)
	{
		if (z fil and w->dis.fend.b > 0 and pc.b >= w->dis.fend.b)
			return nl(w,33), false;

		if (rel(dw, pc.b))
			ocl(dw, "dc", 4), z pc = long_abs(dw, pc, false);
		elif (btst(z dt, pc.b-z org.b) or btst(z dt, pc.b-z org.b+1))
			ocl(dw, "dc", 3), pdhex(*pc.u, 4, &w->cg), z pc.w = ++pc.w;
		else
		{
			short disok = disass(dw);

			if (z coldfire and z pc.w - pc.w > 3)
				disok = 1;

			if (disok ne 0)
			{
				vst_color(w->hl, 2);
				vst_effects(w->hl, bold);
				if (disok > 0)
				{
					z openline = false;
					pos = z pos1;
					tabgain = tabgain1;
					z pc.w = ++pc.w;
				}
				ocl(dw, "dc", 3);
				pdhex(*pc0.u, 4, &w->cg);
			}
		}
	}
	elif (pc.b < z bss.b)
	{
		ocl(dw, "dc", 1);
		pdhex((uint)*pc.b, 2, &w->cg);
		z pc.b = ++pc.b;
	}
	else
	{
		check_mod(dw);
		oc(dw, "end", 0);
		nl(w,34);
		return false;
	}

	mop15 = false;
	return true;
}

static
void dc_b(IT *w, PC pc)
{
	DW *dw = w->dw;
	PC pc0 = pc;
	bool quo, brkl, stri;
	long j;

	ocl(dw, "dc", 1);
	if (!w->cg.opc)
		j = min(z bss.i, (pc.i+8)&-2L);
	else
		j = z bss.i;
	quo = false;
	brkl = false;
	stri = false;
	do
	{
		uchar c = *pc.k;
		if (w->cg.tvis[c] eq c)
		{
			if (!quo)
			{
				if (brkl) break;
				quo = true;
				stri = true;
				if (pc.b > pc0.b)
					*pos++ = ',';
				*pos++ = '\'';
			}
			*pos++ = c;
			if (c eq '\'')
				*pos++ = c;	/* extra ' */
			pc.b++;
		othw
			if (pc.b > pc0.b)
			{
				if (quo)
					quo = false, *pos++ = '\'';
				*pos++ = ',';
			}
			pdhex(c, 2, &w->cg);
			pc.b++;
			if ( (pc.i&1) eq 0 and pc.b >= pc0.b+8 )
				break;
			if (stri and c < 16)
				brkl = true;
		}

		if (w->dis.jt)
			if (btst(w->dis.jt, pc.b-z org.b))
				break;

		if ((pc.i&1) eq 0)
			if (  !btst(z dt, pc.b-z org.b+1)
				or rel(dw, pc.b) )
				break;
		if (btst(z lab, pc.b-z org.b))
			break;
		if (pos+tabgain > w->dis.t74)
			break;
	} while (pc.i < j);
	if (quo)
		*pos++ = '\'';
	z pc = pc;
}

static
bool wd_lab(IT *w, long start, long cur, long *target)
{
	DW *dw = w->dw;
	long di = cur/sizeof(uint), ddx = start + *(z org.w + di);		/* absolute target address */
	bool ok = false;

	if (              ddx >= 0
	    and z org.i + ddx <  z bss.i)		/* check against limits */
	{
		bset(z lab, ddx);
		ok = true;
	}

	if (target)
		*target = ddx;
	return ok;
}

void have_jt(IT *w, long pc, long x);

global
void scan_jt(IT *w, bool msg)
{
	DW *dw = w->dw;
	bool *jt;
	long *lt, l = w->dis.s_jt*CHAR_BIT, d = 0;				/* bit nr for jt; byte nr for image */
	bool longs;

	jt = w->dis.jt, lt = (long *)jt;
	while(d < l)
	{
		long start;

		longs = (d&31) eq 0;
		if (longs and *lt eq 0)
		{
			d += 32;
			lt++;
		othw
			longs = false;
			while (!btst(jt, d) and d < l)
			{
				d += 2;				/* find first bit (there must be 1) */
				longs = (d&31) eq 0;
				if (longs)			/* end of empty part at end of long; switch to whole longs */
				{
					lt++;
					break;
				}
			}

			if (!longs)
			{
				bset(z lab, d);
				start = d;

				while ( btst(jt, d) and d < l)
				{
					long ddx;
					bool ok = wd_lab(w, start, d, &ddx);
					if (ok and msg)
						have_jt(w, d, ddx);
					d += 2;
					longs = (d&31) eq 0;
					if (longs)
						lt++;			/* No of longs */
					if (btst(jt, d+1))
						break;
				}
			}
		}
	}
}

void dc_jmpt(IT *w, PC pc)
{
	DW *dw = w->dw;
	short disp = *pc.w;
	long target,
	     d  = pc.b - z org.b,
	     start;
	bool ok;

	/* find start of jt series */
	while(    d							/* while marked as word */
		  and btst(z dt, d) ne 0
		  and btst(z dt, d+1) eq 0
		  and !(    btst(z dt, d+2) eq 0
		        and btst(z dt, d+3) ne 0
		       )
		 )
	{
		if (btst(w->dis.jt, d) and btst(w->dis.jt, d+1))	/* 2 bits: start of serie */
			break;
		if (!btst(w->dis.jt, d))
		{
			d += 2;
			break;	/* This is not a good start, but we will accept it */
		}
		d -= 2;
	}

	start = d;
	d -= (pc.b - z org.b);	/* disp with start of series */

	ok = wd_lab(w, start, pc.b - z org.b, &target);

	ocl(dw, "dc", 3);

	if (btst(z lab, start))		/* start series already labeled ? */
	{
		if (ok and btst(z lab, target))	/* target ok and already labeled ? */
		{
			address(dw, z org.b + target);
			*pos++ = '-';
			address(dw, z org.b + start);
		othw
			*pos++ = '*';
			*pos++ = '-';
			address(dw, z org.b + start);
			*pos++ = '+';
			pdhex(disp+d, -1, &w->cg);
		}
	othw					/* start of series not labeled */
		if (ok and btst(z lab, target))	/* target ok and already labeled ? */
		{
			address(dw, z org.b + target);
			*pos++ = '-';
			*pos++ = '(';
			*pos++ = '*';
			if (d)
				psdhex(d, -1, &w->cg);
			*pos++ = ')';
		othw						/* no labels at all */
			*pos++ = '*';				/* all those stars show that it is a jump table */
			*pos++ = '+';
			pdhex(disp+d, -1, &w->cg);
			*pos++ = '-';
			*pos++ = '(';
			*pos++ = '*';
			if (d)
				psdhex(d, -1, &w->cg);
			*pos++ = ')';
		}
	}
	z pc.w++;
}

static
void dc_w(IT *w, PC pc)
{
	DW *dw = w->dw;
	PC pc0 = pc;

	ocl(dw, "dc", 3);

	pdhex(*pc.u++, 4, &w->cg);
	while ( pc.b < pc0.b+8 and btst(z dt, pc.b-z org.b) )
	{
		if (w->dis.jt)
			if (btst(w->dis.jt, pc.b-z org.b))
				break;
		if (btst(z dt, pc.b-z org.b+1))
			break;
		if (btst(z dt, pc.b-z org.b+3) and btst(z dt, pc.b-z org.b+2) eq 0)
			break;
		if (rel(dw, pc.b) or btst(z lab, pc.b-z org.b))
			break;
		*pos++ = ',';
		pdhex(*pc.u++, 4, &w->cg);
	}
	z pc = pc;
}

static
void dc_l(IT *w, PC pc)
{
	DW *dw = w->dw;

	ocl(dw, "dc", 4);
	pc = long_abs(dw, pc, false);
	if (     btst(z dt, pc.b-z org.b)
		and  btst(z dt, pc.b-z org.b+3)
		and !(   rel(dw, pc.b+2)
		      or btst(z dt, pc.b-z org.b+2)
		     )
	   )
	{
		if (   ( w->dis.jt ne nil and !(btst(w->dis.jt, pc.b-z org.b) or btst(w->dis.jt, pc.b-z org.b + 2)) )
			or   w->dis.jt eq nil
		   )
			if (btst(z lab, pc.b-z org.b) eq 0)
			{
				*pos++ = ',';
				pc = long_abs(dw, pc, false);
			}
	}
	z pc = pc;
}

static
void pr_equ(IT *w)
{
	DW *dw = w->dw;

	if (pos < z t1)
		tab(dw, z t1);
	else
		*pos++ = ' ';
	print(w->cg.equ);
	tab(dw, z t2);		/* for t2 tab itself already checks position overflow */
	print("*-");
	pdhex(w->dis.dist, 2, &w->cg);
}

static
void labels_multiple(IT *w, PC a, long pp, bool sep, short which)
{
	DW *dw = w->dw;
	long xx = a.b-z shift.b;
	short ty = 10;

	keep_end_label(dw, ty++);					/* this for the first label */
	if (w->cg.sym and z L.lab[pp].v eq xx)
		while (z L.lab[pp].v ne HIGH_LV)
		{
#if NEW
			long ppo = pp;
#endif
			pp = (pp+1)&z L.hash;

			if (z L.lab[pp].v eq xx)
			{
				LAB *ll = &z L.lab[pp];
#if NEW
				LAB *lo = &z L.lab[ppo];
				send_msg("ll %s %ld, %d == lo %s %ld, %d\n",
					pure_name(ll->n), ll->v, ll->ty, pure_name(lo->n), lo->v, lo->ty);
#endif

				if (  ( is_PC and !pure_local(ll->n) )
					or !is_PC
					)
				{
					if (!z fil and ii <= 0)
						break;
					nl(w,35), il(w);
					if is_PC
						print(pure_name(ll->n));
					else
						print(dri_name (ll->n, ll->d, z sozobon));	/* 5'99 RA: d */

					if (sep)
						print(w->cg.labelsep);
					else
						pr_equ(w);
					keep_end_label(dw, ty++);	/* this for the subsequent label (see il()) */
				}
			}
		}
		
}

static
void do_equs(IT *w, PC pc0, PC pc)
{
	DW *dw = w->dw;
	PC j; long pp;

	for (j.b = pc0.b+1; j.b < pc.b; j.b++)
		if (btst(z lab, j.b-z org.b))
		{
			nl(w,36);
			pos = regel;
			tabgain = 0;
			pp = address(dw, j.b);
			w->dis.dist = pc.b-j.b;
			pr_equ(w);
			labels_multiple(w, j, pp, false, 1);
		}
}

/*	a 32 byte string
01234567890123456789012345678901
*/

static
bool find_bm(IT *w, PC pc)
{
	DW *dw = w->dw;
	HSYM *s = &z ML; LAB *l;
	long a  = pc.b-z shift.b,
		 pp = ttd_hash(s, a);

	while(s->lab[pp].v < a)
		pp = (pp+1)&s->hash;

	l = &s->lab[pp];

	if (l->v eq a)
	{
		char c = *l->n;
		if (c eq ';' or c eq '*')
			print(l->n);
		else
		{
			print(w->cg.kpref);
			phex(l->v, w->cg.rdx, z lbl_len);
			print(w->cg.labelsep);
			if (*l->n)
			{
				tab(dw, z t2);
				print("; ");
				print(l->n);
			}
		}
		if (pc.b eq w->cf.spg.b)
			w->dis.is_bm = true;
		nl(w,37), il(w);
		return true;
	}
	return false;
}

static
char * find_comment(IT *w, PC pc)
{
	DW *dw = w->dw;
	char *comm = nil;
	HSYM *s = &z CL;  LAB *l;
	long a  = pc.b-z shift.b,
		 pp = ttd_hash(s, a);

	while(s->lab[pp].v < a)
		pp = (pp+1)&s->hash;
	while (s->lab[pp].v eq a)
	{
		l = &s->lab[pp];
		if (ii > 0 and (*l->n eq ';' or *l->n eq '*'))
		{
			print(l->n);
			if (pc.b eq w->cf.spg.b)
				w->dis.is_bm = true;
			nl(w,37), il(w);
		}
		elif (comm eq nil)
			comm = l->n;
		pp = (pp+1)&s->hash;
	}
	return comm;
}

static
bool with_labels(IT *w)
{
	DW *dw = w->dw;
	PC pc = z pc, pc0 = pc;
	long j;
	bool m0, m1, m2, m3;

	if (z fil and w->dis.fend.b > 0 and pc.b >= w->dis.fend.b)
		return nl(w,38), false;

	if (pc.b >= z top.b)
	{
		if (ii>0)
		{
			if (z ML.lab and z ML.no)
				find_bm(w, pc);
			labels_multiple(w, pc, label(dw, pc, true), true, 2);
			if (ii>0)
			{
				nl(w,39);
				if (ii>0)
				{
					il(w);
					check_mod(dw);
					oc(dw, "end", 0);
					nl(w,40);
				}
			}
		}
		return false;
	}

	if (z prg)
	{
		if   (pc.b eq z bss.b)
		{
			if (new_section(w, w->cg.sec_bss) eq 0) return false;	/* ii --> 0 */
		}
		elif (pc.b eq z dat.b)
		{
			if (new_section(w, w->cg.sec_data) eq 0) return false;
		}
		elif (pc.b eq z org.b)
		{
			if (new_section(w, w->cg.sec_text) eq 0) return false;
		}
	}

	if (z ML.lab and z ML.no)
		find_bm(w, pc);

	if (btst(z lab, pc.b-z org.b))
	{
		labels_multiple(w, pc, label(dw, pc, true), true,3);
		if (w->cg.labnl)
			nl(w,41), il(w);
	}

	if (pc.b >= z bss.b)
	{
		long j, j2;
		j = pc.b-z org.b;
		j2 = (j+sizeof(long)*CHAR_BIT)&-(sizeof(long)*CHAR_BIT);
		do					/* nonzero acts per long */
		{
			j++;
			if (j eq j2)
				j = (nonzero(&z lab[j2/(sizeof(bool)*CHAR_BIT)])-(long)&z lab[0])*CHAR_BIT;
				/* bool is a typedef enum */
		} while (btst(z lab, j) eq 0);
		ocl(dw, "ds", 1);
		pdhex(z org.b-pc.b+j, 8, &w->cg);
		pc.b = z org.b+j;
		z pc = pc;
		return true;
	}

	j = pc.b-z org.b;
	m0 = btst(z dt, j);
	m1 = btst(z dt, j+1);
	m2 = btst(z dt, j+2);
	m3 = btst(z dt, j+3);

	if (pc.i&1)
		dc_b(w, pc);
	elif (rel(dw, pc.b))
		dc_l(w, pc);
	elif (m0 eq 0)
	{
		if (m1 ne 0)
			dc_w(w, pc);
		else
		{
			short disok = disass(dw);
	/*                    ==========									*/
			if (z coldfire and z pc.w - pc.w > 3)
				disok = 1;

			if (disok or mop15 or z prcol)
			{
				short col = z prcol ? z prcol : 2;	/* v8.2 */
				if (mop15 and !disok)
					col = 4;						/* v8.3 */
				vst_color(w->hl, col); 
				vst_effects(w->hl, bold);
			}

			if (disok ne 0)
			{
				if (disok > 0)
				{
					z openline = false;
					pos = z pos1;
					tabgain = tabgain1;
					z pc.w = pc0.w+1;
				}
				ocl(dw, "dc", 3);
				pdhex(*pc0.u, 4, &w->cg);
				z dcf = true;
			}
		}
	}
	elif (m1 ne 0)
		dc_b(w, pc);
	elif (    m3 ne 0
		  and !(   rel(dw, pc.b+2)
		        or m2 ne 0
		       )
		 )
		dc_l(w, pc);
	elif (w->dis.jt and btst(w->dis.jt, pc.b-z org.b) ne 0) /* if in jump table */
		dc_jmpt(w, pc);
	else
		dc_w(w, pc);

	mop15 = false;
	return true;
}

#if SHOWMARKS
static add_hexasc(IT *w, PC pc0, PC pc)
{
	DW *dw = w->dw;
	long no = pc.b-pc0.b, i = pc0.b-z org.b;

	tab(dw, w->t6);
	while (no > 0)
	{
		if (btst(z dt, i))
			if (rel(dw, i+z org.b))
				*pos++ = 'R';
			else
				*pos++ = '|';
		else
			if (rel(dw, i+z org.b))
				*pos++ = 'r';
			else
				*pos++ = '_';
		no--;
		i++;
	}
	return true;
}
#else
static
bool add_hexasc(IT *w, PC pc0, PC pc)
{
	DW *dw = w->dw;
	short ti = 0, nodig;
	char * stpos; bool teveel;
	short i, j = pc.b-pc0.b;

	if (w->cg.opoct)
		ti = 2;
	nodig = 3*j+ti;
	if (   pos > w->dis.t6
		or (    cfg.hslider eq 0
		    and w->dis.t6+nodig > regel+w->norm.sz.w+w->norm.pos.x
		   )
		)
	{
		nodig += 3;
		if (ii <= 0)
			return z pc = pc0, z kp = z kp0, false;
		nl(w,42);
		pos = regel;
		*pos++ = '*';
		stpos = z t1;
		if (stpos+nodig > regel+w->norm.sz.w+w->norm.pos.x)
			stpos = pos;
		teveel = true;
	othw
		stpos = w->dis.t6;
		teveel = false;
	}

	tab(dw, stpos);

	if (w->cg.comm and z fil and !teveel)
		print("; ");

	if (w->cg.opoct)
	{
		uint c = *pc0.u;

		phex     ((c>>12)&15, 16, 1);
		*pos++ = ((c>> 9)&7)+'0';
		*pos++ = ((c>> 6)&7)+'0';
		*pos++ = ((c>> 3)&7)+'0';
		*pos++ = ( c     &7)+'0';
		*pos++ = ' ';
		loop(i, j-2)
			phex(*(pc0.b+i+2), 16, 2);
	othw
		loop(i, j)
			phex(*(pc0.b+i), 16, 2);
	}

	if (teveel)
	{
		tab(dw, stpos+44+ti);
		*pos++ = '|';
	othw
		tab(dw, w->dis.t69);
	}

	loop(i, j)
		*pos++ = w->cg.tvis[*(pc0.k+i)];

	if (teveel)
		*pos++ = '|';
	return true;
}
#endif

StdCompare vgl_W
{
	LAB *v1 = p1, *v2 = p2;
	if (v1->v < v2->v)	return -1;
	if (v1->v > v2->v)	return  1;
	return 0;
}

global
LAB *sort_names(HSYM *s)
{
	short n = s->hash + 1;
	LAB *sort = MMalloc(n*sizeof(LAB), "sort on v", AH_DIG_SORT, 0);
	if (sort ne nil)
	{
		memmove(sort, s->lab, n*sizeof(LAB));
		qsort(sort, n, sizeof(LAB), vgl_W);
	othw
		send_msg_n("%s\n", frstr(NMEMSORT));
		sort = s->lab;
	}
	return sort;
}

bool broken(IT *w)
{
	DW *dw = w->dw;

	if ((ii%100) eq 0)
		if break_in
		{
			send_msg_n("%s %ld\n", frstr(BROKE), z pc.b-z org.b);
			return true;
		}
	return false;
}

static
void assembler(IT *w)
{
	DW *dw = w->dw;
	PC pc;

	w->dis.is_bm = false;		/* true if topline is bookmark */
	w->cf.spg.b = min(max(w->cf.spg.b, z org.b), z top.b);
/*	if (!w->cf.lbl)	*/
	if (w->cg.stand)
		w->cf.spg.b = min(w->cf.spg.b, z bss.b);
	init_page(w);

	if (	  z pc.b   eq z org.b
		and !(w->dis.ssel.b eq z org.b)
		)
	{
		if (z prg and w->dis.defs)
			header(w), defines(w);

		if ((w->cg.lbl or w->cg.sym) and z fil)
			user_names(w, ofile);
	}

	while (ii > 0)
		if (z fil and broken(w))
			break;
		else
		{
			bool b; char *comm = nil;
			z openline = false;
			il(w);
			pc = z pc;
		 	w->dis.pc0 = pc;

		 	if (z CL.lab and z CL.no)
		 		comm = find_comment(w, pc);
		 	b = w->cg.stand ? standard(w) : with_labels(w);
			if (!b)
				break;

			if (z berr)
			{
				print(" ;!! #");
				print(w->cg.r16);
				phex(z berr, 16, 4);
				print(".W");
				z berr = 0;
				ping
			}

			if (comm and w->cg.opc)
			{
				tab(dw, w->dis.t6);
				if (*z cg->copref)
					print(z cg->copref), print(" ");
				else
					print("; ");
				print(comm);
			}

			if (pc.b < z bss.b)
			{
				if (w->cg.opasc)
				{
					if (!add_hexasc(w, pc, z pc))
						break;					/* if there, bit didnt fit in page */
				}

				if ((w->cg.lbl or w->cg.sym) and z pc.i > pc.i+1)
				{
					long j, iii = ii; short doeq = 0;
					for(j = pc.i+1; j<z pc.i; j++)
						if (btst(z lab, j-z org.i))
							iii--, doeq++;
					if (iii <= 0)
					{
						z pc = pc;
						z kp = z kp0;
						break;
					}
				 	if (doeq)
				 		do_equs(w, pc, z pc);
				}
			}
			nl(w,43);

			if (z pc.b <= z bss.b and (w->cg.lbl or w->cg.sym))
				if (   z openline
					or z pc.b eq z dat.b
					or z pc.b eq z bss.b
					or btst(z dt, pc.b-z org.b) ne btst(z dt, z pc.b-z org.b)
					)
					if (ii > 0 or z fil)
						il(w), nl(w,44);

		}

	/* shady label at top of page */
	if (    !w->dis.defs					/* HR 02'09 for Lonny Purcell */
		and !w->dis.is_bm
		and	(w->cg.lbl or w->cg.sym)
		and !(   btst(z lab, w->cf.spg.b-z org.b)
		      or z fil
		      )
		)
	{
		ulong sp = min(z top.i, w->cf.spg.i)-z shift.i;

		pos = regel;
		*pos++ = 'L';
		phex(sp,
			(BTST(sp,23) and (sp&0xff000000) eq 0) ? 16
			                                       : w->cg.rdx,
			z lbl_len);
		vst_effects(w->hl, SHADED);
		f_txt(w->hl, w->ma.x, w->ma.y, regel);
		vst_effects(w->hl, 0);
		pos = regel;
		*pos = 0;
	}
}

static
void hex_ascii(IT *w)
{
	DW *dw = w->dw;
	PC pc, pc0;

	w->cf.spg.b = min(max(w->cf.spg.b, w->dis.buffer), w->dis.lim.b);
	init_page(w);
	pc = z pc;
	w->dis.pc0 = z pc;
	while (ii > 0)
		if (z fil and broken(w))
			break;
		else
		{
			pos = regel;
			tabgain = 0;
			keep_label(dw, pc.b, 0);

			if (z fil and w->dis.fend.b > 0 and pc.b >= w->dis.fend.b)
			{
				nl(w,45);
				return;
			}
			if (pc.b >= w->dis.lim.b)
			{
				print(">>>>>>  END at  ");
				pdhex(w->dis.lim.b-z shift.b, 6, &w->cg);
				nl(w,46);
				return;
			}
			phex(pc.b-z shift.b, w->cg.rdx, 6);
			*pos++ = ':';
			tab(dw, w->dis.t_hex);
			pc0 = pc;
			while (pc.b < min(pc0.b+w->dis.hexw, w->dis.lim.b))
			{
				phex(*pc.b, 16, 2);
				if (pc.i&1)
					*pos++ = ' ';
				pc.b++;
			}
			tab(dw, w->dis.t_char);
			*pos++ = '|';
			pc = pc0;
			while (pc.k < min(pc0.k+w->dis.hexw, w->dis.lim.k))
				*pos++ = w->cg.tvis[*pc.k++];
			*pos++ = '|';
			z pc = pc;
			w->dis.pc0 = pc0;
			nl(w,47);
		}
}

global
DRAW draw_page			/* draw only !! no interpretations of defs */
{
	DW *dw = w->dw;
	short dum;

	hidem;
	vst_height(w->hl, w->points, &dum, &dum, &dum, &dum);

	w->view.sz.w = 0;
	z lnr = 0;
	pbox(w->hl, w->wa.x,
				w->wa.y,
				w->wa.x+(w->mgw.x mod w->unit.w)-1,
				w->wa.y+w->wa.h-1);
	z kp = z keep;

	if (w->cg.asc)
		hex_ascii(w);
	else
		assembler(w);

	w->dis.npg = z pc;
	keep_label(dw, z pc.b, 0);

	if (ii>0)
		pbox(v_hl,				/* spacefill rest of window */
				w->ma.x,
				w->ma.y+(w->norm.sz.h-ii)*w->unit.h,
				w->ma.x+w->ma.w-1,
				w->ma.y+w->ma.h-1);
	sliders(w);
	showm;
}

global
void write_all(IT *w)
{
	if (w->cg.asc)
		hex_ascii(w);
	else
		assembler(w);
}

global
void page(IT *w)
{
	if (w and w ne &deskw)
	{
		DW *dw = w->dw;

		toolong = false;
		w->dis.odefs = w->dis.defs;
		via(w->slider)(w);
		do_redraw(w, w->wa);		/* calls draw_page() over rectangle list */
		if (z pc.b eq z org.b)
			w->dis.defs = false;
		if (toolong)			/* delayed (after do_redraw()!!) */
		{
			static bool alerted = false;
			if (!alerted)
			{
				send_msg(frstr(MWW), w->norm.sz.w);
				ping
				alerted = true;
			}
		}
	}
}

/*			  0, 1, 2, 3, 4, 5, 6, 7	      types     */
short vx[8] = { 7, 4, 0, 1, 2, 3, 5, 6 }; /* new order */
static
StdCompare vglsym
{
	SYM *v1 = p1, *v2 = p2;
	short x1 = vx[v1->ty&7],
	      x2 = vx[v2->ty&7];

	if     ( x1 < x2 ) return -1;
	if     ( x1 > x2 ) return  1;
	if     ( v1->v ne v2->v )
	return ( v1->v <  v2->v ? -1 : 1 );
	else
	return ( strncmp(v1->n, v2->n, 8) );
}

static
char *pc_name(char *fp1)
{
	short c = *fp1;
	char *np = pcn;
	if (c eq 0 or (c eq 1 and *fp1 eq '.'))
		return "\\0";

	fp1++;
	while (c--)
		*np++ = *fp1++;
	*np = 0;

	return pcn;
}

static
void put_hname(IT *w, HSYM *s, LAB new)
{
	DW *dw = w->dw;
	long j;

	if (new.ty and new.v >= 0 and new.v <= z top.b-z org.b)
		bset(z lab, new.v);

	j = ttd_hash(s, new.v);		/* prik in tabel */
	do
	{
		if (s->lab[j].v > new.v)
		{
			LAB x = s->lab[j];
			s->lab[j] = new;
			new = x;				/* exchange */

			if (x.v eq HIGH_LV)
				break;
		}
		j = (j+1)&s->hash;
	}od
}

global
bool user_hname(IT *w, HSYM *s, LAB new)
{
	long j;

	if (w)
	{
		DW *dw = w->dw;

		if (    new.ty ne 0
			and new.ty ne FIX_wabs and new.ty ne FIX_book
			and new.v >= 0
			and new.v <= z top.b-z org.b
		   )
			bset(z lab, new.v);
	}

	j = ttd_hash(s, new.v);		/* prik in tabel */

	do{
		if (s->lab[j].v eq new.v)
		{
			free(s->lab[j].n);
			s->lab[j] = new;		/* replace with new */
			return false;
		}
		if (s->lab[j].v > new.v)
		{
			LAB x = s->lab[j];
			s->lab[j] = new;
			new = x;				/* exchange */

			if (x.v eq HIGH_LV)
				return true;
		}
		j = (j+1)&s->hash;
	}od
}

global
void symbols(IT *w)
{
	DW *dw = w->dw;
	long i, count;

	if (is_PC and !w->cg.sym1)
	{
		FIX *f = z F;

		loop(i, z L.hash+1)
			z L.lab[i].v = HIGH_LV;
		count = (z L.hash*4)/5;				/* count = 80% van hash */
		while (f < z F+w->dis.fixups)
		{
			char ty = f->ty;
			if (ty eq FIX_end  or  ty eq FIX_offs)
				break;
			if (ty >= FIX_glmod and ty <= FIX_lcent)
			{
				if (count <= 0)
					break;
				count--;
				i = f->nd;
				put_hname(w, &z L, z PL[i]);
			}
			f++;
		}
		w->cg.sym1 = true;
	}
	elif (w->dis.d_info and !w->cg.sym1 and (z rlc.i&1) eq 0)
	{
		bool relative;
		SYM *s;

		loop(i, z L.hash+1)
			z L.lab[i].v = HIGH_LV;

		if (z reloff)
			relative = true;
		else
		{
			relative = false;
			s = z S;
#if SOZOBON
			if (s->ty eq 0x42 and strncmp(s->n, "SozobonX", 8) eq 0)	/* HR 021208 ty 0x42 Sozobon extended names */
			{
				z sozobon = 1;
				send_msg("SozobonX v2 binary\n");
			}
#endif
			while (s < z S+w->dis.syms)
			{
#if SOZOBON
				if (z sozobon and s->ty eq 0x42)			/* HR 021208 ty 0x42 Sozobon extended names */
				{
					s++;
					w->dis.esym = true;
				}
				else
#endif
				{
					if (s->ty&4)						/* data seg */
						if (s->v < z dat.b-z org.b)		/* niet in data */
							relative = true;
					if (s->ty&1)						/* bss seg */
						if (s->v < z bss.b-z org.b)		/* niet in bss */
							relative = true;

					if (s->d eq 0x48 or s->d eq 0xc8)
						s++,
						w->dis.esym = true;
				}
				if (relative)
					break;
				s++;
			}
		}
		count = (z L.hash*4)/5;				/* count = 80% van hash */
		s = z S;
		while (s < z S+w->dis.syms)
		{
			LAB new;
			if (count < 0)					/* HR 311004: count can be zero */
				break;
			if (s->ty&7)
			{
				new.v = s->v;
				new.n = s->n;
				new.d = s->d;
				new.sz = 0;
				new.ty = s->ty;

				count--;
				if (relative)
					if   (s->ty&1)
						new.v += z bss.b-z org.b;
					elif (s->ty&4)
						new.v += z dat.b-z org.b;

				put_hname(w, &z L, new);

				if (s->d eq 0x48 or s->d eq 0xc8)
					s++;
			}
			s++;
		}
		w->cg.sym1 = true;
	}
}

global
void il(IT *w)
{
	DW *dw = w->dw;

	regel[0] = 0;
	pos = regel;
	tabgain = 0;
	z kp0 = z kp;
	keep_label(dw, z pc.b, 0);
}

global
void init_labs(IT *w)
{
	DW *dw = w->dw;

	if (z dat.i&1)
		bset(z dt, z dat.b-z org.b-1),
		bset(z dt,z dat.b-z org.b);
	if (z bss.i&1)
		bset(z dt, z bss.b-z org.b-1),
		bset(z dt, z bss.b-z org.b);
/*	bset(z lab, 0);					removed: on request of Lonny Purcell */
	bset(z lab, z dat.b-z org.b);
	bset(z lab, z bss.b-z org.b);
	bset(z lab, z top.b-z org.b);
}

static
void scan_wabs(IT *w, HSYM *s)
{
	DW *dw = w->dw;
	ulong i;

	for (i = 0;i <= s->hash;i++)
		if (s->lab[i].v ne HIGH_LV)
		{
			long a = s->lab[i].v + z shift.i;
			if (a >= z org.i and a < z top.i)
				bset(z lab, a - z org.i);
		}
}

static
void scan_W(IT *w)
{
	DW *dw = w->dw;

	if (z WL.lab)
		scan_wabs(w, &z WL);
	if (namA.lab)
		scan_wabs(w, &namA);
}

global
void labels(IT *w)
{
	DW *dw = w->dw;

	long timer;
	short sup = z org.i < 0x800 ? 8 : 0;
	mask20(w);
	if (w->cg.lbl or w->cg.sym)
	{
		if (!w->dis.lbl1)
		{
			send_msg_n("%s labels ...\n", frstr(L_SCAN));
			timer = clock();
			init_labs(w);
			if (z mach or w->cg.mc81)
				scanlabx((z prg&1)|(z mach?2:0)|((w->cg.mc81&1)<<2)|sup,
						  z org, z bss, z top, w->cf.offset,
						  w->dis.mask, w->dis.maskx, z rel, z dt, z lab);
			else
				scanlab(z prg|sup,
						z org, z bss, z top, w->cf.offset,
						w->dis.mask, z rel, z dt, z lab);
			if (w->dis.jt)
				scan_jt(w, false);

			if (w->cf.offset eq z org.i and is_ram(dw))
				scan_W(w);

			timer = (clock()-timer)*5;
			if (timer)
				send_msg_n("... %ld ms\n", timer);
			w->dis.lbl1 = true;
			w->dis.rescan = false;
		}
	}
}

global
void scan_PC(IT *w)
{
	DW *dw = w->dw;
	PC c = z rlc,
	   rlc = c;
	LAB *pcty = z PL;

	send_msg_n("%s\n", frstr(FIX_UP));

	while (c.b < rlc.b+w->dis.limg)
	{
		if (*c.w)
		{
			FIX *f = z F+*c.w;
			PCL cross = (PCL)(z org.b+(c.b-rlc.b));
			char ty = f->ty;

			if (f->nd >= 0 and f->nd < z L.no)	/* 12'05 */
			{
				if (pcty[f->nd].ty eq 0x10)
					bset(z rel, c.b-rlc.b+1);		/* set odd rel ! */
				if (   ty eq FIX_labs
					and pcty[f->nd].ty ne 0x10
					and *cross > 0
					and *cross < w->dis.limg+w->dis.lbss	  /* absolute long reference */
					)
					bset(z lab, *cross);
			}
			if (ty eq FIX_labs or ty eq FIX_lpcrel)		/* all long refs */
				bset(z rel, c.b-rlc.b),
				c.w++;
		}
		c.w++;
	}
}

global
PC scan_DRI(IT *w)		/* Scan DRI fix_up information */
{
	DW *dw = w->dw;
	PC  c = z rlc,
		rlc = c;

	send_msg_n("%s\n", frstr(FIX_UP));
	while (c.b < rlc.b + w->dis.lreloc)
	{
		PC cross;

		cross.b = c.b - z reloff;

		switch (*c.w&7)
		{
		case 5:					/* long refs */
			switch (*(c.w+1)&7)
			{
			case 0:
			case 4:
			case 6:
				bset(z rel, c.b-rlc.b+1);		/* set odd rel! */
			esac
			case 1:
			case 2:
			case 3:
				if (    *cross.l > 0
					and *cross.l < w->dis.ltext+w->dis.ldat+w->dis.lbss
					)
				bset(z lab, *cross.l);
			esac
			case 5:
			case 7:
				return c.i = 0, c;
			}
			bset(z rel, c.b-rlc.b);
			c.w++;
		esac
		case 4:
		case 6:
			bset(z rel, c.b-rlc.b+1);		/* set odd rel! */
		}
		c.w++;
	}
	return c;
}

global
PCB scan_PRG(IT *w)		/* Scan relocation information of a executable */
{
	DW *dw = w->dw;
	PC rep;
	long timer;

	if (!w->dis.kop.drih.norelo)
	{
		send_msg_n("%s\n", frstr(SCAN_REL));
		timer = clock();
		rep.b = scanreloc(z org, z bss, z top,
				      z rlc, w->dis.lim, z rel, z lab);
		if (rep.i < z rlc.i)
		{
			send_msg("-= FAIL %ld=-\n", rep.i);
			rep = z rlc;
		}
		else
			send_msg_n("-= OK =- %ld ms\n", (clock()-timer)*5);
	}
	return rep.b;
}

global
void scan_reloc(IT *w)
{
	DW *dw = w->dw;

	if (is_PC)
		scan_PC(w);
	elif (is_DRI)
		if (z reloff)
			scan_DRI(w);
		else
			scan_PRG(w);
}

global
ulong near_hi_p2(ulong in, bool t2)
{
	ulong m = 0x40000000;
	if (in eq 0)
		return 255;
	while ((in&m) eq 0) m >>= 1;
	if (t2)
		return (m<<1) | m | m-1;
	else
		return m | m-1;
}

global
bool alloc_hsym(HSYM *s, short wl, char *txt)
{
	if (wl < 127)
		wl = 127;
	wl = near_hi_p2(wl, 1);		/* hash for table (nearest but 1 higher power of two) */
	s->lab = MMalloc((wl+1)*sizeof(LAB), "alchsym", AH_DIG_SYM, 0);
	if (s->lab)
	{
		long i;
		s->hash = wl;
		memset(s->lab, 0, (s->hash+1)*sizeof(LAB));
		for (i = 0;i <= s->hash;i++)
			s->lab[i].v = HIGH_LV;
		s->max = (s->hash*4)/5;	/* safe maximum */
		s->no = 0;				/* current no of symbols */
		return true;
	othw
		send_msg("%s\n", frstr(WNALLOC));
		return false;
	}
}

static
char *findname(char *fps, long ld, short nnr)
{
	char *fpx = fps;
	short nr = 0;
	if (nnr >= 0)
		while (fpx < fps+ld)
		{
			char *fp1 = fpx;
			short c = *fp1;
			char *np = pcn;
			if (c eq 0)
			{
				np = "\\0";
				fp1++;
			othw
				fp1++;
				while (c--)
					*np++ = *fp1++;
				*np = 0;
				np = pcn;
			}
			if (nr eq nnr)
				return np;
			nr++;
			fpx = fp1;
		}
	return "";
}

global
void listnames(char *fps, long ld)
{
	IT *jw = get_it(-1, JRNL);
	short nnr = 0, nr;
	char *fpx = fps;

	send_msg("\nstring table:\n");
	send_msg(" entry  index string\n\n");

	while (fpx < fps+ld)
	{
		char *fp1 = fpx;
		short c = *fp1;
		char *np = pcn;
		if (c eq 0)
		{
			np = "\\0";
			fp1++;
			nr = 1;
		othw
			fp1++;
			while (c--)
				*np++ = *fp1++;
			*np = 0;
			np = pcn;
			nr = 1;
		}
		ins_text(LAST, jw, "%6ld\t%5d %s", fpx-fps, nnr, np);
		nnr += nr;
		fpx = fp1;
	}
}

global char *fixnames[] = {
	"0   ", "END ", "STEP", "TEXT", "DATA", "BSS ", "OFFS", "GL_M",
	"GL_E", "LC_M", "LC_E", "L_AB", "W_AB", "L_PC", "W_PC", "F   ",
	"  16", "  17", "  18", "  19", "  20", "  21", "  22", "  23",
	"  24", "  25", "  26", "  27", "  28", "  29", "  30", "  31"
};

global
long skip(FIX *f)
{
	long sk = *(long *)f;
/*	sk &= 0xffffff; */
	return sk << 8;
}

global
void listfixups(IT *w)		/* uit de bron */
{
	DW *dw = w->dw;
	IT *jw = get_it(-1, JRNL);
	FIX *f = z F;
	long staffel = 0, sk;
	bool offs_regime = false;

	send_msg("\nfixups:        ty      inc       pc  nnr\n\n");

	while (f < z F+w->dis.fixups)
	{
		char *sa = "%08lx %s %3d %8ld %8ld%5d %s",
			 *sb = "%08lx %s %3d %8ld %8ld%5d %s\t\t;%8lx";

		sk = f->ty eq FIX_step
				? skip(f)				/* HR june 14 2004: use 24 bits */
				: f->sk;

		staffel += sk;

		if (f->ty eq FIX_step)
			ins_text(LAST, jw, "%08lx %s %3d %8ld %8ld", *f,
				   fixnames[f->ty], f->ty, sk, staffel);
		else
			ins_text(LAST, jw,
				offs_regime ? sb :sa, *f,
			     fixnames[f->ty], f->ty, sk, staffel, f->nd,
			         (f->nd >= 0 and f->nd < z L.no)	/* 12'05 */
			           ? findname(z nam, w->dis.lnam, f->nd)
			           : "",
			         staffel);

		if (f->ty eq FIX_offs)
			staffel = 0, offs_regime = true;

		f++;
	}
}

static
void donames(IT *w)
{
	DW *dw = w->dw;
	short i;

	send_msg("\nnames:     nr \n\n");

	loop(i, z L.no)
		send_msg("%6ld\t%5d %s\n", z PL[i].n-z nam,
			i, pc_name(z PL[i].n)
			);
}

static
void dorefups(IT *w)
{
	DW *dw = w->dw;
	PC p = z rlc;

	send_msg("\nrefs:\n ty   ty inc      pc  nnr\n\n");

	while (p.b < z rlc.b+w->dis.limg)
	{
		if (*p.w ne 0)
		{
			FIX f = z F[*p.w];

			send_msg("%s %02x%4d%8ld%5d %s\n",
				fixnames[f.ty],
				f.ty,
				f.sk,
				p.b-z rlc.b,
				f.nd,
				pc_name(z PL[f.nd].n));
		}
		p.w++;
	}
}

static
void doups(IT *w, char *tn(char *))
{
	DW *dw = w->dw;
	long i;

	send_msg("\nrefs:\npc       name\n\n");

	for (i = 0; i <= z L.hash; i++)
	{
		if ( z L.lab[i].v ne HIGH_LV)
			send_msg("%8ld %s\n",
				z L.lab[i].v,
				z L.lab[i].n ? tn(z L.lab[i].n) : "_NULL_");
	}
	send_msg("\n");
}

global
void listsym(IT *w, SYM *sy, bool lnk, long ld, long htext, long hdata, long hbss, bool es)		/* 5'99 RA: es */
{
	DW *dw = w->dw;
	IT *jw = get_it(-1, JRNL);

	long nss = ld/sizeof(SYM);
	if (ld>0)
	{
		short ns, i;
		char naam[256];
		SYM *S = nil;

		if (!es)				/* 5'99 RA */
			S = MMalloc(ld, "listsym", AH_DIG_SSYM, 0);

		if (S)
		{
			memmove(S, sy, ld);
			qsort(S, nss, sizeof(SYM), vglsym);

			send_msg("\n%s\n", lnk ? frstr(SRTTARG) : frstr(SRTADDR));
			send_msg("%s\n\n", frstr(SYMTITLE));
			for (ns = 0;ns<nss;ns++)
			{
				SYM *s = &S[ns];
				long om; short t = s->ty&7, nt = (s+1)->ty&7;
				for (i = 0;i<8;i++)
					naam[i] = s->n[i] eq 0 ? ' ' : s->n[i];
				naam[8] = 0;

#if 1
				if (lnk)			/* linkable DRI object */
				{
					if (t eq nt and t ne 0)
						om = (s+1)->v - s->v;
					else
					{
						if   (t eq 2) om = htext - s->v;
						elif (t eq 4) om = hdata - s->v;
						elif (t eq 1) om = hbss  - s->v;
						else om = 0;
					}
				othw
					if ((ns+1) eq nss)
						om = (htext + hdata + hbss) - s->v;
					else
						om = (s+1)->v - s->v;
				}

				if (om)
					ins_text(LAST, jw, "%s %02x,%02x %s%06lx%7ld%7ld %s%06lx",
					                   naam, s->ty, s->d, w->cg.r16, s->v, s->v, om, w->cg.r16, om);
				else
					ins_text(LAST, jw, "%s %02x,%02x %s%06lx%7ld",
					                   naam, s->ty, s->d, w->cg.r16, s->v, s->v);
#else
					ins_text(LAST, jw, "%s %d/%d/%d/%d %02x,%02x %s%06lx%7ld",
					                   naam, s->ty>>7,(s->ty>>4)&7, (s->ty>>3)&1, s->ty&7, s->ty,s->d, w->cg.r16, s->v, s->v);
#endif
			}
			free(S);
		othw
			S = sy;
			if (!es)
				send_msg("\n%s\n", frstr(NMEMSORT));
			send_msg("%s\n\n", frstr(XSYMTITLE));
			for (ns = z sozobon; ns < nss; ns++)
			{
				SYM *s = &S[ns];
#if SOZOBON
				SYM *e = &S[ns+1];
				if (z sozobon)			/* HR 021208 ty 0x42 Sozobon extended names */
				{
					if (s->ty ne 0x42)
					{
						char *to = naam;
						short dn = ns;
						for (i = 0; i < 8; i++)
							*to++ = s->n[i] eq 0 ? ' ' : s->n[i];
						*to = 0;

						while (e->ty eq 0x42)
						{
							for (i = 0; i < 8; i++)
								*to++ = e->n[i] eq 0 ? ' ' : e->n[i];
							*to = 0;
							ns++, e++;
						}

						ins_text(LAST, jw, "%3d %-22s %02x,%02x %s%06lx%7ld",
						           dn, naam, s->ty, s->d, w->cg.r16, s->v, s->v);
					}
				}
				else
#endif
				{
					if (s->d ne 0x48 and s->d ne 0xc8 )
					{
						for (i = 0; i < 8; i++)
							naam[i] = s->n[i] eq 0 ? ' ' : s->n[i];
						naam[8] = 0;
						ins_text(LAST, jw, "%3d %-22s %02x,%02x %s%06lx%7ld",
						           ns, naam, s->ty, s->d, w->cg.r16, s->v, s->v);
					othw
						strncpy(naam, s->n, 8);
						for (i = 0; i < 14; i++)
							naam[i+8] = (s+1)->n[i] eq 0 ? ' ' : (s+1)->n[i];
						naam[22] = 0;
						ins_text(LAST, jw, "%3d %-22s %02x,%02x %s%06lx%7ld",
						           ns, naam, s->ty, s->d, w->cg.r16, s->v, s->v);
						ns++;
					}
				}
			}
		}
		send_msg("%s\n\n", frstr(EOLIST));
	}
}

global
void settabs(IT *w)
{
	DW *dw = w->dw;
	short t = 8;

	z t1 = regel+t;
	if (w->cg.sym and !w->cg.labnl)
		if (w->cg.opc)
			z t1 += t;		/* room enough */
		else
			z t1++;			/* for ':' */
	z t2 = z t1+t;
	z t3 = z t2+t;
	z t4 = z t3+t;

	w->dis.t5 = z t4+t;
	w->dis.t6 = w->dis.t5+t;
	w->dis.t_hex = regel+11;
	w->dis.t_char = w->dis.t_hex+5*(w->dis.hexw/2)+1;
	w->dis.t69 = regel+69;
	w->dis.t_h = w->dis.t_char+w->dis.hexw;
	w->dis.t74 = regel+74;
/*	if (z com and z fil)
		w->dis.t6 -= 2;
*/	if (w->cg.opoct)
		w->dis.t6 -= 2;
	w->dis.t_x = w->dis.t_h-regel;
}

global
void other_machine(IT *w, bool draw)
{
	DW *dw = w->dw;

	z mach = 0; z coldfire = 0;			/* coldfire is special case: it is a mutilated 68000 */
	if (w->cg.mc60) z mach |= MC060;
	if (w->cg.mc40) z mach |= MC040;
	if (w->cg.mc30) z mach |= MC030;
	if (w->cg.mc20) z mach |= MC020;
	if (w->cg.mccf) z coldfire = true;

	if (!w->cg.stand and w->dis.rescan)
	{
		w->dis.lbl1 = false;
		w->cg.sym1 = false;
		memset(z lab, 0, w->dis.s_lab);
		if (z prg)
			scan_reloc(w);
	}
	settabs(w);
	labels(w);
	symbols(w);
	set_menu(w);
	if (draw)
		page(w);
}

global
CON_RET set_dat			/* struct it *w, char *line, short prompt, short curtask, short curstage */
{
	DW *dw = w->dw;
	PC a;

	a.i = get_addr(w, line);
	if (!a.i)
		send_msg("%s\n", frstr(NFEXT));
	else
	{
		z dat.b = min(max(a.b+z shift.i, z org.b), z bss.b);
		if (w->dis.ltext ne z dat.b - z org.b)
		{
			if (z prg)
				w->dis.ltext = z dat.b - z org.b,
				w->dis.ldat  = z bss.b - z dat.b;
			if (w->cg.lbl or w->cg.sym)
			{
				w->dis.lbl1 = false;
				w->cg.sym1 = false;
				memset(z lab, 0, w->dis.s_lab);
				if (z prg)
					scan_reloc(w);
				labels(w);
				symbols(w);
			}
		}
		con_end(true);
		page(w);
	}
}

global
KEPT which_label	/* 	IT *w, short x, short y */
{
	DW *dw = w->dw;
	RXY *kp = z kp;

	if (x>16)
		return z keep-1;

	while (kp-- > z keep)
		if (kp->x eq 0 and y eq kp->y)
			break;
	return kp;
}

global
KEPT which_lname
{
	DW *dw = w->dw;
	RXY *kp = z kp;

	while (kp-- > z keep)
		if (    x >= kp->x
			and x <  kp->x1
			and y eq kp->y
			)
			break;
	return kp;
}

global
KEPT which_line
{
	DW *dw = w->dw;
	RXY *kp = z kp;

	while (kp-- > z keep)
		if (kp->x eq 0 and y eq kp->y)
			break;
	return kp;
}

static
MUIS vet_kruis
{
	graf_mouse(6, nil);
}

global
void do_select(IT *w, short sel)
{
	DW *dw = w->dw;
	short x, y, dum;
	RXY *k, *kx;
	PC ost = w->dis.ssel, oes = w->dis.esel;

	graf_mkstate(&x, &y, &dum, &dum);
	x = (x-w->ma.x)/w->unit.w+w->norm.pos.x;
	y = (y-w->ma.y)/w->unit.h;
	if (sel eq 0)
	{
		w->dis.ssel.i = 0;
		w->dis.esel.i = 0;
	othw
		k =  which_line(w, x, y);
		kx = which_line(w, x, y+1);

		if (kx < z keep)
			send_msg_n("Lost pc of next line.\n");
		elif (k >= z keep)
		{
			if (sel eq 1)
			{
				w->dis.ssel = k->r;
				if (w->dis.ssel.b <z org.b)
					w->dis.ssel = z org;
				if (w->dis.ssel.b > z bss.b)
					w->dis.ssel = z bss;
				if (w->dis.ssel.i eq w->dis.esel.i)
					w->dis.ssel.i = 0, w->dis.esel.i = 0;
				elif (w->dis.esel.i eq 0)
					w->dis.esel = kx->r;
			othw
				w->dis.esel = kx->r;
				if (w->dis.esel.i < z org.i)
					w->dis.esel = z org;
				if (w->dis.esel.b > z top.b)		/* bss --> top */
					w->dis.esel = z top;
				if (w->dis.esel.i eq w->dis.ssel.i)
					w->dis.esel.i = 0, w->dis.ssel.i = 0;
				elif (w->dis.ssel.i eq 0)
					w->dis.ssel = k->r;
			}
			if (w->dis.ssel.i > w->dis.esel.i)
			{
				PC xx = w->dis.esel;
				w->dis.esel = w->dis.ssel;
				w->dis.ssel = xx;
			}
		}
	}
	if (ost.i ne w->dis.ssel.i or oes.i ne w->dis.esel.i)
		page(w);
	if (w->dis.esel.i)
		w->muisvorm = vet_kruis;
	else
		w->muisvorm = m_kader;
	w->muisvorm(w);					/* per definition mouse is in window */
}

global
bool alloc_jt(IT *w)
{
	w->dis.s_jt = w->dis.s_dt;
	w->dis.jt = MMalloc(w->dis.s_jt, "alloc jt", AH_DIG_JT, 0);
	if (w->dis.jt)
	{
		memset(w->dis.jt, 0, w->dis.s_jt);
		return true;
	othw
		send_msg_n("%s\n", frstr(NMEMJPT));
		ping
		return false;
	}
}

/*  bool btst(...)	is designed as to yield 0 or 1 exactly
    so if you compare with the enum'ed false resp true you can
    compare for equality */

global
void jmpwmark(IT *w, MARK *do_mark)	/* mark jump table */
{
	DW *dw = w->dw;
	long org, orgmax;

	if (w->cg.stand)
		return;
	if (w->dis.ssel.b)
	{
		bool all = true;
		if (w->dis.jt eq nil)
			all = alloc_jt(w);
		if (all)
		{
			org = (w->dis.ssel.i&-2)-z org.i;
			orgmax = w->dis.esel.i-z org.i;
			if (org >= 0 and org < orgmax)
			{
				long st = org;
				w->dis.marked = true;
				w->dis.rescan = true;
				w->ismod = true;
				while (     st < orgmax
						and btst(z dt, st  ) ne 0
						and btst(z dt, st+1) eq 0
					  )
					do_mark(w->dis.jt, st), st += 2;
				bset(w->dis.jt, org+1);	/* start of serie has both bits */
				page(w);
			}
		}
	}
}

char *Bookmark = "Bm", *Ref = "Ref", *Jt_ref = "Jt_ref";

global
void bookmark_msg(IT *w, void (*msg)(char *text, ...), long org, char *b, char *n)
{
	DW *dw = w->dw;
	char regel[256];
	char *save = pos;

	pos = regel;
	if (w->cg.rdx eq 16 or tosaddr(org, 8))
		pdhex(org, z lbl_len, &w->cg);
	else
		sprintf(regel, "%6ld", org);
	if (*n)
		msg("%s at %s \"%s\" in '%s'\n", b, regel, n, w->title);
	else
		msg("%s at %s in '%s'\n", b, regel, w->title);
	pos = save;
}

global
bool find_bookmark(IT *w, short x)
{
	short f = 0, t;
	IT *wt;
	PC pc;
	long fl;
	char *s = w->line, *p, n[DIRL], *b, bm[DIRL];

	if   (strncmp(s, Bookmark, strlen(Bookmark)) eq 0)
		f = strlen(Bookmark), t = 1;
	elif (strncmp(s, Ref, strlen(Ref)     ) eq 0)
		f = strlen(Ref     ), t = 2;
	elif (strncmp(s, Jt_ref, strlen(Jt_ref)  ) eq 0)
		f = strlen(Jt_ref  ), t = 2;

	if (f)
	{
		s += f+3;		/* incl ' at' */
		while (*s eq ' ') s++;
		b = bm;
		while (*s ne ' ') *b++ = *s++;
		*b = 0;
		while (*s eq ' ') s++;
		if (*s eq '\"')
		{
			s++;
			while (*s ne '\"') s++;
			s++;
		}
		while (*s ne '\'') s++;
		s++;
		p = n;
		while (*s ne '\'') *p++ = *s++;
		*p = 0;
		wt = get_fn_it(n);
		if (wt)
		{
			DW *dw = wt->dw;
			pc.i = get_addr(wt, bm) + z shift.i;
			wind_set(wt->wh, WF_TOP);
#if MAKEBMVIS
			make_visible(wt, pc);
#else
			if (t eq 2)
				make_vis_pc(wt, pc);
			else
			{
				wt->cf.spg = pc;
				page(wt);
			}
#endif
			return true;
		othw
			if ( (fl = Fopen(n, 0)) > 0)
			{
				open_object(n, fl, nil);
				wt = get_fn_it(n);
				if (wt)
				{
					DW *dw = wt->dw;
					pc.i = get_addr(wt, bm) + z shift.i;
#if MAKEBMVIS
					make_visible(wt, pc);
#else
					if (t eq 2)
						make_vis_pc(wt, pc);
					else
					{
						wt->cf.spg = pc;
						page(wt);
					}
#endif
					return true;
				}
			}
		}
	othw
		s += x-1;
		if (is_alpha(*s) and *(s-1) eq '\'' and *(s+1) eq ':')
		{
			p = n;
			while (*s ne '\'') *p++ = *s++;
			*p = 0;
			if ( (fl = Fopen(n, 0)) > 0)
			{
				open_object(n, fl, nil);
				return true;
			}
		}
	}
	ping
	return false;
}

global
TOPPED top_jrnl		/* IT *nw, IT *ow */
{
	short x, y, s, k, bx;
	graf_mkstate(&x, &y, &s, &k);
	bx = x-nw->ma.x+nw->unit.w;
	bx = bx/nw->unit.w+nw->norm.pos.x;
	if (nw->base)
		if (find_line(nw, (y-nw->ma.y)/nw->unit.h+nw->norm.pos.y) ne nil)
			if (   strncmp(nw->line, Bookmark, strlen(Bookmark)) eq 0
				or strncmp(nw->line, Ref,      strlen(Ref)     ) eq 0
				or strncmp(nw->line, Jt_ref,   strlen(Jt_ref)  ) eq 0
			   )
			{
				find_bookmark(nw, bx);
				return;
			}
	w_top(nw->wh, nw, ow);		/* default TOPPED action */
}

global
void mark(IT *w, MARK *do_mark, MARK *do_clr, short s)
{
	DW *dw = w->dw;
	short x, y, dum;
	RXY *k;
	long org, orgmax;
	union
	{	long l;
		struct { B2 m01, m23; } mc;
	} m4;

	if (w->cg.stand)
		return;
	if (w->dis.ssel.b)
	{
		org = (w->dis.ssel.i&-2)-z org.i;
		orgmax = w->dis.esel.i-z org.i;
	othw
		graf_mkstate(&x, &y, &dum, &dum);
		x = (x-w->ma.x)/w->unit.w+w->norm.pos.x;
		y = (y-w->ma.y)/w->unit.h;
		k = which_label(w, x, y);
		if (k < z keep)
			return;
		org = (k->r.i&-2)-z org.i;
		orgmax = z bss.i-z org.i;
	}

	if (org >= 0 and org < orgmax)
	{
		w->dis.marked = true;
		w->dis.rescan = true;
		w->ismod = true;
		if (s eq 2)		/* with CONTRL\SHIFT: until end */
		{
			m4.l = g4bool(z dt, org);					/* 4 bits:  */
			if (   m4.mc.m01.m[0] eq m4.mc.m01.m[1]		/* b0 eq b1 */
				or m4.mc.m01.m[0] eq m4.mc.m23.m[0]		/* b0 eq b2 */
				or m4.mc.m01.m[1] eq m4.mc.m23.m[1]		/* b1 eq b3 */
			   )
				m4.mc.m23.m[0] = m4.mc.m01.m[0],		/* b2 := b0 */
				m4.mc.m23.m[1] = m4.mc.m01.m[1];		/* b3 := b1 */

		/*	if (m0 eq m1 or m0 eq m2 or m1 eq m3)
				m2 = m0, m3 = m1;
		*/
			do{
				do_mark(z dt, org);
				if (w->dis.jt)
					do_clr (w->dis.jt, org);
				org += 2;
				if (   org >= orgmax
					or g2bool(z dt, org) ne m4.mc.m23.i)		break;
				do_mark(z dt, org);
				if (w->dis.jt)
					do_clr (w->dis.jt, org);
				org += 2;
				if (   org >= orgmax
					or g2bool(z dt, org) ne m4.mc.m01.i)		break;
			}od
		}
		elif (s eq 1)	/* with CONTRL: until label */
			do{
				do_mark(z dt, org);
				if (w->dis.jt)
					do_clr (w->dis.jt, org);
				org += 2;
				if ( org >= orgmax or g2bool(z lab, org))	break;
			}od
		elif (w->dis.ssel.b)	/* on selection */
			while (org < orgmax)
			{
				do_mark(z dt, org);
				if (w->dis.jt)
					do_clr (w->dis.jt, org);
				org += 2;
			}
		else
		{
			do_mark(z dt, org);
			if (w->dis.jt)
				do_clr (w->dis.jt, org);
			org += 2;
		}
		/* if next word is last part of previous long mark,
		   change that to word mark */
		if (btst(z dt, org+1) ne 0 and btst(z dt, org) eq 0)
		{
			bassign(z dt, org,   true);
			bassign(z dt, org+1, false);
		}
		page(w);
	}
}

global
void mark_long(IT *w, short s)
{
	DW *dw = w->dw;
	short x, y, dum;
	RXY *k;
	long org, orgmax, m;

	if (w->cg.stand)
		return;
	if (w->dis.ssel.b)
	{
		org = (w->dis.ssel.i&-2)-z org.i;
		orgmax = w->dis.esel.i-z org.i-3;
	othw
		graf_mkstate(&x, &y, &dum, &dum);
		x = (x-w->ma.x)/w->unit.w+w->norm.pos.x;
		y = (y-w->ma.y)/w->unit.h;
		k = which_label(w, x, y);
		if (k < z keep)
			return;
		org = (k->r.i&-2)-z org.i;
		orgmax = z bss.i-z org.i-3;
	}

	if (org >= 0 and org < orgmax)
	{
		w->dis.marked = true;
		w->dis.rescan = true;
		w->ismod = true;
		if (s eq 2)		/* with CONTRL/SHIFT: until end or different mark */
		{
			m = g4bool(z dt, org);
			do{
				longmark(z dt, org);
				if (w->dis.jt)
					longclr (w->dis.jt, org);
				org += 4;
				if (org >= orgmax or g4bool(z dt, org) ne m)			break;
			}od
		}
		elif (s eq 1)	/* with CNTRL: until label over existing marks */
			do{
				longmark(z dt, org);
				if (w->dis.jt)
					longclr (w->dis.jt, org);
				org += 4;
				if (org >= orgmax or g4bool(z lab, org) ne 0)		break;
			}od
		elif (w->dis.ssel.b)	/* on selection over existing marks */
			while (org < orgmax)
			{
				longmark(z dt, org);
				if (w->dis.jt)
					longclr (w->dis.jt, org);
				org += 4;
			}
		else
		{
			longmark(z dt, org);
			if (w->dis.jt)
				longclr (w->dis.jt, org);
			org += 4;
		}
		page(w);
	}
}
