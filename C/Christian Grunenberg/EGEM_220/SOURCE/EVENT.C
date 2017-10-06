
#include "proto.h"
#include <string.h>
#include <time.h>

#undef ev_mtlocount
#undef ev_mthicount

#define MOUSE_OBJ	0x100
#define MTOS_TIMER	50

typedef struct
{
	long	type;
	long	what;
} APPLRECORD;

typedef struct
{
	unsigned int ev_mtlocount,ev_mthicount;
} E_TIMER;

typedef struct
{
	int ev_mmflags,ev_mmx,ev_mmy,ev_mmwidth,ev_mmheight;
} E_MOUSE;

typedef struct
{
	int ev_mbclicks,ev_mbmask,ev_mbstate;
} E_BUTTON;

typedef struct timeout_entry
{
	struct timeout_entry *next;
	long id,last,count,para;
	long (*fkt)(long,long,MKSTATE *);
} TIMEOUT;

static E_BUTTON click = {258,3,0}, no_click = {1,3,0};
static E_MOUSE mu_mx;
static MESSAG msg_buf[MAX_WINDOWS*5];
static XMSG mbuffered = {MAX_WINDOWS*4,0,0,&msg_buf[0]};
static XMSG mnobuf = {MAX_WINDOWS,0,0,&msg_buf[MAX_WINDOWS*4]};
static APPLRECORD record[] = {{1l,0x10000l}, {0l,5l}, {1l,0x100001l}};
static TIMEOUT *timeout_list=NULL;

int _no_output,_mouse_off;
static int update,ctrl,no_mouse,last_mouse,handler_events,egem_events,key;
static int (*event_init)(XEVENT *,int),(*event_handler)(XEVENT *);

int MouseForm(int form,MFORM *user)
{
	if ((form&=0x7fff)<256)
	{
		last_mouse = form;
		if (!_app_mouse && form!=ARROW && aes_version>=0x0400)
			form |= 0x8000;
	}
	return (graf_mouse(form,user));
}

void MouseOn(void)
{
	if (--_mouse_off==0)
		MouseForm(M_ON,NULL);
}

void MouseOff(void)
{
	if (_mouse_off++==0)
		MouseForm(M_OFF,NULL);
}

int beg_update(int test,int off)
{
	if (update==0)
	{
		if (test && _up_test)
		{
			if (wind_update(BEG_UPDATE|0x0100)==0)
				return (FALSE);
		}
		else
			wind_update(BEG_UPDATE);
	}

	if (off)
		MouseOff();
	update++;
	return (TRUE);
}

void end_update(int on)
{
	if (on)
		MouseOn();
	if (--update==0)
		wind_update(END_UPDATE);
}

void MouseUpdate(int flag)
{
	if (flag)
		no_mouse++;
	else if (--no_mouse==0)
		_inform(MOUSE_INIT);
}

int beg_ctrl(int test,int out,int ms)
{
	if (ctrl==0)
	{
		if (!beg_update(test,FALSE))
			return (FALSE);
		wind_update(BEG_MCTRL);
		if (_top_timer)
		{
			KillTimer(_top_timer);
			_top_timer = 0;
		}
	}

	ctrl++;
	if (out)
		_no_output++;
	if (ms)
		no_mouse++;

	return (TRUE);
}

void end_ctrl(int out,int ms)
{
	if (out)
		_no_output--;
	if (ms)
		no_mouse--;

	if (--ctrl==0)
	{
		if (!_untop && _opened>0 && _top_timer==0)
			_top_timer = NewTimer(TOP_TIMER,0,_Topper);
		wind_update(END_MCTRL);
		end_update(FALSE);
	}

	_inform(MOUSE_INIT);
}

int mouse(int *x,int *y)
{
	int lx,ly,lb,d;

	if (_back_win && !bevent)
		vq_mouse(x_handle,&lb,&lx,&ly);
	else
		graf_mkstate(&lx,&ly,&lb,&d);

	if (x) *x = lx;
	if (y) *y = ly;

	return (lb&3);
}

void NoClick()
{
	XEVENT event;

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags = MU_BUTTON1;
	event.ev_mb1mask = 3;
	event.ev_mb1clicks = 1;

	beg_ctrl(FALSE,FALSE,TRUE);
	Event_Multi(&event);
	end_ctrl(FALSE,TRUE);
}

static int EgemHandlerInit(XEVENT *event,int available)
{
#ifndef SMALL_NO_FSEL
	return (FSelDialog ? (available&(MU_MESAG|MU_KEYBD)) : 0);
#else
	return (0);
#endif
}

static int EgemHandlerEvent(XEVENT *event)
{
#ifndef SMALL_NO_FSEL
	if ((event->ev_mwich & (MU_MESAG|MU_KEYBD)) && FSelDialog)
		return (_FselEvent(event->ev_mwich,event->ev_mmgpbuf,event));
#endif
	return (0);
}

int _call_event_handler(int msg,XEVENT *event,int sendkey)
{
	reg int used = 0,old = event->ev_mwich;

	if ((event->ev_mwich=(msg & egem_events))!=0)
		msg &= ~(used=EgemHandlerEvent(event));
	if (event_handler && (event->ev_mwich=(msg & handler_events))!=0)
		used |= event_handler(event);
	event->ev_mwich = old;

#ifndef SMALL_NO_XACC_AV
	if ((msg & MU_KEYBD) && (used & MU_KEYBD)==0 && sendkey && output)
	{
		reg XAcc *xacc;
		reg int mbuf[8];

		mbuf[3] = event->ev_mmokstate;
		mbuf[4] = event->ev_mkreturn;

		if (AvServer>=0)
		{
			AvSendMsg(AvServer,AV_SENDKEY,mbuf);
			used |= MU_KEYBD;
		}
		else if (!multi && !_app && (xacc=find_id(0))!=NULL)
		{
			if (xacc->flag & AV)
				AvSendMsg(0,AV_SENDKEY,mbuf);
			else
				XAccSendKey(0,event->ev_mkreturn,event->ev_mmokstate);
			used |= MU_KEYBD;
		}
	}
#endif

	return (used);
}

void Event_Handler(int (*init)(XEVENT *,int),int (*handler)(XEVENT *))
{
	if (init && handler)
	{
		event_init = init;
		event_handler = handler;
	}
	else
	{
		event_init = NULL;
		event_handler = NULL;
	}
}

