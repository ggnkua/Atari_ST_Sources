/* MN_EVENT.C
 * ================================================================
 * DESCRIPTION: These are the evnt, blit and arrow routines.
 *
 * 11/30/91  cjg   - created
 * 12/5/91   cjg   - Scrolling, Menu Delays and Menu Drag routines in.
 *                 - Fixed fall thru bug when the mouse is clicked on.
 *		   - Fixed the proper return of menu items clicked on.
 * 01/10/91  cjg   - Modified to handle the menubar also.
 *		   - removed Menu_Set and replaced it with menu_set.
 *		   - If a user clicks on a disabled menu item,
 *		     treat it as if the user clicked on no item.
 *		   - removed menu_ichoice().
 * 01/21/92  cjg   - Created global tree, menu and item for popmenu.c
 *		     Since going dynamic, returning the objL is no
 *		     no longer viable. When we search for the menuid,
 *		     its already gone when the menu was cleaned up.
 *		     Now, the items selected are in CurTree, CurMenu
 *		     and CurObject.
 * 01/27/92  cjg   - added some comments
 * 01/29/92  cjg   - Started conversion to Alcyon ( AES Version )
 * 02/18/92  cjg   - compiled under Alcyon.
 * 02/19/92  cjg   - merged into AES
 * 02/20/92  cjg   - works!
 * 02/25/92  cjg   - Check only for G_STRINGs....
 * 02/28/92  cjg   - Fixed size allocation in pop_blit()
 * 03/23/92  cjg   - Removed WaitForUpButton() from EvntSubMenu()
 *		   - GetMouseState() if no mouse button - mk.buttons = 0
 *		   - ArrowScroll() - Check mouse state b4 arrow delay
 *		   - Put in a Scroll_Delay variable
 * 03/24/92  cjg   - moved scroll_delay and arrow_delay to mn_submn.c
 *		   - removed graf_mkstate() calls.
 *		   - removed WaitForUpButton()
 * 03/30/92  cjg   - Renamed SetDragRect() to SetDRect()
 * 04/01/92  cjg   - Added Scroll field and CurScroll
 * 05/06/92  cjg   - Redid EvntSubMenu() and a few other routines.
 * 05/13/92  cjg   - use global buparm
 *		   - use do_chg() and menu_set()
 *		   - objc_find() looks only 1 level deep.
 *		   - modified EventSubMenu()
 * 05/14/92  cjg   - modified EventSubMenu() to fix moving
 *		     the mouse into the menubar area. If its disabled OR
 *		     selected, set use m1 and m2 rectangles for the next event.
 * 		     Pass in Process ID's where appropriate
 * 05/15/92  cjg   - Use internal AES calls
 * 05/19/92  cjg   - Added keystate
 * 06/02/92  cjg   - Fixed bug relating to arrow scrolling
 * 06/04/92	   - Fixed xdo_chg()
 * 07/01/92  cjg   - The scroll flag now lets one start scrolling from
 *		     an object other than the first child of the parent.
 * 09/22/92  cjg   - pop_blit() - use ob_gclip()
 *
 * 02/11/93  cjg   - Converted to Lattice C 5.51
 * 02/19/93  cjg   - Force the use of Prototype Files
 * 05/14/93  cjg   - modified EvntSubMenu() to add in Drop Down List handling.
 *		   - modified pop_blit() to add in drop down list handling.
 *		   - modified item_handler() to add in drop down list handling.
 * 06/10/93  cjg   - Modified ArrowScroll() to scroll even when the parent
 *		     of the menu is not at the root.
 * 		   - Installed MU_KEYBD event for the event_multi().
 *		     Handles UP, DOWN, SHIFT-UP and SHIFT-DOWN for the
 *		     scrolling menus and drop-down menus. Scrolling menus
 *		     only do UP and DOWN tho...
 * 07/16/93  cjg   - Adjusted width of a DropDown List to be 
 *		     4 character widths wider than normal for Pop_Blit().
 * 08/05/93  cjg   - Fixed Pop_Blit() - added 2L to the size of the malloc.
 *		     and 2L to blit as an offset.
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

#define	 K_UP	  0x4800
#define  K_DOWN   0x5000

/* EXTERNS
 * ================================================================
 */
EXTERN	OBJECT	*mn_addr;
EXTERN WORD	MAX_MENU_HEIGHT;
EXTERN LONG 	SUBMENU_DELAY;	/* Menu Display Delay       */
EXTERN LONG 	SUBDRAG_DELAY;	/* Drag mouse to Menu Delay */
EXTERN LONG 	SCROLL_DELAY;	/* scrolling delay */
EXTERN LONG 	ARROW_DELAY;	/* start scrolling delay */
EXTERN BOOLEAN  MenuBar_Mode;
EXTERN GRECT    ActiveRect;
EXTERN GRECT    TitleRect;
EXTERN OBJECT   *gl_mtree;
EXTERN WORD	buparm;
EXTERN WORD	gl_hchar;
EXTERN GRECT	gl_rfull;
EXTERN GRECT	gl_rscreen;
EXTERN GRECT	gl_rzero;
EXTERN WORD	gl_nplanes;
EXTERN WORD	gl_wchar;	/* cjg 05/14/93	 */
EXTERN WORD	gl_button;

EXTERN WORD	DListFlag;	/* cjg 05/14/93  */


/* GLOBALS
 * ================================================================
 */
BYTE   UpText[4]   = { 0x20, 0x20, 0x01, 0x0 };	     /* Up ARROW menu text  */
BYTE   DownText[4] = { 0x20, 0x20, 0x02, 0x0 };	     /* Down Arrow menu text*/

OBJECT *CurTree;		  /* Global Tree selected                   */
WORD   CurMenu;		          /* Global Menu selected      	            */
WORD   CurObject;	          /* Global Menu Object Selected 	    */
WORD   CurScroll;		  /* Global Menu Scroll Flag		    */
WORD   CurKeyState;		  /* Global Key State Flag		    */

WORD   locount;	   		   /* evnt_multi low-word timer		*/
WORD   hicount;	   		   /* evnt_multi hi-word timer		*/

LONG         CycleTimeHz;	   /* Start time in 200hz - 5ms ticks for
				    * updating the mouse drag rectangle.
				    */
WORD         OldX,OldY;	   	   /* These are used in conjunction with
				    * the CycleTimeHz for determining
				    * if the mouse should exit the drag.
				    */
BOOLEAN      SamePlaceFlag;  	   /* Used for above - TRUE - mouse has
				    * remained in the same spot.
				    */
BOOLEAN	     UpDownFlag;	   /* Used to determine if the mouse moved
				    * straight up or down during a drag.
			            */
WORD	     slide_obj;		   /* Slider object that we clicked on for
				    * the Drop Down Lists  - cjg 05/14/93
				    */


/*	Customized of do_chg 	*/

	UWORD
xdo_chg( tree, iitem, chgvalue, dochg, dodraw, usetrap )
	OBJECT		*tree;			/* tree that holds item	*/
	WORD		iitem;			/* item to affect	*/
	REG UWORD	chgvalue;		/* bit value to change	*/
	WORD		dochg;			/* set or reset value	*/
	WORD		dodraw;			/* draw resulting change*/
						/* only if item enabled	*/
	WORD		usetrap;
{
	REG UWORD		curr_state;

	curr_state = tree[iitem].ob_state;

	if ( curr_state & DISABLED )
	  return(FALSE);
	
	if ( dochg )
	  curr_state |= chgvalue;
	else
	  curr_state &= ~chgvalue;

	if ( usetrap )
	    objc_change( ( LONG )tree, iitem, 0, gl_rscreen.g_x,
			 gl_rscreen.g_y, gl_rscreen.g_w,
			 gl_rscreen.g_h, curr_state, dodraw );
	else
	{
	  gsx_sclip( &gl_rscreen );
	  ob_change( ( LONG )tree, iitem, curr_state, dodraw );
	}

	return( TRUE );
}


/*
*	Routine to set and reset values of certain items if they
*	are not the current item
*/

	WORD
