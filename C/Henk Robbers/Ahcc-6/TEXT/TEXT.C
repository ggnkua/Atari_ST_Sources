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

/* 	TEXT.C
 *	======
 */

#include <ctype.h>
#include <string.h>
#include <ahcm.h>
#include <np_aes.h>

#include "aaaa.h"

#include "common/aaaa_lib.h"
#include "common/files.h"
#include "common/mallocs.h"
#include "common/options.h"
#include "common/cursor.h"
#include "common/wdial.h"
#include "common/kit.h"

#include "cursor.h"
#include "text.h"
#include "text_cfg.h"
#include "text_sel.h"
#include "editor.h"

#define TDS 0

M_S tmen={false,false,0,0,0,0,0,0,0,0L,0L};

extern
XA_memory XA_jnl_base;

global
short totab(short c,short t) { return ((c/t)+1)*t; }

/* Also used in do_Edit() by MNRETAB.
 * the use of maxw unnecessitates the use of clipping when the window
 * is on top.
 */
global
short de_tab(char *tabbed, char *pm, short tabs, short vis, short vco, short maxw)
{
	short l=0;
	short p;
	char trail[MAXL+1];
	char *pt = pm + strlen(pm) - 1;

	if (vis ne ' ')
	{
		strcpy(trail, pm);			/* 10'10 HR make also trailing white space visible */
		pm = trail;
		pt = trail + strlen(trail) - 1;
		while (*pt eq ' ' or *pt eq '\t' and pt > pm)
			*pt-- = 127;			/* small triangle (delta) */
	}

	while ((p=*pm++) ne 0
	       and l < maxw
	      )
	{
		if ( p eq '\t' and tabs )
		{
			short t = totab(l,tabs);
			char tt = vis;
			while ( l < t and l < maxw)
				*tabbed++=tt,l++,tt= tt eq ' ' ? ' ' : vco;
		othw
			*tabbed++=p, l++;
		}
	}

	*tabbed=0;
	return l;
}

#if (BIP_CC or BOLDTAGS) /* reserved words bold */

short is_bold_word(BOLDCAT *bc, char *s);

#if BOLDTAGS			/* in resource, othw in compilers keyword table */

#define BOLDCATS 5

global int strtcmp(int a, const char *s1, const char *s2)
{
static int tel = 0;
	alert_text("(%d) SCMP %d", ++tel, a);
	return strcmp(s1, s2);
}

static
BOLDCAT boldcat[BOLDCATS] = {nil};
static
short boldcats = 0;

static
StdCompare vgl
{
	char **e1 = p1, **e2 = p2;
	return SCMP(99,*e1, *e2);
}

void read_tags(void)
{
	short k;
	BOLDCAT *bc;
	OBJECT *bt;

	rsrc_gaddr(0, BOLDTAGS, &bt);
	if (!bt)
		return;

	k = bt->head;
	do
	{

		if (k < 1)
			break;

		if (bt[k].type eq G_BUTTON and bt[k].head > 0)
		{
			short b = bt[k].head;
			short tgs = 0;

			bc = &boldcat[boldcats];
			bc->match = bt[k].spec.free_string;
			bc->st_guide = (bt[k].state & CROSSED) ne 0;
			bc->upper = (bt[k].state & CHECKED) ne 0;
			bc->a68 = (bt[k].state & SELECTED) ne 0;

			do{					/* first count words; for malloc */
				if (bt[b].type eq G_STRING)
					if (islower(*bt[b].spec.free_string))
						tgs++;
				if (bt[b].next eq k)
					break;
				b = bt[b].next;
			}od

			bc->tags = xmalloc((tgs+1)*sizeof(char *), AH_BOLDTAGS);
			if (bc->tags eq nil)
				alert_text("no boldtags");
			else
			{
				short i = 0;
				b = bt[k].head;
				do{				/* now pick up pointers to words */
					if (bt[b].type eq G_STRING)
						if (islower(*bt[b].spec.free_string))
							bc->tags[i] = bt[b].spec.free_string, i++;
					if (bt[b].next eq k)
						break;
					b = bt[b].next;
				}od

				qsort(bc->tags,tgs,sizeof(char *),vgl);

				bc->tags[tgs] = nil;

				loop(i,26) bc->at[i]=nil;		/* find startpointers for each starting letter */

				b = 0;
				while (bc->tags[b])
				{
					bc->at[*bc->tags[b]-'a'] = &bc->tags[b];
					while (bc->tags[b+1])
					{
						if (*bc->tags[b] ne *bc->tags[b+1])
							break;
						b++;
					}
					b++;
				}
			}

			boldcats++;
		}

		if (bt[k].next eq 0)
			break;
		k = bt[k].next;
	}
	while (boldcats < BOLDCATS);
}

