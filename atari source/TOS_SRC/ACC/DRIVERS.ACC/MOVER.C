/* FILE:  MOVER.C
 *==========================================================================
 * WARNING: THIS VERSION DOES NOT DO HOT SCROLLING....
 * THE CODE HAS BEEN REMOVED....
 *
 * DATE:  May 16, 1990
 *	  Nov  5, 1992  3D
 *	  Nov 23, 1992  For New ACC - Removed Hot Scrolling Routines
 *	  Jan 15, 1993  When clicking on a printer, write the assign.sys
 *			immediately.
 *
 * DESCRIPTION: MOVER
 *
 * INCLUDE FILE: MOVER.H
 */
 
/* NOTES: To make this a totally independent routine, several things
 *        need to be changed.
 *        1) MAX_SLITS - defines how many items can be displayed at once.
 *	  2) fblank[]  - a blank string to blank out the slots.
 *	  3) hot_spot[] - array to create a rectangle ( MAX_SLITS + 2 )
 *	                  to detect hot spots.
 *	  5) double_clicking - needs a routine to handle double clicking
 *	                       when needed.
 *	  6) If we want an object to be enabled/disabled depending upon
 *	     whether any mover objects are selected needs UNDO_FNODES()
 *	     to be modified to clear the appropriate object when 
 *	     necessary.
 *	     DO_HOT_SCROLL() also needs to be modified to enable/disable
 *	     the hot object based upon a mover object selections.
 */
 
 
/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h> 
#include <stdlib.h>

#include "country.h"
#include "drvhead.h"
#include "fsmio.h"

#include "drivers.h"
#include "mainstuf.h"
#include "device.h"
#include "sliders.h"
#include "text.h"


/* STRUCTURES
 *==========================================================================
 */
struct foobar {
	WORD	dummy;
	WORD	*image;
	};

 
/* EXTERNS
 *==========================================================================
 */ 
extern int AES_Version;
extern int gl_ncolors;
void	WaitForUpButton( void );



/* PROTOTYPES
 *==========================================================================
 */
 
/* Interface Routines */
void	mover_setup( HDEVICE_PTR list_ptr, int font_count,
		     int base, int slider, int up, int down,
		     int first_obj, int last_obj, int base_obj,
		     int start_index, int num_slits );

void mover_button( int obj );

void	Undo_Fnodes( HDEVICE_PTR ptr );
BOOLEAN IsChanged( HDEVICE_PTR ptr );
HDEVICE_PTR	Find_Fnode( HDEVICE_PTR ptr, int index );


/* Slit handling */
void  	Draw_Slit( void );
void  	slit_offset_adjust( HDEVICE_PTR ptr, int value, HDEVICE_PTR array[] );
void	Assign_Slit( HDEVICE_PTR ptr, HDEVICE_PTR array[] );
void	Blit_Slits( int old_slit, int new_slit );
int	Get_Findex( HDEVICE_PTR tptr, HDEVICE_PTR ptr );


void	device_mover_setup( DEV_PTR list_ptr, int font_count,
		     int base, int slider, int up, int down,
		     int first_obj, int last_obj, int base_obj,
		     int start_index, int num_slits );
void  	device_offset_adjust( DEV_PTR ptr, int value, DEV_PTR array[] );
void	Device_Assign_Slit( DEV_PTR ptr, DEV_PTR array[] );
int	Get_Device_Index( DEV_PTR tptr, DEV_PTR ptr );
void  	Draw_Device_Slit( void );
void	device_mover_button( int obj );
void	Undo_Dnodes( DEV_PTR ptr, int flag );
void	RedrawObject( OBJECT *tree, int obj );
void	ClearHFLAG( HDEVICE_PTR ptr );



/* DEFINES
 *==========================================================================
 */



/* GLOBALS
 *==========================================================================
 */
 
/* MOVER/RENAME VARIABLES */

/* The blank string for the filenames    */
char fblank[] = "                           ";
char fblank2[] = "    ";
char fblank3[] = "                         ";
char fblank4[] = "   ";

DEV_PTR device_hdptr = NULL;
DEV_PTR Device_Slit[12];
char *Device_Array[] = { "   ",
			"   ",
			"   ",
			"   ",
			"   ",
			"   ",
			"   ",
			"   ",
			"   ",
			"   ",
			"   ",
			"   "
		      };
		      