mu_set(tree, last_item, cur_item, setit, usetrap)
	OBJECT		*tree;
	REG WORD	last_item;
	WORD		cur_item,setit,usetrap;
{
	if ( (last_item != NIL) && (last_item != cur_item) )
	  return( xdo_chg(tree, last_item, SELECTED, setit, TRUE, usetrap) );

	return(FALSE);
}



/* FUNCTIONS
 * ================================================================
 */


/* EvntSubMenu()
 * ================================================================
 * This is the main recursive routine that handles the menus.
 * IN: MENU_PTR MenuPtr - The pointer to the active menu structure.
 * OUT: -1L	- Clicked outside of any menus.
 *      -2L     - Clicked in a previous menu.
 *      LONG Num - HIGH WORD - LOW WORD
 *		    MENU ID     MENU OBJECT
 *      If the Menu ID is valid, but the menu object is -1,
 *      then the user clicked on a disabled menu item.
 *      Use MenuChoice() ( it may be changed ) to see wot was clicked on.
 */
LONG
EvntSubMenu( id, MenuPtr )
WORD		id;		   /* Process id	     */
REG MENU_PTR	MenuPtr;	   /* ptr to the menu node   */
{
      OBJECT   	   *tree;
      WORD         cur_obj;	   /* object mouse is over   */
      WORD     	   old_obj;	   /* old object             */

      MENU_PTR     SubMenuPtr;	   /* Pointer to SubMenu     */
      GRECT        SubRect;	   /* GRECT of active Submenu*/

      MENU_PTR     OldMenuPtr;	   /* Ptr to previous submenu*/

      GRECT        OldRect;	   /* GRECT of old submenu   */
      GRECT        CurRect;	   /* GRECT of current menu  */
      GRECT        DragRect;  	   /* GRECT for Dragging     */

      BOOLEAN  	   MenuObject;     /* Object for Delay Flag           */
      BOOLEAN      MenuDragFlag;   /* Started a Drag toward a submenu */
      BOOLEAN      MenuDelayFlag;  /* Entered a menu item with a submenu 
				    * Delay is to set the timer going to
				    * see if we really want to display it
				    */
      MRETS        mk;		   /* Mouse Structure - Graf_mkstate()  */
      LONG         result;	   /* Result to return with             */

      BOOLEAN      done = FALSE;   /* Completion flag        		*/
   
      WORD         event;	   /* evnt_multi event 	     		*/
      WORD         scancode;	   /* evnt_multi scan code returned     */
      WORD         nclicks;	   /* evnt_multi nclicks returns        */
      MOBLK        m1;		   /* evnt_multi M1 Mouse Rectangle     */
      MOBLK        m2;		   /* evnt_multi M1 Mouse Rectangle     */
      UWORD        mn_mask;	   /* event multi mask 			*/
      WORD         title;
      WORD         title_state;
      WORD	   buff[6]; 	
      LONG	   tmparm,lbuparm;


      WORD	   ScrollFlag;	   /* Flag to see if the menu can scroll
				    * Used by the Keyboard event
				    */
      MENU_PTR	   ScrollMenuPtr;  /* MenuPtr to the Menu scrolling for
				    * Keyboard Scrolling...	
				    */


      /* INITIALIZE LOCAL VARIABLES */
      result        = -1L;		   /* Init return obj     */
      old_obj       = NIL;		   /* Init old object     */
      done          = FALSE;   

      MenuObject    = NIL;
      SubMenuPtr    = NULL;


      /* START THE CODING...*/
      ActiveTree( MTREE( MenuPtr ) );		/* Set the Active Tree */
      CurRect  = MOBRECT( MenuPtr );		/* Get GRECT of Menu   */
      DragRect = CurRect;
      ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );


      /* Get the current object the mouse is over */
      gr_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );

      if( MenuBar_Mode )
         buparm = (( mk.buttons & 0x01 ) ? ( 0 ) : ( 1 ));
      else
         buparm = 0x01;
    
      cur_obj = GetMouseState( &mk, MenuPtr );

      /* INITIALIZE the EVNT_MULTI MASK */
	
      ItemHandler( id, MenuPtr, cur_obj, old_obj, SubMenuPtr,
	           &MenuDelayFlag, &MenuDragFlag, &mn_mask,
		   &MenuObject, &m1, &m2, &mk );

       do
       {
	     CurKeyState = 0;

	     tmparm = HW(hicount) + LW(locount);	
	     lbuparm = HW(1)|LW((1 << 8) | buparm);
	
             event = ev_multi(	mn_mask | MU_KEYBD, &m1, &m2,
                               	tmparm,lbuparm,
				0x0L,&buff[0] );

	     mk.x       = buff[0];
	     mk.y       = buff[1];
	     mk.buttons = buff[2];
	     mk.kstate  = buff[3];
	     scancode   = buff[4];
	     nclicks    = buff[5];


	      /* Find the Current Object that the mouse is over and
               * Update the old object.
               * If the mouse is on top of the ROOT or just the PARENT,
               * then, we set it to NIL.
	       */
	      old_obj = cur_obj;
              cur_obj = GetMouseState( &mk, MenuPtr );



	       /* Keyboard Event
	        * =====================================================
		*/
	       if( !done && ( event & MU_KEYBD ) ) {

		    /* ----------------------------------------------------------------
		     * Check if we're a drop down list menu. If so, check the sliders
		     * and process them if necessary.  Skip if we're already at the
		     * very top or the very bottom. 
		     * In case we are, kill the events and loop back to the evnt multi.
		     * Otherwise, continue processing for more events below..ie: button
		     * ----------------------------------------------------------------
		     */
		    if( DListFlag && ( ( ( scancode & 0xFF00 ) == K_UP ) ||
			( ( scancode & 0xFF00 ) == K_DOWN ) ) ) {

			  if( ( ( ( scancode & 0xFF00 ) == K_UP ) &&
				( MFIRST_CHILD( MenuPtr ) != MTOP_OBJ( MenuPtr ) ) ) ||
			    ( ( ( scancode & 0xFF00 ) == K_DOWN ) && ( MB_OBJ( MenuPtr ) !=
				  MLAST_CHILD( MenuPtr ) ) ) ) {

			    /* ----------------------------------------------
			     * Process the UP or DOWN Keys...SHIFT ALSO...
			     * If the mouse is over a menu item, clear it...
			     * ----------------------------------------------
			     */
			    if( old_obj != NIL )
       			       mu_set( MTREE( MenuPtr ), old_obj, -1, FALSE, FALSE );
			    old_obj = cur_obj = NIL;

			    SliderButtons( scancode );


			    /* ----------------------------------------------
			     * Upon return from the slider code, we should 
			     * check where them mouse is. If it is over a
			     * menu item, we should select it and set the
			     * MU rect event. Continue processing events.
			     * ----------------------------------------------
			     */
			    gr_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
      			    cur_obj = GetMouseState( &mk, MenuPtr );

		            ItemHandler( id, MenuPtr, cur_obj, old_obj, SubMenuPtr,
	           		         &MenuDelayFlag, &MenuDragFlag, &mn_mask,
		   		         &MenuObject, &m1, &m2, &mk );
		        }

		    } /* end of 'if' DListFlag */
		    else {

			/* --------------------------------------------------------------
		         * Check if the current menu can be scrolled. This is NOT a drop
			 * down list menu. If the menu can be scrolled, Let's scroll it.
			 * If the menu cannot be scrolled, check if the submenu can be 
			 * scrolled. If so, scroll the submenu if its displayed.
			 * --------------------------------------------------------------
			 */
			ScrollMenuPtr = NULL;

			if( MSCROLL( MenuPtr ) > 0 )	/* Can we scroll the menu that we are in? */
                           ScrollMenuPtr = MenuPtr;	/* If so, set the pointer to scroll it... */


			/* -------------------------------------------------------------
			 * If we can't scroll the menu that we're in, is there a submenu
			 * attached that is visible that we can scroll? AND the mouse is
			 * still over the original cur_obj with the submenu attachment.
			 * -------------------------------------------------------------
			 */
			if( !ScrollMenuPtr && SubMenuPtr && ( MSCROLL( SubMenuPtr ) > 0 ) 
			    && ( MenuObject == cur_obj )) 
			    ScrollMenuPtr = SubMenuPtr;


			/* If we can scroll a menu, check for an UP, Down, SHIFT-Up or SHIFT-Down Keypress */
			if( ScrollMenuPtr && ( ( ( scancode & 0xFF00 ) == K_UP )
			    || ( ( scancode & 0xFF00 ) == K_DOWN ) ) )  {

				ScrollFlag = FALSE;


				/* Check if we're an UP Button and if its OK to scroll upwards. */
				if( (( scancode & 0xFF00 ) == K_UP ) &&
				    ArrowCheck( ScrollMenuPtr, MTREE( ScrollMenuPtr ),
				    MTOP_OBJ( ScrollMenuPtr ) ) )  {

				   ScrollFlag = MTOP_OBJ( ScrollMenuPtr );
				}


				/* Check if we're a Down Button and if its OK to scroll Downwards. */
				if( (( scancode & 0xFF00 ) == K_DOWN ) &&
				    ArrowCheck( ScrollMenuPtr, MTREE( ScrollMenuPtr ),
				    MB_OBJ( ScrollMenuPtr ) ) )  {

				   ScrollFlag = MB_OBJ( ScrollMenuPtr );
				}

				if( ScrollFlag ) {


				    /* ---------------------------------------------------------
				     * If we are scrolling a menu, and a submenu is displayed,
				     * shut down the submenu.  In addition, clear the menu item
				     * that the mouse is on top of before the scroll.
				     * ---------------------------------------------------------
				     */
			            if( ( MenuPtr == ScrollMenuPtr ) && ( old_obj != NIL )) {

					/* If there is a submenu displayed, close it up */
				        ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );

					/* Need to reset the menu items and m1 variables.*/
				   	if( SubMenuPtr ) {
	                   		   HideSubMenu( SubMenuPtr );
					   old_obj        = MenuObject;   /* So that we can clear */
					   MenuObject     = NIL;	  /* them menu item with  */
              		   		   SubMenuPtr     = NULL;	  /* the submenu attached */
			      		   MenuDelayFlag  = FALSE;
			      		   MenuDragFlag   = FALSE;
		           		}

					/* Clear the old object, in the menu that will be scrolled*/
       			                mu_set( MTREE( MenuPtr ), old_obj, -1, FALSE, FALSE );
			                old_obj = cur_obj = NIL;
				    }


      	                	    ArrowScroll( ScrollMenuPtr, ScrollFlag );


				    /* -------------------------------------------------------
				     * Always check to see, after the scroll, what menu item,
				     * if any, that we are on top of...
				     * -------------------------------------------------------
				     */
				    gr_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
      				    cur_obj = GetMouseState( &mk, MenuPtr );


				    /* ------------------------------------------------------
				     * If the menu that the mouse is over cannot be scrolled,
				     * BUT, a submenu is displayed, shut down the submenu.
				     * In addition, clear the delays.
				     * ------------------------------------------------------
				     */
				    if( SubMenuPtr && ( MenuObject != cur_obj ) ) {

				        ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );

					/* Need to reset the menu items and m1 variables.*/
				   	if( SubMenuPtr ) {
	                   		   HideSubMenu( SubMenuPtr );
					   MenuObject     = NIL;
              		   		   SubMenuPtr     = NULL;
			      		   MenuDelayFlag  = FALSE;
			      		   MenuDragFlag   = FALSE;
		           		}
				    }

				    /* ------------------------------------------------------
				     * If the object that we were once over is not the same,
				     * clear the old object. Set the new object if possible.
				     * ------------------------------------------------------
				     */
			            mu_set( MTREE( MenuPtr ), old_obj, cur_obj, FALSE, FALSE );
		        	    ItemHandler( id, MenuPtr, cur_obj, old_obj, SubMenuPtr,
	           		      		 &MenuDelayFlag, &MenuDragFlag, &mn_mask,
		   		     		 &MenuObject, &m1, &m2, &mk );


				    /* -----------------------------------------------------
				     * If the mouse is no longer over the menu itself, jump
				     * to do more in the hopes that we might be on top of
				     * the menubar.
				     * -----------------------------------------------------
				     */
				    if( cur_obj == NIL )
				    {
			   		/* Clear the event flag - no other events */
			   		event = 0;
			   		goto do_more;
				    }

				}
		        }
		    }
	       }		    /* End of event & MU_KEYBD */



	       /* Mouse M1 Rectangle Event
	        * =====================================================
                */
               if( !done && ( event & MU_M1 ))
	       {
		   /* If we EVER get an MU_M1 rectangle event,
		    * CLEAR the MenuDelayFlag AND clear the TIMER EVENT.
		    * This is because, we have left the menu item BEFORE
		    * the DISPLAY DELAY TIME expired, which tells us to
		    * display the submenu.
		    */
		   if( MenuDelayFlag )
		       ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );


		   /* If MenuDragFlag == TRUE, we have exited the 
		    * menu item, and are now dragging to the submenu
		    * 1) Set the Timer to TIME_SAMPLE increments
		    *    The timer event is used to check if we have gone
		    *    vertical or have stayed in the same spot.
		    * 2) Set the Bounding Rectangle in DragRect
		    * 3) set the M1 rectangle to look OUT and 1 pixel 
		    * 4) Look for MU_BUTTON, MU_M1, MU_M2 and TIMER
		      5) Set M2 to be SubRect - LOOK IN
		    */
		   if( MenuDragFlag )
		   {
			/* FIRST TIME THRU - SET THE TIMER AND INITIAL VALUES
			 * for the drag.
			 */
			if( mn_mask != ( MU_BUTTON | MU_M1 | MU_M2 | MU_TIMER ))
			{
			   mn_mask = MU_BUTTON | MU_M1 | MU_M2 | MU_TIMER;

			   /* Set to TIME_SAMPLE increments */
			   locount = ( WORD )( TIME_SAMPLE & 0x0000ffffL );
			   hicount = ( WORD )( TIME_SAMPLE >> 16 );
			   CycleTimeHz = 0L;

			   /* Get the SubMenu Rectangle ENTER */
	                   SetDRect( &DragRect, mk.x, mk.y, &SubRect );

			   /* Set the SubMenu Rectangle */
			   m2.m_out = FALSE;		/* LOOK IN!  */
			   m2.m_x   = SubRect.g_x;
			   m2.m_y   = SubRect.g_y;
			   m2.m_w   = SubRect.g_w;
			   m2.m_h   = SubRect.g_h;

			   /* Get the Bounding Rectangle to EXIT-1 pixel wide*/
			   m1.m_out = TRUE;		/* LOOK OUT! */
			   m1.m_x   = mk.x - 1;
			   m1.m_y   = mk.y - 1;
			   m1.m_w   = m1.m_h = 2;

			   /* Initialize the flags to check if we remain 
			    * in the same place, OR go vertically in the menus.
			    */
			   SamePlaceFlag = FALSE;
			   UpDownFlag    = FALSE;
			   OldX 	 = mk.x;
	                   OldY 	 = mk.y;
			   MenuObject    = old_obj;

			   /* If we're inside the drag rect, then drag,
			    * otherwise, its a cancel...
			    */
			   if( !inside( mk.x, mk.y, &DragRect ) )
			   {
		               ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );
			       old_obj = MenuObject;
			   }
			}
			else
			{
			   /* If we've reached here, the mouse has moved.
			    * if we are outside DragRect, exit, otherwise
			    * we update the DragRect rectangle and M1 rect
			    * and continue.
			    */
			   if( inside( mk.x, mk.y, &DragRect ) )
			   {
			      /* Still in DragRect, update it and continue*/
	                      SetDRect( &DragRect, mk.x, mk.y, &SubRect );

			      /* Update the m1 box */
			      m1.m_x = mk.x - 1;
			      m1.m_y = mk.y - 1;
			   }
			   else
			   {
			      /* We are OUTSIDE the DragRect Rectangle.
			       * therefore, clean up!
			       */
		               ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );
			       old_obj = MenuObject;
			   }
			   /* Potentially, can skip button events this way. */
			   /* Now, fall thru and set m1, menu items etc. */

			}  /* End of ELSE */
		   }	/* End of MenuDragFlag */

		   /* Want to do this ONLY if we're NOT Dragging the Mouse*/
		   if( !MenuDragFlag )
		   {
		       /* ERASE the selected OLD Menu ITEM
	 	        * We just check here first, because the redraw of the
         	    	* menu item will be incorrect due to the presence of the submenu.
         	    	*/
           		
			/* Check for a submenu pointer, if true, hide the submenu */
		   	if( SubMenuPtr )
           		{
	                   HideSubMenu( SubMenuPtr );
              		   SubMenuPtr     = NULL;
	      		   MenuDelayFlag  = FALSE;
	      		   MenuDragFlag   = FALSE;
           		}

			M1_Event( id, MenuPtr, &old_obj, &cur_obj,
				  SubMenuPtr, &MenuDelayFlag,
				  &MenuDragFlag, &mn_mask,
	  			  &m1, &m2, &mk, &MenuObject );

			if(( event & MU_TIMER ) && MenuDelayFlag )
			  event = FALSE;

			/* This is for when we are OUTSIDE of a SUBMENU after
			 * entering it, of course. AND, we have reentered
			 * it. This will ensure that if we land on a
			 * menu item with a submenu, that it will be displayed
		         * and not get cancelled by MU_M2.
			 * Cause, as we are OUTSIDE of a submenu,
			 * MU_M2 is used to see which menu we land on and
			 * is generating events like crazy.
			 */
			if(( event & MU_M2 ) && MenuDelayFlag )
			   event = FALSE;
		   } 			/* end of if( !MenuDragFlag ) */

	       }	   		/* End of MU_M1               */



	       /* Mouse M2 Rectangle Event
	        * =====================================================
                */
	        if( !done && ( event & MU_M2 ))
		{
		    if( CheckButton( buparm, &mk ) )
			goto do_button;

		    /* We are dragging toward the Submenu and MOVED INTO IT*/
		    if( MenuDelayFlag || MenuDragFlag )
		    {
		       old_obj = MenuObject;
		       ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );

		      /* we were at a menu item with a submenu displayed.
		       * Check if we have ENTERED the NEW submenu.
		       */
		       if( SubMenuPtr && inside( mk.x, mk.y, &SubRect ) )
             	       {
                	  MPREV( SubMenuPtr ) = MenuPtr;
			  result = EvntSubMenu( id, SubMenuPtr );

			  /* Check if we have returned from a button click.
			   * AND we aren't returning from entering a new menu.
			   */

			  if( ( result == -1L ) || ( result != -2L ) )
			  {
			     cur_obj = NIL;
	                     done    = TRUE;   
			     event   = FALSE;
	                  }
			  else
			  {
			      /* Get the current object the mouse is over */
			      gr_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
	      		      cur_obj = GetMouseState( &mk, MenuPtr );
			  }
			
			  if( SubMenuPtr )
			  {
			     HideSubMenu( SubMenuPtr );
	                     SubMenuPtr = NULL;
	                  }
		  
			  /* Check if we are OUTSIDE this menu and NOT done*/
			  if( ( cur_obj == NIL ) && !done )
			  {
			    /* we are NOT the only menu up, therefore,
			     * we need to check our submenu rectangles.
			     * If we are IN another rectangle, then we
			     * need to EXIT immediately.
			     */
			     OldMenuPtr = MPREV( MenuPtr );
			     while( OldMenuPtr )
        	             {
			        OldRect = MOBRECT( OldMenuPtr );
			        if( inside( mk.x, mk.y, &OldRect ) )
        	                {
				   /* Entered a old submenu, So - exit evntsubmenu
		        	    * and shut down the submenu emanating if
	                            * one exists.
        	                    */
	        	            if( SubMenuPtr )
	         	            {
        	                       HideSubMenu( SubMenuPtr );
	        	               SubMenuPtr   = NULL;
			 	    }
	  			    done           = TRUE;
				    result         = -2L;
				    event          = FALSE;
				    break;
        	                }
			        OldMenuPtr = MPREV( OldMenuPtr );
	                     } /* end of while */
			
			  }  /* end of if cur_obj == NIL */
			  else
			  {
			     /* Check if we are INSIDE this menu */
			     if( ( cur_obj != NIL ) && !done )
			     {
				M1_Event( id, MenuPtr, &old_obj, &cur_obj,
					  SubMenuPtr, &MenuDelayFlag,
					  &MenuDragFlag, &mn_mask,
	  				  &m1, &m2, &mk, &MenuObject );
			     }
			  }
	                }
		     }  /* end of if MenuDelayFlag | MenuDragFlag */
		     else
		     {
do_more:
			/* if we are a menubar, check if we've reentered
        	         * the Active Area. If so, exit us!
			 */
			if( MenuBar_Mode )
                	{
		   	    /* ActiveRect is a global GRECT of THEACTIVE set
                    	     * by a menubar.c routine.
                    	     * TitleRect is a global GRECT of the active Title
                    	     * set by a menubar.c routine.
		    	     * gl_mtree is a global tree of the menubar set
                    	     * by a menubar.c routine.
		    	     * All three are set and cleared at the same time.
		    	     */
		    	    if( inside( mk.x, mk.y, &ActiveRect ) )
                   	    {
				title = ob_find( ( LONG )gl_mtree, THEACTIVE, 1, mk.x, mk.y );
				if( title != NIL )
				{
				   /* Check if we are in the same menu title OR
		 		    * if its disabled. Set m1 to enter the menu.
		 		    * set m2 to exit the title.
		 		    */
			   	   title_state = gl_mtree[ title ].ob_state;
			   	   if( title_state && DISABLED )
				   {
			  	       mn_mask  = MU_BUTTON | MU_M1 | MU_M2;

				       /* Set the M1 RECT to LOOK IN at our current rectangle */
          			       m1.m_out = FALSE;	
				       ob_actxywh( ( LONG )MTREE( MenuPtr ), MPARENT( MenuPtr ), ( GRECT *)&m1.m_x );

				       /* Set M2 to Look OUT of the title */
          			       m2.m_out = TRUE;	
				       ob_actxywh( ( LONG )gl_mtree, title, ( GRECT *)&m2.m_x );
								       
				       continue;
			     	       /*goto skip;*/   
				   }
				}
	                	if( SubMenuPtr )
         	        	{
                          	   HideSubMenu( SubMenuPtr );
	                  	   SubMenuPtr          = NULL;
				}
				/* Exit Like a Button Click on NIL */
	                	MenuDelayFlag         = FALSE;
	                	MenuDragFlag          = FALSE;
  				done   = TRUE;
				result = -1L;
				goto da_bar;
                   	    }
			}	/* End of If MenuBar Mode */
skip:
			/* Update the Mouse Rectangle */
			/* However, don't update if we have no events.
			 * called probably from a goto from do_button()
			 * and an arrow scroll.
			 */
			if( event )
			{
			  m2.m_x = mk.x - 1;
			  m2.m_y = mk.y - 1;
			}


			/* we are NOT the only menu up, therefore,
			 * we need to check our submenu rectangles.
			 * If we are IN another rectangle, then we
			 * need to EXIT immediately and CLEAR MU_M2.
			 */
			if( CheckButton( buparm, &mk ) )
			  goto do_button;

			OldMenuPtr = MPREV( MenuPtr );
			while( OldMenuPtr )
        	        {
			    if( CheckButton( buparm, &mk ) )
			      goto do_button;

			    OldRect = MOBRECT( OldMenuPtr );
			    if( inside( mk.x, mk.y, &OldRect ) )
        	            {
				/* Entered a old submenu, So - exit evntsubmenu
		        	 * and shut down the submenu emanating if
	                         * one exists.
        	                 */
	        	        if( SubMenuPtr )
	         	        {
        	                  HideSubMenu( SubMenuPtr );
	        	          SubMenuPtr   = NULL;
				}
	  			done           = TRUE;
				result         = -2L;
				event	       = FALSE;
				mn_mask = MU_BUTTON | MU_M1;
				break;
        	            }
			    OldMenuPtr = MPREV( OldMenuPtr );
	                } /* end of while */
		     }
		}	/* End of MU_M2 */


	       /* MU_BUTTON EVENT 
	        * =====================================================
	        */
	        if( !done && (( event & MU_BUTTON ) || CheckButton( buparm, &mk )) )
	        {

		    buparm = 0x01;

do_button:

		    /* Button Event occurred while waiting for
		     * a Display Delay or a Drag Delay.
		     * Set the object to be the menu item.
		     */
		    if( MenuDelayFlag || MenuDragFlag )
		    {
		       if( MenuDragFlag )
			   cur_obj = MenuObject;
		       ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );
		    }


		     /* Check if clicking on an ARROW and NOT a Drop Down List Menu */
                     if( !DListFlag && ArrowCheck( MenuPtr, MTREE( MenuPtr ), cur_obj ) )
                     {
			/* We are clicking on an ARROW - SCROLL IT! */
      	                ArrowScroll( MenuPtr, cur_obj );

			gr_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
      			cur_obj = GetMouseState( &mk, MenuPtr );

	                old_obj = NIL;
		        ItemHandler( id, MenuPtr, cur_obj, old_obj, SubMenuPtr,
	           		     &MenuDelayFlag, &MenuDragFlag, &mn_mask,
		   		     &MenuObject, &m1, &m2, &mk );

			/* if the object is NIL, we are not in the menu.
			 * Check if we are over the menu bar or over another
			 * menu.
			 */
			if( cur_obj == NIL )
			{
			   /* Clear the event flag - no other events */
			   event = 0;
			   goto do_more;
			}
             	     }
	             else
	             {
			 /* Check if we're a drop down list, if so, check
			  * the sliders and process them if necessary.
			  * cjg 05/14/93
			  */
			 if( DListFlag )
			 {
			    if( ( slide_obj = SliderCheck( mk.x, mk.y ) ) != -1 )
			    {
				SliderButtons( slide_obj );

			        gr_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
      				cur_obj = GetMouseState( &mk, MenuPtr );

	                        old_obj = NIL;
		                ItemHandler( id, MenuPtr, cur_obj, old_obj, SubMenuPtr,
	           		             &MenuDelayFlag, &MenuDragFlag, &mn_mask,
		   		             &MenuObject, &m1, &m2, &mk );
			        event = 0;
			        continue;
			    } /* end of 'if' */
			 }


			 /* Just a Mouse CLick! */

			 /* Need to clear the submenu, if its displayed. */
		         if( SubMenuPtr )
		         {
              		     HideSubMenu( SubMenuPtr );
	      		     SubMenuPtr    = NULL;
			     MenuDelayFlag = FALSE;
			     MenuDragFlag  = FALSE;
            		 }  
	                 CurTree     = MTREE( MenuPtr );
	                 CurMenu     = MPARENT( MenuPtr );
	                 CurObject   = cur_obj;
 	                 CurScroll   = MSCROLL( MenuPtr );
		         CurKeyState = mk.kstate;
                         done      = TRUE;

	                 /* If clicked outside, its NIL, and should return as such. */
	                 result    = (( cur_obj == NIL ) ? ( -1L ) : ( NULL ) );
                     }
	  	}	/* End of MU_BUTTON */


		/* MU_TIMER
	         * =====================================================
		 */
		if( !done && ( event & MU_TIMER ) )
		{
		    /* -------------------------------------------------
		     * The mouse has entered a menu item that has a submenu
		     * attached to it. We are waiting for the timer event
		     * ( SUBMENU_DELAY ) to expire. If so, we execute the
		     * code below in order to display the submenu.
	             * -------------------------------------------------
        	     */
	            if( MenuDelayFlag )
        	    {
		      /* CLEAR THE TIMER EVENT */
		      ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );

		      /* Check if we are still in the same menu item. */
		      if( MenuObject == cur_obj )	/* YES!!!!!  */
	              {
		          SubMenuPtr = DoSubMenu( id, MTREE( MenuPtr), cur_obj );
		          if( SubMenuPtr )
	                  {
			    MenuDragFlag  = TRUE;
			    SubRect       = MOBRECT( SubMenuPtr );
			    MenuObject    = cur_obj;

			    /* Set M2 to LOOK IN for the submenu! */
			    mn_mask = MU_BUTTON | MU_M1 | MU_M2;
			    m2.m_out = FALSE;
			    m2.m_x   = SubRect.g_x;
			    m2.m_y   = SubRect.g_y;
			    m2.m_w   = SubRect.g_w;
			    m2.m_h   = SubRect.g_h;
	                  }
        	      }
	              else	/* If we're no longer in the same object, */
	              {		/* Then the menu doesn't need to go up.   */
			  MenuObject    = NIL;
	              }
		      continue;	/* skips checking below */
		    } /* END OF IF MenuDelayFlag */


		    /* We are dragging toward the submenu
		     * The timer is in increments of TIME_SAMPLE
		     * If the timer exceeds SUBDRAG_DELAY,
		     * then cancel drag.
		     * If the mouse remains in the same spot, or
		     * if the mouse goes vertical only, cancel the drag.
		     */
		    if( MenuDragFlag )
		    {
		        CycleTimeHz += TIME_SAMPLE;
			if( CycleTimeHz < SUBDRAG_DELAY )
			{
		           SamePlaceFlag = ( ( OldX == mk.x ) && ( OldY == mk.y ));
    		           UpDownFlag    = ( (( OldX == mk.x ) ||
				           (( mk.x >= ( OldX - 4 )) &&
				           ( mk.x <= ( OldX + 4 ) )))  &&
				           ( OldY != mk.y ));

		           OldX          = mk.x;
                           OldY          = mk.y;

			   if( !SamePlaceFlag && !UpDownFlag )
			      continue;
			}

		        ClearDelays( &MenuDelayFlag, &MenuDragFlag, &mn_mask );
			old_obj = MenuObject;

			/* Need to reset the menu items and m1 variables.*/
		   	if( SubMenuPtr )
           		{
	                   HideSubMenu( SubMenuPtr );
              		   SubMenuPtr     = NULL;
	      		   MenuDelayFlag  = FALSE;
	      		   MenuDragFlag   = FALSE;
           		}
			M1_Event( id, MenuPtr, &old_obj, &cur_obj,
				  SubMenuPtr, &MenuDelayFlag,
				  &MenuDragFlag, &mn_mask,
	  			  &m1, &m2, &mk, &MenuObject );

		    }
		  
		} /* End of MU_TIMER */

      }while( !done );

