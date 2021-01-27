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
 *
 * ld_ob.c           code for loading objectfiles in ld
 *
 * built in linker for Pure C object format
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "common/mallocs.h"
#include "param.h"

long bios(void, ...);

#define DR_I 1
#define GS_T 0

#undef prior
#undef next

#include "po.h"				/* Pure objects */
#include "plib.h"
#include "ld_ob.h"			/* any objects */
#include "common/amem.h"

global
bool gfa;

static
short stack_ob_init[] =
{
	0x4efa, 0x001c,
	0, 0,
	0, 0x0010,
	0, 0x000a,
	0, 0,
	0, 0,
	0, 0,
	0, 0,
	0x0600, 0xffff,
	0x0200, 0x0010, 		/* the FIX_step that can be varied at will */
	0x0800, 0x0000, 		/* FIX_glent name number 0 :-)  */
	0x0100, 0xffff,
	0x085f, 0x5374, 		/* _StkSize */
	0x6b53, 0x697a,
	0x6500
};

static
short stack_ob[sizeof(stack_ob_init)/sizeof(short)];

void send_msg(char *text, ...);

global
short format_error(FLIST *fl, short nr)
{
	P.result = nr;
	send_msg("ld: format error %d in %s\n", nr, fl->name);
	return 0;
}

static
PO_NAME * get_pc_names(FLIST *fl)
{
	PO_NAME *this = nil;
	short names = 0;
	PC_H *fh = &fl->h->pc;
	char *st, *s, *top;

	(long)s = (long)fh->image + fh->limage + fh->lfixup;
	st = s;
	top = st + fh->lnames;

	while (s < top)			/* count names */
	{
		long l = *s;
		if (s + l > top)
			return (void *)format_error(fl, 1);
		names++;
		s += l + 1;
	}

	if (names)
	{
/*		this = CC_qalloc(&defmem, names * sizeof(PO_NAME), LD_ranout, AH_CC_NAMES); */

/*      03'09: In libraries the no of names can be quite large. qalloc has a max of 16384,
 *      so for the names we use CC_xmalloc.
 */
 		this = CC_xmalloc(names * sizeof(PO_NAME), AH_CC_NAMES, LD_ranout);

		if (this)
		{
			s = st;

			names = 0;
			while (s < top)
			{
				long l = *s;
				PO_NAME *pn = &this[names];
				strmaxcpy(s, s + 1, l);
				pn->s = s;
				pn->l = l;
				pn->nr = names;
				pn->hash = *s ? ldhash(s) : 0;
				pn->ty = 0;
				names++;
				s += l + 1;
			}
		}
	}

	fl->names.high = names;

	return this;
}

static
long skip(FIX *f)
{
	if (f->ty eq FIX_step)
	{
		long sk = *(long *)f;
		sk &= 0xffffff;
		return sk * VAL_step;
	}

	return f->sk;
}

static
FIXUP * ins_fixup (
		FIXBASE *this,
		FLIST *fl,
		NAMEBASE *nb,
		short target,
		char *start,
		long disp,
		FIX *f)
{
	PO_NAME *name = nil, *pn = nb->base;
	char labn[12];
	FIXUP *new = nil;

	if (f->ty > FIX_offs)
	{
		if (f->nnr < 0)
			return (void *)format_error(fl, 9);

		if (f->nnr > fl->names.high)
			return (void *)format_error(fl, 10);

		name = &pn[f->nnr];

		if (name eq nil)
			return (void *)format_error(fl, 11);

		if (*name->s eq 0)
			if (f->ty eq FIX_lcmod)
				if (flags.j)
				{
					name->s = CC_qalloc(&defmem, name->l + 1, LD_ranout, AH_CC_TEMPNAME);
					*name->s = 0;
				othw
					name->l = sprintf(labn, "~_%d", ld_lbl++);
					name->s = CC_qalloc(&defmem, name->l + 1, LD_ranout, AH_CC_TEMPNAME);
					strcpy(name->s, labn);
				}
	}
	elif (f->nnr ne -1)
		return (void *)format_error(fl, 12);

	new = new_fixup(this, name, target, f->ty, start, disp, LD_ranout);
	if (new)
		new->fix = *f;

	return new;
}

static
bool is_start(short ty)
{
	switch (ty)
	{
		case FIX_text:
		case FIX_data:
		case FIX_bss:
		case FIX_offs:
		return true;
	}
	return false;
}

