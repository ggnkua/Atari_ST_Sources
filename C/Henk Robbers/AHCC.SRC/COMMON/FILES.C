/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
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

/* 	FILES.C
 *	=======
 *
 *	This module concentrates ALL and ONly the open menu entries.
 */

#define TI2 1		/* Tile if 2 startfiles */

#include <string.h>

#include "aaaa_lib.h"
#include "hierarch.h"

#include "mallocs.h"
#include "aaaa.h"
#include "kit.h"
#include "cursor.h"
#include "hierarch.h"
#include "text/cursor.h"			/* for x_to_s_t */
#if TEXTFILE
#include "text/text.h"
#endif
#include "files.h"
#include "journal.h"

#if DIGGER
#include "digger/dig.h"
#include "digger/digobj.h"
#endif

#if BINARY
#include "bined/ed.h"
#endif

#if WKS
FOPEN open_sheet;
void cinf_upd(IT *w, CINF *ci);
#endif

#if MFRAC
#include "mandel/mandelbr.h"
#endif

#include "ahcm.h"

#ifdef TTPSHELL
#define frstr(a) a
char FNF[] = "File | '%s' |not found | %s";
char FNOP[] = "Cant create | '%s'";
char FNW[] = "Couldnt write to | '%s'";
#endif

global
char *argmake;			/* If a .prj is passed in argv */

global
void not_found(Cstr fn)
{
	alertm(frstr(FNF),fn);
}

global
bool write_out(IT *w, char *fn)
{
	FILE *oup=fopen(fn,"w");
	if (!oup)
	{
		alertm(frstr(FNOP), fn);
		return false;
	othw
		STMDEF *m=w->base;
		STMC *s;
		long wcnt;

		w->fl = oup->Handle;
		s = stmfifirst(m);
		while (s)
		{
			char tus[MAXL+3];	/* allow for \r\n */
			char *t=tus;
			char *u=s->xtx;
			short ll=0;

			while (*u) *t++=*u++,ll++;

#if INTERNAL
			{
				static short sll=1;
				if (ll ne s->xl and sll)
					sll=0,
					alertm("Internal error | inconsistent: | ll:%d, s->xl:%d ",ll,s->xl);
			}
#endif
			if (stmcur(*m) eq stmlast(*m))
			{
				if (!s->xl)
					break;
			}
			else
				*t++='\n',ll++;

			*t=0;

			wcnt=fwrite(tus,ll,1,oup);	/* fwrite adds itself the '\r' (PC, GEMDOS) */
			if (wcnt ne 1)
			{
				wcnt=-1;
				alertm(frstr(FNW), fn);
				break;
			}

			s=stmfinext(m);
		}
		fclose(oup);
		if (wcnt < 0)
			return false;
	}
	return true;
}

global
bool savemsgfile(IT *w)
{
	if (w)
	{
		char *fn = select_file(&idir, nil, &fsel, " Save journal as ... ", &drive);

		if (fn)
			write_out(w, fn);
		return true;
	}
	return false;
}

#ifdef TEXTFILE
global
void open_text_file(char *fn) /* open a given textfile if not already open */
{
	long fl;

	IT *w=get_fn_it(fn);		/* cached */
	if (w)
	{
		if (!w->op)
			open_text(fn,-1, &deskw.loc);
	}
	else
	if ( (fl=Fopen(fn, 0)) > 0)
	{
		open_text(fn, fl, &deskw.loc);
	othw
		open_text(fn, 0, &deskw.loc);
	}
}

static
void textfile(short mt)		/* open speficly via menu */
{
	MAX_dir suf;
	char *filename;
	short i=0;

	char *me = get_freestring(Menu, mt);

	while (*me and *me ne '.') me++;

	if (*me eq '.' and *(me+1) ne '.')
	{									/* one of the 'Open .x' entries */
		while (*me and *me ne ' ') suf[i++] = *me++;
		suf[i] = 0;
		idir = dir_plus_name(&idir, "*.*");		/* 08'13 HR */
		idir = change_suffix(&idir, suf);

		if (*fsel.s)
			fsel = change_suffix(&fsel, suf);
	}
#ifndef OPEN_ANY_IS_LAST
	else								/* Open ... */
		idir = change_suffix(&idir, ".*");
			/* dont change fsel */
#endif

	filename=select_file(&idir, nil, &fsel, " Open text file ", &drive);

	if (filename ne nil)
		open_text_file(filename);
}
#endif

