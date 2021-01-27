/*  (c) 1987 - 1991 by Han  Driesen Leiden.
 *  (c) 1996 - present by Henk Robbers Amsterdam.
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

/*	DIG.C  */

char *version=VERSION;

#include <string.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>
#include <ext.h>

#include "common/mallocs.h"
#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#include "aaaa.h"
#include "common/cursor.h"
#include "text/text.h"
#include "common/files.h"
#include "common/journal.h"
#include "common/config.h"
#include "common/wdial.h"
/* #include "common/kit.h" */
#include "common/ahcm.h"
#include "ttd_kit.h"
#include "ttd_cfg.h"
#include "ttdisass.h"
#include "dig.h"
#include "digobj.h"
#include "dig_it.h"

M_S dmen={false, false, 0, 0, 0, 0, 0, 0, 0, nil, nil};

global
COPRMSG ttd_msg=
{
	"                 " PRGNAME " " VERSION,
	"                 ====== ====",
	" (c) 1987 - 1991 by Han  Driesen te Leiden.",
	"",
	" MC68030 - MC68060 & MC68881/2 support:",
	" (c) 1996 - present by Henk Robbers te Amsterdam.",
	" Completely rewritten in ANSI C using Pure C.",
/*            1         2         3         4         5
     12345678901234567890123456789012345678901234567890		*/
    "  -= Also starring Harald Siegmunds NKCC. =-",
    nil
};

void M(char *text, ...);

global
char bytes[]=" bytes";

extern char *Bookmark, *Ref, *Jt_ref;

global MAX_str pcn;
global FILE *ofile;

global
void mask20(IT *w)
{
	DW *dw = w->dw;

	bool *m  =w->dis.mask,
		  mo = z mach != 0;
	short r1;

	bassign(m,   03,mo);	/* chk2,cmp2.b	*/
	bassign(m,  013,mo);	/* chk2,cmp2.w	*/
	bassign(m,  023,mo);	/* chk2,cmp2.l	*/
	bassign(m,  033,mo);	/* callm		*/
	bassign(m, 0460,mo);	/* mulX.l		*/
	bassign(m, 0461,mo);	/* divX.l		*/
#if 0
	bassign(m, 0450,mo);	/* tst.b */
	bassign(m, 0451,mo);	/* tst.w */
	bassign(m, 0452,mo);	/* tst.l */
#endif
	for (r1 = 0; r1 <= 070; r1 += 010)    /* chk.l	*/
		bassign(m, 0404+r1, mo);
	bassign(m,01643,mo);	/* bftst		*/
	bassign(m,01647,mo);	/* bfextu		*/
	bassign(m,01657,mo);	/* bfexts		*/
	bassign(m,01667,mo);	/* bfffo		*/
#if 0 /* OK ???? */
	bassign(m,01643,mo);	/* bftst		*/
	bassign(m,01647,mo);	/* bfextu		*/
	bassign(m,01653,mo);	/* bfchng		*/
	bassign(m,01657,mo);	/* bfexts		*/
	bassign(m,01663,mo);	/* bfclr		*/
	bassign(m,01667,mo);	/* bfffo		*/
	bassign(m,01673,mo);	/* bfset		*/
	bassign(m,01677,mo);	/* bfins		*/
#endif
}

static
void setmask(IT *w)
{
	bool *m = w->dis.mask, *xm = w->dis.maskx;
	short s[] = {04, 0406, 0407, 01000, 01100, 01300, 01400, 01500};
	short r1, i, j = 0, l, a;

	bset(m, 32);	/* &o040, BTST #n, xx				*/
	bset(m, 275);	/* &o423, MOVE xx, CCR				*/
	bset(m, 283); 	/* &o433, MOVE xx, SR				*/
	bset(m, 289); 	/* &o441, PEA xx					*/
#if 1
	bset(m, 0450);	/* tst.b */
	bset(m, 0451);	/* tst.w */
	bset(m, 0452);	/* tst.l */
#endif
	bset(m, 306); 	/* &o462, MOVEM.W xx, <reglist>		*/
	bset(m, 307); 	/* &o463, MOVEM.L xx, <reglist>		*/
	bset(m, 314); 	/* &o472, JSR xx					*/
	bset(m, 315); 	/* &o473, JMP xx					*/

	loop(i, 3)			/* BTST dy, xx ! CHK xx, Dy ! LEA xx, Ay */
	{
		a = s[j++];		/* read a */
		for (r1 = 0; r1 <= 070; r1 += 010)
			bset(m, a+r1);
	}
	loop(i, 5)
	{
		a = s[j++];
		for (l = -1; l <= 3; l++)
			for (r1 = l&7; r1 <= 077; r1 += 010)
				bset(m, a+r1);
	}
	for (l = 0100; l <= 0300; l += 0100)	/* MOVE xx, yy */
		for (r1 = 0; r1 <= 071; r1++)
			bset(m, (l+(r1&7)*010)+(r1>>3));
	for (r1 = 1; r1 <= 071; r1 += 010)		/* No movea.b */
		bclr(m, r1+0100);
	bassign(m, 01715, w->cg.mc81);       /* frestore */
	bassign(m, 01710, w->cg.mc81);		 /* TT: all normal fp */

/*	Now mark the 4 byte instructions.
      These are the instruction that have a extension word that is NOT
		the extension word belonging to the addressing mode !!! */

	bset(xm, 03);              /* cmp2.s, chk2.s	*/
	bset(xm, 013);
	bset(xm, 023);
	bset(xm, 033);             /* callm			*/
	bset(xm, 040);             /* btst			*/
	bset(xm, 0460);            /* mul.l			*/
	bset(xm, 0461);            /* div.l			*/
	bset(xm, 0462);            /* movem.w		*/
	bset(xm, 0463);            /* movem.l		*/
	bset(xm, 01643);           /* bftst			*/
	bset(xm, 01647);           /* bfextu			*/
	bset(xm, 01653);           /* bfexts			*/
	bset(xm, 01663);           /* bfffo			*/
#if 0 /* OK ????? */
	bset(xm, 01643);			/* bftst		*/
	bset(xm, 01647);			/* bfextu		*/
	bset(xm, 01653);			/* bfchng		*/
	bset(xm, 01657);			/* bfexts		*/
	bset(xm, 01663);			/* bfclr		*/
	bset(xm, 01667);			/* bfffo		*/
	bset(xm, 01673);			/* bfset		*/
	bset(xm, 01677);			/* bfins		*/
#endif
	bset(xm, 01710);           /* alle floating point instructions met bit 8, 7, 6 = 0 */
}

void free_hsym(HSYM *s)
{
	short i;
	if (s->no)
		for (i = 0; i <= s->hash; i++)
		{	ERASE(s->lab[i].n);	}
	ERASE(s->lab);
	s->no = 0;
}

global
void cleanup(IT *w)
{
	DW *dw = w->dw;
	if (dw)
	{
		ERASE(z lab);
		ERASE(z rel);
		ERASE(z dt);
		ERASE(w->dis.jt);
		free_hsym(&z WL);
		free_hsym(&z XL);
		free_hsym(&z ML);
		free_hsym(&z CL);
		if is_PC
			ERASE(z rlc.b);
		ERASE(z L.lab);
		ERASE(z PL);
		ERASE(w->dis.history);
	}
}

global
void split_fn(IT *w, char *fn)
{
	char slash[2];
	char *f;

	inq_xfs(fn, slash);
	f = strrchr(fn, '.');
	if (f ne nil and strrchr(f, *slash) eq nil )
		strsncpy(w->dis.fo, fn, f-fn+1);
	else
		strcpy(w->dis.fo, fn);

	f = strrchr(fn, *slash);
	if (f)
		strcpy(w->dis.fs, f+1);
	else
	{
		f = strrchr(fn, ':');
		if (f)
			strcpy(w->dis.fs, f+1);
		else
			strcpy(w->dis.fs, fn);
	}
}

global
void end_disass(void)
{
	free_hsym(&namA);
	free(deskw.cg_tab);
}

short tabgain, tabgain1;
char regel[2048];
char * pos = regel;

global
void do_Ocopyright(void)
{
	do_init_text(nil, nil, ttd_msg);
	send_msg("\n");
}

#if TMAL
/* I use this if an area is violated by a bug,
    by varying xxxx I can find the offender */

