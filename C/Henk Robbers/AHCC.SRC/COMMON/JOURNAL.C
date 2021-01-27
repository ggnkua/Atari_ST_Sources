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

/*
 *	JOURNAL.C
 *
 */

#include <string.h>
#include <ctype.h>
#include <ext.h>
#include "aaaa_lib.h"
#include "hierarch.h"

#include "mallocs.h"
#include "aaaa.h"
#include "kit.h"
#include "text/cursor.h"
#include "text/text.h"
#include "text/text_sel.h"
#include "text/editor.h"
#include "cursor.h"
#include "options.h"
#include "files.h"
#include "journal.h"
#ifdef MNJCALC
#include "F_x.h"
#endif
#ifdef MNJDEP
#include "pdb.h"
#endif
#include "wdial.h"
#include "ahcm.h"

#define MAXTABS 12

M_S jmen={false,0,0,0,0,0,0,0,nil,nil};

XA_memory
	XA_jnl_base = {nil, nil, nil,  8192, 13, 0, 0, 0, nil, nil, "journal messages base"};
char *Journal = " Journal ";
STMDEF jrnl;					/* Journal */
char   *jrnlmap="\0";			/* dummy bitmap */
static
char otxt[50], txt[50];
static
bool journal_created = false;

static
TIMER timer_timer
{
	static short tim=0;
#ifdef MINICONS
	txt_timer(w);
#endif
	if ( ++tim > 15 )			/*	1/4 minuut */
	{
		short i;
		char *t,*v=txt;

		tim=0;
		loop(i,49) *v++=' ';
		*v=0;
		v=txt;
		t=ttijd();
		while (*t ne 0) *v++=*t++;
		if ( strcmp(txt,otxt) ne 0 )
		{
			strcpy(otxt,txt);
			strcpy(w->info, txt);
			wind_set(w->wh,WF_INFO,w->info);
		}
	}
}

global
COPRM do_init_text		/* short *w, short *h, COPRMSG msg */
{
	IT *wi = get_it(-1,JRNL);
	short i=0,j=0;
	while (msg[i])
	{
		short k=strlen(msg[i]);
		if (k > j)
			j = k;
		if (!w)
			ins_text(LAST,wi,msg[i]);
		i++;
	}

	if (w)
		*w=j+1;
	if (h)
		*h=i+1;
}

static
void open_jrnl(short full)
{
	short j;
	IT *w;

	w = get_it(-1,JRNL);
	j = w->wh;

	if ( j > 0 )
	{
		wind_set(j,WF_TOP);
		to_top();
	othw
		if ( (j=wind_create(
					w->wkind,win.x,win.y,win.w,win.h)
			 ) < 0 )		/* NB max grootte */
			alertwindow("the journal");
		else
		{
			w->wh=j;
			w->view.sz.w=MAXL;			/* max output line length (excl \0) */
			w->norm.sz.w=w->ma.w/wchar;
			if (full>0)
			{
				w->nfrem=w->rem;
				w->rem=w->frem;
				w->full=true;
			}
			open_w(w);			/* put window for journal on screen */
								/* (includes get_work() & sliders()) */
			w->norm.pos.y = bounce(w, w->view.sz.h - 1);
		}
	}
}

static
void clearjmal(STMDEF *d)
{
	STMC *nx;

	if (!d)
		return;
	nx = stmfifirst(d);
	while (nx)
	{
		if (!(nx->xfg&ISMAP))
			XA_free(&XA_jnl_base, nx->xtx);
		nx = stmfinext(d);
	}
}

static
FCLOSE deletejrnl
{
	clearjmal(w->base);
	stmclear(w->base);
	close_w(w);
	stmdelcur(&winbase);
	return true;
}

static
CLOSED close_jrnl	/* (IT *w) */
{
	cur_off(w);
	clearjmal(w->base);			/* close the journal clears it */
	stmclear(w->base);
	w->view.sz.h = 0;
	close_w(w);
#if WINDIAL
	if (!w_handles(whs,no_dial))	/* same as in close_text */
	/*	close_dials();	 */
		set_dialinfs(0L);
#endif
}

global
RECT jrect = {0,0,0,0};

