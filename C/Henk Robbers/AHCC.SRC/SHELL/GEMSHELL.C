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

/*
 *	GEMSHELL.C
 *  ==========
 */

#include <stdlib.h>				/* for free() */
#include <ctype.h>
#include <ext.h>

#include "common/mallocs.h"
#include "common/aaaa_lib.h"
#include "common/hierarch.h"
#include "common/pdb.h"

#include "aaaa.h"
#include "common/kit.h"
#include "text/text.h"
#include "text/text_cfg.h"
#include "shlcfg.h"
#include "sheldefs.h"
#include "shell.h"
#include "common/journal.h"
#include "common/ipff.h"
#include "common/hierarch.h"
#include "ahcc/peepstat.h"
#include "common/treeview.h"
#include "common/files.h"

externOBJECT *Menu;

/* If the program is started with an argument
	we want start with that file,
	not with the initial journal message,
	so this bool is defined by FILES.C */
externbool init_open_jrnl;
externOpEntry shel_tab[];

void dial_b2(void);
void free_cache(void);

static
S_path mksel={""};

global
COPRMSG shell_msg=
/*            1         2         3         4         5         6         7
     123456789012345678901234567890123456789012345678901234567890123456789012		*/
{
#if FOR_A || LL
	PRGNAME " v6 (c) 2017 by H. Robbers A'dam.",
#else
	"            " PRGNAME " v5.6 = Sozobon ANSI C",
	"ANSI and GEM integration: (c) 2014 by H. Robbers A'dam.",
    "            Using Harald Siegmunds NKCC.",
#endif
	"-------------------------------------------------------",
	"",
 	nil
};

global
void do_Scopyright(void)
{
	do_init_text(nil, nil, shell_msg);
	send_msg("\n");
}

bool check_modified(char *fn);

global
void menu_prj(char *pn)
{
	char *mnd = Menu[MTPRJ].spec.free_string;
	MAX_dir fn;
	if (pn)
		strcpy(fn, pn);
	else
		strcpy(fn, "Project");
	fn[menu_prj_l - 1] = 0;
	strcpy(mnd + 1, fn);
	menu_bar(Menu, true);
}

#if JOURNAL
extern
char *Found ,
     *Scanning;

extern
char fkey[];
extern
short skl,fls,fds;
externIT *jrnlwin;

global
void find_project(void)
{
	if (auto_dependencies)
	{
		short i;
		DPP ft;
		jrnlwin = get_it(-1,JRNL);

		fls=0, fds=0;
		strcpy(fkey, get_fistr(0));
		skl = strlen(fkey);
		if (skl)
		{
			if (!cfg.o.csens)
				loop(i,skl)
					fkey[i]=tolower(fkey[i]);

			qpfind_prepare(skl, (uchar *)fkey);

			send_msg("Looking for '%s' in project %s\n",
						get_fistr(0),
						radio_c(&cfg.o)
					);

			ft = auto_dependencies;
			while (ft)
			{
				if (scan_file(ft->data->name))
					break;

				ft = ft->dnext;
			}

			send_msg("%d in %d file%s\n",fds,fls,pluralis(fls));
		}
		else
			send_msg("find empty string\n");
	}
	else
		send_msg("Project help not active\n\tor no database (.ADB) file present\n");
}
#endif

static
DOSTIME tostime(void)	/* tbv touch.
						 * Dit alles allen maar om datum en tijd om te
						 * draaien! terwijl pv310c's Gettime het spul in de
						 * goede volgorde levert.
						 * NL de datum voorop.
						 * Eenmaal goed bedacht, worden de dingen wegens
						 * domheid van ijverige software makers weer
						 * verpest, zodat luie gebruikers onnodig toch hard
						 * moeten werken en het risico lopen alsnog voor lui
						 * gehouden te worden.
						 */
{
	union
	{	long l;
		struct
		{
			unsigned short
				date,
				time;
		} kbdt;
	} tost;

	DOSTIME t;

	tost.l=Gettime();
	(unsigned)t.date=tost.kbdt.date;
	(unsigned)t.time=tost.kbdt.time;
	return t;
}

