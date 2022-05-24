
/* XAcc-Spion (l„uft als Programm und als Accessory),
   (c) 1994 C. Grunenberg */

#include <e_gem.h>
#include <string.h>
#include <stdio.h>

#define MAX_LINE	512
#define MINSIZE		160
#define GADGETS		NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SMALLER

typedef struct
{
	int scan,shift,norm;
} KEY;

KEY scroll_keys[] = {
{SCANUP,PAGE_UP,LINE_UP},
{SCANDOWN,PAGE_DOWN,LINE_DOWN},
{SCANLEFT,PAGE_LEFT,LINE_LEFT},
{SCANRIGHT,PAGE_RIGHT,LINE_RIGHT},
{SCANHOME,WIN_END,WIN_START} };

SCROLL scroll;
WIN *window;

char *entry = "  XAccSearch",*title = "XAccSearch",info[64];
char *xacc_name = "XAccSearch",*av_name = "XACCLOOK";

XAcc *app[128];
int app_cnt;

char textline[MAX_LINE+128],xdsc[MAX_LINE];
char xacc_info[] = "  Name                 Ap-ID  Menu-ID    Version    Groups  Extended Features";
char xacc_sub[]  = " -----------------------------------------------------------------------------";
char xacc_out[] = "  %-20s%4d%8d%6d.%d ($%02x,%2d) %s  %s";
char xacc_groups[] = "av____";

int make_info(XAcc *xacc)
{
	reg char c,*name = (xacc->xname!=NULL) ? xacc->xname : xacc->name,*p,*q;
	reg int version = xacc->version>>8,low = 0,high,i,bit;

	if (version>=0x30 && version<=0x39)
		high = version - 0x30;
	else if (version>=0x10)
	{
		high = version>>4;
		low = version & 0xf;
	}
	else
		high = version;

	p = xacc_groups;
	*p++ = (xacc->flag & AV) ? 'A' : '_';
	*p++ = (xacc->flag & XACC) ? 'X' : '_';
	for (i=4,bit=(1<<3);--i>=0;bit>>=1)
		*p++ = (xacc->version & bit) ? i+'1' : '_';

	p = xdsc;
	if ((q=xacc->xdsc)!=NULL)
	{
		for (;;)
		{
			q++;
			while ((c=*q++)!='\0')
				*p++ = c;
			if (*q)
				*p++ = ' ';
			else
				break;
		}
	}
	*p = '\0';

	return (sprintf(textline,xacc_out,name,xacc->id,xacc->menu_id,high,low,version,version,xacc_groups,xdsc));
}

void Draw(WIN *win,GRECT *area)
{
	reg SCROLL *sc = win->scroll;
	reg XAcc **xacc_lst;
	reg char c,*text;
	reg int char_cnt,x,y = win->work.g_y,d_x = 120*gr_cw;
	int start_line,lines;

	v_set_mode(MD_XOR);
	v_set_text(ibm_font_id,ibm_font,BLACK,NULL);
	rc_sc_clear(area);

	start_line = (area->g_y - y)/gr_ch;
	y += start_line*gr_ch;
	start_line += sc->vpos;
	xacc_lst = &app[max(start_line-3,0)];

	lines = min((area->g_y - y + area->g_h + gr_ch - 1)/gr_ch,scroll.vsize-start_line);
	for (;--lines>=0;y+=gr_ch,start_line++)
	{
		switch (start_line)
		{
		case 0:
			continue;
		case 1:
			text = xacc_info;
			char_cnt = (int) sizeof(xacc_info);
			break;
		case 2:
			text = xacc_sub;
			char_cnt = (int) sizeof(xacc_sub);
			break;
		default:
			text = textline;
			char_cnt = make_info(*xacc_lst++);
		}

		x = win->work.g_x;
		text += sc->hpos;
		char_cnt -= sc->hpos;

		while (char_cnt>0)
		{
			text += 120;
			c = *text;
			*text = '\0';
			v_gtext(x_handle,x,y,text-120);
			*text = c;

			char_cnt -= 120;
			x += d_x;
		}
	}
}