static
WINIT jrnl_winit
{
	short cw=0,ch=0;
	if (w->init_text)
		do_init_text(&cw,&ch,*w->init_text);	/* calculate only w & h */

	if (jrect.w eq 0 or jrect.h eq 0)		/* If not configured */
	{
		if (!cw)
			cw=36;								/* usefull defaults */
		w->in.w = cw*deskw.unit.w + w->v.w+w->mgw.w;
		if (!ch)
			ch=11;								/* quarter ST high screen */
		w->in.h = ch*deskw.unit.h + w->v.h+w->mgw.h;

		w->in.x = (wwa.w-w->in.w)/2;
		if (w->in.x < 0)				/* for low res */
			w->in.x = w->unit.w;
		w->in.y = (wwa.h-w->in.h)/2;
		if (w->in.w > wwa.w)			/* for low res */
			w->in.w = wwa.w-w->unit.w;
	othw
		/* gradually try to fit (large) journal into (small) desktop */
		if (jrect.w > wwa.w)
			jrect.w = wwa.w-w->unit.w;
		if (jrect.h > wwa.h)
			jrect.h = wwa.h;
		if (jrect.x + jrect.w > wwa.x + wwa.w)
			jrect.x -= jrect.x + jrect.w - (wwa.x + wwa.w);
		if (jrect.y + jrect.h > wwa.y + wwa.h)
			jrect.y -= jrect.y + jrect.h - (wwa.y + wwa.h);
		if (jrect.x <= 0)
			jrect.x = w->unit.w;
		if (jrect.y < wwa.y)
			jrect.y = wwa.y;

		w->in = jrect;
	}
	snapwindow(w,&w->in);	/* !!! gebruikt slechts w->v !!! */
								/* mooi he? */
	w->frem=wwa;
	w->frem.w = w->in.w;
	w->frem.x = wwa.w - w->frem.w;
	snapwindow(w,&w->frem);		/* snap fulled height */
}

#ifdef  MNJCALC
static
CON_RET tcalc
{
	Token val;
	char *s = line + prompt;		/* v5.2: + prompt */
	parsedef(nil, nil);
	val = F_x(10, 2, s);		/* v5.2: + prompt v5.6 y */
	if (val.t eq NUM)
		send_msg("%g\n",val.v);				/* OK */
	else
		send_msg("Error %d :: %s\n", val.t, val.name);
}

static
CON_RET
calc_undo
{
	con_end(false);
}
#endif

#if defined COFT && (defined MNJDEP || defined MNJFU)
static
void jnl_out(DPP this, DPP root, short flag, short lvl)
{
	void jnl_outer(DPP, DPP, short, short);

	if (this)
	{
		DPP dpd = nil, fd;
		Cstr name = this->data->name;
		bool have = flag eq 0 or (this->data->flags & flag) ne 0,
		     star;

		fd = pdb_find(root, name);

		if (fd)
			dpd = fd->depend;

		if (have)
		{
			star = dpd and (fd->data->flags & TRV_DO) eq 0;

			send_msg("%d>%s%s\n", lvl, name, star ? " *" : "");
			if (dpd)
			{
				if (fd->data->flags & TRV_DO)
				{
					fd->data->flags &= ~TRV_DO;				/* Done */
					jnl_outer(dpd, root, 0, lvl+1);
				}
			}
		}
	}
}

static
void jnl_outer(DPP this, DPP root, short flag, short lvl)
{
	while (this)
	{
		jnl_out(this, root, flag, lvl);
		this = this->dnext;
	}
}

global
void jnl_tree(DPP start, DPP root, short flag)		/* treeview in journal in stead of treeview window */
{
	if (root)
	{
		send_msg("A star indicates a recursion or a repetition.\n");
		pdb_mark(root, TRV_DO, 1);				/* set TRV_DO for all */
		jnl_outer(start, root, flag, 0);
	}
	else
		send_msg("No information present!\nCheck either 'auto dependencies' or 'project help'\n");
}
#endif

static
void do_jFile(IT *w,short mt)	/* w = my top window */
{
	switch (mt)
	{
	#ifdef MNJVOLAT
	case MNJVOLAT:
		cfg.volat=!cfg.volat;
		w->con.volat = cfg.volat;
		options(ttdcfg, OSET);
	break;
	#endif
#ifdef MINICONS
	#ifdef MNJCALC
	case MNJCALC:
		con_input(w, MNJCALC, 0, frstr(JCALC), ">", nil, tcalc, calc_undo);
	break;;
	#endif
#endif
	#ifdef MNJDEP
	case MNJDEP:
		send_msg("\nAuto dependencies for %s:\n", mkfn.s);
		jnl_tree(auto_dependencies,auto_dependencies,TRV_IN);
	break;
	#endif
	#ifdef MNJFU
	case MNJFU:
	{
		if (fun_dependencies)
		{
			Cstr rnm = get_rootname();
			DPP start = pdb_find(fun_dependencies, rnm);
			if (start)
			{
				send_msg("Function tree for %s\n", mkfn.s);
				start->data->flags |= TRV_IN;
				jnl_tree(start, fun_dependencies, TRV_IN);
			}
			else
				send_msg("root function '%s' not present\n", rnm);
		}
		else
			send_msg("No function tree information present\n");
	}
	break;
	#endif
	#ifdef MNJPRI
	case MNJPRI:
		printfile(w);
	break;
	#endif
#if SELECTION and defined MNJPRIS
	case MNJPRIS:
		printselection(w);
	break;
	#endif
	#ifdef MNJCLOSE
	case MNJCLOSE:
		#ifdef WMENU
		wmenu_tnormal(w,MTJ1,true); /* before its gone */
		#endif
		if (w)
			via (w->closed)(w);		/* same as window closebox */
	break;

	case MNJSAVES:
		savemsgfile(w);
	break;
#endif
	}
}

