/* FILE:  XCONFIG.C
 *==========================================================================
 * DATE:  January 21, 1990
 * DESCRIPTION:
 *
 * INCLUDE FILE: XCONFIG.H
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdlib.h>

#include "country.h"
#include "xcontrol.h"				/* Xcontrol.c defines   */

#include "cpxdata.h"				/* Keep these in order..*/
#include "xstructs.h"
#include "cpxhandl.h"				

#include "popstuff.h"				/* Popup.c prototypes	*/
#include "timedate.h"				/* Timedate.c prototypes*/
#include "xcontrl2.h"				/* Xcontrol.c prototypes*/
#include "windows.h"
#include "xerror.h"
/*#include "sliders.h"*/
#include "slots.h"
#include "stuffptr.h"
#include "xoptions.h"
#include "mover.h"
#include "text.h"


/* PROTOTYPES
 *==========================================================================
 */
void redraw_xconfig( GRECT *xrect, GRECT *rect );
void clear_xconfig( void );
void move_xconfig( GRECT *rect );
void Xconfig_buttons( MRETS *mrets );
void xoptions( int obj );

int  Pop_Handle( OBJECT *tree, int button, char *items[], int num_items,
                 int *default_item, int font_size, int width );
                 
void close_xconfig( BOOLEAN flag );


void set_xopt_items( int num );
BOOLEAN IsXconfigActive( void );
BOOLEAN IsXtreeActive( void );



/* DEFINES
 *==========================================================================
 */

/* cpx xconfiguration defines */
#define XOPT_ITEMS   	5			/* Number of items     */

#define XOPT1_NOCPX	2			/* Number if AES >= 3.01 */
#define XOPT2_NOCPX	3			/* Number if AES < 3.01  */


#define XOPT_YESCPX	5			/* number WITH cpxs    */


#define NO_XTREE	( -1 )
#define NO_XOBJ		( -1 )
#define NO_XCONFIG	( -1 )
#define RETURN	0x1C0D
#define ENTER	0x720D




/* GLOBALS
 *==========================================================================
 */
int XOPT_NOCPX;				/* Number of menu items for XOPT1_NOCPX or XOPT2_NOCPX */

char blanks[40][40];	       		/* strings for popup		*/
char *blank[40];


int  xconfig = NO_XCONFIG;	/* flag if a xconfig object is displayed
				 * -1 == no xconfig object is displayed
				 * else # is index based on xoption_string
				 * If there is an xconfig option, the xtree
				 * and xobj should be filled in too...
				 */

OBJECT *xtree;			/* xconfig tree objects			  */


/* FUNCTIONS
 *==========================================================================
 */
 

/* clear_xconfig()
 *==========================================================================
 * Clear the flag and object trees associated with an Xconfiguration routine
 *
 * IN:  void
 * OUT: void
 *
 * GLOBAL:    int  xobj;	object to draw from for xconfig option
 *	      int  xconfig:     number of xconfig active, -1 if none
 *	      OBJECT *xtree:    object tree of xconfig option
 * 	      int num_xoptions: number of xconfig options visible
 *				in the popup menu.
 */		 
void
clear_xconfig( void )
{
  xconfig = NO_XCONFIG;
  xtree = ( OBJECT *)NO_XTREE;
  set_xopt_items( XOPT_NOCPX );
  Delete_Fnodes();
}





/* close_xconfig()
 *==========================================================================
 * Clear the xconfiguration flag and trees due to a close window message
 * and/or an ACC_CLOSE message
 * 
 * Called ONLY by acc_close() and wm_close()
 * IN:  TRUE - called by Acc_close();
 *      FALSE - called by wm_close();
 * 
 * At acc_close(), we treat it as a cancel
 * at wm_close(), treat it as OK
 */
void	
close_xconfig( BOOLEAN flag )
{
   if( ( xconfig == OPT_XOPTION ) && flag )
	pop_xdata();		/* treat as cancel */
   else
        push_xdata();		/* treat as OK     */
   clear_xconfig();
}




/* set_xopt_items()
 *==========================================================================
 * Set the number of Xconfiguration items that are in the Pop_handle menu
 * 
 * IN:  int num:		number of items to show in popup menu
 *				for xconfig options
 * OUT: void
 *
 * GLOBAL:   int num_xoptions:  Number of items visible in popup menu
 *				for xconfig options.
 */
