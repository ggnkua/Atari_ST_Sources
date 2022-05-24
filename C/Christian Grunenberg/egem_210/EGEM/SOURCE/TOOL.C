
#include "proto.h"
#include <string.h>
#include <time.h>

static int clipping_area[4];
static int handler_events;
static int (*event_init)(XEVENT *,int),(*event_handler)(XEVENT *);

char UpperChar(char ch)
{
	if (ch>='a')
	{
		if (ch>'z')
		{
			if (ch=='„')
				return ('Ž');
			else if (ch=='”')
				return ('™');
			else if (ch=='')
				return ('š');
		}
		else
			return (ch-32);
	}

	return (ch);
}

char LowerChar(char ch)
{
	if (ch>='A')
	{
		if (ch>'Z')
		{
			if (ch=='Ž')
				return ('„');
			else if (ch=='™')
				return ('”');
			else if (ch=='š')
				return ('');
		}
		else
			return (ch+32);
	}

	return (ch);
}

static int mouse_off;

void MouseOn(void)
{
	mouse_off--;
	if (mouse_off==0)
		graf_mouse(M_ON,NULL);
}

void MouseOff(void)
{
	if (mouse_off==0)
		graf_mouse(M_OFF,NULL);
	mouse_off++;
}

static int _mode,_lwidth,_lcolor,_fcolor,_finter,_fstyle,_tfont,_theight,_tcolor;

void vs_attr(void)
{
	_mode = _lwidth = _lcolor = _fcolor = _finter = _fstyle = _tfont = _theight = _tcolor = -1;
}

void _vdi_attr(int mode,int wid,int col)
{
	v_set_mode(mode);
	v_set_line(col,wid);
}

void v_set_text(int font,int height,int color,int *out)
{
	if (font!=_tfont)
		vst_font(x_handle,_tfont=font);

	if (out!=NULL || height!=_theight)
	{
		int dummy[4];

		if (out==NULL)
			out = dummy;

		if (height>0)
			vst_height(x_handle,height,&out[0],&out[1],&out[2],&out[3]);
		else
			vst_point(x_handle,-height,&out[0],&out[1],&out[2],&out[3]);
		_theight = height;
	}

	if (color!=_tcolor)
		vst_color(x_handle,_tcolor = color);
}

void v_set_mode(int mode)
{
	if (mode>=0 && mode!=_mode)
		vswr_mode(x_handle,_mode=mode);
}

void v_set_line(int color,int width)
{
	if (width>=0 && width!=_lwidth)
		vsl_width(x_handle,_lwidth=width);

	if (color>=0 && color!=_lcolor)
		vsl_color(x_handle,_lcolor=color);
}

void v_set_fill(int color,int inter,int style)
{
	if (color>=0 && color!=_fcolor)
		vsf_color(x_handle,_fcolor=color);

	if (inter>=0 && inter!=_finter)
		vsf_interior(x_handle,_finter=inter);

	if (style>=0 && style!=_fstyle)
		vsf_style(x_handle,_fstyle=style);
}

void vsf_aespattern(int handle, int obx, int oby, int patternindex)
{
	static long aespatterns[] = {
		0x00000000L, 0x00440011L, 0x00550055L, 0x88552288L,
		0x55AA55AAL, 0xAADDAA77L, 0x55FF55FFL, 0xFFFFFFFFL };

	unsigned long pat;
	reg int i,j,pattern[16];
	reg char *patptr, *p;

	pat = aespatterns[patternindex];

	obx &= 3;
	pat >>= obx;
	pat &= 0x0F0F0F0FL;
	pat |= (pat<<4);

	oby &= 3;
	pat = (pat<<((4-oby)<<3))|(pat>>(oby<<3));

	patptr = (char *) pattern;
	for (i=4;--i>=0;)
	{
		p = (char *) &pat;
		for (j=4;--j>=0;)
		{
			*patptr++ = *p;
			*patptr++ = *p++;
        }
    }

	vsf_interior(handle, 4);
	vsf_udpat(handle, pattern, 1);
}

void v_aespattern(int ob_x, int ob_y, int pattern)
{
	vsf_aespattern(x_handle, ob_x, ob_y, pattern);
	_finter = 4;
}

void _line(int x1,int y1,int x2,int y2)
{
	reg int pxy[4];
	
	pxy[0] = x1;
	pxy[1] = y1;
	pxy[2] = x2;
	pxy[3] = y2;
	v_pline(x_handle,2,pxy);
}

void _bar(int x,int y,int w,int h,int interior,int style,int color)
{
	reg int pxy[4];

	v_set_fill(color,interior,style);

	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + w;
	pxy[3] = y + h;
	v_bar(x_handle,pxy);
}

