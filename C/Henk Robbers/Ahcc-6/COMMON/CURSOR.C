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

/* 	CURSOR.C
 *	========
 */

#include <ctype.h>
#include "aaaa_lib.h"
#include "hierarch.h"

#include "aaaa.h"
#include "cursor.h"

/* Mouse Form Block  */

static
MFORM kader16 =
{	7,7,1,0,1,
  {	0x3FFC,0x3FFC,0x300C,0x300C,		/* mask */
	0x300C,0x300C,0x300C,0x300C,
	0x300C,0x300C,0x300C,0x300C,
	0x300C,0x300C,0x3FFC,0x3FFC },
  {	0x1FF8,0x1008,0x1008,0x1008,		/* form */
	0x1008,0x1008,0x1008,0x1008,
	0x1008,0x1008,0x1008,0x1008,
	0x1008,0x1008,0x1008,0x1FF8 }
},
	 kader8 =
{
	7,7,1,0,1,
  { 0x0000,0x0000,0x3FFC,0x3FFC, 		/* m */
    0x300C,0x300C,0x300C,0x300C,
    0x300C,0x300C,0x300C,0x300C,
    0x3FFC,0x3FFC,0x0000,0x0000 },
  { 0x0000,0x0000,0x0000,0x1FF8, 		/* f */
    0x1008,0x1008,0x1008,0x1008,
    0x1008,0x1008,0x1008,0x1008,
    0x1FF8,0x0000,0x0000,0x0000 }
};

global
MUIS m_kader		/* IT *w */
{
	graf_mouse(USER_DEF, w->unit.h > 8 ? &kader16 : &kader8);
}

global
bool make_visible(IT *w,CINF vi, bool top)
{
	short ls = 0;
	STMNR l1 = vi.pos.y,
		  l2 = vi.pos.y;
	bool draw=false;

	if (w->selection)		/* try to get as much visible as possible */
	{
		ls = w->se.pos.y - w->ss.pos.y;
		if (ls > w->norm.sz.h)
			ls = w->norm.sz.h;
		if (vi.pos.y eq w->se.pos.y)
			l1-=ls, ls = -ls;
		else
			l2+=ls;
	}

	if (	vi.scrx <  w->norm.pos.x
		or  vi.scrx >= w->norm.pos.x + w->norm.sz.w)
	{
		draw |= true;

		w->norm.pos.x = vi.scrx-(w->norm.sz.w/2);
		if (w->norm.pos.x < 0)
			w->norm.pos.x = 0;
	}

	if (   l1 <  w->norm.pos.y
	    or l2 >= w->norm.pos.y + w->norm.sz.h
	   )
	{
		draw |= true;
		w->norm.pos.y = bounce(w,vi.pos.y-(w->norm.sz.h-ls)/2);	/* put in the middle */
	}

	if (!top)
		if (get_top_it() ne w)
			draw |= true, wind_set(w->wh, WF_TOP);

	if (draw)
	{
		via (w->slider)(w);
		do_redraw(w,w->wa);
	}
	return draw;
}

global
bool make_vis_cur(IT *w)
{
	bool ret;
	w->vc.pos.y = w->cu.pos.y;		/* start point for next do_ficu() */
	ret = make_visible(w,w->cu,false);	/* check on top */
	return ret;
}

global
bool make_vis_top(IT *w)
{
	bool ret;
	w->vc.pos.y = w->cu.pos.y;		/* start point for next do_ficu() */
	ret = make_visible(w,w->cu,true);	/* already on top */
	return ret;
}

global
void write_curect(short hl, short pxy[])
{
	hidem;
	vswr_mode    (hl,3);
	vsf_color    (hl,1);	/* black      */
	v_bar        (hl,pxy);
	vsf_color    (hl,0);	/* white again */
	vswr_mode    (hl,1);
	showm;
}

global
void xy_to_unit(IT *w, short mx, short my, long *pbx, long *pby)
{
	short x, y;
	x = (mx - w->ma.x) / w->unit.w + w->norm.pos.x;
	y = (my - w->ma.y) / w->unit.h + w->norm.pos.y;
	if (x >= w->view.sz.w)
		x  = w->view.sz.w-1;
	if (y >= w->view.sz.h)
		y  = w->view.sz.h-1;
	*pbx = x;
	*pby = y;
}

global
void cussse(IT *w, char *s)
{
	alert_text(" %s | %d/%ld s%d t%d ty %d | %d/%ld s%d t%d ty %d | %d/%ld s%d t%d ty %d ",
	              s,  w->cu,                 w->ss,                 w->se                    );
}

global
void sh_1(char *s, CINF c)
{
	alert_text(" %s | %d/%ld s%d t%d ty %d ", s, c);
}
global
void sh_2(char *s, CINF c1, CINF c2)
{
	alert_text(" %s | %d/%ld s%d t%d ty %d | %d/%ld s%d t%d ty %d ", s, c1, c2);
}
global
void sh_3(char *s, CINF c1, CINF c2, CINF c3)
{
	alert_text(" %s | %d/%ld s%d t%d ty %d | %d/%ld s%d t%d ty %d | %d/%ld s%d t%d ty %d ", s, c1, c2, c3);
}

global
short C_cmp(CINF *a, CINF *b)
{
	if (a->pos.y < b->pos.y) return -1;
	if (a->pos.y > b->pos.y) return  1;
/* l's are equal */
	if (a->pos.x < b->pos.x) return -1;
	if (a->pos.x > b->pos.x) return  1;
/* all equal */
	return 0;
}

#if 0
global
bool cur_vis(IT *w)
{
	if (	w->cu.pos.y >= w->norm.pos.y
		and w->cu.pos.y <  w->norm.pos.y + w->norm.sz.h
		and w->cu.scrx  >= w->norm.pos.x
		and w->cu.scrx  <  w->norm.pos.x + w->norm.sz.w
	   )
		return true;
	return false;
}
#endif

