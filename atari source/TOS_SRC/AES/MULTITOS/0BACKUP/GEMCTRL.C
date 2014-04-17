/*	GEMCTRL.C	5/14/84 - 02/23/85	Lee Jay Lorenzen	*/
/*	pstart bugs,1.1	2/12/85 - 04/05/85	LKW			*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	Fix at hctl_window 05/11/85 - 10/21/85	Derek Mui		*/
/*	Fix the button semaphore at ctlmgr	2/27/86	 Derek Mui	*/
/*	Ctlmouse to control the mouse 		03/05/86 Derek Mui	*/
/*	Change at ctlmouse to save mouse form by using line a function,	*/
/*	take out tmpmaddr	1/7/87		Derek Mui		*/
/*	Smooth scrolling	2/4/87		Derek Mui		*/
/*	Change at ctlmgr for smooth scrolling	3/11/87	Derek Mui	*/
/*	Fix at ctlmouse of gsx_ncode		12/11/87	D.Mui	*/
/*	Take out gl_fakemsg at hctl_button	2/17/88		D.Mui	*/ 
/*	Take out gl_fakemsg at hctl_button	6/25/90		D.Mui	*/
/*	Fixed at hctl_window to check if button is pressed 6/6/92	*/
/*	Convert to Lattice C 5.51		2/17/93		C.Gee	*/
/*	Force the use of prototypes		2/24/93		C.Gee	*/
/*	Iconify feature added to screen manager 5/04/93		H.Krober*/
/*	Add "Iconify All Windows" feature	5/27/93		H.Krober*/
/*	Added toolbar handling at hctl_window   05/28/93	C.Gee	*/
/*	Double-Clicking on the title bar will send a FULL message. This */
/*      only occurs if the window has a full button AND the window      */
/*      is not iconified.			06/11/93        C.Gee   */
/*	Add support for icon tiling		07/18/93	H.Krober*/
/*									*/
/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "objaddr.h"
#include "windlib.h"
#include "message.h"
#include "osbind.h"
#include "mintbind.h"
#include "signal.h"

/* FROM DESKMISC.C */
VOID	rep2_path( BYTE *name, BYTE *path );


#define THEDESK 	3
#define MBDOWN 		0x0001
#define BELL 		0x07	


EXTERN	WORD	gl_multi;
EXTERN	PD	*shellpd;
EXTERN	WORD	cpdid;
EXTERN	BYTE	*loadapp;
EXTERN	WINDOW	*hashtbl[];
EXTERN	WORD	gl_xrat;
EXTERN	WORD	gl_yrat;
EXTERN	PD	*tlr;
EXTERN	WORD	st_redraw;
EXTERN	WORD	dy_redraw;
EXTERN	WORD	gl_mnpid;
EXTERN	GRECT	gl_offscreen;
EXTERN	WORD	phanwind;
EXTERN	OBJECT	*mn_addr;
EXTERN	WORD	cu_xrat;
EXTERN	WORD	cu_yrat;
EXTERN	OBJECT	*gl_wtree;
EXTERN	PD	*plr;
EXTERN	WORD	gl_cdabox;
EXTERN	OBJECT	*gl_mntree;
EXTERN	WORD	deskwind;		/* background window handle */
EXTERN	WORD	gl_topw;
EXTERN	WORD	gl_wbox;
EXTERN	WORD	gl_hbox;
EXTERN	GRECT	gl_rfull;
EXTERN	GRECT	gl_rmenu;
EXTERN	GRECT	gl_rmnactv;
EXTERN	GRECT	gl_rscreen;
EXTERN	THEGLO	D;
EXTERN  WORD	gl_dclick;	/* gemevlib.c - double click speed	*/
EXTERN	PD	*gl_mowner;
EXTERN  WORD	gl_kbid;

EXTERN	WORD	gl_button;	/* current button state	*/
EXTERN	WORD	gl_dabase;
EXTERN  MOBLK	gl_ctwait;
EXTERN	WORD	cu_button;

EXTERN	PD	*scr_pd;
EXTERN	WORD	shutdown;

EXTERN BYTE	*a_strtproc;
EXTERN BYTE	*a_faildesk;


GLOBAL WORD	gl_wa[] =
{
	WA_UPLINE,		/* used to convert from	*/
	WA_DNLINE,		/*   window object # to	*/	
	WA_UPPAGE,		/*   window message code*/
	WA_DNPAGE,
	0x0,
	WA_LFLINE,
	WA_RTLINE,
	WA_LFPAGE,
	WA_RTPAGE
};

MLOCAL	WORD	ctrl_shut;

EXTERN	BYTE	*icnslots;
EXTERN	BYTE	currIcnmax;

GLOBAL	BYTE	AE_TREDRAW[] = "AE_TREDRAW=";
GLOBAL	BYTE	AE_SREDRAW[] = "AE_SREDRAW=";

MLOCAL	BYTE	MY_MSG[] = "[1][ MultiTOS is written by | Derek Mui, Allan Pratt |\
 and Eric Smith.| Copyright 1992-1993 Atari Corp.| All Rights Reserved][ OK ]";


