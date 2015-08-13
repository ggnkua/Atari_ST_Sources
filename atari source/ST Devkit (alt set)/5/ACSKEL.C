/*********************************************************************/
/* SAMPLE ACCESSORY SKELETON 					     */
/*	started 5/28/85 R.Z.   Copyright ATARI Corp. 1985	     */
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES						     */
/*********************************************************************/

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"

/*********************************************************************/
/* DEFINES						   	     */
/*********************************************************************/

#define WI_KIND		(SIZER|MOVER|FULLER|CLOSER|NAME)

#define NO_WINDOW (-1)

#define MIN_WIDTH  (2*gl_wbox)
#define MIN_HEIGHT (3*gl_hbox)

/*********************************************************************/
/* EXTERNALS						   	     */
/*********************************************************************/

extern int	gl_apid;

/*********************************************************************/
/* GLOBAL VARIABLES					   	     */
/*********************************************************************/

int	gl_hchar;
int	gl_wchar;
int	gl_wbox;
int	gl_hbox;	/* system sizes */

int	menu_id ;	/* our menu id */

int 	phys_handle;	/* physical workstation handle */
int 	handle;		/* virtual workstation handle */
int	wi_handle;	/* window handle */
int	top_window;	/* handle of topped window */

int	xdesk,ydesk,hdesk,wdesk;
int	xold,yold,hold,wold;
int	xwork,ywork,hwork,wwork;	/* desktop and work areas */

int	msgbuff[8];	/* event message buffer */
int	keycode;	/* keycode returned by event-keyboard */
int	mx,my;		/* mouse x and y pos. */
int	butdown;	/* button state tested for, UP/DOWN */
int	ret;		/* dummy return variable */

int	hidden;		/* current state of cursor */

int	fulled;		/* current state of window */

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];	/* storage wasted for idiotic bindings */

int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */

/****************************************************************/
/*  GSX UTILITY ROUTINES.					*/
/****************************************************************/

hide_mouse()
{
	if(! hidden){
		graf_mouse(M_OFF,0x0L);
		hidden=TRUE;
	}
}

show_mouse()
{
	if(hidden){
		graf_mouse(M_ON,0x0L);
		hidden=FALSE;
	}
}

/****************************************************************/
/* open virtual workstation					*/
/****************************************************************/
open_vwork()
{
int i;
	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
}

/****************************************************************/
/* set clipping rectangle					*/
/****************************************************************/
set_clip(x,y,w,h)
int x,y,w,h;
{
int clip[4];
	clip[0]=x;
	clip[1]=y;
	clip[2]=x+w;
	clip[3]=y+h;
	vs_clip(handle,1,clip);
}

/****************************************************************/
/* open window							*/
/****************************************************************/
open_window()
{
	wi_handle=wind_create(WI_KIND,xdesk,ydesk,wdesk,hdesk);
	wind_set(wi_handle, WF_NAME," IMA SAMPLE ",0,0);
	graf_growbox(xdesk+wdesk/2,ydesk+hdesk/2,gl_wbox,gl_hbox,xdesk,ydesk,wdesk,hdesk);
	wind_open(wi_handle,xdesk,ydesk,wdesk,hdesk);
	wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
}

/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/
do_redraw(xc,yc,wc,hc)
int xc,yc,wc,hc;
{
GRECT t1,t2;

	hide_mouse();
	wind_update(TRUE);
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	wind_get(wi_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h) {
	  if (rc_intersect(&t2,&t1)) {
	    set_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
	    draw_sample();
	  }
	  wind_get(wi_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	}
	wind_update(FALSE);
	show_mouse();
}

/****************************************************************/
/*		Accessory Init. Until First Event_Multi		*/
/****************************************************************/
main()
{
	appl_init();
	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	menu_id=menu_register(gl_apid,"  Sample Accessory");
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);

	wi_handle=NO_WINDOW;
	hidden=FALSE;
	fulled=FALSE;
	butdown=TRUE;

	multi();
}


