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
 * ld.c
 *
 * built in linker for Pure C object format
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <tos.h>
#include <setjmp.h>

#include "common/mallocs.h"
#include "common/amem.h"
#include "param.h"

#define REDIRECT 0		/* later */
#define TEST_CHECK 1

#undef prior
#undef next

#include "po.h"				/* Pure objects */
#include "ld_ob.h"			/* any object   */
#include "plib.h"

#if ! BIP_CC
global
AHCOUT *bugf = stdout;
#endif

static
FIXUP *BaseA4;

static
long lreloc;

global
long stacksize;
static
Wstr sttext, stdata, stbss;		/* start addresses for ROM images */
static
long imgsize;

#define DEFSTACK 4096		/* default stacksize is Pure C compatible */

global
char stackname[] = "StckSize";

global
FLGS flags;		/* is zeroed */

static
REFS *ex_row[NHASH],
     *gl_row[NHASH],
     *out_row[NHASH];			/* for hashing */

static
REFBASE ex_base,			/* outside refs */
        out_base;			/* for checking double refs on output */
global
REFBASE gl_base;			/* global entries */

global
short ld_lbl = 0;

static
Cstr oname;

#if ! BIP_LD || TTPLD
PO_COMMON P = {0};
#endif

/* Because LD mostly needs its tables all the time
   there is no need to allow a individual free facility, hence this
   very fast and very simple method of allocating structures.
   Note that this forces the use of AHCM which provides
   multiple heaps.
*/

extern
MEMBASE defmem, refmem;

static
REFS *last;
static
short cmp, name_d;
static
PO_NAME *rname;
#define EQ8 1		/* In Pure C libs names that are 8 bytes may match longer names or vice versa. */

/* recursion must start with last not nil!! */
static
short bfind_ref(REFS *rf)
{
	if (rf)
	{
		last = rf;	/* if not found we must keep the last ref and the comparison result */
		cmp = SCMP(320, rname->s, rf->fx->name->s);
		if (cmp < 0)
			return bfind_ref(rf->less);
		if (cmp > 0)
			return bfind_ref(rf->great);
	}
	return cmp;
}

static
REFS *find_ref(REFBASE *rb, PO_NAME *name)
{
	cmp = 1;		/* not having to stack these saves a lot of time */
	last = nil;
	rname = name;
	cmp = bfind_ref(rb->ha_tree[rb->hashed ? rname->hash : 0]);
	return cmp eq 0 ? last : nil;
}

#if EQ8
static
REFS *eq8;
#endif

static
PO_NAME *gname;

/* global refs search: allow 8 byte equality in Pure C libs */
static
short gbfind_ref(REFS *rf)
{
	if (rf)
	{
		PO_NAME *n = rf->fx->name;

		last = rf;	/* if not found we must keep the last ref and the comparison result */
#if EQ8
		if (
#if 1
		        (rf->obty & PURE_C) ne 0		/* 05'17 HR: v5.6 not also lib */
#else
		        rf->obty eq (PURE_C|LIB)
#endif
		    and n->l >= 8 and gname->l >= 8
		   )
		{
			cmp = strncmp(gname->s, n->s, 8);
			if (cmp eq 0)
			{
				eq8 = rf;	    /* remember found first 8 bytes equal */
								/* go on because complete equality prevails */
				if (n->l > 8 or gname->l > 8)
					cmp = SCMP(321, gname->s + 8, n->s + 8);
			}
		}
		else
#endif
			cmp = SCMP(322, gname->s, n->s);

		if (cmp < 0)
			return gbfind_ref(rf->less);
		if (cmp > 0)
			return gbfind_ref(rf->great);
	}
	return cmp;
}

static
REFS *gfind_ref(REFBASE *rb, PO_NAME *name)
{
#if EQ8
	eq8 = nil;		/* not having to stack these saves a lot of time */
#endif
	cmp = 1;
	last = nil;
	gname = name;

	cmp = gbfind_ref(rb->ha_tree[rb->hashed ? gname->hash : 0]);

	if (cmp ne 0)			/* if not found complete equality return eq8 if there */
	{
#if EQ8
		return eq8;
#else
		return nil;
#endif

	}
	else
		return last;
}

static
short bfind_locref(REFS *rf)
{
	if (rf)
	{
		last = rf;	/* if not found we must keep the last ref and the comparison result */
		cmp = name_d eq rf->fx->name->nr
		    ? 0
		    : (name_d < rf->fx->name->nr
		      ? -1
		      : 1
		      );
		if (cmp < 0)
			return bfind_locref(rf->less);
		if (cmp > 0)
			return bfind_locref(rf->great);
	}
	return cmp;
}

global
REFS *find_locref(REFBASE *rb, short nd)
{
	cmp = 1;		/* not having to stack these saves a lot of time */
	last = nil;
	name_d = nd;
	cmp = bfind_locref(*rb->ha_tree);
	return cmp eq 0 ? last : nil;
}

static
void ins_bref(REFBASE *rb, REFS *rf)
{
	REFS **pf = &rb->ha_tree[rb->hashed ? rf->fx->name->hash : 0];

	if (*pf)
	{
		if (cmp < 0)
			last->less = rf;
		else
			last->great = rf;

		rf->parent = last;
	othw
		*pf = rf;
		rf->parent = nil;
	}
}

