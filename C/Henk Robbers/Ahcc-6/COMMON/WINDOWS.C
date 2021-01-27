/*  Copyright (c) 1992 - present by Henk Robbers Amsterdam.
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

/*	WINDOWS.C
 *	=========
 *
 *	window library for GEM programs using IT.
 */

#include <string.h>
#include <limits.h>

#include "aaaa_lib.h"
#include "hierarch.h"

#include "aaaa.h"
#include "text/text.h"
#include "wdial.h"
#include "ahcm.h"

void send_msg  (char *text, ...);
void send_msg_n(char *text, ...);

#ifdef COFT
#include "treeview.h"
#endif

global
short whs[256];					/* for use with w_handles() */

global
CINF cnil = {{0,0},0,0,0};

global
void alertwindow(char *opm)
{
	alertm(frstr(WINOP),opm);
}

/* only if you have both AES and own menu, and you need to bridge */
global
short wmenu_tnormal(IT *w,short i, short state)
{
	short r;
	if (w eq &deskw)
	{
		w->menu->mn=i;
		return menu_title(w->menu,state);
	othw
		w->menu->mn=i;
		r=menu_title(w->menu,state);
		w->menu->mn=0;
		return r;
	}
}

global
WSELECT is_drop
{
	return w and w->ty eq DROP;
}

global
WSELECT is_text		/* (IT *w) */
{
	return w->ty >= DIALM and w->ty < TEXTM;
}

global
WSELECT is_sheet
{
	return w->ty >= TEXTM and w->ty < WKSM;
}

global
WSELECT is_dial
{
	return w and (w->ty < DIALM or is_sheet(w));
}

global
WSELECT no_dial
{
	return w and w->ty >= DIALM and !is_drop(w);
}

global
WSELECT for_tile
{
	return w and w->ty >= SRCE and w->ty < DROP;
}

global
WSELECT is_buf
{
	return w->ty eq BUFF;
}

global
WSELECT is_jrnl
{
	return w->ty eq JRNL;
}

global
WSELECT is_srce
{
	return w->ty >= SRCE and w->ty < TEXTM;
}

global
WSELECT is_mand
{
	return w->ty eq MAND;
}

global
WSELECT is_object
{
	return w->ty >= OBJ and w->ty < OBJM;
}

global
WSELECT no_graphic
{
	return w->ty < WKSM or w->ty >= GRAPHM;
}

global
WSELECT is_graphic
{
	return w->ty >= WKSM and w->ty < GRAPHM;
}

global
WSELECT is_bin
{
	return w->ty >= BIN and w->ty < BINM;
}

global
WSELECT is_file
{
	return      (w->ty >= DIALM and w->ty <= BIN)
	       and !(w->ty eq BUFF  or  w->ty eq JRNL)
#if DIGGER
	       and !(w->ty >= OBJ + MNDISK and w->ty < OBJM)
#endif
	       ;
}

global
WSELECT is_trv
{
	return w->ty >= TRV and w->ty < TRVM;
}

global
IT *get_it(short wh,INFO_T ty)
{
	STMC *ws;
	IT *w;

	ws=stmfifirst(&winbase);

	while (ws)
	{
		w=ws->wit;
		if (   (wh > 0 and w->wh eq wh)
			or (ty > 0 and w->ty eq ty)
		   )
			return w;
		ws=stmfinext(&winbase);
	}

	return nil;
}

global
IT *is_it(IT *w)
{
	STMC *ws;

	ws = stmfifirst(&winbase);

	while (ws)
	{
		if (w eq ws->wit)
			return w;
		ws = stmfinext(&winbase);
	}

	return nil;
}

global
void to_top(void)			/* move current winfo to top */
{
	stmmove(&winbase,&winbase,LAST);
	stmrenum(&winbase,nil);
}

global
void to_bottom(void)
{
	stmmove(&winbase,&winbase,FIRST);
	stmrenum(&winbase,nil);
}

/* Find free upper left position.
 * There is allways one !!
 * The function uses the work are pointers because these can change.
 * So if a window is moved from a start position, a further window can be put
 * on the position that is now free. That gives a very natural look.
 * Of course this has only sense if the work area is allways snapped on
 * multiples of dx and dy.
 */
global
void next_upper_left(IT *nw, short dx, short dy, RECT *in)
{
	short sx = wwa.x-nw->v.x,
		sy = wwa.y-nw->v.y;

	do{
		bool occupied = false;
		STMC *ws = stmfifirst(&winbase);
		while (ws)
		{
			IT *w = ws->wit;
			if (	w ne nw
				and !is_drop(w)
				and (w->wa.x eq sx or w->wa.y eq sy)
				)
			{
				occupied = true;
				sx+=dx;
				sy+=dy;
				break;
			}
			ws = stmfinext(&winbase);
		}

		if (!occupied)
		{
			in->x = sx+nw->v.x;
			in->y = sy+nw->v.y;
			return;
		}
	}od
}

global
IT *get_top_it(void)
{
	short h;
	IT *w;
	wind_get(0,WF_TOP,&h);	/* what's REALLY the top window */

	w = get_it(h,-1);		/* find MY window info */
	if (w)
		to_top();			/* synchronization. (convergent programming) */
	return w;
}

global
IT *get_fn_it(Cstr fn)
{
	IT *w;
	STMC *ws=stmfifirst(&winbase);

	while (ws)
	{
		w=ws->wit;
		if (stricmp(fn, w->title.t) eq 0)
			return w;

		ws=stmfinext(&winbase);
	}

	return nil;
}