static
FIXBASE get_fixups(FLIST *fl, NAMEBASE *nb)
{
	long tally = 0, tolly = 0;
	short target = FIX_text;
	FIXBASE this = {0,0};

	PC_H *fh = &fl->h->pc;
	FIX *s, *top;
	char *start, *base;

	base = fh->image;
	(long)s = (long)fh->image + fh->limage;
	top = s + fh->lfixup/sizeof(FIX);

	while (s < top)
	{
		long step;
		FIXUP *new;
		bool st;

		if (s->ty <= FIX_0 or s->ty >= FIX_f)
			format_error(fl, 3);

		st = is_start(s->ty);
		if (st)
			target = s->ty;

		if (is_module(s->ty) or st)
		{
			tally = 0;
			start = base + tolly;
		}

		new = ins_fixup(&this, fl, nb, target, start, tally, s);

		step = skip(++s);

		if (s->ty eq FIX_step)
			step += skip(++s);

		tally += step;
		tolly += step;

		if (new)
			new->step = step;
	}

	return this;
}

static
bool is_begin(short ty)
{
	return is_start(ty) or is_module(ty) or ty eq FIX_end;
}

static
bool get_area(FLIST *fl)
{
	FIXBASE *fb = &fl->fixups;
	FIXUP *f = fb->first;

	if (f)
		while (f->fix.ty ne FIX_end)
		{
			while (f and is_start(f->fix.ty))
				f = rem_list(fb, f);

			if (f and f->fix.ty ne FIX_end)
			{
				if (is_module(f->fix.ty) or f->target eq FIX_offs)
				{
					AREA *new;
					FIXUP *astart;

					new = new_area(fl, f->target, f->name ? f->name->s : "", LD_ranout);
					if (new)
					{
						new->image = f->start;
						astart = f;

						while (f->next and !is_begin(f->next->fix.ty))
							f = f->next;

						new->limage = f->disp + f->step;
						move_list(&new->fixups, fb, astart, f);		/* move f --> new area */

						return true;
					}
				}
				else
					format_error(fl, 3);
			}
		}

	return false;
}

/* find the area to which the anonymous ref points */
global
AREA * anon_ref(FIXUP *f, REFS *loc, long *disp)
{
	while (loc)
	{
		if (loc->fx->name->nr eq f->name->nr)
		{
		    f->out = loc->fx->in;

		    if (disp)
		    	*disp = loc->fx->disp;

		    return f->out;
		}

		loc = loc->next;
	}

	return nil;
}

static
void analyse_a_refs(FLIST *fl)
{
	AREA *ar = fl->areas.first;

	while (ar)
	{
		REFS *rf  = ar->a_refs.first;

		while (rf)
		{
			if (anon_ref(rf->fx, fl->l_ents.first, nil) eq nil)
				format_error(fl, 4);

			rf = rf->next;
		}

		ar = ar->next;
	}
}

static
void make_symbol_tree(FLIST *fl)
{
	AREA *ar = fl->areas.first;
	MEMBASE mlocal;

	init_membase(&mlocal, 8192, XA_LOCAL, "symbols local base", nil);

	while (ar)
	{
		FIXUP *f;
		REFBASE this_g_ents,
		        this_l_ents;

		clr_treebase(&this_g_ents, false, 0, nil, "area global entries");
		clr_treebase(&this_l_ents, false, 0, nil, "area local entries");
		clr_treebase(&ar->o_refs,  false, 0, nil, "area outside refs");
		clr_treebase(&ar->a_refs,  false, 0, nil, "area anonymous refs");

		f = ar->fixups.first;

		while (f)
		{
			if (is_lc_entry(f->fix.ty))
			{
				new_locref(&mlocal, &this_l_ents, ar, f);
				new_locref(&refmem, &fl->l_ents, ar, f);
			}
			elif (is_gl_entry(f->fix.ty))
			{
				new_locref(&mlocal, &this_g_ents, ar, f);
				new_ref(&refmem, &gl_base, ar, f, fl->obty);
			}

			f = f->next;
		}

		if (!no_image(ar->target))
		{
			f = ar->fixups.first;
			while (f)
			{
				if (is_ref(f->fix.ty))
				{
					if (*f->name->s)
					{
						if (    find_locref(&this_l_ents, f->name->nr) eq nil
						    and find_locref(&this_g_ents, f->name->nr) eq nil
						   )
							new_ref(&refmem, &ar->o_refs, ar, f, fl->obty);
					othw				/* anonymous */
										/* no name, so simple list */
						ins_ref(&refmem, &ar->a_refs, ar, f, LD_ranout);
					}
				}

				f = f->next;
			}
		}

		ar = ar->next;
	}

	free_membase(&mlocal);

	analyse_a_refs(fl);		/* find the target area of the anonymous refs */
}