void Event_Timer(int locount,int hicount,int no_key)
{
	XEVENT event;

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags = MU_TIMER|MU_MESAG|MU_GET_MESSAG;
	event.ev_mt1locount = locount;
	event.ev_mt1hicount = hicount;

	if (no_key)
		key++;
	while (Event_Multi(&event) & MU_MESAG);
	if (no_key)
		key--;
}

#ifndef SMALL_NO_MENU
static int menu_item(int cnt,MITEM *list,int *msg)
{
	WIN *win=NULL;

	if (list==NULL && (win=get_top_window())!=NULL)
	{
		list = win->items;
		cnt = win->items_cnt;
	}

	if (list)
		for (;--cnt>=0;list++)
			if (list->menu==msg[4])
			{
				menu_select(msg[3],0);
				WindowHandler(list->mode,win,NULL);
				return (TRUE);
			}

	return (FALSE);
}
#endif

static void set_mouse(WIN *win,int in)
{
	if (win->inside!=in)
	{
		switch (win->inside=in)
		{
		case MOUSE_IN:
			MouseForm(win->mouse_in,win->mouse_inform);break;
		case MOUSE_WORK:
			MouseForm(win->mouse_work,win->mouse_workform);break;
	#ifndef SMALL_NO_ICONIFY
		case MOUSE_IN_ICON:
			MouseForm(win->mouse_icon,win->mouse_iconform);break;
	#endif
		case MOUSE_OUT:
			MouseForm(win->mouse_out,win->mouse_outform);break;
	#ifndef SMALL_NO_EDIT
		case MOUSE_EDIT:
			MouseCursor();
	#endif
		}
	}
}

#ifndef SMALL_NO_HZ

int _no_edit;
static long timer_id;
DIAINFO *_last_cursor;

static DIAINFO *GetCursor(void)
{
	DIAINFO *info;

	if (_no_output || _no_edit)
		info = NULL;
	else if (_dia_len>0)
		info = _dia_list[_dia_len-1];
	else if (_opened>0)
	{
		if ((info=(DIAINFO *) _window_list[0]->dialog)!=NULL && info->di_ed_cnt<=0)
			info = NULL;
	}
	else
		info = NULL;
	return (info);
}

static long Cursor(long para,long time,MKSTATE *mk)
{
	DIAINFO *info = GetCursor();

	if (info!=_last_cursor && _last_cursor && !_last_cursor->di_cursor && output)
		ob_set_cursor(_last_cursor,FAIL,FAIL,FAIL);

	if ((_last_cursor=info)!=NULL)
	{
		if (info->di_cursor)
			_cursor_off(info);
		else
			ob_set_cursor(info,FAIL,FAIL,FAIL);
		return (CONT_TIMER);
	}
	else
	{
		timer_id = 0;
		return (STOP_TIMER);
	}
}

static void CursorInit(int new)
{
	DIAINFO *info = GetCursor();

	if (info!=_last_cursor && _last_cursor && !_last_cursor->di_cursor && output)
		ob_set_cursor(_last_cursor,FAIL,FAIL,FAIL);

	if ((new || info==NULL) && timer_id)
	{
		KillTimer(timer_id);
		_last_cursor = NULL;
		timer_id = 0;
	}

	if ((_last_cursor=info)!=NULL)
	{
		if (!info->di_cursor && info!=_last_cursor)
			ob_set_cursor(info,FAIL,FAIL,FAIL);
		if (_crs_hz>0 && timer_id==0)
			timer_id = NewTimer(1000/_crs_hz,0,Cursor);
	}
}

#endif

static int dia_mouse(DIAINFO *info,WIN *win,int obj,int x,int y,int in,int *mouse,GRECT *rc)
{
	int mou = DIALOG_OBJECT;

	win->mrect = *rc;
	if (info && info->di_mouse)
	{
		if (win->inside==MOUSE_FAIL || info->di_last_obj!=obj || (info->di_last_mode==DIALOG_MOVEMENT))
		{
			if ((mou=info->di_mouse(info,info->di_tree,obj,info->di_last_obj,x,y,rc))!=DIALOG_OBJECT)
			{
				in = MOUSE_OBJ;
				if (mou==DIALOG_MOVEMENT)
				{
					win->mflag = 1;
					rc_intersect(rc,&win->mrect);
				}
			}
			info->di_last_obj = obj;
		}
		else if (win->inside==MOUSE_OBJ)
			in = MOUSE_OBJ;
		info->di_last_mode = mou;
	}

	if (mouse==NULL)
		set_mouse(win,in);
	else
		*mouse = mou;

	return (in);
}