da_bar:

      if( ( cur_obj != NIL ) && ( cur_obj != MPARENT( MenuPtr )) && 
          ( result != -1L ) && ( result != -2L ) )
      {
          /* If the user clicked on a disabled object, treat it
           * as if the user clicked outside of any menu. 
      	   * return -1L
      	   */
      	  if( !IsDisabled( cur_obj ) )
          {
	       /* This is actually useless and the code ignores the result
         	* if it is other than -1L or -2L. The reason is, when the code
         	* has the time to look at the result, it has to search for the
                * menuid of the menu selected. BUT, the menu selected structure
         	* is already gone. So, we use CurTree, CurMenu and CurObject to
         	* return the code.
	 	*
	 	* We'll keep the code as is so that 'result' doesn't equal -1L or -2L
	 	*/
        	result  = 0L;
        	result  = ( int )MMENU_ID( MenuPtr );
        	result  = ( result << 16L );
          	result |= ( cur_obj & 0x0000FFFFL );
     	  }
          else
            result = -1L;
        
      }
      return( result );   
}



/* M1_Event()
 * ================================================================
 * Handles MU_M1 events
 */
VOID
M1_Event( id, MenuPtr, old_obj, cur_obj, SubMenuPtr,
	  MenuDelayFlag, MenuDragFlag, mn_mask,
	  m1, m2, mk, MenuObject )