global
void wi_title(IT *w)
{
	char *t = w->title.t;

	if (w->title.x ne ' ') t = &w->title.x;
	if (w->title.u ne ' ') t = &w->title.u;	/* title.u before title.x */
	if (w->title.v ne ' ') t = &w->title.v;	/* title.v before title.u */
	if (w->wh > 0)
		wind_set(w->wh, WF_NAME, t);
}

global
void set_U(IT *w)
{
	if (w->title.u ne 'U')
	{
		w->title.u='U';
		wi_title(w);
	}
}

global
void set_X(IT *w)
{
	if (w->title.x ne '*')
	{
		w->title.x='*';
		wi_title(w);
	}
}

#if WKS
global
void set_V(IT *w)
{
	switch (w->wks.Ver)
	{
		case 0:						/* 07'17 HR */
		if (w->title.v ne 'O')
		{
			w->title.v = 'O';
			wi_title(w);
		}
		break;
		case 1:
		if (w->title.v ne 'N')
		{
			w->title.v = 'N';
			wi_title(w);
		}
		break;
		case 2:
		if (w->title.v ne 'T')
		{
			w->title.v = 'T';
			wi_title(w);
		}
		break;
	}
}
#endif

global
short w_handles(short whs[],WSELECT *te_sel) /* te_sel = nil; select all */
{										 /* whs = nil; only count */
	short i=0;
	STMC *ws=stmfifirst(&winbase);
	while (ws and i < WIDIVMAX)
	{
		IT *w=ws->wit;
		if (w->op and (!te_sel or (te_sel and (*te_sel)(w)) ) )
		{
			if (whs)
				whs[i]=w->wh;
			i++;
		}
		ws = stmfinext(&winbase);
	}
	return i;
}

global
void renum(IT *w)
{
	long av = stmrenum(w->base,&w->view.sz.h);
	if (w->view.sz.h)
		av /= w->view.sz.h;
	if (av)
		w->avrg=av/2;
	else
		w->avrg = 10;
	if (w->cu.pos.y > w->view.sz.h - 1)
		w->cu.pos.y = w->view.sz.h - 1;
}

global
RECT lower_right(RECT in)
{
	short iw = in.x + in.w,
		ih = in.y + in.h,
		aw = wwa.x + wwa.w,
		ah = wwa.y + wwa.h;

	if ( iw > aw )
		in.w -= iw - aw;
	else
		in.x += aw - iw;

	if ( ih > ah )
		in.h -= ih - ah;
	else
		in.y += ah - ih;

	return in;
}

/* snap on my ma */
global
void snapwindow(IT *w,RECT *sn)
{
	short nx,nw,nh;

	if (w->snap)
	{
		nx=sn->x - w->v.x;
		nx/=CHAR_BIT;
		nx*=CHAR_BIT;

		/* difference with CHAR_BIT of the little margin
			included in mg that makes the w not mult of CHAR_BIT
			to keep it free from left screen edge */
		if (w->mg.w or nx <= 0)
			nx+=CHAR_BIT-(w->mg.w mod CHAR_BIT);
		sn->x=nx + w->v.x;
	}

	/* we don't change sn->y */

	/* Note that w->v is obtained by merely subtracting WORKXYWH
	   from CURRXYWH,
	   where w->mg is deliberately stated in absolute numbers
	   which mean the real width cq height of the 4 borders
	   and NOT differences as in w->v
	*/

	nw=sn->w - w->v.w - w->mg.w;
	nw/=w->unit.w;
	nw*=w->unit.w;
	sn->w=nw + w->v.w + w->mg.w;

	nh=sn->h - w->v.h - w->mg.h;
	nh/=w->unit.h;
	nh*=w->unit.h;
	sn->h=nh + w->v.h + w->mg.h;
}

global
RECT overlap(void)
{
	short srcopen, h_h = half_h();
	RECT in = wwa;

	in.x = win.x;
	srcopen =w_handles(nil,is_srce);
	srcopen+=w_handles(nil,is_sheet);
	in.x+=(srcopen mod WIDIVMAX)*h_h;
	in.y+=(srcopen mod WIDIVMAX)*h_h;
	in.w-=WIDIVMAX*h_h;
	if (in.w > MAX_W)
		in.w = MAX_W;			/* for very large screens */
	in.h-=WIDIVMAX*h_h;
	return in;
}

static
CURSOR no_cur {}
global

RECT
nomargin = {0,0,0,0};

global
void w_vhl(IT *w, short vhl)
{
	if (w)
	{
		if   (vhl  > 0)
			w->vhl = vhl;			/* 07'20 HR v6: use given handle */
		elif (vhl  < 0)				/* 07'20 HR v6: open a workstation for this window */
			w->vhl = deskw.vhl;
		else
			w->vhl = open_vwk(1,w->title.t, nil, nil);
	}
}

