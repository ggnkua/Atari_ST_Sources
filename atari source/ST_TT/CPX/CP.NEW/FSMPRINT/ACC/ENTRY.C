/* FILE:  ENTRY.C
 *==========================================================================
 * DATE:  June 19, 1991
 * DESCRIPTION: ENTRY Point from SKEL.C for FSMPRINT.ACC
 * 
 *
 * INCLUDE FILES:   ENTRY.H
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
 
#include "country.h"

#include "fprint.h"

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "fprint.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "fixrsh.h"
#include "xform_do.h"
#include "windows.h"

#include "text.h"
#include "mainstuf.h"
#include "popmenu.h"


/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par


/* PROTOTYPES
 *==========================================================================
 */
void    Activity( void );


/* DEFINES
 *==========================================================================
 */

/* GLOBALS
 *==========================================================================
 */
OBJECT  *tree; 
OBJECT  *cpxtree;
OBJECT  *drivetree;
OBJECT  *xytree;
OBJECT  *ad_scan;	/* scan message tree	     */

int ctrl_id;			/* ACC id slot #     	    */


/* FUNCTIONS
 *==========================================================================
 */
 
 
/* rsrc_init()
 *==========================================================================
 * Initialize resource and xcpb structure
 *
 * IN: void
 * OUT: BOOLEAN	- We, uh, always return TRUE...
 *
 * GLOBALS:   All of the rsh variables for the fixup...
 */
BOOLEAN
rsrc_init(void)
{
   fix_rsh( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE, rs_object,
            rs_tedinfo, rs_strings, rs_iconblk, rs_bitblk, rs_frstr,
            rs_frimg, rs_trindex, rs_imdope );

   Fix_As_Dialog = TRUE;
   fix_rsh( NUMX_OBS, NUMX_FRSTR, NUMX_FRIMG, NUMX_TREE,
            rx_object, rx_tedinfo, rx_strings, rx_iconblk,
            rx_bitblk, rx_frstr, rx_frimg, rx_trindex,
            ( struct foobar *)rx_imdope );

   cpxtree    = (OBJECT *)rs_trindex[ PRINTER ];
   ad_scan    = ( OBJECT *)rs_trindex[ SCANMSG ];

   drivetree  = ( OBJECT *)rx_trindex[ DRIVER ];
   xytree     = ( OBJECT *)rx_trindex[ XYREZ ];     

   return(TRUE);      
}



/* wind_init()
 *==========================================================================
 * Initialize window structure
 */
void
wind_init(void)
{
   if( !_app )
        ctrl_id = menu_register( gl_apid, menu_title );

   init_window();
      
   if( _app )
   {
        if( Create_Window() )
        {
          ActiveTree( cpxtree );
          initialize();	/* check window first, initialize, open window*/
   	  open_window();
   	  graf_mouse( ARROW, 0L );
   	  Activity();
   	}
   	else
   	  form_alert( 1, alert5 );  
   }
}





/* evnt_init()
 *==========================================================================
 * Initialize the event_multi with the proper messages, timers etc...
 */ 
void
evnt_init(void)
{
     /* We are looking ONLY for evnt messages - ACC_OPEN and ACC_CLOSE */
     /* The XFORM_DO() will handle the other messages in its own event loop */
     
     evnt_set( MU_MESAG, -1, -1, -1, NULL, NULL, -1L );
     /* In this case 'FSMACC' we don't even hit this call and
      * have just entered the XFORM_DO() loop directly.
      */
}



/* activity()
 *==========================================================================
 * THe KEY call to enter XFORM_DO()
 */
void
Activity( void )
{
     int  quit = FALSE;
     WORD button;
     WORD msg[8];
     
     ActiveTree( cpxtree );
     do
     {
	button = xform_do( tree, 0, msg );
	quit   = handle_button( button, msg );
     }while( !quit);

     DeletePopUpMenu( Menu[ MQUALITY ].menuid );
     DeletePopUpMenu( Menu[ MPAGESIZE ].menuid );
     DeletePopUpMenu( Menu[ MREZ ].menuid );
     DeletePopUpMenu( Menu[ MCOLOR ].menuid );
     DeletePopUpMenu( Menu[ MPORT ].menuid );
     DeletePopUpMenu( Menu[ MTRAY ].menuid );
     
     /* Checks if these exited because of AC_CLOSE or WM_CLOSE() */
     /* Wot about simple keystroke quits? */
     /* we exit for several reasons...
      * 1) press EXIT
      * 2) click on exit
      * 3) ACC_CLOSE
      * 4) WM_CLOSE
      */
     if( CheckAccClose() )
         return;	/* then return cause the windows are gone already*/
         
     /* if not AC_CLOSE, then the user selected EXIT from MAINTREE
      * or WM_CLOSE and we should shut down the window and
      * just go bck to the event_multi() loop - In other words
      * ALWAYS to a WM_Close call. WM_Close will hand _app programs
      * by exiting within WM_CLOSE.
      */
     Wm_Closed( (int *)msg );
}