short cmpl(Cstr s1, Cstr s2, short l);
short cmpli(Cstr s1, Cstr s2, short l);
									/* l at least 1 */
short is_bold_word(BOLDCAT *bc, char *s)
{
	if (bc)
	{
		char *to = s; long l;

		if (bc->st_guide and *(s-1) ne '@')
			return -1;
		if (bc->a68)
		{
			while (isupper(*to)) to++;
			return to - s;
		othw
			if (bc->upper)
				while (is_alpha(*to)) to++;
			else
				while (islower(*to)) to++;
			if (!isalpha(*s))
				return -1;			/* Cannot handle words starting with '_' */
			if (!is_alpha(*to))
			{
				char **k;

				l = to-s;
				if (l)
				{
					char c = tolower(*s);
					k = bc->at[c-'a'];
					if (k)
						while (*k and c eq **k)
						{
							short i;
							if (bc->upper)
								i = cmpli(s, *k, l);
							else
								i = cmpl (s, *k, l);
							if ( i eq 0)
								return l;
							elif (i < 0)
								break;
							++k;
						}
				}
			}
		}
	}
	return -1;
}

BOLDCAT *get_bold(IT *w)
{
	short i = 0;
	loop (i, boldcats)
	{
		char *s = strrchr(w->title.t, '\\');
		if (!s)
			s = strrchr(w->title.t, ':');
		if (!s)
			s = w->title.t;
		if (match_pattern(s, boldcat[i].match))
			return &boldcat[i];
	}
	return nil;
}
#endif

static
char *text_split(BOLDCAT *bc, bool *type, short *l, char *text)
{
	static char s[MAXL+1]; short bl;
	char *ps = s;
	bl = is_bold_word(bc, text);
	if (bl > 0)
	{
		*type = true;
		*l = bl;
		if (bc and bc->a68)
			while (bl--) *ps++ = tolower(*text++);
		else
			while (bl--) *ps++ = *text++;
	}
	else
	{
		bl = 0;
		*type = false;
		while ( *text and is_alpha(*text))
		{
			*ps++ = *text++;
			bl++;
		}
		while ( *text and !is_alpha(*text))
		{
			*ps++ = *text++;
			bl++;
		}
		*l = bl;
	}
	*ps = 0;
	return s;
}

#define BOLD (ulined|bold)

static
void s_txt(BOLDCAT *bc, short hs, short x, short y, char *text)
{
	x &= 0xfff8;

	if (!bc)
		v_gtext(hs, x, y, text);
	else
	{
		char *ps; short l;
		bool boldtag=false;

#if BIP_CC
		bc = nil;		/* AHCC doesnt use bc but only the return of is_bold_word() */
#endif
		while (*text)
		{
			ps = text_split(bc, &boldtag, &l, text);
			vst_effects(hs, boldtag ? bold : 0);
			v_gtext(hs, x, y, ps);
			boldtag = !boldtag;
			x += l * wchar;
			text += l;
		}
		vst_effects(hs, 0);
	}
}
#else
static
void s_txt(BOLDCAT *bc, short hs, short x, short y, char *text)
{
	x &= 0xfff8;
	v_gtext(hs, x, y, text);
}
#endif

/* Not used anymore (and not needed, snapping is performed by snapwindow()
global
void f_txt(short hs, short x, short y, char *text)
{
	x &= 0xfff8;			/* Really (x/wchar)*wchar
							   When you dont snap, you'll notice */
	v_gtext(hs, x, y, text);
}
*/
global
ANTEVNT text_evm		/* IT *w; bool w_on, short evmask */
{
#if WINDIAL
	set_dialinfs(w);
#endif
	evmask|=MU_KEYBD|MU_M1|MU_TIMER;

	if (w_on)					/* if mouse within wa */
		evmask|=MU_BUTTON;

	return evmask;
}

global		/* also used by journal.c */
void txt_margin(IT *w,STMC *s,short y)
{
	short hl = w->vhl;
	/* standard */
	short x = w->wa.x + w->mg.w mod w->unit.w;

	/* w->mg includes the little margin (< w->unit.w) for showchange */

	if (showchange and (s->xfg&ISMOD) )
	{
		vsf_color(hl,1);
		vsf_interior(hl,FIS_PATTERN);
		vsf_style(hl,(s->xfg&ISMAP) ? 6 : 4);
		pbox(hl, w->wa.x,y, x-1,y+w->unit.h-1);
		vsf_color(hl,0);
		vsf_interior(hl,FIS_SOLID);
		vsf_style(hl,0);
	}

#ifdef SCLIN
	if (w->mg.w > w->unit.w and w->loc.lnrs)
	{
		short mw = w->ma.x - (w->unit.w/2),
		      my = y + w->unit.h - 1;
		v_gtext(hl, x,  y, cbdlu(s->xn, w->den, ' '));	/* line number */
		line (hl, mw, y, mw, my);
	}
#endif
}