static void mouse_form(WIN *window,int x,int y)
{
	DIAINFO *info = (DIAINFO *) window->dialog;
	OBJECT *tree;
#ifndef SMALL_NO_SCROLL
	GRECT area;
#endif
	GRECT rect;
	int in;

#ifndef SMALL_NO_HZ
	CursorInit(FALSE);
#endif

	if (_dia_len>0)
	{
		info = _dia_list[_dia_len-1];
		tree = info->di_tree;

	#ifndef SMALL_NO_EDIT
		if (info->di_ed_cnt<=0 && info->di_mouse==NULL)
	#else
		if (info->di_mouse==NULL)
	#endif
		{
			window->inside = MOUSE_FAIL;
			window->mflag = -1;
			MouseArrow();
			return;
		}
		else
		{
			window->mouse_in = window->mouse_out = ARROW;
			window->work = *(GRECT *) &tree->ob_x;
		}
	}
	else if (info)
		tree = info->di_tree;

	window->mflag = 1;

	if (!window->iconified && rc_inside(x,y,&window->work))
	{
	#ifndef SMALL_NO_SCROLL
		if (window_work(window,&area) && rc_inside(x,y,&area))
		{
			in = MOUSE_IN;
			rect = area;
		}
		else
		{
			in = MOUSE_WORK;
			if (rc_equal(&area,&window->work) || (window->mouse_in==window->mouse_work && window->mouse_inform==window->mouse_workform))
				rect = window->work;
			else
			{
				rect.g_x = x;
				rect.g_y = y;
				rect.g_w = rect.g_h = 1;
			}
		}
	#else
		in = MOUSE_IN;
		rect = window->work;
	#endif

	#ifndef SMALL_NO_EDIT
		if (info && (info->di_ed_cnt>0 || info->di_mouse))
	#else
		if (info && info->di_mouse)
	#endif
		{
			int mouse,obj = objc_find(tree,ROOT,MAX_DEPTH,x,y);
			OBJECT *ob_ptr = &tree[obj];

			in = dia_mouse(info,window,obj,x,y,in,&mouse,&rect);

		#ifndef SMALL_NO_EDIT
			if (mouse==DIALOG_OBJECT && obj>=0 && info->di_ed_cnt>0 && (ob_ptr->ob_flags & EDITABLE) && !(ob_ptr->ob_state & DISABLED))
			{
				EDINFO ed;
				mouse = TRUE;
				_edit_get_info(tree,obj,0,&ed);
				if (rc_inside(x,y,(GRECT *) &ed.edit_x))
				{
					in = MOUSE_EDIT;
					rc_intersect((GRECT *) &ed.edit_x,&window->mrect);
					mouse = FAIL;
				}
			}
			else
		#endif
				mouse = (mouse==DIALOG_MOVEMENT) ? FAIL : FALSE;

			if (!mouse && ob_ptr->ob_head<0)
			{
				ob_pos(tree,obj,&rect);
				rc_intersect(&rect,&window->mrect);
			}
			else if (mouse!=FAIL)
			{
				window->mrect.g_x = x;window->mrect.g_y = y;
				window->mrect.g_w = window->mrect.g_h = 1;
			}
		}
		else
			window->mrect = rect;
		set_mouse(window,in);
	}
#ifndef SMALL_NO_ICONIFY
	else if (win_iconified(window) && rc_inside(x,y,&window->icon_work))
		dia_mouse(info,window,-1,x,y,MOUSE_IN_ICON,NULL,&window->icon_work);
#endif
	else
	{
		window->mflag = (window->iconified & SHADE) ? -1 : 0;
	#ifndef SMALL_NO_ICONIFY
		dia_mouse(info,window,-1,x,y,MOUSE_OUT,NULL,win_iconified(window) ? &window->icon_work : &window->work);
	#else
		dia_mouse(info,window,-1,x,y,MOUSE_OUT,NULL,&window->work);
	#endif
	}
}

