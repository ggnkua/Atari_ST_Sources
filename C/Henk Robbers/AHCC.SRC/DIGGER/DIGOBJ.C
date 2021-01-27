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

/*	DIGOBJ.C
 *	========
 */

#include <string.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>
#include <ext.h>

#include "common/mallocs.h"
#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#include "aaaa.h"
#include "dig.h"
#include "digobj.h"
#include "common/cursor.h"
#include "text/text.h"
#include "common/files.h"
#include "common/journal.h"
#include "common/config.h"
#include "common/wdial.h"
#include "common/ahcm.h"
#include "ttd_kit.h"
#include "ttd_cfg.h"
#include "ttdisass.h"
#include "dig_it.h"

static long timer=0; long clock(void);
static SYSHDR	*sysbase;
static short 	os_version;
static char		tos_id[128];

static char *languages[]=
{
	"USA", "FRG", "FRA", "UK", "SPA",
	"ITA", "SWE", "SWF", "SWG", "TUR",
	"FIN", "NOR", "DEN", "SAU", "NL",
	"TOS"
};

global
char *find_sep(char c, char *s)
{
	while (*s and *s ne c) s++;
	if (*s)
		return s+1;
	return nil;
}

static
short get_drv(char *s)
{
	while (*s <= ' ') s++;
	*s = toupper(*s);
	if (*s >= 'A' and *s <= 'Z')
		return *s-'A';
	return -1;
}

/* HR 151002: Improved detection of TOS 1.x F-line & table. */
global
long getosstart(void)
{
	sysbase = *((SYSHDR **)(0x4f2L));
	return 0;
}

/* HR 151002: Improved detection of TOS 1.x F-line & table. */
static
void getosparams(IT *w, SYSHDR *os_base)
{
	PC ft;
	short os_lang, os_conf;
	DW *dw = w->dw;

	z linef.l = 0;
	z os_base = os_base;
	os_version = os_base->os_version;
	os_conf = os_base->os_palmode;
	os_lang = (os_conf>>1)&15;
	sprintf(tos_id, "%s_%x", languages[os_lang], os_version);

	if (w->cf.offset eq 0xfc0000)	/* antieke tossen */
	{
		ft.b = (char *)os_base + 192*1024L;

		/* Find the sequence:
			move  d2, sr
			unlk  a6
			rts

			If this sequence exists, it is followed by a table of function pointers.
			The length of this table is the maximum operand value for the F-line call.
		*/
		while (ft.b > (char *)os_base + 6)
			if (*(ft.w-1) eq 0x4e75 and *(ft.w-2) eq 0x4e5e and *(ft.w-3) eq 0x46c2)
			{
				z linef = ft;
				break;
			}
			else
				ft.w--;

		if (z linef.i)
		{
			while (*ft.l > w->cf.offset and *ft.l < w->cf.offset + 192*1024L)
				ft.l++;

			z linef_max = ft.i - z linef.i;
		}
	}
}

static
char *run_ppu2o(char *f, char *of)
{
	static char fno[DIRL];
	char cmd[DIRL];
	short e;

	cmd[0] = sprintf(cmd+1, "%s", f);
	send_msg_n("Run %s %s\n", cfg.ppupath, cmd+1);
	e = Pexec(0, cfg.ppupath, (COMMAND *)cmd, NULL);
	if (e >= 0)
	{
		sprintf(fno, "%s.O", of);
		return fno;
	othw
		send_msg("%d %s %s\n", e, frstr(RETNBY), cfg.ppupath);
	}

	return nil;
}

static char ppuname[DIRL] = "PPU2O.TTP";

global
void locate_ppu(short mt)
{
	if (!cfg.ppu and *cfg.ppupath eq 0)
		send_msg("%s\n", frstr(PPUWARN));
	locate(&cfg.ppu, cfg.ppupath, ppuname, LOCATE);
	menu_icheck(Menu, mt, cfg.ppu);
}

static
bool setup(IT *w)
{
	DW *dw = w->dw;
	short i;

	w->cf_tab      = copyconfig(ttdfil, &dcfg.cf, &w->cf);
	w->cg_tab      = copyconfig(ttdtab, &DIS_cfg, &w->cg);
	z dat          = z top;
	z bss          = z top;
	w->cf.offset   = z org.i;
	z S            = (SYM *)z top.b;
	z rlc          = z top;
	w->dis.s_lab   = (z top.b-z org.b)/CHAR_BIT+4;
	w->dis.s_dt    = w->dis.s_lab;
	z lab          = MMalloc(w->dis.s_lab, "setup lab", AH_DIG_LAB, 0);
	z dt           = MMalloc(w->dis.s_dt,  "setup dt",  AH_DIG_DT, 0);
	w->dis.history = MMalloc( HISTN*sizeof(PCB), "setup history", AH_DIG_HIST, 0);

	if (z dt eq 0 or z lab eq 0 or w->dis.history eq 0)
	{
		send_msg("%s\n", frstr(NOTAB));
		via (w->close_file)(w, true);
		return false;
	othw
		w->dis.his_ptr = 0;
		memset(z lab, 0, w->dis.s_lab);
		memset(z dt,  0,w->dis.s_dt);

		loop(i, HISTN)
			w->dis.history[i] = z org;
		l_opt(w, DMF4, false);
		return true;
	}
}

static short open_w(IT *w)
{
	DW *dw = w->dw;
	short l; char lbll[10];

	settabs(w);
	w->norm.pos.y = 0;
	w->op = wind_open(w->wh, w->in.x, w->in.y, w->in.w, w->in.h);
	get_Dwork(w);
	w->view.sz.w = MAXL+1;
	w->norm.sz.w = w->ma.w/wchar;
	l = sprintf(lbll, "%lx", z top.b-z shift.b);
	z lbl_len = min(max(l, 2), 8);
	return w->op;
}

static
void show_bpb(short drive, BPB *bpb)
{
	uint *buf, sum = 0, i;
	send_msg("%-16s%6d\n", frstr(BPS),    bpb->recsiz);
	send_msg("%-16s%6d\n", frstr(CLSIZ),  bpb->clsiz);
	send_msg("%-16s%6d\n", frstr(CLSIZB), bpb->clsizb);
	send_msg("%-16s%6d\n", frstr(RDLEN),  bpb->rdlen*bpb->recsiz/32);
	send_msg("%-16s%6d\n", frstr(FSIZ),   bpb->fsiz);
	send_msg("%-16s%6d\n", frstr(FATREC), bpb->fatrec);
	send_msg("%-16s%6d\n", frstr(DATREC), bpb->datrec);
	send_msg("%-16s%6d\n", frstr(NUMCL),  bpb->numcl);
	send_msg("%-16s $%04x\n", frstr(BFLAG), bpb->bflags);
	buf = MMalloc(bpb->recsiz, "showbpb", AH_DIG_BPB, 0);
	if (buf)
	{
		if (Rwabs(0, buf, 1, 0, drive) eq 0)
		{
			loop(i, 256)
				sum += buf[i];
			if (sum eq 0x1234)
				send_msg("-= %s =-\n\n", frstr(BOOTEX));
		}
		free(buf);
	}
}