/* v_gtext */
static
void rev_txt(BOLDCAT *bc, short hl, short x, short y, short color, char *text)
{
	short ext[8];

	x&=0xfff8;
	vqt_extent(hl,text,ext);
								/* first a black box */
	vsf_color(hl,color);
	pbox(hl,ext[0]+x,ext[1]+y,ext[4]+x-1,ext[5]+y-1);
	vsf_color(hl,0);
								/* then */
	vst_color(hl,0);			/* white */
	vswr_mode(hl,2);			/* transparant */
	s_txt(bc,hl,x,y, text);		/* text */
								/* gives a surprising effect */
	vswr_mode(hl,0);
	vst_color(hl,1);
}

#if BOLDTAGS
static
BOLDCAT *can_bold(IT *w)
{
	if (is_text(w) and w->loc.boldtag)
		return w->bc;
	return nil;
}
#else
#define can_bold(w) (void *)w->loc.boldtag
#endif

global
DISP disp_nosel
{
	short hl = w->vhl, dum;
	bool rest;
	char tabbed[MAXL+1];
	short
		l=0,
		ls,
		nr = s->xn - 1,
		x  = w->ma.x,
		y  = w->ma.y + (nr - w->norm.pos.y) * w->unit.h,
		xplusw = w->ma.      x+w->ma.     w,
		maxw   = w->norm.pos.x+w->norm.sz.w;

	if (maxw > w->view.sz.w)
		maxw = w->view.sz.w;
	vst_height(hl,w->points,&dum,&dum,&dum,&dum);
	/* mouse allready off ? */
	if (hide eq HIDE)	/* VERY important: AES still rather slow */
		hidem;
	w->line=tabbed;

	if (w->dha) l += (*w->dha)(w, s);		/* ante display (able to step w->line) */
	            l += de_tab(w->line,s->xtx,
	                        w->loc.tabs,
	                        w->loc.vistab,
	                        w->loc.vistco, maxw);		/* maxw < MAXL */
	if (w->dhp) l += (*w->dhp)(w, s);		/* post display */

	w->line=tabbed;
	l -= w->norm.pos.x;
	if (l<0) l=0;

	ls = x+l*w->unit.w;
	rest = ls < xplusw;

	if (l)
		s_txt(can_bold(w), hl,x,y,tabbed+w->norm.pos.x);

	if (rest)
	{
		pbox(hl,ls,y,xplusw-1,y+w->unit.h-1);	/* fill rest of line */
		vsf_color(hl,0);
	}

	via (w->do_margin)(w,s,y);

	if (hide eq HIDE)
		showm;
}

global
DISP disp_line		/*	IT *w,STMC *s,bool hide	*/
/* line must be current and in window,
   also used in EDITOR	for single lines.
   Directly inversed write of selections.
	   All this programming is mainly for cosmetic purposes,
			not so much for speed.
	   It is to avoid the whitening of the screen prior
	   to the immediate following blackening.
*/