static
bool load_pure(FLIST *fl)
{
	PC_H *hd = &fl->h->pc;
	HI_NAME *hn;

	/* do some checks */
	if (  sizeof(PC_H)
        + hd->limage
        + hd->lfixup
        + hd->lnames
        > fl->size
       )
		return format_error(fl, 2);

	fl->obty = PURE_C;
	hn = hn_make(fl->name, ":\\.", 3);

	if (hn)
	{
		if (    strnicmp(hn->fn->n,   "pc", 2) eq 0
		    and stricmp (hn->fn->ext, "lib"  ) eq 0
		   )
			fl->obty |= LIB;		/* have Pure C library, for EQ8 comparisons */
		hn_free(hn);
	}

	fl->names.base = get_pc_names(fl);
	fl->fixups = get_fixups(fl, &fl->names);

	while(get_area(fl))
		;

	if (!flags.j)
		make_symbol_tree(fl);

	if (fl->areas.first eq nil)
		send_msg("no areas in %s\n", fl->name);
	return true;
}

#if DR_I

/*			    0, 1, 2, 3, 4, 5, 6, 7	      types     */
short vx[8] = { 7, 4, 0, 1, 2, 3, 5, 6 }; /* new order */
static
StdCompare vglsym
{
	const VPO *v1 = p1,
	          *v2 = p2;
	short x1 = vx[v1->ty&7],
	      x2 = vx[v2->ty&7];

	if     ( x1 < x2 ) return -1;
	if     ( x1 > x2 ) return  1;
	if     ( v1->v ne v2->v )
	return ( v1->v <  v2->v ? -1 : 1 );
	else
	return ( strncmp(v1->pn->s, v2->pn->s, 8) );
}

static
uint topc[] = {0,1,0,2};

static
PO_NAME *put_name(PO_NAME *pn, char *s, short nr)
{
	pn->s = s;
	pn->l = strlen(s);
	pn->nr = nr;
	pn->hash = *s ? ldhash(s) : 0;
	pn->ty = 0;
	return pn;
}

static
short get_dri_names(FLIST *fl, DRI_H *hd)
{
	short have = 0;
	PO_NAME *this = nil; DRI_SYM *s; VPO *sv = nil;
	short i, names;
	char *space;

	names = hd->lsym/sizeof(DRI_SYM);

#if L_VERBOSE
	send_msg("%d names of %ld\n", names, sizeof(s->n));
#endif

	if (hd->ltext) have |= 2;
	if (hd->ldata) have |= 4;
	if (hd->lbss ) have |= 1;

	this  = CC_xmalloc((names + DRI_AREAS + 1) * sizeof(PO_NAME), AH_CC_NAMES, LD_ranout);

	if (names)
	{
		space = CC_xmalloc( names      * (sizeof(s->n) + 2), AH_CC_NAMES, LD_ranout);
		sv    = CC_xmalloc((names + 1) * sizeof(VPO),        AH_CC_NAMES, LD_ranout);
		if (this and space and sv)
		{
			i = 0;
			(long)s = (long)hd->image + hd->ltext + hd->ldata;
			while (i < names)
			{
				PO_NAME *pn = &this[i];
				VPO     *vn = &sv[i];

				strmaxcpy(space, s->n, sizeof(s->n));
				put_name(pn, space, i);

				vn->v  = s->v;
				vn->ty = s->ty;
				vn->d  = s->d;
				vn->pn = pn;
				if ((s->ty & 15) eq 0)
					have |= 8;				/* have absolute names */
				else
					have |= s->ty & 7;
				space += sizeof(s->n) + 2;
				i++;
				s++;
			}

			this[i].s = nil;

			qsort(sv, names, sizeof(*sv), vglsym);

		}
	}

	/* make empty local names for the DRI_AREAS segments */
	for (i = 0; i < DRI_AREAS; i++)
		fl->names.area[i] = put_name(this + names + i, "", names + i);

	if ((have & 2) eq 0)
		fl->names.area[0]->nr = -1;				/* no text */
	if ((have & 4) eq 0)
		fl->names.area[1]->nr = -1;				/* no data */
	if ((have & 1) eq 0)
		fl->names.area[2]->nr = -1;				/* no bss */

	/* terminate lists */
	this[names + DRI_AREAS].s = nil;
	sv  [names].pn = nil;

	fl->names.base = this;
	fl->names.sort = sv;
	fl->names.high = names;

	return have;
}

static
short dri_ent2pc(short ty)
{
	if ((ty>>4) & 2)
		return FIX_glent;

	return FIX_lcent;
}

static
short dri_mod2pc(short ty)
{
	switch (ty>>4)
	{
		case 0xa:	return FIX_glmod;
		case 0x8:	return FIX_lcmod;
	}
	return 0;
}