void *MMalloc(long l, char *id, XA_key key, long xxxx)
{
	long *m = xmalloc(l+xxxx, key);
	send_msg("MM:%7ld($%8lx) <= %s[%ld($%lx)] + %ld\n", m, m, id, l, l, xxxx);
	return m;
}
#endif

static
CON_RET close_antw  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	FCLOSE close_disass;
	if (*line eq 'y' or *line eq 'Y')
		close_disass(w, true);			/* doesnt want to save indexfile */
	else
	{
		sprintf(fx, "%s%s", w->dis.fo, frstr(EXT_I));
		save_idx(w, fx);
		con_end(false);
	}
}

global
FCLOSE close_disass		/*	(IT *w, bool force)	*/
{
	DW *dw = w->dw;
	strcpy(pcn, w->title.t);
	if (w->wh > 0)
		get_it(w->wh, -1);		/* make current on winbase */
	else
		get_fn_it(w->title.t);

	if (!force and w->ismod)
	{
		con_input(w, DMCLOSE, 0, frstr(SVINDEX), nil, "NO!!", close_antw, nil);
		return false;
	}

	if (cfg.sidf and is_file(w))
		save_idf(w, w->dis.fo);

	cleanup(w);
	ERASE(w->dw);
	ERASE(w->map);
	ERASE(z keep);
	close_w(w);
	mpijl;  /* for some AES's */

#if INTERNAL
/*  stmcur(d) ((d).us.c) */
	if (stmcur(winbase)->wit ne w)
	{
		sprintf(lost_cw, "[1][ Internal error: | lost current IT | w: %lx | c: %lx ][ Pffft! ]", w, stmcur(winbase)->wit);
		do_alert(1, lost_cw);
	}
	else
#endif
	stmdelcur(&winbase);
	send_msg_n("%s '%s'\n\n", frstr(XCLOSED), pcn);

#if WINDIAL
	set_dialinfs(0L);
#endif

	return true;
}

static
CLOSED close_obj	/* (IT *w) */		/* for disassembler close box */
{
#if WINDIAL
	if (close_disass(w, false))		/* do not force */
		if (!w_handles(0L, no_dial))
			set_dialinfs(0L);
#else
	close_disass(w, false);
#endif
}

static WINIT objt_winit
{
	next_upper_left(w, deskw.unit.w, deskw.unit.h, &w->in);

	get_it(w->wh, -1);

	if (cfg.width <= 0)
		w->in.w = wwa.w;
	elif (cfg.width*deskw.unit.w+w->v.x+w->v.w > wwa.w)
		w->in.w = wwa.w;
	else
		w->in.w = cfg.width*deskw.unit.w+w->v.w-w->v.x+w->mgw.x;

	if (cfg.height <= 0)
		w->in.h = wwa.h;
	elif (cfg.height*deskw.unit.h+w->v.y+w->v.h > wwa.h)
		w->in.h = wwa.h;
	else
		w->in.h	= cfg.height*deskw.unit.h+w->v.h-w->v.y+w->mgw.y;

	snapwindow(w, &w->in);	/* !!! gebruikt slechts w->v !!! */
								/* mooi he? */
	w->frem = wwa;
	snapwindow(w, &w->frem);		/* snap fulled height */
}

static
void ienable(OpEntry *tab, short item, bool enable)
{
	menu_ienable(dmen.m, item, enable);

	while(tab->s.str[0])
	{
		if ( tab->s.o.srt eq 'd' and (tab->menuob or tab->ob))
		{
			if (tab->menuty eq OMENU and tab->menuob eq item)
			{
				if (tab->ob and tab->ty eq TTD_KIT)
				{
					if (enable)
						enable(pkit.tree[tab->ob]);
					else
						disable(pkit.tree[tab->ob]);
					wdial_draw(get_it(-1, TTD_KIT), tab->ob);
				}
			}
		}

		tab++;
	}
}

global
MENU_SET set_menu		/* IT *w, short which */
{
	DW *dw = w->dw;
	if (dw)
	{
		ienable(w->cg_tab, DMF6, w->dis.d_info ? true : false);
		ienable(w->cg_tab, DMF7, w->dis.f_info ? true : false);
		ienable(w->cg_tab, DMF8, w->dis.d_info ? true : false);
		ienable(w->cg_tab, DMEXTRA, w->dis.debug ? true : false);

		w->cg.rdx = w->cg.dec ? 10 : 16;
	}
	options(w->cg_tab, OSET);
	options(w->cf_tab, OSET);
}

static
void ob_v_slider(IT *w, long vpos, long vsize, long winsize)
{
	if (cfg.vslider)
	{
		long ovs = w->vsls, ovp = w->vslp;

		if (vsize <= 0)
			vsize = 1;
		if (vsize < winsize)
			w->vsls = 1000;
		else
			w->vsls = (winsize*1000)/vsize;
		if (w->vsls eq 0)
			w->vsls = 1;
		if (ovs ne w->vsls)
			wind_set(w->wh, WF_VSLSIZE, w->vsls);
		if (vpos eq 0)
			w->vslp = 0;
		elif (vpos+winsize >= vsize)
			w->vslp = 1000;
		else
			w->vslp = ((vpos+(winsize/2))*1000)/vsize;
		if (ovp ne w->vslp)
			wind_set(w->wh, WF_VSLIDE, w->vslp);
	}
}

static
void ob_h_slider(IT *w, long hpos, long hsize, long winsize)
{
	if (cfg.hslider)
	{
		long ohp = w->hslp, ohs = w->hsls;

		if (hsize <= 0)
			hsize = 1;
		if (hsize < winsize)
			w->hsls = 1000;
		else
			w->hsls = (winsize*1000)/hsize;
		if (w->hsls eq 0)
			w->hsls = 1;
		if (ohs ne w->hsls)
		{
			wind_set(w->wh, WF_HSLSIZE, w->hsls);
			ohs = w->hsls;
		}
		if (hpos eq 0)
			w->hslp = 0;
		elif (hpos+winsize >= hsize)
			w->hslp = 1000;
		else
			w->hslp = ((hpos+(winsize/2))*1000)/hsize;
		if (ohp ne w->hslp)
		{
			wind_set(w->wh, WF_HSLIDE, w->hslp);
			ohp = w->hslp;
		}
	}
}

global
SLIDER sliders		/* IT *w */
{
	DW *dw = w->dw;

	if (!w->cg.asc)
		if (w->cg.lbl or w->cg.sym)
			ob_v_slider(w, w->cf.spg.b-z org.b, z top.b-z org.b, w->dis.npg.b-w->cf.spg.b);
		else
			ob_v_slider(w, w->cf.spg.b-z org.b, z bss.b-z org.b, w->dis.npg.b-w->cf.spg.b);
	else
		ob_v_slider(w, w->cf.spg.b-w->dis.buffer, w->dis.lim.b-w->dis.buffer, w->norm.sz.h*w->dis.hexw);
	ob_h_slider(w, w->norm.pos.x, w->view.sz.w, w->norm.sz.w);
}

static
void plus(IT *w, short n)
{
	DW *dw = w->dw;

	n &= -2;	/* make even */
	if (w->cf.spg.b eq z org.b and w->dis.odefs)
		w->dis.defs = false;
	elif (w->cg.asc)
		w->cf.spg.b += w->dis.hexw;
	else
		w->cf.spg.i = (w->cf.spg.i+n)&-2;
	page(w);
}

static
void minus(IT *w, short n)
{
	DW *dw = w->dw;

	n &= -2;	/* make even */
	if (w->cf.spg.b eq z org.b and !w->dis.defs and n eq 2)
		w->dis.defs = true;
	elif (w->cg.asc)
		w->cf.spg.b -= w->dis.hexw;
	else
		w->cf.spg.i = (w->cf.spg.i-(n-1))&-2;
	page(w);
}
static
void prv_page(IT *w)
{
	DW *dw = w->dw;
	long mina, minb, k, minbuf;

	mina = w->norm.sz.h-2;
	minb = mina*2;		/* (lines-2)*2 */
	minbuf = w->dis.hexw*w->norm.sz.h;
	mina = mina&-2;

	w->dis.defs = w->cf.spg.b eq z org.b;
	if (w->cg.asc)				/* hexascii only */
		w->cf.spg.b = max(w->dis.buffer, (w->cf.spg.b-minbuf));
	else
	{
		long refadr;

		k = (w->cf.spg.i-minb)&-2;
		w->cf.spg.i = max(z org.i, k);
		if (w->cf.spg.b > z bss.b)
		{
			refadr = ((long)&z lab[(w->cf.spg.b-z org.b)/(sizeof(bool)*CHAR_BIT)]+1)&-2;
			w->cf.spg.i = (( backzero((bool *)refadr)
			          -(long)&z lab[0]
			         )*CHAR_BIT
			        )+z org.i;
		}
		if (w->cg.lbl or w->cg.sym)             /* pinpoint on a label */
		{
			PCB p;
			if (btst(z lab, w->cf.spg.b-z org.b) eq 0)
				for(p = w->cf.spg.b+2; p <= w->cf.spg.b+mina;p++)
					if (btst(z lab, p-z org.b))
					{
						w->cf.spg.b = p;
						break;
					}
		}
	}
	page(w);
}