static int handle_messag(XEVENT *event,int no_messag,int flags)
{
#if !defined(SMALL_NO_DD) || !defined(SMALL_NO_ICONIFY) || !defined(SMALL_NO_SCROLL)
	reg int state;
#endif
#ifndef SMALL_NO_DD
	DRAG_DROP dd;
	char *args_mem;
#endif
#ifndef SMALL_NO_SCROLL
	reg SCROLL *sc;
	reg long pos,old_h,old_v;
#endif
	reg WIN *window,**wins;
	reg int events = event->ev_mwich;
	reg int *msg = event->ev_mmgpbuf;
#ifndef SMALL_NO_ICONIFY
	reg int icf;
#endif

#ifndef SMALL_NO_XACC_AV
	if (_XAccComm(msg)==FALSE)
	{
#endif
		if (msg[0]==WM_M_BDROPPED)
			msg[0] = WM_BOTTOMED;

		if (_app && (msg[0]==AC_OPEN || msg[0]==AC_CLOSE))
			return (events & (~MU_MESAG));

		if (!output)
			switch (msg[0])
			{
			case AP_TERM:
				if (!_no_output)
					break;
				msg[0] = AP_TFAIL;
				msg[1] = -1;
				msg[2] = 0;
				shel_write(10,0,0,(char *) msg,NULL);
			case AC_OPEN:
				return (events & (~MU_MESAG));
			case AC_CLOSE:
				if (!_no_output)
					break;
			case WM_ICONIFY:
			case WM_UNICONIFY:
			case WM_ALLICONIFY:
			case WM_CLOSED:
			case WM_REDRAW:
			case WM_MOVED:
			case WM_FULLED:
			case WM_SIZED:
			case WM_ONTOP:
			case WM_NEWTOP:
			case WM_TOPPED:
			case WM_UNTOPPED:
			case WM_BOTTOMED:
			case WM_HSLID:
			case WM_VSLID:
			case WM_ARROWED:
				_send_puf(TRUE,msg[0],msg);
				return (events & (~MU_MESAG));
			}

		window = get_window(msg[3]);

	#if !defined(SMALL_NO_SCROLL) || !defined(SMALL_NO_ICONIFY)
		if (window)
		{
		#ifndef SMALL_NO_SCROLL
			sc = window->scroll;
		#endif
		#ifndef SMALL_NO_ICONIFY
			icf = window->iconified & (ICONIFIED|ICFS);
		#endif
		}
		else
		{
		#ifndef SMALL_NO_SCROLL
			sc = NULL;
		#endif
		#ifndef SMALL_NO_ICONIFY
			icf = 0;
		#endif
		}
	#endif

		switch (msg[0])
		{
	#ifndef SMALL_NO_SCROLL
		case WM_ARROWED:
		case WM_HSLID:
		case WM_VSLID:
			if (sc)
			{
				old_h = sc->hpos;
				old_v = sc->vpos;

				switch (msg[0])
				{
				case WM_HSLID:
					pos = msg[4];
					pos *= sc->hmax;
					sc->hpos = pos/1000l;
					scroll_window(window,WIN_SCROLL,NULL);
					break;
				case WM_VSLID:
					pos = msg[4];
					pos *= sc->vmax;
					sc->vpos = pos/1000l;
					scroll_window(window,WIN_SCROLL,NULL);
					break;
				default:
					if (winx || window->redraw==NULL || sc->scroll!=FAST_SCROLL)
					{
						for (;;)
						{
							_arrow_window(sc,msg[4],(winx && msg[5]<0) ? -msg[5] : 0);
							if (winx && msg[7]<0)
							{
								msg[4] = msg[6];
								msg[5] = msg[7];
								msg[7] = 0;
							}
							else
								break;
						}
						scroll_window(window,WIN_SCROLL,NULL);
					}
					else
					{
						GRECT work;
						reg int i=0,update;

						if (!window_first(window,&work))
							break;
						else
							_scroll_all = (work.g_w>=window->work.g_w && work.g_h>=window->work.g_h);

						state = (msg[4]<WA_LFPAGE) ? VERT_SLIDER : HOR_SLIDER;

						switch (msg[4])
						{
						case WA_UPLINE:
						case WA_DNLINE:
							update = max((int) (sc->vsize/min(window->work.g_h>>1,500)),4);
							break;
						case WA_LFLINE:
						case WA_RTLINE:
							update = 4;
							break;
						default:
							update = 2;
						}

						_scroll = TRUE;
						beg_ctrl(FALSE,FALSE,FALSE);
						MouseOff();

						do
						{
							scroll_window(window,msg[4],NULL);
							if (++i==update)
							{
								_window_scroll_pos(window,state);
								i = 0;
							}
						} while (mouse(NULL,NULL));

						if (i!=0)
							_window_scroll_pos(window,state);

						MouseOn();
						end_ctrl(FALSE,FALSE);
						_scroll = _scroll_all = FALSE;
					}
				}

				if (old_h!=sc->hpos || old_v!=sc->vpos)
				{
					msg[0] = WIN_SCROLLED;
					msg[3] = window->handle;
					*(WIN **) &msg[4] = window;
				}
				else
					events &= ~MU_MESAG;
			}
			break;
	#endif
		case WIN_CHANGEFNT:
			msg[0] = FONT_CHANGED;
			break;
	#ifndef SMALL_NO_DD
		case AP_DRAGDROP:
			_rec_ddmsg(msg);
			events &= ~MU_MESAG;
			break;
	#ifndef SMALL_NO_XACC_AV
		case VA_START:
		case AV_OPENWIND:
		case AV_XWIND:
			dd.dd_type = msg[0]==VA_START ? AV_START : AV_OPEN;
			dd.dd_win = NULL;
			dd.dd_mx = dd.dd_my = -1;
			dd.dd_args = *(char **) &msg[3];
			goto _drag_msg;
		case VA_DRAGACCWIND:
			dd.dd_type = AV_DRAG;
			dd.dd_win = window;
			*(long *) &dd.dd_mx = *(long *) &msg[4];
			dd.dd_args = *(char **) &msg[6];
			_drag_msg:
			dd.dd_kstate = event->ev_mmokstate;
			dd.dd_originator = msg[1];
			dd.dd_mem = dd.dd_name = args_mem = NULL;
			dd.dd_ext[0] = '\0';
			dd.dd_size = 0l;
			if (dd.dd_args && *dd.dd_args=='\0')
				dd.dd_args = NULL;
			if (dd.dd_args && (args_mem=strdup(dd.dd_args))!=NULL)
				dd.dd_args = args_mem;
			state = _send_msg(&dd,0,OBJC_DRAGGED,0,0);
			if (args_mem)
				free(args_mem);
			switch (msg[0])
			{
			case VA_START:
				AvSendMsg(msg[1],AV_STARTED,msg);break;
			case AV_OPENWIND:
			case AV_XWIND:
				msg[3] = state;
				AvSendMsg(msg[1],msg[0]==AV_OPENWIND ? VA_WINDOPEN : VA_XOPEN,msg);
			}
			events &= ~MU_MESAG;
			break;
	#endif
	#endif
	#ifndef SMALL_NO_MENU
		case MENU_INIT:
			if (_menu)
			{
				reg MITEM *item;
				reg int enable,cnt = _mitems_cnt,top = FALSE,gadgets = 0;

				beg_update(FALSE,FALSE);
				if ((window=get_top_window())!=NULL)
				{
					top = TRUE;
					gadgets = window->gadgets;
				}	

				for (item=_menu_items;--cnt>=0;item++)
					if (item->menu>0)
					{
						switch (item->mode)
						{
						case W_UNICONIFYALL:
						#ifndef SMALL_NO_ICONIFY
							enable = (top && _opened>0 && (_window_list[0]->gadgets&SMALLER));break;
						#else
							enable = 0;break;
						#endif
						case W_ICONIFYALLINONE:
						case W_ICONIFYALL:
						#ifndef SMALL_NO_ICONIFY
							enable = (top && _icfs!=NULL && _opened>0 && (_window_list[0]->gadgets&SMALLER));break;
						#else
							enable = 0;break;
						#endif
						case W_CLOSEALL:
							enable = (top && _opened>0 && (_window_list[0]->gadgets&CLOSER));break;
						case W_FULL:
							enable = gadgets&FULLER;break;
						case W_UNICONIFY:
						case W_ICONIFY:
						#ifndef SMALL_NO_ICONIFY
							enable = gadgets&SMALLER;break;
						#else
							enable = 0;break;
						#endif
						case W_CLOSE:
							enable = gadgets&CLOSER;break;
						case W_CYCLE:
						case W_INVCYCLE:
							enable = (top && _opened>1);break;
						case W_GLOBALCYCLE:
							enable = (owner || AvServer>=0);break;
						case W_BOTTOM:
							enable = ((bottom && (owner || top)) || (top && _opened>1));break;
						default:
							continue;
						}
						menu_item_enable(item->menu,enable);
					}
				end_update(FALSE);
			}
			break;
	#endif
		case MOUSE_INIT:
			{
				int top;
				for (wins=_window_list;(window=*wins++)!=NULL;window->inside=MOUSE_FAIL);
				window = _dia_len>0 ? _dia_list[_dia_len-1]->di_win : get_window(top=GetTop());
				if (window)
				{
					window->inside = MOUSE_FAIL;
					mouse_form(window,event->ev_mmox,event->ev_mmoy);
				}
				else if (_app_mouse || top<=0 || last_mouse!=ARROW)
					MouseArrow();
			}
			events &= ~MU_MESAG;
			break;
	#ifndef SMALL_NO_HZ
		case CURSOR_INIT:
			CursorInit(TRUE);
			events &= ~MU_MESAG;
			break;
	#endif
		case WIN_TOPPED:
			msg[0] = WM_TOPPED; break;
		case WIN_CLOSED:
			msg[0] = WM_CLOSED; break;
	#ifndef SMALL_NO_MENU
		case MN_SELECTED:
			if (menu_item(_mitems_cnt,_menu_items,msg) || menu_item(0,NULL,msg))
				events &= ~MU_MESAG;
			else
			{
				*(OBJECT **) &msg[5] = _menu;
				msg[7] = -1;
			}
			break;
	#endif
		case WIN_INFO:
		case WIN_NAME:
			if (window)
			{
				char *set = *(char **) &msg[4];
				wind_set(msg[3],(msg[0]==WIN_INFO) ? WF_INFO : WF_NAME,set);
				events &= ~MU_MESAG;
			}
			break;
		case WIN_HSLSIZE:
		case WIN_VSLSIZE:
		case WIN_HSLIDE:
		case WIN_VSLIDE:
			if (window)
			{
				switch (msg[0])
				{
				case WIN_HSLSIZE:
					msg[0] = WF_HSLSIZE;break;
				case WIN_VSLSIZE:
					msg[0] = WF_VSLSIZE;break;
				case WIN_HSLIDE:
					msg[0] = WF_HSLIDE;break;
				default:
					msg[0] = WF_VSLIDE;
				}

				wind_set(msg[3],msg[0],msg[4]);
				events &= ~MU_MESAG;
			}
			break;
		case WM_SHADED:
			if (window)
			{
				window->iconified |= SHADE;
				goto _win_changed;
			}
			break;
		case WM_UNSHADED:
			if (window)
			{
				window->iconified &= ~SHADE;
				_win_changed:
				msg[0] = WIN_CHANGED;
				msg[3] = window->handle;
				*(WIN **) &msg[4] = window;
				events &= ~MU_MESAG;
				_inform(MOUSE_INIT);
			}
			break;
		#ifndef SMALL_NO_ICONIFY
		case WM_ICONIFY:
			state = W_ICONIFY;
			goto aes_iconify;
		case WM_UNICONIFY:
			state = W_UNICONIFY;
			goto aes_iconify;
		case WM_ALLICONIFY:
			state = W_ICONIFYALLINONE;
			aes_iconify:
			if (window)
			{
				if (window->gadgets & SMALLER)
					WindowHandler(state,window,(GRECT *) &msg[4]);
				events &= ~MU_MESAG;
			}
			break;
		case WM_MOVED:
			if (icf)
			{
				GRECT work = window->icon_work;
				wind_set(window->handle,WF_CURRXYWH,msg[4],msg[5],msg[6],msg[7]);
				wind_xget(window->handle,WF_WORKXYWH,&window->icon_work.g_x,&window->icon_work.g_y,&window->icon_work.g_w,&window->icon_work.g_h);
				if (!rc_equal(&work,&window->icon_work))
				{
					if (window->dialog)
						_send_msg(window->dialog,0,OBJC_SIZED,0,0);
					else
						_send_msg(window,window->handle,WIN_SIZED,0,0);
				}
				events &= ~MU_MESAG;
			}
			break;
		case WM_REDRAW:
			if (window && (window->redraw || (icf && window->icon!=NIL)))
		#else
		case WM_REDRAW:
			if (window && window->redraw)
		#endif
			{
				redraw_window(window,(GRECT *) &msg[4]);
				events &= ~MU_MESAG;
			}
			break;
		case WM_CLOSED:
			if (window)
			{
			#ifndef SMALL_NO_ICONIFY
				if ((state=event->ev_mmokstate)!=0)
				{
					if (_icfs && (window->gadgets & SMALLER))
					{
						if (state & (K_CTRL|K_ALT))
						{
							if ((state & K_CTRL) || (state & K_SHIFT))
								state = W_ICONIFYALLINONE;
							else
								state = W_ICONIFY;
						}
						else
							state = W_ICONIFYALL;
						WindowHandler(state,window,NULL);
					}
					events &= ~MU_MESAG;
				}
			#else
				if (event->ev_mmokstate)
					events &= ~MU_MESAG;
			#endif
			}
			break;
		case WM_ONTOP:
		case WM_NEWTOP:
		case WM_UNTOPPED:
			_new_top(-1,FALSE);break;
		case WM_TOPPED:
			if (!bevent && _back_win && window && !window->iconified && (flags & (MU_BUTTON1|MU_BUTTON2)) && rc_inside(event->ev_mmox,event->ev_mmoy,&window->work))
			{
				events &= ~(MU_MESAG|MU_BUTTON1|MU_BUTTON2);
				event->ev_mmobutton = event->ev_mb1return = event->ev_mb2return = 1;

				if (event->ev_mb1clicks>=256 || (event->ev_mb1state & 1))
					events |= MU_BUTTON1;

				if (event->ev_mb2clicks>=256 || (event->ev_mb2state & 1))
					events |= MU_BUTTON2;

				if (mouse(NULL,NULL) & 1)
					appl_tplay(record,3,100);
			}
			break;
	#ifndef SMALL_NO_XACC_AV
		case AV_SENDKEY:
			events &= ~MU_MESAG;
			if (flags & MU_KEYBD)
			{
				events |= MU_KEYBD;
				event->ev_mkreturn = msg[4];
				event->ev_mmokstate = msg[3] & (K_CTRL|K_ALT|K_SHIFT);
			}
			break;
		case ACC_KEY:
			events &= ~MU_MESAG;
			if (flags & MU_KEYBD)
			{
				events |= MU_KEYBD;
				event->ev_mkreturn = msg[3];
				event->ev_mmokstate = msg[4] & (K_CTRL|K_ALT|K_SHIFT);
				XAccSendAck(msg[1],1);
			}
			else
				XAccSendAck(msg[1],0);
			break;
		case ACC_META:
			if (_xacc_msgs & X_MSG_META)
				break;
		case ACC_IMG:
			if (_xacc_msgs & X_MSG_IMG)
				break;
			XAccSendAck(msg[1],0);
			events &= ~MU_MESAG;
	#endif
		}

		if ((events & MU_MESAG) && no_messag==0)
		{
			event->ev_mwich = events;
			_messag_handler(FALSE,event,NULL,NULL);
			return (event->ev_mwich);
		}
		else
			return (events);
#ifndef SMALL_NO_XACC_AV
	}
	else
		return (events & (~MU_MESAG));
#endif
}