static
ANTEVNT jrnl_evm		/* IT *w; bool w_on, short evmask */
{
#ifdef WINDIAL
	set_dialinfs(w);
#endif
		evmask|=MU_TIMER|MU_M1;
#if (defined GEMSHELL || defined MNMULT)
		evmask|=MU_BUTTON|MU_KEYBD;	/* for completeness (main() must add this) */
#elif defined MINICONS
	if (w_on and w->con.task)			/* if mouse within wa & console task */
		evmask|=MU_BUTTON|MU_KEYBD;
	#if DMFMARK
		evmask|=MU_BUTTON;
	#endif
	if (w_on and w->con.volat)
		evmask|=MU_KEYBD;
#endif
	return evmask;
}

static
MENU_DO do_Jmenu			/* file open allready catered for in main()	*/
{
#ifdef MTSEARCH
	short mtra;
#endif

#ifdef MTJ1
	if ( title eq MTJ1 )
		do_jFile  (w,choice);
#endif

	wmenu_tnormal(w,title,true);	/* the below open a window */

#ifdef MTJS
	if ( title eq MTJS)
	{
	#ifdef MTEDITOR
		if (choice eq MNJCOPY)
			do_Buffer(w,MNCOPY,kstate);
		else
	#endif
	#ifdef MTSEARCH
		switch(choice)
		{
		case MNJFIND:		mtra = MNFIND;		break;
		case MNJFISEL:		mtra = MNFISEL;		break;
		#if defined MNJFISELMPL and defined MNJFISELPRJ
			case MNJFISELMPL: mtra= MNFISELM; break;
#if BIP_CC && defined MNJFISELPRJ
			case MNJFISELPRJ: mtra= MNFISELP; break;	/* 11'09 HR */
#endif
		#endif
		#ifdef MNJHELP
		case MNJHELP:		mtra = MNHELP;		break;
#if BIP_CC && defined MNJUNDO
		case MNJUNDO:
			if (help_stack)
			{
				mtra = MNUNDO;
				break;
			}
			else
				return true;
#endif
		#endif
		case MNJFISAM:		mtra = MNFISAM;		break;
		case MNJFIRSAM:		mtra = MNFIRSAM;	break;
		case MNJSELALL:		mtra = MNSELALL;	break;
#ifdef MNJFICU
		case MNJFICU:		mtra = MNFICU;		break;
#endif
#ifdef MNJFIES
		case MNJFIES:		mtra = MNFIES;		break;
#endif
		default:	return true;
		}
		do_Search(w,mtra);
	#endif
	}
#endif

	return true;
}

#ifdef MINICONS
static
CURSOR no_cur {}

global
void con_end(bool top)
{
	IT *wo,
	   *w=get_it(-1,JRNL);

	w->con.task=0;			/* output to journal ends or cancels a task */
	w->cursor=no_cur;	/* switch off cursor (cannot switch timer)  */
	w->con.stage=0;
	wo=w->con.act_on;
	w->con.act_on=nil;
	w->con.ret_action=nil;
	if (w->con.volat)
	{
		KEYBD con_volatile;
		w->keybd=con_volatile;
	}
	strcpy(w->title.t,Journal);
	wi_title(w);

	if (top)
	if (wo)
	if (wo->wh > 0)
	if (wo->op)
		wind_set(wo->wh,WF_TOP);
}

static
BUTTON con_click		/* w,button,kstate,bclicks,mx,my */
{
	long bx, by;

	xy_to_unit(w, mx, my, &bx, &by);
/*	short bx=mx-w->ma.x+w->unit.w;
	    bx=bx/w->unit.w+w->norm.pos.x;
*/
	if (w->con.task)
	{
		cur_off(w);
		t_to_s_x(w, w->view.sz.h - 1, bx, &w->cu, LOW);
		make_vis_cur(w);
		cur_on(w);
#if DMFMARK
	othw
		bool find_bookmark(IT *w, short x);
		if (w->base)
			if ( find_line(w,(my-w->ma.y)/w->unit.h+w->norm.pos.y) ne nil)
				find_bookmark(w,bx);
#endif
	}
}