static
void do_noprg(IT *w)
{
	DW *dw = w->dw;
	short i;

	ERASE(z lab);
	ERASE(z rel);
	ERASE(z dt);
	ERASE(w->dis.jt);
	free_hsym(&z WL);
	free_hsym(&z XL);
	free_hsym(&z ML);
	free_hsym(&z CL);

	if (w->dis.history eq 0)
		w->dis.history = MMalloc( HISTN*sizeof(PCB), "nprg history", AH_DIG_HIST, 0);
	w->dis.s_lab = w->dis.flen/CHAR_BIT+4;
	z   lab = MMalloc(w->dis.s_lab, "nprg lab", AH_DIG_LAB, 0);
	w->dis.s_dt = w->dis.s_lab;
	z   dt = MMalloc(w->dis.s_dt, "nprg dt", AH_DIG_DT, 0);

	if (   z lab eq nil
		or z dt  eq nil
		or w->dis.history eq nil)
	{
		send_msg("%s\n", frstr(NOTAB));
		via (w->close_file)(w, true);
		return;
	}

	memset(z lab, 0, w->dis.s_lab);
	memset(z dt,  0, w->dis.s_dt);

	z reloff = 0;
	z shift.b = z org.b-w->cf.offset;
	z dat = w->dis.lim;
	z bss = w->dis.lim;
	z top = w->dis.lim;
	z bot = z org;
	z S = (SYM *)w->dis.lim.i;
	z rlc = w->dis.lim;
	if (z bss.i&1)
		bset(z dt, z bss.b-z org.b-1),
		bset(z dt, z bss.b-z org.b);
	w->dis.his_ptr = 0;
	loop(i, HISTN)
		w->dis.history[i] = z org;
	w->dis.d_info = false;
/*	l_ opt(w, w->cf.l_mode, false);	*/
	other_machine(w, false);
	if (z tosimg)
		getosparams(w, (SYSHDR *)w->dis.buffer);
	open_w(w);
	if (z tosimg)
	{
		sprintf(w->title.t, " *** TOS %s ***", tos_id);
		wi_title(w);
	}

	set_menu(w);
	other_machine(w, false);
}

static
CON_RET ram  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	DW *dw = w->dw;

	char *s = find_sep(',',line);
	if (!s)
	{
		send_msg("%s\n", frstr(NEED2A));
	othw
		z org.i = get_addr(w, line);
		z top.i = get_addr(w, s);

		if (z org.i < 0x800)	/* if in supervisor part, move it */
		{
			void *ssp;
			w->dis.buffer = MMalloc(0x800, "superRAM", AH_DIG_RAM, 0);
			if (w->dis.buffer eq nil)
			{
				send_msg("%s\n", frstr(SUPROOM));
				close_disass(w, true);
				return;
			}

			ssp = (void *)Super(nil);
			memmove(w->dis.buffer, 0, 0x800);
			Super(ssp);

			z org.b = w->dis.buffer;
			z bot      = z org;
			z top.i    = z org.i + 0x800;
			w->dis.lim = z top;
			z shift    = z org;
			strcpy(w->title.t, frstr(SUPERRAM));		/* No need to be intelligent: give it all */
		othw
			z top.i = max(min(0x400000, (z top.i+1)&-2), z org.i+2);
			w->dis.lim = z top;
			z bot = z org;
			w->dis.buffer = z org.b;
			if (w->cg.rdx eq 16)
				sprintf(w->title.t, "%s   (%s%lX - %s%lX)", frstr(RAM), w->cg.r16, z org.i, w->cg.r16, z top.i-1);
			else
				sprintf(w->title.t, "%s   (%ld - %ld)",     frstr(RAM), z org.i, z top.i-1);
		}

		wi_title(w);
		if (setup(w))
		{
			send_msg_n("%s\n", w->title.t);
			if (w->cg.rdx eq 16)
				sprintf(w->dis.fo, "M_%06lX", z org.i);
			else
				sprintf(w->dis.fo, "M_%ld", z org.i);
			strcpy(w->dis.fs, w->dis.fo);
			open_w(w);
		}
	}
}

static
CON_RET disk  /* IT *w, char *line, short prompt, short curtask, short curstage */
{
	DW *dw = w->dw;
	long sts = -1, lts = -1; long offset = 0;

	char *r, *s, *t;

	strsncpy(w->con.remember, line, MAXJ);

	r = find_sep(',', line);
	if (r)
	{
		offset = cldbv(r);

		s = find_sep(',', r);
		if (s)
		{
			sts = cldbv(s);
			t = find_sep('-', s);
			if (t)
				lts = cldbv(t);
		}
	}

	drive = get_drv(line);

	if (drive < 0)
		send_msg("%s\n", frstr(INVDRV));
	else
	{
		long mts, nsect,
		     mediach = Mediach(drive);
		short bps, rflag;
		BPB *bpb = Getbpb(drive);

		sprintf(w->title.t, " %c:\\ ", drive+'A');

		if (!bpb)
		{
			send_msg("%s\n", frstr(INVBPB));
			mts = 1;
			bps = 512;
			rflag = 2;
		othw
			struct dfree ff;
			mts = ((long)bpb->clsiz*bpb->numcl)+bpb->datrec;
			bps = bpb->recsiz;
			rflag = 0;
			if (mediach) getdfree(drive+1, &ff);
			show_bpb(drive, bpb);
		}

		if (sts >= 0)
		{
			long avail;
			if (lts >= sts)
				nsect = lts-sts+1;
			else
				nsect = 1, lts = sts;

			avail = (long)Malloc(-1)-bps;
			if (avail < nsect*bps)
				nsect = avail/bps,
				lts = sts+nsect;

			if (lts > mts)
				lts = mts,
				nsect = lts-sts+1;

			w->dis.flen = nsect*bps;

			w->dis.buffer = MMalloc(w->dis.flen, "disk: buffer", AH_DIG_BUF, 0);
			Rwabs(rflag, w->dis.buffer, nsect, sts, drive);
			w->dis.lim.b = w->dis.buffer + w->dis.flen;
			z reloff = 0;
			z prg = false;
			z org.b = w->dis.buffer;
			w->map = w->dis.buffer;		/* for cleanup */
			z top = w->dis.lim;
			z bot = z org;
			w->dis.d_info = false;
			if (!setup(w))
				return;

			z shift.i = z org.i-offset;
			w->cf.offset = offset;

			opt(w, DMF2, true);		/* hex/ascii */
			if (w->cg.rdx eq 16)
				sprintf(w->title.t, " %s  (%s%lX - %s%lX) %c:\\ ",
							frstr(DISK), w->cg.r16, sts, w->cg.r16, lts, drive+'A');
			else
				sprintf(w->title.t, " %s  (%ld - %ld) %c:\\ ",
							frstr(DISK), sts, lts, drive+'A');
			wi_title(w);
			if (w->cg.rdx eq 16)
				sprintf(w->dis.fo, "D_%06lX", sts);
			else
				sprintf(w->dis.fo, "D_%ld", sts);
			strcpy(w->dis.fs, w->dis.fo);
			open_w(w);
			return;
		}
	}
	via (w->close_file)(w, true);
}