static
long ref_find(IT *w, PC start, PC stop)
{
	DW *dw = w->dw;
	PC rks = w->dis.rkey;

	rks.b += z shift.i;
	if (z mach or w->cg.mc81)
		return findrefx((z prg&1)|(z mach?2:0)|((w->cg.mc81&1)<<2),
			z org, z bss, stop, w->dis.rkey, w->dis.mask, w->dis.maskx,
			z rel, z dt, rks, start);
	else
		return findref(z prg&1,
			z org, z bss, stop, w->dis.rkey, w->dis.mask,
			z rel, z dt, start, rks);
}

global
void make_vis_pc(IT *w, PC pc)
{
	w->dis.ruler = pc;
	if (pc.b < w->cf.spg.b or pc.b > w->dis.npg.b)
	{
		w->cf.spg = pc;
		minus(w, w->norm.sz.h);
	}
	page(w);
}

void scan_jt(IT *w, bool msg);

static PC jtkey;
static short lrj = 0;

global
void have_jt(IT *w, long d, long x)
{
	if (x eq jtkey.i)
		bookmark_msg(w, store_msg, d, Jt_ref, ""), lrj++;
}

static
void rfind_label(IT *w, RXY *k)
{
	DW *dw = w->dw;
	PC start, pc;

	lrj = 0;
	w->dis.rkey.i = k->r.i-z org.i+w->cf.offset;
	if (w->dis.jt)
	{
		jtkey = w->dis.rkey;
		scan_jt(w, true);
	}
	start.b = max(w->cf.spg.b, z org.b);
	pc.i = min(w->cf.spg.i&-2, z bss.i);
	if (rel(dw, pc.b))
		pc.w++;
	pc.w++;
	pc.i = ref_find(w, pc, z bss);
	if (pc.b >= z bss.b)
	{
		pc.l = min(start.l+1, z bss.l);
		pc.i = ref_find(w, z org, pc);
		if (pc.i >= start.i)
			pc = z bss;
	}
	if (lrj)
		send_msg("\n");
	if (pc.i<z bss.i)
		w->dis.key_remember = pc,
		make_vis_pc(w,pc);
	elif (!lrj)
		ping
}

static
void rfind_next(IT *w)
{
	DW *dw = w->dw;
	PC stop, pc;

	if (w->dis.rkey.i eq -1 or w->dis.key_remember.i eq -1)
		ping
	else
	{
		stop.l = w->dis.key_remember.l+1;
		pc.w = w->dis.key_remember.w+1;
		pc.i = ref_find(w, pc, z bss);
		if (pc.b >= z bss.b)
		{
			pc.i = min(stop.i, z bss.i);
			pc.i = ref_find(w, z org, pc);
			if (pc.i >= stop.i)
				pc = z bss;
		}
		if (pc.i<z bss.i)
			w->dis.key_remember = pc,
			make_vis_pc(w,pc);
		else
			ping
	}
}

static
void list_ref(IT *w)
{
	DW *dw = w->dw;
	PC pc = z org;

	if (w->dis.rkey.i eq -1)
		ping
	else
	{
		PC k = w->dis.rkey;
		lrj = 0;
		jtkey = k;
		k.i += z shift.i;
		pos = regel;
		label(dw, k, false);
		*pos = 0;
		send_msg_n("List of references to '%s'\n", regel);
		while (pc.b < z bss.b)
		{
			pc.i = ref_find(w, pc, z bss);
			if (pc.i<z bss.i)
				bookmark_msg(w, store_msg, pc.i - z shift.i, Ref, ""), lrj++;
			pc.w++;
		}
		if (w->dis.jt)
			scan_jt(w, true);		/* calls have_jt for each PC relative
										displacement found in jumptables */
		send_msg("%d reference%s\n", lrj, lrj eq 1 ? "" : "s");
	}
}

global
long get_addr(IT *w, char * s)
{
	long i;
	DW *dw = w->dw;

	while (*s and *s <= ' ') s++;
	if (*s eq '$')
		return crbv(s+1, 16);
	if (strncmp(s, w->cg.r16, strlen(w->cg.r16)) eq 0)
		return crbv(s+strlen(w->cg.r16), 16);

	if (*s >= '0' and *s <= '9')
		return cldbv(s);
	if (w->cg.sym and *s)
		for (i = 0; i <= z L.hash; i++)
			if (z L.lab[i].v ne HIGH_LV)
				if is_PC
					if (strcmp(pure_name(z L.lab[i].n), s) eq 0)
						return z L.lab[i].v;
					else ;
				else
					if (strcmp(dri_name(z L.lab[i].n,
					                    z L.lab[i].d,
					                    z sozobon), s) eq 0)	/* 5'99 RA: .d */
						return z L.lab[i].v;

	if (z WL.lab and *s)
		for (i = 0; i <= z WL.hash; i++)
			if (z WL.lab[i].v ne HIGH_LV)
				if (strcmp(z WL.lab[i].n, s) eq 0)
					return z WL.lab[i].v;
	if (z XL.lab and *s)
		for (i = 0; i <= z XL.hash; i++)
			if (z XL.lab[i].v ne HIGH_LV)
				if (strcmp(z XL.lab[i].n, s) eq 0)
					return z XL.lab[i].v;
	if (z ML.lab and *s)
		for (i = 0; i <= z ML.hash; i++)
			if (z ML.lab[i].v ne HIGH_LV)
				if (strcmp(z ML.lab[i].n, s) eq 0)
					return z ML.lab[i].v;
	if (*s eq 'L' or *s eq 'X' or *s eq 'T' or *s eq 'U' or *s eq 'M')
	{
		s++;
		while(*s and *s <= ' ') s++;
	}
	{	IT *w = dw->w;
		if (w->ty eq OBJ+MNTOS)
			return crbv(s, 16);
	}
	if (w->cg.rdx eq 10)
		return cldbv(s);
	return crbv(s, 16);
}

static
void tfind(IT *w, short l, uchar *key, uchar *k, uchar *d)
{
	DW *dw = w->dw;
	PC pc;
	long timer = clock();

	pc.b = w->cf.spg.b+1;
	w->dis.fend = w->cg.asc ? w->dis.lim : z bss;

	pc.b = qfind(l, pc.k, w->dis.fend.k, key, d, k);

	timer = (clock()-timer)*5;
	con_end(true);
	if (pc.b <= z bss.b - l)
	{
		w->cf.spg = pc;
		if (timer)
			send_msg_n("... %ld ms\n", timer);
		page(w);
	}
	else
		ping
}

static
uchar to_x(uchar c)
{
	if (c >= '0' and c <= '9')
		return c-'0';
	if (c >= 'a' and c <= 'f')
		return c-'a'+10;
	if (c >= 'A' and c <= 'F')
		return c-'A'+10;
	ping;
	return 0;
}

static
short to_hex(uchar *s)
{
	uchar *t = s, *st = s;
	while(*s)
	{
		uchar u;
		u = to_x(*s++)<<4;
		u |= to_x(*s++)&0xf;
		*t++ = u;
	}
	*t = 0;
	return t-st;
}

/* This function is called by the journal if <RETURN> or <ENTER> is pressed */
/*    Of course for the menu entries that pass its address.					*/
/* It may also be directly called for default actions.						*/

