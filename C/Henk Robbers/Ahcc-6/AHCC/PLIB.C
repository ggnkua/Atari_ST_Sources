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
 * plib.c
 *
 * lib functions for the Pure C object format
 *     common between ld.c, po.c and as_out.c
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>
#include "param.h"
#include "common/mallocs.h"

const char * pluralis(short);

#undef prior
#undef next

#include "po.h"				/* Pure objects */
#include "plib.h"
#undef NL
#if 0
#define NL newl()
#else
#define NL
#endif

global
long bin_size;


static
short result = 0;

global
MEMBASE defmem, refmem, opndmem;

static
char *target_txt[] =
{ "TEXT", "DATA", "BSS ", "OFFS" };
static
char *fixnames[]=
{
	"0   ", "END ", "STEP", "TEXT", "DATA", "BSS ", "OFFS", "GL_M",
	"GL_E", "LC_M", "LC_E", "L_AB", "W_AB", "L_PC", "W_PC", "F   ",
	"B_PC", "W_BR", "S_BR", "HIGH", "*20*", "*21*", "*22*", "*23*",
	"*24*", "*25*", "*26*", "*27*", "*28*", "*29*", "*30*", "*31*"
};

static void newl   (void)           { console("\n");                               }
static void barrier(void)           { console("================================\n"); }
static void l9     (long l, Cstr s) { console(" %9ld %s\n", l, s ? s : "");        }


#define SPM 32
static
void sp(short n)
{
	char spaces[SPM + 1], *s = spaces;
	if (n > SPM) n = SPM;
	while (n-- > 0) *s++ = ' ';
	*s = 0;
	console(spaces);
}

static
void byli(long b, long l)
{
	console(" bytes\t:"); l9(b, nil);
	console(" lines\t:"); l9(l, nil);

	if (l)
	console("\t\t="); l9(b/l, "bytes/line");
}

static
void adl(short l, char c)
{
	char ss[12], *s = ss;
	while (l--) *s++ = c;
	*s = 0;
	console(" %s +\n", ss);
}

static
void pl(Cstr wc, Cstr wh, long c, long h)
{

	short lc = strlen(wc),
	      lh = strlen(wh),
	      ss = lc > lh ? lc : lh;

	console(" %*s:", ss, wc); l9(c, nil);
	console(" %*s:", ss, wh); l9(h, nil);
	sp(ss+2); adl(9, '-');
	sp(ss+2); l9(c + h, nil);
	newl();
}

global
void init_stats(void)
{
	zero(stats);
	stats.start = clock()/2;
}

global
void pr_stats(void)
{
	long cmins, csecs, secs, cobytes, colines;

	depth = 0;

	NL;
	newl();
	console("'Make all' statistics\n");
	barrier();
	console("Project:\n");
	byli(stats.bytes, stats.lines);

	cobytes = stats.cbytes + stats.hbytes;
	colines = stats.clines + stats.hlines;

	NL;
	newl();
	console("Compiled:\n");
	pl("input  ", "headers", stats.I, stats.H);

	NL;
	byli(cobytes, colines);

	NL;
	pl("bytes in input  ", "bytes in headers", stats.cbytes, stats.hbytes);
	if (stats.I or stats.H)
	{
		if (stats.I)
			console(" bytes /  input  :"); l9(stats.cbytes/stats.I, nil);
		if (stats.H)
			console(" bytes /  header :"); l9(stats.hbytes/stats.H, nil);
	}

	NL;
	pl("lines in input  ", "lines in headers", stats.clines, stats.hlines);

	stats.limit = clock()/2;
	stats.time = stats.limit - stats.start;

	csecs = stats.time/100;
	cmins = csecs/60;
	secs  = csecs%60;

	NL;
	console(" time   : %4ld' %02ld\" (%ld second%s)\n", cmins, secs, csecs, pluralis(csecs) );

	if (csecs)
	{
		sp(8); console("="); l9(stats.cbytes/csecs, "bytes/second");
		sp(9);                l9(stats.clines/csecs, "lines/second");
	}

	barrier();
	NL;
}


global
bool is_ref(short ty)
{
	switch (ty)
	{
		case FIX_labs:
		case FIX_wabs:
		case FIX_lpcrel:
		case FIX_wpcrel:
		return true;
	}
	return false;
}