#if BINARY
void open_DMA(void);
static
void binary_file(short mt)
{
	long fl;
	char *fn=select_file(&idir, nil, &fsel, " Open binary file ", &drive);

	if (fn ne nil)
	{
		if ( (fl=Fopen(fn,0)) > 0)
			open_binary(fn,fl, nil);
		else
			not_found(fn);
	}
}
#endif

#if MFRAC
void mandel_palet(void);

static
void mandel_file(short mt)
{
	long fl;
	char *fn=select_file(&idir, nil, &fsel, " Open mandelbrot file ", &drive);

	if (fn ne nil)
	{
		if ( (fl=Fopen(fn,0)) > 0)
			open_mandel(fn,fl,nil);
		else
			not_found(fn);
	}
}
#endif

global
void open_startfile(char *fn, short fl, short ty, F_CFG *q)
{
#if GEMSHELL
	argmake = nil;
	if (ty eq SRC_P or findsuf(fn,".prj") eq 'p')
	{
		argmake = fn;
		Fclose(fl);			/* 12'09 HR: loadmake uses stream IO */
	}
	else
#endif

#if DIGGER
	if (   (     ty > 0 and ty eq OBJ)
		or (     ty < 0
	#if (WKS or TEXTFILE or MFRAC or BINARY)
			and (  findsuf(fn,".o"  ) eq 'o'
				or findsuf(fn,".prg") eq 'p'
				or findsuf(fn,".tos") eq 't'
				or findsuf(fn,".ttp") eq 't'
				or findsuf(fn,".gtp") eq 'g'
				or findsuf(fn,".l"  ) eq 'l'
				or findsuf(fn,".lib") eq 'l'
				or findsuf(fn,".app") eq 'a'
				or findsuf(fn,".img") eq 'i'
				)
	#endif
			)
	   )
	{
		if (get_it(-1,JRNL) eq nil)
		{
			init_open_jrnl=true;
			init_jrnl(&ttd_msg, nil, ty > 0 ? 0 : 1);
		}
		open_object(fn, fl, (D_CFG *)q);
		init_open_jrnl=false;
	}
	else
#endif

#if WKS
	if (   (ty > 0 and ty >= TEXTM and ty < WKSM)
		or (ty < 0 and findsuf(fn,".cal") eq 'c')
	   )
	{
		Fclose(fl);
		open_sheet(fn,fl, nil),
		init_open_jrnl=false;
	}
	else
#endif

#if TEXTFILE
		open_text(fn, fl , q),
		init_open_jrnl=false
#elif MFRAC
		open_mandel(fn, fl, nil);
#elif BINARY
		open_binary(fn, fl, nil);
#endif
	;
}

#if TEXTFILE || BINARY || WKS
static
F_CFG  fcfg,
      *fcfg_base = nil;

CFGNEST floc_cfg;

static
OpEntry *floctab = nil;

static
OpEntry filtab[]=
{
	{"FILE= {\n",0,nil},			/* nil stops recursion, but must be written. */
	{"nam =%s\n",DIR_MAX,fcfg.name},
	{"typ =%d\n",6,&fcfg.ty},
	{"cul =%ld\n",13,&fcfg.cu.pos.y},
#if TEXTFILE || WKS
	{"cuf =%d\n",6,&fcfg.cu.pos.x},
	{"son =%d\n",6,&fcfg.selection},
	{"sel =%ld\n",6,&fcfg.se.pos.y},
	{"sef =%d\n",6,&fcfg.se.pos.x},
	{"sty =%d\n",6,&fcfg.sty},
#endif
#if TEXTFILE || BINARY
	{"LCFG= {}\n",0, floc_cfg,0,0},
#endif
	{"}      \n"},
	{"\0"}
};