static
CON_RET find  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	DW *dw = w->dw;

	static uchar nxk  [256],
	             xxkey[MAXJ+1],
	             xnxk [256],
	             xtd1 [256],
	             td1  [256];

	static short skl, xskl;
	static PC a;

	switch (curtask)
	{
		case DMREF:		/* single stage task */
		{
			PC start, pc;

			lrj = 0;
			strsncpy(w->con.remember, line, MAXJ);
			w->dis.rkey.i = get_addr(w, line);
			if (!w->dis.rkey.i)
				send_msg("%s\n", frstr(NFEXT));
			else
			{
				if (w->dis.jt)
				{
					jtkey = w->dis.rkey;
					scan_jt(w, true);
				}
				start.b = max(w->cf.spg.b, z org.b);
				pc.i = min(w->cf.spg.i&-2, z bss.i);
				if (rel(dw, pc.b))
					pc.w++;
				pc.w++;
				pc.i = ref_find(w, pc, z bss);
				if (pc.b >= z bss.b)
				{
					start.l = pc.l+1;
					pc.i = min(start.i, z bss.i);
					pc.i = ref_find(w, z org, pc);
					if (pc.i >= start.i)
						pc = z bss;
				}
				if (lrj)
					send_msg("\n");
				if (pc.i<z bss.i)
				{
					con_end(true);
					w->cf.spg.b = pc.b+1;
					w->dis.key_remember = pc;
					make_vis_pc(w, pc);
				}
				elif (!lrj)
					send_msg("'%s' %s\n", line, frstr(NF));
			}
		}
		esac
		case DMADDR:		/* single stage task */
		{
			strsncpy(w->con.remember, line, MAXJ);
			a.i = get_addr(w, line);
			if (!a.i)
				send_msg("%s\n", frstr(NFEXT));
			else
			{
				con_end(true);
				w->cf.spg.i = a.i+z shift.i;
				w->dis.defs = false;
				page(w);
			}
		}
		esac
		case DMBKADDR:
			if (a.i)
			{
				w->cf.spg.i = a.i+z shift.i;
				w->dis.defs = false;
				page(w);
			}
		esac
		case DMTEXT:		/* single stage task */
		{
			skl = strlen(line);
			if (skl)
			{
				strsncpy(w->con.remember, line, MAXJ);
				qfind_prepare(skl, (uchar *)w->con.remember, nxk, td1);
				tfind(w, skl, (uchar *)w->con.remember, nxk, td1);
			}
		}
		esac
		case DMNXTEXT:		/* directly called */
			if (skl)
				tfind(w, skl, (uchar *)w->con.remember, nxk, td1);
		esac
		case DMHEX:
		{
			uchar *s = xxkey;
			xskl = strlen(line);
			if (xskl)
			{
				strsncpy(w->con.remember, line, MAXJ);
				if (xskl&1)
					*s++ = '0';		/* make even length */
				strcpy((char *)s, line);
				xskl = to_hex(xxkey);
				qfind_prepare(xskl, xxkey, xnxk, xtd1);
				tfind(w, xskl, xxkey, xnxk, xtd1);
			}
		}
		esac
		case DMNXHEX:		/* directly called */
			if (xskl)
				tfind(w, xskl, xxkey, xnxk, xtd1);
		esac
	}
}

static
bool any_preamble(bool *b, short n)
{
	short i = 0;
	loop(i,n)
		if (b[i]) return true;
	return false;
}

void write_all(IT *w);

static
bool save_obj(IT *w, char *fn)
{
	short i = 0;
	DW *dw = w->dw;
	char fname[DIRL];

	strcpy(fname, fn);			/* for if 'include' name has to be selected. :-) */
	ofile = fopen(fname, "w");
	if (ofile)
	{
		PC svp = w->cf.spg,
		   svn = w->dis.npg,
		   svtop = z top, svbot = z bot,
		   svlim = w->dis.lim;

		time_t tijd = time(nil);

		if (w->dis.ssel.b)
		{
			w->dis.npg  = w->dis.ssel;
			w->dis.fend = w->dis.esel;
		othw
			w->dis.npg = z org;
			w->dis.fend.b = 0;
		}

		z fil = true;
		w->dis.defs = true;
		settabs(w);
		fprintf(ofile, "*\t%s %s\n", frstr(CREABY), version);
		fprintf(ofile, "*\t%s\n", ctime(&tijd));
		if (any_preamble(w->cg.kb, 5)and !w->cg.asc and (w->cg.lbl or w->cg.sym))
		{
			fprintf(ofile, "*\tOutput preamble\n\n");
			loop(i,5)
				if (*w->cg.kt[i] and w->cg.kb[i])
					fprintf(ofile, "%s\n", w->cg.kt[i]);
			fprintf(ofile, "\n");
		}

		if (z prg)
		{
			if (w->dis.npg.b ne z org.b)
			{
				fprintf(ofile, "\tds.b\t");
				if (w->cg.rdx ne 16)
					fprintf(ofile, "%ld\n", w->dis.npg.b-z org.b);
				else
					fprintf(ofile, "%06lx\n", w->dis.npg.b-z org.b);
			}
		othw
			fprintf(ofile, "\torigin = ");
			if (w->cg.rdx ne 16)
				fprintf(ofile, "%ld\n", w->dis.npg.b-z shift.b);
			else
				fprintf(ofile, "%06lx\n", w->dis.npg.b-z shift.b);
		}

		send_msg("%s\n", frstr(PRESS));

		mbumble;
		w->cf.spg = w->dis.npg;
		write_all(w);

		fclose(ofile);
		z fil = false;
		settabs(w);

		w->cf.spg  = svp,
		w->dis.npg = svn,
		z top = svtop,
		z bot = svbot,
		w->dis.lim = svlim;

		w->muisvorm(w);

		send_msg_n("'%s' %s %s\n", w->title.t, frstr(SAVEOB), fname);
		return true;
	}
	return false;
}

global
void l_opt(IT *w, short new_m, bool draw)
{
	DW *dw = w->dw;

	if (dw)
		if (new_m eq DMF4)
			w->dis.defs = false;
		else
			w->dis.defs = true;

	w->cg.stand  = new_m eq DMF4;
	w->cg.lbl    = new_m eq DMF5;
	w->cg.sym    = new_m eq DMF6;

	if (dw)
		other_machine(w, draw);
}

global
void opt(IT *w, short new_m, bool draw)
{
/*	w->dis.opc = w->cg.opc;
	w->dis.asc = w->cg.asc
	w->dis.opasc = w->cg.opasc;
*/
	w->cg.opc   = new_m eq DMF1;		/* opcodes   only */
	w->cg.asc   = new_m eq DMF2;		/* hex/ascii only */
	w->cg.opasc = new_m eq DMF3;		/* opcodes + hex/ascii */
	if (w->dw)
		settabs(w);
	set_menu(w);
	if (draw)
 		page(w);
}

char xwname[MAXJ+1] = "";
char xlname[MAXJ+1] = "";

extern bool ok_name(char c);

static
void add_name(IT *w, char *s, long val, HSYM *hs, short ty)
{
	short i, l;

	while (*s and *s ne '=') s++;
	if (*s ne '=')
		ping
	else
	{
		char name[MAXJ+1];
		char *t = name;
		s++;

		while (ok_name(*s))
			*t++ = *s++;
		*t = 0;
		l = t - name;

		if (*name ne '.')
			for (i = 0; i <= hs->hash; i++)
				if (hs->lab[i].v ne HIGH_LV)
					if (strcmp(hs->lab[i].n, name) eq 0)
					{
						send_msg("%s: %s\n", frstr(DUPNAM), name);
						ping
						return;
					}

		if (hs->no+1 < hs->max)
		{
			LAB new;
			new.n = xmalloc(l+1, AH_DIG_NAME);
			if (new.n)
			{
				strcpy(new.n, name);
				new.v = val;
				new.sz = 0;
				new.ty = ty;
				if (user_hname(w, hs, new))
					hs->no++;
				w->ismod = true;		/* for save_idx */
				con_end(true);
				page(w);
			}
			else
				send_msg("%s\n", frstr(RANOUT)), ping
		}
		else
			send_msg("%s\n", frstr(TABFUL)), ping
	}
}

static
bool erase_name(IT *w, HSYM *s, long old)
{
	long j = ttd_hash(s, old);		/* prik in tabel */

	do{
		if (s->lab[j].v eq old)
			break;
		if (s->lab[j].v > old)
			if (s->lab[j].v eq HIGH_LV)
				return false;					/* not there */
		j = (j+1)&s->hash;
	}od
	do{
		LAB *r = &s->lab[j];
		j = (j+1)&s->hash;
		*r = s->lab[j];
		if (s->lab[j].v eq HIGH_LV)
			break;
	}od
	w->ismod = true;		/* for save_idx */
	con_end(true);
	page(w);
	return true;
}


