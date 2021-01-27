/*  Copyright (c) 1987 - 1991 by Han  Driesen Leiden.
 *            (c) 1996 - 2008 by Henk Robbers Amsterdam.
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

/*
 *	TTDKIT.C
 *
 */

#include <limits.h>
#include <string.h>

#include "common/aaaa_lib.h"
#include "aaaa.h"
#include "common/config.h"
#include "text/cursor.h"
#include "ttd_kit.h"
#include "ttd_cfg.h"
#include "common/journal.h"
#include "common/wdial.h"
#include "ttdisass.h"
#include "dig_it.h"

global
KIT_REFS pkit;		/* pointers to RSC structures */

void *subst_objects( OBJECT  *obs, bool menu );
void  subst_free   ( USERBLK *ublks );
extern M_S dmen;

global USERBLK *ubkit = nil;

static
CHARSET ch[] =
{
	{	/* Custom */
		"01111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111"
	},
	{	/* 95/Eng */
		"00000000" "00000000" "00000000" "00000000",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111110",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000"
	},
	{	/* Ger */
		"00000000" "00000000" "00000000" "00000000",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111110",
		"01001000" "01010010" "00001000" "01111010",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000"
	},
	{	/* Fra */
		"00000000" "00000000" "00000000" "00000000",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111110",
		"10110101" "10100100" "10010111" "00011000",
		"11110000" "00000000" "00001110" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000"
	},
	{	/* Lat */
		"00000000" "00000000" "00000000" "00000000",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111110",
		"10110101" "10101100" "10010111" "00011000",
		"11111100" "10000000" "11000011" "10000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000"
	},
	{	/* Scan */
		"00000000" "00000000" "00000000" "00000000",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111110",
		"01001010" "01010011" "00001000" "01111000",
		"00000000" "00000000" "00110000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000"
	},
	{	/* Math */
		"00000000" "00000000" "00000000" "00000000",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111110",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00011011" "00000000" "00000000",
		"00100000" "00000000" "00000000" "00000011",
		"11111111" "11111111" "11111111" "11111111"
	},
	{	/* All */
		"01111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111",
		"11111111" "11111111" "11111111" "11111111"
	},
	{	/* None */
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000",
		"00000000" "00000000" "00000000" "00000000"
	}
};

static
WINIT diskit_init
{
	OBJECT *ob = w->dial.ob;

	w->in.x = CHAR_BIT + w->v.x;
	w->in.y = wwa.y;
	w->in.w = ob[w->dial.item].w + w->v.w;
	w->in.h = ob[w->dial.item].h + w->v.h;
	w->frem = lower_right(w->in);
	snapwindow(w,&w->frem);
	w->in.w = ob[TKBLOK].w + 4*w->unit.w + w->v.w;
	w->in = lower_right(w->in);
	snapwindow(w,&w->in);
	ob->x = w->in.x - w->v.x;
	ob->y = w->in.y - w->v.y;
	objc_offset(ob,w->dial.item,&w->dial.ddx,&w->dial.ddy);
	w->dial.ddx-=ob->x;		/* distances from root to first to draw */
	w->dial.ddy-=ob->y;
}

global
void diskit_fresh(IT *w)
{
	wincfg_to_tree(&pkit, w ? &w->cg : &deskw.cg);
	wdial_draw(get_it(-1,TTD_KIT),TTDK1);
}

static
short obmn[] =
{
	KMC_CF, DMCF,
	KMC000, DM00,
	KMC020, DM20,
	KMC030, DM30,
	KMC040, DM40,
	KMC060, DM60,
	KMC851, DM51,
	KMC881, DM81,
	KOPC,	DMF1,
	KHASC,	DMF2,
	KOASC,	DMF3,
	KSTAND,	DMF4,
	KLBLS,	DMF5,
	KSYMS,	DMF6,
	KLBNL,	DMTNL,
	KXOOO,	DMOPOC,
	KDECI,	DMDEC,
	KUSYS,	DMUSYSV,
	KISYS,	DMISYSV,
	0, 0
};

void text_to_vis(KIT_REFS *k, TTD_PROF *w)
{
	short i;
	loop (i, 8)
		strncpy(w->svvis.v[i], k->vis[i], 32);
}