global
bool is_entry(short ty)
{
	switch (ty)
	{
		case FIX_glmod:
		case FIX_glent:
		case FIX_lcmod:
		case FIX_lcent:
		return true;
	}
	return false;
}

global
bool is_lc_entry(short ty)
{
	switch (ty)
	{
		case FIX_lcmod:
		case FIX_lcent:
		return true;
	}
	return false;
}

global
bool is_gl_entry(short ty)
{
	switch (ty)
	{
		case FIX_glmod:
		case FIX_glent:
		return true;
	}
	return false;
}

global
short ldhash(Cstr key)
{
	if (*key)
	{
		Cstr s = key;
		short i = 8;
		short k = 0;

		while (*s and i)
			k = (((k << 1) + (k >> 14)) ^ (*s++)) & 0x3fff,
			--i;

		k %= NHASH;
		return k;
	}
	else
		return 0;
}

global
bool no_image(short ty)
{
	switch (ty)
	{
		case FIX_bss:
		case FIX_offs:
		return true;
	}
	return false;
}

global
bool is_module(short ty)
{
	switch (ty)
	{
		case FIX_glmod:
		case FIX_lcmod:
		return true;
	}
	return false;
}

global
char * fixup_name(short ty)
{
	if (ty >= 0 and ty < FIX_HIGH)
		return fixnames[ty];
	else
		return "~~2";
}

global
void disp_fix(FIXUP *f, short level, char *out)
{
	console("%d>fixup %s %3d, FIX(%3d,%3d,%3d) %4ld, @ %6ld %6ld [%3d]%s\n",
			level,
			fixup_name(f->fix.ty),
			f->target,
			f->fix.ty,
			f->fix.sk,
			f->fix.nnr,
			out + f->disp,
/*			f->start,
*/			f->disp,
			f->step,
			f->name ? f->name->nr : -1,
			f->name ? (f->name->s ? f->name->s : "") : ""
			);
}

global
void list_fixups(FIXUP *f)
{
	while (f)
	{
		disp_fix(f, 0, 0);
		f = f->next;
	}
}

global
void list_all_fixups(void)
{
	FLIST *fl = P.fbase.first;
	while (fl)
	{
		AREA *ar = fl->areas.first;
		while (ar)
		{
			FIXUP *f = ar->fixups.first;

			while (f)
			{
				disp_fix(f, 0, ar->out);
				f = f->next;
			}
			ar = ar->next;
		}
		fl = fl->next;
	}
}

global
char * disp_target(short tg)
{
	if (tg >= FIX_text and tg <= FIX_offs)
		return target_txt[tg - FIX_text];
	else
		return "";
}

global
void list_refs(REFS *rf, bool in)
{
	while (rf)
	{
		FIXUP *f = rf->fx;
		Cstr intx, flname;

		if (in)
		{
			intx = "in ";
			flname = f->in->in->name;
		othw
			intx = "";
			flname = "";
		}

#if P_VERBOSE
		console("%6ld + %6ld\t", f->in->out, f->disp);
		if (is_module(f->fix.ty) or *f->in->name eq 0)
			console("%s %s nd %d %s %s\n",
				fixup_name(f->fix.ty), f->name->s, f->name->nr, intx, flname);
		else
			console("%s %-32s nd %d in '%s' %s %s\n",
				fixup_name(f->fix.ty), f->name->s, f->name->nr, f->in->name, intx, flname);
#else
		if (is_module(f->fix.ty) or *f->in->name eq 0 or *f->in->name eq '~' or is_tmplab(f))
			console("%-18s %s%-18s\n",
				f->name->s, intx, flname);
		else
			console("%-18s in %-18s %s%-18s\n",
				f->name->s, f->in->name, intx, flname);
#endif
		rf = rf->next;
	}
}

static
void disp_area(AREA *new, bool out, short level)
{
	if (out)
	{
		Cstr n = new->name;
#if ! P_VERBOSE
		if (*n eq '~' and *(n+1) eq '_')
			n = "";
#endif
		console("%d>area at %6ld [%6ld]  %s %s\n",
				level,
				new->out,
				new->limage,
				disp_target(new->target),
				n
				);
	}
	else
		console("%d>%s area at %08lx [%6ld]  %s %s\n",
				level,
				new->referenced ? "referenced" : "          ",
				new->image,
				new->limage,
				disp_target(new->target),
				new->name
				);
}

