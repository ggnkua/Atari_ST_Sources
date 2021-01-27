/*  Copyright (c) 1989 - present by Henk Robbers Amsterdam.
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
 *	KIT.C
 *
 */

#define __MINT__

#include <limits.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <ext.h>

#include "mallocs.h"
#include "aaaa_lib.h"
#include "hierarch.h"

#include "aaaa.h"
#include "kit.h"
#include "cursor.h"
#include "journal.h"
#include "wdial.h"
#include "ahcm.h"

#if WINTEXT
#include "text/cursor.h"
#include "text/text.h"
#include "text/text_cfg.h"
#include "text/text_sel.h"
#endif

#if BINARY
#include "bined/ed.h"
#endif

global
KIT_REFS pkit;		/* pointers to RSC structures */

static
short eds[FBS]={DFS1,DFS2,DFS3,DFS4,DFS5,DFS6,DFS7,DFS8,DFS9,DFS10},
      bts[FBS]={DFB1,DFB2,DFB3,DFB4,DFB5,DFB6,DFB7,DFB8,DFB9,DFB10};

short butcur = 0;	/* current selected find button for replace */
static
short edcyc = 0;  	/* current cyclic edit field for use with CNTRL_I */

#ifdef GEMSHELL
#include "shell/shlcfg.h"
#include "shell/shell.h"
#include "pdb.h"
#endif

extern
RECT jrect;

#ifdef MNHOOKS
/* object numbers (independent of resource sequence) */
static
short
	hkswl[] = {	HKSWL0,HKSWL1,HKSWL2,HKSWL3,HKSWL4,
				HKSWL5,HKSWL6,HKSWL7,HKSWL8,HKSWL9 },
	hkswr[] = {	HKSWR0,HKSWR1,HKSWR2,HKSWR3,HKSWR4,
				HKSWR5,HKSWR6,HKSWR7,HKSWR8,HKSWR9 };

extern
HOOKS hooks[N_WH];
#endif

char findstr[FBS][FSL],
     repstr[FSL];

static
TEDINFO *dsfind[FBS], *dsrep;

CFGNEST loc_cfg, file_cfg, shell_cfg;

global
OpEntry settab[]=
{
	{"FIN0=%s\n",FSL,findstr[0],0,0},
	{"FIN1=%s\n",FSL,findstr[1],0,0},
	{"FIN2=%s\n",FSL,findstr[2],0,0},
	{"FIN3=%s\n",FSL,findstr[3],0,0},
	{"FIN4=%s\n",FSL,findstr[4],0,0},
	{"FIN5=%s\n",FSL,findstr[5],0,0},
	{"FIN6=%s\n",FSL,findstr[6],0,0},
	{"FIN7=%s\n",FSL,findstr[7],0,0},
	{"FIN8=%s\n",FSL,findstr[8],0,0},
	{"FIN9=%s\n",FSL,findstr[9],0,0},
	{"EDCU=%d\n",6,&edcur,0,0},
	{"EDCY=%d\n",6,&edcyc,0,0},
	{"REPS=%s\n",FSL,repstr,0,0},
	{"BTCU=%d\n",6,&butcur,0,0},

#ifdef DSW
	{"WORD=%d\n",6,&cfg.o.wrd,  DSW,   KIT},
	{"NWRD=%d\n",6,&cfg.o.any,  DSANY, KIT},
	{"WRDB=%d\n",6,&cfg.o.wpre, DSPRE, KIT},
	{"WRDE=%d\n",6,&cfg.o.wpost,DSPOST,KIT},
#endif

#ifdef DSWORD
	{"WORD=%d\n",6,&cfg.o.wrd,   DSWORD,KIT},
#endif

#ifdef DSCASE
	{"CASE=%d\n",6,&cfg.o.csens, DSCASE,KIT},
#endif
#ifdef DSSURND
	{"SURR=%d\n",6,&cfg.surr,DSSURND,KIT},
#endif
#ifdef DSMDEEP
	{"DEEP=%d\n",6,&cfg.deep,DSMDEEP,KIT},
#endif
#ifdef DSMTALK
	{"TALK=%d\n",6,&cfg.talk,DSMTALK,KIT},
#endif
#ifdef DSMONCE
	{"ONCE=%d\n",6,&cfg.once,DSMONCE,KIT},
#endif
#ifdef DSBCKWRD
	{"FBCK=%d\n",6,&cfg.o.fbck,DSBCKWRD,KIT},
	{"FRWD=%d\n",6,&cfg.o.forw,DSFORWRD,KIT},
#endif

#ifdef MNHOOKS
	{"HKL0=%s\n",HKSL,hooks[0].swl,0,0},
	{"HKR0=%s\n",HKSL,hooks[0].swr,0,0},
	{"HKL1=%s\n",HKSL,hooks[1].swl,0,0},
	{"HKR1=%s\n",HKSL,hooks[1].swr,0,0},
	{"HKL2=%s\n",HKSL,hooks[2].swl,0,0},
	{"HKR2=%s\n",HKSL,hooks[2].swr,0,0},
	{"HKL3=%s\n",HKSL,hooks[3].swl,0,0},
	{"HKR3=%s\n",HKSL,hooks[3].swr,0,0},
	{"HKL4=%s\n",HKSL,hooks[4].swl,0,0},
	{"HKR4=%s\n",HKSL,hooks[4].swr,0,0},
	{"HKL5=%s\n",HKSL,hooks[5].swl,0,0},
	{"HKR5=%s\n",HKSL,hooks[5].swr,0,0},
	{"HKL6=%s\n",HKSL,hooks[6].swl,0,0},
	{"HKR6=%s\n",HKSL,hooks[6].swr,0,0},
	{"HKL7=%s\n",HKSL,hooks[7].swl,0,0},
	{"HKR7=%s\n",HKSL,hooks[7].swr,0,0},
	{"HKL8=%s\n",HKSL,hooks[8].swl,0,0},
	{"HKR8=%s\n",HKSL,hooks[8].swr,0,0},
	{"HKL9=%s\n",HKSL,hooks[9].swl,0,0},
	{"HKR9=%s\n",HKSL,hooks[9].swr,0,0},
	{"HKCS=%d\n",6,&cfg.hookscase,HKSCASE,KIT},
#endif

#ifdef MNFCOMP
	{"FCP1=%s\n",DIR_MAX,pkit.cp1dir.s, 0,0},
	{"FCP2=%s\n",DIR_MAX,pkit.cp2dir.s, 0,0},
#endif

#ifdef MNMULT
	{"MULN=%s\n",DIR_MAX,pkit.muldir.s, 0,0},
	{"JRLX=%d\n",6,&jrect.x,0,0},		/* journal */
	{"JRLY=%d\n",6,&jrect.y,0,0},
	{"JRLW=%d\n",6,&jrect.w,0,0},
	{"JRLH=%d\n",6,&jrect.h,0,0},
#endif

#if RTUN
	{"RTUN=%d\n",6,&cfg.rtun,0,0,RTUN,AMENU},		/* empty undo after return */
#endif
#ifdef SOPT
	{"SOPT=%d\n",6,&cfg.s,0,0,SOPT,AMENU},			/* Use cipboard */
#endif
	{"AOPT=%d\n",6,&cfg.a,0,0,AOPT,AMENU},			/* autosave config */

#if TEXTFILE || BINARY
	{"LCFG= {}\n",0,loc_cfg,0,0},
#endif

#ifdef GEMSHELL
	{"SHEL= {}\n",0,shell_cfg,0,0},	/* this one is not written; it only starts the recursion */
#endif   /* GEMSHELL */

	{"FILE= {}\n",0,file_cfg,0,0},	/* this one is not written; it only starts the recursion */
	{"\0"}
};

