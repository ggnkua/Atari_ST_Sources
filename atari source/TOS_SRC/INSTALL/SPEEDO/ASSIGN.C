/* ASSIGN.C
 * ================================================================
 * Handles the Assign.sys dialog box
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
int	assign_dialog( void );
void	SetAssignWindow( void );
int	assign_handler( void );

/* GLOBALS
 * ================================================================
 */
char ANewFile[15];


/* FUNCTIONS
 * ================================================================
 */

/* Assign_Dialog()
 * ================================================================
 */
int
assign_dialog( void )
{
   int flag = TRUE;

   if( !check_sysfile( "C:\\ASSIGN.SYS", AssignPath ) )
   {
     SetAssignWindow();
     flag = assign_handler();
   }
   return( flag );
}



/* SetAssignWindow()
 * ================================================================
 */
void
SetAssignWindow( void )
{
   ActiveTree( ad_assign );

   Select( A1 );   
   Deselect( A2 );
   Deselect( A3 );

   SetNewDialog( ad_assign );
}



/* assign_handler()
 * ================================================================
 */
int
assign_handler( void )
{
    int msg[8];
    int button;
    int done;
    int i;
    int dummy;

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case EASETUP:  done = TRUE;
			for( i = A1; i <= A3; i++ )
			{
			   if( IsSelected( i ) )
			     gl_assign = i - A1;
			}
			Deselect( EASETUP );
			break;

	 case EAEXIT:   CheckExit();
			deselect( ad_tree, EAEXIT );
			break;

	 case B1:	if( !IsSelected( A1 ) )
			{
			  deselect( ad_tree, A2 );
			  deselect( ad_tree, A3 );
			  select( ad_tree, A1 );
			}
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			break;

	 case B2:	if( !IsSelected( A2 ) )
			{
			  deselect( ad_tree, A1 );
			  deselect( ad_tree, A3 );
			  select( ad_tree, A2 );
			}
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			break;

	 case B3:	if( !IsSelected( A3 ) )
			{
			  deselect( ad_tree, A1 );
			  deselect( ad_tree, A2 );
			  select( ad_tree, A3 );
			}
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
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



