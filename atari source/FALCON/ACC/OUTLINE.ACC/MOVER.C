/* FILE:  MOVER.C
 *==========================================================================
 * DATE:  May  16, 1990
 *        July 11, 1991
 *	  July  9, 1992 Yup- 1992 - no kidding
 *			IF AES version is >= 3.2, use MFsave, else skip
 *	  Dec   9, 1992 Modifications for FONTS.ACC
 *	  Dec  15, 1992 Remove Bitmap and Device stuff
 *
 * DESCRIPTION: MOVER
 *
 * INCLUDE FILE: MOVER.H
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h> 
#include <stdlib.h>

#include "country.h"
#include "fonthead.h"
#include "fonts.h"
#include "fsmio.h"

#include "front.h"
#include "mainstuf.h"
#include "text.h"
#include "sliders.h"
#include "custom.h"
#include "inactive.h"


struct foobar {
	WORD	dummy;
	WORD	*image;
	};
extern int AES_Version;
extern int gl_ncolors;


/* PROTOTYPES
 *==========================================================================
 */
 
/* Interface Routines */
void	mover_setup( FON_PTR list_ptr, int font_count,
		     int base, int slider, int up, int down,
		     int first_obj, int last_obj, int base_obj,
		     int start_index, int num_rows );

void mover_button( int obj, int clicks );
BOOLEAN mover_keys( void );

void	Undo_Fnodes( FON_PTR ptr, FON_PTR flag );
void	ClearFnodes( FON_PTR ptr );
BOOLEAN IsChanged( FON_PTR ptr );
FON_PTR	Find_Fnode( FON_PTR ptr, int index );


/* Slit handling */
void  	Draw_Slit( void );
void	Draw_Hot( void );
void  	slit_offset_adjust( FON_PTR ptr, int value, FON_PTR array[] );
void	Assign_Slit( FON_PTR ptr, FON_PTR array[] );
void	Blit_Slits( int old_slit, int new_slit );


void	Make_Hot_Spots( int top_object );

int	Get_Findex( FON_PTR tptr, FON_PTR ptr );
int	Get_Hot_Index( int *hot_index );


FON_PTR	Hot_Old_New_Update( int index, FON_PTR Top_Node,
		     	     int old_index, int findex,
		     	     int Top_Obj, FON_PTR Slit_Array[] );

void	Old_Index_Handler( int old_index, int new_index, int findex,
		   	   FON_PTR Top_Node, FON_PTR Base_Node,
		   	   int Above_Obj, int Below_Obj );
void	New_Index_Handler( int old_index, int new_index, int findex,
			   FON_PTR Top_Node, FON_PTR Base_Node,
			   int Above_Obj, int Below_Obj );
void	Hot_Scroll( FON_PTR Xptr, int cur_slit, int First_Obj, int End_Obj );
void	Do_Hot_Scroll( int obj, FON_PTR Top_Node, FON_PTR base_node,
		       int Top_Obj, int Total,
	       	       int Xbase, int Xslider, int *cur_slit,
		       FON_PTR Slit_Array[], void (*foo)() );

int     rub_wait( GRECT *obj, int dir, int state );
		     	     
void	Hot_Slide( OBJECT *tree, int base, int slider, int obj,
           	   int inc, int min, int max, int *numvar,
	           int direction, GRECT *rect, void (*foo)() );

int	FindNumSelected( FON_PTR ptr );
FON_PTR	FindFirstFont( FON_PTR ptr );


void	CheckHotFront( FON_PTR Head_Node );
void	CheckHotAvailable( FON_PTR Head_Node );
void	CheckHotPoints( FON_PTR Head_Node );


/* DEFINES
 *==========================================================================
 */


/* GLOBALS
 *==========================================================================
 */
 
/* MOVER/RENAME VARIABLES */

/* The blank string for the filenames    */
char fblank[] = "                           ";
char fblank2[] = "   ";
#if 0
char fblank3[] = "            ";
#endif

FON_PTR  hdptr = NULL;		/* Active FNODE Pointer Head		 */
int      Total;			/* Total 'Active' filenames		 */
FON_PTR  Active_Slit[25];	/* These are arrays of FNODE pointers    
			         * which are used to point to the fnode
    				 * that is in its slot. That way we can
    				 * quickly get the information from the
    				 * node. If the fnode is NULL, we set the
    				 * text to point to fblank[]
    				 */
    				 
int   Cur_Slit, Old_Slit;	/* The index INTO the filename linked list
				 * so that we can count INTO it and find
				 * an offset for the top node. I = Inactive
				 * and A = Active
				 */
GRECT hot_spot[25];		/* Grect(s) for the 6 filename buttons plus
				 * one above and one below. They are 
				 * created ONLY when a filename button 
				 * object is selected: LINE0 - LINE5
				 */
int   hot_index;   		/* Index for Hot_Spot[] 
				 * Hot_Spot[] is an array of grects which is
				 * defined when the user clicks on a filename.
				 * The GRECTS are the boxes where we look to
				 * see where the mouse IS, and WAS so that
				 * we can select, deselect or scroll the
				 * filenames.
				 */
FON_PTR Base_Node; 		/* The node the scroll started with */
int     new_index;		/* NEW index into linked list ( zero based ) */
int     findex;			/* node index INTO the linked list ( zero based )
				 * This is the one that was first clicked on
				 * and started all of the scrolling.
				 * NOTE: findex's node is Base_Node.
				 */
				
char src_fname[128];		/* Active and Inactive source paths */
char dst_fname[128];

FON  Point_Arena[ MAX_POINTS + 2 ];/* Arena for the Scrolling of point sizes */
FON_PTR  Temp_Fon;
			

	
MFORM	mfOther;

/*
   Below Variables are GLOBALS for the MOVER Routines so that
   we can use more than one tree to perform with the sliders
   NOTE: We must still have MAX_SLITS for each slider and
         the slider must be VERTICAL.
*/
int Mbase,Mslider;		/* Active Mover Base and Slider */
int Mup, Mdown;			/* Active UP Button and Down Button*/
int First_Obj;			/* First Object in Scroll Area : ie: LINE0 */
int Base_Obj;			/* Parent Obj of Scroll Area Objects 0 - 5*/				
int Obj_Beg, Obj_End;
int MAX_SLITS;


/* FUNCTIONS
 *==========================================================================
 */


/*
 *==========================================================================
 * Interface Routines
 *==========================================================================
 */
 

/* mover_setup()
 *==========================================================================
 * RETURNS TRUE - SUCCESS
 *	   FALSE- ERROR! ( probably memory allocation )
 */