void _inform(int msg)
{
	_send_puf(FALSE,msg,NULL);
}

void _inform_buffered(int msg)
{
	_send_puf(TRUE,msg,NULL);
}

void _send_puf(int buffered,int msg_id,int *msg)
{
	reg XMSG *buf = buffered ? &mbuffered : &mnobuf;
	reg int tail = buf->msg_tail,head = buf->msg_head,*mbuf = (int *) &buf->msg[tail];

	while (tail!=head)
	{
		if (*mbuf==msg_id && (msg_id==WIN_NEWTOP || msg==NULL || mbuf[3]==msg[3]))
		{
			if (msg_id==WM_REDRAW)
			{
				mbuf[6] = max(mbuf[4]+mbuf[6],msg[4]+msg[6]);
				mbuf[7] = max(mbuf[5]+mbuf[7],msg[5]+msg[7]);
				Min(&mbuf[4],msg[4]);
				Min(&mbuf[5],msg[5]);
				mbuf[6] -= mbuf[4];
				mbuf[7] -= mbuf[5];
			}
			else if (msg_id==WIN_NEWTOP)
				mbuf[3] = msg[3];
			else if (msg)
				memcpy(&mbuf[4],&msg[4],8);
			return;
		}
		else if (++tail==buf->msg_max)
			mbuf = (int *) &buf->msg[tail=0];
		else
			mbuf += 8;
	}

	*mbuf++ = msg_id;
	*mbuf++ = ap_id;
	*mbuf++ = 0;

	if (msg)
	{
		msg += 3;
		*mbuf++ = *msg++;
		*((long *) mbuf)++ = *((long *) msg)++;
		*((long *) mbuf)++ = *((long *) msg)++;
	}

	if (++buf->msg_head==buf->msg_max)
		buf->msg_head = 0;
}