static
bool con_cursor(IT *w, short kcode)
{
	short k=kcode&0xff;

	if (kcode&NKF_CTRL)
		return true;
	if (kcode&NKF_SHIFT)
	{
		if (k eq NK_LEFT)
		{
			cur_off(w);
			w->cu.pos.x=w->con.prompt;
			x_to_s_t(w,&w->cu);
			make_vis_cur(w);
			return true;
		}
		elif (k eq NK_RIGHT)
		{
			cur_off(w);
			t_to_s_x(w, w->cu.pos.y, w->view.sz.w, &w->cu, HIGH);
			make_vis_cur(w);
			return true;
		}
	}
	else
	{
		if (k eq NK_LEFT)
		{
			cur_off(w);
			w->cu.scrx--;
			t_to_s_x(w, w->cu.pos.y, w->cu.scrx, &w->cu, LOW);
			if (w->cu.pos.x < w->con.prompt)
			{
				w->cu.pos.x = w->con.prompt;
				x_to_s_t(w,&w->cu);
			}
			make_vis_cur(w);
			return true;
		}
		elif (k eq NK_RIGHT)
		{
			cur_off(w);
			w->cu.scrx++;
			t_to_s_x(w, w->cu.pos.y, w->cu.scrx, &w->cu, HIGH);
			make_vis_cur(w);
			return true;
		}
	}
	return false;		/* not processed */
}

static
void con_key(IT *w, short kcode)
{
	short k = kcode&0xff;
	STMC *s;

	s = find_line(w, w->view.sz.h - 1);		/* this is for w->line */

	if (kcode < 0 and k eq NK_BS)
		if (w->cu.pos.x > w->con.prompt)
			con_cursor(w,NK_LEFT|NKF_FUNC);
		else
			make_vis_top(w);

	if (kcode < 0)
	{
		if ( k eq NK_ESC)
		{
			*(w->line+w->con.prompt)=0;
			s->xrm=w->view.sz.w-w->con.prompt;
			s->xl=w->con.prompt;
			w->cu.pos.x=w->con.prompt;
			x_to_s_t(w,&w->cu);
			if (!make_vis_top(w))
				(*w->disp)(w,s,HIDE);
		}
		elif (    (k eq NK_DEL or k eq NK_BS)
			  and *(s->xtx+w->cu.pos.x) ne 0)	/* dont delete NL */
		{
			char *c,*d;

			d=s->xtx+w->cu.pos.x;
			c=d+1;
			while ( (*d++ = *c++) ne 0);	/* incl NL */
			s->xl-=1;
			s->xrm+=1;
			if (!make_vis_top(w))
				(*w->disp)(w,s,HIDE);
		}
		else
			make_vis_top(w);
	}
	elif (s->xrm > 1 and k)
	{
		short j=s->xl-w->cu.pos.x+1;
		char *c=s->xtx+s->xl;
		char *d=c+1;
		while(j--)
			*d--=*c--;
		*(s->xtx+w->cu.pos.x)=k;
		s->xrm-=1;
		s->xl+=1;

		x_to_s_t(w,&w->cu);
		if (!make_vis_top(w))
			(*w->disp)(w,s,HIDE);		/* + hidem; */
		con_cursor(w,NK_RIGHT|NKF_FUNC);
	}
}

static
KEYBD con_volatile
{
	if (w->con.volat)
	{
		short k = kcode&0xff;
		if (kcode < 0)
			switch (k)
			{
				case NK_RET:
				case NK_ENTER:
				case NK_UNDO:
					close_jrnl(w);
			}
	}
}

static
KEYBD con_keybd    /* IT *w,short kcode */
{
	if (w->con.task)
	{
		short k = kcode&0xff;
		cur_off(w);
		find_line(w, w->view.sz.h - 1);		/* this is for w->line */
		if (kcode > 0 or !con_cursor(w,kcode))	/* cursor handling */
			if (kcode < 0 and (k eq NK_RET or k eq NK_ENTER))
			{
				if (w->con.volat)
					close_jrnl(w);	/* keeps 'IT *w' alive */
				if (w->con.ret_action)
					(*w->con.ret_action)(w->con.act_on,w->line,w->con.prompt,w->con.task,w->con.stage);
#if INTERNAL
				else
					send_msg("No <return> action specified\n");
#endif
				return;
			}
			elif (k eq NK_UNDO)
			{
				if (w->con.volat)
					close_jrnl(w);	/* keeps 'IT *w' alive */
				if (w->con.undo_action)
					(*w->con.undo_action)(w->con.act_on,w->line,w->con.prompt,w->con.task,w->con.stage);
				else
					con_end(true);
			}
			else
				con_key(w,kcode);
		cur_on(w);
	}
}
#endif		/* MINICONS */

