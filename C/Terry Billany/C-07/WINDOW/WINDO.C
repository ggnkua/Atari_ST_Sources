/*----------------------------*/
/* windows demo 	      */
/* ST Application Programming */
/*----------------------------*/

#include <gem.h>
#include <stdio.h>
#include <obdefs.h>
#include <osbind.h>

#include "window.h"

#define MAX_WINDOW 4

int p_handle,
    v_handle,
    scrn_rez,	 
    col_scrn,
    y_max,
    x_max;

#define WMIN_WIDTH  (2*gr_wbox)
#define WMIN_HEIGHT (3*gr_hbox)

int	ap_id;

int	gr_hchar;
int	gr_wchar;
int	gr_wbox;
int	gr_hbox;	/* system sizes */

int	num_windows, cur_window;
int	wind1, wind2, wind3, wind4;
int	xdesk, ydesk, hdesk, wdesk;

int	m_hidden = FALSE;		/* current state of cursor */

typedef struct wind_type {
	int handle;
	int type;
	int visible;
	int fullsize;
} WINDOW;
WINDOW windows[MAX_WINDOW];
WINDOW desktop;

/*----------------------------------------------*/
open_vwork(phys_handle)
/*----------------------------------------------*/
int phys_handle;
{
int work_in[11],
    work_out[57],
    new_handle;
int i;

    for(i=0;i<10;i++)
	 work_in[i]=1;
    work_in[10]=2;
    new_handle=phys_handle;
    v_opnvwk(work_in,&new_handle,work_out);
/*  v_clrwk(new_handle);   */
    return(new_handle);
}
/*----------------------------------------------*/
set_scrn_attr()
/*----------------------------------------------*/
{
int work_out[57];

    vq_extnd(v_handle,0,work_out);
    x_max=work_out[0];
    y_max=work_out[1];
    scrn_rez=Getrez();
    col_scrn=(scrn_rez < 2);
}
/*----------------------------------------------*/
hide_mouse()
/*----------------------------------------------*/
{
	if(! m_hidden){
		graf_mouse(M_OFF,0x0L);
		m_hidden=TRUE;
	}
}
/*----------------------------------------------*/
show_mouse()
/*----------------------------------------------*/
{
	if(m_hidden){
		graf_mouse(M_ON,0x0L);
		m_hidden=FALSE;
	}
}
/*----------------------------------------------*/
load_resource(rfile) char *rfile;
/*----------------------------------------------*/
{
char temp[128];
	if (!rsrc_load(rfile))
	{
		sprintf(temp,"[0][load %s failed|Ending...][OK]",rfile);
		form_alert(1, temp);
		return(FALSE);
	}
	return(TRUE);
}
/*----------------------------------------------*/
do_dialog(box_index) int box_index;
/*----------------------------------------------*/
{
int xbox, ybox, hbox, wbox;
int smallx, smally, smallw, smallh;
int exit_object;
OBJECT *box_addr;

	rsrc_gaddr(0, box_index, &box_addr);

	form_center(box_addr, &xbox, &ybox, &wbox, &hbox);
	smallx = xbox + (wbox/2);
	smally = ybox + (hbox/2);
	smallw = 0;
	smallh = 0;

	form_dial(FMD_START,
		smallx, smally, smallw, smallh, 	
		xbox, ybox, wbox, hbox);
	form_dial(FMD_GROW,
		smallx, smally, smallw, smallh, 	
		xbox, ybox, wbox, hbox);

	objc_draw(box_addr, 0, 10, xbox, ybox, wbox, hbox);
	exit_object = form_do(box_addr, 0);

	form_dial(FMD_SHRINK,
		smallx, smally, smallw, smallh, 	
		xbox, ybox, wbox, hbox);
	form_dial(FMD_FINISH,
		smallx, smally, smallw, smallh, 	
		xbox, ybox, wbox, hbox);

	box_addr[exit_object].ob_state = NORMAL;
	return(exit_object);
}
/*----------------------------------------------*/
set_clip(x,y,w,h)
/*----------------------------------------------*/
int x,y,w,h;
{
int clip[4];
	clip[0]=x;
	clip[1]=y;
	clip[2]=x+w-1;
	clip[3]=y+h-1;
	vs_clip(v_handle,TRUE,clip);
}
/*----------------------------------------------*/
init_windows()
/*----------------------------------------------*/
{
int i;
	num_windows = 0;
	for (i=0; i < MAX_WINDOW; i++)
		windows[i].handle = -1;
	desktop.handle=0;
	wind_get(desktop.handle,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
}

/*----------------------------------------------*/
create_window(newkind, wtitle)	int newkind; char *wtitle;
/*----------------------------------------------*/
{
int new;
	if (num_windows >= MAX_WINDOW)
	{
		form_alert(1, "[0][Too many windows #1][OK]");
		return(-1);
	}

	for (new=0; new < MAX_WINDOW; new++)
		if (windows[new].handle <0 )
			break;
	if (new >= MAX_WINDOW)
	{
		form_alert(1, "[0][Too many windows #2][OK]");
		return(-1);
	}

	windows[new].handle =
		wind_create(newkind,xdesk,ydesk,wdesk,hdesk);
	if (windows[new].handle <0 )
	{
		form_alert(1, "[0][wind_create fails][OK]");
		return(-1);
	}

	windows[new].type = newkind;
	windows[new].fullsize = FALSE;
	windows[new].visible = FALSE;

	wind_set(windows[new].handle, WF_NAME, wtitle, 0, 0);
	num_windows++;
}
/*----------------------------------------------*/
open_window(wi_index)
/*----------------------------------------------*/
{
int xsize, ysize, wsize, hsize;

	if(windows[wi_index].visible)
		return;
	wind_get(windows[wi_index].handle, WF_PREVXYWH,
			&xsize, &ysize, &wsize, &hsize);
	if ( !(xsize || ysize || wsize || hsize) )
	{
		xsize = xdesk;
		ysize = ydesk;
		wsize = wdesk;
		hsize = hdesk;
	}
	hide_mouse();
/*	graf_growbox(xsize+wsize/2, ysize+hsize/2,
		gr_wbox, gr_hbox, xsize, ysize, wsize, hsize);
*/	wind_open(windows[wi_index].handle, xsize, ysize, wsize, hsize);
	windows[wi_index].visible = TRUE;
	show_mouse();	
}
/*----------------------------------------------*/
close_window(wi_index)
/*----------------------------------------------*/
{
int xsize, ysize, wsize, hsize;

	if(!windows[wi_index].visible)
		return;

	wind_get(windows[wi_index].handle, WF_CURRXYWH,
			&xsize, &ysize, &wsize, &hsize);

	hide_mouse();
	wind_close(windows[wi_index].handle);
/*	graf_shrinkbox(xsize+wsize/2, ysize+hsize/2,
		gr_wbox, gr_hbox, xsize, ysize, wsize, hsize);
*/	windows[wi_index].visible = FALSE;
	show_mouse();	
}
/*----------------------------------------------*/
del_window(wi_index)
/*----------------------------------------------*/
{
	if(windows[wi_index].visible)
		close_window(wi_index);

	wind_delete(windows[wi_index].handle);
	windows[wi_index].handle = -1;
	num_windows--;
}
/*----------------------------------------------*/
find_window(wi_handle)
/*----------------------------------------------*/
{
int i;
	for (i=0; i < MAX_WINDOW; i++)
		if(windows[i].handle == wi_handle)
			return(i);
	return(-1);
}
/*----------------------------------------------*/
do_redraw(wi_index, wi_redraw, xc, yc, wc, hc)
/*----------------------------------------------*/
int wi_index, (*wi_redraw)(), xc, yc, wc, hc;
{
GRECT redraw, clip;

	hide_mouse();
	wind_update(TRUE);
	redraw.g_x=xc;
	redraw.g_y=yc;
	redraw.g_w=wc;
	redraw.g_h=hc;
	wind_get(windows[wi_index].handle,WF_FIRSTXYWH,
		    &clip.g_x,&clip.g_y,&clip.g_w,&clip.g_h);

	while (clip.g_w && clip.g_h) {
	    if (rc_intersect(&redraw, &clip)) {
		     set_clip(clip.g_x,clip.g_y,clip.g_w,clip.g_h);
		     (*wi_redraw)();
	      }
	    wind_get(windows[wi_index].handle, WF_NEXTXYWH,
		       &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
	}
	wind_update(FALSE);
	show_mouse();
}
/*---------------------------------------------*/
draw_function()
/*---------------------------------------------*/
{
int temp[4];
int xwork, ywork, wwork, hwork;
	wind_get(windows[cur_window].handle, WF_WORKXYWH,
			&xwork, &ywork, &wwork, &hwork);
	vsf_interior(v_handle,2);
	vsf_style(v_handle,8);
	vsf_color(v_handle,2);
	temp[0] = xwork;
	temp[1] = ywork;
	temp[2] = temp[0] + wwork - 1;
	temp[3] = temp[1] + hwork - 1;
	v_bar(v_handle, temp);

	if (cur_window == wind1)
	    vsf_style(v_handle, 9);
	else if (cur_window == wind2)
	    vsf_style(v_handle, 10);
	if (cur_window == wind3)
	    vsf_style(v_handle, 11);
	if (cur_window == wind4)
	    vsf_style(v_handle, 12);
	vsf_color(v_handle, 1);
	v_ellipse(v_handle, xwork+wwork/2, ywork+hwork/2,
		   wwork/2, hwork/2);
}
/*----------------------------------------------*/
control()
/*----------------------------------------------*/
{
OBJECT *menu_addr;
int	end_prog = FALSE;
int	mevx,mevy,
	butstate,
	mevbut,
	keystate,
	keycode,
	mbreturn,
	msg_buf[8],
	event,
	menu_index;
int	draw_function();
int x, y, w, h;

	wind1 = -1;
	wind2 = -1;
	wind3 = -1;
	wind4 = -1;

	rsrc_gaddr(0, MAINMENU, &menu_addr);
	menu_bar(menu_addr, TRUE);
	butstate = TRUE;

	do
	{
	event = evnt_multi(MU_MESAG | MU_BUTTON | MU_KEYBD,
			0, 0, butstate,
			0,0,0,0,0,
			0,0,0,0,0,
			msg_buf, 0, 0,
			&mevx ,&mevy, &mevbut,
			&keystate, &keycode, &mbreturn);

	wind_update(TRUE);

	if (event & MU_MESAG)
	{
	  switch (msg_buf[0])
	  {
	  case MN_SELECTED:
	    switch(msg_buf[4])
		{
		case QUIT:
			end_prog = TRUE;
			break;
		case INFOITEM:
			do_dialog(INFOBOX);
			break;

		case WIND1:
			if (wind1 < 0)
			{
				wind1 = create_window(
							(NAME|CLOSER|FULLER|MOVER|SIZER),
							" Window 1 ");
				if (wind1 < 0)
				{
					end_prog = TRUE;
					break;
				}
			}
			if (windows[wind1].visible)
			{
				close_window(wind1);
				menu_text(menu_addr, WIND1, "  Open Window #1");
			}
			else
			{
				open_window(wind1);
				menu_text(menu_addr, WIND1, "  Close Window 1");
			}
			break;
		case WIND2:
			if (wind2 < 0)
			{
				wind2 = create_window(
							(NAME|CLOSER|FULLER|MOVER|SIZER),
							" Window 2 ");
				if (wind2 < 0)
				{
					end_prog = TRUE;
					break;
				}
			}
			if (windows[wind2].visible)
			{
				close_window(wind2);
				menu_text(menu_addr, WIND2, "  Open Window #2");
			}
			else
			{
				open_window(wind2);
				menu_text(menu_addr, WIND2, "  Close Window 2");
			}
			break;
		case WIND3:
			if (wind3 < 0)
			{
				wind3 = create_window(
							(NAME|CLOSER|FULLER|MOVER|SIZER),
							" Window 3 ");
				if (wind3 < 0)
				{
					end_prog = TRUE;
					break;
				}
			}
			if (windows[wind3].visible)
			{
				close_window(wind3);
				menu_text(menu_addr, WIND3, "  Open Window #3");
			}
			else
			{
				open_window(wind3);
				menu_text(menu_addr, WIND3, "  Close Window 3");
			}
			break;
		case WIND4:
			if (wind4 < 0)
			{
				wind4 = create_window(
								(NAME|CLOSER|FULLER|MOVER|SIZER),
							" Window 4 ");
				if (wind4 < 0)
				{
					end_prog = TRUE;
					break;
				}
			}
			if (windows[wind4].visible)
			{
				close_window(wind4);
				menu_text(menu_addr, WIND4, "  Open Window #4");
			}
			else
			{
				open_window(wind4);
				menu_text(menu_addr, WIND4, "  Close Window 4");
			}
			break;

		default:
			break;
		}
		menu_tnormal(menu_addr, msg_buf[3], 1);
		menu_bar(menu_addr,TRUE);
		break;


	case WM_REDRAW:
	    if ( (cur_window = find_window(msg_buf[3])) < 0)
			break;
		do_redraw(cur_window, draw_function,
			msg_buf[4], msg_buf[5], msg_buf[6], msg_buf[7]);
	    break;

	case WM_NEWTOP:
	case WM_TOPPED:
	    if ( (cur_window = find_window(msg_buf[3])) < 0)
			break;
    	wind_set(windows[cur_window].handle,WF_TOP,0,0,0,0);
	    break;

	case WM_CLOSED:
	    if ( (cur_window = find_window(msg_buf[3])) < 0)
			break;
    	close_window(cur_window);
		if (cur_window == wind1)
			menu_text(menu_addr, WIND1, "  Open Window #1");
		else if (cur_window == wind2)
			menu_text(menu_addr, WIND2, "  Open Window #2");
		else if (cur_window == wind3)
			menu_text(menu_addr, WIND3, "  Open Window #3");
		else if (cur_window == wind4)
			menu_text(menu_addr, WIND4, "  Open Window #4");
	    break;

	case WM_SIZED:
	case WM_MOVED:
	    if ( (cur_window = find_window(msg_buf[3])) < 0)
			break;
	    if (msg_buf[6] < WMIN_WIDTH)
			msg_buf[6] = WMIN_WIDTH;
	    if (msg_buf[7] < WMIN_HEIGHT)
			msg_buf[7] = WMIN_HEIGHT;
	    wind_set(windows[cur_window].handle, WF_CURRXYWH,
			msg_buf[4], msg_buf[5], msg_buf[6], msg_buf[7]);
	    wind_get(windows[cur_window].handle, WF_PREVXYWH,
			&x, &y, &w, &h);
/* there's a GEM bug that no redraw is requested if window size reduced */
	    if ((msg_buf[6] <= w)&&(msg_buf[7] <= h))
	    {
		wind_get(windows[cur_window].handle, WF_WORKXYWH,
			&x, &y, &w, &h);
		msg_buf[0] = WM_REDRAW;
		msg_buf[3] = windows[cur_window].handle;
		msg_buf[4] = x;
		msg_buf[5] = y;
		msg_buf[6] = w;
		msg_buf[7] = h;
		appl_write(ap_id, 16, msg_buf);
	    }
	    break;

	case WM_FULLED:
	    if ( (cur_window = find_window(msg_buf[3])) < 0)
			break;
	    if (windows[cur_window].fullsize)
		{
		    wind_get(windows[cur_window].handle, WF_PREVXYWH,
					&x, &y, &w, &h);
		    wind_set(windows[cur_window].handle, WF_CURRXYWH,
					x, y, w, h);
		}
	    else
		{
		    wind_get(windows[cur_window].handle, WF_FULLXYWH,
					&x, &y, &w, &h);
		    wind_set(windows[cur_window].handle, WF_CURRXYWH,
					x, y, w, h);
	    }
		windows[cur_window].fullsize ^= TRUE;
	    break;

	default:
		break;
	} /* switch (msgbuff[0]) */
	}

	if (event & MU_BUTTON)
		butstate = !(butstate);

	if (event & MU_KEYBD)
	{
		switch(keycode)
		{
		default:
			break;
		}
		menu_tnormal(menu_addr, menu_index, 1);
	}			

	if (end_prog)
	{
		int i;
		for (i=0; i < MAX_WINDOW; i++)
			if (windows[i].handle >= 0)
				del_window(i);
	}
	wind_update(FALSE);			
	}
	while (!end_prog);
}
/*---------------------------------------------*/
main()
{
int ap_id;

	ap_id = appl_init();
	if (ap_id < 0)
	{
		Cconws("*** initialisation error ***\n");
		Cconws("*** press any key....... ***\n");
		Crawcin();
		exit(-1);
	}
	p_handle =
	  graf_handle(&gr_wchar, &gr_hchar, &gr_wbox, &gr_hbox);
	v_handle = open_vwork(p_handle);
	set_scrn_attr();
	graf_mouse(ARROW, -1l);

	if (!load_resource("window.rsc"))
		exit(1);

	init_windows();
	control();

	rsrc_free();
	v_clsvwk(v_handle);
	appl_exit();
}
