/* HANDLERS.C
 * ================================================================
 * DATE April 14, 1992
 */
#include <alt\gemskel.h>
#include <alt\vdikeys.h>

#include <gemlib.h>
#include <dos.h>

#include "country.h"
#include "setup.h"
#include "text.h"
#include "gemskel.h"
#include "intro.h"
#include "file.h"
#include "menubind.h"
#include "dpath.h"
#include "drivers.h"
#include "fonts.h"
#include "apps.h"
#include "assign.h"
#include "extend.h"
#include "epath.h"


/* DEFINES
 * ================================================================
 */
#define F10  0x4400
#define MAX_DISKS 10
#define XFSM 1
typedef struct _pnode
{
    char name[21];
    char mname[21];
    char fname[15];
}PNODE;


/* PROTOTYPES
 * ================================================================
 */
void 	do_window( int *msg, int *event );
void	CrossDraw( GRECT *rect );

void	do_redraw( int *msg );
void	Do_Redraw( OBJECT *tree, GRECT *area );
void	do_move( int *msg );

void	SetNewDialog( OBJECT *newtree );
void	CheckExit( void );

void	do_cross_draw( OBJECT *tree, int obj );
void	DoComplete( void );

void	DoCopy( char *fname );
int	DoStart( void );
void	DoGDOS( void );


/* EXTERNS
 * ================================================================
 */


/* GLOBALS 
 * ================================================================
 */
OBJECT *tree;			/* Main tree Global Variable */
OBJECT *ad_intro;		/* Intro dialog box	     */
OBJECT *ad_tree;		/* Global Tree		     */
OBJECT *ad_path;		/* Destination Path Dialog   */
OBJECT *ad_driver;		/* Driver Dialog box	     */
OBJECT *ad_fonts;		/* Fonts Dialog box	     */
OBJECT *ad_apps;		/* application dialog box    */
OBJECT *ad_submenu;
OBJECT *ad_insert;
OBJECT *ad_complete;
OBJECT *ad_copy;
OBJECT *ad_start;
OBJECT *ad_assign;
OBJECT *ad_epath;
OBJECT *ad_extend;
OBJECT *ad_gdos;

int    wid = NIL;		/* window handle	     */

int    gl_gdos = XFSM;		/* Global flag - FSM or FONTGDOS*/
int    gl_numdisks = 0;
char   gl_disk_string[MAX_DISKS][128];
int    gl_num_printers = 0;
int    gl_printer = 0;

int    gl_assign;	/* assign dialog values */
int    gl_extend;	/* extend dialog values */

int    gl_meta = 1;		/* Copy over Meta.sys  */
int    gl_mem  = 1;		/* copy over memory.sys*/

int    gl_scalable = 0;
int    gl_fonts    = 0;
int    gl_nb15     = 0;
int    gl_slm      = 0;
int    gl_fx80     = 0;

int    gl_cpx      = 0;
int    gl_acc      = 0;
int    gl_pageomat = 0;
int    gl_move     = 0;

PNODE  MenuNode[ 20 ];


/* FUNCTIONS
 * ================================================================
 */


/* rsrc_init()
 * ================================================================
 */
BOOLEAN
rsrc_init( void )
{
   graf_mouse( ARROW, 0L );

   if( !rsrc_load( "INSTALL.RSC" ) )
       return( FALSE );

   rsrc_gaddr( 0, INTRO, &ad_intro );
   rsrc_gaddr( 0, DPATH, &ad_path );
   rsrc_gaddr( 0, DRIVERS, &ad_driver );
   rsrc_gaddr( 0, FONTS, &ad_fonts );
   rsrc_gaddr( 0, APPS, &ad_apps );
   rsrc_gaddr( 0, SUBMENU, &ad_submenu );
   rsrc_gaddr( 0, INSERT, &ad_insert );
   rsrc_gaddr( 0, COMPLETE, &ad_complete );
   rsrc_gaddr( 0, COPY, &ad_copy );
   rsrc_gaddr( 0, COMMENCE, &ad_start );
   rsrc_gaddr( 0, EASSIGN, &ad_assign );
   rsrc_gaddr( 0, EEXTEND, &ad_extend );
   rsrc_gaddr( 0, EPATH, &ad_epath );
   rsrc_gaddr( 0, GDOSTST, &ad_gdos );

   return( TRUE );      
}



/* rsrc_exit();
 * ================================================================
 */
void
rsrc_exit( void )
{
   /* Free up the DATA Buffer */
   if( data_buffer )
      Mfree( data_buffer );
    data_buffer = NULL;

   /* Close up and Free all the windows */
   if( wid > 0 )
   {
     wind_close( wid );
     wind_delete( wid );
   }

   /* Free up the Resource */
   rsrc_free();

   /* Free up the SubMenus and Popups */
   FreeMenus();
}





/* do_main()
 * ================================================================
 */