static
void disp_2(IT *w1, IT *w2)
{

	if (!make_visible(w1,w1->cu, true))
		do_redraw(w1,w1->wa);

	if (!make_visible(w2,w2->cu, true))
		do_redraw(w2,w2->wa);
}


static
void change_edcur(IT *w,short olded, short edcur)
{
	wdial_draw(w,EDCURBLOK);
}

global
void set_find(void)
{
	IT *w = get_it(-1, KIT);
	wdial_change(w, false, 0, bts[butcur], -1, 0,-1, SELECTED);
	wdial_setcur(w, eds[edcur]);
}

global
void reverse_rich(void)
{
	pkit.tree[DSBCKWRD].state^=SELECTED;
	opt_to_cfg(settab,DSBCKWRD,KIT,pkit.tree,nil);

	if ((pkit.tree[DSFORWRD].state&SELECTED) eq (pkit.tree[DSBCKWRD].state&SELECTED) )
	{
		pkit.tree[DSFORWRD].state^=SELECTED;
		opt_to_cfg(settab,DSFORWRD,KIT,pkit.tree,nil);
	othw
		alertm("inconsistent radio button");	/* must be a programming error */
	}

	wdial_draw(get_it(-1,KIT),DSRICH);
}

global
void change_font(IT *wt, bool small)
{
	short dum,x,y,k,s;

	if (small)
	{
		wt->points=hpoints;
		vst_height(wt->vhl,hpoints,&dum,&dum,&wt->unit.w,&wt->unit.h);
	othw
		wt->points=points;
		vst_height(wt->vhl, points,&dum,&dum,&wt->unit.w,&wt->unit.h);
	}

	if (wt ne &deskw)
	{
		mouse(x,y,k,s);
		if (m_inside(x,y,wt->wa))
		{
			via(wt->muisvorm)(wt);
		}
		/* for snap height */
		sizewindow(wt,&wt->rem);

		bounce(wt,wt->norm.pos.y);
		via (wt->slider)(wt);
	}
}

global
void flip_lnrs(IT *w, bool new)
{
	w->mg.w  = MINMARGIN;

	if (new)		/* present */
	{
		w->den    = denotation_space(w->view.sz.h, 10);
		w->mg.w += (w->den + 1) * w->unit.w;
	}

	get_work(w);
}

/* black boxes */
global
Cstr get_fistr(short cur)
{
	if (cur eq 0) cur = edcur;
	return dsfind[cur]->text;
}
global
Cstr get_repstr(void)
{
	return dsrep->text;
}
global
short get_repl(void)
{
	return strlen(dsrep->text);
}
#if MTEDITOR or MBEDITOR
global
bool is_all(void)
{
	return (pkit.tree[DSALL   ].state&SELECTED) ne 0;
}
#endif

#ifdef MNFCOMP
global
void get_cpfstr(S_path *s1, S_path *s2)
{
	xstr_to_s(pkit.tree, DSCPF1STR, DSCPF1XTR, s1);
	xstr_to_s(pkit.tree, DSCPF2STR, DSCPF2XTR, s2);
}

global
bool is_fdeep(void)
{
	return (pkit.tree[DSFDEEP].state&SELECTED) ne 0;
}
#endif

#ifdef MNMULT
global
void get_mulstr(S_path *s1)
{
	xstr_to_s(pkit.tree, DSMULSTR, DSMULXTR, s1);
}

global
bool is_mult(void)
{
	return (pkit.tree[DSMULT  ].state&SELECTED) ne 0;
}
global
bool is_talk(void)
{
	return (pkit.tree[DSMTALK].state&SELECTED) ne 0;
}
global
bool is_deep(void)
{
	return (pkit.tree[DSMDEEP].state&SELECTED) ne 0;
}
global
bool is_once(void)
{
	return (pkit.tree[DSMONCE].state&SELECTED) ne 0;
}
#endif

#ifdef DSPROJ
global
bool is_project(void)
{
	return (pkit.tree[DSPROJ  ].state&SELECTED) ne 0;
}
#endif

static
WINIT kit_init
{
	struct wdial *d = &w->dial;
	OBJECT *ob = d->ob;

	w->in.x = CHAR_BIT + w->v.x;
	w->in.y = wwa.y;
	w->in.w = ob[d->item].w + w->v.w;
	w->in.h = ob[d->item].h + w->v.h;
	w->frem = lower_right(w->in);
	snapwindow(w,&w->frem);

#ifdef DOPBLOK				/* AHCC */
	w->in.h -= ob[DOPBLOK].h;
#endif
	w->in.w = ob[DFBLOK].w + 4*w->unit.w + w->v.w;
	w->in = lower_right(w->in);
	snapwindow(w,&w->in);
	ob->x = w->in.x - w->v.x;
	ob->y = w->in.y - w->v.y;
	objc_offset(ob,d->item,&d->ddx,&d->ddy);
	d->ddx-=ob->x;		/* distances from root to first to draw */
	d->ddy-=ob->y;
}