/*	Find the top window handle of a particular process 		*/
/*	We need to do waitforaes because there is no legal way for 	*/
/*	screen manager to inquire the information that it needs. The	*/
/*	way we can do it is to go directly to the AES window variables	*/
/*	but we need to wait until nobody is the AES fooling around with	*/
/*	the variables. By doing the waitforaes semaphore, we can be sure*/
/*	we can wait in line until someone get out and we go in and block*/
/*	the next one who wants to come in				*/ 

	WORD
c_w_tophandle( p )
	PD	*p;
{
	WORD	ret;

	waitforaes();
	ret = w_tophandle( p );
	releaes();
	return( ret );
}



/*	Find the PD structure of a given process	*/

	PD
*c_fpdnm( pointer, id )
	BYTE	*pointer;
	WORD	id;
{
	PD	*p;

	waitforaes();
	p = fpdnm( pointer, id );
	releaes();
	return( p );
}


/*	Use the AES internal window draw to draw the gadgets	*/

	VOID
c_clipdraw( pwin, cpt, pointer )
	WINDOW	*pwin;
	WORD	cpt;
	BYTE	*pointer;
{
	waitforaes();
	w_clipdraw( pwin, cpt, ( GRECT *)NULLPTR );
	releaes();
}
			

/*	Send message 	*/

	VOID
ct_msgup(message, owner, wh, m1, m2, m3, m4)
	WORD		message;
	WORD		owner, wh;
	WORD		m1, m2, m3, m4;
{
	WORD		msg[8];

	msg[0] = message;
	msg[1] = scr_pd->p_pid;
	msg[2] = 0;
	msg[3] = wh;
  	msg[4] = m1,
	msg[5] = m2;
	msg[6] = m3;
	msg[7] = m4;	
	appl_write( owner, EV_BUFSIZE, ( BYTE *)msg );
}


/*	Send message and wait for the mouse button to come up	*/

	VOID
ct_wmsgup(message, owner, wh, m1, m2, m3, m4)
	WORD		message;
	WORD		owner, wh;
	WORD		m1, m2, m3, m4;
{
	if ( message )
	{
		while (gl_button & 0x01) ;
	  	ct_msgup( message, owner, wh, m1, m2, m3, m4 );
	}
}


/*	Handle the window click action and send message	*/

	VOID