#ifdef GEMSHELL
extern
Wstr Error,Warning,Message,Comment,Fatal;	/* from the compiler */
#endif

#ifdef MNFCOMP
extern
Wstr Mismatch, Lone, Diffing;
#endif

extern
Wstr Found, Scanning;


static
char *get_fname(char *f, char *p)
{
	while(*f and *f ne ' ')
		*p++=*f++;
	*p=0;
	return f;
}

global
void open_clicked_file(Cstr fn, short linenr)
{
	long fl;
	IT *wt = get_fn_it(fn);		/* cached */
	if (wt)
	{
		if (!wt->op)
		{
			open_text(fn, -2, &deskw.loc);
			wt = get_fn_it(fn);
		}
		if (linenr > 0)
			goto_line(wt, linenr);
	}
	elif ( (fl = Fopen(fn, 0)) >= 0)
	{
		open_text(fn, fl, &deskw.loc);
		wt = get_fn_it(fn);
		if (linenr > 0)
			goto_line(wt, linenr);
	}
	else
		not_found(fn);
}

/* 07'14 HR v5.1 */
static void close_files(void)
{
	IT *w;
	STMC *ws = stmfifirst(&winbase);
	while (ws)
	{
		STMC *ns = stmfinext(&winbase);

		w = ws->wit;
		if (is_srce(w))
			close_text(w);

		ws = ns;
	}
}

global
BUTTON jrnl_button		/* click in the journal */
{
	char fn[DIRL], *f;
	short linenr=1;

	txtsel_button(w,button,kstate,bclicks,mx,my);

	if (w->selection)
	{
		find_line(w ,w->ss.pos.y);
		f = w->line+w->ss.pos.x;

		if (*(f+1) eq ':' and is_alpha(*f))
		{
			get_fname(f,fn);
			open_clicked_file(fn, 1);
		}
		else
#ifdef GEMSHELL
		if (   strncmp(f,Warning, strlen(Warning) ) eq 0
			or strncmp(f,Error,   strlen(Error)   ) eq 0
			or strncmp(f,Fatal,   strlen(Fatal)   ) eq 0
			or strncmp(f,Message, strlen(Message) ) eq 0
			or strncmp(f,Found,   strlen(Found)   ) eq 0
			or strncmp(f,Comment, strlen(Comment) ) eq 0
			or strncmp(f,Scanning,strlen(Scanning)) eq 0
			)
#else
		if (   strncmp(f,Found,   strlen(Found)   ) eq 0
			or strncmp(f,Scanning,strlen(Scanning)) eq 0
			)
#endif
		{
			if ( (f = strstr(f,"in ")) ne nil)
			{
				f = get_fname(f+3,fn);
				while (*f and *f ne 'L') f++;
				if (*f)
				{
					f++;
					linenr = cdbv(f);
				}

				open_clicked_file(fn, linenr);
			}
		}
#if defined  GEMSHELL && defined OPTBUG
		elif (strncmp(f,"sline", 5) eq 0)
		{
			char *src_name(void);
			char *fn;
			f += 5;
			while (*f and *f ne '#') f++;
			if (*f)
			{
				f++;
				linenr = cdbv(f);
			}

			fn = src_name();
			if (fn)
				open_clicked_file(fn, linenr);
		}
#endif
#ifdef MNFCOMP
		elif (strncmp(f,Mismatch,strlen(Mismatch)) eq 0)
		{
			void sync_lines(IT *w);
			IT * get_second(IT *w, WSELECT *);

			IT *w, *wt;
			close_files();			/* 07'14 HR v5.1 */
			f = get_fname(f+strlen(Mismatch)+1,fn);
			open_clicked_file(fn, 0);		/* 07'14 HR: v5.1 0= line 1 not selected */
			get_fname(f+4,fn);
			open_clicked_file(fn, 0);
			wt = get_top_it();
#if MNTILE
			do_Mode(wt,MNTILE);
#endif
			w = get_second(wt, is_srce);
			w_top(w->wh, w, wt);
			sync_lines(w);			/* 07'14 HR: v5.1 */
		}
		elif (strncmp(f,Lone,strlen(Lone)) eq 0)
		{
			get_fname(f+strlen(Lone)+1,fn);
			open_clicked_file(fn, 0);
		}
#endif
#ifdef MNFDIFF
		/* 09'14 v5.1 */
		elif (strncmp(f,Diffing,strlen(Diffing)) eq 0)
		{
			close_files();
			f = get_fname(f+strlen(Diffing)+1,fn);
			open_clicked_file(fn, 1);
			get_fname(f+4,fn);
			open_clicked_file(fn, 1);
#if MNTILE
			do_Mode(w,MNTILE);
#endif
		}
#endif
#if MNFKEYS
		elif (strncmp(f, "Function", 8) eq 0)
		{
			STMC *sp = stmfiprior(&winbase);
			if (sp)
			{
				IT *w = sp->wit;
				if (w)
				if (w->wh > 0)
				if (w->op)
				if (is_text(w))
				{
					while (*f and !isdigit(*f)) f++;
					if (*f)
					{
						short key = cdbv(f) - 1;
						if (key >= 0 and key < FKS)
						{
							wind_set(w->wh, WF_TOP);
							insert_fkey(w, key);
						}
					}
				}
			}
		}
#endif
	}
}

