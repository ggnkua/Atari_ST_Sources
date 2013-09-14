/*==========================================================================
 * FILE: MAINSTUF.C
 *==========================================================================
 * DATE: November 20, 1992
 *
 * DESCRIPTION: Drivers ACC
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
 
 
 
#include "country.h"
#include "drivers.h"
#include "drvhead.h"

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "drivers.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "fixrsh.h"
#include "xform_do.h"
#include "windows.h"
#include "device.h"
#include "text.h"
#include "custom.h"
#include "path.h"
#include "modify.h"

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
OBJECT *ad_device;	/* tree for DEVICE dialog    */
OBJECT *ad_scan;	/* tree for scanning dialog  */
OBJECT *drivetree;
OBJECT *xytree;
OBJECT *ad_path;
OBJECT *ad_modify;

OBJECT *PrevTree;
int    ctrl_id;	/* ACC id slot # */




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
      ad_device  = ( OBJECT *)rs_trindex[ DEVICE ];
      ad_scan    = ( OBJECT *)rs_trindex[ SCAN ];
      drivetree  = ( OBJECT *)rs_trindex[ DRIVER ];
      xytree     = ( OBJECT *)rs_trindex[ XYREZ ];     
      ad_path    = ( OBJECT *)rs_trindex[ FONTPATH ];
      ad_modify  = ( OBJECT *)rs_trindex[ MODIFY ];

      /* Minor Adjustments */
      ActiveTree( ad_path );
      ObW( PPATH ) -= 1;

      ActiveTree( ad_device );
      ObW( DLINE )   -= 1;
      for( i = DLINE0; i<= DCOVER11; i += 1)
         ObW( i ) -= 1;

      ActiveTree( ad_front );
      ObW( FTITLE ) += 1;
      ObX( FUP )    += 1;
      ObX( FDOWN )  += 1;
      ObX( FBASE )  += 1;

      ObW( FTITLE1 ) += 1;
      ObW( FPRINTER ) += 1;

      ObW( FBOX1 )    += 1;
      
                        
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
   if(( AES_Version >= 0x0330 )
        && ( gl_ncolors > LWHITE ) )
   {
     Do3D();
   }

   init_window();
   
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
	
	/* Custom Tree Button Handling */
	if( IsActiveTree( ad_device ) )
	{
	    quit = handle_custom( button, msg );
	    continue;
	}    

	/* Driver Path Button Handling */
	if( IsActiveTree( ad_path ) )
	{
	    quit = Path_Button( button, msg );
	    continue;
	}    

	/* ADD/MODIFY Driver Button Handling */
	if( IsActiveTree( ad_modify ) )
	{
	    quit = Modify_Button( button, msg );
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
   /* Make the Front Dialog Box 3D.*/
   ActiveTree( ad_front );
   Make3D2( FREMOVE );
   Make3D2( FCONFIG );
   Make3D2( FCUSTOM );
   Make3D2( FSETPATH );
   Make3D2( FSAVE );
   Make3D2( FEXIT );
   
   Make3D1( FDRAFT );
   Make3D1( FFINAL );
 
   Make3DUpDown( FUP );
   Make3DUpDown( FDOWN );
   Make3DUpDown( FSLIDER );
   MakeBase( FUP, FDOWN, FSLIDER, FBASE, LINEBASE );
   MakeBoxText( FTITLE1, FALSE );
   ObW( FTITLE1 ) -= 1;
   MakeBoxText( FTITLE, FALSE );
 
 
   /* Make the Driver Parameter Editor Dialog Box 3D */
   ActiveTree( drivetree );
   Make3D2( DOK );
   Make3D2( DCANCEL );
   Make3D1( AREAON );
   Make3D1( AREAOFF );
   
   ActiveTree( xytree );
   Make3D2( XYOK );
   Make3D2( XYCANCEL );
 
 
   /* Make the Custom Dialog Box 3D.*/
   ActiveTree( ad_device );
   Make3D2( DADD );
   Make3D2( DMODIFY );
   Make3D2( DDELETE );
   Make3D2( DMENU );

   Make3DUpDown( DUP );
   Make3DUpDown( DDOWN );
   Make3DUpDown( DSLIDE );
   MakeBase( DUP, DDOWN, DSLIDE, DBASE, DLINE );
   MakeBoxText( DTITLE, FALSE );
   ObW( DTITLE2 ) += 1;
   TedColor( DTITLE2 ) = ( TedColor( DTITLE2 ) & 0xff70 ) | LWHITE | 0x70;
   
   
   /* Make the Modify/ADD Dialog Box 3D. */
   ActiveTree( ad_modify );
   Make3DUpDown( MUP );
   Make3DUpDown( MDOWN );
   MakeBoxText( MEDIT, FALSE );  
   ObH( MUP ) = ObH( MDOWN ) = ObH( MEDIT ) = gl_hbox;
   MakeBoxText( MTITLE, FALSE );  
   ObW( MTITLE ) -= 1;
   
   Make3D1( MROMYES );
   Make3D1( MROMNO );
   Make3D1( MRESYES );
   Make3D1( MRESNO );
   Make3D2( MOK );
   Make3D2( MCANCEL );
   
   
   /* Path Dialog Box to 3D */
   ActiveTree( ad_path );
   Make3D2( POK );
   Make3D2( PCANCEL );
   Make3DUpDown( PLEFT );
   Make3DUpDown( PRIGHT );
   MakeBoxText( PPATH, FALSE );
   ObH( PPATH ) = ObH( PLEFT ) = ObH( PRIGHT ) = gl_hbox;
   
   MakeBoxText( PTITLE1, FALSE );
   ObW( PTITLE1 ) -= 1;
   
   ObW( PTITLE2 ) += 1;
   TedColor( PTITLE2 ) = ( TedColor( PTITLE2 ) & 0xff70 ) | LWHITE | 0x70;
   MakeBoxText( PTITLE3, FALSE );
   ObW( PTITLE3 ) -= 1;
   
   
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


#if 0

void	test( void );
test();          


void
test( void )
{
   form_alert( 1, alert13 );
   form_alert( 1, alert56 );
   form_alert( 1, alert1 );
   form_alert( 1, alert2 );
   form_alert( 1, alert3 );
   form_alert( 1, alert4 );
   form_alert( 1, alert5 );
   form_alert( 1, alert6 );
   form_alert( 1, alert7 );
   form_alert( 1, alert10 );
   form_alert( 1, alert12 );
   form_alert( 1, alert50 );
   form_alert( 1, alert51 );
   form_alert( 1, alert52 );
   form_alert( 1, alert53 );
   form_alert( 1, alert54 );
   form_alert( 1, wider );
   form_alert( 1, alert55 );
   form_alert( 1, alert57 );
}
#endif