global
IT *create_IT(
				bool		with_w,
				Cstr 		name,
				short 		fl,
				char *		info,
				COPRMSG		*init_text,
				short 		wkind,
				INFO_T		ty,
				void  *		root,
				Cstr 		pname,
				OBJECT *	ob,
				OB_PLACE	place,
				short 		item,
				WINIT		winit,
				DEXIT		wdial_do,
				DRAW		antedraw,
				DRAW		draw,
				DRAW		postdraw,
				ANTEVNT		antevnt,
				LINES       lines,
				DISP		disp,
				DISPH		dha,
				DISPH		dhp,
				CLOSED		closew,
				FCLOSE		fclose,
				TOPPED		topw,
				FULLED		fullw,
				SLIDE		slidew,
				SLIDER		slider,
				ARROWD		arrow,
				SIZED		sizew,
				MOVED		movew,
				BUTTON		buttonw,
				KEYBD		keyw,
				EDIT		ed_key,
				TIMER		timer,
				DRAWM		window_menu,
				MENU_DO		do_wmenu,
				MENU_SET	set_menu,
				M_S *		menu,
				SELECT		sel,
				DESELECT	desel,
				XSELECT		wsel,
				CURSOR		do_cur,
				CINFI		ci,
				CINFO		co,
				MUIS		amouse,
				void *		bitmap,
				long		mapl,
				WH    		unit,
				short		vhl,		/* 06'20 HR v6 */
				short 		points,
				short		minmargin,
				MARGIN		do_margin
			)
{
	IT *w=nil;
	STMC  *ws;
	short wh = -1;
	if (with_w)
		wh=wind_create(wkind,win.x,win.y,win.w,win.h);	/* NB max grootte */
/* You can use wind_calc() without the need for an existing window */
	if ( wh >= 0 or !with_w)
	{
		ws=stminsert(&winbase,LAST);
		if (ws)
		{	w=ws->wit;
			stmrenum(&winbase,nil);
		othw
			mem_alert("while creating window_info","Action abandoned.");
			m_alerted=false;	/* must alert everytime */
		}

		pzero(w);

		w->cu = c1st;
#if MNUNDO
		w->u.cu = c1st;
#endif
		w->magic1 = w->magic2 = ITMAGIC;

		w->ty= ty;
		w->plain = false;		/* dfault: only special keys in menu */
		w->title.filler=' ';
		w->title.v=' ';
		w->title.x=' ';
		w->title.u=' ';
		w->unit = unit;
		w->map  = bitmap;
		w->mapl = mapl;
		w->points = points;
		w->mg.w = minmargin;
		w->do_margin = do_margin;
		w->op = false;	/* open komt later */
		w->wh = wh;		/* bovendien genereert wind_open een redraw event  */
		w->snap = true;	/* We either allways snap or never */
		w->fl = fl;

		if (menu)
		{
			w->draw_menu=window_menu;		/* draws window menu */
			w->menu=menu;				/* window menu info */
			w->menu->wh = wh;			/* window handle */
			w->do_menu=do_wmenu;			/* handles window menu */
			w->set_menu=set_menu;
		}

#if FILES
		strmaxcpy(w->title.t, name, DIR_MAX);		/* internal security: 128 */
		if (info)								/* 10'12 HR: check!! v4.15 */
			strmaxcpy(w->info,  info, DIR_MAX);
#endif
		w->wkind=wkind;
		wind_calc(WC_WORK,wkind,win.x,win.y,win.w,win.h,&w->c.x,&w->c.y,&w->c.w,&w->c.h);

		if (w->draw_menu and (MENU_M))
		{
			w->c.y+=MENU_H;			/* is for height menu bar */
			w->c.h-=MENU_H;
		}

		w->v.x=win.x-w->c.x;		/* bereken afmetingen omranding */
		w->v.y=win.y-w->c.y;
		w->v.w=win.w-w->c.w;
		w->v.h=win.h-w->c.h;
		w->vsls=1;
		w->hsls=1;

		if (with_w)
		{
			wind_set(w->wh,WF_VSLSIZE,w->vsls);
			wind_set(w->wh,WF_VSLIDE, w->vslp);
			wind_set(w->wh,WF_HSLSIZE,w->hsls);
			wind_set(w->wh,WF_HSLIDE, w->hslp);
		}

	#if WINDIAL or WIN_OB
		w->dial.exit = wdial_do;
		w->dial.ob=ob;				/* before winit */
		w->dial.place=place;
		w->dial.item=item;

		if (ob)
		#if KIT
			wdial_edob(w, edcur ? edcur : first_edob(ob));
		#else
			wdial_edob(w, first_edob(ob));
		#endif
	#endif
		w->init_text=init_text;
#ifdef COFT
		w->trv.dp = root;
		w->trv.prj = pname;
#endif
		via (winit) (w);		/* calculate w->in & w->frem (uses w->ob) */
		else
		{
			w->in = wwa;
			w->in.x = win.x;
			w->frem = w->in;
		}
		w->rem     =w->in;			/* remember = initieel  */
		w->nfrem   =w->in;			/* remember niet FULLED = initieel */
	#if WINDIAL or WIN_OB
	if (ob and w->dial.edob)
		wdial_itotmpl(w);			/* after winit */
	#endif
		if (with_w)
		{	if (wkind&INFO)
				wind_set(w->wh,WF_INFO,w->info);
			wi_title(w);
		}
		w->full    = false;
		w->antedraw= antedraw;
		w->draw    = draw;
		w->postdraw= postdraw;
		w->antevnt = antevnt;
		w->lines   = lines;
		w->disp    = disp;
		w->dha     = dha;
		w->dhp     = dhp;
		w->closed  = closew;
		w->close_file=fclose;
		w->topped  = topw;
		w->fulled  = fullw;
		w->slide   = slidew;
		w->slider  = slider;
		w->arrowd  = arrow;
		w->sized   = sizew;
		w->moved   = movew;
		w->button  = buttonw;
		w->keybd   = keyw;
		w->edit    = ed_key;
		w->timer   = timer;
		w->select  = sel;
		w->deselect= desel;
		w->wselect = wsel;
		w->cursor  = do_cur ? do_cur : no_cur; /* security measure (cur_on/cur_off are macro's) */
		w->cinf_upd = co;
		w->upd_cinf = ci;
		w->muisvorm= amouse;
#if TEXTFILE || BINED
		w->loc     = deskw.loc;		/* local options */
#endif
		w->vhl     = virt_handle;
		w->fullw   = deskw.fullw;	/* default sizes */
		w->color   = BLACK;	/* selection color default */
	}
	return w;
}

