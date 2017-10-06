
/* Mouse! (PRG): zeigt st„ndig die Mauskoordinaten im Fenster */

#include <e_gem.h>
#include <string.h>

#define GADGETS	NAME|CLOSER|MOVER

WIN *win;
char *info="X: 1234, Y: 1234";
int lx,ly;

void Draw(int first,WIN *win,GRECT *rect,GRECT *work,void *dummy)
{
	v_gtext(x_handle,work->g_x+8,work->g_y+((work->g_h-gr_sh)>>1),info);
}

void Redraw(int first,WIN *win,GRECT *rect)
{
	rc_sc_clear(rect);
	Draw(0,win,rect,&win->work,NULL);
}

long MouseTimer(long p,long t,MKSTATE *mk)
{
	if (lx!=mk->mx || ly!=mk->my)
	{
		int2str(info+3,lx=mk->mx,-4);
		int2str(info+12,ly=mk->my,-4);
		draw_window(win,NULL,NULL,MOUSE_TEST,Draw);
	}
	return(CONT_TIMER);
}

int Init(XEVENT *ev,int av)
{
	return(MU_MESAG);
}

int Event(XEVENT *ev)
{
	if (ev->ev_mwich & MU_MESAG)
		switch (ev->ev_mmgpbuf[0])
		{
		case AP_TERM:
		case WM_CLOSED:
			exit_gem(TRUE,0);
		}
	return(0);
}

void main()
{
	if (init_gem(NULL,NULL,"Mouse","MOUSE",0,0,0)==TRUE)
	{
		GRECT curr;
		window_border(GADGETS,0,0,gr_sw*16+16,gr_sh*2,&curr);
		if ((win=open_window("Mouse",NULL,NULL,NULL,GADGETS,FALSE,0,0,NULL,&curr,NULL,Redraw,NULL,XM_TOP|XM_BOTTOM|XM_SIZE))!=NULL)
		{
			window_set_mouse(win,THIN_CROSS,THIN_CROSS,ARROW,ARROW,NULL,NULL,NULL,NULL);
			v_set_mode(MD_REPLACE);
			v_set_text(small_font_id,small_font,BLACK,0,0,NULL);
			Event_Handler(Init,Event);
			NewTimer(50,0l,MouseTimer);
			Event_Multi(NULL);
		}
	}
	exit_gem(TRUE,-1);
}
