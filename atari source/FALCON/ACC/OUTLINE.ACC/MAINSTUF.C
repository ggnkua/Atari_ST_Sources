/*==========================================================================
 * FILE: MAINSTUF.C
 *==========================================================================
 * DATE: December 7, 1992	Combine the Bitmap and outline fonts together...
 *       December 15, 1992	AAAAGGGHHH - Remove the Bitmap Stuff again...
 *	 January  14, 1993	Changed to the new 3D format...
 *
 * DESCRIPTION: Fonts ACC
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
 
 
 
#include "country.h"
#include "fonts.h"
#include "fonthead.h"

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "fonts.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "fixrsh.h"
#include "xform_do.h"
#include "windows.h"
#include "front.h"
#include "text.h"
#include "inactive.h"
#include "options.h"
#include "path.h"
#include "points.h"
#include "custom.h"
#include "cache.h"
#include "printer.h"

/*
 * TURN OFF Turbo C " parameter X is never used" warnings.
 */
#pragma warn -par



/* PROTOTYPES
 *==========================================================================
 */
void    Activity( void );
void	XDeselect( OBJECT *tree, int button );
void	XSelect( OBJECT *tree, int button );
void	Do3D( void );
void	Make3D2( int obj );
void	Make3D1( int obj );
void	Make3DUpDown( int obj );
void	MakeBase( int up, int down, int slide, int base, int linebase );
void	MakeBoxText( int obj, int flag );
void	MakeIndicator( int obj );
void	MakeActivator( int obj );

void	RedrawObject( OBJECT *tree, int obj );
void	RedrawBase( OBJECT *tree, int obj );




/* DEFINES
 *==========================================================================
 */
#define UNDO	0x6100
#define MIN_RESOLUTION  639


/* EXTERNALS
 *==========================================================================
 */
extern int AES_Version;
extern int gl_ncolors;


/* GLOBALS
 *==========================================================================
 */
OBJECT *tree; 
OBJECT *ad_front;	/* tree for FRONT dialog     */
OBJECT *ad_scan;	/* tree for scanning dialog  */
OBJECT *ad_inactive;	/* tree for the available dialog*/
OBJECT *ad_options;	/* tree for options dialog */
OBJECT *ad_path;	/* tree for path dialog    */
OBJECT *ad_points;	/* tree for point size dialog*/
OBJECT *ad_cache;	/* tree for cache settings dialog */
OBJECT *ad_load;	/* tree for loading ...*/
OBJECT *ad_width;	/* tree for building width tables */
OBJECT *ad_add;		/* tree for adding point size */

OBJECT *PrevTree;
int    ctrl_id;		/* ACC id slot # */




/* FUNCTIONS
 *==========================================================================
 */
	

/* rsrc_init()
 * =======================================================================
 */
BOOLEAN
rsrc_init( void )			
{
      int i;

      if( !_app )
            ctrl_id = menu_register( gl_apid, menu_title );
      
      fix_rsh( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
               rs_object, rs_tedinfo, rs_strings, rs_iconblk,
               rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
               rs_imdope );
      
      ad_front   = ( OBJECT *)rs_trindex[ FRONT ];
      ad_scan    = ( OBJECT *)rs_trindex[ SCAN ];
      ad_inactive= ( OBJECT *)rs_trindex[ UNUSED ];
      ad_options = ( OBJECT *)rs_trindex[ OPTIONS ];
      ad_path    = ( OBJECT *)rs_trindex[ PATHTREE ];
      ad_points  = ( OBJECT *)rs_trindex[ PNTSIZE ];
      ad_cache   = ( OBJECT *)rs_trindex[ CACHE ];
      ad_load	 = ( OBJECT *)rs_trindex[ LOADING ];
      ad_width   = ( OBJECT *)rs_trindex[ MAKEWID ];
      ad_add     = ( OBJECT *)rs_trindex[ ADD ];
      

      /* Minor Adjustments - to align the sliders and text boxes...*/
      ActiveTree( ad_front );
      for( i = LINEBASE; i <= LINE13; i++ )
        ObW( i ) -= 1;

      ActiveTree( ad_inactive );
      for( i = ILINE; i <= ILINE13; i++ )
        ObW( i ) -= 1;


      ActiveTree( ad_points );
      for( i = PNTLINE; i <= PNTLINE5; i++ )
        ObW( i ) -= 1;


      ActiveTree( ad_front );              
      PrevTree   = ( OBJECT *)NULL;
      
      /* Get Cookie to see if we are using at least XGDOS */
      Supexec( get_cookie );

      return( TRUE );
}