global
SCRL_VAL h_and_v		/* IT *w, short *hv, short *vv, short *htv,short *vtv */
{	short h,v,ht,vt;

	if (w->loc.scv.m1)
		v=w->norm.sz.h;
	else
		v=(w->norm.sz.h*w->loc.scv.grtel)/w->loc.scv.grnoem;

	if (w->loc.sch.m1)
		h=w->norm.sz.w;
	else
		h=(w->norm.sz.w*w->loc.sch.grtel)/w->loc.sch.grnoem;

	ht=w->loc.sch.arrow;
	vt=w->loc.scv.arrow;

	if (!h)  h=w->norm.sz.w/2;
	if (!v)  v=w->norm.sz.h/2;

	if (!ht) ht=w->loc.tabs;		/* defaults */
	if (!vt) vt=1;

	*hv=h;
	*vv=v;
	*htv=ht;
	*vtv=vt;
}

global
void clear_all_margins(IT *w)
{
	if (w->mg.w)
		pbox(w->vhl,w->wa.x,
				    w->wa.y,
				    w->ma.x-1,
				    w->wa.y+w->wa.h-1);
	if (w->mg.h)
		pbox(w->vhl,w->ma.x,
				    w->wa.y,
				    w->ma.x+w->ma.w-1,
				    w->ma.y-1);
}

global
void clear_margin(IT *w)
{
	if (w->mg.w)
		pbox(w->vhl,w->wa.x,
				    w->wa.y,
		            w->wa.x+w->mg.w,			/* 06'14 v5.1 */
				    w->ma.y+w->ma.h-1);
}

global
void get_work(IT *w)
{
	wind_get(w->wh,WF_WORKXYWH,&w->wa.x,&w->wa.y,&w->wa.w,&w->wa.h);

	w->ma.x=w->wa.x + w->mg.w;
	w->ma.w=w->wa.w - w->mg.w;
	w->ma.y=w->wa.y + w->mg.h;
	w->ma.h=w->wa.h - w->mg.h;
	w->inf.x=w->wa.x+w->unit.w;
	w->inf.y=w->wa.y-(INFO_H-1);
	w->inf.w=w->rem.w;
	w->inf.h=(w->wkind&INFO) ? INFO_H-1 : 0;

#if WINDIAL or WIN_OB
	via (w->dial.place)(w);
	wdial_edob(w, w->dial.edob);
#endif

#ifdef WMENU
	if (w->draw_menu)
	{
		w->men.x=w->wa.x;
		w->men.y=w->wa.y;
		w->men.w=w->wa.w;
		w->men.h=MENU_H;
		w->wa.y+=w->men.h;
		w->wa.h-=w->men.h;
		w->ma.y+=w->men.h;
		w->ma.h-=w->men.h;
	}
#endif

	w->norm.sz.w=w->ma.w/w->unit.w;
	w->norm.sz.h=w->ma.h/w->unit.h;

#ifdef TREEWIN
	if (is_trv(w))
	{
		w->view.sz.h = 0;
		w->norm.sz.w = 0;
		trv_linenrs(w,w->trv.root);
	}
#endif
}

global
void close_w(IT *w)
{
#if TEXTFILE || BINED
	if (w->loctab)
		xfree(w->loctab);
#endif
	if (w->wh > 0)
	{
		M_S *mn = w->menu;
		if (mn)
			mn->valid = false;
		if (w->op)
			wind_close (w->wh);
		wind_delete(w->wh);
#if VWWL	/* 06'20 HR v6 */
		if (w->vhl > 0 and w->vhl ne deskw.vhl and  w->vhl ne virt_handle)
		{
			v_clsvwk(w->vhl);
			w->vhl = -1;
		}
#endif
	}
	w->op=false;
	w->wh=-1;
}

global
short open_w(IT *w)
{
	get_it(w->wh,-1);				/* make current */
#if VWWL
	if (!w->vhl)
		w_vhl(w, 0);
#endif
	wi_title(w);
	if (w->wkind&INFO)
		wind_set(w->wh,WF_INFO,w->info);
	wind_set(w->wh,WF_VSLSIZE,w->vsls);		/* If you know them beforehand, they used */
	wind_set(w->wh,WF_VSLIDE, w->vslp);
	wind_set(w->wh,WF_HSLSIZE,w->hsls);
	wind_set(w->wh,WF_HSLIDE, w->hslp);
#ifdef WMENU
	w->menu->vhl = w->vhl;		/* 07'20 HR: v6 */
#endif
	w->op = wind_open(w->wh, w->rem.x, w->rem.y, w->rem.w, w->rem.h) ne 0;
	if (w->op)
	{
		wind_set(w->wh,WF_TOP);
		if (w->base)
			renum(w);				/* gets w->n & w->avrg */
		get_work(w);
		to_top();
		via (w->slider)(w);		/* If you could only know them after get_work() */
#if WINDIAL
		set_dialinfs(w);
#endif
	}
	return w->op;
}