global
void goto_line(IT *w,short linenr)	/* w must be open & on top */
{
	via (w->deselect)(w,LOW);
	w->cu = c1st;
	if (linenr > 0)
	{
		w->ss=c1st;
		w->se=c1st;
		if (linenr > w->view.sz.h)
			linenr = w->view.sz.h;
		w->ss.pos.y = linenr - 1;
		w->se.pos.y = linenr;
		w->selection = true;
		w->cu=w->ss;
	}
	if (!make_vis_cur(w))
		do_redraw(w, w->wa);
}

#ifdef MNFCOMP
char *Mismatch="Mismatch",
     *Diffing ="Diffing",
	 *Lone    ="Lone";
#endif

#ifdef MNMULT
global
char *Found   ="Found",
     *Scanning="Scanning";

global
char fkey[LSEL+1];

global
short skl,fls,fds,dirs,tfls;

/* typedef struct ffblk FB; */
#define deeper deep+1

global
uchar aaaalower[STR_MAX];	/* tbv find multiple */

global
S_path fdum = {"DUMMY"};	/* voor alleen folder gevraagd */

global
IT *jrnlwin;

static
char slash [2] = "\\",
     slash2[2] = "\\";

static
char *back_nl(char *s, char *start)
{
	do{
		if (s eq start)
			return start;
		if (*s eq '\n' or *s eq '\r')
			return s + 1;
		s--;
	}od
}

static
char *forw_nl(char *s, char *stop)
{
	do{
		if (s >= stop)
			return stop;
		if (*s eq 0 or *s eq '\r' or *s eq '\n')
			return s;
		s++;
	}od
}

static
void show_scheme(char *dir, char *fn)
{
	MAX_str spacefill;
	if (!is_talk())			/* 07'04 ! and forgotten () */
	{
		short dip = strlen(dir);
		char *spa = spacefill;

		while(dip--)
			if (*dir++ eq *slash)
				*spa++ = '\t';

		*spa=0;
		ins_text(LAST,jrnlwin,"%s%s",spacefill,fn);
	othw
		send_msg("%s in %s\n",Scanning,fn);
	}
}


static
bool opt_match(char *s, short l, FIND_OPTIONS *c)
{
	char *t1 = s, *te = s + l;

	if (    (!c->wrd and !c->wpre and !c->wpost)
	     or (    c->wrd
		     and cmp_nonw(t1 - 1)
		     and cmp_nonw(te)
		    )
		 or (    c->wpre
		     and cmp_nonw(t1 - 1)
		    )
		 or (    c->wpost
		     and cmp_nonw(te    )
		    )
		)
		return true;

	return false;
}

global
bool scan_file(Cstr fn)
{
	char *map;
	bool broken = false,
	        hit = false;
	IT *w;
	short fh;
	long l,
	     oln = 0;
	extern char *zkey;

	if (is_talk())
		send_msg("%s in %s w%d,b%d\n",Scanning,fn,cfg.o.wrd,cfg.o.wpre);

	w = get_fn_it(fn);

	map = w ? condense(w,&l, nil)
	        : Fload(fn,&fh,&l, AH_SCAN_FILE);

	if (map)
	{
		char *z = map, *zz;
		long lineno = 1;

		fls++;
		while (z <= map+l-skl)
		{
			char isol[MAXL+1];
			char *t = isol,
			     *t1,
			     *te;

			*t = 0;
			zz = z;
			z = cfg.o.csens ? qpfind   ((uchar *)z, (uchar *)map+l)
			                : qpfind_nc((uchar *)z, (uchar *)map+l);
			/* qpfind....s return same value in both A0 and D0 for convenience */

			while (zz < z)		/* step up lineno */
			{
				if (   (*zz eq '\r' and *(zz+1) ne '\n')	/* some unix files have cr only */
					or  *zz eq '\n'
				   )
					lineno++;
				zz++;
			}

			if (z < map+l-skl)	/* if a occurence doesnt fit, nothing found, end */
			{
				t1 = z;
				te = z + skl;

				if (opt_match(z, skl, &cfg.o))
				{
					t1 = back_nl(t1, map);
					te = forw_nl(te, map + l);

					while (cmp_space(t1))
						t1++;

					while (    t1 ne te
					       and te-t1 < MAXL	/* protect the stack */
					       )
					{
						if (*t1 eq '\t')
							*t++ = ' ';
						else
							*t++ = *t1;
						t1++;
					}
					*t = 0;

					fds++;

					if (is_once())
					{
						send_msg("%s   in %s L%ld %s\n", Found, fn, lineno, isol);
						break;
					}

					if (lineno ne oln)
					{
						oln = lineno;
						ins_text(LAST,jrnlwin, "%s   in %s L%ld %s", Found, fn, lineno,  isol);
						hit = true;
					}

					broken = break_in;
					if (broken)
						break;
				}
			}
			z += skl;
		}

		ffree(map);
		if (!is_talk() and hit)
			send_msg("\n");		/* \n flushes message buffer */
	}

	if (!broken)
		broken = break_in;

	if (broken)
		send_msg("Search broken off.\n");

	return broken;
}

static
bool fromfolder(char *fn, FILE *t, char *wild)
{
	FB fb={0};

	if (Aopendir(fn, &fb))
	{
		while (Areaddir(&fb))
			if (!fb.deep and match_pattern(fb.fb.ff_name, wild))
				fprintf(t, "%s\n",fb.fb.ff_name);

		Aclosedir(&fb);
		return true;
	}
	return false;
}

global
bool makefrfold(char *fn, FILE *t)
{
	bool ok;
	ok = fromfolder(fn, t, "*.[Cc]");
	if (ok)
	{
		fromfolder(fn, t, "*.[Ss]");
		fromfolder(fn, t, "*.[Ll]*");
	}
	return ok;
}