global
void init_jrnl(COPRMSG *init_text, DIALFI find, short full)
{
	short i;
	IT *w;

#if DIGGER
	TOPPED top_jrnl;
#endif

	loop(i,49)
		otxt[i]=' ';
	otxt[i]=0;	/* tbv tijd */

	if	( (w=create_IT(
					false,		/* no WIND_CREATE */
					Journal,
					0,
					ttijd(),
					init_text,
					KIND|INFO,
					JRNL,
					nil,
					nil,
					nil,
					nil,
					0,
					jrnl_winit,		/* text init position */
					nil,
					nil,			/* antedraw */
					display,	/* draw function for txt window */
					nil,			/* postdraw */
					jrnl_evm,	/* antevnt */
					text_lines,
				#if (defined GEMSHELL || defined MNMULT)
					disp_line,
				#else
					disp_nosel,
				#endif
					nil,		/* ante display */
					nil,		/* post display */
					close_jrnl,
					deletejrnl,
				#if DIGGER
					top_jrnl,	/* for background clicking of bookmarks */
				#else
					nil,		/* default topping */
				#endif
					text_full,
					slidewindow,
					v_slider,
					arrowwindow,
					sizewindow,
					movewindow,

				#ifdef GEMSHELL
					jrnl_button,
					do_keybd,
					ed_key,
				#elif defined MNMULT
					jrnl_button,
					do_keybd,
					nil,
				#elif defined MINICONS
					con_click,
					#if defined MNJVOLAT
						con_volatile,
					#else
						nil,		/* con_keybd if minicon task on	*/
					#endif
					nil,		/* no special ed_key			*/
				#else
					nil,nil,nil,
				#endif

					timer_timer,
				#ifdef WMENU
					menu_draw,
					do_Jmenu,
					nil,
					&jmen,
				#else
					nil,
					do_menu,
					nil,
					nil,
				#endif
				#if defined GEMSHELL || defined MNMULT
					text_select,
					text_deselect,
					text_wselect,
					std_cursor,
				#else
					nil,nil,nil,		/* no selection */
					nil,     		/* if minicons task on */
				#endif
					t_to_s_x,
					x_to_s_t,
					m_kader,
					0,
					nil,

					deskw.unit,
					deskw.points,
					txt_margin
                   )
				)
		   eq nil
		 )
	{
		form_alert(1,frstr(IW));
		eruit(1);
	}

	w->base=&jrnl;
	txtfreebase=stminit(&jrnl,txtfreebase,STMMODE,0,STMS, "Journal");
	w->old=nil;
	w->dial_find = find;

	w->loc = deskw.loc;
	w->loc.boldtag = false;
	w->loc.lnrs = false;
	w->loc.trail = false;

	if (w->init_text)
		do_init_text(nil,nil,*w->init_text);
	else
		ins_text(LAST,w,"");	/* no empty chain */

#ifdef MNJVOLAT
	if (jmen.m[MNJVOLAT].state&CHECKED)	/* initial state or after setoptions() */
		w->con.volat=true;
#endif
#if DRAGSELECTION
		w->drag = drag_selection;
#endif

	journal_created = true;
	if (init_open_jrnl and w->init_text)
		open_jrnl(full);
}

extern
char msg_buf[];
extern
short  msg_l;

typedef enum
{
	BAK,TOP,STO
} MSGMODE;