static int get_puf(XMSG *buf,XEVENT *event)
{
	reg int tail = buf->msg_tail;

	if (tail!=buf->msg_head)
	{
		*(MESSAG *) event->ev_mmgpbuf = buf->msg[tail++];
		buf->msg_tail = tail==buf->msg_max ? 0 : tail;
		return (TRUE);
	}
	return (FALSE);
}

long NewTimer(long count,long para,long (*fkt)(long,long,MKSTATE *))
{
	static long id=1;
	reg TIMEOUT **to,*t,*next;
	reg long timer,last;
 
	last = clock()*5;
	timer = last+count;
	for (to=&timeout_list;(next=*to)!=NULL;to=&next->next)
		if (timer<(next->last+next->count))
			break;

	if ((t=malloc(sizeof(TIMEOUT)))==NULL)
		return (0);

	*to = t;
    t->next = next;
    t->last = last;
    t->count = count;
    t->fkt = fkt;
    t->para = para;
    t->id = id++;

	if (id==0)
		id++;

    return (t->id);
}

int KillTimer(long id)
{
	reg TIMEOUT **to,*t;

	for (to=&timeout_list;(t=*to)!=NULL;to=&t->next)
		if (id==t->id)
		{
			t = t->next;
			free(*to);
			*to = t;
			return (TRUE);
		}

	return (FALSE);
}

static void GetTimer(long *last,long count,long *timer,int *next_timer,long time,int flag)
{
	reg long val;

	if ((val=*last)<=0)
		*last = time;
	else
		count += val - time;

	val = *timer;
	if (count<=0)
	{
		if (val<=0)
			*next_timer |= flag;
		else
		{
			*next_timer = flag;
			*timer = count;
		}
	}
	else if (count<=val)
	{
		if (count<val)
		{
			*next_timer = flag;
			*timer = count;
		}
		else
			*next_timer |= flag;
	}
}

static int GetMouse(int flags,XEVENT *event,E_MOUSE *mu_m1)
{
	reg int events = 0,x = event->ev_mmox,y = event->ev_mmoy;

	if ((flags & MU_M1) && rc_inside(x,y,(GRECT *) &mu_m1->ev_mmx)!=mu_m1->ev_mmflags)
		events |= MU_M1;

	if ((flags & MU_M3) && rc_inside(x,y,(GRECT *) &event->ev_mm3x)!=event->ev_mm3flags)
		events |= MU_M3;

	if ((flags & MU_M4) && rc_inside(x,y,(GRECT *) &event->ev_mm4x)!=event->ev_mm4flags)
		events |= MU_M4;

	if ((flags & MU_MX) && rc_inside(x,y,(GRECT *) &mu_mx.ev_mmx)!=mu_mx.ev_mmflags)
		events |= MU_MX;

	return (events);
}