void
mover_setup( FON_PTR list_ptr, int font_count,
	     int base, int slider, int up, int down,
	     int first_obj, int last_obj, int base_obj,
	     int start_index, int num_rows )
{
    int i;

    hdptr = list_ptr;
    Total = font_count;
    MAX_SLITS   = num_rows;
    
    Mbase 	= base;
    Mslider	= slider;
    Mup		= up;
    Mdown	= down;
    First_Obj	= first_obj;
    Base_Obj	= base_obj;
    Obj_Beg	= first_obj;
    Obj_End	= last_obj;           
    
    for( i = 0; i < MAX_SLITS;i++ )
    {
        Active_Slit[i] = NULL;
#if 0
	/* For the CUSTOM Dialog Box, we need fblank to be shorter..*/
	if( IsActiveTree( ad_custom ) )
          TedText( First_Obj + i ) = fblank3;
#endif

	if( IsActiveTree( ad_points ) )
          TedText( First_Obj + i ) = fblank2;

	if( IsActiveTree( ad_front ) || IsActiveTree( ad_inactive ) )
            TedText( First_Obj + i ) = fblank;
    }
        
    if( Total > MAX_SLITS )
    {
       if( start_index > Total - MAX_SLITS )
           start_index = Total - MAX_SLITS;
    }
    else
       start_index = 0;
       
    slit_offset_adjust( hdptr, start_index, Active_Slit );

    if( start_index )
        start_index = Get_Findex( hdptr, Active_Slit[0] );

    Old_Slit = Cur_Slit = start_index;
    sl_size( tree, Mbase, Mslider, Total, MAX_SLITS, VERTICAL, 0 );
    sl_y( tree, Mbase, Mslider, Cur_Slit,
           	   max( Total - MAX_SLITS, 0 ), 0, NULLFUNC );
}




/* mover_button()
 *==========================================================================
 * Handles the button events for the CPX Mover/Rename Function
 * IN: int obj:		The RCS Object clicked on.
 * OUT: BOOLEAN:   TRUE - Exit the CPX Mover Config
 *		   FALSE - Remain in the CPX Mover Config
 */
void
mover_button( int obj, int clicks )
{
   MRETS mk;
   int   ox,oy;
   
        Old_Slit = Cur_Slit;

	if( obj == Mup )
	{        
	   sl_arrow( tree, Mbase, Mslider, Mup, -1,
           	      max( Total - MAX_SLITS, 0 ), 0,
           	      &Cur_Slit, VERTICAL, Draw_Slit );
           return;			    	     
        }   			    	     

        if( obj == Mdown )
        {
           sl_arrow( tree, Mbase, Mslider, Mdown, 1,
           	     max( Total - MAX_SLITS, 0 ), 0,
           	     &Cur_Slit, VERTICAL, Draw_Slit );
           return;			    	     
        }   			    	     

        if( obj == Mslider )
        {
           MF_Save();
	   if( AES_Version >= 0x0320 )
	       graf_mouse( FLAT_HAND, 0L );

           if(( AES_Version >= 0x0330 )
	       && ( gl_ncolors > LWHITE ) )
	       XSelect( tree, Mslider );

           graf_mkstate( (int*)&mk.x, &oy, (int*)&mk.buttons, (int*)&mk.kstate );
	   do
	   {
	       graf_mkstate( (int*)&mk.x, (int*)&mk.y, (int*)&mk.buttons, (int*)&mk.kstate );
	   }while( mk.buttons && ( mk.y == oy ));

 	   if( mk.buttons && ( mk.y != oy ))
	   {
	       
              sl_dragy( tree, Mbase, Mslider,
           	        max( Total - MAX_SLITS, 0 ), 0,
           	    	&Cur_Slit, Draw_Slit );
           }

	   if(( AES_Version >= 0x0330 )
	        && ( gl_ncolors > LWHITE ) )
	       XDeselect( tree, Mslider );
           	    	      
	   MF_Restore();
           return;		  
        }           		  
        
        if( obj == Mbase )
        {   		 
           Graf_mkstate( &mk );
           objc_offset( tree, Mslider, &ox, &oy );
           ox = (( mk.y < oy ) ? ( -MAX_SLITS ) : ( MAX_SLITS ) );
           sl_arrow( tree, Mbase, Mslider, -1, ox,
               	     max( Total - MAX_SLITS, 0 ), 0,
             	     &Cur_Slit, VERTICAL, Draw_Slit );
           return;           		  	    	     
        }   		  	    	     

        /* CPX filename buttons */
        if( ( obj >= Obj_Beg ) &&
            ( obj <= Obj_End ) )
        {           
	   if( clicks )
	   {
	   }
	   else
	       Do_Hot_Scroll( obj, hdptr, Active_Slit[ obj - First_Obj ],
	     	              First_Obj, Total,
	   		      Mbase, Mslider, &Cur_Slit,
	   		      Active_Slit, Draw_Hot );
	   return;
	}   		  		 
        Undo_Fnodes( hdptr, ( FON_PTR )NULL );
}




/* Undo_Fnodes()
 *==========================================================================
 * Deselects any Slits visible. Also, it goes down the slit ptr passed in,
 * and undo's any changes made to the filename.
 *
 * IN: 	FNODE *ptr:	Head Node pointer to the linked list.
 * 	BOOLEAN flag:	Defines which linked list to clear out.
 */
void
Undo_Fnodes( FON_PTR ptr, FON_PTR flag )
{
    FON_PTR curptr;
    int i;

    /* Here we restore whatever the previous state was */
    if( !IsChanged( ptr ) )
    	return;

    curptr = ptr;
    while( curptr )
    {
        AFLAG( curptr ) = SFLAG( curptr ) = FALSE;   
        curptr = FNEXT( curptr );
    }
    
    for( i = 0; i < MAX_SLITS; i++ )
    {
       if( IsSelected( First_Obj + i ) )
          deselect( tree, First_Obj + i );
    }

    if( IsActiveTree( ad_front ) && !flag )
    {
       if( !IsDisabled( FREMOVE ) )
	 ChangeButton( ad_front, FREMOVE, FALSE );
       
       if( !IsDisabled( FCONFIG ) )
	 ChangeButton( ad_front, FCONFIG, FALSE );
    }

    if( IsActiveTree( ad_inactive ) && !flag )
    {
       if( !IsDisabled( IINSTALL ) )
	 ChangeButton( ad_inactive, IINSTALL, FALSE );
       
       if( !IsDisabled( ICONFIG ) )
	 ChangeButton( ad_inactive, ICONFIG, FALSE );

       CheckSelectAll( TRUE );
    }



    /* This is the Point Size Dialog Box */
    if( IsActiveTree( ad_points ) && !flag )
    {
       if( !IsDisabled( PNTDEL ) )
	 ChangeButton( ad_points, PNTDEL, FALSE );
    }

}



/* Undo_Fnodes()
 *==========================================================================
 * Deselects any Slits visible. Also, it goes down the slit ptr passed in,
 * and undo's any changes made to the filename.
 *
 * IN: 	FNODE *ptr:	Head Node pointer to the linked list.
 * 	BOOLEAN flag:	Defines which linked list to clear out.
 */