static
STMC *ins_msg(IT *w, short *jbl, char *jb, MSGMODE top)
{
	STMDEF *b;
	STMC *st;
	char *mal,*s;
	short l;

	if (!journal_created)
		return nil;

	if (!w or abandon_ins)		/* !w (eruit: no more JRNL msgs) */
		return nil;

	s=jb;
	b=w->base;
	while (*s)
	{
		static short tabtel=0;
		char *sn=s;
		l=0;
		st=nil;

		while (*s and *s ne '\n' and l <= MAXL)
		{
			if (*s eq '\t')
				if (++tabtel eq MAXTABS)
				{
					*s='\n';
					break;		/* force new line */
				}
			s++;
			l++;
		}

		tabtel=0;

		if (*s)					/* newline or MAXL found */
		{
			mal = XA_alloc(&XA_jnl_base, l + 1, nil, AH_INS_MSG, 0);
			if (mal)
				if ( (st=stminsert(b,LAST)) ne nil)
				{
					st->xtx=mal;
					strmaxcpy(mal,sn,l);
					st->xl=l;
					st->xfg=ISMOD;
					st->xty=0;
					st->xrm=0;
					st->xun=0;
				}

			if (*s eq '\n')
				s++, l++;				/* skip newline if there */

			if (!st)
			{
				mem_alert(w->ty eq JRNL
							? "while appending journal"
							: "while appending output", "Ignored");
				abandon_ins=true;
			othw
				m_alerted=false;

				if (w->ty ne JRNL or top eq STO)
				{
					w->view.sz.h += 1;
					st->xn  = w->view.sz.h;
					w->lsto = true;
				othw
					/* if less than fits a window or not bottom aligned
						or not top_window
						or not open */

					if (w->wh < 0)
					{
						short twh;
						IT *wt = get_top_it();
						open_jrnl(-1);		/* also sets w->n (renum()) */
						w->norm.pos.y = bounce(w, w->view.sz.h - 1);
						via(w->slider)(w);
						do_redraw(w,w->wa);
						if (top eq BAK)
						{
							if (wt eq nil)
							{
								wind_get(0,WF_TOP,&twh);
								if (twh ne w->wh)
									wind_set(twh,WF_TOP);
							}
							elif (w ne wt)
								wind_set(wt->wh,WF_TOP);
						}
					}
					else
					if (top eq BAK)
					{
						w->view.sz.h += 1;
						st->xn = w->view.sz.h;
						w->norm.pos.y = bounce(w, w->view.sz.h - 1);
						via(w->slider)(w);
						do_redraw(w,w->wa);
					}
					else			/* force journal on top */
					if (get_top_it() ne w)
					{
						w->view.sz.h += 1;
						st->xn=w->view.sz.h;
						wind_set(w->wh,WF_TOP);
						to_top();
						w->norm.pos.y = bounce(w, w->view.sz.h - 1);
						via(w->slider)(w);
						do_redraw(w,w->wa);
					}
					else			/* is on top */
					if (w->view.sz.h < w->norm.sz.h and w->norm.pos.y eq 0 and !w->lsto)  /* and nicely aligned */
					{
						w->view.sz.h += 1;
						st->xn = w->view.sz.h;
						(*w->disp)(w, st, HIDE);
					}
					else
					if (w->view.sz.h < w->norm.sz.h or w->norm.pos.y+w->norm.sz.h ne w->view.sz.h)
					{							/* probably scrolled to some place */
						w->view.sz.h += 1;
						st->xn=w->view.sz.h;
						w->norm.pos.y = bounce(w, w->view.sz.h - 1);
						via(w->slider)(w);
						do_redraw(w,w->wa);
					}
					else			/* on top and fully visible */
					{
						w->view.sz.h += 1;
						st->xn=w->view.sz.h;
						via(w->arrowd)(w, WA_DNLINE, true);	/* just rack up */
					}
					w->lsto = false;

					#if WAIT
						Cconin();
					#endif
				}
			}
			strncpy(jb,s,(2*MAXL)-l);
			s=jb;
			*jbl-=l;
			if (*jbl < 0)
				*jbl=0;
		}
	}
#ifdef MINICONS
	if (w->ty eq JRNL)
		con_end(false);	/* output to journal clears a task */
/* multi_stage tasks must be done with repeated con_input()'s */
#endif

	return st;
}

global
char msg_tab[] = "\t";

/* Called by shell & built_in compilers main */
/* if compiler is .TTP this fu is different from 'console'
	and both are in TTP_IO.C */