static int Wait_for_Event(XEVENT *event)
{
	E_MOUSE mu_m1;
	E_BUTTON mu_button1;
	E_TIMER mu_timer1;

	reg TIMEOUT *timeout;
	reg int in,events = 0,flags = event->ev_mflags,t_flags = (flags & (MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4));
	int button = 0,msg = 0,next_timer;
	long time,timer;

	event->ev_mflags &= MU_MESAG|MU_BUTTON|MU_KEYBD|MU_M1|MU_M2|MU_TIMER;

	if (flags & (MU_M3|MU_M4|MU_MX))
	{
		mu_m1 = *(E_MOUSE *) &event->ev_mm1flags;
		*(long *) &event->ev_mm1x = *(long *) &event->ev_mmox;
		event->ev_mm1flags = event->ev_mm1width = event->ev_mm1height = 1;
		event->ev_mflags |= MU_M1;
		if (GetMouse(flags,event,&mu_m1))
			event->ev_mm1x = event->ev_mm1y = -1;
	}

	if (flags & MU_BUTTON2)
	{
		mu_button1 = *(E_BUTTON *) &event->ev_mb1clicks;

		if (event->ev_mflags & MU_BUTTON1)
		{
			if (event->ev_mb1clicks<256 && event->ev_mb1state==0)
			{
				if (event->ev_mb2clicks<256 && event->ev_mb2state==0)
					*(E_BUTTON *) &event->ev_mb1clicks = no_click;
				else
				{
					*(E_BUTTON *) &event->ev_mb1clicks = click;
					button = -1;
				}
			}
			else
			{
				if (event->ev_mb2clicks<256 && event->ev_mb2state==0)
					button = -1;
				*(E_BUTTON *) &event->ev_mb1clicks = click;
			}
		}
		else
		{
			*(E_BUTTON *) &event->ev_mb1clicks = *(E_BUTTON *) &event->ev_mb2clicks;
			event->ev_mflags |= MU_BUTTON1;
			button = 1;
		}
	}

	if (mtos)
	{
		if (flags & MU_KEYBD)
			msg = TRUE;
		else if ((flags & MU_MESAG) && _opened>0 && !ctrl)
			msg =TRUE;
	}

	mu_timer1 = *(E_TIMER *) &event->ev_mt1locount;

	do
	{
		event->ev_mt1hicount = next_timer = 0;

		if ((timeout=timeout_list)!=NULL || t_flags)
		{
			event->ev_mflags |= MU_TIMER;	

			time = clock()*5;
			timer = 1l<<30;

			if (t_flags & MU_TIMER1)
				GetTimer(&event->ev_mt1last,(((long) event->ev_mt1hicount)<<16)|event->ev_mt1locount,&timer,&next_timer,time,MU_TIMER1);

			if (t_flags & MU_TIMER2)
				GetTimer(&event->ev_mt2last,event->ev_mt2count,&timer,&next_timer,time,MU_TIMER2);

			if (t_flags & MU_TIMER3)
				GetTimer(&event->ev_mt3last,event->ev_mt3count,&timer,&next_timer,time,MU_TIMER3);

			if (t_flags & MU_TIMER4)
				GetTimer(&event->ev_mt4last,event->ev_mt4count,&timer,&next_timer,time,MU_TIMER4);

			if (timeout)
				GetTimer(&timeout->last,timeout->count,&timer,&next_timer,time,MU_XTIMER);

			if (timer<=(long) _min_timer)
			{
				event->ev_mt1locount = _min_timer;
				events = MU_TIMER;
			}
			else if (button<0)
			{
				event->ev_mt1locount = _min_timer;
				events = MU_TIMER;
				next_timer = 0;
			}
			else if (msg && timer>MTOS_TIMER)
			{
				event->ev_mt1locount = MTOS_TIMER;
				next_timer = 0;
			}
			else
			{
				event->ev_mt1locount = (int) timer;
				event->ev_mt1hicount = (int) (timer>>16);
			}

			if (timer>0)
				time += timer;
		}
		else if (button<0)
		{
			event->ev_mt1locount = _min_timer;
			event->ev_mflags |= MU_TIMER;
			events = MU_TIMER;
		}
		else if (msg)
		{
			event->ev_mt1locount = MTOS_TIMER;
			event->ev_mflags |= MU_TIMER;
		}
		else
			event->ev_mflags &= ~MU_TIMER;

		if ((flags & MU_MESAG) && (_no_output|no_mouse)==0 && (get_puf(&mnobuf,event) || (!ctrl && get_puf(&mbuffered,event))))
		{
			events |= MU_MESAG;
			graf_mkstate(&event->ev_mmox,&event->ev_mmoy,&event->ev_mmobutton,&event->ev_mmokstate);
		}
		else if (events & MU_TIMER)
		{
			events |= EvntMulti((EVENT *) event);
			if (_min_timer==0 && !(events & MU_BUTTON))
				graf_mkstate(&event->ev_mmox,&event->ev_mmoy,&event->ev_mmobutton,&event->ev_mmokstate);
		}
		else
			events |= EvntMulti((EVENT *) event);

		event->ev_mmobutton &= 3;
		if (!bevent && _back_win && event->ev_mmobutton==0)
		{
			event->ev_mmobutton = mouse(NULL,NULL);
			if (events & MU_BUTTON)
			{
				in = event->ev_mmobutton & event->ev_mb1mask;
				if (event->ev_mb1clicks<256)
				{
					if (in!=event->ev_mb1state)
						events &= ~MU_BUTTON;
				}
				else if (in==0)
					events &= ~MU_BUTTON;
			}
		}

		event->ev_mmokstate &= (K_SHIFT|K_CTRL|K_ALT); 

		if (flags & MU_BUTTON2)
		{
			event->ev_mb2return = event->ev_mb1return;

			if (button>0)
			{
				if (events & MU_BUTTON1)
				{
					events &= ~MU_BUTTON1;
					events |= MU_BUTTON2;
				}
			}
			else if (button<0 || (events & MU_BUTTON1))
			{
				events &= ~MU_BUTTON1;

				in = event->ev_mmobutton & event->ev_mb2mask;
				if (event->ev_mb2clicks<256)
				{
					if (in==event->ev_mb2state)
					{
						events |= MU_BUTTON2;
						if (in==0 && button<0)
							event->ev_mb2return = 1;
					}
				}
				else if (in)
					events |= MU_BUTTON2;

				in = event->ev_mmobutton & mu_button1.ev_mbmask;
				if (mu_button1.ev_mbclicks<256)
				{
					if (in==mu_button1.ev_mbstate)
					{
						events |= MU_BUTTON1;
						if (in==0 && button<0)
							event->ev_mb1return = 1;
					}
				}
				else if (in)
					events |= MU_BUTTON1;
			}
		}

		if ((flags & (MU_M3|MU_M4|MU_MX)) && (events & MU_M1))
		{
			events &= ~MU_M1;
			events |= GetMouse(flags,event,&mu_m1);
			*(long *) &event->ev_mm1x = *(long *) &event->ev_mmox;
		}

		if (events & MU_TIMER)
		{
			events &= ~MU_TIMER;
			if (next_timer)
			{
				events |= next_timer;

				if (next_timer & MU_TIMER1)
					event->ev_mt1last = time;

				if (next_timer & MU_TIMER2)
					event->ev_mt2last = time;

				if (next_timer & MU_TIMER3)
					event->ev_mt3last = time;

				if (next_timer & MU_TIMER4)
					event->ev_mt4last = time;

				if (next_timer & MU_XTIMER)
				{
					if ((events & MU_MESAG)==0 || event->ev_mmgpbuf[0]!=AC_CLOSE)
					{
						long mode;
						reg TIMEOUT **to,*next=timeout->next;

						timeout->last = time;
						timeout_list = next;

						if ((mode=timeout->fkt(timeout->para,time,(MKSTATE *) &event->ev_mmox))>=CONT_TIMER)
						{
							if (mode>=0)
								timeout->count = mode;
							timer = time+timeout->count;
							for (to=&timeout_list;(next=*to)!=NULL;to=&next->next)
								if (timer<(next->last+next->count))
									break;
							*to = timeout;
						    timeout->next = next;
						}
						else
							free(timeout);
					}
					events &= ~MU_XTIMER;
				}
			}
		}
	} while (events==0);

	*(E_TIMER *) &event->ev_mt1locount = mu_timer1;

	if (flags & (MU_M3|MU_M4|MU_MX))
		*(E_MOUSE *) &event->ev_mm1flags = mu_m1;

	if (flags & MU_BUTTON2)
		*(E_BUTTON *) &event->ev_mb1clicks = mu_button1;

	event->ev_mwich = events;
	event->ev_mflags = flags;

	return (events);
}

void ClrKeybd(void)
{
	EVENT wait;

	wait.ev_mflags = MU_TIMER|MU_KEYBD;
	wait.ev_mtlocount = _min_timer;
	wait.ev_mthicount = 0;

	while (EvntMulti(&wait)!=MU_TIMER);
}