void
ClearFnodes( FON_PTR ptr )
{
    FON_PTR curptr;
    int i;

    /* Here we restore whatever the previous state was */
    if( !IsChanged( ptr ) )
    	return;

    curptr = ptr;
    while( curptr )
    {
        AFLAG( curptr ) = SFLAG( curptr ) = FALSE;   
        curptr = FNEXT( curptr );
    }
    
    for( i = 0; i < MAX_SLITS; i++ )
    {
       if( IsSelected( First_Obj + i ) )
          Deselect( First_Obj + i );
    }
}




/* IsChanged()
 *==========================================================================
 * Used to see if any FNODES in the filename linked list has been 
 * changed opposite from its aflag <=> sflag
 * FNODE *ptr:	The head filename node for that linked list
 *
 * RETURN: TRUE  - YES
 *	   FALSE - NO
 */
BOOLEAN
IsChanged( FON_PTR ptr )
{
   FON_PTR curptr;
   BOOLEAN flag = FALSE;
   
   curptr = ptr;
   while( curptr )
   {
       if( AFLAG( curptr ) )
       {
           flag = TRUE;
           break;
       }
       curptr = FNEXT( curptr );   
   }
   return( flag );
}







/*
 *==========================================================================
 * Linked List Handling
 *==========================================================================
 */



/* Assign_Slit()
 *==========================================================================
 *  Assigns the 6 slits visible an FNODE, where possible.
 * IN: FNODE *ptr:	Start assigning with this node
 *     FNODE *array[]:	A 5 slit pointer array.
 */
void
Assign_Slit( FON_PTR ptr, FON_PTR array[] )
{
    int i;
    FON_PTR curptr;
    
    curptr = ptr;
    for( i = 0; i < MAX_SLITS; i++ )
    {
        array[ i ] = NULL;
        Deselect( First_Obj + i );

	if( IsActiveTree( ad_points ) )
          TedText( First_Obj + i ) = fblank2;

        if( IsActiveTree( ad_front ) || IsActiveTree( ad_inactive ) )
          TedText( First_Obj + i ) = fblank;

        if( curptr )
        {
	    /* if we are in point_size, and the point is zero,
	     * skip it...and continue with the next one.
	     */
	    if( IsActiveTree( ad_points ) )
	    {
		if( !POINT_SIZE( curptr ) )
		   continue;
            }

            array[i] = curptr;
            TedText( First_Obj + i ) = FNAME( curptr );
            
	    if( AFLAG( curptr ) )
              Select( First_Obj + i );
            curptr = FNEXT( curptr );	
        }  
    }
}




/* Draw_Slit()
 *==========================================================================
 * The Draw Slider Routine passed into the Active ( CPX ) slider routines.
 */
void
Draw_Slit( void )
{
    slit_offset_adjust( hdptr, Cur_Slit, Active_Slit );
    Blit_Slits( Old_Slit, Cur_Slit );
    Old_Slit = Cur_Slit;
}


/* Draw_Hot()
 *==========================================================================
 * The Draw Slider Routine passed into the Active (CPX ) HOT slider
 * Routines. This routine is used when we are doing ' hot' scrolling.
 * Routines.
 */
void
Draw_Hot( void )
{
    Hot_Scroll( hdptr, Cur_Slit, First_Obj, First_Obj + MAX_SLITS - 1 );
    Draw_Slit();
#if 0    
    Evnt_timer( 50L );
#endif    
}



/* slit_offset_adjust()
 *==========================================================================
 * Assign the linked list to the slits. Used in conjuction with Assign_Slit.
 * IN: FNODE *ptr:	The Head Pointer Node
 *     int   value:	The Index (base 0 ) into the linked list
 *     FNODE *array[]:	Text for the slider.
 */
void
slit_offset_adjust( FON_PTR ptr, int value, FON_PTR array[] )
{
    FON_PTR curptr;
    int   i;
    
    curptr = ptr;
    
     
    for( i = 0; i < value; i++ )
       curptr = FNEXT( curptr );
    Assign_Slit( curptr, array );
}




/* blit_slits()
 *==========================================================================
 * Perform the blitting when the slits are scrolling.
 * IN: BOOLEAN flag:	either Active or Inactive
 *     int old_slit:	The previous slit
 *     int new_slit:	The current slit to work on.
 */