WORD	 id;		/* Process id */
MENU_PTR MenuPtr;
WORD     *old_obj;
WORD     *cur_obj;
MENU_PTR SubMenuPtr;
WORD     *MenuDelayFlag;
WORD     *MenuDragFlag;
WORD     *mn_mask;
MOBLK    *m1;
MOBLK    *m2;
MRETS 	 *mk;
BOOLEAN  *MenuObject;
{
       mu_set( MTREE( MenuPtr ), *old_obj, *cur_obj, FALSE, FALSE );
       ItemHandler( id, MenuPtr, *cur_obj, *old_obj, SubMenuPtr,
      		    MenuDelayFlag, MenuDragFlag, mn_mask,
		    MenuObject, m1, m2, mk );
}



/* ClearDelays()
 * ================================================================
 * Clear the Drag and Displa delay values. Also clears the
 * evnt_multi mask and timer values.
 */
VOID
ClearDelays( MenuDelayFlag, MenuDragFlag, mn_mask )
WORD *MenuDelayFlag;
WORD *MenuDragFlag;
WORD *mn_mask;
{
	*MenuDelayFlag = FALSE;
	*MenuDragFlag  = FALSE;
	*mn_mask = MU_BUTTON | MU_M1;
	locount = hicount = 0;
}



/* ItemHandler()
 * ================================================================
 * Handles the selecting and deselecting of menu items.
 * Starts the timer for display delays and sets the mouse rectangles
 * for a potential drag.
 */
