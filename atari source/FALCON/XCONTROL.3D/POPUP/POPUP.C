/* POPUP.C
 *==========================================================================
 * DATE: February 19, 1990
 * DESCRIPTION: Generic Popup Routines
 *
 * INCLUDE: POPSTUFF.H
 *
 * 031290	cjg	Pop_Text()- Modified to pass in the width of the
 *			selected button + 3 ( which takes care of the
 *			shadow.  This way, we make sure that the popup
 *			is at least as wide as the button.
 * 121692	cjg	Exit if fails the open_vwork()
 */



/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <string.h >
#include <tos.h>

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "popup.rsx"
#pragma warn .apt
#pragma wanr .rpt
#include "popup.h"
#include "fixrsh.h"



/* PROTOTYPES
 *==========================================================================
 */
short  cdecl Pop_Up( char *items[], int num_items, int default_item,
                     int font_size, GRECT *button, GRECT *world );

void   Pop_FixUp( void );

int    Pop_Text( char *items[], int num_items, int default_item,
                 int font_size, int but_width );
                 
int    Pop_Blit( long *PopPtr, GRECT *clip, int flag );
GRECT  Pop_Offset( GRECT *button, GRECT *world );
void   Pop_Arrow( int obj, int *offset, int num_items, char *item[] );
int    rub_wait( GRECT *obj, int dir, int state );

int    Set_Box( OBJECT *tree, int index, int cur_height,
	        int Height, int Width, int Just, int FontSize,
	 	char *text );


/* EXTERNALS
 *==========================================================================
 */
int	open_vwork( void );
void	close_vwork( void );
extern int AES_Version;
extern int gl_ncolors;

/* DEFINES
 *==========================================================================
 */
#define POP_MAX		5	   /* 5 slots max for popups menu items */
#define DELAY		125	   /* Delay for Arrow increments	*/
#define XDELAY		25	   /* Delay to wait after a Popup       */
				   /* activates, and before we check the*/
				   /* mouse button status.		*/

#define POP_BLINK	0	   /* # of blinks when item selected	*/
				   /* want 0 - 3			*/
				   /* Remain Set to Zero because of     */
				   /* Copyright (c) Apple Corp.		*/

#define BLINK1		50	   /* 50 ms display selected...         */	   
#define BLINK2		100	   /* 100 ms display deselected...	*/

#define LOOK_OUT	1	   /* Direction to look for hotspot	*/		
#define LOOK_IN		0	   /* Ditto...			        */

#define EVNT_MASK	( MU_BUTTON | MU_M1 )




/* LOCAL
 *==========================================================================
 */

struct foobar {
	WORD	dummy;
	WORD	*image;
	};




/* FUNCTIONS
 *==========================================================================
 */
 


/* Pop_Up()
 *==========================================================================
 * DESCRIPTION: Entry point for performing popup menu items.
 *
 * IN:	char *items[]:		Pointer to string array.		
 *				Note: Text must already be formated to  
 *				be min of 2 blanks in front of text.    
 * 				and 1 blank after longest menu item.	
 *				The remaining menu items must be padded 
 *				to be equal to the longest item.	
 * 				The text will be right justified in the 
 *				objects.				
 *	int num_items:		The number of menu objects - 1 based.	
 *	int default_item:	The default menu item. ( zero based )   
 *				This is the index into the text array   
 *				If -1, don't check any item.		
 *	int font_size:		Either IBM or SMALL text		
 *	GRECT *button:		The GRECT of the button pressed.	
 * 	GRECT *world:		The GRECT of the CPX.			
 *				Note: the GRECT.g_x and GRECT.g_y must  
 *				already be fixed up with objc_offset()  
 *									
 *	Pop_Up() will perform its redraw by copying the cpx and then    
 *  	redrawing by blitting the original screen back in. This way     
 * 	the Pop_Up() routines do not need to know about the original    
 *	tree and is therefore, independent.				
 *									
 *	There are only 5 slots available for the menu items.		
 *	If more menu items are needed, Pop_Up() will change slot 1 and  
 *	slot 5 to up and down scroll arrows respectively.	
 *
 * OUT: Returns -1 if failed for any reason, (ie: not enough memory )
 *		   Or the user clicked outside of the popup box.
 *      Returns the object index into the text array if a menu item was
 *	selected.
 *
 * When clicking on a menu item, if the user lets go of the button, 
 * the user must click to execute an operation. Ergo, of the user is
 * still holding down the button, the user must let go of the button for
 * an operation to occur.
 */