static
void h_slider(IT *w)
{
	short ww,hr,po,so;

	po=w->hslp;
	so=w->hsls;

/*	---------	slidersize	-------------  */

	ww=w->norm.sz.w;
	if (ww < w->view.sz.w)
		w->hsls=ww*1000L/w->view.sz.w;
	else
		w->hsls=1000;

/*	--------	sliderpos	-------------  */

	hr=w->view.sz.w-ww;
	if (hr <= 0)
		w->hslp=0,
		w->norm.pos.x=0;
	else
		w->hslp=(w->norm.pos.x*1000L)/hr;

	if (w->hslp ne po)
		wind_set(w->wh,WF_HSLIDE, w->hslp);
	if (w->hsls ne so)
		wind_set(w->wh,WF_HSLSIZE,w->hsls);
}

global
SLIDER v_slider		/* IT *w */  /* standard  */
{
	long wr,hw=w->norm.sz.h;
	short po=w->vslp;
	short so=w->vsls;

/*	---------	slidersize	-------------  */

	if ( hw < w->view.sz.h )
		w->vsls=(hw*1000L)/w->view.sz.h;
	else
		w->vsls=1000;

/*	--------	sliderpos	-------------  */

	wr=w->view.sz.h-hw;		/* totaal aantal regels - window */

	if ( wr < 0 or w->norm.pos.y eq 0 )
		w->vslp=0;
	else
		if ( w->norm.pos.y + hw >= w->view.sz.h )
			w->vslp=1000;
		else
			w->vslp=(w->norm.pos.y*1000L)/wr;

	if (w->vslp ne po)
		wind_set(w->wh,WF_VSLIDE, w->vslp);
	if (w->vsls ne so)
		wind_set(w->wh,WF_VSLSIZE,w->vsls);
	if ((w->wkind&HSLIDE) ne 0)
		h_slider(w);
}

global
REDRAW do_redraw	/* (IT *w,RECT t2) */
{
	RECT t1;
	short hl;

	if (!w)
		return;
	hl=w->vhl;

	wind_get(w->wh,WF_FIRSTXYWH,&t1.x,&t1.y,&t1.w,&t1.h);

	while (t1.w and t1.h)
	{
		if (rc_intersect(&t2,&t1))
		{
			gsclip(hl,ON,t1);

			via (w->antedraw) (w,t1);
			via (w->draw) 	  (w,t1);	/* nil if dialogue window */
	#if WINDIAL or WIN_OB
			if (is_dial(w))
			{
				if (w->dial.ob[w->dial.item].type eq G_IBOX)
					gspbox(hl,w->wa);
				wdial_off(w);
			    draw_ob(w->dial.ob,w->dial.item,t1);
				wdial_on(w);
			}
	#endif
#ifdef WMENU
			if (w->draw_menu) pbox(hl,w->wa.x,w->men.y,w->wa.x+wchar-1,w->men.y+w->men.h-1);
			via (w->postdraw) (w,t1);
			if (w->draw_menu)
			{
				w->menu->vhl = hl;
				w->draw_menu(w->menu,w->men,t1);
			}
#endif
		}
		wind_get(w->wh,WF_NEXTXYWH,&t1.x,&t1.y,&t1.w,&t1.h);
	}

	gsclip(hl,ON,screct);	/* whole screen */
}

global
void redraw_windows(INFO_T ty)
{
	STMC *ws;
	IT *w;

	ws=stmfifirst(&winbase);

	while (ws)
	{
		w=ws->wit;
		if (w->ty eq ty)
			do_redraw(w,screct);
		ws=stmfinext(&winbase);
	}

}

global
STMNR bounce(IT *w, STMNR top)		/* bounce top if bottom appears in window */
{
	if (w->view.sz.h < w->norm.sz.h)
		top = 0;
	elif (top+w->norm.sz.h > w->view.sz.h)
		top = w->view.sz.h - w->norm.sz.h;		/* bounce proper */

	if (top < 0)
		top = 0;

	return top;
}

global
bool is_beyond_scr(IT *w)
{
	return (   w->wa.x+w->wa.w-1 > scr.w
	        or w->wa.y+w->wa.h-1 > scr.h );
}

global
ARROWD arrow_img
{
	via (w->winfo)(w);
}