static
void new_bref(REFBASE *rb, REFS *rf)
{
	REFS *nm = find_ref(rb, rf->fx->name);
	if (!nm)
		ins_bref(rb, rf);
}

/* For trees without parent pointer */
static
REFS *find_parent(REFS *rb, REFS *rf)
{
	REFS *xf;
	if (rb eq rf)
		return nil;		/* means root of tree */
	if (rb->less)
	{
		if (rb->less eq rf)
			return rb;
		xf = find_parent(rb->less, rf);
		if (xf)
			return xf;
	}
	if (rb->great)
	{
		if (rb->great eq rf)
			return rb;
		xf = find_parent(rb->great, rf);
		if (xf)
			return xf;
	}
	return nil;
}

void send_msg(char *text, ...);

static
void list_tree(REFS *rf, char c, short lvl, bool with_parent)
{
	if (rf)
	{
		short level = lvl;

		while(level--)
			send_msg(" ");
		if (rf->fx)
		{
			if (with_parent)
				send_msg("%c nd %d %s\t\t%s\n",
						c, rf->fx->name->nr, rf->fx->name->s,
						rf->parent ? rf->parent->fx->name->s : "~~~");
			else
				send_msg("%c nd %d %s\n", c, rf->fx->name->nr, rf->fx->name->s);
		}
		else
			send_msg("%c %s\t\t%s\n",
					c, "NO FX",
					rf->parent
					?
					(  rf->parent->fx
					   ? rf->parent->fx->name->s
					   : "NO PARENT FX"
					)
					: "~~~");

		list_tree(rf->less,  '<', lvl + 1, with_parent);
		list_tree(rf->great, '>', lvl + 1, with_parent);
	}
}

static
void list_ordered_tree(REFS *rf)
{
	if (rf)
	{
		list_ordered_tree(rf->less);
		send_msg("%s\n", rf->fx->name->s);
		list_ordered_tree(rf->great);
	}
}

static
void *remove_ref(REFBASE *rb, REFS *rf)
{
	REFS **pf = &rb->ha_tree[rb->hashed ? rf->fx->name->hash : 0];

	REFS *nx = rf->next,
	    *pr = rf->prior,
	    *les = rf->less,
	    *gre = rf->great;

/* remove from the list is easy */

	if (pr)
		pr->next = nx;
	else
		rb->first = nx;

	if (nx)
		nx->prior = pr;
	else
		rb->last = pr;

/* remove from the tree is only a little bit more complicated ;-) */

	pr = rf->parent;

	if (pr eq nil)
		*pf = nil;		/* rf was root of tree ;-) */
	else
	{
		if (pr->less eq rf)
		{
			/* 	can the orphaned great be put in the great of
				the less ?  (if its empty)

								 pr
				               /   \
			rf will go:	     rf
				            /  \
				         les    gre -->
				          / \         |
				             0  <-----'
			*/
			if (gre and les)
			{
				if (les->great eq nil)
				{
					les->great = gre;
					gre->parent = les;
					gre = nil;				/* processed */
				}
			}

			pr->less = les;
			if (les)
			{
				les->parent = pr;
				les = nil;				/* processed */
			}
		}
		elif (pr->great eq rf)
		{
			/* 	can the orphaned less be put in the empty less of
				the great  (if its empty)

				           pr
				         /   \
				             rf		  rf will go
				            /  \
				     <-- les    gre
				     |         / \
				     '------> 0
			*/
			if (les and gre)
			{
				if (gre->less eq nil)
				{
					gre->less = les;
					les->parent = rf->great;
					les = nil;				/* processed */
				}
			}

			pr->great = gre;
			if (gre)
			{
				gre->parent = pr;
				gre = nil;				/* processed */
			}
		}
	}

	/* anything that couldnt be done (too complex for now) */

	if (les)
		new_bref(rb, les);
	if (gre)
		new_bref(rb, gre);

	return nx;
}

/* alphabetic ordered */
global
void new_ref(MEMBASE *mb, REFBASE *rb, AREA *area, FIXUP *f, int obty)
{
	REFS *nm = find_ref(rb, f->name);
	if (!nm)
	{
		REFS *new = ins_ref(mb, rb, area, f, LD_ranout);
		if (new)
		{
			new->obty = obty;
			ins_bref(rb, new);
		}
	}
}

/* Local names: No unique names but unique name index */
global
void new_locref(MEMBASE *mb, REFBASE *rb, AREA *area, FIXUP *f)
{
	REFS *nm = find_locref(rb, f->name->nr);
	if (!nm)
	{
		REFS *new = ins_ref(mb, rb, area, f, LD_ranout);
		if (new)
			ins_bref(rb, new);
	}
}

static
void copy_refs(MEMBASE *mb, REFBASE *to, REFBASE *fro)
{
	REFS *f = fro->first;

	while (f)
	{
		new_ref(mb, to, f->fx->in, f->fx, f->obty);

		f = f->next;
	}
}

static
void ifile(Cstr buf)
{
	if (*buf ne '\0' and *buf ne ' ')
	{
		ins_flist(buf, AH_CC_IFILE, nil, LD_ranout);
		if (!flags.j)					/* make executable */
			if (P.fbase.first eq P.fbase.last)
				ins_flist(stackname, AH_CC_STACK_OB, nil, LD_ranout);
	}
}

static
void un_eol(char *s)
{
	s += strlen(s)-1;
	if (*s eq '\n') *s-- = 0;
	if (*s eq '\r') *s = 0;

}

