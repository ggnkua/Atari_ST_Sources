/*==========================================================================
 * FILE: SAMPLE.C
 *==========================================================================
 * DATE: 	September 28, 1990
 * DESCRIPTION: SAMPLE CPX demonstrating the use of the popup and slider
 *		functions in a FORM-TYPE CPX.
 * COMPILER: 	TURBO C Version 2.0
 */

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>

 
#include "sample.h"

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "sample.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "..\cpxdata.h"		   /* Our CPX Data Structures */	



/* PROTOTYPES
 *==========================================================================
 * The prototypes are required for TURBO C
 */
CPXINFO	*cdecl cpx_init( XCPB *Xcpb );
BOOLEAN cdecl  cpx_call( GRECT *rect );

void	initialize( void );
int	handle_button( int button, WORD *msg );
void	VDraw( void );
void	HDraw( void );

int	Pop_Handle( OBJECT *tree, int button, char *items[],
        	    int num_items, int *default_item, int font_size );


/* DEFINES
 *==========================================================================
 */
#define NUM_ITEMS	5		/* # of items for the popup.     */

#define MAX_ITEMS	12		/* Upper limit for slider value. */
#define MIN_ITEMS	0		/* Lower limit for slider value  */

#define AAAA		0		/* Start with the first index	 */
#define INIT_VALUE	6		/* Initial value for sliders	 */



/* EXTERNALS
 *==========================================================================
 */


/* GLOBALS
 *==========================================================================
 */
XCPB *xcpb;			      /* XControl Parameter Block       */
CPXINFO cpxinfo;		      /* CPX Information Structure      */

OBJECT *tree; 			      /* Our resource object tree  	*/
GRECT	desk;			      /* GRECT of the desktop work area */

char blanks[5][30];		      /* Used for Pop_Up String Builds  */
char *blank[5];		

char *menu_items[] = { "AAAA",	      /* The text for the popup button. */
		       "BBBB",
		       "CCCC",
		       "DDDD",
		       "EEEE"
	             };
	             
BOOLEAN click_flag = FALSE;	/* Double click flag */
int  cur_item;			/* Current popup menu item ( zero based )*/

char vcur_text[3];		/* Text Strings for current slider values*/
char hcur_text[3];

int  vcur_item;			/* Current Slider Values	      */
int  hcur_item;

MFORM Mbuffer;			/* Mouse background image storage     */

int   errno;			/* Variable for Turbo C only - itoa() */



/* FUNCTIONS
 *==========================================================================
 */

/* cpx_init()
 *==========================================================================
 * cpx_init() is where a CPX is first initialized.
 * There are TWO parts.
 *
 * PART ONE: cpx_init() is called when the CPX is first 'booted'. This is
 *	     where the CPX should read in its defaults and then set the
 *	     hardware based on those defaults.  
 *
 * PART TWO: The other time cpx_init() is called is when the CPX is being
 *	     executed.  This is where the resource is fixed up and current
 *	     cpx variables are updated from the hardware.  In addition,
 *	     this is where the CPXINFO structure should be filled out.
 *
 * IN:  XCPB	*Xcpb:	Pointer to the XControl Parameter Block
 * OUT: CPXINFO  *ptr:	Pointer to the CP Information Structure
 */			
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    xcpb = Xcpb;

     /* Only those CPXs with their 'Booting' flag or 'Set-only' flag
      * set will be initialized here.
      *
      * Read in your defaults from 'save_vars' and slam them into
      * the hardware where appropriate.
      *
      * Return TRUE to tell XCONTROL that the header should be retained
      * so that the cpx may be executed.
      *
      * Return FALSE to tell XCONTROL NOT to retain our header.
      * An example of this would be a 'Set-Only' CPX.
      */
    if( xcpb->booting )
        return( ( CPXINFO *)TRUE );  
    else
    {
      /* Fixup the resource...
       * The flag prevents rsh_fix() from being called more than once.
       * If executing from disk, rsh_fix() is called every time. However,
       * If the CPX is 'resident', rsh_fix() will be called only once.
       */
        
      if( !xcpb->SkipRshFix )
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                            rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                            rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                            rs_imdope );
           
      tree   = ( OBJECT *)rs_trindex[ MAINTREE ];
                        
      /* Initialize the CPXINFO structure */           
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = NULL;
      cpxinfo.cpx_wmove  = NULL;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = NULL;
      cpxinfo.cpx_button = NULL;
      cpxinfo.cpx_m1 	 = NULL;
      cpxinfo.cpx_m2	 = NULL;
      cpxinfo.cpx_hook   = NULL;
      cpxinfo.cpx_close  = NULL;
      
      return( &cpxinfo );
    }
}




