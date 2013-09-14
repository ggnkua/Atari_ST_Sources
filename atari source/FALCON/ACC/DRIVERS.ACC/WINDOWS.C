/* FILE:  WINDOWS.C
 *==========================================================================
 * DATE:  November 20, 1992
 * DESCRIPTION: Window Routines for DRIVERS.ACC
 *
 * INCLUDE FILES:   WINDOWS.H
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
 
#include "country.h"
#include "drivers.h"

#include "mainstuf.h"
#include "device.h"
#include "text.h"



/* PROTOTYPES
 *==========================================================================
 */
void	init_window( void );
void	Wm_Redraw( int *msg );
void	Wm_Topped( int *msg );
void	Wm_Closed( int *msg );
void	Wm_Moved( int *msg );
BOOLEAN Create_Window( void );
void	open_window( void );
void	do_redraw( OBJECT *tree, GRECT *prect );
void	GrowShrinkBox( BOOLEAN flag );
void	Send_Redraw( GRECT *rect );



/* DEFINES
 *==========================================================================
 */
#define NO_WINDOW 	( -1 )
#define WKIND		( NAME | CLOSER | MOVER )
#define GROWBOX		0
#define SHRINKBOX	1


/* EXTERNS
 *==========================================================================
 */
EXTERN int AES_Version;
EXTERN int gl_ncolors;


/* GLOBALS
 *==========================================================================
 */
int     WIND_WIDTH;
int     WIND_HEIGHT;
WINFO	w;				/* w.r == outer area of window
					 * w.work == work area of window
				         * w.phy  == work area of config
					 * w.work is also the work area of
					 * the cpxs
					 */
					



/* FUNCTIONS
 *==========================================================================
 */


/* init_window()
 *==========================================================================
 * Initialize the window dimensions, parts and structures
 *
 * IN:  void
 * OUT: void
 *
 * GLOBAL:	WINFO w:	window structure
 */
void
init_window( void )
{
   ActiveTree( ad_front );
   WIND_WIDTH = ObW( FRONT );
   WIND_HEIGHT = ObH( FRONT );

   w.kind     = WKIND;
   w.id       = NO_WINDOW;     
   strcpy( w.name, window_title );
   w.wchar    = gl_wbox;
   w.hchar    = gl_hbox;
   w.work.g_x = desk.g_x;
   w.work.g_y = desk.g_y;
   
   w.work.g_w = WIND_WIDTH;
   w.work.g_h = WIND_HEIGHT;

   /* Convert to 3D if possible - ONLY if AES 0x0330 or Greater */
   if( AES_Version >= 0x0330 )
      w.work.g_h = WIND_HEIGHT + 4;

   w.fulled   = FALSE;
}





/* Wm_Redraw()
 *==========================================================================
 * Handle main event_multi window redraw messages.
 * 
 * IN:  int *msg:	Event messages
 * OUT: void
 *
 * GLOBAL:     WINFO  w:       window structure
 *	       int xconfig:    The index of which config routine is active
 *			       -1 when none active
 */
void
Wm_Redraw( int *msg )
{
   GRECT  *rect;

   if( msg[3] == w.id )
   {
      rect = (GRECT *)&msg[4];
      do_redraw( tree, rect );
   }      
}






/* Wm_Topped()
 *==========================================================================
 * Handle main event_multi window topped messages
 */
void
Wm_Topped( int *msg )
{
   if( msg[3] == w.id )
   {
         wind_set( w.id, WF_TOP );
   }         
}





/* Wm_Closed()
 *==========================================================================
 * Handle main event_multi window close messages
 *
 * IN:   int *msg:		Event messages
 * OUT:  void
 *
 * GLOBAL:	WINFO w:	window structure messages
 *		_app:		TRUE- we ran as a PRG file
 */
void
Wm_Closed( int *msg )
{
   if( msg[3] == w.id )
   {
      wind_close( w.id );
      wind_delete( w.id );
      GrowShrinkBox( SHRINKBOX );
      w.id = NO_WINDOW;

      if( _app )
  	  gem_exit( 0 );
   }
}






/* Wm_Moved()
 *==========================================================================
 * Handle main event_multi window moved messages.
 *
 * IN:   int *msg:	Event messages
 * OUT:  void
 *
 * GLOBAL:    WINFO w:  window structure
 */