static
bool read_obnames(Cstr fname)
{
	/* Essentially for inserting ldfile.tmp (aka LTMP) */
	/* Jet not good wnough to be set by a user or called twice */
	MAX_str buf;
	FILE *fd = fopen(fname, "r");
	new_flist(fname);

	if (fd)
	{
#if 1
		while(fgets(buf, STR_MAX, fd) ne nil)
		{
			un_eol(buf);
			ifile(buf);
		}
#else
		while (fscanf(fd, "%128s", buf) eq 1)
			ifile(buf);
#endif
		fclose(fd);

/*		list_flist();
*/		return true;
	}
	else
		send_msg("[1]Can't open %s\n", fname);

	return false;
}

static
Cstr after_is(Cstr st)
{
	Cstr s = st;
	while (*s)
		if (*s eq '=')
			return s + 1;		/* return after '=' */
		else
			s += 1;

	return st + 1;				/* no '=', return after options letter */
}

long cldbv(Cstr s);

static
void doopt(Cstr s, FLGS *flg)
{
	while (*s)
	{
		switch (tolower(*s))
		{
		case 'c':				/* file of objects */
			read_obnames(after_is(s));
			return;
		case 'g':				/* add global symbols */
			flg->glo++;
		break;
		case 'j':				/* make new lib */
			flg->j++;
		break;
		case 'l':				/* add local symbols */
			flg->loc++;
		break;
		case 'm':				/* set malloc for TTram flag */
			flg->m++;
		break;
		case 'f':				/* set fast load flag */
			flg->f++;
		break;
		case 'o':				/* object file name */
			oname = after_is(s);	/* must be last */
			return;
		case 'r':				/* load program in TT ram */
			flg->tt++;
		break;
		case 's':
			stacksize = cldbv(after_is(s));
			if (stacksize < 0)
				stacksize = DEFSTACK;
			stacksize += 255;
			stacksize &= -256;	/* round up to multiple of step size */
			return;
		case 'n':
			flg->nmsym++;		/* print 'nm' symbol list */
		break;
		case 'p':				/* print load map */
			flg->map++;
		break;
		case 'v':				/* verbose */
			flg->v++;
		break;
		case 'y':				/* add debug info */
			flg->y++;
		break;
		case 'h':				/* tpa size */
		case 'b':				/* bss  segment address */
			flg->b++;
			(long)stbss = cldbv(after_is(s));
			return;
		case 'd':				/* data segment address */
			flg->d++;
			(long)stdata = cldbv(after_is(s));
			return;
		case 't':				/* text segment address */
			flg->t++;
			(long)sttext = cldbv(after_is(s));
			return;
		case 'i':
			imgsize = cldbv(after_is(s));
			return;
#if !BIP_LD
		default:
			send_msg("AHCL, A Home Cooked Linker. (c) 2006 - 2013 by H. Robbers @ Amsterdam\n");
			send_msg("usage:\n");
			send_msg("-v    Verbose\n");
			send_msg("-j    Collect (make new linkable object)\n");
			send_msg("-o... Output file name\n");
			send_msg("-n	Write 'nm' type symbol list\n");
			send_msg("-p    Write load map to [-o].map\n");
			send_msg("-c... Name of text file with list of input filenames\n");
			send_msg("\n");
			send_msg("Options for executable output:\n");
			send_msg("-s=N  Stack size\n");
			send_msg("-g    Add global symbols\n");
			send_msg("-l    Add local  symbols\n");
			send_msg("   Set load flags:\n");
			send_msg("-m    Mallocs for TT ram\n");
			send_msg("-f    Fast load\n");
			send_msg("-r    Load in TT ram\n");
			send_msg("-t=N  Make ROM image @ N\n");
			send_msg("-i=N  Image fixed size\n");
			send_msg("\n");
			send_msg("Followed by:\n");
			send_msg("list of input filenames additional to -c\n");
			send_msg(">\n");
			bios(2,2);
		return;
#endif
		}
		s++;
	}
}

static
XA_report pfree
{
	send_msg("**** %s: ", txt);
	if (!unit)
	{
		send_msg("nil\n");
	othw
		XA_unit *pr = unit->prior, *nx = unit->next;
		send_msg(" -= %d =- unit %08lx(%ld), block %08lx(%ld), p:%08lx(%ld), n:%08lx(%ld)\n",
			unit->key,
			unit, unit->size,
			blk,  blk->size,
			pr,   pr ? pr->size : -1,
			nx,   nx ? nx->size : -1
			);
	}
}

#define C_VERBOSE 0

static
FIXUP *removeable(FIXUP *f)
{
	if (f->in)
	{
		send_msg("removeable? %lx", f->start ? *(long *)f->start : 0L);
		if (    f->in->limage eq DOT_L
		    and f->disp eq 0
		    and (    f->in->target eq FIX_bss
		         or (f->in->target eq FIX_data and *(long *)f->start eq 0L)
		        )
		   )
		{
			send_msg(" Yes\n");
			return f;
		}

		send_msg(" No\n");
	}

	return nil;
}

#if REDIRECT
void redirect(FIXUP *fro, FIXUP *to)
{
	send_msg("redirect %s from %s to %s\n", fro->name->s, fro->in->name, to->in->name);
}
#endif

