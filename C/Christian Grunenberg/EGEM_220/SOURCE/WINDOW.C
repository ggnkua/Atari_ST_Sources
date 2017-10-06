
#include "proto.h"
#include <string.h>
#include <stdarg.h>

#define WINCREATED	1
#define WINOPENED	100

static int top = -1;

#ifndef SMALL_NO_ICONIFY
int		_iconified;
#endif

#ifndef SMALL_NO_SCROLL
int _scroll,_scroll_all;
#endif

WIN	*_window_list[MAX_WINDOWS+1];

static void kill_window(WIN *kill)
{
	reg WIN **wins=_window_list,*window;
	reg int i;

	for (i=0;(window=*wins++)!=NULL && window!=kill;i++);
	memcpy(&_window_list[i],&_window_list[i+1],sizeof(WIN *)*(MAX_WINDOWS-i));
}

static void insert_window(WIN *insert,int first)
{
	reg WIN **wins=_window_list;

	kill_window(insert);
	if (first)
		memcpy(&wins[1],&wins[0],sizeof(WIN *)*MAX_WINDOWS);
	else
	{
		while (*wins++!=NULL);
		wins--;
	}
	*wins = insert;
}

static void send_winmsg(WIN *window,int msg_id,int msg4,int msg5,int msg6,int msg7)
{
	int msg[8];

	msg[3] = window->handle;
	msg[4] = msg4;
	msg[5] = msg5;
	msg[6] = msg6;
	msg[7] = msg7;
	_send_puf(TRUE,msg_id,msg);
}

#ifndef SMALL_NO_XACC_AV
static void AvWin(WIN *win,int init)
{
	XAcc *av;
	if ((av=find_id(AvServer))!=NULL && (av->va_msgs&MSG_ACCWINDOPEN))
	{
		if (init!=win->av_win)
		{
			int msg[8];
			msg[3] = win->handle;
			AvSendMsg(AvServer,(init) ? AV_ACCWINDOPEN : AV_ACCWINDCLOSED,msg);
		}
	}
	else
		init = FALSE;
	win->av_win = init;
}

void _AvAllWins(void)
{
	reg WIN **windows=_window_list,*win;
	while ((win=*windows++)!=NULL)
		AvWin(win,TRUE);
#ifndef SMALL_NO_MENU
	_inform_buffered(MENU_INIT);
#endif
}
#endif