hctl_window( mx, my, kshift, clicks )
	WORD		mx, my, kshift, clicks; /* click added 5/4/93 hmk */
{
	GRECT		f, real;
	WORD		set, w_handle, x, y, w, h, buttonset;
	WORD		wm, hm;
	WORD		mstate, kind, xelev, yelev;
	REG WORD	message, cpt;
	REG WINDOW	*pwin;
	WORD		rets[8];
	PD		*p;
	REG OBJECT	*obj;

Debug1("hctl_window()\r\n");
	if ( ( w_handle = wind_find( mx, my ) ) == NIL )
	  return;
	graf_mouse( M_ARROW|0xC000, 0L );

	waitforaes();
	pwin = srchwp( w_handle );
	releaes();
	message = 0;

	/* if window is top window, handle control points */
	  		/* changed ROOT to W_BOX 072691 - ml. */
	obj = pwin->obj;
	cpt = objc_xfind( obj, W_BOX, MAX_DEPTH, mx, my );

/*	t = pwin->curr;	*/
/*	rc_intersect( &gl_rfull, &t );	*/
	r_get( ( WORD *)&pwin->curr, &x, &y, &w, &h );
	kind = pwin->kind;
	p = pwin->owner;
	buttonset = TRUE;

	switch( cpt )
	{
	    case W_SMALLER:		/* +++ 04/93 Iconify Feature */
 	      	if (kshift & 0x0004)	/* CONTROL & Iconify = Iconify All Windows */
			message = WM_ICONIFYALL;	
	      	else
	        	message = WM_ICONIFIED;
		w = WINICON_W; h = WINICON_H;

		set = TRUE;
		if (icnslots == NULL)  		/* +++ 7/18/93 */
			set = FALSE ;
		else if (findIcnslot(icnslots, &currIcnmax, &x, &y, 
		&pwin->iconslot) == FALSE )
			set = FALSE;
		
		if (!set)
			y = gl_rfull.g_y + gl_rfull.g_h - h - 1;

		goto do_cpt;

	    case W_CLOSER:
	    case W_FULLER:
		message = ( cpt == W_FULLER ) ? WM_FULLED : WM_CLOSE; 

do_cpt:
		set = FALSE;
		while( TRUE )
		{
		  graf_mkstate( &mx, &my, &mstate, &kind );
		  wm = objc_xfind( obj, W_BOX, MAX_DEPTH, mx, my );
		  if ( mstate & 0x01 )
		  {
		    if ( wm == cpt )
		    {
		      if ( !set )
		      {
			obj[cpt].ob_state |= SELECTED;
			c_clipdraw( pwin, cpt, NULLPTR );
			set = TRUE;
		      }
		    }
		    else
		    {
		      if ( set )
		      {
		        obj[cpt].ob_state &= ~SELECTED;
		        c_clipdraw( pwin, cpt, NULLPTR );
		        set = FALSE;
		      }
		    }
		  }
		  else
		    break;
		}

		obj[cpt].ob_state &= ~SELECTED;
		c_clipdraw( pwin, cpt, NULLPTR );
		if ( wm != cpt )
		  message = 0; 
		break;

	    case W_NAME:

		/* Double click? treat like a FULLER! cjg 06/11/93 */
		if( ( clicks == 2 ) && ( kind & FULLER ) &&
		    ( !pwin->iconflag )  ) {
		    message = WM_FULLED;
		    goto do_cpt;
		} else if ((clicks == 2) && (pwin->iconflag)) { /* +++ HMK 6/30/93 */
			goto do_uniconify;
		}
		
		if ( !( gl_button & 1 ) ) {
		  message = (w_handle == gl_topw) ? WM_BOTTOMED : WM_TOPPED;
		  break;
		}

	        if ( kind & MOVER )
		{
		  obj[cpt].ob_state |= SELECTED;		  
		  c_clipdraw( pwin, cpt, NULLPTR );
		  r_set( ( WORD *)&f, 0, gl_hbox,(gl_rscreen.g_w + w - gl_wbox - 6), 10000);
		  graf_dragbox( w, h, x, y, f.g_x, f.g_y, f.g_w, f.g_h, &x, &y );
		  if ( ( mx == gl_xrat ) && ( my == gl_yrat ) ) {
		    message = 0;
		  }
		  else 
		    message = WM_MOVED;
		}

		break;
	    case W_SIZER:
	       if ( kind & SIZER )	/* fix 10/21/85	*/
	       {
	         GRECT t;

		 obj[cpt].ob_state |= SELECTED;		  
		 c_clipdraw( pwin, cpt, NULLPTR );
		 wm_min( pwin, &wm, &hm );
#if 0
		 w += pwin->curr.g_w + 1;
		 h += pwin->curr.g_h + 1;
		 graf_rubbox( x, y, wm, hm, &w, &h );
#else
		 wind_get(w_handle, WF_WORKXYWH, &t.g_x, &t.g_y, &t.g_w,
			  &t.g_h);
	  	 t.g_x -= x;
		 t.g_y -= y;
		 t.g_w -= w;
		 t.g_h -= h;
		 graf_rwind(x, y, wm, hm, &t, &w, &h);
#endif
		 if ( ( mx != cu_xrat ) || ( my != cu_yrat ) )
		   message = WM_SIZED;
	       }

	       break;

	    case W_HSLIDE:	/* Horizontal slider background */	
	    case W_VSLIDE:	/* Vertical slider background	*/
		buttonset = FALSE;

		/* The cpt+1 will lead to their respective elevator objs	*/

		objc_offset( obj, cpt + 1, &xelev, &yelev);

		if ( cpt == W_HSLIDE )
		{
						/* fix up for index	*/
						/*   into gl_wa		*/
		  if ( !(mx < xelev) )
		    cpt += 1;
		}
		else
		{
		  if ( !(my < yelev) )
		    cpt += 1;
		}
		message = WM_ARROWED;
		break;				/* fall thru		*/

	    case W_UPARROW:
	    case W_DNARROW:
	    case W_LFARROW:
	    case W_RTARROW:
		message = WM_ARROWED;
		break;

	    case W_HELEV:
	    case W_VELEV:
		message = (cpt == W_HELEV) ? WM_HSLID : WM_VSLID;
		obj[cpt].ob_state |= SELECTED;		  
		c_clipdraw( pwin, cpt, NULLPTR );
					/* slide is 1 less than elev	*/
		x = graf_slidebox(obj, cpt - 1, cpt, (cpt == W_VELEV));
		break;

	    default:

	       /* CJG 05/28/93
	        * Button Handling for the ToolBar, if any...
		* 1) ad_tools must be non-zero, its the tree!
		* 2) The window must not be iconified...
		* 3) Window must be on TOP	06/01/93 cjg
		*
		* 1a) Check if we have clicked on the ToolBar....
		* 1b) Check if the clicked item is a TouchExit...
	        */
	      if( pwin->ad_tools && !pwin->iconflag && 
		( w_handle == gl_topw ) ) {

		cpt = objc_xfind( pwin->ad_tools, ROOT, MAX_DEPTH, mx, my );

		if( cpt != -1 ) {
		   if( pwin->ad_tools[ cpt ].ob_flags & TOUCHEXIT ) {

		     x = cpt;	  /* Object Clicked on in the ToolBar */ 
		     y = clicks;  /* Number of Clicks... */
		     w = kshift;  /* keystate at time of clicks	*/
		     h = 0; 
		     message = WM_TOOLBAR;
		     cpt = W_BOX;	  /* Clear cpt object */
		     break;
		   }
		}
		cpt = W_BOX;
	      }


		/* +++ 04/05/93 HMK
		 * If window is iconoified and a double click is
		 * hapening on the window's work area, uniconify the
		 * window
		 */
do_uniconify:
	      if (pwin->iconflag && (clicks == 2)) {
		message = WM_UNICONIFIED;
		x = pwin->icon.g_x;	/* coords before window was 	*/ 
		y = pwin->icon.g_y;	/* iconified.			*/
		w = pwin->icon.g_w;
		h = pwin->icon.g_h;
		retIcnslot(icnslots, &pwin->iconslot, &currIcnmax);
		break;
	      }

	      if ( w_handle != gl_topw )
	      {
		if ( w_handle )		/* Not the top window	*/
	          message = (kshift & 3) ? WM_BOTTOMED : WM_TOPPED;
	      }
	      else if (kshift & 3)
	        message = WM_BOTTOMED;
	      else
	      {
		rets[0] = 0;
		rets[1] = p->p_pid;
		hctl_mesag( rets );
	      }
	      Debug1("hctl_window: button - default\r\n");

	  }/* switch */

	  if ( message == WM_ARROWED )
	  {
	    x = gl_wa[cpt - W_UPARROW];	/* request action code */
	    if ( buttonset )
	    {
	      obj[cpt].ob_state |= SELECTED;
	      c_clipdraw( pwin, cpt, NULLPTR );
	    }

	    kind = TRUE;
	
	    real.g_w = obj[cpt].ob_width + (ADJ3DPIX << 1);
	    real.g_h = obj[cpt].ob_height + (ADJ3DPIX << 1); 	
	    objc_offset( obj, cpt, &real.g_x, &real.g_y );
	    real.g_x -= ADJ3DPIX;
	    real.g_y -= ADJ3DPIX;
	    do
	    {
	      if ( buttonset )	/* Genuine ARROW messages	*/
	      {
	        if ( !inside( gl_xrat, gl_yrat, &real ) )
		  break;
	      }
	
	      wind_update( 0 );		/* give up the screen		*/

	      if ( p->p_qdq )
	        ct_msgup( message, p->p_pid, w_handle, x, y, w, h );
	      else
	      if ( !p->p_message[0] )	/* message is sent		*/
	      { 
		p->p_message[0] = 1;
	        p->p_message[1] = message;	/* message		*/ 
		p->p_message[2] = scr_pd->p_pid;/* sender		*/	
	        p->p_message[3] = 0;
		p->p_message[4] = w_handle;	
	        p->p_message[5] = x;
	      }

              kickaes();		/* force a dsptch		*/

					/* Delay for half current double*/
					/* click time: allow button to	*/
					/* come back up on single click.*/
	      if ( kind )		/* Only delay 1st time through */ 
	      { 
		kind = FALSE;
		evnt_timer( gl_dclick * 8, 0  );
	      }

	      wind_update( 1 );		/* take back the screen		*/

	    } while( gl_button & 1 );	/* button is global		*/


	  }/* if WM_ARROWED	*/		
	  else
	  {
	    if ( message )
	    {
	      if ( message == WM_TOPPED || message == WM_BOTTOMED )
	      {
	        ct_wmsgup( message, p->p_pid, w_handle, x, y, w, h );
	      }
	      else {
	        if( message == WM_TOOLBAR ) {  /* TOOLBAR HANDLING */

		    /* The TOOLBAR needs to force an immediate dispatch
		     * and then sit around waiting for the button to
		     * come back up.  We can't exit this function
		     * because we don't want other toolbar messages.
		     */
		    kind = TRUE;

		    do {
	               wind_update( 0 );    /* give up the screen  */

	               if( kind ) {	    /* Send the message only once */
	                 ct_msgup( message, p->p_pid, w_handle, x, y, w, h );
		       }
					/* Delay for half current double*/
					/* click time: allow button to	*/
					/* come back up on single click.*/
	               if( kind ) {	/* Only delay 1st time through */ 
		         kind = FALSE;
		         evnt_timer( gl_dclick * 8, 0  );
	               }

	               wind_update( 1 );	/* take back the screen	*/
			
		    }while( gl_button & 1 );
		    graf_mouse( M_RESTORE, 0L );
		    return;  

		}   /* end of if( message == WM_TOOLBAR */
		else                           /* ALL OTHER MESSAGE HANDLING*/
	 	    ct_msgup( message, p->p_pid, w_handle, x, y, w, h );

	      }
	    }
	  }

	  if ( obj[cpt].ob_state & SELECTED )
	  {	
	    obj[cpt].ob_state &= ~SELECTED;
	    c_clipdraw( pwin, cpt, NULLPTR );
	  }

	  graf_mouse( M_RESTORE, 0L );
	  return;
}