static
bool check_idx(IT *w)
{
	long fl;

	sprintf(fx, "%s%s", w->dis.fo, frstr(EXT_I));
	fl = Fopen(fx, 0);
	if (fl > 0)
	{
		Fclose(fl);
		return true;
	}
	return false;
}

static
void look_extra(IT *w)
{
	if (w->dis.pclim.b < w->dis.lim.b)
	{
		w->dis.debug = w->dis.lim.b-w->dis.pclim.b;
		if (((*w->dis.pclim.l)>>8) ne 'QDB')
			send_msg("%ld %s.\n", w->dis.debug, frstr(XTRAB)),
			w->dis.extra = true;
		else
			send_msg("debug info: %7ld bytes\n", w->dis.debug);
	}
	open_w(w);
	if (check_idx(w))
		load_idx(w, fx);
}

static
CON_RET con_undo
{
	w = get_it(w->wh, -1);
	via (w->close_file)(w, true);
	con_end(true);
}

static
CON_RET have_offset		/* IT *w, char *line, short prompt, short curtask, short curstage */
{
	w->cf.offset = get_addr(w, line);
	w->cf.haveoff = true;
	con_end(true);
	do_noprg(w);
	if (check_idx(w))
	{
		load_idx(w, fx);
		page(w);
	}
}

static
void noprg(IT *w, char *msg, bool offs)
{
	DW *dw = w->dw;

	if (z tosimg)
		send_msg("%s %ld -= %s =-\n", frstr(TOSIMG), w->dis.flen, msg);
	else
		send_msg("%s -= %s =-\n", frstr(NOPRG), msg);

	z org.b = w->dis.buffer;
	z prg = false;

	if (!offs)			/* normal no prg */
	{
		if (/* !startfiles and */!w->cf.haveoff)
		{
			if (z tosimg)			/* 151002 */
			{
				if (w->dis.flen > 192*1024L)
					w->cf.offset = 0xe00000;
				else
					w->cf.offset = 0xfc0000;
				w->cf.haveoff = true;
				do_noprg(w);
				if (check_idx(w))
				{
					load_idx(w, fx);
					page(w);
				}
			}
			else
				con_input(w, 1000, 0, frstr(P_ORG), nil, nil, have_offset, con_undo);
		othw
			do_noprg(w);
			if (check_idx(w))
				load_idx(w, fx);
		}
	othw				/* errors */
		if is_PC
		{
			z puc = false;
			ERASE(z rlc.b);
			ERASE(z PL);
			ERASE(z L.lab);
		}
		z org.i = (z org.i+1)&-2;
		w->cf.offset = z org.b-w->dis.buffer;
/*		w->cf.l_mode = 0;		*/	/* 12'05 */

		do_noprg(w);
	}
}

static
void dri_decode(IT *w, bool gfa)
{
	DW *dw = w->dw;
	PC c = z rlc;

	if (gfa)
	{
		send_msg_n("\n%s: '%s'\n\n", frstr(GFAM), w->title.t);
		send_msg_n("text %s:%7ld\n", frstr(SEGM), w->dis.ltext);
		send_msg_n("data %s:%7ld\n", frstr(SEGM), w->dis.ldat);
		send_msg_n("bss  %s:%7ld\n", frstr(SEGM), w->dis.lbss);
		send_msg_n("%s:%7ld\n",      frstr(SYMTAB), w->dis.lsym);
		send_msg_n("%s:%7ld\n",      frstr(NNAMES), w->dis.syms);
		send_msg_n("%s:%7ld\n",      frstr(RELOT), w->dis.kop.drih.res1);
		send_msg_n("%s:%7ld\n",      frstr(RELOD), w->dis.kop.drih.res2);
	othw
		send_msg_n("\nDRI object: '%s'\n\n", w->title.t);
		send_msg_n("text %s:%7ld\n", frstr(SEGM), w->dis.ltext);
		send_msg_n("data %s:%7ld\n", frstr(SEGM), w->dis.ldat);
		send_msg_n("bss  %s:%7ld\n", frstr(SEGM), w->dis.lbss);
		send_msg_n("%s:%7ld\n",      frstr(SYMTAB), w->dis.lsym);
		send_msg_n("%s:%7ld\n",      frstr(NNAMES), w->dis.syms);
	}

	if (w->dis.lreloc ne w->dis.ltext + w->dis.ldat)
		send_msg_n("reloc info:   %7ld\n", w->dis.lreloc);

	z reloff = z rlc.b-z org.b;

	send_msg_n("\n%s\n", frstr(DECO));

	timer = clock();
	w->dis.pclim.b = z rlc.b+w->dis.ltext+w->dis.ldat;
	while (c.b < w->dis.pclim.b)
	{
		PC x;
		x.b = c.b-z reloff;

		switch (*c.w & 7)
		{
		case 1:		/* data.w */
			*x.w += w->dis.ltext;
		esac
		case 3:		/* bss.w */
			*x.w += w->dis.ltext + w->dis.ldat;
		esac
		case 5:
			switch(*(c.w+1)&7)
			{
			case 1:		/* data.l */
				*x.l += w->dis.ltext;
			esac
			case 3:		/* bss.l */
				*x.l += w->dis.ltext + w->dis.ldat;
			esac
			}
			c.w++;
		esac
		}
		c.w++;
	}
	w->dis.d_info = w->dis.lsym ne 0;
	w->dis.pclim = scan_DRI(w);
	if (w->dis.pclim.b eq nil)
		noprg(w, frstr(ERR_REL), true);
	else
	{
		send_msg_n("-= OK =- %ld ms\n", (clock()-timer)*5);
		look_extra(w);
	}
}