static int key_item(int cnt,MITEM *item,XEVENT *event)
{
	WIN *win = NULL;

	if (item==NULL && (win=get_top_window())!=NULL)
	{
		item = win->items;
		cnt = win->items_cnt;
	}

	if (item)
	{
		reg int scan = event->ev_mkreturn,state = event->ev_mmokstate,ascii = scan_2_ascii(scan,state),shift = state & K_SHIFT;

		for (scan>>=8;--cnt>=0;item++)
			if (((state^item->state) & (K_ALT|K_CTRL))==0 && ((scan && (item->scan>>8)==scan) || (ascii && (char) item->scan==ascii)))
				if ((item->state & K_SHIFT) ? shift : !shift)
				{
					if (item->mode<100)
						ClrKeybd();
					WindowHandler(item->mode,win,NULL);
					return (TRUE);
				}
	}
	return (FALSE);
}

int Event_Multi(reg XEVENT *event)
{
#ifndef SMALL_NO_ICONIFY
	reg WIN *window;
	E_BUTTON mu_button1;
	int button;
#endif

	XEVENT local_event;
	E_MOUSE mu_save;
	reg E_MOUSE *mu_restore;
	reg WIN *ms_win;
	reg int events,form_do,wait_events,flags;
	int mesag,available,old_flags,mouse,waited;

	if (event==NULL)
	{
		event = &local_event;
		memset(event,0,sizeof(XEVENT));
		old_flags = form_do = wait_events = 0;
	}
	else
	{
		old_flags = event->ev_mflags;
		form_do = (old_flags & MU_NO_HANDLER);
		wait_events = (old_flags & (MU_MESAG|MU_KEYBD|MU_BUTTON1|MU_BUTTON2|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4));
	}

	waited = ~(wait_events & (MU_BUTTON1|MU_BUTTON2|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4));

	do
	{
		available = waited;
		if (_no_output|no_mouse)
			available &= MU_MESAG|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4;
		else
			available &= MU_MESAG|MU_KEYBD|MU_BUTTON1|MU_BUTTON2|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4;
		if (key)
			available &= ~MU_KEYBD;
		flags = wait_events|(egem_events=EgemHandlerInit(event,available));
		flags |= (handler_events = event_init ? (event_init(event,available) & available) : 0);

	#ifndef SMALL_NO_ICONIFY
		button = FAIL;
	#endif
		mouse = 0;

		if ((_no_output|no_mouse)==0)
		{
			if (!ctrl && _opened>0)
			{
				ms_win = _window_list[0];
			#ifndef SMALL_NO_ICONIFY
				if (_iconified && _mouse_off==0)
				{
					button = FALSE;
					if (!(flags & (MU_BUTTON1|MU_BUTTON2)) && (available & MU_BUTTON1))
					{
						flags |= MU_BUTTON1;
						mu_button1 = *(E_BUTTON *) &event->ev_mb1clicks;
						*(E_BUTTON *) &event->ev_mb1clicks = click;
						button = TRUE;
					}
				}
			#endif
				flags |= (available & MU_KEYBD);
			}
			else if (_dia_len>0)
				ms_win = _dia_list[_dia_len-1]->di_win;
			else
				ms_win = NULL;

			if (ms_win && !_mouse_off && ms_win->inside!=MOUSE_FAIL && ms_win->mflag>=0)
			{
				available &= ~flags;
				if (available & MU_M1)
				{
					mu_restore = (E_MOUSE *) &event->ev_mm1flags;
					mouse = MU_M1;
				}
				else if (available & MU_M2)
				{
					mu_restore = (E_MOUSE *) &event->ev_mm2flags;
					mouse = MU_M2;
				}
				else
				{
					mu_restore = &mu_mx;
					mouse = MU_MX;
				}

				mu_save = *mu_restore;
				mu_restore->ev_mmflags = ms_win->mflag;
				*(GRECT *) &mu_restore->ev_mmx = ms_win->mrect;
				flags |= mouse;
			}
		}

		event->ev_mflags = flags;
		events = Wait_for_Event(event);
		event->ev_mflags = old_flags;

	#ifdef CTRLSIM
		if (event->ev_mmokstate & K_RSHIFT)
		{
			event->ev_mmokstate |= K_CTRL;
			event->ev_mmokstate &= ~K_RSHIFT;

			switch (event->ev_mkreturn>>8)
			{
			case SCANLEFT:
				event->ev_mkreturn = CTRLLEFT<<8;break;
			case SCANRIGHT:
				event->ev_mkreturn = CTRLRIGHT<<8;
			}
		}
	#endif

		if (events & mouse)
		{
			if ((events & MU_MESAG)==0 || event->ev_mmgpbuf[0]!=AC_CLOSE)
				mouse_form(ms_win,event->ev_mmox,event->ev_mmoy);
			*mu_restore = mu_save;
			events ^= mouse;
		}

	#ifndef SMALL_NO_ICONIFY
		if (button>=FALSE)
		{
			if (button==TRUE)
				*(E_BUTTON *) &event->ev_mb1clicks = mu_button1;
			if ((event->ev_mmobutton & 1) && !(events & MU_MESAG))
				if ((window=window_find(event->ev_mmox,event->ev_mmoy))!=NULL && (window->gadgets & SMALLER) && (window->iconified & ICFS) && rc_inside(event->ev_mmox,event->ev_mmoy,&window->icon_work))
				{
					WindowHandler((event->ev_mmokstate & K_SHIFT) ? W_UNICONIFYALL : W_UNICONIFY,window,NULL);
					NoClick();
					events &= ~(MU_BUTTON1|MU_BUTTON2);
				}
		}
	#endif

		if ((mesag=(events & MU_MESAG))!=0)
		{
			if ((old_flags & MU_GET_MESSAG)==0)
				mesag = 0;
			events = handle_messag(event,form_do,flags);
		}

		if ((events & MU_KEYBD) && !ctrl && (key_item(_mitems_cnt,_menu_items,event) || key_item(0,NULL,event)))
			events &= ~MU_KEYBD;

		if (!form_do)
			events &= ~_call_event_handler(events,event,(wait_events & MU_KEYBD)==0);
	} while ((events=(events&wait_events)|mesag)==0);
	return (event->ev_mwich=events);
}