/*	Swap to next application	*/

	VOID
swap_prg( p )
	PD	*p;
{
	WORD	item;
	WORD	msgbuff[8];

	if (!p) return;		/* sanity check */
	item = c_w_tophandle( p );

	if ( item != -1 )	/* Yes, it has a window */
	{
	  ct_wmsgup( WM_TOPPED, p->p_pid, item, item, item, item, item );
	}

	waitforaes();
	openphanwind( p );
	releaes();

	msgbuff[0] = 0;		/* force a background redraw	*/
	msgbuff[1] = p->p_pid;
	hctl_mesag( msgbuff );
}


/*	Inside the menu bar area	*/

	VOID
hctl_rect( mx, my )
	WORD		mx, my;
{
	WORD		i,title,item,kill;
	REG WORD	owner, mesag;
	PD		*p;
	OBJECT		*obj;
	WORD		keyret,pmenu;
	LONG		*ptree;
	WORD		temp1, temp2;


	Debug7("hctl_rect() called, menu bar handling\r\n");

	if ( ( gl_mntree != 0x0L ) && ( inside( mx, my, &gl_rmnactv ) ) )
	{
	  obj = mn_addr;
	  Debug7("hctl_rect() inside menu bar\r\n");

#if 0
	  /* clean up all the check mark in the menu */
	  for( i = 0; i <= obj[0].ob_tail; i++ )
	    xdo_chg( obj, i, CHECKED, FALSE, FALSE, TRUE  );
#endif

	  if (idtopd( gl_kbid )->p_mobj != -1)
 	  {
 	    /* clean up all the check mark in the menu */
 	    for( i = 0; i <= obj[0].ob_tail; i++ )
 	      xdo_chg( obj, i, CHECKED, FALSE, FALSE, TRUE  );
	    xdo_chg( mn_addr, idtopd( gl_kbid)->p_mobj, CHECKED, TRUE, FALSE, TRUE );
	  }
	  kill = FALSE;		/* assume we will not kill the process */

	  if ( mn_hdo( &title, ( OBJECT **)&ptree, &pmenu, &item, &keyret ) )
	  {
	    if (gl_multi && (keyret & 0x04))
	      kill = TRUE;	
		
	    owner = gl_mnpid;
	    mesag = MN_SELECTED;

	    if ( title == THEDESK )	/* leftmost menu */
	    { 	
	      if ( item >= gl_dabase )	
	      {
		p = plr;
		while( p )
		{			/* Look for matching item	*/
		  if ( p->p_mobj == item )	
		  {
	            xdo_chg( gl_mntree, title, SELECTED, FALSE, TRUE, TRUE );
					/* process is dead		*/
		    if ( gl_multi && Pkill( p->p_sysid, 0 ) )
		    {
		      appl_term( p->p_pid );
		      goto h_exit;
		    }

		    owner = p->p_pid;

		    if ( p->p_type & AESACC )	/* open accessories	*/
		    {
		      Debug1("Open Accessories, pid="); Ndebug1((LONG)owner);
		      if ( ( kill ) && ( p != scr_pd ) && gl_multi )
			Pkill( p->p_sysid, SIGTERM );
		      else
		      {
	                mesag = AC_OPEN;
	                item = p->p_accid;
			Debug1("Open Accessories, accid="); Ndebug1((LONG)item);
		        break;
		      }
		    }				/* swap programs	*/
		    else
		    {
		      if ( ( kill ) && ( p != scr_pd ) )
		      {
		  	if ( p->p_events & 0x01 )
			  ct_wmsgup( AP_TERM, owner, 0, 0, 0, 0, 0  );
			else
			  Pkill( p->p_sysid, SIGTERM );
		      }
		      else /* if (gl_multi) */
		        swap_prg( p );
 		    }
  	
		    goto h_exit;
		  }
		  else
		    p = p->p_thread;

		}		/* while 		*/
	      }			/* left most menu	*/
	      else		
		item = gl_mntree[gl_cdabox].ob_head;

	    }/* if desk menu	*/

	    temp1 = (WORD) (( (LONG)ptree >> 16L ) & 0x0000FFFFL );
	    temp2 = (WORD) ( (LONG)ptree & 0x0000FFFFL );

	    ct_wmsgup( mesag, owner, title, item, temp1, temp2, pmenu );

	  }/* menu item selected */
	}/* if hit the menu	*/
h_exit:
	return;
}