VOID
ItemHandler( id, MenuPtr, cur_obj, old_obj, SubMenuPtr,
	     MenuDelayFlag, MenuDragFlag, mn_mask, MenuObject,
	     m1, m2, mk )
WORD		id;		/* Process id		  */
REG MENU_PTR	MenuPtr;	/* ptr to the menu node   */
WORD		cur_obj;
WORD		old_obj;
MENU_PTR	SubMenuPtr;	/* Pointer to the SubMenu */
WORD		*MenuDelayFlag;
WORD		*MenuDragFlag;
WORD		*mn_mask;
WORD		*MenuObject;
MOBLK		*m1;
MOBLK		*m2;
MRETS		*mk;
{
      /* Setup the menu item if we are within the menu */
      if( cur_obj != NIL )
      {
          *mn_mask = MU_BUTTON | MU_M1;

	  /* SELECT the new MENU ITEM unless its an ARROW ITEM */ 

	   if( ArrowCheck( MenuPtr, MTREE( MenuPtr ), cur_obj ) )
	       mu_set( MTREE( MenuPtr ), cur_obj, old_obj, FALSE, FALSE );
           else
	   {

	       mu_set( MTREE( MenuPtr ), cur_obj, old_obj, TRUE, FALSE );	

	      /* Check for a Submenu on the Current object.
               * Set the SubMenuDisplayDelay flag if the check is valid.
	       *
	       * Check if we're a Drop Down List, if NOT, check for
	       * Submenus. Otherwise, Skip it... cjg 05/14/93
               */

	      if( !DListFlag && !(*MenuDelayFlag) && CheckForSubMenu( id, MTREE( MenuPtr), cur_obj, SubMenuPtr ) )
	      {
	         *mn_mask = MU_BUTTON | MU_M1 | MU_TIMER;
	         locount = (WORD)(SUBMENU_DELAY & 0x0000ffffL );
	         hicount = (WORD)(SUBMENU_DELAY >> 16 );
	         *MenuDelayFlag = TRUE;
	         *MenuDragFlag  = FALSE;
	         *MenuObject    = cur_obj;
	      }	

	  }
          m1->m_out = TRUE;	/* Look for leaving this menu item */
          ob_actxywh( ( LONG )MTREE( MenuPtr ), cur_obj, ( GRECT *)&m1->m_x );

       }
       else	/* We are OUTSIDE the Menu! */
       {
	  /* Set the M1 RECT to LOOK IN at our current rectangle */
          m1->m_out = FALSE;	
          ob_actxywh( ( LONG )MTREE( MenuPtr ), MPARENT( MenuPtr ), ( GRECT *)&m1->m_x );
	  
	  /* If the current menu ISN'T the ROOT MENU, then set M2
	   * into pixel search mode. Of course, set it to this mode
	   * if we are a menubar.
	   */
	  if( MenuBar_Mode )
	  {
	     /* We are a SUBMENU, therefore, we need to set M2 to look out
	      * AND to set it so that our box is 1 pixel.  This way, when
              * the mouse moves, we can see if its inside any of our
	      * previous submenus.
	      * OR if we're already inside the menubar...
	      */
	     if( MPREV( MenuPtr ) )
	     {
	       m2->m_out = TRUE;
	       m2->m_x   = mk->x - 1;
	       m2->m_y   = mk->y - 1;
	       m2->m_w   = m2->m_h = 2;	
	     }
	     else
             {
		/* We are the 1st Level Menu in the menubar.
		 * M1 is set to look into our menu.
 		 * Set M2 to look into the Active!
		 */
	       m2->m_out = FALSE;
    	       ob_actxywh( ( LONG )gl_mtree, THEACTIVE, ( GRECT *)&m2->m_x );	
             }
	     *mn_mask  = MU_BUTTON | MU_M1 | MU_M2;
	  }
	  else
	  {
	     /* Check if this menu is at the ROOT - 
	      * If so, just use m1 to look IN
	      * If we have submenus, set M2 to look out of a small box.
	      * The system will check everytime it moves if we are over
	      * anything.
	      */
	     if( MPREV( MenuPtr ) )
	     {
	       m2->m_out = TRUE;
	       m2->m_x   = mk->x - 1;
	       m2->m_y   = mk->y - 1;
	       m2->m_w   = m2->m_h = 2;	
	       *mn_mask  = MU_BUTTON | MU_M1 | MU_M2;
	     }

	  }
       }
}