{
	short hl = w->vhl, dum;
	bool rest;
	char tabbed[MAXL+1];

	short
		l = 0,
		ls,
		nr = s->xn - 1,
		sl = w->ss.pos.y,
		el = w->se.pos.y,
		x = w->ma.x,
		y = w->ma.y + (nr - w->norm.pos.y) * w->unit.h,
		xplusw=w->ma.x+w->ma.w,
		maxw=w->norm.pos.x+w->norm.sz.w;

	bool sel = w->selection;
	short color = w->color;

	if (maxw > w->view.sz.w + 1)
		maxw = w->view.sz.w + 1;
	vst_height(hl,w->points,&dum,&dum,&dum,&dum);
	/* mouse allready off ? */
	if (hide eq HIDE)	/* VERY important: AES still rather slow */
		hidem;

	w->line = tabbed;
	if (w->dha) l += (*w->dha)(w,s);		/* ante display (able to step w->line) */
			    l += de_tab(tabbed, s->xtx, w->loc.tabs, w->loc.vistab, w->loc.vistco, maxw);		/* maxw < MAXL */
	if (w->dhp) l += (*w->dhp)(w,s);		/* post display */

	w->line = tabbed;
	l -= w->norm.pos.x;
	if (l < 0) l = 0;

	ls = x + l * w->unit.w;
	rest = ls < xplusw;

	if (!sel)
	{
		if (l)
			s_txt(can_bold(w), hl,x,y,tabbed+w->norm.pos.x);
	othw
	/*	whole line within selection ? */
		if (   (    sl <  nr
				or (sl eq nr and w->ss.pos.x eq 0)
			   )
			and nr < el
			)
		{
			if (l)
				rev_txt(can_bold(w),hl,x,y,color,tabbed+w->norm.pos.x);
			if (rest)
				vsf_color(hl,color);			/* for pbox on rest of line */
		othw
			if (l)
			{			/* normal handle */
				s_txt(can_bold(w), hl, x, y, tabbed + w->norm.pos.x);
				if (sl eq el and nr eq sl)
				{
					via (w->select)(w);		/* easy; its NOT worthwhile to split a line in three. */
				othw
					if (!(nr eq el and w->se.pos.x eq 0))	/* excl newline !!! */
						via (w->wselect)(w,&w->ss,&w->se,nr,nr+1);
					if (nr eq sl and rest)
						vsf_color(hl,color);		/* for rest of line */
				}
			}
		}
	}

	if (rest)
	{
		pbox(hl,ls,y,xplusw-1,y+w->unit.h-1);	/* fill rest of line */
		vsf_color(hl,0);
	}

	via (w->do_margin)(w,s,y);

	if (hide eq HIDE)
		showm;
}

global
STMC *find_line(IT *w, long zoek)		/* !! zoek (search) is 0-n-1 */
{
	STMDEF * m   = w->base;
	STMC *   new = 0L;

	if (zoek < 0)
		zoek = 0;
	if (m)
	{
#if INTERNAL
		if ( (new=stmfinum(m,zoek + 1)) eq 0L)	/* fast proc */
		{
			form_alert(1,"[3][|Fatal internal error|empty chain][ Stop ]");
			eruit(1);
		}
#else
		new=stmfinum(m, zoek + 1);		/* fast */
#endif
		w->line = new->xtx;
	}
	return new;
}

global
STMC *find_current_line(IT *w)
{
	STMDEF * m    = w->base;
	STMC *   new  = nil;
	long     zoek = w->cu.pos.y;

	if (zoek < 0)
		zoek = 0;
	if (m)
	{
		new=stmfinum(m, zoek + 1);		/* fast */
		w->line = new->xtx;
	}
	return new;
}

global
LINES text_lines  /* IT *w, short arrow */
{	short i=0, y;
	STMC *msp;
	short yplush = w->ma.y + w->ma.h-1,
	      xplusw = w->ma.x + w->ma.w-1;

	hidem;

	if (!arrow)
		cur_off(w);

	y = w->ma.y;

	msp = find_line(w, w->norm.pos.y);
	clear_margin(w);

	while ( i < w->norm.sz.h and msp)
	{
		if (	!arrow
			or	(arrow < 0 and i >= w->norm.sz.h + arrow)
			or  (arrow > 0 and i <                 arrow)
		   )
		{	via (w->disp)(w, msp, NO_HIDE);	}
		y += w->unit.h;
		msp=stmfinext(w->base);
		i++;
	}

	if ( y < yplush)
		pbox( w->vhl,				/* spacefill rest of window */
			w->wa.x,
			y,
			xplusw,
			yplush);

	showm;
}

global
DRAW display		/* (IT *w)	*/
{
	via (w->lines)(w,0);
}

global
bool abandon_ins=false;


/* used by Digger and kit for large journal output */
global
STMC *ins_text(STMACC acc,IT *w,char *text, ...)
{
	va_list argpoint;
	short l;
	char mb[MAXL*4];			/* allow for message body */
	STMDEF *m = w->base;
	STMC *msgp=0L;
	char *mal;

	if (abandon_ins)
		return 0L;

	va_start(argpoint,text);
	l=vsprintf(mb,text,argpoint);
	va_end(argpoint);

	mal = XA_alloc(&XA_jnl_base, l + 1, nil, AH_INS_MSG, 0);

	if (mal)
		if ( (msgp=stminsert(m,acc)) ne 0L)
		{
			msgp->xtx=mal;
			strcpy(mal,mb);
			msgp->xfg=0;
			msgp->x_l=l;
			msgp->xrm=0;
		}

	if (!msgp)
	{
		mem_alert("while appending text","Ignored");
		abandon_ins=true;
	othw
		m_alerted=false;
		if (acc ne LAST)
		{
			renum(w);
		othw
			w->view.sz.h += 1;
			msgp->xn=w->view.sz.h;
		}
#if JOURNAL
		w->lsto = true;
#endif
		if (w->ty eq BUFF and w->op)
			form_dial(FMD_FINISH,0,0,0,0,w->wa.x,w->wa.y,w->wa.w,w->wa.h);
		/* is window wel gecreeerd maar nog niet open, heeft dit geen effect */
	}
	return msgp;
}