char comstr[MAXJ+1] = "";
char comprompt[16] = "";

global
void add_comm(IT *w, char *s, long val, HSYM *hs, short ty)
{
	char name[MAXJ+1];
	char *t = name;
	short l;

	if (*s)
	{
		while (*s and *s ne ':') s++;
		if (*s ne ':')
		{
			ping
			return;
		}
		s++;
		while(*s)
			*t++ = *s++;
		*t = 0;
	othw
		if (ty eq FIX_book)
			*name = 0;
	}
	l = t - name;

	if (hs->no+1 < hs->max)
	{
		LAB new;
		new.n = xmalloc(l+1, AH_DIG_COMM);
		if (new.n)
		{
			strcpy(new.n, name);
			new.v = val;
			new.sz = 0;
			new.ty = ty;
			if (user_hname(w, hs, new))
				hs->no++;
			w->ismod = true;		/* for save_idx */
			con_end(true);
			page(w);
			if (ty eq FIX_book)
				bookmark_msg(w, send_msg_n, val, Bookmark, name);
		}
		else
			send_msg("%a\n", frstr(RANOUT)), ping
	}
	else
		send_msg("%s\n", frstr(TABFUL)), ping
}
static
CON_RET word_name  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	DW *dw = w->dw;
	char *s = line;
	if (*s)
	{
		long v = get_addr(w, s);
		while (*s)
			if (*s eq '=')
				break;
			elif (*s eq '.')
			{
				if (*(s+1) eq 'w')
					v = (short)v;
				break;
			}
			else
				s++;
		strcpy(xwname, line);
		add_name(w, line, v, &z WL, FIX_wabs);
	}
}

static
CON_RET long_name  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	DW *dw = w->dw;
	if (*(line+prompt))
		add_name(w, line, get_addr(w, line), &z XL, FIX_labs);
	else
		erase_name(w, &z XL, w->dis.value);
}

static
CON_RET book_mark  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	DW *dw = w->dw;
	if (*(line+prompt))
		add_comm(w, line, get_addr(w, line), &z ML, FIX_book);
	else
		erase_name(w, &z ML, w->dis.value);
}

static
CON_RET comment  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	DW *dw = w->dw;
	if (*(line+prompt))
		add_comm(w, line, get_addr(w, line), &z CL, 0);
	else
		erase_name(w, &z CL, w->dis.value);
}

static
void fsel_index(IT *w)
{
	char *fn, slash[2];

	inq_xfs(idir.s, slash);
	idir = change_suffix(&idir, frstr(EXT_I));

	if (*w->dis.fs)
		fsel = DIR_suffix(w->dis.fs, frstr(EXT_I));

	fn = select_file(&idir, nil, &fsel, frstr(I_INDEX), &drive);
	if (fn)
	{
		split_fn(w, fn);
		load_idx(w, fn);
		page(w);
	}
}

static
bool is_yes(char c)
{
	return c eq 'Y' or c eq 'J' or c eq 'y' or c eq 'j';
}

static
CON_RET load_index  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	if (is_yes(*line))
		fsel_index(w);

	con_end(true);
}

static
CON_RET unload_index  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	if (is_yes(*line))
		delete_index(w);

	con_end(true);
}

global
long ttd_hash(HSYM *s, long a)
{
	return ( (a & s->hash) * 43) & s->hash;
}

static
char *check_hname(HSYM *s, long a)
{
	long pp = ttd_hash(s, a);

	while(s->lab[pp].v < a)
		pp = (pp+1)&s->hash;
	if (s->lab[pp].v eq a)
		return s->lab[pp].n;
	return "";
}

static
bool dcompare(IT *w1, IT *w2)
{
	static bool skip = false;
	DW *dw1 = w1->dw, *dw2 = w2->dw;
	PC pc1 = w1->cf.spg, pc2 = w2->cf.spg;
#if 0
	send_msg("w1 %lx, w2 %lx\n", pc1.i, pc2.i);
	send_msg("org1 %lx, org2 %lx\n", dw1->org.i, dw2->org.i);
	send_msg("l1 = %ld, l2 = %ld\n", pc1.i - dw1->org.i, pc2.i - dw2->org.i);
#endif
	if (skip) pc1.u++, pc2.u++;
	while (pc1.i < dw1->top.i and pc2.i < dw2->top.i)
	{
		if (*pc1.u ne *pc2.u)
		{
			w1->cf.spg = pc1;
			w2->cf.spg = pc2;
			skip = true;
			return true;
		}
		pc1.u++, pc2.u++;
	}

	send_msg("objects are same\n");
	skip = false;
	return false;
}

