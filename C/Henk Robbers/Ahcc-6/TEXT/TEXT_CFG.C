/* Copyright (c) 1990 - present by H. Robbers Amsterdam.
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

/* 	TEXTCFG.C
 *	=========
 */

#include <string.h>
#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#include "aaaa.h"
#include "common/kit.h"
#include "text.h"
#include "text_cfg.h"
#include "cursor.h"
#ifdef GEMSHELL
#include "shell/shell.h"
#endif
#include "common/wdial.h"

VpV bgld;

/* item & KIT only for buttons */
global
OpEntry loctab[]=
{
	{"LCFG= {\n",0,nil},			/* nil stops recursion */
#ifdef SCVISTAB
	{"vit =%d\n",6,&cfg.loc.vistab, 0,0},
	{"vic =%d\n",6,&cfg.loc.vistco, 0,0},
#endif
#ifdef SCTABNEW
	{"atab=%d\n",6,&cfg.loc.tabn,   0,0},
	{"ptab=%d\n",6,&cfg.loc.tabp,   0,0},
	{"ltab=%d\n",6,&cfg.loc.tabl,   SCTABLEAD,KIT},
#endif
#ifdef SCTABS
	{"tab =%d\n",6,&cfg.loc.tabs,   0,0},
#endif
#ifdef SCSPLIT
	{"spl =%d\n",6,&cfg.loc.split,  0,0},
#endif
#ifdef SCAUTOI
	{"aui =%d\n",6,&cfg.loc.ai,     SCAUTOI,KIT},
#endif
#ifdef SCBOLD
	{"bol =%d\n",6,&cfg.loc.boldtag,SCBOLD,KIT},
#endif
#ifdef SCLIN
	{"lnr =%d\n",6,&cfg.loc.lnrs,   SCLIN, KIT},
#endif
#ifdef SCTRAIL
	{"tra =%d\n",6,&cfg.loc.trail,  SCTRAIL,KIT},
#endif
#ifdef SCFONT
	{"sma =%d\n",6,&cfg.loc.font,   SCFONT,KIT},
#endif
#ifdef SCV
	{"svm =%d\n",6,&cfg.loc.scv.m1,     SCV, KIT},
	{"sva =%d\n",6,&cfg.loc.scv.arrow,  0, 0},
	{"svt =%d\n",6,&cfg.loc.scv.grtel,  0, 0},
	{"svn =%d\n",6,&cfg.loc.scv.grnoem, 0, 0},
#endif
#ifdef SCH
	{"shm =%d\n",6,&cfg.loc.sch.m1,     SCH, KIT},
	{"sha =%d\n",6,&cfg.loc.sch.arrow,  0, 0},
	{"sht =%d\n",6,&cfg.loc.sch.grtel,  0, 0},
	{"shn =%d\n",6,&cfg.loc.sch.grnoem, 0, 0},
#endif
	{"}      \n"},
	{"\0"}
};

global
CFG_LOCAL txt_local(void)
{
	extern CFG_LOCAL def_loc;
	return def_loc;
}

static
void tree_to_wincfg(KIT_REFS *k, CFG_LOCAL *w)
{
	/* buttons */

#if TEXTEDIT
	FBUT(ai, SCAUTOI);
	FBUT(tabl, SCTABLEAD);
#endif

#ifdef SCBOLD
	FBUT(boldtag, SCBOLD);
#endif

#ifdef SCLIN
	FBUT(lnrs, SCLIN);
#endif

#ifdef SCFONT
	FBUT(font, SCFONT);
#endif

#ifdef SCTRAIL
	FBUT(trail, SCTRAIL);
#endif

#ifdef SCH
	FBUT(sch.m1, SCH);
#endif

#ifdef SCV
	FBUT(scv.m1, SCV);
#endif

#ifdef COLIB
	FBUT(lib_str, COLIB);
#endif

	/* text fields */

	FCDBV(tabn);
	FCDBV(tabs);
	FCDBV(tabp);
	F2CDBV(sch.arrow,  harr);
	F2CDBV(sch.grtel,  hgrt);
	F2CDBV(sch.grnoem, hgrn);
	F2CDBV(scv.arrow,  varr);
	F2CDBV(scv.grtel,  vgrt);
	F2CDBV(scv.grnoem, vgrn);
#ifdef SCSPLIT
 	FCDBV(split);
	if (w->split <= 0 or w->split > MAXL)
		w->split  = MAXL;
#endif
	w->vistab	  = * k->scvist->text;
	w->vistco     = *(k->scvist->text+1);
}