/*	Screen handles the key	*/

	VOID
hctl_keybd( key )		/* This is tricky!!!	*/
	LONG	key;		/* Look at how this function is being called */
{
	PD	*last;
	REG PD	*p;
	WORD	up,plr_used;
	
	/* Control Shift Alternate Clr Home and Right button */
	if ( ( key == 0xe770037L ) && ( gl_button & 0x02 ) )
	{
	  form_alert( 1, MY_MSG );	
	  return;	
	}

#ifdef NO_DEADLOCK
/* this seems to cause a deadlock under some circumstances when
 * CTRL-ALT-TAB is held down
 */
	waitforaes();
#endif

	last = idtopd( gl_kbid );

	if ( key == 0xc0f0009L )	/* go down */
	  up = FALSE;
	else
	{
	  if ( key == 0xe0f0009L ) 	/* go up */
	  {
	    up = TRUE;
	  }
	  else
	    return;
	}

	if ( !( p = last->p_thread ) )
	{
	  p = plr;
	  plr_used = TRUE;
	} else
	  plr_used = FALSE;

	while( p )
	{
	  if ( p->p_type & (AESAPP|AESSHELL) )
	  {
	    if ( up )		/* go up */
	    {
	      if ( p != idtopd( gl_kbid ) )
	      {
	      	last = p;
	        goto c1;
	      }

	      p = last;
	    }
#ifdef NO_DEADLOCK
	    releaes();
#endif
	    swap_prg( p );		       	
	    return;
	  }

c1:	  if ( !( p = p->p_thread ) && !plr_used )
	  {
	    p = plr;
	    plr_used = TRUE;
	  }
	}
#ifdef NO_DEADLOCK
	releaes();
#endif
}



/*
*	Handle timer, check to see if any process is marked dead in a 
*	fixed interval of time.
*	We have to do it this way because we don't want the AES to be jammed
*	up by all the dead processes
*/	

	WORD