/****************************************************************/
/* dispatches all accessory tasks				*/
/****************************************************************/
multi()
{
int event;

      while (TRUE) {
	event = evnt_multi(MU_MESAG | MU_BUTTON | MU_KEYBD,
			1,1,butdown,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuff,0,0,&mx,&my,&ret,&ret,&keycode,&ret);

	wind_update(TRUE);
	wind_get(wi_handle,WF_TOP,&top_window,&ret,&ret,&ret);

	if (event & MU_MESAG)
	  switch (msgbuff[0]) {

	  case WM_REDRAW:
	    if (msgbuff[3] == wi_handle)
	      do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
	    break;

	  case WM_NEWTOP:
	  case WM_TOPPED:
	    if (msgbuff[3] == wi_handle){
	      wind_set(wi_handle,WF_TOP,0,0,0,0);}
	    break;

	  case AC_CLOSE:
	    if((msgbuff[3] == menu_id)&&(wi_handle != NO_WINDOW)){
	      v_clsvwk(handle);
	      wi_handle = NO_WINDOW;
	    }
	    break;

	  case WM_CLOSED:
	    if(msgbuff[3] == wi_handle){
	      wind_close(wi_handle);
	      graf_shrinkbox(xwork+wwork/2,ywork+hwork/2,gl_wbox,gl_hbox,xwork,ywork,wwork,hwork);
	      wind_delete(wi_handle);
	      v_clsvwk(handle);
	      wi_handle = NO_WINDOW;
	    }
	    break;

	  case WM_SIZED:
	  case WM_MOVED:
	    if(msgbuff[3] == wi_handle){
		if(msgbuff[6]<MIN_WIDTH)msgbuff[6]=MIN_WIDTH;
		if(msgbuff[7]<MIN_HEIGHT)msgbuff[7]=MIN_HEIGHT;
		wind_set(wi_handle,WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
		wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	    }
	    break;

	  case AC_OPEN:
	    if (msgbuff[4] == menu_id){
	      if(wi_handle == NO_WINDOW){
		open_vwork();
	        open_window();
	      }
	      else	/* if already opened, for user convenience */
	        wind_set(wi_handle,WF_TOP,0,0,0,0);
	    }
	    break;

	  case WM_FULLED:
	    if(fulled){
		wind_calc(WC_WORK,WI_KIND,xold,yold,wold,hold,
				&xwork,&ywork,&wwork,&hwork);
		wind_set(wi_handle,WF_CURRXYWH,xold,yold,wold,hold);}
	    else{
		wind_calc(WC_BORDER,WI_KIND,xwork,ywork,wwork,hwork,
				&xold,&yold,&wold,&hold);
		wind_calc(WC_WORK,WI_KIND,xdesk,ydesk,wdesk,hdesk,
				&xwork,&ywork,&wwork,&hwork);
		wind_set(wi_handle,WF_CURRXYWH,xdesk,ydesk,wdesk,hdesk);
	    }
	    fulled ^= TRUE;
	    break;

	  } /* switch (msgbuff[0]) */

	if ((event & MU_BUTTON)&&(wi_handle == top_window))
	  if(butdown) butdown = FALSE;
	  else butdown = TRUE;

	  if(event & MU_KEYBD){
	     do_redraw(xwork,ywork,wwork,hwork);
	  }
	
	wind_update(FALSE);

      } /* while (TRUE) */

}

/****************************************************************/
/* Draw Filled Ellipse.						*/
/****************************************************************/
draw_sample()
{
int temp[4];
	vsf_interior(handle,2);
	vsf_style(handle,8);
	vsf_color(handle,0);
	temp[0]=xwork;
	temp[1]=ywork;
	temp[2]=xwork+wwork-1;
	temp[3]=ywork+hwork-1;
	v_bar(handle,temp);		/* blank the interior */
	vsf_interior(handle,4);
	vsf_color(handle,1);
	v_ellipse(handle,xwork+wwork/2,ywork+hwork/2,wwork/2,hwork/2);
}