static
bool any_loc(CFG_LOCAL *o, CFG_LOCAL *n)
{
	return
	   (   o->tabs     ne n->tabs
	    or o->tabn     ne n->tabn
	    or o->tabp     ne n->tabp
#ifdef SCSPLIT
	    or o->split    ne n->split
#endif
		or o->vistab   ne n->vistab
		or o->vistco   ne n->vistco
		or o->boldtag  ne n->boldtag
		or o->font     ne n->font
		or o->trail    ne n->trail
#ifdef SCLIN
		or o->lnrs     ne n->lnrs
#endif
	   );
}

global
void init_txtcfg(KIT_REFS *k)
{
#ifdef SCFONT
	if (half_h() ne hchar or hchar < 16)
	{
		change_font(&deskw, deskw.loc.font);
	othw
		k->tree[SCFONT].flags |= HIDETREE;
		keusaf(k->tree[SCFONT]);
	}
#endif
	/* text fields */

	FTED(scvist, SCVISTAB);
	FTED(tabn,   SCTABNEW);
	FTED(tabp,   SCTABPHYS);
	FTED(tabs,   SCTABS);
#ifdef TEXTEDIT
	FTED(split,  SCSPLIT);
#endif
	FTED(harr,   SCHARR);
	FTED(hgrt,   SCHGRT);
	FTED(hgrn,   SCHGRN);
	FTED(varr,   SCVARR);
	FTED(vgrt,   SCVGRT);
	FTED(vgrn,   SCVGRN);
#ifdef CORN
	FTED(rootname,CORN);
#endif
#ifdef LOADS
	FTED(loads,  LOADS);
#endif
#ifdef MAKES
	FTED(makes,  MAKES);
#endif
	tree_to_wincfg(k, &deskw.loc);
}

static
void wincfg_to_tree(KIT_REFS *k, CFG_LOCAL *w)		/* IT --> dialogue */
{
	/* buttons */

#ifdef TEXTEDIT
	FSTATE(ai,SCAUTOI);
	FSTATE(tabl,SCTABLEAD);
#endif

#ifdef SCBOLD
	FSTATE(boldtag,SCBOLD);
#endif

#ifdef SCLIN
	FSTATE(lnrs,SCLIN);
#endif

#ifdef SCFONT
	FSTATE(font,SCFONT);
#endif

#ifdef SCTRAIL
	FSTATE(trail,SCTRAIL);
#endif

#ifdef SCH
	FSTATE(sch.m1,SCH);
#endif

#ifdef SCV
	FSTATE(scv.m1,SCV);
#endif

	/* text fields */
	FBIN(tabn);
	FBIN(tabs);
	FBIN(tabp);
	F2BIN(harr,sch.arrow);
	F2BIN(hgrt,sch.grtel);
	F2BIN(hgrn,sch.grnoem);
	F2BIN(varr,scv.arrow);
	F2BIN(vgrt,scv.grtel);
	F2BIN(vgrn,scv.grnoem);
#ifdef SCSPLIT
	FBIN(split);
#endif
	* k->scvist->text   = w->vistab;
	*(k->scvist->text+1)= w->vistco;
}

