/* DPATH.C
 * ================================================================
 * Handles the ASSIGN.SYS Path Dialog Box
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
int	path_dialog( void );
void	SetPathWindow( void );
int	path_handler( void );


/* GLOBALS
 * ================================================================
 */
char   ADefaultPath[] = "C:\\MULTITOS";


/* FUNCTIONS
 * ================================================================
 */

/* Path_Dialog()
 * ================================================================
 */
int
path_dialog( void )
{
   int flag;

   SetPathWindow();

   flag = path_handler();
   return( flag );
}



/* SetPathWindow()
 * ================================================================
 */
void
SetPathWindow( void )
{
   ActiveTree( ad_path );
   
   if( !AssignPath[0] )
      strcpy( AssignPath, ADefaultPath );
   strcpy( TempString, AssignPath );
   TedText( PPATH ) = TempString;

   SetNewDialog( ad_path );
}



/* path_handler()
 * ================================================================
 */
int
path_handler( void )
{
    int msg[8];
    int button;
    int done;
	int len;

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case PSETUP:   /* Check if the drive is valid */
			strcpy( TempString, TedText( PPATH ) );

			   /* STOOPID Fix for Allan's idiodic GEMDOS. It now
				* won't let you create a directory with a slash on
				* the end of the path. Thanks, Allan.
				*/
			   len = strlen( TempString );
			   if( TempString[len-1] == '\\' )
					TempString[len-1] = '\0';

		        if( ( TempString[0] == 'A' ) || ( TempString[0] == 'B' )
		            || ( TempString[0] > 'P' ) || !DriveArray[ TempString[0] - 'C']
			  )
			{
		 	  form_alert( 1, bad_drive );
			  strcpy( TempString, AssignPath );
			  TedText( PPATH ) = TempString;
			  ObjcDraw( ad_tree, PPATH, MAX_DEPTH, NULL );
			  deselect( ad_tree, PSETUP );
			  continue;
			}

		        Dsetdrv( TempString[0] - 'A' );


			/* Check the path...*/
			if( Dsetpath( TempString ))
			{
			   if( form_alert( 1, dirmake ) == 2 )
			   {
			      deselect( ad_tree, PSETUP );
			      continue;
			   }

			   strcpy( ScratchString, TempString );

			   if( do_mkdir( ScratchString, 0 ) < 0 )
			   {
			      form_alert( 1, bad_path );
			      strcpy( TempString, AssignPath );
			      TedText( PPATH ) = TempString;
			      ObjcDraw( ad_tree, PPATH, MAX_DEPTH, NULL );
			      deselect( ad_tree, PSETUP );
			      continue;
			   }
			}
			strcpy( AssignPath, TempString ); 
			done = TRUE;
			Deselect( PSETUP );
			break;

	 case PEXIT:    CheckExit();
			deselect( ad_tree, PEXIT );
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



