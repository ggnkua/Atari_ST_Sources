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

/* BUFFER.C
 * ========
 */

#include "common/aaaa_lib.h"

#include "aaaa.h"
#include "cursor.h"
#include "text.h"
#include "editor.h"
#ifdef SOPT
#include "common/scrap.h"
#endif
#include "common/mallocs.h"
#include "common/journal.h"	/* mainly for send_msg() */
#include "common/cursor.h"
#include "common/files.h"	/* mainly for write_out() */
#include "common/ahcm.h"

static
VpV clear_buf
{
	IT *bw = get_it(-1,BUFF);
	STMDEF *bb = bw->base;

	close_w(bw);
	clearmal(bb);
	stmclear(bb);
	if (bw->map)
	{
		ffree(bw->map);
		bw->map = nil;
		bw->mapl = 0;
	}
}

static
bool _copy_(IT *w, bool shift, CINF ds, CINF de)
{
	STMC *s,*bs;
	STMDEF *bb=&shunt;

	if (!shift)
		clear_buf();

	s=find_line(w,ds.pos.y);

	if (ds.pos.y eq de.pos.y and *(s->xtx+ds.pos.x) )
	{
		if (!copy_1(bb,s,ds.pos.x,de.pos.x-ds.pos.x,LAST))
			return false;
		if (shift)
		{
			bs=stmfiprior(bb);
			catenate(0L,bb,bs,w->avrg);
		}
	othw
		short j=ds.pos.y;
		bool rb=true;
		if (copy_1(bb,s,ds.pos.x,s->x_l-ds.pos.x,LAST))
		{
			STMDEF *m=w->base;

			if (shift)
			{
				bs=stmfiprior(bb);
				catenate(0L,bb,bs,w->avrg);
			}
			j++;
			if ( (s=stmfinext(m)) ne 0L)
			{
				while (s and j < de.pos.y)
				{
					rb=copy_1(bb,s,0,s->x_l,LAST) ne nil;
					if (!rb)
						break;
					s=stmfinext(m);
					j++;
				}
				if ( s and rb )
					copy_1(bb,s,0,de.pos.x,LAST);
			}
		}
	}
	update_it(shift, BUFF);
	return true;
}

global
bool _cut_(IT *w, bool shift, CINF ds, CINF de)
{
	STMC *s,*bs;
	STMDEF *m=w->base,*bb=&shunt;

	if (!shift)
	{
		clearmal(bb);
		stmclear(bb);
	}

	s=find_line(w,ds.pos.y);

	if (ds.pos.y eq de.pos.y and *(s->xtx+ds.pos.x) )
	{
		if (!copy_1(bb,s,ds.pos.x,de.pos.x-ds.pos.x,LAST))
			return false;
		if (shift)
		{
			bs=stmfiprior(bb);
			catenate(0L,bb,bs,w->avrg);
		}
		_del_(w, ds, de);
	othw
		short j=ds.pos.y;
		bool rb=true;
		set_X(w);
		if (copy_1(bb,s,ds.pos.x,s->x_l-ds.pos.x,LAST))
		{
			if (shift)
			{
				bs=stmfiprior(bb);
				catenate(0L,bb,bs,w->avrg);
			}
			if ( (rb=del_ch(w,s,ds.pos.x,s->x_l-ds.pos.x)) ne 0)
			{
				j++;
				if ( (s=stmfinext(m)) ne 0L)
				{
					while (s and j < de.pos.y)
					{
						to_undo(w,s);
						stmmove(bb,m,LAST);	/* saves many mallocs */
						s=stmfinext(m);
						if (!s)
						{
							rb=false;
							break;
						}
						j++;
					}
					if ( s and rb )
						if ( copy_1(bb,s,0,de.pos.x,LAST) )
							if ( del_ch(w,s,0,de.pos.x) )
								if ( (s=stmfiprior(m)) ne 0L)
									catenate(w,w->base,s,w->avrg);
				}
			}
		}
	}
	update_it(shift, BUFF);
	renum(w);
	return true;
}

static
bool buf_emp(CINF *s, CINF *e)
{
	IT *wb;
	CINF ds,de;

	wb = get_it(-1,BUFF);

	if (wb->selection)
	{
		ds = wb->ss;
		de = wb->se;
	othw
		ds = c1st;
		t_to_s_x(wb, wb->view.sz.h - 1, MAXL, &de, HIGH);	/* de --> end of file */
	}

	if (s) *s = ds;
	if (e) *e = de;

	if (ds.pos.y eq de.pos.y and ds.pos.x eq de.pos.x and ds.pos.x eq 0)
		return true;			/* buffer empty */

	return false;
}