static
void prg_decode(IT *w)
{
	DW *dw = w->dw;

	z reloff = 0;
	send_msg_n("\n%s: '%s'\n\n", frstr(PROGM), w->title.t);
	send_msg_n("text %s:%7ld\n", frstr(SEGM), w->dis.ltext);
	send_msg_n("data %s:%7ld\n", frstr(SEGM), w->dis.ldat);
	send_msg_n("bss  %s:%7ld\n", frstr(SEGM), w->dis.lbss);
	send_msg_n("%s:%7ld\n",      frstr(SYMTAB), w->dis.lsym);
	send_msg_n("%s:%7ld\n",      frstr(NNAMES), w->dis.syms);
	w->dis.d_info = w->dis.lsym ne 0;
	w->dis.pclim.b = scan_PRG(w);
	look_extra(w);
}

static
PC move_gfa_rlc(IT *w, long rl)
{
	DW *dw = w->dw;
	PC r = z rlc;				/* old *GFA reloc */
	long l = w->dis.ltext + w->dis.ldat;

	r.b += l;					/* new *GFA reloc */
	w->dis.lreloc = l;

	memmove(r.b, z rlc.b, rl);	/* move GFA reloc --> new */
	memset (z rlc.b, 0, l);		/* zeroize DRI reloc */
	return r;					/* return new GFA reloc */
}

#define SHOW_GFA 1

static
PC text_GFA(IT *w, PC r, PC rt, long rl, bool show)
{
	long i;

#if SHOW_GFA
	DW *dw = w->dw;
	long tally = 0, fixes[8];
	short ll = ' ';

	send_msg("-= converting short relocation info %ld ---> %ld =-\n", rl, w->dis.ltext);

	loop (i,8) fixes[i] = 0;

	loop(i, rl / sizeof(uint) )
	{
		uint get = *r.u,
		     sym =  get >> 3,
		     ty  =  get &  7,
		     step = sym * sizeof(uint);

		if break_in break;

		fixes[ty] ++;

		if (ty eq 5)
		{
			*rt.u = *r.u;
			ll = 'L';
			tally += sizeof(uint);
		}
		elif (ty eq 7)
		{
			if (show) send_msg("%4ld STEP %c %6d %3d   %6ld 0x%04x\n",
						i, ll, sym, ty, tally, get);
			tally += step;
			ll = ' ';
		othw
			*rt.u = *r.u;
			switch(ty)
			{
				case 0:
					if (show) send_msg("%4ld ~~~~ %c %6d %3d * %6ld\n",
						i, ll, sym, ty, tally);
				esac
				case 1:						/* in data */
					if (show) send_msg("%4ld DATA %c %6d %3d * %6ld\n",
						i, ll, sym, ty, tally);
				esac
				case 2:						/* in text */
					if (show) send_msg("%4ld TEXT %c %6d %3d * %6ld\n",
						i, ll, sym, ty, tally);
				esac
				case 3:						/* in bss */
					if (show) send_msg("%4ld BSS  %c %6d %3d * %6ld\n",
						i, ll, sym, ty, tally);
				esac
				case 4:						/* absolute long relocatable */
					if (show) send_msg("%4ld ABS  %c %6d %3d   %6ld %s\n",
						i, ll, sym, ty, tally, dri_name(z S[sym].n, z S[sym].d, 0) );
				esac
				case 6:						/* word pc relative relocatable */
					if (show) send_msg("%4ld PC   W %6d %3d   %6ld %s\n",
						i, sym, ty, tally, dri_name(z S[sym].n, z S[sym].d, 0) );
				esac
			}

			tally += sizeof(uint);
			ll = ' ';
		}

		r.u ++;
		rt.b = z rlc.b + tally;
	}

	loop (i, 8)
		send_msg("fixes[%ld] = %ld\n", i, fixes[i]);
	send_msg("last: %ld\n", tally);

#else
	for(i = 0; i < (rl / sizeof(uint)); i++, r.u++)
		if ((*r.u & 7) eq 7)
			 rt.u  += *r.u >> 3;
		else
			*rt.u++ = *r.u;
#endif

	return r;
}

static
PC data_GFA(IT *w, PC r, PC rt, long rl, bool show)
{
	long i;

#if SHOW_GFA
	DW *dw = w->dw;
	long tally = 0, fixes[8];

	send_msg("-= converting short relocation info %ld ---> %ld =-\n", rl, w->dis.ldat);

	loop (i,8) fixes[i] = 0;

	loop(i, rl / sizeof(uint) )
	{
		uint get = *r.u,
		     step =  get >> 3,
		     ty  =  get &  7;

		if break_in break;

		fixes[ty] ++;

		if (ty eq 7)
		{
			if (show) send_msg("%4ld STEP %6d %3d   %6ld 0x%04x\n",
						i, step, ty, tally, get);
			tally += step;
		}
		else
			send_msg("GFA data relocation format error %d\n", ty & 7);

		r.u ++;
		rt.b = z rlc.b + tally;
	}

	loop (i, 8)
		send_msg("fixes[%ld] = %ld\n", i, fixes[i]);
	send_msg("last: %ld\n", tally);

#else
	for(i = 0; i < (rl / sizeof(uint)); i++, r.u++)
		if ((*r.u & 7) eq 7)
			 rt.b  += *r.u >> 3;
		else
			send_msg("GFA data relocation format error %d\n", *r.u & 7);
#endif

	return r;
}

static
void convert_GFA(IT *w, long rl)		/* Scan relocation information of a GFA object module */
{
	DW *dw = w->dw;
	PC rd, r  = move_gfa_rlc(w, rl);

	rd.b = z rlc.b + w->dis.ltext;

	r = text_GFA(w, r, z rlc, w->dis.kop.drih.res1, false);
	    data_GFA(w, r, rd,    w->dis.kop.drih.res2, true);
}