/* cpx_call()
 *==========================================================================
 * Called when a CPX is invoked AFTER the cpx_init() call has been
 * completed.  The function is passed a rectangle describing the current
 * work area of the XControl window.  This allows a CPX to set up for
 * a user interaction and optionally call the custom xform_do() routine
 * to handle its user interface.
 *
 *
 * IN: GRECT *rect:	Ptr to a GRECT that describes the current work
 *			area of the XControl window.
 *
 * OUT:
 *   FALSE:     The CPX has exited and no more messages are
 *		needed.  XControl will either return to its
 *		main menu or close its windows.
 *		This is used by XForm_do() type CPXs.
 *
 *   TRUE:	The CPX requests that XCONTROL continue to
 *		send AES messages.  This is used by EVENT-TYPE CPXs.
 */
BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     int  button;
     int  quit = 0;
     WORD msg[8];
     
     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;

     initialize();
     
     Wind_get( 0, WF_WORKXYWH, ( WARGS *)&desk );
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     do
     {
	button = (*xcpb->Xform_do)( tree, 0, msg );
	quit = handle_button( button, msg );

     }while( !quit);
     return( FALSE );
}



/* initialize()
 *==========================================================================
 * Initialize the slider and popup values and calculate 
 * the slider positions.
 *
 * IN:  none
 *
 * OUT: none
 */
void
initialize( void )
{
   cur_item = AAAA;
   vcur_item = hcur_item = INIT_VALUE;

   itoa( vcur_item, vcur_text, 10 );
   TedText( SLIDEV ) = vcur_text;
   ( *xcpb->Sl_y)( tree, BASEV, SLIDEV, vcur_item, MAX_ITEMS, MIN_ITEMS, NULLFUNC );

   itoa( hcur_item, hcur_text, 10 );
   TedText( SLIDEH ) = hcur_text;
   ( *xcpb->Sl_x)( tree, BASEH, SLIDEH, hcur_item, MIN_ITEMS, MAX_ITEMS, NULLFUNC );
   
}




/* handle_button()
 *==========================================================================
 * Perform button click handling
 *
 * IN:  int button: AES object clicked on.
 *	WORD: *msg: message array returned from the event_multi().
 *
 * OUT: int quit:   Returns value to cpx_call().
 *		    FALSE - don't quit cpx
 *		    TRUE  - quit the cpx and return to XControl.
 *
 */