void
Wm_Moved( int *msg )
{
   GRECT  *rect;

   if( msg[3] == w.id )
   {
     rect = (GRECT *)&msg[4];
     w.r  = *rect;
     Wind_set( w.id, WF_CURRXYWH, ( WARGS *)&w.r );
     Wind_get( w.id, WF_WORKXYWH, ( WARGS *)&w.work );
     ObX( ROOT ) = w.work.g_x;
     ObY( ROOT ) = w.work.g_y;
   }
}




/* Create_Window()
 *==========================================================================
 * Creates the Window for the open_window() call.
 * This must be called before
 */
BOOLEAN
Create_Window( void )
{
    if( (w.id = Wind_create( w.kind, &desk )) < 0 )
    {
    	w.id = NO_WINDOW;
    	return( FALSE );
    }
    return( TRUE );    
}




/* open_window()
 *==========================================================================
 * Open the Xcontrol window
 *
 * IN:  VOID
 * OUT: BOOLEAN:	TRUE if window opening was success
 *
 * GLOBAL:  WINFO w:	window structure
 */
void
open_window( void )
{
    wind_set( w.id, WF_NAME, w.name );

    /* cjg - re-init window width and height every time we open */
    w.work.g_w = WIND_WIDTH;
    w.work.g_h = WIND_HEIGHT;

   /* Convert to 3D if possible - ONLY if AES 0x0330 or Greater */
   if( AES_Version >= 0x0330 )
      w.work.g_h = WIND_HEIGHT + 4;
    
    Wind_calc( 0, w.kind, &w.work, &w.r );
    w.r.g_x = max( desk.g_x, (desk.g_w - w.r.g_w )/2 );
    w.r.g_y = max( desk.g_y, (desk.g_h - w.r.g_h )/2 );
    Wind_calc( 1, w.kind, &w.r, &w.work );

    GrowShrinkBox( GROWBOX );    
    Wind_open( w.id, &w.r );  

    wind_get( w.id, WF_WORKXYWH, &w.work.g_w,&w.work.g_y,&w.work.g_w,&w.work.g_h );
    wind_get( w.id, WF_CURRXYWH, &w.r.g_x,&w.r.g_y,&w.r.g_w,&w.r.g_h );
    
    ObX( FRONT ) = w.work.g_x;
    ObY( FRONT ) = w.work.g_y;
}




/* do_redraw()
 *==========================================================================
 * Standard object tree redraw routine for handling object trees
 *
 * IN:  OBJECT *tree:    	object tree
 *      int    object:		object to redraw
 *	GRECT  *prect:		GRECT of dirtied area
 *
 * OUT: void
 *
 * GLOBAL:  WINFO  w:		window structure
 */
void
do_redraw( OBJECT *tree, GRECT *prect )
{
   GRECT rect;
   
   Wind_get( w.id, WF_FIRSTXYWH, ( WARGS *)&rect );
   while( !rc_empty( &rect ) )
   {
       if( rc_intersect( prect, &rect ))
       {
       	  Vsync();
 	  Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
       }
       Wind_get( w.id, WF_NEXTXYWH, ( WARGS *)&rect );
   }
}






/* GrowShrinkBox()
 *==========================================================================
 * Perform a Grow or Shrink Box animation
 *
 * IN:   BOOLEAN flag:		Flag for grow or shrink
 * OUT:  void
 *
 * GLOBAL:   WINFO w:		Window structure
 */
void
GrowShrinkBox( BOOLEAN flag )
{
    GRECT rect;

    rect      = w.r;
    rect.g_x += rect.g_w / 2;
    rect.g_y += rect.g_h / 2;

    if( !flag )
    {
       rect.g_w = gl_wbox * 2;
       rect.g_h = gl_hbox * 2;
       Graf_growbox( &rect, &w.r );
    }
    else
    {
       rect.g_w = gl_wbox;
       rect.g_h = gl_hbox;
       Graf_shrinkbox( &rect, &w.r );
    }
}



/* Send_Redraw()
 *==========================================================================
 * Force the sending of a redraw message.
 * IN: GRECT *rect:	The GRECT of the dirty area
 * OUT: void
 */
void
Send_Redraw( GRECT *rect )
{
     int msg_buff[8];
     
     msg_buff[0] = WM_REDRAW;
     msg_buff[1] = gl_apid;
     msg_buff[2] = 0;
     msg_buff[3] = (int)w.id;
     msg_buff[4] = rect->g_x;
     msg_buff[5] = rect->g_y;
     msg_buff[6] = rect->g_w;
     msg_buff[7] = rect->g_h;
     appl_write( gl_apid, 16, msg_buff );
}
