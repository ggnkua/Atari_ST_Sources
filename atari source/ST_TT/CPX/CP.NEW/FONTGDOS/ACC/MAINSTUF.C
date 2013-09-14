/*==========================================================================
 * FILE: MAINSTUF.C
 *==========================================================================
 * DATE: December 19, 1990
 * DESCRIPTION: Font GDOS - BITMAP Font CPX Manager
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
 
#include "country.h"

#include "choice.h"

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "choice.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "fixrsh.h"
#include "xform_do.h"
#include "windows.h"

#include "popup.h"
#include "inactive.h"

#include "fonthead.h"
#include "fsmio.h"
#include "mover.h"

#include "path.h"
#include "edit.h"
#include "text.h"

#include "fontacc.h"

/*
 * TURN OFF Turbo C " parameter X is never used" warnings.
 */
#pragma warn -par



/* PROTOTYPES
 *==========================================================================
 */
void Activity( void );


/* DEFINES
 *==========================================================================
 */
#define UNDO	0x6100


/* EXTERNALS
 *==========================================================================
 */

/* GLOBALS
 *==========================================================================
 */
OBJECT *tree; 
OBJECT *ad_inactive;	/* Outline Tree              */
OBJECT *ad_active;	/* Font GDOS tree            */
OBJECT *ad_scan;	/* scan message tree	     */
OBJECT *ad_path;	/* tree for setting font path*/
OBJECT *ad_edit;	/* tree for editing devices  */
OBJECT *ad_front;	/* tree for FONT dialog      */
OBJECT *ad_menu;	/* tree for main menu dialog */

OBJECT *PrevTree;



int	ctrl_id;	/* ACC id slot # */


/* FUNCTIONS
 *==========================================================================
 */
	

/* rsrc_init()
 * =======================================================================
 */
BOOLEAN
rsrc_init( void )			
{
      fix_rsh( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
               rs_object, rs_tedinfo, rs_strings, rs_iconblk,
               rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
               rs_imdope );
      
      ad_inactive= ( OBJECT *)rs_trindex[ INACTIVE ];
      ad_active  = ( OBJECT *)rs_trindex[ FONTGDOS ];
      ad_scan    = ( OBJECT *)rs_trindex[ SCANMSG ];
      ad_path    = ( OBJECT *)rs_trindex[ PATH ];
      ad_edit	 = ( OBJECT *)rs_trindex[ EDIT ];
      ad_front   = ( OBJECT *)rs_trindex[ FRONT ];
      ad_menu    = ( OBJECT *)rs_trindex[ MMENU ];
            
      /* Initialize the DRAFT/FINAL flag based on the cookie */
      Supexec( get_cookie );

      PrevTree   = ( OBJECT *)NULL;
      return( TRUE );
}


/* wind_init()
 * =====================================================================
 * Initialize window structure.
 */
void
wind_init( void )
{
   if( !_app )
      ctrl_id = menu_register( gl_apid, menu_title );
      
   init_window();
   
   if( _app )
   {
      if( Create_Window() )
      {
        ActiveTree( ad_front );
        initialize();
        open_window();
        graf_mouse( ARROW, 0L );
        Activity();
      }
      else
        form_alert( 1, alert13 );
   }
}
 

/* evnt_init()
 * =====================================================================
 * Initialize the evnt_multi with the proper messages, timers etc...
 */
void
evnt_init( void )
{
   evnt_set( MU_MESAG, -1, -1, -1, NULL, NULL, -1L );
}



/* Activity()
 * =====================================================================
 * The KEY call to enter the XFORM_DO()
 */
void
Activity( void )
{
   int 	quit = FALSE;
   WORD button;
   WORD msg[8];
   
   do
   {
   	button = xform_do( tree, 0, msg );

	/* Front Tree Button Handling */
	if( IsActiveTree( ad_front ) )
	{
	    quit = handle_front( button, msg );
	    continue;
	}    

	/* MainTree Button Handling */
	if( IsActiveTree( ad_active ) )
	{
	    quit = handle_button( button, msg );
	    continue;
	}    

	/* Inactive Font Button Handling */
	if( IsActiveTree( ad_inactive ))
	{
	    quit = InActive_Button( button, msg );
	    continue;
	}    
	
	/* Font Path Button Handling */
	if( IsActiveTree( ad_path ) )
	{
	    quit = Path_Button( button, msg );
	    continue;
	}
	
	/* Edit Devices Button handling */
	if( IsActiveTree( ad_edit ) )
	{
	    quit = Edit_Button( button, msg );
	    continue;
	}

	/* Main Menu Button Handling */
	if( IsActiveTree( ad_menu ) )
	{
	    quit = Handle_Menu( button, msg );
	    continue;
	}
		
   	
   }while( !quit );
   
   if( CheckAccClose() )
     return;
   
   Wm_Closed( (int*)msg );
}



/* do_windows()
 * =====================================================================
 * wndow handling.
 *
 * IN: int *msg:   message buffer
 *     int *event: flag to end the program.
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
 * =====================================================================
 * Accessory Open Messages
 * 
 * IN: int *msg: message buffer;
 * OUT: void
 *
 * GLOBAL: WINFO w:   window structure
 *         int   ctrl_id: application id
 */
void
acc_open( const int *msg )
{
    if( msg[4] == ctrl_id )
    {
      if( w.id == NO_WINDOW )
      {
        if( Create_Window() )
        {
          ActiveTree( ad_front );
          initialize();
          open_window();
          graf_mouse( ARROW, 0L );
          Activity();
        }
        else
          form_alert( 1, alert13 );
      }
      else
        wind_set( w.id, WF_TOP );
    }
}



/* acc_close()
 * =====================================================================
 * Accessory Close message
 *
 * IN:  int *msg:	message buffer
 * OUT: void
 *
 * GLOBAL: int ctrl_id:    application id
 *         WINFO w;	   window structure
 *
 * Closing and deleting the window are unneccesary since the window
 * handles are already invalid by the time we get the acc_close() message
 */
void
acc_close( const int *msg )
{
   if( ( msg[3] == ctrl_id ) && ( w.id != NO_WINDOW ) )
   {
       w.id = NO_WINDOW;
   }
}





/* do_button()
 * =====================================================================
 * Button Handling routines
 */
void
do_button( MRETS *mrets, int nclicks, int *event )
{
}



/* do_timer()
 * =====================================================================
 */
void
do_timer( int *event )
{
}


/* do_key()
 * =====================================================================
 * Should never be called...
 */
void
do_key( int kstate, int key, int *event )
{
}


/* do_m1()
 * =====================================================================
 */
void
do_m1( MRETS *mrets, int *event )
{
}


/* do_m2()
 * =====================================================================
 */
void
do_m2( MRETS *mrets, int *event )
{
}



/* evnt_hook()
 * =====================================================================
 */
BOOLEAN
evnt_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks )
{
   return( FALSE );
}




/* wind_exit()
 * =====================================================================
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