global
void check_double(void)
{
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		AREA *ar = fl->areas.first;
#if C_VERBOSE
		send_msg("check_double in file '%s'\n", fl->name);
#endif
		while (ar)
		{
			FIXUP *f = ar->fixups.first;

#if C_VERBOSE
			send_msg("check_double in area '%s'\n", ar->name);
#endif
			while (f)
			{
				if (f->name)
					if (f->name->s)
						if (is_gl_entry(f->fix.ty))
						{
							REFS *ref;
#if C_VERBOSE
							send_msg("\tlook for '%s'\n", f->name->s);
#endif
							ref = gfind_ref(&out_base, f->name);
							if (ref)
							{
								FIXUP *of = ref->fx;
								if (is_gl_entry(of->fix.ty))
								{
#if REDIRECT
									FIXUP *okof, *okf;


									send_msg("dbl: %s\n", f->name->s);
									if (of->in)
									{
										send_msg("1st[%ld.%ld] %s, %s",
													of->disp,
													of->in->limage,
													fixup_name(of->fix.ty),
													of->in->referenced ? "R" : "-"
												);
										send_msg(" %s\n", fixup_name(of->in->target));
									}
									if (f->in)
									{
										send_msg("2nd[%ld.%ld] %s, %s",
													f->disp,
													f->in->limage,
													fixup_name( f->fix.ty),
													f->in->referenced ? "R" : "-"
												);
										send_msg(" %s\n", fixup_name(f->in->target));
									}

									okof = removeable(of);
									okf  = removeable(f);
									if (okof or okf)
									{
										send_msg("correct attributes for amalgamating\n");

										if (okof and okf)			/* both removeable: hold on to the latter which is okof */
											redirect(f, of);
										elif (okf)
											redirect(f, of);
										else
											redirect(of, f);
									}
									else
#endif
									{
										send_msg("doubly defined '%s'\n", f->name->s);
										P.result = 1;
									}
								}
							}
							else
							{
								REFS *new;
#if C_VERBOSE
								send_msg("\tinsert entry '%s'\n", f->name->s);
#endif
								new = ins_ref(&refmem, &out_base, ar, f, LD_ranout);
								if (new)
									ins_bref(&out_base, new);
							}
						}

				f = f->next;
			}

			ar = ar->next;
		}

		fl = fl->next;
	}
}

#define SYMS22 1

static
long write_symbols(long hdl, short target)
{
	short fixtodri[] = {0,0,0,0x82,0x84,0x81,0xc0,0x20,0x20,0,0,0,0,0,0,0};
	long lsym = 0;

	DRI_SYMBOL sym;
	FLIST *fl = P.fbase.first;

#if SYMS22
	char symx[sizeof(sym)];
#endif

	while (fl)
	{
		AREA *ar = fl->areas.first;

		while (ar)
		{
			if (ar->target eq target)
			{
				FIXUP *f = ar->fixups.first;

				while (f)
				{
					short ty = f->fix.ty;
					if (    is_entry(ty)
					    and (*f->name->s and *f->name->s ne '~')
					    and !(flags.loc eq 0 and is_lc_entry(ty))
					   )
					{

						if (hdl eq -2)		/* count only */
						{
							lsym += sizeof(sym);
#if SYMS22
							if (f->name->l > 8)
								lsym += sizeof(sym);
#endif
						}
						else
						{
							zero(sym);
							sym.v = (long)ar->out + f->disp;
							strncpy(sym.name, f->name->s, 8);
							sym.ty = fixtodri[target] | fixtodri[ty];
#if SYMS22
							if (f->name->l > 8)
								sym.d = 0x48;
#endif
							if (hdl > 0)
								Fwrite(hdl, sizeof(sym), &sym);
							else
							{
								memmove(P.fbase.to_image, &sym, sizeof(sym));
								P.fbase.to_image += sizeof(sym);
							}
#if SYMS22
							if (f->name->l > 8)
							{
								short l = f->name->l - 8;
								zero(symx);
								if (l > sizeof(symx)) l = sizeof(symx);
								strncpy(symx, f->name->s+8, l);
								if (hdl > 0)
									Fwrite(hdl, sizeof(symx), &symx);
								else
								{
									memmove(P.fbase.to_image, &symx, sizeof(symx));
									P.fbase.to_image += sizeof(symx);
								}
							}
#endif
						}
					}

					f = f->next;
				}
			}

			ar = ar->next;
		}

		fl = fl->next;
	}

	return lsym;
}

void match_area(AREA *, short);		/* recursion */

static
bool match_local(FLIST *fl, REFS *rf, short level)
{
	REFS *lf = find_locref(&fl->l_ents, rf->fx->name->nr);

	if (lf)
	{
		match_area(lf->fx->in, level);
		return true;
	}
	return false;
}

static
bool match_ref(REFBASE *rb, REFS *rf, short level)
{
	if (rb->first)
	{
		REFS *nm = find_ref(rb, rf->fx->name);
		if (nm)
		{
			FIXUP *f = nm->fx;

			if (rb eq &ex_base)
				remove_ref(rb, nm);

			match_area(f->in, level + 1);
			return true;
		}
	}
	return false;
}