/* Pop_Blit()
 * ================================================================
 * Blit from the screen to a buffer or from the buffer to the screen.
 * It assumes that the tree is already positioned properly on the
 * screen. The storage of the blit buffer is attached to the
 * menu node structure.
 *
 * IN: MENU_PTR MenuPtr - ptr to the menu node
 *     WORD flag         - FALSE - Blit to the buffer
 *			   TRUE  - blit FROM the bufffer to the scrn.
 *
 * OUT: TRUE - SUCCESS
 *      FALSE - FAILURE
 */
BOOLEAN
Pop_Blit( MenuPtr, flag )
REG MENU_PTR	MenuPtr;	/* ptr to the menu node        */
WORD		flag;		/* Blit To/From buffer and scrn*/
{
   REG  OBJECT   *tree;		/* the tree in question        */
   LONG     location = 0L;	/* variable to save us an MFDB */
   LONG     size;		/* size to blit...             */
   WORD     pxy[8];		/* clipping array              */
   FDB      ObjMFDB;		/* MFDB                        */
   GRECT    clip;		/* Clipping rectangle ( GRECT )*/
   WORD	    dummy;
	
   ActiveTree( MTREE( MenuPtr ) );

   ob_gclip( ( LONG )MTREE( MenuPtr ), MPARENT( MenuPtr ), &dummy,&dummy,
	     &clip.g_x,&clip.g_y,&clip.g_w,&clip.g_h );

   /* cjg 05/14/93 - Adjust width of clip to take into account
    * the sliders if we're a drop down list.
    */
   if( DListFlag )
      clip.g_w += ( gl_wchar * 4 );

   rc_intersect( &gl_rfull, &clip );	/* clip to the work area*/
   gsx_sclip( &clip );			/* set the clip		*/

   if( !flag )				/* Screen to Buffer    */
   {					/* Malloc buffer...    */
       size = (LONG)(( LONG ) ((LONG)( ((LONG)clip.g_w + 15L )/16L )*2L)*
              (LONG)clip.g_h * (LONG)gl_nplanes );
               
       MBUFFER( MenuPtr ) = ( LONG *)dos_xalloc( size + 2L, 3 );
   }
   if( !MBUFFER( MenuPtr ) )	 /* No memory - FAILURE        */
   {
       gsx_sclip( &gl_rscreen );
       return( FALSE );
   }

   /* Setup the Destination MFDB */
   ObjMFDB.fd_addr    = (LONG)MBUFFER( MenuPtr ) + 2L;
   ObjMFDB.fd_w       = clip.g_w;
   ObjMFDB.fd_h       = clip.g_h;
   ObjMFDB.fd_wdwidth = ( clip.g_w + 15 ) / 16;       
   ObjMFDB.fd_stand   = 0;       
   ObjMFDB.fd_nplanes = gl_nplanes;       
   ObjMFDB.fd_r1 = ObjMFDB.fd_r2 = ObjMFDB.fd_r3 = 0;       

   gsx_moff();

   if( !flag )				/* SCREEN to BUFFER  */
   {
       rc_2xy( &clip, &pxy[0] );	/* get the source    */
       pxy[4] = pxy[5] = 0;		/* set destination   */
       pxy[6] = clip.g_w - 1;
       pxy[7] = clip.g_h - 1;
       vro_cpyfm( 3, pxy, ( WORD *)&location, ( WORD *)&ObjMFDB );
   }
   else
   {					/* BUFFER to SCREEN! */
       pxy[0] = pxy[1] = 0;		/* set the source    */
       pxy[2] = clip.g_w - 1;
       pxy[3] = clip.g_h - 1;
       rc_2xy( &clip, ( WORD *)&pxy[4] ); /* set the dest    */
       vro_cpyfm( 3, pxy, ( WORD *)&ObjMFDB, ( WORD *)&location );

       if( MBUFFER( MenuPtr ) )		/* Clear the buffer  */
           dos_free( ( LONG )MBUFFER( MenuPtr ) );
       MBUFFER( MenuPtr ) = NULL;
   }
   gsx_sclip( &gl_rscreen );		/* set clip to screen */
   gsx_mon();				/* and turn the mouse */
   return( TRUE );			/* back on....        */
}