global
void list_areas(AREA *ar, bool out)
{
	while (ar)
	{
		if (ar->referenced)
			disp_area(ar, out, 0);
		ar = ar->next;
	}
}

#define USEHASH 1
global
void clr_treebase(REFBASE *rb, bool hashed, short numhash, REFS **hash_row, char *name)
{
	rb->first = nil;		/* order of appearance */
	rb->last  = nil;
	rb->unhashed = nil;
	rb->name = name;
	rb->hashed =
#if USEHASH
	             hashed;
#else
	             false;
#endif
	rb->numhash = numhash;
	if (rb->hashed)
	{
		while (numhash > 0)
			hash_row[--numhash] = nil;
		rb->ha_tree = hash_row;
	}
	else
		rb->ha_tree = &rb->unhashed;
}


static
void *create_last(MEMBASE *mb, void *base, short l, XA_run_out *ranout)
{
	LIST *new = CC_qalloc(mb, l, ranout, AH_CC_LIST);
	ins_last(base, new);
	return new;
}

static
void *create_after(MEMBASE *mb, void *base, void *after, short l, XA_run_out *ranout)
{
	LIST *new = CC_qalloc(mb, l, ranout, AH_CC_LIST);
	ins_after(base, after, new);
	return new;
}

static
void *create_before(MEMBASE *mb, void *base, void *before, short l, XA_run_out *ranout)
{
	LIST *new = CC_qalloc(mb, l, ranout, AH_CC_LIST);
	ins_before(base, before, new);
	return new;
}

global
FLIST * ins_flist(Cstr f, XA_key key, FLIST *after, XA_run_out *ranout)
{
	FLIST *new;

	if (after)
		new = create_after(&defmem, &P.fbase, after, sizeof(*new), ranout);
	else
		new = create_last (&defmem, &P.fbase,        sizeof(*new), ranout);

	if (new)
	{
		Wstr s = CC_qalloc(&defmem, strlen(f) + 1, ranout, key);
		if (s)
			strcpy(s, f);
		new->name = s;
		new->h = nil;
		new->size = 0;
		new->obty = 0;
		new->names.high = 0;
		new->names.base = nil;

		clr_listbase(&new->fixups);
		clr_listbase(&new->areas);
		clr_treebase(&new->l_ents, false, 0, nil, "file local entries");
	}

	return new;
}


VpV list_flist
{
	FILEBASE *fb = &P.fbase;
	FLIST *this = fb->first;

	console("****  list of %s\n", fb->name);

	while (this)
	{
		Cstr s = this->name;
		console("%s\n", s);
		this = this->next;
	}

	console("****\n");
}

void
new_flist(Cstr name)
{
	P.fbase.name = name;
}

/* serial (local entries need not have unique name) */
global
REFS * ins_ref(MEMBASE *mb, REFBASE *rb, AREA *area, FIXUP *f, XA_run_out *ranout)
{
	REFS *new = create_last(mb, rb, sizeof(*new), ranout);
	if (new)
	{
		P.num_refs++;
		new->fx = f;
		new->fx->in = area;
		new->less = nil;
		new->great = nil;
		new->obty = 0;
	}

	return new;
}

global
FIXUP * new_fixup(FIXBASE *this, PO_NAME *name,
                  short target, short ty, char *start, long disp,
                  XA_run_out *ranout)
{
	FIXUP *new = create_last(&defmem, this, sizeof(*new), ranout);

	if (new)
	{
		P.num_fixups++;
		new->in     = nil;
		new->out    = nil;
		new->fix.ty = ty;
		new->fix.sk = 0;			/* recalculated at a later stage */
		new->fix.nnr= name ? name->nr : -1;
		new->target = target;
		new->start  = start;
		new->disp   = disp;
		new->step   = 0;
		new->name   = name;
	}

	return new;
}

global
AREA * new_area(FLIST *fl, short target, Cstr name, XA_run_out *ranout)
{
	AREA *new = create_last(&defmem, &fl->areas, sizeof(*new), ranout);
	if (new)
	{
		P.num_areas++;
		new->target     = target;
		new->id         = P.num_areas;
		new->class      = target;
		new->image      = nil;
		new->limage     = 0;
		new->allo       = 0;
		new->referenced = false;
		new->out        = nil;
		new->name       = name;
		new->in         = fl;
		clr_listbase(&new->fixups);
		clr_treebase(&new->o_refs, false, 0, nil, "area outside refs");
		clr_treebase(&new->a_refs, false, 0, nil, "area anonymous refs");
		clr_treebase(&new->lbls,   false, 0, nil, "area branch labels");
	}

	return new;
}