typedef union
{
	char *  b;
	short * w;
	long *  l;
	uchar * k;
	uint *  u;
	long    i;
} PC;

static
AREA *dri_segment(FLIST *fl, short target)
{
	DRI_H *hd = &fl->h->dri;
	AREA *ar = new_area(fl, target, "", LD_ranout);

	if (ar)
	{
		switch (target)
		{
			case FIX_text:
				ar->limage = hd->ltext;
				ar->image  = hd->image;
			break;
			case FIX_data:
				ar->limage = hd->ldata;
				ar->image  = hd->image + hd->ltext;
			break;
			case FIX_bss:
				ar->limage = hd->lbss;
				ar->image  = hd->image + hd->ltext + hd->ldata;
			break;
			case FIX_offs:
				ar->limage = 0;
				ar->image  = 0; /* hd->image + hd->ltext + hd->ldata; */
		}

		ar->target = target;
	}
	else
		P.result = 11;

	return ar;
}

static
PO_NAME *getname(FLIST *fl, short i, short target)
{
	if (fl->names.area[i]->nr >= 0)		/* was there local area fixup */
		return fl->names.area[i];
	else
	{
		if (i eq target - FIX_text)
			return fl->names.base;			/* use the first name */
		else
		{
#if L_VERBOSE
			send_msg("i %d, target %d fl->names.area[i]->nr %d\n", i, target, fl->names.area[i]->nr);
#endif
			fl->names.area[i]->nr = fl->names.high + i;		/* reactivate local area default */
#if L_VERBOSE
			send_msg("reactivate\n");
#endif
			dri_segment(fl, i + FIX_text);
			return fl->names.area[i];
		}
	}
}


static
VPO * in_symtab(AREA *ar, PC pc, VPO *s)
{
	static short pctodri[] = {2, 4, 1, 0};
	short ty = pctodri[ar->target- FIX_text];

	if (s->pn)
		if (pc.i eq s->v and (s->ty&7) ne 0)		/* entry points (exclude externals !!) */
		{
			long v = s->v;
			while (s->pn and s->v eq v and (s->ty&7) eq ty /* and (s->ty&7) ne 0 */)
			{
/*				send_msg("fix: %s ty %x\n", s->pn->s, s->ty);	*/
				new_fixup(&ar->fixups, s->pn,
								ar->target, dri_ent2pc(s->ty), ar->image, pc.i,
								LD_ranout);
				s++;
			}
		}

	return s;
}

