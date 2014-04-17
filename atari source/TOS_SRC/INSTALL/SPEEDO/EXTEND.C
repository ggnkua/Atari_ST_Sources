/* EXTEND.C
 * ================================================================
 * Handles the EXTEND.sys dialog box
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
int	extend_dialog( void );
void	SetExtendWindow( void );
int	extend_handler( void );

/* GLOBALS
 * ================================================================
 */
char ENewFile[15];

/* FUNCTIONS
 * ================================================================
 */

/* extend_dialog()
 * ================================================================
 */
int
extend_dialog( void )
{
   int flag = TRUE;

   if( !check_sysfile( "C:\\EXTEND.SYS", ExtendPath ) )
   {
     SetExtendWindow();
     flag = extend_handler();
   }
   else	/* If there is NO EXTEND.SYS, USE the ASSIGN.SYS Path */
     strcpy( ExtendPath, AssignPath );
   return( flag );
}



/* SetExtendWindow()
 * ================================================================
 */
void
SetExtendWindow( void )
{
   ActiveTree( ad_extend );

   Select( E1 );   
   Deselect( E2 );
   Deselect( E3 );

   SetNewDialog( ad_extend );
}



/* extend_handler()
 * ================================================================
 */
int
extend_handler( void )
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
	 case EOK:	done = TRUE;
			for( i = E1; i <= E3; i++ )
			{
			   if( IsSelected( i ) )
			     gl_extend = i - E1;
			}
			Deselect( EOK );
			break;

	 case EEXIT:   CheckExit();
			deselect( ad_tree, EEXIT );
			break;

	 case F1:	if( !IsSelected( E1 ) )
			{
			  deselect( ad_tree, E2 );
			  deselect( ad_tree, E3 );
			  select( ad_tree, E1 );
			}
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			break;

	 case F2:	if( !IsSelected( E2 ) )
			{
			  deselect( ad_tree, E1 );
			  deselect( ad_tree, E3 );
			  select( ad_tree, E2 );
			}
			evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			break;

	 case F3:	if( !IsSelected( E3 ) )
			{
			  deselect( ad_tree, E1 );
			  deselect( ad_tree, E2 );
			  select( ad_tree, E3 );
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