static
AREA *last_area;

global
char * add_areas(short ty, char **to, long *l)
{
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		AREA *ar = fl->areas.first;
		while (ar)
		{
			if (ar->target eq ty)
			{
				last_area = ar;
				ar->out = *to;
				if (ar->limage & 1)		/* 04'09 make even */
					ar->limage++;
				*to += ar->limage;
				*l  += ar->limage;
#if 0
				disp_area(ar, 1, 0);
#endif
			}

			ar = ar->next;
		}

		fl = fl->next;
	}

	return *to;
}

static
char * handle_fixups(short ty, char *where, FIXUP **prior, XA_run_out *ranout)
{
	FLIST *fl = P.fbase.first;
	FIXUP *pr = *prior;

	/* remove local names and entries that are no longer needed */
	while (fl)
	{
		AREA *ar = fl->areas.first;
		PO_NAME *n = fl->names.base;

		if (n)
		if (n->s)
		if (*n->s eq WARN_AREA)
			n->nr = -1;

		while (ar)
		{
			if (ar->target eq ty)
			{
				FIXUP *f = ar->fixups.first;

				while (f)
				{
					FIXUP *fx = f->next;

					if (f->name)
					{
						if (   (f->name->s and *f->name->s eq WARN_AREA)
						    or is_tmplab(f)
						   )
						{
							if (f->fix.ty eq FIX_lcent)
							{
#if P_VERBOSE
								console("handle_fixups: %d, -1 --> %s\n",
											f->name->nr, f->name->s ? f->name->s : "~~~");
#endif
								if (f->name->s eq nil)
									console("CE: local entry format error: nil name\n");

								f->name->nr = -1;			/* remove fixup if TLAB */
								rem_list(&ar->fixups, f);
							othw
#if P_VERBOSE
								console("handle_fixups: %d, /0 --> %s\n",
									f->name->nr, f->name->s ? f->name->s : "~~~");
#endif
								if (f->name->s eq nil)
									console("CE: fixup format error: nil name\n");
								else
									*f->name->s = 0;
								f->name->l = 0;
							}
						}
					}

					f = fx;
				}
			}

			ar = ar->next;
		}

		fl = fl->next;
	}

	/* calculate distances between fixups */
	fl = P.fbase.first;
	while (fl)
	{
		AREA *ar = fl->areas.first;

		while (ar)
		{
			if (ar->target eq ty)
			{
				FIXUP *f = ar->fixups.first;

				while (f)
				{
					char *to = ar->out + f->disp;
					long sk = to - where;

					if (sk >= VAL_step)
					{
						long skip  = sk/VAL_step;
						FIXUP *nf = create_before(&defmem, &ar->fixups, f, sizeof(*nf), ranout);

						if (nf)
						{
							nf->start  = f->start;
							nf->in     = f->in;
							nf->out    = f->out;
							nf->target = f->target;
							nf->disp   = where - ar->out + skip*VAL_step;
							nf->name   = nil;
							nf->fix.ty = FIX_step;
							nf->fix.sk = skip >> 16;
							nf->fix.nnr= skip & 0xffff;
							nf->step   = sk;  /* skip*VAL_step; */
							where += skip*VAL_step;
							f->fix.sk = to - where;
						othw
							result = 1;
							break;
						}
					othw
						f->fix.sk = sk;
						if (pr)
							pr->step = sk;
					}
					where = to;
					pr = f;
					f = f->next;
				}
			}
			if (result) break;

			ar = ar->next;
		}
		if (result) break;

		fl = fl->next;
	}

	*prior = pr;
	return where;
}

static
char * add_fixups(char **to, long *count)
{
	long nf = 0;

	FLIST *fl = P.fbase.first;

	while (fl)
	{
		AREA *ar = fl->areas.first;

		while (ar)
		{
			FIXUP *f = ar->fixups.first;

			while (f)
			{
				nf++;
				f = f->next;
			}

			ar = ar->next;
		}

		fl = fl->next;
	}

	*count = nf * sizeof(FIX);

#if P_VERBOSE
	console("\n%ld fixups\n\n", nf);
#endif

	return *to + nf * sizeof(FIXUP);
}