void vis_to_text(KIT_REFS *k, TTD_PROF *w)
{
	short i;
	loop(i, 8)
		strncpy(k->vis[i], w->svvis.v[i], 32);
}

static
short obno_to_menu(short obno)
{
	short i = 0;
	while (obmn[i])
		if (obmn[i] eq obno)
			return obmn[i+1];
		else
			i+=2;
	return 0;
}

static
void flip_mach(IT *w, short mt)
{
	opt_to_cfg(w->cg_tab, mt, OMENU, pkit.tree, dmen.m);
}

static
void mach_all_off(IT *w)
{
	if (w->cg.mccf) flip_mach(w, DMCF);
	if (w->cg.mc00) flip_mach(w, DM00);
	if (w->cg.mc20) flip_mach(w, DM20);
	if (w->cg.mc30) flip_mach(w, DM30);
	if (w->cg.mc40) flip_mach(w, DM40);
	if (w->cg.mc60) flip_mach(w, DM60);
}

#if 0
global
void set_wordop(TTD_PROF *w)
{
	if (strncmp(w->wordops,".w",2) eq 0)
		w->wordop=true;
	else
		w->wordop=false;
}
#else
/* 11'15 v8.3 deskw --> w->, better comparison */
global
void set_wordop(TTD_PROF *w)
{
	uchar c = *w->wordops;
	if (c eq 0 or c eq ' ')
		w->wordop=false;
	else
		w->wordop=true;
}
#endif
global
void do_mach(IT *w, short mt)
{
	if (mt)
	{
		bool mc20 = w->cg.mc20;

		if (mt <= DM60)
			mach_all_off(w);

		flip_mach(w, mt);

		w->dis.rescan=true;

		if (mt eq DM20 or mt eq DM51)
		{
			if (w->cg.mccf)
				flip_mach(w, DMCF);
			if (w->cg.mc00)
				flip_mach(w, DM00);
			if (w->cg.mc30)
				flip_mach(w, DM30);
			if (w->cg.mc40)
				flip_mach(w, DM40);
			if (w->cg.mc60)
				flip_mach(w, DM60);
			if (mt eq DM20 and mc20 and w->cg.mc51)	/* mc20 for old state !!! */
				flip_mach(w, DM51);
			if (mt eq DM51 and w->cg.mc20 eq 0)
				flip_mach(w, DM20);
		}
		elif (mt eq DMCF or mt eq DM00 or (mt >= DM30 and mt <= DM60))
		{
			if (w->cg.mc20) flip_mach(w, DM20);
			if (w->cg.mc51) flip_mach(w, DM51);
		}
		if (w->dw)
			other_machine(w,true);
	}
}

global
CHARSET * curr_cs(TTD_PROF *w)
{
	if (w->v95)   return &ch[1];
	if (w->vger)  return &ch[2];
	if (w->vfra)  return &ch[3];
	if (w->vlat)  return &ch[4];
	if (w->vsca)  return &ch[5];
	if (w->vmat)  return &ch[6];
	if (w->vall)  return &ch[7];
	if (w->vnon)  return &ch[8];
	return &w->cust;
}