/* do_windows()
 *==========================================================================
 * window handling...
 *
 * IN:  int *msg:	message buffer
 *	int *event:	flag to end the program
 *
 * OUT: void
 */
void
do_windows( int *msg, int *event )
{
   switch( msg[0] )
   {			
        case WM_REDRAW: Wm_Redraw( msg );
			break;
			
	case WM_NEWTOP:
	case WM_TOPPED: Wm_Topped( msg );
			break;
			
			
	case WM_CLOSED: Wm_Closed( msg );
			break;
			
	case WM_MOVED:  Wm_Moved( msg );
			break;
	default:
		 break;
   }
}




/* acc_open()
 *==========================================================================
 * Accessory Open Messages
 *
 * IN:   int *msg:	message buffer
 * OUT:  void
 *
 * GLOBAL: WINFO w:	window structure
 *	   int ctrl_id: application id
 */	   
void
acc_open( const int *msg )
{
    if( msg[4] == ctrl_id )
    {
           if( w.id == NO_WINDOW )
           {
       	     if( Create_Window())		
       	     {
                ActiveTree( cpxtree );
       	        initialize();
       	        open_window();
     	        graf_mouse( ARROW, 0L );
		Activity();
       	     }
       	     else
     	       form_alert( 1, alert5 );  
           }				 
           else				 
       	     wind_set( w.id, WF_TOP ); 
    }
   
}






/* acc_close()
 *==========================================================================
 * Accessory Close message
 *
 * IN:   int *msg:	message buffer
 * OUT:  void
 *
 * GLOBAL:  int ctrl_id:	application id
 *	    WINFO w:		window structure
 * 
 * Closing and deleting the window are unnecessary since the window
 * handles are already invalid by the time we get the acc_close() message
 */
void
acc_close( const int *msg )
{
     if(( msg[3] == ctrl_id ) && ( w.id != NO_WINDOW ) )
     {
        w.id = NO_WINDOW;
     }
}




/* do_button()
 *==========================================================================
 * Button handling routines
 *
 * IN:    MRETS *mrets:		mouse information
 *        int nclicks:		number of clicks;
 *	  int *event:		flag to end program
 *
 * OUT:    void
 *
 * GLOBAL: int xconfig:		which xconfig option active? -1 if none
 *	   WINFO  w:		window structure
 *
 * NOTE: This routine should never be called.
 */
void
do_button( MRETS *mrets, int nclicks, int *event )
{
}






/* do_timer()
 *==========================================================================
 */
void
do_timer( int *event ) 
{
}



/* do_key()
 *==========================================================================
 * SHould never be called...
 */
void
do_key( int kstate, int key, int *event )
{
}



/* do_m1()
 *==========================================================================
 */
void
do_m1( MRETS *mrets, int *event )
{
}



/* do_m2()
 *==========================================================================
 */
void
do_m2( MRETS *mrets, int *event )
{
}




/* evnt_hook()
 *==========================================================================
 * OUT: BOOLEAN - return true if one wants to skip event_multi processing
 */
BOOLEAN
evnt_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks )
{
   return( FALSE );
}



/* wind_exit();
 * ================================================================
 */
void
wind_exit( void )
{
   if( w.id != NO_WINDOW )
   {
      wind_delete( w.id );
      w.id = NO_WINDOW;         
   }
}



/* Open_Scanning()
 *==========================================================================
 * Displays the dialog box using 'Tree';
 * IN: flag = TRUE  - Display the dialog box.
 *          = FALSE - Generate the Redraw Message
 */
void
Scan_Message( OBJECT *Tree, BOOLEAN flag )
{  
     static GRECT rect;
     static GRECT xrect;
     
     if( flag )
     {
       xrect.g_x = xrect.g_y = 10;
       xrect.g_w = xrect.g_h = 36;
   
       Form_center( Tree, &rect );
       Form_dial( FMD_START, &xrect, &rect );
       Objc_draw( Tree, ROOT, MAX_DEPTH, &rect );
     }
     else
       Form_dial( FMD_FINISH, &xrect, &rect );
}