static
MENU_DO do_wdmenu
{
	DW *dw = w->dw;

	switch (title)
	{
	case DMOUT:
		if (choice eq DMCLOSE)
		{
			wmenu_tnormal(w, title, true); /* before it's gone */
			via(w->close_file)(w, false);
		othw
			switch(choice)
			{
			case DMLIND:
				if (!w->ismod)
					fsel_index(w);
				else
					con_input(w, DMLIND, 0, frstr(SVINDEX), nil, "no", load_index, nil);
			esac
			case DMSIND:
			{
				char *fn, slash[2];
				inq_xfs(idir.s, slash);
				idir = change_suffix(&idir, frstr(EXT_I));
				if (*w->dis.fs)
					fsel = DIR_suffix(w->dis.fs, frstr(EXT_I));

				fn = select_file(&idir, nil, &fsel, frstr(S_IDX), &drive);
				if (fn)
				{
					split_fn(w, fn);
					save_idx(w, fn);
				}
			}
			esac
			case DMUIND:
				if (w->ismod)
					con_input(w, DMUIND, 0, frstr(SVINDEX), nil, "yes", unload_index, nil);
				else
					delete_index(w);
			esac
			case DMSAVE:
			{
				char *fn, *s, slash[2];
				if (w->cg.asc)
					s = w->cg.hex_ext;
				elif (w->cg.lbl or w->cg.sym)
					s = w->cg.src_ext;
				else
					s = w->cg.asx_ext;

				inq_xfs(idir.s, slash);
				idir = change_suffix(&idir, s);
				if (*w->dis.fs)
					fsel = DIR_suffix(w->dis.fs, s);

				fn = select_file(&idir, nil, &fsel, frstr(w->dis.ssel.b ? S_ASMSEL
																            : S_ASM   ),
						 &drive);
				if (fn)
					save_obj(w, fn);
			}
			esac
			}
			wmenu_tnormal(w, title, true);
		}
	esac
	case DMOPT:
		if (choice >= DMF1 and choice <= DMF3)
			opt(w, choice, true);
		elif (choice >= DMF4 and choice <= DMF6)
			l_opt(w, choice, true);
		else
			switch (choice)
			{
			case DMF7:
			{
				store_msg("\nFile info:\n==========\n");
				store_msg("name: '%s'\n", w->title.t);
				store_msg("size: %7ld(%s%08lx)\n", w->dis.flen, w->cg.r16, w->dis.flen);
				if (z prg)
					if is_PC
					{
						PC_H kop = w->dis.kop.pch;
						store_msg("\nPure C header: %d bytes\n", (kop.he&0xff)+4);
						store_msg("\tMagic:     %s4efa%04x\n", w->cg.r16, kop.magic);
						store_msg("\tImage:  %7ld\n",          kop.limage);
						store_msg("\tFixups: %7ld\n",          kop.lfixup);
						store_msg("\tNames:  %7ld\n",          kop.lnames);
						store_msg("\tRes0:  %s%08lx\n",        w->cg.r16, kop.res0);
						store_msg("\tRes1:  %s%08lx\n",        w->cg.r16, kop.res1);
						store_msg("\tRes2:  %s%08lx\n",        w->cg.r16, kop.res2);
					othw
						DRI_H kop = w->dis.kop.drih;
						store_msg("\nDRI header: %d bytes\n", (kop.magic&0xff)+2);
						store_msg("\tMagic:     %s%04x\n", w->cg.r16, kop.magic);
						store_msg("\tText:   %7ld\n",      kop.ltext);
						store_msg("\tData:   %7ld\n",      kop.ldata);
						store_msg("\tBss:    %7ld\n",      kop.lbss);
						store_msg("\tSymbols:%7ld\n",      kop.lsym);
						store_msg("\tRes1:  %s%08lx %ld\n",    w->cg.r16, kop.res1, kop.res1);
						store_msg("\tRes2:  %s%08lx %ld\n",    w->cg.r16, kop.res2, kop.res2);
						store_msg("\tRelocflag: %s%04x %d\n", w->cg.r16, kop.norelo, kop.norelo);
					}
				send_msg("\nend\n\n");
			}
			esac
			case DMF8:
				if is_PC
				{
					listfixups(w);
					listnames (z nam, w->dis.lnam);
					send_msg("%s\n\n", frstr(EOLIST));
				othw
					listsym (w, z S, z reloff ne 0, w->dis.lsym, w->dis.ltext, w->dis.ldat, w->dis.lbss, w->dis.esym);
				}
			esac
			case DMF9:		/* data range */
				con_input(w, DMF9, 0, frstr(DRANGE), nil, nil, set_dat, nil);
			esac
			}
		wmenu_tnormal(w, title, true);
	esac
	case DMGOTO:
		switch (choice)
		{
		case DMHOME:
			w->cf.spg = z org;
			w->dis.defs = true;
			page(w);
		esac
		case DMEND:
			w->cf.spg = w->cg.asc ? w->dis.lim : ((w->cg.lbl or w->cg.sym) ? z top : z bss);
			prv_page(w);
		esac
		case DMEXTRA:
			if (w->dis.debug)
			{
			
				w->cf.spg = w->dis.pclim;
				opt(w, DMF2, true);		/* hex/ascii */
			}
		esac
		case DMUNDO:
			w->dis.his_ptr -= 1;
			w->dis.his_ptr &= HISTN-1;
			w->cf.spg = w->dis.history[w->dis.his_ptr];
			page(w);
		esac
		case DMDC:
			if (!w->cg.asc)
			{
				z dcf = false;
				z dc = true;
				do
				{
					if (w->dis.npg.b >= z dat.b)
						break;
					w->cf.spg = w->dis.npg;
					page(w);
				} while(!z dcf);
			}
			z dc = false;
		esac
		case DMNXP:
			w->cf.spg = w->dis.npg;
			page(w);
		esac
		case DMSAMP:
			w->dis.defs = w->dis.odefs;
			page(w);
		esac
		case DMPRVP:
			prv_page(w);
		esac
		case DMLEFT:
			minus(w, 2);
		esac
		case DMRIGHT:
			plus(w, 2);
		esac
		case DMSTAS:
			if (w->dis.ssel.b)
			{
				w->cf.spg = w->dis.ssel;
				prv_page(w);
			}
			else
				ping
		esac
		case DMENDS:
			if (w->dis.ssel.b)
			{
				w->cf.spg = w->dis.esel;
				prv_page(w);
			}
			else
				ping
		esac
		}
		wmenu_tnormal(w, title, true);
	esac
	case DMFIND:
	{
	static
		char fref[MAXJ+1] = "";
		switch (choice)
		{
		case DMADDR:
			con_input(w, DMADDR, 0, w->cg.sym
							? frstr(P_ADNM)
							: frstr(P_ADDR), nil, fref, find, nil);
		esac
		case DMBKADDR:
			find(w, nil, 0, DMBKADDR, 0);
		esac
		case DMTEXT:
		{
		static
			char key[MAXJ+1] = "";
			con_input(w, DMTEXT, 0, frstr(P_TEXT), nil, key, find, nil);
		}
		esac
		case DMNXTEXT:
			find(w, nil, 0, DMNXTEXT, 0);
		esac
		case DMHEX:
		{
		static
			char xkey[MAXJ+2] = "";
			con_input(w, DMHEX, 0, frstr(P_HEX), nil, xkey, find, nil);
		}
		esac
		case DMNXHEX:
			find(w, nil, 0, DMNXHEX, 0);
		esac
		case DMREF:
			con_input(w, DMREF, 0, w->cg.sym
							? frstr(P_ADNM)
							: frstr(P_ADDR), nil, fref, find, nil);
		esac
		case DMNEXTREF:
			rfind_next(w);
		esac
		case DMLREF:
			list_ref(w);
		esac
#ifdef DMCOMPARE
		case DMCOMPARE:			/* 08'15 v9 */
		{
			IT *get_second(IT *, WSELECT *),
			   *w1 = w,
			   *w2 = get_second(w1, is_object);
			   
			if (!w2)
				send_msg("^2 needs 2 open files\n");
			else
			{
				dcompare(w1, w2);
				page(w1);
				page(w2);
			}
		}
		esac
#endif
		case DMJMPIND:		/* find indirect jmp or jsr */
		{
			PC pc = w->cf.spg;
			static
			PC lj = {nil};
			if (pc.u eq lj.u)	/* if not moved, skip */
				pc.u++;

			while (pc.b < z bss.b)
			{
				uint p = (*pc.u)&0177700;
				if (   p eq 047300
					or p eq 047200 )
				{
					uchar m = (*pc.u>>3)&7,
					      r = (*pc.u   )&7;
					if break_in
						break;
					if (m eq 2 or m eq 5 or m eq 6)
					{
						w->cf.spg = pc;
						lj = pc;
						page(w);
						break;
					}
					elif (m eq 7)
					{
						if (r eq 3)
						{
							w->cf.spg = pc;
							lj = pc;
							page(w);
							break;
						}
						elif (r eq 0)
							pc.w++;
						elif (r eq 1)
							pc.l++;
					}
				}
				pc.w++;
			}
		}
		esac
		case DMFMARK:
			if (z ML.lab and z ML.no)
			{
				short i, j = 0;
				HSYM *m = &z ML;
				LAB *s = sort_names(&z ML);

				for (i = 0; i <= m->hash; i++)
				{
					PC a;
					a.i = s[i].v;
					if (a.i ne HIGH_LV)
						bookmark_msg(w, store_msg, s[i].v, Bookmark, s[i].n), j++;
				}
				send_msg("%d bookmark%s\n", j, j eq 1 ? "" : "s");
				if (s ne z ML.lab)
					free(s);
			}
			else
				send_msg_n("No bookmarks\n"), ping
		esac
		}
		wmenu_tnormal(w, title, true);
	}
	esac
	case DMMARK:
		switch(choice)
		{
		case DMBYTE:
			mark(w, bytemark, byteclr, 0);
		esac
		case DMBYTES:
			mark(w, bytemark, byteclr, 1);
		esac
		case DMBYTEC:
			mark(w, bytemark, byteclr, 2);
		esac
		case DMWORD:
			mark(w, wordmark, wordclr, 0);
		esac
		case DMWORDS:
			mark(w, wordmark, wordclr, 1);
		esac
		case DMWORDC:
			mark(w, wordmark, wordclr, 2);
		esac
		case DMLONG:
			mark_long(w, 0);
		esac
		case DMLONGS:
			mark_long(w, 1);
		esac
		case DMLONGC:
			mark_long(w, 2);
		esac
		case DMCODE:
			mark(w, codemark, codeclr, 0);
		esac
		case DMCODES:
			mark(w, codemark, codeclr, 1);
		esac
		case DMCODEC:
			mark(w, codemark, codeclr, 2);
		esac
		case DMJMPT:
			jmpwmark(w, wordmark);
		esac
		case DMBMARK:
			if (!w->cg.asc)
			{
				bool all = true;
				if (z ML.lab eq nil)
					all = alloc_hsym(&z ML, 127, "bookmarks");
				if (all)
				{
					short x, y, dum;
					RXY *k;
					long org;
					IT *w = dw->w;

					if (w->cg.lbl or w->cg.sym)
					{
						graf_mkstate(&x, &y, &dum, &dum);
						x = (x-w->ma.x)/w->unit.w+w->norm.pos.x;
						y = (y-w->ma.y)/w->unit.h;
						k = which_label(w, x, y);
						if (k >= z keep)
						{
							org = (k->r.i&-2)-z shift.i;
							add_comm(w, "", org, &z ML, FIX_book);
						}
					}
				}
			}
		esac
		case DMBCMARK:
			if (!w->cg.asc)
			{
				bool all = true;
				if (z ML.lab eq nil)
					all = alloc_hsym(&z ML, 127, "comments");
				if (all)
				{
					short x, y, dum;
					RXY *kp;
					graf_mkstate(&x, &y, &dum, &dum);
					x = (x-w->ma.x)/w->unit.w+w->norm.pos.x;
					y = (y-w->ma.y)/w->unit.h;
					kp = which_line(w, x, y);
					if (kp >= z keep)
					{
						long a = kp->r.i - z shift.i;
						char *n = check_hname(&z ML, a);
						if (w->cg.rdx eq 16 or w->ty eq OBJ + MNTOS)
							sprintf(comstr, "%s%lx:", w->cg.r16, a);
						else
							sprintf(comstr, "%ld:", a);
						w->dis.value = a;
						con_input(w, DMBCMARK, 0, frstr(BMCOM), comstr, n, book_mark, nil);
					}
				}
			}
		esac
		}
		wmenu_tnormal(w, title, true);
	esac
	case DMDO:
	{
		switch (choice)
		{
		case DMSSEL:
			do_select(w, 1);
		esac
		case DMESEL:
			do_select(w, 2);
		esac
		case DMXSEL:
			do_select(w, 0);
		esac
		case DMWNAME:
		{
			bool all = true;
			if (z WL.lab eq nil)
				all = alloc_hsym(&z WL, 255, "absolute names");
			if (all)
				con_input(w, DMWNAME, 0, frstr(WORD_NAME), nil,
							xwname,word_name,nil);
		}
		esac
		case DMLNAME:
			if (!w->cg.asc)
			{
				bool all = true;
				if (z XL.lab eq nil)
					all = alloc_hsym(&z XL, 255, "labels");
				if (all)
				{
					short x, y, dum;
					RXY *kp;
					graf_mkstate(&x, &y, &dum, &dum);
					x = (x-w->ma.x)/w->unit.w+w->norm.pos.x;
					y = (y-w->ma.y)/w->unit.h;
					kp = which_lname(w, x, y);
					if (kp >= z keep)
					{
						long a = kp->r.i - z shift.i;
						char *n = check_hname(&z XL, a);
						if (w->cg.rdx eq 16 or w->ty eq OBJ + MNTOS)
							sprintf(xlname, "%s%lx=", w->cg.r16, a);
						else
							sprintf(xlname, "%ld=", a);
						w->dis.value = a;
						con_input(w, DMLNAME, 0, frstr(LABL_NAME), xlname, n, long_name, nil);
					}
				}
			}
		esac
		case DMCOM:
			if (!w->cg.asc)
			{
				bool all = true;
				if (z CL.lab eq nil)
					all = alloc_hsym(&z CL, 127, "comments");
				if (all)
				{
					short x, y, dum;
					RXY *kp;
					graf_mkstate(&x, &y, &dum, &dum);
					x = (x-w->ma.x)/w->unit.w+w->norm.pos.x;
					y = (y-w->ma.y)/w->unit.h;
					kp = which_line(w, x, y);
					if (kp >= z keep)
					{
						long a = kp->r.i - z shift.i;
						char *n = check_hname(&z CL, a);
						if (w->cg.rdx eq 16 or w->ty eq OBJ + MNTOS)
							sprintf(comstr, "%s%lx:", w->cg.r16, a);
						else
							sprintf(comstr, "%ld:", a);
						w->dis.value = a;
						con_input(w, DMCOM, 0, frstr(COMMENT), comstr, n, comment, nil);
					}
				}
			}
		esac
		}
		wmenu_tnormal(w, title, true);
	}
	esac
	case DMMACH:
	{
		if (choice >= DMCF and choice <= DM81)
			do_mach(w, choice);			/* also called in TTD_KIT */
		elif (choice eq DMUSYSV)
		{
			opt_to_cfg(w->cg_tab, choice, OMENU, pkit.tree, dmen.m);
			page(w);
		}
		elif (choice >= DMTNL)
		{
			opt_to_cfg(w->cg_tab, choice, OMENU, pkit.tree, dmen.m);
			set_menu(w);
			settabs(w);
			page(w);
		}
		wmenu_tnormal(w, title, true);
	}
	esac
	}
	return true;
}