short
cdecl
Pop_Up( char *items[], int num_items, int default_item,
        int font_size, GRECT *button, GRECT *world )
{
   OBJECT *tree;			/* Our OBJECT Tree....    	*/
   int    offset;			/* Offset if scrolling box	*/
   int    aflag = 0;			/* Flag if arrows used..  	*/
   long   PopPtr;			/* Pointer to malloced mem	*/

   GRECT  base;				/* GRECT of POPUP box	  	*/
   int    obj;				/* object selected	  	*/
   MRETS  mk;				/* mouse structures	  	*/
   int    oldobj;			/* old object		  	*/
   int    dirflag;   			/* direction for mouse hot spot */
   int    done = FALSE;			/* Done flag to return..	*/
   int    event;			/* Mouse button event flag	*/
   					/* TRUE = event occurred	*/
   GRECT  wall;				/* GRECT of mouse hotspot	*/
   int    outobj;			/* return obj ( adjusted )	*/
   int    exit_state;			/* looking for up or down button*/
   GRECT  work;
   int    dummy;
   
   Pop_FixUp();
   offset = Pop_Text( items, num_items, default_item,
                      font_size, ( button->g_w + 3 ) );
   aflag = (offset & 0x8000 );
   offset &= 0x7FFF;
   work = Pop_Offset( button, world );
   if( !Pop_Blit( &PopPtr, &work, 0 ))
   		return( -1 );
   		
   Objc_draw( ad_object, QBASE, MAX_DEPTH, &work );

   ActiveTree( ad_object );
   base = ObRect( QBASE );
   objc_offset( ad_object, QBASE, &base.g_x, &base.g_y );

   Evnt_timer( XDELAY );  
   Graf_mkstate( &mk );
   exit_state = ( mk.buttons ^ TRUE );
   
   oldobj  = -1;
   obj = objc_find( ad_object, QBASE, MAX_DEPTH, mk.x, mk.y );
   dirflag = (( obj == -1 ) ? ( LOOK_IN ) : ( LOOK_OUT ));
   
   do
   {
       if( obj != -1 )
       {	
	   if( obj != oldobj )
   	   {		
	     Select( obj );
	     wall = ObRect( obj );
	     objc_offset( ad_object, obj, &wall.g_x, &wall.g_y );
	     if( oldobj != -1 )
	     {		
		Deselect( oldobj );
		Objc_draw( ad_object, oldobj, 0, NULL );
	     }
	     dirflag = LOOK_OUT;
	     Objc_draw( ad_object, obj, 0, NULL );
	   }
       }
       else
       {
	   wall = base;
	   dirflag = LOOK_IN;
	   if( oldobj != -1 )
           {
	      Deselect( oldobj );
	      Objc_draw( ad_object, oldobj, 0, NULL );
           }
       }

       oldobj = obj;
       
       Graf_mkstate( &mk );
       event = FALSE;
       if( (xy_inrect(mk.x, mk.y, &wall ) && dirflag ) ||
	   ( !xy_inrect(mk.x, mk.y, &wall ) && !dirflag ) )
       event = rub_wait( &wall, dirflag, exit_state );
          
       Graf_mkstate( &mk );
       obj = objc_find( ad_object, QBASE, MAX_DEPTH, mk.x, mk.y );

       if( event && aflag && (( obj == Q1 ) || ( obj == Q5 ) ))
       {
	  event = FALSE;					
          Pop_Arrow( obj, &offset, num_items, items );	
	  Evnt_timer( DELAY );				
       }

       if( event )
	   done = TRUE;
		
   }while( !done );

   /* Get rid of the Check Mark */
   if( default_item != -1 )
           *items[ default_item ] = 0x20;

   Pop_Blit( &PopPtr, &base, 1 );
/*   Evnt_button( 1, 1, 0, &mk ); cjg - 05/12/92 */
   /* Wait for up Button! */
   do
   {
      Graf_mkstate( &mk );
   }while( mk.buttons );
   
   if( obj == -1 )
      outobj = obj;
   else
      outobj = (( aflag ) ? ( obj - Q2 + offset ) : ( obj - Q1 + offset ) );

   return( outobj );
}