/* a ref refered to this area */
static
void match_area(AREA *ar, short level)
{
	if (ar eq nil)
		return;

	if (!ar->referenced)
	{
		REFS *rf;

		ar->referenced = true;		/* so it must be included */
		rf = ar->o_refs.first;

		while (rf)					/* match all its outside references */
		{
			REFS *nx = rf->next;

			if (!match_local(ar->in, rf, level+1))			/* file local modules */
				if (!match_ref(&gl_base, rf, level+1))				/* globals */
					new_ref(&refmem, &ex_base, ar, rf->fx, rf->obty);

			rf = nx;
		}

		rf = ar->a_refs.first;		/* match all its anonymous refs */

		while (rf)
		{
			if (rf->fx->out)
				match_area(rf->fx->out, level + 1);

			rf = rf->next;
		}
	}
}

static
void match_global(void)
{
	/* The number of global entries (gl_base) increases quickly, while
	   the number of external references (ex_base) will gradually diminish.
	   So it is better to use the fast log n searching on the entries.
	   Because ex_base entries will disappear randomly it is not possible to
	   follow the ex_base list because refs got removed from it.
	   So we make a temporary copy.
	*/

	REFS *ef;
	REFBASE this;
	MEMBASE mlocal;

	clr_treebase(&this, false, 0, nil, "copy ex_base");
	init_membase(&mlocal, 8192, XA_LOCAL, "copy ex_base", nil);

	copy_refs(&mlocal, &this, &ex_base);

	ef = this.first;
	while (ef)
	{
		PO_NAME *name = ef->fx->name;
		REFS  *nm = gfind_ref(&gl_base, name);

		if (nm)
		{
			REFS *rf = gfind_ref(&ex_base, name);

			if (rf)
				remove_ref(&ex_base, rf);

			match_area(nm->fx->in, 0);
		}

		ef = ef->next;
	}

	free_membase(&mlocal);
}

static
void entries(bool gfa)
{
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		AREA *ar;

		clr_treebase(&fl->l_ents, false, 0, nil, "file local entries");

		ar = fl->areas.first;

		while (ar)
		{
			FIXUP *f;

			clr_treebase(&ar->o_refs, false, 0, nil,"area outside refs");
			clr_treebase(&ar->a_refs, false, 0, nil,"area anonymous refs");

			f = ar->fixups.first;

			while (f)
			{
				if (is_lc_entry(f->fix.ty))
					new_locref(&refmem, &fl->l_ents, ar, f);
				elif (is_gl_entry(f->fix.ty))
				{
					new_ref(&refmem, &gl_base, ar, f, fl->obty);

					if (gfa)
						if (SCMP(323, f->name->s, "BaseA4") eq 0)
							BaseA4 = f;
				}

				f = f->next;
			}

			ar = ar->next;
		}

		fl = fl->next;
	}
}

static
void debug_lref(void *where, char *d, long what, long new)
{
	send_msg("fix %08lx(%ld) from %ld to %ld + %ld = %ld\n",
			where, d, what, what, new, what + new);
}

static
long relprev;

static
char *reloc, *relp;
long curreloc;

static
void firstreloc(char *d)
{
	curreloc = 512;
	reloc = xmalloc(curreloc, AH_FIRST_RELOC);
	if (reloc)
	{
		*(long *)reloc = (long)d;
		relp = reloc + 4;
		lreloc = 4;

	othw
		P.result = 10;
	}
}

static
void addreloc(short r)
{
	if (reloc)
	{
		if (relp >= reloc + curreloc)
		{
			void * new = xrealloc(reloc, curreloc*2, AH_ADD_RELOC);
			if (new eq nil)
			{
				reloc = nil;
				P.result = 9;
				return;
			}
			reloc = new;
			relp = reloc + curreloc;
			curreloc *= 2;
		}

		*relp++ = r;
		lreloc++;
	}
}

static
void fix(short ty, short img)
{
	FLIST *fl;

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
					if (is_ref(f->fix.ty))
					{
						REFS *ef;
						AREA *in = nil;
						long disp = 0;

						if (*f->name->s)
						{
							ef = find_locref(&fl->l_ents, f->name->nr);

							if (ef)
								in = ef->fx->in;

							if (in)
								disp = ef->fx->disp;
							else
							{
								ef = gfind_ref(&gl_base, f->name);
								if (ef)
									in = ef->fx->in;
								if (in)
									disp = ef->fx->disp;
							}
						}
						else
						{
							in = anon_ref(f, fl->l_ents.first, &disp);
#if 0
							if (disp)
							{
								console("repaired anon_ref in %s %d %ld\n", fl->name, f->fix.nnr, disp);
								if (in)
								{
									long new = (long)in->out + disp;
									console("in: target %d out %ld, new %ld, %s\n", in->target,
												in->out, new, in->name ? in->name : "\0");
								}
							}
#endif
						}

						if (in eq nil)
							format_error(fl, 8);
						else
						{
							long new = (long)in->out + disp,
							     dist;
							char *on = f->start + f->disp,
							     *d_on = ar->out + f->disp;

							switch (f->fix.ty)
							{
								case FIX_labs:
								{
									long *where = (long *)on;

									*where += new;				/* fix it */

									if (!img and in->target ne FIX_offs)
									{
										if (relprev eq nil)
											firstreloc(d_on);
										else
										{
											long d = (long)d_on - relprev;

											if (d > 254)
											{
												while (d > 254)
												{
													addreloc(1);
													d -= 254;
												}

											}

											addreloc(d);
										}

										relprev = (long)d_on;
									}
								}
								break;
								case FIX_wabs:
								{
									short *where = (short *)on;
									*where += new;				/* fix it */
								}
								break;
								case FIX_lpcrel:
								{
									long *where = (long *)on;
									dist = new - (long)d_on;
									*where += dist;				/* fix it */
								}
								break;
								case FIX_wpcrel:
								{
									short *where = (short *)on;
									dist = new - (long)d_on;

									if (dist > 32767 or dist < -32768)
									{
										short opc = *(where - 1);
										char *nm = f->name ? f->name->s ? f->name->s : "" : "";
										if (    BaseA4
											and ar->target eq FIX_text
										    and (fl->obty & 15) eq GFA
										    and (opc eq 060400 or opc eq 060000)		/* bsr, bra */
										    and *nm
										   )
										{
											/* GFA's INIT.O sets a4 to BaseA4 + 32768 */
											long d = (long)BaseA4->in->out + 32768;

											/* change to jsr x(a4), jmp x(a4)	*/

											*(where - 1) = opc eq 060400 ? 047254 : 047354;
											* where      = new - d;
										othw
											send_msg("pc relative overflow to %s%s%s i: %o\n",
												nm, *ar->name ? " in " : "", ar->name, *(where - 1));
											P.result = 3;
										}
									}
									else
										*where += dist;			/* fix it */
								}
								break;
							}
						}
					}

					f = f->next;
				}
			}

			ar = ar->next;
		}

		fl = fl->next;
	}
}