static
char * add_names(char **to, long *count)
{
	long nn = 0, nametotal = 0;
	FLIST *fl = P.fbase.first;

#if P_VERBOSE
	console("**** Names ****\n\n");
#endif

	while (fl)
	{
		PO_NAME *nb = fl->names.base;
#if P_VERBOSE
		console("---- in %s -----\n\n", fl->name);
#endif
		if (nb)
		{
			short i = 0;

			while (i < fl->names.high)
			{
				PO_NAME *pn = &nb[i];
				if (pn->nr ne -1)
				{
					nametotal += pn->l + 1;
#if 0 /* P_VERBOSE */
					console("[%3ld] %6d %3d %3d %08lx %08lx %s\n",
							nn, pn->nr, pn->ty, pn->l, *(long *)pn, pn->s, pn->s);
#endif
					pn->nr = nn;		/* renumber */
					nn++;
				}

				i++;
			}
		}

		fl = fl->next;
	}

#if P_VERBOSE
	console("\n%ld names in %ld bytes\n\n", nn, nametotal);
#endif

	*count = nametotal;
	return *to + nametotal;
}

global
void write_areas(long hdl, short ty)
{
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		AREA *ar = fl->areas.first;

		while (ar)
		{
			if (ar->target eq ty and ar->limage)
			{
#if 0 /* P_VERBOSE */
				console("writing area %3d class %d [%6ld] %s\n", ar->id, ar->class, ar->limage, ar->name);
#endif
				P.num_areas++;
				if (hdl > 0)
				{
					long have = Fwrite(hdl, ar->limage, ar->image);
					if (have ne ar->limage)
					{
						console("Couldnt write %s\n", P.fbase.name);
						result = 2;
						break;
					}
				othw
					memmove(P.fbase.to_image, ar->image, ar->limage);
					P.fbase.to_image += ar->limage;
				}
			}

			ar = ar->next;
		}

		if (result) break;

		fl = fl->next;
	}
}

static
bool wfixup(long hdl, FIX *fix)
{
	if (hdl > 0)
	{
		long have = Fwrite(hdl, sizeof(FIX), fix);
		if (have ne sizeof(FIX))
		{
			console("Couldnt write %s\n", P.fbase.name);
			result = 2;
			return false;
		}
	othw
		memmove(P.fbase.to_image, fix, sizeof(FIX));
		P.fbase.to_image += sizeof(FIX);
	}

	return true;
}

static
void segment_fixup(short ty, XA_run_out *ranout)
{
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		AREA *ar = fl->areas.first;

		while (ar)
		{
			if (ar->target eq ty)
			{
				FIXUP *f = ar->fixups.first;

				if (!f or (f and f->fix.ty ne ty))		/* if not already there */
				{
					FIXUP *nf = create_before(&defmem, &ar->fixups, f, sizeof(*f), ranout);
					if (nf)
					{
						nf->start  = f ? f->start : 0;
						nf->in     = f ? f->in    : ar;
						nf->out    = f ? f->out   : nil;
						nf->target = ty;
						nf->disp   = 0;
						nf->name   = nil;
						nf->step   = 0;
						nf->fix.ty = ty;
						nf->fix.sk = 0;
						nf->fix.nnr = -1;
					}
					else
						result = 1;
				}
				return;			/* only the first */
			}
			ar = ar->next;
		}
		fl = fl->next;
	}
}

static
void write_fixups(long hdl, short ty)
{
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		AREA *ar = fl->areas.first;

		while (ar)
		{
			if (ar->target eq ty)
			{
				FIXUP *f = ar->fixups.first;

				while (f)
				{
					PO_NAME *pn = f->name;

					if (pn)
						f->fix.nnr = pn->nr;

					if (!wfixup(hdl, &f->fix))
						break;

					f = f->next;
				}
			}
			if (result) break;

			ar = ar->next;
		}
		if (result) break;

		fl = fl->next;
	}
}