global
ARROWD arrowwindow	/* (IT *w,short arrow, bool topw) */
{
	short h, v, ht, vt;
	STMNR top = w->norm.pos.y;
#if FASTRACK  && (WINTEXT || BINED)
	MFDB van  = {nil};
	MFDB naar = {nil};

	short
		pxy[8],
		disp,
		yplush = w->wa.y + w->wa.h - 1,
		xplusw = w->wa.x + w->wa.w - 1;

	pxy[0] = w->wa.x;
	pxy[2] = xplusw;
	pxy[4] = pxy[0];
	pxy[6] = pxy[2];
#endif

	h_and_v(w,&h,&v,&ht,&vt);
	v--;						/*  12'16 HR v5.5 */
	if ( arrow <= WA_DNLINE)
	{
#if TEXTFILE
/* 12'16 HR v5.5 */
/* Only of use with scroling down */
		if   (arrow eq WA_DNPAGE)
		{
			STMC *t = find_line(w, top+1);
			short y = 1;
			bool have = false;	/* break indicator */
			while (t)
			{
				char *s;
				if (y > v)
					break; /* while(t) */

				s = t->xtx;
				while (*s)
				{
					if (*s eq 12) /* 12 = FORM_FEED */
					{
						have = true;	/* break outer loop */
						v = y;
						break; /* *s */
					}

					s++;
				}

				if (have)
					break; /* while(t). bloody C should have labeled loops:  */

				y++;
				t = stmfinext(w->base);
			}
		}
#endif
		switch (arrow)
		{
		case WA_UPPAGE:
			vt=v;
		case WA_UPLINE:
			w->norm.pos.y  = bounce(w,w->norm.pos.y-vt);
			if (w->norm.pos.y ne top)
			{
				via (w->slider)(w);
#if !FASTRACK || !(WINTEXT || BINED)
				do_redraw(w,w->wa);
#else
				if (!topw or is_beyond_scr(w) or !(is_text(w) or is_bin(w)))
					do_redraw(w,w->wa);
				else
				{
					disp   = top - w->norm.pos.y;
					pxy[1] = w->wa.y;					/*  van y1 */
					pxy[3] = yplush -disp*w->unit.h;	/*	    y2 */
					pxy[5] = w->wa.y+disp*w->unit.h;	/*  naar y1 */
					pxy[7] = yplush;					/*	     y2	*/
					hidem;
					vro_cpyfm(w->vhl, S_ONLY, pxy, &van, &naar);
					showm;
					via (w->lines)(w, disp);			/* new top to old top */
				}
#endif
			}
		break;
		case WA_DNPAGE:
			vt=v;
		case WA_DNLINE:
			w->norm.pos.y  = bounce(w,w->norm.pos.y+vt);
			if (w->norm.pos.y ne top)
			{
				via (w->slider)(w);
#if !FASTRACK || !(WINTEXT || BINED)
				do_redraw(w,w->wa);
#else
				if (!topw or is_beyond_scr(w) or !(is_text(w) or is_bin(w)))
					do_redraw(w,w->wa);
				else
				{
					disp  = top - w->norm.pos.y;
					pxy[1]= w->wa.y-disp*w->unit.h;	/*	van	y1	*/
					pxy[3]= yplush;					/*      y2	*/
					pxy[5]= w->wa.y;					/*	naar y1	*/
					pxy[7]= yplush+disp*w->unit.h;	/*       y2 */
					hidem;
					vro_cpyfm(w->vhl, S_ONLY, pxy, &van, &naar);
					showm;
					via (w->lines)(w, disp);				/* old bot to new bot */
				}
#endif
			}
		break;
		}
	othw
		short old=w->norm.pos.x;

		switch (arrow)
		{
		case WA_LFPAGE:				/* blad naar links */
			w->norm.pos.x-=h;
		break;
		case WA_RTPAGE:				/* blad naar rechts */
			w->norm.pos.x+=h;
		break;
		case WA_LFLINE:				/* kolom naar links */
			w->norm.pos.x-=ht;
		break;
		case WA_RTLINE:				/* kolom naar rechts */
			w->norm.pos.x+=ht;
		break;
		}

		if (w->norm.pos.x > w->view.sz.w-(w->norm.sz.w/2) )
			w->norm.pos.x = w->view.sz.w-(w->norm.sz.w/2);
		if (w->norm.pos.x >= w->view.sz.w)
			w->norm.pos.x  = w->view.sz.w-1;
		if (w->norm.pos.x < 0)
			w->norm.pos.x = 0;

		h_slider(w);
		if (w->norm.pos.x ne old)
			do_redraw(w,w->wa);
	}
}

#if IMGS
global
void set_pxy_s(IT *w, short x, short y)
{
	w->img.set.pn.x = x;
	w->img.set.pn.y = y;

	w->img.get.pv.x = x;
	w->img.get.pv.y = y;
}

global
void v_bounce_img(IT *w)
{
	if (w->img.orig.y > w->ma.y)
		w->img.orig.y = w->ma.y;
	if (w->img.orig.y+w->img.orig.h < w->ma.y+w->ma.h)
		w->img.orig.y = w->ma.y+w->ma.h - w->img.orig.h;
}

global
void h_bounce_img(IT *w)
{
	if (w->img.orig.x > w->ma.x)
		w->img.orig.x = w->ma.x;
	if (w->img.orig.x+w->img.orig.w < w->ma.x+w->ma.w)
		w->img.orig.x = w->ma.x+w->ma.w - w->img.orig.w;
}

