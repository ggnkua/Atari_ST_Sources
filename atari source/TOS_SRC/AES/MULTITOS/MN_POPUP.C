/* MN_POPUP.C
 * ================================================================
 * DESCRIPTION: These are the popup menu specific routines
 *
 * 11/30/91  cjg   - created from portions of menu.c
 * 01/07/92  cjg   - modified to accomodate calls from the menubar
 * 01/13/92  cjg   - modified to remove user-called MenuIDs
 * 01/27/92  cjg   - added comments
 * 01/29/92  cjg   - Started conversion to Alcyon ( AES Version )
 * 02/19/92  cjg   - merged into AES
 * 03/23/92  cjg   - moved both BEG_MCTRL and END_CTRL - mn_popup()
 *		   - exit WaitForUpButton() only for popups
 * 03/24/92  cjg   - removed WaitForUpButton()
 *		   - use evnt_button instead.
 * 04/01/92  cjg   - redo menu_popup() to use MENU structure
 * 05/07/92  cjg   - Don't wait for an up button upon entry if
 *		     if mn_popup is called by a menubar.
 * 05/14/92  cjg   - Pass in the Process ID to the appropriate functions
 * 05/15/92  cjg   - use internal AES function calls.
 * 05/19/92  cjg   - Added keystate
 * 07/01/92  cjg   - Limit the Scroll value to the children of the parent.
 * 07/09/92  cjg   - Use gl_button instead of a graf_mkstate...
 * 09/22/92  cjg   - Clip to the intersection of the screen and menu
 * 01/13/93  cjg   - Added MTOP_FLAG() and MB_FLAG() usage.
 *
 * 02/11/93  cjg   - Converted to Lattice 5.51
 * 02/19/93  cjg   - Force the use of prototypes
 * 05/14/93  cjg   - Modified menu_popup() for drop down lists
 * 06/24/93  cjg   - If the DropDown List exceeds the bottom,
 *		     kick it up till it fits.
 * 06/25/93  cjg   - AdjustMenuPosition() - Set SkipFlag to FALSE
 *		     for the Popups, and TRUE for the DropDownList.
 */


/* INCLUDE FILES
 * ================================================================
 */
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "pdstruct.h"
#include "dispvars.h"
#include "objaddr.h"
#include "osbind.h"



/* EXTERNS
 * ================================================================
 */
EXTERN OBJECT   *CurTree;
EXTERN WORD     CurMenu;
EXTERN WORD     CurObject;
EXTERN WORD	CurScroll;
EXTERN WORD	CurKeyState;
EXTERN BOOLEAN  MenuBar_Mode;
EXTERN MENU_PTR gl_menuptr;
EXTERN GRECT    gl_rfull;
EXTERN WORD     gl_button;

EXTERN WORD	DListFlag;
EXTERN MENU_PTR DListPtr;
EXTERN WORD	MAX_LIST_HEIGHT;
EXTERN OBJECT   *ad_list;

/* GLOBALS
 * ================================================================
 */

/* FUNCTIONS
 * ================================================================
 */


/* mn_popup()
 * ================================================================
 * Displays a First Level Popup Menu.
 * 
 * GLOBALS: There are several MENUBAR globals used so that this
 *          is compatible with the menubar routines. There shouldn't
 *          be any interference with them.
 * 
 * IN:  WORD   id        Process id
 *      MENU   *Menu     Contains the tree, menu, start item and scroll flag
 *      WORD   xpos      The xpos we want the menu to start on
 *      WORD   ypos      The ypos we want the menu to start on
 *	MENU   *MData    Returns the tree, menu, item and scroll flag
 *			 of the submenu that was selected.
 *
 * OUT: TRUE - The return MENU structure is valid
 *
 *      FALSE - the return Menu Structure is invalid
 *	      - FALSE means that the user clicked either on a disabled
 *		menu item, or clicked outside of any menu.
 */
