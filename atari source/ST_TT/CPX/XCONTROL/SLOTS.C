/* FILE:  SLOTS.C
 *==========================================================================
 * DATE:  February 1, 1990
 * DESCRIPTION:
 *
 * INCLUDE FILE: SLOTS.H
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdlib.h>

#include "country.h"
#include "xcontrol.h"

#include "cpxdata.h"			/* These must remain in order...*/
#include "xstructs.h"			/* cpxhandl.h requires defines  */
#include "cpxhandl.h"			/* in cpxdata.h and xstructs.h  */

#include "xconfig.h"
#include "xcontrl2.h"


/* PROTOTYPE
 *==========================================================================
 */
void    assign_slots( CPXNODE *xptr );
BOOLEAN	check_active_slot( int obj );
void	set_active_slot( int obj );
void	clear_active_slot( int flag );
void    slot_offset_adjust( int value );
void	clean_slot( int index );
void    blit_slots( int oldnum, int newnum );



/* DEFINES
 *==========================================================================
 */
#define MAX_SLOTS		4		/* Slots to display...  */

#define NO_SLOT_ACTIVE  	( -1 )		/* if active, the slot
						 * is inversed.
						 */
						 
#define SLOT_TEXT_LENGTH	16		/* Length of string for */



/* GLOBALS
 *==========================================================================
 */
int active_slot;		/* There are 4 slots which defined 
				 * below as SLOT slots[]
				 * When selected, active_slot contains
				 * the index to the slot. 0, 1, 2, 3, 4
				 * If no slot is active, then active_slot
				 * is == NO_ACTIVE_SLOT
				 * An active slot is distinguished by
				 * being Selected.
				 */

/* Text string to blank out the text segment of a slot.
 * The length is currently SLOT_TEXT_LENGTH
 * The actual length must match the one in the text field of the
 * CPXNODE structure found in xstructs.h
 */						  
char     Blank[ SLOT_TEXT_LENGTH ];



/* An array of 4 SLOT structures. ( See XSTRUCTS.H for structur definition )
 * The first objects are the objects in the slot rcs structure.
 * They are the top object, icon, text and base object
 * There is a ptr to the cpx node in order to get more information
 * such as icon data, filename, file size, resident and vacancy flags
 * When empty, the tedinfo structures point to Blank[]
 * and the cpx pointer is equated to NULL.
 * Text Length for CPX Description: 15 characters
 * Text Length for icon: 12 characters
 * Icon dimensions: 32 pixels x 24 pixels
 *
 */
SLOT slots[] = {  { SLOT0, SLOT0TXT, ICON0, SLOTB0, NULL },
	          { SLOT1, SLOT1TXT, ICON1, SLOTB1, NULL },
	          { SLOT2, SLOT2TXT, ICON2, SLOTB2, NULL },
	          { SLOT3, SLOT3TXT, ICON3, SLOTB3, NULL }
               };


/* FUNCTIONS
 *==========================================================================
 */
 
 


/* assign_slots()
 *==========================================================================
 * Assign a slot to a node in sequence. A slot will not be assigned to an
 * empty node. Slots that are unassigned have their pointers nulled and
 * text ptrs set to blank. It is also assumed that the active nodes are
 * sequential in nature and do not have empty nodes between any two active
 * nodes.
 *
 * IN:  CPXNODE *xptr:		Start assigning slots starting from
 *				this node
 *
 * OUT: void
 *
 * GLOBAL:   SLOTS slots[]:	slot array structure
 */
void
assign_slots( CPXNODE *xptr )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   int index = 0;
   CPXNODE *curptr;
   
   curptr = xptr;
   
   for( index = 0; index < MAX_SLOTS; index++ )
   {
     clean_slot( index );
     if( curptr && (curptr->vacant ))
     {   
        TedText( slots[index].text ) = curptr->cpxhead.title_txt;
        TedColor( slots[ index ].text ) = curptr->cpxhead.t_color;
        slots[index].sptr = curptr;
        ShowObj( slots[ index ].icon );
        IconData( slots[ index ].icon ) = ( int *)(curptr->cpxhead.sm_icon);
        IconText( slots[ index ].icon ) = curptr->cpxhead.i_text;
	IconColor( slots[ index ].icon ) = curptr->cpxhead.i_color;
	curptr = curptr->next;   
     }
   }
}




/* check_active_slot()
 *==========================================================================
 * Compares if the slot that was clicked on, the active slot.
 *
 * IN:   int obj:		Object clicked on
 * OUT:  BOOLEAN:		TRUE or FALSE if obj was the active slot
 */
BOOLEAN
check_active_slot( int obj )
{
   return( ( ( obj - SLOT0 ) >> 2 ) == active_slot );
}


/* get_active_slot_obj()
 *==========================================================================
 * return the SLOT resource object
 */
int
get_active_slot_obj( void )
{
    return( ( active_slot << 2 ) + SLOT0 );
}



/* set_active_slot()
 *==========================================================================
 * Make the new slot the active slot. If the slot is already active, don't
 * do anything.
 *
 * IN:  int obj:	object of new active slot
 * OUT: void:
 *
 * GLOBAL: int active_slot:           non-zero if a slot is active.
 *				      Tells which slot object is active
 *	   SLOTS slots[]:	      Slot array structure
 */
void
set_active_slot( int obj )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
    int item;
    
    
    item = ( obj - SLOT0 ) >> 2;

    if( slots[ item ].sptr )
    {
      set_xopt_items( XOPT_YESCPX );
      active_slot = item;
      Select( slots[ active_slot ].obj );
      Objc_draw( tree, slots[ active_slot ].base, MAX_DEPTH, NULL );
    }
}