static
void
write_names(long hdl)
{
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		PO_NAME *nb = fl->names.base;
		if (nb)
		{
			short i;

			for (i = 0; i < fl->names.high; i++)
			{
				PO_NAME *pn = &nb[i];

				if (pn->nr ne -1)
				{
					long l = pn->l;

					if (hdl > 0)
					{
						long have;
						char name[258];
						name[0] = l;

						if (l)
							strcpy(name + 1, pn->s);
						have = Fwrite(hdl, l + 1, name);
						if (have ne l + 1)
						{
							console("Couldnt write %s\n", P.fbase.name);
							result = 2;
							break;
						}
					othw
						char *to = P.fbase.to_image;
						*to++ = l;
						strcpy(to, pn->s);
						P.fbase.to_image += l + 1;
					}
				}
			}
		}

		if (result) break;

		fl = fl->next;
	}
}

global
void write_object(Cstr name, short verbose, bool compile, XA_run_out *ranout)
{
	long hdl;
	long    ltext = 0, ldata = 0,   lbss = 0,   lname = 0, lfix = 0, loffs = 0;
	Wstr ttext = 0, tdata = 0,               tname = 0, tfix  = 0;
	char *where = nil;
	FIXUP *pr = nil;
	PC_H header;

	bin_size = 0;
	last_area = nil;				/* 05'13 HR v4.15 */
	/* Calculate area start addresses and sizes */
	tdata = add_areas(FIX_text, &ttext, &ltext);
            add_areas(FIX_data, &tdata, &ldata);
	tfix  = add_areas(FIX_bss,  &tdata, &lbss);
	        add_areas(FIX_offs, &tdata, &loffs);

	if (last_area)
		new_fixup(&last_area->fixups, nil, FIX_end, FIX_end,
		           last_area->image, last_area->limage,
		           ranout);

	segment_fixup(FIX_text, ranout);
	segment_fixup(FIX_data, ranout);
	segment_fixup(FIX_bss,  ranout);
	segment_fixup(FIX_offs, ranout);

	where = handle_fixups(FIX_text, where, &pr, ranout);
	where = handle_fixups(FIX_data, where, &pr, ranout);
	where = handle_fixups(FIX_bss,  where, &pr, ranout);
	        handle_fixups(FIX_offs, where, &pr, ranout);

	tname = add_fixups(&tfix,  &lfix);
	        add_names (&tname, &lname);		/* and renumber names */

	if (verbose > 1)
	{
		console("  bss        : %6ld\n", lbss);
		console(" text        : %6ld\n", ltext);
		console(" data        : %6ld\n", ldata);
		console("\n");
		console("image section: %6ld  (text+data)\n", ltext + ldata);
		console("fixup section: %6ld\n", lfix);
		console(" name section: %6ld\n", lname);
		console("\n");
	}

	hdl = Fcreate(name, 0);
	if (hdl > 0)
	{
		zero(header);
		header.magic  = PMAGIC;
		header.he     = PPMAGIC;
		header.limage = ltext + ldata;
		header.lfixup = lfix;
		header.lnames = lname;
		Fwrite(hdl, sizeof(header), &header);

		P.num_areas = 0;
		P.fbase.image = xmalloc(ltext + ldata + 4, AH_WOB_IMAGE);
		if (P.fbase.image eq nil)
		{
			write_areas(hdl, FIX_text);
			write_areas(hdl, FIX_data);
		othw
			P.fbase.to_image = P.fbase.image;

			write_areas(-1, FIX_text);
			write_areas(-1, FIX_data);

			Fwrite(hdl, ltext + ldata, P.fbase.image);
			xfree(P.fbase.image);
		}

		P.fbase.image = xmalloc(lfix + 4, AH_WOB_FIX);
		if (P.fbase.image eq nil)
		{
			write_fixups (hdl, FIX_text);
			write_fixups (hdl, FIX_data);
			write_fixups (hdl, FIX_bss);
			write_fixups (hdl, FIX_offs);
		othw
			P.fbase.to_image = P.fbase.image;

			write_fixups (-1, FIX_text);
			write_fixups (-1, FIX_data);
			write_fixups (-1, FIX_bss);
			write_fixups (-1, FIX_offs);

			Fwrite(hdl, lfix, P.fbase.image);
			xfree(P.fbase.image);
		}

		P.fbase.image = xmalloc(lname + 4, AH_WOB_NAMES);
		if (P.fbase.image eq nil)
		{
			write_names(hdl);
		othw
			P.fbase.to_image = P.fbase.image;

			write_names(-1);

			Fwrite(hdl, lname, P.fbase.image);
			xfree(P.fbase.image);
		}

		bin_size = ltext + ldata + lfix + lname + sizeof(header);
		Fclose(hdl);
	}
}