BOOLEAN
mn_popup( id, Menu, xpos, ypos, MData )
WORD    id;			/* Process id			 */
MENU    *Menu;			/* the Input Menu Structure	 */
WORD	xpos;			/* the xpos that we want to start*/
WORD	ypos;			/* the ypos that we want to start*/
MENU	*MData;			/* the output menu structure	 */
{
    REG OBJECT   *tree;
    REG MENU_PTR MenuPtr;	/* Ptr to the Menu Node  	 */
    WORD         MenuID;	/* The menu id for the menu node */
    LONG         obj;		/* return value from evnt_submenu*/
    GRECT        rect;		/* GRECT for dummy variable      */
    BOOLEAN      flag;		/* VALID/INVALID variable        */

    flag = FALSE;		/* Set to Invalid return data    */

    ActiveTree( Menu->mn_tree );

    obj = -1L;			/* Set it to no object selected  */
    if( !MenuBar_Mode )		/* PopUp Menu Routines!          */
    {
      /* Wait for the up button */
	do
	{
	}while( gl_button );
			        /* moved 03/23/92 cjg 		 */

       wm_update( BEG_MCTRL );	/* Lock the menus and mouse      */

       DListFlag = FALSE;	/* Reset DropDown List Flag	 */


      /* Get the new Menu ID! */
      if( ( MenuID = Menu_Insert( tree, Menu->mn_menu )) > 0 )
      {
        MenuPtr = ( MENU_PTR )GetMenuPtr( MenuID );	/* Get the ptr   */
        MWIDTH( MenuPtr )  = ObW( MPARENT( MenuPtr ));  /* Set the width */
        MHEIGHT( MenuPtr ) = ObH( MPARENT( MenuPtr ));  /* and height    */

	/* Initialize the menu data. Set the starting item */
        AssignMenuData( MenuPtr, Menu->mn_item );		


        /* Is this a normal popup menu? or a Drop Down List?  */

        if( Menu->mn_scroll >= 0 )
	{
	   /* ----- POPUP MENU -------
            * ---------------------------------------------------------
	    * Adjust for scrolling, if its wanted. Do this by checking
            * the height of the menu.
            */

	   /* Make sure we stay within the limits */
	   if( Menu->mn_scroll )
	   {
	       Menu->mn_scroll = max( Menu->mn_scroll, ObHead( Menu->mn_menu ) );

	       if( Menu->mn_scroll >= ( ObTail( Menu->mn_menu ) - 1 ) )
		   Menu->mn_scroll = ObHead( Menu->mn_menu );
	   }

	   MSCROLL( MenuPtr ) = Menu->mn_scroll;
           if( Menu->mn_scroll )
               CheckMenuHeight( MenuPtr );

	   /* Adjust the x and y position of the popup */
           AdjustMenuPosition( MenuPtr, xpos, ypos, &rect, FALSE, TRUE, FALSE );
        }
 	else
	{
	   /* ---- Drop Down List -------- - cjg 05/14/93
	    * If Menu->mn_scroll is < 0, specifically, -1, then
	    * We're a drop down list.  For our purposes,
	    * any negative value for now, means drop down list.
	    */
	   DListFlag = TRUE;		/* Set Drop Down List Flag ACTIVE*/
	   DListPtr  = MenuPtr;	/* Global MENU pointer for sliders.*/
	   MSCROLL( MenuPtr ) = 0;	/* Reset to ZERO the scroll flag   */

	   CheckListHeight( MenuPtr );  /* Check Height of List  */

	   /* Adjust the x and y position of the Drop Down List */
	   ObX( MPARENT( MenuPtr ) ) = MXPOS( MenuPtr ) = xpos;
	   ObY( MPARENT( MenuPtr ) ) = MYPOS( MenuPtr ) = ypos;

	   /* Adjust the x and y position of the popup cjg 06/24/93 */
           AdjustMenuPosition( MenuPtr, xpos, ypos, &rect, FALSE, TRUE, TRUE );


	   /* If there are fewer than MAX_LIST_HEIGHT menu items,
	    * then just display as a popup in the drop down list spot.
	    * Otherwise, initialize the drop down list sliders.
	    */
	   if( MNUM_ITEMS( MenuPtr ) < MAX_LIST_HEIGHT )
	       DListFlag = FALSE;
	   else
	       InitListSliders( MenuPtr );
	}


	/* Save the area underneath the menu */
        if( Pop_Blit( MenuPtr, FALSE ) )
        {
	  ObjcDraw( tree, MPARENT( MenuPtr ), &gl_rfull );	

	  /* If we have a drop down list, draw the sliders */
	  if( DListFlag )
	     ObjcDraw( ad_list, ROOT, &gl_rfull );

          obj = EvntSubMenu( id, MenuPtr ); 	         /* Do EVNT!*/
          Pop_Blit( MenuPtr, TRUE );			 /* Restore */
        }
        else
          obj = -2L;   /* Memory Allocation Error */
        RestoreMenu( MenuPtr );				   /* Rebuild menu  */
        Menu_Delete( MenuID );				   /* Delete Node   */
      }




    }
    else
    { /* MENU BAR ROUTINES  */

      obj = EvntSubMenu( id, gl_menuptr );	      /* Go Do IT!          */
      MData->mn_tree   = NULL;			      /* set the variables  */
      MData->mn_menu   = NIL;
      MData->mn_item   = NIL;
      MData->mn_keystate = 0;
      MData->mn_scroll = FALSE;      

      if( obj == -1L )				      /* set flag if AOK      */
        flag = TRUE;				      /* For the Menu bar only*/
    }

    /* MenuID and MenuPtr are reused here...*/
    if( ( obj != -1L ) && ( obj != -2L ) )	      /* For PopUPs!       */
    {						      /* Set your variables*/
	MData->mn_tree   = CurTree;		      /* The tree!         */
	MData->mn_menu   = CurMenu;		      /* The menu          */
	MData->mn_item   = CurObject;		      /* The menu item     */
	MData->mn_scroll = CurScroll;		      /* Scroll field      */
	flag    = TRUE;
    }

    /* Always return the keystate - regardless */
    MData->mn_keystate = CurKeyState;

    /* 03/23/92 cjg - this is so that the popups disappear immediately
     *                but the menubar itself has its own WaitForUpButton()
     */
    if( !MenuBar_Mode )
    {
	do
	{
	}while( gl_button );

      wm_update( END_MCTRL );
    }
    return( flag );
}