char iname[DIRL] = "SYSVARS.H";

static
void abs_names(IT *w, FILE *fp, HSYM *s, char *coms, char *come)
{
	short i, n = s->hash + 1;
	LAB *sort = sort_names(s);
	fprintf(fp, "\n");
	if (coms and *coms)
		fprintf(fp, "%s\n", coms);
	loop(i, n)
	{
		LAB *l = sort+i;
		if (l->n) if (*l->n)
		{
			long v = l->v;
			if (!w->cg.wabx and (l->v&0xffff8000) eq 0xffff8000)		/* 5'99 RA */
				v &= 0xffff;
			fprintf(fp, "%s\t%s\t$%lx\n", l->n, w->cg.equ, v);
		}
	}
	if (coms and *coms and come and *come)
		fprintf(fp, "%s\n", come);

	fprintf(fp, "\n");
	if (sort ne s->lab)
	{	ERASE(sort);	}
}

static
bool locate_incA(IT *w, short msg)
{
	bool dum = false;
	locate(&dum, w->cg.wnamApath, iname, msg);
	if (*w->cg.wnamApath ne 0)
	{
		FILE *fp = fopen(w->cg.wnamApath, "w");
		if (fp)
		{
			abs_names(w, fp, &namA, nil, nil);
			send_msg("%s '%s'\n", frstr(SYSVINC), w->cg.wnamApath);
			fclose(fp);
			return true;
		othw
			send_msg("%s '%s'\n", frstr(FNF), w->cg.wnamApath);
			ping
		}
	}
	*w->cg.wnamApath = 0;
	return false;
}

global
void user_names(IT *w, FILE *fp)
{
	DW *dw = w->dw;

	if (namA.no and w->cg.usysv)
	{
		if  (w->cg.isysv)
		{
			char incl[DIRL], *s, *t;
			if (!*w->cg.wnamApath)
				locate_incA(w, INCSAVE);
			if (*w->cg.wnamApath)
			{
				t = w->cg.include;
				s = incl;
				while (*t and *t ne '!')
					*s++ = *t++;					/* copy head */
				*s = 0;
				if (*t)
				{									/* found % */
					if (*++t eq 'N')
					{
						t++;
						strcpy(s, w->cg.wnamApath);	/* insert path */
					}
					strcat(s, t);					/* append tail */
				}
				fprintf(fp, "%s\n%s\n%s\n", w->cg.sysvcom, incl, w->cg.sysvend);
			othw
				w->cg.isysv = false;
				options(w->cg_tab, OSET);
				options(w->cf_tab, OSET);
			}
		}

		if (!w->cg.isysv)
			abs_names(w, fp, &namA, w->cg.sysvcom, w->cg.sysvend);
	}

	if (z WL.lab and z WL.no)
		abs_names(w, fp, &z WL, w->cg.idxcom, w->cg.idxend);
}

static
ANTEVNT dis_evm		/* IT *w; bool w_on, short evmask */
{
#if WINDIAL
	set_dialinfs(w);
#endif
	evmask |= MU_KEYBD|MU_M1;
	if (w_on)					/* if mouse within wa */
		evmask |= MU_BUTTON;

	return evmask;
}

static
BUTTON dis_button	/* IT *w; short button, kstate, bclicks, mx, my */
{
	DW *dw = w->dw;
	RXY *kp;
	short x = (mx-w->ma.x)/w->unit.w+w->norm.pos.x,
		y = (my-w->ma.y)/w->unit.h;

	kp = which_lname(w, x, y);
	if (    kp >= z keep
		and !w->cg.asc
		and (kstate&CONTRL)
		)
		rfind_label(w, kp);
	elif (     kp >= z keep
		  and (kp->r.b ne w->cf.spg.b or w->dis.odefs)
		 )
	{
		w->cf.spg = kp->r;
		if (w->cf.spg.b eq z org.b)
			w->dis.defs = false;
		page(w);
	}
	elif (w->cg.asc)					/* hex/ascii */
	{
		short tox = w->dis.t_hex  - regel,
		    toc = w->dis.t_char - regel+1;

		if ( x >= tox and x < tox+5*(w->dis.hexw/2) )
		{
			x -= tox;
			w->cf.spg.b += y*w->dis.hexw+(2*x)/5;
			page(w);
		}
		elif (x >= toc and x <= toc+w->dis.hexw)
		{
			x -= toc;
			w->cf.spg.b += y*w->dis.hexw+x;
			page(w);
		}
	}
}

global
void get_Dwork(IT *w)
{
	get_work(w);
	w->dis.hexw = 72;
	do w->dis.hexw -= 4, settabs(w);
	while (w->dis.t_x >= w->norm.sz.w);
}

