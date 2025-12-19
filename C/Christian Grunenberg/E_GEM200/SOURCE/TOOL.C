
#include <time.h>
#include "proto.h"

static int clipping_area[4];
static int handler_events;
static int (*event_init)(XEVENT *,int),(*event_handler)(XEVENT *);

char _upper(char ch)
{
	if (ch>='a')
	{
		if(ch>'z')
		{
			if (ch=='„')
				return('Ž');
			else if (ch=='”')
				return('™');
			else if (ch=='')
				return('š');
		}
		else
			return(ch-32);
	}

	return(ch);
}

char _lower(char ch)
{
	if (ch>='A')
	{
		if(ch>'Z')
		{
			if (ch=='Ž')
				return('„');
			else if (ch=='™')
				return('”');
			else if (ch=='š')
				return('');
		}
		else
			return(ch+32);
	}

	return(ch);
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

void _bitblt(OBJECT *tree,MFDB *form,boolean flag)
{
	reg int pxy[8],*ptr=pxy;
	reg int x = tree->ob_x - 3,y = tree->ob_y - 3;
	reg int w = tree->ob_width + 5,h = tree->ob_height + 5;
	
	graf_mouse(M_OFF,NULL);

	if (flag)
	{
		*ptr++ = x;
		*ptr++ = y;
		*ptr++ = x + w;
		*ptr++ = y + h;
		*ptr++ = 0;
		*ptr++ = 0;
		*ptr++ = w;
		*ptr   = h;
		vro_cpyfm(x_handle,3,pxy,screen,form);
	}
	else
	{
		*ptr++ = 0;
		*ptr++ = 0;
		*ptr++ = w;
		*ptr++ = h;
		*ptr++ = x;
		*ptr++ = y;
		*ptr++ = x + w;
		*ptr   = y + h;
		vro_cpyfm(x_handle,3,pxy,form,screen);
	}

	graf_mouse(M_ON,NULL);
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

void _bar(int x,int y,int w,int h,int interior,int color)
{
	reg int pxy[4];

	v_set_fill(color,interior,-1);

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
	if (_mouse_but())
	{
		XEVENT event;

		event.ev_mflags = MU_BUTTON;
		event.ev_mbmask = 3;
		event.ev_mbclicks = 1;
		event.ev_mbstate = 0;
		Event_Multi(&event);
	}
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
	reg long old_stack;
	reg KEYTAB *keytab = Keytbl((void *) -1l,(void *) -1l,(void *) -1l);

	if (state)
	{
		scan = (int) (((unsigned) scan)>>8);
		if ((scan>=120) && (scan<=131))
			scan -= 118;

		if (mint)
			old_stack = (long) Super(NULL);

		if (state & 3)
			scan = (int) *(keytab->shift+scan);
		else
			scan = (int) *(keytab->unshift+scan);

		if (mint)
			Super((void *) old_stack);
	}

	scan &= 0xff;
	if (scan>='a')
	{
		if (scan<='z')
			scan -= 32;
		else if (scan=='„')
			scan='Ž';
		else if (scan=='”')
			scan='™';
		else if (scan=='')
			scan='š';
	}
	return(scan);
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
	reg int used;

	if (event_handler!=NULL && (handler_events & msg))
	{
		reg int old = event->ev_mwich;

		event->ev_mwich = msg;
		used = event_handler(event);
		event->ev_mwich = old;
	}
	else
		used = 0;

	if ((msg & MU_KEYBD) && sendkey && _dia_len==0 && (used & MU_KEYBD)==0)
	{
		if (AvServer>=0)
		{
			int msg[8];
			msg[3] = event->ev_mmokstate;
			msg[4] = event->ev_mkreturn;
			AvSendMsg(AvServer,AV_SENDKEY,msg);
		}
		else if (!multi && find_id(0)!=NULL)
			XAccSendKey(0, event->ev_mkreturn, event->ev_mmokstate);
	}

	return (used);
}

static void cycle_close_window(int cycle,int titel)
{
	reg WIN *window,*wins,*last;
	int top,dummy,mbuf[8];

	if (_dia_len==0)
	{
		if (menu_available && titel>0 && menu!=NULL)
			menu_tnormal(menu,titel,1);

		if (_opened>0)
		{
			if (cycle && _opened==1)
				return;

			wind_xget(0,WF_TOP,&top,&dummy,&dummy,&dummy);
			if ((window=get_window(top))!=NULL)
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
				AvSendMsg(ap_id,(cycle) ? WIN_TOPPED : WIN_CLOSED,mbuf);
			}
		}
	}
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

	event.ev_mflags = MU_TIMER|MU_MESAG;
	event.ev_mtlocount = locount;
	event.ev_mthicount = hicount;
	event.ev_mtlast = 0;

	while (Event_Multi(&event) & MU_MESAG);
}

static int icfs_iconify(WIN *window,int iconify,int old_top)
{
	if (iconify)
	{
		int x,y,w,h,top,dummy;

		if (old_top==FALSE)
			wind_xget(0,WF_TOP,&top,&dummy,&dummy,&dummy);
		else
			top = old_top;

		if (top==window->handle)
			top = FALSE;

		if (window->iconified & (ICONIFIED|ICFS))
			return (TRUE);
		else if (!(window->gadgets & SMALLER))
			return (FAIL);
		else if ((window->posnr=(*_icfs)(ICF_GETPOS,&x,&y,&w,&h))>0)
		{
			wind_xget(window->handle,WF_CURRXYWH,&window->x,&window->y,&window->w,&window->h);
			wind_close(window->handle);
			wind_delete(window->handle);
			window->handle = wind_create(NAME|MOVER,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			wind_open(window->handle,x,y,w,h);
			window->iconified |= ICFS;

			if (top>=0)
				wind_set((top>0) ? top : window->handle,WF_TOP);

			return (TRUE);
		}
		else
			return (FALSE);
	}
	else
	{
		if (window->iconified & ICFS)
		{
			wind_close(window->handle);
			wind_delete(window->handle);
			window->handle = wind_create(window->gadgets,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			wind_set(window->handle,WF_BEVENT,_back_win);
			wind_open(window->handle,window->x,window->y,window->w,window->h);
			(*_icfs)(ICF_FREEPOS,window->posnr);
			window->iconified &= ~ICFS;
		}
		return (TRUE);
	}
}

static int handle_messag(XEVENT *event,int no_messag)
{
	GRECT win;
	reg WIN *window;
	reg int events,flags,i,state;
	reg int *msg = event->ev_mmgpbuf;

	if (_XAccComm(msg)==FALSE)
	{
		events = event->ev_mwich;
		flags = event->ev_mflags;

		switch (msg[0])
		{
		case MN_SELECTED:
			if (_cycle>0 && msg[4]==_cycle)
			{
				cycle_close_window(TRUE,msg[3]);
				events &= ~MU_MESAG;
			}
			else if (_close>0 && msg[4]==_close)
			{
				cycle_close_window(FALSE,msg[3]);
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
				if (!(window->iconified & (ICONIFIED|ICFS)))
				{
					wind_set(msg[3],WF_ICONIFY,msg[4],msg[5],msg[6],msg[7]);
					window->iconified |= ICONIFIED;
					goto _win_changed;
				}
			}
			break;
		case WM_UNICONIFY:
			if ((window=get_window(msg[3]))!=NULL)
			{
				if ((window->iconified & (ICONIFIED|ICFS)))
				{
					wind_set(msg[3],WF_UNICONIFY,msg[4],msg[5],msg[6],msg[7]);
					window->iconified &= ~(ICONIFIED|ICFS);
					goto _win_changed;
				}
			}
			break;
		case WM_CLOSED:
			state = (event->ev_mmokstate & (K_RSHIFT|K_LSHIFT|K_ALT));
			if (_icfs!=NULL && state && (window=get_window(msg[3]))!=NULL)
			{
				int top,dummy;

				if (state & K_ALT)
					i = 1;
				else
				{
					i = MAX_WINDOWS;
					window = _windows;
				}

				wind_xget(0,WF_TOP,&top,&dummy,&dummy,&dummy);

				for (;--i>=0;)
				{
					if (window->handle>0)
					{
						if (top==window->handle)
						{
					 		if (icfs_iconify(window,TRUE,FAIL)==FALSE)
								break;
							top = window->handle;
						}
						else if (icfs_iconify(window,TRUE,FAIL)==FALSE)
							break;
					}

					if (state & (K_RSHIFT|K_LSHIFT))
						window++;
				}

				wind_set(top,WF_TOP);

				if (state & K_ALT)
				{
					_win_changed:
					*(WIN **) &msg[4] = window;
				}
				else
					*(WIN **) &msg[4] = NULL;
				msg[0] = WIN_CHANGED;
			}
			break;
		case WM_MOVED:
			if ((window=get_window(msg[3]))!=NULL && (window->iconified & (ICONIFIED|ICFS)))
			{
				Max(&msg[4],desk.g_x);
				Max(&msg[5],desk.g_y);
				wind_set(window->handle,WF_CURRXYWH,msg[4],msg[5],msg[6],msg[7]);
				events &= ~MU_MESAG;
			}
			break;
		case WM_TOPPED:
			wind_xget(msg[3],WF_WORKXYWH,&win.g_x,&win.g_y,&win.g_w,&win.g_h);
			if (rc_inside(event->ev_mmox,event->ev_mmoy,&win))
			{
				if (_icfs!=NULL && (window=get_window(msg[3]))!=NULL && (window->iconified & ICFS))
				{
					icfs_iconify(window,FALSE,FALSE);
					msg[0] = WIN_CHANGED;
					*(WIN **) &msg[4] = window;
				}
				else if (!_bevent && _back_win && (flags & (MU_BUTTON1|MU_BUTTON2)))
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
		case WIN_CLOSED:
			msg[0] = WM_CLOSED;
			break;
		case WIN_TOPPED:
			msg[0] = WM_TOPPED;
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
		case ACC_TEXT:
			if (_xacc_msgs & X_MSG_TEXT)
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
		return (event->ev_mwich & (~MU_MESAG));
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

static E_BUTTON click = {258,3,0}, no_click = {2,3,0};

static int Wait_for_Event(XEVENT *event)
{
	E_MOUSE mu_m1;
	E_BUTTON mu_button1;
	E_TIMER mu_timer1;

	reg int events = 0, flags = event->ev_mflags, t_flags = (flags & (MU_TIMER1|MU_TIMER2));
	reg int in, button = 0;

	int nx,ny,in1,in3,in4;
	long timer,timer1,timer2,time;

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
				timer1 = (((long) event->ev_mt1hicount)<<16)|event->ev_mt1locount;
				if (event->ev_mt1last<=0)
					event->ev_mt1last = time;
				else
					timer1 += event->ev_mt1last - time;
			}

			if (t_flags & MU_TIMER2)
			{
				timer2 = (((long) event->ev_mt2hicount)<<16)|event->ev_mt2locount;
				if (event->ev_mt2last<=0)
					event->ev_mt2last = time;
				else
					timer2 += event->ev_mt2last - time;
			}

			switch (t_flags)
			{
			case MU_TIMER1:
				timer = timer1;
				break;
			case MU_TIMER2:
				timer = timer2;
				break;
			default:
				timer = (timer1<timer2) ? timer1 : timer2;
			}

			if (timer<2 || button<0)
			{
				event->ev_mthicount = 0;
				event->ev_mtlocount = 1;
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
			event->ev_mtlocount = 1;
		}

		events |= EvntMulti((EVENT *) event);

		if (!_bevent && _back_win)
		{
			event->ev_mmobutton = _mouse_but();

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
					event->ev_mb2return = event->ev_mb1return = 1;

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
			if (t_flags && (timer<2 || button>=0))
			{
				switch (t_flags)
				{
				case MU_TIMER1:
					event->ev_mt1last = time;
					break;
				case MU_TIMER2:
					events &= ~MU_TIMER1;
					events |= MU_TIMER2;
					event->ev_mt2last = time;
					break;
				default:
					if (timer1<timer2)
						event->ev_mt1last = time;
					else
					{
						events &= ~MU_TIMER1;
						events |= MU_TIMER2;
						event->ev_mt2last = time;
					}
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
	int available,old_flags,button,msg[8];

	if (event==NULL)
	{
		event = &local_event;
		old_flags = no_messag = wait_events = event->ev_mflags = 0;
	}
	else
	{
		old_flags = event->ev_mflags;
		no_messag = (old_flags & MU_NO_HANDLER);
		wait_events = (old_flags ^ no_messag);
	}

	if (_popup)
		available = MU_TIMER1|MU_TIMER2;
	else
		available = MU_MESAG|MU_KEYBD|MU_BUTTON1|MU_BUTTON2|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2;
	available &= ~(wait_events & (MU_BUTTON1|MU_BUTTON2|MU_M1|MU_M2|MU_M3|MU_M4|MU_TIMER1|MU_TIMER2));

	do
	{
		flags = wait_events;
		if (event_init!=NULL)
			flags |= (handler_events = event_init(event,available) & available);
		else if (event_handler!=NULL && !_popup)
			handler_events = available;
		else
			handler_events = 0;

		if (_icfs!=NULL && _opened>0)
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
			button = FALSE;

		event->ev_mflags = flags;
		events = Wait_for_Event(event);
		event->ev_mflags = old_flags;

		if (button)
			*(E_BUTTON *) &event->ev_mb1clicks = mu_button1;

		if (_icfs!=NULL && _opened>0 && (event->ev_mmobutton & 1))
		{
			if ((window=get_window(wind_find(event->ev_mmox,event->ev_mmoy)))!=NULL && (window->iconified & ICFS))
			{
				icfs_iconify(window,FALSE,FALSE);
				*(WIN **) &msg[4] = window;
				AvSendMsg(ap_id,WIN_CHANGED,msg);
				events &= ~(MU_BUTTON1|MU_BUTTON2);
			}
		}

		if (events & MU_MESAG)
			events = handle_messag(event,no_messag);

		if ((events & MU_KEYBD) && _dia_len==0 && (event->ev_mmokstate & K_CTRL))
		{
			if ((event->ev_mkreturn>>8)==0x66)
			{
				if (_opened>0 && _icfs!=NULL)
				{
					int top,dummy;

					wind_xget(0,WF_TOP,&top,&dummy,&dummy,&dummy);
					if ((window=get_window(top))!=NULL && !(window->iconified & ICONIFIED))
					{
						icfs_iconify(window,!(window->iconified & ICFS),top);
						*(WIN **) &msg[4] = window;
						AvSendMsg(ap_id,WIN_CHANGED,msg);
						events &= ~MU_KEYBD;
					}
				}
			}
			else if ((key=scan_2_ascii(event->ev_mkreturn,event->ev_mmokstate))!='\0')
			{
				key = _upper(key);
				if (key==_cycle_hot || key==_close_hot)
				{
					cycle_close_window(key==_cycle_hot,0);
					events &= ~MU_KEYBD;
				}
			}
		}

		if (no_messag==0)
		{
			if (handler_events & events)
				events &= ~(_call_event_handler(events,event,(wait_events & MU_KEYBD) ? FALSE : FAIL) & (~wait_events));
			events &= wait_events;
		}
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
	reg GRECT work = *source;

	if (rc_intersect(&desk,&work))
	{
		reg GRECT dest;

		dest.g_x = dx;
		dest.g_y = dy;
		dest.g_w = work.g_w;
		dest.g_h = work.g_h;
		
		if (rc_intersect(&desk,&dest))
		{
			reg int pxy[8];

			rc_grect_to_array(&work,pxy);
			rc_grect_to_array(&dest,pxy+4);
			vro_cpyfm(x_handle,mode,pxy,screen,screen);
		}
	}
}

void save_clipping(int *area)
{
	reg long *clip=(long *) clipping_area;

	*((long *) area)++ = *clip++;
	*((long *) area)++ = *clip++;
}

void restore_clipping(int *area)
{
	reg long *clip=(long *) clipping_area;

	vs_clip(x_handle,1,area);
	*clip++ = *((long *) area)++;
	*clip++ = *((long *) area)++;
}
