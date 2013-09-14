/* INTRO.C
 * ================================================================
 * Handles the Intro dialog box.
 * DATE: April 14, 1992
 */
#include <alt\gemskel.h>
#include <alt\vdikeys.h>
#include <gemlib.h>

#include "country.h"
#include "setup.h"
#include "text.h"
#include "gemskel.h"
#include "handlers.h"
#include "dpath.h"

/* DEFINES
 * ================================================================
 */


/* EXTERNS
 * ================================================================
 */



/* PROTOTYPES
 * ================================================================
 */
void	intro_dialog( void );
void	intro_handler( void );

int	SetIntroWindow( void );
void	intro_redraw( int *msg );
void	intro_button( int obj );


/* GLOBALS 
 * ================================================================
 */


/* FUNCTIONS
 * ================================================================
 */


/* intro_dialog()
 * ================================================================
 */
void
intro_dialog( void )
{
    static int flag = FALSE;

    ActiveTree( ad_intro );
    Deselect( XFSM );
    Deselect( XFONT );
    Select( gl_gdos );

    if( !flag )
    {
      if( SetIntroWindow() < NULL )
         Gem_Exit( NIL );
      flag = TRUE;
    }
    else
    {
      SetNewDialog( ad_intro );
      wind_set( wid, WF_NAME, wtitle );
    }
    intro_handler();
}



/* SetIntroWindow()
 * ================================================================
 * RETURN: if < 0, error
 */
int
SetIntroWindow( void )
{
   /* Open the Intro window */
   ad_tree = ad_intro;

   ActiveTree( ad_tree );
   FormCenter( ad_tree, &gl_work );
   ObX( ROOT ) = gl_work.g_x;
   ObY( ROOT ) = gl_work.g_y;

   wid = wind_create( MOVER | NAME | CLOSE, gl_full.g_x, gl_full.g_y,
		            		    gl_full.g_w, gl_full.g_h );

   if( wid > NULL )
   {
     wind_set( wid, WF_NAME, wtitle );
     wind_calc( WC_BORDER, MOVER | NAME | CLOSE,
	        gl_work.g_x, gl_work.g_y, gl_work.g_w, gl_work.g_h,
	        &gl_curr.g_x, &gl_curr.g_y, &gl_curr.g_w, &gl_curr.g_h );

     wind_open( wid, gl_curr.g_x, gl_curr.g_y, gl_curr.g_w, gl_curr.g_h );
   }
   else
     form_alert( 1, nowin );

   return( wid );
}



/* intro_handler()
 * ================================================================
 */
void
intro_handler( void )
{
    int msg[8];
    int button;
    int done;
    int dummy;

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case XSETUP:   done = TRUE;
			if( IsSelected( XFSM ) )
			    gl_gdos = XFSM;
                        else
			    gl_gdos = XFONT;

			gl_scalable = ( gl_gdos == XFSM );
			Deselect( XSETUP );
			break;

	 case XEXIT:    CheckExit();
			deselect( ad_tree, XEXIT );
			break;

	 case FSMTITLE: if( !IsSelected( XFSM ) )
			{
			  deselect( ad_tree, XFONT );
			  select( ad_tree, XFSM );
			}
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			break;

	 case FNTTITLE: if( !IsSelected( XFONT ) )
			{
			  deselect( ad_tree, XFSM );
			  select( ad_tree, XFONT );
			}
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			break;

	 default: if( button == NIL )
		  {
		     switch( msg[0] )
		     {
		        case  WM_CLOSED: CheckExit();
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