#ifndef SMALL_NO_ICONIFY
static int icfs_iconify(WIN *window,int iconify,int old_top)
{
	reg DIAINFO *info = (DIAINFO *) window->dialog;
	reg int handle = window->handle;
#ifndef SMALL_NO_XACC_AV
	reg int old = handle;
#endif
	int x,y,w,h;

	if (iconify)
	{
		if (window->iconified & ICFS)
			return (TRUE);
		else if ((window->posnr=(*_icfs)(ICF_GETPOS,&x,&y,&w,&h))<=0)
			return (FALSE);
	}
	else if ((window->iconified & ICFS)==0)
		return (FALSE);

	wind_close(handle);
	wind_delete(handle);

	window->iconified ^= ICFS;

	window->handle = handle = wind_create(iconify ? NAME|MOVER : window->gadgets,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	window_name(window,window->name,window->icon_name);

	if (iconify)
	{
		wind_open(handle,x,y,w,h);
		wind_xget(handle,WF_WORKXYWH,&window->icon_work.g_x,&window->icon_work.g_y,&window->icon_work.g_w,&window->icon_work.g_h);
		_iconified++;

		if (old_top>=0)
			_new_top(old_top==FALSE ? handle : old_top,TRUE);
	}
	else
	{
		window_info(window,window->info);
		wind_set(handle,WF_BEVENT,_back_win);

		if (window->gadgets & HSLIDE)
		{
			wind_set(handle,WF_HSLIDE,window->sl_hpos);
			wind_set(handle,WF_HSLSIZE,window->sl_hsize);
		}

		if (window->gadgets & VSLIDE)
		{
			wind_set(handle,WF_VSLIDE,window->sl_vpos);
			wind_set(handle,WF_VSLSIZE,window->sl_vsize);
		}

		wind_open(handle,window->curr.g_x,window->curr.g_y,window->curr.g_w,window->curr.g_h);
		(*_icfs)(ICF_FREEPOS,window->posnr);
		_iconified--;

		if (old_top>=0)
			_new_top(handle,FAIL);
	}

#ifndef SMALL_NO_XACC_AV
	if (old!=handle)
	{
		window->handle = old;
		AvWin(window,FALSE);
		window->handle = handle;
		AvWin(window,TRUE);
	}
#endif

	if (info)
		info->di_drawn = FALSE;

	return (TRUE);
}
#endif

void WindowItems(WIN *win,int cnt,MITEM *items)
{
	win->items = items;
	win->items_cnt = cnt;
}

int WindowHandler(int mode,WIN *window,GRECT *icon)
{
#ifndef SMALL_NO_SCROLL
	reg SCROLL *sc;
#endif
	reg WIN **wins = _window_list;
	int mbuf[8],idx,app,top,d,open,hdl,last = -1;

	wind_xget(0,WF_TOP,&top,&d,&d,&idx);
	top = (magx && top<0) ? idx : top;
	_new_top(top,FALSE);

	if (!output || (mode!=W_GLOBALCYCLE && mode!=W_BOTTOM && (_opened==0 || (window==NULL && (window=get_window(top))==NULL))))
		return (FALSE);
	if (window)
		mbuf[3] = window->handle;

	switch (mode)
	{
	case W_GLOBALCYCLE:
		if (owner)
		{
			while ((hdl=top)>0)
			{
				if (!wind_xget(hdl,WF_OWNER,&idx,&open,&d,&top))
					break;
				if (open)
				{
					app = idx;
					last = hdl;
				}
			}
			if ((mbuf[3]=last)>0)
				return (AvSendMsg(app,app==ap_id ? WIN_TOPPED : WM_TOPPED,mbuf));
		}
	#ifndef SMALL_NO_XACC_AV
		else if (AvServer>=0)
		{
			KEYTAB *keytab = Keytbl((void *) -1l,(void *) -1l,(void *) -1l);
			reg char *tab = keytab->unshift;

			for (idx=0;idx<128 && *tab++!='w';idx++);

			mbuf[3] = K_CTRL;
			mbuf[4] = ((idx & 127)<<8)|'w';

			return (AvSendMsg(AvServer,AV_SENDKEY,mbuf));
		}
	#endif
		return (FALSE);
	case W_BOTTOM:
		if (bottom)
		{
			mbuf[3] = top;

			if (owner && wind_xget(top,WF_OWNER,&app,&d,&d,&d))
				return (AvSendMsg(app,WM_BOTTOMED,mbuf));
			else if (get_window(top))
			{
				mbuf[0] = WM_BOTTOMED;
				break;
			}
		}
		if ((window=get_window(top))!=wins[0])
			return (FALSE);
	case W_INVCYCLE:
	case W_CYCLE:
		if (_opened<=1)
			return (FALSE);
		idx = wins[0]->index;
		if (mode==W_CYCLE)
		{
			if (++idx>=_opened)
				idx = 0;
		}
		else if (--idx<0)
			idx = _opened-1;
		do
		{
			window = *wins++;
		} while (window->index!=idx);

		mbuf[0] = WIN_TOPPED;
		mbuf[3] = window->handle;
		break;
	case W_CLOSE:
		if ((window->gadgets & CLOSER)==0)
			return (FALSE);
		mbuf[0] = WIN_CLOSED;
		break;
	case W_CLOSEALL:
		if ((_window_list[0]->gadgets & CLOSER)==0)
			return (FALSE);
		while ((window=*wins++)!=NULL)
			if (window->gadgets & CLOSER)
			{
				mbuf[3] = window->handle;
				_send_puf(TRUE,WIN_CLOSED,mbuf);
			}
		return (TRUE);
	case W_FULL:
		if (!(window->gadgets & FULLER))
			return (FALSE);
		mbuf[0] = WM_FULLED;
		break;
	case W_ICONIFYALLINONE:
		return (FALSE);
	case W_ICONIFYALL:
	case W_UNICONIFYALL:
	#ifndef SMALL_NO_ICONIFY
		window = _window_list[0];
	#endif
	case W_UNICONIFY:
	case W_ICONIFY:
	#ifndef SMALL_NO_ICONIFY
		if ((window->gadgets & SMALLER)==0)
			return (FALSE);
		mbuf[0] = WIN_CHANGED;
		*(WIN **) &mbuf[4] = window;

		if (_icfs)
			switch (mode)
			{
			case W_UNICONIFY:
				if (window->iconified & ICFS)
					icfs_iconify(window,FALSE,FALSE);
				else
					return (FALSE);
				break;
			case W_ICONIFY:
				icfs_iconify(window,!(window->iconified & ICFS),top==window->handle ? FALSE : top);
				break;
			case W_ICONIFYALL:
				while ((window=*wins++)!=NULL)
					if ((window->gadgets & SMALLER) && (window->iconified & ICFS)==0)
					{
						open = TRUE;
						goto icfs_iconifyall;
					}
			case W_UNICONIFYALL:
				open = FALSE;
				icfs_iconifyall:
				for (wins=_window_list;(window=*wins++)!=NULL;)
				{
					idx = (top==window->handle);
					if (icfs_iconify(window,open,FAIL)==FALSE)
						break;
					if (idx)
						top = window->handle;
				}
				_new_top(top,TRUE);
				mbuf[3] = -1;
				*(WIN **) &mbuf[4] = NULL;
			}
		else
			switch (mode)
			{
			case W_ICONIFY:
				if (icon && (window->iconified & ICONIFIED)==0)
				{
					window->iconified ^= ICONIFIED;
					if (_back_win && bevent)
						wind_set(window->handle,WF_BEVENT,0);
					wind_set(window->handle,WF_ICONIFY,icon->g_x,icon->g_y,icon->g_w,icon->g_h);
					window_name(window,window->name,window->icon_name);
					wind_xget(window->handle,WF_WORKXYWH,&window->icon_work.g_x,&window->icon_work.g_y,&window->icon_work.g_w,&window->icon_work.g_h);
					break;
				}
			case W_UNICONIFYALL:
			case W_UNICONIFY:
				for (;;)
				{
					if (mode==W_UNICONIFYALL && (window=*wins++)==NULL)
						break;
					if ((window->gadgets & SMALLER) && (window->iconified & ICONIFIED))
					{
						window->iconified ^= ICONIFIED;
						wind_set(window->handle,WF_UNICONIFY,window->curr.g_x,window->curr.g_y,window->curr.g_w,window->curr.g_h);
						wind_set(window->handle,WF_CURRXYWH,window->curr.g_x,window->curr.g_y,window->curr.g_w,window->curr.g_h);
						window_name(window,window->name,window->icon_name);
						if (_back_win && bevent)
							wind_set(window->handle,WF_BEVENT,1);
					}
					if (mode!=W_UNICONIFYALL)
						break;
				}
				if (mode==W_UNICONIFYALL)
				{
					mbuf[3] = -1;
					*(WIN **) &mbuf[4] = NULL;
				}
				break;
			case W_ICONIFYALL:
				return (FALSE);
			}
		_inform(MOUSE_INIT);
		break;
	#else
		return (FALSE);
	#endif
	default:
	#ifndef SMALL_NO_SCROLL
		if ((sc=window->scroll)!=NULL && !window->iconified)
		{
			long old_h=sc->hpos,old_v=sc->vpos;
			scroll_window(window,mode,NULL);
			if (old_h!=sc->hpos || old_v!=sc->vpos)
				_send_msg(window,window->handle,WIN_SCROLLED,0,0);
			return (TRUE);
		}
		else
	#endif
			return (FALSE);
	}
	_send_puf(TRUE,mbuf[0],mbuf);
	return (TRUE);
}

#ifndef SMALL_NO_ICONIFY
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
#endif

void _new_top(int new_top,int set)
{
	reg WIN *win;
	int get_top,magx_top,dummy;

	if (new_top<0)
	{
		wind_xget(0,WF_TOP,&get_top,&dummy,&dummy,&magx_top);
		new_top = (magx && get_top<0) ? magx_top : get_top;
	}
	else if (set==TRUE)
		wind_set(new_top,WF_TOP);

	win = get_window(new_top);
	if (new_top!=top || set)
	{
		int msg[8];
		msg[3] = top = new_top;
		_send_puf(TRUE,WIN_NEWTOP,msg);
		set = TRUE;
	}

	if (win)
		insert_window(win,TRUE);

	if (set)
	{
		_inform(MOUSE_INIT);
#ifndef SMALL_NO_MENU
		_inform_buffered(MENU_INIT);
#endif
	}
}

int GetTop(void)
{
	if (top<0 || !_untop)
		_new_top(-1,FALSE);
	return (top);
}

WIN *get_top_window(void)
{
	return (get_window(GetTop()));
}

WIN *get_window_list(int first)
{
	static int last=-1;
	reg int i;

	if (first)
		i = 0;
	else if (last>=0)
		i = last+1;
	else
		return (NULL);

	if (i<_opened)
		return (_window_list[last=i]);
	else
	{
		last = -1;
		return (NULL);
	}
}

WIN *get_window(int handle)
{
	reg WIN **wins=_window_list,*window;

	while ((window=*wins++)!=NULL)
		if (window->handle==handle)
			return (window);
	return (NULL);
}

void window_top(WIN *win)
{
	if (!output)
		send_winmsg(win,WIN_TOPPED,0,0,0,0);
	else
		_new_top(win->handle,TRUE);
}

void window_bottom(WIN *win)
{
	if (bottom)
	{
		if (!output)
			send_winmsg(win,WM_BOTTOMED,0,0,0,0);
		else
		{
			wind_set(win->handle,WF_BOTTOM);
			insert_window(win,FALSE);
			_new_top(-1,FALSE);
		}
	}
}

int window_first(WIN *win,GRECT *rect)
{
	if (!wind_xget(win->handle,WF_FIRSTXYWH,&rect->g_x,&rect->g_y,&rect->g_w,&rect->g_h))
		rect->g_w = rect->g_h = 0;
	win->first = *rect;
	return (rect->g_w>0 && rect->g_h>0);
}

int window_next(WIN *win,GRECT *rect)
{
#ifndef SMALL_NO_ICONIFY
	reg GRECT *work = win_iconified(win) ? &win->icon_work : &win->work,*first = &win->first;
#else
	reg GRECT *work = &win->work,*first = &win->first;
#endif
	if ((first->g_w>=work->g_w && first->g_h>=work->g_h) || !wind_xget(win->handle,WF_NEXTXYWH,&rect->g_x,&rect->g_y,&rect->g_w,&rect->g_h))
		rect->g_w = rect->g_h = 0;
	return (rect->g_w>0 && rect->g_h>0);
}

void draw_window(WIN *win,GRECT *area,void *para,int m_off,void (*redraw)(int,WIN*,GRECT*,GRECT*,void*))
{
	GRECT rect,list,ms_area,ms_work;
	reg int pxy[4],off = 0,first = RC_FIRST,pos = 0;

	if ((_dia_len && win->handle>0) || _no_output)
		return;

	rect = area!=NULL ? *area : desk;
	if (area==NULL || rc_intersect(&desk,&rect))
	{
		if (_mouse_off)
			m_off = MOUSE_ON;
		if (win->handle>0)
		{
		#ifndef SMALL_NO_ICONIFY
			GRECT *work = win_iconified(win) ? &win->icon_work : &win->work;
		#else
			GRECT *work = &win->work;
		#endif
			beg_update(FALSE,FALSE);
			if (window_first(win,&list))
				do
				{
					if (rc_intersect(&rect,&list))
					{
						if (!off && m_off!=MOUSE_ON)
						{
							if (m_off==MOUSE_OFF)
							{
								MouseOff();
								off++;
							}
							else
							{
								if (!pos)
								{
									mouse(&ms_area.g_x,&ms_area.g_y);
									ms_area.g_x -= 32;
									ms_area.g_y -= 32;
									ms_area.g_w = ms_area.g_h = 64;
									pos++;
								}
								ms_work = ms_area;
								if (rc_intersect(&list,&ms_work))
								{
									MouseOff();
									off++;
								}
							}
						}

						rc_grect_to_array(&list,pxy);
						if (win->vdi_handle!=x_handle)
						{
							if (win->vdi_handle>0)
								vs_clip(win->vdi_handle,1,pxy);
						}
						else
							restore_clipping(pxy);
						redraw(first,win,&list,work,para);
						first = 0;
					}
				} while(window_next(win,&list));
			end_update(off);
		}
		else
		{
			if (m_off!=MOUSE_ON)
				MouseOff();
			_clip_rect(&rect);
			redraw(first,NULL,&rect,NULL,para);
			if (m_off!=MOUSE_ON)
				MouseOn();
		}
	}
}

void window_set_mouse(WIN *window,int in,int work,int out,int icon,MFORM *in_form,MFORM *work_form,MFORM *out_form,MFORM *icon_form)
{
	window->inside = MOUSE_FAIL;
	window->mouse_in = in;
	window->mouse_work = work;
	window->mouse_out = out;
#ifndef SMALL_NO_ICONIFY
	window->mouse_icon = icon;
	window->mouse_iconform = icon_form;
#endif
	window->mouse_inform = in_form;
	window->mouse_workform = work_form;
	window->mouse_outform = out_form;
	_inform(MOUSE_INIT);
}

static int bits(int masc)
{
	reg int i,bit,cnt=0;
	for (i=16,bit=1;--i>=0;bit<<=1)
		if (masc & bit)
			cnt++;
	return (cnt);
}

long _top_timer;

long _Topper(long para,long time,MKSTATE *mk)
{
	beg_update(FALSE,FALSE);
	GetTop();
	end_update(FALSE);
	return (CONT_TIMER);
}

WIN *open_window(char *title,char *icon_title,char *info,OBJECT *icon,int typ,int box,int min_w,int min_h,GRECT *max_curr,GRECT *curr,SCROLL *scroll,void (*redraw)(int,WIN *,GRECT *),void *para,int msgs)
{
	GRECT max_win;
	reg int handle,bw,bh,i;
	reg WIN *window;

	if (!output || _opened==MAX_WINDOWS || (window=(WIN *) calloc(1,sizeof(WIN)))==NULL)
		return (NULL);

	max_win = max_curr!=NULL ? *max_curr : desk;
	if (max_curr==NULL || rc_intersect(&desk,&max_win))
	{
		if (magx)
			typ |= BACKDROP;
		handle = wind_create(typ,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
		if (handle>0)
		{
			_opened++;
			insert_window(window,TRUE);
			for (i=_opened;--i>=0;)
				_window_list[i]->index = i;

			window->handle = handle;
			window->vdi_handle = x_handle;
			window->gadgets = typ;
			window->msgs = msgs;

			bw = max(bits(typ&(CLOSER|FULLER|BACKDROP|SMALLER)),bits(typ&(LFARROW|RTARROW|SIZER)));
			if ((typ & (VSLIDE|UPARROW|DNARROW)) && (typ & (FULLER|SIZER|BACKDROP|SMALLER))==0)
				bw++;

			bh = max(bits(typ&CLOSER),bits(typ&(FULLER|UPARROW|DNARROW|SIZER)));
			if ((typ & (SMALLER|BACKDROP|NAME|MOVER)) && (typ & (CLOSER|FULLER))==0)
				bh++;
			if (typ & INFO)
				bh++;
			if ((typ & (HSLIDE|LFARROW|RTARROW)) && (typ & SIZER)==0)
				bh++;

			window->min_w = max(min_w,bw*gr_bw+gr_cw*2);
			window->min_h = max(min_h,bh*gr_bh+gr_ch);
		#ifndef SMALL_NO_ICONIFY
			window->icon = icon;
		#endif
			window->redraw = (void *) redraw;
		#ifndef SMALL_NO_SCROLL
			window->scroll = scroll;
		#endif
			window->curr = *curr;
			window->max = max_win;
			window->sl_hpos = window->sl_hsize = window->sl_vpos = window->sl_vsize = -1000;
			window->para = para;

			if (typ & NAME)
				window_name(window,title,icon_title);

			if (typ & INFO)
				window_info(window,info);

			if (_back_win && bevent)
				wind_set(handle,WF_BEVENT,1);

			window_size(window,curr);
			curr = &window->curr;

			if (box)
				graf_growbox(max_w>>1,max_h>>1,1,1,curr->g_x,curr->g_y,curr->g_w,curr->g_h);

			wind_open(handle,curr->g_x,curr->g_y,curr->g_w,curr->g_h);
			window->opened = WINOPENED;

			window->inside = MOUSE_FAIL;

			_new_top(handle,FALSE);

		#ifndef SMALL_NO_XACC_AV
			if (multi && AvServer<0)
				_MultiAv();
			else
				AvWin(window,TRUE);
		#endif

			if (!_untop && _top_timer==0)
				_top_timer = NewTimer(TOP_TIMER,0,_Topper);

			return (window);
		}
	}
	free(window);
	return (NULL);
}

void window_reinit(WIN *win,char *title,char *icon_title,char *info,int home,int draw)
{
#ifndef SMALL_NO_SCROLL
	GRECT area;
	SCROLL *sc = win->scroll;

	if (sc && home)
		sc->px_hpos = sc->px_vpos = sc->hpos = sc->vpos = 0;
#endif

	window_name(win,title,icon_title);
	window_info(win,info);

	win->opened = WINCREATED;
	window_size(win,&win->curr);
	win->opened = WINOPENED;

#ifndef SMALL_NO_SCROLL
	if (draw==TRUE)
	{
		if (window_work(win,&area))
			redraw_window(win,&area);
	}
	else if (draw==FALSE)
		redraw_window(win,NULL);

	if (sc)
	{
		sc->px_hpos = sc->hpos*sc->px_hline;
		sc->px_vpos = sc->vpos*sc->px_vline;
	}
#else
	if (draw>=FALSE)
		redraw_window(win,NULL);
#endif
}

int close_window(WIN *window,int box)
{
	reg int handle,exit = TRUE,i;

	if (window!=NULL && (handle=window->handle)>0)
	{
		if (!_ac_close)
		{
			if (!output)
			{
				send_winmsg(window,WIN_CLOSED,0,0,0,0);
				return (FALSE);
			}
			else if (box)
				graf_shrinkbox(max_w>>1,max_h>>1,1,1,window->work.g_x,window->work.g_y,window->work.g_w,window->work.g_h);
		}

	#ifndef SMALL_NO_ICONIFY
		if (window->iconified & ICFS)
		{
			(*_icfs)(ICF_FREEPOS,window->posnr);
			_iconified--;
		}
	#endif

	#ifndef SMALL_NO_XACC_AV
		if (!_ac_close || multi)
			AvWin(window,FALSE);
	#endif

		kill_window(window);
		memset(window,0,sizeof(WIN));
		free(window);

		for (i=--_opened;--i>=0;)
			_window_list[i]->index = i;

		if (_opened==0 && _top_timer)
		{
			KillTimer(_top_timer);
			_top_timer = 0;
		}

		if (!_ac_close)
		{
			if (!wind_close(handle) || !wind_delete(handle))
				exit = FALSE;
		#ifndef SMALL_NO_MENU
			_inform_buffered(MENU_INIT);
		#endif
			_new_top(-1,FALSE);
		}
		else
			top = -1;
	}
	else
		exit = FALSE;
	return (exit);
}

void window_name(WIN *win,char *name,char *icon_name)
{
	win->name = name;
#ifndef SMALL_NO_ICONIFY
	win->icon_name = icon_name;
#endif

	if (win->gadgets & NAME)
	{
	#ifndef SMALL_NO_ICONIFY
		if (icon_name && win_iconified(win))
			name = icon_name;
	#endif

		win->name_buffer[0] = '\0';
	#ifndef SMALL_NO_ICONIFY
		if (_win_id && (!win_iconified(win) || name==NULL || *name=='\0'))
	#else
		if (_win_id)
	#endif
		{
			if (name && *name)
				strcat(strcat(strcpy(win->name_buffer,"["),_win_id),"] ");
			else
				strcpy(win->name_buffer,_win_id);
		}

		if (name)
			strcat(win->name_buffer,name);
		name = win->name_buffer;

		if (!output)
			send_winmsg(win,WIN_NAME,(int) (((long) name)>>16),(int) name,0,0);
		else
			wind_set(win->handle,WF_NAME,name);
	}
}

void window_info(WIN *win,char *info)
{
	win->info = info;

#ifndef SMALL_NO_ICONIFY
	if ((win->gadgets & INFO) && !(win->iconified & ICFS))
#else
	if (win->gadgets & INFO)
#endif
	{
		if (info==NULL)
			info = "";
		if (!output)
			send_winmsg(win,WIN_INFO,(int) (((long) info)>>16),(int) info,0,0);
		else
			wind_set(win->handle,WF_INFO,info);
	}
}

void window_border(int kind,int x,int y,int w_in,int h_in,GRECT *out)
{
	if (w_in<0 || w_in>desk.g_w)
		w_in = desk.g_w;

	if (h_in<0 || h_in>desk.g_h)
		h_in = desk.g_h;
		
	out->g_x = out->g_y = 0;
	out->g_w = w_in;
	out->g_h = h_in;
	window_calc(WC_BORDER,kind,out,out);
	out->g_x = max(x,desk.g_x);
	out->g_y = max(y,desk.g_y);
	Min(&out->g_w,desk.g_w);
	Min(&out->g_h,desk.g_h);
}

int window_work(WIN *win,GRECT *out)
{
#ifndef SMALL_NO_SCROLL
	reg SCROLL *sc;
#endif

	*out = win->work;
#ifndef SMALL_NO_SCROLL
	if ((sc=win->scroll)!=NULL)
	{
		out->g_x += sc->tbar_l;
		out->g_y += sc->tbar_u;
		if ((out->g_w-=(sc->tbar_l+sc->tbar_r))<=0 || (out->g_h-=(sc->tbar_u+sc->tbar_d))<=0)
			return (FALSE);
	}
#endif

	return (TRUE);
}

void window_calc(int type,int kind,GRECT *in,GRECT *out)
{
	wind_calc(type,kind,in->g_x,in->g_y,in->g_w,in->g_h,
			  &out->g_x,&out->g_y,&out->g_w,&out->g_h);
}

WIN *window_find(int x,int y)
{
	reg WIN *win;

	if (_untop && (win=get_window(top))!=NULL)
	{
		if (!win->iconified)
		{
			if (rc_inside(x,y,&win->curr))
				return (win);
		}
	#ifndef SMALL_NO_ICONIFY
		else if (!(win->iconified & SHADE) && rc_inside(x,y,&win->icon_work))
			return (win);
	#endif
	}
	return (get_window(wind_find(x,y)));
}

#ifndef SMALL_NO_SCROLL
static void window_scroll_size(WIN *win,int vh)
{
	reg SCROLL *sc = win->scroll;
	reg long size;

	size = 1000l;
	if (vh==HOR_SLIDER)
	{
		if (!(win->gadgets & HSLIDE))
			return;
		else if (sc->hmax>0)
		{
			size *= sc->hpage;
			size /= sc->hsize;
		}
	}
	else if (!(win->gadgets & VSLIDE))
		return;
	else if (sc->vmax>0)
	{
		size *= sc->vpage;
		size /= sc->vsize;
	}

	window_slider(win,vh,FAIL,(int) size);
}
#endif

void window_size(WIN *win,GRECT *size)
{
	GRECT curr = *size;
	reg DIAINFO *info = (DIAINFO *) win->dialog;
#ifndef SMALL_NO_SCROLL
	GRECT work;
	reg SCROLL *sc = win->scroll;
	reg long old_h,old_v;
#endif

	Max(&curr.g_x,win->max.g_x);
	Max(&curr.g_y,win->max.g_y);
	Min(&curr.g_w,win->max.g_w);
	Min(&curr.g_h,win->max.g_h);

	win->fulled = rc_equal(size,&win->max) || rc_equal(&curr,&win->max);

	Max(&curr.g_w,win->min_w);
	Max(&curr.g_h,win->min_h);

	win->prev = win->curr;

#ifndef SMALL_NO_SCROLL
	if (sc)
	{
		Max(&sc->px_hline,1);
		Max(&sc->px_vline,1);

		old_h = sc->hpos;
		old_v = sc->vpos;

		window_calc(WC_WORK,win->gadgets,&curr,&work);

		sc->hpage = max((work.g_w-sc->tbar_l-sc->tbar_r)/sc->px_hline,1);
		sc->vpage = max((work.g_h-sc->tbar_u-sc->tbar_d)/sc->px_vline,1);

		if ((sc->hmax=sc->hsize-sc->hpage)<0)
			sc->hmax = 0;

		if ((sc->vmax=sc->vsize-sc->vpage)<0)
			sc->vmax = 0;

		if (win->opened)
		{
			if (sc->hpos<0)
				sc->hpos = 0;
			else if (sc->hpos>sc->hmax)
				sc->hpos = sc->hmax;
			if (sc->vpos<0)
				sc->vpos = 0;
			else if (sc->vpos>sc->vmax)
				sc->vpos = sc->vmax;
		}
		else
			sc->px_hpos = sc->px_vpos = sc->hpos = sc->vpos = 0;

		if (_dial_round && info==NULL)
			work.g_x &= ~7;

		work.g_w = sc->tbar_l + sc->tbar_r + (sc->hpage*sc->px_hline);
		work.g_h = sc->tbar_u + sc->tbar_d + (sc->vpage*sc->px_vline);

		win->work = work;
		window_calc(WC_BORDER,win->gadgets,&work,&curr);
	}
	else
#endif
		window_calc(WC_WORK,win->gadgets,&curr,&win->work);

	win->curr = curr;

	if (win->opened)
	{
	#ifndef SMALL_NO_ICONIFY
		if (!win_iconified(win))
	#endif
		{
			if (!output)
				send_winmsg(win,WM_SIZED,curr.g_x,curr.g_y,curr.g_w,curr.g_h);
			else
				wind_set(win->handle,WF_CURRXYWH,curr.g_x,curr.g_y,curr.g_w,curr.g_h);
		}
		_inform(MOUSE_INIT);
	}

	if (info)
		windial_calc(FALSE,info,&win->work);

#ifndef SMALL_NO_SCROLL
	if (sc)
	{
		window_scroll_size(win,HOR_SLIDER);
		window_scroll_size(win,VERT_SLIDER);
		_window_scroll_pos(win,HOR_SLIDER);
		_window_scroll_pos(win,VERT_SLIDER);

		if (win->opened==WINOPENED && (old_h!=sc->hpos || old_v!=sc->vpos))
		{
			scroll_window(win,WIN_SCROLL,NULL);
			_send_msg(win,win->handle,WIN_SCROLLED,0,0);
		}
	}
#endif
}

static void set_slide(WIN *win,int set_id,int msg_id,int val)
{
	if (!output)
		send_winmsg(win,msg_id,val,0,0,0);
	else
		wind_set(win->handle,set_id,val);
}

#ifndef SMALL_NO_SCROLL
void _window_scroll_pos(WIN *win,int vh)
{
	reg SCROLL *sc = win->scroll;
	reg long pos;
	reg int max;

	if (vh)
	{
		if (!(win->gadgets & VSLIDE))
			return;
		else if (sc->vmax>0)
		{
			if (_scroll || (max=win->work.g_h)>1000)
				pos = (1000*sc->vpos)/sc->vmax;
			else
				pos = (((max*sc->vpos)/sc->vmax)*1000)/max;
		}
		else
			pos = 0;

		if (win->sl_vpos!=(int) pos)
		{
			win->sl_vpos = (int) pos;
		#ifndef SMALL_NO_ICONIFY
			if (!(win->iconified & ICFS))
		#endif
				set_slide(win,WF_VSLIDE,WIN_VSLIDE,(int) pos);
		}
	}
	else
	{
		if (!(win->gadgets & HSLIDE))
			return;
		else if (sc->hmax>0)
		{
			if (_scroll || (max=win->work.g_w)>1000)
				pos = (1000*sc->hpos)/sc->hmax;
			else
				pos = (((max*sc->hpos)/sc->hmax)*1000)/max;
		}
		else
			pos = 0;

		if (win->sl_hpos!=(int) pos)
		{
			win->sl_hpos = (int) pos;
		#ifndef SMALL_NO_ICONIFY
			if (!(win->iconified & ICFS))
		#endif
				set_slide(win,WF_HSLIDE,WIN_HSLIDE,(int) pos);
		}
	}
}
#endif

void window_slider(WIN *win,int dir,int pos,int size)
{
#ifndef SMALL_NO_ICONIFY
	reg int set = !(win->iconified & ICFS);
#endif

	if (pos>1000)
		pos = 1000;

	if (size>1000)
		size = 1000;

	if (dir!=HOR_SLIDER)
	{
		if (win->gadgets & VSLIDE)
		{
			if (pos>=0 && win->sl_vpos!=pos)
			{
				win->sl_vpos = pos;
			#ifndef SMALL_NO_ICONIFY
				if (set)
			#endif
					set_slide(win,WF_VSLIDE,WIN_VSLIDE,pos);
			}

			if (size>=0)
			{
				if (size==0)
					size = -1;
				if (win->sl_vsize!=size)
				{
					win->sl_vsize = size;
				#ifndef SMALL_NO_ICONIFY
					if (set)
				#endif
						set_slide(win,WF_VSLSIZE,WIN_VSLSIZE,size);
				}
			}
		}
	}
	else if (win->gadgets & HSLIDE)
	{
		if (pos>=0 && win->sl_hpos!=pos)
		{
			win->sl_hpos = pos;
		#ifndef SMALL_NO_ICONIFY
			if (set)
		#endif
				set_slide(win,WF_HSLIDE,WIN_HSLIDE,pos);
		}

		if (size>=0)
		{
			if (size==0)
				size = -1;

			if (win->sl_hsize!=size)
			{
				win->sl_hsize = size;
			#ifndef SMALL_NO_ICONIFY
				if (set)
			#endif
					set_slide(win,WF_HSLSIZE,WIN_HSLSIZE,size);
			}
		}
	}
}

#ifndef SMALL_NO_ICONIFY
static void draw_icon(int first,WIN *dummy,GRECT *area,GRECT *work,void *icon)
{
	rc_sc_clear(area);
	if (icon)
		_ob_xdraw((OBJECT *) icon,0,area);
}
#endif

static void draw_win(int first,WIN *win,GRECT *area,GRECT *work,void *para)
{
	win->redraw(first,win,area);
}

void redraw_window(WIN *win,GRECT *area)
{
#ifndef SMALL_NO_EDIT
	EDINFO ed;
	int new;
#endif
#ifndef SMALL_NO_ICONIFY
	reg int redraw = !win_iconified(win);
	reg OBJECT *icon;
#endif
	reg DIAINFO *info = (DIAINFO *) win->dialog;
#ifndef SMALL_NO_SCROLL
	reg SCROLL *sc = win->scroll;

	if (sc)
	{
		sc->px_hpos = sc->hpos*sc->px_hline;
		sc->px_vpos = sc->vpos*sc->px_vline;
	}
#endif

#ifndef SMALL_NO_ICONIFY
	if ((redraw && win->redraw==NULL) || (!redraw && win->icon==NIL) || !output)
#else
	if (win->redraw==NULL || !output)
#endif
	{
		int msg[8];

		msg[3] = win->handle;
		*(GRECT *) &msg[4] = area!=NULL ? *area : desk;
		_send_puf(TRUE,WM_REDRAW,msg);
		return;
	}

	if (info)
	{
	#ifndef SMALL_NO_EDIT
		new = (!info->di_drawn || info->di_cursor);
		info->di_cursor = FALSE;
	#endif
		info->di_drawn = TRUE;
	}

#ifndef SMALL_NO_ICONIFY
	if (redraw)
#endif
	{
	#ifndef SMALL_NO_EDIT
		if (info && new && _edit_get_info(info->di_tree,info->di_ed_obj,info->di_ed_index,&ed))
		{
			OBJECT *tree = info->di_tree;
			GRECT *crs = &info->di_crsrect;

			info->di_cursor = TRUE;
			_calc_cursor(info,&ed,crs);
			draw_window(win,area,crs,MOUSE_TEST,(WIN_DRAW) win->redraw);
			crs->g_x -= tree->ob_x;
			crs->g_y -= tree->ob_y;
		}
		else
	#endif
		draw_window(win,area,NULL,info==NULL ? MOUSE_TEST : MOUSE_ON,info!=NULL ? (WIN_DRAW) win->redraw : draw_win);
	}
#ifndef SMALL_NO_ICONIFY
	else
	{
		if ((icon=(win->icon) ? win->icon : iconified)!=NULL)
		{
			icon->ob_x = win->icon_work.g_x + ((win->icon_work.g_w - icon->ob_width)>>1);
			icon->ob_y = win->icon_work.g_y + ((win->icon_work.g_h - icon->ob_height)>>1);
		}
		draw_window(win,area,icon,MOUSE_TEST,draw_icon);
	}
#endif
}

#ifndef SMALL_NO_SCROLL

#define offset(diff)	(speed) ? diff*speed : diff

void _arrow_window(SCROLL *sc,int mode,reg int speed)
{
	switch (mode)
	{
	case WA_DNLINE:
		sc->vpos += offset(sc->vscroll);break;
	case WA_UPLINE:
		sc->vpos -= offset(sc->vscroll);break;
	case WA_RTLINE:
		sc->hpos += offset(sc->hscroll);break;
	case WA_LFLINE:
		sc->hpos -= offset(sc->hscroll);break;
	case WA_LFPAGE:
		sc->hpos -= offset(sc->hpage);break;
	case WA_UPPAGE:
		sc->vpos -= offset(sc->vpage);break;
	case WA_RTPAGE:
		sc->hpos += offset(sc->hpage);break;
	case WA_DNPAGE:
		sc->vpos += offset(sc->vpage);break;
	}
}

void scroll_window(WIN *win,int mode,GRECT *rect)
{
	GRECT area,work,work2;
	reg DIAINFO *info = (DIAINFO *) win->dialog;
	reg SCROLL *sc = win->scroll;
	reg long dist_h,dist_v;
	reg int pxy[4],all,first = RC_FIRST|RC_SCROLL;
	int off,depth;

	switch (mode)
	{
	case WIN_START:
		sc->vpos = 0;
	case LINE_START:
		sc->hpos = 0;break;
	case WIN_END:
		sc->hpos = 0;sc->vpos = sc->vmax;break;
	case LINE_END:
		sc->hpos = sc->hmax;break;
	default:
		if (mode!=WIN_SCROLL)
			_arrow_window(sc,mode,0);
		if (sc->hpos<0)
			sc->hpos = 0;
		else if (sc->hpos>sc->hmax)
			sc->hpos = sc->hmax;
		if (sc->vpos<0)
			sc->vpos = 0;
		else if (sc->vpos>sc->vmax)
			sc->vpos = sc->vmax;
	}

	dist_h = sc->px_hpos;
	dist_v = sc->px_vpos;
	sc->px_hpos = sc->hpos*sc->px_hline;
	sc->px_vpos = sc->vpos*sc->px_vline;

	if ((dist_h-=sc->px_hpos)!=0 && !_scroll)
		_window_scroll_pos(win,HOR_SLIDER);

	if ((dist_v-=sc->px_vpos)!=0 && !_scroll)
		_window_scroll_pos(win,VERT_SLIDER);

	if ((dist_h==0 && dist_v==0) || win->iconified || sc->scroll==NO_SCROLL)
		return;

	if (rect)
		area = *rect;
	else if (!window_work(win,&area))
		return;

	if (win->redraw==NULL || !output)
		redraw_window(win,&area);
	else
	{
		dist_h = -dist_h;
		dist_v = -dist_v;

		if (info)
			depth = (sc->obj==ROOT) ? MAX_DEPTH : 0;

		if (_scroll)
			off = TRUE;
		else
			beg_update(FALSE,off=FALSE);

		if ((all=(_scroll_all || (win->handle==top && _untop)))!=0)
			work = win->work;

		if (all || window_first(win,&work))
		{
			do
			{
				if (rc_intersect(&area,&work))
				{
					if (!off)
					{
						MouseOff();
						off++;
					}
					switch (rc_sc_scroll(&work,(int) dist_h,(int) dist_v,&work2))
					{
					case 2:
						rc_grect_to_array(&work2,pxy);
						if (win->vdi_handle!=x_handle)
						{
							if (win->vdi_handle>0)
								vs_clip(win->vdi_handle,1,pxy);
						}
						else
							restore_clipping(pxy);
						if (info)
							objc_draw(info->di_tree,sc->obj,depth,work2.g_x,work2.g_y,work2.g_w,work2.g_h);
						else
							win->redraw(first,win,&work2);
					case 1:
						if (_scroll_all!=FAIL)
						{
							rc_grect_to_array(&work,pxy);
							if (win->vdi_handle!=x_handle)
							{
								if (win->vdi_handle>0)
									vs_clip(win->vdi_handle,1,pxy);
							}
							else
								restore_clipping(pxy);
							if (_scroll_all)
								_scroll_all = FAIL;
						}
	
						if (info)
							objc_draw(info->di_tree,sc->obj,depth,work.g_x,work.g_y,work.g_w,work.g_h);
						else
							win->redraw(first,win,&work);
					}
				}
				first = RC_SCROLL;
			} while (!all && window_next(win,&work));
		}
		if (!_scroll)
			end_update(off);
	}
}

#endif