/* Pop_FixUp()
 *==========================================================================
 * Fixes up the custom resource for the Popup box. Note the name change
 * in the RSX file
 *
 * GLOBALS: RSH file objects
 * LOCAL: static skip_flag: - used to skip the resource fixup if
 *			      it was already done.
 */
void
Pop_FixUp( void )
{
   int i,index;
   static int skip_flag = 0;
   
   if( !skip_flag )
   {
     for( i = 0; i < NUM_ADS; i++ )		/* Fixup Base Objects */
     {
   	index = (int)ad_object[i].ob_spec.index;
   	if( ad_object[i].ob_type == G_BOXTEXT )
   	{
	    /* fix pointers in TEDINFO */
	    ad_tedinfo[index].te_ptext  =
	              ad_strings[(long)(ad_tedinfo[index].te_ptext)];
	    ad_tedinfo[index].te_ptmplt =
	              ad_strings[(long)(ad_tedinfo[index].te_ptmplt)];
	    ad_tedinfo[index].te_pvalid =
	              ad_strings[(long)(ad_tedinfo[index].te_pvalid)];
	    ad_object[i].ob_spec.tedinfo = &ad_tedinfo[index];
   	}
   	Rsrc_obfix( ad_object, i );
     }
     skip_flag = TRUE;
   }
}

int
Set_Box( OBJECT *tree, int index, int cur_height,
	 int Height, int Width, int Just, int FontSize,
	 char *text )
{
     SetNormal( index );
     ObW( index )     = Width;
     TedJust( index ) = Just;
     TedFont( index ) = FontSize;
     TedText( index ) = text;
#if 0
     /* Do THIS ONLY if AES Version 0x0330 or Greater! */
     if(( AES_Version >= 0x0330 )
       && ( gl_ncolors > LWHITE ))     
     {  
       ObType( index ) |= 0x0100;/* DRAW3D */
       TedColor( index ) = ( TedColor( index ) & 0xFF70L ) | LWHITE | 0x70;
     }
#endif     
     return( cur_height + Height );
}




/* Pop_Text()
 *==========================================================================
 * Takes the text array and inserts them into the popup box menu items.
 * If there are > 5 items, arrows will be used in slot 1 and 5
 *
 * IN:  char *items[]:		string array of menu items
 *	int num_items:		number of menu items
 *	int default_item:	default item, -1 if none
 *	int font_size:		IBM or SMALL_FONT
 *
 * OUT: Returns the offset index into the text array.
 *      It can be non-zero if arrows are in use. The high bit is set to
 *	indicate if arrows are in use.
 */