static
bool _paste_(IT *w, CINF *cu)
{
	IT *wb;
	STMC *s,*bs;
	CINF ds,de;
	STMDEF *m=w->base,*bb=&shunt;

	wb=get_it(-1,BUFF);

	if (buf_emp(&ds, &de)) return false;

	bs=find_line(wb,ds.pos.y);
	s =find_line(w,cu->pos.y);

	if (ds.pos.y eq de.pos.y and *(bs->xtx+ds.pos.x))
	{
		short l=de.pos.x-ds.pos.x;
		if (insert(w,s,cu->pos.x,l,'?',w->avrg))	/* may change s->xtx */
		{
			char *sn=s->xtx+cu->pos.x;
			char *bn=bs->xtx+ds.pos.x;
			cu->pos.x+=l;
			while (l--) *sn++=*bn++;
			x_to_s_t(w,cu);
			(*w->disp)(w,s,HIDE);
		}
	othw
		short j=ds.pos.y;
		bool rb=true;
		short l=bs->x_l-ds.pos.x;

		if (split(w,s,cu->pos.x,l))
		{
			s=stmfiprior(m);
			if (insert(w,s,cu->pos.x,l,'?',w->avrg))
			{
				char *sn=s->xtx+cu->pos.x;
				char *bn=bs->xtx+ds.pos.x;
				while (l--) *sn++=*bn++;
				if ( (bs=stmfinext(bb)) ne 0L)
				{
					j++;
					while (bs and j < de.pos.y)
					{
						rb=copy_1(m,bs,0,bs->x_l,NEXT) ne nil;
						if (!rb)
							break;
						bs=stmfinext(bb);
						j++;
					}
					s =stmfinext(m);	/* the one splitted off */

#if INTERNAL
					if (!s)
						form_alert(1,"[3][|Internal error !|lost split][ Stop ]");
					else
#endif
					if ( bs and rb)
					{
						l=de.pos.x;
						if (insert(w,s,0,l,'?',w->avrg))
						{
							char *sn=s->xtx;
							char *bn=bs->xtx;
							cu->pos.x=l;
							while (l--) *sn++=*bn++;
						}
					}
				}
			}
		}
	}
	renum(w);
	cu->pos.y+=de.pos.y-ds.pos.y;
	x_to_s_t(w,cu);
	return true;
}

static
void mnpaste(IT *w)
{
#ifdef SOPT
	if (cfg.s)
		scrap_to_buf();
#endif
	if (!buf_emp(nil, nil))
	{
		if (w->selection)
			delete(w);

		make_vis_cur(w);
		_paste_(w, &w->cu);
		cur_off(w);
		if (!make_vis_cur(w))
		{
			via (w->slider)(w);
			do_redraw(w,w->wa);
		}
		cur_on(w);
	}
#ifdef SOPT
	if (cfg.s)
		clear_buf();
#endif
}

global
void do_Buffer(IT *w,short mt,short kstate)
{
#if defined(MNCUTAP) || defined(MNCOPYAP)
	bool shift = mt eq MNCUTAP or mt eq MNCOPYAP;
#else
	bool shift = false;
#endif

	if (w)
		switch (mt)
		{
		#ifdef MNCOPYAP
			case MNCOPYAP:		/* Copy and append (shift set) */
		#endif
		#ifdef MNCOPY
			case MNCOPY:
			if (w->selection)
			{
				if (_copy_(w, shift, w->ss, w->se))
					make_visible(w,w->ss, true);
			othw
				CINF ss,se;
				set_line(w,&ss,&se);
				if (_copy_(w, shift, ss, se))
					make_vis_cur(w);
			}
#ifdef SOPT
			if (have_scrap and cfg.s)
				buf_to_scrap();
#endif
			break;
		#endif
		#ifdef MNCUTAP
			case MNCUTAP:		/* Cut and append (shift set) */
		#endif
		#ifdef MNCUT
			case MNCUT:
			if (w->selection)
			{
				make_visible(w,w->ss, true);
				if (_cut_(w, shift, w->ss, w->se))
				{
					w->cu=w->ss;
					w->ss=cnil;
					w->se=cnil;
					cur_off(w);
					via (w->slider)(w);
					do_redraw(w,w->wa);
					cur_on(w);
				}
			othw
				CINF ss,se;
				make_vis_cur(w);
				cur_off(w);
				set_line(w,&ss,&se);
				if (_cut_(w, shift, ss, se))
				{
					w->cu=ss;
					via (w->slider)(w);
					do_redraw(w,w->wa);
				}
				cur_on(w);
			}
#ifdef SOPT
			if (have_scrap and cfg.s)
				buf_to_scrap();
#endif
			break;
		#endif
		#ifdef MNPASTE
			case MNPASTE:
				mnpaste(w);
			break;
		#endif
		}
}