/*		called via IT->wdial_do if EXIT condition is met */
static
DEXIT diskit_do		/* IT *w, short obno */
{
	IT *wo = w->dial.act_on;

	if (!wo)
		wo = &deskw;
	elif (!is_object(wo))
		wo = &deskw;

	switch(obno)
	{
	/* global options */
		case KPPUU:
		case KSIDF:
		case KASVE:
		case KJVOL:
		case KSIZER:
		case KVSLID:
		case KHSLID:
		case KPPUP:					/* txt */
		case KWIDTH:				/* txt */
		case KHEIGHT:				/* txt */
			tree_to_cfg(&pkit, &cfg);
		esac

	/* local options */
		case KT0:				/* txts */
		case KT1:
		case KT2:
		case KT3:
		case KT4:
		case KB0:
		case KB1:
		case KB2:
		case KB3:
		case KB4:
		 	tree_to_wincfg(&pkit, &wo->cg);
		esac

		case KUSYS:
			opt_to_cfg(wo->cg_tab, obno_to_menu(obno), OMENU, pkit.tree, dmen.m);
			page(wo);
		esac

		/* machines */
		case KMC_CF:
		case KMC000:
		case KMC020:
		case KMC030:
		case KMC040:
		case KMC060:
		case KMC851:
		case KMC881:
			do_mach(wo, obno_to_menu(obno));
		esac

		/* representation */
		case KOPC:
		case KHASC:
		case KOASC:
			opt(wo, obno_to_menu(obno), true);
		esac
		case KSTAND:
		case KLBLS:
		case KSYMS:
			l_opt(wo, obno_to_menu(obno), true);
		esac

		case KLBNL:
		case KXOOO:
		case KDECI:
		case KISYS:
			opt_to_cfg(wo->cg_tab, obno_to_menu(obno), OMENU, pkit.tree, dmen.m);
			set_menu(wo);
			if (wo->dw)
				settabs(wo);
			page(wo);
		esac
		/* simple options that only need redraw */
		case KDBLF:
		case KDIRW:
		case KWABX:
			opt_to_cfg(wo->cg_tab, obno_to_menu(obno), OMENU, pkit.tree, dmen.m);
			page(wo);
		esac

		case KWORD:
			send_msg_n("KWORD\n");
			tree_to_wincfg(&pkit, &wo->cg);
			set_wordop(&wo->cg);
			page(wo);
		esac

		/* special feature */
		/* character visibility */
		case KVCUST:
			tree_to_wincfg(&pkit, &wo->cg);
			trans_vis(&wo->cg, &wo->cg.cust);
			vis_to_text(&pkit, &wo->cg);
			wdial_draw(w, KVIS);
			page(wo);
		esac
		case KV95:
		case KVGER:
		case KVFRA:
		case KVSCAN:
		case KVLAT:
		case KVMATH:
		case KVALL:
		case KVNONE:
			tree_to_wincfg(&pkit, &wo->cg);
			trans_vis(&wo->cg, &ch[obno - KVCUST]);
			vis_to_text(&pkit, &wo->cg);
			wdial_draw(w, KVIS);
			page(wo);
		esac
		case KVIST:				/* txt */
			tree_to_wincfg(&pkit, &wo->cg);
			trans_vis(&wo->cg, curr_cs(&wo->cg));
			vis_to_text(&pkit, &wo->cg);
			wdial_draw(w, KVIS);
			page(wo);
		esac
		case VIS0:				/* string */
			if (w->dial.cx eq 0)
				break;			/* /0 can never be shown :-) */
		case VIS1:				/* string */
		case VIS2:				/* string */
		case VIS3:				/* string */
		case VIS4:				/* string */
		case VIS5:				/* string */
		case VIS6:				/* string */
		case VIS7:				/* string */
		if (wo->cg.vcustom)
		{
			short i = obno - VIS0;
			char *cs = wo->cg.cust.v[i];
			tree_to_wincfg(&pkit, &wo->cg);
			cs[w->dial.cx] ^= 1;
			trans_vis(&wo->cg, &wo->cg.cust);
			vis_to_text(&pkit, &wo->cg);
			wdial_draw(w, KVIS);
			page(wo);
		}
		esac
		case KTODEF:
			if (wo ne &deskw)
				tree_to_wincfg(&pkit, &deskw.cg);

			wdial_change(w, true, KTODEF, KTODEF, -1, 0, ~SELECTED, 0);
		esac
		case KTOCUST:
			if (!wo->cg.vcustom)
				wo->cg.cust = *curr_cs(&wo->cg);

			wdial_change(w, true, KTOCUST, KTOCUST, -1, 0, ~SELECTED, 0);
		esac

		/* all text fields that are never in a menu */
		default:
			tree_to_wincfg(&pkit, &wo->cg);
			page(wo);
	}
}

global
void invoke_ttdkit(void)
{
	rsrc_gaddr(0, TTD_KIT, &pkit.tree);
	ubkit = subst_objects(pkit.tree,false);

	create_dialw(" Configure ", TTD_KIT, pkit.tree, TTDK1, diskit_init, diskit_fresh, diskit_do);
}

global
void end_ttdkit(void)
{
	subst_free(ubkit);
}