void
set_xopt_items( int num )
{
   /* Settle with this for now, we will change pop_handle later */
   num_xoptions = num;
   if( num_xoptions == XOPT_NOCPX )
   {
   	xconfig_string[0] = First_String[0];
   	xconfig_string[1] = First_String[1];
   	xconfig_string[2] = First_String[2];
   }   	
   else
   {
        xconfig_string[0] = Second_String[0];
        xconfig_string[1] = Second_String[1];
        xconfig_string[2] = Second_String[2];
        xconfig_string[3] = Second_String[3];
        xconfig_string[4] = Second_String[4];
   }     
}



/* redraw_xconfig()
 *==========================================================================
 * Redraw the xconfiguration dialog box due to a redraw message
 *
 * IN: GRECT *xrect:	GRECT of dirtied area
 *     GRECT *rect:	xconfig work area
 *
 * OUT: void
 *
 * GLOBAL:   int xobj:	    ROOT of xconfig option
 */
void
redraw_xconfig( GRECT *xrect, GRECT *rect )
{
   OBJECT *tree;
   			   
   if( IsXconfigActive() && IsXtreeActive() )
   {
	ActiveTree( xtree );
        ObX( ROOT ) = rect->g_x;
        ObY( ROOT ) = rect->g_y;
        do_redraw( xtree, ROOT, xrect );
   }
}




/* move_xconfig()
 *==========================================================================
 * Update the x and y coordinates of the root due to a move message
 *
 * IN:   GRECT *rect:		GRECT of new rectangle
 * OUT:  void
 *
 * GLOBAL:  int xobj:		ROOT of xconfig tree
 */
void
move_xconfig( GRECT *rect )
{
   OBJECT *tree;
   
   if( IsXconfigActive() && IsXtreeActive() )
   {
      ActiveTree( xtree );
      ObX( ROOT ) = rect->g_x;
      ObY( ROOT ) = rect->g_y;
   }
}


/* IsXconfigActive()
 *==========================================================================
 * Returns the status of the xconfig flag.
 * NO_XCONFIG == no xconfig option is currently active.
 * Otherwise, it is the index of which xconfig. 0, 1, 2
 */
BOOLEAN
IsXconfigActive( void )
{
   return( xconfig != NO_XCONFIG );
}



/* IsXtreeActive()
 *==========================================================================
 * Makes sure that the a tree exists for the xconfig option.
 * Problem is, we always set it while setting the xconfig flag...
 * Therefore, during optimization, this check can probably go away.
 */
BOOLEAN
IsXtreeActive( void )
{
   return( xtree != ( OBJECT *)NO_XTREE );
}




/* Xkeys_config()
 *==========================================================================
 * Xconfig options keyboard handling.
 * Checking only for the first 3 xconfig options and look only for
 * RETURN or ENTER. The last option, is the UNLOAD CPX option and
 * doesn't require any keyboard handling.
 */
void
Xkeys_config( int key  )
{
  OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];

  if( IsXconfigActive() && IsXtreeActive() && ( xconfig != OPT_UNLOAD )  )		
  {
     if( ( key == RETURN ) || ( key == ENTER ))
     {
     	 /* Check if we're already using XINFO and STATUS
     	  * if IN STATUS, return to XINFO
     	  * otherwise, return to XCONTROL 
     	  */
         if( ( xconfig == OPT_XOPTION ) && !xopt_keys() )
         	return;
         clear_xconfig();
         do_redraw( tree, XCONTROL, &w.phy );
     }
  }
}




/* Xconfig_buttons()
 *==========================================================================
 * Handle the button events for Xconfiguration selections. Each case, is
 * a separate Xconfiguration Selection.
 *
 * IN:  MRETS *mrets		 mouse rectangle information
 * OUT  void
 *
 * GLOBAL:   int xconfig:      which xconfig option is active?
 *	     OBJECT *xtree:    object tree of xconfig option
 *	     int xobj:	       ROOT of xconfig option
 *	     char dirpath[]:   directory path of cpxs
 *	     char path[]:      path for File Selector
 *	     char dirname[]:   filename for File Selector
 *           int  dirsize:     text size of new path
 *	     int  dircount:    increment counter for scrolling
 *	     char template[]:  Template path for text obj
 *	     int  out:	       fsel_name return
 */