static
void dri_file(IT *w, long flen)
{
	DW *dw = w->dw;
	DRI_H kop;
	extern bool force_o;

	z puc = TuC;

	if (flen < sizeof(DRI_H))
		noprg(w, frstr(TOOSMALL), true);		/* default offset */
	else
	{
		kop = w->dis.kop.drih;
		z org.b = w->dis.buffer + sizeof(DRI_H);
		w->dis.f_info = true;
		w->dis.ltext = kop.ltext;
		w->dis.ldat  = kop.ldata;
		w->dis.lbss  = kop.lbss;
		w->dis.lsym  = kop.lsym;

		if (   ((w->dis.ltext|w->dis.ldat|w->dis.lbss|w->dis.lsym)&0xfc000000) ne 0
			or  (w->dis.ltext+w->dis.ldat+w->dis.lsym) >  flen
			)
			noprg(w, frstr(DRIHDERR), true);
		else
		{
			short i;
			z L.no = w->dis.lsym/sizeof(SYM);
			z L.max = z L.no;
			z L.hash = near_hi_p2((14*z L.max)/10, 0);

			w->dis.s_lab = (w->dis.ltext+w->dis.ldat+w->dis.lbss)/CHAR_BIT+4;
			w->dis.s_rel = (w->dis.ltext+w->dis.ldat)/CHAR_BIT+4;
			w->dis.s_dt =   w->dis.s_rel;
			z lab   = MMalloc(w->dis.s_lab, "DRI lab", AH_DIG_LAB, 0);
			z rel   = MMalloc(w->dis.s_rel, "DRI rel", AH_DIG_REL, 0);
			z dt    = MMalloc(w->dis.s_dt,  "DRI dt",  AH_DIG_DT,  0);
			z L.lab = MMalloc((z L.hash+1)*sizeof(LAB), "DRI L", AH_DIG_LLAB, 0);
			w->dis.history = MMalloc(HISTN*sizeof(PCB),  "DRI history", AH_DIG_HIST,0);

			if (   z lab     eq nil
				or z rel     eq nil
				or z dt      eq nil
				or w->dis.history eq nil
				or z L.lab   eq nil
				)
			{
				send_msg("%s\n", frstr(NOTAB));
				via (w->close_file)(w, true);
				return;
			}

			memset(z lab,   0, w->dis.s_lab);
			memset(z rel,   0, w->dis.s_rel);
			memset(z dt,    0, w->dis.s_dt);
			memset(z L.lab, 0, (z L.hash+1)*sizeof(LAB));
			dat_to_w(w);
			z prg = true;
			w->cf.offset = 0;
			z shift = z org;
			z dat.b = z org.b+w->dis.ltext;
			z bss.b = z dat.b+w->dis.ldat;
			z top.b = z bss.b+w->dis.lbss;
			z bot = z org;
			(PCB)z S = z bss.b;
			w->dis.syms = w->dis.lsym/sizeof(SYM);

			if (w->dis.syms eq nil and w->cg.sym)
				w->cg.sym = false, w->cg.lbl = true;

			z rlc.b = (PCB)(z S+w->dis.syms);
			if (z rlc.i & 1)
				noprg(w, "format error", true);
			else
			{
				char slash[2];
				bool dri; long rl;

				inq_xfs(w->title.t, slash);
				dri =   stricmp(getsuf(w->title.t), "O") eq 0
					 or force_o;

				w->dis.his_ptr = 0;
				loop(i, HISTN)
					w->dis.history[i] = z org;

				w->dis.lreloc = flen
				              - (w->dis.ltext + w->dis.ldat + w->dis.lsym)
				              - sizeof(DRI_H);					 /* for check */

				rl = w->dis.kop.drih.res1 + w->dis.kop.drih.res2;

				if (dri and rl > 0)
				{
					convert_GFA(w, rl);
					dri_decode(w, true);
				}
				elif (dri and z rlc.b + w->dis.ltext + w->dis.ldat <= w->dis.lim.b)
					dri_decode(w, false);
				else
					prg_decode(w);
			}
			/* format err */
		}
		/* hd err */
	}
	/* too small */
}

#if GST
typedef struct
{
	uchar l;
	uchar s[0];
} pstring;

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
PCB pstr(PCB r, char *n)
{
	uint c = *r++;
	while (c--)
		*n++ = *r++;
	*n = 0;
	return r;
}

static
PCB getlong(PCB r, long *l)
{
	*((char *)l + 0) = *r++;
	*((char *)l + 1) = *r++;
	*((char *)l + 2) = *r++;
	*((char *)l + 3) = *r++;
	return r;
}

static
PCB getshort(PCB r, short *i)
{
	*((char *)i + 0) = *r++;
	*((char *)i + 1) = *r++;
	return r;
}

static
void gst_file(IT *w, long flen)
{
	PC rs, r, re, ts, t;
	long i, j;
	short trunc_rule, fixes[GST_last];

	r.b = xmalloc(flen + 2, AH_DIG_GST);
	if (r.b eq nil)
		return;

	memmove(r.b, w->dis.buffer, flen);
	t.b = w->dis.buffer;
	memset(t.b, 0, flen);

	rs = r;
	ts = t;

	re.b = r.b + flen;

	loop(i, GST_last)
		fixes[i] = 0;

	while (r.b < re.b)
	{
		uchar c = *r.b;

		if (c eq GST_escape)
		{
			char name[256];
			short id;
			long val;

			i = r.b - rs.b;
			j = t.b - ts.b;
			r.b++;
			c = *r.b;
			if (c < GST_last)
				fixes[c]++;

			switch (c)
			{
			case GST_escape:
				send_msg("%4ld %4ld GST_escape\n", i, j);
				*t.b++ = *r.b;
			esac
			case 0:
				send_msg("%4ld %4ld %s\n", i, j, gst_names[c]);
			esac
			case GST_source:
				r.b++;
				r.b = pstr(r.b, name);
				send_msg("%4ld %4ld %s %s\n", i, j, gst_names[c], name);
			continue;
			case GST_comment:
				r.b++;
				r.b = pstr(r.b, name);
				send_msg("%4ld %4ld %s %s\n", i, j, gst_names[c], name);
			continue;
			case GST_org:
				r.b++;
				r.b = getlong(r.b, &val);
				send_msg("%4ld %4ld %s %6ld\n", i, j, gst_names[c], val);
			continue;
			case GST_section:
				r.b++;
				r.b = getshort(r.b, &id);
				send_msg("%4ld %4ld %s %3d\n", i, j, gst_names[c], id);
			continue;
			case GST_offset:
				r.b++;
				getlong(r.b, &val);
				r.b += val;
				send_msg("%4ld %4ld %s %6ld\n", i, j, gst_names[c], val);
			continue;
			case GST_xdef:
				r.b++;
				r.b = pstr(r.b, name);
				r.b = getlong(r.b, &val);
				r.b = getshort(r.b, &id);
				send_msg("%4ld %4ld %s %-15s = %3d @ %6ld\n", i, j, gst_names[c], name, id, val);
			continue;
			case GST_xref:
				r.b++;
				r.b = getlong(r.b, &val);
				trunc_rule = *r.b++;
				send_msg("%4ld %4ld %s %6ld ", i, j, gst_names[c], val);
				while ((uchar)*r.b ne GST_escape)
				{
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
					{
						send_msg("GST xref format error\n");
						r.b++;
					}
					if (trunc_rule & 1)
						*t.b++ = val;
					if (t.i & 1)
						send_msg("to odd\n");
					elif (trunc_rule & 2)
						*t.w++ = val;
					elif  (trunc_rule & 4)
						*t.l++ = val;
				}
				send_msg("0x%02x %s\n", trunc_rule, trunc(trunc_rule));
			esac
			case GST_8:
				send_msg("%4ld %4ld %s\n", i, j, gst_names[c]);
			esac
			case GST_9:
				send_msg("%4ld %4ld %s\n", i, j, gst_names[c]);
			esac
			case GST_define:
				r.b++;
				r.b = getshort(r.b, &id);
				r.b = pstr(r.b, name);
				send_msg("%4ld %4ld %s %-15s = %3d\n", i, j, gst_names[c], name, id);
			continue;
			case GST_11:
				send_msg("%4ld %4ld%s\n", i, j, gst_names[c]);
			esac
			case GST_common:
				r.b++;
				r.b = getshort(r.b, &id);
				r.b = pstr(r.b, name);
				send_msg("%4ld %4ld %s %-15s = %3d\n", i, j, gst_names[c], name, id);
			continue;
			case GST_end:
				send_msg("%4ld %4ld %s\n", i, j, gst_names[c]);
			esac
			default:
				send_msg("%4ld %4ld unknown %d 0x%02x\n", i, j, c, c);
			}
		}
		else
			*t.b++ = *r.b;

		r.b++;
	}
	loop (i, GST_last)
		send_msg("fixes[%2ld,%-12s] = %d\n", i, gst_names[i], fixes[i]);
}
#endif