void error(int icon,char *msg)
{
	xalert(1,1,icon,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,msg,"[Got it!");
}

void SetWindow(void)
{
	scroll.hsize = MAX_LINE;
	scroll.vsize = app_cnt+3;
	scroll.px_hline = gr_cw;
	scroll.px_vline = gr_ch;
	scroll.hscroll = scroll.vscroll = 1;

	if (app_cnt)
		sprintf(info," %d XAcc-/AV-Applikation(en) gefunden.",app_cnt);
	else
		strcpy(info," Keine XAcc-/AV-Applikationen.");
}

void CloseWindow(void)
{
	if (window)
	{
		close_window(window,FALSE);
		window = NULL;
		if (!_app)
			MouseArrow();
	}

	if (_app)
		exit_gem(0);
}

void OpenWindow(void)
{
	SetWindow();
	window = open_window(title,NULL,info,NULL,GADGETS,FALSE,MINSIZE,MINSIZE,NULL,&desk,&scroll,Draw);
	if (window==NULL)
	{
		error(X_ICN_ALERT,"No more windows available!");
		CloseWindow();
	}
	else
		window_set_mouse(window,TEXT_CRSR,ARROW,NULL,NULL);
}

int InitEvent(XEVENT *ev,int avail)
{
	int flags = MU_MESAG|MU_KEYBD;

	if (window)
	{
		if (window->inside>=0 && (avail & MU_M1))
		{
			ev->ev_mm1flags = window->inside;
			*(GRECT *) &ev->ev_mm1x = window->work;
			flags |= MU_M1;
		}
	}

	return (flags & avail);
}

int Event(XEVENT *ev)
{
	int *msg,wich = ev->ev_mwich,scan,state,used=0,i,k;
	KEY *keys;

	if (wich & MU_M1)
	{
		window_mouse(window);
		used |= MU_M1;
	}

	if (wich & MU_MESAG)
	{
		msg = ev->ev_mmgpbuf;
		used |= MU_MESAG;

		switch (msg[0])
		{
		case AC_OPEN:
			OpenWindow();
			break;
		case AC_CLOSE:
		case AP_TERM:
		case WM_CLOSED:
			CloseWindow();
			break;
		case WM_TOPPED:
			window_top(window);
			break;
		case WM_BOTTOMED:
			window_bottom(window);
			break;
		case WM_FULLED:
			*(GRECT *) &msg[4] = (window->fulled) ? window->prev : window->max;
		case WM_SIZED:
		case WM_MOVED:
			window_size(window,(GRECT *) &msg[4]);
			break;
		case XACC_AV_INIT:
		case XACC_AV_EXIT:
			app_cnt = 0;
			i = 1;
			while ((app[app_cnt++]=find_app(i))!=NULL)
				i = 0;
			app_cnt--;
			SetWindow();
			if (window)
				window_reinit(window,title,NULL,info,FALSE);
			break;
		default:
			used &= ~MU_MESAG;
		}
	}

	if ((wich & MU_KEYBD) && window!=NULL)
	{
		k = scan_2_ascii(scan=ev->ev_mkreturn,state=ev->ev_mmokstate);
		if (state & K_CTRL)
		{
			if (k=='Q')
			{
				used |= MU_KEYBD;
				CloseWindow();
			}
		}
		else
			for (keys=&scroll_keys[0],i=0,scan>>=8;i<sizeof(scroll_keys);i++,keys++)
				if (keys->scan==scan)
				{
					scroll_window(window,(state & (K_RSHIFT|K_LSHIFT)) ? keys->shift : keys->norm,NULL);
					used |= MU_KEYBD;
					break;
				}
	}

	return (used);
}

void main(void)
{
	if (init_gem(entry,xacc_name,av_name,0,0,0)==TRUE)
	{
		scroll.scroll = TRUE;

		Event_Handler(InitEvent,Event);
		if (_app)
		{
			Event_Timer(500,0);
			OpenWindow();
		}
		Event_Multi(NULL);
	}
}
