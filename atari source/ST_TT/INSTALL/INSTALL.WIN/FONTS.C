/* FONTS.C
 * ================================================================
 * Handles the Fonts Dialog Box
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
int	fonts_dialog( void );
void	SetFontsWindow( void );
int	fonts_handler( void );
void	fonts_redraw( int *msg );
void	draw_button( int flag, int obj );


/* GLOBALS
 * ================================================================
 */



/* FUNCTIONS
 * ================================================================
 */


/* fonts_dialog()
 * ================================================================
 */
int
fonts_dialog( void )
{
   int flag;

   ActiveTree( ad_fonts );

   SetFontsWindow();

   flag = fonts_handler();
   return( flag );
}


/* SetDriverWindow()
 * ================================================================
 */
void
SetFontsWindow()
{
      SetNewDialog( ad_fonts );
}


/* fonts_handler()
 * ================================================================
 */
int
fonts_handler( void )
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
	 case FSETUP:   done = TRUE;
			Deselect( FSETUP );
			break;

	 case FEXIT:    CheckExit();
			deselect( ad_tree, FEXIT );
			break;

	 case FFSM:	
	 case FFSM2: gl_scalable ^= 1;	
		     draw_button( gl_scalable, FFSM2 );
		     break;

	 case FSCREEN:
	 case FSCREEN2: gl_fonts ^= 1;
		        draw_button( gl_fonts, FSCREEN2 );
			break;

	 case FNB:
	 case FNB2: gl_nb15 ^= 1;
		    draw_button( gl_nb15, FNB2 );
		    break;

	 case FSLM:
	 case FSLM2: gl_slm ^= 1;
		     draw_button( gl_slm, FSLM2 );
		     break;

	 case FFX:
	 case FFX2:  gl_fx80 ^= 1;
		     draw_button( gl_fx80, FFX2 );
		     break;

	 default: if( button == NIL )
		  {
		     switch( msg[0] )
		     {
			case  WM_REDRAW: fonts_redraw( msg );
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



/* fonts_redraw()
 * ================================================================
 */
void
fonts_redraw( int *msg )
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
/*
	 ObjcDraw( ad_fonts, ROOT, MAX_DEPTH, &rect );
 */

	 /* Redraw Scalable Outline Fonts */
	 if( gl_scalable )
	     do_cross_draw( ad_fonts, FFSM2 );

	 /* Redraw Bitmap screen fonts  */
	 if( gl_fonts )
	     do_cross_draw( ad_fonts, FSCREEN2 );
		
	 /* Redraw Bitmap NB15 fonts */
         if( gl_nb15 )
	     do_cross_draw( ad_fonts, FNB2 );

	 /* Redraw Bitmap SLM fonts */
         if( gl_slm )
	     do_cross_draw( ad_fonts, FSLM2 );

	 /* Redraw Bitmap FX80 fonts */
         if( gl_fx80 )
	     do_cross_draw( ad_fonts, FFX2 );
     }
     wind_get( msg[3], WF_NEXTXYWH,&rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );
   }
   vs_clip( vhandle, 0, clip );
   graf_mouse( M_ON, 0L );
}


/* draw_button()
 * ================================================================
 */
void
draw_button( int flag, int obj )
{
   GRECT clip;
   int   msg[8];
   int   dummy;

   if( flag )
   {
     objc_xywh( ad_fonts, obj, &clip );
     msg[3] = wid;
     msg[4] = clip.g_x;
     msg[5] = clip.g_y;
     msg[6] = clip.g_w;
     msg[7] = clip.g_h;
     fonts_redraw( msg );
   }
   else
     ObjcDraw( ad_fonts, obj, MAX_DEPTH, NULL );
   evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
}