static
bool anonymous(Cstr n)
{
	return n[0] eq 0 or ((n[0] eq '~' or n[0] eq '_') and n[1] eq '_');
}

static
Cstr ar_name(AREA *ar)
{
	static char s[256];
	FIXUP *f = ar->fixups.first;

	if (anonymous(ar->name))
		return "";
	if (!f)
		return ar->name;
	if (is_gl_entry(f->fix.ty))
		return ar->name;
	sprintf(s, "<%s>", ar->name);
	return s;
}

static
void pr_map(short target, short img)
{
	bool show;
	FLIST *fl = P.fbase.first;

	while (fl)
	{
		long d = 0;
		AREA *ar = fl->areas.first;
		show = false;
		while (ar)
		{
			if (ar->target eq target)
			{
				FIXUP *f = ar->fixups.first;

				if (!show)
				{
					send_msg("in %s\n", fl->name);
					show = true;
				}
#if 1
				send_msg("%08lx(%8ld)", ar->out, ar->out);
#else
				send_msg(img ? "%08lx" : "%8ld", ar->out);
#endif
				send_msg(" %6ld[%6ld]  %s %s\n",
						d,
						ar->limage,
						disp_target(ar->target),
						ar_name(ar)
						);

				while (f)
				{
					if (is_entry(f->fix.ty) and !anonymous(f->name->s))		/* 05'10 HR: is_entry first */
						if (SCMP(324, f->name->s, ar->name) ne 0)
						{
#if 1
							char * s = ar->out + f->disp;
							send_msg("%08lx(%8ld)", s, s);
#else
							send_msg(img ? "%08lx" : "%8ld", s);
#endif
							send_msg(" %6ld          %s",
									d + f->disp,
									disp_target(ar->target)
									);
							if (is_gl_entry(f->fix.ty))
								send_msg(" %s\n", f->name->s);
							else
								send_msg(" <%s>\n", f->name->s);
						}

					f = f->next;
				}

				d += ar->limage;
			}

			ar = ar->next;
		}

		if (d) send_msg("                   %6ld\n", d);

		fl = fl->next;
	}
}

static
void load_map(Cstr f, short img)
{
	S_path new;
	FILE  *save_bugf = bugf, *map = nil;
	P_path fn;

	fn.s = f;
	if (f)
	{
		new = change_suffix(fn.t, ".map");
		map = fopen(new.s, "w");
		if (map)
			bugf = map;
	}

	if (map)
		send_msg("* load map of %s produced by AHCL (c) H. Robbers @ Amsterdam\n\n", f);
	else
		send_msg("\nload map:\n\n");

	pr_map(FIX_text, img);
	pr_map(FIX_data, img);
	pr_map(FIX_bss,  0);
	pr_map(FIX_offs, 0);

	if (map)
	{
		fclose(map);
		bugf = save_bugf;
		send_msg("Load map saved in %s\n", new.s);
	}
	else
		send_msg("\nend of map\n");
}

static
void pr_sym(short target, short img)
{
	FLIST *fl = P.fbase.first;

	img = true;		/* 05'10 HR: nm compatible */

	while (fl)
	{
		AREA *ar = fl->areas.first;

		while (ar)
		{
			if (ar->target eq target)
			{
				FIXUP *f = ar->fixups.first;

				while (f)
				{
					if (is_entry(f->fix.ty) and !anonymous(f->name->s))	/* 05'10 HR: is_entry first */
						if (!(is_lc_entry(f->fix.ty) and flags.loc eq 0))
						{
							send_msg(img ? "%08lx" : "%8ld",
									ar->out + f->disp);
							send_msg(" %c %s\n",
									(is_lc_entry (f->fix.ty) ? tolower : toupper)
										(*disp_target(ar->target)),
									f->name->s
								);
						}

					f = f->next;
				}
			}

			ar = ar->next;
		}

		fl = fl->next;
	}
}