hctl_timer( VOID )
{
	BYTE		name[10];
	UWORD		id,type,mode;
	WORD		i,ret;
	REG WINDOW	*win;
	PD		*p;

	waitforaes();

	p = plr;
			/* check here to see if any process take over the */ 
	while( p )	/* system for too long. If so change the state	  */
	{
	  if ( (!( p->p_type & AESSYSTEM )) && ( p->p_state & PS_ALLRUN ) )
	  {
	    if ( p->p_tick )
	      p->p_tick--;
		
	    if ( !p->p_tick )
	    {			/* check the codes at ev_multi */
	      if ( cpdid == p->p_pid )
		cpdid = -1;

	      p->p_state = PS_RUN;
	    }
	  }

	  p = p->p_thread;
	}	

	releaes();

	mode = 0;		/* search first	*/
	ret = FALSE;

	while(TRUE)
	{
	  if ( gl_multi && appl_search( mode, name, &type, &id ) )
	  {
	    mode = 1;		/* search next	*/

	    if ( !( type & 1 ) )/* if not system process */
	    {
	       if ( Pkill( appl_find( ( BYTE *)(0xFFFE0000L|(LONG)id) ), 0 ) )
		 appl_term( id );	
	    }
	  }
	  else
	    break;
	}

	if ( ctrl_shut )
	{
	  ret = TRUE;
	  waitforaes();

	  for ( i = 0; i < NUMWIN; i++ )
	  {
	    if ( win = hashtbl[i] )
	    {
	      while( win )
	      {
		if ( win->handle != deskwind )
		{
		  if ( ( win->status.opened ) && !( win->owner->p_type & AESSYSTEM ) )
		  {
		    ret = FALSE;
		    break;
		  }
	        }
		win = win->wnext;
	      }
	    }
	  }

	  if ( ret )	/* if OK */
	  {
	    p = plr;
	    while( p )
	    {
	      if (gl_multi && !(p->p_type & AESSYSTEM))
	      {
	        Pkill( p->p_sysid, SIGTERM );
		ret = FALSE;
	      } else if (!(p->p_type & AESSYSTEM)) {
			forkq((WORD(*)())pdterm, ((LONG) p->p_sysid << 16L));
	      }
	      p = p->p_thread;	 	
	    } 		    	
	  }
	
	  releaes();
	}	

	return( !ret );
}



/*	Process 1 - Screen manager 	*/

	VOID
screenmgr( VOID )
{
	REG WORD	ev_which;
	WORD		rets[6];
	WORD		msgbuff[8];
	WORD		cont;
	LONG		temp;

	Bigstack();

	catchsignal( -1 );	

	appl_init();

	/* we want to do it here because only at this point	*/
	/* only that I know that system is up and running	*/

	takeerr();		/* handler critical error 	*/

	/********************************************************/

	cont = TRUE;
	ctrl_shut = FALSE;

	icnslots = allocIcnslots();	/* +++ 7/18/93 */
	currIcnmax = 0;

	do
	{
				/* wait for something to happen		*/
				/* +++ 05/04/93 HMK			*/
				/* Now also waiting for double clicks.	*/
				/* This is needed for uniconifying a	*/
				/* window.				*/
	  ev_which = evnt_multi( MU_MESAG|MU_KEYBD|MU_M1|MU_BUTTON|MU_TIMER,
				 2, 1, 1,	
				 gl_ctwait.m_out,
				 gl_ctwait.m_x,
				 gl_ctwait.m_y,
				 gl_ctwait.m_w,
				 gl_ctwait.m_h,
				 gl_ctwait.m_out,
				 gl_ctwait.m_x,
				 gl_ctwait.m_y,
				 gl_ctwait.m_w,
				 gl_ctwait.m_h,
				 ( LONG )msgbuff,
 				 (ctrl_shut ? 0x10 : 0x500),0x0,
				 &rets[0], &rets[1],
				 &rets[2],
				 &rets[3],
				 &rets[4],
				 &rets[5] );

	  if ( ev_which & MU_TIMER )	/* check all the process first */
	    cont = hctl_timer();	    

	  wind_update(1);

	  if ( ev_which & MU_MESAG )
	    cont = hctl_mesag( msgbuff );

	  if ( ev_which & MU_BUTTON ) /* # clicks added -+ 5/4/93 hmk */
          {			      /*                 V            */
	    hctl_window( rets[0], rets[1], rets[3], rets[5] );
	   }
						/* mouse over menu bar	*/
	  if (ev_which & MU_M1)
	    hctl_rect( rets[0], rets[1] );

	  if (ev_which & MU_KEYBD ) {
	    temp = ((LONG) rets[3] << 16L) & 0xFFFF0000L;
	    temp = temp | (LONG) rets[4];
	    hctl_keybd( temp );
	  }
	  wind_update(0);
			
	}while( cont );

	freeIcnslots(icnslots); 	/* +++ 7/18/93 */

	giveerr();		/* release critical error	*/	
	appl_exit();		
	dos_term( 1 );		/* terminate process	*/
}


/*	Redraw the dirty window	*/

	VOID