static
bool make_fixups(FLIST *fl, DRI_H *hd)			/* for DRI/GFA objects */
{
	PC pc, pce, rlc, rlce;
	AREA *ar = fl->areas.first;
	VPO  *s = fl->names.sort, *se = fl->names.sort + fl->names.high;
	PO_NAME *pn = fl->names.base;
#if L_VERBOSE
	PC rlcs;
#endif

	long torlc = hd->ltext + hd->ldata + hd->lsym;

	while (ar)
	{
		if (ar->target eq FIX_offs)
			break;

		pc.b  = ar->out;
		pce.b = pc.b + ar->limage;
		rlc.b = ar->image + torlc;
		rlce  = rlc;
		rlce.b += hd->rltext + hd->rldata;

#if L_VERBOSE
		rlcs  = rlc;
		send_msg("T%ld + D%ld = %ld\n", hd->rltext, hd->rldata, hd->rltext + hd->rldata);
		send_msg("rlc %ld, pc %ld\n", rlc.b, pc.b);
#endif

		if (ar->target eq FIX_text)
		{
			if (s->v ne 0)
				new_fixup(&ar->fixups, fl->names.area[0],
								ar->target, FIX_lcmod, ar->image, 0,
								LD_ranout);
			else
			{
				new_fixup(&ar->fixups, s->pn,
								ar->target, dri_mod2pc(s->ty), ar->image, 0,
								LD_ranout);
				fl->names.area[0]->nr = -1;    /* if the local name isnt used, remove it */
				s++;
			}
		}
		elif (ar->target ne FIX_offs)
			new_fixup(&ar->fixups, fl->names.area[ar->target - FIX_text],
							ar->target, FIX_lcmod, ar->image, 0,
							LD_ranout);

		while (pc.b <= pce.b and rlc.b <= rlce.b)
		{
			s = in_symtab(ar, pc, s);

			if (pc.b eq pce.b)
				break;
			if (rlc.b > rlce.b)
				break;

			if (!(    no_image(ar->target)
			      or ((fl->obty & 0xff) eq GFA and ar->target eq FIX_data)
			     )
			   )
			{
				if ((pc.i & 1) eq 0)		/* operand fixups only at even addresses */
				{
					uint x4, fw = *rlc.u&7, fx = *(rlc.u + 1)&7;

					switch(fw)
					{
						case 0:		/* nothing to fix */
							rlc.u++;
						break;
						case 1:		/* data.w */
						case 2:		/* text.w */
						case 3:		/* bss.w  */
							new_fixup(&ar->fixups,
										getname(fl, topc[fw], ar->target),
										ar->target, FIX_wabs, ar->image, pc.i,
										LD_ranout);
							rlc.u++;
						break;
						case 4:		/* symbol.w */
							x4 = *rlc.u >> 3;
							new_fixup(&ar->fixups, &pn[x4],
										ar->target, FIX_wabs, ar->image, pc.i,
										LD_ranout);
							rlc.u++;
						break;
						case 5:
							switch(fx)
							{
								case 0:
									rlc.u++;
								break;
								case 1:		/* data.l */
								case 2:		/* text.l */
								case 3:		/* bss.l  */
									new_fixup(&ar->fixups,
												getname(fl, topc[fx], ar->target),
												ar->target, FIX_labs, ar->image, pc.i,
												LD_ranout);
									rlc.u++;
								break;
								case 4:		/* symbol.l */
									x4 = *(rlc.u + 1) >> 3;
									new_fixup(&ar->fixups, &pn[x4],
												ar->target, FIX_labs, ar->image, pc.i,
												LD_ranout);
									rlc.u++;
								break;
								case 6:
									x4 = *(rlc.u + 1) >> 3;
									new_fixup(&ar->fixups, &pn[x4],
												ar->target, FIX_lpcrel, ar->image, pc.i,
												LD_ranout);
									rlc.u++;
								break;
								case 7:
#if L_VERBOSE
									send_msg("istart.L @ %ld\n", rlc.b - rlcs.b);
#endif
									rlc.u++;
								break;
							}
							rlc.u++;
							pc.u++;
						break;
						case 6:
							x4 = *rlc.u >> 3;
							new_fixup(&ar->fixups, &pn[x4],
									ar->target, FIX_wpcrel, ar->image, pc.i,
									LD_ranout);
							rlc.u++;
						break;
						case 7:
							x4 = *rlc.u >> 3;
							if (x4)
							{
								x4 *= sizeof(short);
								while (x4)
								{
									s = in_symtab(ar, pc, s);
									pc.b ++;
									x4--;
								}

								rlc.u ++;
								continue;
							}
#if L_VERBOSE
							else
								send_msg("istart.W @ %ld\n", rlc.b - rlcs.b);
#endif
							rlc.u++;
						break;
					}		/* switch fixup */
				}		/* if even */
			}		/* with image */

			pc.b++;		/* NOTE! pc is stepped 1 byte at a time for finding odd entries (DATA section) */

		}	/* while pc valid */

		ar = ar->next;
	}

	/* Remaining are the absolute and externals names.
	   Values of absolute names have no relation to the program counter (pc)
	   whatsoever, so the names are picked up in a separate loop.
	 */

	if (ar)				/* if a ar remains, its the offs area */
	{
		while(s < se)
		{
			if ((s->ty & 0x8) eq 0)		/* only need the offset names */
				new_fixup(&ar->fixups, s->pn, ar->target, dri_ent2pc(s->ty), 0, s->v, LD_ranout);
			s++;
		}
	}

	return true;
}

static
bool gfa_data(FLIST *fl)
{
	DRI_H *hd = &fl->h->dri;
	short i;
	long t = 0;
	PC drlc;

	if (hd->rldata eq 0)		/* The difference between GFA and DRI lies in the data reloc format */
		return false;			/* If no data, no difference :-) */

	drlc.b = hd->image + hd->ltext + hd->ldata + hd->lsym + hd->rltext;

	for (i = 0; i < hd->rldata; i += 2)
	{
		short ty = *drlc.u & 7, step = *drlc.u >> 3;
/*		send_msg("ty %d, step %d\n", ty, step);		*/

		if (ty ne 7)
			return false;

		t += step;

		if (step eq 8191)			/* special case */
			t++;

		drlc.u++;
	}

/*	send_msg("total rldata %ld\n", t); */
	return t eq hd->ldata;
}

