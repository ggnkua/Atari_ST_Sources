
/* Hello! (PRG): einfaches 'Hello world'-Beispiel (u.a. Demonstration der Mausverwaltung) */

#include <e_gem.h>

#define GADGETS	NAME|CLOSER|MOVER

char *text="Hello f„ns! Hir ei „m!";

void Draw(int first,WIN *win,GRECT *rect)
{
	rc_sc_clear(rect);
	v_gtext(x_handle,win->work.g_x+gr_cw,win->work.g_y+((win->work.g_h-gr_ch)>>1),text);
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
		exit_gem(TRUE,0);
	}
	return(0);
}

void main()
{
	if (init_gem(NULL,NULL,"Hello","HELLO",0,0,0)==TRUE)
	{
		WIN *w;
		GRECT curr;
		int x,y;

		mouse(&x,&y);
		window_border(GADGETS,x,y,gr_cw*24,gr_ch*2,&curr);
		if ((w=open_window("Hello",NULL,NULL,NULL,GADGETS,FALSE,0,0,NULL,&curr,NULL,Draw,NULL,XM_TOP|XM_BOTTOM|XM_SIZE))!=NULL)
		{
			window_set_mouse(w,TEXT_CRSR,TEXT_CRSR,ARROW,FLAT_HAND,NULL,NULL,NULL,NULL);
			v_set_mode(MD_REPLACE);
			v_set_text(ibm_font_id,ibm_font,BLACK,0,0,NULL);
			Event_Handler(Init,Event);
			Event_Multi(NULL);
		}
	}
	exit_gem(TRUE,-1);
}