static
void write_nm(Cstr f, short img)
{
	S_path new;
	FILE  *save_bugf = bugf, *map = nil;
	P_path fn;

	fn.s = f;
	if (f)
	{
		new = change_suffix(fn.t, ".sym");
		map = fopen(new.s, "w");
		if (map)
			bugf = map;
	}

	if (map)
		send_msg("* %s symbols of %s produced by AHCL (c) H. Robbers @ Amsterdam\n\n",
				flags.loc ? "All" : "Global", f);
	else
		send_msg("\nSymbols:\n\n");

	if (img)
	{
		pr_sym(FIX_bss,  1);
		pr_sym(FIX_text, 1);
		pr_sym(FIX_data, 1);
		pr_sym(FIX_offs, 0);
	othw
		pr_sym(FIX_text, 0);
		pr_sym(FIX_data, 0);
		pr_sym(FIX_bss,  0);
		pr_sym(FIX_offs, 0);
	}

	if (map)
	{
		fclose(map);
		bugf = save_bugf;
		send_msg("Symbols  saved in %s\n", new.s);
	}
	else
		send_msg("\nend of symbols\n");
}


static
void remove_unreferenced(void)
{
	FLIST *fl = P.fbase.first;
	while (fl)
	{
		AREA *ar = fl->areas.first;
		while (ar)
		{
			AREA *nx = ar->next;
			if (!ar->referenced)
				rem_list(&fl->areas, ar);

			ar = nx;
		}

		fl = fl->next;
	}
}

static
void write_program(short img, Wstr rom)
{
	PRG_HD header;

	/* establish displacements. */

	long   ltext = 0, ldata = 0, lbss = 0, loffs = 0, lsym = 0, lhead = 0;
	Wstr ttext = 0, tdata = 0, tbss = 0, toffs = 0, total;

	P.fbase.name = oname;
	relp = nil;

	remove_unreferenced();

#if TEST_CHECK
	check_double();
#endif

	if (img)
		ttext = rom;

	/* Calculate area start addresses */
	tdata = add_areas(FIX_text, &ttext, &ltext);
	tbss  = add_areas(FIX_data, &tdata, &ldata);

	if (img)
		tbss = nil;

	total = add_areas(FIX_bss,  &tbss,  &lbss);
	        add_areas(FIX_offs, &toffs, &loffs);

	if (flags.map)
		load_map(oname, img);

/* Refresh entries */
	free_membase(&refmem);
	init_membase(&refmem, 16384, 0, "reference base", nil);		/* start with high value */
	clr_treebase(&gl_base, true,  NHASH, gl_row, "all global entries");		/* list of global entries */
	clr_treebase(&ex_base, true,  NHASH, ex_row, "all unreferenced");		/* list of unresolved references */

	entries(gfa);

/* Do all fixups */
	relprev = 0;
	relp = nil;
	reloc = nil;

	fix(FIX_text, img);
	fix(FIX_data, img);

	if (relp)
	{
		*relp = 0;
		lreloc++;
	}

/* Produce the output */
	if (P.result eq 0)
	{
		long hdl = Fcreate(oname, 0);
		if (hdl > 0)
		{
			if (!img)
			{
				header.ty = PRGMAGIC;
				header.text_len = ltext;
				header.data_len = ldata;
				header.bss_len = lbss + stacksize;
				header.sym_len = 0;
				header.res1 = 0;
				header.flags = 7;
				header.flags &= ~(flags.f    );		/* B0: fastload */
				header.flags &= ~(flags.tt<<1);		/* B1: load in TT-ram       "      */
				header.flags &= ~(flags.m <<2);		/* B2: mallocs TT-ram (if present) */
				header.absflag = 0;

				if (flags.glo)
				{
					header.sym_len += write_symbols(-2, FIX_text);
					header.sym_len += write_symbols(-2, FIX_data);
					header.sym_len += write_symbols(-2, FIX_bss);
					header.sym_len += write_symbols(-2, FIX_offs);
					lsym = header.sym_len;
					if (flags.v)
						send_msg("SYM  size: %6ld\t%ld symbols\n",
								lsym, lsym/sizeof(DRI_SYMBOL));
				}

				Fwrite(hdl, sizeof(header), &header);
				lhead = sizeof(header);
			}

			P.num_areas = 0;
			P.fbase.image = xmalloc(ltext + ldata + 4, AH_WPR_IMAGE);
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

			if (!img and flags.glo)
			{
				P.fbase.image = xmalloc(lsym + 4, AH_WPR_SYM);
				if (P.fbase.image eq nil)
				{
					write_symbols(hdl, FIX_text);
					write_symbols(hdl, FIX_data);
					write_symbols(hdl, FIX_bss);
					write_symbols(hdl, FIX_offs);
				othw
					P.fbase.to_image = P.fbase.image;

					write_symbols(-1, FIX_text);
					write_symbols(-1, FIX_data);
					write_symbols(-1, FIX_bss);
					write_symbols(-1, FIX_offs);

					Fwrite(hdl, lsym, P.fbase.image);
					xfree(P.fbase.image);
				}
			}

			if (reloc)
				Fwrite(hdl, lreloc, reloc);

			if (img)
			{
#define FILLZ 4096
				long size = ltext + ldata;
				if (size < imgsize)
				{
					char buf[FILLZ]; long r;
					memset(buf, 0, sizeof(buf));
					imgsize -= size;
					r = imgsize % FILLZ;
					if (r)
					{
						imgsize -= r;
						Fwrite(hdl, r, buf);
					}

					while (imgsize > 0)
					{
						Fwrite(hdl, FILLZ, buf);
						imgsize -= FILLZ;
					}
				}
			}

			Fclose(hdl);
		othw
			send_msg("Cant create %s\n", oname);
			P.result = 8;
		}

		if (flags.nmsym)
			write_nm(oname, img);

		if (flags.v or flags.map)
			send_msg("%ld areas in %ld object files\n\n",
				P.num_areas, P.num_files);

		send_msg("%s  size: %6ld\n", fixup_name(FIX_text), ltext);
		send_msg("%s  size: %6ld\n", fixup_name(FIX_data), ldata);
		send_msg("%s  size: %6ld\t", fixup_name(FIX_bss),  lbss + stacksize);
		send_msg("(stack size: %6ld)\n", stacksize);

		if (!img)
		{
			send_msg("            ------ +\n");
			send_msg("            %6ld\n", total + stacksize);
		}

		bin_size = imgsize ? imgsize : lhead
		         + ltext + ldata + lreloc + lsym;
	}
}

