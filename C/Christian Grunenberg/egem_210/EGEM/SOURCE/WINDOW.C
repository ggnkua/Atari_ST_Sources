
#include <stdarg.h>
#include <string.h>
#include "proto.h"

#define WINCREATED	1
#define WINOPENED	100

static void send_winmsg(WIN *window,int msg_id,int msg4,int msg5,int msg6,int msg7)
{
	int msg[8];

	msg[3] = window->handle;
	msg[4] = msg4;
	msg[5] = msg5;
	msg[6] = msg6;
	msg[7] = msg7;
	_send_puf(msg_id,msg);
}

void CycleCloseWindows(char cycle_hot,char close_hot,int cycle_menu,int close_menu)
{
	_cycle_hot = UpperChar(cycle_hot);
	_close_hot = UpperChar(close_hot);

	_cycle = cycle_menu;
	_close = close_menu;

	_set_menu();
}

void _cycle_close_window(int cycle,int titel)
{
	reg WIN *window,*wins,*last;
	int mbuf[8];

	if (_dia_len==0 && _popup==0)
	{
		if (titel>0)
			menu_select(titel,0);

		if (_opened>0)
		{
			if (cycle && _opened==1)
				return;

			if ((window=get_top_window())!=NULL)
			{
				if (cycle)
				{
					wins = window+1;
					last = &_windows[MAX_WINDOWS];
					while (wins<last)
						if (wins->handle>0)
							break;
						else
							wins++;

					if (wins>=last)
					{
						last = window;
						wins = _windows;
						while (wins<last)
							if (wins->handle>0)
								break;
							else
								wins++;
					}
				}
				else
					wins = window;
				mbuf[3] = wins->handle;
				_send_puf((cycle) ? WIN_TOPPED : WIN_CLOSED,mbuf);
			}
		}
	}
}

#define DEFAULT_WINW 72
#define DEFAULT_WINH 72

int cdecl _default_icfs(int type,...)
{
	reg int bitpos, x, *c, ret = -1;
	reg unsigned long mask = 1L;
	va_list pp;
	static unsigned long pos = 0L;

	va_start(pp,type);
	if (type==ICF_GETPOS)
	{
		bitpos = 0;
		x = desk.g_x;

		do
		{
			if ((pos & mask)==0L)
			{
				pos |= mask;
				ret = bitpos+1;
				break;
			}

			bitpos++;
			x += DEFAULT_WINW;
			mask<<=1;
		}
		while (bitpos<32 && (x+DEFAULT_WINW)<=desk.g_x+desk.g_w);

		if (ret>0)
		{
			c = va_arg(pp,int*);
			*c = x;
			c = va_arg(pp,int*);
			*c = desk.g_y+desk.g_h-DEFAULT_WINH;
			c = va_arg(pp,int*);
			*c = DEFAULT_WINW;
			c = va_arg(pp,int*);
			*c = DEFAULT_WINH;
		}
	}
	else if (type==ICF_FREEPOS)
	{
		bitpos = va_arg(pp,int)-1;
		if (bitpos>=0 && bitpos<=31)
		{
			if (bitpos>0)
				mask <<= bitpos;
			pos &= ~mask;
			ret = 0;
		}
	}
	else
		ret = -32;

	va_end(pp);
	return (ret);
}

static void AvWin(int handle,int init)
{
	if (AvServer>=0)
	{
		int msg[8];
		msg[3] = handle;
		AvSendMsg(AvServer,(init) ? AV_ACCWINDOPEN : AV_ACCWINDCLOSED,msg);
	}
}