drawit( handle, px, obj, start )
	WORD	handle,start;
	GRECT	*px;
	OBJECT	*obj;
{
	GRECT	pt;

	wind_update(1);

	graf_mouse( M_OFF, 0L );

	wind_get( handle, WF_FIRSTXYWH, &pt.g_x, &pt.g_y, &pt.g_w, &pt.g_h );

	while( pt.g_w && pt.g_h )
	{
	  if ( rc_intersect( px, &pt ) )
	    objc_draw( ( LONG )obj, start, MAX_DEPTH, pt.g_x, pt.g_y, pt.g_w, pt.g_h );

	  wind_get( handle, WF_NEXTXYWH, &pt.g_x, &pt.g_y, &pt.g_w, &pt.g_h );
	}

	graf_mouse( M_ON, 0L );

	wind_update(0);
}


/*	Receive various message from AES to do things	*/

	WORD
hctl_mesag( msgbuff )
	WORD	msgbuff[];
{
	PD		*p;
	WORD		item;
	BYTE		name[16];	/* file name 	*/
	BYTE		buffer[128];	/* path buffer 	*/
	WORD		button;
	BYTE		*bptr;

	if ( msgbuff[0] == MN_SELECTED )
	{
	  if ( shellpd == scr_pd )	/* If no Shell	*/
	    item = form_alert( 1, a_strtproc );
	  else
	    item = 2;
	
	  switch( item )
	  {
	    case 1:		/* Restart desktop */	
	      if ( !shel_write( 12, 0, 0, 0L, 0L ) )
	        form_alert( 1, a_faildesk );
	      else
	      {			/* Screen is not the shell anymore */ 
	        scr_pd->p_type &= ~AESSHELL;
		scr_pd->p_mobj = -1;	
	      }			
	    case 3:		/* Cancel	   */
	      break;	
   	    case 2:		/* Load another application	*/		
	      strcpy( "C:\\BIN\\*.PRG", buffer );
	      name[0] = 0;
	      fsel_exinput( ( LONG )buffer, ( LONG )name, &button, loadapp );
	      if ( button )	/* if OK */
	      {
	        rep2_path( name, buffer );
	        if ( !shel_write( 0, 0, 0, ( LONG )buffer, 0L ) )
	          form_error( 8 );
	      }
	      break;	
	    default:
	      break;		 
	  }	
	  menu_tnormal( ( LONG )scr_pd->p_mnaddr, msgbuff[3], 1 );
	  return( TRUE );
	}

	if ( msgbuff[0] == WM_TOPPED )
	{
	  waitforaes();
	  openphanwind( scr_pd );
	  releaes();
	  wind_set( phanwind, WF_TOP, 0, 0, 0, 0 );
	  return( TRUE );
	}

	if ( !( p = c_fpdnm( NULLPTR, msgbuff[1] ) ) )/* process is dead */
	  return( TRUE );

	switch( msgbuff[0] )
	{
	    case 0:	
			/* select menu to swap the program 	*/
			/* or application's window is on top	*/
			/* or application just open a window	*/	
	      gl_kbid = p->p_pid;	/* force the mouse ownership	*/

	      if ( ( p->p_mnaddr ) && ( p->p_pid != gl_mnpid ) ) {
		Debug1("hctl_msg(): select menu to swap prg\r\n");	     
		menu_bar( ( OBJECT *)p->p_pid, TRUE|0x0100 );
	     }

	      break;

	    case 1:	/* An application or accessory starts to run	*/
			/* redraw the menu and background		*/

	      if ( ( shutdown ) || ( p->p_type & AESACC ) )
		break;

	      if ( p == scr_pd )
		break;

	      shel_envrn( ( LONG )&bptr, ( LONG )AE_SREDRAW );
	      if ( bptr ) 
	      {
		if ( *bptr == '1' )
		{
	      	   if ( ( p->p_mnaddr ) && ( p->p_pid != gl_mnpid ) )
	             menu_bar( ( OBJECT *)p->p_pid, TRUE|0x0100 );
	      	   else
	             menu_bar( (OBJECT*)-1, TRUE|0x0200 );

	           form_dial( 3, 0, 0, 0, 0, gl_rfull.g_x, gl_rfull.g_y, 
			      gl_rfull.g_w, gl_rfull.g_h );
		}
	      }

	      break;

	    case 2:		/* a process just died, update the screen */
	      if ( shutdown )	/* if necessary				  */
		break;
	
	      if ( p != scr_pd )	
	      {	
	        shel_envrn( ( LONG )&bptr, ( LONG )AE_TREDRAW );
	        if ( bptr ) 
	        {
		  if ( *bptr == '1' )
		    goto l_1;
	        }
	        break;
	      }
	
	    case 3:		/* must redraw background regardless	*/
	      if ( shutdown )	/* it is determined in swap_next	*/
		break;
l_1:
	      graf_mouse( M_ARROW, 0L );		
	      form_dial( 3, 0, 0, 0, 0, gl_rfull.g_x, gl_rfull.g_y, gl_rfull.g_w, 
		 	 gl_rfull.g_h );
	      break;

	    case 4:
	      if ( p->p_mobj != -1 )	/* some one just did an appl_init	*/
		break;			/* make sure that the current menu bar	*/
					/* register with this new process	*/	

		     			/* If already did, then let it fall 	*/
 					/* through				*/
	    case 5:
		menu_bar( (OBJECT*)-1, TRUE|0x0200 );
	      break;
 					/* someone did a menu register	*/
					/* update the menu, please	*/
	
	    case 6:			/* reschange process exit */
	      ctrl_shut = TRUE;		/* begin checking	*/
	      break;		

	    case 7:		/* send shut_completed message */
	      ct_msgup( SHUT_COMPLETED, p->p_pid, 1, 0, 0, 0, 0 );
	      break;

	    case 8:			/* update the menu bar */
	      Debug1("hctl_msg(): Update menu bar\r\n");
	      /**
		Next two lines added 04/29/93 HMK.
		If PD's menu addr is NULL the process either has no menu
		bar or called menu_bar(tree, 0) to erase it. So we will
		display the shell's (desktop's) menu bar instead.
	      **/	
	      if (p->p_mnaddr == NULL)
		p = shellpd;		/* use desktop's menu bar */
	      menu_bar( ( OBJECT *)p->p_pid, TRUE|0x0100 );
	      break;

	    case 9:			/* swap out the menu bar */
	      if ( shutdown )
		break;
	      menu_bar( ( OBJECT *)p->p_pid, 0x0200 );
	      break;

	    default:
	      break;
	}

	return( TRUE );
}