#ifdef MTLUA
static
void do_Lua(short mt)
{
	#if BIP_LUA
	if (mt eq MNLUARUN)
		LUA_main();		/* Dummy, get it linked in */
	#endif
}
#endif


global
void pdb_mark(DPP dp, short mark, short fu)
{
	while (dp)
	{
		if (!fu)
			dp->data->flags = 0;
		elif (fu eq 1)
			dp->data->flags |=  mark;
		elif (fu eq 2)
			dp->data->flags &= ~mark;
		/* else no change, only wasting time :-> */
		pdb_mark(dp->depend, mark, fu);
		dp = dp->dnext;
	}
}

#ifdef TREEWIN
static
void dp_expand(IT *w)
{
	NSP np = w->trv.root->d;
	while(np)
	{
		w->trv.sel = np;
		via (w->select)(w);

		np = np->n;
	}
}

static
MENU_DO do_Dmenu	/* IT *w, ...... */
{
	if (title eq MTDP)
	{
		wmenu_tnormal(w,title,true);	/* the below open a window */
		switch (choice)
		{
		case DPEXPAND:
			dp_expand(w);
		break;;
		case DPOPEN:
			if (trv_find_sel(w->trv.root))
				open_text_file(w->trv.txt);
		break;;
		}
	}
	return true;
}

static
void dp_add(IT *w, NSP np)
{
	char *fn;
	DPP dp;
	short subs = 0;
	fn = w->trv.txt;
	strcpy(fn,np->trv_txt);
	dp = pdb_find(w->trv.dp, fn);
	if (dp)
	{
		dp = dp->depend;
		while (dp)
		{
			NSP new = trv_new_nest(dp->data->name);
			if (new)
			{
				DPP ddp = pdb_find(w->trv.dp, dp->data->name);
				if (ddp)
					new->f = ddp->depend ? NEST : TERM;
				trv_add_nest(np, new, 0);
				subs++;
			}

			dp = dp->dnext;
		}
	}

	if (subs)			/* subsidiaries found */
		trv_spacer(np);

	np->subs = subs;
}

SELECT dp_select;
globalM_S dmen={false,0,0,0,0,0,0,0,nil,nil};
typedef short DP_REC(IT *w, DPP this, NSP to, short flag, short lvl);
DP_REC dp_file, dp_files;  			/* recursion */

static
DP_REC dp_file	/* IT *w, DPP this, NSP to, short flag, short lvl */
{
	if (!this)	return 0;
	else
	{
		DPP dpd = nil, fd;
		short lines = 0;
		NSP new = to;
		Cstr name = this->data->name;
		bool have = flag eq 0 or (this->data->flags & flag) ne 0;

		fd = pdb_find(w->trv.dp, name);

		if (fd)
			dpd = fd->depend;

		if (have)
		{
			new = trv_new_nest(name);		/* create(allocate) only */
			if (new)
			{
				if (dpd eq nil)
					new->f = TERM;
				else
					new->dep = lvl+1;
				trv_add_nest(to, new, 0);	/* add to tree */
			}

			lines++;
		}

		trv_adjust(w, w->trv.root);

		if (dpd and have and new)
		{
			if (fd->data->flags & TRV_DO)
			{
				fd->data->flags &= ~TRV_DO;				/* Done */
				lines += dp_files(w, dpd, new, 0, lvl+1);
				trv_spacer(new);
				lines++;
			}
		}

		return lines;
	}
}

static
DP_REC dp_files		/* IT *w, DPP this, NSP to, short flag, short lvl */
{
	short lines = 0;

	while (this)
	{
		lines += dp_file(w, this, to, flag, lvl);
		this = this->dnext;
	}

	return lines;
}

static
void dp_init(IT *w)
{
	short lines = 1;

	w->trv.root = trv_new_nest(w->trv.prj);
	pdb_mark(w->trv.dp, TRV_DO, 1);				/* set TRV_DO for all */
	lines += dp_files(w, w->trv.dp, w->trv.root, TRV_IN, 0);

	if (w->in.w eq 0)
	{
		w->in.x = (wwa.w-(w->norm.sz.w*wchar+w->v.w)-wchar);		/* right upper */
		w->in.y = wwa.y+hchar;
		w->in.w = w->norm.sz.w*wchar+w->v.w;
		w->in.h = (lines)*hchar+w->v.h;
	}
	w->in = fit_inside(w->in,wwa);
	trv_adjust(w, w->trv.dp);

}