static
jmp_buf ld_jump;
static
char *abort_msg = "**** linker aborted, insufficient memory. ****\n";

global
XA_run_out LD_ranout
{
#if GEMSHELL
	if (phase ne LINKING)
	{
		console("Internal error: LD_ranout wrong phase %d, key %d", phase, xkey);
		bios(2,2);
		exit(9999);
	}
#endif

	if (base->flags & XA_LOCAL)
		XA_free_all(base, -1, -1);

	P.result = 10;				/* out of memory */
	longjmp(ld_jump, 1);
	return 1;			/* dummy: not reached ever */
}

global
short AHCL(short argc, char **argv)
{
	short i, xjmp = 0;
	FLIST *fl;
	long clo = clock();

	BaseA4 = nil;
	gfa = false;

	zero(flags);

#if GEMSHELL
	phase = LINKING;
#else
	flags.map = 1;
#endif

	zero(P);

	init_membase(&defmem, 16384, 0, "global base",    nil);		/* start with high value */
	init_membase(&refmem, 16384, 0, "reference base", nil);		/* start with high value */

	clr_treebase(&gl_base, true, NHASH, gl_row, "all global entries");		/* list of global entries */
	clr_treebase(&ex_base, true, NHASH, ex_row, "all unreferenced");		/* list of unresolved references */
	clr_treebase(&out_base,true, NHASH, out_row,"all output entries");		/* list of entries in output */

	stacksize = DEFSTACK;

	ld_lbl = 0;
	xjmp = setjmp(ld_jump);

	if (xjmp eq 1)
		goto ld_abort;

	for (i=1; i<argc; i++)
	{
		if (argv[i][0] eq '-')
			doopt(&argv[i][1], &flags);
		else
			ifile(argv[i]);
	}

	if (flags.t)		/* simplification for current ROM's */
	{
		flags.b = 1;
		flags.d = 0;
		stbss = 0;
		send_msg("For ROM image at 0x%06lx, size %ldK\n", sttext, imgsize);
		imgsize *= 1024;
		if (imgsize > 4L*1024*1024)
			imgsize = 4L*1024*1024;			/* lets not exagerate :-) */
	}

	fl = P.fbase.first;

	if (fl)
	{
		if (flags.j)		/* make new object */
		{

	/* Read input files,
	   Write everything to 1 output object file.
	 */

			while (fl and P.result eq 0)
			{
				if ((fl->obty & LIB) eq 0)
					if (!load_ob(fl))				/* load file and get areas */
						P.result = 1;

				fl = fl->next;
			}

			if (P.result eq 0)
			{
				write_object(oname, flags.v, false, LD_ranout);

				if (flags.map)
					load_map(oname, 0);

				free_membase(&refmem);
			}
		othw				/* make executable */

	/* Read input files, start with the first area of the first file
	   as referenced, link areas recursively until either
	   no more input files or no more outside references */

			do
			{
				if ((fl->obty & LIB) eq 0)
					if (load_ob(fl))				/* load file and get areas */
						if (P.fbase.first eq fl)
							match_area(fl->areas.first, 0);	/* start with the first area of the first file */
						else
							match_global();
					else
						P.result = 1;

				fl = fl->next;
			}
			while (fl and ex_base.first);

			if (ex_base.first)
			{
				send_msg("unresolved references:\n");
				list_refs(ex_base.first, 1);
				P.result = 5;
			}
			elif (P.result eq 0)		/* Ok we've got everything, mow make the binary */
				write_program(flags.t, sttext);
		}
	}

ld_abort:

	free_membase(&refmem);
	free_membase(&defmem);
	XA_free_all(nil, AH_LD, -1);
	CC_xfree_all(AH_CC_NAMES);				/* 03'09 */
	CC_xfree_all(AH_LD);					/* 03'09 */
	CC_xfree_all(AH_LOAD_OB);				/* 03'09 */
	CC_ffree_all(AH_CC_NAMES);				/* 03'09 */
	CC_ffree_all(AH_LD);					/* 03'09 */
	CC_ffree_all(AH_LOAD_OB);				/* 03'09 */
	XA_free_all(&XA_file_base, AH_LD, -1);
	XA_free_all(&XA_file_base, AH_LOAD_OB, -1);

	clo = clock() - clo;
	{
		short fclo = clo/2;
		send_msg("%d.%02d seconds\n", fclo/100, fclo%100);
	}

	if (xjmp)
		send_msg(abort_msg);

	EXIT_AHCL(P.result);
}