int _icfs_iconify(WIN *window,int iconify,int old_top)
{
	reg int handle = window->handle;

	if (iconify)
	{
		int x,y,w,h;

		if (win_iconified(window))
			return (TRUE);
		else if (!(window->gadgets & SMALLER))
			return (FAIL);
		else if ((window->posnr=(*_icfs)(ICF_GETPOS,&x,&y,&w,&h))>0)
		{
			reg int top = (old_top==FALSE) ? _get_top() : old_top;

			if (top==handle)
				top = FALSE;

			wind_close(handle);
			wind_delete(handle);

			window->iconified |= ICFS;

			window->handle = wind_create(NAME|MOVER,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			window_name(window,window->name,window->icon_name);
			wind_open(window->handle,x,y,w,h);
			wind_xget(window->handle,WF_WORKXYWH,&window->icf_work.g_x,&window->icf_work.g_y,&window->icf_work.g_w,&window->icf_work.g_h);

			if (top>=0)
				wind_set(_last_top = (top>0) ? top : window->handle,WF_TOP);

			if (handle!=window->handle && window->av_win)
			{
				AvWin(handle,FALSE);
				AvWin(window->handle,TRUE);
			}

			return (TRUE);
		}
		else
			return (FALSE);
	}
	else
	{
		if (window->iconified & ICFS)
		{
			wind_close(handle);
			wind_delete(handle);

			window->iconified &= ~ICFS;

			window->handle = wind_create(window->gadgets,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			window_name(window,window->name,window->icon_name);
			window_info(window,window->info);
			wind_set(window->handle,WF_BEVENT,_back_win);

			if (window->gadgets & HSLIDE)
			{
				wind_set(window->handle,WF_HSLIDE,window->sl_hpos);
				wind_set(window->handle,WF_HSLSIZE,window->sl_hsize);
			}

			if (window->gadgets & VSLIDE)
			{
				wind_set(window->handle,WF_VSLIDE,window->sl_vpos);
				wind_set(window->handle,WF_VSLSIZE,window->sl_vsize);
			}

			wind_open(_last_top=window->handle,window->curr.g_x,window->curr.g_y,window->curr.g_w,window->curr.g_h);
			(*_icfs)(ICF_FREEPOS,window->posnr);

			if (handle!=window->handle && window->av_win)
			{
				AvWin(handle,FALSE);
				AvWin(window->handle,TRUE);
			}
		}

		return (TRUE);
	}
}

int _get_top(void)
{
	int top,dummy;

	wind_xget(0,WF_TOP,&top,&dummy,&dummy,&dummy);
	return (top);
}

WIN *get_top_window(void)
{
	WIN *win = get_window(_get_top());
	if (win)
		_last_top = win->handle;
	return (win);
}

WIN *get_window(int handle)
{
	reg WIN *window = _windows;
	reg int i;

	if (handle<=0)
		return (NULL);

	for (i=MAX_WINDOWS;--i>=0;window++)
		if (window->handle==handle)
			return (window);

	return (NULL);
}

void window_top(WIN *win)
{
	if (_dia_len>0 || _popup)
	{
		send_winmsg(win,WIN_TOPPED,0,0,0,0);
		win->inside = FAIL;
	}
	else
	{
		wind_set(_last_top=win->handle,WF_TOP);
		_window_fast_mouse(win,TRUE);
	}
}

void window_bottom(WIN *win)
{
	if (_bottom)
	{
		if (_dia_len>0 || _popup)
			send_winmsg(win,WM_BOTTOMED,0,0,0,0);
		else
		{
			wind_set(win->handle,WF_BOTTOM);
			if (get_top_window()==NULL && _last_top==win->handle)
				_last_top = FAIL;
		}
		win->inside = FAIL;
	}
}

int window_first(WIN *win,GRECT *rect)
{
	return (wind_xget(win->handle,WF_FIRSTXYWH,&rect->g_x,&rect->g_y,&rect->g_w,&rect->g_h));
}

int window_next(WIN *win,GRECT *rect)
{
	return (wind_xget(win->handle,WF_NEXTXYWH,&rect->g_x,&rect->g_y,&rect->g_w,&rect->g_h));
}

void _window_fast_mouse(WIN *window,int top)
{
	window->inside = FAIL;

	if (_popup==0 && _dia_len==0 && (top || get_top_window()==window))
	{
		if (!window->iconified)
		{
			SCROLL *sc = window->scroll;
			GRECT area;
			int x,y;

			area = window->work;
			if (sc)
			{
				area.g_x += sc->tbar_l;
				area.g_y += sc->tbar_u;
				area.g_w -= sc->tbar_l+sc->tbar_r;
				area.g_h -= sc->tbar_u+sc->tbar_d;
			}

			_mouse_pos(&x,&y);
			if ((window->inside=rc_inside(x,y,&area))!=0)
			{
				if (window->mouse_in>=0)
					graf_mouse(window->mouse_in,window->mouse_inform);
			}
			else if (window->mouse_out>=0)
				graf_mouse(window->mouse_out,window->mouse_outform);
		}
		else if (window->mouse_out>=0)
			graf_mouse(window->mouse_out,window->mouse_outform);
	}
}

void _reset_mouse(void)
{
	WIN *window;

	if (_dia_len==0 && _popup==0 && (window=get_top_window())!=NULL)
		_window_fast_mouse(window,TRUE);
}

void window_mouse(WIN *window)
{
	_window_fast_mouse(window,FALSE);
}

void window_set_mouse(WIN *window,int in,int out,MFORM *in_form,MFORM *out_form)
{
	if (window->dialog!=NULL)
		in = out = FAIL;

	window->mouse_in = in;
	window->mouse_out = out;
	window->mouse_inform = in_form;
	window->mouse_outform = out_form;
	window_mouse(window);
}

WIN *open_window(char *title,char *icon_title,char *info,OBJECT *icon,int typ,int box,int min_w,int min_h,GRECT *max_curr,GRECT *curr,SCROLL *scroll,void (*redraw)(WIN *,GRECT *))
{
	reg int handle,i,av_win = (AvServer>=0 && _no_av_win==0);
	reg WIN *window,*win;
	int x,y;

	_no_av_win = 0;

	if (_dia_len>0 || _popup)
		return (NULL);

	for (i=MAX_WINDOWS,window=_windows;--i>=0;window++)
		if (window->handle<=0)
			break;

	if (i<0)
		return(NULL);

	if (title)
		typ |= NAME;

	if (info)
		typ |= INFO;

	if (magx)
		typ |= BACKDROP;

	if (max_curr==NULL)
		max_curr = &desk;

	handle = wind_create(typ,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	if (handle>0)
	{
		for (i=MAX_WINDOWS,win=_windows;--i>=0;win++)
			if (win->handle>0)
				win->inside = FAIL;

		window->handle = handle;
		window->vdi_handle = x_handle;
		window->gadgets = typ;

		window->min_w = max(min_w,(gr_cw*12));
		window->min_h = max(min_h,(gr_ch*4));
		window->icon = icon;
		window->redraw = (void *) redraw;
		window->scroll = scroll;
		window->curr = *curr;
		window->max = *max_curr;
		window->sl_hpos = window->sl_hsize = window->sl_vpos = window->sl_vsize = -1000;

		if (typ & NAME)
			window_name(window,title,icon_title);

		if (typ & INFO)
			window_info(window,info);

		if (_back_win && _bevent)
			wind_set(handle,WF_BEVENT,1);

		window_size(window,curr);
		curr = &window->curr;

		if (box)
			graf_growbox(max_w>>1,max_h>>1,1,1,curr->g_x,curr->g_y,curr->g_w,curr->g_h);

		wind_open(_last_top=handle,curr->g_x,curr->g_y,curr->g_w,curr->g_h);
		window->opened = WINOPENED;

		_mouse_pos(&x,&y);
		window->inside = rc_inside(x,y,&window->work);
		window->mouse_in = window->mouse_out = FAIL;
		window->av_win = av_win;

		if (av_win)
			AvWin(handle,TRUE);

		_opened++;
		_set_menu();

		return (window);
	}
	else
		return (NULL);
}

void window_reinit(WIN *win,char *title,char *icon_title,char *info,int home)
{
	SCROLL *sc = win->scroll;

	if (sc && home)
		sc->hpos = sc->vpos = sc->px_hpos = sc->px_vpos = 0;

	window_name(win,title,icon_title);
	window_info(win,info);

	win->opened = WINCREATED;
	window_size(win,&win->curr);
	win->opened = WINOPENED;

	redraw_window(win,NULL);
}

int close_window(WIN *window,int box)
{
	reg int handle = window->handle, exit = TRUE;

	if (handle>0)
	{
		if (!_ac_close && (_dia_len>0 || _popup))
		{
			send_winmsg(window,WM_CLOSED,0,0,0,0);
			return (FALSE);
		}

		if (box && !_ac_close)
			graf_shrinkbox(max_w>>1,max_h>>1,1,1,window->work.g_x,window->work.g_y,window->work.g_w,window->work.g_h);

		if (window->iconified & ICFS)
			(*_icfs)(ICF_FREEPOS,window->posnr);

		if (window->av_win && (!_ac_close || multi))
			AvWin(handle,FALSE);

		memset(window,0,sizeof(WIN));
		_opened = max(_opened-1,0);

		_set_menu();

		if (!_ac_close)
		{
			if (!wind_close(handle) || !wind_delete(handle))
				exit = FALSE;
			if (get_top_window()==NULL && _last_top==handle)
				_last_top = FAIL;
			_reset_mouse();
		}
	}
	else
		exit = FALSE;

	return (exit);
}

void window_name(WIN *win,char *name,char *icon_name)
{
	win->name = name;
	win->icon_name = icon_name;

	if (win->gadgets & NAME)
	{
		if (win_iconified(win) && icon_name)
			name = icon_name;

		if (name==NULL)
			name = "";

		if (_dia_len>0 || _popup)
			send_winmsg(win,WIN_NAME,(int) (((long) name)>>16),(int) name,0,0);
		else
			wind_set(win->handle,WF_NAME,name);
	}
}

void window_info(WIN *win,char *info)
{
	win->info = info;

	if ((win->gadgets & INFO) && !(win->iconified & ICFS))
	{
		if (info==NULL)
			info = "";
		if (_dia_len>0 || _popup)
			send_winmsg(win,WIN_INFO,(int) (((long) info)>>16),(int) info,0,0);
		else
			wind_set(win->handle,WF_INFO,info);
	}
}

void window_border(int kind,int x,int y,int w_in,int h_in,GRECT *out)
{
	out->g_x = out->g_y = 0;
	out->g_w = w_in;
	out->g_h = h_in;
	window_calc(WC_BORDER,kind,out,out);
	out->g_x = max(x,desk.g_x);
	out->g_y = max(y,desk.g_y);
	Min(&out->g_w,desk.g_w);
	Min(&out->g_h,desk.g_h);
}

void window_calc(int type,int kind,GRECT *in,GRECT *out)
{
	wind_calc(type,kind,in->g_x,in->g_y,in->g_w,in->g_h,
			  &out->g_x,&out->g_y,&out->g_w,&out->g_h);
}

WIN *window_find(int x,int y)
{
	return (get_window(wind_find(x,y)));
}

void window_scroll_slider(WIN *win,int vh)
{
	reg SCROLL *sc = win->scroll;
	reg long pos,size;
	reg int max_h,max_v;

	pos = size = 1000;
	if (vh==HOR_SLIDER)
	{
		if (!(win->gadgets & HSLIDE))
			return;
		else if ((max_h=sc->hsize-sc->hpage)>0)
		{
			pos *= sc->hpos;
			pos /= max_h;

			size *= sc->hpage;
			size /= sc->hsize;
		}
		else
			pos = 0;
	}
	else if (!(win->gadgets & VSLIDE))
		return;
	else if ((max_v=sc->vsize-sc->vpage)>0)
	{
		pos *= sc->vpos;
		pos /= max_v;
		size *= sc->vpage;
		size /= sc->vsize;
	}
	else
		pos = 0;

	window_slider(win,vh,(int) pos,(int) size);
}

void window_size(WIN *win,GRECT *size)
{
	GRECT curr = *size,work;
	reg DIAINFO *info = (DIAINFO *) win->dialog;
	reg SCROLL *sc = win->scroll;
	reg int old_h,old_v;

	Max(&curr.g_x,win->max.g_x);
	Max(&curr.g_y,win->max.g_y);

	curr.g_w = max(min(curr.g_w,win->max.g_w),win->min_w);
	curr.g_h = max(min(curr.g_h,win->max.g_h),win->min_h);

	win->fulled = rc_equal(&curr,&win->max);
	win->prev = win->curr;

	if (sc)
	{
		Max(&sc->px_hline,1);
		Max(&sc->px_vline,1);

		old_h = sc->hpos;
		old_v = sc->vpos;

		window_calc(WC_WORK,win->gadgets,&curr,&work);

		sc->hpage = max((work.g_w-sc->tbar_l-sc->tbar_r)/sc->px_hline,1);
		sc->vpage = max((work.g_h-sc->tbar_u-sc->tbar_d)/sc->px_vline,1);

		if (win->opened)
		{
			sc->hpos = max(min(sc->hpos,sc->hsize-sc->hpage),0);
			sc->vpos = max(min(sc->vpos,sc->vsize-sc->vpage),0);
		}
		else
			sc->hpos = sc->vpos = sc->px_hpos = sc->px_vpos = 0;

		if (_dial_round && info==NULL)
			work.g_x &= ~7;

		work.g_w = sc->tbar_l + sc->tbar_r + (sc->hpage*sc->px_hline);
		work.g_h = sc->tbar_u + sc->tbar_d + (sc->vpage*sc->px_vline);

		win->work = work;
		window_calc(WC_BORDER,win->gadgets,&work,&curr);
	}
	else
		window_calc(WC_WORK,win->gadgets,&curr,&win->work);

	win->curr = curr;

	if (win->opened)
	{
		_window_fast_mouse(win,FALSE);
		if (!win_iconified(win))
		{
			if (_dia_len>0 || _popup)
				send_winmsg(win,WM_SIZED,curr.g_x,curr.g_y,curr.g_w,curr.g_h);
			else
				wind_set(win->handle,WF_CURRXYWH,curr.g_x,curr.g_y,curr.g_w,curr.g_h);
		}
	}

	if (info)
	{
		reg OBJECT *tree = info->di_tree;

		*(GRECT *) &tree->ob_x = win->work;
		tree->ob_x += info->di_xy_off;
		tree->ob_y += info->di_xy_off;
		tree->ob_width -= info->di_wh_off;
		tree->ob_height -= info->di_wh_off;
	}

	if (sc)
	{
		window_scroll_slider(win,HOR_SLIDER);
		window_scroll_slider(win,VERT_SLIDER);
		if (win->opened==WINOPENED && (old_h!=sc->hpos || old_v!=sc->vpos))
		{
			scroll_window(win,WIN_SCROLL,NULL);
			_send_msg(win,0,WIN_SCROLLED,old_h,old_v);
		}
	}
}

static void set_slide(WIN *win,int set_id,int msg_id,int val)
{
	if (_dia_len>0 || _popup)
		send_winmsg(win,msg_id,val,0,0,0);
	else
		wind_set(win->handle,set_id,val);
}

void window_slider(WIN *win,int dir,int pos,int size)
{
	reg int set = !(win->iconified & ICFS);

	pos = min(pos,1000);

	if (dir!=HOR_SLIDER)
	{
		if (win->gadgets & VSLIDE)
		{
			if (pos>=0 && win->sl_vpos!=pos)
			{
				win->sl_vpos = pos;
				if (set)
					set_slide(win,WF_VSLIDE,WIN_VSLIDE,pos);
			}

			if (size>0 && win->sl_vsize!=size)
			{
				win->sl_vsize = size;
				if (set)
					set_slide(win,WF_VSLSIZE,WIN_VSLSIZE,size);
			}
		}
	}
	else if (win->gadgets & HSLIDE)
	{
		if (pos>=0 && win->sl_hpos!=pos)
		{
			win->sl_hpos = pos;
			if (set)
				set_slide(win,WF_HSLIDE,WIN_HSLIDE,pos);
		}

		if (size>0 && win->sl_hsize!=size)
		{
			win->sl_hsize = size;
			if (set)
				set_slide(win,WF_HSLSIZE,WIN_HSLSIZE,size);
		}
	}
}

void redraw_window(WIN *win,GRECT *area)
{
#ifndef SMALL_EGEM
	EDINFO ed;
#endif
	GRECT cursor,work,mouse,m_work;
	reg int redraw = !win_iconified(win),clipped,mouse_off;
	reg OBJECT *icon;
	reg DIAINFO *info = (DIAINFO *) win->dialog;
	reg SCROLL *sc = win->scroll;
	int d,pxy[4];

	if (sc)
	{
		sc->px_hpos = sc->hpos*sc->px_hline;
		sc->px_vpos = sc->vpos*sc->px_vline;
	}

	if (area==NULL)
		area = &desk;
	else if (!rc_intersect(&desk,area))
		return;

	if ((redraw && win->redraw==NULL) || (_dia_len|_popup))
	{
		int msg[8];

		msg[3] = win->handle;
		*(GRECT *) &msg[4] = *area;
		_send_puf(WM_REDRAW,msg);
		return;
	}

	if (info!=NULL)
	{
		info->di_cursor = FALSE;
		info->di_drawn = TRUE;
	}

	if (redraw)
	{
		icon = NULL;

	#ifndef SMALL_EGEM
		if (info && win->iconified==0 && _edit_get_info(info->di_tree,info->di_ed_obj,info->di_ed_index,&ed))
		{
			_calc_cursor(info,&ed,&cursor);
			info->di_cursor = TRUE;
		}
	#endif
	}
	else
		icon = (win->icon) ? win->icon : iconified;

	if (icon)
	{
		icon->ob_x = win->icf_work.g_x + ((win->icf_work.g_w - icon->ob_width)>>1);
		icon->ob_y = win->icf_work.g_y + ((win->icf_work.g_h - icon->ob_height)>>1);
	}

	graf_mkstate(&mouse.g_x,&mouse.g_y,&d,&d);
	mouse.g_x -= 16;
	mouse.g_y -= 16;
	mouse.g_w = 32;
	mouse.g_h = 32;
	rc_intersect(&desk,&mouse);

	wind_update(BEG_UPDATE);
	clipped = mouse_off = FALSE;
	window_first(win,&work);
	while (work.g_w>0 && work.g_h>0)
	{
		if (rc_intersect(area,&work))
		{
			if (!mouse_off)
			{
				m_work = work;
				if ((mouse_off=rc_intersect(&mouse,&m_work))!=0)
					MouseOff();
			}

			if (redraw)
			{
				rc_grect_to_array(&work,pxy);
				vs_clip(win->vdi_handle,1,pxy);
				clipped = (win->vdi_handle==x_handle);

				if (info)
					(*(D_PROC) win->redraw)(info,&work,&cursor);
				else
					(*(R_PROC) win->redraw)(win,&work);
			}
			else
			{
				_clip_rect(&work);
				clipped = TRUE;
				rc_sc_clear(&work);
				if (icon)
					objc_draw(icon,0,MAX_DEPTH,work.g_x,work.g_y,work.g_w,work.g_h);
			}
		}
		window_next(win,&work);
	}

	if (clipped)
		_clip_rect(&desk);
	if (mouse_off)
		MouseOn();
	wind_update(END_UPDATE);
}

void _arrow_window(SCROLL *sc,int mode,int speed)
{
	switch (mode)
	{
	case WA_LFPAGE:
		sc->hpos -= max(sc->hpage-sc->hscroll,1)*speed;break;
	case WA_UPPAGE:
		sc->vpos -= max(sc->vpage-sc->vscroll,1)*speed;break;
	case WA_RTPAGE:
		sc->hpos += max(sc->hpage-sc->hscroll,1)*speed;break;
	case WA_DNPAGE:
		sc->vpos += max(sc->vpage-sc->vscroll,1)*speed;break;
	case WA_LFLINE:
		sc->hpos -= speed*sc->hscroll;break;
	case WA_UPLINE:
		sc->vpos -= speed*sc->vscroll;break;
	case WA_RTLINE:
		sc->hpos += speed*sc->hscroll;break;
	case WA_DNLINE:
		sc->vpos += speed*sc->vscroll;break;
	case WIN_START:
		sc->vpos = 0;
	case LINE_START:
		sc->hpos = 0; break;
	case WIN_END:
		sc->hpos = 0;sc->vpos = sc->vsize;break;
	case LINE_END:
		sc->hpos = sc->hsize; break;
	}
}

void scroll_window(WIN *win,int mode,GRECT *rect)
{
	GRECT area,work,work2;
	reg DIAINFO *info = (DIAINFO *) win->dialog;
	reg SCROLL *sc = win->scroll;
	reg int dist_h,dist_v,old_h,old_v,clipped,depth;
	int pxy[4];

	if (sc==NULL)
		return;

	_arrow_window(sc,mode,1);

	sc->hpos = max(min(sc->hpos,sc->hsize-sc->hpage),0);
	sc->vpos = max(min(sc->vpos,sc->vsize-sc->vpage),0);

	old_h = sc->px_hpos;
	old_v = sc->px_vpos;
	sc->px_hpos = sc->hpos*sc->px_hline;
	sc->px_vpos = sc->vpos*sc->px_vline;

	if ((dist_h=(sc->px_hpos-old_h))!=0)
		window_scroll_slider(win,HOR_SLIDER);

	if ((dist_v=(sc->px_vpos-old_v))!=0)
		window_scroll_slider(win,VERT_SLIDER);

	if ((dist_h==0 && dist_v==0) || win->iconified || sc->scroll==FALSE)
		return;

	if (rect)
		area = *rect;
	else
	{
		area = win->work;
		area.g_x += sc->tbar_l;
		area.g_y += sc->tbar_u;
		if ((area.g_w-=sc->tbar_l+sc->tbar_r)<=0 || (area.g_h-=sc->tbar_u+sc->tbar_d)<=0)
			return;
	}

	if (win->redraw==NULL || _dia_len>0 || _popup)
		redraw_window(win,&area);
	else
	{
		if (info)
			depth = (sc->obj==ROOT) ? MAX_DEPTH : 0;

		clipped = FALSE;
		wind_update(BEG_UPDATE);
		MouseOff();
		window_first(win,&work);
		if (work.g_w>0 && work.g_h>0)
			for (;;)
			{
				if (rc_intersect(&area,&work))
				{
					switch (rc_sc_scroll(&work,dist_h,dist_v,&work2))
					{
					case 2:
						rc_grect_to_array(&work2,pxy);
						vs_clip(win->vdi_handle,1,pxy);
						if (info)
							objc_draw(info->di_tree,sc->obj,depth,work2.g_x,work2.g_y,work2.g_w,work2.g_h);
						else
							(*(R_PROC) win->redraw)(win,&work2);
					case 1:
						rc_grect_to_array(&work,pxy);
						vs_clip(win->vdi_handle,1,pxy);
						clipped = (win->vdi_handle==x_handle);
						if (info)
							objc_draw(info->di_tree,sc->obj,depth,work.g_x,work.g_y,work.g_w,work.g_h);
						else
							(*(R_PROC) win->redraw)(win,&work);
					}
				}

				if (clipped)
					_clip_rect(&desk);

				window_next(win,&work);
				if (work.g_w<=0 || work.g_h<=0)
					break;
			}

		MouseOn();
		wind_update(END_UPDATE);
	}
}