static
DRAW dp_draw
{
	short y = w->wa.y;

	w->trv.y = y;

	trv_draw(w, w->trv.root);
	y = w->trv.y;
	if (y < w->wa.y+w->wa.h)
		gpbox(w->hl,w->wa.x,y,w->wa.w,w->wa.y+w->wa.h-y);
}

static
NSP dp_set_new(IT *w, NSP np, char *nm)
{
	if (np and np->f ne EMP)
	{
		if (nm)
			strcpy(nm, np->trv_txt);
		trv_deselect(w, w->trv.root);
		np->state |= SELECTED;
		get_work(w);
		w->norm.pos.y  = bounce(w,w->norm.pos.y);
		do_redraw(w, w->wa);
	}
	return np;
}

static
SELECT dp_select
{
	char *fn = w->trv.txt;
	NSP np = w->trv.sel;
	if (np and np->dep > 0)
	{
		if (np->d)
			trv_del_nest(np);
		elif (np->f eq NEST)
			dp_add(w, np);
		else
			strcpy(fn, np->trv_txt);
	}

	dp_set_new(w, np, nil);

	if (np->f eq NEST)
		trv_adjust(w, np);

	w->trv.cur = np;
}

static
CLOSED dp_close
{
	trv_del_nest(w->trv.root);
	close_w(w);
	stmdelcur(&winbase);
}

static
KEYBD dp_keybd
{
	short ks = kcode,
		  kb = ks&0xff;
	NSP cur = w->trv.cur;
	char *fn = w->trv.txt;

	if (ks&NKF_FUNC)
		switch(kb)
		{
			case NK_UP:
				do
					cur = dp_set_new(w,trv_find_ln(w->trv.root, cur ? cur->ln-1 : 2),fn);
				while (cur and cur->f eq EMP);
			break;
			case NK_DOWN:
				do
					cur = dp_set_new(w,trv_find_ln(w->trv.root, cur ? cur->ln+1 : 2),fn);
				while (cur and cur->f eq EMP);
			break;
			case NK_LEFT:
				if (cur and cur->o)
					cur = dp_set_new(w,cur->o,fn);
			break;
			case NK_RIGHT:
				if (cur)
					if (cur->o and cur->o->n)
						cur = dp_set_new(w,cur->o->n,fn);
					else
						cur = dp_set_new(w,cur->n,fn);
			break;
			case NK_INS:
			case NK_UNDO:
				w->trv.sel = cur;
				via (w->select)(w);
			break;
		}
		w->trv.cur = cur;
}

WICON trv_icon;

global
VpV dp_end
{
	short i = 0;
	IT * w = get_it(-1, TRVDEP);
	while(w)
	{
		i++;
		via(w->closed)(w);
		w = get_it(-1, TRVDEP);
	}
}

static
IT * dp_tree(struct dep *root, Cstr name, Cstr pname)
{
	IT *w = nil;
	if (root)
	{
		w = treeview_window
			(
				name,
				root,
				pname,
				dp_init,
				dp_draw,
				dp_select,
				dp_close,
				dp_keybd,
				nil,
				nil,nil, /* do_Dmenu, &dmen, */
				TRVDEP
			);

		if (w)
			open_w(w);
	}
	return w;
}
#endif