/* AssignMenuData()
 * ================================================================
 * Called by PopUpMenu() and ShowSubMenu() to initialize the
 * menu structure right before it will be displayed.
 *
 * IN: MENU_PTR MenuPtr - the ptr to the menu node in question.
 *     WORD     start_obj - the start menu object we want to begin with
 *
 * OUT: VOID
 */
VOID
AssignMenuData( MenuPtr, start_obj )
REG MENU_PTR	MenuPtr;		/* the ptr to the menu node */
WORD		start_obj;		/* the obj we want on top   */
{
    REG OBJECT *tree;

    ActiveTree( MTREE( MenuPtr ) );

    MFIRST_CHILD( MenuPtr )   = ObHead( MPARENT( MenuPtr ) );
    MLAST_CHILD( MenuPtr )    = ObTail( MPARENT( MenuPtr ) );

    MOBRECT( MenuPtr )        = ObRect( MPARENT( MenuPtr ) );

    start_obj = min( start_obj, MLAST_CHILD( MenuPtr ) );
    MSTART_OBJ( MenuPtr )     = max( MFIRST_CHILD( MenuPtr ), start_obj );
    MOFFSET( MenuPtr )	      = MSTART_OBJ( MenuPtr );
    MNUM_ITEMS( MenuPtr )     = CountMenuItems( MenuPtr );

    MTOP_OBJ( MenuPtr )       = MFIRST_CHILD( MenuPtr );
    MTOP_STATE( MenuPtr )     = ObState( MFIRST_CHILD( MenuPtr ) );
    MTOP_FLAG( MenuPtr )      = ObFlags( MFIRST_CHILD( MenuPtr ) );
    MTOP_TXT( MenuPtr )[0]    = '\0';

    MB_OBJ( MenuPtr )         = MLAST_CHILD( MenuPtr );
    MB_STATE( MenuPtr )       = ObState( MLAST_CHILD( MenuPtr ) );
    MB_FLAG( MenuPtr )        = ObFlags( MLAST_CHILD( MenuPtr ) );
    MB_TXT( MenuPtr )[0]      = '\0';

    MBUFFER( MenuPtr )        = NULL;
    MPREV( MenuPtr )	      = NULL;

    MSCROLL( MenuPtr ) 	      = FALSE;
}
