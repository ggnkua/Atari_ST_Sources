
/* Sample (PRG): Grafik wird an Fenstergr”že angepažt */

#include <e_gem.h>

#define GADGETS	NAME|CLOSER|FULLER|SIZER|MOVER

WIN *win;

void Draw(int first,WIN *win,GRECT *rect)
{
	int pxy[4];
	rc_sc_clear(rect);
	rc_grect_to_array(&win->work,pxy);
	v_line(pxy[0],pxy[1],pxy[2],pxy[3]);
	v_line(pxy[0],pxy[3],pxy[2],pxy[1]);
}

int Init(XEVENT *ev,int av)
{
	return(MU_MESAG);
}

int Event(XEVENT *ev)
{
	switch (ev->ev_mmgpbuf[0])
	{
	case AP_TERM:
	case WM_CLOSED:
		exit_gem(TRUE,0);break;
	case WIN_SIZED:
		redraw_window(win,NULL);break;
	default:
		return(0);
	}
	return(MU_MESAG);
}

void main()
{
	if (init_gem(NULL,NULL,"Sample","SAMPLE",0,0,0)==TRUE)
	{
		GRECT curr;
		window_border(GADGETS,0,0,desk.g_w>>1,desk.g_h>>1,&curr);
		if ((win=open_window("Sample",NULL,NULL,NULL,GADGETS,FALSE,0,0,NULL,&curr,NULL,Draw,NULL,XM_TOP|XM_BOTTOM|XM_SIZE))!=NULL)
		{
			v_set_mode(MD_TRANS);
			v_set_line(RED,1,0,1,1);
			Event_Handler(Init,Event);
			Event_Multi(NULL);
		}
	}
	exit_gem(TRUE,-1);
}