static
bool find_in_dir(short deep, char *dir,char *wild, bool scheme)
{
	FB fb={0};
	MAX_dir fn;
	strcpy(fn,dir);


	if (is_deep())
	{
		if (Aopendir(fn, &fb))
		{
			while (Areaddir(&fb))
			{
				if (fb.deep)
				{
					if (deep > 9)
						send_msg("\n**** Directory tree more than 10 deep ****\n\n");
					elif (*(fb.fb.ff_name) ne '.')
					{
						if (scheme)
							if (!is_talk())
								show_scheme(dir,fb.fb.ff_name);
							else 	/* is_talk() used for clicking on displayed filenames */
								;	/* displaying folders is of no use here */
						dirs++;
						if (find_in_dir(deeper,fb.fn,wild,scheme))
							return true;
					}
				}
				else
					tfls++;
			}
			Aclosedir(&fb);
		}
	}

	strcpy(fn,dir);

	if (Aopendir(fn, &fb))
	{
		while (Areaddir(&fb))
		{
			if (!fb.deep and match_pattern(fb.fb.ff_name, wild+1))
				if (scheme)
				{
					fls++;
					if (is_talk())
						ins_text(LAST,jrnlwin, "%s" sbslash "%s",fn,fb.fb.ff_name);		/* 07'04 */
					else
						show_scheme(dir,fb.fb.ff_name);
				}
				elif (scan_file(fb.fn))
					return true;
		}
		Aclosedir(&fb);
	}

	return false;
}

static
void get_wild(char *p, char *wild)
{
	short i = 0;

	while(p[i] ne 0) i++;		/* zoek eind */
	while (i-- > 0
			and p[i] ne *slash
			and p[i] ne ':' );	/* zoek begin filename cq wildcard */
	if (p[i] eq ':')
	{
		strcpy(wild,slash);
		strcat(wild,p+i+1);
		*(p+i+1) = 0;
	othw
		strcpy(wild,p+i);
		*(p+i) = 0;
	}
}

global
void find_multiple(void)
{
	short i;
	MAX_dir wild;

	fls=0, fds=0, dirs=0, tfls=0;
	jrnlwin = get_it(-1,JRNL);

	strcpy(fkey,get_fistr(0));
	skl = strlen(fkey);
	if (skl)
	{
		if (!cfg.o.csens)
			loop(i,skl)
				fkey[i]=tolower(fkey[i]);

		qpfind_prepare(skl, (uchar *)fkey);
	}

	get_mulstr(&pkit.muldir);
	if (skl)
		send_msg("Looking for '%s' in '%s' %s\n",
			get_fistr(0),
			pkit.muldir.s,
			radio_c(&cfg.o)
		);
	else
		send_msg("Scheme for '%s'\n",pkit.muldir.s);

	get_wild(pkit.muldir.s,wild);

	find_in_dir(0,pkit.muldir.s,wild,skl eq 0);

	if (skl)
		send_msg("%d in %d file%s\n",fds,fls,pluralis(fls));
	else
		send_msg("%d file%s\n",fls,pluralis(fls));

	if (is_deep())
	{
		send_msg("total %d file%s ",tfls,pluralis(tfls));
		send_msg("in %d dir%s\n\n", dirs,pluralis(dirs));
	}
	else
		send_msg("total %d file%s\n\n",tfls,pluralis(tfls));
}

static
char *ask_dir(void)
{
	idir =  change_suffix(&idir, ".*");
	return select_file(&idir, nil, &fdum, "find folder:", &drive);
}
#endif

#if MNFCOMP
/*
global
void close_X(IT *w)
{
	get_fn_it(w->title);		/* make current on winbase */

	if (w->base)
	{
		clearmal(w->base);
		stmclear(w->base);
		w->base=0L;
	}

	ffree(w->map);
	stmdelcur(&winbase);
}
*/
static
bool comp_file(char *fn1, char *fn2, short fun, short how)
{
	if (break_in)
		return true;

	elif (fun eq 0)
	{
		char *f1, *f2;
		long  l1,  l2;
		f2 = Fload(fn2,nil,&l2,AH_COMP_FILE1);
		if (f2)
		{
			f1 = Fload(fn1,nil,&l1,AH_COMP_FILE2);
			if (f1)
			{
				fls++;
				if (l1 ne l2 or memcmp(f1,f2,l1))
				{
#ifdef MNFDIFF
					char *dtxt = how ? Diffing : Mismatch;
					send_msg("%s %s :: %s\n", dtxt, fn1, fn2);

					if (how)
					{
						IT *wr = open_X(fn2);
						if (wr)
						{
							IT *wl = open_X(fn1);
							if (wl)
							{
								void diff_2(IT *wl);
							/*	send_msg("Opened\tO:%s\n\t\tN:%s\n", wr->title, wl->title); */
								diff_2(wl);
								close_X(wl);
							}
							close_X(wr);
						}
					}
#else
					send_msg("%s %s :: %s\n", Mismatch, fn1, fn2);
#endif
				}
				ffree(f1);
			}
			ffree(f2);
		othw
			send_msg("%s %s\n",Lone,fn1);
		}
	othw
		long l2;
		l2 = Fopen(fn2,0);
		if (l2 <= 0)
			send_msg("%s %s\n",Lone,fn1);
		else
			Fclose(l2);
	}
	return false; 		/* not broken in */
}

static
bool comp_in_dir(char *dir1, char *dir2, char *wild, short deep, short fun, short how)
{
	FB fb={0};
	MAX_dir fn2;

	if (Aopendir(dir1, &fb))
	{
		while (Areaddir(&fb))
		{
			if (!fb.deep and match_pattern(fb.fb.ff_name, wild+1))
			{
				strcpy(fn2,dir2);
				inq_xfs(fn2,slash2);
				strcat(fn2,slash2);
				strcat(fn2,fb.fb.ff_name);
				if (fun eq 0)
					dirs++;
				if (comp_file(fb.fn,fn2,fun, how))
					return true;				/* if broken in */
			}
		}
		Aclosedir(&fb);
	}

	if (is_fdeep())
	{
		if (Aopendir(dir1, &fb))
		{
			while (Areaddir(&fb))
			{
				if (fb.deep)
				{
					if (deep > 9)
						send_msg("\n**** Directory tree more than 10 deep ****\n\n");
					elif (*(fb.fb.ff_name) ne '.')
					{
						strcpy(fn2,dir2);
						inq_xfs(fn2,slash2);
						strcat(fn2,slash2);
						strcat(fn2,fb.fb.ff_name);
						if (comp_in_dir(fb.fn,fn2,wild,deeper,fun, how))
							return true;				/* if broken in */
					}
				othw
					if (fun eq 0)
						tfls++;
				}
			}
			Aclosedir(&fb);
		}
	}

	return false;		/* not broken in */
}