void
Xconfig_buttons( MRETS *mrets )
{
  OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
  int  obj;
  BOOLEAN  redraw_flag = FALSE;
             	
  if( IsXconfigActive() && IsXtreeActive() )
  {
      obj = objc_find( xtree, ROOT, MAX_DEPTH, mrets->x, mrets->y );
      switch( xconfig )
      {
         case OPT_ABOUT:   redraw_flag = do_about_button( obj );
          	           break;
              		
         case OPT_INFO:	   redraw_flag = do_info_button( obj );
         		   break;
         		   
         case OPT_XOPTION: redraw_flag = do_option_button( obj );
		   break;
		   
         default:
                   break;
      }
           
      if( redraw_flag )
      {
         clear_xconfig();
         do_redraw( tree, XCONTROL, &w.phy );
      }
  }
}





/* xoptions()
 *==========================================================================
 * Handle the Pop_up menu for the xconfiguration selections
 *
 * IN: int obj:		which xconfig option was selected?
 * OUT: void
 * 
 * GLOBAL:   int xconfig:    which xconfig option was selected?
 *	     OBJECT *xtree:  object tree of xconfig option
 *	     int xobj:	     object root of xconfig option
 *	     int hour_state: 12 or 24 hour time setting
 *	     char template[]:text for text object
 *	     int dircount:   index for dir path scrolling
 *	     int dirsize:    text size of path
 *	     WINFO  w:	     Window structure
 */
void
xoptions( int obj )
{
   OBJECT *ad_tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   OBJECT *tree;
   int dft;
   
   dft = -1;
#if USA | UK   
   obj = Pop_Handle( ad_tree, obj, xconfig_string, num_xoptions,
                     &dft, IBM, ( num_xoptions == XOPT_NOCPX ) ? ( XOPT_WIDTH - 2 ) : ( XOPT_WIDTH ) );
#else
  obj = Pop_Handle( ad_tree, obj, xconfig_string, num_xoptions,
                     &dft, IBM, XOPT_WIDTH );
#endif   

   switch( obj )
   {
      case OPT_ABOUT:   xopt_about();
      	      	        break;

      case OPT_INFO:    xopt_info();
      			break;
      			      	      
      case OPT_XOPTION: xopt_option();
 	      		break;
    
      case OPT_OPEN:    if( num_xoptions == XOPT_NOCPX )
      			   xopt_shutdown();
      			else
      			   xopt_open();
       			break;
      			            	      
      case OPT_UNLOAD:  xopt_unload();
       	      	        break;
      	      
      default: clear_xconfig();
      	       break;
   }
     
   if(  IsXconfigActive() && IsXtreeActive() )
   {
      objc_offset( ad_tree, XBASE, &w.phy.g_x, &w.phy.g_y );
      
      ActiveTree( xtree );
      ObX( ROOT ) = w.phy.g_x;
      ObY( ROOT ) = w.phy.g_y;
      do_redraw( xtree, ROOT, &w.phy );
   }
}





/* Pop_Handle()
 *==========================================================================
 * Adjust the strings of the popup menu items and perform the popup.
 *
 * IN:   OBJECT *tree:		object tree
 *       int button:		button object
 *	 char *items[]:		string array of text menu items
 *	 int num_items:		number of menu items
 *       int *default_item:     The default item that will have a check mark
 *				if none desired, -1 will suffice.
 *	 int font_size:		Either IBM or SMALL_FONT
 *	 int width:		number of characters wide. This should be
 *				at least 1 character longer than the
 *				longest string, plus 2 characters in front
 *			        of the string.
 *
 * OUT: int - the object selected, or -1 for none selected.
 * 
 * GLOBALS:   char blanks[][]:    For building the text strings 
 *	      char blank[]:
 */
int
Pop_Handle( OBJECT *tree, int button, char *items[], int num_items,
            int *default_item, int font_size, int width )
{
   GRECT butn, world;
   
   int   i;
   int   obj;
     
   butn = ObRect( button );
   objc_offset( tree, button, &butn.g_x, &butn.g_y );
   world = ObRect( ROOT );
   objc_offset( tree, ROOT, &world.g_x, &world.g_y ); 
   		   
   for( i = 0; i < num_items; i++ )
   {
      strcpy( &blanks[i][0], "  ");		/* get 2 blank spaces */
      strcat( &blanks[i][0], items[ i ]);	/* copy the string    */
      do
      {
         strcat( &blanks[i][0], " ");
      }while( strlen( &blanks[i][0] ) < width );
      blank[i] = &blanks[i][0];
   }
   
   obj=Pop_Up( blank, num_items, *default_item, font_size, &butn, &world );
   if(( obj != -1 ) && ( *default_item != -1 ))
   {
      *default_item = obj;
      TedText( button ) = items[ obj ];
      Objc_draw( tree, button, 0, NULL );
   }
   return( obj );
}