void _rectangle(int sx,int sy,int dx,int dy)
{
	reg int pxy[10];

	pxy[0] = pxy[6] = pxy[8] = sx;
	pxy[1] = pxy[3] = pxy[9] = sy;
	pxy[2] = pxy[4] = dx;
	pxy[5] = pxy[7] = dy;
	v_pline(x_handle,5,pxy);
}

void _beg_ctrl()
{
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
}

void _end_ctrl()
{
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

int _mouse_but(void)
{
	int but,dummy;

	if (_back_win && !_bevent)
		vq_mouse(x_handle,&but,&dummy,&dummy);
	else
		graf_mkstate(&dummy,&dummy,&but,&dummy);

	return(but);
}

void _mouse_pos(reg int *x,reg int *y)
{
	int dummy;
	graf_mkstate(x,y,&dummy,&dummy);
}

void _no_click()
{
	XEVENT event;

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags = MU_BUTTON1;
	event.ev_mb1mask = 3;
	event.ev_mb1clicks = 1;

	_no_button++;
	Event_Multi(&event);
	_no_button--;
}

/*************************/

int min(int v_1,int v_2)
{
	if (v_1<v_2)
		return(v_1);
	else
		return(v_2);
}

int max(int v_1,int v_2)
{
	if (v_1>v_2)
		return(v_1);
	else
		return(v_2);
}

void Min(int *var,int val)
{
	if (*var>val)
		*var = val;
}

void Max(int *var,int val)
{
	if (*var<val)
		*var = val;
}

int scan_2_ascii(int scan,int state)
{
	reg int sc = (int) (((unsigned) scan)>>8);

	if (state && sc)
	{
		long old_stack;
		reg KEYTAB *keytab = Keytbl((void *) -1l,(void *) -1l,(void *) -1l);

		if (sc>=120 && sc<=131)
			sc -= 118;

		if (mint)
			old_stack = (long) Super(NULL);

		if (state & 3)
			scan = (int) *(keytab->shift+sc);
		else
			scan = (int) *(keytab->unshift+sc);

		if (mint)
			Super((void *) old_stack);
	}

	return (UpperChar(scan));
}

void mfdb(MFDB *fm,int *adr,int w,int h,int st,int pl)
{
	fm->fd_addr		= adr;
	fm->fd_w		= (w+15) & 0xfff0;
	fm->fd_h		= h;
	fm->fd_wdwidth	= fm->fd_w>>4;
	fm->fd_stand	= st;
	fm->fd_nplanes	= pl;
}

long mfdb_size(MFDB *fm)
{
	return ((long) (fm->fd_wdwidth<<1) * (long) fm->fd_h * (long) fm->fd_nplanes);
}

int _call_event_handler(int msg,XEVENT *event,int sendkey)
{
	reg XAcc *xacc;
	reg int used,mbuf[8];

	if (event_handler!=NULL && (handler_events & msg))
	{
		reg int old = event->ev_mwich;

		event->ev_mwich = msg;
		used = event_handler(event);
		event->ev_mwich = old;
	}
	else
		used = 0;

	if ((msg & MU_KEYBD) && sendkey && _dia_len==0 && _popup==0 && (used & MU_KEYBD)==0)
	{
		mbuf[3] = event->ev_mmokstate;
		mbuf[4] = event->ev_mkreturn;

		if (AvServer>=0)
			AvSendMsg(AvServer,AV_SENDKEY,mbuf);
		else if (!multi && (xacc=find_id(0))!=NULL)
		{
			if (xacc->flag & AV)
				AvSendMsg(0,AV_SENDKEY,mbuf);
			else
				XAccSendKey(0, event->ev_mkreturn, event->ev_mmokstate);
		}
	}

	return (used);
}

void Event_Handler(int (*init)(XEVENT *,int),int (*handler)(XEVENT *))
{
	if (init!=NULL || handler==NULL)
		event_init = init;

	if (handler!=NULL || init==NULL)
		event_handler = handler;

	if (event_handler==NULL)
		event_init = NULL;
}

typedef struct
{
	long	type;
	long	what;
} APPLRECORD;

static APPLRECORD record[] = {{1l,0x10000l}, {0l,10l}, {1l,0x100001l}};

void Event_Timer(int locount,int hicount)
{
	XEVENT event;

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags = MU_TIMER|MU_MESAG|MU_GET_MESSAG;
	event.ev_mtlocount = locount;
	event.ev_mthicount = hicount;

	while (Event_Multi(&event) & MU_MESAG);
}

static void iconify(WIN *window,int all)
{
	reg int i,top = _get_top();

	if (all)
	{
		i = MAX_WINDOWS;
		window = _windows;
	}
	else
		i = 1;

	for (;--i>=0;)
	{
		if (window->handle>0)
		{
			if (top==window->handle)
			{
		 		if (_icfs_iconify(window,TRUE,FAIL)==FALSE)
					break;
				top = window->handle;
			}
			else if (_icfs_iconify(window,TRUE,FAIL)==FALSE)
				break;
		}

		if (all)
			window++;
	}

	wind_set(_last_top=top,WF_TOP);
}

static int handle_messag(XEVENT *event,int no_messag,int flags)
{
	DRAG_DROP dd;
	reg SCROLL *sc;
	reg WIN *window;
	reg int events = event->ev_mwich,state,old_h,old_v;
	reg int *msg = event->ev_mmgpbuf;
	reg long pos;

	if (_XAccComm(msg)==FALSE)
	{
		if (msg[0]==WM_M_BDROPPED)
			msg[0] = WM_BOTTOMED;

		if (_dia_len>0 || _popup)
			switch (msg[0])
			{
			case AC_CLOSE:
			case AC_OPEN:
			case AP_TERM:
			case MN_SELECTED:
			case WM_SHADED:
			case WM_UNSHADED:
			case WM_ICONIFY:
			case WM_UNICONIFY:
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
				_send_puf(msg[0],msg);
				return (events & (~MU_MESAG));
			}

		switch (msg[0])
		{
		case AP_DRAGDROP:
			_rec_ddmsg(msg);
			events &= ~MU_MESAG;
			break;
		case VA_START:
			dd.dd_type = AV_START;
			dd.dd_win = NULL;
			dd.dd_mx = dd.dd_my = -1;
			dd.dd_kstate = event->ev_mmokstate;
			dd.dd_args = *(char **) &msg[3];
			goto _drag_msg;
		case VA_DRAGACCWIND:
			dd.dd_type = AV_DRAG;
			dd.dd_win = get_window(msg[3]);
			dd.dd_mx = msg[4];
			dd.dd_my = msg[5];
			dd.dd_kstate = event->ev_mmokstate;
			dd.dd_args = *(char **) &msg[6];
			_drag_msg:
			dd.dd_originator = msg[1];
			dd.dd_mem = dd.dd_name = NULL;
			dd.dd_ext[0] = '\0';
			dd.dd_size = 0l;
			_send_msg(&dd,0,OBJC_DRAGGED,0,0);
			events &= ~MU_MESAG;
			break;
		case WIN_TOPPED:
			msg[0] = WM_TOPPED;
			break;
		case WIN_CLOSED:
			msg[0] = WM_CLOSED;
			break;
		case MN_SELECTED:
			if (_cycle>0 && msg[4]==_cycle)
			{
				_cycle_close_window(TRUE,msg[3]);
				events &= ~MU_MESAG;
			}
			else if (_close>0 && msg[4]==_close)
			{
				_cycle_close_window(FALSE,msg[3]);
				events &= ~MU_MESAG;
			}
			break;
		case WIN_INFO:
		case WIN_NAME:
			if ((window=get_window(msg[3]))!=NULL)
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
			if ((window=get_window(msg[3]))!=NULL)
			{
				switch (msg[0])
				{
				case WIN_HSLSIZE:
					msg[0] = WF_HSLSIZE;
					break;
				case WIN_VSLSIZE:
					msg[0] = WF_VSLSIZE;
					break;
				case WIN_HSLIDE:
					msg[0] = WF_HSLIDE;
					break;
				default:
					msg[0] = WF_VSLIDE;
				}

				wind_set(msg[3],msg[0],msg[4]);
				events &= ~MU_MESAG;
			}
			break;
		case WM_SHADED:
			if ((window=get_window(msg[3]))!=NULL)
			{
				window->iconified |= SHADE;
				goto _win_changed;
			}
			break;
		case WM_UNSHADED:
			if ((window=get_window(msg[3]))!=NULL)
			{
				window->iconified &= ~SHADE;
				goto _win_changed;
			}
			break;
		case WM_ICONIFY:
			if ((window=get_window(msg[3]))!=NULL)
			{
				wind_set(msg[3],WF_ICONIFY,msg[4],msg[5],msg[6],msg[7]);
				if (window->icon_name)
					wind_set(msg[3],WF_NAME,window->icon_name);
				wind_xget(window->handle,WF_WORKXYWH,&window->icf_work.g_x,&window->icf_work.g_y,&window->icf_work.g_w,&window->icf_work.g_h);
				window->iconified |= ICONIFIED;
				goto _win_changed;
			}
			break;
		case WM_UNICONIFY:
			if ((window=get_window(msg[3]))!=NULL)
			{
				window->iconified &= ~ICONIFIED;
				wind_set(msg[3],WF_UNICONIFY,window->curr.g_x,window->curr.g_y,window->curr.g_w,window->curr.g_h);
				wind_set(msg[3],WF_CURRXYWH,window->curr.g_x,window->curr.g_y,window->curr.g_w,window->curr.g_h);
				window_name(window,window->name,window->icon_name);
				goto _win_changed;
			}
			break;
		case WM_CLOSED:
			state = (event->ev_mmokstate & (K_RSHIFT|K_LSHIFT|K_ALT));
			if (_icfs!=NULL && state && (window=get_window(msg[3]))!=NULL)
			{
				if (state & K_ALT)
				{
					iconify(window,FALSE);
					_win_changed:
					*(WIN **) &msg[4] = window;
				}
				else
				{
					iconify(window,TRUE);
					*(WIN **) &msg[4] = NULL;
				}
				msg[0] = WIN_CHANGED;
				_window_fast_mouse(window,FALSE);
			}
			break;
		case WM_REDRAW:
			if ((window=get_window(msg[3]))!=NULL && (window->redraw!=NULL || win_iconified(window)))
			{
				redraw_window(window,(GRECT *) &msg[4]);
				events &= ~MU_MESAG;
			}
			break;
		case WM_MOVED:
			if ((window=get_window(msg[3]))!=NULL && win_iconified(window))
			{
				wind_set(window->handle,WF_CURRXYWH,msg[4],msg[5],msg[6],msg[7]);
				wind_xget(window->handle,WF_WORKXYWH,&window->icf_work.g_x,&window->icf_work.g_y,&window->icf_work.g_w,&window->icf_work.g_h);
				events &= ~MU_MESAG;
			}
			break;
		case WM_UNTOPPED:
			if ((window=get_window(msg[3]))!=NULL)
				window->inside = FAIL;
			break;
		case WM_ONTOP:
		case WM_NEWTOP:
			_last_top = msg[3];
			_reset_mouse();
			break;
		case WM_TOPPED:
			if (!_bevent && _back_win && (flags & (MU_BUTTON1|MU_BUTTON2)))
			{
				if ((window=get_window(msg[3]))!=NULL && !win_iconified(window) && rc_inside(event->ev_mmox,event->ev_mmoy,&window->work))
				{
					events &= ~MU_MESAG;
					event->ev_mmobutton = 1;
					event->ev_mb1return = event->ev_mb2return = 1;

					if (event->ev_mb1clicks>=256 || (event->ev_mb1state & 1))
						events |= MU_BUTTON1;

					if (event->ev_mb2clicks>=256 || (event->ev_mb2state & 1))
						events |= MU_BUTTON2;

					if (_mouse_but() & 1)
						appl_tplay(record,3,100);
				}
			}
			break;
		case WM_HSLID:
		case WM_VSLID:
		case WM_ARROWED:
			if ((window=get_window(msg[3]))!=NULL && ((sc=window->scroll)!=NULL))
			{
				old_h = sc->hpos;
				old_v = sc->vpos;

				switch (msg[0])
				{
				case WM_HSLID:
					pos = msg[4];
					pos *= max(sc->hsize - sc->hpage,0);
					pos /= 1000;
					sc->hpos = (int) pos;
					break;
				case WM_VSLID:
					pos = msg[4];
					pos *= max(sc->vsize - sc->vpage,0);
					pos /= 1000;
					sc->vpos = (int) pos;
					break;
				default:
					for (;;)
					{
						_arrow_window(sc,msg[4],(winx && msg[5]<0) ? -msg[5] : 1);
						if (winx && msg[7]<0)
						{
							msg[4] = msg[6];
							msg[5] = msg[7];
							msg[7] = 0;
						}
						else
							break;
					}
				}

				scroll_window(window,WIN_SCROLL,NULL);
				msg[0] = WIN_SCROLLED;
				*(WIN **) &msg[4] = window;
				msg[6] = old_h;
				msg[7] = old_v;
			}
			break;
		case AV_SENDKEY:
			events &= ~MU_MESAG;
			if (flags & MU_KEYBD)
			{
				events |= MU_KEYBD;
				event->ev_mkreturn = msg[4];
				event->ev_mmokstate = msg[3];
			}
			break;
		case ACC_KEY:
			events &= ~MU_MESAG;
			if (flags & MU_KEYBD)
			{
				events |= MU_KEYBD;
				event->ev_mkreturn = msg[3];
				event->ev_mmokstate = msg[4];
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
			break;
		}

		if (no_messag==0 && (events & MU_MESAG))
		{
			event->ev_mwich = events;
			_messag_handler(FALSE,event,NULL,NULL);
			return (event->ev_mwich);
		}
		else
			return (events);
	}
	else
		return (events & (~MU_MESAG));
}

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

static E_BUTTON click = {258,3,0}, no_click = {1,3,0};
static int next_msg;

MESSAG _messages[MAX_MSG];
int _msg_cnt;

void _send_puf(int msg_id,int *msg)
{
	reg int *mbuf, act = next_msg, last = _msg_cnt;

	mbuf = (int *) &_messages[act];
	while (act!=last)
	{
		if (*mbuf==msg_id && mbuf[3]==msg[3])
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
			else
				memcpy(&mbuf[4],&msg[4],8);
			return;
		}
		else if (++act==MAX_MSG)
			mbuf = (int *) &_messages[act=0];
		else
			mbuf += 8;
	}

	memcpy(mbuf,msg,16);
	*mbuf++ = msg_id;
	*mbuf++ = ap_id;
	*mbuf++ = 0;

	if (++_msg_cnt==MAX_MSG)
		_msg_cnt = 0;
}

static int Wait_for_Event(XEVENT *event)
{
	E_MOUSE mu_m1;
	E_BUTTON mu_button1;
	E_TIMER mu_timer1;

	reg long timer,l_timer;
	reg int events = 0,flags = event->ev_mflags,t_flags = (flags & (MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4));
	int in,button = 0,nx,ny,in1,in3,in4,mouse,d,next_timer;
	long time;

	event->ev_mflags &= MU_MESAG|MU_BUTTON|MU_KEYBD|MU_M1|MU_M2|MU_TIMER;

	if (flags & (MU_M3|MU_M4))
	{
		mu_m1 = *(E_MOUSE *) &event->ev_mm1flags;

		_mouse_pos(&nx,&ny);
		in1 = rc_inside(nx,ny,(GRECT *) &event->ev_mm1x);
		in3 = rc_inside(nx,ny,(GRECT *) &event->ev_mm3x);
		in4 = rc_inside(nx,ny,(GRECT *) &event->ev_mm4x);

		event->ev_mm1flags = event->ev_mm1width = event->ev_mm1height = 1;
		event->ev_mm1x = nx;
		event->ev_mm1y = ny;

		event->ev_mflags |= MU_M1;
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

	if (t_flags || button<0)
	{
		mu_timer1 = *(E_TIMER *) &event->ev_mt1locount;
		event->ev_mflags |= MU_TIMER;
	}

	do
	{
		if (t_flags)
		{
			time = clock()*5;

			if (t_flags & MU_TIMER1)
			{
				timer = (((long) event->ev_mt1hicount)<<16)|event->ev_mt1locount;
				if (event->ev_mt1last<=0)
					event->ev_mt1last = time;
				else
					timer += event->ev_mt1last - time;
				next_timer = MU_TIMER1;
			}
			else
			{
				timer = (1l<<30);
				next_timer = 0;
			}

			if (t_flags & MU_TIMER2)
			{
				l_timer = event->ev_mt2count;
				if (event->ev_mt2last<=0)
					event->ev_mt2last = time;
				else
					l_timer += event->ev_mt2last - time;
				if (l_timer<timer)
				{
					timer = l_timer;
					next_timer = MU_TIMER2;
				}
			}

			if (t_flags & MU_TIMER3)
			{
				l_timer = event->ev_mt3count;
				if (event->ev_mt3last<=0)
					event->ev_mt3last = time;
				else
					l_timer += event->ev_mt3last - time;
				if (l_timer<timer)
				{
					timer = l_timer;
					next_timer = MU_TIMER3;
				}
			}

			if (t_flags & MU_TIMER4)
			{
				l_timer = event->ev_mt4count;
				if (event->ev_mt4last<=0)
					event->ev_mt4last = time;
				else
					l_timer += event->ev_mt4last - time;
				if (l_timer<timer)
				{
					timer = l_timer;
					next_timer = MU_TIMER4;
				}
			}

			if (timer<=(long) _min_timer || button<0)
			{
				event->ev_mthicount = 0;
				event->ev_mtlocount = _min_timer;
				events = MU_TIMER;
			}
			else
			{
				event->ev_mtlocount = (int) timer;
				event->ev_mthicount = (int) (timer>>16);
			}

			if (timer>0)
				time += timer;
		}
		else if (button<0)
		{
			event->ev_mthicount = 0;
			event->ev_mtlocount = _min_timer;
			events = MU_TIMER;
		}

		if ((flags & MU_MESAG) && _msg_cnt!=next_msg && _dia_len==0 && _popup==0)
		{
			*(MESSAG *) &event->ev_mmgpbuf[0] = _messages[next_msg++];
			if (next_msg==MAX_MSG)
				next_msg = 0;
			events |= MU_MESAG;
			graf_mkstate(&event->ev_mmox,&event->ev_mmoy,&event->ev_mmobutton,&event->ev_mmokstate);
		}
		else if (events & MU_TIMER)
		{
			events |= EvntMulti((EVENT *) event);
			if (!(events & MU_BUTTON1))
				graf_mkstate(&d,&d,&event->ev_mmobutton,&event->ev_mmokstate);
		}
		else
			events |= EvntMulti((EVENT *) event);

		if (!_bevent && _back_win)
		{
			event->ev_mmobutton = _mouse_but();
			mouse = TRUE;

			if (events & MU_BUTTON1)
			{
				in = event->ev_mmobutton & event->ev_mb1mask;

				if (event->ev_mb1clicks<256)
				{
					if (in!=event->ev_mb1state)
						events &= ~MU_BUTTON1;
				}
				else if (in==0)
					events &= ~MU_BUTTON1;
			}
		}
		else
			mouse = FALSE;

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
				if (events & MU_BUTTON1)
					events &= ~MU_BUTTON1;
				else
				{
					if (mouse==FALSE)
						event->ev_mmobutton = _mouse_but();
					event->ev_mb2return = event->ev_mb1return = 1;
				}

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

		if ((events & MU_M1) && (flags & (MU_M3|MU_M4)))
		{
			events &= ~MU_M1;		

			ny = event->ev_mmox;
			nx = event->ev_mmoy;

			if (flags & MU_M1)
			{
				in = rc_inside(nx,ny,(GRECT *) &mu_m1.ev_mmx) - in1;
				if ((in<0 && mu_m1.ev_mmflags) || (in>0 && mu_m1.ev_mmflags==0))
					events |= MU_M1;
			}

			if (flags & MU_M3)
			{
				in = rc_inside(nx,ny,(GRECT *) event->ev_mm3x) - in3;
				if ((in<0 && event->ev_mm3flags) || (in>0 && event->ev_mm3flags==0))
					events |= MU_M3;
			}

			if (flags & MU_M4)
			{
				in = rc_inside(nx,ny,(GRECT *) event->ev_mm4x) - in4;
				if ((in<0 && event->ev_mm4flags) || (in>0 && event->ev_mm4flags==0))
					events |= MU_M4;
			}
		}

		if (events & MU_TIMER)
		{
			if (t_flags && (timer<=(long) _min_timer || button>=0))
			{
				events &= ~MU_TIMER;
				events |= next_timer;

				switch (next_timer)
				{
				case MU_TIMER2:
					event->ev_mt2last = time;
					break;
				case MU_TIMER3:
					event->ev_mt3last = time;
					break;
				case MU_TIMER4:
					event->ev_mt4last = time;
					break;
				default:
					event->ev_mt1last = time;
				}
			}
			else
				events &= ~MU_TIMER;
		}
	} while (events==0);

	if (flags & (MU_M3|MU_M4))
		*(E_MOUSE *) &event->ev_mm1flags = mu_m1;

	if (t_flags || button<0)
		*(E_TIMER *) &event->ev_mt1locount = mu_timer1;

	if (flags & MU_BUTTON2)
		*(E_BUTTON *) &event->ev_mb1clicks = mu_button1;

	event->ev_mwich = events;
	event->ev_mflags = flags;

	return (events);
}

int Event_Multi(XEVENT *event)
{
	E_BUTTON mu_button1;
	reg WIN *window;
	XEVENT local_event;
	reg int events,no_messag,wait_events,key,flags;
	int mesag,available,old_flags,button;

	if (event==NULL)
	{
		event = &local_event;
		memset(event,0,sizeof(XEVENT));
		old_flags = no_messag = wait_events = 0;
	}
	else
	{
		old_flags = event->ev_mflags;
		no_messag = (old_flags & MU_NO_HANDLER);
		wait_events = (old_flags & (MU_MESAG|MU_KEYBD|MU_BUTTON1|MU_BUTTON2|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4));
	}

	if (_popup)
		available = MU_MESAG|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4;
	else if (_no_button)
		available = MU_MESAG|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4;
	else
		available = MU_MESAG|MU_KEYBD|MU_BUTTON1|MU_BUTTON2|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4;
	available &= ~(wait_events & (MU_BUTTON1|MU_BUTTON2|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2|MU_TIMER3|MU_TIMER4));

	do
	{
		flags = wait_events;
		if (event_init!=NULL)
			flags |= (handler_events = event_init(event,available) & available);
		else if (event_handler!=NULL && !_popup)
			handler_events = available;
		else
			handler_events = 0;

		if (_icfs!=NULL && _opened>0 && _dia_len==0 && _popup==0)
		{
			if (!(flags & (MU_BUTTON1|MU_BUTTON2)) && (available & MU_BUTTON1))
			{
				flags |= MU_BUTTON1;

				mu_button1 = *(E_BUTTON *) &event->ev_mb1clicks;
				*(E_BUTTON *) &event->ev_mb1clicks = click;
				button = TRUE;
			}
			else
				button = FALSE;

			if (!(flags & MU_KEYBD) && (available & MU_KEYBD))
				flags |= MU_KEYBD;
		}
		else
			button = FAIL;

		event->ev_mflags = flags;
		events = Wait_for_Event(event);
		event->ev_mflags = old_flags;

		if (button>=FALSE)
		{
			if (button==TRUE)
				*(E_BUTTON *) &event->ev_mb1clicks = mu_button1;
			if (event->ev_mmobutton & 1)
				if ((window=window_find(event->ev_mmox,event->ev_mmoy))!=NULL && (window->iconified & ICFS) && rc_inside(event->ev_mmox,event->ev_mmoy,&window->icf_work))
					if (!(events & MU_MESAG) || event->ev_mmgpbuf[0]!=WM_MOVED)
					{
						_icfs_iconify(window,FALSE,FALSE);
						_send_msg(window,0,WIN_CHANGED,0,0);
						events &= ~(MU_BUTTON1|MU_BUTTON2);
						_no_click();
					}
		}

		mesag = 0;
		if (events & MU_MESAG)
		{
			if (old_flags & MU_GET_MESSAG)
				mesag = MU_MESAG;
			events = handle_messag(event,no_messag,flags);
		}

		if ((events & MU_KEYBD) && _opened>0 && _dia_len==0 && _popup==0 && (event->ev_mmokstate & K_CTRL) && (window=get_top_window())!=NULL)
		{
			button = event->ev_mkreturn>>8;
			if (button==0x66)
			{
				int mbuf[8];
				mbuf[3] = window->handle;
				_send_puf(WM_FULLED,mbuf);
				events &= ~MU_KEYBD;
			}
			else if (button==0x39 && _icfs!=NULL)
			{
				if (event->ev_mmokstate & (K_LSHIFT|K_RSHIFT))
				{
					iconify(window,TRUE);
					_send_msg(NULL,0,WIN_CHANGED,0,0);
				}
				else
				{
					_icfs_iconify(window,!(window->iconified & ICFS),window->handle);
					_send_msg(window,0,WIN_CHANGED,0,0);
				}
				events &= ~MU_KEYBD;
			}
			else if ((key=scan_2_ascii(event->ev_mkreturn,event->ev_mmokstate))!='\0')
			{
				key = UpperChar(key);
				if (key==_cycle_hot || key==_close_hot)
				{
					_cycle_close_window(key==_cycle_hot,0);
					events &= ~MU_KEYBD;
				}
			}
		}

		if (no_messag==0)
		{
			if (handler_events & events)
				events &= ~_call_event_handler(events,event,(wait_events & MU_KEYBD) ? FALSE : FAIL);
			events &= wait_events;
		}

		events |= mesag;
	} while (!events);

	return (event->ev_mwich = events);
}

void rc_sc_clear(GRECT *dest)
{
	rc_sc_copy(dest,dest->g_x,dest->g_y,0);
}

void rc_sc_invert(GRECT *dest)
{
	rc_sc_copy(dest,dest->g_x,dest->g_y,D_INVERT);
}

void rc_sc_copy(GRECT *source,int dx,int dy,int mode)
{
	reg int pxy[8];

	rc_grect_to_array(source,pxy);

	pxy[4] = dx;
	pxy[5] = dy;
	pxy[6] = dx+source->g_w-1;
	pxy[7] = dy+source->g_h-1;

	vro_cpyfm(x_handle,mode,pxy,screen,screen);
}

int rc_sc_scroll(GRECT *work,int dist_h,int dist_v,GRECT *work2)
{
	reg int dx,dy,abs_dist_h,abs_dist_v;
	int x,y,w,h;

	if (!rc_intersect(&desk,work))
		return (0);
	else if (dist_h==0 && dist_v==0)
		return (1);

	abs_dist_h = abs(dist_h);
	abs_dist_v = abs(dist_v);

	w = work->g_w;
	h = work->g_h;

	if (abs_dist_h<w && abs_dist_v<h)
	{
		dx = x = work->g_x;
		dy = y = work->g_y;

		if (dist_h>0)
			work->g_x += abs_dist_h;
		else
			dx += abs_dist_h;

		if (dist_v>0)
			work->g_y += abs_dist_v;
		else
			dy += abs_dist_v;

		work->g_w -= abs_dist_h;
		work->g_h -= abs_dist_v;
		rc_sc_copy(work,dx,dy,3);

		if (abs_dist_h && abs_dist_v)
		{
			work2->g_x = x;
			if (dist_h>0)
				work2->g_x += work->g_w;
			work2->g_y = y;
			work2->g_w = abs_dist_h;
			work2->g_h = h - abs_dist_v;

			work->g_x = x;
			if (dist_v>0)
				work->g_y = y + work->g_h;
			else
				work2->g_y += abs_dist_v;

			work->g_w = w;
			work->g_h = abs_dist_v;

			return (2);
		}
		else if (abs_dist_h)
		{
			if (dist_h>0)
				work->g_x = x + work->g_w;
			work->g_w = abs_dist_h;
		}
		else
		{
			if (dist_v>0)
				work->g_y = y + work->g_h;
			work->g_h = abs_dist_v;
		}
	}

	return (1);
}

int rc_sc_save(GRECT *rect,RC_RECT *rc)
{
	reg int pxy[8],*ptr = &pxy[4];
	reg long mem,len;

	mfdb(&rc->mfdb,NULL,rect->g_w,rect->g_h,0,planes);
	len = mfdb_size(&rc->mfdb);

	if (rect->g_x>=0 && rect->g_y>=0 && (rect->g_x+rect->g_w)<=max_w && (rect->g_y+rect->g_h)<=max_h &&
		(mem=(long) malloc(len+16l))>0l)
	{
		rc->mem = (void *) mem;
		rc->area = *rect;
		rc->mfdb.fd_addr = (int *) ((mem+1) & (~1l));

		rc_grect_to_array(&rc->area,pxy);
		*ptr++ = 0;
		*ptr++ = 0;
		*ptr++ = rc->area.g_w - 1;
		*ptr++ = rc->area.g_h - 1;
		vro_cpyfm(x_handle,3,pxy,screen,&rc->mfdb);

		rc->valid = TRUE;
	}
	else
		rc->valid = FALSE;

	return (rc->valid);
}

int _rc_sc_savetree(OBJECT *tree,RC_RECT *rc)
{
	GRECT save;
	int valid;

	save.g_x = tree->ob_x - 3;
	save.g_y = tree->ob_y - 3;
	save.g_w = tree->ob_width + 6;
	save.g_h = tree->ob_height + 6;

	MouseOff();
	valid = rc_sc_save(&save,rc);
	MouseOn();

	return (valid);
}

int rc_sc_freshen(int sx,int sy,RC_RECT *rc)
{
	reg int pxy[8],*ptr = &pxy[4];
	reg GRECT *area = &rc->area;

	if (rc->valid && (sx+area->g_w)<=max_w && (sy+area->g_h)<=max_h)
	{
		area->g_x = sx;
		area->g_y = sy;

		rc_grect_to_array(area,pxy);
		*ptr++ = 0;
		*ptr++ = 0;
		*ptr++ = area->g_w - 1;
		*ptr++ = area->g_h - 1;
		vro_cpyfm(x_handle,3,pxy,screen,&rc->mfdb);

		return (TRUE);
	}
	else
		return (FALSE);
}

int rc_sc_restore(int x,int y,RC_RECT *rc,int mode)
{
	reg int pxy[8],*ptr = pxy;

	if (rc->valid)
	{
		if (mode!=FAIL)
		{
			*ptr++ = 0;
			*ptr++ = 0;
			*ptr++ = rc->area.g_w - 1;
			*ptr++ = rc->area.g_h - 1;
			*ptr++ = x;
			*ptr++ = y;
			*ptr++ = x + pxy[2];
			*ptr++ = y + pxy[3];
			vro_cpyfm(x_handle,3,pxy,&rc->mfdb,screen);
		}

		if (mode!=FALSE)
		{
			free(rc->mem);
			memset(rc,0,sizeof(RC_RECT));
		}

		return (TRUE);
	}
	else
		return (FALSE);
}

void save_clipping(int *area)
{
	reg long *clip=(long *) clipping_area;

	*((long *) area)++ = *clip++;
	*((long *) area)++ = *clip++;
}

void _clip_rect(GRECT *area)
{
	int pxy[4];
	rc_grect_to_array(area,pxy);
	restore_clipping(pxy);
}

void restore_clipping(int *area)
{
	reg long *clip=(long *) clipping_area;

	vs_clip(x_handle,1,area);
	*clip++ = *((long *) area)++;
	*clip++ = *((long *) area)++;
}