/* clear_active_slot()
 *==========================================================================
 * Clear the current active slot by deselecting it and redrawing if
 * necessary.
 *
 * IN:  int redraw:		TRUE - perform a redraw
 * OUT: void
 * 
 * GLOBAL:  SLOTS slots:    slot array structure
 */
void
clear_active_slot( int redraw )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   
   if( active_slot != NO_SLOT_ACTIVE )
   {
      set_xopt_items( XOPT_NOCPX );
      Deselect( slots[ active_slot ].obj );
      
      if( redraw)
      	    Objc_draw( tree, slots[ active_slot ].base, MAX_DEPTH, NULL );
      active_slot = NO_SLOT_ACTIVE;
   }
}





/* slot_offset_adjust()
 *==========================================================================
 * Start assigning nodes to slots AFTER we have adjusted an offset
 * of X amount of nodes.  This way, we aren't always assigning slots
 * from the header node.
 *
 * IN:   int value:		Number of nodes to skip
 * OUT:  void
 *
 * GLOBAL:   CPXNODE *hdptr:    head pointer to nodes
 */
void
slot_offset_adjust( int value )
{
    CPXNODE *curptr;
    int  i;
    
    curptr = hdptr;
    for( i = 0; i < value; i++ )
         curptr = curptr->next;
    assign_slots( curptr );
}





/* clean_slot()
 *==========================================================================
 * Blank out the text ptr and the slot pointer to the structure
 *
 * IN:   int index:			which slot array to clean out
 * OUT:  void
 *
 * GLOBAL:    SLOTS slots[]:	Slot array structure
 */
void
clean_slot( int index )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   
   TedText( slots[ index ].text ) = Blank;
   slots[ index ].sptr = NULL;
   HideObj( slots[ index ].icon );
   IconData( slots[ index ].icon ) = NULL;
   IconText( slots[ index ].icon ) = '\0';
}




/* get_cpx_from_slot()
 *==========================================================================
 * Returns the cpx node from the active slot
 */
CPXNODE
*get_cpx_from_slot( void )
{
     return( slots[ active_slot ].sptr );   
}




/* blit_slots()
 *==========================================================================
 * Handle the scrolling of the slots.  Worst case is to redraw all four
 * slots. Otherwise, we blit three, two or one slots, and redraw the 
 * remaining.
 *
 * IN:   int oldnum:		Old node number
 *       int newnum:		new node number
 *				Note: the node nunber is the node
 *				that is in the first slot.
 * OUT: void
 */
void
blit_slots( int oldnum, int newnum )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
    
    GRECT srcbase;
    GRECT dstbase;
    GRECT clip;
    GRECT rect;
    int   pxy[16];
    GRECT clip2;
            
    int   offset;
    long  location = 0L;
    int   dummy;
    
    clip = ObRect( SLOT0 );
    objc_offset( tree, SLOT0, &clip.g_x, &clip.g_y );
    clip.g_h = ( clip.g_h * MAX_SLOTS ) + MAX_SLOTS;
    clip2 = srcbase = dstbase = rect = clip;
    offset = newnum - oldnum;
               
    if( !offset )			/* went nowhere fast...*/
    	   return;
    	   
    open_vwork();

    rc_intersect( &desk, &clip2 );
    if(  ( abs( offset )  <  MAX_SLOTS ) &&
    	 rc_equal( &clip2, &clip ) 
      )
    {
       rect.g_h    = ( abs( offset ) * ObH( SLOT0 ) );
       dstbase.g_h = srcbase.g_h = (MAX_SLOTS - abs(offset )) * ObH( SLOT0 ) + ( MAX_SLOTS - abs( offset) );
       if( offset > 0 )
       {
          objc_offset( tree, slots[ abs( MAX_SLOTS - offset ) ].obj,
                       &dummy, &rect.g_y );
	  objc_offset( tree, slots[ abs( offset ) ].obj, &dummy, &srcbase.g_y );
       }
       else
	  objc_offset( tree, slots[ abs( offset ) ].obj, &dummy, &dstbase.g_y );

       rc_intersect( &desk, &srcbase );
       rc_intersect( &desk, &dstbase );
       
       rc_2xy( &srcbase, ( WORD *) &pxy[0] );
       rc_2xy( &dstbase, ( WORD *)&pxy[4] );
       rc_2xy( &clip, ( WORD *)&pxy[8] );
       vs_clip( vhandle, 1, &pxy[8] );
       graf_mouse( M_OFF, 0L );
       Vsync();
       vro_cpyfm( vhandle, 3, pxy, ( MFDB *)&location,
                                   ( MFDB *)&location );
       graf_mouse( M_ON, 0L );
    }
    else
    {
       rc_2xy( &clip, ( WORD *)&pxy[0] );
       vs_clip( vhandle, 1, &pxy[0] );
    }
    
    Vsync();
    Objc_draw( tree, SLOTBASE, MAX_DEPTH, &rect );

    close_vwork();
}




/* Slot_Color_Update()
 *==========================================================================
 * Update the color information in the slot with the NODE IF there
 * is a node in the first place...
 */
void
Slot_Color_Update( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   int index = 0;
   CPXNODE *curptr;
   
   for( index = 0; index < MAX_SLOTS; index++ )
   {
     curptr = slots[ index ].sptr;
     if( curptr )
     {   
        TedColor( slots[ index ].text )  = curptr->cpxhead.t_color;
	IconColor( slots[ index ].icon ) = curptr->cpxhead.i_color;
     }
   }
}