global
void comp_folder(short how)
{
	S_path dir1, dir2;
	MAX_dir wild, wilddum;
	char *ctxt = how ? "Diffing" : "Comparing";

	fls=0, dirs=0, tfls=0;
	jrnlwin = get_it(-1,JRNL);

	get_cpfstr(&pkit.cp1dir, &pkit.cp2dir);
	if (pkit.cp1dir.s[0] and pkit.cp2dir.s[0])		/* 07'14 HR v5.1 */
	{
		send_msg("%s '%s' :: '%s'\n", ctxt, pkit.cp1dir.s, pkit.cp2dir.s);

		DIRcpy(&dir1, pkit.cp1dir.s);
		get_wild(dir1.s, wild);
		DIRcpy(&dir2, pkit.cp2dir.s);
		get_wild(dir2.s, wilddum);

		send_msg("Unequal files and files in first directory only\n");
		comp_in_dir(dir1.s, dir2.s, wild, 0, 0, how);
		send_msg("Files in second directory only\n");
		comp_in_dir(dir2.s, dir1.s ,wild, 0, 1, 0);

		if (is_fdeep())
		{
			send_msg("total %d file%s ",tfls,pluralis(tfls));
			send_msg("in %d dir%s\n\n", dirs,pluralis(dirs));
		}
		else
			send_msg("total %d file%s\n\n",tfls,pluralis(tfls));
	}
	else
		kit_dial(nil, 0, MNFCOMP);				/* 07'14 HR v5.1 */
}
#endif

static
void set_xstr(IT *w, short it1, short it2, Cstr s)
{
	s_to_xstr(w->dial.ob,it1,it2,s);
	if (w->dial.edob eq it1 or w->dial.edob eq it2)
		wdial_itotmpl(w);
	wdial_change(w,true,it1,it1,-1,0,-1,0);
	wdial_change(w,true,it2,it2,-1,0,-1,0);
}

#ifdef MNMULT
static
void xask_dir(IT *w, S_path *dir, short it1, short it2)
{
	char *f, slash[2], *fp;
	S_path filter;

	f = ask_dir();
	if (f)
	{
		DIRcpy(dir,idir.s);
		get_mulstr(&filter);
		inq_xfs(filter.s, slash);
		fp = strrchr(filter.s, *slash);
		if (fp)
		{
			char *dp;
			inq_xfs(dir->s, slash);
			dp = strrchr(dir->s, *slash);
			if (dp)
				*dp = 0;
			DIRcat(dir, fp);
		}
		set_xstr(w,it1,it2, dir->s);
	}
}
#endif

#if 0
short searches[] = { DSW, DSANY, DSWPRE, DSWPOST, DSWF, DSWL, 0 };

static
bool is_fopt(short o)
{
	short *s = searches;
	while (s) if (o eq *s) return true; else s++;
	return false;
}
#endif

#ifdef MNCHECK
short handle_space(char *, char *);
void dlines (IT *w)
{
	STMDEF *b = w->base;
	STMC *s = stmfifirst(b);
	char t[256];
	while (s)
	{
		/* perform any check on element s */
		short r;

		handle_space(t, s->xtx);
		r = alert_qtext(true, "L%ld = '%s'", s->xn, t);
		if (r eq 2) break;
		s = stmfinext(b);
	}
}
#endif

/*		called via IT->wdial_do if EXIT condition is met */
static
DEXIT kit_do		/* IT *w, short obno */
{
	IT *wo = w->dial.act_on;
	short i, olded = edcur;
	bool neg = obno < 0;

	obno&=0x7fff;

	if (obno > KIT_MAX)
		return;						/* internal security check (should not occur) */

	loop(i,FBS)						/* find fields are TOUCHEXIT */
		if ( obno eq eds[i] )		/* click sets cursor */
		{
			edcur=i;
			w->dial.edob = eds[i];
			break;
		}

	if ( i >= FBS )				/* if other object, then cursor pos */
		loop(i,FBS)
			if (w->dial.edob eq eds[i])
			{
				edcur=i;
				break;
			}

	if (olded ne edcur)
		change_edcur(w,olded,edcur);

	loop(i,FBS)
		if (obno eq bts[i])
		{
			butcur = i;
			break;
		}

#if GEMSHELL && OPTBLOK			/* shell, compiler, linker options blocks */
	if (obno > OPTBLOK)
			opt_to_cfg(    shel_tab, obno, KIT, pkit.tree, nil);
	else
#endif
	{
		switch (obno)
		{

			case DSFORWRD:
			case DSBCKWRD:
#ifdef DSW
			case DSW:
			case DSANY:
			case DSPRE:
			case DSPOST:
#endif
			/* 02'14 HR handle all radiobuttons the same */
				radio_to_cfg(settab, obno, KIT, pkit.tree);
			default:
		/* some touchexit objects may be in the config as well */
				opt_to_cfg  (settab, obno, KIT, pkit.tree, nil);
			}
		if (wo)
			opt_to_cfg(  wo->loctab, obno, KIT, pkit.tree, nil);
		else
			opt_to_cfg(deskw.loctab, obno, KIT, pkit.tree, nil);
	}

	if (obno >= DFS1 and obno <= DFS10)
	{
#ifdef MNMULT
		if (is_mult())
			find_multiple();
	#ifdef MNPROJ
		elif (is_project())
			find_project();
	#endif
		elif (wo and wo->op)
#else
		if (wo and wo->op)
#endif
		{	via (wo->dial_find)(wo,dsfind[edcur]->text);	}
	}
	else
	switch (obno)
	{
#ifdef MNFCOMP
	case DCFOK:
		comp_folder(0);
	break;
#endif
#ifdef DSMULSTR
	case DSMULSTR:
	case DSMULXTR:
		if (neg)
			xask_dir(w,&pkit.muldir,DSMULSTR,DSMULXTR);
	break;
#endif
#ifdef DSCPF1STR
	case DSCPF1STR:
	case DSCPF1XTR:
		if (neg)
			xask_dir(w,&pkit.cp1dir,DSCPF1STR,DSCPF1XTR);
	break;
	case DSCPF2STR:
	case DSCPF2XTR:
		if (neg)
			xask_dir(w,&pkit.cp2dir,DSCPF2STR,DSCPF2XTR);
	break;
#endif

#if DSREPSTR
	case DSREPSTR:
		if (wo)
		{	via (wo->do_repl)(wo);	}
	break;
#endif
#if TEXTFILE
	case DSLNNR:
		if (wo)
			goto_line(wo,cdbv(pkit.lnr->text));
	break;
#endif

#ifdef MNWINDOW
	#if BINARY
	case SCVISIBLE:
	case SCFONT:
		do_bincfg(wo);
	break;
	#endif
#endif
	default:
#if TEXTFILE
		if (obno > DSCBLOK and obno < DHKSBLOK)
			do_txtcfg(wo);
#endif
	break;
	}

	if ( (w->dial.ob[obno].flags&(SELECTABLE|EXIT)) eq (SELECTABLE|EXIT))
		wdial_change(w,true,obno,obno,-1,0,~SELECTED,0);
}