void
Blit_Slits( int old_slit, int new_slit )
{
    GRECT srcbase;
    GRECT dstbase;
    GRECT clip;
    GRECT rect;
    int   pxy[16];
    GRECT clip2;
                
    int   offset;
    long  location = 0L;
    int   dummy;
    int   obj;
    int   base;
    
    obj  = First_Obj;
    base = Base_Obj;
    clip = ObRect( base );
    objc_offset( tree, obj, &clip.g_x, &clip.g_y );
    clip2 = srcbase = dstbase = rect = clip;  
    offset = new_slit - old_slit;
               
    if( !offset )			/* went nowhere fast...*/
    	   return;
    	   
    if( !open_vwork())
    {
        form_alert( 1, alert18 );
        return;
    }

    rc_intersect( &desk, &clip2 );
    if(  ( abs( offset )  <  MAX_SLITS ) &&
    	 rc_equal( &clip2, &clip ) 
      )
    {
       rect.g_h    = ( abs( offset ) * ObH( obj ) );
       dstbase.g_h = srcbase.g_h = ( MAX_SLITS - abs( offset ) ) * ObH( obj );
       if( offset > 0 )
       {
          objc_offset( tree, obj + abs( MAX_SLITS - offset ),
                       &dummy, &rect.g_y );
	  objc_offset( tree, obj + abs( offset ), &dummy, &srcbase.g_y );
       }
       else
	  objc_offset( tree, obj + abs( offset ), &dummy, &dstbase.g_y );

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
    Objc_draw( tree, base, MAX_DEPTH, &rect );

    close_vwork();
}







/*
 *==========================================================================
 * Hot and Cold Scroll Handling
 *==========================================================================
 */



/* Hot_Scroll() 
 *=================================================================
 * Object Scrolling Handler for Hot Scrolling Routines.
 * Called ONLY by Draw_IHot() and Draw_AHot()
 * The hot scrolling kicks in when the mouse is in ZONE 0 or ZONE 6.
 * The zone boundaries are created by 'Make_Hot_Spots()'.
 * IN:  FNODE *Xptr:	The Parent FNODE pointer to the linked list.
 *  	int cur_slit:	The current index into the linked list
 *	int First_Obj:	Either A0 or I0 - the first clickable object
 *	int End_Obj:	Either A5 or I5 - The last clickable object
 *
 * OUT: void
 */
void
Hot_Scroll( FON_PTR Xptr, int cur_slit, int first_obj, int end_obj )
{
    FON_PTR curptr;
    int   index;
           
    if( Xptr )
    {
     
      if( hot_index == 0 )		/* ZONE 0 Hot Spot */
      {
        /* Scrolling around the TOP...*/
        curptr = Find_Fnode( Xptr, cur_slit );
        new_index = cur_slit;

       /* We must now compare the initial index ('findex') to
        * our NEW index. If they are the same, we just draw it
        * based on the flag.
        */
        if( new_index == findex )
        {
            if( AFLAG( Base_Node ) )
                Select( first_obj );
		
            else
                Deselect( first_obj );
        }
        
        if( new_index < findex )
        {
   	  /* The New index is ABOVE the starting point.
	   * Therefore, we want to set the state to
	   * be the same as the 'Base_Node->aflag'
	   * The OBJECT is ALWAYS the first filename block
	   * while we are scrolling.
	   */
           if( AFLAG( Base_Node ) )
           {
             /* Want them SELECTED
              * So, if the node is deselected, SELECT IT
	      * else, leave it alone.
              * NOTE: Don't update the 'sflag'
              */
	     if( !AFLAG( curptr ) )
                  AFLAG( curptr )^= TRUE;
             Select( first_obj );    
           }
           else
           {
             /* Want it DESELECTED
              * So, if the node is selected, DESELECT IT
              * else, leave it alone.
              * NOTE: Don't update the 'sflag'
              */
             if( AFLAG( curptr ) )
                 AFLAG( curptr )^= TRUE;
             Deselect( first_obj );     
           }
        }
        
	if( new_index > findex )	       
	{
	  /* The New index is BELOW the starting point.
	   * Therefore, we want to set the state of the object
	   * to its ORIGINAL state. This is the 'sflag'.
	   * The OBJECT is ALWAYS the first filename block
	   * while we are scrolling.
	   */
	   AFLAG( curptr ) = SFLAG( curptr );
	   if( AFLAG( curptr ) )
	       Select( first_obj );
	   else
	       Deselect( first_obj );
	}
      }
      
      
      if( hot_index == ( MAX_SLITS + 1 ) )      	/* ZONE 6 Hot Spot */
      {
         /* Scrolling around the Bottom */
         curptr = Find_Fnode( Xptr, cur_slit + MAX_SLITS - 1);
	 index = Get_Findex( Xptr, curptr );
	 
             new_index = index;


             /* We must now compare the initial index ('findex') to
              * our NEW index.
              * If they are the same, we select/deselect it
              * based on the status of Base_Node.
              */
              if( new_index == findex )
              {
                 if( AFLAG( Base_Node ) )
                    Select( end_obj );
                 else
                    Deselect( end_obj );
              }
        
              if( new_index < findex )
              {
   	         /* The New index is ABOVE the starting point.
   	          * We want to RESTORE the original 'sflag' state.
	   	  * The OBJECT is ALWAYS the LAST filename block
	   	  * while we are scrolling.
	  	  */
	          AFLAG( curptr ) = SFLAG( curptr );
	          if( curptr->aflag )
	               Select( end_obj );
           	  else
	               Deselect( end_obj );
              }
              
	      if( new_index > findex )
              {
	  	 /* The New index is BELOW the starting point.
	  	  * We want to set the state of the object to the
	  	  * same as the Base_Node.
	          */
                 if( AFLAG( Base_Node ) )
                  {
                      /* Want them SELECTED
		       * So, if the node is deselected, SELECT IT
		       * else, leave it alone.
       	       	       * NOTE: Don't update the 'sflag'
        	       */
		       if( !AFLAG( curptr ) )
		            AFLAG( curptr )^= TRUE;
		       Select( end_obj );    /* had I0 here */
                  }
                  else
                  {
                     /* Want it DESELECTED
	              * So, if the node is selected, DESELECT IT
                      * else, leave it alone.
             	      * NOTE: Don't update the 'sflag'
                      */
                      if( AFLAG( curptr ) )
                         AFLAG( curptr )^= TRUE;
                      Deselect( end_obj );     /* had I0 here */
                  }
	      }

      } 			  /* hot_index == 6 */
    }


}






/* Make_Hot_Spots()
 *==========================================================================
 * Create the # Hot spot rectangles required for scrolling through the
 * filenames.  They are in this order:
 *
 *		______________________
 *		|                    |		ZONE 0 ( Above )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 1 ( LINE0 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 2 ( LINE1 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 3 ( LINE2 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 4 ( LINE3 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 5 ( LINE4 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 6 ( LINE5 )
 *		|                    |
 *		+--------------------+
 *		|		     |		ZONE 7 ( BELOW )
 *		|		     |
 *		----------------------
 *
 * NOTE: The widths of the zones are the width of the screen.
 * IN: int top_object:	LINE0
 */
void
Make_Hot_Spots( int top_object )
{
   int i;
   int obj;
   GRECT rect;
      
   for( i = 1; i <= MAX_SLITS; i++ )
   {
      obj = top_object + i - 1;
      hot_spot[ i ] = ObRect( obj );
      objc_offset( tree, obj, &hot_spot[i].g_x, &hot_spot[i].g_y );
      hot_spot[ i ].g_w = desk.g_w;
      hot_spot[ i ].g_x = desk.g_x;
   }
   rect = desk;
   rect.g_y = 0;
   rect.g_h = desk.g_y + desk.g_h;
   
   hot_spot[0] = hot_spot[ MAX_SLITS + 1 ] = rect;
   hot_spot[ 0 ].g_h = hot_spot[ 1 ].g_y;
   hot_spot[ MAX_SLITS + 1 ].g_y = hot_spot[ MAX_SLITS ].g_y + hot_spot[ MAX_SLITS ].g_h; 
   hot_spot[ MAX_SLITS + 1 ].g_h = rect.g_h - hot_spot[ MAX_SLITS + 1 ].g_y + 1;

   /* Now, adjust the rectangles clipped to the desktop */   
   for( i = 0; i < ( MAX_SLITS + 2 ); i++ )
      rc_intersect( &rect, &hot_spot[ i ] );
}




/* Get_Findex()
 *==========================================================================
 * Given the Parent FNODE pointer AND the FNODE pointer in question,
 * find its index into the linked list ( zero based ).
 * IN: FNODE *tptr:	The Parent FNODE pointer
 *     FNODE *ptr:	The FNODE pointer we want the index for.
 *
 * OUT: int:	The index into the linked list ( 0 based ) to the FNODE *ptr
 */
int
Get_Findex( FON_PTR tptr, FON_PTR ptr )
{
    FON_PTR curptr;
    int   count = 0;
    
    curptr = tptr;
    while( curptr )
    {
         if( curptr == ptr )
         	 break;
         count++;
         curptr = FNEXT( curptr );
    }
    return( count );
}



/* Get_Hot_Index()
 *==========================================================================
 * Get the 'hot_index' INDEX INTO the hot_spot array to tell us
 * which rectangle we ended up in for our filename scrolling.
 * Returns the OLD hot_index in d0 and the NEW hot_index in A0.
 * IN:	int *hot_index:	   Our previus ZONE that we were in. 
 *			   Upon exit, contains the NEW ZONE that we are in.
 * OUT: int:		   Returns the OLD ZONE that we were in.
 */
int
Get_Hot_Index( int *hot_index )
{
    int   index = 0;
    int   cold_index;
    MRETS mk;
   
    cold_index = *hot_index;
     
    Graf_mkstate( &mk );
    while( !xy_inrect( mk.x, mk.y, &hot_spot[ index++ ] ));				     
    index -= 1;

    *hot_index = index;	
    return( cold_index );
}





/* Find_Fnode()
 *==========================================================================
 * Given the Parent FNODE pointer ( filename node ) and the index (base 0 )
 * into the linked list, return the FNODE pointer to that index.
 * Note that we will return the end pointer if index exceeds the number
 * of nodes.
 * IN:	FNODE *ptr:	The parent FNODE pointer to the list.
 *	int index;	The INDEX into the linked list ( 0 based )
 *
 * OUT: FNODE *ptr:	Return the pointer to the node indexed in.
 */
FON_PTR
Find_Fnode( FON_PTR ptr, int index )
{
    FON_PTR curptr;
    int count = 0;
    
    curptr = ptr;
    while( curptr && ( count != index ) )
    {
 	count++;  
        curptr = FNEXT( curptr );
    }    	   

    return( curptr );   
}





/* Old_Index_Handler()
 *==========================================================================
 * 1) Selects/Deselects a filename object for the MOVER/RENAMER.
 * 2) Sets the FNODE flag of the old_index either to SELECT or DESELECT
 * NOTE: This routine basically cleans up AFTER 'new_index' and
 * 	 follows it around.
 * 
 * IN: 	int old_index:		 OLD index object INTO linked list 
 *	int new_index:		 NEW index object INTO linked list 
 *	int findex:		 index object INTO linked list that 
 *				 started all this scrolling thing... 
 *	FNODE *Top_Node:	 STARTING node of linked list		 
 *      FNODE *Base_Node:	 The findex NODE pointer
 *	int Above_Obj:		 rcs object when old_index < findex    
 *	int Below_Obj:		 rcs object when old_index > findex 
 */
void
Old_Index_Handler( int old_index, int new_index, int findex,
		   FON_PTR Top_Node, FON_PTR Base_Node,
		   int Above_Obj, int Below_Obj )
{
   FON_PTR Old_Node;			/* FNODE pointer of 'old_index'  */
   
   /* if the old_index is the same as 'findex', or
    * 'old_index' is the same as 'new_index',
    * then skip this routine.
    */
   if(( old_index != findex ) && ( old_index != new_index ) )			       
   {

      /* Get the NODE for the 'old_index'.  Find_Fnode() will always
       * return a node regardless. 'Top_Node' contains at least 
       * ONE node, otherwise, 'Old_Index_Handler would never have been
       * called.
       */
       Old_Node = Find_Fnode( Top_Node, old_index );


      /* CODE to Handle 'old_index' ABOVE 'findex' */
      if( old_index < findex )
      {
         /* Check if we are ABOVE or BELOW the 'new_index'
          *==================================================
          * CODE ONLY for 'old_index' being ABOVE 'new_index'
          * AND ABOVE 'findex'.
          * MEANING: the 'new_index' moved DOWNWARDS.
          *==================================================
          * For 'old_index' being ABOVE 'findex' BUT
          * BELOW 'new_index'.
          * MEANING: 'new_index' moved UPWARDS!
          * HOWEVER: INSPECTION reveals that 'old_index'
          *          handling is not required for that case.
          */
	  if( old_index < new_index )
          {
             /* We must RESTORE the 'Old_Node' to its
              * previous state, IF the conditions 
              * are met. Otherwise, do not touch anything.
              */
             if( AFLAG( Base_Node ) )
             {
                 if( !SFLAG( Old_Node ) )
                 {
                     AFLAG( Old_Node ) = SFLAG( Old_Node );
                     deselect( tree, Above_Obj );
                 }
             }
             else
             {
                 if( SFLAG( Old_Node ) )
                 {
                     AFLAG( Old_Node ) = SFLAG( Old_Node );
                     select( tree, Above_Obj );
                 }
             }
    	  }
    						      
      }				/* End of ( old_index < findex */
    						   


      /* CODE to Handle 'old_index' BELOW 'findex' */	
      if( old_index > findex )
      {
	 /* Check if we are ABOVE or BELOW the 'new_index'
          *==================================================
          * CODE ONLY for 'old_index' being BELOW 'new_index'
          * AND BELOW 'findex'.
          * MEANING: the 'new_index' moved UPWARDS.
          *==================================================
          * For 'old_index' being BELOW 'findex' AND
          * ABOVE 'new_index'...'new_index' moved 'DOWNWARDS'.
          * HOWEVER: INSPECTION reveals that 'old_index'
          *	     handling is not required for that case.
          */
          if( old_index > new_index )
    	  {
    	     /* Restore the 'old_node' to its previous state
    	      * if the below conditions are met. Otherwise
    	      * do not touch anything...
    	      */
    	     if( AFLAG( Base_Node ) )
    	     {
    	         if( !SFLAG( Old_Node ) )
    	         {
    	            AFLAG( Old_Node ) = SFLAG( Old_Node );
    	            deselect( tree, Below_Obj );
    	         }
    	     }
    	     else
    	     {
    	         if( SFLAG( Old_Node ) )
    	         {
    	           AFLAG( Old_Node ) = SFLAG( Old_Node );
    	           select( tree, Below_Obj );
    	         }
    	     }
	  }
       }	      	   
    }			/* If( ( old_index != new_index ) && ( old_index != findex ) ) */
}






/* New_Index_Handler()
 *==========================================================================
 * 1) Selects/Deselects a filename object for the MOVER/RENAMER.
 * 2) Sets the FNODE flag of the new_index either to SELECT or DESELECT
 * NOTE: This deals with 'new_index' which is followed by 'old_index'
 * 
 * IN: 	int old_index:		 OLD index object INTO linked list 
 *	int new_index:		 NEW index object INTO linked list 
 *	int findex:		 index object INTO linked list that 
 *				 started all this scrolling thing... 
 *	FNODE *Top_Node:	 STARTING node of linked list		 
 *	FNODE *Base_Node:	 FINDEX node in LINKED list		 
 *	int Above_Obj:		 rcs object when old_index < findex    
 *	int Below_Obj:		 rcs object when old_index > findex 
 */
void
New_Index_Handler( int old_index, int new_index, int findex,
		   FON_PTR Top_Node, FON_PTR Base_Node,
		   int Above_Obj, int Below_Obj )
{
   FON_PTR New_Node;			/* FNODE pointer of 'old_index'  */

   /* If the 'new_index' is the same as 'old_index' or
    * it is the same as 'findex', we skip this routine entirely.
    */					       
  if( ( new_index != old_index ) && ( new_index != findex ) )
  {
      /* Get the FNODE pointer based on the 'new_index' index.
       * NOTE: We will always have a node, otherwise this
       *       routine will never have been called.
       */
      New_Node = Find_Fnode( Top_Node, new_index );

      /* We must now decide whether to select, deselect or
       * leave the node flag alone depending upon the 
       * position of findex, old_index and new_index.
       * Depending upon the state of 'Base_Node', we will
       * either Select, Deselect or skip the node.
       */						   

     /* CODE where 'new_index' < 'findex'
      * MEANING: We are ABOVE findex.
      */    						   
     if( new_index < findex )
     {
         /* Check if we are ABOVE or BELOW the 'old_index'
          *===============================================
          * CODE ONLY for 'new_index' ABOVE 'old_index'
          * NOTE: We are MOVING UPWARDS.
          * HERE, we save the 'aflag' state to 'sflag'
          * and then toggle 'aflag'.
          * We THEN, REDRAW the OBJECT that the node
          * was in.
          *===============================================
          * NOTE: For the case where new_index > old_index.
          * This is where 'new_index' is BELOW 'old_index'
          * We are MOVING DOWNWARDS.
          * HOWEVER, initial estimates show that we can
          * ignore this case.
          */
         if( new_index < old_index )
         {
		if( AFLAG( Base_Node ) )
    		{
    		    /* The Base_Node wants SELECTED.
    		     * So, if our 'New_Node' is Deselected, SELECT IT!
    		     * by backing up to 'sflag' and toggling 'aflag'.
    		     * If we have already SELECTED it, don't do anything.
    		     */
    		    if( !AFLAG( New_Node ) )
    		    {
    		       SFLAG( New_Node ) = AFLAG( New_Node );
    		       AFLAG( New_Node )^= TRUE;
    		       select( tree, Above_Obj );
    		    }
    		}
    		else
    		{
    		    /* The Base_Node wants DESELECTED!
    		     * So, if our 'New_Node' is Selected, DESELECT IT!
    		     * by backing up to 'sflag' and toggling 'aflag'.
    		     * If we have already DESELECTED it, don't do anything.
    		     */
    		    if( AFLAG( New_Node ) )
    		    {
    		        SFLAG( New_Node ) = AFLAG( New_Node );
    		        AFLAG( New_Node )^= TRUE;
    		        deselect( tree, Above_Obj );
    		    }
    		}            
         }		/* end of if( new_index < old_index ) */
    						      
     }
    						   

    /* CODE where 'new_index' > 'findex'.
     * MEANIN: We are BELOW 'findex'.
     */    						   
    if( new_index > findex )
    {
        /* NOTE: Initial analysis shows that the case
         * new_index < old_index can be ignored.
         */
        if( new_index > old_index )
        {
    	   /* We are BELOW findex AND BELOW old_index...
    	    * meaning, we have moved DOWNWARDS to the new_index.
    	    */
    	   if( AFLAG( Base_Node ) )
    	   {
    	      /* The BASE wants SELECTED!
    	       * If we are DESELECTED, SELECT IT!
    	       * Update 'sflag' and toggle 'aflag'
    	       * If ALREADY SELECTED, SKIP! 
    	       */
    	      if( !AFLAG( New_Node ) )
    	      {
    	         SFLAG( New_Node ) = AFLAG( New_Node );
    	         AFLAG( New_Node ) ^= TRUE;
    	         select( tree, Below_Obj );
    	      }
    	   }
    	   else
    	   {
    	      /* The BASE wants DESELECTED!
    	       * If we are SELECTED, DESELECT IT!
    	       * Update 'sflag' and toggle 'aflag'
    	       * If ALREADY DESELECTED, SKIP!
    	       */
    	      if( AFLAG( New_Node ) )
    	      {
    	          SFLAG( New_Node ) = AFLAG( New_Node );
    	          AFLAG( New_Node )^= TRUE;
    	          deselect( tree, Below_Obj );
    	      }
    	   }  
      }
   }					
  }  /* End of if( old_index != new_index etc..*/
}








/* Do_Hot_Scroll()
 *==========================================================================
 * Perform THE HOT Scrolling by dragging the mouse around.
 * Called when LINE0 - LINE5 is clicked on.
 * 
 * int obj:		The Initial Object selected
 * int Top_Obj:		The Top Object selectable: A0 or I0
 * FNODE *Top_Node:	The Head Pointer Node of Linked List
 * FNODE *Base_Node:    The Node Pointer of the object selected.
 * int  Total:		Total Number of objects to scroll...
 *
 */
void
Do_Hot_Scroll( int obj, FON_PTR Top_Node, FON_PTR base_node,
	       int Top_Obj, int Total,
	       int Xbase, int Xslider, int *cur_slit,
	       FON_PTR Slit_Array[],  void (*foo)() )
{
     MRETS mk;
     
     int  sindex;			/* index into Slit Arrays */
     int  bstate;			/* Button state */

     int   cold_index;			/* shadow for hot_index */
     int   old_index;			/* Old index into linked list ( zero based ) */
     int   temp_index;
     FON_PTR New_Node;			/* The Node pointer to the new_index slot */
     int   ox;
     int  dir, index;
     BOOLEAN Skip_Flag = FALSE;
     BOOLEAN Scroll_Exit = FALSE;
          
     Base_Node = base_node;		/* Base_Node is Global and needs updating */

     sindex = obj - Top_Obj;
     
     Graf_mkstate( &mk );    

     /* If the person is holding down the shift key, add
      * another item. OTHERWISE, clear all of them.
      * HOWEVER, if this is the printer dialogbox, skip it! 
      */
     if( !( mk.kstate && K_LSHIFT ) )
             Undo_Fnodes( Top_Node, Base_Node );
    
     if( Top_Node && Base_Node )
     {
         AFLAG( Base_Node )^= TRUE;		/* <=====   NOTE: there might be a problem here */
         SFLAG( Base_Node ) = AFLAG( Base_Node );   /* Especially when shift key is supposed to be down*/
         if( AFLAG( Base_Node ) )
            select( tree, obj );
         else
            deselect( tree, obj );
      
         cold_index = hot_index = sindex + 1;
         findex = Get_Findex( Top_Node, Base_Node );
         old_index = new_index = findex;
         
         New_Node = Top_Node;
         while( New_Node )
         {
             SFLAG( New_Node ) = AFLAG( New_Node );
             New_Node = FNEXT( New_Node );
         }
         New_Node = NULL;
     }
    
    
     /* ------------------------------------------------------------
      * Enable or Disable the REMOVe and CONFIG buttons on
      * 2 dialog boxes...
      */
      
      
      /* This is the front dialog box - installed fonts */
      CheckHotFront( Top_Node );

      /* This is the available fonts dialog box..*/
      CheckHotAvailable( Top_Node );
     
      /* This is the Point Size dialog box */
      CheckHotPoints( Top_Node );

     Make_Hot_Spots( Top_Obj );
     do
     {
       /* Skip this whole mess if there isn't a Header Pointer or
        * a pointer where we clicked on.
        */
 	if( Top_Node && Base_Node )
 	{
 	    /* We now will look for the exit condition ( Going OUT )
 	     * or an up button, whichever occurs first.
 	     * Returns ZERO if button event occurred.
 	     */
 	    if( !Scroll_Exit ) 
 	         bstate = rub_wait( &hot_spot[ hot_index ], 1, 0 );
 	    else
 	         bstate = FALSE;
 	              
 	    if( !bstate )
 	    {
 	        /* Find out which hot_spot rectangle that we are in. */
 	        cold_index = Get_Hot_Index( &hot_index );
 	        
 	        /* If we have ended up in the SAME 'hot_index' slit, 
 	         * then we have gone nowhere. Therefore, skip
 	         * any scrolling.
 	         */
 	        
 	        Scroll_Exit = Skip_Flag = FALSE;
 	        if( hot_index != cold_index )
 	        {
 		   /*************************************************
		    * Hot_Index SCROLLING of filenames
		    * We have ended up within the filename slits.
		    *************************************************/

		    /* There are several cases possible only
		     * 		   START		 END
		     *		  Cold_Index	      Hot_Index
		     * CASE 0:      0 | 7		0 | 7
		     * CASE 1:      0 | 7		1 - 6	      
		     * CASE 2:      1-6			0 | 7
		     * case 3:	    1-6			1 - 6
		     * 
		     * We are going to have to clean up form cold to hot_index
		     * in turn since they might not necessarily be adjacent.
		     */

		    dir = 0;
		    dir = (( hot_index < cold_index ) ? ( -1 ) : ( dir ) );
		    dir = (( hot_index > cold_index ) ? ( 1 ) : ( dir ) );
		    index = cold_index + dir;

		    if(( cold_index == 0 ) || ( cold_index == ( MAX_SLITS + 1 )))
		    {
		        old_index = (( cold_index == 0 ) ? ( max( new_index - 1 , 0 ) ) : ( min( new_index + 1, Total - 1 )) );
		        if( old_index != new_index )
		        {
			     New_Node = Slit_Array[ index - 1 ];
			     if( New_Node )
			     {
				 new_index = Get_Findex( Top_Node, New_Node );

			         New_Index_Handler( old_index, new_index, findex,
			   		            Top_Node, Base_Node,
						    ( index - 1 ) + Top_Obj,
						    ( index - 1 ) + Top_Obj );
			      }		 
		        }
	        	old_index = new_index;
	        	    	     
	        	if( index != hot_index )
		            index += dir;
		        else
		            Skip_Flag = TRUE;	   
		        	    	     	
		        while( index != hot_index )
		        {
			     Hot_Old_New_Update( index, Top_Node,
		     	   			 old_index, findex, 
		     	            		 Top_Obj, Slit_Array );
		        	    		
		             index += dir;
		             old_index = new_index;	/* warning: new_index is global */
		             Skip_Flag = FALSE;	
		        }   
		    
		    } /* End of if(( cold_index == 0 ) || ( cold_index == ( MAX_INDEX + 1 )) */

		    if(( cold_index > 0 ) && ( cold_index <= MAX_SLITS ))
		    {
		        while( index != hot_index )
		        {
			    Hot_Old_New_Update( index, Top_Node,
		     	   			old_index, findex, 
		     	            		Top_Obj, Slit_Array );
		        	    
		            index += dir;
		            old_index = new_index;	/* warning: new_index is global */
		         }
		    
		    }	/* End of if(( cold_index > 0 ) && ( cold_index <= MAX_INDEX ))*/

      		    if(( ( hot_index > 0 ) && ( hot_index < ( MAX_SLITS + 1 ) ) ) && !Skip_Flag )
		    {
			Hot_Old_New_Update( hot_index, Top_Node,
		     		            old_index, findex, 
		     		            Top_Obj, Slit_Array );
       		    }					    		               
	        

		    if( ( hot_index == 0 ) || ( hot_index == ( MAX_SLITS + 1 ) ) )
		    {
		          /* We have ENTERED the box ABOVE or BELOW
		           * the Object area, therefore, SCROLL, if possible 
		           *
		           * hot_index == 0 or hot_index == 6 ( outside obj boundaries )
		           */
				           
		           /* need to update the old_index HERE before we enter the scroll */
		           temp_index = (( hot_index == 0 ) ? ( new_index - 1 ) : ( new_index + 1 ) );
			   Old_Index_Handler( old_index, temp_index, findex,
			                      Top_Node, Base_Node,
			                      ( hot_index - 2 ) + Top_Obj,
		 			      hot_index + Top_Obj );
			   ox = ( ( hot_index == 0 ) ? ( -1 ) : ( 1 ) );
		           Hot_Slide( tree, Xbase, Xslider, -1,
           			      ox, max( Total - MAX_SLITS, 0 ), 0,
           			      cur_slit, VERTICAL, &hot_spot[ hot_index ],
           			      foo );
           					      
			/* Update the Hot_Index flag to see where we really are...
			 * It SHOULD be either hot_index 1 or 5
			 *
			 * Need to figure out why slot 0 and 4 do not select or
			 * deselect after a slide like this.
			 *
			 */
			 Scroll_Exit = TRUE;
		    }
 	        
	 	    /* Update the old_index and the NEW index...*/
		    old_index = new_index;

 	        }  			/* End of 'if( hot_index != cold_index )' */
 	    }				/* End of 'if( !bstate )'		  */
 	}    
	Graf_mkstate( &mk );
     }while( mk.buttons != 0 );
}





/* Hot_Old_New_Update()
 *==========================================================================
 * Combines the Updating of the 'old_index' and the 'new_index' into
 * one routine.
 *
 * IN: 	int index:		The 'hot ZONE index'
 *	FNODE *Top_Node:	The Parent Node pointer to the list
 *	int old_index:		The 'old_index' into the linked list
 *	int findex:		The index to the fnode which we
 *				clicked on to start the scrolling.
 *	int Top_Obj:		Either A0 | I0
 *	FNODE *Slit_Array[]	The array (either for CPX or CPZ )
 *				that contains a pointer to the
 *				FNODE in that slit.
 */
FON_PTR
Hot_Old_New_Update( int index, FON_PTR Top_Node,
		     int old_index, int findex,
		     int Top_Obj, FON_PTR Slit_Array[] )
{
   FON_PTR New_Node = NULL;

	/**********************************************
	 * We have ENTERED a NEW object area.
	 * Get the FNODE and find out what the NEW 
	 * 'new_index' for that node is. If there is
	 * NO NODE, we SKIP any scrolling.
	 **********************************************/
	New_Node = Slit_Array[ index - 1 ];
	if( New_Node )
	{
	     new_index = Get_Findex( Top_Node, New_Node );

	     Old_Index_Handler( old_index, new_index, findex,
	                        Top_Node, Base_Node,
	                        ( index - 2 ) + Top_Obj,
			        index + Top_Obj );

	     New_Index_Handler( old_index, new_index, findex,
	  			Top_Node, Base_Node,
				( index - 1 ) + Top_Obj,
				( index - 1 ) + Top_Obj );
	}
	return( New_Node );
}



int
rub_wait( GRECT *obj, int dir, int state )
{
    int which, kr;
    int mb, ks, br;
    int mx, my;
    
    wind_update( BEG_MCTRL );
    which = evnt_multi( MU_BUTTON | MU_M1 , 0x01, 0x01, state,
    dir, obj->g_x, obj->g_y, obj->g_w, obj->g_h,
    0,0,0,0,0,
    0L,
    0,0,
    &mx, &my, &mb, &ks, &kr, &br);
    wind_update( END_MCTRL );
    return( which & MU_BUTTON );
}





/* Hot_Slide()
 *==========================================================================
 * Used EXCLUSIVELY by the HOT SCrolling routines in MOVER.C
 * This routine was needed because the existing routines couldn't
 * handle it.
 *
 * IN:	OBJECT *tree:		The object tree
 *	int base:		The base of the slider
 *	int slider:		The slider object.
 *	int obj:		The object clicked on ( -1 if none )
 *	int inc:		increment (+/- # )
 *	int min:		minimum value
 *	int max:		maximum value
 *	int *numvar:		current value
 *	int direction:		VERTICAL | HORIZONTAL
 *	GRECT *rect:		Rectangle for our hot spot. If we exit the
 *				rectangle, we exit this routine also.
 *	void (*foo)():		The custom slider draw routine.
 */
void
Hot_Slide( OBJECT *tree, int base, int slider, int obj,
           int inc, int min, int max, int *numvar,
           int direction, GRECT *rect, void (*foo)() )
{
    MRETS mk;
    int   newvalue, oldvalue;
    GRECT slidrect;

    slidrect = ObRect( slider );
    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
	/* account for outlines */
    slidrect.g_x -= 3;
    slidrect.g_y -= 3;
    slidrect.g_w += 6;
    slidrect.g_h += 6;

    if( obj > 0 )
	XSelect( tree, obj );

    oldvalue = *numvar;
    do {
	newvalue = *numvar + inc;

	if( max > min )
	{
	    if( newvalue < min ) newvalue = min;
	    else if( newvalue > max ) newvalue = max;
	}
	else
	{
	    if( newvalue > min ) newvalue = min;
	    else if( newvalue < max ) newvalue = max;
	}

	/* if in bounds, change the slider thumb */
	if( newvalue != oldvalue ) {
	    oldvalue = newvalue;
	    *numvar = newvalue;
	    if( direction == VERTICAL )
	      sl_y( tree, base, slider, newvalue, min, max, foo );
		/* undraw old */
	    Objc_draw( tree, base, 3 , &slidrect ); /* was 0 */
		/* draw new */
	    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
    	    slidrect.g_x -= 3;
    	    slidrect.g_y -= 3;
	    Objc_draw( tree, slider, 3 , &slidrect );
	    
        }
	Graf_mkstate( &mk );
    } while( ( mk.buttons != 0 ) && ( xy_inrect( mk.x, mk.y, rect )));

    if( obj > 0 )
	XDeselect( tree, obj );
    Objc_draw( tree, base, MAX_DEPTH, &slidrect );
}


/* FindNumSelected()
 *==========================================================================
 */
int
FindNumSelected( FON_PTR ptr )
{
   FON_PTR curptr;
   int     count;
   
   count  = 0;
   curptr = ptr;
   while( curptr )
   {
       if( AFLAG( curptr ) )
           count++;
       curptr = FNEXT( curptr );   
   }
   return( count );
}


FON_PTR
FindFirstFont( FON_PTR ptr )
{
   FON_PTR curptr;
   
   curptr = ptr;
   while( curptr )
   {
       if( AFLAG( curptr ) && ( FTYPE( curptr ) == SPD_FONT ) )
           break;
       curptr = FNEXT( curptr );   
   }
   return( curptr );
}



/* CheckHotFront()
 *==========================================================================
 * Turn On/Off Remove and Config buttons in the ad_front tree
 */
void
CheckHotFront( FON_PTR Head_Node )
{
      if( IsActiveTree( ad_front ) )
      {
         if( IsChanged( Head_Node ) )
         {
           if( IsDisabled( FREMOVE ) )
	      ChangeButton( ad_front, FREMOVE, TRUE );
       
           if( IsDisabled( FCONFIG ) )
	      ChangeButton( ad_front, FCONFIG, TRUE );
	 }
	 else
	 {
           if( !IsDisabled( FREMOVE ) )
	      ChangeButton( ad_front, FREMOVE, FALSE );
       
           if( !IsDisabled( FCONFIG ) )
	      ChangeButton( ad_front, FCONFIG, FALSE );
	 }     
      }
}



/* CheckHotAvailable()
 *==========================================================================
 * Turn On/Off Remove and Config buttons in the ad_inactive tree
 */
void
CheckHotAvailable( FON_PTR Head_Node )
{
      if( IsActiveTree( ad_inactive ) )
      {
         if( IsChanged( Head_Node ) )
         {
           if( IsDisabled( IINSTALL ) )
	       ChangeButton( ad_inactive, IINSTALL, TRUE );
       
           if( IsDisabled( ICONFIG ) )
	       ChangeButton( ad_inactive, ICONFIG, TRUE );
	 }
	 else
	 {
           if( !IsDisabled( IINSTALL ) )
	       ChangeButton( ad_inactive, IINSTALL, FALSE );
       
           if( !IsDisabled( ICONFIG ) )
	       ChangeButton( ad_inactive, ICONFIG, FALSE );
	 }
	 CheckSelectAll( TRUE );
      }
}




/* CheckHotPoints()
 *==========================================================================
 * Turn On/Off Delete Points button in the points tree
 */
void
CheckHotPoints( FON_PTR Head_Node )
{
      if( IsActiveTree( ad_points ) )
      {
         if( IsChanged( Head_Node ) )
         {
           if( IsDisabled( PNTDEL ) )
	       ChangeButton( ad_points, PNTDEL, TRUE );
	 }
	 else
	 {
           if( !IsDisabled( PNTDEL ) )
	       ChangeButton( ad_points, PNTDEL, FALSE );
	 }      
      }
}
