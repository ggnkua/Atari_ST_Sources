
/* einfaches "Hello world!"-Beispielprogramm, l„uft nur als Programm */

#include <e_gem.h>
#include <string.h>

#define GADGETS	NAME|CLOSER|FULLER|MOVER|SIZER|SMALLER

WIN *win;
char text[] = "Hello f„ns! Hir ei „m!";

void Draw(WIN *win,GRECT *rect)
{
	rc_sc_clear(rect);
	v_gtext(x_handle,win->work.g_x+gr_cw,win->work.g_y+gr_ch,text);
}

int Init(XEVENT *event,int available)
{
	return((MU_MESAG|MU_KEYBD) & available);
}

int Event(XEVENT *event)
{
	int *msg = event->ev_mmgpbuf,wich = event->ev_mwich;

	if ((wich & MU_KEYBD) && (event->ev_mmokstate & K_CTRL) && scan_2_ascii(event->ev_mkreturn,K_CTRL)=='Q')
		exit_gem(0);

	if (wich & MU_MESAG)
	{
		switch (msg[0])
		{
		case AP_TERM:
		case WM_CLOSED:
			exit_gem(0);
			break;
		case WM_TOPPED:
			window_top(win);
			break;
		case WM_BOTTOMED:
			window_bottom(win);
			break;
		case WM_FULLED:
			*(GRECT *) &msg[4] = win->fulled ? win->prev : win->max;
		case WM_SIZED:
		case WM_MOVED:
			window_size(win,(GRECT *) &msg[4]);
			break;
		default:
			return(0);
		}
	}

	return (MU_MESAG & wich);
}

void main(void)
{
	GRECT curr;
	int x,y,d;
	if (init_gem(NULL,"Hello!","HELLO",0,0,0)==TRUE)
	{
		graf_mkstate(&x,&y,&d,&d);
		window_border(GADGETS,x,y,gr_cw*((int) sizeof(text)+1),gr_ch*3,&curr);
		if ((win=open_window("Hello!",NULL,NULL,NULL,GADGETS,FALSE,0,0,NULL,&curr,NULL,Draw))!=NULL)
		{
			v_set_mode(MD_REPLACE);
			v_set_text(ibm_font_id,ibm_font,BLACK,NULL);
			Event_Handler(Init,Event);
			Event_Multi(NULL);
		}
	}
	exit_gem(-1);
}