global
SLIDER img_slider
{
	short po=w->vslp;
	short so=w->vsls;
	short hw;

/*	---------	vertical slidersize	-------------  */

	hw = w->ma.h;
	if (hw < w->img.orig.h)
		w->vsls=((long)hw*1000)/w->img.orig.h;
	else
		w->vsls = 1000;

/*	--------	vertical sliderpos	-------------  */

	if (w->img.orig.y eq w->ma.y)
		w->vslp = 0;
	elif (w->img.orig.y+w->img.orig.h eq w->ma.y+w->ma.h)
		w->vslp = 1000;
	else
		w->vslp = ((long)(w->ma.y-w->img.orig.y)*1000)/(w->img.orig.h - w->ma.h);

	if (w->vslp ne po)
		wind_set(w->wh,WF_VSLIDE, w->vslp);
	if (w->vsls ne so)
		wind_set(w->wh,WF_VSLSIZE,w->vsls);

/*	--------	horizontal slidersize	-------------  */

	po=w->hslp;
	so=w->hsls;

	hw = w->ma.w;
	if (hw < w->img.orig.w)
		w->hsls=((long)hw*1000)/w->img.orig.w;
	else
		w->hsls = 1000;

/*	--------	horizontal sliderpos	-------------  */

	if (w->img.orig.x eq w->ma.x)
		w->hslp = 0;
	elif (w->img.orig.x+w->img.orig.w eq w->ma.x+w->ma.w)
		w->hslp = 1000;
	else
		w->hslp = ((long)(w->ma.x-w->img.orig.x)*1000)/(w->img.orig.w - w->ma.w);

	if (w->hslp ne po)
		wind_set(w->wh,WF_HSLIDE, w->hslp);
	if (w->hsls ne so)
		wind_set(w->wh,WF_HSLSIZE,w->hsls);
	via (w->winfo)(w);
}

/* rem = remember window position */
/* frem = fulled position (snapped desk wa) */
/* nfrem = remember not fulled (after sized & moved) */

global
SIZED size_img
{
	if (to->w > w->img.orig.w+w->v.w)
		to->w = w->img.orig.w+w->v.w;
	if (to->h > w->img.orig.h+w->v.h)
		to->h = w->img.orig.h+w->v.h;
	w->rem = *to;
	w->nfrem=w->rem;
	w->full=false;
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	h_bounce_img(w);
	v_bounce_img(w);
	set_pxy_s(w,w->img.orig.x,w->img.orig.y);
	via (w->slider)(w);
	via (w->winfo)(w);
	do_redraw(w,w->wa);
}

global
MOVED move_img
{
	w->img.orig.x+=to->x - w->rem.x;
	w->img.orig.y+=to->y - w->rem.y;
	w->rem=*to;
	w->nfrem=w->rem;
	w->full=false;
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	set_pxy_s(w,w->img.orig.x,w->img.orig.y);
	via (w->winfo)(w);
}

global
FULLED full_img
{
	if ( w->full )
	{
		w->rem=w->nfrem;
		w->full=false;
	othw
		w->rem=w->frem;
		w->full=true;
	}
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	v_bounce_img(w);
	h_bounce_img(w);
	via (w->slider)(w);
	via (w->winfo)(w);
}

global
SLIDE slide_img
{
	if ( w->vslp ne vslp )
	{
		short  old = w->ma.y - w->img.orig.y,
		     new = (w->img.orig.h - w->ma.h)*(long)vslp/1000;

		w->vslp=vslp;
		if (old ne new)
		{
			w->img.orig.y+=old-new;
			v_bounce_img(w);
			set_pxy_s(w,w->img.orig.x,w->img.orig.y);
			wind_set(w->wh,WF_VSLIDE,vslp);
			do_redraw(w,w->wa);
		}
	}

	if ( w->hslp ne hslp)
	{
		short  old = w->ma.x - w->img.orig.x,
		     new = (w->img.orig.w - w->ma.w)*(long)hslp/1000;

		w->hslp=hslp;
		if (old ne new)
		{
			w->img.orig.x+=old-new;
			h_bounce_img(w);
			set_pxy_s(w,w->img.orig.x,w->img.orig.y);
			wind_set(w->wh,WF_HSLIDE,hslp);
			do_redraw(w,w->wa);
		}
	}
	via (w->winfo)(w);
}
#endif	/* IMGS */

global
SIZED sizewindow	/* (IT *w, RECT *to) */
{
#ifndef WINX
	bool no_evnt;
#endif
	if ((w->wkind&SIZER) eq 0)			/* security */
	{
		to->w=w->rem.w;
		to->h=w->rem.h;
	}
	snapwindow(w,to);
#ifndef WINX
	no_evnt=to->w <= w->rem.w and to->h <= w->rem.h;
#endif
	w->rem=*to;
	w->nfrem=w->rem;
	w->full=false;
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	w->norm.pos.y  = bounce(w,w->norm.pos.y);
	via (w->slider)(w);
#ifndef WINX
	if ((	no_evnt
		and (w->mg.w or w->mg.h)
	    )						/* if right or bottom margin must redraw */
	    or is_sheet(w) )		/*	8'95 (as long as sh_edob at bottom)
	    						    because no redraw event is caused */
#endif
		do_redraw(w,w->wa);		/* allways if WINX */
	via (w->winfo)(w);
}

global
MOVED movewindow	/* (IT *w, RECT *to) */
{
	snapwindow(w,to);
	w->rem=*to;
	w->nfrem=w->rem;
	w->full=false;
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	via (w->winfo)(w);
}

global
FULLED fullwindow	/* (IT *w) */
{
	if ( w->full )		/* all these values are allready snapped */
	{
		w->rem=w->nfrem;
		w->full=false;
	othw
		w->rem=w->frem;
		w->full=true;
	}
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	w->norm.pos.y  = bounce(w,w->norm.pos.y);
	via (w->slider)(w);
	via (w->winfo)(w);
}