/*
 * ================================================================
 * ARROW MENU ITEM HANDLING
 * ================================================================
 */

/* ArrowCheck()
 * ================================================================
 * Check if the user is clicking on the UP or DOWN arrow
 *
 * IN: MENU_PTR MenuPtr - ptr to the menu node in question
 *     WORD  cur_obj     - the object to check.
 * OUT: TRUE - This is an active UP or DOWN arrow
 *      FALSE - Nope - this isn't an UP or DOWN arrow
 *
 * To qualify, the top menu item must be an Up arrow or
 *             the bottom menu item must be a Down arrow.
 */
BOOLEAN
ArrowCheck( MenuPtr, tree, cur_obj )
REG MENU_PTR	MenuPtr;		/* ptr to menu node   */
OBJECT	        *tree;
REG WORD	cur_obj;		/* the object to check*/
{

   if( ( cur_obj != NIL ) &&	/* Check for NIL pointer */
       IsG_String( cur_obj ) &&	/* CHeck only for G_STRING */
       (
	 /* AES Version - strcmp() - true or False only */
	 (( cur_obj == MTOP_OBJ( MenuPtr ) ) &&
            strcmp( ObString( cur_obj ), &UpText[0] )) ||
         (( cur_obj == MB_OBJ( MenuPtr ) )  &&
            strcmp( ObString( cur_obj ), &DownText[0] ))
       )
     )
   {
     return( TRUE );
   }
   else
   {
     return( FALSE );
   }
}


/* ArrowScroll()
 * ================================================================
 * Scroll the menu when the user is clicking on either the
 * up or down arrows.
 *
 * IN: MENU_PTR MenuPtr - the menu node in question ( a ptr to )
 *     WORD     cur_obj - the menu item the user is clicking on.
 * OUT: TRUE/FALSE - hmmm...does it really matter?
 */