#ifdef SOPT
VpV scrap_to_buf
{
	char nm[SCRS], *in;
	short h;
	long l;

	mk_scrap_name(nm);
	in = Fload(nm, &h, &l, AH_SCRAP);

	if (in)
	{
		IT *w = get_it(-1, BUFF);
		/* append to buffer */
		if (w)
		{
			w->map = in;
			w->mapl =l;
			make_lines(w);	/* always appends */
			renum(w);
			stmfifirst(w->base);
		}

		Fclose(h);
	}
}

bool have_buf(void)
{
	IT *w = get_it(-1, BUFF);
	STMC *f = stmfifirst(w->base),
	     *l = stmfilast (w->base);
	     char *s;
	if (!f)
		return false;
	if (f ne l)
		return true;
	s = f->xtx;
	if (!s)
		return false;
	return *s ne 0;
}

VpV buf_to_scrap
{
	IT *w = get_it(-1, BUFF);
	char nm[SCRS]; long h;

	if (have_buf())
	{
		create_scrap();
		mk_scrap_name(nm);
		h = Fcreate(nm, 0);
		Fclose(h);
		write_out(w, nm);	/* Opens/closes itself */
		via (w->closed)(w);
		Fdelete(buffn.s);
	}
}
#endif

global
void repLbyR(IT *w)
{
	STMC *ws;
	IT *wt=w,*w2=nil;

	while ((ws=stmfind(&winbase,NEXT,CYCLIC)) ne nil)
	{
		w2=ws->wit;
		if (is_srce(w2))
			break;
	}


	if (w2 and w2 ne w)
	{
		if (wt->selection)
		{
			if (w2->selection)
			{
				if (_copy_  (wt, false, wt->ss, wt->se))
				{
					mnpaste(w2);
					txtsel_cursor(w2,NK_RIGHT|NKF_FUNC);
					txtsel_cursor(wt,NK_RIGHT|NKF_FUNC);
					wt = get_it(wt->wh, -1);
					wind_set(wt->wh,WF_TOP);
					to_top();
				}
			}
			else
				send_msg("needs selection in other text window\n");
		}
		else
			send_msg("needs selection in top (text)window\n");
	}
}

static
bool still_down(short b)
{
	short dum,button;
	graf_mkstate(&dum,&dum,&button,&dum);
	return button eq b;
}

static
bool in_selection(IT *w, short mx, short my)
{
	long bx, by;

	xy_to_unit(w, mx, my, &bx, &by);

	if (by <  w->ss.pos.y or  by >  w->se.pos.y)
		return false;
	if (by eq w->ss.pos.y and bx <  w->ss.scrx)
		return false;
	if (by eq w->se.pos.y and bx >= w->se.scrx)
		return false;
	return true;
}

typedef struct {short x,y; } pair;

static
pair pxy[16];
short nxy;

static
void write_poly(short hl, pair *pxy, short nxy)
{
	gsclip(hl,ON,screct);	/* whole screen */
	vsl_udsty(hl,0x5555);
	vsl_color(hl,1);
	vswr_mode(hl,3);
	hidem;
	v_pline(hl,nxy,(short *)pxy);
	showm;
	vswr_mode(hl,1);
	vsl_type(hl,1);
}

static
short add_pair(pair *p, short x, short y, short i)
{
	if (i)
	{
		short j = i - 1;
		if (p[j].x eq x and p[j].y eq y)
			return i;
		if (j)
		{
			short k = j - 1;;
			if (p[k].x eq x)
			{
				p[j].y = y;
				return i;
			}
			if (p[k].y eq y)
			{
				p[j].x = x;
				return i;
			}
		}
	}

	p[i].x = x;
	p[i].y = y;
	return i + 1;
}

