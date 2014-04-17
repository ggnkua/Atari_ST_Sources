/*    APSKEL2.C				2/7/91			D.Mui	*/

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"

/*********************************************************************/
/* DEFINES						   	     */
/*********************************************************************/

#define TRUE	1
#define FALSE	0

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

int 	phys_handle;	/* physical workstation handle 	*/
int 	v_handle;	/* virtual workstation handle 	*/
int	wi_handle;	/* window handle 		*/

			/* desktop and work areas 	*/
int	xwork,ywork,hwork,wwork;	

int	msgbuff[8];	/* event message buffer */

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];	/* storage wasted for idiotic bindings */

int 	work_in[11];	/* Input to GSX parameter array */
int 	work_out[57];	/* Output from GSX parameter array */
int 	pxyarray[10];	/* input point array */


/****************************************************************/
/* open virtual workstation					*/
/****************************************************************/

open_vwork()
{
	int i;

	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	v_handle = phys_handle;
	v_opnvwk( work_in, &v_handle, work_out );
}

/****************************************************************/
/* set clipping rectangle					*/
/****************************************************************/

set_clip( x, y, w, h )
	int x,y,w,h;
{
	int clip[4];

	clip[0]=x;
	clip[1]=y;
	clip[2]=x+w-1;
	clip[3]=y+h-1;
	vs_clip( v_handle,1,clip);
}

/****************************************************************/
/* open window							*/
/****************************************************************/

open_window( kind )
	int	kind;
{
	wi_handle=wind_create( kind,xwork,ywork,wwork,hwork);
	wind_set(wi_handle, WF_NAME,"window",0,0);
	graf_growbox(xwork+wwork/2,ywork+hwork/2,gl_wbox,gl_hbox,xwork,ywork,wwork,hwork);
	wind_open(wi_handle,xwork,ywork,wwork,hwork);
	wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
}


/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/

do_redraw(xc,yc,wc,hc)
	int xc,yc,wc,hc;
{
	GRECT t1,t2;

	graf_mouse( M_OFF, 0x0L );
	wind_update( TRUE );
	t2.g_x = xc;
	t2.g_y = yc;
	t2.g_w = wc;
	t2.g_h = hc;
	wind_get( wi_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h );
	while (t1.g_w && t1.g_h) {
	  if (rc_intersect(&t2,&t1)) {
	    set_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
	    draw_sample();
	  }
	  wind_get(wi_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	}

	wind_update( FALSE );
	graf_mouse( M_ON, 0x0L );
}


/****************************************************************/
/*		Accessory Init. Until First Event_Multi		*/
/****************************************************************/

main()
{
	int	mx,my,but,kstate;
	int	value1,value2,element;
	OBJECT	*obj;

	appl_init();
	phys_handle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	wind_get(0, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
	open_vwork();
	if ( !v_handle )
	{	
	  form_alert( 1, "[1][ Failed to open work station ][ OK ]" );
	  goto end;
	}

	if ( !rsrc_load( "WMCALC" ) )
	  goto e1;

	rsrc_gaddr( 0, 1, &obj );
	graf_mouse( ARROW,0x0L );

	do
	{
	  objc_draw( obj, 0, 8, 0, 0, 1000, 1000 );		  	
          open_window( element );
	  multi();
          wind_close( wi_handle );
          wind_delete( wi_handle );
	}while(1);

e_1:	
        v_clsvwk( v_handle);
end:
        appl_exit( );
}


/****************************************************************/
/* Events handler						*/
/****************************************************************/

	
multi()
{
	int event,cont,fulled,ret,keycode,mx,my;

	cont = TRUE;
	fulled = FALSE;

      	do {
	     event = evnt_multi( MU_MESAG,
			1,1,1,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuff,0,0,&mx,&my,&ret,&ret,&keycode,&ret);

	wind_update(TRUE);

	if ( event & MU_MESAG )
	{
	  switch (msgbuff[0]) 
 	  {
	    case AC_CLOSE:
	      wind_close( wi_handle );
	      break;

	    case AC_OPEN:
              open_window( MOVER|FULLER|CLOSER|NAME|SIZER );
	      break;
	
	    case WM_CLOSED:
	      cont = FALSE;
	      break;
	
	    case WM_REDRAW:
		form_alert( 1, "[1][ Redraw ][ OK ]" );
	      do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
	      break;

	    case WM_NEWTOP:
	    case WM_TOPPED:
	      wind_set(wi_handle,WF_TOP,0,0,0,0);
	      break;

	    case WM_SIZED:
	    case WM_MOVED:
	      wind_set(wi_handle,WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
	      wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	      break;

	    case WM_FULLED:
	      if ( fulled )
	      {
		wind_get(wi_handle,WF_PREVXYWH,&xwork,&ywork,&wwork,&hwork);
		wind_set(wi_handle,WF_CURRXYWH,xwork,ywork,wwork,hwork);
		wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	      }
	      else
	      {
		wind_get(wi_handle,WF_FULLXYWH,&xwork,&ywork,&wwork,&hwork);
		wind_set(wi_handle,WF_CURRXYWH,xwork,ywork,wwork,hwork);
		wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	      }

	      fulled ^= TRUE;
	      break;
	      
	   } /* switch (msgbuff[0]) */
	}

	wind_update( FALSE );

      }while( cont );
}


/****************************************************************/
/* Draw Filled Ellipse.						*/
/****************************************************************/

draw_sample()
{
int temp[4];

	vsf_interior( v_handle,2 );
	vsf_style( v_handle,8 );
	vsf_color( v_handle,0 );
	temp[0]=xwork;
	temp[1]=ywork;
	temp[2]=xwork+wwork-1;
	temp[3]=ywork+hwork-1;
	v_bar( v_handle,temp );		/* blank the interior */
	vsf_interior( v_handle,4 );
	vsf_color( v_handle,1 );
	v_ellipse( v_handle,xwork+wwork/2,ywork+hwork/2,wwork/2,hwork/2);
}