BOOLEAN
ArrowScroll( MenuPtr, cur_obj )
REG MENU_PTR	MenuPtr;	/* ptr to the menu node     */
REG WORD        cur_obj;	/* the obj being clicked on */
{
   GRECT       clip;		/* the blit clip rectangle  */
   MRETS       mk;		/* the mouse structure      */
   GRECT       rect;		/* temp GRECT		    */

   WORD        pxy[12];		/* blit array		    */
   LONG        location = 0L;	/* saves us one MFDB        */
   WORD        Direction;	/* direction variable       */

   BOOLEAN     DrawFlag;	/* Do the Redraw! 	    */
   BOOLEAN     UpArrowFlag;	/* Up arrow clicked on      */
   BOOLEAN     DownArrowFlag;	/* Down arrow clicked on    */
   BOOLEAN     DelayFlag;	/* Do the scroll delay      */

   WORD	       done;
   WORD        event;	   	/* evnt_multi event    		     */
   WORD        scancode;   	/* evnt_multi scan code returned     */
   WORD        nclicks;	   	/* evnt_multi nclicks returns        */
   MOBLK       m1;	   	/* evnt_multi M1 Mouse Rectangle     */
   WORD        mn_mask;		/* event multi mask 		     */
   WORD	       locount;		/* event multi timer - locount       */
   WORD        hicount;		/* event multi timer - hicount       */
   WORD	       buff[6]; 	
   WORD	       button;
   WORD	       rets[4];


   DelayFlag = TRUE;		/* Do the delay just once   */
   done      = FALSE;
   button    = 0;


   m1.m_out = TRUE;	/* Look for leaving this menu item */
   ob_actxywh( ( LONG )MTREE( MenuPtr ), cur_obj, ( GRECT *)&m1.m_x );
   mn_mask = MU_BUTTON | MU_M1 | MU_TIMER;

   /* In order to get here, cur_obj cannot be NIL. */
   do
   {
       DrawFlag  = FALSE;			/* Don't redraw yet */
       Direction = NO_ARROW;			/* Set  NO direction*/
 
       /* Check Up Arrow and update offset if necessary   
        * Make sure we don't scroll past the top of the menu.
        */
       if( ( cur_obj == MTOP_OBJ( MenuPtr ) ) &&
	   ( MTOP_OBJ( MenuPtr ) != MSCROLL( MenuPtr ) )
         )
       {
	 MOFFSET( MenuPtr ) -= 1;		/* adjust offset   */
	 DrawFlag  = TRUE;			/* YES - So REDRAW */
	 Direction = UP_ARROW; 			/* Set direction   */
       }

       /* Check Down Arrow and update offset if necessary
        * Make sure we don't scroll past the bottom of the menu.
        */
       if( ( cur_obj == MB_OBJ( MenuPtr ) ) &&
	   ( MB_OBJ( MenuPtr ) != MLAST_CHILD( MenuPtr ) )
         )
       {
         MOFFSET( MenuPtr ) += 1;		/* adjust offset    */
         DrawFlag  = TRUE;			/* YES - So Redraw  */
         Direction = DOWN_ARROW;		/* Set direction    */
       }

       if( DrawFlag )				/* Do we redraw?    */
       {					/* Set the flags    */
          UpArrowFlag   = ( MTOP_OBJ( MenuPtr ) != MSCROLL( MenuPtr ) );
	  DownArrowFlag = ( MB_OBJ( MenuPtr ) != MLAST_CHILD( MenuPtr ) );




          /* get the clipping Rectangle */
	  clip = *( GRECT *)&MTREE( MenuPtr )[ MTOP_OBJ( MenuPtr )].ob_x;

          ob_offset( ( LONG )MTREE( MenuPtr ), MTOP_OBJ( MenuPtr ), &clip.g_x, &clip.g_y );

	  /* This is MAX_MENU_HEIGHT because to get here we needed to
           * scroll the menu, therefore, its automatically, MAX_MENU_HEIGHT
           */

	  /* The height is the number of visible objects in the scrolling
	   * area - set by ( BOTTOM - TOP ) + 1 == # of objects
 	   *
	   * Changed to "HEIGHT - ( SCROLL - FIRST )" cjg 06/10/93
	   */
	   clip.g_h *= ( MAX_MENU_HEIGHT - ( MSCROLL( MenuPtr ) - MFIRST_CHILD( MenuPtr ))  );

	  /* 
	   * Adjust for the presence of both an Up and down arrow.
	   * There's at least one of them, otherwise, we wouldn't be
           * here...
	   */
	  clip.g_h -= ( 2 * gl_hchar );
	  clip.g_y += gl_hchar;

          rc_intersect( &gl_rfull, &clip );        /* Setup the Source rectangle*/
          rect = clip;
	  rc_2xy( &clip, ( WORD *)&pxy[0] );
 	  
          if( Direction == UP_ARROW )	       /* Setup DESTINATIN Rectangle*/
            clip.g_y += gl_hchar;	       /* Either UP....		    */
           
          if( Direction == DOWN_ARROW )	       /* Or DOWN...		    */
            clip.g_y -= gl_hchar;

          rc_intersect( &gl_rfull, &clip );       /* Clip to the desktop       */
          rc_2xy( &clip, ( WORD *)&pxy[4] );

          clip = rect;			       /* setup clipping rectangle  */
          rc_intersect( &gl_rfull, &clip );
	  gsx_sclip( &clip );

          /* BLIT the screen portion in the proper direction */ 
	  gsx_moff();
          vro_cpyfm( 3, pxy, ( WORD*)&location,(WORD*)&location);
	  gsx_mon();

	  gsx_sclip( &gl_rscreen );

	  /* Adjust the menu to compensate for the scrolling */
	  MenuScrollAdjust( MenuPtr, MOFFSET( MenuPtr ) ); 

	  if( Direction == UP_ARROW )		/* Scroll - UP ARROW */
	  {
	    /* Redraw the Down arrow if its needed and not already drawn */
	    if( !DownArrowFlag && ( MB_OBJ( MenuPtr ) != MLAST_CHILD( MenuPtr ) ) )
            {
		ob_actxywh( ( LONG )MTREE( MenuPtr), MB_OBJ( MenuPtr ), &rect );
		MTREE( MenuPtr )[ MB_OBJ( MenuPtr ) ].ob_state = NORMAL;
		ObjcDraw( MTREE( MenuPtr ), MPARENT( MenuPtr ), &rect );
            }
	    ob_actxywh( ( LONG )MTREE( MenuPtr ), MTOP_OBJ( MenuPtr ), &rect );

	    if( MTOP_OBJ( MenuPtr ) != MSCROLL( MenuPtr ) )
	    {  /* Draw 1 item...*/
	       rect.g_y += gl_hchar;   
            }
            else
            {  /* Arrow is gone, draw 2 items */
	       rect.g_h += gl_hchar;
            }
          }
	  

          if( Direction == DOWN_ARROW )		/* SCROLL - DOWN ARROW */
          {
	     /* Redraw the Up Arrow if its needed and not already drawn */
             if( !UpArrowFlag && ( MTOP_OBJ( MenuPtr ) != MSCROLL( MenuPtr) ) )
             {
	       MTREE( MenuPtr )[ MTOP_OBJ( MenuPtr )].ob_state = NORMAL;
	       ob_actxywh( ( LONG )MTREE( MenuPtr ), MTOP_OBJ( MenuPtr ), &rect );
               ObjcDraw( MTREE( MenuPtr ), MPARENT( MenuPtr ), &rect );
             }
	     ob_actxywh( ( LONG )MTREE( MenuPtr ), MB_OBJ( MenuPtr ), &rect );

             /* Draw at least one item. */
             rect.g_y -= gl_hchar;
	     if( MB_OBJ( MenuPtr ) == MLAST_CHILD( MenuPtr ) )
             {	/* Arrow is gone, draw 2 items */
		rect.g_h += gl_hchar;
             }
          }
          ObjcDraw( MTREE( MenuPtr ), MPARENT( MenuPtr ), &rect );

	   /* This is the delay when we are already scrolling */
	   if( !DelayFlag )
	   {
	      locount = (WORD)( SCROLL_DELAY & 0x0000ffffL);
	      hicount = (WORD)( SCROLL_DELAY >> 16 );
	   }
       }
       else
       {
	   /* We've reached the end of the menu - scrolling 
	    * Therefore, we'll just wait for a button or mouse rectangle event
            */
	    mn_mask = MU_BUTTON | MU_M1;
	    locount = hicount = 0;
       }


       /* The delay is so that at the first press, there is ONE
        * scroll and then the delay. This way, the user can keep 
        * clicking fast and get only one unit of movement. If the user
        * keeps holding down the key, there is no need for the
        * scroll delay after the first one.
        */
       if( DelayFlag )
       {
	  locount = (WORD)(ARROW_DELAY & 0x0000ffffL);
	  hicount = (WORD)(ARROW_DELAY >> 16);
	  DelayFlag = FALSE;
       }

       event = ev_multi( mn_mask, &m1, 0L,
                         (LONG)(HW(hicount) + LW(locount)),
			 (LONG)( HW(1)|LW((1 << 8) | button )),
			 0x0L,
			 &buff[0] );

       mk.x       = buff[0];
       mk.y       = buff[1];
       mk.buttons = buff[2];
       mk.kstate  = buff[3];
       scancode   = buff[4];
       nclicks    = buff[5];

       if( event & MU_BUTTON )
	   done = TRUE;

       if( event & MU_M1 )
       {
	   done = TRUE;
           ev_button( 1, 1, 0, &rets[0] );
       }


       if( event & MU_TIMER )
       {
	  /* We must get the new object that would be under the mouse
	   * since as we scroll, a new object appears under the arrow.
	   * The blit routines need to know whether or not to draw
	   * based upon the current object and the last menu item in the menu.
	   */
          cur_obj = ob_find( ( LONG )MTREE( MenuPtr ), MPARENT( MenuPtr ),
	                       1, mk.x, mk.y );
   	  if( !cur_obj || ( cur_obj == MPARENT( MenuPtr ) ) ) 
               cur_obj = NIL;
       }
   }while( !done );
   return( TRUE );
}



/* SetDRect()
 * ================================================================
 * Sets the bounding rectangle for dragging the mouse to a submenu.
 * This is called when we drag the mouse from a menu item to a
 * newly displayed submenu.
 *
 * IN: GRECT *DragRect - The new bounding rectangle for the drag.
 *     WORD  mx,my     - The mouse position
 *     GRECT *SubRect  - The target submenu GRECT 
 */
VOID
SetDRect( DragRect, mx, my, SubRect )
REG GRECT 	*DragRect;	/* the new bounding rect for the drag */
REG WORD	mx;		/* the xpos of the mouse	      */
REG WORD	my;		/* ;the ypos of the mouse	      */
REG GRECT	*SubRect;	/* the target submenu GRECT...        */
{

   /* Handle the HORIZONTAL Position of the rectangle */
   if( mx <= SubRect->g_x )
   {
      DragRect->g_x =  min( mx, SubRect->g_x );
      DragRect->g_w = ( ( SubRect->g_x + SubRect->g_w - 1 ) - DragRect->g_x )+ 1;
   }
   else
   {
      DragRect->g_x = SubRect->g_x;
      DragRect->g_w = max( mx - SubRect->g_x, SubRect->g_w ) + 1;
   }

   /* Handle the Vertical position of the rectangle */
   if( my <= SubRect->g_y )
   {
      DragRect->g_y = min( my, SubRect->g_y );
      DragRect->g_h = ( ( SubRect->g_y + SubRect->g_h - 1 ) - DragRect->g_y ) + 1;
   }
   else
   {
      DragRect->g_y = SubRect->g_y;
      DragRect->g_h = max( my - SubRect->g_y, SubRect->g_h ) + 1;
   }
}


/* GetMouseState()
 * ================================================================
 * Get the object the mouse is over.
 * 
 * IN:  MRETS *mk - mouse structure
 *      MENU_PTR MenuPtr - the menu that we want to check if we're over.
 * OUT: WORD - the object that the mouse is over.
 */
WORD
GetMouseState( mk, MenuPtr )
REG MRETS	*mk;			/* ptr to the mouse structure     */
REG MENU_PTR	MenuPtr;		/* ptr to the node we want checked*/
{
  REG WORD cur_obj;

  cur_obj = ob_find( ( LONG )MTREE( MenuPtr ), MPARENT( MenuPtr ),
		       1, mk->x, mk->y );

  if( !cur_obj || ( cur_obj == MPARENT( MenuPtr ) ) ) 
       cur_obj = NIL;
  return( cur_obj );
}



/* CheckButton()
 * ================================================================
 * Get the mouse state at key locations. Usually found in MU_M2.
 * It is used because since we are getting alot of events,
 * we can miss the key button click.
 */
BOOLEAN
CheckButton( button, mk )
WORD  button;
MRETS *mk;
{
   gr_mkstate( &mk->x, &mk->y, &mk->buttons, &mk->kstate );
   return( ( !button && !mk->buttons ) || ( button && mk->buttons ) );
}