global
void do_txtcfg(IT *wo)
{
	CFG_LOCAL o;

	if (!wo)
		wo = &deskw;
	o = wo->loc;

	tree_to_wincfg(&pkit, &wo->loc);

	if (wo ne &deskw)
	{
		if (any_loc(&o, &wo->loc))
		{
			if (o.font  ne wo->loc.font)
				change_font(wo, wo->loc.font);
#ifdef SCLIN
			if (o.lnrs ne wo->loc.lnrs)
				flip_lnrs(wo, wo->loc.lnrs);
#endif
			x_to_s_t(wo,&wo->ss);
			x_to_s_t(wo,&wo->se);
			x_to_s_t(wo,&wo->cu);
			cur_off(wo);
			do_redraw(wo,wo->wa);
		}
	}
}

global
void change_txtkit(KIT_REFS *k, IT *w, IT *wd)
{
	wincfg_to_tree(k, w ? &w->loc : &deskw.loc);
	wdial_draw(wd, DSCBLOK);
}

global
void txtkit_fresh(IT *w)	/* w is source data (text window) */
{
	wincfg_to_tree(&pkit, w ? &w->loc : &deskw.loc);
	wdial_draw(get_it(-1,KIT),DSCBLOK);
}

#if 0
#define CC copyconfig
#else
global
OpEntry *CC(OpEntry *tab, void *old, void *new)
{
	short l = 1;
	OpEntry *newtab, *this = tab;

	while(this->s.str[0]) l++, this++;		/* count entries */

	l *= sizeof(OpEntry);
	newtab = mmalloc(l, "while opening", "not opened", 1000);
	if (newtab)
	{
		memcpy(newtab, tab, l);
		changeconfig(newtab, old, new);
	}

	return newtab;
}
#endif

global
bool load_txtconfig(void)
{
	KIT_REFS *k = &pkit;
	FILE *fp;
	deskw.loctab = CC(loctab, &cfg.loc, &deskw.loc);
	setfn = dir_plus_name(&ipath, cfgname());
	fp = fopen(setfn.s,"r");
	if (fp)
	{
		loadconfig(fp,settab,0);		/* ---> cfg */
		fclose(fp);
		change_font(&deskw, cfg.loc.font);
	#ifdef MNMULT
		s_to_xstr(k->tree, DSMULSTR, DSMULXTR, k->muldir.s);
	#endif

	#ifdef MNFCOMP
		s_to_xstr(k->tree, DSCPF1STR, DSCPF1XTR, k->cp1dir.s);
		s_to_xstr(k->tree, DSCPF2STR, DSCPF2XTR, k->cp2dir.s);
	#endif

	#ifdef GEMSHELL
		cfg_to_rsc();
	#endif

		wincfg_to_tree(k, &deskw.loc);	/* prepare tree from config table */
		options(settab, OSET);			/* put options in tree */
		options(deskw.loctab, OSET);
		tree_to_wincfg(k, &deskw.loc);	/* now get options that are per window */

	#ifdef DFB1
		set_find();
	#endif
		return true;
	othw
		options(settab, OSET);	/* if no config file */
		options(deskw.loctab, OSET);
		return false;
	}
}

global
bool save_txtconfig(void)		/* called in eruit() */
{
	KIT_REFS *k = &pkit;
	FILE *fp;

#ifdef MNMULT
	get_mulstr(&k->muldir);
#endif
#ifdef MNFCOMP
	get_cpfstr(&k->cp1dir, &k->cp2dir);
#endif
#ifdef GEMSHELL
	rsc_to_cfg();
#endif

	wincfg_to_tree(k, &deskw.loc);		/* first put options that are per window */
	options(settab, OGET);				/* get them in cfg for output */
	options(deskw.loctab, OGET);
	tree_to_wincfg(k, &deskw.loc);

	fp = fopen(setfn.s,"w");
	if (fp ne nil)
	{
#ifdef JOURNAL
		extern RECT jrect;
		jrect = get_it(-1,JRNL)->rem;
#endif
		saveconfig(fp,settab,0);
		fclose(fp);
		return true;
	}
	return false;
}

global
CFGNEST loc_cfg		/* FILE *fp, OpEntry **tab, short lvl, short io */
{
	if (io eq 1)		/* output */
		saveconfig(fp, deskw.loctab, lvl+1);
	else
		loadconfig(fp, deskw.loctab, lvl+1);
}