int
Pop_Text( char *items[], int num_items, int default_item,
          int font_size, int but_width )
{   
   OBJECT *tree;
   int i, index;
   int offset = 0;
   int width  = 0;
   int height = 0;

   width =  (int)(strlen( items[0] ) + 1 ) * 8;	/* Get width of objects  */
   
   ActiveTree( ad_object );   
   ObW( QBASE ) = max( width, but_width );	
   if( num_items <= POP_MAX )
   {			
	index = 0;   	
	do
   	{
   	    height = Set_Box( tree, index + Q1,
   	    		      height, ObH( index + Q1 ) - 1,
   	    		      max( width, but_width ),
   	    		      TE_RIGHT, font_size,
   	    		      items[ index ] );
   	    if( index == default_item )  *items[ index ] = 0x08;
	    ObNext( index + Q1 ) = index + Q1 + 1;
   	    index++;
   	}while( index < num_items );
	ObNext( index - 1 + Q1 ) = QBASE;
	ObTail( QBASE ) = index + Q1 - 1;
   }					
   else
   {
     /* Using Arrows...ensure that the default item is in the middle */
     index = (( default_item == -1 ) ? ( 0 ) : ( default_item - 1));
     if( index < 0 ) index = 0;
     
     if( default_item > ( num_items - 2 ) )
     	index = num_items - 3;
     offset = index;
     
     
     height = Set_Box( tree, Q1, height,
     		       ObH( Q1 ) - 1,
     		       max( width, but_width ),
     		       TE_CNTR, IBM, ad_strings[0] );
     height = Set_Box( tree, Q5, height,
     		       ObH( Q5 ) - 1,
     		       max( width, but_width ),
     		       TE_CNTR, IBM, ad_strings[ 12 ] );

     for( i = Q2; i <= Q4; i++ )
     {
 	 height = Set_Box( tree, i, height, ObH( i ) - 1,
 	 		   max( width, but_width ),
 	 		   TE_RIGHT, font_size, items[ index ] );
 	 		   
   	 if( index == default_item )  *items[ index ] = 0x08;
         index++;
     }
     
     /* Set the upper bit to show Arrows are being used. */
     index = offset;
     offset = offset | 0x8000;
     
     for( i = Q1; i<= Q4; i++ )
     	ObNext( i ) = i + 1;
     ObNext( Q5 ) = QBASE;
     ObTail( QBASE ) = Q5;
   }
   ObH( QBASE ) = height + 1;
   return( offset );
}






/* Pop_Blit()
 *==========================================================================
 * Blit from screen to buffer or buffer to screen for Popup Box redraws.
 *
 * IN: long *PopPtr:	Pointer to memory buffer...
 *     GRECT *area:	GRECT of blit PXY area
 *     GRECT *clip:	GRECT of clip blit area
 *     int   flag:	0 - blit from screen to buffer
 *                      1 - blit from buffer to screen
 *
 * OUT: returns true if successful, false if failed.
 */
int
Pop_Blit( long *PopPtr, GRECT *clip, int flag )
{
   long location = 0L;				/* SCREEN MFDB		*/
   static int  nplanes;				/* Number of planes	*/
   int  pxy[8];					/* pxy for blit		*/
   static MFDB PopMFDB;				/* buffer MFDB		*/
   
   unsigned long size;				/* size of malloc	*/

   if( !open_vwork() )
     return( FALSE );

   clip->g_w = clip->g_w + 2;
   clip->g_h = clip->g_h + 2;   
   rc_2xy( clip, ( WORD *)&pxy[0] );
   vs_clip( vhandle, 1, pxy ); 
   
   if( !flag )					/* screen to buffer blit*/
   {
     vq_extnd( vhandle, 1, work_out );
     nplanes = work_out[4];

     size = (unsigned long)(((long)clip->g_w + 7L )/8L) *
            (long)clip->g_h * (long)nplanes;
     size = size * 2L;       
     *PopPtr = (long)Malloc( (unsigned long ) size );
     if( !*PopPtr )
     {
		close_vwork();
	     	return( FALSE );
     }
     
     PopMFDB.fd_addr 	= (long *)*PopPtr;	/* Setup the MFDB      */
     PopMFDB.fd_w	= clip->g_w;			
     PopMFDB.fd_h	= clip->g_h;
     PopMFDB.fd_wdwidth = ( clip->g_w + 15 ) / 16;
     PopMFDB.fd_stand 	= 0;
     PopMFDB.fd_nplanes = nplanes;
     PopMFDB.fd_r1 	= PopMFDB.fd_r2 = PopMFDB.fd_r3 = 0;
   }  
   
   graf_mouse( M_OFF, 0L );

   if(!flag )			
   { 
     /* Screen to buffer blit */  
     rc_intersect( &desk, clip );        
     rc_2xy( clip, ( WORD *)&pxy[0] );
     pxy[4] = pxy[5] = 0;	       
     pxy[6] = clip->g_w - 1;
     pxy[7] = clip->g_h - 1;
     vro_cpyfm( vhandle, 3, pxy, (MFDB *)&location, &PopMFDB );
   }
   else				
   {
     /* Buffer to screen blit */
     rc_intersect( &desk, clip );
     pxy[0] = pxy[1] = 0;	       
     pxy[2] = clip->g_w - 1; 
     pxy[3] = clip->g_h - 1;
     rc_2xy( clip, ( WORD *)&pxy[4] );   
     vro_cpyfm( vhandle, 3, pxy, &PopMFDB, (MFDB *)&location );
     if( *PopPtr )
         Mfree( (long)*PopPtr );
   }
   graf_mouse( M_ON, 0L );

   close_vwork();
   return( TRUE );
}