global
CFGNEST file_cfg		/* FILE *fp, OpEntry **tab, short lvl, short io */
{
#if TEXTFILE || BINARY
	floctab = copyconfig(loctab, &cfg.loc, &fcfg.loc);
#endif

	if (io eq 1)		/* output */
	{
		STMC *ws;
		IT *w;
		ws=stmfilast(&winbase);

		while (ws)
		{
			w=ws->wit;
			if (is_file(w))
				if (w->op)
				{
					strcpy(fcfg.name, w->title.t);
					fcfg.ty = w->ty;
					fcfg.cu = w->selection ? w->ss : w->cu;
					fcfg.se = w->se;
					fcfg.sty = w->selty;
					fcfg.selection = w->selection;
#if TEXTFILE || BINARY
					fcfg.loc = w->loc;
#endif
#if BINARY
					fcfg.cu.pos.y = fcfg.cu.pos.y*w->bin.bw+fcfg.cu.pos.x;
#endif
					saveconfig(fp,filtab,lvl+1);
				}
			ws=stmfiprior(&winbase);
		}
	othw
		F_CFG *q = xmalloc(sizeof(F_CFG),AH_FCFG);
		if (q)
		{
			fcfg.loc = deskw.loc;		/* for defaults */
			loadconfig(fp,filtab,lvl+1);
			*q = fcfg;
			q->n = fcfg_base;
			fcfg_base = q;
		}
	}

#if TEXTFILE || BINARY
	xfree(floctab);
#endif
}

static
CFGNEST floc_cfg		/* FILE *fp, OpEntry **tab, short lvl, short io */
{
	if (io eq 1)		/* output */
		saveconfig(fp, floctab, lvl+1);
	else
		loadconfig(fp, floctab, lvl+1);
}

#if TI2
	short startfiles;
#endif

static
void load_fcfg(void)
{
	F_CFG *q = fcfg_base;

#if TI2
	startfiles = 0;
#endif

	while (q)
	{
		F_CFG *qn= q->n;
		char *fn = q->name;
		long fl;
		if (fn[strlen(fn)-1] eq '\n')
			fn[strlen(fn)-1] = 0;
		if (fn[strlen(fn)-1] eq '\r')
			fn[strlen(fn)-1] = 0;

		if ( (fl=Fopen(fn,0)) > 0)
		{
			IT *w;
			open_startfile(fn, fl, q->ty, q);

			w = get_fn_it(fn);
			if (w)
			{
#if TI2
				startfiles++;
#endif
				w->cu=q->cu;
#if TEXTFILE
				find_current_line(w);
#endif
#if BINARY
				l_to_s_t(w,w->cu.pos.y);	/* checks cu.l against w->mapl and divides by window width */
				w->loc = q->loc;
				change_font(w, w->loc.font);
				w->loctab = copyconfig(loctab, &fcfg.loc, &w->loc);
#elif TEXTFILE
				x_to_s_t(w,&w->cu);		/* checks cu.l against w->n */
				w->ss = w->cu;
				w->se = q->se;
				w->selection = q->selection;
				find_line(w,w->se.pos.y);
				x_to_s_t(w,&w->se);

				w->selty = q->sty;
				w->loc = q->loc;
				change_font(w, w->loc.font);
	#ifdef SCLIN
				flip_lnrs(w, w->loc.lnrs);
	#endif
				w->loctab = copyconfig(loctab, &fcfg.loc, &w->loc);
#elif WKS
				cinf_upd(w,&w->cu);
				cinf_upd(w,&w->cu);		/* checks cu.l against w->n */
				w->ss = w->cu;
				w->se = q->se;
				w->selection = q->selection;
				cinf_upd(w,&w->se);
				w->selty = q->sty;
#endif
				make_vis_cur(w);
			}
		}
		else
			alert_msg(" Not opened: | %s ",fn);

		free(q);
		q = qn;
	}

#if TI2				/* 05'16 HR: v5.4 */
	if (startfiles eq 2)
	{
		void do_Mode(IT *, short);
		IT *wt;
		wt = get_top_it();
		if (wt)
		{

#	if DEBUG
			STMC *ws;

			ws = stmfifirst(&winbase);

			while (ws)
			{
				IT *w = ws->wit;
				via (w->keybd)(w, NKF_FUNC | NK_HOME);
				ws = stmfinext(&winbase);
			}
#	endif
			do_Mode(wt, MNTILE);
		}
	}
# endif
}
#endif

