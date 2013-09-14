/* APPS.C
 * ================================================================
 * Handles the CPX, ACC and other Dialog Box
 * DATE: April 17, 1992
 */
#include <alt\gemskel.h>
#include <alt\vdikeys.h>
#include <gemlib.h>


#include "country.h"
#include "setup.h"
#include "text.h"
#include "gemskel.h"
#include "handlers.h"



/* DEFINES
 * ================================================================
 */


/* EXTERNS
 * ================================================================
 */


/* PROTOTYPES
 * ================================================================
 */
int	apps_dialog( void );
void	SetAppsWindow( void );
int	apps_handler( void );
void	apps_redraw( int *msg );
void	apps_draw_button( int flag, int obj );


/* GLOBALS
 * ================================================================
 */



/* FUNCTIONS
 * ================================================================
 */


/* apps_dialog()
 * ================================================================
 */
int
apps_dialog( void )
{
   int num;
   int flag;

   ActiveTree( ad_apps );



   /* Get CPX Path */
   num = Check_CPX();   

   if( num )
   {
      /* No CONTROL.INF file */
      if( num == 1 )
	   form_alert( 1, no_cpxfile );

      /* Invalid CPX Path */
      if( num == 2 )
	   form_alert( 1, no_cpxpath );
      Disable( ACPX );
      Disable( ACPX2 );     
      NoTouchexit( ACPX2 );
      NoTouchexit( ACPX );
   }
   SetAppsWindow();

   flag = apps_handler();
   return( flag );
}


/* SetAppsWindow()
 * ================================================================
 */
void
SetAppsWindow()
{
      SetNewDialog( ad_apps );
}


/* apps_handler()
 * ================================================================
 */
int
apps_handler( void )
{
    int msg[8];
    int button;
    int done;

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case ASETUP:   done = TRUE;
			Deselect( ASETUP );
			break;

	 case AEXIT:    CheckExit();
			deselect( ad_tree, AEXIT );
			break;

	 case ACPX:
	 case ACPX2: gl_cpx ^= 1;
		     apps_draw_button( gl_cpx, ACPX2 );
		     break;

	 case AACC:
	 case AACC2: gl_acc ^= 1;
		     apps_draw_button( gl_acc, AACC2 );
		     break;

	 case APAGE:
	 case APAGE2: gl_pageomat ^= 1;
		      apps_draw_button( gl_pageomat, APAGE2 );
		      break;

	 default: if( button == NIL )
		  {
		     switch( msg[0] )
		     {
			case  WM_REDRAW: apps_redraw( msg );
					 break;

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


/* apps_redraw()
 * ================================================================
 */
void
apps_redraw( int *msg )
{
   GRECT area;
   GRECT rect;
   int   clip[4];

   area.g_x = msg[4];
   area.g_y = msg[5];
   area.g_w = msg[6];
   area.g_h = msg[7];

   graf_mouse( M_OFF, 0L );
   wind_get( msg[3], WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );

   while( rect.g_w && rect.g_h )
   {
     if( rc_intersect( &area, &rect ) )
     {
	 rc_2xy( &rect, clip );
	 vs_clip( vhandle, 1, clip );
/*	 ObjcDraw( ad_apps, ROOT, MAX_DEPTH, &rect );*/

	 /* Redraw CPXs */
	 if( gl_cpx )
	     do_cross_draw( ad_apps, ACPX2 );

	 /* Redraw ACC  */
	 if( gl_acc )
	     do_cross_draw( ad_apps, AACC2 );
		
	 /* Redraw pageomat */
         if( gl_pageomat )
	     do_cross_draw( ad_apps, APAGE2 );
     }
     wind_get( msg[3], WF_NEXTXYWH,&rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );
   }
   vs_clip( vhandle, 0, clip );
   graf_mouse( M_ON, 0L );
}


/* apps_draw_button()
 * ================================================================
 */
void
apps_draw_button( int flag, int obj )
{
   GRECT clip;
   int   msg[8];
   int   dummy;

   if( flag )
   {
     objc_xywh( ad_apps, obj, &clip );
     msg[3] = wid;
     msg[4] = clip.g_x;
     msg[5] = clip.g_y;
     msg[6] = clip.g_w;
     msg[7] = clip.g_h;
     apps_redraw( msg );
   }
   else
     ObjcDraw( ad_apps, obj, MAX_DEPTH, NULL );
   evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
}