global		/* directly called by drag_selection */
bool write_cur(IT *w, CINF cu)		/* top left pos: 0,0 */
{
	if (	cu.pos.y >= w->norm.pos.y
		and cu.pos.y <  w->norm.pos.y + w->norm.sz.h
		and cu.scrx  >= w->norm.pos.x
		and cu.scrx  <  w->norm.pos.x + w->norm.sz.w
	   )
	{
		short c[4];

		c[0] = w->ma.x;
		c[0]+= (cu.scrx  - w->norm.pos.x) * w->unit.w;
		c[1] = w->ma.y;
		c[1]+= (cu.pos.y - w->norm.pos.y) * w->unit.h;
		c[2] = c[0] + w->unit.w - 1;
		c[3] = c[1] + w->unit.h - 1;
	#ifdef CURLINE
		c[0]-=1;
		c[2]+=1;
		c[1]+=w->h-1;
		c[3]+=1;
	#endif
		write_curect(w->vhl, c);
		return true;
	}
	else
		return false;
}

global
CURSOR std_cursor		/*	(IT *w, CURST to) */
{
	if (to eq OFF)
	{
		if (w->cup eq OFF) return;			/* cursor already off */
		w->cup=OFF;							/* converge */
		if ( w->selection) return;				/* not if selection on */
		write_cur(w,w->cu);					/* if visible, unwrite */
	othw
		if ( w->cup eq ON) return;			/* cursor already on */
		if ( w->selection) return;				/* not if selection on */
		if (write_cur(w,w->cu))				/* if visible, write */
			w->cup=ON;
	}
}

global
bool do_std_cursor(IT *w,short kcode)		/* kcode is < 0 !! */
{
	short k = kcode&0xff;

	if (kcode&NKF_SHIFT)
		if (kcode&NKF_CTRL)
			switch (k)
			{
				case NK_DOWN:
					(*w->arrowd)(w,WA_DNLINE,true);
					return true;
				case NK_UP:
					(*w->arrowd)(w,WA_UPLINE,true);
					return true;
				case NK_LEFT:
					(*w->arrowd)(w,WA_LFLINE,true);
					return true;
				case NK_RIGHT:
					(*w->arrowd)(w,WA_RTLINE,true);
					return true;
			}
		else
			switch (k)
			{
				case NK_DOWN:
				case NK_UP:
				{
					short disp;
					cur_off(w);
					make_vis_top(w);				/* also sets top */
					disp = w->cu.pos.y - w->norm.pos.y;
					(*w->arrowd)(w,k eq NK_DOWN ? WA_DNPAGE : WA_UPPAGE,true);
					via(w->upd_cinf)(w, w->norm.pos.y + disp, w->cu.updn, &w->cu, LOW);
				}
				return true;
				case NK_LEFT:
					cur_off(w);
					w->cu.scrx = 0;
					w->cu.updn = 0;
					w->cu.pos.x  = 0;
					make_vis_top(w);
				return true;
				case NK_RIGHT:
					cur_off(w);
					via(w->upd_cinf)(w, w->cu.pos.y, w->view.sz.w - 1, &w->cu, HIGH);
					make_vis_top(w);
				return true;
				case NK_CLRHOME:
					cur_off(w);
					if (w->base)
						stmfilast(w->base);		/* snel */
					w->cu.pos.y = w->view.sz.h - 1;
					via(w->upd_cinf)(w, w->cu.pos.y, w->view.sz.w - 1, &w->cu, HIGH);
					make_vis_top(w);
				return true;
			}
	else
	switch (k)
	{
	case NK_LEFT:
		cur_off(w);
		w->cu.scrx--;
		if (w->upd_cinf)
		{
			if ((*w->upd_cinf)(w, w->cu.pos.y, w->cu.scrx, &w->cu, LOW))
			{
				make_vis_top(w);
				return true;
			}
		}
		w->cu.scrx = 0;
		if (w->cu.pos.y > 0)
			w->cu.updn = w->view.sz.w - 1;
		else
			w->cu.updn = 0;
	fall_thru  						/* if scroll */
	case NK_UP:
		if (w->cu.pos.y > 0)
		{
			cur_off(w);
			w->cu.pos.y--;
			if (w->cu.pos.y eq w->norm.pos.y)
				(*w->arrowd)(w, WA_UPLINE,true);
			cur_off(w);
			via(w->upd_cinf)(w, w->cu.pos.y, w->cu.updn, &w->cu, LOW);
			make_vis_top(w);
		}
	return true;
	case NK_RIGHT:
		cur_off(w);
		w->cu.scrx++;

		if (w->upd_cinf)
			if ((*w->upd_cinf)(w, w->cu.pos.y, w->cu.scrx, &w->cu, HIGH) )
			{
				make_vis_top(w);
				return true;
			}
		w->cu.updn = 0;
	fall_thru 						/* if scroll */
	case NK_DOWN:
		if (w->cu.pos.y < w->view.sz.h - 1)
		{
			cur_off(w);
			w->cu.pos.y++;
			if (w->cu.pos.y eq w->norm.pos.y+w->norm.sz.h - 1)
				(*w->arrowd)(w,WA_DNLINE,true);
			cur_off(w);
			via(w->upd_cinf)(w, w->cu.pos.y, w->cu.updn, &w->cu, LOW);
			make_vis_top(w);
		}
	return true;
	case NK_CLRHOME:
		cur_off(w);
		w->cu=c1st;
		if (w->base)
			stmfifirst(w->base);		/* fast */
		make_vis_top(w);
		return true;
	}

	return false;			/* not processed */
}