static
short make_poly(IT *w, pair *p)
/* called when mouse points in selection */
{
	long sl, el;
	short i, nl, sc, ec,
		  ww = w->norm.sz.w,
		  hw = w->norm.sz.h;
	pair p0, p1, p2;
	CINF ss = w->ss,
		 se = w->se;
	short top = w->norm.pos.y,
		  bot = w->norm.pos.y + ww,
		  xplusw = w->ma.x + w->ma.w;

	if (C_cmp(&ss, &se) >= 0)
		return 0;

	sl=ss.pos.y;
	sc=ss.scrx;
	el=se.pos.y;
	ec=se.scrx;

	sc -= w->norm.pos.x;
	ec -= w->norm.pos.x;

	if (sc <  0 )     sc = 0;
	if (sc >  ww - 1) sc = 0,  sl++;
	if (ec <= 0 )     ec = ww, el--;
	if (ec >  ww - 1) ec = ww;

	if (sl < top  ) sl = top, sc=0;
	if (el > bot-1) el = bot-1,ec=ww;

	sl -= w->norm.pos.y;
	el -= w->norm.pos.y;

	if (sl < 0   ) sl=0,   sc=0;
	if (el > hw-1) el=hw-1,ec=ww;

	p0.x = w->ma.x;
	p0.y = w->ma.y;
	p1.x = p0.x+(sc*w->unit.w);
	p1.y = p0.y+(sl*w->unit.h);
	p2.x = p0.x+(ec*w->unit.w);
	p2.y = p0.y+(el*w->unit.h)+w->unit.h;

/*                              0                         1
		8                      	___________________________
		______________________9_|_________________________| 2
		|_________________________________________________| 3
	 7  |_______________| 4
	   6                5

	add_pair() doesnt add when x and y are same as previous.
	More over: if a line doesnt change direction, the previous
	pair is adapted.
*/
	nl = el - sl;
	i = add_pair(p, p1.x, p1.y, 0);						/* 0 */
	if (nl)
	{
		i = add_pair(p, xplusw, p1.y, i);				/* 1 */
		i = add_pair(p, xplusw, p1.y + w->unit.h, i);	/* 2 */
	        p1.y += nl * w->unit.h;
		i = add_pair(p, xplusw, p1.y, i);				/* 3 */
	}
	i = add_pair(p, p2.x  , p1.y, i);					/* 4 */
	i = add_pair(p, p2.x  , p2.y, i);					/* 5 */
	if (nl)
	{
		i = add_pair(p, p0.x  , p2.y, i);				/* 6 */
		i = add_pair(p, p0.x  , p1.y, i);				/* 7 */
	        p1.y -= nl * w->unit.h;
		i = add_pair(p, p0.x  , p1.y + w->unit.h, i);	/* 8 */
	}
	i = add_pair(p, p1.x  , p1.y + w->unit.h, i);		/* 9 */
	i = add_pair(p, p1.x  , p1.y, i);					/* close */

	return i;
}

static
/* Mouse Form Block */
MFORM
ARROW_4={7,7,1,0,1
,0x03C0,0x07E0,0x0FF0,0x07E0
,0x23C4,0x73CE,0xFFFF,0xFFFF
,0xFFFF,0xFFFF,0x73CE,0x23C4
,0x07E0,0x0FF0,0x07E0,0x03C0
,0x0180,0x03C0,0x07E0,0x0180
,0x0180,0x2184,0x6186,0xFFFF
,0xFFFF,0x6186,0x2184,0x0180
,0x0180,0x07E0,0x03C0,0x0180
},
FORBID={7,7,1,0,1
,0x0FF0,0x3FFC,0x7FFE,0x7E7E
,0xF83F,0xF07F,0xF0FF,0xE1E7
,0xE3C7,0xE78F,0xFF0F,0xFE1F
,0x7E7E,0x7FFE,0x3FFC,0x0FF0
,0x0180,0x07E0,0x1C38,0x300C
,0x201C,0x6036,0x4062,0xC0C3
,0xC183,0x4302,0x6606,0x2C04
,0x380C,0x1C38,0x07E0,0x0180
};

typedef enum {plus,arr4,forb} MF;

static
MF rat(MF was, MF nu)
{
	if (was ne nu)
		switch(nu)
		{case plus:	graf_mouse(6,nil); break;
		 case arr4: graf_mouse(USER_DEF,&ARROW_4); break;
		 case forb: graf_mouse(USER_DEF,&FORBID); break;
		}
	return nu;
}

global
bool write_cur(IT *w, CINF cu);