static
void Get_Teds(OBJECT *tree, TEDINFO *td[], char str[][FSL], short start, short n)
{
	short i = 0;
	while (i < n)
	{
		td[i] = get_tedinfo(tree, start + i);
		strcpy(str[i], td[i]->text);
		td[i]->text = str[i];
		++i;
	}
}

global
void Get_Fted(OBJECT *dsb, short i, short item)
{
	dsfind[i]=get_tedinfo(dsb,item);
	strcpy(findstr[i],dsfind[i]->text );
	dsfind[i]->text = findstr[i];
}

void *subst_objects( OBJECT  *obs, bool menu );
void  subst_free   ( USERBLK *ublks );

global
USERBLK *ubdbs = nil;
global
VpV invoke_kit
{
	short i;

	rsrc_gaddr(0,KIT,&pkit.tree);
	ubdbs = subst_objects(pkit.tree,false);
	Get_Teds(pkit.tree, dsfind, findstr, DFS1, FBS);
#ifdef DSLNNR
	pkit.lnr=get_tedinfo(pkit.tree,DSLNNR  );
#endif
#if MTEDITOR or MBEDITOR
	dsrep = get_tedinfo(pkit.tree,DSREPSTR);
	strcpy(repstr,dsrep->text);
	dsrep->text=repstr;
	*repstr=0;
#endif
#ifdef DSMULT
	for(i=0;i<256;i++)
		aaaalower[i]=tolower(i);	/* for qfind_nc() */

#endif
	loop(i,FBS)
		*findstr[i]=0;

#if ! FLOAT
	#ifdef CO2
		pkit.tree[CO2].state |= DISABLED;
	#endif
	#ifdef CO8
		pkit.tree[CO8].state |= DISABLED;
	#endif
#endif
	#ifdef CO1
		pkit.tree[CO1].state |= DISABLED;
	#endif

#ifdef MNHOOKS
	loop (i,N_WH)
	{
		char *s;
		short j = hkswl[i];
		hooks[i].owl = j;
		hooks[i].twl = get_tedinfo(pkit.tree,j);
		strcpy(hooks[i].swl,hooks[i].twl->text);
		hooks[i].twl->text = hooks[i].swl;
		s=hooks[i].swl;
		while(*s ne 0 and *s ne '_') s++;
		*s=0;

		j = hkswr[i];
		hooks[i].owr = j;
		hooks[i].twr = get_tedinfo(pkit.tree,j);
		strcpy(hooks[i].swr,hooks[i].twr->text);
		hooks[i].twr->text=hooks[i].swr;
		s=hooks[i].swr;
		while(*s ne 0 and *s ne '_') s++;
		*s=0;
	}
#endif

	create_dialw(  " KIT ",
	               KIT,
	               pkit.tree,
	               KIT1,
	               kit_init,
	       #if TEXTFILE
	               txtkit_fresh,
	       #elif BINARY
	               binkit_fresh,
	       #endif
	               kit_do);
}

global
void end_kit(void)
{
#ifdef GEMSHELL
	end_shlcfg();
#endif
	subst_free(ubdbs);
}

global
short find_type(IT *wd,short mt)
{
#ifdef MNFIND
	if   (mt eq MNFIND)
	{
	#ifdef DSMULT
		wdial_change(wd,true,DSTOPW,DSTOPW,-1,0,-1,SELECTED);
	#endif
	}
#endif
#ifdef MNMULT
	elif (mt eq MNMULT)
		wdial_change(wd,true,DSMULT,DSMULT,-1,0,-1,SELECTED);
#endif
#ifdef MNPROJ
	elif (mt eq MNPROJ)
		wdial_change(wd,true,DSPROJ,DSPROJ,-1,0,-1,SELECTED);
#endif
	return DFBLOK;		/* tevens default */
}

/* mn =  0: general options in main menu */
/* mn <> 0: actions related to window menu */
global
void kit_dial(IT *w, short mn, short mt)	/* w = top window that is not a dialogue */
{
	IT *wd = get_it(-1, KIT);	/* kit's window */
	short blok;

	change_edcur(wd, edcur, edcur);

#ifdef MNGOTL
	wdial_draw(wd, DSLNNR);
	if (w)
		sprintf(pkit.lnr->text, "%ld",w->cu.pos.y + 1);
#endif

#ifdef MNWINDOW
	#if TEXTFILE
		change_txtkit(&pkit, w, wd);
	#elif BINARY
		change_binkit(&pkit, w, wd);
	#endif
#endif

/* make block visible according to menu choice
	set multiple, project or top window */
	blok = find_type(wd,mt);

#ifdef MNGOTL
	if (mn and mt eq MNGOTL)
		blok = DLINBLOK;
	else
#endif
#if MTEDITOR or MBEDITOR
	if (mn and mt eq MNREPL)
		blok = DFBLOK;
	else
#endif
#ifdef MNWINDOW
	if (mn eq 0 and mt eq MNWINDOW)
		blok = DSCBLOK;
	else
#endif
#ifdef MNHOOKS
	if (mn eq 0 and mt eq MNHOOKS)
		blok = DHKSBLOK;
	else
#endif
#ifdef MNFCOMP
	if (mn eq 0 and mt eq MNFCOMP)
		blok = DCFBLOK;
	else
#endif
#ifdef MNCOOPT
	if (mn eq 0 and mt eq MNCOOPT)
		blok = OPTBLOK;
#endif
	;
	wind_dial(KIT, blok);		/* opens window or puts on top
									with 'blok' visible        */
}

#if WINTEXT
/* An example of a recursive process	*/
/* Try this without recursion */

static
CINF brace_cinf;