global
void printfile(IT *w)
{	FILE   *prt;
	STMDEF *d;
	STMC   *s;
	char tabbed[MAXL+1];

	if (w)
	{	d=w->base;
		prt=fopen("PRN:","w");

		s=stmfifirst(d);
		while (s)
		{
			short l = de_tab(tabbed ,s->xtx,
			               w->loc.tabs,
			               w->loc.vistab,
			               w->loc.vistco, MAXL);
			fwrite(tabbed,l,1L,prt);
			fwrite("\r\n",2,1L,prt);
			s=stmfinext(d);
		}
		fclose(prt);
	}
}

static
void do_tFile(IT *w,short mt)	/* w = my top window */
{
#if defined TMENU
	switch (mt)
	{
	#ifdef MNTPR
	case MNTPR:
		printfile(w);
	break;
	#endif
	#ifdef MNTPRSEL
	case MNTPRSEL:
		#if SELECTION
		printselection(w);
		#endif
	break;
	#endif
	case MNTCLOSE:
	#ifdef WMENU
		wmenu_tnormal(w,MTT1,true); /* before its gone */
	#endif
		via (w->closed)(w);		/* same as window closebox */
	break;
	#ifdef MTEDITOR
	case MNTSAVE:
		if (w->ty eq BUFF or w->ty eq JRNL)
			savesfile(w);
		else
			savefile(w, w->title.t, false);	/* false = don't force */
	break;
	case MNTSAVES:
		savesfile(w);
	break;
	case MNTABAN:
		abandonfile(w);
	break;
	#endif
	}
#endif
}

global
MENU_DO do_tmenu			/* file open allready catered for in main()	*/
{
#if defined MTT1
	if (title eq MTT1)		do_tFile  (w,choice);
#elif defined MT1
	if (title eq MT1 )		do_tFile  (w,choice);
#endif

	wmenu_tnormal(w,title,true);	/* the below open a window */

#ifdef MTSEARCH
	#ifdef MTREPAIR
	if     ( title eq MTREPAIR)	do_Repair(w,choice,kstate);
	else
	#endif
	#ifdef MTEDITOR
	if     ( title eq MTEDITOR)	do_Edit  (w,choice,kstate);
	else
	#endif
	#ifdef MTBUFFER
	if     ( title eq MTBUFFER)	do_Buffer(w,choice,kstate);
	else
	#endif
		if ( title eq MTSEARCH)	do_Search(w,choice);
#endif

	return true;
}

global
void clearmal(STMDEF *d)
{
	STMC *nx;

	if (!d)
		return;
	nx = stmfifirst(d);
	while (nx)
	{
		if (!(nx->xfg&ISMAP))
			xfree(nx->xtx);
		nx = stmfinext(d);
	}
}

#if INTERNAL
char lost_cw[128];
#endif

global
FCLOSE close_textfile	/*	(IT *w,bool force)	*/
{
#ifdef MTEDITOR
	#ifndef TESTPHASE
	if (w->base)
		if (!(force or check_save(w)))
			return false;
	#endif
#endif

	cur_off(w);

	if (w->wh > 0)
		get_it(w->wh,-1);		/* make current on winbase */
	else
		get_fn_it(w->title.t);
	w->cu=c1st;
	if (w->base)
	{
		clearmal(w->base);
		stmclear(w->base);
		w->base=0L;
#if TEXTEDIT
		clear_undo(w);
#endif
		w->old=0L;
	}
	ffree(w->map);
	close_w(w);
	mpijl;  /* for some AES's */
	w->fl=0;
#if INTERNAL
	/*  macro!!: stmcur(d) ((d).us.c) */

	if (stmcur(winbase)->wit ne w)
	{
		sprintf(lost_cw,"[1][ Internal error: | lost current IT | w: %lx | c: %lx ][ Pffft! ]",w,stmcur(winbase)->wit);
		form_alert(1,lost_cw);
	#ifdef MNPRINFO
		{
			short sd=diagnostics;
			diagnostics=true;
			print_it(w,"lost_it");
			print_it(stmcur(winbase)->wit,"got_it");
			diagnostics=sd;
		}
	#endif
	}						/* must delete someone to prevent looping */

#endif

	stmdelcur(&winbase);

#if WINDIAL
	set_dialinfs(0L);
#endif

	return true;
}