DEV_PTR	     dhdptr = NULL;
HDEVICE_PTR  hdptr = NULL;		/* Active FNODE Pointer Head		 */
int      Total;			/* Total 'Active' filenames		 */
HDEVICE_PTR  Active_Slit[8];/* These are arrays of FNODE pointers    
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
mover_setup( HDEVICE_PTR list_ptr, int font_count,
	     int base, int slider, int up, int down,
	     int first_obj, int last_obj, int base_obj,
	     int start_index, int num_slits )
{
    int i;

    hdptr = list_ptr;
    Total = font_count;

    Mbase 	= base;
    Mslider	= slider;
    Mup		= up;
    Mdown	= down;
    First_Obj	= first_obj;
    Base_Obj	= base_obj;
    Obj_Beg	= first_obj;
    Obj_End	= last_obj;           
    MAX_SLITS   = num_slits;
        
    for( i = 0; i < MAX_SLITS;i++ )
    {
        Active_Slit[i] = NULL;
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
 *
 */
void
mover_button( int obj )
{
   MRETS mk;
   int   ox,oy;
   HDEVICE_PTR curptr;
   DEV_PTR temp_device;
      
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

           graf_mkstate( ( int *)&mk.x, &oy, (int *)&mk.buttons, ( int *)&mk.kstate );
	   do
	   {
	       graf_mkstate( (int *)&mk.x, (int *)&mk.y, (int *)&mk.buttons, ( int *)&mk.kstate );
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


	if(( obj >= Obj_Beg ) && ( obj <= Obj_End ))
	{
	    if( !IsSelected( obj ) )
	    {
	      curptr = Active_Slit[ obj - First_Obj ];
	      if( !curptr )
	      	return;	      
	      
/*	      SetChangeFlag();*/
	      Undo_Fnodes( hdriver_head );
	      HFLAG( curptr ) = TRUE;
	      XSelect( tree, obj );
	      cur_cdriver = HNAME( curptr );
	      
              strcpy( driver_text, cdrivers[ HNAME( curptr )] );
              TedText( FPRINTER ) = &driver_text[0];
              Objc_draw( tree, FPRINTER, MAX_DEPTH, NULL );

              temp_device = find_device( 21 );	/* find the printer device */
              if( !temp_device )
      	      {
      	         /* Add the Device if necessary */
                 temp_device = AddNewDevice( 21 );
        	 if( temp_device )
        	 {
          	   /* found a slot and added it to the device linked list array. */
	  	   DNAME( temp_device ) = cdriver_array[ cur_cdriver ];         
	         }  
              }
              else
                /* Else, just change the device name */
                DNAME( temp_device ) = cdriver_array[ cur_cdriver ];   

	      if( IsDisabled( FREMOVE ) )
	        ChangeButton( tree, FREMOVE, TRUE );
	      
	      if( strstr( cdrivers[ cur_cdriver ], NonSpeedo ) )
	      {
	        if( !IsDisabled( FCONFIG ) )
	          ChangeButton( tree, FCONFIG, FALSE );
	      }
	      else
	      {	                      
                if( IsDisabled( FCONFIG ) )
                  ChangeButton( tree, FCONFIG, TRUE );
              }
              /* WRITE THE ASSIGN.SYS IMMEDIATELY */
              write_assign();    
	   }  
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
Undo_Fnodes( HDEVICE_PTR ptr )
{
    int     i;
    	
    ClearHFLAG( ptr );	
    
    for( i = 0; i < MAX_SLITS; i++ )
    {
        if( IsSelected( First_Obj + i ) )
            XDeselect( tree, First_Obj + i );
    }    
}



/* ClearHFLAG()
 *==========================================================================
 */
void
ClearHFLAG( HDEVICE_PTR ptr )
{
    HDEVICE_PTR curptr;
    	
    curptr = ptr;
    while( curptr )
    {
        HFLAG( curptr ) = FALSE;   
        curptr = HNEXT( curptr );
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
Undo_Dnodes( DEV_PTR ptr, int flag )
{
    DEV_PTR curptr;
    int     i;
    	
    curptr = ptr;
    while( curptr )
    {
        DFLAG( curptr ) = FALSE;   
        curptr = DNEXT( curptr );
    }
    
    for( i = 0; i < MAX_SLITS; i++ )
    {
        if( IsSelected( DCOVER0 + ( i * 6 ) ))
        {
            Deselect( DCOVER0 + ( i * 6 ) );
            Objc_draw( tree, DCOVER0 + ( i * 6 ) - 5, MAX_DEPTH, NULL );
        }    
    }    

    if( flag )
    {
      if( !IsDisabled( DMODIFY ) )
      {
        NoExit( DMODIFY );
        Disable( DMODIFY );

        RedrawObject( tree, DMODIFY );
      }

      if( !IsDisabled( DDELETE ) )
      {
         NoExit( DDELETE );
         Disable( DDELETE );

         RedrawObject( tree, DDELETE );
      }    
   }   
}




/*
 *==========================================================================
 * Linked List Handling
 *==========================================================================
 */

/* Device_Assign_Slit()
 *==========================================================================
 *  Assigns the 6 slits visible an FNODE, where possible.
 * IN: FNODE *ptr:	Start assigning with this node
 *     FNODE *array[]:	A 5 slit pointer array.
 */
void
Device_Assign_Slit( DEV_PTR ptr, DEV_PTR array[] )
{
    int i;
    DEV_PTR curptr;
    
    curptr = ptr;
    for( i = 0; i < MAX_SLITS; i++ )
    {
        array[ i ] = NULL;

	Deselect( First_Obj + ( i * 6 ) + 5 );
	
	strcpy( Device_Array[i], fblank4 );
	TedText( First_Obj + ( i * 6 ) + 1 ) = Device_Array[i];
        TedText( First_Obj + ( i * 6 ) + 2 ) = fblank3;
        HideObj( First_Obj + ( i * 6 ) + 3 );	
        HideObj( First_Obj + ( i * 6 ) + 4 );	

        if( curptr )
        {
              array[i] = curptr;
              sprintf( Device_Array[i], "%d", DDEV( curptr ) );
	      TedText( First_Obj + ( i * 6 ) + 1 ) = Device_Array[i];
	      TedText( First_Obj + ( i * 6 ) + 2 ) = drivers[ DNAME( curptr )];


	      if( ( DTYPE( curptr ) == 'p' ) || ( DTYPE( curptr ) == 'P' ))
                 ShowObj( First_Obj + ( i * 6 ) + 3 );	

	      if( ( DTYPE( curptr ) == 'r' ) || ( DTYPE( curptr ) == 'R' ))
                 ShowObj( First_Obj + ( i * 6 ) + 4 );	
              curptr = DNEXT( curptr );	
        }  
    }
}



/* Assign_Slit()
 *==========================================================================
 *  Assigns the 6 slits visible an FNODE, where possible.
 * IN: FNODE *ptr:	Start assigning with this node
 *     FNODE *array[]:	A 5 slit pointer array.
 */
void
Assign_Slit( HDEVICE_PTR ptr, HDEVICE_PTR array[] )
{
    int i;
    HDEVICE_PTR curptr;
    
    curptr = ptr;
    for( i = 0; i < MAX_SLITS; i++ )
    {
        array[ i ] = NULL;
        Deselect( First_Obj + i );
        TedText( First_Obj + i ) = fblank;

        if( curptr )
        {
            if( HNAME( curptr ) != -1 )
            {
              array[i] = curptr;
              TedText( First_Obj + i ) = cdrivers[ HNAME( curptr )];
               
	      if( HFLAG( curptr ) )
            	  Select( First_Obj + i );
              curptr = HNEXT( curptr );	
            }  
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


/* Draw_Slit()
 *==========================================================================
 * The Draw Slider Routine passed into the Active ( CPX ) slider routines.
 */
void
Draw_Device_Slit( void )
{
    Undo_Dnodes( device_head, TRUE );

    device_offset_adjust( device_head, Cur_Slit, Device_Slit );
    Blit_Slits( Old_Slit, Cur_Slit );
    Old_Slit = Cur_Slit;
}




/* slit_offset_adjust()
 *==========================================================================
 * Assign the linked list to the slits. Used in conjuction with Assign_Slit.
 * IN: FNODE *ptr:	The Head Pointer Node
 *     int   value:	The Index (base 0 ) into the linked list
 *     FNODE *array[]:	Text for the slider.
 */
void
slit_offset_adjust( HDEVICE_PTR ptr, int value, HDEVICE_PTR array[] )
{
    HDEVICE_PTR curptr;
    int   i;
    
    curptr = ptr;
    
     
    for( i = 0; i < value; i++ )
       curptr = HNEXT( curptr );
    Assign_Slit( curptr, array );
}



/* device_offset_adjust()
 *==========================================================================
 * Assign the linked list to the slits. Used in conjuction with Assign_Slit.
 * IN: FNODE *ptr:	The Head Pointer Node
 *     int   value:	The Index (base 0 ) into the linked list
 *     FNODE *array[]:	Text for the slider.
 */
void
device_offset_adjust( DEV_PTR ptr, int value, DEV_PTR array[] )
{
    DEV_PTR curptr;
    int   i;
    
    curptr = ptr;
    
     
    for( i = 0; i < value; i++ )
       curptr = DNEXT( curptr );
    Device_Assign_Slit( curptr, array );
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
    int   variable;
    
    obj  = First_Obj;
    base = Base_Obj;
    clip = ObRect( base );
    objc_offset( tree, obj, &clip.g_x, &clip.g_y );
    
    if( tree == ad_front )
       variable = 1;
    
    if( tree == ad_device )
       variable = 6;
       
    clip2 = srcbase = dstbase = rect = clip;  
    offset = new_slit - old_slit;
               
    if( !offset )			/* went nowhere fast...*/
    	   return;
    	   
    if( !open_vwork())
    {
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
          objc_offset( tree, obj + ( abs( MAX_SLITS - offset ) * variable ),
                       &dummy, &rect.g_y );
	  objc_offset( tree, obj + ( abs( offset ) * variable ), &dummy, &srcbase.g_y );
       }
       else
	  objc_offset( tree, obj + ( abs( offset ) * variable ), &dummy, &dstbase.g_y );

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
Get_Findex( HDEVICE_PTR tptr, HDEVICE_PTR ptr )
{
    HDEVICE_PTR curptr;
    int   count = 0;
    
    curptr = tptr;
    while( curptr )
    {
         if( curptr == ptr )
         	 break;
         count++;
         curptr = HNEXT( curptr );
    }
    return( count );
}



/* Get_Device_Index()
 *==========================================================================
 * Given the Parent FNODE pointer AND the FNODE pointer in question,
 * find its index into the linked list ( zero based ).
 * IN: FNODE *tptr:	The Parent FNODE pointer
 *     FNODE *ptr:	The FNODE pointer we want the index for.
 *
 * OUT: int:	The index into the linked list ( 0 based ) to the FNODE *ptr
 */
int
Get_Device_Index( DEV_PTR tptr, DEV_PTR ptr )
{
    DEV_PTR curptr;
    int   count = 0;
    
    curptr = tptr;
    while( curptr )
    {
         if( curptr == ptr )
         	 break;
         count++;
         curptr = DNEXT( curptr );
    }
    return( count );
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
HDEVICE_PTR
Find_Fnode( HDEVICE_PTR ptr, int index )
{
    HDEVICE_PTR curptr;
    int count = 0;
    
    curptr = ptr;

    while( curptr && ( count != index ) )
    {
       count++;  
       curptr = HNEXT( curptr );
    }    	   
    return( curptr );
}





/* device_mover_setup()
 *==========================================================================
 * RETURNS TRUE - SUCCESS
 *	   FALSE- ERROR! ( probably memory allocation )
 */
void
device_mover_setup( DEV_PTR list_ptr, int font_count,
	            int base, int slider, int up, int down,
	            int first_obj, int last_obj, int base_obj,
	            int start_index, int num_slits )
{
    int i;

    dhdptr = list_ptr;
    Total = font_count;

    Mbase 	= base;
    Mslider	= slider;
    Mup		= up;
    Mdown	= down;
    First_Obj	= first_obj;
    Base_Obj	= base_obj;
    Obj_Beg	= first_obj;
    Obj_End	= last_obj;           
    MAX_SLITS   = num_slits;
        
    for( i = 0; i < MAX_SLITS;i++ )
    {
        Deselect( First_Obj + ( i * 6 ) + 5 );
        
        Device_Slit[i] = NULL;
	TedText( First_Obj + ( i * 6 ) + 2 ) = fblank3;
        HideObj( First_Obj + ( i * 6 ) + 3 );	
        HideObj( First_Obj + ( i * 6 ) + 4 );	
    }
        
    if( Total > MAX_SLITS )
    {
       if( start_index > Total - MAX_SLITS )
           start_index = Total - MAX_SLITS;
    }
    else
       start_index = 0;
       
    device_offset_adjust( dhdptr, start_index, Device_Slit );

    if( start_index )
        start_index = Get_Device_Index( dhdptr, Device_Slit[0] );
    
    Old_Slit = Cur_Slit = start_index;
    sl_size( tree, Mbase, Mslider, Total, MAX_SLITS, VERTICAL, 0 );
    sl_y( tree, Mbase, Mslider, Cur_Slit,
          max( Total - MAX_SLITS, 0 ), 0, NULLFUNC );

}


/* device_mover_button()
 *==========================================================================
 * Handles the button events for the CPX Mover/Rename Function
 * IN: int obj:		The RCS Object clicked on.
 * OUT: BOOLEAN:   TRUE - Exit the CPX Mover Config
 *		   FALSE - Remain in the CPX Mover Config
 *
 */
void
device_mover_button( int obj )
{
   MRETS mk;
   int   ox,oy;
   DEV_PTR curptr;
               
        Old_Slit = Cur_Slit;
	if( obj == Mup )
	{        
	   sl_arrow( tree, Mbase, Mslider, Mup, -1,
           	     max( Total - MAX_SLITS, 0 ), 0,
           	     &Cur_Slit, VERTICAL, Draw_Device_Slit );
           return;			    	     
        }   			    	     

        if( obj == Mdown )
        {
           sl_arrow( tree, Mbase, Mslider, Mdown, 1,
           	     max( Total - MAX_SLITS, 0 ), 0,
           	     &Cur_Slit, VERTICAL, Draw_Device_Slit );
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

           graf_mkstate( ( int *)&mk.x, &oy, ( int *)&mk.buttons, (int *)&mk.kstate );
	   do
	   {
	       graf_mkstate( (int*)&mk.x, (int*)&mk.y, (int*)&mk.buttons, (int*)&mk.kstate );
	   }while( mk.buttons && ( mk.y == oy ));
           
 	   if( mk.buttons && ( mk.y != oy ))
	   {
              sl_dragy( tree, Mbase, Mslider,
           	        max( Total - MAX_SLITS, 0 ), 0,
           	        &Cur_Slit, Draw_Device_Slit );
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
             	     &Cur_Slit, VERTICAL, Draw_Device_Slit );
           return;           		  	    	     
        }   		  	    	     


	if( ( obj >= DCOVER0 ) && ( obj <= DCOVER11 ))
	{
	    if( !IsSelected( obj ) )
	    {
	    
	      curptr = Device_Slit[ (( obj - 5 ) - DLINE0 ) / 6 ];
	      if( !curptr )
	      {
	         Undo_Dnodes( device_head, TRUE );
	         return;
	      }

	      Undo_Dnodes( device_head, FALSE );
	      
	      DFLAG( curptr ) = TRUE;
	      Select( obj );
	      Objc_draw( tree, obj - 5, MAX_DEPTH, NULL );

	      if( IsDisabled( DMODIFY ) )
	      {	      
	        MakeExit( DMODIFY );
	        Enable( DMODIFY );
	        RedrawObject( tree, DMODIFY );
	      }
	        
	      if( IsDisabled( DDELETE ) && ( DDEV( curptr ) > 9 ) )
	      {
	        Enable( DDELETE );
	        MakeExit( DDELETE );
	        RedrawObject( tree, DDELETE );
	      }

	      if( !IsDisabled( DDELETE ) && ( DDEV( curptr ) <= 9 ))
	      {
		NoExit( DDELETE );
		Disable( DDELETE );
		RedrawObject( tree, DDELETE );
	      }  
 	      
	    }
	    else
	    {
	      Undo_Dnodes( device_head, TRUE );
	    }  
	    WaitForUpButton();
	}	    
}




/* RedrawObject()
 *==========================================================================
 */
void
RedrawObject( OBJECT *tree, int obj )
{
    GRECT rect;
    
    rect = ObRect( obj );
    objc_offset( tree, obj, &rect.g_x, &rect.g_y );
    rect.g_x -= 5;
    rect.g_y -= 5;
    rect.g_w += 10;
    rect.g_h += 10;
    Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
}