static
bool check_brace(IT *w,CINF *n,	/* n = error point */
					 	short blvl, short ilvl, short plvl)
{
	short ch;
	CINF starthook;
	do
	{
		short b=0,i=0,p=0;	/* levels: set to 0 if other type of hook */
							/* back to orig level via stack mechanism */
		*n=brace_cinf;
		ch=next_ch(w,&brace_cinf);

		if   (ch eq '{') b=blvl+1 ;		/* increment hooklevels */
		elif (ch eq '[') i=ilvl+1;
		elif (ch eq '(') p=plvl+1;

		if (b or i or p)		/* if one of the left hooks */
		{
			starthook=brace_cinf;
			if (!check_brace(w,n,b,i,p))	/* on higher level for this hook */
			{
				*n=starthook;
				return false;
			}					/* if ok go on same level */
		othw
			*n=brace_cinf;		/* if one of the right hooks */
			switch (ch)			/* these returns set the right hooklevel back */
			{					/* thereby checking level */
				case ')':
					return plvl > 0;	/* use ch-.. to balance hooks */
				case ']':
					return ilvl > 0;
				case '}':
					return blvl > 0;
			}
		}						/* don't use check_braces() on this file */
	} while (ch ne FBOUND);

	return blvl eq 0 and ilvl eq 0 and plvl eq 0;
}

#if BIP_CC
HELP_STACK *help_stack = nil;


global
void menu_help(bool set)
{
	char *p,*s = Menu[MTPRJ].spec.free_string;

	s += strlen(s);
	p = s - 1;
	if (!set)
	{
		if (*p eq ')')
		while (*p ne '(')
			p--;
		*p = 0;
		menu_bar(Menu, true);
	}
	elif (set and *p ne ')')
	{
		strcpy(s, "(H)");
		menu_bar(Menu, true);
	}
}

static
void up_help(HELP_STACK *new)
{
	new->prev = help_stack;
	help_stack = new;
	menu_help(true);
}

static
void dn_help(HELP_STACK *prev)
{
	xfree(help_stack);
	help_stack = prev;
	if (prev eq nil)
		menu_help(false);
}

global
void clear_help_stack(void)
{
	while (help_stack)
		dn_help(help_stack->prev);
}

static
void to_help_stack(IT *w)	/* cursor_undo, undo_cursor */
{
	HELP_STACK *new = xcalloc(1, sizeof(*new), AH_VIEW);
	if (new)
	{
		VIEW_STATE *v = &new->this;
		v->w = w;
		v->cu = w->cu;
		v->ss = w->ss;
		v->se = w->se;
		v->top = w->norm.pos.y;
		v->selty = w->selty;
		up_help(new);
	}
}

global
void restore_help_stack(IT *wt)
{
	if (help_stack)
	{
		VIEW_STATE *v = &help_stack->this;
		HELP_STACK *p = help_stack->prev;
		IT *w = is_it(v->w);
		if (w)
		{
			w->cu = v->cu;
			w->ss = v->ss;
			w->se = v->se;
			w->selty = v->selty;
			dn_help(p);
			if (!make_visible(w, w->ss, false))
				do_redraw(w, w->wa);
		othw
			dn_help(p);
			if (p)
				restore_help_stack(p->this.w);
		}
	}
}
#endif

static
bool is_ws(char *s)
{
	return *s eq ' ' or *s eq '\t';
}

static
short handle_space(char *o, char *i)
{
	char *so = o;

	while (*i)
	{
		if (is_ws(i))
		{
			while (*i and is_ws(i))
				i++;
			*o++ = ' ';
		}
		else
			*o++ = *i++;
	}

	if (o > so)
		if (*(o-1) eq ' ')
			o--;

	*o = 0;

	return o - so;
}

/* line_compare returns
   0: equal,
   1: 1st < 2nd,
  -1: 1st > 2nd,
   2: unequal unspecified
*/

#include "diff.h"

static
void show_2(STMC *s1, STMC *s2)
{
	char t1[MAXL+1], t2[MAXL+1];
	if (s1)
	{
		handle_space(t1, s1->xtx);
		send_msg("e1-=%s=-\n",t1);
	}
	if (s2)
	{
		handle_space(t2, s2->xtx);
		send_msg("e2-=%s=-\n",t2);
	}

	send_msg("====\n"); Cconin();
}