extern char *fixnames[];

static
void pc_file(IT *w, long flen)
{
	DW *dw = w->dw;
	PC_H kop;
	PC relocend;

	z puc = PuC;

	if (flen < sizeof(PC_H))
		noprg(w, frstr(TOOSMALL), true);
	else
	{
		long j;

		kop = w->dis.kop.pch;
		z org.b = w->dis.buffer + sizeof(PC_H);
		w->dis.f_info = true;
		w->dis.limg   = kop.limage;
		w->dis.lfix   = kop.lfixup;
		w->dis.lnam   = kop.lnames;
		w->dis.fixups = w->dis.lfix/sizeof(FIX);
		w->dis.debug  = 0;
		j = w->dis.limg+w->dis.lfix+w->dis.lnam;

		if (j > flen or j < 0)
			noprg(w, frstr(PCHDERR), true);
		else
		{
			FIX *F;
			long staffel, regime;
			bool fixfout = false;

			send_msg_n("\nPure C object: '%s'\n\n", w->title.t);
			send_msg_n("image %s:%7ld\n", frstr(SEGM), w->dis.limg);
			send_msg_n("fixup %s:%7ld\n", frstr(SEGM), w->dis.lfix);
			send_msg_n("names %s:%7ld\n", frstr(SEGM), w->dis.lnam);

			z rlc.b = MMalloc(w->dis.limg+4, "PuC rlc", AH_DIG_RLC, 0);
			if (z rlc.b eq nil)
			{
				send_msg("%s\n", frstr(NOTAB));
				via (w->close_file)(w, true);
				return;
			}

			memset(z rlc.b, 0, w->dis.limg+4);
			(PCB)z F = z org.b+w->dis.limg;
			z dat.b = (PCB)z F;
			z bss.b = nil /* z dat */;
			z top = z dat;
			z L.no = 0;

			F = z F;
			staffel = 0;

			send_msg_n("\n%s\n", frstr(DECO));

			/* bepalen ldat, ltext & lbss */
			timer = clock();

			while(F < z F+w->dis.fixups)
			{
				uchar fixty = F->ty;

				if (fixty eq FIX_end or fixty eq FIX_offs)
				{
					staffel += F->sk;
					z top.b = z org.b+staffel;
					break;
				}
				switch (fixty)
				{
				case FIX_step:			/* advance */
					staffel += skip(F);		/* HR june 14 2004: use 24 bits */
				esac
				case FIX_text:			/* start new TEXT segment */
					staffel += F->sk;
					if (z dat.b ne (PCB)z F)	/* already had data? */
						fixfout = true;
				esac
				case FIX_data:			/* start new DATA segment */
					staffel += F->sk;
					if (z bss.b ne nil)	/* already had bss? */
						fixfout = true;
					if (z dat.b eq (PCB)z F)
						z dat.b = z org.b+staffel;
				esac
				case FIX_bss:			/* start new BSS segment */
					staffel += F->sk;
					if (z bss.b eq nil)
						z bss.b = z org.b+staffel;
				esac
				default:
					staffel += F->sk;
					if (staffel < w->dis.limg)	/* there is no rlc for bss */
						if ( (staffel & 1) eq 0)	/* even */
							if (fixty >= FIX_labs and fixty <= FIX_wpcrel)
								*((PCW)(z rlc.b + staffel)) = F-z F;
				}
#if 0
					send_msg("F %3d %s %ld\n", F->nd, fixnames[F->ty], staffel);
#endif
				F++;
			}

			if (fixfout)
			{
				cleanup(w);
				noprg(w, frstr(FIXER), true);
			othw
				short i;
				PC pcc;

/* We must know exactly how many names there are */
				z nam = (char *)z F+w->dis.lfix;
				pcc.b = z nam;
				i = 0;
				while (pcc.b < z nam+w->dis.lnam)
				{
					uchar c = *(pcc.k);
					i++;
					pcc.b++;
					pcc.b += c;
				}

				z L.no = i;

				if (z bss.b eq nil)		/* bo bss */
					z bss.b = z top.b;
				w->dis.lbss = z top.b-z bss.b;
				w->dis.ldat = z bss.b-z dat.b;
				w->dis.ltext = z dat.b-z org.b;

				if (w->dis.ltext + w->dis.ldat ne w->dis.limg)
				{
					send_msg("text: %ld + data: %ld = %ld is not image: %ld\n", w->dis.ltext, w->dis.ldat, w->dis.ltext + w->dis.ldat, w->dis.limg);
					cleanup(w);
					noprg(w, frstr(FIXER), true);
				othw
					z L.max = z L.no;
					z L.hash = near_hi_p2((14*z L.max)/10, 0);

					w->dis.s_lab = (w->dis.limg+w->dis.lbss)/CHAR_BIT+4;
					w->dis.s_rel =  w->dis.limg/CHAR_BIT+4;
					w->dis.s_dt  =  w->dis.s_rel;

					z lab = MMalloc(w->dis.s_lab, "PuC lab", AH_DIG_LAB, 0);
					z rel = MMalloc(w->dis.s_rel, "PuC rel", AH_DIG_REL, 0);
					z dt  = MMalloc(w->dis.s_dt,  "PuC dt",  AH_DIG_DT, 0);
					w->dis.history = MMalloc( HISTN*sizeof(PCB), "PuC history", AH_DIG_HIST, 0);
					z PL  = MMalloc(z L.no*sizeof(LAB), "PuC PL",      AH_DIG_PL, 0);
					z L.lab = MMalloc((z L.hash+1)*sizeof(LAB)*2, "PuC L", AH_DIG_LLAB, 0);
#if 0
					send_msg_n("MMalloc lab %lx + %ld = %lx\n",z lab,w->dis.s_lab,(long)z lab + w->dis.s_lab);
					send_msg_n("MMalloc rel %lx + %ld = %lx\n",z rel,w->dis.s_rel,(long)z rel + w->dis.s_rel);
					send_msg_n("MMalloc dt %lx + %ld = %lx\n",z dt,w->dis.s_dt,(long)z dt + w->dis.s_dt);
					send_msg_n("MMalloc hist %lx + %ld = %lx\n",w->dis.history,HISTN*sizeof(PCB),(long)w->dis.history + (HISTN*sizeof(PCB)));
					send_msg_n("MMalloc PL %lx + %ld = %lx\n",z PL,z L.no*sizeof(LAB),(long)z PL + (z L.no*sizeof(LAB)));
					send_msg_n("MMalloc L.lab %lx + %ld = %lx\n",z L.lab,(z L.hash+1)*sizeof(LAB)*2,(long)z L.lab + ((z L.hash+1)*sizeof(LAB)*2));
#endif
					if (   z PL      eq nil
						or z L.lab   eq nil
						or z lab     eq nil
						or z rel     eq nil
						or z dt      eq nil
						or w->dis.history eq nil
						)
					{
						send_msg("%s\n", frstr(NOTAB));
						send_msg("%lx %lx %lx %lx %lx %lx\n",
								z PL, z L.lab, z lab, z rel, z dt, w->dis.history);
						via (w->close_file)(w, true);
						return;
					}

					memset(z lab,   0, w->dis.s_lab);
					memset(z rel,   0, w->dis.s_rel);
					memset(z dt,    0, w->dis.s_dt);
					memset(z PL,    0, z L.no*sizeof(LAB));
					memset(z L.lab, 0, (z L.hash+1)*sizeof(LAB)*2);
					loop(i, z L.no)
						z PL[i].ty = 0x10;
					w->dis.pclim.b = z org.b+w->dis.limg+w->dis.lfix+w->dis.lnam;
					w->dis.lreloc = w->dis.ltext+w->dis.ldat;

	/* fill name table with value and type of name */
					F = z F;
					staffel = 0;
					regime = 0;
					while (F < z F+w->dis.fixups)
					{
						long nnr = F->nd;
						staffel += F->sk;
						if (F->ty eq FIX_end)
							break;
						elif (F->ty eq FIX_offs)
						{
							regime = 1;
							staffel = 0;
						}
						elif (F->ty eq FIX_step)
							staffel += skip(F);		/* HR june 14 2004: use 24 bits */
						elif (F->ty >= FIX_glmod and F->ty <= FIX_lcent)
						{
							if (nnr < z L.no)		/* debug check */
							{
								z PL[nnr].v  = staffel;
								z PL[nnr].ty = regime ? FIX_offs : F->ty;
							}
						}
						F++;
					}

			/* Now put the names themselves in the table */
					(char *)z nam = (char *)z F+w->dis.lfix;
					pcc.b = z nam;
					j = 0;
					while (pcc.b < z nam+w->dis.lnam)
					{
						uchar c = *(pcc.k);
						z PL[j].n = pcc.b++;
	#if 0
						{
							char nx[256];
							strsncpy(nx, pcc.b, c+1);
							send_msg("name[%3ld]%14ld ty %s @ %lx(%ld) %3d '%s'\n",
									j, z PL[j].v, fixnames[z PL[j].ty], pcc.b, pcc.b-z nam, c, nx);
						}
	#endif
						pcc.b += c;
						j++;
					}
					dat_to_w(w);
					z prg = true;
					(PCB)z S = w->dis.lim.b;
					w->cf.offset = 0;
					z shift = z org;
					z bot = z org;
					w->dis.his_ptr = 0;
					loop(i, HISTN)
						w->dis.history[i] = z org;
					w->dis.d_info = true;

					relocend.b = z rlc.b+w->dis.lreloc;
					pcc = z rlc;

#if 0
					send_msg("lreloc %ld relocend %lx - pcc %lx = %ld\n",
						w->dis.lreloc, relocend.b, pcc.b, relocend.b - pcc.b);
#endif
					while (pcc.b < relocend.b)
					{
						if (*pcc.w)
						{
							FIX *f = z F+*pcc.w;
							long nnr = f->nd;
							if (nnr >= 0 and nnr < z L.no)			/* 12'05 */
							{
								PC x;

								x.b = z org.b + (pcc.b - z rlc.b);
								if (z PL[nnr].ty ne 0x10)	/* external */
								{
									long uu, val = z PL[nnr].v;
									switch(f->ty)
									{
									case FIX_labs:
										*x.l += val;
										pcc.w++;
									esac
									case FIX_wabs:
										*x.w += val;
									esac
									case FIX_lpcrel:
										*x.l += val-(x.b-z org.b);
										pcc.w++;
									esac
									case FIX_wpcrel:
										uu = val-(x.b - z org.b);
#if 0
										if (labs(*x.w + uu) >= 16384)
											send_msg("*x %d += val %ld -(x.b - org.b = %ld) uu %ld\n",
													  *x.w, val, x.b - z org.b, uu );
#endif
										*x.w += uu;
									esac
									}
								}
							}
						}
						pcc.w++;
					}

					scan_PC(w);

					send_msg_n("-= OK =- %ld ms\n", (clock()-timer)*5);
					send_msg_n("%s %ld\n", frstr(NNAMES), z L.no);
					send_msg_n("No of fixups: %ld\n", w->dis.lfix/sizeof(FIX));
					look_extra(w);
				}
				/* size err */
			}
			/* fix err */
		}
		/* hd err */
	}
	/* too small */
}