void
do_main( void )
{
   int result;
   
   do
   {
     /* Do Introduction Dialog Box */
     intro_dialog();
     result = TRUE;

     /* Do Assign.SYS Dialog Box */
     if( result )
         result = assign_dialog();

     /* Do APath Dialog Box */
     if( result )
         result = path_dialog();

     /* Do EXTEND.SYS Dialog Box */
     if( result )
        result = extend_dialog();

     /* Do EPATH Dialog Box */
     if( result )
         result = epath_dialog();

     /* Do Driver Dialog Box */
     if( result )
         result = driver_dialog();

#if 0

     /* Do Fonts Dialog Box */
     if( result )
         result = fonts_dialog();

     /* Do Application Dialog Box */
     if( result )
         result = apps_dialog();
#endif

     /* Do Start Dialog Box */
     if( result )
         result = DoStart();

     /* Go To main loop */
     if( result )
         DoInstall();

   }while( !result );

   /* Display Complete */
   if( vq_gdos() )
      DoGDOS();	     	/* Display warning of a previously loaded GDOS */
   else
     DoComplete();	/* Standard reboot exit message */
}



/* do_window()
 * ================================================================
 */
void
do_window( int *msg, int *event )
{
    switch( msg[0] )
    {
      case WM_REDRAW:   do_redraw( msg );
			break;
	

      case WM_TOPPED:	/* make this the top window */
			if( msg[3] == wid )
			    wind_set( msg[3], WF_TOP );
			break;	

      case WM_CLOSED:   CheckExit();
			break;	

      case WM_ARROWED:
			break;	

      case WM_HSLID:
			break;	
      case WM_VSLID:
			break;	

      case WM_MOVED:    do_move( msg );
			break;	

      default:
		break;
    }
}




/* CrossDraw()
 * ================================================================
 */
void
CrossDraw( GRECT *rect )
{
    int pxy[4];

    /* Upper Left to Lower Right */
    pxy[0] = rect->g_x;
    pxy[1] = rect->g_y;

    pxy[2] = rect->g_x + rect->g_w - 1;
    pxy[3] = rect->g_y + rect->g_h - 1;
    v_pline( vhandle, 2, pxy );

    /* Lower Left to Upper Right */
    pxy[0] = rect->g_x;
    pxy[1] = rect->g_y + rect->g_h - 1;

    pxy[2] = rect->g_x + rect->g_w - 1;
    pxy[3] = rect->g_y;
    v_pline( vhandle, 2, pxy );
}




/* do_redraw();
 * ================================================================
 */
void
do_redraw( int *msg )
{
   GRECT area;
   GRECT rect;

   area.g_x = msg[4];
   area.g_y = msg[5];
   area.g_w = msg[6];
   area.g_h = msg[7];

   graf_mouse( M_OFF, 0L );
   wind_update( BEG_UPDATE );
   wind_get( msg[3], WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );

   while( rect.g_w && rect.g_h )
   {
     if( rc_intersect( &area, &rect ) )
         ObjcDraw( tree, ROOT, MAX_DEPTH, &rect );

     wind_get( msg[3], WF_NEXTXYWH,&rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );
   }
   wind_update( END_UPDATE );
   graf_mouse( M_ON, 0L );
}



/* Do_Redraw();
 * ================================================================
 */
void
Do_Redraw( OBJECT *tree, GRECT *area )
{
   GRECT rect;

   graf_mouse( M_OFF, 0L );
   wind_update( BEG_UPDATE );
   wind_get( wid, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );

   while( rect.g_w && rect.g_h )
   {
     if( rc_intersect( area, &rect ) )
         ObjcDraw( tree, ROOT, MAX_DEPTH, &rect );

     wind_get( wid, WF_NEXTXYWH,&rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );
   }
   wind_update( END_UPDATE );
   graf_mouse( M_ON, 0L );
}




/* do_move()
 * ================================================================
 */
void
do_move( int *msg )
{
  if( msg[3] == wid )
  {
    gl_move     = TRUE;

    gl_curr.g_x = (( msg[4] + 7 ) / 8 ) * 8;
    gl_curr.g_y = msg[5];
    gl_curr.g_w = msg[6];
    gl_curr.g_h = msg[7];

    wind_set( msg[3], WF_CURRXYWH, gl_curr.g_x, gl_curr.g_y,
				   gl_curr.g_w, gl_curr.g_h );
    wind_get( msg[3], WF_WORKXYWH, &gl_work.g_x, &gl_work.g_y,
	                           &gl_work.g_w, &gl_work.g_h);

    ActiveTree( ad_tree );
    ObX( ROOT ) = gl_work.g_x;
    ObY( ROOT ) = gl_work.g_y;
  }

}



/* SetNewDialog()
 * ================================================================
 */