global
void do_Search(IT *w,short mt)
{
	void find_project(void);
	void rep1stby2nd(IT *w);
	if (w)
	{
		find_line(w,w->ss.pos.y ? w->ss.pos.y : w->cu.pos.y);
		switch (mt)
		{
	#ifdef MNFIND
			case MNFIND:
				kit_dial(w, 1, MNFIND);
			break;
		#ifdef MNFIRSAM
			case MNFIRSAM:
				reverse_rich();
			fall_thru
			case MNFISAM:
				if ( *dsfind[edcur]->text )
				{
					IT *kit = get_it(-1, KIT);
					find_type(kit, MNFIND);
					wdial_setcur(kit, eds[edcur]);
					dial_find(w,dsfind[edcur]->text);
				othw
					ping;
					kit_dial(w, 1, MNFIND);
				}
			break;
		#endif
		#ifdef MNFISEL
			#ifdef MNMULT
			case MNFISELM:
			#endif
			#ifdef MNPROJ
			case MNFISELP:
			#endif
			case MNFISEL:
				if (!w->selection)
				{
					cur_off(w);
					select_thing(w);		/* may set w->selection */
					w->selection = true;
					via (w->select)(w);
				othw
					short i, olded = edcur;
					CINF fs = w->ss, fe=w->se;
					char selection[LSEL + 1];
					char *st = selection;
					IT *kit = get_it(-1, KIT);

					find_type(kit, MNFIND);

					loop(i,dsfind[0]->tmplen)		/* extract selection */
					{
						if (fs.pos.y eq fe.pos.y and fs.pos.x eq fe.pos.x)
							break;
						*st++=*(w->line+fs.pos.x);
						next_ch(w,&fs);
					}
					*st=0;

					loop(i,FBS)
						if ( SCMP(10, dsfind[i]->text,selection) eq 0) break;

					wdial_off(kit);		/* cursor off */

					if (i < FBS)		/* allready in findlist */
						edcur=i;
					else
					{
						IT *wd = get_it(-1,KIT);
						loop(i,FBS)
							if ( *dsfind[i]->text eq 0 ) break;

						if (i eq FBS)
						{
							edcur = edcyc++;		/* no empties: overwrite cyclic */
							if (edcur eq butcur)	/* dont overwrite find for replace!!! */
								edcur = edcyc++;
							edcyc%=FBS;
							edcur%=FBS;
						othw
							edcur=i;				/* empty one: use it and set for next */
							edcyc=(i+1)%FBS;
						}
						strcpy(dsfind[edcur]->text,selection);

						wdial_draw(wd,eds[olded]);
						wdial_draw(wd,eds[edcur]);
					}

					wdial_setcur(kit, eds[edcur]);	/* move cursor */

				#ifdef MNMULT
					if (mt eq MNFISELM)
						find_multiple();
					else
				#endif
				#ifdef MNPROJ
					if (mt eq MNFISELP)
						find_project();
					else
				#endif
						dial_find(w,dsfind[edcur]->text);
				}
			break;
		#endif
	#endif					/* MNFIND */
	#ifdef MNFICU
			case MNFICU:
			case MNFIES:
				if (w->selection)
					if (mt eq MNFICU)
						make_visible(w,w->ss, false);
					else
						make_visible(w,w->se, false);
				else
					make_vis_cur(w);
			break;
	#endif
	#ifdef MNHELP
			case MNHELP:
			{
				char word[MAXL+1];
				*word = 0;
				select_and_get_word(w, word);
#if BIP_CC
				if (*word)
				{
					PDB *ide = pdb_find_ide(&identifiers, word);

					if (ide)
					{
						Cstr fn = pdb_file_by_number(auto_dependencies, ide->file_number);
						if (fn)
						{
							to_help_stack(w);
							open_clicked_file(fn, ide->line_number);
						}
						else
							ping
					}
					else
						ping
				}
#endif
			}
			break;
	#endif
	#ifdef MNGOTL
			case MNGOTL:
			{
				IT *kit = get_it(-1, KIT);
				wdial_setcur(kit, DSLNNR);
				kit_dial(w, 1, MNGOTL);
			}
			break;
	#endif
	#ifdef MNBRACE
			case MNBRACE:
			{
				CINF hs;		/* allways starts form cursor position */
				brace_cinf=w->selection ? w->ss : w->cu;
				find_line(w,brace_cinf.pos.y);
				if (!check_brace(w,&hs,0,0,0))
						/* uses brace_cinf, returns hs when false */
				{
					ping;
					via (w->deselect)(w,LOW);
					w->cu=hs;
					x_to_s_t(w,&w->cu);
					make_vis_cur(w);
					cur_on(w);
					break;
				}
			}
			break;
	#endif
	#ifdef MNSELALL
			case MNSELALL:
			{
				STMC *last=stmfilast(w->base);

				via (w->deselect)(w, LOW);
				w->ss=c1st;
				w->se.pos.y = last->xn - 1;
				t_to_s_x(w,w->se.pos.y,MAXL,&w->se,HIGH);
				w->selection = true;
				via (w->select)(w);
			}
			break;
	#endif
	#ifdef MNLR
			case MNLR:
				rep1stby2nd(w);		/* Not yet */
			break;
	#endif
	#ifdef MNCOMPARE
/* Find first lines that are (un)equal */
			case MNCOMPARE:
				sync_lines(w);
			break;
	#endif
	#ifdef MNDIFF				/* HR: Basicly only for testing */
			case MNDIFF:
				diff_2(w);		/* write diffs to journal. */
			break;
	#endif
	#ifdef MNCHECK				/* HR: Basicly only for testing */
			case MNCHECK:
				dlines(w);
			break;
	#endif
		}
	}
}
#endif

#if BINARY
global
void do_bSearch(IT *w,short mt)
{
	if (w)
	{
		switch (mt)
		{
	#ifdef MNFIND
			case MNFIND:
				kit_dial(w, 1, MNFIND);
			break;
	#endif
	#ifdef MBCOMPARE
			case MBCOMPARE:
			{
				STMC *ws;
				IT *w1=w,*w2=nil;

				while ((ws=stmfind(&winbase,NEXT,CYCLIC)) ne nil)
				{
					w2=ws->wit;
					if (is_bin(w2))
						break;
				}

				if (w2 and w2 ne w)
				{
					long l1, l2;
					char *b1, *b2;

					via (w->deselect)(w1, HIGH);	/* if already found unequal, will find next */
					via (w->deselect)(w2, HIGH);
					l1 = w1->cu.pos.y*w1->bin.bw + w1->cu.pos.x;
					l2 = w2->cu.pos.y*w2->bin.bw + w2->cu.pos.x;
					b1 = w1->map + l1;
					b2 = w2->map + l2;

					while (    l1 < w1->mapl
					       and l2 < w2->mapl
					      )
						if (*b1++ ne *b2++)		/* Yes its slow, but I dont care; it is interactive */
							break;				/* and I need to know the line numbers. */
						else
							l1++, l2++;

					l_to_s_t(w1, l1);
					l_to_s_t(w2, l2);
					disp_2(w1, w2);
				}
			}
			break;
	#endif
		}
	}
}
#endif

static
void preserve_filter(Wstr s, Cstr filter)
{
	char *fp,slash[2];

	inq_xfs(filter,slash);
	fp = strrchr(filter,*slash);
	if (fp)
	{
		char *dp;
		inq_xfs(s,slash);
		dp = strrchr(s,*slash);
		if (dp)
			*dp = 0;
		strcat(s,fp);				/* we know s is big enough */
	}
}

#if DSMULSTR || DSCPF1STR
global
void kit_drop(IT *w,short ty, Wstr s, short mx, short my)
{
	S_path filter;
	short nob = objc_find(w->dial.ob,0,MAX_DEPTH,mx,my);

	switch (nob)
	{
#if DSMULSTR
	case DSMULSTR:
	case DSMULXTR:
		get_mulstr(&filter);
		preserve_filter(s, filter.s);
		set_xstr(w, DSMULSTR, DSMULXTR, s);
	break;
#endif
#if DSCPF1STR
	case DSCPF1STR:
	case DSCPF1XTR:
		xstr_to_s(pkit.tree,DSCPF1STR,DSCPF1XTR, &filter);
		preserve_filter(s, filter.s);
		set_xstr(w, DSCPF1STR, DSCPF1XTR, s);
	break;
#endif
#if DSCPF2STR
	case DSCPF2STR:
	case DSCPF2XTR:
		xstr_to_s(pkit.tree,DSCPF2STR,DSCPF2XTR, &filter);
		preserve_filter(s, filter.s);
		set_xstr(w, DSCPF2STR, DSCPF2XTR, s);
	break;
#endif
	}
}
#endif