global
void cyclewindows(IT *wt)
{
	while (true)
	{
		IT *nw;
		STMC *ws=stmfind(&winbase,NEXT,CYCLIC);

		if (!ws)
			break;

		nw=ws->wit;
		if (nw->wh > 0 and !is_drop(nw))
		{
			if (wt->cursor)
				cur_off(wt);
			to_top();
			wind_set(nw->wh,WF_TOP);
#ifdef WMENU
			get_work(nw);
#endif
			break;
		}
	}
}

global
void rack_up(IT *w, STMNR oldy)
{
	RECT clip = w->wa;
	short disp = oldy - w->norm.pos.y;

	if (disp < w->norm.sz.h)
	{
		MFDB van  = {nil,0,0,0,0,0,0,0,0};
		MFDB naar = {nil,0,0,0,0,0,0,0,0};
		short pxy[8],
			yplush = clip.y+clip.h-1,
			xplusw = clip.x+clip.w-1;

		pxy[0] = clip.x;
		pxy[2] = xplusw;
		pxy[4] = pxy[0];
		pxy[6] = pxy[2];

		pxy[1] = clip.y;					/*  van  y1 */
		pxy[3] = yplush-disp*w->unit.h;		/*	     y2 */
		pxy[5] = clip.y+disp*w->unit.h;		/*  naar y1 */
		pxy[7] = yplush;					/*	     y2	*/
		hidem;
		vro_cpyfm(w->vhl,S_ONLY,pxy,&van,&naar);
		showm;
		clip.h = disp*w->unit.h;
	}

	do_redraw(w, clip);				/* new top to old top */
}

global
void rack_dn(IT *w, STMNR oldy)
{
	RECT clip = w->wa;
	short disp = oldy - w->norm.pos.y;

	if (-disp < w->norm.sz.h)
	{
		MFDB van  = {nil,0,0,0,0,0,0,0,0};
		MFDB naar = {nil,0,0,0,0,0,0,0,0};
		short pxy[8],
			yplush = clip.y+clip.h-1,
			xplusw = clip.x+clip.w-1;

		pxy[0] = clip.x;
		pxy[2] = xplusw;
		pxy[4] = pxy[0];
		pxy[6] = pxy[2];

		pxy[1] = clip.y-disp*w->unit.h;		/*	van	 y1	*/
		pxy[3] = yplush;					/*       y2	*/
		pxy[5] = clip.y;					/*	naar y1	*/
		pxy[7] = yplush+disp*w->unit.h;		/*       y2 */
		hidem;
		vro_cpyfm(w->vhl,S_ONLY,pxy,&van,&naar);
		showm;
		clip.y = pxy[7];
		clip.h = -disp*w->unit.h;
	}

	do_redraw(w, clip);				/* old bot to new bot */
}

global
SLIDE slidewindow	/* (IT *w,short hslp,short vslp, bool topw) */
{
	if ( w->vslp ne vslp )
	{
		STMNR old=w->norm.pos.y,nnr;

		w->vslp=vslp;
		wind_set(w->wh,WF_VSLIDE,vslp);

		nnr=((w->view.sz.h-(w->norm.sz.h-1))*vslp)/1000;
	#if WINTEXT
		if (w->base)
		{
			STMC *new=find_line(w,nnr);
			nnr=new->xn - 1;
		}
	#endif
		w->norm.pos.y  = bounce(w,nnr);
		via (w->slider)(w);
		if (w->norm.pos.y ne old)
			do_redraw(w,w->wa);
	}

	if ( w->hslp ne hslp)
	{
		short old=w->norm.pos.x;

		w->hslp=hslp;
		wind_set(w->wh,WF_HSLIDE,hslp);

		w->norm.pos.x=(((long)w->view.sz.w-w->norm.sz.w)*hslp)/1000;
		if (w->norm.pos.x ne old)
			do_redraw(w,w->wa);
	}
	via (w->winfo)(w);
}

global
bool delete_windows(bool force)
{
	STMC *ws;
	IT *w;
	bool fdeleted,have_journal=false,have_drop=false;

	do
	{
		fdeleted=false;
		ws=stmfifirst(&winbase);
		while (ws)
		{
			w=ws->wit;
			if   (is_jrnl(w))
				have_journal = true;		/* delay closing of journal */
			elif (is_drop(w))
				have_drop    = true;		/* delay closing of drop */
			elif (w->close_file)
			{
				fdeleted=(*w->close_file)(w, force);
				if (!fdeleted)		/* close canceled, so abandon QUIT */
					return false;
				else
					break;
			}
			ws=stmfinext(&winbase);
		}
	} while (fdeleted);			/* ivm CYCLIC nature of winbase */
							/* if nothing was done we can stop */

	if (have_journal)
	{
		w = get_it(-1,JRNL);
		via (w->close_file)(w, force);
	}

	if (have_drop)
	{
		w = get_it(-1,DROP);
		via (w->close_file)(w, force);
	}

	return true;
}

global
void update_it(bool app, INFO_T ty)
{
	IT *wb = get_it(-1,ty);

	renum(wb);

	wb->cu=c1st;

	if (app)
	{
		wb->norm.pos.y = bounce(wb,wb->view.sz.h - 1);
		wb->norm.pos.y = wb->norm.pos.y + 1;
		wb->  cu.pos.y = wb->view. sz.h - 1;
	othw
		wb->ss = cnil;
		wb->se = cnil;
		wb->selection = false;
	}

	if (wb->wh > 0)
	{
		via (wb->slider)(wb);
		do_redraw(wb,wb->wa);
	}
}
