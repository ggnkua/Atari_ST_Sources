/* DCLICK.C
 *==========================================================================
 * DATE:	March 21, 1990
 * DESCRIPTION: Mouse Double Click Routines
 */
 
 
 /* INCLUDE FILES
 *==========================================================================
 */ 
#include <sys\gemskel.h>

#include "country.h"

#include "general.h"
#include "gen2.h"


/* DEFINES
 *==========================================================================
 */


/* PROTOTYPES
 *==========================================================================
 */
void	Set_Dclick( void );
void	Get_Dclick( void );
void	Dclick_Update( void );
void	Dclick_Select( int obj );
void	Dclick_Handle( BOOLEAN flag, int obj );


/* EXTERNALS
 *==========================================================================
 */


/* GLOBALS 
 *==========================================================================
 */


/* FUNCTIONS
 *==========================================================================
 */


 
/* Set_Dclick()
 *==========================================================================
 * Set the Mouse Double Click Rate
 */ 
void
Set_Dclick( void )
{
   evnt_dclick( cur_value.dclick, 1 );
}


/* Get_Dclick()
 *==========================================================================
 * Get the current Mouse Double Click Rate
 */
void
Get_Dclick( void )
{
    cur_value.dclick = evnt_dclick( 0, 0 );
}



/* Dclick_Update()
 *==========================================================================
 * Update the Mouse Double Click Objects
 */    
void
Dclick_Update( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   
   Select( cur_value.dclick + M0 );  	
}



/* Dclick_Select()
 *==========================================================================
 * Selects one of the 5 mouse double click objects possible
 */
void
Dclick_Select( int obj )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   
   Deselect( cur_value.dclick + M0 );
   Objc_draw( tree, cur_value.dclick + M0, 0, NULL );
   Select( obj );
   cur_value.dclick = obj - M0;
   Objc_draw( tree, obj, 0, NULL );
   Set_Dclick();
   wait_button( UP );
}




/* Dclick_Handle()
 *==========================================================================
 * Handle the Double Click Routine
 * Select the Object IF a double click occurred
 */
void
Dclick_Handle( BOOLEAN flag, int obj )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   
   if( flag )	/* double click? */
   {
      	XSelect( tree, DOUBLE );
/*       	Objc_draw( tree, obj, 0, NULL );*/
       	Evnt_timer( 250L );
       	XDeselect( tree, DOUBLE );
/*       	Objc_draw( tree, obj, 0, NULL );*/
   }
   wait_button( UP );
  
}


void
Dclick_Redraw( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   int old_dclick = cur_value.dclick;
   
   Get_Dclick();
   Dclick_Update();

   if( old_dclick != cur_value.dclick )
   {
      Deselect( old_dclick + M0 );
      do_redraw( tree, old_dclick + M0 ); 
      do_redraw( tree, cur_value.dclick + M0 );
   }
}