static
void new_left(IT *w)
{
	if (w->norm.pos.x < 0)
		w->norm.pos.x = 0;
	elif (w->norm.sz.w > w->view.sz.w)
		w->norm.pos.x = 0;
	elif (w->norm.pos.x+w->norm.sz.w > w->view.sz.w)
		w->norm.pos.x = w->view.sz.w-w->norm.sz.w;
}

static
FULLED full_obj					/* (IT *w) */
{
	if ( !w->full )				/* all these values are allready snapped */
	{
		w->rem.y = w->frem.y;
		w->rem.h = w->frem.h;
		w->full = true;
	othw
		w->rem.y = w->nfrem.y;
		w->rem.h = w->nfrem.h;
		w->full = false;
	}
	wind_set(w->wh, WF_CURRXYWH, w->rem);
	get_Dwork(w);
	new_left(w);
	page(w);
}

static
MOVED move_obj					/* IT *w, RECT *to */
{
	snapwindow(w, to);
	w->rem = *to;
	w->nfrem = w->rem;
	w->full = false;
	wind_set(w->wh, WF_CURRXYWH, w->rem);
	get_Dwork(w);
}

static
MOVED size_obj					/* IT *w, RECT *to */
{
	if ((w->wkind&SIZER) eq 0)			/* security */
	{
		to->w = w->rem.w;
		to->h = w->rem.h;
	}
	if (w->wkind & HSLIDE)
		if ( (to->w-w->v.w)/w->unit.w < w->dis.t6-regel)
			to->w = (w->dis.t6-regel)*w->unit.w-w->v.w;
		else ;
	elif (to->w < 640)
		  to->w = 640;
	snapwindow(w, to);
	w->rem = *to;
	w->nfrem = w->rem;
	w->full = false;
	wind_set(w->wh, WF_CURRXYWH, w->rem);
	get_Dwork(w);
	new_left(w);
	page(w);
}

/* uses allways rectangle list, so topw not needed */
static
ARROWD arrow_obj			/* IT *w, short arrow, bool topw */
{
	short owl = w->norm.pos.x;

	switch (arrow)
	{
	case WA_UPLINE:
		minus(w, 2);
	esac
	case WA_UPPAGE:
		prv_page(w);
	esac
	case WA_DNLINE:
		plus(w, 2);
	esac
	case WA_DNPAGE:
		w->cf.spg = w->dis.npg;
		page(w);
	esac
	case WA_LFPAGE:
	case WA_LFLINE:
		w->norm.pos.x = 0;
		if (owl ne w->norm.pos.x)
			page(w);
	esac
	case WA_RTLINE:
	case WA_RTPAGE:
		w->norm.pos.x = w->view.sz.w - w->norm.sz.w;
		if (owl ne w->norm.pos.x)
			page(w);
	esac
	}
}

static
SLIDE slide_obj				/* IT *w, short hslp, short vslp */
{
	DW *dw = w->dw;
	long naar;

	if (w->vslp ne vslp)
	{
		if (!w->cg.asc)
		{
			w->cf.spg = z org;
			if (w->cg.lbl or w->cg.sym)
				naar = z top.i - z org.i - (w->norm.sz.h*2);
			else
				naar = z bss.i - z org.i - (w->norm.sz.h*2);
		othw
			w->cf.spg.b = w->dis.buffer;
			naar = w->dis.lim.b - w->dis.buffer - (w->norm.sz.h*w->dis.hexw);
		}
		if (naar < 0)
			naar = 0;
		if (vslp > 1)
			w->cf.spg.i += (naar*vslp)/1000;

		w->vslp = vslp;
		wind_set(w->wh, WF_VSLIDE, vslp);

		page(w);
	}

	if (w->hslp ne hslp)
	{
		short old = w->norm.pos.x;

		w->hslp = hslp;
		wind_set(w->wh, WF_HSLIDE, hslp);

		w->norm.pos.x = (((long)w->view.sz.w-w->norm.sz.w)*hslp)/1000;
		if (w->norm.pos.x ne old)
			page(w);
	}
}

global
IT *make_w(char *fn, short fl, D_CFG *q)
{
	IT *w;
	TTD_PROF *qcg = q ? &q->cg : &deskw.cg;
	TTD_CFG  *qcf = q ? &q->cf : &deskw.cf;

	short wkind = NAME|CLOSER;

/* some usefull attributes */
	if (cfg.vslider)
		wkind |= VSLIDE|UPARROW|DNARROW;
	if (cfg.hslider)
		wkind |= HSLIDE|LFARROW|RTARROW;
	if (cfg.sizer)
		wkind |= SIZER|FULLER|MOVER;

/*	textmargin.x = deskw.unit.w/2;
*/
	if	( (w = create_IT
				(	true, /* incl WIND_CREATE */
					fn,
					fl,
					" ",
					nil,
					wkind,
					OBJ,
					nil,
					nil,
					nil,
					nil,
					0,
					objt_winit,		/* object window init position */
					nil,
					nil,			/* antedraw */
					draw_page,		/* draw */
					nil,			/* postdraw */
					dis_evm,	/* antevnt */
					nil,			/* display lines */
					nil,			/* display unit (line) */
					nil,			/* ante display */
					nil,			/* post display */
					close_obj,
					close_disass,
					nil,			/* default top action */
					full_obj,
					(wkind&(VSLIDE|HSLIDE)) ? slide_obj : nil,
					sliders,
					(wkind&(UPARROW|DNARROW)) ? arrow_obj : nil,
					(wkind&SIZER) ? size_obj : nil,
					(wkind&MOVER) ? move_obj : nil,
					dis_button,
					nil,		/* All keyboard via menu shortcuts! */
					nil,
					nil,
					menu_draw,
					do_wdmenu,
					set_menu,
					&dmen,
					nil,
					nil,
					nil,
					nil,			/* No cursor */
					nil,
					nil,
					m_kader,
					nil,
					nil,
					deskw.unit,
					deskw.points,
					nil
/*					,textmargin
 */                  )

		  ) eq nil
		)
		alertwindow("object");
	else
	{
		w->plain = true; 		/* all keys in menu */
		w->dw = MMalloc(sizeof(DW), "DW", AH_DIG_DW, 0);

		w->cf = *qcf;
		w->cg = *qcg;

		if (w->dw eq nil)
		{
			send_msg(frstr(WINOP), "object");
			via (w->close_file)(w, true);
			return nil;
		othw
			DW *dw = w->dw;
			memset(dw, 0, sizeof(DW));

			z w = w;				/* cross reference */
			w->cf_tab = copyconfig(ttdfil, &dcfg.cf, &w->cf);
			w->cg_tab = copyconfig(ttdtab, &DIS_cfg, &w->cg);

			z cg = &w->cg;
			z cf = &w->cf;

			setmask(w);
			w->cg.rdx = qcg->dec?10:16;
			w->dis.rkey.i = -1;
			w->dis.key_remember.i = -1;	/* invalidate ^R (next reference) */
			w->norm.sz.w = 0;
			w->view.sz.h = 0;
			w->hl = v_hl;
			w->frem.x = w->in.x;		/* breedte fulled = als initieel */
			w->frem.w = w->in.w;
			w->base = nil;
			w->old = nil;
			z keep = MMalloc(WLONGS*sizeof(RXY), "keep", AH_DIG_KEEP, 0);
			if (z keep eq nil)
				send_msg("%s\n", frstr(NOKEEP));
		}
	}
	return w;
}

static
void init_L(LAB *L, long l)
{
	while (--l >= 0)
	{
		L->ty = 0x10;
		L->v  = HIGH_LV;
		L->n  = "";
		L++;
	}
}

global
void dat_to_w(IT *w)		/* Mark data seg as word */
{
	DW *dw = w->dw;
	long j;
	for (j = w->dis.ltext; j < w->dis.ltext+w->dis.ldat; j += 2)
		bset(z dt, j);
}

global
bool locate(bool *cfg, char *path, char *name, short msg)
{
	S_path pdir;
	P_path pn;

	pn.s = name;
	*cfg = !*cfg;

	if (*cfg and *path eq 0)	/* on? so it must have been off */
	{
		char *fn;
		pdir = idir;
		fn = select_file(&pdir, nil, pn.t, frstr(msg), &drive);
		if (fn)					/* OK clicked */
			strcpy(path, fn);
		else
			*cfg = false;		/* cancel */
	}
	return *cfg;
}
