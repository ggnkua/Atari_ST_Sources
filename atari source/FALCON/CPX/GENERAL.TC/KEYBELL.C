/* KEYBELL.C
 *==========================================================================
 * DATE:	March 21, 1990
 * DESCRIPTION: Keyclick and Bell Routines
 */
 
 
 /* INCLUDE FILES
 *==========================================================================
 */ 
#include <sys\gemskel.h>
#include <tos.h>

#include "country.h"

#include "general.h"
#include "gen2.h"


/* DEFINES
 *==========================================================================
 */


/* PROTOTYPES
 *==========================================================================
 */
void	Set_Keybell( void );
void	Get_Keybell( void );
void	Keybell_Update( void );
long	get_noise( void );
long	set_noise( void );
void	keybell_handle( int base, int *var );
void    Keybell_Redraw( void );


/* EXTERNALS
 *==========================================================================
 */


/* GLOBALS 
 *==========================================================================
 */


/* FUNCTIONS
 *==========================================================================
 */

 
/* Set_Keybell()
 *==========================================================================
 * Set Keyboard Keyclick and Bell
 */ 
void
Set_Keybell( void )
{
   Supexec( set_noise );
}



/* Get_Keybell()
 *==========================================================================
 * Get Current Keyboard Keyclick and Bell values
 */
void
Get_Keybell( void )
{
    Supexec( get_noise );
}



/* Keybell_Update()
 *==========================================================================
 * Update the keyclick and bell objects
 */
void
Keybell_Update( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   
   (( cur_value.keyclick ) ? ( Enable( KEYICON )) : ( Disable(KEYICON )));   
   (( cur_value.bell ) ? ( Enable(BELLICON )) : ( Disable( BELLICON ))); 
}



/* get_noise()
 *==========================================================================
 * Get current key and bell settings from the system
 * NOTE: This routine must be Supexec'd
 */
long
get_noise( void )
{
    char *conterm;
    
    conterm = (char *)0x484L;
    cur_value.bell     = ((*conterm & 0x04) == 0x04 );
    cur_value.keyclick = ((*conterm & 0x01) == 0x01 );
    return( 0L );
}



/* set_noise()
 *==========================================================================
 * Set keyboard keyclick and bell
 *
 * GLOBALS:  cur_value.keyclick -  bit 0 of conterm
 *	     cur_value.bell     -  bit 2 of conterm
 * Note: Preserve bits 1 and 3 of conterm
 * NOTE: Call this routine using Supexec()
 */
long
set_noise( void )
{
    char *conterm;

    conterm = (char *)0x484L;
    *conterm &= 0xa;
    *conterm |= (( cur_value.bell ) ? ( 0x04 ) : ( 0x0 ) );
    *conterm |= (( cur_value.keyclick ) ? ( 0x01 ) : ( 0x0 ) );
    return( 0L );
}



/* keybell_handle()
 *==========================================================================
 * Turn on/off key or bell
 */
void
keybell_handle( int base, int *var )
{
  OBJECT *tree  = (OBJECT *)rs_trindex[GENERAL];
  
  *var ^= TRUE;
  (( *var ) ? ( Enable( base ) ) : ( Disable( base ) ) );
  Objc_draw( tree, base, MAX_DEPTH, NULL );
  Set_Keybell();
  wait_button( UP );
}



void
Kbell_Redraw( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   int old_key  = cur_value.keyclick;
   int old_bell = cur_value.bell;
   
   Get_Keybell();
   Keybell_Update();
   
   if( old_key != cur_value.keyclick )
	do_redraw( tree, KEYICON );
	   
   if( old_bell != cur_value.bell )
        do_redraw( tree, BELLICON );
   	
}