static
bool load_dri(FLIST *fl)
{
	DRI_H *hd = &fl->h->dri;
	long size = fl->size;
	short have;

	/* do some checks */
	long l;

	fl->obty = DRI;
	if (hd->rltext eq 0 and hd->rldata eq 0)
	{
		hd->rltext = hd->ltext;
		hd->rldata = hd->ldata;
	othw
		if (gfa_data(fl))
			fl->obty = GFA, gfa = true;
	}

	l =   sizeof(DRI_H)
	    + hd->ltext
	    + hd->ldata
	    + hd->lsym,
	    + hd->rltext
	    + hd->rldata;

	if (l > size)
	{
#if L_VERBOSE
		send_msg("t %ld d %ld s %ld,   bss %ld\n", hd->ltext, hd->ldata, hd->lsym, hd->lbss);
		send_msg("rlt %ld rld %ld l %ld :: size %ld\n", hd->rltext, hd->rldata, l, size);
#endif
		return format_error(fl, 5);
	}

	have = get_dri_names(fl, hd);

/* make anonymous areas for the 3 segments */
	if (have & 2)
		dri_segment(fl, FIX_text);
	if (have & 4)
		dri_segment(fl, FIX_data);
	if (have & 1)
		dri_segment(fl, FIX_bss);
	if (have & 8)
		dri_segment(fl, FIX_offs);		/* container for absolute symbols */

	if (make_fixups(fl, hd))
	{
		if (!flags.j)
			make_symbol_tree(fl);
		return true;
	}
	else
		P.result = 12;

	return false;
}

static
char *gfa_name(char *s, bool app)
{
	static char n[16];
	short i = 13;

	strmaxcpy(n, s, 14);

	if (app)
		while (n[i] eq 0 and i)
			n[i--] = ' ';

	return n;
}

static
bool load_drilib(FLIST *fl)
{
	AR_F *b = &fl->h->drilib.f[0];
	FLIST *new = fl;

	while ((long)(b+1) < (long)fl->h + fl->size)
	{
		AR_H  *h  = &b->ah;
		DRI_H *hd = &b->dri;

		if (h->size <= 0)
		{
			format_error(fl, 6);
			break;
		}

		new = ins_flist(gfa_name(h->name, false), AH_CC_DRILIB, new, LD_ranout);
		if (new)
		{
			new->size = h->size;
			new->h = (FHD *)hd;
			load_dri(new);
		}

		b++;
		(long)b += h->size - sizeof(*hd);
	}

	return true;
}

#endif

#if GS_T

static
char *gst_names[]=
{
	"GST_0",
	"GST_source ",
	"GST_comment",
	"GST_org    ",
	"GST_section",
	"GST_offset ",
	"GST_xdef   ",
	"GST_xref   ",
	"GST_8",
	"GST_9",
	"GST_a",
	"GST_b",
	"GST_c",
	"GST_d",
	"GST_e",
	"GST_f",
	"GST_define ",
	"GST_11",
	"GST_common ",
	"GST_end"
};

static
char *trunc_rules[] =
{
	"byte,",
	"word,",
	"long,",
	"S,",
	"U,",
	"PC,",
	"relo,"
	"",
};

static
char *trunc(uchar c)
{
	static char s[256];
	short i = 0;
	*s = 0;
	while(c)
	{
		if (c & 1)
			strcat(s, trunc_rules[i]);
		c >>= 1;
		i++;
	}

	if (*s)
		*(s + strlen(s) - 1) = 0;	/* last comma */
	return s;
}

static
string pstr(string r, char * n)		/* get pascal string */
{
	uint c = *r++;
	while (c--)
		*n++ = *r++;
	*n = 0;
	return r;
}

static
string getlong(string r, long *l)
{
	*((string)l + 0) = *r++;
	*((string)l + 1) = *r++;
	*((string)l + 2) = *r++;
	*((string)l + 3) = *r++;
	return r;
}

static
string getshort(string r, short *i)
{
	*((string)i + 0) = *r++;
	*((string)i + 1) = *r++;
	return r;
}

typedef struct
{
	short fixes[GST_last];
	short names;
	long  lname, ltext, ldata, lbss;
	bool text, data, bss;
	short high_id;
} GST_C;

static
string pskstr(string r, GST_C *sp)		/* skip pascal string */
{
	uint c = *r++;
	sp->names += 1;
	sp->lname += c + 1;
	return r + c;
}