/*	Create a screen manager	*/

	PD
*iscrmgr( VOID )
{
					/* create a screen process */
	if ( gl_mowner = scr_pd = get_pd( "SCREEN", AESSYSTEM ) )
	{
	  gl_kbid = gl_mowner->p_pid;
	  pstart( scr_pd, &runaes, ( BYTE *)&screenmgr );
	  srchwp( 0 )->owner = scr_pd;
	  ps_rename( scr_pd->p_sysid, "SCREEN.", TRUE );	
	}

	return( scr_pd );
}



/*	Replace path			*/
/*	A:\aaa\*.* -> A:\aaa\bbb	*/
/* COPIED FROM DESKMISC.C		*/
	VOID
rep2_path( name, path )
	BYTE	*name;
	BYTE	*path;
{
	path = r_slash( path );	
	path++;
	strcpy( name, path ); 
}
#if 0
/*
 *	Icon Slot Manager
 *	+++ HMK 7/18/93
 */

BYTE *allocIcnslots()
{
	REG BYTE *ip, *p;
	REG WORD i;
	WORD	 size;


Debug1("gl_rfull.g_w="); Ndebug1((LONG)gl_rfull.g_w);
Debug1("gl_rfull.g_h="); Ndebug1((LONG)gl_rfull.g_h);

	size = (gl_rfull.g_w / WINICON_W) * (gl_rfull.g_h / WINICON_H);

	ip = p = (BYTE *) dos_xalloc((LONG) size, 3);

	for (i = 0; i < size; i++)
		*p++ = 0;

	return ip;
}

	VOID
freeIcnslots(ip)
	BYTE	*ip;
{
	if (ip != NULL)
		dos_free((LONG)ip);
}

	WORD
findIcnslot(slots, curr_icnmax, x, y, slotnr)
	REG BYTE *slots;
	BYTE	 *curr_icnmax;
	WORD	 *x, *y;
	BYTE	 *slotnr;
{
	REG WORD i, c, r;
	WORD	 rows, cols;

	rows = gl_rfull.g_h / WINICON_H;
	cols = gl_rfull.g_w / WINICON_W;

Debug1("find: rows="); Ndebug1((LONG) rows);
Debug1("find: cols="); Ndebug1((LONG) cols);

	do {
		for (r = rows - 1; r >= 0; r--) {
			for (c = 0; c < cols; c++) {
				i = (r * cols) + c;
				if ((slots[i] <= *curr_icnmax) && 
				    (slots[i] < 127)) {
					slots[i] += 1;
					*x = c * WINICON_W;
					*y = ((r+1) * WINICON_H) - gl_rfull.g_y;
					*slotnr = (BYTE) i;
Debug1("slot nr="); Ndebug1((LONG) i);
Debug1("row="); Ndebug1((LONG) r);
Debug1("col="); Ndebug1((LONG) c);
Debug1("x="); Ndebug1((LONG) *x);
Debug1("y="); Ndebug1((LONG) *y);
Debug1("curr_icnmax="); Ndebug1((LONG) *curr_icnmax);
					return TRUE;
				}
			}
		}
		(*curr_icnmax)++;
	} while (*curr_icnmax < 127);
	
	return FALSE;
}

	VOID
retIcnslot(slots, slotnr, curr_icnmax)
	BYTE	*slots;
	BYTE	*slotnr;
	BYTE	*curr_icnmax;
{
	WORD		flag;
	REG WORD	i, n;
	WORD		rows, cols;

Debug1("ret: slotnr="); Ndebug1((LONG) *slotnr);

	if (*slotnr == (BYTE) -1)
		return;

	slots[*slotnr] -= 1;
	*slotnr = (BYTE) -1;

	rows = gl_rfull.g_h / WINICON_H;
	cols = gl_rfull.g_w / WINICON_W;
	
Debug1("ret: before curr_icnmax="); Ndebug1((LONG) *curr_icnmax);
	n = rows * cols;
	flag = TRUE;
	for (i = 0; i < n; i++, slots++) {
		if (*slots >= *curr_icnmax)
			flag = FALSE;	 
	}
	if (flag)
		(*curr_icnmax)--;

	Debug1("ret: after curr_icnmax="); Ndebug1((LONG) *curr_icnmax);
}
#endif