global
void send_msg(char *text, ...)
{
#ifdef GEMSHELL
extern
FILE *bugf;
#endif

	va_list argpoint;
	va_start(argpoint,text);

#ifdef GEMSHELL
	if (bugf ne stdout or !journal_created)
	{
		if (    * text      eq '%'
		    and *(text + 1) eq 'd'
		    and *(text + 2) eq '>'
		   )
		{
			short lvl = va_arg(argpoint, short);
			while (lvl--)
				fprintf(bugf, msg_tab);
			text += 3;
		}
		vfprintf(bugf,text,argpoint);
	}
	else
#endif
	{
		if (    * text      eq '%'
		    and *(text + 1) eq 'd'
		    and *(text + 2) eq '>'
		   )
		{
			short lvl = va_arg(argpoint, short);
			while (lvl--)
				msg_l+=sprintf(msg_buf+msg_l, msg_tab);
			text += 3;		/* this keeps it compatible
			                   if you use the format string in a other
			                   environment simply nnnn> is printed */
		}
		msg_l+=vsprintf(msg_buf+msg_l,text,argpoint);
		ins_msg(get_it(-1,JRNL),&msg_l,msg_buf,TOP);
	}
	va_end(argpoint);
}

global
void send_msg_n(char *text, ...)
{
	va_list argpoint;
	va_start(argpoint,text);

	if (!journal_created)
		return;

	msg_l+=vsprintf(msg_buf+msg_l,text,argpoint),
	ins_msg(get_it(-1,JRNL),&msg_l,msg_buf,BAK);	/* does not top the journal */

	va_end(argpoint);
}

global
void store_msg(char *text, ...)			/* just store in jrnl text chain */
{
	va_list argpoint;
	va_start(argpoint,text);

	if (!journal_created)
		return;

	msg_l+=vsprintf(msg_buf+msg_l,text,argpoint),
	ins_msg(get_it(-1,JRNL),&msg_l,msg_buf,STO);	/* store only in the journal text chain */

	va_end(argpoint);
}

global
short alert_jrnl(char *text, ...)
{
	va_list argpoint;
	va_start(argpoint,text);
	{
		IT *w=get_it(-1,JRNL);
		msg_l+=vsprintf(msg_buf+msg_l,text,argpoint);
		*(msg_buf+msg_l++)='\n';
		*(msg_buf+msg_l)='0';
		ins_msg(w,&msg_l,msg_buf,TOP);
/* the freestrings for which this fu is designed need not have a 'little bell' added. */
	}
	va_end(argpoint);
	return 1;
}

#ifdef MINICONS

global
void con_input(IT *on,short task,short stage,
				char *msg, char *prompt, char *deflt,
				CON_RET *ret_action,
				CON_RET *undo_action)
{
	STMC *st; short ml=0, i;
	IT *w=get_it(-1,JRNL);
	char inpline[MAXJ+1];
	char * ret;

	inpline[0]=0,
	w->con.prompt = 0;

	if (msg)
		send_msg("%s\n",msg);

	if (prompt)
		strcpy(inpline,prompt),
		w->con.prompt = strlen(prompt);

	if (deflt)
		strcat(inpline,deflt);

	ml=strlen(inpline);

	for (i=ml;i<MAXJ;i++)
		inpline[i]=' ';		/* spaces are overflow room */

	inpline[MAXJ]=0;		/* v4.15 */
	send_msg("%s\n",inpline);

	strcpy(w->title.t," Console ");
	wi_title(w);

	st = find_line(w, w->view.sz.h - 1);
	st->xl = ml;
	ret = w->line + ml;
	*ret=0;
	st->xrm=MAXJ-ml;
	w->cu.pos.y = w->view.sz.h - 1;
	w->cu.pos.x = w->con.prompt;				/* cursor on first ch of default part of line */
	x_to_s_t(w, &w->cu);
	w->con.task=task;			/* activates events */
	w->con.stage=stage;
	w->con.act_on=on;
	w->con.ret_action =ret_action;
	w->con.undo_action=undo_action;
	w->cursor=std_cursor;		/* standard cursor */
	w->keybd=con_keybd;
	if (deflt)					/* v5.2 */
	{
		strcpy(w->con.remember, deflt);
		if (on)
			strcpy(on->con.remember, deflt);
	}
}
#endif

/* Called by built_in compilers main */

global
void console(char *text, ...)
{
	extern FILE *bugf;
	va_list argpoint;
	va_start(argpoint,text);

	if (bugf ne stdout or !journal_created)
		vfprintf(bugf,text,argpoint);
	else
	{
		msg_l+=vsprintf(msg_buf+msg_l,text,argpoint);
		ins_msg(get_it(-1,JRNL),&msg_l,msg_buf,TOP);
	}
	va_end(argpoint);
}