static
void count_gst(FLIST *fl, PC r, PC re, GST_C *sp)
{
	PC r0 = r;
	short section, trunc, id;
	long i, val, *to = &sp->ltext;

	pzero(sp);

	while (r.b < re.b)
	{
		uchar c = *r.b;

		if (c eq GST_escape)
		{
			i = r.b - r0.b;

			r.b++;
			c = *r.b;

			if (c < GST_last)
				sp->fixes[c]++;

			if (c eq GST_end)
				break;			/* while r */

			switch (c)
			{
			case GST_escape:
				*to += 1;
			break;
			case GST_comment:
				r.b++;
				r.b += *r.k + 1;
			continue;
			case GST_org:
				r.b += sizeof(long) + 1;
			continue;
			case GST_section:
				r.b++;
				r.b = getshort(r.b, &section);
				if (section eq -1)
					to = &sp->ltext, sp->text = true;
				elif (section eq -2)
					to = &sp->ldata, sp->data = true;
				elif (section eq -3)
					to = &sp->lbss, sp->bss = true;
				else
					format_error(fl, 20);
			continue;
			case GST_offset:
				r.b++;
				getlong(r.b, &val);
				*to += val;
			continue;
			case GST_xdef:
				r.b = pskstr(++r.b, sp);
				r.b += sizeof(long) + sizeof(short);
			continue;
			case GST_xref:
				r.b += sizeof(long) + 1;
				trunc = *r.b++;

				while ((uchar)*r.b ne GST_escape)
				{
					if   (*r.b eq '-')
						r.b += sizeof(short) + 1;
					elif (*r.b eq '+')
						r.b += sizeof(short) + 1;
					else
					{
						format_error(fl, 21);
						r.b++;
					}
					if (trunc & 1)
						*to += 1;
					elif (trunc & 2)
						*to += 2;
					elif  (trunc & 4)
						*to += 4;
				}
			break;
			case GST_define:
				r.b = getshort(++r.b, &id);
				if (id > sp->high_id)
					sp->high_id = id;
				r.b = pskstr(r.b, sp);
			continue;
			case GST_common:
				r.b += sizeof(short) + 1;
				r.b = pskstr(r.b, sp);
			continue;
			default:
				format_error(fl, 22);
				send_msg("%4ld unknown %d 0x%02x\n", i, c, c);
			}
		}
		else
			*to += 1;

		r.b++;
	}

	for (i = 0; i < GST_last; i++)
		if (sp->fixes[i])
			send_msg("%2ld,%-12s = %d\n", i, gst_names[i], sp->fixes[i]);
	send_msg("names %d, space %ld\n", sp->names, sp->lname);
	send_msg("highest id: %d\n", sp->high_id);
	send_msg("ltext %ld,%d, ldata %ld,%d, lbss %ld,%d\n",
		sp->ltext, sp->text, sp->ldata, sp->data, sp->lbss, sp->bss);
}

char temp[10000];

static
AREA *gst_segment(FLIST *fl, short target long size)
{
	AREA *ar = new_area(fl, target, "");

	if (ar)
	{
		ar->limage = size;
		if (!no_image(target))
			ar->image = CC_qalloc(&defmem, size + 1, LD_ranout, AH_CC_GSTAREA);
		ar->target = target;
	}
	else
		P.result = 21;

	return ar;
}