/* drag a selection */
global
DRAG_SEL drag_selection 		/* w,button,kstate,bclicks,mx,my */
{
	IT *wt = w; MF was = -1;
	bool shift = (kstate&(LSHIFT|RSHIFT)) ne 0,
		 cop   = shift;

	if (	w->ty ne BUFF
		and w->selection
		and button eq 2
		and still_down(button)
		and in_selection(w,mx,my)
	   )
	{
		short state;
		static short obx,oby;

		CINF s1=w->ss,s2=w->se,
			 cu=s1;
/*		long ps=s1.pos.y*(MAXL+1)+s1.pos.x,		/* for easy comparisons */
		     pe=s2.pos.y*(MAXL+1)+s2.pos.x,
		     pn;
*/
		short hl = w->vhl;

		nxy = make_poly(w,pxy);

		write_cur(w,cu);
		obx=(mx/w->unit.w)*w->unit.w;
		oby=(my/w->unit.h)*w->unit.h;

		write_poly(hl,pxy,nxy);

		was = rat(was,cop?plus:arr4);

		do					/* drag the polyline */
		{
			graf_mkstate(&mx,&my,&button,&state);
			mx = (mx/w->unit.w)*w->unit.w;
			my = (my/w->unit.h)*w->unit.h;
			if (mx ne obx or my ne oby)
			{
				short i;
				write_poly(hl,pxy,nxy);		/* unwrite old */
				write_cur(w,cu);
				for (i=0; i<nxy; i++)	/* update points */
					pxy[i].x += mx-obx, pxy[i].y += my-oby;
				if (m_inside(pxy[0].x,pxy[0].y,w->rem))
				{
					if (w eq wt)
						cop = shift;
					was = rat(was,cop?plus:arr4);
				othw
					short nh = wind_find(pxy[0].x,pxy[0].y);
					was = rat(was,forb);
					if (nh)
					{
						IT *nw = get_it(nh,-1);
						if (nw)
						{
							if (    nw->ty ne BUFF
								and is_text(nw)
								and nw->edit        )
							{
								w_top(nh, nw, w);
								do_redraw(nw, nw->wa);
								w = nw;
								cop = true;
								was = rat(was,plus);
							}
						}
					}
				}
				{
					long bx, by;
					xy_to_unit(w, pxy[0].x, pxy[0].y, &bx, &by);
					t_to_s_x(w, by, bx, &cu, LOW);
					write_cur(w,cu);
					write_poly(hl,pxy,nxy);		/* write new */
					obx = mx;
					oby = my;
				}
			}
		} while (button);

		write_poly(hl,pxy,nxy);	/* unwrite last */
		write_cur(w,cu);		/* insertion point */

		if (m_inside(pxy[0].x,pxy[0].y,w->ma))
		{
			if (w eq wt)
			{
				if (	 w->edit
				    and !((C_cmp(&s1, &cu) < 0) and C_cmp(&cu, &s2) < 0)
				   )
				{
					w->deselect(w,LOW);

					if (cop)
					{
						_copy_(w, false, s1, s2);		/* copy doesnt change new cur pos */
						_paste_(w, &cu);
					}
					elif (C_cmp(&cu, &s1) <= 0)		/* move up doesnt change new cur pos */
					{
						_cut_(w, false, s1, s2);
						_paste_(w, &cu);
					othw							/* move down */
						_copy_(w, false, s1, s2);		/* first copy, then insert, then delete */
						_paste_(w, &cu);
						_del_(w, s1, s2);
						cu.pos.y -= s2.pos.y - s1.pos.y;
					}
					w->cu=cu;
					w->norm.pos.y = bounce(w,w->norm.pos.y);
					via (w->slider)(w);
					do_redraw(w,w->wa);
					cur_on(w);
				}
			othw		/* wt is now the window from which the drag is started!! */
						/* w is the target window */
				if (cop or wt->edit eq nil)
					_copy_(wt, false, s1, s2);
				else
				{
					wt->deselect(wt,LOW);
					_cut_(wt, false, s1, s2);
					wt->norm.pos.y = bounce(wt,wt->norm.pos.y);
					via (wt->slider)(wt);
					do_redraw(wt,wt->wa);
				}

				w->deselect(w,LOW);
				_paste_(w, &cu);
				w->cu=cu;
				w->norm.pos.y = bounce(w,w->norm.pos.y);
				via (w->slider)(w);
				do_redraw(w,w->wa);
				cur_on(w);
			}
		}
		via(w->muisvorm)(w);
		return true;
	}
	else
		return false;
}

void disforbuffer(OBJECT *m)
{
	dis_paste_etc(m,false);
}

global
void open_buf(void)
{
	short buffer;
	IT *w;

	w = get_it(-1,BUFF);
	buffer = w->wh;
	if (stmfirst(*w->base) eq 0L)
		form_alert(1,frstr(BEMP));
	else
	if ( buffer > 0 )
	{
		wind_set(buffer,WF_TOP);
		to_top();
	othw
		if ( (buffer=wind_create(
					w->wkind,win.x,win.y,win.w,win.h)
			 ) < 0 )		/* NB max grootte */
			alertwindow("het buffer");
		else
		{
			w->wh=buffer;
			w->norm.sz.w  = w->ma.w/wchar;
			w->norm.pos.y = 0;
			open_w(w);	/* put window on screen (includes get_work() & sliders()) */
			disforbuffer(w->menu->m);
		}
	}
}