/* Pop_Offset()
 *==========================================================================
 * Reposition the Popup box to the button selected
 * Adjust position if not enough room on the bottom or to the right.
 *
 * IN: GRECT *button:		GRECT of button
 *     GRECT *world:		GRECT of cpx (used for boundary checks )
 *
 * OUT: void
 */
GRECT 
Pop_Offset( GRECT *button, GRECT *world )
{
   GRECT work;
   OBJECT *tree;

   ActiveTree( ad_object );
   work = ObRect( QBASE );
   work.g_x = ObX( QBASE ) = button->g_x;
   work.g_y = ObY( QBASE ) = button->g_y;
   
   /* adjust if extends below the bottom of the world */
   if(( work.g_y + work.g_h ) >= ( world->g_y + world->g_h ))
   	work.g_y = ObY( QBASE ) = work.g_y - ( work.g_h - button->g_h ) + 3;
   	
   /* adjust if extends past the right edge of the world.*/
   if(( work.g_x + work.g_w ) >= ( world->g_x + world->g_w ))
   	work.g_x = ObX( QBASE ) =  work.g_x - ( work.g_w - button->g_w ) + 3;
   	
   /* 
    * Set the clipping rectangle taking into account the Shadow
    * of the object
    */
   work.g_x = ( ObX( QBASE ) -= 1 );
   work.g_y = ( ObY( QBASE ) -= 1 );
   work.g_w += 3;
   work.g_h += 3;
   return( work );
}





/* Pop_Arrow()
 *==========================================================================
 * Scroll the popup menu items if up or down arrow is selected.
 * 
 * IN: int obj:		up or down arrow is selected.
 *     int *offset:	Offset into the menu items text array
 *     int num_items:   Total number of menu items involved.
 *     char *items[]:   Pointer to the text array
 *
 * OUT: void
 */
void
Pop_Arrow( int obj, int *offset, int num_items, char *items[] )
{
   OBJECT *tree;
   int draw = FALSE;
   int i;

   ActiveTree( ad_object );
   /* Up Arrow Selected AND not at the top */
   if( ( obj == Q1 ) && ( *offset > 0 ))
   {
       *offset -= 1;
       draw = TRUE;
   }

   /* DOWN Arrow and not within 3 items from the bottom */
   if( ( obj == Q5 ) && ( *offset < ( num_items - 3 ) ) )
   {
       *offset += 1;
       draw = TRUE;
   }

   if( draw )
   {
      for( i = ( Q2 - Q2 ); i <= Q4 - Q2; i++ )
      {
          TedText( i + Q2 ) = items[ *offset + i ];
  	  SetNormal( i + Q2 );
 	  Objc_draw( ad_object, i + Q2, 0, NULL );
      }
   }   
}





/* rub_wait()
 *==========================================================================
 * Wait for mouse button event or mouse rectangle event...
 *
 * IN:  GRECT *obj:		- GRECT for rect hot spot
 *	int   dir:		- Direction looking for
 *				  0 = entry	1 = exit
 *	int   state:		- button state looking for
 * 
 * OUT: returns 0 if button event occurred
 */
int
rub_wait( GRECT *obj, int dir, int state )
{
	int which, kr;
	int mb, ks, br;
	int mx, my;
	
	wind_update( BEG_MCTRL );
	which = evnt_multi( EVNT_MASK,0x01, 0x01, state,
	dir, obj->g_x, obj->g_y, obj->g_w, obj->g_h,
	0,0,0,0,0,
	0L,
	0,0,
	&mx, &my, &mb, &ks, &kr, &br);
	
	wind_update( END_MCTRL );
	return( which & MU_BUTTON );
}