#ifdef MNCRLF
static
MENU_SET set_crlf
{
	menu_icheck(tmen.m, MNCRLF, w->crlf ? 1 : 0);
}
#endif

global
IT *editor_window(	bool cre, Cstr name, char *info,
					short kind, short fl, short ty,
					char *map, long mapl,
					MENU_DO do_menu, M_S *m_s_menu, EDIT ed_key,
					CLOSED closer, FCLOSE deleter,
					FULLED fuller, TIMER timer,
					WINIT winit
					)
{
	IT *w =
	create_IT	(	cre,		/* true ? incl WIND_CREATE */
					name,
					fl,
					info,
					nil,
					kind | (diagnostics ? INFO : 0),
					ty,
					nil,
					nil,
					nil,
					nil,
					0,
					winit,		/* text init position */
					nil,
					nil,			/* antedraw */
					display,	/* draw function for txt window */
					nil,			/* postdraw */
					text_evm,	/* antevnt */
					text_lines,	/* display lines */
					disp_line,	/* display unit (line) */
					nil,		/* ante display */
					nil,		/* post display */
					closer,
					deleter,
					nil,
					fuller,
					slidewindow,
					v_slider,
					arrowwindow,
					sizewindow,
					movewindow,
					txtsel_button,
					txtsel_keybd,
					ed_key,
					timer,
				#ifdef WMENU
					menu_draw,
					do_menu,
					#ifdef MNCRLF
						set_crlf,
					#else
						nil,
					#endif
					m_s_menu,
				#else
					nil,
					do_menu,
					nil,
					nil,
				#endif
					text_select,
					text_deselect,
					text_wselect,
					std_cursor,
					t_to_s_x,
					x_to_s_t,
					m_kader,
					map,
					mapl,
					deskw.unit,
					0,		/* 07'20 HR v6 */
					deskw.points,
					MINMARGIN,
					txt_margin
                  );
	if (w)
	{
		w->dial_find = dial_find;	/* find/replace functions for binaryfiles */
#if TEXTEDIT
		w->do_repl   = do_repl;		/*  use the same dialogue but different functions */
#endif
#if DRAGSELECTION
		w->drag      = drag_selection;
#endif
	}
	return w;
}

global
STMC * empty(IT *w)	 /* only 1 empty line */
{
	STMC *i = stminsert(w->base,LAST);
	i->xtx  = "****\r\n\0";
	i->x_l   = 4;
	w->view.sz.h = 1;
	i->xn   = 1;
	i->xun  = 1;
	i->xfg  = 0;
	i->xrm  = 0;
	return i;
}

global
char *get_n(Cstr s, size_t l)
{
	if (l <= 50)
	{
		char t[52];
		strsncpy(t,s,l);
		return t;
	}
	else
		return "~";
}

global bool text_char(uchar c)
{
	switch (c)
	{
	case 10:		/* nl */
	case 12:		/* ff */
	case 13:		/* cr */
		return true;
	}
	return c >= 0x20 and c <= 0x7f;
}
global
bool ascii_file(uchar *s, size_t l)
{
	size_t a = 0, na = 0, pa, pna;
	uchar *e = s + l;
	bool t;

	while (s < e)
	{
		if (text_char(*s) )
			a++;
		else
			na++;
		s++;
	}

	pa  = a *100/l;
	pna = na*100/l;
	t = pa > APRCT;

	if (!t)
	{
		pna= na*100/l;

		alert_text("APRCT %d, a %ld, na %ld | l %ld, pa %ld, pna %ld", APRCT, a, na, l, pa, pna);
	}

	return t;
}