#ifdef MTPRJ
global
bool do_shell(short mn, short mt)
{
	void open_text_file(char *fn);

	switch(mn)
	{
#ifdef MTPRJS
		case MTPRJS:
		switch(mt)
		{
			case MNLMAKE:
			{
				char *f;
				S_path dir;
				DIRcpy(&dir, mkpad.s);

				DIRcat(&dir, (MagX or MiNT) ? "*.prj" : "*.PRJ");		/* 05'12 HR V4.12 */
				f = select_file(&dir, &mkpad, &mksel, "find project:", &drive);
#ifdef DMENU
				if (f)
				{
					/* if treeviews, delete treeviews; */
					dp_end();
					loadmake(f, 0);
					/* if was treeview, reopen
					if (tree)
						dp_reopen(f);
					*/
				}
#else
				if (f)
					loadmake(f, 0);
#endif
			}
			break;
#ifdef MNDMAKE
			case MNDMAKE:
			#if BIP_CC
				if (auto_dependencies)
					pdb_write_dep();
			#endif

				remove_project();
				zero(root_project);
			#ifdef GEMSHELL
				menu_prj(nil);
			#endif
			break;
#endif

#ifdef MNLFOLD				/* 05'16 HR: v5.4 */
			case MNLFOLD:
			{
				char *fro, *to;
				FILE *fto = nil;
				bool makefrfold(char *, FILE *);
				fro = select_file(&idir, nil, &fdum, "find folder:", &drive);
				if (fro)
				{
					S_path ln = {"exc_name"}, lf;
					
					HI_NAME *hn = hn_make(fro, nil, 4);
					if (hn) if (hn->last)
					{
						strcpy(ln.s, hn->last->n);
						strcat(ln.s, ".prk");
						strcpy(lf.s, hn->last->n);
						strcat(lf.s, ".app");
					}

					to = select_file(&idir, nil, &ln, "save to:", &drive);
					if (to)
					{
						fto = fopen(to, "w");

						if (fto)
						{
							fprintf(fto, "%s\n\n.C [-2 -8]\n.S []\n.L [-S=8192]\n=\n", lf.s);
							fprintf(fto, "ahcstart.o\n\n");
							makefrfold(idir.s, fto);
							fprintf(fto, "\n");
							fprintf(fto, "ahccstd.lib\n");
							fprintf(fto, "ahccgem.lib\n");
							fclose(fto);
							open_text_file(to);
						othw
							alertm(frstr(FNOP), to);
						}
					}
				}
			}
			break;
#endif
		}
		menu_tnormal(Menu, MTPRJS, true);
		break;;
#endif
		case MTPRJ:
		switch(mt)
		{
			case MNCOOPT:
				kit_dial(nil, 0, MNCOOPT);
			break;
#ifdef MNPROJ
			case MNPROJ:
				kit_dial(nil, 0, MNPROJ);
			break;
#endif
#ifdef MNDOWN
			case MNDOWN:
				clear_help_stack();
			break;
#endif
#ifndef MTPRJS
			case MNLMAKE:
			{
				char *f;
				S_path dir;
				DIRcpy(&dir, mkpad.s);
				DIRcat(&dir, "*.prj");
				f = select_file(&dir, &mkpad, &mksel, "find project:", &drive);
				if (f)
					loadmake(f, 0);
			}
			break;
#endif
#ifdef MNDMAKE
			case MNDMAKE:
			#if BIP_CC
				if (auto_dependencies)
					pdb_write_dep();
			#endif

				remove_project();
				zero(root_project);
			#ifdef GEMSHELL
				menu_prj(nil);
			#endif
			break;
#endif
			case MNEDPRJ:
				if (*mkfn.s)
					open_text_file(mkfn.s);
			break;
			case MNRELOAD:
				if (*mkfn.s)
					loadmake(mkfn.s, 0);
			break;
#ifdef MNPRJD
			case MNPRJD:
				if (auto_dependencies or prj_dependencies)
	#if TREEWIN
					dp_tree(auto_dependencies, "auto dependencies", mkfn.s);
	#else
				{
					send_msg("No treeview with " PRGNAME "\n");
					send_msg("\nPRJ dependencies:\n");
					pdb_list(stdout, prj_dependencies, 0);
					send_msg("end of list\n\n");
					send_msg("\nAuto dependencies:\n");
					pdb_list(stdout, auto_dependencies, 0);
					send_msg("end of list\n\n");
				}
	#endif
				else
					send_msg("no dependency information\n");
			break;
#endif
#ifdef MNPRJT
			case MNPRJT:
				if (fun_dependencies)
				{
					Cstr rnm = get_rootname();
					DPP start = pdb_find(fun_dependencies, rnm);
					if (start)
					{
						start->data->flags |= TRV_IN;
						dp_tree(fun_dependencies, "function call tree", mkfn.s);
					}
					else
						send_msg("root function '%s' not present\n", rnm);
				}
				else
					send_msg("No function tree information present\n");
			break;
#endif

#ifdef MNSIDE
			case MNSIDE:		/* show identifiers from help database */
			{
				if (SHL_cfg.ah_project_help)
				{
					if (identifiers.first)
					{
						extern char msg_tab[];
						send_msg("%d identifiers\n", identifiers.last ? identifiers.last->n : 0);

						*msg_tab = ' ';
						pdb_list_ordered(stdout, identifiers.cur, ' ', 0);
						*msg_tab = '\t';
					}
					else
						send_msg("no identifiers present; Try 'Make All'\n");
				}
				else
					send_msg("no project help active\n");
			}
			break;
#endif
			case MNCOMP:
			{
				IT *w=get_top_it();
				if (!w)
					break;
#if PCNT_SAMPLE
				clr_pcnts();
#endif
				do_compile(&root_project, w->title.t);
				free_cache();
			}
			break;

#ifdef MNASSEMF
			case MNASSEMF:
			{
				char *f;

				idir = dir_plus_name(&idir, "*.*");		/* 08'13 HR */
				idir = change_suffix(&idir, sufs.s);
				if (*fsel.s)
					fsel = change_suffix(&fsel, sufs.s);
				f = select_file(&idir, nil, &fsel, "assemble:", &drive);
#if PCNT_SAMPLE
				clr_pcnts();
#endif
				do_compile(&root_project, f);
				free_cache();
			}
			break;
#endif
			case MNCOMPF:
			{
				char *f;

				idir = dir_plus_name(&idir, "*.*");		/* 08'13 HR */
#if FOR_A
				idir = change_suffix(&idir, sufs.a);
				if (*fsel.s)
					fsel = change_suffix(&fsel, sufs.a);
#else
				idir = change_suffix(&idir, sufs.c);
				if (*fsel.s)
					fsel = change_suffix(&fsel, sufs.c);
#endif
				f = select_file(&idir, nil, &fsel, "compile:", &drive);
#if PCNT_SAMPLE
				clr_pcnts();
#endif
				do_compile(&root_project, f);
				free_cache();
			}
			break;
			case MNMAKE:
#if 0 /* DEBUG */
				if (!warn_opt())
#endif
				{
#if PCNT_SAMPLE
					clr_pcnts();
#endif
					domake(&root_project, true);
					free_cache();
				}
			break;

			case MNMAKEAL:

#if PCNT_SAMPLE
				clr_pcnts();
#endif
				send_msg("\nMake all %s\n", mkfn.s);
				loadmake(mkfn.s, 1);		/* clean, dont load ADB */
				domakeall(&root_project);
#ifdef MAKES
				SHL_cfg.makes++;
				CBIN(makes);
#endif
				free_cache();
			break;
#if BIP_LD
			case MNLINK:
				dold(&root_project);
			break;
#endif
		}
		menu_tnormal(Menu, MTPRJ, true);
		break;

#ifdef MTDEBUG
		case MTDEBUG:
		switch (mt)
		{
	#if defined BUGGER && defined CODBG && DEBUG
			case CODBG:
				dial_b2();
			break;
			case DBGTXT:
				open_text_file("bugflags.txt");
			break;
	#endif
			default:
				opt_to_cfg(shel_tab, mt, AMENU, nil, Menu);
		}

		menu_tnormal(Menu,MTDEBUG,true);
		break;
#endif
		default:					/* for menu title */
			return false;
	}

	return true;
}
#endif

global
void init_shell(void)
{
	gsclip(v_hl,1,scr_grect);

	kit_for_shell();
	pdb_init();
	remove_project();
	menu_help(false);
}

#if JOURNAL
global
void show_its(void)
{
	IT *w;
	STMC *ws;

	send_msg("--== IT's ==--\n");
	ws=stmfifirst(&winbase);
	while (ws)
	{
		w=ws->wit;
		send_msg("%s\tfl:%d,wh:%d\n", w->title, w->fl, w->wh);
		stmakecur(&winbase,ws);		/* send_msg() changes currency in winbase */
		ws=stmfinext(&winbase);
	}
	send_msg("--== end ==--\n");
}
#endif
