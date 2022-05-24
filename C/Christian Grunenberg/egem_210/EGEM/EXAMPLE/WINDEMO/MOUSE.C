
/* einfaches Beispielprogramm (zeigt st„ndig die Mauskoordinaten an),
   l„uft nur als Programm */

#include <e_gem.h>
#include <stdio.h>
#include <string.h>

#define GADGETS	NAME|CLOSER|MOVER|SMALLER

WIN *win;
char info[256];

int update;

void Draw(WIN *win,GRECT *rect)
{
	if (!update)
		rc_sc_clear(rect);
	v_gtext(x_handle,win->work.g_x+gr_cw,win->work.g_y+gr_ch,info);
}

int Init(XEVENT *event,int available)
{
	int flags = MU_MESAG|MU_KEYBD;

	if (win->inside>=0)
	{
		if (available & MU_M1)
		{
			event->ev_mm1flags = event->ev_mm1width = event->ev_mm1height = 1;
			event->ev_mm1x = event->ev_mmox;
			event->ev_mm1y = event->ev_mmoy;
			flags |= MU_M1;
		}

		if (available & MU_M2)
		{
			event->ev_mm2flags = win->inside;
			*(GRECT *) &event->ev_mm2x = win->work;
			flags |= MU_M2;
		}
	}

	return (flags & available);
}

int Event(XEVENT *event)
{
	int *msg = event->ev_mmgpbuf,wich = event->ev_mwich,used = 0;

	if (wich & MU_M1)
	{
		sprintf(info,"X: %3d, Y: %3d",event->ev_mmox,event->ev_mmoy);
		update++;
		redraw_window(win,NULL);
		update--;
		used |= MU_M1;
	}

	if (wich & MU_M2)
	{
		window_mouse(win);
		used |= MU_M2;
	}

	if ((wich & MU_KEYBD) && (event->ev_mmokstate & K_CTRL) && scan_2_ascii(event->ev_mkreturn,K_CTRL)=='Q')
		exit_gem(0);

	if (wich & MU_MESAG)
	{
		used |= MU_MESAG;
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
		case WM_MOVED:
			window_size(win,(GRECT *) &msg[4]);
			break;
		default:
			used &= ~MU_MESAG;
		}
	}

	return (used);
}

void main(void)
{
	GRECT curr;
	if (init_gem(NULL,"Mouse!","MOUSE",0,0,0)==TRUE)
	{
		window_border(GADGETS,0,0,gr_cw*16,gr_ch*3,&curr);
	 	if ((win=open_window("Mouse!",NULL,NULL,NULL,GADGETS,FALSE,0,0,NULL,&curr,NULL,Draw))!=NULL)
		{
			window_set_mouse(win,THIN_CROSS,ARROW,NULL,NULL);
			v_set_mode(MD_REPLACE);
			v_set_text(ibm_font_id,ibm_font,BLACK,NULL);
			Event_Handler(Init,Event);
			Event_Multi(NULL);
		}
	}
	exit_gem(-1);
}