global
VpW make_lines
/*  appends naturally to any already existing chain of lines.
 *	That's what stminsert(..,Last) does.
 */
{
	char *s=w->map, *svs;
	short svl;
	char *e=s+w->mapl;
	STMC *i;

	if (abandon_ins) return;
	if (w->loc.split <= 0)
		w->loc.split = MAXL;
	w->view.sz.h = 0;
	while (s <= e)		/* make at least 1 empty cell */
	{

		i=stminsert(w->base,LAST);
		if (i eq 0)
		{
			mem_alert("while reading textfile","Remainder ignored");
			abandon_ins=true;
			m_alerted=false;
			return;
		}

		i->xtx = s;
		i->x_l  = 0;
		w->view.sz.h++;
		i->xn  = w->view.sz.h;
		i->xun = w->view.sz.h;
		i->xfg = ISMAP;
		i->xrm = 0;

		while (     *s ne '\0'
			    and *s ne '\r'
			    and *s ne '\n'
			    and i->x_l < w->loc.split
			   )
		{
			s++;
			i->x_l++;
		}

		if (*s eq 0)		/* allready internally nulled, allow for 2 */
		{
			s++;
			if (s <= e and *s eq 0 and (i->xfg & SGL_0) ne 0)
				s++;

		}
		else
		if (*s eq '\r' or *s eq '\n')
		{				/* internally terminate with \0 */
			if (*s eq '\r') 	/* \r (MS & ATARI) | MAC */
			{
				bool dbl = *(s+1) eq '\n';

				if (w->view.sz.h eq 1)		/* register crlf situation */
				{
					w->crlf = dbl;
#ifdef MNCRLF
					set_crlf(w);
#endif
				}
				elif (!w->crlf)
					set_X(w);

				*s++=0;		/* \r --> 0 */

				if (dbl)
					*s++ = 0;	/* \n --> 0 */
				else
					i->xfg |= SGL_0;	/* room for only 1 line ending character!! */
			othw
				*s++ = 0;		/* single \n UNIX line ending */
				i->xfg |= SGL_0;	/* room for only 1 line ending character!! */
			}
		othw			/* line too long; find space */
			svs = s;
			svl = i->x_l;

			while (*s ne ' ' and *s ne '\t' and i->x_l > 0)
			{
				s--;
				i->x_l--;
			}
			if (i->x_l eq 0)		/* no space found; try any punctuation */
			{
				s = svs;
				i->x_l = svl;
				while(!is_punct(*s) and i->x_l > 0)		/*  Pure C ispunct is a nonsense function */
				{
					s--;
					i->x_l--;
				}
				if (i->x_l)
				{
					uchar c = *s;
					alert_text("line %ld > max|split at pos %ld|loosing puctuation char '%c'", i->xn, i->x_l,c);
				}
			}
			if (i->x_l eq 0)		/* no punctuation found; split at max loosing a char */
			{
				s = svs /*  + w->loc.split */;		/* 09'17 HR: oeps! */
				i->x_l = w->loc.split;
				alert_text("line %ld|split at max(%d)|loosing a char", i->xn, w->loc.split);
			}
			*s++ = 0;
		}
	}
}

global
FULLED text_full	/* (IT *w) */
{
	if ( w->full )		/* all these values are allready snapped */
	{
		w->rem  = w->nfrem;
		w->full = false;
	othw
		short x = w->rem.x;			/* 12'05 keep x the same if possible */
		if (x + w->frem.w > win.w)
			x = win.w - w->frem.w;
		if (x ne w->frem.x)
			w->frem.x = x,
			snapwindow(w, &w->frem);
		w->rem  = w->frem;
		w->full = true;
	}
	wind_set(w->wh, WF_CURRXYWH, w->rem);
	get_work(w);
	w->norm.pos.y =bounce(w, w->norm.pos.y);
	via (w->slider)(w);
	via (w->winfo)(w);
#ifdef PRINFO
	print_it(w, "fullwindow");
#endif
}

global
WINIT txt_winit
{
	w->in = wwa;
	next_upper_left(w,deskw.unit.w,deskw.unit.h,&w->in);
	w->in.w-=WIDIVMAX*deskw.unit.w;
	if (w->in.w > MAX_W)
		w->in.w = MAX_W;			/* for very large screens */
	w->in.h-=WIDIVMAX*half_h();

	get_it(w->wh,-1);

	snapwindow(w,&w->in);	/* !!! gebruikt slechts w->v !!! */
								/* mooi he? */
	w->frem=wwa;

	w->frem.w=(deskw.unit.w*(deskw.fullw+1))+w->v.w /*+w->mg.w*/;
	if (w->frem.w > wwa.w)
		w->frem.w = wwa.w;

	snapwindow(w,&w->frem);		/* snap fulled height */
}

global
short src_type(char * fn)
{
	short stype = SRCE;
	char *pr;

	pr = getsuf(fn);
	if (pr)
		switch (toupper(*pr))
		{
			case 'C': stype = SRC_C; break;
			case 'S': stype = SRC_S; break;
			case 'A': stype = SRC_A; break;
			case 'H': stype = SRC_H; break;
			default: stype = SRCE;
		}

	return stype;
}

/* New since v5.1: needed for diffing (test synchronization) */

global
IT * create_X(Cstr fn, short fl, void *bitmap, long pl)
/* create a IT structure not destined for displaying anything */
{
	return
		create_IT(	false,		/*no WIND_CREATE */
					fn, fl, nil, nil,
					0, SRCE,
					nil, nil, nil, nil,
					0,
					nil, nil, nil, nil, nil,	/* postdraw */
					nil, nil, nil, nil, nil,	/* post display */
					nil, nil, nil, nil, nil,
					nil, nil, nil, nil, nil,
					nil, nil, nil, nil, nil,
					nil, nil, nil, nil, nil,
					nil, nil, nil, nil,
					bitmap, pl,
					deskw.unit,
					0,		/* 07'20 HR v6 */
					deskw.points,
					0,
					nil
                  );
 }