int
handle_button( int button, WORD *msg )
{
   int   quit = FALSE;
   int   obj;
   MRETS mk;
   int   ox,oy;

   /* Check if we have a double click item */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      click_flag = TRUE;
      button &= 0x7FFF;      
   }   
   
   switch( button )
   {
     case QUIT:  quit = TRUE;
     		 Deselect( QUIT );
     		 break;
	   		
     case POPUP: obj = Pop_Handle( tree, POPUP, menu_items, NUM_ITEMS, &cur_item, IBM );
		 if( obj != -1 )
		 {
		   cur_item = obj;
		   TedText( POPUP ) = menu_items[ cur_item ];
		   Objc_draw( tree, POPUP, MAX_DEPTH, NULL );
		 }
		 deselect( tree, POPUP );     
		 break;
		 
		 
		 
     case UP:	   (*xcpb->Sl_arrow)( tree, BASEV, SLIDEV, UP, -1,
           	    	              MAX_ITEMS, MIN_ITEMS, &vcur_item,
           	    	              VERTICAL, VDraw );
		   break;
     
     case DOWN:	   (*xcpb->Sl_arrow)( tree, BASEV, SLIDEV, DOWN, 1,
	           	    	      MAX_ITEMS, MIN_ITEMS, &vcur_item,
	           	    	      VERTICAL, VDraw );
           	   break;	      

     case BASEV:   Graf_mkstate( &mk );
                   objc_offset( tree, SLIDEV, &ox, &oy );
                   ox = (( mk.y < oy ) ? ( -2 ) : ( 2 ) );
                   (*xcpb->Sl_arrow)( tree, BASEV, SLIDEV, -1, ox,
             	    	              MAX_ITEMS, MIN_ITEMS, &vcur_item,
             	    	              VERTICAL, VDraw );
		   break;

     case SLIDEV:  (*xcpb->MFsave)( MFSAVE, &Mbuffer );
	           graf_mouse( FLAT_HAND, 0L );
                   (*xcpb->Sl_dragy)( tree, BASEV, SLIDEV, MAX_ITEMS,
                   		      MIN_ITEMS, &vcur_item, VDraw );
	           (*xcpb->MFsave)( MFRESTORE, &Mbuffer );
     		   break;
     		  



     case LEFT:	   (*xcpb->Sl_arrow)( tree, BASEH, SLIDEH, LEFT, -1,
           	    	      MIN_ITEMS, MAX_ITEMS, &hcur_item,
           	    	      HORIZONTAL, HDraw );
		   break;
		   
     case RIGHT:   (*xcpb->Sl_arrow)( tree, BASEH, SLIDEH, RIGHT, 1,
           	    	      MIN_ITEMS, MAX_ITEMS, &hcur_item,
           	    	      HORIZONTAL, HDraw );
           	   break;	      

     case BASEH:   Graf_mkstate( &mk );
                   objc_offset( tree, SLIDEH, &ox, &oy );
                   oy = (( mk.x < ox ) ? ( -2 ) : ( 2 ) );
                   (*xcpb->Sl_arrow)( tree, BASEH, SLIDEH, -1, oy,
             	    	              MIN_ITEMS, MAX_ITEMS, &hcur_item,
             	    	              HORIZONTAL, HDraw );
     		   break;
     		   
     case SLIDEH:  (*xcpb->MFsave)( MFSAVE, &Mbuffer );
	           graf_mouse( FLAT_HAND, 0L );
                   (*xcpb->Sl_dragx)( tree, BASEH, SLIDEH, MIN_ITEMS,
                   		      MAX_ITEMS, &hcur_item, HDraw );
	           (*xcpb->MFsave)( MFRESTORE, &Mbuffer );
     		   break;
     
     		 		      		       			           
     default:	 if( button == -1 )
     		 {
     		   switch( msg[0] )
     		   {
     		     case AC_CLOSE:  
     		     case WM_CLOSED: quit = TRUE;
				     break;

     		     case WM_REDRAW: 
		     case CT_KEY:    
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
     		 break;
   }
   return( quit );
}



/* VDraw()
 *==========================================================================
 * Convert the vertical slider value to a string, update the rcs 
 * structure, and redraw the string.
 * 
 * GLOBAL: int vcur_item:
 *	   char vcur_text[]:
 *	   OBJECT *tree:
 *
 * IN:  none
 * OUT: none
 */
void
VDraw( void )
{
  itoa( vcur_item, vcur_text, 10 );
  TedText( SLIDEV ) = vcur_text;
  Objc_draw( tree, SLIDEV, 0, NULL );   
}




/* HDraw()
 *==========================================================================
 * Convert the horizontal slider value to a string, update the rcs 
 * structure, and redraw the string.
 * 
 * GLOBAL: int hcur_item:
 *	   char hcur_text[]:
 *	   OBJECT *tree:
 *
 * IN:  none
 * OUT: none
 */
void
HDraw( void )
{
  itoa( hcur_item, hcur_text, 10 );
  TedText( SLIDEH ) = hcur_text;
  Objc_draw( tree, SLIDEH, 0, NULL );
}




/* Pop_Handle()
 *==========================================================================
 * Setup the strings for the popup menu. We want the strings to have 2
 * spaces in front of each string and spaces after the string up to
 * the length + 1 of the longest string.
 * 
 * IN: 	OBJECT *tree:	  our RCS tree
 * 	int    button:    The popup object we clicked on to get here.
 *	char   *items[]:  Pointer array to the text for the menu.
 *	int    num_items: The number of items in the text array.
 *      int    *default_item:  The current item to check mark ( zero based)
 *			       Set to -1 if no item is to be checked.
 *	int    font_size: AES font size - currently the large font
 *			  is only supported.
 *
 * OUT: # of the menu item selected ( zero based ).
 *               - OR -
 *     -1 No item selected.
 */
int
Pop_Handle( OBJECT *tree, int button, char *items[], int num_items,
            int *default_item, int font_size )
{
   GRECT butn, world;
   
   int  i;
   int  obj;

   butn = ObRect( button );
   objc_offset( tree, button, &butn.g_x, &butn.g_y );
   world = ObRect( ROOT );
   objc_offset( tree, ROOT, &world.g_x, &world.g_y ); 
   
   /* This will put 2 spaces before each string and 1 space after
    * each string. For variable length strings, you'll have to 
    * pad spaces up to the length of the longest string plus 1.
    */
   for( i = 0; i < num_items; i++ )
   {
      strcpy( &blanks[i][0], "  ");
      strcat( &blanks[i][0], items[ i ]);
      strcat( &blanks[i][0], "  ");
      blank[i] = &blanks[i][0];
   }
   
   obj = (*xcpb->Popup)( blank, num_items, *default_item, font_size, &butn, &world );
   return( obj );
}


