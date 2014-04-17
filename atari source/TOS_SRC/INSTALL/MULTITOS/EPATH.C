/* EPATH.C
 * ================================================================
 * Handles the EXTEND.SYS Path Dialog Box
 * DATE: April 14, 1992
 */
#include <alt\gemskel.h>
#include <alt\vdikeys.h>
#include <gemlib.h>
#include <osbind.h>

#include "country.h"
#include "setup.h"
#include "text.h"
#include "gemskel.h"
#include "handlers.h"
#include "assign.h"
#include "file.h"

/* DEFINES
 * ================================================================
 */


/* EXTERNS
 * ================================================================
 */


/* PROTOTYPES
 * ================================================================
 */
int	epath_dialog( void );
void	SetEPathWindow( void );
int	epath_handler( void );

/* GLOBALS
 * ================================================================
 */
char   EDefaultPath[] = "C:\\FONTS";


/* FUNCTIONS
 * ================================================================
 */

/* EPath_Dialog()
 * ================================================================
 */
int
epath_dialog( void )
{
   int flag;

   SetEPathWindow();

   flag = epath_handler();
   return( flag );
}



/* SetEPathWindow()
 * ================================================================
 */
void
SetEPathWindow( void )
{
   ActiveTree( ad_epath );
   
   if( !ExtendPath[0] )
      strcpy( ExtendPath, EDefaultPath );
   strcpy( TempString, ExtendPath );
   TedText( EPATHS ) = TempString;

   SetNewDialog( ad_epath );
}



/* epath_handler()
 * ================================================================
 */
int
epath_handler( void )
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
	 case EOK2:   /* Check if the drive is valid */
			strcpy( TempString, TedText( EPATHS ) );
		        if( ( TempString[0] == 'A' ) || ( TempString[0] == 'B' )
		            || ( TempString[0] > 'P' ) || !DriveArray[ TempString[0] - 'C']
			  )
			{
		 	  form_alert( 1, bad_drive );
			  strcpy( TempString, AssignPath );
			  TedText( EPATHS ) = TempString;
			  ObjcDraw( ad_tree, EPATHS, MAX_DEPTH, NULL );
			  deselect( ad_tree, EOK2 );
			  continue;
			}

			/* Check the path...*/
			Dsetdrv( TempString[0] - 'A' );
			if( Dsetpath( TempString ))
			{
			   if( form_alert( 1, dirmake ) == 2 )
			   {
			      deselect( ad_tree, EOK2 );
			      continue;
			   }

			   strcpy( ScratchString, TempString );

			   /* STOOPID Fix for Allan's idiodic GEMDOS. It now
				* won't let you create a directory with a slash on
				* the end of the path. Thanks, Allan.
				*/
			   len = strlen( ScratchString );
			   if( ScratchString[len] == '\\' )
					ScratchString[len] = '\0';

			   if( do_mkdir( ScratchString, 0 ) < 0 )
			   {
			      form_alert( 1, bad_path );
			      strcpy( TempString, ExtendPath );
			      TedText( EPATHS ) = TempString;
			      ObjcDraw( ad_tree, EPATHS, MAX_DEPTH, NULL );
			      deselect( ad_tree, EOK2 );
			      continue;
			   }
			}
			strcpy( ExtendPath, TempString ); 
			done = TRUE;
			Deselect( EOK2 );
			break;

	 case EEXIT2:    CheckExit();
			deselect( ad_tree, EEXIT2 );
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