global
IT * open_X(char *fn)
{
	long pl;
	char *bitmap;
	IT *w = nil;
	short fl;

	bitmap = Fload(fn, &fl, &pl, AH_LOAD_FILE);
	if (bitmap)
	{
		w = create_X(fn, fl, bitmap, pl);
		if (w)
		{
			w->view.sz.w = MAXL;			/* max line length (excl \0) */
			txtfreebase=stminit(&w->text,txtfreebase,STMMODE,0,STMS, fn);
			w->base=&w->text;
			make_lines(w);
		othw
			alert_text("NO IT");
		}
	}
	else
		not_found(fn);
	return w;
}

global
void close_X(IT *w)
{
	get_fn_it(w->title.t);		/* make current on winbase */

	if (w->base)
	{
		clearmal(w->base);
		stmclear(w->base);
		w->base=0L;
	}

	ffree(w->map);
	stmdelcur(&winbase);
}

void send_msg(Cstr text, ...);

global
FOPEN open_text	/* (char *fn, short fl, void *q) */
/* fl = 0 : new file, fl = -1 : cached file, -2 clicked cached file */
{
	long pl=0;
	char *bitmap;
	IT *w=nil;
#ifdef SCLIN
	F_CFG *pq = q;
#endif
	if (!fl)							/* " new filename " */
		bitmap=mmalloc(1,"while creating new","Canceled",AH_OPEN_TEXT);
	else
	{
		if (fl > 0)						/* normal case */
			bitmap=Fload(nil,&fl,&pl, AH_LOAD_TEXT); /* 0L: allready open */
		else
		{
			w=get_fn_it(fn);			/* file cached     */
			bitmap=w->map;
			fl=w->fl;
		}
	}

	if (bitmap)
	{
		if (fn)
			if (inq_xfs(fn, nil) eq 0)
				strupr((char *)fn);

#if 0		/* not yet */
		if (!ascii_file((uchar *)bitmap, pl))
		{
			alert_text("'%s' | does not look  | like a text file", fn);
/*			return;		/* or open as binary (see AHCB) */
*/		}
#endif
		if (!w)			/* not cached */
		{
			if ( (w=editor_window(true,				/* + window ? */
							fn ? fn : " no title ",
							" ",
							KIND,
							fn ? fl : -1,
							src_type((char *)fn),
							bitmap,
							pl,
							do_tmenu,
							&tmen,
	#ifdef MTEDITOR
							ed_key,
	#else
							0L,
	#endif
							close_text,			/* closer box */
							close_textfile,		/* close mechanism */
							text_full,
							txt_timer,
							txt_winit
							)
					  ) eq 0L
					)
			{
				alertwindow("text");
				return;
			}
		othw
	#ifdef MTEDITOR
			cursor_undo(w);
	#endif
			if( (w->wh=wind_create(KIND,win.x,win.y,win.w,win.h))
				 < 0)
			{
				alertwindow("text");
				return;
			othw
				wi_title(w);
				if (w->wkind&INFO)
					wind_set(w->wh,WF_INFO,w->info);
			}
		}

		w->view.sz.w = MAXL;			/* max line length (excl \0) */
		/* 05'16 v5.4 use (copied) w->title in stminit */
		txtfreebase=stminit(&w->text,txtfreebase,STMMODE,0,STMS, w->title.t);
		w->base=&w->text;
#ifdef MNUNDO
		/* undo buffer */
		txtfreebase=stminit(&w->undo,txtfreebase,STMMODE,0,STMS, w->title.t);
		w->old=&w->undo;
#endif

#if BOLDTAGS
		w->bc = get_bold(w);
#endif

		make_lines(w);
		if (!fl)
			w->crlf = true;		/* 06'10 HR: new file: default */

#ifdef SCLIN
		if (pq)
		if (pq->loc.lnrs)		/* 06'14 v5.1 */
		{
			w->den    = denotation_space(w->view.sz.h, 10);
			w->mg.w += (w->den + 1) * w->unit.w;
		}
#endif
		open_w(w);	/* put window on screen (includes get_work() & sliders()) */
	}
}

global
CLOSED close_text
{
#if WINDIAL
	if (close_textfile(w,false))		/* do not force */
		if (!w_handles(0L,no_dial))
		/*	close_dials(); */
			set_dialinfs(0L);
#else
	close_textfile(w,false);
#endif
}