/* wind_init()
 * =====================================================================
 * Initialize window structure.
 */
void
wind_init( void )
{
   if(( AES_Version >= 0x0330 )
        && ( gl_ncolors > LWHITE ) )
   {
     Do3D();
   }

   init_window();
   Get_Default_Cache();
   
   if( _app )
   {
      if( xres >= MIN_RESOLUTION )
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
      {
	  form_alert( 1, wider );
	  gem_exit( 0 );
      }
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

	/* Available Fonts Tree Button Handling */
	if( IsActiveTree( ad_inactive ) )
	{
	    quit = HandleAvailable( button, msg );
	    continue;
	}    

	/* Options Tree Button Handling */
	if( IsActiveTree( ad_options ) )
	{
	    quit = HandleOptions( button, msg );
	    continue;
	}    
	
	/* Path Tree Button Handling */
	if( IsActiveTree( ad_path ) )
	{
	    quit = HandlePath( button, msg );
	    continue;
	}    


	/* Points Tree Button Handling */
	if( IsActiveTree( ad_points ) )
	{
	    quit = HandlePoints( button, msg );
	    continue;
	}    


	/* Cache Tree Button Handling */
	if( IsActiveTree( ad_cache ) )
	{
	    quit = HandleCache( button, msg );
	    continue;
	}    


	/* Add Pointsize Tree Button Handling */
	if( IsActiveTree( ad_add ) )
	{
	    quit = HandleAdd( button, msg );
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
        if( xres >= MIN_RESOLUTION )
	{
          if( Create_Window() )
          {
            ActiveTree( ad_front );
            initialize();
            open_window();
            Activity();
          }
          else
            form_alert( 1, alert13 );
	}
	else
            form_alert( 1, wider );
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



/* XDeselect()
 * =====================================================================
 */
void
XDeselect( OBJECT *tree, int button )
{
   GRECT rect;

   Deselect( button );
   rect = ObRect( button );
   objc_offset( tree, button, &rect.g_x, &rect.g_y );
   rect.g_x -= 5;
   rect.g_y -= 5;
   rect.g_w += 10;
   rect.g_h += 10;
   Objc_draw( tree, button, MAX_DEPTH, &rect );
}



/* XSelect()
 * =====================================================================
 */
void
XSelect( OBJECT *tree, int button )
{
   GRECT rect;

   Select( button );
   rect = ObRect( button );
   objc_offset( tree, button, &rect.g_x, &rect.g_y );
   rect.g_x -= 5;
   rect.g_y -= 5;
   rect.g_w += 10;
   rect.g_h += 10;
   Objc_draw( tree, button, MAX_DEPTH, &rect );
}

/* Do3D()
 * =====================================================================
 * An Ugly way to make everything 3D...
 */
void
Do3D( void )
{
   /* Make the Front Dialog Box 3D.- INSTALLED FONTS */
   ActiveTree( ad_front );
   Make3D2( FREMOVE );
   Make3D2( FCONFIG );
   Make3D2( FADD );
   Make3D2( FOPTIONS );
   Make3D2( FSAVE );
   Make3D2( FEXIT );
   Make3D2( FINSTALL );
   Make3DUpDown( FUP );
   Make3DUpDown( FDOWN );
   Make3DUpDown( FSLIDER );
   MakeBase( FUP, FDOWN, FSLIDER, FBASE, LINEBASE );
   MakeBoxText( FTITLE, FALSE );

   /* Make Available Fonts Dialog Box 3D */
   ActiveTree( ad_inactive );
   Make3D2( IINSTALL );
   Make3D2( ICONFIG );
   Make3D2( IEXIT );
   Make3D2( ISELECT );
   Make3DUpDown( IUP );
   Make3DUpDown( IDOWN );
   Make3DUpDown( ISLIDER );
   MakeBase( IUP, IDOWN, ISLIDER, IBASE, ILINE );
   MakeBoxText( ITITLE, FALSE );
      
   /* Make Options Dialog Box 3D */
   ActiveTree( ad_options );
   Make3D2( WBUILD );
   Make3D2( WEXIT );
   Make3D2( WCANCEL );
   Make3D2( OOK );
   Make3D2( OPATH );
   Make3D2( OPOINT );
   Make3D2( OCACHE );
   Make3D2( OWIDTH );
   Make3D1( WON );
   Make3D1( WOFF );
   MakeBoxText( OTITLE, FALSE );
   ObW( OTITLE ) -= 1;
   ObH( WON ) -= 2;
   ObH( WOFF ) -= 2;
   MakeBoxText( OTITLE3, FALSE );
   ObW( OTITLE3 ) -= 1;
     
   /* Make Path Tree Dialog Box 3D */
   ActiveTree( ad_path );
   Make3D2( PEXIT );
   Make3D2( PCANCEL );
   Make3DUpDown( OLEFT );
   Make3DUpDown( ORIGHT );
   MakeBoxText( OPATHS, FALSE );
   MakeBoxText( OTITLE2, FALSE );
   ObW( OTITLE2 ) -= 1;
   ObH( OPATHS ) = gl_hbox;
   ObH( OLEFT ) = ObH( ORIGHT ) = gl_hbox;
 
 
   /* Make Add Points Dialog Box 3D */
   ActiveTree( ad_points );
   Make3D2( POINTOK );
   Make3D2( POINTCAN );
   Make3D2( PNTADD );
   Make3D2( PNTDEL );
   Make3D2( PNTDEF );
   Make3D1( P10 );      
   Make3D1( P12 );      
   Make3D1( P18 );      
   Make3D1( P24 );      
   Make3D1( P48 );      
   Make3DUpDown( PNTUP );
   Make3DUpDown( PNTDOWN );
   Make3DUpDown( PNTSLIDE );
   MakeBase( PNTUP, PNTDOWN, PNTSLIDE, PNTBASE, PNTLINE );
   MakeBoxText( PTITLE1, FALSE );
   ObW( PTITLE1 ) -= 1;
   MakeBoxText( PTITLE4, FALSE );
   

   /* Make Cache Dialog Box 3D */
   ActiveTree( ad_cache );
   Make3D2( COK );
   Make3D2( CCANCEL );
   Make3D2( LCACHE );
   Make3D2( MCACHE );
   Make3D2( SCACHE );
   Make3D2( CCACHE );
   MakeBoxText( CTITLE1, FALSE );
   ObW( CTITLE1 ) -= 1;
   MakeBoxText( CTITLE2, FALSE );
   ObW( CTITLE2 ) -= 1;
   MakeBoxText( TITLE2, FALSE );
   ObW( TITLE2 ) -= 1;
   Make3DUpDown( CUP );
   Make3DUpDown( CDOWN );
   Make3DUpDown( MUP );
   Make3DUpDown( MDOWN );
   Make3DUpDown( BUP );
   Make3DUpDown( BDOWN );
   ObH( CUP ) = gl_hbox - 2;
   ObH( CDOWN ) = ObH( MUP ) = ObH( MDOWN ) = ObH( BUP ) = ObH( BDOWN ) = ObH( CUP );
   

   /* Make add point size dialog box 3D */
   ActiveTree( ad_add );
   Make3D2( ADDOK );
   Make3D2( ADDCAN );
   MakeBoxText( ADDTITLE, FALSE );
   ObW( ADDTITLE ) -= 1;
   Make3DUpDown( ADDUP );
   Make3DUpDown( ADDDOWN );
   ObH( ADDUP ) -= 2;
   ObH( ADDDOWN ) -= 2;
      
   /* Restore original tree */
   ActiveTree( ad_front );
}


void
Make3DUpDown( int obj )
{
   MakeActivator( obj );
   ObIndex( obj ) = (LONG)( ( LONG )ObIndex( obj ) & 0xffffff70L ) | (LONG)LWHITE | 0x70L;
   ObH( obj ) = gl_hbox;
}



/* Good for Buttons */
void
Make3D2( int obj )
{
   MakeActivator( obj );
   ObH( obj )  = gl_hbox;

   ObX( obj ) += 1;
   ObY( obj ) += 2;
   ObW( obj ) -= 2;
   ObH( obj ) -= 3;
}
 
 
void
Make3D1( int obj )
{
   MakeIndicator( obj );
   ObH( obj )  = gl_hbox;

   ObX( obj ) += 1;
   ObY( obj ) += 2;
   ObW( obj ) -= 2;
   ObH( obj ) -= 3;
}

 
void
MakeBase( int up, int down, int slide, int base, int linebase )
{
    MakeActivator( base );

    ObY( up )   = ObY( linebase ) + 2;
    ObY( down ) = ObY( linebase ) + ObH( linebase ) - ObH( down ) - 2;
    ObX( down ) = ObX( base ) = ObX( up ) = ObX( linebase ) + ObW( linebase ) + 3;
    ObW( up ) -= 3;
    ObW( down ) = ObW( base ) = ObW( slide ) = ObW( up );
     
    ObY( base ) = ObY( up ) + ObH( up ) + 5;
    ObH( base ) = ( ObY( down ) - 5 ) - ObY( base );
}

void
MakeBoxText( int obj, int flag )
{
   MakeActivator( obj );
   TedColor( obj ) = ( TedColor( obj ) & 0xff70 ) | LWHITE | 0x70;
   ObH( obj )  = gl_hbox;

   ObX( obj ) += 2;
   if( flag )
      ObY( obj ) += 2;
   ObW( obj ) -= 3;
   ObH( obj ) -= 3;
}



void
MakeIndicator( int obj )
{
   ObFlags( obj ) |= IS3DOBJ;
   ObFlags( obj ) &= ~IS3DACT;
}


void
MakeActivator( int obj )
{
   ObFlags( obj ) |= IS3DOBJ;
   ObFlags( obj ) |= IS3DACT;
}




void
RedrawObject( OBJECT *tree, int obj )
{
   GRECT rect;
   
   rect = ObRect( obj );
   objc_offset( tree, obj, &rect.g_x, &rect.g_y );
   rect.g_x -= 5;
   rect.g_y -= 5;
   rect.g_w += 10;
   rect.g_h += 10;
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
}


void
RedrawBase( OBJECT *tree, int obj )
{
   GRECT rect;
   
   rect = ObRect( obj );
   objc_offset( tree, obj, &rect.g_x, &rect.g_y );
   rect.g_x -= 1;
   rect.g_y -= 1;
   rect.g_w += 2;
   rect.g_h += 2;
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
}
 
 
 

#if 0
void	test( void );

test();


void
test( void )
{
   form_alert( 1, alert13 );
   form_alert( 1, alerte11 );
   form_alert( 1, alert56 );
   form_alert( 1, alert58 );
   form_alert( 1, alert2 );
   form_alert( 1, alert3 );
   form_alert( 1, alert10 );
   form_alert( 1, alert12 );
   form_alert( 1, wider );
   form_alert( 1, alert17 );
   form_alert( 1, alert18 );
   form_alert( 1, alert19 );
   form_alert( 1, alert21 );
   form_alert( 1, alert22 );
   form_alert( 1, alertw3 );
   form_alert( 1, alertw16 );
   form_alert( 1, alertw4 );
   form_alert( 1, alertw5 );
   form_alert( 1, pnt1 );
   form_alert( 1, alertdel );
   form_alert( 1, alertpnt14 );
   form_alert( 1, alertpnt15 );
   form_alert( 1, alertpnt20 );
   form_alert( 1, alertpnt23 );
   form_alert( 1, point_invalid );
   form_alert( 1, point_exists );
   form_alert( 1, point_noroom );
   form_alert( 1, nomore );
   form_alert( 1, showall );
   form_alert( 1, selall );
   form_alert( 1, nosel );
   form_alert( 1, nofile );
}
 
#endif