void
SetNewDialog( OBJECT *newtree )
{
    OBJECT *oldtree;
    GRECT  old;

    oldtree = ad_tree;
    ActiveTree( ad_tree );

    old.g_x = ObX( ROOT );   
    old.g_y = ObY( ROOT );   
    old.g_w = ObW( ROOT );   
    old.g_h = ObH( ROOT );   

    ad_tree = newtree;
    ActiveTree( ad_tree );
    
    /* If the window has never been moved, center it */
    if( !gl_move )
       FormCenter( ad_tree, &gl_work );

    ObX( ROOT ) = gl_work.g_x;
    ObY( ROOT ) = gl_work.g_y;
    gl_work.g_w = ObW( ROOT );
    gl_work.g_h = ObH( ROOT );

    wind_calc( WC_BORDER, MOVER | NAME | CLOSE,
	       gl_work.g_x, gl_work.g_y, gl_work.g_w, gl_work.g_h,
	       &gl_curr.g_x, &gl_curr.g_y, &gl_curr.g_w, &gl_curr.g_h );

    wind_set( wid, WF_CURRXYWH, gl_curr.g_x, gl_curr.g_y, gl_curr.g_w, gl_curr.g_h );
    if( gl_gdos == XFSM )
       wind_set( wid, WF_NAME, wfsm );
    else
       wind_set( wid, WF_NAME, wfont );

    /* Don't send a redraw message IF we are using an AES >= 4.0 */
	if( 1 /*AES_Version < 0x0400*/ )
	{
		/* Send a redraw message if this is the same dialog box */
		/* This is good for the insert disk dialog box */
		/* Also send a message if the new dialog box is smaller than or
		 * equal to the previous one, to generate a redraw.
		 */
		if((oldtree == newtree)||((old.g_w>=ObW(ROOT))||
			(old.g_h>=ObH( ROOT )) ))
		{
			form_dial( FMD_FINISH, gl_work.g_x, gl_work.g_y, 
					   gl_work.g_w, gl_work.g_h,
					   gl_work.g_x, gl_work.g_y, gl_work.g_w, 
					   gl_work.g_h );
		}
    }
    else
    {
	/* But, if its the same tree, force a redraw...*/
    if( oldtree == newtree ) 
    { 
	form_dial( FMD_FINISH, gl_work.g_x, gl_work.g_y, gl_work.g_w, gl_work.g_h,
			       gl_work.g_x, gl_work.g_y, gl_work.g_w, gl_work.g_h );
    }

    }

}



/* CheckExit()
 * ================================================================
 */
void
CheckExit( void )
{
   if( form_alert( 2, aexit ) == 1 )
       Gem_Exit( 0 );
}


/* do_cross_draw()
 * ================================================================
 */
void
do_cross_draw( OBJECT *tree, int obj )
{
   GRECT rect;

   objc_xywh( tree, obj, &rect );
   CrossDraw( &rect );
}


/* DoStart()
 * ================================================================
 */
int
DoStart( void )
{
    int msg[8];
    int button;
    int done;

    SetNewDialog( ad_start );

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case ZSETUP:  done = TRUE;
		       Deselect( ZSETUP );
		       break;

	 case ZEXIT:   CheckExit();
		       deselect( ad_tree, ZEXIT );
		       break;

	 default: if( button == NIL )
		  {
		     switch( msg[0] )
		     {
		        case  WM_CLOSED: return( FALSE );
					 break;

			case  CT_KEY:    if( msg[3] == K_F10 )
					   CheckExit();
					 break;
			default:
				 break;
		     }
		  }
		  break;
      }
    }while( !done );
    return( TRUE );
}


/* DoComplete()
 * ================================================================
 */
void
DoComplete( void )
{
    int msg[8];
    int button;
    int done;

    SetNewDialog( ad_complete );

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case CEXIT:   done = TRUE;
		       Deselect( CEXIT );
		       break;

	 default: if( button == NIL )
		  {
		     switch( msg[0] )
		     {
		        case  WM_CLOSED: done = TRUE;
					 break;

			case  CT_KEY:    if( msg[3] == K_F10 )
					   CheckExit();
					 break;
			default:
				 break;
		     }
		  }
		  break;
      }
    }while( !done );
}

/* DoCopy()
 * ================================================================
 */
void
DoCopy( char *fname )
{
   GRECT  area;
   int    flag;

   if( ad_tree == ad_copy )
       flag = TRUE;
   else
       flag = FALSE;
      
   ActiveTree( ad_copy );
   ObString( CFNAME ) = fname;

   if( !flag )
   {
      SetNewDialog( ad_copy );
      ObjcDraw( ad_copy, ROOT, MAX_DEPTH, NULL );
   }
   else
   {
      objc_xywh( ad_copy, CFNAME, &area );
      Do_Redraw( ad_copy, &area );
   }
}



/* DoGDOS()
 * ================================================================
 */
void
DoGDOS( void )
{
    int msg[8];
    int button;
    int done;

    SetNewDialog( ad_gdos );

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case GEXIT:   done = TRUE;
		       Deselect( GEXIT );
		       break;

	 default: if( button == NIL )
		  {
		     switch( msg[0] )
		     {
		        case  WM_CLOSED: done = TRUE;
					 break;

			case  CT_KEY:    if( msg[3] == K_F10 )
					   CheckExit();
					 break;
			default:
				 break;
		     }
		  }
		  break;
      }
    }while( !done );
}