static
void GFA_tok(IT *w, long flen)
{
	noprg(w, w->title.t, false);
}

global
void open_object(char *fn, short fl, D_CFG *q) /* fl >= 100 is RAM, TOS, CARTR, DISK  etc */
{
	IT *w;
	DW *dw;
	char askdisk[MAXJ+1];

	*askdisk = 0;

	w = make_w(fn, fl, q);

	if (w eq nil)
		return;

	set_wordop(&w->cg);			/* 11'15 v8.3 */
	dw = w->dw;

	if (fl > 100 and fl < 200)
		switch(fl-100)
		{
		case MNDISK:
			w->ty += MNDISK;
			con_input(w, MNDISK, 0, frstr(P_DISK), nil, askdisk, disk, con_undo);
		esac
		case MNRAM:
			w->ty += MNRAM;
			con_input(w, MNRAM, 0, frstr(P_RAM), nil, nil, ram, con_undo);
		esac
		case MNCARTR:
			w->ty += MNCARTR;
			z org.i = 0xfa0000;
			w->dis.buffer = z org.b;
			z top.i = z org.i+0x20000;
			sprintf(w->title.t, " %s    (%s%lX - %s%lX)", frstr(CARTR), w->cg.r16, z org.i, w->cg.r16, z top.i-1);
			wi_title(w);
			z bot = z org;
			w->dis.lim = z top;
			if (setup(w))
			{
				send_msg_n("-= %s =-\n", frstr(CARTR));
				sprintf(w->dis.fo, "%lX", z org.i);
				strcpy(w->dis.fs, w->dis.fo);
				open_w(w);
			}
		esac
		case MNTOS:
			w->ty += MNTOS;
			z org.i = (long)sysbase->os_base;
			w->dis.buffer = z org.b;
			w->cf.offset = z org.i;
			getosparams(w, sysbase->os_base);		/* 151002 tos image in file */
			z top.i = z org.i+0x30000;
			if (os_version > 0x200)
				z top.i += 0x10000;
			if (os_version > 0x400)				/* 140401; TOS > 4 is 512Kb */
				z top.i += 0x40000;
			sprintf(w->title.t, " *** TOS %s ***    (%s%lX - %s%lX)", tos_id, w->cg.r16, z org.i, w->cg.r16, z top.i-1);
			wi_title(w);
			z bot = z org;
			w->dis.lim = z top;
			if (setup(w))
			{
				send_msg_n("-= %s =-\n", tos_id);
				strcpy(w->dis.fo, tos_id);
				strcpy(w->dis.fs, w->dis.fo);
				open_w(w);
				if (check_idx(w))
					load_idx(w, fx);
			}
		esac
		}
	else
	{
		bool tosimg = fl > 200;					/* 151002; Load a TOS img file. */
		long gfa = 0;
		long pl, u_pl, flen;
		DRI_H *dh;
		PC_H *ph;
		PCB buffer;

		if (tosimg)
			fl -= 200;

		split_fn(w, fn);

		Fread(fl, sizeof(FHD), &w->dis.kop);

		Fseek(0L, fl, 0);
		pl = Fseek(0L, fl, 2);
		Fseek(0L, fl, 0);
		u_pl = pl;
		dh = &w->dis.kop.drih;
		ph = &w->dis.kop.pch;

		if (dh->magic eq 0x601a and (dh->res1 > 0 /* or dh->res2 > 0 */) )
		{
			gfa = dh->ltext + dh->ldata;
			u_pl += gfa;				/* make room for dri type relocation */
		}

		if ( (buffer = MMalloc(u_pl + 1, "load file", AH_DIG_BUF, 0)) eq nil)
		{
			send_msg("%s\n", frstr(NLDMEM));
			Fclose(fl);
			via (w->close_file)(w, true);
		othw
			DW *dw = w->dw;

			if (cfg.sidf)		/* then .IDF is the last written */
				load_idf(w, w->dis.fo);

			if (check_idx(w))	/* The above is per def. the last one written */
				fcfg_idx(w, fx);

			z tosimg = tosimg or z tosimg ? true : false;		/* 151002 */
			w->dis.buffer = buffer;

			flen = Fread(fl, pl, w->dis.buffer);
			Fclose(fl);

			*(buffer+pl) = 0;
			w->map = buffer;
			w->dis.flen = flen;
			w->dis.lim.b = buffer+flen;

			if (strncmp(w->dis.buffer, "PPU3", 4) eq 0 and (Menu[MNPPU].state&CHECKED) ne 0)
			{
				MAX_dir ofn;
				strcpy(ofn, w->dis.fo);
				via (w->close_file)(w, true);
				fn = run_ppu2o(fn, ofn);
				if (fn ne nil)
					if ( (fl = Fopen(fn, 0)) >= 0)
						open_object(fn, fl, q);		/* !!! recursive call !!! */
					else
						not_found(fn);
				return;
			}
#if GST
			elif (dh->magic eq 0xfb01)	/* GST object */
			{
				gst_file(w, flen);
				noprg(w, fn, false);  /* normal no object file */
				w->cf.spg.i += z org.i;
				if (w->cg.sym)
					w->cg.sym = false, w->cg.lbl = true;
			}
#endif
			elif (ph->magic eq 0x4efa)	/* pure C format */
			{
				pc_file(w, flen);
				w->cf.spg.i += z org.i;
				set_menu(w);
				other_machine(w, false);
			}
			elif (dh->magic eq 0x601a)	/* DRI object ? */
			{
				dri_file(w, flen);
				w->cf.spg.i += z org.i;
				set_menu(w);
				other_machine(w, false);
			}
			elif (strncmp(w->dis.buffer+2, "GFA-BASIC3", 10) eq 0)
			{
				GFA_tok(w, flen);  /* GFA file */
				w->cf.spg.i += z org.i;
				if (w->cg.sym)
					w->cg.sym = false, w->cg.lbl = true;
			}
			else
			{
				noprg(w, fn, false);  /* normal no object file */
				w->cf.spg.i += z org.i;
				if (w->cg.sym)
					w->cg.sym = false, w->cg.lbl = true;
			}

			settabs(w);
		}
		/* no room */
	}
	/* file */

	z ty = w->ty;
}