global
void init_files(short argc, char *argv[])
{
	short i;
	long fl;
	char *fn,*ssuf,suf[6];
#if TMENU or WKS or BMENU
	load_fcfg();	/* load any files that were in the config */
#elif DIGGER
	load_dcfg();
#endif
	i=1;
	while (--argc)
	{
		DIRcpy(&idir, argv[i]);
		fn=argv[i];
		if ( (fl=Fopen(fn,0)) > 0)
		{
			open_startfile(fn, fl, -1, nil);	/* we know only the name */
		}
		else
			alert_msg(" Not opened: | %s ",fn);	/* jrnl not yet established */
		i++;
	}

#if defined INITOP and defined TEXTFILE
	if (*frstr(INITOP))
		if (w_handles(whs,is_text) eq 0)	/* altijd iets meteen open in testfase */
		{
			fn = frstr(INITOP);
			strcpy(idir.s,frstr(INITDIR));
			if ( (fl=Fopen(fn,0)) > 0)
			{
				open_text(fn,fl);
				init_open_jrnl=false;
			}
		}
#endif
	/* replace filename by "*" ; retain original suffix if there */

	ssuf=getsuf(idir.s);
	*suf=0;
	strcpy(suf,ssuf ? ssuf : "*");
	ssuf=strrslash(idir.s);
	if (ssuf)
		*(ssuf+1)=0,
		strcat(ssuf, "*.");
	else
		DIRcpy(&idir, "*.");
	DIRcat(&idir, suf);
}

#ifdef DIGGER
static
void objectfile(short mt)
{
	long fl;
	char *fn,suf[6];
	short i=0;
	char *me=get_freestring(Menu,mt);

	while (*me ne '.') me++;
	while (*me ne ' ') suf[i++]=*me++;
	suf[i]=0;
	idir = change_suffix(&idir,suf);
	if (*fsel.s)
		fsel = change_suffix(&fsel,suf);
	fn=select_file(&idir, nil, &fsel, " Open object file ", &drive);

	if (fn ne nil)
		if ( (fl=Fopen(fn,0)) > 0)
			open_object(fn,fl + (mt eq MNTOSIMG ? 200 : 0), nil);		/* 151002 TOS img file */
		else
			not_found(fn);
}
#endif

#ifdef WKS
static
void worksheet(short mt)
{
	char suf[6],*fn;
	short i=0;
	char *me=get_freestring(Menu,mt);

	while (*me ne '.') me++;
	while (*me ne ' ') suf[i++]=*me++;
	suf[i]=0;

	idir = dir_plus_name(&idir, "*.*");		/* 08'13 HR */
	idir = change_suffix(&idir,suf);

	if (*fsel.s)
		fsel = change_suffix(&fsel,suf);

	fn=select_file(&idir, nil, &fsel, " Open calc sheet ", &drive);

	if (fn)
		open_sheet(fn,0,nil);
}
#endif

#ifdef DIGGER
bool force_o;
#endif

#if HRD2ENUM
#endif

global
void do_Open(short mt)
{
	switch (mt)
	{
#ifdef DIGGER
	case MNO:
		force_o = true;
		objectfile(mt);
	break;
	case MNL:
	case MNPRG:
	case MNTTP:
	case MNAPP:
	case MNTOSIMG:
		force_o = false;
		objectfile(mt);
	break;
	case MNDISK:
	case MNRAM:
	case MNTOS:
	case MNCARTR:
		open_object(" -- ",mt+100,nil);
	break;
	case MNPPU:
		locate_ppu(mt);
	break;
#endif

#ifdef TEXTFILE
	#ifdef MNOPEN
	case MNOPEN:
	#endif
	#ifdef MNC
	case MNC:
	#endif
	#ifdef MNS
	case MNS:
	#endif
	#ifdef MNH
	case MNH:
	#endif
	#ifdef MNP
	case MNP:
	#endif
	#ifdef MNA
	case MNA:
	#endif
	#ifdef MNI
	case MNI:
	#endif
	#ifdef MNOL
	case MNOL:
	#endif
		textfile(mt);
	break;
#endif

#ifdef BINARY
	case MNOPENB:
		binary_file(mt);
	break;
#endif

#ifdef WKS
	case MNWKS:
		worksheet(mt);
	break;
#endif

#ifdef MFRAC
	case MNMO:
		mandel_file(mt);
	break;
	case MNMPAL:
		mandel_palet();
	break;
#endif

#ifdef MNITS
	case MNITS:
		show_its();
	break;
#endif
	}
}