static
bool load_gst(FLIST *fl, PC *cur, PC re)
{
	AREA *ar, *text = nil, *data = nil, *bss = nil, *offs = nil;

	PC r0, r, t;
	long i;
	short trunc_rule;

	GST_C sp;

	count_gst(fl, *cur, re, &sp);
	if (P.result)
		return false;

	if (sp.text) text = gst_segment(fl, FIX_text, sp.ltext);
	if (sp.data) data = gst_segment(fl, FIX_data, sp.ldata);
	if (sp.bss ) bss  = gst_segment(fl, FIX_bss,  sp.lbss );
	offs = gst_segment(fl, FIX_offs, 0);

	r = *cur;
	r0 = r;

	ar = text ? text : data ? data : nil;

	while (r.b < re.b)
	{
		uchar c = *r.b;

		if (c eq GST_escape)
		{
			char name[256];
			short id;
			long val;

			i = r.b - r0.b;
			r.b++;
			c = *r.b;

			if (c eq GST_end)
			{
				r.b++;
				send_msg("%4ld %s\n", i, gst_names[c]);
				break;			/* while r */
			}
			else
			switch (c)
			{
			case GST_escape:
				send_msg("%4ld %4ld GST_escape\n", i, ar->allo);
				if (ar->image)
					*(ar->image + ar->allo) = *r.b;
				ar->allo++;
			break;
			case 0:
				send_msg("%4ld %4ld %s\n", i, ar->allo, gst_names[c]);
			break;
			case GST_comment:
				r.b++;
				r.b += *r.k + 1;
			continue;
			case GST_org:
				r.b++;
				r.b = getlong(r.b, &val);
				send_msg("%4ld %4ld %s %6ld\n", i, ar->allo, gst_names[c], val);
			continue;
			case GST_section:
				r.b++;
				r.b = getshort(r.b, &id);
				if (id eq -1)
					ar = text;
				elif (id eq -2)
					ar = data;
				elif (id eq -3)
					ar = bss;
				elif (id eq -4)
					ar = offs;
				send_msg("%4ld %4ld %s %3d\n", i, ar->allo, gst_names[c], id);
			continue;
			case GST_offset:
				r.b++;
				getlong(r.b, &val);
				ar->allo += val;
				send_msg("%4ld %4ld %s %6ld\n", i, ar->allo, gst_names[c], val);
			continue;
			case GST_xdef:
				r.b++;
				r.b = pstr(r.b, name);
				r.b = getlong(r.b, &val);
				r.b = getshort(r.b, &id);
				send_msg("%4ld %4ld %s %-15s = %3d @ %6ld\n", i, ar->allo, gst_names[c], name, id, val);
			continue;
			case GST_xref:
				r.b++;
				r.b = getlong(r.b, &val);
				trunc_rule = *r.b++;
				send_msg("%4ld %4ld %s %6ld ", i, ar->allo, gst_names[c], val);
				while (*r.k ne GST_escape)
				{
					short sz = trunc_rule & 7;
					if   (*r.b eq '-')
					{
						r.b++;
						r.b = getshort(r.b, &id);
						send_msg("-= %4d, ", id);
					}
					elif (*r.b eq '+')
					{
						r.b++;
						r.b = getshort(r.b, &id);
						send_msg("+= %4d, ", id);
					}
					else
						r.b++;

					if (ar->image eq nil)
					{
						format_error(fl, 30);
						ar->allo += sz;
					othw
						t.b = ar->image + ar->allo;

						if (sz eq 1)
							*t.b = val, ar->allo += sz;
						if (ar->allo & 1)
							send_msg("to odd\n");
						elif (sz eq 2)
							*t.w = val, ar->allo += sz;
						elif  (sz eq 4)
							*t.l = val, ar->allo += sz;
					}
				}
				send_msg("0x%02x %s\n", trunc_rule, trunc(trunc_rule));
			break;
			case GST_define:
				r.b++;
				r.b = getshort(r.b, &id);
				r.b = pstr(r.b, name);
				send_msg("%4ld %4ld %s %-15s = %3d\n", i, ar->allo, gst_names[c], name, id);
			continue;
			case GST_11:
				send_msg("%4ld %4ld%s\n", i, ar->allo, gst_names[c]);
			break;
			case GST_common:
				r.b++;
				r.b = getshort(r.b, &id);
				r.b = pstr(r.b, name);
				send_msg("%4ld %4ld %s %-15s = %3d\n", i, ar->allo, gst_names[c], name, id);
			continue;
			}
		othw
			if (ar->image)
				*(ar->image + ar->allo) = *r.b;
			ar->allo++;
		}

		r.b++;
	}

	*cur = r;

	return false;
}

static
bool load_gstlib(FLIST *fl)
{
	PC r, re;
	FLIST *new = fl;

	r.b = (string )fl->h;
	re.b = r.b + fl->size;

	while (r.i < re.i)
	{
		char name[256];

		if (*r.k eq GST_escape and *(r.k + 1) eq GST_source)
		{
			r.u++;
			r.b = pstr(r.b, name);
			send_msg("GST object %s\n", name);

			new = ins_flist(name, AH_CC_GSTLIB, new);
			if (new)
			{
				load_gst(new, &r, re);
				new->obty = GST;
			}
		}
		else
			return format_error(fl, 7);
	}

	return true;
}

#endif

global
bool load_ob(FLIST *fl)
{
	if (fl->name)
	{
		if (SCMP(325, fl->name, stackname) eq 0)
		{
			if (stacksize > 0xffffff)
				stacksize = 0xffffff;
			memmove(stack_ob, stack_ob_init, sizeof(stack_ob_init));
			(short *)fl->h = stack_ob;
			stack_ob[19] = stacksize/256;
			fl->size = sizeof(stack_ob);
		othw
			P.num_files++;
			(char * )fl->h = CC_load(fl->name, nil, &fl->size, "while loading object file", AH_LOAD_OB);
		}

		if (fl->h)
		{
			if (flags.v)
				send_msg("Loaded '%s'\n", fl->name);
			if   (fl->h->pc.magic eq PMAGIC)
				return load_pure(fl);
#if DR_I
			elif (fl->h->dri.magic eq DLMAGIC)
				return load_drilib(fl);
			elif (fl->h->dri.magic eq DMAGIC)
				return load_dri(fl);
#endif
#if GS_T
			elif (fl->h->gst.magic eq GMAGIC)
				return load_gstlib(fl);
#endif
			else
			{
				send_msg("ld: %s no object file\n", fl->name);
				return false;
			}
		}
		else
			send_msg("Can't open object file '%s'\n", fl->name);
	}
	else
		send_msg("invalid name\n");

	return false;
}
